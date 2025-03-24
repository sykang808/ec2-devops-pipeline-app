#!/bin/bash
# WAR 파일을 Tomcat 웹앱 디렉토리로 복사
cp /tmp/tomcat-sample-app.war /var/lib/tomcat/webapps/ROOT.war

# 권한 설정
chown -R tomcat:tomcat /var/lib/tomcat/webapps/

echo "After install completed" 