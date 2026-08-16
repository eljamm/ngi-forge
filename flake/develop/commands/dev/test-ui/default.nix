{
  lib,
  playwright-test,
  writeShellScriptBin,
  buildNpmPackage,
  ...
}:
let
  npmDeps = buildNpmPackage {
    pname = "test-ui-deps";
    version = "1.0.0";
    src = ../../../../../ui/tests/e2e;
    npmDepsHash = "sha256-v7OOg2VPQS/It7TJ5Yxe/zJQ4p3U7bhEIKPdlECElnM=";
    dontNpmBuild = true;
  };
  script = writeShellScriptBin "test-ui" ''
    export NODE_PATH=${npmDeps}/lib/node_modules/e2e/node_modules
    ${lib.getExe playwright-test} test -c ui/tests/e2e "$@"
  '';
in
script.overrideAttrs (_: {
  meta.description = "run UI tests";
})
