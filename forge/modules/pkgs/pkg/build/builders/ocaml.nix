{
  config,
  lib,
  ...
}:

{
  imports = [
    (lib.modules.importApply ./builder.nix {
      name = "ocaml";
      imports = ocaml/options.nix;
      mkDerivation = config.build.builders.ocaml.buildDunePackage;
      attrs =
        builder: finalAttrs: previousAttrs:
        {
          propagatedBuildInputs = previousAttrs.propagatedBuildInputs or [ ] ++ builder.packages.dependencies;

          env = (previousAttrs.env or { }) // {
            DUNE_CACHE = "disabled";
          };
        }
        // lib.optionalAttrs (builder.minimalVersion != null) {
          minimalOCamlVersion = builder.minimalVersion;
        };
    })
  ];
}
