#!/bin/bash

#================================================================
# Part 1: Clone external packages
#================================================================
# Clone packages
git clone https://github.com/ophub/luci-app-amlogic --depth=1 package/amlogic
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata --depth=1 package/v2ray-geodata
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 package/passwall
git clone https://github.com/fw876/helloworld --depth=1 package/helloworld
git clone https://github.com/jerrykuku/luci-theme-argon --depth=1 package/argon

#================================================================
# Part 2: Place packages into correct directory
#================================================================
# Copy LuCI applications
cp -rf package/amlogic/luci-app-amlogic package/
cp -rf package/mosdns/luci-app-mosdns package/
cp -rf package/passwall/luci-app-passwall package/
cp -rf package/helloworld/luci-app-ssr-plus package/
cp -rf package/argon/luci-theme-argon package/
cp -rf package/argon/luci-app-argon-config package/

# Copy backend programs & dependencies
cp -rf package/mosdns/mosdns package/
cp -rf package/mosdns/v2dat package/
cp -rf package/v2ray-geodata package/
# Copy all dependencies for ssr-plus, except xray-core
cp -rf package/helloworld/dns2socks-rust package/
cp -rf package/helloworld/microsocks package/
cp -rf package/helloworld/shadow-tls package/
cp -rf package/helloworld/shadowsocks-rust package/
cp -rf package/helloworld/shadowsocksr-libev package/
cp -rf package/helloworld/simple-obfs package/
cp -rf package/helloworld/tcping package/
cp -rf package/helloworld/trojan package/
cp -rf package/helloworld/tuic-client package/

#================================================================
# Part 3: Replace golang and apply patches
#================================================================
# Replace golang with a newer version to compile xray-core
echo "Replacing golang..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b master feeds/packages/lang/golang

# Patch xray-core for go 1.21+ compatibility
echo "Patching xray-core..."


# The patch logic is still valid and necessary
XRAY_CORE_DIR=$(find feeds package -type d -name "xray-core" | head -n 1)
if [ -d "$XRAY_CORE_DIR" ]; then
    patch -p1 -d "$XRAY_CORE_DIR" < "$GITHUB_WORKSPACE/patches/xray-core-go-1.21-compat.patch"
fi

XRAY_PLUGIN_DIR=$(find feeds package -type d -name "xray-plugin" | head -n 1)
if [ -d "$XRAY_PLUGIN_DIR" ]; then
    patch -p1 -d "$XRAY_PLUGIN_DIR" < "$GITHUB_WORKSPACE/patches/xray-plugin-go-1.21-compat.patch"
fi

#================================================================
# Cleanup
rm -rf package/amlogic package/mosdns package/v2ray-geodata package/passwall package/helloworld package/argon