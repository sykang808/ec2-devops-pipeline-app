# Tomcat Java 7 샘플 애플리케이션

이 프로젝트는 Java 7과 Tomcat을 사용하는 간단한 웹 애플리케이션입니다. AWS EC2 인스턴스에 배포되며, 오토스케일링 그룹과 로드 밸런서를 통해 고가용성을 제공합니다.

## 프로젝트 구조

- `src/main/java`: Java 소스 코드
- `src/main/webapp`: 웹 애플리케이션 리소스 (JSP, HTML, CSS 등)
- `src/main/webapp/WEB-INF`: 웹 애플리케이션 설정 파일
- `.github/workflows`: GitHub Actions 워크플로우 설정
- `scripts`: CodeDeploy 배포 스크립트

## CI/CD 파이프라인

이 프로젝트는 GitHub Actions와 AWS CodeDeploy를 사용하여 지속적 통합 및 배포(CI/CD)를 구현합니다.

### GitHub Actions
코드가 main 브랜치에 푸시되면 자동으로 다음 작업이 실행됩니다:
1. Java 7 환경에서 Maven을 사용해 애플리케이션을 빌드합니다.
2. 배포 패키지를 생성하고 AWS S3 버킷에 업로드합니다.
3. AWS CodeDeploy를 통해 EC2 인스턴스에 애플리케이션을 배포합니다.

### GitHub Secrets 설정
GitHub 레포지토리에서 다음 시크릿을 설정해야 합니다:
- `AWS_ACCESS_KEY_ID`: AWS IAM 사용자의 액세스 키 ID
- `AWS_SECRET_ACCESS_KEY`: AWS IAM 사용자의 시크릿 액세스 키
- `AWS_REGION`: 배포할 AWS 리전 (예: ap-northeast-2)
- `S3_BUCKET`: 배포 아티팩트를 저장할 S3 버킷 이름 (CDK 스택 출력에서 확인)

### CodeDeploy 배포 프로세스
배포 과정은 `appspec.yml` 파일과 `scripts` 디렉토리의 스크립트에 정의되어 있습니다:
1. **BeforeInstall**: Tomcat 및 Java 설치, 이전 배포 정리
2. **AfterInstall**: WAR 파일을 Tomcat 웹앱 디렉토리에 복사
3. **ApplicationStart**: Tomcat 서비스 재시작
4. **ValidateService**: 애플리케이션이 정상적으로 실행되는지 확인

## 빌드 및 배포

### 로컬 빌드
Maven을 사용하여 프로젝트를 빌드할 수 있습니다:

```bash
mvn clean package
```

빌드된 WAR 파일은 `target/tomcat-sample-app.war`에 생성됩니다.

### 수동 배포 트리거
GitHub Actions 워크플로우를 수동으로 트리거하려면 GitHub 레포지토리의 Actions 탭에서 "Build and Deploy to EC2" 워크플로우를 선택하고 "Run workflow" 버튼을 클릭하세요.

## 인프라 구성

이 애플리케이션은 다음과 같은 AWS 인프라에 배포됩니다:

- EC2 인스턴스 (t3.large)
- 2개의 가용 영역을 사용하는 VPC
- 1개의 NAT Gateway
- CPU 사용률 80% 이상일 때 스케일 아웃되는 오토스케일링 그룹
- Application Load Balancer
- CodeDeploy 애플리케이션 및 배포 그룹
- 배포 아티팩트를 저장하기 위한 S3 버킷 