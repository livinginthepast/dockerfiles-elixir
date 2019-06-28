FROM ubuntu:xenial

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
ARG OTP_VERSION=22.0.4

# We'll install the build dependencies for erlang-odbc along with the erlang
# build process:
RUN set -xe \
	&& OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
	&& runtimeDeps='libodbc1 \
			libsctp1 \
			libwxgtk3.0 \
			libssl-dev' \
	&& buildDeps='unixodbc-dev \
			libsctp-dev \
			libwxgtk3.0-dev \
			autoconf \
			libncurses5-dev libncursesw5-dev' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $runtimeDeps \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& wget -q -O otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& mkdir -vp $ERL_TOP \
	&& tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
	&& rm otp-src.tar.gz \
	&& ( cd $ERL_TOP \
	  && ./otp_build autoconf \
	  && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	  && ./configure --build="$gnuArch" \
	  && make -j$(nproc) \
	  && make install ) \
	&& find /usr/local -name examples | xargs rm -rf \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf $ERL_TOP /var/lib/apt/lists/*

CMD ["erl"]

####### ELIXIR
ARG ELIXIR_VERSION=1.9.0

WORKDIR /elixir
RUN \
  wget -q https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip \
    && unzip Precompiled.zip \
    && rm -f Precompiled.zip \
    && ln -s /elixir/bin/elixirc /usr/local/bin/elixirc \
    && ln -s /elixir/bin/elixir /usr/local/bin/elixir \
    && ln -s /elixir/bin/mix /usr/local/bin/mix \
    && ln -s /elixir/bin/iex /usr/local/bin/iex

