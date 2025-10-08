#!/bin/bash

echo "INFO: Preparing basic Go build environment..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x --single-branch --depth=1 feeds/packages/lang/golang

echo "INFO: Installing Passwall and its curated packages..."
# 1. 删除 feeds 中的旧版本和潜在冲突项
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,hysteria,v2ray-plugin,xray-plugin}
rm -rf feeds/luci/applications/luci-app-passwall

# 2. 克隆后端软件包和 LuCI 界面到 package 目录
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci

echo "INFO: Adding other LuCI applications..."

# 克隆 helloworld 仓库luci-app-ssr-plus
git clone https://github.com/fw876/helloworld --depth=1 package/helloworld-temp
cp -rf package/helloworld-temp/luci-app-ssr-plus feeds/luci/applications/

# 添加其他插件
git clone https://github.com/ophub/luci-app-amlogic --depth=1 package/luci-app-amlogic
git clone https://github.com/chenmoha/luci-app-turboacc.git --depth=1 package/luci-app-turboacc
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 package/mosdns


echo "INFO: Cleaning up temporary files..."
rm -rf package/helloworld-temp

echo "SUCCESS: Your custom configuration is complete!"
