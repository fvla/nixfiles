{ config, pkgs, ... }:
{
  services.displayManager.ly.enable = true;
  programs.hyprland.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    kitty wofi
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    hyprpaper hyprpicker hyprshot
    waybar
  ];
  fonts.packages = with pkgs; [ font-awesome_4 ]; # for waybar
}
