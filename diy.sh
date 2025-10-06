#!/bin/bash

# === Part 0: The Ultimate Fixes (Combining all discoveries) ===

# 1. Replace the official Go toolchain with sbwml's patched version. (Your key discovery)
echo 'Replacing Go toolchain...'
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x --single-branch --depth=1 feeds/packages/lang/golang

# 2. Replace the official v2ray-geodata with a fresh version. (From the successful case)
echo 'Replacing v2ray-geodata...'
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata --depth=1 feeds/packages/net/v2ray-geodata


# === Part 1: Clone all required packages ===
echo 'Cloning packages...'
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
git clone https://github.com/fw876/helloworld.git --depth=1 clone/helloworld
git clone https://github.com/chenmoha/luci-app-turboacc.git --depth=1 clone/turboacc
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 clone/mosdns

# === Part 2: Organize packages ===
echo 'Organizing packages...'

# Clean old versions first
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/mosdns # Ensure a clean slate for mosdns backend

# Copy LuCI applications
cp -rf clone/amlogic/luci-app-amlogic feeds/luci/applications/
cp -rf clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/turboacc/luci-app-turboacc feeds/luci/applications/
cp -rf clone/helloworld/luci-app-ssr-plus feeds/luci/applications/
cp -rf clone/mosdns/luci-app-mosdns feeds/luci/applications/

# Copy all backend packages and dependencies from the complex repos
# This is a robust way to ensure everything is included.
for dir in clone/helloworld/*; do
  if [ -d "$dir" ]; then
    package_name=$(basename "$dir")
    if [ "$package_name" != "luci-app-ssr-plus" ]; then
      cp -rf "$dir" package/
    fi
  fi
done

for dir in clone/mosdns/*; do
  if [ -d "$dir" ]; then
    package_name=$(basename "$dir")
    if [ "$package_name" != "luci-app-mosdns" ]; then
      cp -rf "$dir" package/
    fi
  fi
done

# === Part 3: Final cleanup ===
echo 'Cleaning up...'
rm -rf clone
