{
  description = "A rix flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/976fa3369d722e76f37c77493d99829540d43845.tar.gz";
    housing.url = "https://github.com/rap4all/housing/archive/1c860959310b80e67c41f7bbdc3e84cef00df18e.tar.gz";
    housing.flake = false;
    AER.url = "https://cran.r-project.org/src/contrib/Archive/AER/AER_1.2-8.tar.gz";
    AER.flake = false;
  };

  outputs = { self, nixpkgs, housing, AER }:
  let
    custom_rpkgs = final: prev:
      {
        rPackages = prev.rPackages.override {
          overrides = {

            housing = prev.rPackages.buildRPackage rec {
              name = "housing";
    	      src = housing;
              propagatedBuildInputs = builtins.attrValues {
                inherit (final.rPackages) 
                  dplyr
                  ggplot2
                  janitor
                  purrr
                  readxl
                  rlang
                  rvest
                  stringr
                  tidyr;
              };
            };

            AER = prev.rPackages.buildRPackage rec {
              name = "AER";
    	      src = AER;
              propagatedBuildInputs = builtins.attrValues {
                inherit (final.rPackages) 
                  car
                  lmtest
                  sandwich
                  survival
                  zoo
                  Formula;
              };
            };
          };
        };
      };
    pkgs = nixpkgs.legacyPackages.x86_64-linux.extend custom_rpkgs;
  in
  {
    devShells.x86_64-linux.myenv = pkgs.mkShell {
      buildInputs = [ (pkgs.rWrapper.override{packages = with pkgs.rPackages; [ AER housing poorman ];})];
      
    };
    devShells.x86_64-linux.default = self.devShells.x86_64-linux.myenv;

  };
}
