{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    python/module.nix
    (lib.modules.importApply ./builder.nix {
      name = "python";
      imports = python/options.nix;
      mkDerivation = pkgs.python3Packages.buildPythonApplication;
      attrs = builder: finalAttrs: previousAttrs: {
        format = "pyproject";
        inherit (builder.packages)
          build-system
          dependencies
          optional-dependencies
          ;
        inherit (builder)
          disabledTests
          ;
        # Warning(consistency): such renames are not done elsewhere,
        # eg. in `pkgs.${package}.build.builders.npm.npmDepsHash`
        pythonImportsCheck = builder.importsCheck;
        pythonRelaxDeps = builder.relaxDeps;
      };
    })
  ];
}
