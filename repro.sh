#!/bin/sh
# Builds and installs the repro app on a booted iPhone simulator, then runs the e2e suite.
# usage: ./repro.sh [simulator-udid]
set -eu
cd "$(dirname "$0")"
UDID="${1:-$(xcrun simctl list devices booted -j | node -e '
const { devices } = JSON.parse(require("fs").readFileSync(0, "utf8"));
for (const [runtime, list] of Object.entries(devices))
  for (const d of list) if (runtime.includes("iOS") && d.name.startsWith("iPhone")) { console.log(d.udid); process.exit(0); }
')}"
if [ -z "$UDID" ]; then
  echo "Boot an iPhone simulator first, or pass its UDID." >&2
  exit 2
fi
./build.sh "$UDID"
echo "agent-device: $(npx --no-install agent-device --version)"
REPRO_DEVICE="$UDID" npx --no-install e2e run
