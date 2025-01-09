
# rix: Reproducible Environments with Nix <a href="https://docs.ropensci.org/rix/"><img src="man/figures/logo.png" align="right" height="138" /></a>

- [Introduction](#introduction)
- [Quick start for returning users](#quick-start-for-returning-users)
- [Getting started for new users](#getting-started-for-new-users)
  - [Docker](#docker)
- [Why Nix? Comparison with Docker+renv/Conda/Guix](#why-nix-comparison)
- [Contributing](#contributing)
- [Thanks](#thanks)
- [Recommended reading](#recommended-reading)

<!-- badges: start -->

[![R-hub
v2](https://github.com/ropensci/rix/actions/workflows/rhub.yaml/badge.svg)](https://github.com/ropensci/rix/actions/workflows/rhub.yaml/)
[![CRAN](https://www.r-pkg.org/badges/version/rix)](https://CRAN.R-project.org/package=rix)
[![runiverse-package
rix](https://ropensci.r-universe.dev/badges/rix?scale=1&color=pink&style=round)](https://ropensci.r-universe.dev/rix)
[![Docs](https://img.shields.io/badge/docs-release-blue.svg)](https://docs.ropensci.org/rix/)
[![Status at rOpenSci Software Peer
Review](https://badges.ropensci.org/625_status.svg)](https://github.com/ropensci/software-review/issues/625)
<!-- badges: end -->

## Introduction

`{rix}` is an R package that leverages [Nix](https://nixos.org/), a
package manager focused on reproducible builds. With Nix, you can create
project-specific environments with a custom version of R, its packages,
and all system dependencies (e.g., `GDAL`). Nix ensures full
reproducibility, which is crucial for research and development projects.

Use cases include running web apps (e.g., Shiny, `{plumber}` APIs) or
`{targets}` pipelines with a controlled R environment. Unlike `{renv}`,
which snapshots package versions, `{rix}` provides an entire ecosystem
snapshot, including system-level dependencies.

While Nix has a steep learning curve, `{rix}`

1.  simplifies creating Nix expressions, which define reproducible
    environments, also from `renv.lock` files;
2.  lets you work interactively in IDEs like RStudio or VS Code, or use
    Nix in CI/CD workflows;
3.  makes it easy to create Docker images with the right packages;
4.  provides helpers that make it easy to build those environments,
    evaluate the same code in different development environments, and
    finally to deploy software environments in production.

If you want to watch a 5-Minute video introduction click
[here](https://youtu.be/OOu6gjQ310c?si=qQ5lUhAg5U-WT2W1).

Nix includes nearly all CRAN and Bioconductor packages, with the ability
to install specific package versions or GitHub snapshots. Nix also
includes Python, Julia (and many of their respective packages) as well
as many, many other tools (up to 120’000 pieces of software as of
writing). Expressions generated by `{rix}` point to our fork of Nixpkgs
which provides improved compatibility for older versions of R and R
packages, especially for Apple Silicon computers.

If you have R installed, you can start straight away from your R session
by first installing `{rix}`:

``` r
install.packages("rix", repos = c(
  "https://ropensci.r-universe.dev",
  "https://cloud.r-project.org"
))
library("rix")
```

Now try to generate an expression using `rix()`:

``` r
# Choose the path to your project
# This will create two files: .Rprofile and default.nix
path_default_nix <- "."

rix(
  r_ver = "4.3.3",
  r_pkgs = c("dplyr", "ggplot2"),
  system_pkgs = NULL,
  git_pkgs = NULL,
  ide = "code",
  project_path = path_default_nix,
  overwrite = TRUE,
  print = TRUE
)
```

This will generate two files, `default.nix` and `.Rprofile` in
`project_default_nix`. `default.nix` is the environment definition
written in the Nix programming language, and `.Rprofile` prevents
conflicts with library paths from system-installed R versions, offering
better control over your environment and improving isolation of Nix
environments. `.Rprofile` is created by `rix_init()` which is called
automatically by the main function, `rix()`.

It is also possible to provide a date instead of an R version:

``` r
# Choose the path to your project
# This will create two files: .Rprofile and default.nix
path_default_nix <- "."

rix(
  date = "2024-12-14",
  r_pkgs = c("dplyr", "ggplot2"),
  system_pkgs = NULL,
  git_pkgs = NULL,
  ide = "code",
  project_path = path_default_nix,
  overwrite = TRUE,
  print = TRUE
)
```

The table below illustrates this all the different types of environment
you can generate:

<table border="1">
  <thead>
    <tr>
      <th>r_ver or date</th>
      <th>Intended use</th>
      <th>State of R version</th>
      <th>State of CRAN packages</th>
      <th>State of Bioconductor packages</th>
      <th>State of other packages in Nixpkgs</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>r_ver = "latest-upstream"</td>
      <td>Start of new project where versions don’t matter</td>
      <td>Current or previous</td>
      <td>Outdated (up to 6 months)</td>
      <td>Outdated (up to 6 months)</td>
      <td>Current at time of generation</td>
    </tr>
    <tr>
      <td>r_ver = "4.4.2" (or other)</td>
      <td>Reproducing old project or starting a new project where versions don’t matter</td>
      <td>Same as in `r_ver`, check `available_r()`</td>
      <td>Outdated (up to 2 months if using latest release)</td>
      <td>Outdated (up to 2 months if using latest release)</td>
      <td>Potentially outdated (up to 12 months)</td>
    </tr>
    <tr>
      <td>date = "2024-12-14"</td>
      <td>Reproducing old project or starting a new project using the most recent date</td>
      <td>Current at that date, check `available_dates()`</td>
      <td>Current at that date, check `available_dates()`</td>
      <td>Current at that date, check `available_dates()`</td>
      <td>Potentially outdated (up to 12 months)</td>
    </tr>
    <tr>
      <td>r_ver = "bleeding-edge"</td>
      <td>To develop against the latest release of CRAN</td>
      <td>Always current</td>
      <td>Always current</td>
      <td>Always current</td>
      <td>Always current</td>
    </tr>
    <tr>
      <td>r_ver = "frozen-edge"</td>
      <td>To develop against the latest release of CRAN, but manually manage updates</td>
      <td>Current at time of generation</td>
      <td>Current at time of generation</td>
      <td>Current at time of generation</td>
      <td>Current at time of generation</td>
    </tr>
    <tr>
      <td>r_ver = "r-devel"</td>
      <td>To develop/test against the development version of R</td>
      <td>Development version</td>
      <td>Always current</td>
      <td>Always current</td>
      <td>Always current</td>
    </tr>
    <tr>
      <td>r_ver = "r-devel-bioc-devel"</td>
      <td>To develop/test against the development version of R and Bioconductor</td>
      <td>Development version</td>
      <td>Always current</td>
      <td>Development version</td>
      <td>Always current</td>
    </tr>
    <tr>
      <td>r_ver = "bioc-devel"</td>
      <td>To develop/test against the development version of Bioconductor</td>
      <td>Always current</td>
      <td>Always current</td>
      <td>Development version</td>
      <td>Always current</td>
    </tr>
  </tbody>
</table>

If you want to benefit from relatively fresh packages and have a stable
environment for production purposes, using a date for `r_ver` is likely
your best option.

## Quick-start for returning users

<details>
<summary>
Click to expand
</summary>

If you’re already familiar with Nix and `{rix}`, install Nix using the
[Determinate Systems
installer](https://determinate.systems/posts/determinate-nix-installer):
(if you’re using WSL, do check out the [detailed installation
instructions](https://docs.ropensci.org/rix/articles/b1-setting-up-and-using-rix-on-linux-and-windows.html#windows-pre-requisites)
though):

``` bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Then, install the `cachix` client and configure our `rstats-on-nix`
cache; this will install binary versions of many R packages which will
speed up the building process of environments:

``` bash
nix-env -iA cachix -f https://cachix.org/api/v1/install
```

then use the cache:

``` bash
cachix use rstats-on-nix
```

You only need to do this once per machine you want to use `{rix}` on.
Many thanks to [Cachix](https://www.cachix.org/) for sponsoring the
`rstats-on-nix` cache!

`{rix}` also includes a function called `setup_cachix()` which will
configure the cache but it is recommended to use the `cachix` client
instead. This is because `setup_cachix()` will not edit the files that
require admin/root privileges and only edit the user-level files. This
may not be enough depending on how you installed Nix. Using the `cachix`
client takes care of everything.

You can then use `{rix}` to build and enter a Nix-based R environment:

``` r
library(rix)

path_default_nix <- "."

rix(
  r_ver = "4.3.3",
  r_pkgs = c("dplyr", "ggplot2"),
  system_pkgs = NULL,
  git_pkgs = NULL,
  ide = "code",
  project_path = path_default_nix,
  overwrite = TRUE,
  print = TRUE
)
```

To build the environment, call `nix_build()`

``` r
# nix_build() is a wrapper around the command line tool `nix-build`
nix_build(project_path = ".")
```

If you don’t have R installed, but have the Nix package manager
installed, you can run a temporary terminal session which includes R and
the development version of `{rix}`:

    nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"

You can then create new development environment definitions, build them,
and start using them.
</details>

## Getting started for new users

New to `{rix}` and Nix? Start by reading the
`vignette("a-getting-started")` ([online
documentation](https://docs.ropensci.org/rix/articles/a-getting-started.html)).
to learn how to set up and use Nix smoothly.

### Docker

Try Nix inside Docker by following this
`vignette("z-advanced-topic-using-nix-inside-docker")`
[vignette](https://github.com/ropensci/rix/blob/HEAD/vignettes/z-advanced-topic-using-nix-inside-docker.Rmd).

## How is Nix different from Docker+renv/{groundhog}/{rang}/(Ana/Mini)Conda/Guix? or Why Nix?

### Docker + {renv}

Docker and {renv} provide robust reproducibility by combining package
snapshots with system-level dependencies. However, for long-term
reproducibility, Nix offers a simpler approach by bundling everything
(R, packages, and dependencies) in a single environment.

### Ana/Miniconda & Mamba

Conda is similar to Nix, but Nix offers immutable environments, making
it more reliable for preventing accidental changes. Nix also supports
nearly all CRAN and Bioconductor packages, which Conda lacks.

### Nix vs. Guix

Guix, like Nix, focuses on reproducibility, but Nix supports more
CRAN/Bioconductor packages and works across Windows, macOS, and Linux.

### Is {rix} all there is?

No, there are other tools that you might want to check out, especially
if you want to set up polyglot environments (even though it is possible
to use `{rix}` to set up an environment with R and Python packages for
example).

Take a look at <https://devenv.sh/> and
[https://prefix.dev/](https://prefix.dev) if you want to explore other
tools that make using Nix easier!

## What’s the recommended workflow?

Ideally, you shouldn’t be using a system-wide installation of R, and
instead use dedicated Nix environments for each of your projects.

Start a new project by writing a file called `generate_env.R` and write
something like:

    library(rix)

    path_default_nix <- "."

    rix(
      r_ver = "4.3.3",                # Change to whatever R version you need
      r_pkgs = c("dplyr", "ggplot2")  # Change to whatever packages you need
      system_pkgs = NULL
      git_pkgs = NULL,
      ide = "code",
      project_path = path_default_nix,
      overwrite = TRUE,
      print = TRUE
    )

Then use the following command to bootstrap an enivronment with R and
`{rix}` only (from the same directory):

    nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"

and then simply run `Rscript generate_env.R` which will run the above
script, thus generating the project’s `default.nix`. If you need to add
packages, open the `generate_env.R` file again, modify it, and run it
again, do not edit the `default.nix` directly. Also, commit all the
files to version control to avoid any issues.

## Contributing

Refer to `Contributing.md` to learn how to contribute to the package.

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

## Thanks

Thanks to the [Nix community](https://nixos.org/community/) for making
Nix possible, and thanks to the community of R users on Nix for their
work packaging R and CRAN/Bioconductor packages for Nix (in particular
[Justin Bedő](https://github.com/jbedo), [Rémi
Nicole](https://github.com/minijackson),
[nviets](https://github.com/nviets), [Chris
Hammill](https://github.com/cfhammill), [László
Kupcsik](https://github.com/Kupac), [Simon
Lackerbauer](https://github.com/ciil),
[MrTarantoga](https://github.com/MrTarantoga) and every other person
from the [Matrix Nixpkgs R channel](https://matrix.to/#/#r:nixos.org)).

Finally, thanks to [David Solito](https://www.davidsolito.com/about/)
for creating `{rix}`’s logo!

## Recommended reading

- [NixOS’s website](https://nixos.org/)
- [Nixpkgs’s GitHub repository](https://github.com/NixOS/nixpkgs)
- [Nix for R series from Bruno’s
  blog](https://www.brodrigues.co/tags/nix/). Or, in case you like video
  tutorials, watch [this one on Reproducible R development environments
  with Nix](https://www.youtube.com/watch?v=c1LhgeTTxaI)
- [nix.dev
  tutorials](https://nix.dev/tutorials/first-steps/towards-reproducibility-pinning-nixpkgs#pinning-nixpkgs)
- [INRIA’s Nix
  tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/installation.html)
- [Nix pills](https://nixos.org/guides/nix-pills/)
- [Nix for Data
  Science](https://github.com/nix-community/nix-data-science)
- [NixOS explained](https://christitus.com/nixos-explained/): NixOS is
  an entire Linux distribution that uses Nix as its package manager.
- [Blog post: Nix with R and
  devtools](https://rgoswami.me/posts/nix-r-devtools/)
- [Blog post: Statistical Rethinking and
  Nix](https://rgoswami.me/posts/rethinking-r-nix/)
- [Blog post: Searching and installing old versions of Nix
  packages](https://lazamar.github.io/download-specific-package-version-with-nix/)
