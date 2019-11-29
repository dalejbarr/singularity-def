# Definition files for talklab singularity containers

This repository contains `.def` files and auxiliary files for building containers with software used in my lab.

## Base container `talklab-base` v0.1.0

The base container includes:

* emacs 25.2.2
* org-mode version 9.2.6
* ess 18.10.2
* R version 3.6.1
* apa6 latex class for APA-style formatting

To build it:

```
sudo singularity build talklab-base.sif talklab-base.def
```

## Tidyverse container `talklab-tidy` v0.1.0

This container is built from the `talklab-base` image, and adds the following R packages:

* tidyverse
* devtools
* rmarkdown, webex, knitr, kableExtra, xtable
* lme4, ordinal
* RSQLite
* eyeread (for reading in Eyelink 1000 EDF files)

Build it using:

```
sudo singularity build talklab-tidy.sif talklab-tidy.def
```
