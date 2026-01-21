#!/bin/bash

# Test bash file for LSP functionality
echo "Testing bash LSP..."

function greet() {
  local name=$1
  echo "Hello, $name!"
}

# Call the function
greet "LSP Server"

# Check if file exists
if [ -f "/etc/passwd" ]; then
  echo "System file exists"
fi