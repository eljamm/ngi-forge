{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.modules.importApply ./builder.nix {
      name = "go";
      imports = go/options.nix;
      mkDerivation = pkgs.buildGoModule;
      attrs = builder: finalAttrs: previousAttrs: {
        inherit (builder)
          vendorHash
          modRoot
          subPackages
          ldflags
          tags
          proxyVendor
          ;
      };
    })
  ];
}
