builderArgs:
{
  forge-lib,
  ...
}:
let
  base = [
    "forge"
    "pkgs"
    "<name>"
    "build"
  ];
in
{
  imports = [
    (
      buildArgs:
      forge-lib.mkAliasOptionModule {
        condition = buildArgs.config.builders.${builderArgs.name}.enable;
        inherit base;
        from = [
          "builders"
          builderArgs.name
          "packages"
          "build"
        ];
        to = [
          "phases"
          "build"
          "packages"
          "build"
          "host"
        ];
      } buildArgs
    )
    (
      buildArgs:
      forge-lib.mkAliasOptionModule {
        condition = buildArgs.config.builders.${builderArgs.name}.enable;
        inherit base;
        from = [
          "builders"
          builderArgs.name
          "packages"
          "run"
        ];
        to = [
          "phases"
          "build"
          "packages"
          "host"
          "target"
        ];
      } buildArgs
    )
    (
      buildArgs:
      forge-lib.mkAliasOptionModule {
        condition = buildArgs.config.builders.${builderArgs.name}.enable;
        inherit base;
        from = [
          "builders"
          builderArgs.name
          "packages"
          "check"
        ];
        to = [
          "phases"
          "check"
          "packages"
          "build"
          "host"
        ];
      } buildArgs
    )
  ];
}
