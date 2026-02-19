# Replicate the Ubuntu feel on NixOS.
{ config, pkgs, ... }@inputs:
let 
  gnome = import ./gnome.nix inputs;
  gnomeExtensions = with pkgs.gnomeExtensions; [ dash-to-dock appindicator gtk4-desktop-icons-ng-ding ];
in
gnome // {
  environment.systemPackages = with pkgs; [ yaru-theme ] ++ gnomeExtensions;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    gtk-theme='Yaru'
    icon-theme='Yaru'
    cursor-theme='Yaru'

    [org.gnome.shell.extensions.dash-to-dock]
    dock-position='LEFT'
    extend-height=true
    dash-max-icon-size=48
    autohide=true
  '';
  fonts.packages = with pkgs; [ ubuntu-sans ];
  services.udev.packages = [ pkgs.libappindicator ];
}
