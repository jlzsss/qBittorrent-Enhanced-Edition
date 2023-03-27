#
# Copyright (C) 2017-2020
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qBittorrent-Enhanced-Edition
PKG_VERSION:=4.5.0.10
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/c0re100/qBittorrent-Enhanced-Edition/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/qBittorrent-Enhanced-Edition-release-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:qbittorrent:qbittorrent

PKG_BUILD_DEPENDS:=qttools

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=BitTorrent
	DEPENDS:=+libgcc +libstdcpp \
		+rblibtorrent \
		+libopenssl \
		+qt5-core \
		+qt5-network \
		+qt5-sql \
		+qt5-xml \
		+zlib
	TITLE:=bittorrent client programmed in C++ / Qt
	URL:=https://www.qbittorrent.org/
	PROVIDES:=qBittorrent
endef

define Package/$(PKG_NAME)/description
  qBittorrent is a bittorrent client programmed in C++ / Qt that uses
  libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.
  It aims to be a good alternative to all other bittorrent clients out
  there. qBittorrent is fast, stable and provides unicode support as
  well as many features.
endef

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DQT6=OFF \
	-DSTACKTRACE=OFF \
	-DWEBUI=ON \
	-DGUI=OFF \
	-DVERBOSE_CONFIGURE=ON

# The pcre2 is compiled with support for mips16
ifdef CONFIG_USE_MIPS16
  TARGET_CFLAGS += -minterlink-mips16
endif

# Support the glibc
ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -ldl -lrt -lpthread
endif

TARGET_CFLAGS += -std=c++17 -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -flto

# The pentium-mmx with lto will build failed on qt6
ifeq ($(ARCH),i386)
  ifneq ($(findstring pentium-mmx,$(CONFIG_CPU_TYPE)),)
    TARGET_CFLAGS := $(filter-out -flto,$(TARGET_CFLAGS))
    TARGET_LDFLAGS := $(filter-out -flto,$(TARGET_LDFLAGS))
  endif
endif

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qbittorrent-nox $(1)/usr/bin
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
