# Contributing

You are very welcome to help out in the development of `outsider`!

If you have any ideas for future features then please create an issue.
Otherwise, if you have the guile, time and inspriation dig deep into the code
and fix/create, then please fork and send a pull request!

## Outsider structure

The `outsider` universe is split between four different entities:

* [`outsider.base`](https://github.com/AntonelliLab/outsider.base): low-level
interface between Docker and modules.
* [`outsider`](https://github.com/AntonelliLab/outsider): the user-friendly
functions for running and installing modules.
* [`outsider.devtools`](https://github.com/AntonelliLab/outsider.devtools):
toolkit for making it easier to develop modules.
* ["Test suites"](https://github.com/AntonelliLab/outsider-testsuites):
pipelines connecting modules to test holistic functionality.

If you wish to raise an issue or create a pull-request, please first
determine which part of the `outsider` structure is most relevant. For example,
if the problem seems to be Docker-related it is likely `outsider.base`. If it
seems to be module discoverability it is likely `outsider`. (If in doubt
select `outsider` as default.)

## Areas for possible contribution

### New test suite

`outsider` aims to make it easier to string pipelines together in R that make
use of multiple external programs. To ensure that this is continually
functional, as the project and its packages develop, a GitHub repo
called "outsider-testsuites" is used to run a series of pipelines ("suites")
that run domain-specific pipelines. For example, "suite_1" runs a biological
analysis for inferring an evolutionary tree of pineapple-like plants.

If you have created a series of `outsider` modules for a specific domain and
think they would make for a given test suite, then please add a new pipeline to
the
["outsider-testsuites"](https://github.com/AntonelliLab/outsider-testsuites)!

## How to contribute to an R package

To contribute you will need a GitHub account and to have knowledge of
R (plus, depending on where you contribute, knowledge of bash and Docker).
You can then create a fork of the repo in your own GitHub account
and download the repository to your local machine. `devtools` is recommended.

```r
devtools::install_github('[your account]/outsider')
```

All new functions must be tested. For every new file in `R/`, a new test file
must be created in `tests/testthat/`. To test the package and make sure it
meets CRAN guidelines use `devtools`. 

```r
devtools::test()
devtools::check_cran()
```

For help, refer to Hadley Wickham's book, [R packages](http://r-pkgs.had.co.nz/).

## Style guide

`outsider` is developed for submission to ROpenSci. This means the package and
its code should meet ROpenSci style and standards. For example, function
names should be all lowercase, separated by underscores and the last word
should, ideally, be a verb.

```
# e.g.
species_ids_retrieve()  # good
sppIDs()                # not great
sp.IDS_part2()          # really bad
sigNXTprt.p()           # awful
```

It is best to make functions small, with specific names. Feel free to break up code into multiple separate files (e.g. tools,
helper functions, stages ...). For more details and better explanations refer to the ROpenSci [guide](https://devguide.ropensci.org/building.html).
