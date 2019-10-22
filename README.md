
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- devtools::rmarkdown::render("README.Rmd") -->
<!-- Rscript -e "library(knitr); knit('README.Rmd')" -->
Install and run programs, outside of R, inside of R <img src="logo.png" height="200" align="right"/>
====================================================================================================

[![Build Status](https://travis-ci.org/AntonelliLab/outsider.svg?branch=master)](https://travis-ci.org/AntonelliLab/outsider) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/AntonelliLab/outsider?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider) [![Coverage Status](https://coveralls.io/repos/github/AntonelliLab/outsider/badge.svg?branch=master)](https://coveralls.io/github/AntonelliLab/outsider?branch=master) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![DOI](https://zenodo.org/badge/145114547.svg)](https://zenodo.org/badge/latestdoi/145114547) [![ropensci](https://badges.ropensci.org/282_status.svg)](https://github.com/ropensci/onboarding/issues/282)

> The Outsider is always unhappy, but he is an agent that ensures the happiness for millions of 'Insiders'.<br><br> *[The Outsider, Wilson, 1956](https://en.wikipedia.org/wiki/The_Outsider_(Colin_Wilson)).*

<br> Integrating external programs into a deployable, R workflow can be challenging. Although there are many useful functions and packages (e.g. `base::system()`) for calling code and software from alternative languages, these approaches require users to independently install dependant software and may not work across platforms. `outsider` aims to make this easier by allowing users to install, run and control programs *outside of R* across all operating systems.

It's like [whalebrew](https://github.com/whalebrew/whalebrew) but exclusively for R.

**For more detailed information, check out the [`outsider` website](https://antonellilab.github.io/outsider/articles/outsider.html)**

Installation
------------

To install the development version of the package ...

``` r
remotes::install_github('AntonelliLab/outsider')
```

Additionally, you will also need to install **Docker desktop**. To install Docker visit the Docker website and follow the instructions for your operating system: [Install Docker](https://www.docker.com/products/docker-desktop).

### Compatibility

Tested and functioning on Linux, Mac OS and Windows. (For some older versions of Windows, the legacy [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/) may be required instead of Docker Desktop.)

Quick example
-------------

``` r
library(outsider)
#> ----------------
#> outsider v 0.1.0
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

Available external programs
---------------------------

Modules available on GitHub since 14:42 22 October 2019 (CEST)

● astral

● BAMM

● beast

● blast

● mafft

● PartitionFinder2

● pasta

● PyRate

● RAxML

● revbayes

● trimal

For more details, see the [available modules table](https://antonellilab.github.io/outsider/articles/available.html)

How does it work?
-----------------

`outsider` makes use of the program [docker](https://www.docker.com/) which allows users to create small, deployable machines, called Docker images. The advantage of these images is that they can be run on any machine that has Docker installed, regardless of operating system. The `outsider` package makes external programs available in R by facilitating the interaction between Docker and the R console through **outsider modules**. These modules consist of two parts: a Dockerfile that describes the Docker image that contains the external program and an R package for interacting with the Docker image. Upon installing and running a module through `outsider`, a Docker image is launched and the R code of the module is used to interact with the external program. Anyone can create a module. They are hosted on [GitHub](https://github.com/) as well as other code-sharing sites and can be searched for and downloaded through `outsider`.

![outsider\_outline](https://raw.githubusercontent.com/AntonelliLab/outsider/master/other/outline.png)

To create your own module, check out the [`outsider.devtools`](https://github.com/AntonelliLab/outsider.devtools) package.

Outsider CI statuses
--------------------

|                                                                            |                                                                                                                                                     |                                                                                                                                                                                                        |
|----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`outsider.base`](https://github.com/AntonelliLab/outsider.base)           | [![Build Status](https://travis-ci.org/AntonelliLab/outsider.base.svg?branch=master)](https://travis-ci.org/AntonelliLab/outsider.base)             | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/AntonelliLab/outsider.base?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider.base)             |
| [`outsider`](https://github.com/AntonelliLab/outsider)                     | [![Build Status](https://travis-ci.org/AntonelliLab/outsider.svg?branch=master)](https://travis-ci.org/AntonelliLab/outsider)                       | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/AntonelliLab/outsider?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider)                       |
| [`outsider.devtools`](https://github.com/AntonelliLab/outsider.devtools)   | [![Build Status](https://travis-ci.org/AntonelliLab/outsider.devtools.svg?branch=master)](https://travis-ci.org/AntonelliLab/outsider.devtools)     | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/AntonelliLab/outsider.devtools?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider.devtools)     |
| [outsider-testsuites](https://github.com/AntonelliLab/outsider-testsuites) | [![Build Status](https://travis-ci.org/AntonelliLab/outsider-testsuites.svg?branch=master)](https://travis-ci.org/AntonelliLab/outsider-testsuites) | [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/AntonelliLab/outsider-testsuites?branch=master&svg=true)](https://ci.appveyor.com/project/DomBennett/outsider-testsuites) |

Version
-------

Development version 0.1.

Maintainer
----------

[Dom Bennett](https://github.com/DomBennett)
