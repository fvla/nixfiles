{
  description = "NixOS kernels flake";

  inputs = {
    # See: https://github.com/xddxdd/nix-cachyos-kernel
    #      https://github.com/CachyOS/linux-cachyos
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nix-cachyos-kernel, ... }@inputs:
    let
      kernelPackageNames = builtins.filter
        (name: builtins.match "^linux-cachyos-.*" name != null)
        (builtins.attrNames nix-cachyos-kernel.packages.x86_64-linux);

      generatedKernelModules = builtins.listToAttrs (builtins.map
        (name: {
          inherit name;
          value = { pkgs, ... }: {
            nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
            nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
            nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

            boot.kernelPackages =
              let packageName = builtins.replaceStrings ["linux-"] ["linuxPackages-"] name; in
              pkgs.cachyosKernels.${packageName};
          };
        })
        kernelPackageNames);
    in {
      nixosModules = generatedKernelModules // {
        default = { ... }: {}; # configuration.nix sets default kernel
      };
    };
}
