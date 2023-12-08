#!/bin/bash
PUBLIC_KEY="$1"

key_id=$(echo "$PUBLIC_KEY" |\
  openssl rsa -pubin -inform PEM -outform der 2>/dev/null |\
  openssl dgst -sha256 -binary |\
  basenc --base64url -w 0 |\
  tr -d '=')

jq -n --arg key_id "$key_id" '{"key_id":$key_id}'
