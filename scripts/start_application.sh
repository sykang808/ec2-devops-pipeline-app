#!/bin/bash
# 환경 변수 로드
if [ -f /tmp/tomcat_env.sh ]; then
    echo "Tomcat 환경 변수 로드 중..."
    source /tmp/tomcat_env.sh
    echo "Tomcat 서비스: $TOMCAT_SERVICE"
else
    echo "환경 변수 파일을 찾을 수 없습니다. 서비스 이름 탐색 시도..."
    # 서비스 이름 확인
    for service_name in tomcat tomcat8 tomcat9 tomcat7; do
        if systemctl list-unit-files | grep -q $service_name; then
            TOMCAT_SERVICE=$service_name
            echo "Tomcat 서비스 이름: $TOMCAT_SERVICE"
            break
        fi
    done
    
    if [ -z "$TOMCAT_SERVICE" ]; then
        echo "ERROR: Tomcat 서비스를 찾을 수 없습니다."
        exit 1
    fi
fi

# Tomcat 재시작
echo "Tomcat 서비스 재시작: $TOMCAT_SERVICE"
systemctl restart $TOMCAT_SERVICE

# 배포 로그 기록
echo "Application restart requested at $(date)" >> /var/log/tomcat-deploy.log

# 서비스 상태 확인
echo "Tomcat 서비스 상태 확인:"
systemctl status $TOMCAT_SERVICE --no-pager || echo "서비스 상태 확인 실패"

# 잠시 대기
sleep 10
echo "Application start completed" 