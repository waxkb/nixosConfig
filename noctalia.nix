{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Required by Noctalia features
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
