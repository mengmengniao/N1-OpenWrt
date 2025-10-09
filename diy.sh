#!/bin/bash

#================================================================
# Part 1: 克隆您需要的插件和依赖
#================================================================
# Clone packages
git clone https://github.com/nantayo/My-Pkg clone/my-pkg
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 clone/mosdns
git clone https://github.com/sbwml/v2ray-geodata --depth=1 clone/v2ray-geodata
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall

# Adjust packages
# 注意：这里先不要 clone golang，因为我们下面会用新版的替换
rm -rf feeds/luci/applications/luci-app-passwall feeds/packages/net/mosdns feeds/packages/net/v2ray-geodata
cp -rf clone/amlogic/luci-app-amlogic clone/mosdns/luci-app-mosdns clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/mosdns/mosdns clone/mosdns/v2dat clone/my-pkg/haproxy clone/v2ray-geodata feeds/packages/net/
cp -rf clone/my-pkg/luci-app-mosdns feeds/luci/applications/
sed -i '/docker-compose/d' feeds/luci/applications/luci-app-dockerman/Makefile

# Clean up
rm -rf clone

#================================================================
# Part 2: 替换为新版 Go (sbwml 方案一)
# 这将确保其他需要新版 Go 的包能够正常编译
#================================================================
echo "Replacing golang with new version..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

#================================================================
# Part 3: 为 xray-core 和 xray-plugin 打上兼容性补丁 (sbwml 方案二)
# 核心步骤：让 xray 兼容新版 Go
#================================================================
# 注意: 这一步必须在 `./scripts/feeds install -a` 之后执行，
# 您的 yml 文件设计正确，它在 diy.sh 之后会再次执行 feeds install
# 我们在这里打补丁，以确保源码存在

# 查找 xray-core 的源码目录并应用补丁
XRAY_CORE_DIR=$(find feeds -type d -name "xray-core" | head -n 1)
if [ -d "$XRAY_CORE_DIR" ]; then
    echo "Applying patch to xray-core..."
    # 使用 GITHUB_WORKSPACE 环境变量来确保能从仓库根目录找到 patches 文件夹
    patch -p1 -d "$XRAY_CORE_DIR" < "$GITHUB_WORKSPACE/patches/xray-core-go-1.21-compat.patch"
else
    echo "::warning::xray-core directory not found. Skipping patch."
fi

# 查找 xray-plugin 的源码目录并应用补丁
XRAY_PLUGIN_DIR=$(find feeds -type d -name "xray-plugin" | head -n 1)
if [ -d "$XRAY_PLUGIN_DIR" ]; then
    echo "Applying patch to xray-plugin..."
    patch -p1 -d "$XRAY_PLUGIN_DIR" < "$GITHUB_WORKSPACE/patches/xray-plugin-go-1.21-compat.patch"
else
    echo "::warning::xray-plugin directory not found. Skipping patch."
fi

#================================================================
echo "diy.sh executed successfully!"