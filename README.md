<p align="center"><img src="https://portswigger.net/burp/communitydownload/images/burp-pro-logo.svg" alt="Burp Suite Professional logo" width="320"></p>

# Burp Suite installer

Install on Arch Linux, Debian/Ubuntu/Kali/Parrot, or Windows. Professional features require an
appropriate license from <a href="https://portswigger.net/burp/pro" target="_blank" rel="noopener noreferrer">PortSwigger</a>.

## Purpose and licensing

I share this project for students like me who want to learn cybersecurity but
cannot easily afford expensive tools. My goal is to help learners build practical
skills, prepare for a first job, and eventually support the tools they use through
paid licenses or properly licensed access provided by an employer.

Please purchase an appropriate <a href="https://portswigger.net/burp/pro" target="_blank" rel="noopener noreferrer">Burp Suite Professional license from PortSwigger</a>
for professional or commercial work. Professional use requires a valid license;
educational intent does not automatically exempt other uses from licensing requirements.
This project is independent of PortSwigger and is not endorsed by them. Its educational
purpose does not grant permission to bypass licensing or override their terms.

Students looking for a free starting point can use
<a href="https://portswigger.net/burp/communitydownload" target="_blank" rel="noopener noreferrer">Burp Suite Community Edition</a>
and the <a href="https://portswigger.net/web-security" target="_blank" rel="noopener noreferrer">Web Security Academy</a>.
For licensed Professional installations, follow PortSwigger's
<a href="https://portswigger.net/burp/documentation/desktop/getting-started/activating-burp-license" target="_blank" rel="noopener noreferrer">official activation guide</a>.

## Contents

