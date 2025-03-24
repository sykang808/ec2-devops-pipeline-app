#!/bin/bash
# 환경 변수 로드
if [ -f /tmp/tomcat_env.sh ]; then
    echo "Tomcat 환경 변수 로드 중..."
    source /tmp/tomcat_env.sh
    echo "Tomcat 서비스: $TOMCAT_SERVICE"
    echo "CATALINA_HOME: $CATALINA_HOME"
    echo "CATALINA_BASE: $CATALINA_BASE"
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
    
    # Tomcat 디렉토리 확인
    for tomcat_dir in /usr/share/tomcat* /opt/tomcat* /var/lib/tomcat*; do
        if [ -d "$tomcat_dir" ]; then
            CATALINA_HOME="$tomcat_dir"
            CATALINA_BASE="$tomcat_dir"
            echo "Tomcat 디렉토리 발견: $CATALINA_HOME"
            break
        fi
    done
    
    if [ -z "$TOMCAT_SERVICE" ]; then
        echo "ERROR: Tomcat 서비스를 찾을 수 없습니다."
        exit 1
    fi
fi

# Tomcat 서비스 파일 확인 및 수정 (catalina.home/base가 비어있을 경우)
if [ -f "/usr/lib/systemd/system/tomcat.service" ] && [ -n "$CATALINA_HOME" ]; then
    echo "Tomcat 서비스 파일 확인 중..."
    if grep -q "\-Dcatalina.base=\s*\-D" /usr/lib/systemd/system/tomcat.service || 
       grep -q "\-Dcatalina.home=\s*\-D" /usr/lib/systemd/system/tomcat.service; then
        echo "catalina.base/home이 비어있어 수정합니다..."
        # 백업 생성
        cp /usr/lib/systemd/system/tomcat.service /usr/lib/systemd/system/tomcat.service.bak
        
        # 서비스 파일 수정
        sed -i "s|-Dcatalina.base=|-Dcatalina.base=$CATALINA_HOME|g" /usr/lib/systemd/system/tomcat.service
        sed -i "s|-Dcatalina.home=|-Dcatalina.home=$CATALINA_HOME|g" /usr/lib/systemd/system/tomcat.service
        
        # systemd 재로드
        systemctl daemon-reload
    fi
fi

# Tomcat 재시작 시도
echo "Tomcat 서비스 재시작 시도: $TOMCAT_SERVICE"
systemctl restart $TOMCAT_SERVICE

# 재시작 실패 시 수동으로 시작 시도
if [ $? -ne 0 ] && [ -n "$CATALINA_HOME" ] && [ -f "$CATALINA_HOME/bin/startup.sh" ]; then
    echo "서비스 재시작 실패, 수동으로 시작 시도..."
    CATALINA_HOME="$CATALINA_HOME" CATALINA_BASE="$CATALINA_HOME" $CATALINA_HOME/bin/startup.sh
    
    # 추가 디버깅을 위해 startup.sh 직접 실행 결과 확인
    echo "startup.sh 직접 실행 결과:"
    CATALINA_HOME="$CATALINA_HOME" CATALINA_BASE="$CATALINA_HOME" $CATALINA_HOME/bin/startup.sh
    
    # 프로세스 확인
    echo "프로세스 확인:"
    ps aux | grep -E 'tomcat|java.*catalina' | grep -v grep
fi

# 배포 로그 기록
echo "Application restart requested at $(date)" >> /var/log/tomcat-deploy.log

# 서비스 상태 확인
echo "Tomcat 서비스 상태 확인:"
systemctl status $TOMCAT_SERVICE --no-pager || echo "서비스 상태 확인 실패"

# 잠시 대기
sleep 10
echo "Application start completed" 