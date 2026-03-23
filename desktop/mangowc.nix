{ config, pkgs, pkgs-unstable, ... }:
{
  services.displayManager.ly.enable = true;
  # programs.mangowc.enable = true; # not available on 25.11!
  # programs.mangowc.package = pkgs-unstable.mangowc;

  # # This block comes from https://github.com/NixOS/nixpkgs/blob/0f64115/nixos/modules/programs/wayland/mangowc.nix
  # Necessary Wayland plumbing
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];

    config.mango = {
      default = [
        "gtk"
      ];

      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];

      # wlr does not have this interface, let gtk handle
      "org.freedesktop.impl.portal.Inhibit" = [ "gtk" ];
    };
  };
  # Set up the session for Display Managers (GDM, SDDM, etc.)
  services.displayManager.sessionPackages = [ pkgs-unstable.mangowc ];

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs-unstable; [
    mangowc

    kitty wofi wmenu
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras
    swaybg grim slurp wl-clipboard
    waybar

    pkgs.gcr pkgs.libsecret
  ];
  security.pam.services.ly.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  fonts.packages = with pkgs-unstable; [ font-awesome_4 ]; # for waybar
}
