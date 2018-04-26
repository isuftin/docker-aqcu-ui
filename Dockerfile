FROM tomcat:8.0-jre8

ENV probe_version=3.0.0.M3
ENV repo_name=aqcu-maven-snapshots
ENV artifact_id=aqcu-ui
ENV artifact_version=1.9.1-SNAPSHOT

ADD pull-from-artifactory.sh pull-from-artifactory.sh
RUN ["chmod", "+x", "pull-from-artifactory.sh"]

ADD entrypoint.sh entrypoint.sh
RUN ["chmod", "+x", "entrypoint.sh"]

RUN mkdir -p /usr/local/tomcat/ssl

COPY server.xml /usr/local/tomcat/conf/server.xml
COPY context.xml /usr/local/tomcat/conf/context.xml
COPY tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

COPY setenv.sh /usr/local/tomcat/bin/setenv.sh 
RUN chmod +x /usr/local/tomcat/bin/setenv.sh

RUN wget -O /usr/local/tomcat/webapps/probe.war "https://github.com/psi-probe/psi-probe/releases/download/${probe_version}/probe.war"
RUN ./pull-from-artifactory.sh ${repo_name} gov.usgs.aqcu ${artifact_id} ${artifact_version} /usr/local/tomcat/webapps/timeseries.war

ENV TOMCAT_CERT_PATH=/tomcat-wildcard-ssl.crt
ENV TOMCAT_KEY_PATH=/tomcat-wildcard-ssl.key
ENV keystoreLocation=/usr/local/tomcat/ssl/localkeystore.p12
ENV keystorePassword=changeme
ENV keystoreSSLKey=tomcat
ENV cidaAuthWebserviceUrl=https://cidaauth.nwis.usgs.gov/auth-webservice/
ENV serverHttpPort=80
ENV serverHttpsPort=443
ENV aqcuWebserviceUrl=https://reporting.nwis.usgs.gov/timeseries-ws
ENV aquariusServiceUrl=http://ts.nwis.usgs.gov
ENV nwisRaInterfaceUrl=https://reporting.nwis.usgs.gov/
ENV nwisRaServiceUrl=https://reporting.nwis.usgs.gov/service
ENV nwisHelpEmail=changeme@test.gov
ENV development=true
ENV TZ=America/Chicago

ENTRYPOINT ["/usr/local/tomcat/entrypoint.sh"]