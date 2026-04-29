{
  inputs = {
    nixfiles.url = "github:fvla/nixfiles";
  };

  outputs = { self, nixfiles, ... }:
  let
    extraModules = [
      ./users.nix
    ];
  in
  {
    # Extend each evaluated NixOS system with local modules
    nixosConfigurations =
      nixfiles.inputs.nixpkgs.lib.mapAttrs
        (_: system: system.extendModules { modules = extraModules; })
        nixfiles.nixosConfigurations;
  };
}
