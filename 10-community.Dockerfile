FROM sonarqube:10.3-community

ARG BRANCH_PLUGIN_VERSION=1.18.0
ARG BSL_PLUGIN_VERSION=1.14.0
ARG OIDC_PLUGIN_VERSION=2.1.1

USER root

WORKDIR /opt/sonarqube

# plugins
ADD --chown=sonarqube:sonarqube https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar extensions/plugins
ADD --chown=sonarqube:sonarqube https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${BRANCH_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${BRANCH_PLUGIN_VERSION}.jar extensions/plugins
ADD --chown=sonarqube:sonarqube https://github.com/vaulttec/sonar-auth-oidc/releases/download/v${OIDC_PLUGIN_VERSION}/sonar-auth-oidc-plugin-${OIDC_PLUGIN_VERSION}.jar extensions/plugins

ENV SONAR_WEB_JAVAADDITIONALOPTS=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin-${BRANCH_PLUGIN_VERSION}.jar=web
ENV SONAR_CE_JAVAADDITIONALOPTS=-javaagent:./extensions/plugins/sonarqube-community-branch-plugin-${BRANCH_PLUGIN_VERSION}.jar=ce

USER sonarqube
