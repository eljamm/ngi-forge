{
  lib,
  ...
}:

let
  testOptions = lib.types.submodule (
    lib.modules.importApply ../../test-options.nix {
      type = "app";
    }
  );
in

{
  options = {
    inherit (testOptions)
      packages
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
  };
}
