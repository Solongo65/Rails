# pulling jenkins image from docker repository
FROM --platform=linux/amd64 jenkins/jenkins:2.378
# setup wizard it will be disable and it will setup jenkins as code, and disable client IP check 
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false -Djenkins.model.Jenkins.crumbIssuerProxyCompatibility=true
# copying the list of plugins we want to instal from local to the image
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
# to run the instalation of the plugins defined in plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
# to set the user as root
USER root

