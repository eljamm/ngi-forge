{
  config,
  name,
  lib,
  ...
}:
{
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = ''
        Data item name.

        Defaults to the file's basename when sourced from a path, or to the
        attribute name otherwise.
      '';
    };
    content = lib.mkOption {
      type = lib.types.str;
      default = lib.optionalString (config.path != null) (
        lib.removeSuffix "\n" (lib.readFile config.path)
      );
      description = "Data item content.";
    };
    path = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Data item absolute path.";
    };
  };
}
