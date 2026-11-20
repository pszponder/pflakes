{
  description = "Piotr's collection of packages and NixOS modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # A relative input keeps the package at the collection's repository revision.
    helium.url = "path:./flakes/helium";
    helium.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "path:./flakes/zen-browser";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { helium, zen-browser, ... }:
    {
      nixosModules.helium = helium.nixosModules.default;
      nixosModules.zen-browser = zen-browser.nixosModules.default;
      packages = builtins.mapAttrs (system: packages: {
        inherit (packages) helium;
        inherit (zen-browser.packages.${system}) zen-browser;
      }) helium.packages;
    };
}
