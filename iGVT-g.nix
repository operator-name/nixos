{ config, pkgs, ... }:

{
  boot.kernelModules = [ "kvmgt" "vfio-iommu-type1" "vfio-mdev" ];
  boot.kernelParams = [ "i915.enable_gvt=1" "kvm.ignore_msrs=1" "intel_iommu=on" "i915.enable_guc=0" ];
  virtualisation.kvmgt.enable = true;
  virtualisation.kvmgt.vgpus = {
    "i915-GVTg_V5_2" = {
      uuid = "5ea51de5-cdcf-40c7-b5f5-aca7a11ac71c";
    };
  };
  environment.systemPackages = with pkgs; [
    virtmanager
    virt-viewer
  ];
  
  virtualisation.libvirtd.enable = true;
  users.users.qqii.extraGroups = [ "libvirtd" ];
}