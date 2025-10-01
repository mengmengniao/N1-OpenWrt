#!/bin/bash

# === Part 1: Clone all source repositories ===
# We only need to clone the main 'all-in-one' repositories
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
git clone https://github.com/fw876/helloworld.git --depth=1 clone/helloworld
git clone https://github.com/chenmoha/luci-app-turboacc.git --depth=1 clone/turboacc
git clone https://github.com/sbwml/luci-app-mosdns.git --depth=1 clone/mosdns

# === Part 2: Organize packages (The Thorough Fix) ===
# Clean any old versions that might conflict
rm -rf feeds/luci/applications/luci-app-passwall

# Copy the LuCI applications to the correct feed directory
cp -rf clone/amlogic/luci-app-amlogic feeds/luci/applications/
cp -rf clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/turboacc/luci-app-turboacc feeds/luci/applications/
# Copy LuCI apps from the 'all-in-one' repos
cp -rf clone/helloworld/luci-app-ssr-plus feeds/luci/applications/
cp -rf clone/mosdns/luci-app-mosdns feeds/luci/applications/

# --- THIS IS THE ULTIMATE FIX ---
# Instead of cherry-picking, copy ALL packages from the complex repositories.
# This ensures all dependencies like v2ray-plugin, dns2socks-rust, v2dat, etc., are included.

# Copy all packages from helloworld repository
# Use a loop to ensure we only copy directories (which are packages)
for dir in clone/helloworld/*; do
  if [ -d "$dir" ]; then
    package_name=$(basename "$dir")
    # We already copied luci-app-ssr-plus, so skip it here
    if [ "$package_name" != "luci-app-ssr-plus" ]; then
      cp -rf "$dir" package/
    fi
  fi
done

# Copy all packages from luci-app-mosdns repository (it includes mosdns, v2dat, etc.)
for dir in clone/mosdns/*; do
  if [ -d "$dir" ]; then
    package_name=$(basename "$dir")
    # We already copied luci-app-mosdns, so skip it here
    if [ "$package_name" != "luci-app-mosdns" ]; then
      cp -rf "$dir" package/
    fi
  fi
done
# --- END OF FIX ---

# === Part 3: Clean up ===
rm -rf clone
