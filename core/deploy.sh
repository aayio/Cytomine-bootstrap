#!/bin/bash

/etc/init.d/ssh start

echo Starting "$WAR_URL" 
#Copy the war file from mounted directory to tomcat webapps directory
if [ ! -z "$WAR_URL" ]
then
rm -r /var/lib/tomcat7/webapps/*
cd /var/lib/tomcat7/webapps/  && wget -q $WAR_URL -O ROOT.war
mkdir -p /usr/share/tomcat7/.grails
cd /usr/share/tomcat7/.grails

cp /tmp/cytomineconfig.groovy ./

echo "grails.serverURL='http://$CORE_URL'" >> cytomineconfig.groovy
echo "storage_buffer='$IMS_BUFFER_PATH'" >> cytomineconfig.groovy
echo "storage_path='$IMS_STORAGE_PATH'" >> cytomineconfig.groovy

echo "grails.imageServerURL='http://$IMS_URL'" >> cytomineconfig.groovy
echo "grails.retrievalServerURL ='http://$RETRIEVAL_URL'" >> cytomineconfig.groovy
echo "grails.mongo.host = 'mongodb'" >> cytomineconfig.groovy

echo "grails.uploadURL='http://$UPLOAD_URL:81'" >> cytomineconfig.groovy


fi

if [ $IS_LOCAL = true ]; then
	echo "#Custom adding" >> /etc/hosts
	echo "$(route -n | awk '/UG[ \t]/{print $2}')       $IMS_URL" >> /etc/hosts
	echo "$(route -n | awk '/UG[ \t]/{print $2}')       $RETRIEVAL_URL" >> /etc/hosts
fi

service tomcat7 start

echo "/var/log/tomcat7/catalina.out {"   > /etc/logrotate.d/tomcat7
echo "  copytruncate"                   >> /etc/logrotate.d/tomcat7
echo "  daily"                         >> /etc/logrotate.d/tomcat7
echo "  rotate 14"                      >> /etc/logrotate.d/tomcat7
echo "  compress"                       >> /etc/logrotate.d/tomcat7
echo "  missingok"                      >> /etc/logrotate.d/tomcat7
echo "  create 640 tomcat7 adm"         >> /etc/logrotate.d/tomcat7
echo "}"                                >> /etc/logrotate.d/tomcat7

tail -F /var/lib/tomcat7/logs/catalina.out
