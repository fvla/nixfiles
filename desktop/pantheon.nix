{ config, pkgs, ... }:
{
  services.displayManager.lightdm.enable = true;
  services.desktopManager.pantheon.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-pantheon ];
  programs.firefox.enable = true;
}