- [Purpose and licensing](#purpose-and-licensing)
- [Quick start](#quick-start): [Linux](#linux) · [Windows](#windows)
- [Activation guide](#activation-guide)
- [Options](#options)
- [Versions and updates](#versions-and-updates)
- [Downloads and manual installation](#downloads-and-manual-installation)
- [Bundled components](#bundled-components)
- [Troubleshooting](#troubleshooting)
- [Uninstall](#uninstall)
- [Development and feedback](#development-and-feedback)

## Quick start

Download and extract the repository ZIP, or clone it:

```bash
git clone https://github.com/NoobGajen/BurpSuite_pro.git
cd BurpSuite_pro
```

### Linux

Requires **Python 3.8+**. Run as your normal user; setup uses `sudo` for Java installation only.

```bash
python3 install.py
```

Choose a Burp version and loader. The default installation directory is the repository directory.
After setup, open **BurpSuite Professional** from your application menu, or run from the installation directory:

```bash
./burpsuite_pro_launcher
```

Continue with the [activation guide](#activation-guide).

### Windows

Use **Windows PowerShell 5.1** or **PowerShell 7**. Windows support is experimental.

```powershell
.\install.ps1 -s
```

Choose a Burp version and loader. The default installation directory is
`$env:LOCALAPPDATA\BurpSuite-Pro`. Missing Java is installed through `winget`.

Open **BurpSuite Professional** from Start or the Desktop shortcut. Shortcuts use the Burp icon,
generated from `burpsuite-pro-icon.png`, and the full path to `javaw.exe`, without a terminal window.

Continue with the [activation guide](#activation-guide).

## Activation guide

### Linux loader

Use the full OpenJDK 21 path for your distribution:

```bash
# Debian / Ubuntu / Kali
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -jar ./h3110w0r1d-y_loader.jar

# Arch Linux
/usr/lib/jvm/java-21-openjdk/bin/java -jar ./h3110w0r1d-y_loader.jar
```

### Windows loader

Use the full path to Java 21 if you have multiple versions installed on your system.

```powershell
java -jar .\h3110w0r1d-y_loader.jar
```

### Activation steps

Once the loader GUI opens:

1. Change the License Text to something like "licensed to **yourName**" (or whatever you prefer).
2. Copy the license key from the `h3110w0r1d-y_loader.jar` license section.
3. Open Burp Suite and click the **Continue with Burp Suite Professional** button.
4. Choose **Manually enter license key**, paste the key copied from the loader (or click **Paste**), then click **Next**.
5. Click **Manual Activation** in Burp Suite.
6. Click **Copy request** in Burp Suite.
7. Paste the copied request into the **Activation Request** section in `h3110w0r1d-y_loader.jar`.
8. Copy the **Activation Response** text from `h3110w0r1d-y_loader.jar`.
9. Paste it into the response field in Burp Suite or click **Paste response** in Burp Suite.
10. Click **Next** to complete activation.

> **Note:** After activation, open Burp Suite Professional from the application menu or desktop shortcut. For setup questions or troubleshooting help, start a [Q&A discussion](https://github.com/NoobGajen/BurpSuite_pro/discussions/categories/q-a). To report a reproducible bug in the installer, [open an issue](https://github.com/NoobGajen/BurpSuite_pro/issues/new/choose).

## Options

<details>
<summary>Show options</summary>

Short flags are shared between platforms. PowerShell uses one dash for long parameter names;
Linux uses two. On Linux, pass short options separately rather than combining them as `-yl`.

| Short flag   | Linux                                    | PowerShell         | Purpose                                                 |
| ------------ | ---------------------------------------- | ------------------ | ------------------------------------------------------- |
| `-v VERSION` | `--version VERSION`                      | `-Version VERSION` | Install an exact version                                |
| `-l`         | `--list-versions`                        | `-ListVersions`    | List versions and exit                                  |
| `-n COUNT`   | `--limit COUNT`                          | `-Limit COUNT`     | List/menu size: default 10, range 1–1000                |
| `-y`         | `--defaults`                             | `-Defaults`        | Use defaults without installer prompts                  |
| `-d DIR`     | `--install-dir DIR`                      | `-InstallDir DIR`  | Set the installation directory                          |
| `-j FILE`    | `--java-path FILE`                       | `-JavaPath FILE`   | Select a Java 21+ executable                            |
| `-s`         | Not available                            | `-DesktopShortcut` | Also create a Desktop shortcut                          |
| `-i`         | Java installation is automatic if needed | `-InstallJava`     | Compatibility flag; missing Java installs automatically |
| `-h`         | `--help`                                 | `-Help`            | Show help                                               |

`-y` suppresses installer questions. Operating-system authentication or dependency elevation
may still require interaction.

</details>

## Versions and updates

<details>
<summary>Show versions and updates</summary>

Release listing is **dynamic**: versions and channels come from
<a href="https://portswigger.net/burp/releases" target="_blank" rel="noopener noreferrer">PortSwigger's releases</a>, not a hardcoded list.
The installer excludes DAST, deduplicates desktop versions, and preserves PortSwigger's release order.
When the JSON feed supplies too few desktop versions, it uses the year-by-year release archive.
This fallback may take longer because channel labels are read from individual release pages.

| Invocation        | Version selection                                                               |
| ----------------- | ------------------------------------------------------------------------------- |
| `-l`              | Show the most recent 10 desktop versions, then exit without installing anything |
| `-l -n 20`        | Show 20 versions; `-n` also controls the interactive selection menu             |
| Interactive setup | Choose a listed version or enter one manually; Enter chooses the newest listed  |
| `-v VERSION`      | Reuse a valid matching local JAR, or download that exact version                |
| `-y` without `-v` | Use the newest valid local JAR; otherwise use the pinned fallback **2026.10.1** |

`-y` does not automatically upgrade to the latest online release.
The interactive list can include Early Adopter releases; the default selection is not restricted to Stable.
Channel names are preserved as supplied. `Early Adopter` appears in light gray in supported terminals.
Redirected output stays plain; set `NO_COLOR=1` to disable highlighting.

Listing failures stop with an error. Interactive setup lets you enter a version if listing fails.
If the entire archive contains fewer versions than requested, listing shows those available with a warning.

To update, list available releases and rerun with the desired version:

```bash
python3 install.py -l
python3 install.py -v 2026.10.1 -y     # Replace with your chosen version
```

```powershell
.\install.ps1 -l
.\install.ps1 -v 2026.10.1 -y          # Replace with your chosen version
```

Reuse the same `-d` value for a custom installation. Setup refreshes the launcher and shortcuts;
older application JARs remain until you remove them.

</details>

## Downloads and manual installation

<details>
<summary>Show downloads and manual installation</summary>

Downloads go to a temporary file before replacing an installed JAR. Both installers require a readable
ZIP/JAR archive with a nonempty `Main-Class` manifest entry. Linux checks every entry's CRC;
Windows reads every entry and checks its expanded length.
HTML error pages saved as `.jar`, empty files, malformed manifests, and truncated archives are rejected.

On failure, setup prints **Failed to download** with manual-download instructions,
cleans up the temporary file, and preserves an existing installed JAR.
These checks validate file format and integrity; they do not authenticate the publisher or scan for malware.

For a manual download:

1. Choose a desktop release on <a href="https://portswigger.net/burp/releases" target="_blank" rel="noopener noreferrer">PortSwigger's official releases page</a>.
2. Download the **JAR**, not a native installer or an HTML page.
3. Save it in your installation directory as `burpsuite_pro_vVERSION.jar` or
   `burpsuite_desktop_vVERSION.jar`, for example `burpsuite_desktop_v2026.10.1.jar`.
4. Rerun setup with `-v VERSION -y` and the same `-d` if applicable. The local JAR is checked before reuse.

</details>

## Bundled components

<details>
<summary>Show bundled components</summary>

The repository includes `h3110w0r1d-y_loader.jar` and `x-Ai_loader.jar`.
Interactive setup offers the available components; `-y` prefers `h3110w0r1d-y_loader.jar`,
then an existing alternative. Missing components must be restored from the repository;
setup does not download these components separately.

The source code, build instructions, and exact upstream versions for these third-party
binaries are not recorded here. Their checksums identify the bundled files; they do not
verify who published them.

| File                      | Credited author                                                                                      | SHA-256                                                            |
| ------------------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `h3110w0r1d-y_loader.jar` | <a href="https://github.com/h3110w0r1d-y" target="_blank" rel="noopener noreferrer">h3110w0r1d-y</a> | `1e288c686963eafc34411d4f94265eb1809492ab57a474848669eb3285a2afb3` |
| `x-Ai_loader.jar`         | <a href="https://github.com/x-ai" target="_blank" rel="noopener noreferrer">x-ai</a>                 | `23499f88ed11fa69e6a9bf5b17594b326ef71c631d28da804f02c3ef08c68150` |

</details>

## Troubleshooting

<details>
<summary>Show troubleshooting</summary>

| Problem                                               | What to check                                                                                                            |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Old Linux command uses `install.sh`                   | Use `python3 install.py`; the Bash installer has been removed                                                            |
| Python is missing on Linux                            | Install Python 3.8+ with your distribution's package manager before running setup                                        |
| Java is missing or too old                            | Pass `-j` with the full Java 21+ executable path; verify that executable with `-version`                                 |
| Download fails or returns HTML                        | Follow the manual-download steps above; the filename extension is not enough                                             |
| Version listing fails                                 | Check internet access and the official releases page; use `-v VERSION` to bypass listing                                 |
| Linux menu entry is missing                           | Run setup as your own user; inspect `${XDG_DATA_HOME:-$HOME/.local/share}/applications/burpsuite-professional.desktop`   |
| Launcher paths no longer exist                        | Keep the installation directory in place, or rerun setup with the new `-d` and `-j` paths                                |
| Windows launch fails                                  | Run the script launcher from PowerShell, then read `launcher.log` and `launcher-error.log` in the installation directory |
| Windows shortcut shows PowerShell or opens a terminal | Rerun the updated installer with `-y -s` and the same installation directory; unpin and repin old taskbar shortcuts      |

If Windows blocks a reviewed script, and your organization's policy permits it, use a process-only invocation:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -l -n 20
```

Generated Windows shortcuts start `javaw.exe` directly and do not run PowerShell scripts.
Group Policy can still prevent running the installer or script launcher. See Microsoft's
<a href="https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies" target="_blank" rel="noopener noreferrer">execution-policy documentation</a>.
For Java requirements, see PortSwigger's
<a href="https://portswigger.net/burp/documentation/desktop/troubleshooting/launch-from-command-line" target="_blank" rel="noopener noreferrer">command-line launch documentation</a>.

</details>

## Uninstall

<details>
<summary>Show uninstall</summary>

Close Burp and preserve any project files you need first.

- **Linux:** Remove the user application-menu entry, generated `burpsuite_pro_launcher`, downloaded
  Burp JARs, and copied component/icon files from your chosen installation directory.
  If you installed in the repository, keep source files you still need.
- **Windows:** Remove the Start Menu and optional Desktop shortcuts, then remove the chosen
  installation directory after preserving your project files.

Java is a separate dependency and is not removed automatically.

</details>

## Development and feedback

<details>
<summary>Show development and feedback</summary>

Check syntax and help without installing anything:

```bash
python3 -m py_compile install.py
python3 install.py -h
```

```powershell
.\install.ps1 -h
```

A real installation and GUI launch still need verification on each supported platform.

Use the <a href="https://github.com/NoobGajen/BurpSuite_pro/issues/new/choose" target="_blank" rel="noopener noreferrer">bug report or feature request forms</a>
for feedback. Bug reports should include your OS, exact command, steps to reproduce, and relevant error output.
Remove private information from logs and screenshots.
See [LICENSE](LICENSE) for the repository's license; Burp Suite and third-party components retain their own licenses.

</details>
