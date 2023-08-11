include $(TOPDIR)/rules.mk

PKG_NAME:=nghttp3
PKG_VERSION:=0.14.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ngtcp2/nghttp3/releases/download/v$(PKG_VERSION)
PKG_HASH:=b5704b72f7a025292f2ff328e41c41f5e486f8e46c5bb020c68dfa8d35e82727
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libnghttp3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Library implementing the framing layer of HTTP/3
  ABI_VERSION:=14
endef

CONFIGURE_ARGS += \
		  --enable-lib-only

define Build/Configure
  $(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/.libs/libnghttp3.{a,la,so*} $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/lib/includes/nghttp3 $(1)/usr/include
endef

define Package/libnghttp3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/.libs/libnghttp3.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libnghttp3))
