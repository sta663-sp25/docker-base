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
    libnode-dev

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
RUN apt-get install -y --no-install-recommends \
    python3-dev python3-pip && \
    ln -sf /usr/bin/python3 /usr/bin/python

RUN pip install \
    jupyter \
    notebook \
    jupyterlab \
    ipykernel \
    numpy \
    ipywidgets \
    pandas \
    matplotlib \
    scipy \
    seaborn \
    scikit-learn \
    scikit-image \
    statsmodels \
    sympy \
    cython \
    patsy \
    numba \
    bokeh \
    sqlalchemy \
    beautifulsoup4 \
    pandas-datareader \
    ipython-sql \
    pandasql \
    memory_profiler \
    ipyparallel \
    pymc \
    pystan \
    arrow \
    scikit-plot \
    torch \
    jax \
    shiny \
    shapely \
    nbdev \
    numpyro \
    blackjax \
    bridgestan

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

RUN install.r devtools rmarkdown tidyverse gifski \
 && installGithub.r rundel/checklist rundel/parsermd

RUN apt-get update \
 && apt-get install -y pandoc libmagick++-dev


RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
