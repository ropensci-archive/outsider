---
title: "outsider: Install and run programs, outsider of R, inside of R"
tags:
  - R
  - Docker
  - GitHub
authors:
  - name: Dominic J. Bennett
    orcid: 0000-0003-2722-1359
    affiliation: "1, 2"
  - name: Hannes Hettling
    affiliation: "3"
  - name: Daniele Silvestro
    orcid: 0000-0003-0100-0961
    affiliation: "1, 2"
  - name: Rutger Vos
    orcid: 0000-0001-9254-7318
    affiliation: "3"
  - name: Alexandre Antonelli
    orcid: 0000-0003-1842-9297
    affiliation: "1, 2, 4"
affiliations:
  - name: Gothenburg Global Biodiversity Centre, Box 461, SE-405 30 Gothenburg, Sweden
    index: 1
  - name: Department of Biological and Environmental Sciences, University of Gothenburg, Box 461, SE-405 30 Gothenburg, Sweden
    index: 2
  - name: Naturalis Biodiversity Center, P.O. Box 9517, 2300 RA Leiden, The Netherlands
    index: 3
  - name: Gothenburg Botanical Garden, SE 41319 Gothenburg, Sweden
    index: 4
date: 19 December 2018
bibliography: paper.bib
---

# Summary

Programmatic, analysis pipelines are useful tools for generating results in a consistent manner.  Pipelines make it easier to demonstrate the reproducibility of one’s research as well as create analyses that update as new data are added. Not all analyses, however, can necessarily be coded in one’s favoured programming language. As such, a key requirement for constructing successful pipelines is the ability to integrate code and programs from multiple sources. R [@cran] is one of the most popular computer languages amongst researchers, and many packages exist for calling programs and code from non-R sources (e.g. [@sys] for shell commands, [@reticulate] for `python` and [@rJava] for `Java`). No R package exists, however, with the ability to call code originating from *any* source.

The `outsider` package works through `docker` [@docker] and `GitHub` [@github] to allow a user to install and run, in theory, any external, command-line program.

## How it works

The `outsider` package provides an interface to install and run *outsider modules*. These modules are hosted on GitHub [@github] and consist of two parts: an R package and a Dockerfile. The Dockerfile details the installation process for an external program in the form of a Docker image while the R package comprises functions and documentation for interacting with the external program. By default, a module’s R code simply passes command-line arguments through Docker. After installation a module’s functions can then be imported and launched using `outsider` functions. Upon running a module’s code, the `outsider` package will first launch a Docker container of the image as described by the module’s Dockerfile. `outsider` then facilitates the communication between the module’s R code and the Docker container that hosts the external program. The `outsider` package allows users to look-up available modules and determine build status before installing. In addition the package comes with tools to help users develop their own modules.

![An outline of the outsider module ecosystem.](https://raw.githubusercontent.com/antonellilab/outsider/master/other/outline.png)

------

# Examples

## Saying hello from Ubuntu

By hosting a virtual machine, `outsider` can run any external command-line program. To demonstrate this process we can say "hello world" via a virtual machine hosting the [Ubuntu operating system](https://en.wikipedia.org/wiki/Ubuntu). In this short example, we will install a small `outsider module` -- `om..hello.world` -- that installs a local copy of the latest version of Ubuntu and contains a function for saying hello using the command `echo`.

```r
library(outsider)
# outsider modules are hosted on GitHub
# this repo is a demonstration outsider module
# it contains a function for printing 'Hello World!'
repo <- 'dombennett/om..hello.world'
module_install(repo = repo)
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

**For more detailed and up-to-date examples and tutorials, see the `outsider` GitHub page [@outsider_gh].**

# Availability

`outsider` is open source software made available under the MIT license. It can be installed through CRAN [@outsider_cran], `install.package("outsider")`, or from its GitHub source code repository using the `devtools` package, e.g. as follows: `devtools::install_github("ropensci/outsider")`

# Funding
This package has been developed as part of the supersmartR project [@supersmart] which has received funding through A.A. (from the Swedish Research Council [B0569601], the Swedish Foundation for Strategic Research, a Wallenberg Academy Fellowship, the Faculty of Sciences at the University of Gothenburg and the Wenner-Gren Foundations) and through D.S. (from the Swedish Research Council [2015-04748]).

# References
