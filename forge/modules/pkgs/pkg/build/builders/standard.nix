{
  config,
  lib,
  ...
}:
{
  imports = [
    (lib.modules.importApply ./builder.nix {
      name = "standard";
      imports = standard/options.nix;
      mkDerivation = config.build.builders.standard.stdenv.mkDerivation;
      attrs =
        builder: finalAttrs: previousAttrs:
        { };
    })
  ];
}
