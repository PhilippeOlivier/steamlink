{ config, pkgs, ... }:

{
  # Allow updating the firmware
  # Run `fwupdmgr update` to update
  services.fwupd.enable = true;

  # TRIM
  services.fstrim.enable = true;

  # Microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Time
  time.timeZone = "Canada/Eastern";

  # Locale
  i18n.defaultLocale = "en_CA.UTF-8";

  hardware.enableRedistributableFirmware = true;
}


