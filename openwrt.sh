# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
grep "10.0.0.1" package/base-files/files/bin/config_generate

# NTP server
sed -i "s/0.openwrt.pool.ntp.org/ntp.tuna.tsinghua.edu.cn/g" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='1.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='2.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
sed -i "/add_list system.ntp.server='3.openwrt.pool.ntp.org'/d" package/base-files/files/bin/config_generate
grep "system.ntp.server" package/base-files/files/bin/config_generate

# Speed up on github actions
sed -i "s#git.openwrt.org/feed#github.com/openwrt#g" feeds.conf.default
sed -i "s#git.openwrt.org/project#github.com/openwrt#g" feeds.conf.default

add_feed() {
    local name="$1"
    local url="$2"
    local entry="src-git $name $url"
    
    if grep -q "^src-git $name " feeds.conf.default 2>/dev/null; then
        echo "Feed '$name' already exists, skipping..."
    else
        echo "$entry" >> feeds.conf.default
        echo "Added feed: $name"
    fi
}

add_feed "hickory_dns" "https://github.com/hingbong/hickory-dns-openwrt.git"
add_feed "qosmio" "https://github.com/qosmio/packages-extra"

cat feeds.conf.default

