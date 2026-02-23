{ config, pkgs, ... }:
{
  services.displayManager.lightdm.enable = true;
  services.desktopManager.cinnamon.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-xapp ];
  programs.firefox.enable = true;
}
