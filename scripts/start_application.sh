#!/bin/bash
# Tomcat 재시작
systemctl restart tomcat7

# 배포 로그 기록
echo "Application restart requested at $(date)" >> /var/log/tomcat-deploy.log

# 잠시 대기
sleep 10
echo "Application start completed" 