<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <!DOCTYPE html>
  <html>

  <head>
    <meta charset="UTF-8">
    <title>샘플 Tomcat 애플리케이션</title>
    <style>
      body {
        font-family: 'Malgun Gothic', Arial, sans-serif;
        margin: 0;
        padding: 20px;
        background-color: #f5f5f5;
      }

      .container {
        max-width: 800px;
        margin: 0 auto;
        background-color: white;
        padding: 20px;
        border-radius: 5px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
      }

      h1 {
        color: #3366cc;
        border-bottom: 1px solid #eee;
        padding-bottom: 10px;
      }

      .info-box {
        background-color: #f9f9f9;
        border-left: 4px solid #3366cc;
        padding: 15px;
        margin: 20px 0;
      }

      .nav {
        margin: 20px 0;
      }

      .nav a {
        display: inline-block;
        padding: 8px 15px;
        background-color: #3366cc;
        color: white;
        text-decoration: none;
        border-radius: 3px;
        margin-right: 10px;
      }

      .nav a:hover {
        background-color: #254e9c;
      }
    </style>
  </head>

  <body>
    <div class="container">
      <h1>Tomcat Java 7 샘플 애플리케이션</h1>

      <div class="nav">
        <a href="hello">서블릿 테스트</a>
      </div>

      <div class="info-box">
        <h3>서버 정보:</h3>
        <p>Java 버전: <%= System.getProperty("java.version") %>
        </p>
        <p>Tomcat 버전: <%= application.getServerInfo() %>
        </p>
        <p>서블릿 사양 버전: <%= application.getMajorVersion() %>.<%= application.getMinorVersion() %>
        </p>
        <p>JSP 버전: <%= JspFactory.getDefaultFactory().getEngineInfo().getSpecificationVersion() %>
        </p>
        <p>현재 시간: <%= new java.util.Date() %>
        </p>
        <p>호스트명: <%= java.net.InetAddress.getLocalHost().getHostName() %>
        </p>
      </div>

      <p>이 샘플 애플리케이션은 Java 7과 Tomcat을 사용하여 만들어졌으며, AWS EC2 인스턴스에서 실행됩니다.</p>
      <p>Auto Scaling Group과 Application Load Balancer를 통해 고가용성을 제공합니다.</p>
    </div>
  </body>

  </html>