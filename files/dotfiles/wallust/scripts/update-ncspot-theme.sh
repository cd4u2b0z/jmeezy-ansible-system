#!/bin/bash
# Update ncspot config with wallust-generated theme

NCSPOT_CONFIG="$HOME/.config/ncspot/config.toml"
WALLUST_THEME="$HOME/.cache/wallust/ncspot-theme.toml"

if [[ ! -f "$WALLUST_THEME" ]]; then
    exit 0
fi

# Extract theme section from wallust
THEME_CONTENT=$(sed -n '/^\[theme\]/,/^\[/p' "$WALLUST_THEME" | head -n -1)

# Replace theme section in ncspot config
if grep -q '^\[theme\]' "$NCSPOT_CONFIG"; then
    # Create temp file with new theme
    awk -v theme="$THEME_CONTENT" '
        /^\[theme\]/ { in_theme=1; print theme; next }
        in_theme && /^\[/ { in_theme=0 }
        !in_theme { print }
    ' "$NCSPOT_CONFIG" > "$NCSPOT_CONFIG.tmp"
    mv "$NCSPOT_CONFIG.tmp" "$NCSPOT_CONFIG"
fi
