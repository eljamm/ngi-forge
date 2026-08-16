{ lib, ... }:
{
  options.structuredAttrs = lib.mkOption {
    description = ''
      Attributes local to the build script.

      Mapped to themselves as attributes given to the builder.

      See <https://nix.dev/manual/nix/latest/store/derivation/#structured-attrs>.
    '';
    default = { };
    apply = lib.filterAttrs (k: v: v != null);
    type = lib.types.submodule {
      freeformType =
        with lib.types;
        attrsOf (
          lib.types.serializableValueWith {
            typeName = "structuredAttrs";
            nullable = true;
          }
        );
    };
  };
}
