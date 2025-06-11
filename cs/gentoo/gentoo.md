


<a id="org2f84ce5"></a>

# 安装


<a id="org2af0dd7"></a>

### 1.挂载

将根磁盘挂载到/mnt/genoo


<a id="org4294f57"></a>

### 2.stage3

1.  关于stage包的区别

    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">multilib 32 and 64</td>
    <td class="org-left">尽可能的使用64位库,必要时兼容32</td>
    </tr>
    
    <tr>
    <td class="org-left">no-multilib (纯64位)</td>
    <td class="org-left">除非必要 否则不要使用</td>
    </tr>
    
    <tr>
    <td class="org-left">Openrc</td>
    <td class="org-left">一个简洁的init系统</td>
    </tr>
    
    <tr>
    <td class="org-left">systemd</td>
    <td class="org-left">比openrc臃肿但通用</td>
    </tr>
    </tbody>
    </table>

2.  解压stage3

        tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

3.  创建/mnt/gentoo/etc/portage/repos.conf/gentoo.conf

4.  更改/mnt/gentoo/etc/gentoo/portage/make.conf

5.  二进制配置/mnt/gentoo/etc/gentoo/portage/binrepos.conf/gentoobinhost.conf

6.  挂载文件系统

    -   /proc是伪文件系统 由linux内核生成 挂载到/mnt/proc
    -   /sys是伪文件系统 类似/proc 更结构化
    -   /dev是包含全部设备文件的常规文件系统 一部分由linux设备管理器(通常是udev)  管理
    
    /proc是挂载 /sys /dev /run是绑定挂载
    例如 /mnt/sys就是sys(同一个文件系统的第二个条目) 而/mnt/proc(可以说)是文件系统的新挂载
    
        mount --types proc /proc /mnt/gentoo/proc
        mount --rbind /sys /mnt/gentoo/sys
        mount --make-rslave /mnt/gentoo/sys
        mount --rbind /dev /mnt/gentoo/dev
        mount --make-rslave /mnt/gentoo/dev
        mount --bind /run /mnt/gentoo/run
        mount --make-slave /mnt/gentoo/run

7.  chroot

        chroot /mnt/gentoo /bin/bash
        source /etc/profile
        export PS1="(chroot) &{PS1}"

8.  emerge sync

        emerge --sync

9.  eselect

        eselect news list
        eselect news read
        eselect profile list
        eselect profile set [number]

10. 配置use

        emerge --info |grep ^USE #查看默认use
        vi /etc/portage/make.conf

11. emerge update

        emerge --ask --verbose --update --deep --newuse @world

12. 时区

    1.  openrc
    
            echo "Asia/Shanghai" > /etc/timezone
            emerge --config sys-libs/timezone-data
    
    2.  systemd
    
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

13. locale /etc/locale.gen

        zh_CN.UTF-8 UTF-8
        en_US.UTF-8 UTF-8
    
        locale-gen

14. eselect locale

        eselect locale list #找到zh_CN.utf8
        eselect locale set

15. 内核

        
        emerge linux-firmware
        emerge gentoo-sources
        emerge genkernel
        time genkernel all

16. rc

        emerge dhcpcd
        emerge networkmanager
        emerge syslog-ng
        emerge cronie
        emerge virtual/sshd
        rc-update add dhcpcd default
        rc-update add syslog-ng default
        rc-update add sshd default
        rc-update add cronie default
        emerge sudo
        useradd -m donjuan
        passwd donjuan

17. grub

        emerge sys-boot/grub
        grub-install --target=x86_64-efi --efi-directory=/efi --removable
        grub-mkconfig -o /boot

18. umount

        umount /mnt/gentoo/dev
        umount /mnt/gentoo/proc
        umount /mnt/gentoo/efi
        umount /mnt/gentoo

19. kde

        emerge dev-libs/plasma-wayland-protocols-1.10.0
        emerge dev-libs/wayland-1.22.0
        emerge dev-libs/wayland-protocols-1.32
        emerge sddm
        emerge plasma-meta
        emerge kde-plasma/kwalletmanager

20. display-manager

    注意 也可以直接用dbus启动
    
        dbus-launch startplasma-wayland
    
    使用sddm
    
         emerge gui-libs/display-manager-init
         vi /etc/conf.d/xdm
         vi /etc/conf.d/display-manager
        ->  DISPLAYMANAGER="sddm"
         sudo rc-update add sddm default

21. fcitx

        echo 'app-i18n/fcitx-configtool kcm' > /etc/portage/package.use/fcitx-configtool
        emerge fcitx fcitx-rime fcitx-configtools
    
    在键盘->虚拟键盘 选择fcitx5
    
    在输入法->添加输入法 添加中州韵
    
    1.  /etc/environment
    
            #
            # This file is parsed by pam_env module
            #
            # Syntax: simple "KEY=VAL" pairs on separate lines
            #
            QT_IM_MODULE="fcitx"
            GTK_IM_MODULE="fcitx"
            XMODIFIERS="@im=fcitx"
        
            emerge fcitx fcitx-libpinyin fcitx-qt5 kcm-fcitx libpinyin

22. 服务启动

        sudo emerge alsa-utils
        sudo emerge alsa-plugins
        
        sudo rc-update add udev sysinit
        sudo rc-update add elogind boot
        sudo rc-update add dbus default
        sudo rc-update add alsasound boot
        sudo rc-update add Networkmanager default

23. kde

        dbus-launch --exit-with-session startplasma-wayland


<a id="org42afcc0"></a>

### 3.grub

    emerge grub
    GRUB_TIMEOUT=10
    grub install --target=x86_64-efi --removable --efi-directory=/boot/EFI # EFI

1.  sys-boot/os-prober

    GRUB 可以在运行 grub-mkconfig 命令时检测到其他操作系统并生成启动项
    
        emerge --ask --newuse sys-boot/os-prober


<a id="orgbbbfab8"></a>

### 4.网络

1.  静态ip

    /etc/dhcpcd.conf
    
        static ip_address=192.168.0.10/24
        static routers=192.168.0.1
        static domain_name_servers=192.168.0.1


<a id="org3a59196"></a>

### 5.时间

    sudo emerge net-misc/chrony
    rc-update add chronyd default


<a id="org4eb373e"></a>

# Chroot安装


<a id="org6bab371"></a>

# 后续


<a id="org429572b"></a>

## 23.0版本更新

默认合并了/usr (merged-usr)
在profile中 旧版本需要选择 split-usr

    Select the 23.0 profile corresponding to your current profile, either using
     "eselect profile" or by manually setting the profile symlink.
     Note that old profiles are by default split-usr and the 23.0 profiles by
     default merged-usr. Do NOT change directory scheme now, since this will
     mess up your system! 
     Instead, make sure that the new profile has the same property: for example, 
     OLD default/linux/amd64/17.1  
          ==>  NEW default/linux/amd64/23.0/split-usr
               (added "split-usr")
     OLD default/linux/amd64/17.1/systemd/merged-usr  
          ==>  NEW default/linux/amd64/23.0/systemd
               (removed "merged-usr")


<a id="org18ed822"></a>

## fcitx-rime切换为简体

F4选择即可


<a id="org0e29b8f"></a>

## fcitx


<a id="orgf6cbb0e"></a>

# 注意

更新后记得执行 因为gentoo有时更新会换一些库的位置 dispatch-conf可以帮助你迁移配置文件

    dispatch-conf


<a id="org3847814"></a>

# 部分包配置


<a id="org72ffef1"></a>

### www-client/google-chrome

安装好后在chrome://flags中Preferred Ozone platform选择wayland


<a id="org854e0e6"></a>

# portage


<a id="org765bb86"></a>

## emerge


<a id="org1c06e57"></a>

### 仓库更新

    emerge --sync # 更新仓库


<a id="org79772ce"></a>

### 删除包

    emerge --unmerge package
    emerge --deselect package
    emerge --depclean


<a id="org5645537"></a>

### 搜索包

    emerge --search package # 搜索包名
    emerge --searchdesc package # 搜索包的描述


<a id="org29c2b61"></a>

### 安装包

    emerge package
    emerge --pretend package # 查看依赖
    emerge --fetchonly package # 仅下载源代码至/var/cache/distfiles
    emerge =package-version # 安装指定版本


<a id="org1ab55c6"></a>

### 系统更新

    emerge --update --deep --newuse @world


<a id="org651a091"></a>

### 包信息查询

    emerge -vp package

你将会看到 类似于

    [ebuild  rR    ] kde-plasma/plasma-desktop-6.2.4:6::gentoo  USE="handbook screencast sdl semantic-desktop -debug -ibus -scim -test -webengine" INPUT_DEVICES="-wacom" 0 KiB

其中在[]里

    N new包
    S SLOT安装(并排版本)
    U 更新
    D 降级
    r 重新安装(由于某种原因被强制安装)
    R 替换(重新安装相同的版本)
    I 交互式
    B 由于未解决的冲突被block
    b 被block 但是自动解决冲突

其中在USE后

    -USE 没有激活这个USE
    USE* 状态转换
    UES% 新增加的或减少的
    (USE) 强制的
    {} 被绑定于FEATURES


<a id="orgda4757f"></a>

### 指定根

    emerge --root=DIR # 指定ROOT env
    emerge --sysroot=DIR # 指定SYSROOT env


<a id="org614fe1b"></a>

### 清理缓存

    eclean-dist


<a id="org96b1a04"></a>

