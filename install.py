#!/usr/bin/env python3
"""Install the Burp desktop JAR on Linux. Uses only Python's standard library."""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import shlex
import subprocess
import sys
import tempfile
from html.parser import HTMLParser
from http.client import HTTPException
from urllib.parse import parse_qs, urlencode, urlsplit
from urllib.request import Request, urlopen
import zipfile

SOURCE_DIR = Path(__file__).resolve().parent
RELEASES_URL = "https://portswigger.net/burp/releases"
DEFAULT_VERSION = "2026.10.1"
VERSION_PATTERN = r"[0-9]{4}\.[0-9]+(?:\.[0-9]+)*"
JAVA_OPTIONS = [
    "-noverify",
    "--add-opens=java.desktop/javax.swing=ALL-UNNAMED",
    "--add-opens=java.base/java.lang=ALL-UNNAMED",
    "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED",
    "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED",
    "--add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED",
]


class InstallError(Exception):
    """A failure that can be explained directly to the user."""


def version_argument(value):
    if not re.fullmatch(VERSION_PATTERN, value):
        raise argparse.ArgumentTypeError("use a version such as 2026.10.1")
    return value


def limit_argument(value):
    if not re.fullmatch(r"[0-9]+", value) or not 1 <= int(value) <= 1000:
        raise argparse.ArgumentTypeError("limit must be a whole number from 1 to 1000")
    return int(value)


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument("-v", "--version", type=version_argument, help="install exactly this version")
    parser.add_argument("-l", "--list-versions", action="store_true", help="list versions and channels, then exit")
    parser.add_argument("-n", "--limit", type=limit_argument, default=10, metavar="COUNT", help="number of versions to list (default: 10; max: 1000)")
    parser.add_argument("-y", "--defaults", action="store_true", help="no prompts; newest valid local JAR or pinned default")
    parser.add_argument("-d", "--install-dir", type=Path, default=SOURCE_DIR, metavar="DIR", help="installation directory (default: script directory)")
    parser.add_argument("-j", "--java-path", type=Path, metavar="FILE", help="full path to Java 21 or newer")
    return parser.parse_args(argv)


