# This file was generated by the {rix} R package v0.7.1 on 2024-06-25
# with following call:
# >rix(r_ver = "efb39c6052f3ce51587cf19733f5f4e5d515aa13",
#  > r_pkgs = NULL,
#  > system_pkgs = NULL,
#  > git_pkgs = list(package_name = "rix",
#  > repo_url = "https://github.com/b-rodrigues/rix/",
#  > branch_name = "master",
#  > commit = latest_commit),
#  > ide = "other",
#  > project_path = "../inst/extdata",
#  > overwrite = TRUE,
#  > shell_hook = NULL)
# It uses nixpkgs' revision efb39c6052f3ce51587cf19733f5f4e5d515aa13 for reproducibility purposes
# which will install R version latest.
# Report any issues to https://github.com/b-rodrigues/rix
let
 pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/efb39c6052f3ce51587cf19733f5f4e5d515aa13.tar.gz") {};
  
  git_archive_pkgs = [
    (pkgs.rPackages.buildRPackage {
      name = "rix";
      src = pkgs.fetchgit {
        url = "https://github.com/b-rodrigues/rix/";
        branchName = "master";
        rev = "f91d709971a4385fcda1298250f4e3f9b7641afd";
        sha256 = "sha256-auJClNilLNCoj2nRUuZpx/iG8jq4sv1edWsx7Yn34os=";
      };
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages) 
          codetools
          curl
          jsonlite
          sys;
      };
    })
   ];
   
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      R
      glibcLocales
      nix;
  };
  
in

pkgs.mkShell {
  LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then  "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
  LANG = "en_US.UTF-8";
   LC_ALL = "en_US.UTF-8";
   LC_TIME = "en_US.UTF-8";
   LC_MONETARY = "en_US.UTF-8";
   LC_PAPER = "en_US.UTF-8";
   LC_MEASUREMENT = "en_US.UTF-8";

  buildInputs = [ git_archive_pkgs   system_packages   ];
  
}
