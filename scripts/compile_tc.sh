#!/bin/bash

# Compilation script for report_tc.tex
# This script compiles the LaTeX document with proper handling of bibliography

# Navigate to the whitepaper directory
cd "$(dirname "$0")/../cyberplaza_whitepaper" || exit 1

# Output file name (without extension)
OUTPUT="report_tc"

echo "=========================================="
echo "Compiling ${OUTPUT}.tex"
echo "=========================================="

# First pass: XeLaTeX compilation
echo ""
echo "[1/3] Running XeLaTeX (first pass)..."
xelatex -interaction=nonstopmode "${OUTPUT}.tex"

if [ $? -ne 0 ]; then
    echo "Error: First XeLaTeX compilation failed!"
    exit 1
fi

# Second pass: Biber for bibliography
echo ""
echo "[2/3] Running Biber for bibliography..."
biber "${OUTPUT}"

if [ $? -ne 0 ]; then
    echo "Warning: Biber failed, but continuing..."
fi

# Third pass: XeLaTeX compilation to resolve references
echo ""
echo "[3/3] Running XeLaTeX (second pass)..."
xelatex -interaction=nonstopmode "${OUTPUT}.tex"

if [ $? -ne 0 ]; then
    echo "Error: Second XeLaTeX compilation failed!"
    exit 1
fi

# Optional: Run XeLaTeX one more time to ensure all references are resolved
echo ""
echo "Running XeLaTeX (final pass) to resolve all references..."
xelatex -interaction=nonstopmode "${OUTPUT}.tex"

echo ""
echo "=========================================="
echo "Compilation completed successfully!"
echo "Output: ${OUTPUT}.pdf"
echo "=========================================="

# Clean up auxiliary files (optional - uncomment if needed)
# echo ""
# echo "Cleaning up auxiliary files..."
# rm -f *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.toc

exit 0
