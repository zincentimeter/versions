{
  description = "Versions: Specify software versions in Nix, elegantly and efficiently";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    # https://git.sr.ht/~fubuki/stratosphere/tree/roze/item/flake.nix#L9
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      # https://git.sr.ht/~fubuki/stratosphere/tree/roze/item/flake.nix#L27
      nixosModules = nixpkgs.lib.mapAttrs (
        (name: value: import value) (import ./modules)
      );
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = [ pkgs.nix-update pkgs.nix-prefetch-github ];
          };
        } # (system:
      ); # forAllSystems
    }; # outputs
}
