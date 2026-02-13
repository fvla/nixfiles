# Impermanence "lite" because we fully persist /var.
{ lib, config, pkgs, ... }:
let
  makeFs = name: lib.mkForce {
    device = "/dev/disk/by-label/NixRoot";
    fsType = "btrfs";
    options = [ "subvol=@${name}" "compress=zstd" ];
    neededForBoot = name == "persist";
  };
in
{
  # ============================
  # Root on tmpfs (ephemeral /)
  # ============================
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["mode=755" "size=1G"];
  };

  # ============================
  # Btrfs persistent subvolumes
  # ============================
  fileSystems."/home" = makeFs "home";
  fileSystems."/nix" = makeFs "nix";
  fileSystems."/persist" = makeFs "persist";
  fileSystems."/var" = makeFs "var";
  fileSystems."/var/log" = makeFs "log";
  fileSystems."/var/cache" = makeFs "cache";

  # ============================
  # Ephemeral tmp directories
  # ============================
  boot.tmp.useTmpfs = true;   # /tmp on tmpfs

  # /var/tmp cleared every boot
  systemd.tmpfiles.rules = [
    "D! /var/tmp 1777 root root -"
  ];

  # ============================
  # Impermanence settings
  # ============================
  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
    ];
    files = [
      "/etc/passwd"
      "/etc/group"
      "/etc/shadow"
      "/etc/gshadow"
      "/etc/machine-id"

      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
