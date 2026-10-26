{ lib, specialArgs, ... }:
{
  imports = [
    # Builders are currently setting values in their ancestors,
    # hence they cannot be imported nested in a submodule.
    build/builders.nix
    # Phases are currently aliasing values in their ancestors,
    # hence they cannot be imported nested in a submodule.
    build/phases.nix
  ];
  options.build = lib.mkOption {
    description = "Package build options.";
    type = lib.types.submoduleWith {
      inherit specialArgs;
      modules = [
        build/env/options.nix
        build/structuredAttrs/options.nix
        build/env.nix
        build/structuredAttrs.nix
        {
          options = {
            # Builder-specific options are defined in separate modular
            # files in forge/modules/builders/ directory.
            # Each builder module defines its own options and configuration logic.

            # Common builder options (available to all builders)
            extraAttrs = lib.mkOption {
              # `lazyAttrsOf` enables to use `pkgs` inside `extraAttrs`.
              type = lib.types.lazyAttrsOf lib.types.anything;
              default = { };
              description = ''
                Extra attributes merged into the derivation produced by the selected builder.

                Use this to pass any `stdenv.mkDerivation` attribute
                not exposed as a dedicated option.
                Beware that attributes set here do not take precedence over builder's options,
                so use the builder's options when they exist.

                Expert option. For more information see the
                [Nixpkgs manual](https://nixos.org/manual/nixpkgs/unstable/).
              '';
            };
            debug = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                Enable interactive package build environment for debugging.

                Launch environment:

                ```
                mkdir dev && cd dev
                nix develop .#pkgs.''${package}
                ```

                and follow instructions.
              '';
            };
          };
        }
      ];
    };
  };
}