### 查看USE说明

安装gentoolkit

      equery uses emacs
       * Found these USE flags for app-editors/emacs-29.4:
     U I
     + + X                   : Add support for X11
     - - Xaw3d               : Add support for the 3d athena widget set
     + + acl                 : Add support for Access Control Lists
     + + alsa                : Add support for media-libs/alsa-lib (Advanced Linux Sound Architecture)
     - - athena              : Enable the MIT Athena widget set (x11-libs/libXaw)
     + + cairo               : Enable support for the cairo graphics library
     + + dbus                : Enable dbus support for anything that needs it (gpsd, gnomemeeting, etc)
     + + dynamic-loading     : Enable loading of dynamic libraries (modules) at runtime
     - - games               : Support shared score files for games
    ....


<a id="org561a4a8"></a>

### 二进制包操作

    emerge -g # 从远程下载二进制包 若没有则编译
    emerge -G # 从远程下载二进制包 若没有则报错


<a id="orga67eca7"></a>

### 报错

1.  mask

    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-left" />
    
    <col  class="org-left" />
    </colgroup>
    <tbody>
    <tr>
    <td class="org-left">~arch keyword</td>
    <td class="org-left">该软件没有经过充分的测试 不能进入稳定分支 请等待一段时间后尝试使用</td>
    </tr>
    
    <tr>
    <td class="org-left">-arch keyword or -* keyword</td>
    <td class="org-left">该软件不能在目标机器的架构中工作 如果情况并非如此</td>
    </tr>
    
    <tr>
    <td class="org-left">missing keyword</td>
    <td class="org-left">该软件至今还没有在机器的架构中进行过测试 可以咨询相应架构移植小组是否能对它进行测试 查看 /etc/portage/package.accept<sub>keywords</sub> 和接受单个软件包的关键字</td>
    </tr>
    
    <tr>
    <td class="org-left">package.mask</td>
    <td class="org-left">发现该包已损坏或其他问题 被故意标记为请勿使用</td>
    </tr>
    
    <tr>
    <td class="org-left">profile</td>
    <td class="org-left">该软件不适合当前proifle</td>
    </tr>
    
    <tr>
    <td class="org-left">license</td>
    <td class="org-left">不兼容license</td>
    </tr>
    </tbody>
    </table>

2.  USE

    portage提示USE需要更改
    
        The following USE changes are necessary to proceed:
        #required by app-text/happypackage-2.0, required by happypackage (argument)
        >=app-text/feelings-1.0.0 test
    
    遇到这种情况 请到/etc/portage/package.use设置包

3.  循环依赖

        !!! Error: circular dependencies: 
        ebuild / net-print/cups-1.1.15-r2 depends on ebuild / app-text/ghostscript-7.05.3-r1
        ebuild / app-text/ghostscript-7.05.3-r1 depends on ebuild / net-print/cups-1.1.15-r2
    
    此时应该静待portage更新并反馈bug

4.  profile保护

        !!! Trying to unmerge package(s) in system profile. 'sys-apps/portage'
        !!! This could be damaging to your system.
    
    您要求移除系统核心软件包中的一个 它是您的profile中所列出的必需的软件 因此不能从系统中移除 

5.  测试版本

    类似于
    
        masked by: ~amd64 keyword
    
    此时编籍/etc/portage/package.accept<sub>keywords</sub>/package
    并添加xxx/package ~amd64

6.  Block

    示例
    
        [ebuild  N     ] x11-libs/xcb-imdkit-1.0.9 
        [ebuild  NS    ] app-i18n/fcitx-5.1.10 [4.2.9.8] USE="emoji%* keyboard%* server%* wayland%* -doc% -presage% -systemd%" 
        [blocks B      ] app-i18n/fcitx:4 ("app-i18n/fcitx:4" is soft blocking app-i18n/fcitx-5.1.10)
        [blocks B      ] app-i18n/fcitx:5 ("app-i18n/fcitx:5" is soft blocking app-i18n/fcitx-4.2.9.8)
        
         * Error: The above package list contains packages which cannot be
         * installed at the same time on the same system.
        
          (app-i18n/fcitx-4.2.9.8:4/4::gentoo, installed) pulled in by
            >=app-i18n/fcitx-4.2.9:4 required by (app-i18n/kcm-fcitx-0.5.6:4-plasma5/4-plasma5::gentoo, installed) USE="" ABI_X86="(64)"
            >=app-i18n/fcitx-4.2.9:4 required by (app-i18n/fcitx-rime-0.3.2-r1:4/4::gentoo, installed) USE="" ABI_X86="(64)"
            >=app-i18n/fcitx-4.2.9:4 required by (app-i18n/fcitx-qt5-1.2.5:4/4::gentoo, installed) USE="" ABI_X86="(64)"
            >=app-i18n/fcitx-4.2.9:4 required by (app-i18n/fcitx-libpinyin-0.5.4:4/4::gentoo, installed) USE="-dictionary-manager" ABI_X86="(64)"
        
          (app-i18n/fcitx-5.1.10:5/5::gentoo, ebuild scheduled for merge) pulled in by
            fcitx
        
        
        For more information about Blocked Packages, please refer to the following
        section of the Gentoo Linux x86 Handbook (architecture is irrelevant):
        
        https://wiki.gentoo.org/wiki/Handbook:X86/Working/Portage#Blocked_packages

7.  解决方案

    为了使安装得以继续进行，您可以选择不安装这个软件包，或者先将发生冲突的包卸载。
    你也可能会遇到某些特定版本的包被屏蔽的情况，比如<media-video/mplayer-1.0<sub>rc1</sub>-r2。在这种情况下，升级到一个更新的版本就能解决问题。 


<a id="orgf70a598"></a>

## gentoolkit

安装

    emerge gentoolkit


<a id="org2e8e93f"></a>

### equery

查看依赖于这个包的所有包

    equery depends -D package

查看这个包依赖什么包

    equery depgraph package


<a id="org90eaac3"></a>

# 配置文件


<a id="org1017673"></a>

## sys


<a id="org626991f"></a>

### /etc/portage/make.conf

    
            # These settings were set by the catalyst build script that automatically
    # built this stage.
    # Please consult /usr/share/portage/config/make.conf.example for a more
    # detailed example.
    COMMON_FLAGS="-O2 -pipe"
    CFLAGS="${COMMON_FLAGS}"
    CXXFLAGS="${COMMON_FLAGS}"
    FCFLAGS="${COMMON_FLAGS}"
    FFLAGS="${COMMON_FLAGS}"
    FEATURES="${FEATURES} binpkg-request-signature buildpkg"
    # NOTE: This stage was built with the bindist Use flag enabled
    
    # This sets the language of build output to English.
    # Please keep this setting intact when reporting bugs.
    LC_MESSAGES=C.utf8
    #GENTOO_MIRRORS="rsync://127.0.0.1/repo/gentoo/"
    GENTOO_MIRRORS="rsync://mirror.nju.edu.cn/gentoo/"
    USE="-gnome wayland  qt5 kde dvd cdr acl alsa jack pulseaudio bluetooth wayland browser-integration discover networkmanager  pipewire  screencast plasma grub"
    VIDEO_CARDS="amdgpu radeonsi"
    MAKEOPTS="-j8"
    
    
    # ccache
    #FEATURES="ccache -test"
    #CCACHE_DIR="/var/cache/ccache"
    
    GRUB_PLATFORMS="efi-64"
    
    ACCEPT_LICENSE="*"
    
    ALSA_CARDS="hda_intel"
    
    L10N="en-US zh-CN en zh"
    ABI_X86="32 64"	      


<a id="orgd2d9671"></a>

### /etc/portage/repos.conf/gentoo.conf

    [DEFAULT]
    main-repo = gentoo
    
    [gentoo]
    location = /var/db/repos/gentoo
    sync-type = rsync
    #sync-uri = rsync://127.0.0.1/repo/gentoo-portage
    sync-uri = rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage
    auto-sync = yes
    sync-rsync-verify-jobs = 1
    sync-rsync-verify-metamanifest = no
    sync-rsync-verify-max-age = 24
    sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
    sync-openpgp-key-refresh-retry-count = 40
    sync-openpgp-key-refresh-retry-overall-timeout = 1200
    sync-openpgp-key-refresh-retry-delay-exp-base = 2
    sync-openpgp-key-refresh-retry-delay-max = 60
    sync-openpgp-key-refresh-retry-delay-mult = 4
    sync-webrsync-verify-signature = no


<a id="orgad1d3e9"></a>

### /etc/portage/binrepos.conf/gentoobinhost.conf

      # These settings were set by the catalyst build script that automatically
    # built this stage.
    # Please consider using a local mirror.
    
    [gentoobinhost]
    priority = 1
    sync-uri = https://mirrors.tuna.tsinghua.edu.cn/gentoo/releases/amd64/binpackages/23.0/x86-64


<a id="orgbb0d5e4"></a>

### /etc/portage/repos.conf/gentoo-zh.conf

      # created by eselect-repo
    [gentoo-zh]
    location = /var/db/repos/gentoo-zh
    sync-type = git
    sync-uri = https://github.com/microcai/gentoo-zh.git


<a id="org18510d4"></a>

