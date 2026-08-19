{
  pkgs,
  ...
}:
{
  pkgs."python3.emerge" = {
    build.identityBuilder = {
      enable = true;
      # TODO: replace with Nixpkgs derivation when it's merged and propagated:
      # https://github.com/NixOS/nixpkgs/pull/546633
      derivation = pkgs.python3Packages.callPackage ./_emerge.nix { };
    };
  };
  pkgs.emerge = {
    build.identityBuilder = {
      enable = true;
      derivation = pkgs.python3Packages.toPythonApplication pkgs."python3.emerge";
    };
  };
}
