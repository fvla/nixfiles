# Some quick notes:
# - configuration.nix is the global configuration for all machines.
# - ZenNix is a desktop machine with an NVIDIA GPU.
# - MBP142 is the MacBook Pro 14,2 (2017) T1 laptop, with special hardware support for audio and touchbar.
# - system.stateVersion should never be changed unless installing from scratch or after reading the NixOS docs.
# - Define users setup in users.nix and place in /etc/nixos. See examples/users.nix for a template.
{
  description = "NixOS root system flake";

  inputs = {
    sysflake.url = "/etc/nixos";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, sysflake, nixpkgs, nixpkgs-unstable, nixos-hardware, nix-cachyos-kernel, impermanence, ... }@inputs:
    let
      cachyosKernels = import "${self}/kernels/cachyos.nix" { inherit nix-cachyos-kernel; };
    in {
    nixosConfigurations.ZenNix = nixpkgs.lib.nixosSystem {
      specialArgs = { pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux; };
      modules = [
        impermanence.nixosModules.impermanence

        sysflake.nixosModules.users
        ./configuration.nix
        ./storage/impermanence-lite.nix
        ./hardware/nvidia.nix
        ./desktop/hyprland.nix
        ./desktop/mangowc.nix
        ./programs/podman.nix
        ./programs/steam.nix
        cachyosKernels.linux-cachyos-latest-lto-zen4
        { networking.hostName = "ZenNix"; }
        { system.stateVersion = "25.11"; }
        { nixpkgs.hostPlatform = "x86_64-linux"; }
	      {
          boot.kernelParams = [
            "video=DP-1:3840x2160@120"
            "video=DP-2:3840x2160@120"
            "video=DP-3:3840x2160@120"
          ];
        }
      ];
    };

    nixosConfigurations.MBP142 = nixpkgs.lib.nixosSystem {
      specialArgs = { pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux; };
      modules = [
        sysflake.nixosModules.users
        ./configuration.nix
        ./hardware/MBP142.nix
        ./desktop/pantheon.nix
        nixos-hardware.nixosModules.apple-macbook-pro-14-1
        { networking.hostName = "MBP142"; }
        { system.stateVersion = "25.05"; }
        { nixpkgs.hostPlatform = "x86_64-linux"; }
      ];
    };
  };
}
