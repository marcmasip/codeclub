# Basics
ins_libepoxy(){
	at  https://download.gnome.org/sources/libepoxy/1.5/libepoxy-1.5.10.tar.xz && $mur
	return $?
}
ins_pixman(){
	at  https://www.cairographics.org/releases/pixman-0.46.4.tar.gz && $mur
	return $?
}
ins_cairo(){
	at https://www.cairographics.org/releases/cairo-1.18.4.tar.xz && $mur
	return $?
}




# HW Accel

ins_libdrm(){
	at https://dri.freedesktop.org/libdrm/libdrm-2.4.126.tar.xz && $mu -D udev=true -D valgrind=disabled && $mu32 -D udev=true -D valgrind=disabled
	return $?
}

ins_spirv_headers(){
	src="SPIRV-Headers-vulkan-sdk"
	at https://github.com/KhronosGroup/SPIRV-Headers/archive/vulkan-sdk-1.4.321.0/SPIRV-Headers-vulkan-sdk-1.4.321.0.tar.gz &&\
	cmn -D CMAKE_INSTALL_PREFIX=/usr 
	return $?
}

ins_spirv_tools(){
	src="SPIRV-Tools-vulkan-sdk"
	at https://github.com/KhronosGroup/SPIRV-Tools/archive/vulkan-sdk-1.4.321.0/SPIRV-Tools-vulkan-sdk-1.4.321.0.tar.gz && o && wbd && bd &&\

 cmn -D SPIRV_WERROR=OFF \
      -D BUILD_SHARED_LIBS=ON \
      -D SPIRV_TOOLS_BUILD_STATIC=OFF \
      -D SPIRV-Headers_SOURCE_DIR=/usr 
     
	return $?
}
ins_libvdpau(){
	at https://gitlab.freedesktop.org/vdpau/libvdpau/-/archive/1.5/libvdpau-1.5.tar.bz2 && $mur
	return $?
}
ins_libglvnd(){
	at https://gitlab.freedesktop.org/glvnd/libglvnd/-/archive/v1.7.0/libglvnd-v1.7.0.tar.gz &&
	oa 
}
ins_glslang(){
	at https://github.com/KhronosGroup/glslang/archive/16.0.0/glslang-16.0.0.tar.gz && cmn -D CMAKE_INSTALL_PREFIX=/usr     \
      -D CMAKE_BUILD_TYPE=Release      \
      -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
      -D BUILD_SHARED_LIBS=ON          \
      -D GLSLANG_TESTS=OFF 
     return $?
}
ins_mesa(){
	export CURL_CA_BUNDLE=/etc/ssl/certs/bundle.crt
	at https://mesa.freedesktop.org/archive/mesa-25.2.2.tar.xz &&
	oa -D platforms=x11 \
      -D gallium-drivers=r600,softpipe,radeonsi,d3d12,i915 \
      -D gallium-va=enabled \
      -D vulkan-drivers=amd,swrast,intel_hasvk  \
      -Dglvnd=true \
      -D gallium-vdpau=enabled \
      -D glx=auto \
      -D video-codecs=all \
      -D egl-native-platform=x11 \
      -D egl=enabled \
      -D libunwind=disabled
}
ins_mesa32(){
	src="mesa"
	at https://mesa.freedesktop.org/archive/mesa-25.2.2.tar.xz &&
	export CURL_CA_BUNDLE=/etc/ssl/certs/bundle.crt &&\
	$mu32 \
      -D platforms=x11 \
      -D gallium-drivers=r600,softpipe,radeonsi,d3d12,i915 \
      -D vulkan-drivers=amd,swrast,intel_hasvk  \
      -D glx=auto \
      -D video-codecs=all \
      -D egl-native-platform=x11 \
      -D egl=enabled \
      -D libunwind=disabled
	return $?
}
