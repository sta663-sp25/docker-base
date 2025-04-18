FROM ubuntu:24.04

RUN useradd -s /bin/bash -m docker \
    && usermod -a -G staff docker

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        dirmngr \
        ed \
        gpg-agent \
        less \
        locales \
        vim-tiny \
        wget \
        ca-certificates \
    && wget -q -O - https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
     | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc  \
    && add-apt-repository --yes "ppa:marutter/rrutter4.0" \
    && add-apt-repository --yes "ppa:edd/misc"


## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## This was not needed before but we need it now
ENV DEBIAN_FRONTEND noninteractive

## Otherwise timedatectl will get called which leads to 'no systemd' inside Docker
ENV TZ UTC


RUN apt-get update \
 && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    pandoc \
    libmagick++-dev \
    libglpk-dev \
    libnode-dev \
    libncurses-dev

RUN apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    git \
    vim \
    jed \
    build-essential \
    unzip \
    libsm6 \
    pandoc \
    manpages \
    manpages-dev \
    man \
    gdebi \
    libopenblas-dev \
    libarmadillo-dev \
    libeigen3-dev

RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.40/quarto-1.6.40-linux-amd64.deb \
    && DEBIAN_FRONTEND=noninteractive gdebi --n quarto-*-linux-amd64.deb \
    && rm quarto-*-linux-amd64.deb

# python and related stuff
#RUN apt-get install -y  \
#    python3-dev python3-full python3-pip && \
#    ln -sf /usr/bin/python3 /usr/bin/python

ENV HOME "/root"
WORKDIR ${HOME}
RUN apt-get install -y git
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv
ENV PYENV_ROOT "${HOME}/.pyenv"
ENV PATH "${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

ENV PYTHON_CONFIGURE_OPTS "--enable-shared"
ENV PYTHON_VERSION 3.12.8
RUN pyenv install ${PYTHON_VERSION}
RUN pyenv global ${PYTHON_VERSION}

ADD requirements.txt /root/requirements.txt

RUN pip install -r /root/requirements.txt

# R Stuff

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       littler \
       r-base \
       r-base-dev \
       r-recommended \
       r-cran-docopt \
    && chown root:staff "/usr/local/lib/R/site-library" \
    && chmod g+ws "/usr/local/lib/R/site-library" \
    && ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r \
    && ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ADD Rprofile.site /usr/lib/R/etc/Rprofile.site

RUN install.r devtools rmarkdown tidyverse gifski reticulate \
 && installGithub.r rundel/checklist rundel/parsermd

#RUN Rscript -e "reticulate::py_install(readLines('/root/requirements.txt'))" && \
#    echo "reticulate::use_python('/root/.virtualenvs/r-reticulate/bin/python')" >> /usr/lib/R/etc/Rprofile.site

RUN apt-get update \
 && apt-get install -y pandoc libmagick++-dev


RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
