{ config, pkgs, pkgs-unstable, ... }:
let
  nvidia-vaapi-overlay = final: prev: {
    nvidia-vaapi-driver = prev.nvidia-vaapi-driver.overrideAttrs (oldAttrs: {
      version = "0.0.16";

      src = prev.fetchFromGitHub {
        owner = "elFarto";
        repo = "nvidia-vaapi-driver";
        rev = "v0.0.16";
        sha256 = "sha256-9Gwr13j+JjU3BlN/8E3dKGmBj79rtR9rrZuOa1aYyYI=";
      };
    });
  };
in {
  nixpkgs.overlays = [ nvidia-vaapi-overlay ];

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
