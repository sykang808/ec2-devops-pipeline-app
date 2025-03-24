#!/bin/bash
# Tomcat 디버깅 스크립트

# 환경 변수 로드
if [ -f /tmp/tomcat_env.sh ]; then
    echo "Tomcat 환경 변수 로드 중..."
    source /tmp/tomcat_env.sh
    echo "Tomcat 서비스: $TOMCAT_SERVICE"
    echo "웹앱 디렉토리: $TOMCAT_WEBAPPS"
else
    echo "환경 변수 파일을 찾을 수 없습니다."
fi

# 시스템 정보
echo "====== 시스템 정보 ======"
cat /etc/os-release
uname -a

# 설치된 패키지 확인
echo "====== 설치된 Java 및 Tomcat 패키지 ======"
rpm -qa | grep -E 'java|tomcat'

# 설치된 서비스 확인
echo "====== 서비스 목록 ======"
systemctl list-unit-files | grep -E 'tomcat|java'

echo "====== Tomcat 서비스 상태 확인 ======"
for service_name in tomcat tomcat8 tomcat9 tomcat7; do
    echo "서비스 $service_name 확인 중..."
    systemctl status $service_name --no-pager || echo "$service_name 서비스가 존재하지 않거나 실행 중이 아닙니다."
done

echo "====== Tomcat 프로세스 확인 ======"
ps aux | grep -E 'tomcat|java.*catalina' | grep -v grep || echo "Tomcat 관련 프로세스가 없습니다."

echo "====== Tomcat 로그 디렉토리 확인 ======"
for log_dir in /var/log/tomcat* /var/log/catalina /opt/tomcat*/logs /usr/share/tomcat*/logs; do
    if [ -d "$log_dir" ]; then
        echo "로그 디렉토리 발견: $log_dir"
        echo "최근 로그 파일:"
        ls -la $log_dir | tail -5
        
        echo "최근 로그 내용 (catalina.out 또는 유사 파일):"
        find $log_dir -name "catalina.out" -o -name "*.log" | xargs ls -la | head -3
        for log_file in $(find $log_dir -name "catalina.out" -o -name "*.log" | head -1); do
            echo "===== $log_file 마지막 20줄 ====="
            tail -20 $log_file
        done
    fi
done

# 웹앱 디렉토리 확인
echo "====== 웹 애플리케이션 디렉토리 검색 ======"
for webapps_dir in /var/lib/tomcat*/webapps /usr/share/tomcat*/webapps /opt/tomcat*/webapps; do
    if [ -d "$webapps_dir" ]; then
        echo "웹앱 디렉토리 발견: $webapps_dir"
        ls -la $webapps_dir
    fi
done

# WAR 파일 확인
if [ -n "$TOMCAT_WEBAPPS" ]; then
    echo "====== WAR 파일 확인 ======"
    ls -la $TOMCAT_WEBAPPS/*.war 2>/dev/null || echo "WAR 파일이 없습니다."
    
    echo "====== ROOT 디렉토리 확인 ======"
    if [ -d "$TOMCAT_WEBAPPS/ROOT" ]; then
        ls -la $TOMCAT_WEBAPPS/ROOT
    else
        echo "ROOT 디렉토리가 없습니다."
    fi
fi

echo "====== 포트 사용 현황 확인 ======"
netstat -tulpn | grep -E '8080|8443|80' || echo "웹 관련 포트가 사용 중이 아닙니다."

echo "====== Java 버전 확인 ======"
java -version || echo "Java가 설치되어 있지 않습니다."
javac -version || echo "Java 컴파일러가 설치되어 있지 않습니다."
echo "JAVA_HOME: $JAVA_HOME"
echo "PATH: $PATH"

echo "====== 방화벽 상태 확인 ======"
systemctl status firewalld --no-pager || echo "Firewalld가 설치되어 있지 않습니다."
iptables -L -n || echo "iptables 명령을 사용할 수 없습니다."

echo "====== SELinux 상태 확인 ======"
getenforce || echo "SELinux 명령을 찾을 수 없습니다."
sestatus || echo "SELinux 상태를 확인할 수 없습니다."

echo "====== 디스크 및 메모리 상태 ======"
df -h
free -m

echo "====== 마지막 배포 관련 로그 ======"
if [ -f /var/log/tomcat-deploy.log ]; then
    tail -20 /var/log/tomcat-deploy.log
else
    echo "배포 로그 파일이 없습니다."
fi

echo "====== AWS CodeDeploy 에이전트 상태 ======"
systemctl status codedeploy-agent --no-pager || echo "CodeDeploy 에이전트 서비스가 없습니다."

echo "===== 진단 완료 =====" 