#!/bin/bash

echo "🔍 Testing Which-Key Health Check..."

# Run neovim health check for which-key
nvim --headless -c "checkhealth which-key" -c "wq" > /tmp/which-key-health.log 2>&1

# Check if there are any issues
if grep -q "ERROR\|error\|failed" /tmp/which-key-health.log; then
    echo "❌ Which-key health check found issues:"
    cat /tmp/which-key-health.log
else
    echo "✅ Which-key health check passed!"
    if [ -f /tmp/which-key-health.log ]; then
        echo "📋 Health check output:"
        cat /tmp/which-key-health.log
    fi
fi

# Clean up
rm -f /tmp/which-key-health.log