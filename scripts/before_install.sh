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
if ! systemctl status tomcat &> /dev/null
then
    yum install -y tomcat tomcat-webapps tomcat-admin-webapps
    systemctl start tomcat
    systemctl enable tomcat
fi

# 배포 로그 파일 생성
touch /var/log/tomcat-deploy.log
chown tomcat:tomcat /var/log/tomcat-deploy.log

# 이전 배포 정리
if [ -d /var/lib/tomcat/webapps/ROOT ]; then
    rm -rf /var/lib/tomcat/webapps/ROOT
fi

if [ -f /var/lib/tomcat/webapps/ROOT.war ]; then
    rm -f /var/lib/tomcat/webapps/ROOT.war
fi

echo "Before install completed" 