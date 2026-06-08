# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# NTP server
sed -i "s/0.openwrt.pool.ntp.org/ntp.tuna.tsinghua.edu.cn/g" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='1.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='2.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='3.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate

# Speed up feed downloads on GitHub Actions
sed -i "s#git.openwrt.org/feed#github.com/openwrt#g" feeds.conf.default
sed -i "s#git.openwrt.org/project#github.com/openwrt#g" feeds.conf.default

# Add custom feeds
grep -q "^src-git hickory_dns " feeds.conf.default 2>/dev/null || \
	echo "src-git hickory_dns https://github.com/hingbong/hickory-dns-openwrt.git" >> feeds.conf.default
grep -q "^src-git qosmio " feeds.conf.default 2>/dev/null || \
	echo "src-git qosmio https://github.com/qosmio/packages-extra" >> feeds.conf.default
