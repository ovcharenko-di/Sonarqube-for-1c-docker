FROM adoptopenjdk:11-jdk-hotspot as builder

WORKDIR /tmp

ARG SONAR_BRANCH_PLUGIN_BRANCH=master

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
	&& rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf

RUN git clone https://github.com/mc1arke/sonarqube-community-branch-plugin --branch ${SONAR_BRANCH_PLUGIN_BRANCH} \
    && cd sonarqube-community-branch-plugin \
    && ./gradlew clean build

FROM sonarqube:8.3.1-community

ARG BSL_PLUGIN_VERSION=1.7.0
ARG SONAR_LP_VERSION=8.3.1

ENV PLUGIN=https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar \
    PLUGIN_NAME=sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar \ 
    WEB_ZIP=https://github.com/asosnoviy/sonarqube/releases/download/LP${SONAR_LP_VERSION}/webapp.zip

USER root

WORKDIR /opt/sonarqube

RUN apk add --no-cache \ 
    curl \
    unzip \
	&& rm -rf /var/cache/apk/*

RUN curl -o webapp.zip -fsSL "$WEB_ZIP" \
    && unzip -q webapp.zip \
    && cp -f -r webapp/* web/ \
    && rm -r webapp \
    && rm webapp.zip \
    && curl -o "$PLUGIN_NAME" -fsSL "$PLUGIN" \
    && mv -f "$PLUGIN_NAME" extensions/plugins/

RUN mkdir -p extensions/downloads

COPY --from=builder /tmp/sonarqube-community-branch-plugin/build/libs/* extensions/downloads
COPY --from=builder /tmp/sonarqube-community-branch-plugin/build/libs/* lib/common

RUN chown -R sonarqube:sonarqube extensions/downloads \
    && chown -R sonarqube:sonarqube lib/common

USER sonarqube
