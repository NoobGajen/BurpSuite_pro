#!/bin/bash

echo "=== Burp Suite Professional Automated Installation ==="
echo ""

# Default version (can be overridden with --version argument)
BURP_VERSION="2026.10.1"
USE_DEFAULTS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            BURP_VERSION="$2"
            shift 2
            ;;
        --defaults)
            USE_DEFAULTS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--version VERSION] [--defaults]"
            echo "  --version VERSION  Specify Burp Suite version (default: 2026.10.1)"
            echo "  --defaults         Use default selections without prompting"
            echo "  --help             Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Using Burp Suite version: $BURP_VERSION"

# Detect OS
if [ -f /etc/arch-release ]; then
    OS="arch"
    echo "Detected OS: Arch Linux"
elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    OS="debian"
    echo "Detected OS: Debian/Ubuntu/Kali"
else
    echo "Error: Unsupported OS. This script supports Arch Linux and Debian-based systems."
    echo "Please follow the manual installation steps in README.md for your distribution."
    exit 1
fi

# Get current directory
INSTALL_DIR="$(pwd)"
echo "Installation directory: $INSTALL_DIR"

# Step 1: Install dependencies
echo ""
echo "Step 1: Installing dependencies..."
if [ "$OS" = "arch" ]; then
    echo "Installing wget and jdk21-openjdk..."
    paru -S wget jdk21-openjdk --noconfirm
elif [ "$OS" = "debian" ]; then
    echo "Installing wget, file, and OpenJDK 21 (or 17 for older releases)..."
    if [ "$EUID" -eq 0 ]; then
        apt update
        apt install -y wget file openjdk-21-jdk || apt install -y wget file openjdk-17-jre-headless
    else
        sudo apt update
        sudo apt install -y wget file openjdk-21-jdk || sudo apt install -y wget file openjdk-17-jre-headless
    fi
fi

# Step 2: Configure system to use Java
echo ""
echo "Step 2: Configuring system to use Java..."
if [ "$OS" = "arch" ]; then
    sudo archlinux-java set java-21-openjdk
elif [ "$OS" = "debian" ]; then
    echo "Java is already configured as default via apt package."
fi

# Step 3: Check for loaders
echo ""
echo "Step 3: Checking for loaders..."

# Find all loader JAR files
LOADERS=($(ls -1 *loader*.jar *Loader*.jar 2>/dev/null | grep -v burpsuite))

