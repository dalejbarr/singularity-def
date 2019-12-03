FROM ubuntu:latest

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg
RUN DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.1-linux-x86_64.tar.gz && \
    tar xvzf julia-1.1.1-linux-x86_64.tar.gz && \
    mv julia-1.1.1/ /usr/share/ && \
    ln -s /usr/share/julia-1.1.1/bin/julia /usr/bin/julia

# now configure julia and R
RUN Rscript -e 'install.packages(c("JuliaCall", "lme4"))'

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl libssl-dev \
    libcurl4-openssl-dev libxml2-dev

RUN Rscript -e 'install.packages(c("devtools"))'
RUN Rscript -e 'devtools::install_github("dmbates/RePsychLing")'

RUN DEBIAN_FRONTEND=noninteractive apt-get install --reinstall locales
RUN locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN rm julia-1.1.1-linux-x86_64.tar.gz

RUN locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# just to have a basic text editor
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y emacs-nox ess

RUN Rscript -e 'install.packages("tidyverse")'

RUN Rscript -e 'devtools::install_github("dalejbarr/funfact")'

RUN addgroup --gid 811 talk
RUN useradd -ms /bin/bash --gid 811 ruser
RUN chown ruser:talk /home/ruser
RUN chmod g+rwx /home/ruser
ADD juliacall_test.R /home/ruser/

# run this after adding all the files to home directory
RUN chown -R ruser:811 /home/ruser/
USER ruser
WORKDIR /home/ruser

RUN julia -e 'import Pkg; Pkg.add("RCall"); Pkg.add("MixedModels")'

RUN Rscript -e 'library("JuliaCall"); j <- julia_setup(); j$library("MixedModels")'

# fix locale issues
RUN (echo "export LC_ALL=en_US.UTF-8"; echo "export LANG=en_US.UTF-8"; echo "export LANGUAGE=en_US.UTF-8") >> .bashrc

# setup user's local R library
RUN Rscript -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
RUN Rscript -e 'install.packages("ggthemes")'
RUN Rscript -e 'install.packages("abind")'
RUN Rscript -e 'install.packages("pracma")'

ADD --chown=ruser:811 dotemacs /home/ruser/.emacs
