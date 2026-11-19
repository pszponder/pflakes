{
  description = "Piotr's collection of packages and NixOS modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # A relative input keeps the package at the collection's repository revision.
    helium.url = "path:./flakes/helium";
    helium.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { helium, ... }: {
    nixosModules.helium = helium.nixosModules.default;
    packages = builtins.mapAttrs (_system: packages: { inherit (packages) helium; }) helium.packages;
  };
}
