{
  pkgs,
  ...
}:
{
  pkgs.emerge = {
    build.identityBuilder = {
      enable = true;
      # TODO: replace with Nixpkgs derivation when it's merged and propagated:
      # https://github.com/NixOS/nixpkgs/pull/546633
      derivation = pkgs.python3Packages.callPackage ./_emerge.nix { };
    };
    scope = [ "python3" ];
  };
}
