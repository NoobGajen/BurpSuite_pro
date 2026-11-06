<p align="center"><img src="https://portswigger.net/burp/communitydownload/images/burp-pro-logo.svg" alt="Burp Suite Professional logo" width="360" height="260"></p>

<h1 align="center">Welcome to <b>Burp Suite loader</b>👋</h1>

A simple and automated installer for Burp Suite Professional with loader activation. Supports Arch Linux and Debian-based systems. Includes loaders by h3110w0r1d-y and x-ai.

**Note:** For commercial use, please purchase genuine software from PortSwigger

---

## 📑 Table of Contents

- [Quick Start](#-quick-start)
- [Provider Activation](#provider-activation-one-time-setup)
- [Burp Suite Professional Download](#burp-suite-professional-download-optional)
- [Installation](#-installation)
  - [Automated Installation](#automated-installation)
  - [Arch Linux Manual Installation](#installation-steps-for-burp-suite-professional-on-arch-linux)
  - [Debian/Ubuntu/Kali Manual Installation](#installation-steps-for-burp-suite-professional-on-debianubuntukali)
- [Java Helper Commands](#java-helper-command-for-injecting-previously-downloaded-activator-into-burp)
- [Troubleshooting](#-troubleshooting)
- [Discussion](#-discussion)
- [Acknowledgements](#-acknowledgements)

---

## ⚡ Quick Start

```bash
git clone https://github.com/NoobGajen/BurpSuite_pro.git
cd BurpSuite_pro
./install.sh
# Activate Burp Suite (one-time setup)
# Arch Linux: /usr/lib/jvm/java-21-openjdk/bin/java
# Debian/Kali: /usr/lib/jvm/java-21-openjdk-amd64/bin/java
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -jar h3110w0r1d-y_loader.jar  # Debian/Kali
# OR
/usr/lib/jvm/java-21-openjdk/bin/java -jar h3110w0r1d-y_loader.jar  # Arch Linux
```

---
## Provider Activation (One-time setup)

Before using Burp Suite for the first time, you need to activate it:

```bash
# Arch Linux: /usr/lib/jvm/java-21-openjdk/bin/java
# Debian/Kali: /usr/lib/jvm/java-21-openjdk-amd64/bin/java
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -jar h3110w0r1d-y_loader.jar  # Debian/Kali
# OR
/usr/lib/jvm/java-21-openjdk/bin/java -jar h3110w0r1d-y_loader.jar  # Arch Linux
```

Once the loader GUI opens:
1. Change the License Text to something like "licensed to yourName" (or whatever you prefer)
2. Copy the license key from the h3110w0r1d-y_loader.jar license section
3. Open Burp Suite and click the "Continue with Burp Suite Professional" button, then paste the license key in the activation section, and click Next
4. Choose Manual Activation in Burp Suite
5. Click on Copy Request in Burp Suite
6. Paste the request into the Activation Request section in h3110w0r1d-y_loader.jar
7. Copy the activation response text from h3110w0r1d-y_loader.jar
8. Paste it into the response field in Burp Suite or click the Paste Response button
9. Click Next to complete activation

**Note:** This is a one-time step for activating Burp Suite. `Now you are ready to use Burp Suite Professional from Application menu`.

---

## Burp Suite Professional Download (optional)

Download the latest version from PortSwigger or specify a version:

```bash
# Example: Download version 2026.10.1
wget -O burpsuite_pro.jar --quiet --show-progress "https://portswigger.net/burp/releases/download?product=desktop&version=2026.10.1&type=Jar"

# To download a different version, replace 2026.10.1 with your desired version
```

**Important:** Download the Burpsuite professional jar file from official site if the command is not working: https://portswigger.net/burp/releases#professional

---

## 🚀 Installation

⚠️ **Note:** We strongly advise **against** downloading any all-in-one installer for security reasons. Instead, follow the steps provided in this repository to download Burp Pro from an authentic source and activate it using the available loader.

### Automated Installation

The provided `install.sh` script supports both Arch Linux and Debian-based systems (Ubuntu, Kali Linux, etc.):

```bash
# Run the installation script
./install.sh
```

The script will:
- **Arch Linux**: Install wget and jdk21-openjdk
- **Debian/Ubuntu/Kali**: Install wget, file, and openjdk-21-jdk (or 17 for older releases)
- Download Burp Suite Professional JAR from PortSwigger (default: 2026.10.1)
- Use h3110w0r1d-y_loader.jar from the repository (or download if missing)
- Create a `burpsuite_pro_launcher` executable in the current directory
- Install the `.desktop` file to your application menu with full paths
- Provide instructions for launching Burp Suite

**Usage:**
```bash
./install.sh                    # Interactive mode
./install.sh --version 2026.10.1  # Specific version
./install.sh --defaults         # No prompts
./install.sh --help             # Show help
```

After installation, you can launch Burp Suite from your application menu or by running `./burpsuite_pro_launcher`.

### Provider Activation (One-time setup)

Before using Burp Suite for the first time, you need to activate it:

```bash
# Arch Linux: /usr/lib/jvm/java-21-openjdk/bin/java
# Debian/Kali: /usr/lib/jvm/java-21-openjdk-amd64/bin/java
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -jar h3110w0r1d-y_loader.jar  # Debian/Kali
# OR
/usr/lib/jvm/java-21-openjdk/bin/java -jar h3110w0r1d-y_loader.jar  # Arch Linux
```

Once the loader GUI opens:
1. Change the License Text to something like "licensed to yourName" (or whatever you prefer)
2. Copy the license key from the h3110w0r1d-y_loader.jar license section
3. Open Burp Suite and click the "Continue with Burp Suite Professional" button, then paste the license key in the activation section, and click Next
4. Choose Manual Activation in Burp Suite
5. Click on Copy Request in Burp Suite
6. Paste the request into the Activation Request section in h3110w0r1d-y_loader.jar
7. Copy the activation response text from h3110w0r1d-y_loader.jar
8. Paste it into the response field in Burp Suite or click the Paste Response button
9. Click Next to complete activation

**Note:** This is a one-time step for activating Burp Suite.

## Installation Steps for Burp Suite Professional on  <a href="https://archlinux.org"><img src="https://img.shields.io/badge/Arch_Linux-1793D1?&logo=arch-linux&logoColor=white"></a>


### 1. Install dependencies & Java 21:

```bash
paru -S wget jdk21-openjdk --noconfirm
```

**Note:** The package name for Arch Linux is `jdk21-openjdk` (not `openjdk-21-jdk` which is for Debian/Kali).

### 2. Configure system to use Java 21:
```bash
sudo archlinux-java set java-21-openjdk
```

### 3. Download Burp Suite Professional:

```bash
BURP_VERSION="2026.10.1"
wget -O burpsuite_pro_v${BURP_VERSION}.jar --quiet --show-progress "https://portswigger.net/burp/releases/download?product=desktop&version=${BURP_VERSION}&type=Jar"
file burpsuite_pro_v${BURP_VERSION}.jar
```

### 4. Choose and download loader (if not already present):

```bash
wget -O h3110w0r1d-y_loader.jar --quiet --show-progress https://github.com/NoobGajen/BurpSuite_pro/raw/refs/heads/master/h3110w0r1d-y_loader.jar
wget -O x-Ai_loader.jar --quiet --show-progress https://github.com/NoobGajen/BurpSuite_pro/raw/refs/heads/master/x-Ai_loader.jar
```

### 5. Create launcher script:
```bash
cat > burpsuite_pro_launcher << EOF
#!/bin/bash
/usr/lib/jvm/java-21-openjdk/bin/java -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/h3110w0r1d-y_loader.jar -jar $(pwd)/burpsuite_pro_v${BURP_VERSION}.jar &
EOF
```

### 6. Make executable:
```bash
chmod +x burpsuite_pro_launcher
```

### 7. Provider Activation:
```bash
/usr/lib/jvm/java-21-openjdk/bin/java -jar h3110w0r1d-y_loader.jar
```

Once the loader GUI opens:
1. Change the License Text to something like "licensed to yourName" (or whatever you prefer)
2. Copy the license key from the h3110w0r1d-y_loader.jar license section
3. Open Burp Suite and click the "Continue with Burp Suite Professional" button, then paste the license key in the activation section, and click Next
4. Choose Manual Activation in Burp Suite
5. Click on Copy Request in Burp Suite
6. Paste the request into the Activation Request section in h3110w0r1d-y_loader.jar
7. Copy the activation response text from h3110w0r1d-y_loader.jar
8. Paste it into the response field in Burp Suite or click the Paste Response button
9. Click Next to complete activation

**Note:** This is a one-time step for activating Burp Suite.

### 8. Install .desktop file to application menu:
```bash
INSTALL_DIR=$(pwd)
mkdir -p ~/.local/share/applications
sed "s|REPLACE_EXEC_PATH|$INSTALL_DIR/burpsuite_pro_launcher|g" burpsuite-professional.desktop | \
sed "s|REPLACE_ICON_PATH|$INSTALL_DIR/burpsuite-pro-icon.png|g" > ~/.local/share/applications/burpsuite-professional.desktop
```

### 9. Launch Burp Suite:
```bash
./burpsuite_pro_launcher
```

## Installation Steps for Burp Suite Professional on  <a href="https://www.debian.org"><img src="https://img.shields.io/badge/Debian/Ubuntu/Kali-D70A53?&logo=debian&logoColor=white"></a>

### 1. Install dependencies (wget, file, and OpenJDK 21):

```bash
sudo apt update
sudo apt install -y wget file openjdk-21-jdk
```

**Note:** On older Debian releases (like bookworm), Java 21 may not be available. In that case, the script will automatically install OpenJDK 17 instead.

### 2. Download Burp Suite Professional:

```bash
BURP_VERSION="2026.10.1"
wget -O burpsuite_pro_v${BURP_VERSION}.jar --quiet --show-progress "https://portswigger.net/burp/releases/download?product=desktop&version=${BURP_VERSION}&type=Jar"
file burpsuite_pro_v${BURP_VERSION}.jar
```

### 3. Choose and download loader (if not already present):

```bash
wget -O h3110w0r1d-y_loader.jar --quiet --show-progress https://github.com/NoobGajen/BurpSuite_pro/raw/refs/heads/master/h3110w0r1d-y_loader.jar
wget -O x-Ai_loader.jar --quiet --show-progress https://github.com/NoobGajen/BurpSuite_pro/raw/refs/heads/master/x-Ai_loader.jar
```

### 4. Create launcher script:

```bash
cat > burpsuite_pro_launcher << EOF
#!/bin/bash
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/h3110w0r1d-y_loader.jar -jar $(pwd)/burpsuite_pro_v${BURP_VERSION}.jar &
EOF
```

### 5. Make executable:
```bash
chmod +x burpsuite_pro_launcher
```

### 6. Provider Activation:
```bash
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -jar h3110w0r1d-y_loader.jar
```

Once the loader GUI opens:
1. Change the License Text to something like "licensed to yourName" (or whatever you prefer)
2. Copy the license key from the h3110w0r1d-y_loader.jar license section
3. Open Burp Suite and click the "Continue with Burp Suite Professional" button, then paste the license key in the activation section, and click Next
4. Choose Manual Activation in Burp Suite
5. Click on Copy Request in Burp Suite
6. Paste the request into the Activation Request section in h3110w0r1d-y_loader.jar
7. Copy the activation response text from h3110w0r1d-y_loader.jar
8. Paste it into the response field in Burp Suite or click the Paste Response button
9. Click Next to complete activation

**Note:** This is a one-time step for activating Burp Suite.

### 7. Install .desktop file to application menu:
```bash
INSTALL_DIR=$(pwd)
mkdir -p ~/.local/share/applications
sed "s|REPLACE_EXEC_PATH|$INSTALL_DIR/burpsuite_pro_launcher|g" burpsuite-professional.desktop | \
sed "s|REPLACE_ICON_PATH|$INSTALL_DIR/burpsuite-pro-icon.png|g" > ~/.local/share/applications/burpsuite-professional.desktop
```

### 8. Launch Burp Suite:

```bash
./burpsuite_pro_launcher
```

## Java helper command for injecting previously downloaded activator into Burp.

### 1. Updated Java helper command (Recommended)
```bash
# Arch Linux
/usr/lib/jvm/java-21-openjdk/bin/java -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/h3110w0r1d-y_loader.jar -jar burpsuite_pro.jar

# OR Debian/Kali
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/h3110w0r1d-y_loader.jar -jar burpsuite_pro.jar
```

### 2. Previous Java helper command fallback (Parent Repo)
```bash
# Arch Linux
/usr/lib/jvm/java-21-openjdk/bin/java -noverify -Dsun.java2d.d3d=false -Dsun.java2d.noddraw=true --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED -javaagent:$(pwd)/x-Ai_loader.jar -jar burpsuite_pro.jar

# OR Debian/Kali
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -noverify -Dsun.java2d.d3d=false -Dsun.java2d.noddraw=true --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED -javaagent:$(pwd)/x-Ai_loader.jar -jar burpsuite_pro.jar
```


## 🔧 Troubleshooting

### Download returns HTML file instead of JAR
**Problem:** The downloaded file is an HTML document instead of a JAR file.

**Solution:**
- Ensure you're using `product=desktop` in the download URL (not `product=pro`)
- Check that the version number is correct and available on PortSwigger's releases page
- Try downloading directly from [PortSwigger's official site](https://portswigger.net/burp/releases#professional)

### Java version errors
**Problem:** "Unsupported class file major version" or similar Java errors.

**Solution:**
- The script automatically installs Java 21 (or 17 for older systems)
- Verify your Java version: `java -version`
- On Arch Linux: `sudo archlinux-java set java-21-openjdk`
- On Debian/Ubuntu: The script handles this automatically

### Loader not found
**Problem:** Script fails with "No loader found" error.

**Solution:**
- Ensure you're in the repository directory
- Check that loader files exist: `ls -la *loader*.jar`
- The script will download the loader automatically if missing
- Manually download from the [Loader Options](#-loader-options) section

### Permission denied errors
**Problem:** "Permission denied" when running the installer.

**Solution:**
- Make the script executable: `chmod +x install.sh`
- Run with sudo if needed: `sudo ./install.sh`
- Ensure you have write permissions in the installation directory

### Burp Suite won't start
**Problem:** Launcher script runs but Burp Suite doesn't open.

**Solution:**
- Check that Java is installed: `java -version`
- Verify the JAR file exists and is valid: `file burpsuite_pro_v*.jar`
- Ensure the loader file exists: `ls -la h3110w0r1d-y_loader.jar`
- Try running the Java command directly from the [Java Helper Commands](#java-helper-command-for-injecting-previously-downloaded-activator-into-burp) section

---

## 📝 Discussion


If you have questions or better suggestions on how to use it, you can ask [issue](https://github.com/NoobGajen/BurpSuite_pro/issues).
NB! Be prepared to bear the full weight of responsibility for any incorrectly asked questions and general stupidity in my repository. 

## ❤️ Acknowledgements

Special thanks to the loader developers:
- [h3110w0r1d-y](https://github.com/h3110w0r1d-y) - For the recommended loader
- [x-ai](https://github.com/x-ai) - For the default loader from the parent repository