# Release discovery: filter desktop releases before applying the requested limit.
class ReleasePage(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.years = set()
        self.releases = []
        self.channels = []
        self.label_parts = None
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "label" and "label" in attrs.get("class", "").split():
            self.label_parts = []
        if tag != "a":
            return
        url = urlsplit(attrs.get("href") or "")
        if url.netloc not in ("", "portswigger.net") or url.scheme not in ("", "https"):
            return
        if url.path == "/burp/releases/archive":
            for year in parse_qs(url.query).get("y", []):
                if re.fullmatch(r"[0-9]{4}", year):
                    self.years.add(year)
        match = re.fullmatch(r"/burp/releases/professional-community(?:-edition)?-([0-9]{4}(?:-[0-9]+)+)", url.path)
        if match:
            self.releases.append((match[1].replace("-", "."), url.path))

    def handle_data(self, text):
        if self.label_parts is not None:
            self.label_parts.append(text)

    def handle_endtag(self, tag):
        if tag == "label" and self.label_parts is not None:
            label = " ".join("".join(self.label_parts).split())
            if label and label not in self.channels:
                self.channels.append(label)
            self.label_parts = None


def get_text(url):
    request = Request(url, headers={"User-Agent": "BurpSuite-Pro-installer"})
    try:
        with urlopen(request, timeout=45) as response:
            encoding = response.headers.get_content_charset() or "utf-8"
            return response.read().decode(encoding)
    except (HTTPException, UnicodeError, LookupError) as error:
        raise InstallError("Could not read {}: {}".format(url, error)) from error


def parse_feed(text, limit):
    rows = json.loads(text)["ResultSet"]["Results"]
    if not isinstance(rows, list):
        raise ValueError("invalid release list")
    releases = {}
    for row in rows:
        categories = row.get("categories") or []
        if row.get("buildCategory") not in ("desktop", "pro", "professional") and not any(
            category in categories for category in ("Desktop", "Professional")
        ):
            continue
        version = row.get("version", "")
        if not isinstance(version, str) or not re.fullmatch(VERSION_PATTERN, version) or version in releases:
            continue
        channels = row.get("releaseChannels")
        if channels is None:
            channels = []
        if not isinstance(channels, list) or not all(isinstance(label, str) for label in channels):
            raise ValueError("invalid release channels")
        labels = [" ".join(label.split()) for label in channels]
        releases[version] = ", ".join(filter(None, labels)) or "Not specified"
        if len(releases) >= limit:
            break
    return list(releases.items())


def fetch_versions(limit=10):
    known_channels = {}
    try:
        releases = parse_feed(get_text(RELEASES_URL + "/data?pageSize=100"), limit)
        if len(releases) >= limit:
            return releases
        known_channels = dict(releases)
    except (InstallError, OSError, ValueError, KeyError, TypeError, AttributeError):
        # The archive can still work if the feed is unavailable or changes shape.
        pass

    years = ReleasePage(get_text(RELEASES_URL + "/archive")).years
    if not years:
        raise InstallError("Cannot read the release archive. Use -v VERSION to install a specific version.")
    releases = {}
    for year in sorted(years, reverse=True):
        page = ReleasePage(get_text(RELEASES_URL + "/archive?y=" + year))
        for version, path in page.releases:
            if version in releases:
                continue
            channel = known_channels.get(version)
            if not channel or channel == "Not specified":
                labels = ReleasePage(get_text("https://portswigger.net" + path)).channels
                if not labels:
                    raise InstallError("Cannot read the release channel for " + version)
                channel = ", ".join(labels)
            releases[version] = channel
            if len(releases) >= limit:
                return list(releases.items())
    if not releases:
        raise InstallError("No desktop releases found. See " + RELEASES_URL)
    print("Only {} desktop versions are available (requested {}).".format(len(releases), limit), file=sys.stderr)
    return list(releases.items())


def print_versions(releases, numbered=False):
    if not numbered:
        print("{:<16} {}".format("VERSION", "CHANNEL"))
    for index, (version, channel) in enumerate(releases, 1):
        if sys.stdout.isatty() and not os.environ.get("NO_COLOR") and os.environ.get("TERM") != "dumb" and "Early Adopter" in channel:
            channel = "\033[38;5;250m" + channel + "\033[0m"
        prefix = "  {}) ".format(index) if numbered else ""
        print("{}{:<16} {}".format(prefix, version, channel))


# Downloads are staged beside the destination and never executed during validation.
def validate_jar(path):
    try:
        with zipfile.ZipFile(path) as jar:
            manifest = jar.read("META-INF/MANIFEST.MF").decode("utf-8")
            return bool(re.search(r"^Main-Class:[ \t]+\S+", manifest, re.MULTILINE)) and jar.testzip() is None
    except Exception:
        # ZIP readers can also raise decompressor-specific errors on damaged data.
        return False


def download_jar(destination, version):
    temporary = None
    try:
        url = RELEASES_URL + "/download?" + urlencode({"product": "desktop", "version": version, "type": "Jar"})
        request = Request(url, headers={"User-Agent": "BurpSuite-Pro-installer"})
        print("Downloading Burp Suite {}...".format(version))
        with tempfile.NamedTemporaryFile(dir=destination.parent, prefix=destination.name + ".part.", delete=False) as stream:
            temporary = Path(stream.name)
            with urlopen(request, timeout=45) as response:
                shutil.copyfileobj(response, stream, length=1024 * 1024)
        if not validate_jar(temporary):
            raise ValueError("response is not a valid executable JAR; it may be HTML, empty, or corrupt")
        temporary.replace(destination)
    except (OSError, ValueError, HTTPException) as error:
        raise InstallError(
            "Failed to download Burp Suite {}: {}. Download the JAR manually from {}, "
            "save it as {}, then rerun with -v {} and the same -d directory.".format(version, error, RELEASES_URL, destination, version)
        ) from error
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


# Package managers install Java only. Python handles HTTP, JSON, HTML, and ZIP files.
def java_major(path):
    if not path.is_file() or not os.access(path, os.X_OK):
        return 0
    result = subprocess.run([str(path), "-version"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=False, timeout=15)
    match = re.search(r'(?:version\s+["\']?|openjdk\s+)([0-9]+)', result.stdout)
    return int(match[1]) if result.returncode == 0 and match else 0


def find_java(explicit=None):
    if explicit is not None:
        path = explicit.expanduser().resolve()
        if java_major(path) >= 21:
            return path
        raise InstallError("Java at {} is missing, cannot run, or older than 21. Use -j with a valid Java executable.".format(path))
    candidates = [Path("/usr/lib/jvm/java-21-openjdk/bin/java")]
    candidates.extend(sorted(Path("/usr/lib/jvm").glob("java-21-openjdk-*/bin/java")))
    if os.environ.get("JAVA_HOME"):
        candidates.append(Path(os.environ["JAVA_HOME"]) / "bin/java")
    java_on_path = shutil.which("java")
    if java_on_path:
        candidates.append(Path(java_on_path))
    for path in candidates:
        try:
            if java_major(path) >= 21:
                return path.resolve()
        except (OSError, subprocess.SubprocessError):
            continue
    return None


def ensure_java(explicit=None):
    if Path("/etc/arch-release").is_file():
        commands = [["pacman", "-S", "--needed", "--noconfirm", "jdk21-openjdk"]]
    elif Path("/etc/debian_version").is_file():
        commands = [["apt-get", "update"], ["apt-get", "install", "-y", "openjdk-21-jre"]]
    else:
        raise InstallError("Supported Linux distributions: Arch and Debian/Ubuntu/Kali.")
    java = find_java(explicit)
    if java:
        return java
    if not shutil.which("sudo"):
        raise InstallError("Java 21 is missing and sudo is unavailable. Install Java manually and pass -j /full/path/to/java.")
    for command in commands:
        subprocess.run(["sudo"] + command, check=True)
    java = find_java()
    if java is None:
        raise InstallError("Java 21 was not found after installation. Use -j /full/path/to/java.")
    return java


def prompt(message):
    try:
        return input(message).strip()
    except EOFError as error:
        raise InstallError("No input. Use -y to accept defaults, optionally with -v VERSION.") from error


def choose_version(args):
    if args.version:
        return args.version
    if args.defaults:
        versions = set()
        for path in args.install_dir.glob("*.jar"):
            match = re.fullmatch(r"burpsuite_(?:pro|desktop)_v(" + VERSION_PATTERN + r")\.jar", path.name)
            if match and validate_jar(path):
                versions.add(match[1])
        return max(versions, key=lambda value: tuple(map(int, value.split(".")))) if versions else DEFAULT_VERSION
    try:
        releases = fetch_versions(args.limit)
    except (InstallError, OSError, ValueError) as error:
        print("Could not fetch releases: {}. See {}".format(error, RELEASES_URL), file=sys.stderr)
        choice = prompt("Enter a version [{}]: ".format(DEFAULT_VERSION)) or DEFAULT_VERSION
    else:
        print_versions(releases, numbered=True)
        choice = prompt("Select a number, enter a version, or press Enter for the newest listed: ") or "1"
        if re.fullmatch(r"[0-9]+", choice) and 1 <= int(choice) <= len(releases):
            return releases[int(choice) - 1][0]
    if not re.fullmatch(VERSION_PATTERN, choice):
        raise InstallError("Invalid version: " + choice)
    return choice


def check_resources():
    for name in ("burpsuite-professional.desktop", "burpsuite-pro-icon.png"):
        if not (SOURCE_DIR / name).is_file():
            raise InstallError("Required file missing: {}. Keep the repository files together.".format(name))
    loaders = sorted(path for path in SOURCE_DIR.iterdir() if path.is_file() and path.suffix.lower() == ".jar" and "loader" in path.name.lower())
    if not loaders:
        raise InstallError("Bundled loader missing. Restore it from the repository before installing.")
    return loaders


def choose_loader(loaders, defaults):
    selected = next((path for path in loaders if path.name == "h3110w0r1d-y_loader.jar"), loaders[0])
    if not defaults and len(loaders) > 1:
        for index, path in enumerate(loaders, 1):
            print("  {}) {}".format(index, path.name))
        choice = prompt("Select loader (Enter for {}): ".format(selected.name))
        if choice:
            if not re.fullmatch(r"[0-9]+", choice) or not 1 <= int(choice) <= len(loaders):
                raise InstallError("Invalid loader selection.")
            selected = loaders[int(choice) - 1]
    return selected


def desktop_value(value):
    return str(value).replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")


def write_launcher(directory, java, jar, loader):
    target_loader = directory / loader.name
    if loader.resolve() != target_loader.resolve():
        shutil.copy2(loader, target_loader)
    launcher = directory / "burpsuite_pro_launcher"
    arguments = [str(java)] + JAVA_OPTIONS + ["-javaagent:" + str(target_loader), "-jar", str(jar)]
    launcher.write_text("#!/usr/bin/env python3\nimport os, sys\nos.execv({!r}, {!r} + sys.argv[1:])\n".format(str(java), arguments), encoding="utf-8")
    launcher.chmod(0o755)
    icon = directory / "burpsuite-pro-icon.png"
    if SOURCE_DIR.resolve() != directory.resolve():
        shutil.copy2(SOURCE_DIR / icon.name, icon)
    executable = '"' + "".join("\\" + char if char in '\\"`$' else char for char in str(launcher)) + '"'
    template = (SOURCE_DIR / "burpsuite-professional.desktop").read_text(encoding="utf-8")
    desktop = template.replace("REPLACE_EXEC_PATH", desktop_value(executable.replace("%", "%%")))
    desktop = desktop.replace("REPLACE_ICON_PATH", desktop_value(icon))
    apps = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "applications"
    apps.mkdir(parents=True, exist_ok=True)
    (apps / "burpsuite-professional.desktop").write_text(desktop, encoding="utf-8")
    return launcher


def main(argv=None):
    args = parse_args(argv)
    try:
        if args.list_versions:
            print_versions(fetch_versions(args.limit))
            return 0
        if sys.platform != "linux":
            raise InstallError("This installer requires Linux. Use install.ps1 on Windows.")
        if os.geteuid() == 0:
            raise InstallError("Run as your normal user; only Java package installation uses sudo.")
        args.install_dir = args.install_dir.expanduser().resolve()
        if "\n" in str(args.install_dir) or "\r" in str(args.install_dir):
            raise InstallError("Installation path cannot contain line breaks.")
        loaders = check_resources()
        java = ensure_java(args.java_path)
        args.install_dir.mkdir(parents=True, exist_ok=True)
        version = choose_version(args)
        loader = choose_loader(loaders, args.defaults)
        jar = args.install_dir / "burpsuite_pro_v{}.jar".format(version)
        alternative = args.install_dir / "burpsuite_desktop_v{}.jar".format(version)
        if validate_jar(jar):
            print("Reusing " + str(jar))
        elif validate_jar(alternative):
            jar = alternative
            print("Reusing " + str(jar))
        else:
            download_jar(jar, version)
        launcher = write_launcher(args.install_dir, java, jar, loader)
        print("Installation complete: Burp Suite {}\nJava: {}\nLauncher: {}".format(version, java, launcher))
        print("Activation: run these commands to open the selected loader:")
        print("cd -- " + shlex.quote(str(args.install_dir)))
        print(shlex.quote(str(java)) + " -jar " + shlex.quote("./" + loader.name))
        print("Then follow the Activation guide in README.md.")
        return 0
    except (InstallError, OSError, ValueError, subprocess.SubprocessError) as error:
        hint = " See {} or use -v VERSION.".format(RELEASES_URL) if args.list_versions else ""
        print("Error: " + str(error) + hint, file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("\nInstallation cancelled.", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(main())
