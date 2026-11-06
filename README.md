# ax3600-builder

Builds OpenWrt images for the Xiaomi AX3600 (`qualcommax/ipq807x`) from
**upstream [openwrt/openwrt](https://github.com/openwrt/openwrt)** and publishes
them as GitHub releases.

| Branch | Contents |
| --- | --- |
| `master` | Upstream build (this branch) |
| `nss-legacy` | Frozen copy of the previous qosmio/openwrt-ipq NSS build |

## What changed compared to the NSS build

- **Source**: `openwrt/openwrt` (`main`) instead of `qosmio/openwrt-ipq`
  (`main-nss`, unmaintained since 2026-06).
- **Offload**: wired routing/NAT/PPPoE/VLAN is offloaded by the in-tree
  `qca_ppe`/`qca_edma` drivers; the NSS firmware, `qca-nss-dp`, `qca-ssdk`,
  ECM and the NSS SQM scripts are gone.
- **Config**: the 300 KB `.full_config` from the NSS tree is replaced by the
  small seed [`configs/ax3600.config`](configs/ax3600.config). CI copies it to
  `.config` and runs `make defconfig`, so dependencies and renamed symbols are
  resolved by the build system itself. A verify step then fails the build if a
  critical package (LuCI, hickory-dns, odhcpd, OpenSSH, wpad-openssl,
  WireGuard) silently disappeared.
- **Radio**: the unused QCA9889 (ath10k) radio is disabled by
  [`scripts/disable-ath10k-ax3600.sh`](scripts/disable-ath10k-ax3600.sh),
  which appends a `&pcie0 { status = "disabled"; }` override and strips
  `ath10k-ct` from the device profile. A patch is no longer needed, so this
  keeps working when upstream reshapes the DTS.
- **Wi-Fi firmware**: `WLAN.HK.2.12-01460` (qosmio/upstream-wifi-fw, hash-pinned)
  is overlaid on top of the stock `ath11k-firmware-ipq8074` package rather
  than replacing it, so that package's `board-2.bin` stays in place. The
  workflow downloads and verifies the tarball, then copies `q6_fw.*` and
  `m3_fw.*` into `files/lib/firmware/IPQ8074/`.
- **Firewall**: `flow_offloading` and `flow_offloading_hw` are enabled in
  [`files/etc/uci-defaults/uci-settings`](files/etc/uci-defaults/uci-settings);
  without the hardware switch the PPE flow table is never programmed.
- **DNS/DHCP**: unchanged — hickory-dns (feed `hickory_dns`) for DNS, odhcpd
  for DHCPv4/DHCPv6/RA, dnsmasq disabled.
- **Feeds**: only the `hickory_dns` custom feed is added on top of the
  upstream feeds; `qosmio/packages-extra` and `sqm-scripts-nss` are gone.

## Build

The workflow runs on GitHub Actions (`Build AX3600 (upstream)`):

1. Fork this repository and enable Actions.
2. Run **Actions → Build AX3600 (upstream) → Run workflow**.
   - `openwrt_repository` defaults to `openwrt/openwrt`
   - `branch` defaults to `main`
   - `openwrt_commit` optionally cherry-picks upstream SHAs (comma separated)
3. The job caches `openwrt/dl` and the host/toolchain, builds the images and
   publishes a release tagged `ax3600-<date>-<time>`.

Local static checks (no compiler needed):

```sh
python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/ax3600.yaml"))'
sh -n openwrt.sh
sh -n scripts/disable-ath10k-ax3600.sh
sh -n files/etc/uci-defaults/uci-settings
```

## Notes

- `configs/ax3600.config` is intentionally a *seed*: packages are listed by
  name, and `make defconfig` adds their dependencies. To add a package, add one
  `CONFIG_PACKAGE_<name>=y` line — but check that it still exists upstream, or
  the verify step (for critical ones) will catch it.
- The AX3600 has 1 Gbit ports: the PPE offload is mostly about CPU headroom,
  not peak throughput. Wi-Fi frames still cross the host CPU (ath11k has no
  PPE path), so bridged NAS↔wireless traffic is CPU-bound.
