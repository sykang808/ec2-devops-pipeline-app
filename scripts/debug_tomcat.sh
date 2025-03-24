#!/bin/bash
# Tomcat 디버깅 스크립트

echo "====== Tomcat 서비스 상태 확인 ======"
systemctl status tomcat

echo "====== Tomcat 프로세스 확인 ======"
ps aux | grep tomcat

echo "====== Tomcat 로그 확인 (마지막 20줄) ======"
if [ -f /var/log/tomcat/catalina.out ]; then
  tail -20 /var/log/tomcat/catalina.out
else
  echo "Tomcat 로그 파일을 찾을 수 없습니다."
  find /var/log -name "*tomcat*" -type f 2>/dev/null
fi

echo "====== 웹 애플리케이션 디렉토리 확인 ======"
ls -la /var/lib/tomcat/webapps/

echo "====== 포트 사용 현황 확인 ======"
netstat -tulpn | grep 8080 || echo "포트 8080이 사용 중이 아닙니다."

echo "====== Java 버전 확인 ======"
java -version

echo "====== Tomcat 패키지 확인 ======"
rpm -qa | grep tomcat

echo "====== 디스크 공간 확인 ======"
df -h

echo "====== 메모리 사용량 확인 ======"
free -m

echo "====== SELinux 상태 확인 ======"
getenforce || echo "SELinux 명령을 찾을 수 없습니다."

echo "====== 방화벽 상태 확인 ======"
systemctl status firewalld || echo "Firewalld가 설치되어 있지 않습니다." 