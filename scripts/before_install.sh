#!/bin/bash
# 배포 디렉토리 준비
mkdir -p /tmp/codedeploy

# Amazon Linux 2 확인 및 정보 출력
echo "시스템 정보:"
cat /etc/os-release

# 필요한 패키지 설치 확인
if ! command -v java &> /dev/null
then
    echo "Java가 설치되어 있지 않아 설치합니다..."
    yum update -y
    yum install -y java-1.7.0-openjdk-devel
    java -version
fi

# 시스템에 설치된 Tomcat 패키지 확인
echo "현재 설치된 Tomcat 패키지 확인:"
rpm -qa | grep -i tomcat || echo "설치된 Tomcat 패키지가 없습니다."

# 시스템에 등록된 서비스 확인
echo "등록된 Tomcat 서비스 확인:"
systemctl list-unit-files | grep -i tomcat || echo "등록된 Tomcat 서비스가 없습니다."

# Tomcat 설치 (기본 Amazon Linux 2 리포지토리에서)
echo "Tomcat 설치 중..."
yum install -y tomcat tomcat-webapps tomcat-admin-webapps

# 설치 후 서비스 이름 확인
echo "설치 후 서비스 확인:"
TOMCAT_SERVICE=$(systemctl list-unit-files | grep -i tomcat | head -1 | awk '{print $1}')

if [ -z "$TOMCAT_SERVICE" ]; then
    echo "Tomcat 서비스를 찾을 수 없습니다. 수동으로 서비스 이름을 확인합니다."
    # 일반적인 Tomcat 서비스 이름 시도
    for service_name in tomcat tomcat8 tomcat9 tomcat7; do
        if systemctl status $service_name &>/dev/null; then
            TOMCAT_SERVICE=$service_name
            echo "Tomcat 서비스 이름: $TOMCAT_SERVICE"
            break
        fi
    done
else
    echo "Tomcat 서비스 이름: $TOMCAT_SERVICE"
fi

# 서비스 시작 및 활성화
if [ -n "$TOMCAT_SERVICE" ]; then
    echo "Tomcat 서비스 시작 및 활성화: $TOMCAT_SERVICE"
    systemctl start $TOMCAT_SERVICE
    systemctl enable $TOMCAT_SERVICE
    
    # 환경 변수 저장
    echo "TOMCAT_SERVICE=$TOMCAT_SERVICE" > /tmp/tomcat_env.sh
else
    echo "ERROR: Tomcat 서비스를 찾을 수 없습니다. 수동 설치가 필요합니다."
    # 대체 설치 시도
    echo "대체 설치 시도: Amazon Linux Extras 사용"
    amazon-linux-extras install -y tomcat8.5 || echo "Amazon Linux Extras에서 Tomcat 설치 실패"
    
    # 다시 서비스 이름 확인
    TOMCAT_SERVICE=$(systemctl list-unit-files | grep -i tomcat | head -1 | awk '{print $1}')
    if [ -n "$TOMCAT_SERVICE" ]; then
        echo "대체 설치 후 서비스 이름: $TOMCAT_SERVICE"
        systemctl start $TOMCAT_SERVICE
        systemctl enable $TOMCAT_SERVICE
        echo "TOMCAT_SERVICE=$TOMCAT_SERVICE" > /tmp/tomcat_env.sh
    else
        echo "FATAL ERROR: Tomcat 서비스를 설치할 수 없습니다."
        exit 1
    fi
fi

# 배포 로그 파일 생성
touch /var/log/tomcat-deploy.log
chown tomcat:tomcat /var/log/tomcat-deploy.log || echo "tomcat 사용자가 없어 로그 파일 권한을 변경할 수 없습니다."

# 웹 애플리케이션 디렉토리 확인 및 생성
echo "웹 애플리케이션 디렉토리 확인:"
for webapps_dir in /var/lib/tomcat/webapps /usr/share/tomcat/webapps /var/lib/tomcat8/webapps /var/lib/tomcat9/webapps; do
    if [ -d "$webapps_dir" ]; then
        echo "웹앱 디렉토리 발견: $webapps_dir"
        echo "TOMCAT_WEBAPPS=$webapps_dir" >> /tmp/tomcat_env.sh
        break
    fi
done

# 이전 배포 정리
source /tmp/tomcat_env.sh
if [ -n "$TOMCAT_WEBAPPS" ] && [ -d "$TOMCAT_WEBAPPS/ROOT" ]; then
    rm -rf $TOMCAT_WEBAPPS/ROOT
    echo "이전 ROOT 디렉토리 제거: $TOMCAT_WEBAPPS/ROOT"
fi

if [ -n "$TOMCAT_WEBAPPS" ] && [ -f "$TOMCAT_WEBAPPS/ROOT.war" ]; then
    rm -f $TOMCAT_WEBAPPS/ROOT.war
    echo "이전 ROOT.war 파일 제거: $TOMCAT_WEBAPPS/ROOT.war"
fi

echo "Before install completed" 