#!/bin/bash

# === Part 0: The Go Build Fix (harmless to keep) ===
# This addresses a common build error with Go packages. Keeping it is good practice.
sed -i 's/GO_PKG_TARGET_VARS:=/GO_PKG_TARGET_VARS:=\nexport GOFLAGS:=-buildvcs=false/' feeds/packages/lang/golang/golang.mk

# === Part 1: Clone all source repositories ===
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
git clone https://github.com/fw876/helloworld.git --depth=1 clone/helloworld
git clone https://github.com/chenmoha/luci-app-turboacc.git --depth=1 clone/turboacc
git clone https://github.com/sbwml/luci-app-mosdns.git --depth=1 clone/mosdns

# === Part 2: Organize packages (The Thorough Method) ===
rm -rf feeds/luci/applications/luci-app-passwall
cp -rf clone/amlogic/luci-app-amlogic feeds/luci/applications/
cp -rf clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/turboacc/luci-app-turboacc feeds/luci/applications/
cp -rf clone/helloworld/luci-app-ssr-plus feeds/luci/applications/
cp -rf clone/mosdns/luci-app-mosdns feeds/luci/applications/

# Copy ALL packages from the complex repositories to ensure all dependencies are met.
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

# === Part 3: Clean up ===
rm -rf clone