### /etc/genkernel.conf

    NICE=19
    # Add DMRAID support
    DMRAID="yes"
    
    # Add SSH support
    #SSH="no"
    
    # Add b2sum support
    #B2SUM="no"
    
    # Include busybox in the initramfs. If included, busybox is rebuilt
    # if the cached copy is out of date.
    #BUSYBOX="yes"
    
    # Add MDRAID support
    #MDADM="no"
    
    # Specify a custom mdadm.conf.
    # By default the initramfs will be built *without* an mdadm.conf and will auto-detect
    # arrays during bootup.  Usually, this should not be needed.
    #MDADM_CONFIG="/etc/mdadm.conf"
    
    # Add Multipath support
    #MULTIPATH="no"
    
    # Add iSCSI support
    #ISCSI="no"
    
    # Add e2fsprogs support
    #E2FSPROGS="no"
    
    # Include support for unionfs
    #UNIONFS="no"
    
    # Include support for zfs volume management.  If unset, genkernel will attempt
    # to autodetect and enable this when rootfs is on zfs.
    #ZFS="no"
    
    # Add BTRFS support
    #BTRFS="no"
    
    # Add xfsprogs support
    #XFSPROGS="no"
    
    # Install firmware onto root filesystem
    # Will conflict with sys-kernel/linux-firmware package
    #FIRMWARE_INSTALL="no"
    
    # Include full contents of FIRMWARE_DIR
    # (if FIRMWARE option below is set to YES).
    #ALLFIRMWARE="no"
    
    # Add firmware(s) to initramfs required by copied modules
    #FIRMWARE="no"
    
    # Specify directory to pull from
    #FIRMWARE_DIR="/lib/firmware"
    
    # Specify a comma-separated list of firmware files or directories to include,
    # relative to FIRMWARE_DIR (if FIRMWARE option above is set to YES
    # and ALLFIRMWARE is set to NO).
    #FIRMWARE_FILES=""
    
    # Add new kernel to grub
    # Possible values: empty/"no", "grub", "grub2"
    #BOOTLOADER="no"
    
    # Use sandbox when building initramfs
    #SANDBOX="yes"
    
    # Embed and set font early on boot
    # Possible values: empty/"none", "current", <PSF file>
    #BOOTFONT="none"
    
    # Add boot splash using splashutils
    #SPLASH="no"
    
    # Use this splash theme. If commented out - the "default" name theme is used.
    # Also, SPLASH="yes" needs to be enabled for this one to work.
    # This supersedes the "SPLASH_THEME" option in '/etc/conf.d/splash'.
    #SPLASH_THEME="gentoo"
    
    # Includes or excludes Plymouth from the initramfs. If "splash" is
    # passed at boot, Plymouth will be activated.
    #PLYMOUTH="no"
    
    # Embeds the given plymouth theme in the initramfs.
    #PLYMOUTH_THEME="text"
    
    # Run "emerge @module-rebuild" automatically when possible and necessary
    # after kernel and modules have been compiled
    #MODULEREBUILD="yes"
    
    # Run the specified command in the current environment after the kernel and
    # modules have been compiled, useful to rebuild external kernel module
    # (see MODULEREBUILD above) or installing additional
    # files (use 'copy_image_with_preserve dtb path/to/dtb dtb <kernelname>')
    #CMD_CALLBACK=""
    
    
    # =========KEYMAP SETTINGS=========
    #
    # Force keymap selection at boot
    #DOKEYMAPAUTO="no"
    
    # Enables keymap selection support
    #KEYMAP="yes"
    
    
    # =========LOW LEVEL COMPILE SETTINGS=========
    #
    # Assembler to use for the kernel.  See also the --kernel-as command line
    # option.
    #KERNEL_AS="as"
    
    # Archiver to use for the kernel.  See also the --kernel-ar command line
    # option.
    #KERNEL_AR="ar"
    
    # Compiler to use for the kernel (e.g. distcc).  See also the --kernel-cc
    # command line option.
    #KERNEL_CC="gcc"
    
    # Linker to use for the kernel.  See also the --kernel-ld command line option.
    #KERNEL_LD="ld"
    
    # NM utility to use for the kernel.  See also the --kernel-nm command line option.
    #KERNEL_NM="nm"
    
    # GNU Make to use for kernel.  See also the --kernel-make command line option.
    #KERNEL_MAKE="make"
    
    # objcopy utility to use for the kernel.  See also the --kernel-objcopy command
    # line option.
    #KERNEL_OBJCOPY="objcopy"
    
    # objdump utility to use for the kernel.  See also the --kernel-objdump command
    # line option.
    #KERNEL_OBJDUMP="objdump"
    
    # ranlib utility to use for the kernel.  See also the --kernel-ranlib command
    # line option.
    #KERNEL_RANLIB="ranlib"
    
    # readelf utility to use for the kernel.  See also the --kernel-readelf command
    # line option.
    #KERNEL_READELF="readelf"
    
    # strip utility to use for the kernel.  See also the --kernel-strip command line
    # option.
    #KERNEL_STRIP="strip"
    
    # Assembler to use for the utilities.  See also the --utils-as command line
    # option.
    #UTILS_AS="as"
    
    # Archiver to use for the utilities.  See also the --utils-ar command line
    # option.
    #UTILS_AR="ar"
    
    # C Compiler to use for the utilities (e.g. distcc).  See also the --utils-cc
    # command line option.
    #UTILS_CC="gcc"
    
    # C++ Compiler to use for the utilities (e.g. distcc).  See also the --utils-cxx
    # command line option.
    #UTILS_CXX="g++"
    
    # Linker to use for the utilities.  See also the --utils-ld command line
    # option.
    #UTILS_LD="ld"
    
    # NM utility to use for the utilities.  See also the --utils-nm command line option.
    #UTILS_NM="nm"
    
    # GNU Make to use for the utilities.  See also the --utils-make command line
    # option.
    #UTILS_MAKE="make"
    
    # Target triple (i.e. aarch64-linux-gnu) to build for. If you do not
    # cross-compile, leave blank for auto detection.
    #CROSS_COMPILE=""
    
    # Target triple (i.e. aarch64-linux-gnu) to build kernel for.  Utilities will be
    # built for the native target, not this target. If you do not cross-compile,
    # leave blank.
    #KERNEL_CROSS_COMPILE=""
    
    # Override default make target (bzImage). See also the --kernel-target
    # command line option. Useful to build a uImage on arm.
    #KERNEL_MAKE_DIRECTIVE_OVERRIDE="fooImage"
    
    # Override default kernel binary path. See also the --kernel-binary
    # command line option. Useful to install a uImage on arm.
    #KERNEL_BINARY_OVERRIDE="arch/foo/boot/bar"
    
    
    # =========GENKERNEL LOCATION CONFIGURATION=========
    #
    # Variables:
    #   %%ARCH%%  - Final determined architecture
    #   %%CACHE%% - Final determined cache location
    
    # Set genkernel's temporary work directory
    #TMPDIR="/var/tmp/genkernel"
    
    # Set the boot directory, default is /boot
    #BOOTDIR="/boot"
    
    # Default share directory location
    GK_SHARE="${GK_SHARE:-/usr/share/genkernel}"
    
    # Location of the default cache
    CACHE_DIR="/var/cache/genkernel"
    
    # Location of DISTDIR, where our source tarballs are stored
    DISTDIR="${GK_SHARE}/distfiles"
    
    # Log output file
    LOGFILE="/var/log/genkernel.log"
    
    # Debug Level
    LOGLEVEL=1
    
    
    # =========COMPILED UTILS CONFIGURATION=========
    #
    # Default location of kernel source
    DEFAULT_KERNEL_SOURCE="/usr/src/linux"
    
    # Default kernel config (only use to override using
    # arch/%%ARCH%%/kernel-config-${VER}.${PAT} !)
    #DEFAULT_KERNEL_CONFIG="${GK_SHARE}/arch/%%ARCH%%/kernel-config"
    
    # Specifies a user created busybox config
    #BUSYBOX_CONFIG="/path/to/file"
    
    # NOTE: Since genkernel 3.4.41 the version of
    #   busybox, lvm, mdadm, ... have been moved to
    #   /usr/share/genkernel/defaults/software.sh in order to
    #   reduce the merging you have to do during etc-update.
    #   You can still override these settings in here.
    
    
    # =========MISC KERNEL CONFIGURATION=========
    #
    # Set kernel filename which will be used when kernel will be installed
    # into BOOTDIR. See man page to learn more about available placeholders.
    #KERNEL_FILENAME="vmlinuz-%%KV%%"
    
    # Set kernel symlink name which will be used when kernel will be installed
    # into BOOTDIR and SYMLINK option is enabled
    #KERNEL_SYMLINK_NAME="kernel"
    
    # This option will set kernel option CONFIG_LOCALVERSION.
    # Use special value "UNSET" to unset already set CONFIG_LOCALVERSION.
    #KERNEL_LOCALVERSION="-%%ARCH%%"
    
    # This option is only valid if kerncache is
    # defined. If there is a valid kerncache no checks
    # will be made against a kernel source tree.
    #KERNEL_SOURCES="yes"
    
    # Build a static (monolithic kernel)
    #BUILD_STATIC="no"
    
    # Make and install kernelz image (PowerPC)
    #GENZIMAGE="no"
    
    # Archive file created using tar containing kernel binary, content
    # of /lib/modules and the kernel config.
    # NOTE: Archive is created before the callbacks are run!
    #KERNCACHE="/path/to/file.tar.xz"
    
    # Prefix to kernel module destination, modules
    # will be installed in <prefix>/lib/modules
    #KERNEL_MODULES_PREFIX=""
    
    
    # =========MISC INITRAMFS CONFIGURATION=========
    #
    # Set initramfs filename which will be used when initramfs will be
    # installed into BOOTDIR. See man page to learn more about available
    # placeholders.
    #INITRAMFS_FILENAME="initramfs-%%KV%%.img"
    
    # Set initramfs symlink name which will be used when initramfs will be
    # installed into BOOTDIR and SYMLINK option is enabled
    #INITRAMFS_SYMLINK_NAME="initramfs"
    
    # Copy all compiled kernel modules to the initramfs
    #ALLRAMDISKMODULES="no"
    
    # Copy selected modules to the initramfs based on arch-specific modules_load file
    #RAMDISKMODULES="yes"
    
    # Archive file created using tar containing kernel and initramfs.
    # NOTE: No modules outside of the initramfs will be included!
    #MINKERNPACKAGE="/path/to/file.tar.xz"
    
    # Add additional modules to the initramfs using the module groups defined
    # in /usr/share/genkernel/defaults/modules_load (see this file for
    # more details).  This would be used if, for example, you
    # required an additional crypto module or network device at boot
    # time and did not want to statically compile these in the kernel.
    # Options take the form AMODULES_{group} where {group} is one of
    # the groups in modules_load (which are in the form MODULES_{group}).
    # Use this with caution.
    #AMODULES_group="module-to-include another-module"
    
    # Override the default modules in the initramfs, for a given group, as defined by
    # /usr/share/genkernel/defaults/modules_load and the per-arch modules_load
    # files. You PROBABLY want to use AMODULES_* above, and NOT MODULES_* here.
    # If you use MODULES_* here, the default and per-arch modules will NOT be used.
    #MODULES_group1="some-module"
    #MODULES_group2="" # Load no modules for this group
    
    # Override the default used linuxrc script.
    #LINUXRC="/path/to/custom/linuxrc"
    
    # Archive file created using tar containing modules after
    # the callbacks have run
    #MODULESPACKAGE="/path/to/file.tar.xz"
    
    # Directory structure to include in the initramfs,
    # only available on >=2.6 kernels
    #INITRAMFS_OVERLAY=""
    
    # Build the generated initramfs into the kernel instead of
    # keeping it as a separate file
    #INTEGRATED_INITRAMFS="no"
    
    # Compress generated initramfs
    #COMPRESS_INITRD="yes"
    
    # Types of compression: best, xz, lzma, bzip2, gzip, lzop, lz4, zstd, fastest
    # "best" selects the best available compression method
    # "fastest" selects the fastest available compression method
    #COMPRESS_INITRD_TYPE="best"
    
    # wrap initramfs using mkimage for u-boot bootloader
    # WRAP_INITRD=no
    
    # Create a self-contained env in the initramfs
    #NETBOOT="no"
    
    
    # =========MISC BOOT CONFIGURATION=========
    #
    # Specify a default for real_root=
    #REAL_ROOT="/dev/one/two/gentoo"


