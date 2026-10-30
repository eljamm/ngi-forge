{
  lib,
  pkgs,
  config,
  ...
}:

{
  pkgs.esp-pylib = {
    version = "1.2.0";
    description = "Python library for logging, utils and constants for Espressif Python projects.";
    homePage = "https://github.com/espressif/esp-pylib";
    license = lib.licenses.asl20;

    source = {
      git = "github:espressif/esp-pylib/v${config.pkgs.esp-pylib.version}";
      hash = "sha256-wj9Enkaxj6LlNfJlmditKFZ8lKfVq9SbQg8f5xIyXP8=";
    };

    build.builders.pythonModule = {
      enable = true;
      packages = {
        build-system = with pkgs.python3Packages; [
          setuptools
          wheel
        ];
        dependencies = with pkgs.python3Packages; [
          click
          pyserial
          rich
          rich-click
        ];
      };
      importsCheck = [ "esp_pylib" ];
    };

    test = {
      packages = [
        (pkgs.python3.withPackages (ps: [ pkgs.esp-pylib ]))
      ];
      script = ''
        python -c "import esp_pylib; assert esp_pylib.__version__ == '${config.pkgs.esp-pylib.version}'"
      '';
    };
  };
}
