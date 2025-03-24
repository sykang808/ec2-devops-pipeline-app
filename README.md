# Tomcat Java 7 샘플 애플리케이션

이 프로젝트는 Java 7과 Tomcat을 사용하는 간단한 웹 애플리케이션입니다. AWS EC2 인스턴스에 배포되며, 오토스케일링 그룹과 로드 밸런서를 통해 고가용성을 제공합니다.

## 프로젝트 구조

- `src/main/java`: Java 소스 코드
- `src/main/webapp`: 웹 애플리케이션 리소스 (JSP, HTML, CSS 등)
- `src/main/webapp/WEB-INF`: 웹 애플리케이션 설정 파일

## 빌드 및 배포

Maven을 사용하여 프로젝트를 빌드할 수 있습니다:

```bash
mvn clean package
```

빌드된 WAR 파일은 `target/tomcat-sample-app.war`에 생성됩니다. 이 파일을 Tomcat의 웹앱 디렉토리에 배포하면 됩니다.

## 인프라 구성

이 애플리케이션은 다음과 같은 AWS 인프라에 배포됩니다:

- EC2 인스턴스 (t3.large)
- 2개의 가용 영역을 사용하는 VPC
- 1개의 NAT Gateway
- CPU 사용률 80% 이상일 때 스케일 아웃되는 오토스케일링 그룹
- Application Load Balancer 