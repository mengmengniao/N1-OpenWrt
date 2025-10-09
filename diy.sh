#!/bin/bash

#================================================================
# Part 1: 克隆需要的插件和依赖
#================================================================
# Clone packages
git clone https://github.com/nantayo/My-Pkg clone/my-pkg
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 clone/mosdns
git clone https://github.com/sbwml/v2ray-geodata --depth=1 clone/v2ray-geodata
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
# 克隆 helloworld 仓库
git clone https://github.com/fw876/helloworld --depth=1 clone/helloworld

#================================================================
# Part 2: 调整软件包位置
#================================================================
# 清理可能冲突的旧包
rm -rf feeds/luci/applications/luci-app-passwall feeds/packages/net/mosdns feeds/packages/net/v2ray-geodata
cp -rf clone/amlogic/luci-app-amlogic feeds/luci/applications/
cp -rf clone/mosdns/luci-app-mosdns feeds/luci/applications/
cp -rf clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/my-pkg/luci-app-mosdns feeds/luci/applications/
# 拷贝自定义的后端软件包
cp -rf clone/mosdns/mosdns clone/mosdns/v2dat clone/my-pkg/haproxy clone/v2ray-geodata feeds/packages/net/
cp -rf clone/helloworld/* package/
sed -i '/docker-compose/d' feeds/luci/applications/luci-app-dockerman/Makefile

# 清理临时目录
rm -rf clone

#================================================================
# Part 3: 替换为新版 Go (sbwml 方案一)
#================================================================
echo "Replacing golang with new version..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

#================================================================
# Part 4: 为 xray-core 和 xray-plugin 打上兼容性补丁 (sbwml 方案二)
#================================================================
# 查找 xray-core 的源码目录并应用补丁
# find 命令会同时搜索 feeds 和 package 目录，所以能正确找到 xray-core
XRAY_CORE_DIR=$(find feeds package -type d -name "xray-core" | head -n 1)
if [ -d "$XRAY_CORE_DIR" ]; then
    echo "Applying patch to xray-core..."
    patch -p1 -d "$XRAY_CORE_DIR" < "$GITHUB_WORKSPACE/patches/xray-core-go-1.21-compat.patch"
else
    echo "::warning::xray-core directory not found. Skipping patch."
fi

# 查找 xray-plugin 的源码目录并应用补丁
XRAY_PLUGIN_DIR=$(find feeds package -type d -name "xray-plugin" | head -n 1)
if [ -d "$XRAY_PLUGIN_DIR" ]; then
    echo "Applying patch to xray-plugin..."
    patch -p1 -d "$XRAY_PLUGIN_DIR" < "$GITHUB_WORKSPACE/patches/xray-plugin-go-1.21-compat.patch"
else
    echo "::warning::xray-plugin directory not found. Skipping patch."
fi

#================================================================
echo "diy.sh executed successfully!"