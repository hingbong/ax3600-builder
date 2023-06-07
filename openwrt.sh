# luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata

git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
grep "10.0.0.1" package/base-files/files/bin/config_generate

# Default SSID
sed -i 's/.ssid=OpenWrt/.ssid=OpenWrt_AX3600/' package/kernel/mac80211/files/lib/wifi/mac80211.sh
grep "OpenWrt_AX3600" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Listen with HTTP/2
sed -i "s/ssl default_server/ssl default_server http2/g" feeds/packages/net/nginx-util/files/nginx.config
grep "list listen" feeds/packages/net/nginx-util/files/nginx.config


#NTP server
sed -i "s/0.openwrt.pool.ntp.org/ntp.tuna.tsinghua.edu.cn/g" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='1.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='2.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='3.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
grep "system.ntp.server" package/base-files/files/bin/config_generate

