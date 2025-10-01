#!/bin/bash

# Add packages
git clone https://github.com/ophub/luci-app-amlogic --depth=1 clone/amlogic
git clone https://github.com/xiaorouji/openwrt-passwall --depth=1 clone/passwall
# --- 新增 ---
git clone https://github.com/fw876/helloworld.git --depth=1 clone/helloworld
git clone https://github.com/chenmoha/luci-app-turboacc.git --depth=1 clone/turboacc
git clone https://github.com/sbwml/luci-app-mosdns.git --depth=1 clone/mosdns

# Update packages
rm -rf feeds/luci/applications/luci-app-passwall
# --- 修改下面这一行，把新增的包加进去 ---
cp -rf clone/amlogic/luci-app-amlogic clone/passwall/luci-app-passwall clone/helloworld/luci-app-ssr-plus clone/turboacc/luci-app-turboacc clone/mosdns/luci-app-mosdns feeds/luci/applications/

# Clean packages
rm -rf clone
