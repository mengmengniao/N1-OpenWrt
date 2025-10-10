#!/bin/bash

#================================================================
# Part 1: 克隆需要的插件和依赖 ( openwrt 22.03 )
#================================================================
# Clone packages
git clone https://github.com/nantayo/My-Pkg clone/my-pkg
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 clone/mosdns
git clone https://github.com/sbwml/v2ray-geodata --depth=1 clone/v2ray-geodata
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
git clone https://github.com/fw876/helloworld --depth=1 clone/helloworld
# Argon 主题仓库
git clone https://github.com/jerrykuku/luci-theme-argon --depth=1 clone/argon

#================================================================
# Part 2: 调整软件包位置 
#================================================================
# 清理可能冲突的旧包
rm -rf feeds/luci/applications/luci-app-passwall feeds/packages/net/mosdns feeds/packages/net/v2ray-geodata

# 拷贝自定义 LuCI 界面
cp -rf clone/amlogic/luci-app-amlogic feeds/luci/applications/
cp -rf clone/mosdns/luci-app-mosdns feeds/luci/applications/
cp -rf clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/my-pkg/luci-app-mosdns feeds/luci/applications/
cp -rf clone/helloworld/luci-app-ssr-plus feeds/luci/applications/

# 拷贝自定义的后端软件包
cp -rf clone/mosdns/mosdns clone/mosdns/v2dat clone/my-pkg/haproxy clone/v2ray-geodata feeds/packages/net/

# 拷贝 helloworld 的所有后端依赖包，但排除v2ray-core 以避免冲突
cp -rf clone/helloworld/dns2socks-rust package/
cp -rf clone/helloworld/microsocks package/
cp -rf clone/helloworld/shadow-tls package/
cp -rf clone/helloworld/shadowsocks-rust package/
cp -rf clone/helloworld/shadowsocksr-libev package/
cp -rf clone/helloworld/simple-obfs package/
cp -rf clone/helloworld/tcping package/
cp -rf clone/helloworld/trojan package/
cp -rf clone/helloworld/tuic-client package/

# 新增：拷贝 Argon 主题和配置程序到 package 目录
cp -rf clone/argon/luci-theme-argon package/
cp -rf clone/argon/luci-app-argon-config package/

#================================================================
# Part 2.5: 修改 Makefile
#================================================================
echo "Patching luci-app-ssr-plus Makefile to remove unused dependencies..."
SSR_PLUS_MAKEFILE="feeds/luci/applications/luci-app-ssr-plus/Makefile"
if [ -f "$SSR_PLUS_MAKEFILE" ]; then
    sed -i '/shadowsocks-libev-ss-local/d' "$SSR_PLUS_MAKEFILE"
    sed -i '/shadowsocks-libev-ss-redir/d' "$SSR_PLUS_MAKEFILE"
    sed -i '/shadowsocks-libev-ss-server/d' "$SSR_PLUS_MAKEFILE"
fi


rm -rf clone

#================================================================
# Part 3: 替换为新版 Go (openwrt 22.03 )
#================================================================
echo "Replacing golang with new version..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

#================================================================
# Part 4: 为 xray-core 打补丁 
#================================================================
# 查找 xray-core 的源码目录并应用补丁
XRAY_CORE_DIR=$(find feeds package -type d -name "xray-core" | head -n 1)
if [ -d "$XRAY_CORE_DIR" ]; then
    echo "Applying patch to xray-core..."
    patch -p1 -d "$XRAY_CORE_DIR" < "$GITHUB_WORKSPACE/patches/xray-core-go-1.21-compat.patch"
fi

# 查找 xray-plugin 的源码目录并应用补丁
XRAY_PLUGIN_DIR=$(find feeds package -type d -name "xray-plugin" | head -n 1)
if [ -d "$XRAY_PLUGIN_DIR" ]; then
    echo "Applying patch to xray-plugin..."
    patch -p1 -d "$XRAY_PLUGIN_DIR" < "$GITHUB_WORKSPACE/patches/xray-plugin-go-1.21-compat.patch"
fi

#================================================================
echo "diy.sh executed successfully!"