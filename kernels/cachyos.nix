{ nix-cachyos-kernel }:
let
  kernelPackageNames = builtins.filter
    (name: builtins.match "^linux-cachyos-.*" name != null)
    (builtins.attrNames nix-cachyos-kernel.packages.x86_64-linux);

  generatedKernelModules = builtins.listToAttrs (builtins.map
    (name: {
      inherit name;
      value = { pkgs, ... }: {
        nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];

        boot.kernelPackages =
          let packageName = builtins.replaceStrings ["linux-"] ["linuxPackages-"] name; in
          pkgs.cachyosKernels.${packageName};
      };
    })
    kernelPackageNames);
in
generatedKernelModules // {
  default = { ... }: {}; # configuration.nix sets default kernel
}
