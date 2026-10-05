{
  getTestOptions,
  lib,
  ...
}:

let
  testOptions = (getTestOptions "app").getSubOptions { };
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
