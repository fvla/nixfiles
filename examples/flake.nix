{
  inputs = {
    # This flake depends on nixfiles...
    nixfiles.url = "github:fvla/nixfiles";
    # ...and nixfiles depends on this flake. This works because the outputs themselves have no circular dependencies.
    nixfiles.inputs.sysflake.follows = "";
  };

  outputs = { self, nixfiles, ... }:
  with nixfiles; {
    # Pass through the NixOS configurations from nixfiles.
    inherit nixosConfigurations;

    # Pseudo-circular dependency: nixfiles.nixosConfigurations imports this flake to get the nixosModules.
    nixosModules.hardware-configuration = import ./hardware-configuration.nix;
    nixosModules.users = import ./users.nix;
  };
}
