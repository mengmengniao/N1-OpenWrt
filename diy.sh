#!/bin/bash

# Adjust source code
patch -p1 -f < $(dirname "$0")/automount.patch
patch -p1 -f < $(dirname "$0")/luci.patch

# Clone packages
git clone https://github.com/nantayo/My-Pkg clone/my-pkg
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/sbwml/luci-app-mosdns -b v5 --single-branch --depth=1 clone/mosdns
git clone https://github.com/sbwml/packages_lang_golang -b 22.x --single-branch --depth=1 clone/golang
git clone https://github.com/sbwml/v2ray-geodata --depth=1 clone/v2ray-geodata
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
# 克隆 helloworld 仓库luci-app-ssr-plus
git clone https://github.com/fw876/helloworld --depth=1 package/helloworld-temp

# Adjust packages
rm -rf feeds/luci/applications/luci-app-passwall feeds/packages/lang/golang feeds/packages/net/mosdns feeds/packages/net/v2ray-geodata
cp -rf clone/amlogic/luci-app-amlogic clone/mosdns/luci-app-mosdns clone/passwall/luci-app-passwall feeds/luci/applications/
cp -rf clone/golang feeds/packages/lang/
cp -rf clone/mosdns/mosdns clone/mosdns/v2dat clone/my-pkg/haproxy clone/v2ray-geodata feeds/packages/net/
cp -rf clone/my-pkg/luci-app-mosdns clone/my-pkg/luci-app-passwall feeds/luci/applications/
cp -rf package/helloworld-temp/luci-app-ssr-plus feeds/luci/applications/
sed -i '/docker-compose/d' feeds/luci/applications/luci-app-dockerman/Makefile

# Clean packages
rm -rf clone
