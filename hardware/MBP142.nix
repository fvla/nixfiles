{ config, pkgs, ... }:
let
  kernelPackages = config.boot.kernelPackages;
  kernel = kernelPackages.kernel;
in
{
  environment.systemPackages = with pkgs; [wirelesstools tiny-dfr];
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  systemd.services.brcm-txpower = {
    description = "Lock BCM43602 txpower to 10 dBm";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-pre.target" "sys-subsystem-net-devices-wlp2s0.device" ];
    requires = [ "sys-subsystem-net-devices-wlp2s0.device" ];

    serviceConfig.Type = "oneshot";
    script = ''
      for i in {1..15}; do
        ${pkgs.wirelesstools}/bin/iwconfig wlp2s0 txpower 10dBm 2>/dev/null && exit 0
	sleep 1
      done
      echo "WARNING: Failed to set txpower on wlp2s0" >&2
    '';
  };

  # ===== Custom kernel modules for MacBook Pro hardware support =====
  boot.initrd.kernelModules = [ "apple-bce" "apple-ib-tb" ];
  boot.extraModulePackages = [
    # Audio driver for MacBook Pro
    (pkgs.stdenv.mkDerivation rec {
      pname = "snd_hda_macbookpro";
      version = "2025-11-24";

      # Driver patches and custom files
      driverSrc = pkgs.fetchFromGitHub {
        owner = "davidjo";
        repo = "snd_hda_macbookpro";
        rev = "5c7a1c24459aa93e67f293e695914affe057035a";
        hash = "sha256-mLhY57j7taBROWCiuH2Oj2o9YxmpAenMs9aHwe0086M=";
      };

      # Use kernel source and build infrastructure
      inherit (kernel) src nativeBuildInputs;

      kernel_dev = kernel.dev;
      kernelVersion = kernel.modDirVersion;
      modulePath = "sound/hda";

      # Don't unpack kernel source normally - we'll extract just what we need
      dontUnpack = true;

      patchPhase = ''
        runHook prePatch

        # Extract only sound/hda from kernel source
        tar -xf ${kernel.src} --strip-components=1 linux-${kernel.version}/sound/hda
        chmod -R u+w sound

        cd sound/hda

        # Replace Makefiles with custom ones
        cp ${driverSrc}/makefiles/Makefile .
        cp ${driverSrc}/makefiles/Makefile_common common/Makefile
        cp ${driverSrc}/makefiles/Makefile_codecs codecs/Makefile
        cp ${driverSrc}/makefiles/Makefile_cirrus codecs/cirrus/Makefile

        # Copy custom headers
        cp ${driverSrc}/patch_cirrus/cirrus_apple.h codecs/cirrus/
        cp ${driverSrc}/patch_cirrus/patch_cirrus_boot84.h codecs/cirrus/
        cp ${driverSrc}/patch_cirrus/patch_cirrus_new84.h codecs/cirrus/
        cp ${driverSrc}/patch_cirrus/patch_cirrus_real84.h codecs/cirrus/
        cp ${driverSrc}/patch_cirrus/patch_cirrus_hda_generic_copy.h codecs/cirrus/
        cp ${driverSrc}/patch_cirrus/patch_cirrus_real84_i2c.h codecs/cirrus/

        # Apply patches (for kernel 6.17+)
        patch -p1 < ${driverSrc}/patch_cs8409.c.diff
        patch -p1 < ${driverSrc}/patch_cs8409.h.diff

        cd ../..

        runHook postPatch
      '';

      buildPhase = ''
        runHook preBuild

        BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

        # Copy necessary kernel build files to current directory
        cp $BUILT_KERNEL/Module.symvers .
        cp $BUILT_KERNEL/.config .
        cp $kernel_dev/vmlinux .

        # Build our module with custom CFLAGS (make will handle preparation)
        make -C $BUILT_KERNEL "-j$NIX_BUILD_CORES" \
          CFLAGS_MODULE="-DAPPLE_PINSENSE_FIXUP -DAPPLE_CODECS -DCONFIG_SND_HDA_RECONFIG=1 -Wno-unused-variable -Wno-unused-function" \
          M=$(pwd)/$modulePath \
          modules

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        make -C $kernel_dev/lib/modules/$kernelVersion/build \
          INSTALL_MOD_PATH="$out" \
          XZ="xz -T$NIX_BUILD_CORES" \
          M="$(pwd)/$modulePath" \
          modules_install

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Patched HDA audio driver for MacBook Pro";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
      };
    })

    # iBridge driver for Touch Bar and ALS
    (pkgs.stdenv.mkDerivation rec {
      pname = "mbp-t1-touchbar-driver";
      version = "unstable-2024";

      src = pkgs.fetchFromGitHub {
        owner = "parport0";
        repo = "mbp-t1-touchbar-driver";
        rev = "6d62f38c6b2c27da1becd311ad7b15826e58ed41";
        hash = "sha256-3YjShwyUBsqTRK/c3f4AVZJswlwpr3DoeDZEBZ3RkdQ=";
      };

      inherit (kernel) nativeBuildInputs;

      kernel_dev = kernel.dev;
      kernelVersion = kernel.modDirVersion;

      hardeningDisable = [ "pic" "format" ];

      makeFlags = [
        "KERNELRELEASE=${kernel.modDirVersion}"
        "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];

      buildPhase = ''
        runHook preBuild

        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) \
          modules

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) \
          INSTALL_MOD_PATH=$out \
          modules_install

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "iBridge driver for Touch Bar and Ambient Light Sensor";
        homepage = "https://github.com/parport0/mbp-t1-touchbar-driver";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
      };
    })

    # Apple BCE (Buffer Copy Engine) driver - Required for T2 chip communication
    (pkgs.stdenv.mkDerivation rec {
      pname = "apple-bce-drv";
      version = "unstable-2024";

      src = pkgs.fetchFromGitHub {
        owner = "t2linux";
        repo = "apple-bce-drv";
        rev = "4882e1b7dcb5ef00f488a3ecd16227e5a0824265";
        hash = "sha256-lq2UL/dBpxgWf7pAvP4BfY3aytjnW5zw4+dO/SctkHM=";
      };

      inherit (kernel) nativeBuildInputs;

      kernel_dev = kernel.dev;
      kernelVersion = kernel.modDirVersion;

      hardeningDisable = [ "pic" "format" ];

      makeFlags = [
        "KERNELRELEASE=${kernel.modDirVersion}"
        "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];

      buildPhase = ''
        runHook preBuild

        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) \
          modules

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) \
          INSTALL_MOD_PATH=$out \
          modules_install

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Apple BCE (Buffer Copy Engine) driver for T2 chip communication";
        homepage = "https://github.com/t2linux/apple-bce-drv";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
      };
    })
  ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=mbp131
    options snd-hda-codec-cs8409 model=mbp131
    options applespi fnremap=1 swap_opt_cmd=1
    options apple_ib_tb fnmode=2
  '';
  boot.kernelParams = [
    "brcmfmac.feature_disable=0x82000"
    "ieee80211.default_regdomain=US"
  ];
}
