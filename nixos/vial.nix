{ config, pkgs, ... }:

let
  vialUdevRules = pkgs.writeTextFile {
    name = "vial-udev-rules";
    destination = "/etc/udev/rules.d/60-vial.rules";
    text = ''
      # Vial keyboard (vendor 0xFEED, product 0x1212)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="1212" MODE="0660", TAG+="uaccess"
    '';
  };
in
{
  services.udev.packages = [ vialUdevRules ];
  environment.systemPackages = with pkgs; [ vial ];
}
