FROM ubuntu:bionic

ENV UPDATED_AT 20190627

RUN \
  apt-get update -qq \
    && apt-get install --only-upgrade openssl \
    && apt-get install -y \
      apt-transport-https \
      build-essential \
      git \
      locales \
      unzip \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


####### NODE
RUN \
  wget --quiet -O - https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get update -qq \
    && apt-get install -y \
      nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


####### ERLANG
ARG ERLANG_VERSION=1:22.0.7-1

RUN \
  echo 'deb http://packages.erlang-solutions.com/ubuntu bionic contrib' >> /etc/apt/sources.list \
    && apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc \
    && apt-get -qq update \
    && apt-get install -y \
      esl-erlang=$ERLANG_VERSION \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


####### ELIXIR
ARG ELIXIR_VERSION=1.9.2

WORKDIR /elixir
RUN \
  wget -q https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip \
    && unzip Precompiled.zip \
    && rm -f Precompiled.zip \
    && ln -s /elixir/bin/elixirc /usr/local/bin/elixirc \
    && ln -s /elixir/bin/elixir /usr/local/bin/elixir \
    && ln -s /elixir/bin/mix /usr/local/bin/mix \
    && ln -s /elixir/bin/iex /usr/local/bin/iex

