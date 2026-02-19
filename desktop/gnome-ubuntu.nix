# Replicate the Ubuntu feel on NixOS.
{ config, pkgs, ... }:
let 
  gnome = import ./gnome.nix;
in
gnome // {
  environment.systemPackages = with pkgs; [ yaru-theme ];
  programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [ dash-to-dock appindicator desktop-icons-ng ];
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
  fonts.packages = with pkgs; [ ubuntu-font-family ];
  services.udev.packages = [ pkgs.libappindicator ];
}
