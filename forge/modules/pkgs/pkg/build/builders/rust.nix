{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (lib.modules.importApply ./builder.nix {
      name = "rust";
      imports = rust/options.nix;
      mkDerivation = pkgs.rustPlatform.buildRustPackage;
      attrs = builder: finalAttrs: previousAttrs: {
        inherit (builder)
          cargoHash
          cargoBuildFlags
          ;
      };
    })
  ];

}
