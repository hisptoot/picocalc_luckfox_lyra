################################################################################
#
# sdl2
#
################################################################################

SDL2_VERSION = 2.28.5
SDL2_SOURCE = SDL2-$(SDL2_VERSION).tar.gz
SDL2_SITE = http://www.libsdl.org/release
SDL2_LICENSE = Zlib
SDL2_LICENSE_FILES = LICENSE.txt
SDL2_CPE_ID_VENDOR = libsdl
SDL2_CPE_ID_PRODUCT = simple_directmedia_layer
SDL2_INSTALL_STAGING = YES
SDL2_SUPPORTS_IN_SOURCE_BUILD = NO

SDL2_CONF_OPTS += \
	-DSDL_RPATH=OFF
	-DSDL_ARTS=OFF
	-DSDL_ESD=OFF
	-DSDL_PULSEAUDIO=OFF

# We must enable static build to get compilation successful.
SDL2_CONF_OPTS += -DSDL_STATIC=ON
ifeq ($(BR2_ARM_INSTRUCTIONS_THUMB),y)
SDL2_CONF_ENV += CFLAGS="$(TARGET_CFLAGS) -marm"
endif

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
SDL2_DEPENDENCIES += udev
endif

ifeq ($(BR2_X86_CPU_HAS_SSE),y)
SDL2_CONF_OPTS += -DSDL_SSE=ON
else
SDL2_CONF_OPTS += -DSDL_SSE=OFF
endif

ifeq ($(BR2_X86_CPU_HAS_3DNOW),y)
SDL2_CONF_OPTS += -DSDL_3DNOW=ON
else
SDL2_CONF_OPTS += -DSDL_3DNOW=OFF
endif

ifeq ($(BR2_PACKAGE_SDL2_DIRECTFB),y)
SDL2_DEPENDENCIES += directfb
SDL2_CONF_OPTS += -DSDL_DIRECTFB=ON
else
SDL2_CONF_OPTS += -DSDL_DIRECTFB=OFF
endif

ifeq ($(BR2_PACKAGE_SDL2_OPENGLES)$(BR2_PACKAGE_RPI_USERLAND),yy)
SDL2_DEPENDENCIES += rpi-userland
SDL2_CONF_OPTS += -DSDL_RPI=ON
else
SDL2_CONF_OPTS += -DSDL_RPI=OFF
endif

# x-includes and x-libraries must be set for cross-compiling
# By default x_includes and x_libraries contains unsafe paths.
# (/usr/X11R6/include and /usr/X11R6/lib)
ifeq ($(BR2_PACKAGE_SDL2_X11),y)
SDL2_DEPENDENCIES += xlib_libX11 xlib_libXext

# X11/extensions/shape.h is provided by libXext.
SDL2_CONF_OPTS += -DSDL_X11=ON
	-DSDL_X11_XSHAPE=ON

ifeq ($(BR2_PACKAGE_XLIB_LIBXCURSOR),y)
SDL2_DEPENDENCIES += xlib_libXcursor
SDL2_CONF_OPTS += -DSDL_X11_XCURSOR=ON
else
SDL2_CONF_OPTS += -DSDL_X11_XCURSOR=OFF
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXI),y)
SDL2_DEPENDENCIES += xlib_libXi
SDL2_CONF_OPTS += -DSDL_X11_XINPUT=ON
else
SDL2_CONF_OPTS += -DSDL_X11_XINPUT=OFF
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXRANDR),y)
SDL2_DEPENDENCIES += xlib_libXrandr
SDL2_CONF_OPTS += -DSDL_X11_XRANDR=ON
else
SDL2_CONF_OPTS += -DSDL_X11_XRANDR=OFF
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXSCRNSAVER),y)
SDL2_DEPENDENCIES += xlib_libXScrnSaver
SDL2_CONF_OPTS += -DSDL_X11_XSCRNSAVER=ON
else
SDL2_CONF_OPTS += -DSDL_X11_XSCRNSAVER=OFF
endif

else
SDL2_CONF_OPTS += -DSDL_X11=OFF
SDL2_CONF_ENV += CFLAGS=" -DMESA_EGL_NO_X11_HEADERS "
endif

ifeq ($(BR2_PACKAGE_SDL2_OPENGL),y)
SDL2_CONF_OPTS += -DSDL_OPENGL=ON
SDL2_DEPENDENCIES += libgl
else
SDL2_CONF_OPTS += -DSDL_OPENGL=OFF
endif

ifeq ($(BR2_PACKAGE_SDL2_OPENGLES),y)
SDL2_CONF_OPTS += -DSDL_OPENGLES=ON
SDL2_DEPENDENCIES += libgles
else
SDL2_CONF_OPTS += -DSDL_OPENGLES=OFF
endif

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
SDL2_DEPENDENCIES += alsa-lib
SDL2_CONF_OPTS += -DSDL_ALSA=ON
else
SDL2_CONF_OPTS += -DSDL_ALSA=OFF
endif

ifeq ($(BR2_PACKAGE_SDL2_KMSDRM),y)
SDL2_DEPENDENCIES += libdrm libgbm
SDL2_CONF_OPTS += -DSDL_KMSDRM=ON
else
SDL2_CONF_OPTS += -DSDL_KMSDRM=OFF
endif

ifeq ($(BR2_PACKAGE_SDL2_WAYLAND),y)
SDL2_DEPENDENCIES += wayland libxkbcommon
SDL2_CONF_OPTS += -DSDL_WAYLAND=ON
else
SDL2_CONF_OPTS += -DSDL_WAYLAND=OFF
endif


define SDL2_FIX_SDL2_CONFIG
	$(SED) 's|-I/[^ ]*/sysroot/usr/include|-I/usr/include|g' \
		$(TARGET_DIR)/usr/bin/sdl2-config
endef
SDL2_POST_INSTALL_TARGET_HOOKS += SDL2_FIX_SDL2_CONFIG

$(eval $(cmake-package))
