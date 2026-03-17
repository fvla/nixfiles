{ config, pkgs, pkgs-unstable, ... }:
{
  services.displayManager.ly.enable = true;
  programs.hyprland.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs-unstable; [
    kitty wofi
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    hyprpaper hyprpicker hyprshot
    waybar

    pkgs.gcr pkgs.libsecret
  ];
  security.pam.services.ly.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  fonts.packages = with pkgs-unstable; [ font-awesome_4 ]; # for waybar
}
