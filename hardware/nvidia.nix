{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;  # use the open kernel module
    package = config.boot.kernelPackages.nvidiaPackages.latest; # switch to stable if something breaks

    powerManagement.enable = false;
    nvidiaPersistenced = true;
  };
}
