{ lib, ... }:
{
  options.structuredAttrs = lib.mkOption {
    type = lib.types.submodule {
      options = {
      };
    };
  };
}
