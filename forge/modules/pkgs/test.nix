{
  getTestOptions,
  config,
  lib,
  ...
}:

let
  testOptions = (getTestOptions "pkg").getSubOptions { };
in

{
  options = {
    inherit (testOptions)
      nixosConfig
      packages
      runner
      sandbox
      ;

    script = lib.mkOption {
      type = lib.types.str;
      default = ''
        echo "Test script"
      '';
      description = ''
        Script to test the package.
        The package being tested is available in PATH.

        Launch test with:

        ```
        nix build .#pkgs.''${package}.test
        ```
      '';
      example = ''
        hello | grep "Hello, world"
      '';
    };

    derivation = lib.mkOption {
      internal = true;
      description = "Function that builds the test derivation according to runner.";
      type = lib.types.functionTo lib.types.package;
      default =
        {
          pkgs,
          finalAttrs,
          ...
        }:
        let
          name = "${finalAttrs.pname}-test";
          packages = [ finalAttrs.finalPackage ] ++ config.packages;
        in
        if config.runner == "bash" then
          pkgs.testers.runCommand {
            inherit name;
            buildInputs = packages;
            script = config.script + "\ntouch $out";
          }
        else if config.runner == "nixos" then
          (pkgs.testers.runNixOSTest {
            inherit name;
            nodes.machine = {
              imports = [ config.nixosConfig ];
              environment.systemPackages = packages;
              system.stateVersion = "25.11";
            };
            testScript = ''
              machine.start()
              machine.wait_for_unit("multi-user.target")
              machine.succeed("${pkgs.writeShellScript "${finalAttrs.pname}-test" ''
                set -euo pipefail
                ${config.script}
              ''}")
            '';
          }).overrideTestDerivation
            (_: lib.optionalAttrs (!config.sandbox) { __noChroot = true; })
        else
          throw "Unsupported test runner: ${config.runner}";
    };
  };
}
