# Place a users.nix file like this inside /etc/nixos to define your users!
{ config, pkgs, ... }:
{
  users.users.me = {
    isNormalUser = true;
    description = "me";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
}
