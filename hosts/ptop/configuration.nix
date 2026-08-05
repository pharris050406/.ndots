{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "ptop";

  environment.systemPackages = with pkgs; [
    # laptop-specific system packages go here
  ];
}
