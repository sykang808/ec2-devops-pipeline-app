#!/bin/bash
# 애플리케이션 상태 확인
sleep 5

# Tomcat 프로세스 확인
if ! pgrep -f tomcat7 > /dev/null
then
    echo "Tomcat 프로세스가 실행되지 않고 있습니다."
    exit 1
fi

# 웹 애플리케이션 확인
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "웹 애플리케이션이 올바르게 응답하지 않습니다. HTTP 코드: $HTTP_RESPONSE"
    exit 1
fi

echo "서비스 검증 완료: 애플리케이션이 정상적으로 실행 중입니다."
exit 0 