#!/bin/bash
# 배포 디렉토리 준비
mkdir -p /tmp/codedeploy

# 필요한 패키지 설치 확인
if ! command -v java &> /dev/null
then
    yum update -y
    yum install -y java-1.7.0-openjdk-devel
fi

# Tomcat이 설치되어 있는지 확인
if ! systemctl status tomcat7 &> /dev/null
then
    yum install -y tomcat7 tomcat7-webapps tomcat7-admin-webapps
    systemctl start tomcat7
    systemctl enable tomcat7
fi

# 이전 배포 정리
if [ -d /var/lib/tomcat7/webapps/ROOT ]; then
    rm -rf /var/lib/tomcat7/webapps/ROOT
fi

if [ -f /var/lib/tomcat7/webapps/ROOT.war ]; then
    rm -f /var/lib/tomcat7/webapps/ROOT.war
fi

echo "Before install completed" 