if [ ${#LOADERS[@]} -eq 0 ]; then
    # No loaders found, download the recommended one
    echo "No loader found. Downloading recommended h3110w0r1d-y_loader.jar..."
    wget -O h3110w0r1d-y_loader.jar --quiet --show-progress https://github.com/NoobGajen/BurpSuite_pro/raw/refs/heads/master/h3110w0r1d-y_loader.jar
    if [ ! -f "h3110w0r1d-y_loader.jar" ]; then
        echo "Error: Failed to download h3110w0r1d-y_loader.jar"
        exit 1
    fi
    echo "h3110w0r1d-y_loader.jar downloaded successfully."
    LOADER_JAR="h3110w0r1d-y_loader.jar"
elif [ ${#LOADERS[@]} -eq 1 ]; then
    # Only one loader found, use it
    LOADER_JAR="${LOADERS[0]}"
    echo "Found loader: $LOADER_JAR"
else
    # Multiple loaders found, ask user to choose
    echo "Found multiple loader files:"
    loader_index=1
    preferred_index=0
    for loader in "${LOADERS[@]}"; do
        if [ "$loader" = "h3110w0r1d-y_loader.jar" ]; then
            echo "  $loader_index) $loader [RECOMMENDED]"
            preferred_index=$loader_index
        else
            echo "  $loader_index) $loader"
        fi
        ((loader_index++))
    done

    if [ "$USE_DEFAULTS" = true ]; then
        choice=$preferred_index
        echo "Using default selection: $preferred_index"
    else
        read -p "Select loader (1-${#LOADERS[@]}, default: $preferred_index): " choice
        if [ -z "$choice" ]; then
            choice=$preferred_index
        fi
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#LOADERS[@]} ]; then
        LOADER_JAR="${LOADERS[$((choice-1))]}"
        echo "Selected: $LOADER_JAR"
    else
        echo "Invalid selection. Using recommended h3110w0r1d-y_loader.jar"
        LOADER_JAR="h3110w0r1d-y_loader.jar"
    fi
fi

# Step 4: Download Burp Suite Professional if needed
echo ""
echo "Step 4: Checking for Burp Suite Professional..."

# Find all Burp JAR files
BURP_JARS=($(ls -1 burpsuite_pro_v*.jar burpsuite_desktop_v*.jar 2>/dev/null))

# Filter out HTML files (invalid downloads)
VALID_BURP_JARS=()
for jar in "${BURP_JARS[@]}"; do
    file_output=$(file "$jar")
    # Check if file is HTML (invalid download)
    if echo "$file_output" | grep -qi "HTML document"; then
        echo "Warning: Skipping invalid file (HTML instead of JAR): $jar"
        echo "  File type: $file_output"
    else
        VALID_BURP_JARS+=("$jar")
    fi
done
BURP_JARS=("${VALID_BURP_JARS[@]}")

if [ ${#BURP_JARS[@]} -eq 0 ]; then
    # No JAR files found, download the specified version
    BURP_JAR="burpsuite_pro_v${BURP_VERSION}.jar"
    echo "No Burp Suite JAR found. Downloading v${BURP_VERSION}..."
    wget -O "$BURP_JAR" --quiet --show-progress "https://portswigger.net/burp/releases/download?product=desktop&version=${BURP_VERSION}&type=Jar"
    if [ ! -f "$BURP_JAR" ]; then
        echo "Error: Failed to download Burp Suite Professional"
        exit 1
    fi

    # Validate that the downloaded file is actually a JAR file
    if file "$BURP_JAR" | grep -q "HTML"; then
        echo "Error: Downloaded file is HTML (not a JAR). The download link may be invalid or require authentication."
        echo "Please check: https://portswigger.net/burp/releases for the correct download link."
        rm -f "$BURP_JAR"
        exit 1
    fi

    echo "Burp Suite Professional downloaded successfully."
elif [ ${#BURP_JARS[@]} -eq 1 ]; then
    # Only one JAR found, use it
    BURP_JAR="${BURP_JARS[0]}"
    echo "Found Burp Suite JAR: $BURP_JAR"
else
    # Multiple JARs found, ask user to choose
    echo "Found multiple Burp Suite JAR files:"
    jar_index=1
    for jar in "${BURP_JARS[@]}"; do
        echo "  $jar_index) $jar"
        ((jar_index++))
    done

    if [ "$USE_DEFAULTS" = true ]; then
        choice=""
        echo "Using latest version by default"
    else
        read -p "Select Burp Suite JAR (1-${#BURP_JARS[@]}, press Enter for latest/recommended): " choice
    fi

    if [ -z "$choice" ]; then
        # Use the latest version (sort by version)
        BURP_JAR=$(printf "%s\n" "${BURP_JARS[@]}" | sort -V | tail -n 1)
        echo "Selected latest: $BURP_JAR"
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#BURP_JARS[@]} ]; then
        BURP_JAR="${BURP_JARS[$((choice-1))]}"
        echo "Selected: $BURP_JAR"
    else
        echo "Invalid selection. Using latest version"
        BURP_JAR=$(printf "%s\n" "${BURP_JARS[@]}" | sort -V | tail -n 1)
    fi
fi

# Detect Java path based on OS
if [ "$OS" = "arch" ]; then
    JAVA_PATH="/usr/lib/jvm/java-21-openjdk/bin/java"
else
    JAVA_PATH="/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
fi

# Step 5: Create launcher script
echo ""
echo "Step 5: Creating launcher script..."
cat > burpsuite_pro_launcher << EOF_SCRIPT
#!/bin/bash
$JAVA_PATH -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/$LOADER_JAR -jar $(pwd)/$BURP_JAR &
EOF_SCRIPT

# Step 6: Make executable
echo ""
echo "Step 6: Making launcher executable..."
chmod +x burpsuite_pro_launcher

# Step 7: Install .desktop file
echo ""
echo "Step 7: Installing .desktop file for application menu..."
DESKTOP_FILE="burpsuite-professional.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    # Create temporary file with full paths replaced
    sed "s|REPLACE_EXEC_PATH|$INSTALL_DIR/burpsuite_pro_launcher|g" "$DESKTOP_FILE" | \
    sed "s|REPLACE_ICON_PATH|$INSTALL_DIR/burpsuite-pro-icon.png|g" > "$DESKTOP_FILE.tmp"

    # Install to user applications directory
    USER_APPS_DIR="$HOME/.local/share/applications"
    mkdir -p "$USER_APPS_DIR"
    mv "$DESKTOP_FILE.tmp" "$USER_APPS_DIR/$DESKTOP_FILE"
    echo ".desktop file installed to $USER_APPS_DIR/$DESKTOP_FILE"
    echo "Burp Suite Professional will now appear in your application menu."
else
    echo "Warning: $DESKTOP_FILE not found. Skipping desktop file installation."
fi

# Step 8: Installation complete
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Configuration:"
echo "  Burp Suite JAR: $BURP_JAR"
echo "  Loader: $LOADER_JAR"
echo ""
echo "To launch Burp Suite Professional:"
echo "   ./burpsuite_pro_launcher"
echo ""
echo "You can also launch Burp Suite from your application menu."
echo ""
echo "Alternatively, you can run Burp directly with:"
echo "$JAVA_PATH -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$INSTALL_DIR/$LOADER_JAR -jar $INSTALL_DIR/$BURP_JAR"
