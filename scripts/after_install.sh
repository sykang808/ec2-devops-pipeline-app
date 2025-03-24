#!/bin/bash
# 환경 변수 로드
if [ -f /tmp/tomcat_env.sh ]; then
    echo "Tomcat 환경 변수 로드 중..."
    source /tmp/tomcat_env.sh
    echo "웹앱 디렉토리: $TOMCAT_WEBAPPS"
    echo "Tomcat 서비스: $TOMCAT_SERVICE"
else
    echo "환경 변수 파일을 찾을 수 없습니다. 기본 경로 사용 시도..."
    # 웹앱 디렉토리 확인
    for webapps_dir in /var/lib/tomcat/webapps /usr/share/tomcat/webapps /var/lib/tomcat8/webapps /var/lib/tomcat9/webapps; do
        if [ -d "$webapps_dir" ]; then
            TOMCAT_WEBAPPS=$webapps_dir
            echo "웹앱 디렉토리 발견: $TOMCAT_WEBAPPS"
            break
        fi
    done
    
    if [ -z "$TOMCAT_WEBAPPS" ]; then
        echo "ERROR: Tomcat 웹앱 디렉토리를 찾을 수 없습니다."
        exit 1
    fi
    
    # 서비스 이름 확인
    for service_name in tomcat tomcat8 tomcat9 tomcat7; do
        if systemctl list-unit-files | grep -q $service_name; then
            TOMCAT_SERVICE=$service_name
            echo "Tomcat 서비스 이름: $TOMCAT_SERVICE"
            break
        fi
    done
fi

# WAR 파일을 Tomcat 웹앱 디렉토리로 복사
echo "WAR 파일 복사 중: /tmp/tomcat-sample-app.war -> $TOMCAT_WEBAPPS/ROOT.war"
cp /tmp/tomcat-sample-app.war $TOMCAT_WEBAPPS/ROOT.war

# Tomcat 사용자 확인
TOMCAT_USER=$(ps -ef | grep tomcat | grep -v grep | head -1 | awk '{print $1}')
if [ -z "$TOMCAT_USER" ]; then
    TOMCAT_USER="root"
    echo "Tomcat 사용자를 찾을 수 없어 root 사용"
else
    echo "Tomcat 사용자: $TOMCAT_USER"
fi

# 권한 설정
echo "웹앱 디렉토리 권한 설정..."
chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_WEBAPPS/ || echo "권한 설정 실패, 권한 문제가 있을 수 있습니다"

echo "After install completed" 