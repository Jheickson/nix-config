{ config, pkgs, ... }:

let
  vialUdevRules = pkgs.writeTextFile {
    name = "vial-udev-rules";
    destination = "/etc/udev/rules.d/99-vial.rules";
    text = ''
      # Vial keyboard (vendor 0xFEED, product 0x1212)
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="1212", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
in
{
  services.udev.packages = [ vialUdevRules ];
  environment.systemPackages = with pkgs; [ vial ];
}
