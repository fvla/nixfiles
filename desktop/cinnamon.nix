{ config, pkgs, ... }:
{
  services.displayManager.ly.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-xapp ];
  programs.firefox.enable = true;
}
