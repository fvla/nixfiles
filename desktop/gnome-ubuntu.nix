# Replicate the Ubuntu feel on NixOS.
{ lib, config, pkgs, ... }@inputs:
let 
  gnome = import ./gnome.nix inputs;
  gnomeExtensions = with pkgs.gnomeExtensions; [ dash-to-dock appindicator gtk4-desktop-icons-ng-ding ];
in
gnome // {
  environment.systemPackages = with pkgs; [ yaru-theme ] ++ gnomeExtensions;
  # services.desktopManager.gnome.extraGSettingsOverrides = ''
  #   [org.gnome.desktop.interface]
  #   gtk-theme='Yaru'
  #   icon-theme='Yaru'
  #   cursor-theme='Yaru'

  #   [org.gnome.shell.extensions.dash-to-dock]
  #   dock-position='LEFT'
  #   extend-height=true
  #   dash-max-icon-size=48
  #   autohide=true
  # '';
  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = {
        "org/gnome/shell".enabled-extensions = map (ex: ex.extensionUuid) gnomeExtensions;
        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-position = "LEFT";
          extend-height = true;
          dash-max-icon-size = lib.gvariant.mkInt32 48;
          autohide = true;
        };
        "org/gnome/desktop/interface" = {
          gtk-theme = "Yaru";
          icon-theme = "Yaru";
          cursor-theme = "Yaru";
        };
      };
    }];
  };
  fonts.packages = with pkgs; [ ubuntu-sans ];
}
