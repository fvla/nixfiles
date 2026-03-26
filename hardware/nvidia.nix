{ config, pkgs, pkgs-unstable, ... }:
{
  hardware.graphics.enable = true;

  # Use latest vaapi driver
  hardware.nvidia.videoAcceleration = false;
  hardware.graphics.extraPackages = with pkgs-unstable; [
    nvidia-vaapi-driver
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;  # use the open kernel module
    package = config.boot.kernelPackages.nvidiaPackages.latest; # switch to stable if something breaks

    powerManagement.enable = false;
    nvidiaPersistenced = true;
  };
}
