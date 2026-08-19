{
  config,
  lib,
  forge-lib,
  packageBuilderModule,
  pkgs,
  ...
}:
{
  imports = [
    ./assertions-warnings.nix
    ./builders/shared
  ];

  options.forge = lib.mkOption {
    type = lib.types.submoduleWith {
      modules = [
        (
          { specialArgs, ... }@forgeArgs:
          {
            options.pkgs = lib.mkOption {
              default = { };
              description = ''
                Packages indexed by their `pname`.

                Each package uses one of the available builders.
                Only one builder can be enabled per package by setting build.<builder>.enable = true.
              '';
              type = lib.types.attrsOf (
                lib.types.submoduleWith {
                  specialArgs = specialArgs // {
                    forgeOptions = forgeArgs.options;
                    inherit packageBuilderModule;
                  };
                  modules = [
                    ./pkgs/pkg.nix
                  ];
                }
              );
            };
          }
        )
      ];
    };
  };

  # Config section is now provided by builder modules
  config =
    let
      # Process warnings: filter to get active warnings (condition = true), then show them
      activeWarnings = lib.filter (x: x.condition) config.warnings;
      showWarnings = lib.foldr (w: acc: lib.warn w.message acc) true activeWarnings;

      # Process assertions: filter to get failed assertions (condition = false)
      failedAssertions = lib.filter (x: !x.condition) config.assertions;
      assertionMessages = lib.concatMapStringsSep "\n" (x: "- ${x.message}") failedAssertions;

      packages = lib.attrsets.foldlAttrs (
        acc: name: value:
        let
          path = lib.splitString "." name;

          # Recursively check that `path` is available in `tree`, i.e. that no
          # derivation already sits at or above the target location (a package
          # name cannot also be used as a scope).
          pathIsAvailable =
            path: tree:
            let
              nodeIsAvailable = parts: node: !(lib.hasAttr (lib.head parts) node);

              walk =
                parts: node:
                if lib.isDerivation node then
                  false
                else if parts == [ ] || nodeIsAvailable parts node then
                  true
                else
                  walk (lib.tail parts) node.${lib.head parts};
            in
            walk path tree;

          throwOverlap = throw "Package could not be evaluated at \"pkgs.${name}\" as that path is already contained in pkgs. This is likely due to a package name overlapping with the name of a scope.";

          scopedPkg = lib.attrsets.setAttrByPath path value.result.derivation;
        in
        assert (pathIsAvailable path acc) || throwOverlap;
        lib.attrsets.recursiveUpdate acc scopedPkg
      ) { } config.forge.pkgs;

      packagesWithNamespace = pkgs.callPackage (forge-lib.flakePackagesWithNamespace {
        namespace = "pkgs";
        derivations = packages;
      }) { };
    in
    {
      inherit (packagesWithNamespace) packages;

      # Collect warnings from forge.pkgs
      warnings = lib.flatten (
        map (pkg: [
          {
            condition = pkg.source.hash == "" && pkg.source.path == null && !pkg.build.identityBuilder.enable;
            message = ''
              Package '${pkg.pname}': source.hash is empty.
              Correct hash will be printed in the error message when package is built.
            '';
          }
          {
            condition = pkg.license == [ ];
            message = ''
              Package '${pkg.pname}': license is empty.
            '';
          }
        ]) (lib.attrValues config.forge.pkgs)
      );

      # Collect assertions from forge.pkgs
      assertions = lib.flatten (
        map (
          pkg:
          let
            builders = lib.filterAttrs (name: _: lib.hasSuffix "Builder" name) pkg.build;
            builderNames = map (name: "build." + name) (lib.attrNames builders);

            enabledBuilders = lib.filterAttrs (_: b: b.enable) builders;
            enabledBuilderNames = map (name: "build." + name) (lib.attrNames enabledBuilders);

            enabledBuildersCount = lib.length enabledBuilderNames;
          in
          [
            {
              condition =
                !(
                  pkg.source.git == null
                  && pkg.source.url == null
                  && pkg.source.path == null
                  && !pkg.build.identityBuilder.enable
                );
              message = ''
                Package '${pkg.pname}': one of sources options must be defined.
                Available options: source.git, source.url, or source.path.
              '';
            }
            {
              condition = !(enabledBuildersCount != 1);
              message = ''
                Package '${pkg.pname}': only one builder can be enabled at a time.
                Enabled options: ${lib.concatStringsSep ", " enabledBuilderNames}.
              '';
            }
            {
              condition = !(enabledBuildersCount == 0);
              message = ''
                Package '${pkg.pname}': one of builder options must be enabled.
                Available options: ${lib.concatStringsSep ", " builderNames}.
              '';
            }
          ]
        ) (lib.attrValues config.forge.pkgs)
      );

      # Evaluation check: show warnings first, then throw on failed assertions
      _module.check =
        if showWarnings then
          if failedAssertions != [ ] then throw "\nFailed assertions:\n${assertionMessages}" else true
        else
          true;
    };
}
