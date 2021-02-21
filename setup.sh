#!/bin/bash
tmp_zip_name="config.zip"
config_url=$1
user=$2
pass=$3
config_path="$(realpath $4)"

rm -rf "$config_path"
mkdir "$config_path"

mkdir tmp
cd tmp
wget -O "$tmp_zip_name" "$config_url"
unzip "$tmp_zip_name"
mv config/* "$config_path"
chmod +x "$config_path/update-resolv-conf"
cd .. && rm -rf tmp

# Edits start here
# replace /etc/openvpn with /vpn paths in all files
find "$config_path" -type f -name "*" -print0 | xargs -0 sed -i "s/\/etc\/openvpn\//\/vpn\//g"

echo "$user" >> "$config_path/credentials"
echo "$pass" >> "$config_path/credentials"

# Change output location for logs to stdout
sed -i 's/log \/tmp\/openvpn.log/log \/dev\/stdout/g' "$config_path/ovpn.conf"

