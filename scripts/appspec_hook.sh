#!/bin/bash
# CodeDeploy 배포 훅 향상 스크립트

# 현재 스크립트 디렉토리 확인
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "스크립트 디렉토리: $SCRIPT_DIR"

# 디버그 모드 활성화
set -x

# 디버깅 스크립트 복사
echo "디버깅 스크립트 복사..."
cp "$SCRIPT_DIR/debug_tomcat.sh" /tmp/debug_tomcat.sh
chmod +x /tmp/debug_tomcat.sh

# Amazon Linux 버전 확인
echo "시스템 정보:"
cat /etc/os-release

# SELinux 상태 확인
echo "SELinux 상태:"
getenforce || echo "SELinux 명령을 찾을 수 없습니다."

# CodeDeploy 에이전트 상태
echo "CodeDeploy 에이전트 상태:"
systemctl status codedeploy-agent --no-pager || echo "CodeDeploy 에이전트 서비스가 없습니다."

# Tomcat 서비스 검색
echo "Tomcat 서비스 검색:"
for service_name in tomcat tomcat8 tomcat9 tomcat7; do
    if systemctl list-unit-files | grep -q $service_name; then
        echo "발견된 Tomcat 서비스: $service_name"
        TOMCAT_SERVICE=$service_name
        break
    fi
done

if [ -z "$TOMCAT_SERVICE" ]; then
    echo "주의: Tomcat 서비스를 찾을 수 없습니다."
    echo "Amazon Linux Extras 패키지 확인:"
    amazon-linux-extras list || echo "Amazon Linux Extras를 찾을 수 없습니다."
else
    echo "TOMCAT_SERVICE=$TOMCAT_SERVICE" > /tmp/tomcat_env.sh
fi

# 웹앱 디렉토리 검색
echo "웹앱 디렉토리 검색:"
for webapps_dir in /var/lib/tomcat*/webapps /usr/share/tomcat*/webapps /opt/tomcat*/webapps; do
    if [ -d "$webapps_dir" ]; then
        echo "발견된 웹앱 디렉토리: $webapps_dir"
        echo "TOMCAT_WEBAPPS=$webapps_dir" >> /tmp/tomcat_env.sh
        break
    fi
done

# Tomcat 수동 설치 시도 (서비스를 찾을 수 없는 경우)
if [ -z "$TOMCAT_SERVICE" ]; then
    echo "Tomcat을 찾을 수 없습니다. Amazon Linux Extras를 통한 설치 시도..."
    amazon-linux-extras install -y tomcat8.5 || echo "Amazon Linux Extras에서 Tomcat 설치 실패"
    
    echo "기본 패키지 관리자를 통한 설치 시도..."
    yum install -y tomcat tomcat-webapps tomcat-admin-webapps || echo "Yum을 통한 Tomcat 설치 실패"
    
    # 다시 서비스 이름 확인
    TOMCAT_SERVICE=$(systemctl list-unit-files | grep -i tomcat | head -1 | awk '{print $1}')
    if [ -n "$TOMCAT_SERVICE" ]; then
        echo "설치 후 발견된 Tomcat 서비스: $TOMCAT_SERVICE"
        echo "TOMCAT_SERVICE=$TOMCAT_SERVICE" > /tmp/tomcat_env.sh
        
        # 서비스 시작
        echo "Tomcat 서비스 시작..."
        systemctl start $TOMCAT_SERVICE
        systemctl enable $TOMCAT_SERVICE
    else
        echo "Tomcat 서비스를 설치할 수 없습니다. 수동 설치가 필요할 수 있습니다."
    fi
fi

# 디버그 모드 비활성화
set +x

echo "appspec_hook.sh 실행 완료" 