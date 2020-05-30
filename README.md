
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- devtools::rmarkdown::render("README.Rmd") -->

<!-- Rscript -e "library(knitr); knit('README.Rmd')" -->

# Install and run programs, outside of R, inside of R <img src="logo.png" height="200" align="right"/>

[![Build
Status](https://travis-ci.org/ropensci/outsider.svg?branch=master)](https://travis-ci.org/ropensci/outsider)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/ropensci/outsider?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider)
[![Coverage
Status](https://coveralls.io/repos/github/ropensci/outsider/badge.svg?branch=master)](https://coveralls.io/github/ropensci/outsider?branch=master)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3615177.svg)](https://doi.org/10.5281/zenodo.3615177)
[![ropensci](https://badges.ropensci.org/282_status.svg)](https://github.com/ropensci/onboarding/issues/282)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.02038/status.svg)](https://doi.org/10.21105/joss.02038)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/outsider)](https://CRAN.R-project.org/package=outsider)

> The Outsider is always unhappy, but he is an agent that ensures the
> happiness for millions of ‘Insiders’.<br><br> *[The Outsider,
> Wilson, 1956](https://en.wikipedia.org/wiki/The_Outsider_\(Colin_Wilson\)).*

<br> Integrating external programs into a deployable, R workflow can be
challenging. Although there are many useful functions and packages (e.g.
`base::system()`) for calling code and software from alternative
languages, these approaches require users to independently install
dependant software and may not work across platforms. `outsider` aims to
make this easier by allowing users to install, run and control programs
*outside of R* across all operating systems.

It’s like [whalebrew](https://github.com/whalebrew/whalebrew) but
exclusively for R.

**For more detailed information, check out the [`outsider`
website](https://docs.ropensci.org/outsider/articles/outsider.html)**

## Installation

To install the development version of the package …

``` r
remotes::install_github('ropensci/outsider')
```

Additionally, you will also need to install **Docker desktop**. To
install Docker visit the Docker website and follow the instructions for
your operating system: [Install
Docker](https://www.docker.com/products/docker-desktop).

### Compatibility

Tested and functioning on Linux, Mac OS and Windows. (For some older
versions of Windows, the legacy [Docker
Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/) may
be required instead of Docker Desktop.)

## Quick example

``` r
library(outsider)
#> ----------------
#> outsider v 0.1.1
#> ----------------
#> - Security notice: be sure of which modules you install
# outsider modules are hosted on GitHub and other code-sharing sites
# this repo is a demonstration outsider module
# it contains a function for printing 'Hello World!' in Ubuntu 18.04
repo <- 'dombennett/om..hello.world'
module_install(repo = repo, force = TRUE)

# look up the help files for the module
module_help(repo = repo)

# import the 'hello_world' function
hello_world <- module_import(fname = 'hello_world', repo = repo)

# run the imported function
hello_world()
#> Hello world!
#> ------------
#> DISTRIB_ID=Ubuntu
#> DISTRIB_RELEASE=18.04
#> DISTRIB_CODENAME=bionic
#> DISTRIB_DESCRIPTION="Ubuntu 18.04.1 LTS"
```

## Available external programs

Modules available on GitHub since 12:08 30 May 2020 (CEST)

● astral

● beast

● PyRate

● RAxML

● pasta

…. Plus, at least, 10 more\!

For more details, see the [available modules
table](https://docs.ropensci.org/outsider/articles/available.html)

### Real-World Example: Aligning biological sequences

Installing and running a multiple sequence alignment program
([mafft](https://mafft.cbrc.jp/alignment/software/)).

![](https://raw.githubusercontent.com/ropensci/outsider/master/other/alignment_example.gif)

(See [“Evolutionary tree
pipeline”](https://ropensci.github.io/outsider/articles/phylogenetic_pipeline.html)
for running this program yourself.)

### Not finding a module you need?

Try raising an issue to request someone make a module, [Raise an
Issue](https://github.com/ropensci/outsider/issues/new).

Otherwise, why not make it yourself? Check out the
[`outsider.devtools`](https://github.com/ropensci/outsider.devtools)
package.

## Security notice :rotating\_light:

There is a risk that `outsider` modules may be malicious. Modules make
use of the program Docker which allows any program to be efficiently
deployed by wrapping the program’s code, along with everything that
program requires to run e.g. operating system, dependent libraries, into
an executable container.

While this is useful for providing users with whichever programs they
require, there is a potential security risk if, along with the desired
program and dependencies, malicious software is also shipped.

A well-known malicious example of Docker container exploitation is in
cryptocurrency mining. A container may ship with a cryptocurrency mining
software that would make use of your computer’s resources while you ran
you the module.

To minimise any security risks **Be sure of which modules you install on
your machine.** Whenever installing a new module, `outsider` will alert
you to the potential security risks. Before installing a new module, ask
yourself:

  - Is this module from a well-known developer?
  - How many others are using this module?

Consider checking the stats on the module’s GitHub page (e.g. number of
stars/watchers) or looking-up the details of the developer (e.g. email
forums, twitter, academic profile).

Additionally, you may wish to check the Dockerfile of the module. Does
it install programs from well-known code repositories (e.g. `apt-get`)?
Or is it running lines of code from unknown/untrackable URL sources?

## How does it work?

`outsider` makes use of the program [docker](https://www.docker.com/)
which allows users to create small, deployable machines, called Docker
images. The advantage of these images is that they can be run on any
machine that has Docker installed, regardless of operating system. The
`outsider` package makes external programs available in R by
facilitating the interaction between Docker and the R console through
**outsider modules**. These modules consist of two parts: a Dockerfile
that describes the Docker image that contains the external program and
an R package for interacting with the Docker image. Upon installing and
running a module through `outsider`, a Docker image is launched and the
R code of the module is used to interact with the external program.
Anyone can create a module. They are hosted on
[GitHub](https://github.com/) as well as other code-sharing sites and
can be searched for and downloaded through
`outsider`.

![outsider\_outline](https://raw.githubusercontent.com/ropensci/outsider/master/other/outline.png)

## Outsider CI statuses

*Statuses of package building checks and tests, run
monthly.*

| Repo                                                                      | Linux ([Travis CI](https://travis-ci.org/))                                                                                                 | Windows 10 ([Appveyor](https://www.appveyor.com/))                                                                                                                                                 |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`outsider.base`](https://github.com/ropensci/outsider.base)              | [![Build Status](https://travis-ci.org/ropensci/outsider.base.svg?branch=master)](https://travis-ci.org/ropensci/outsider.base)             | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/ropensci/outsider.base?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider.base)             |
| [`outsider`](https://github.com/ropensci/outsider)                        | [![Build Status](https://travis-ci.org/ropensci/outsider.svg?branch=master)](https://travis-ci.org/ropensci/outsider)                       | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/ropensci/outsider?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider)                       |
| [`outsider.devtools`](https://github.com/ropensci/outsider.devtools)      | [![Build Status](https://travis-ci.org/ropensci/outsider.devtools.svg?branch=master)](https://travis-ci.org/ropensci/outsider.devtools)     | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/ropensci/outsider.devtools?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider.devtools)     |
| [Outsider Test suites](https://github.com/ropensci/outsider-testsuites)\* | [![Build Status](https://travis-ci.org/ropensci/outsider-testsuites.svg?branch=master)](https://travis-ci.org/ropensci/outsider-testsuites) | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/ropensci/outsider-testsuites?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider-testsuites) |

*\*Mock pipelines to test the interaction of all the packages.*

## Version

Released version 0.1, see
[NEWS](https://github.com/ropensci/outsider/blob/master/NEWS.md).

## Citation

Bennett et al., (2020). outsider: Install and run programs, outside of
R, inside of R. Journal of Open Source Software, 5(45), 2038,
<https://doi.org/10.21105/joss.02038>

## Maintainer

[Dom
Bennett](https://github.com/DomBennett)

-----

[![ropensci\_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
