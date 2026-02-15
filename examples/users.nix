# Place a users.nix file like this inside /etc/nixos to define your users!
# Putting hashed password in this file is mainly for the sake of making impermanence work easily.
# Without impermanence, you can manage passwords normally.
{ config, pkgs, ... }:
{
  users.mutableUsers = false;
  users.users.me = {
    isNormalUser = true;
    description = "me";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    hashedPassword = "<hashed password here>"; # Use `mkpasswd -m sha-512` to generate this.
  };
}
