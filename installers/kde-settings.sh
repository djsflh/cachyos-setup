#!/bin/bash
echo "--- Applying KDE settings ---"

# ── Power Management ──────────────────────────────────────────────
PMCFG="$HOME/.config/powermanagementprofilesrc"

# AC Power: When inactive → Do nothing (action=0)
kwriteconfig5 --file "$PMCFG" --group "AC" --group "DPMSControl" --key "idleTime" "600"
kwriteconfig5 --file "$PMCFG" --group "AC" --group "DPMSControl" --key "lockBeforeTurnOff" "0"
kwriteconfig5 --file "$PMCFG" --group "AC" --group "HandleButtonEvents" --key "lidAction" "0"
kwriteconfig5 --file "$PMCFG" --group "AC" --group "SuspendSession" --key "idleTime" "0"
kwriteconfig5 --file "$PMCFG" --group "AC" --group "SuspendSession" --key "suspendThenHibernate" "false"
kwriteconfig5 --file "$PMCFG" --group "AC" --group "SuspendSession" --key "suspendType" "0"

# AC Power: Turn off screen → Never (set to 0 = never)
kwriteconfig5 --file "$PMCFG" --group "AC" --group "DPMSControl" --key "OffAfterIdle" "false"

# Battery: Screen brightness → 70%
kwriteconfig5 --file "$PMCFG" --group "Battery" --group "Display" --key "brightness" "70"
kwriteconfig5 --file "$PMCFG" --group "Battery" --group "Display" --key "brightnessLocked" "false"

# ── Screen Locking ────────────────────────────────────────────────
# Lock screen automatically: Never
kwriteconfig5 --file "$HOME/.config/kscreenlockerrc" \
    --group "Daemon" --key "Autolock" "false"

# Notify KDE of changes
if command -v qdbus &>/dev/null; then
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

echo "KDE settings applied."
