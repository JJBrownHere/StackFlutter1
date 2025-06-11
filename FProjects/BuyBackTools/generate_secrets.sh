#!/bin/bash
# Usage: GOOGLE_SHEETS_API_KEY=xxx API_KEY=yyy ./generate_secrets.sh

cat > lib/secrets.dart <<EOF
const String googleSheetsApiKey = '${AIzaSyCq7Y0ShV5s0-nV5ZB5BsiW8qhXeKwOiwQ}';
const String API_KEY = '${NT5-IKU-RBE-B7T-FX8-ILZ}';
EOF
echo "lib/secrets.dart generated." 