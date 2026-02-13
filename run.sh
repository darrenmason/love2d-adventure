#!/bin/bash
# Run script for the Point-and-Click Adventure Game

# Check if LÖVE2D is installed
if ! command -v love &> /dev/null; then
    echo "LÖVE2D is not installed!"
    echo ""
    echo "Please install LÖVE2D from https://love2d.org/"
    echo ""
    echo "On Ubuntu/Debian:"
    echo "  sudo apt install love"
    echo ""
    echo "On Arch Linux:"
    echo "  sudo pacman -S love"
    echo ""
    echo "On macOS (with Homebrew):"
    echo "  brew install love"
    exit 1
fi

# Run the game
echo "Starting Point-and-Click Adventure Game..."
love "$(dirname "$0")"
