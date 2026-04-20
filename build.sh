#!/bin/sh

# Define colors for output messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if the script is running with root privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "[${RED}Error${NC}] This script must be run as root."
	exit 1
fi

echo "=============================="
echo "  TwinkleAgent Build System   "
echo "=============================="
echo ""

# Select the target architecture
echo "Please select the target architecture:"
echo ""
echo "1) x86_64"
echo "2) i686"
echo "3) aarch64"
echo "4) armhf"
echo "5) armsf"
echo "6) exit"
echo ""

while true; do
    read -p "Enter choice [1-6]: " choice
    case $choice in
        1)
            TARGET_TRIPLE="x86_64-linux-musl"
            break
            ;;
        2)
            TARGET_TRIPLE="i686-linux-musl"
            break
            ;;
        3)
            TARGET_TRIPLE="aarch64-linux-musl"
            break
            ;;
        4)
            TARGET_TRIPLE="arm-linux-musleabihf"
            break
            ;;
        5)
            TARGET_TRIPLE="arm-linux-musleabi"
            break
            ;;
        6)
			echo ""
            echo "Exiting build system..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid selection, please enter a number between 1-6.${NC}"
            ;;
    esac
done

echo ""
echo -e "[${BLUE}Info${NC}] The target architecture has been selected: $TARGET_TRIPLE"

# Create the output directory
echo -e "[${BLUE}Info${NC}] Check and create output directory"
mkdir -p build

# Starting compilation
echo -e "[${BLUE}Info${NC}] Starting compilation..."

# Set the compiler
CXX="${TARGET_TRIPLE}-g++"

# Check if the compiler exists
if ! command -v $CXX &> /dev/null; then
    echo -e "[${RED}Error${NC}] Compiler not found!$CXX"
    echo -e "[${YELLOW}Warn${NC}] Please check your PATH environment variable or toolchain installation status and try again."
    exit 1
fi

$CXX cmd/main/main.cpp \
-o build/TwinkleAgent -static -static-libgcc -static-libstdc++ \
-Os -s -ffunction-sections -fdata-sections \
-fno-unwind-tables -fno-asynchronous-unwind-tables \
-Wl,--gc-sections

# Check the result
if [ $? -eq 0 ]; then
    echo -e "[${GREEN}Success${NC}] Compilation completed successfully!"
	echo -e "[${BLUE}Info${NC}] Check the executable file in the ./build directory"
else
    echo -e "[${RED}Error${NC}] Compilation failed!"
    exit 1
fi