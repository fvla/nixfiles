{ config, pkgs, pkgs-unstable, hyprland ? null, ... }:
{
  services.displayManager.ly.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.package = if hyprland != null then hyprland else pkgs-unstable.hyprland;
  xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
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

    hyprpolkitagent
    pkgs.gcr pkgs.libsecret
  ];
  services.udisks2 = {
    enable = true;
    settings."mount_options.conf".defaults = {
      # defaults = "ro";
      allow = "exec,noexec,nodev,nosuid,atime,noatime,nodiratime,ro,rw,sync,dirsync,noload";
      ntfs_defaults = "ro,uid=$UID,gid=$GID,windows_names";
      ntfs_allow = "uid=$UID,gid=$GID,umask,dmask,fmask,locale,norecover,ignore_case,windows_names,compression,nocompression,big_writes";
    };
  };
  security.polkit.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.gcr ];

  xdg.mime.enable = true;

  # Add overlay
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
        dolphin = prev.symlinkJoin {
          name = "dolphin-wrapped";
          paths = [ kprev.dolphin ];
          nativeBuildInputs = [ prev.makeWrapper ];
          postBuild = ''
            rm $out/bin/dolphin
            makeWrapper ${kprev.dolphin}/bin/dolphin $out/bin/dolphin \
              --set XDG_CONFIG_DIRS "${prev.libsForQt5.kservice}/etc/xdg:$XDG_CONFIG_DIRS" \
              --run "${kprev.kservice}/bin/kbuildsycoca6 --noincremental ${prev.libsForQt5.kservice}/etc/xdg/menus/applications.menu"
          '';
        };
      });
    })
  ];

  fonts.packages = with pkgs-unstable; [
    font-awesome # for default waybar
    vista-fonts # consolas my beloved
  ];
}
