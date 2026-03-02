#!/bin/bash
# Run this script once to download all app icons locally.
# Requires: curl, internet access
# Usage: bash download-icons.sh

mkdir -p images

IDS=(
  "872763741"
  "6746279573"
  "6745224568"
  "6747080826"
  "384838619"
  "429988765"
  "440280028"
  "1201264158"
  "455248468"
  "826575958"
  "882220839"
  "6670708178"
)

echo "Fetching icon URLs from iTunes API..."
RESPONSE=$(curl -s "https://itunes.apple.com/lookup?id=$(IFS=,; echo "${IDS[*]}")")

if [ -z "$RESPONSE" ]; then
  echo "ERROR: Could not reach iTunes API"
  exit 1
fi

echo "$RESPONSE" | python3 -c "
import json, sys, subprocess, os

data = json.load(sys.stdin)
results = data.get('results', [])
print(f'Found {len(results)} apps')

for r in results:
    tid = str(r.get('trackId', ''))
    icon = r.get('artworkUrl512') or r.get('artworkUrl100', '')
    name = r.get('trackName', 'unknown')
    if not tid or not icon:
        continue
    # Use 512px version
    icon = icon.replace('100x100bb', '512x512bb')
    outfile = f'images/icon-{tid}.jpg'
    if os.path.exists(outfile):
        print(f'  SKIP {name} (already exists)')
        continue
    print(f'  Downloading {name} -> {outfile}')
    result = subprocess.run(['curl', '-sL', '-o', outfile, icon], capture_output=True)
    if result.returncode == 0 and os.path.getsize(outfile) > 1000:
        print(f'    OK ({os.path.getsize(outfile)//1024}KB)')
    else:
        print(f'    FAILED')
        os.remove(outfile) if os.path.exists(outfile) else None
"

echo ""
echo "Done. Check the images/ folder."
echo "Icons are now referenced locally in index.html — no more runtime downloads."