<a id="org5b82aff"></a>

## doc


<a id="orgb6be82f"></a>

### /var/db/repos/gentoo/profiles/use.desc

      # Copyright 1999-2025 Gentoo Authors
    # Distributed under the terms of the GNU General Public License v2
    
    # Keep them sorted
    
    X - Add support for X11
    Xaw3d - Add support for the 3d athena widget set
    a52 - Enable support for decoding ATSC A/52 streams used in DVD
    aac - Enable support for MPEG-4 AAC Audio
    aalib - Add support for media-libs/aalib (ASCII-Graphics Library)
    accessibility - Add support for accessibility (eg 'at-spi' library)
    acl - Add support for Access Control Lists
    acpi - Add support for Advanced Configuration and Power Interface
    adns - Add support for asynchronous DNS resolution
    afs - Add OpenAFS support (distributed file system)
    alsa - Add support for media-libs/alsa-lib (Advanced Linux Sound Architecture)
    ao - Use libao audio output library for sound playback
    apache2 - Add Apache2 support
    aqua - Include support for the Mac OS X Aqua (Carbon/Cocoa) GUI
    asm - Enable using assembly for optimization
    atm - Enable Asynchronous Transfer Mode protocol support
    apparmor - Enable support for the AppArmor application security system
    appindicator - Build in support for notifications using the libindicate or libappindicator plugin
    audiofile - Add support for libaudiofile where applicable
    audit - Enable support for Linux audit subsystem using sys-process/audit
    avif - Add AV1 Image Format (AVIF) support
    bash-completion - Enable bash-completion support
    berkdb - Add support for sys-libs/db (Berkeley DB for MySQL)
    bidi - Enable bidirectional language support
    big-endian - Big-endian toolchain support
    bindist - Flag to enable or disable options for prebuilt (GRP) packages (eg. due to licensing issues)
    blas - Add support for the virtual/blas numerical library
    bluetooth - Enable Bluetooth Support
    branding - Enable Gentoo specific branding
    brotli - Enable Brotli compression support
    build - !!internal use only!! DO NOT SET THIS FLAG YOURSELF!, used for creating build images and the first half of bootstrapping [make stage1]
    bzip2 - Enable bzip2 compression support
    cairo - Enable support for the cairo graphics library
    calendar - Add support for calendars (not using mcal!)
    caps - Use Linux capabilities library to control privilege
    cdb - Add support for the CDB database engine from the author of qmail
    cdda - Add Compact Disk Digital Audio (Standard Audio CD) support
    cddb - Access cddb servers to retrieve and submit information about compact disks
    cdinstall - Copy files from the CD rather than asking the user to copy them, mostly used with games
    cdr - Add support for CD writer hardware
    cgi - Add CGI script support
    cjk - Add support for Multi-byte character languages (Chinese, Japanese, Korean)
    clamav - Add support for Clam AntiVirus software (usually with a plugin)
    colord - Support color management using x11-misc/colord
    connman - Add support for net-misc/connman
    coreaudio - Build the CoreAudio driver on Mac OS X systems
    cracklib - Support for cracklib strong password checking
    crypt - Add support for encryption -- using mcrypt or gpg where applicable
    css - Enable reading of encrypted DVDs
    cuda - Enable NVIDIA CUDA support (computation on GPU)
    cups - Add support for CUPS (Common Unix Printing System)
    curl - Add support for client-side URL transfer library
    custom-cflags - Build with user-specified CFLAGS (unsupported)
    cvs - Enable CVS (Concurrent Versions System) integration
    cxx - Build support for C++ (bindings, extra libraries, code generation, ...)
    dbi - Enable dev-db/libdbi (database-independent abstraction layer) support
    dbm - Add support for generic DBM databases
    dbus - Enable dbus support for anything that needs it (gpsd, gnomemeeting, etc)
    debug - Enable extra debug codepaths, like asserts and extra output. If you want to get meaningful backtraces see https://wiki.gentoo.org/wiki/Project:Quality_Assurance/Backtraces
    dedicated - Add support for dedicated game servers (some packages do not provide clients and servers at the same time)
    dga - Add DGA (Direct Graphic Access) support for X
    dist-kernel - Enable subslot rebuilds on Distribution Kernel upgrades
    djvu - Support DjVu, a PDF-like document format esp. suited for scanned documents
    doc - Add extra documentation (API, Javadoc, etc). It is recommended to enable per package instead of globally
    dri - Enable direct rendering: used for accelerated 3D and some 2D, like DMA
    dts - Enable DTS Coherent Acoustics decoder support
    dv - Enable support for a codec used by many camcorders
    dvb - Add support for DVB (Digital Video Broadcasting)
    dvd - Add support for DVDs
    dvdr - Add support for DVD writer hardware (e.g. in xcdroast)
    eds - Enable support for Evolution-Data-Server (EDS)
    egl - Enable EGL (Embedded-System Graphics Library, interfacing between windowing system and OpenGL/GLES) support
    elogind - Enable session tracking via sys-auth/elogind
    emacs - Add support for GNU Emacs
    emboss - Add support for the European Molecular Biology Open Software Suite
    encode - Add support for encoding of audio or video files
    examples - Install examples, usually source code
    exif - Add support for reading EXIF headers from JPEG and TIFF images
    expat - Enable the use of dev-libs/expat for XML parsing
    fam - Enable FAM (File Alteration Monitor) support
    fastcgi - Add support for the FastCGI interface
    fbcon - Add framebuffer support for the console, via the kernel
    ffmpeg - Enable ffmpeg/libav-based audio/video codec support
    fftw - Use FFTW library for computing Fourier transforms
    filecaps - Use Linux file capabilities to control privilege rather than set*id (this is orthogonal to USE=caps which uses capabilities at runtime e.g. libcap)
    firebird - Add support for the Firebird relational database
    flac - Add support for FLAC: Free Lossless Audio Codec
    fltk - Add support for the Fast Light Toolkit gui interface
    fontconfig - Support for configuring and customizing font access via media-libs/fontconfig
    fortran - Add support for fortran
    freetds - Add support for the TDS protocol to connect to MSSQL/Sybase databases
    ftp - Add FTP (File Transfer Protocol) support
    gd - Add support for media-libs/gd (to generate graphics on the fly)
    gdbm - Add support for sys-libs/gdbm (GNU database libraries)
    geoip - Add geoip support for country and city lookup based on IPs
    geolocation - Enable physical position determination
    ggi - Add support for media-libs/libggi (non-X video api/drivers)
    gif - Add GIF image support
    gimp - Build a plugin for the GIMP
    git - Enable git (version control system) support
    gles2 - Enable GLES 2.0 (OpenGL for Embedded Systems) support (independently of full OpenGL, see also: gles2-only)
    gles2-only - Use GLES 2.0 (OpenGL for Embedded Systems) or later instead of full OpenGL (see also: gles2)
    glut - Build an OpenGL plugin using the GLUT library
    gmp - Add support for dev-libs/gmp (GNU MP library)
    gnome - Add GNOME support
    gnome-keyring - Enable support for storing passwords via gnome-keyring
    gnuplot - Enable support for gnuplot (data and function plotting)
    gnutls - Prefer net-libs/gnutls as SSL/TLS provider (ineffective with USE=-ssl)
    gphoto2 - Add digital camera support
    gpm - Add support for sys-libs/gpm (Console-based mouse driver)
    gps - Add support for Global Positioning System
    graphicsmagick - Build and link against GraphicsMagick instead of ImageMagick (requires USE=imagemagick if optional)
    graphviz - Add support for the Graphviz library
    gsl - Use the GNU scientific library for calculations
    gsm - Add support for the gsm lossy speech compression codec
    gstreamer - Add support for media-libs/gstreamer (Streaming media)
    gtk - Add support for x11-libs/gtk+ (The GIMP Toolkit)
    gtk-doc - Build and install gtk-doc based developer documentation for dev-util/devhelp, IDE and offline use
    gui - Enable support for a graphical user interface
    guile - Add support for the guile Scheme interpreter
    gzip - Compress files with Lempel-Ziv coding (LZ77)
    handbook - Enable handbooks generation for packages by KDE
    hardened - Activate default security enhancements for toolchain (gcc, glibc, binutils)
    hddtemp - Enable monitoring of hdd temperature (app-admin/hddtemp)
    hdf5 - Add support for the Hierarchical Data Format v5
    headers-only - Install only C headers instead of whole package. Mainly used by sys-devel/crossdev for toolchain bootstrap.
    heif - Enable support for ISO/IEC 23008-12:2017 HEIF/HEIC image format
    hscolour - Include coloured haskell sources to generated documentation (dev-haskell/hscolour)
    http2 - Enable support for the HTTP/2 protocol
    ibm - Add support for IBM ppc64 specific systems
    iconv - Enable support for the iconv character set conversion library
    icu - Enable ICU (Internationalization Components for Unicode) support, using dev-libs/icu
    idn - Enable support for Internationalized Domain Names
    ieee1394 - Enable FireWire/iLink IEEE1394 support (dv, camera, ...)
    imagemagick - Enable optional support for the ImageMagick or GraphicsMagick image converter
    imap - Add support for IMAP (Internet Mail Application Protocol)
    imlib - Add support for imlib, an image loading and rendering library
    infiniband - Enable Infiniband RDMA transport support
    initramfs - Include kernel modules in the initramfs, and re-install the kernel (only effective for distribution kernels)
    inotify - Enable inotify filesystem monitoring support
    introspection - Add support for GObject based introspection
    io-uring - Enable the use of io_uring for efficient asynchronous IO and system requests
    iodbc - Add support for iODBC library
    ios - Enable support for Apple's iDevice with iOS operating system (iPad, iPhone, iPod, etc)
    ipod - Enable support for iPod device access
    ipv6 - Add support for IP version 6
    jack - Add support for the JACK Audio Connection Kit
    java - Add support for Java
    javascript - Enable javascript support
    jbig - Enable jbig-kit support for tiff, Hylafax, ImageMagick, etc
    jemalloc - Use dev-libs/jemalloc for memory management
    jit - Enable just-in-time compilation for improved performance. May prevent use of some PaX memory protection features in Gentoo Hardened.
    joystick - Add support for joysticks in all packages
    jpeg - Add JPEG image support
    jpeg2k - Support for JPEG 2000, a wavelet-based image compression format
    jpegxl - Add JPEG XL image support
    kde - Add support for software made by KDE, a free software community
    kerberos - Add kerberos support
    keyring - Enable support for freedesktop.org Secret Service API password store
    ladspa - Enable the ability to support ladspa plugins
    lame - Prefer using LAME libraries for MP3 encoding support
    lapack - Add support for the virtual/lapack numerical library
    lash - Add LASH Audio Session Handler support
    latex - Add support for LaTeX (typesetting package)
    lcms - Add lcms support (color management engine)
    ldap - Add LDAP support (Lightweight Directory Access Protocol)
    lerc - Add LERC suppport (Limited Error Raster Compression)
    libass - SRT/SSA/ASS (SubRip / SubStation Alpha) subtitle support
    libcaca - Add support for colored ASCII-art graphics
    libedit - Use the libedit library (replacement for readline)
    libffi - Enable support for Foreign Function Interface library
    libnotify - Enable desktop notification support
    libsamplerate - Build with support for converting sample rates using libsamplerate
    libwww - Add libwww support (General purpose WEB API)
    lirc - Add support for lirc (Linux's Infra-Red Remote Control)
    livecd - !!internal use only!! DO NOT SET THIS FLAG YOURSELF!, used during livecd building
    llvm-libunwind - Use llvm-runtimes/libunwind instead of sys-libs/libunwind
    lm-sensors - Add linux lm-sensors (hardware sensors) support
    lto - Enable Link-Time Optimization (LTO) to optimize the build
    lua - Enable Lua scripting support
    lz4 - Enable support for lz4 compression (as implemented in app-arch/lz4)
    lzip - Enable support for lzip compression
    lzma - Support for LZMA compression algorithm
    lzo - Enable support for lzo compression
    m17n-lib - Enable m17n-lib support
    mad - Add support for mad (high-quality mp3 decoder library and cli frontend)
    magic - Add support for file type detection via magic bytes (usually via libmagic from sys-apps/file)
    maildir - Add support for maildir (~/.maildir) style mail spools
    man - Build and install man pages
    matroska - Add support for the matroska container format (extensions .mkv, .mka and .mks)
    mbox - Add support for mbox (/var/spool/mail) style mail spools
    memcached - Add support for memcached
    mhash - Add support for the mhash library
    mikmod - Add libmikmod support to allow playing of SoundTracker-style music files
    milter - Add sendmail mail filter (milter) support
    minimal - Install a very minimal build (disables, for example, plugins, fonts, most drivers, non-critical features)
    mmap - Add mmap (memory map) support
    mms - Support for Microsoft Media Server (MMS) streams
    mng - Add support for libmng (MNG images)
    modplug - Add libmodplug support for playing SoundTracker-style music files
    modules - Build the kernel modules
    modules-compress - Install compressed kernel modules (if kernel config enables module compression)
    modules-sign - Cryptographically sign installed kernel modules (requires CONFIG_MODULE_SIG=y in the kernel)
    mono - Build Mono bindings to support dotnet type stuff
    motif - Add support for the Motif toolkit
    mp3 - Add support for reading mp3 files
    mp4 - Support for MP4 container format
    mpeg - Add libmpeg3 support to various packages
    mpi - Add MPI (Message Passing Interface) layer to the apps that support it
    mplayer - Enable mplayer support for playback or encoding
    mssql - Add support for Microsoft SQL Server database
    mtp - Enable support for Media Transfer Protocol
    multilib - On 64bit systems, if you want to be able to compile 32bit and 64bit binaries
    musepack - Enable support for the musepack audio codec
    musicbrainz - Lookup audio metadata using MusicBrainz community service (musicbrainz.org)
    mysql - Add mySQL Database support
    mysqli - Add support for the improved mySQL libraries
    nas - Add support for network audio sound
    native-extensions - Build native (e.g. C, Rust) extensions in addition to pure (e.g. Python) code (usually speedups)
    ncurses - Add ncurses support (console display library)
    neXt - Enable neXt toolkit
    netcdf - Enable NetCDF data format support
    networkmanager - Enable net-misc/networkmanager support
    nis - Support for NIS/YP services
    nls - Add Native Language Support (using gettext - GNU locale utilities)
    nntp - Add support for newsgroups (Network News Transfer Protocol)
    nocd - Install all files required to run the application without a CD mounted
    nsplugin - Build plugin for browsers supporting the Netscape plugin architecture (that is almost any modern browser)
    nvenc - Add support for NVIDIA Encoder/Decoder (NVENC/NVDEC) API for hardware accelerated encoding and decoding on NVIDIA cards (requires x11-drivers/nvidia-drivers)
    ocaml - Add support/bindings for the Ocaml language
    ocamlopt - Enable ocamlopt support (ocaml native code compiler) -- Produces faster programs (Warning: you have to disable/enable it at a global scale)
    oci8 - Add Oracle 8 Database Support
    oci8-instant-client - Use dev-db/oracle-instantclient-basic as Oracle provider instead of requiring a full Oracle server install
    odbc - Add ODBC Support (Open DataBase Connectivity)
    offensive - Enable potentially offensive items in packages
    ofx - Enable support for importing (and exporting) OFX (Open Financial eXchange) data files
    ogg - Add support for the Ogg container format (commonly used by Vorbis, Theora and flac)
    openal - Add support for the Open Audio Library
    opencl - Enable OpenCL support (computation on GPU)
    openexr - Support for the OpenEXR graphics file format
    opengl - Add support for OpenGL (3D graphics)
    openmp - Build support for the OpenMP (support parallel computing), requires >=sys-devel/gcc-4.2 built with USE="openmp"
    opentype-compat - Convert BDF and PCF bitmap fonts to OTB wrapper format
    opus - Enable Opus audio codec support
    oracle - Enable Oracle Database support
    orc - Use dev-lang/orc for just-in-time optimization of array operations
    osc - Enable support for Open Sound Control
    oss - Add support for OSS (Open Sound System)
    otf - Install OpenType font versions
    pam - Add support for PAM (Pluggable Authentication Modules) - DANGEROUS to arbitrarily flip
    pch - Enable precompiled header support for faster compilation at the expense of disk space and memory
    pcmcia - Add support for PCMCIA slots/devices found on laptop computers
    pcre - Add support for Perl Compatible Regular Expressions
    pda - Add support for portable devices
    pdf - Add general support for PDF (Portable Document Format), this replaces the pdflib and cpdflib flags
    perl - Add optional support/bindings for the Perl language
    php - Include support for the PHP language
    pie - Build programs as Position Independent Executables (a security hardening technique)
    plasma - Build optional KDE plasma addons
    plotutils - Add support for plotutils (library for 2-D vector graphics)
    png - Add support for libpng (PNG images)
    policykit - Enable PolicyKit (polkit) authentication support
    portaudio - Add support for the crossplatform portaudio audio API
    posix - Add support for POSIX-compatible functions
    postgres - Add support for the postgresql database
    postscript - Enable support for the PostScript language (often with ghostscript-gpl or libspectre)
    ppds - Add support for automatically generated ppd (printing driver) files
    prefix - Defines if a Gentoo Prefix offset installation is used
    profile - Add support for software performance analysis (will likely vary from ebuild to ebuild)
    pulseaudio - Add sound server support via media-libs/libpulse (may be PulseAudio or PipeWire)
    python - Add optional support/bindings for the Python language
    qdbm - Add support for the qdbm (Quick Database Manager) library
    qmail-spp - Add support for qmail SMTP plugins
    qt5 - Add support for the Qt 5 application and UI framework
    qt6 - Add support for the Qt 6 application and UI framework
    quicktime - Add support for OpenQuickTime
    radius - Add support for RADIUS authentication
    raw - Add support for raw image formats
    rdp - Enables RDP/Remote Desktop support
    readline - Enable support for libreadline, a GNU line-editing library that almost everyone wants
    recode - Enable support for the GNU recode library
    rss - Enable support for RSS feeds
    ruby - Add support/bindings for the Ruby language
    samba - Add support for SAMBA (Windows File and Printer sharing)
    sasl - Add support for the Simple Authentication and Security Layer
    savedconfig - Use this to restore your config from /etc/portage/savedconfig ${CATEGORY}/${PN}. Make sure your USE flags allow for appropriate dependencies
    scanner - Add support for scanner hardware (e.g. build the sane frontend in kdegraphics)
    screencast - Enable support for remote desktop and screen cast using PipeWire
    sctp - Support for Stream Control Transmission Protocol
    sdl - Add support for Simple Direct Layer (media library)
    seccomp - Enable seccomp (secure computing mode) to perform system call filtering at runtime to increase security of programs
    secureboot - Automatically sign efi executables using user specified key
    selinux - !!internal use only!! Security Enhanced Linux support, this must be set by the selinux profile or breakage will occur
    semantic-desktop - Cross-KDE support for semantic search and information retrieval
    session - Add persistent session support
    sid - Enable SID (Commodore 64 audio) file support
    skey - Enable S/Key (Single use password) authentication support
    slang - Add support for the slang text display library (it's like ncurses, but different)
    smartcard - Enable smartcard support
    smp - Enable support for multiprocessors or multicore systems
    snappy - Enable support for Snappy compression (as implemented in app-arch/snappy)
    sndfile - Add support for libsndfile
    snmp - Add support for the Simple Network Management Protocol if available
    soap - Add support for SOAP (Simple Object Access Protocol)
    sockets - Add support for tcp/ip sockets
    socks5 - Add support for the socks5 proxy
    sound - Enable sound support
    source - Zip the sources and install them
    sox - Add support for Sound eXchange (SoX)
    speech - Enable text-to-speech support
    speex - Add support for the speex audio codec (used for speech)
    spell - Add dictionary support
    split-usr - Enable behavior to support maintaining /bin, /lib*, /sbin and /usr/sbin  separately from /usr/bin and /usr/lib*
    sqlite - Add support for sqlite - embedded sql database
    ssl - Add support for SSL/TLS connections (Secure Socket Layer / Transport Layer Security)
    startup-notification - Enable application startup event feedback mechanism
    static - !!do not set this during bootstrap!! Causes binaries to be statically linked instead of dynamically
    static-libs - Build static versions of dynamic libraries as well
    strip - Allow symbol stripping to be performed by the ebuild for special files
    subversion - Enable subversion (version control system) support
    suid - Enable setuid root program(s)
    svg - Add support for SVG (Scalable Vector Graphics)
    svga - Add support for SVGAlib (graphics library)
    symlink - Force kernel ebuilds to automatically update the /usr/src/linux symlink
    syslog - Enable support for syslog
    systemd - Enable use of systemd-specific libraries and features like socket activation or session tracking
    szip - Use the szip compression library
    taglib - Enable tagging support with taglib
    tcl - Add support the Tcl language
    tcmalloc - Use the dev-util/google-perftools libraries to replace the malloc() implementation with a possibly faster one
    tcpd - Add support for TCP wrappers
    telemetry - Send anonymized usage information to upstream so they can better understand our users
    test - Enable dependencies and/or preparations necessary to run tests (usually controlled by FEATURES=test but can be toggled independently)
    test-install - Install testsuite for manual execution by the user
    test-rust - Enable important test dependencies that require Rust toolchain
    theora - Add support for the Theora Video Compression Codec
    threads - Add threads support for various packages. Usually pthreads
    tidy - Add support for HTML Tidy
    tiff - Add support for the TIFF image format
    time64 - Use 64-bit time_t type instead of the regular 32-bit type. This flag is forced on time64 profiles, and masked elsewhere. It should be only used when detection of type width is not possible (e.g. for SRC_URI)
    timidity - Build with Timidity++ (MIDI sequencer) support
    tk - Add support for Tk GUI toolkit
    truetype - Add support for FreeType and/or FreeType2 fonts
    ttf - Install TrueType font versions
    udev - Enable virtual/udev integration (device discovery, power and storage device support, etc)
    udisks - Enable storage management support (automounting, volume monitoring, etc)
    uefi - Enable support for the Unified Extensible Firmware Interface
    unicode - Add support for Unicode
    unwind - Add support for call stack unwinding and function name resolution
    upnp - Enable UPnP port mapping support
    upnp-av - Enable UPnP audio/video streaming support
    upower - Enable power management support
    usb - Add USB support to applications that have optional USB support (e.g. cups)
    v4l - Enable support for video4linux (using linux-headers or userspace libv4l libraries)
    vaapi - Enable Video Acceleration API for hardware decoding
    vala - Enable bindings for dev-lang/vala
    valgrind - Enable annotations for accuracy. May slow down runtime slightly. Safe to use even if not currently using dev-debug/valgrind
    vanilla - Do not add extra patches which change default behaviour; DO NOT USE THIS ON A GLOBAL SCALE as the severity of the meaning changes drastically
    vcd - Video CD support
    vdpau - Enable the Video Decode and Presentation API for Unix acceleration interface
    verify-sig - Verify upstream signatures on distfiles
    vhosts - Add support for installing web-based applications into a virtual-hosting environment
    videos - Install optional video files (used in some games)
    vim-syntax - Pulls in related vim syntax scripts
    vnc - Enable VNC (remote desktop viewer) support
    vorbis - Add support for the OggVorbis audio codec
    vpx - Add support for VP8/VP9 codecs (usually via media-libs/libvpx)
    vulkan - Add support for 3D graphics and computing via the Vulkan cross-platform API
    wavpack - Add support for wavpack audio compression tools
    wayland - Enable dev-libs/wayland backend
    webkit - Add support for the WebKit HTML rendering/layout engine
    webp - Add support for the WebP image format
    wifi - Enable wireless network functions
    wmf - Add support for the Windows Metafile vector image format
    wxwidgets - Add support for wxWidgets/wxGTK GUI toolkit
    x264 - Enable h264 encoding using x264
    xattr - Add support for extended attributes (filesystem-stored metadata)
    xcb - Support the X C-language Binding, a replacement for Xlib
    xcomposite - Enable support for the Xorg composite extension
    xemacs - Add support for XEmacs
    xface - Add xface support used to allow a small image of xface format to be included in an email via the header 'X-Face'
    xft - Build with support for XFT font renderer (x11-libs/libXft)
    xine - Add support for the XINE movie libraries
    xinerama - Add support for querying multi-monitor screen geometry through the Xinerama API
    xinetd - Add support for the xinetd super-server
    xml - Add support for XML files
    xmlrpc - Support for xml-rpc library
    xmp - Enable support for Extensible Metadata Platform (Adobe XMP)
    xmpp - Enable support for Extensible Messaging and Presence Protocol (XMPP) formerly known as Jabber
    xosd - Sends display using the X On Screen Display library
    xpm - Add support for XPM graphics format
    xscreensaver - Add support for XScreenSaver extension
    xv - Add in optional support for the Xvideo extension (an X API for video playback)
    xvid - Add support for xvid.org's open-source mpeg-4 codec
    zeroconf - Support for DNS Service Discovery (DNS-SD)
    zip - Enable support for ZIP archives
    zlib - Add support for zlib compression
    zsh-completion - Enable zsh completion support
    zstd - Enable support for ZSTD compression


<a id="org07cbeda"></a>

## packages


<a id="org11f5535"></a>

### package.use

1.  emacs

        app-editors/emacs libxml2 dynamic-loading json xwidgets

2.  ffmpeg

        media-video/ffmpeg libass opus vpx

3.  glibc

        sys-libs/glibc hash-sysv-compat

4.  qbittorrent

        net-p2p/qbittorrent gui webui

5.  wine-proton

        app-emulation/wine-proton osmesa v4l

6.  rust

        dev-lang/rust  clippy doc rust-analyzer rust-src rust-fmt
        dev-lang/rust-bin clippy rust-src rust-analyzer rustfmt

7.  gcc

        sys-devel/gcc jit

8.  libdrm

        x11-libs/libdrm video_cards_radeon

9.  obs-studio

        meida-video/obs-studio pipewire

10. pipewire

    \#+begin<sub>src</sub> shell
      media-video/pipewire gstreamer

11. librime-lua

        app-i18n/librime-lua lua_single_target_lua5-4


<a id="org36a3f34"></a>

### package.accept<sub>keywords</sub>

1.  gentoo-zh/xanmod-kernel

        sys-kernel/xanmod-kernel ~amd64


<a id="org0ff5b57"></a>

# 应该安装的包

    fcitx-gtk


<a id="orgee4e1c2"></a>

# 问题

-   当遇到编译出错时 可以试着先更新portage包
-   也可以用equery看看出错包的依赖 然后先更新那些包


<a id="org99d9fc2"></a>

# Ebuild


<a id="orgdeb829d"></a>

## 标准变量(variables)

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">P</td>
<td class="org-left">软件包名称-版本 \({PN}-\){PV} eg. vim-6.3</td>
</tr>

<tr>
<td class="org-left">PN</td>
<td class="org-left">仅包名称 eg. vim</td>
</tr>

<tr>
<td class="org-left">PV</td>
<td class="org-left">包版本 eg. 6.3</td>
</tr>

<tr>
<td class="org-left">PR</td>
<td class="org-left">修订</td>
</tr>

<tr>
<td class="org-left">PVR</td>
<td class="org-left">版本-修订 \({PV}-\){PR} eg. 6.3-r1</td>
</tr>

<tr>
<td class="org-left">PF</td>
<td class="org-left">包名称-版本-修订 \({PN}-\){PVR} eg. vim-6.3-r1</td>
</tr>

<tr>
<td class="org-left">A</td>
<td class="org-left">包所有的源代码文件(不包括USE关闭的)</td>
</tr>

<tr>
<td class="org-left">CATEGORY</td>
<td class="org-left">包的类别 eg. app-editors/emacs的app-editors</td>
</tr>

<tr>
<td class="org-left">FILESDIR</td>
<td class="org-left">包目录的files/的文件 用于一些patch或者其他</td>
</tr>

<tr>
<td class="org-left">WORKDIR</td>
<td class="org-left">ebuild根构建目录的路径 eg.${PORTAGE<sub>BUILDDIR</sub>}/work</td>
</tr>

<tr>
<td class="org-left">T</td>
<td class="org-left">ebuild可能使用的临时目录路径 eg.${PORTAGE<sub>BUILDDIR</sub>}/temp</td>
</tr>

<tr>
<td class="org-left">D</td>
<td class="org-left">临时安装目录的路径 eg. ${PORTAGE<sub>BUILDDIR</sub>}/image</td>
</tr>

<tr>
<td class="org-left">HOME</td>
<td class="org-left">临时目录的路径 供ebuild调用的任何可你呢个读取或修改主目录的程序用 eg. ${PORTAGE<sub>BUILDDIR</sub>}/homedir</td>
</tr>

<tr>
<td class="org-left">ROOT</td>
<td class="org-left">软件包要合并到根目录的绝对路径 仅在pkg<sub>*</sub>阶段允许</td>
</tr>

<tr>
<td class="org-left">DISTDIR</td>
<td class="org-left">包含存储为包获取的所有文件的目录的路径</td>
</tr>

<tr>
<td class="org-left">EPREFIX</td>
<td class="org-left">PREFIX安装的规范化PREFIX前缀路径</td>
</tr>

<tr>
<td class="org-left">ED</td>
<td class="org-left">\({D%/}\){EPREFIX}/ 的简写</td>
</tr>

<tr>
<td class="org-left">EROOT</td>
<td class="org-left">\({ROOT%/}\){EPREFIX}/ 的简写</td>
</tr>

<tr>
<td class="org-left">SYSROOT</td>
<td class="org-left">(EAPI=7)包含构建依赖的根目录的绝对路径</td>
</tr>

<tr>
<td class="org-left">ESYSROOT</td>
<td class="org-left">(EAPI=7)\({SYSROOT%/}\){EPREFIX}/ 的简写</td>
</tr>

<tr>
<td class="org-left">BROOT</td>
<td class="org-left">(EAPI=7)包含所满足的构建依赖项的根目录的绝对路径BDEPEND，通常是可执行构建工具。</td>
</tr>

<tr>
<td class="org-left">MERGE<sub>TYPE</sub></td>
<td class="org-left">正在合并的软件包类型(类似portage feature的buildpkg): source代表源代码 binary是否安装ebuild构建的二进制包 buildonly仅构建不安装</td>
</tr>

<tr>
<td class="org-left">REPLACING<sub>VERSIONS</sub></td>
<td class="org-left">此软件包的所有版本(PVR)的空格分格列表</td>
</tr>

<tr>
<td class="org-left">REPLACED<sub>BY</sub><sub>VERSION</sub></td>
<td class="org-left">若此软件包作为安装的一部分被卸载 则返回软件版本(PVR)</td>
</tr>
</tbody>
</table>


<a id="org62d426c"></a>

## Ebuild定义变量

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">EAPI</td>
<td class="org-left">EAPI版本</td>
</tr>

<tr>
<td class="org-left">DESCRIPTION</td>
<td class="org-left">(必须)软件包的简短描述 &lt;=80字</td>
</tr>

<tr>
<td class="org-left">HOMEPAGE</td>
<td class="org-left">(必须)软件包主页 缺省值:<a href="https://wiki.gentoo.org/wiki/No_homepage">https://wiki.gentoo.org/wiki/No_homepage</a></td>
</tr>

<tr>
<td class="org-left">SRC<sub>URI</sub></td>
<td class="org-left">软件包URI列表</td>
</tr>

<tr>
<td class="org-left">LICENSE</td>
<td class="org-left">许可</td>
</tr>

<tr>
<td class="org-left">SLOT</td>
<td class="org-left">(必须)包的SLOT</td>
</tr>

<tr>
<td class="org-left">KEYWORDS</td>
<td class="org-left">包的keywords</td>
</tr>

<tr>
<td class="org-left">IUSE</td>
<td class="org-left">ebuild中所有USE(不包括arch)</td>
</tr>

<tr>
<td class="org-left">REQUIRED<sub>USE</sub></td>
<td class="org-left">必须满足的USE</td>
</tr>

<tr>
<td class="org-left">PROPERTIES</td>
<td class="org-left">空格分格的属性列表 支持条件语法 :interactive live test<sub>network</sub></td>
</tr>

<tr>
<td class="org-left">RESTRICT</td>
<td class="org-left">空格分格的要限制的portage功能列表 :fetch mirror strip test userpriv</td>
</tr>

<tr>
<td class="org-left">DEPEND</td>
<td class="org-left">构建依赖表</td>
</tr>

<tr>
<td class="org-left">BDEPEND</td>
<td class="org-left">(EAPI=7) CBUILD依赖表</td>
</tr>

<tr>
<td class="org-left">RDEPEND</td>
<td class="org-left">运行时依赖表</td>
</tr>

<tr>
<td class="org-left">PDEPEND</td>
<td class="org-left">合并后要安装的包列表</td>
</tr>

<tr>
<td class="org-left">S</td>
<td class="org-left">临时的构建目录路径 由src<sub>compile,src</sub><sub>install使用</sub> 默认:\({WORKDIR}/\){P}</td>
</tr>

<tr>
<td class="org-left">DOCS</td>
<td class="org-left">src<sub>install默认安装的文档文件列表</sub></td>
</tr>

<tr>
<td class="org-left">HTML<sub>DOCS</sub></td>
<td class="org-left">einstalldocs要递归安装的文档列表</td>
</tr>
</tbody>
</table>


<a id="org9b26e57"></a>

### SRC<sub>URI</sub>

可以条件性的下载源码

    SRC_URI = " https://example.com/files/${P}-core.tar.bz2
              x86? (https://example.com/files/${P}-sse-asm.tar.bz2)
    "

也可以重命名

    SRC_URI = "https://example.com/files/${PV}.tar.gz -> ${P}.tar.gz"

也可以定义多个下载源

    github https://github.com https://ghproxy.net
    SRC_URI="mirror://github/${PN}/${P}.tar.gz"


<a id="org3451ac0"></a>

### REQUIRED<sub>USE</sub>

USE关系

如果foo 则不能有bar

    REQUIRED_USE = " foo? (!bar) "

如果foo 则有必须bar 或 baz 或 quux 至少一个

    REQUIRED_USE = "foo? (|| (bar baz quux))"

必须foo bar gaz中至少一个

    REQUIRED_USE = "|| (bar baz quux)"

必须foo bar gaz中一个 不能多

    REQUIRED_USE = " ^^ （ foo bar baz ）"

必须一个或零个 不能多

    REQUIRED_USE = " ?? (a b c)"


<a id="orgcfb487d"></a>

## 用户环境


<a id="orgc2a86ff"></a>

## skel.ebuild中文

      # 版权所有 1999-2025 Gentoo 作者
    # 根据 GNU 通用公共许可证 v2 条款分发
    
    # 注意：此文件中的注释仅用于说明和文档。
    # 它们不应该出现在你的最终生产 ebuild 中。请
    # 记得在提交或确认你的 ebuild 之前删除它们。
    # 但并不意味着您不能添加自己的评论。
    
    # EAPI 变量告诉正在使用的 ebuild 格式。
    # 建议您使用理事会批准的最新 EAPI。
    # PMS 包含所有 EAPI 的规范。Eclasses 将对此进行测试
    # 如果他们需要使用并非所有 EAPI 都通用的功能，则变量。
    # 如果 eclass 不支持最新的 EAPI，则使用以前的 EAPI。
    EAPI=8
    
    
    # 继承列出要从中继承函数的 eclass。例如，ebuild
    # 需要 autotools.eclass 中的 eautoreconf 函数将无法工作
    # 没有下面这一行：
    # inherit autotools
    #
    # Eclasses 倾向于列出如何正确使用其功能的描述。
    # 查看 eclass/ 目录以获取更多示例。
    
    # 该包的简短一行描述。
    DESCRIPTION="这是一个示例骨架 ebuild 文件"
    
    # 主页，Portage 不直接使用，但方便开发人员参考
    HOMEPAGE="https://foo.example.org/"
    
    # 指向任何所需的源；这些将由
    # 搬运。
    SRC_URI="ftp://foo.example.org/${P}.tar.gz"
    
    # 源目录；可以找到源的目录（自动
    # 解压后）放在 ${WORKDIR} 中。S 的默认值是 ${WORKDIR}/${P}
    # 如果你不需要改变它，请将 S= 行从 ebuild 中移除
    # 保持整洁。
    #S="${WORKDIR}/${P}"
    
    
    # 软件包的许可证。这必须与
    # licenses/ 目录。对于复杂的许可证组合，请参阅开发者
    # 请参阅 gentoo.org 上的文档以了解详细信息。
    LICENSE=""
    
    # SLOT 变量用于告诉 Portage 是否可以保留多个
    # 同时安装同一软件包的多个版本。例如，
    # 如果我们有 libfoo-1.2.2 和 libfoo-1.3.2（不兼容）
    # 对于 1.2.2 版本，最好指示 Portage 不要删除
    # 如果我们决定升级到 libfoo-1.3.2，则需要使用 libfoo-1.2.2。为此，
    # 我们在 libfoo-1.2.2 中指定 SLOT="1.2"，在 libfoo-1.3.2 中指定 SLOT="1.3"。
    # emerge clean 了解 SLOT，并将保留最新版本
    #每个 SLOT 的数量并删除其他所有内容。
    # 注意，如果可能的话，普通应用程序应该使用 SLOT="0"，因为
    # 一次只能安装一个版本。
    # 不要使用 SLOT=""，因为 SLOT 变量不能为空。
    SLOT="0"
    
    # 使用关键词，我们可以在 ebuild 内部记录屏蔽信息
    # 而不是依赖外部的 package.mask 文件。现在，你
    # 应该为每个 ebuild 设置 KEYWORDS 变量，以便它包含
    # ebuild 适用的所有架构的名称。
    # 所有官方架构都可以在 arch.list 文件中找到
    # 位于 profiles/ 目录中。通常你应该只设置这个
    # 改为“~amd64”。体系结构前面的 ~ 表示
    # 软件包是新的，在测试证明之前应该被认为是不稳定的
    # 它的稳定性。所以，如果你已经确认你的 ebuild 可以在
    # amd64 和 ppc，您需要指定：
    # 关键词="~amd64 ~ppc"
    # 一旦软件包稳定下来，~ 前缀就会被删除。
    # 对于二进制包，使用 -* 然后列出 bin 包的 archs
    # 存在。如果该包是针对 x86 二进制包的，那么
    # KEYWORDS 应设置如下：KEYWORDS="-* x86"
    # 不要使用 KEYWORDS="*"；这在 ebuild 上下文中无效。
    KEYWORDS="~amd64"
    
    # ebuild 中利用的所有 USE 标志的综合列表，
    # 有一些例外，例如 ARCH 特定标志，如“amd64”或“ppc”。
    # 如果 ebuild 不使用任何 USE 标志，则不需要。
    IUSE="gnome X"
    
    # 以空格分隔的要限制的 portage 功能列表。man 5 ebuild
    # 了解详细信息。通常不需要。
    #RESTRICT="剥离"
    
    
    # 运行时依赖项。必须将其定义为运行所依赖的任何内容。
    # 例子：
    # SSL？（>=dev-libs/openssl-1.0.2q:0=）
    #>=dev-lang/perl-5.24.3-r1
    # 建议使用上面显示的 >= 语法，以反映您
    # 在您测试软件包时，它已安装在您的系统上。然后
    # 希望其他用户不会因为没有正确版本的
    # 依赖项。
    #RDEPEND=""
    
    # 需要与系统二进制兼容的构建时依赖项
    # 正在构建（CHOST）。其中包括我们链接的库。
    # 如果需要相同的运行时依赖来编译，则以下内容有效。
    #DEPEND="${RDEPEND}"
    
    # 在 emerge 过程中执行的构建时依赖项，以及
    # 仅需存在于原生构建系统 (CBUILD) 中。例如：
    #BDEPEND="虚拟/pkgconfig"
    
    
    # 下面的 src_configure 函数是 portage 默认实现的，因此
    # 仅当您需要不同的行为时才需要调用它。
    #src_configure() {
    # 大多数开源包使用 GNU autoconf 进行配置。
    # 运行 configure 的默认、最快（也是首选）方式是：
    #econf
    #
    # 您可以使用类似于以下几行来
    # 在编译之前配置你的包。“|| die”部分
    如果命令失败，最后的#将停止构建过程。
    # 您应该在构建过程中的关键命令末尾使用它
    # 过程。（提示：大多数命令都很关键，例如构建
    # 如果不成功，进程应该中止。）
    #./配置 \
    # --host=${CHOST} \
    # --prefix=/usr\
    # --infodir=/usr/share/info \
    # --mandir=/usr/share/man ||死
    # 注意上面 --infodir 和 --mandir 的用法。这是为了让
    # 此软件包符合 FHS 2.2 标准。更多信息，请参阅
    # https://wiki.linuxfoundation.org/lsb/fhs
    #}
    
    # 下面的 src_compile 函数是 portage 默认实现的，因此
    # 如果您需要不同的行为，您只需调用它。
    #src_compile() {
    # emake 是一个使用并行调用标准 GNU make 的脚本
    # 构建选项以实现更快的构建（尤其是在 SMP 系统上）。
    # 先尝试 emake。它可能不适用于某些软件包，因为
    # 一些 makefile 存在与并行性相关的错误，在这种情况下，
    # 使用 emake -j1 将 make 限制为单个进程。-j1 是一个
    # 向其他人提供视觉线索，表明 makefile 存在错误，
    # 解决了。
    
    #emake
    #}
    
    # 下面的 src_install 函数是 portage 默认实现的，因此
    # 如果您需要不同的行为，您只需调用它。
    #src_install() {
    # 你必须*亲自验证*此技巧是否无法安装
    # DESTDIR 之外的任何内容；通过阅读和
    # 了解 Makefile 的安装部分。
    # 这是首选的安装方式。
    #emake DESTDIR="${D}" 安装
    
    # 当你使用 emake 失败时，不要只使用 make。
    # 最好修复 Makefile 以允许正确的并行化。
    # 如果失败了，请使用“emake -j1”，它仍然比 make 更好。
    
    # 对于没有正确使用 DESTDIR 的 Makefile，设置
    # 前缀通常是一种替代方案。但是如果你这样做，那么
    # 您还需要指定 mandir 和 infodir，因为它们是
    # 传递给 ./configure 作为绝对路径（覆盖前缀
    # 环境）。
    #emake \
    # 前缀="${D}"/usr \
    # mandir="${D}" /usr/share/man \
    # infodir="${D}"/usr/share/info \
    # libdir="${D}"/usr/$(get_libdir) \
    ＃ 安装
    # 再次验证 Makefile！我们不希望出现任何问题
    # 在 ${D} 之外。
    #}


<a id="org5e63a75"></a>

## 编写dotnet项目的ebuild

首先我们需要安装gdmt

    sudo emerge -v dev-dotnet/gentoo-dotnet-maintainer-tools

然后我们安装dotnet-sdk

    sudo emerge -v dev-dotnet/dotnet-sdk-bin

我们到项目的path 然后执行

    gdmt restore -e sdk版本

接下来可以获取NUGET

## 错误
### ninja: error: manifest 'build.ninja' still dirty after 100 tries, perhaps system time is notset
修改系统时间到未来
```shell
date -s "2094-06-11 15:30:00"
```
