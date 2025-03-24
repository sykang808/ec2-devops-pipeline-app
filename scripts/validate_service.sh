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
fi

# 애플리케이션 상태 확인
sleep 5

# Tomcat 서비스 확인
echo "Tomcat 서비스 상태 확인: $TOMCAT_SERVICE"
if [ -n "$TOMCAT_SERVICE" ]; then
    systemctl status $TOMCAT_SERVICE --no-pager
    if [ $? -ne 0 ]; then
        echo "Tomcat 서비스($TOMCAT_SERVICE)가 실행되지 않고 있습니다."
        exit 1
    fi
else
    # 서비스 이름을 찾을 수 없는 경우 프로세스로 확인
    echo "Tomcat 서비스 이름을 찾을 수 없어 프로세스 확인..."
    if ! pgrep -f tomcat > /dev/null && ! pgrep -f java.*catalina > /dev/null
    then
        echo "Tomcat 프로세스가 실행되지 않고 있습니다."
        exit 1
    fi
fi

# 웹 애플리케이션 확인 전 대기
echo "웹 애플리케이션 확인 전 30초 대기..."
sleep 30

# 웹 애플리케이션 확인
echo "웹 애플리케이션 응답 확인 중..."
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "웹 애플리케이션이 올바르게 응답하지 않습니다. HTTP 코드: $HTTP_RESPONSE"
    echo "디버깅 정보:"
    netstat -tulpn | grep 8080 || echo "포트 8080이 사용 중이 아닙니다."
    if [ -f "/tmp/debug_tomcat.sh" ]; then
        echo "디버깅 스크립트 실행 중..."
        bash /tmp/debug_tomcat.sh
    fi
    exit 1
fi

echo "서비스 검증 완료: 애플리케이션이 정상적으로 실행 중입니다."
exit 0 