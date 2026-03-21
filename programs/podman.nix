{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # optional
    defaultNetwork.settings.dns_enabled = true;
  };
}