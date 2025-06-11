
# 错误与处理

<a id="orgd7626db"></a>

## 环境问题


<a id="orgd281e37"></a>

### opengl


<a id="org3f1ec1e"></a>

#### 问题

GLFW Error: GLX: Failed to create context: GLXBadFBConfig

    Unable to load file texturedMesh.obj with ASSIMP
    GLFW Error: GLX: Failed to create context: GLXBadFBConfig
    Failed to create window
    Failed creating OpenGL window


<a id="org3d98409"></a>

#### solution

    MESA_GL_VERSION_OVERRIDE=4.5 然后再执行命令


<a id="orgc7e8ed6"></a>

### rust cuda

      Compiling tracing-core v0.1.32
    error[E0599]: no method named `cuMemAdvise_v2` found for reference `&'static driver::sys::sys_12010::Lib` in the current scope
       --> /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cudarc-0.11.7/src/driver/result.rs:613:10
        |
    612 | /     lib()
    613 | |         .cuMemAdvise_v2(dptr, num_bytes, advice, location)
        | |_________-^^^^^^^^^^^^^^
        |
    help: there is a method `cuMemAdvise` with a similar name
        |
    613 |         .cuMemAdvise(dptr, num_bytes, advice, location)
        |          ~~~~~~~~~~~
    
    error[E0599]: no method named `cuMemPrefetchAsync_v2` found for reference `&'static driver::sys::sys_12010::Lib` in the current scope
         --> /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cudarc-0.11.7/src/driver/result.rs:628:10
          |
    627   | /     lib()
    628   | |         .cuMemPrefetchAsync_v2(dptr, num_bytes, location, 0, stream)
          | |_________-^^^^^^^^^^^^^^^^^^^^^
          |
    help: there is a method `cuMemPrefetchAsync` with a similar name, but with different arguments
         --> /home/ubuntu/.cargo/registry/src/index.crates.io-6f17d22bba15001f/cudarc-0.11.7/src/driver/sys/sys_12010.rs:13548:5
          |
    13548 | /     pub unsafe fn cuMemPrefetchAsync(
    13549 | |         &self,
    13550 | |         devPtr: CUdeviceptr,
    13551 | |         count: usize,
    13552 | |         dstDevice: CUdevice,
    13553 | |         hStream: CUstream,
    13554 | |     ) -> CUresult {
          | |_________________^


<a id="org47bb0de"></a>

#### solution

安装cuda12.4

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
    sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
    sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-4


<a id="org815e32e"></a>

### python


<a id="org6766050"></a>

#### No module named 'pkg<sub>resources</sub>'

    pip install distribute


<a id="org492a4e5"></a>

#### error: invalid command 'dist<sub>info</sub>'

    pip install setuptools


<a id="orgdcc6cb5"></a>

### wine


<a id="orgb22e389"></a>

### gstreamer


<a id="org8e4fd60"></a>

#### plugins

1.  missing decoder

         winegstreamer error: decodebin1: 您的 GStreamer 安装缺少插件。
         winegstreamer error: decodebin1:
          ../gst-plugins-base-1.22.11/gst/playback/gstdecodebin2.c(4705): 
                                 gst_decode_bin_expose (): /GstBin:bin0/GstDecodeBin:decodebin1:
         Missing decoder: 
        wmvversion=(int)3, format=(string)WVC1, width=(int)1920, 
        height=(int)1080, 
    
    解决方案 安装gst-plugins-libav 或者安装gst-plugins-meta 并打开USE=ffmpeg
    
        sudo emerge media-plugins/gst-plugins-libav


<a id="org6ad2838"></a>

### obs-studio

在wayland下不显示屏幕

解决方案: 重新编译obs 并加上pipewire use 并且plasma-workspace等加上screencast的USE


<a id="orgc3ccf3c"></a>

## 系统问题


<a id="orgb74a8eb"></a>

### kde


<a id="orgcbd87f5"></a>

#### PolicyKit 身份验证系统不可用 Not authorized to perform operation

[Polkit配置](./linux.md)


<a id="org3061fa8"></a>

#### fcitx漏字

安装fcitx-gtk


<a id="org828deb3"></a>

### gnome


<a id="org3ccf1e1"></a>

#### 关于Gnome下wayland的问题

1.  nvidia

    首先安装nvidia驱动 然后rm /usr/lib/udev/rules.d/61-gdm.rules 然后在/etc/gdm/daemon.conf下WaylandEnable=true
    运行软件的时候
    
        __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia COMMAND


<a id="org3286c89"></a>

### 系统


<a id="org94de0b8"></a>

#### btd<sub>service</sub><sub>connect</sub>() a2dp-sink profile connect failed

bluetooth缺少pulseaudio支持 安装对应的包

    sudo pacman -S pulseaudio-bluetooth


## 编译问题
### ninjia
#### ninja: error: manifest 'build.ninja' still dirty after 100 tries, perhaps system time is not set
这是系统时间的问题 可以先将系统时间设置到未来 再使用ninjia编译
```shell
date -s "2077-06-11 15:30:00"
```
