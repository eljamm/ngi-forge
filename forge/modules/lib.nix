{
  lib,
  config,
  ...
}:
{
  flake.lib = {
    # Helper to support namespacing with dot (`.`) in `flake.packages`
    # (eg. `nix build .#pkgs.${packageName}`).
    # This relies on the Nix completion not quoting attrset keys containing
    # a dot.
    flakePackagesWithNamespace =
      { namespace, derivations }:
      { linkFarm, stdenv }:
      let
        # Take an attrset of arbitrary nesting and make it flat
        # by concatenating the nested names with the given separator.
        flattenAttrs =
          separator:
          let
            f = path: lib.concatMapAttrs (flatten path);
            flatten =
              path: name: value:
              if (lib.isAttrs value) && (!lib.isDerivation value) then
                f (path + name + separator) value
              else
                { ${path + name} = value; };
          in
          f "";

        # Flakes don't accept attribute sets, so here we recursively collect
        # derivation leaves along with their dotted names, so that nested
        # scopes (e.g. `pkgs.python3.emerge`) can be exported.
        leaves = flattenAttrs "." derivations;

        bundle = linkFarm namespace leaves;
      in
      {
        packages = {
          ${namespace} = derivations // {
            all = bundle;
            name = namespace;
            type = "derivation";
            inherit (stdenv.hostPlatform) system;
          };
        }
        // lib.mapAttrs' (name: lib.nameValuePair "${namespace}.${name}") leaves;

        legacyPackages = {
          # Tip(debugging): use this when not using the Flake setup (`nix repl -f.`)
          # to get a curated list of packages `pkgs.<Tab>`
          # In the Flake setup, it's equivalent to use `nix flake show`.
          # This is because simply querying `pkgs` will not display the list,
          # `pkgs` being a derivation and not an attrset of derivations
          # also in the Traditional setup to keep consistency between Flake and Traditional.
          "${namespace}Repl" = derivations;
        };
      };

    # Get the Nix store hash of a derivation's output path
    # (eg. `/nix/store/<hash>-name` -> `<hash>`).
    nixStoreHash = drv: lib.unsafeDiscardStringContext (lib.substring 0 32 (baseNameOf drv.outPath));

    # Recursively remove Nix context used to track dependencies.
    # Useful to avoid building the derivations contained in a `config`
    # when serializing it (eg. with `builtins.toJSON`).
    scrubNixContext =
      x:
      if lib.isString x || lib.isDerivation x then
        lib.unsafeDiscardStringContext x
      else if lib.isFunction x then
        null
      else if lib.isList x then
        map config.flake.lib.scrubNixContext x
      else if lib.isAttrs x then
        lib.mapAttrs (n: v: if n == "__toString" then v else config.flake.lib.scrubNixContext v) x
      else
        x;
  };
}
