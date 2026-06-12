#!/bin/bash
# =============================================
# ONE-STEP MIGRATION SCRIPT
# Run from Mac Terminal while on Salesforce VPN
# =============================================
set -e

echo ""
echo "🚀 MC CCO GTM → Salesforce Internal GitHub Migration"
echo ""

read -sp "Paste your git.soma PAT: " PAT
echo ""

SOMA="git.soma.salesforce.com"
ORG="mc-cco-gtm"

echo "Checking VPN connection..."
if ! curl -sf --connect-timeout 5 -H "Authorization: token ${PAT}" "https://${SOMA}/api/v3/user" > /dev/null 2>&1; then
  echo "❌ Can't reach ${SOMA}. Are you on VPN?"
  exit 1
fi
echo "✅ VPN connected"

WORK=$(mktemp -d)
cd "$WORK"

echo ""
echo "📦 [1/2] Release Tracker..."
curl -sf -X POST -H "Authorization: token ${PAT}" -H "Content-Type: application/json" \
  "https://${SOMA}/api/v3/orgs/${ORG}/repos" \
  -d '{"name":"mcccogtm","description":"Summer 26 SE Release Tracker","private":false}' > /dev/null 2>&1 || true

git clone https://github.com/jstollen/mcccogtm.git tracker 2>/dev/null
cd tracker && git checkout main 2>/dev/null
grep -q "MOVED" index.html 2>/dev/null && git reset --hard HEAD~1 2>/dev/null
git remote add soma "https://${PAT}@${SOMA}/${ORG}/mcccogtm.git"
git push soma main --force 2>/dev/null
echo "✅ Release Tracker pushed"
cd "$WORK"

echo ""
echo "📦 [2/2] Impact Dashboard..."
curl -sf -X POST -H "Authorization: token ${PAT}" -H "Content-Type: application/json" \
  "https://${SOMA}/api/v3/orgs/${ORG}/repos" \
  -d '{"name":"cco-dash","description":"MC CCO GTM Impact Dashboard","private":false}' > /dev/null 2>&1 || true

git clone https://github.com/jstollen/cco-dash.git dashboard 2>/dev/null
cd dashboard && git checkout main 2>/dev/null
grep -q "MOVED" index.html 2>/dev/null && git reset --hard HEAD~1 2>/dev/null
git remote add soma "https://${PAT}@${SOMA}/${ORG}/cco-dash.git"
git push soma main --force 2>/dev/null
echo "✅ Impact Dashboard pushed"
cd "$WORK"

echo ""
echo "🌐 Enabling GitHub Pages..."
for repo in mcccogtm cco-dash; do
  curl -sf -X POST -H "Authorization: token ${PAT}" -H "Content-Type: application/json" \
    "https://${SOMA}/api/v3/repos/${ORG}/${repo}/pages" \
    -d '{"source":{"branch":"main","path":"/"}}' > /dev/null 2>&1 \
    && echo "✅ Pages enabled: ${repo}" || echo "⚠️  Enable Pages manually: ${SOMA}/${ORG}/${repo}/settings"
done

echo ""
echo "========================================="
echo "✅ DONE! Your repos are now at:"
echo "  https://${SOMA}/${ORG}/mcccogtm"
echo "  https://${SOMA}/${ORG}/cco-dash"
echo "========================================="
echo ""
echo "Check each repo's Settings → Pages for the live URLs."
rm -rf "$WORK"
