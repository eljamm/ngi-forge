{
  config,
  pkgs,
  lib,
  ...
}:

# let
#   pyEnv = pkgs.python3.withPackages (ps: [ pkgs.forgePkgs.python3.emerge ]);
# in

{
  apps.emerge = lib.trace (lib.attrNames pkgs.forgePkgs) {
    displayName = "EMerge";
    description = "Electromagnetic field computation program.";
    usage = ''
      EMerge is a python based FEM EM library for the time harmonic helmholtz formulation.
      You can use it to simulate:

      - RF Filters
      - Signal propagation through PCBs
      - Antennas
      - Optycal systems
      - Arrays and periodic structures
      - Much more!

      #### Basic Usage

      Write the following script into a local file:

      ```py
      # ${lib.baseNameOf ./tests/first-simulation.py}
      ${lib.readFile ./tests/first-simulation.py}
      ```

      Then, [enter the Nix shell](app/emerge#run-shell) and execute the script:

      ```bash
      python ${lib.baseNameOf ./tests/first-simulation.py}
      ```

      Screenshots of the result will be written in the same directory as the script.

      For more details and examples, please see the latest user manual in the [project documentation](${config.apps.emerge.links.docs}) page.
    '';

    links = {
      website = "https://www.emerge-software.com";
      source = "https://github.com/FennisRobert/EMerge";
      docs = "https://www.emerge-software.com/resources";
    };

    ngi.grants = {
      Commons = [
        "EMerge"
      ];
    };

    programs = {
      mainPackage = pkgs.emerge;
      packages = with pkgs; [
        # emerge
        # pyEnv
      ];

      runtimes = {
        shell.enable = true;
        program.enable = true;
      };
    };

    test.programs = {
      packages = with pkgs; [
        mesa.llvmpipeHook # OpenGL context
        pyEnv
        writableTmpDirAsHomeHook
        xvfb-run
      ];
      script = ''
        export NUMBA_DISABLE_JIT=1 # quite slow and won't be cached anyways
        xvfb-run python ${./tests/first-simulation.py}
      '';
    };
  };

  # pkgs.emerge.build.identityBuilder = {
  #   enable = true;
  #   derivation = pkgs.python3Packages.toPythonApplication pkgs.forgePkgs.python3.emerge;
  # };
}
