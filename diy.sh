#!/bin/bash

# === Part 1: Clone all source repositories ===
# Clone LuCI apps and repositories containing their dependencies
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
git clone https://github.com/fw876/helloworld.git --depth=1 clone/helloworld
git clone https://github.com/chenmoha/luci-app-turboacc.git --depth=1 clone/turboacc
git clone https://github.com/sbwml/luci-app-mosdns.git --depth=1 clone/mosdns
git clone https://github.com/sbwml/v2dat.git --depth=1 clone/v2dat # Dependency for mosdns

# === Part 2: Organize packages for the build system ===
# First, clean any old versions that might conflict
rm -rf feeds/luci/applications/luci-app-passwall

# Copy the LuCI applications to the correct feed directory
cp -rf clone/amlogic/luci-app-amlogic feeds/luci/applications/
cp -rf clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/helloworld/luci-app-ssr-plus feeds/luci/applications/
cp -rf clone/turboacc/luci-app-turboacc feeds/luci/applications/
cp -rf clone/mosdns/luci-app-mosdns feeds/luci/applications/

# Copy the dependency packages into the main 'package' directory
# The build system will find them here.

# Dependencies from helloworld repo (for ssr-plus) that fix the warnings
cp -rf clone/helloworld/shadowsocksr-libev package/
cp -rf clone/helloworld/shadowsocks-libev package/
cp -rf clone/helloworld/dns2socks package/
cp -rf clone/helloworld/chinadns-ng package/
# Copy all required protocols for full functionality
cp -rf clone/helloworld/hysteria package/
cp -rf clone/helloworld/tuic-client package/
cp -rf clone/helloworld/trojan package/
cp -rf clone/helloworld/v2ray-core package/
cp -rf clone/helloworld/v2ray-plugin package/
cp -rf clone/helloworld/xray-core package/
cp -rf clone/helloworld/xray-plugin package/


# Dependency from v2dat repo (for mosdns)
cp -rf clone/v2dat/v2dat package/

# === Part 3: Clean up ===
rm -rf clone
