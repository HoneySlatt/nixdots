{ ... }:

{
  fileSystems."/mnt/NAS" = {
    device = "/dev/disk/by-uuid/a709dee0-6279-4893-9618-47bb19b61b48";
    fsType = "btrfs";
    options = [ "defaults" "nofail" ];
  };
}
