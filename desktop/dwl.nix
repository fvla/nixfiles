{ config, pkgs, ... }:
{
  services.displayManager.ly.enable = true;
  programs.dwl.enable = true;
  programs.dwl.package = (pkgs.dwl.override {
    configH = ./dwl-config.h;
  }).overrideAttrs (oldAttrs: {
    buildInputs =
      oldAttrs.buildInputs or []
      ++ [
        pkgs.libxcb
        pkgs.libxcb-wm
      ];
    makeFlags =
      oldAttrs.makeFlags or []
      ++ [ "XWAYLAND+=-DXWAYLAND" ];
  });
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [ foot wmenu ];
}
