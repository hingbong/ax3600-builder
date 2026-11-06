#!/bin/sh
# Disable the AX3600's third radio (QCA9889 on PCIe0) and drop the ath10k-ct
# userspace packages from the device profile.
#
# Run from the top of an openwrt tree: scripts/disable-ath10k-ax3600.sh
#
# The driver is disabled by overriding the pcie0 status at the end of the
# board DTS instead of deleting the node, so this keeps applying when
# upstream reshapes the PCIe/WLAN nodes around it.

set -e

DTS=target/linux/qualcommax/dts/ipq8071-ax3600.dts
IMAGE_MK=target/linux/qualcommax/image/ipq807x.mk

[ -f "$DTS" ] || { echo "error: $DTS not found (wrong tree or DTS moved again)" >&2; exit 1; }
[ -f "$IMAGE_MK" ] || { echo "error: $IMAGE_MK not found" >&2; exit 1; }

if ! grep -q 'ax3600-builder: disable the unused QCA9889' "$DTS"; then
	cat >> "$DTS" <<'EOF'

/* ax3600-builder: disable the unused QCA9889 ath10k radio on PCIe0 */
&pcie0 {
	status = "disabled";
};
EOF
fi

# Device/xiaomi_ax3600 forces ath10k-ct into DEVICE_PACKAGES; strip it again.
# Scope the edit to that profile: other boards in the same file use ath10k too.
awk '
/^define Device\/xiaomi_ax3600$/ { in_block = 1 }
in_block && /DEVICE_PACKAGES/ {
	gsub(/ kmod-ath10k-ct-smallbuffers/, "")
	gsub(/ ath10k-firmware-qca9887-ct/, "")
}
in_block && /^endef$/ { in_block = 0 }
{ print }
' "$IMAGE_MK" > "$IMAGE_MK.tmp"
mv "$IMAGE_MK.tmp" "$IMAGE_MK"

profile=$(sed -n '/^define Device\/xiaomi_ax3600$/,/^endef$/p' "$IMAGE_MK")
if printf '%s\n' "$profile" | grep -q 'ath10k'; then
	echo "error: ath10k packages are still in the xiaomi_ax3600 profile" >&2
	exit 1
fi

echo "ath10k radio disabled; device packages:"
printf '%s\n' "$profile" | grep -n 'DEVICE_PACKAGES'
