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
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.follows = "sysflake/nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, sysflake, nixpkgs, nixos-hardware, impermanence, ... }@inputs: {
    nixosConfigurations.ZenNix = nixpkgs.lib.nixosSystem {
      modules = [
        impermanence.nixosModules.impermanence

        sysflake.nixosModules.hardware-configuration
        sysflake.nixosModules.users
        ./configuration.nix
        ./storage/impermanence-lite.nix
        ./hardware/nvidia.nix
        ./desktop/gnome.nix
        { networking.hostName = "ZenNix"; }
        { system.stateVersion = "25.05"; }
      ];
    };

    nixosConfigurations.MBP142 = nixpkgs.lib.nixosSystem {
      modules = [
        sysflake.nixosModules.hardware-configuration
        sysflake.nixosModules.users
        ./configuration.nix
        ./hardware/MBP142.nix
        ./desktop/pantheon.nix
        nixos-hardware.nixosModules.apple-macbook-pro-14-1
        { networking.hostName = "MBP142"; }
        { system.stateVersion = "25.05"; }
      ];
    };
  };
}
