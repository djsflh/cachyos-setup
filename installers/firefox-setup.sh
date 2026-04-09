#!/bin/bash

# ── Ensure Firefox is installed ───────────────────────────────────
run_quiet "Installing Firefox" sudo pacman -Sy --noconfirm --needed firefox

# ── Deploy policies.json ──────────────────────────────────────────
POLICIES_DIR="/usr/lib/firefox/distribution"
sudo mkdir -p "$POLICIES_DIR"

echo "  → Writing Firefox policies.json..."
TMPFILE=$(mktemp)
cat > "$TMPFILE" <<'EOF'
{
  "policies": {
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisableFeedbackCommands": true,
    "DisableFirefoxAccounts": true,
    "DisableRemoteImprovements": true,
    "OverrideFirstRunPage": "",
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      },
      "{74145f27-f039-47ce-a470-a662b129930a}": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi"
      }
    },
    "FirefoxHome": {
      "Search": true,
      "TopSites": false,
      "SponsoredTopSites": false,
      "Highlights": false,
      "Pocket": false,
      "Stories": false,
      "SponsoredPocket": false,
      "SponsoredStories": false,
      "Snippets": false,
      "locked": false
    },
    "UserMessaging": {
      "ExtensionRecommendations": false,
      "FeatureRecommendations": false,
      "UrlbarInterventions": false,
      "SkipOnboarding": true,
      "MoreFromMozilla": false,
      "FirefoxLabs": false,
      "locked": false
    },
    "HttpsOnlyMode": "enabled",
    "DNSOverHTTPS": {
      "Enabled": true,
      "ProviderURL": "https://mozilla.cloudflare-dns.com/dns-query",
      "locked": false,
      "Fallback": false
    },
    "EnableTrackingProtection": {
      "Value": true,
      "locked": false,
      "Cryptomining": true,
      "Fingerprinting": true,
      "EmailTracking": true,
      "SuspectedFingerprinting": true,
      "BaselineExceptions": false,
      "ConvenienceExceptions": false
    },
    "Cookies": {
      "Locked": true,
      "Behavior": "reject-foreign"
    },
    "Homepage": {
      "URL": "about:preferences#privacy"
    }
  }
}
EOF
sudo cp "$TMPFILE" "$POLICIES_DIR/policies.json"
rm "$TMPFILE"
echo "  ✔ policies.json written to $POLICIES_DIR"

# ── Find or create Firefox profile ───────────────────────────────
PROFILE_DIR=$(find "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" -maxdepth 1 -name "*.default-release" 2>/dev/null | head -n 1)

if [ -z "$PROFILE_DIR" ]; then
    echo "  → Creating Firefox profile..."
    timeout 5 firefox --headless 2>/dev/null || true
    PROFILE_DIR=$(find "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" -maxdepth 1 -name "*.default-release" 2>/dev/null | head -n 1)
fi

# ── Write user.js ─────────────────────────────────────────────────
if [ -n "$PROFILE_DIR" ]; then
    echo "  → Writing Firefox user.js..."
    TMPFILE=$(mktemp)
    cat > "$TMPFILE" <<'EOF'
// Strict tracking protection
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("browser.contentblocking.category", "strict");
user_pref("browser.uiCustomization.state", "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"urlbar-container\",\"downloads-button\",\"uBlock0_raymondhill_net-browser-action\",\"_74145f27-f039-47ce-a470-a662b129930a_-browser-action\",\"unified-extensions-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"uBlock0_raymondhill_net-browser-action\",\"_74145f27-f039-47ce-a470-a662b129930a_-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"unified-extensions-area\"],\"currentVersion\":20,\"newElementCount\":2}");

// Disable all telemetry and data collection
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);

// Block AI features
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.sidebar", false);
EOF
    #cp "$TMPFILE" "$PROFILE_DIR/user.js"
    #rm "$TMPFILE"
    #echo "  ✔ user.js written to $PROFILE_DIR"
else
    echo
    echo "  ✘ WARNING: Could not find Firefox profile directory. user.js not written."
    echo "    Launch Firefox once manually, then re-run this installer."
fi

# ── Manual steps reminder ─────────────────────────────────────────
echo
echo "════════════════════════════════════════════════════"
echo "  Firefox setup complete — 1 manual step required: "
echo "════════════════════════════════════════════════════"
echo
echo "  1. Enable extensions in Private Windows:"
echo "     • Open Firefox"
echo "     • Go to about:addons"
echo "     • Click uBlock Origin → check 'Run in Private Windows'"
echo "     • Click ClearURLs   → check 'Run in Private Windows'"
echo
echo "════════════════════════════════════════════════════"
echo
