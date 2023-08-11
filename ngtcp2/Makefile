include $(TOPDIR)/rules.mk

PKG_NAME:=ngtcp2
PKG_VERSION:=0.18.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ngtcp2/ngtcp2/releases/download/v$(PKG_VERSION)
PKG_HASH:=c52ba414c3301e73b17ebc15518039e5f235a75adb9d0537555cbc13ac072ac7

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libngtcp2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library implementing the framing layer of QUIC
  ABI_VERSION:=14
  DEPENDS:=+libwolfsslcpu-crypto +libnghttp3
endef

TARGET_LDFLAGS += \
		  -Wl,-rpath,$(STAGING_DIR)/usr/lib

CONFIGURE_ARGS += \
		  --enable-lib-only \
		  --with-wolfssl

define Build/Configure
  $(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/crypto/wolfssl/.libs/libngtcp2_crypto_wolfssl.{a,la,so*} $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/.libs/libngtcp2.{a,la,so*} $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/crypto/wolfssl/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/lib/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/lib/includes/ngtcp2 $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/crypto/includes/ngtcp2 $(1)/usr/include
endef

define Package/libngtcp2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/crypto/wolfssl/.libs/libngtcp2_crypto_wolfssl.so* $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/.libs/libngtcp2.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libngtcp2))
