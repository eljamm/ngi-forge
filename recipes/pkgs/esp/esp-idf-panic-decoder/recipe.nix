{
  lib,
  pkgs,
  config,
  ...
}:

{
  pkgs.esp-idf-panic-decoder = {
    version = "1.5.0";
    description = "ESP-IDF panic decoder for crash logs and backtraces.";
    homePage = "https://github.com/espressif/esp-idf-panic-decoder";
    license = lib.licenses.asl20;

    source = {
      git = "github:espressif/esp-idf-panic-decoder/v${config.pkgs.esp-idf-panic-decoder.version}";
      hash = "sha256-NDMpvJXjZp+Iz+AwjM/S9svYEdd1lNG7HWuFFSvTvuo=";
    };

    build.builders.pythonModule = {
      enable = true;
      packages = {
        build-system = [ pkgs.python3Packages.setuptools ];
        dependencies = with pkgs.python3Packages; [
          pyelftools
          pyparsing
        ];
      };
      importsCheck = [ "esp_idf_panic_decoder" ];
    };

    test = {
      packages = [
        (pkgs.python3.withPackages (ps: [ pkgs.esp-idf-panic-decoder ]))
      ];
      script = ''
        python -c "import esp_idf_panic_decoder; assert esp_idf_panic_decoder.__version__ == '${config.pkgs.esp-idf-panic-decoder.version}'"
      '';
    };
  };
}
