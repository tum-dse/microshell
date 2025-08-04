#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS and install scc
install_scc() {
    echo "scc not found. Installing..."
    
    # Detect OS and package manager
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command_exists apt-get; then
            # Debian/Ubuntu
            echo "Installing scc using snap..."
            sudo snap install scc
        elif command_exists yum; then
            # RHEL/CentOS/Fedora
            echo "Installing scc from GitHub releases..."
            curl -L https://github.com/boyter/scc/releases/latest/download/scc-linux-x86_64 -o /tmp/scc
            chmod +x /tmp/scc
            sudo mv /tmp/scc /usr/local/bin/
        elif command_exists pacman; then
            # Arch Linux
            echo "Installing scc using yay (AUR)..."
            yay -S scc-bin
        else
            echo "Installing scc from GitHub releases (generic Linux)..."
            curl -L https://github.com/boyter/scc/releases/latest/download/scc-linux-x86_64 -o /tmp/scc
            chmod +x /tmp/scc
            sudo mv /tmp/scc /usr/local/bin/
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command_exists brew; then
            echo "Installing scc using Homebrew..."
            brew install scc
        else
            echo "Homebrew not found. Installing scc from GitHub releases..."
            curl -L https://github.com/boyter/scc/releases/latest/download/scc-macos-x86_64 -o /tmp/scc
            chmod +x /tmp/scc
            sudo mv /tmp/scc /usr/local/bin/
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        if command_exists choco; then
            echo "Installing scc using Chocolatey..."
            choco install scc
        elif command_exists scoop; then
            echo "Installing scc using Scoop..."
            scoop install scc
        else
            echo "Please install scc manually from: https://github.com/boyter/scc/releases"
            echo "Or install Chocolatey/Scoop first"
            exit 1
        fi
    else
        echo "Unsupported OS. Please install scc manually from: https://github.com/boyter/scc/releases"
        exit 1
    fi
}

# Check if scc is installed
if ! command_exists scc; then
    install_scc
    
    # Verify installation
    if ! command_exists scc; then
        echo "Error: scc installation failed. Please install manually from: https://github.com/boyter/scc/releases"
        exit 1
    fi
    echo "scc installed successfully!"
fi

# Host code
echo "Baseline Host application Complexity Measurement"
echo "==============================================================="

# Function to run scc with error handling
run_scc() {
    local path=$1
    local app_name=$2
    
    echo "----------------------------------------"
    echo "$app_name"
    echo "----------------------------------------"
    
    if [ -d "$path" ]; then
        scc "$path"
    else
        echo "Warning: Directory '$path' not found. Skipping..."
    fi
    echo
}

# Run complexity measurements
run_scc "examples_sw/apps/audio" "Audio Compression"
run_scc "examples_sw/apps/digi_sign" "Digital Signature"
run_scc "examples_sw/apps/secure" "Secure Storage"
run_scc "examples_sw/apps/signcomp" "Signed Compression"
run_scc "examples_sw/apps/speech" "Speech Recognition"

echo "==============================================================="
echo "Complexity measurement complete!"