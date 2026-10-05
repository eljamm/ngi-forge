{
  config,
  lib,

  # specialArgs
  app,
  getTestOptions,
  ...
}:

let
  testOptions = (getTestOptions "app").getSubOptions { };
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
      default = "";
      description = ''
        Script to test the program runtime.

        Launch tests with:

        ```
        nix build .#apps.<app-name>.test-programs
        ```
      '';
      example = ''
        $program --version
      '';
    };

    derivation = lib.mkOption {
      internal = true;
      description = "Function that builds the test derivation according to runner.";
      type = lib.types.functionTo lib.types.package;
      default =
        {
          pkgs,
          finalApp,
          ...
        }:
        let
          name = "${app.name}-test";
          packages = [
            finalApp
          ]
          ++ lib.optional (app.programs.mainPackage != null) app.programs.mainPackage
          ++ config.packages;
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
              machine.succeed("${pkgs.writeShellScript "${app.name}-test" ''
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
