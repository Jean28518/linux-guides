FROM tomcat:latest
COPY tomcat-users.xml /usr/local/tomcat/conf/
COPY logging.properties /usr/local/tomcat/conf/
RUN mv /usr/local/tomcat/webapps.dist/host-manager /usr/local/tomcat/webapps/
RUN mv /usr/local/tomcat/webapps.dist/docs /usr/local/tomcat/webapps/
RUN mv /usr/local/tomcat/webapps.dist/manager /usr/local/tomcat/webapps/
COPY host-manager-context.xml /usr/local/tomcat/webapps/host-manager/META-INF/context.xml
COPY docs-context.xml /usr/local/tomcat/webapps/docs/META-INF/context.xml
COPY manager-context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
