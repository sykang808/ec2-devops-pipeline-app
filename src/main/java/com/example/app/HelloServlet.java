package com.example.app;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 간단한 예제 서블릿
 */
public class HelloServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * 서블릿 GET 요청 처리
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<meta charset=\"UTF-8\">");
            out.println("<title>Hello Servlet</title>");
            out.println("<style>");
            out.println("body { font-family: 'Malgun Gothic', Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }");
            out.println(".container { max-width: 800px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }");
            out.println("h1 { color: #3366cc; }");
            out.println(".info { background-color: #f0f8ff; padding: 15px; border-radius: 5px; }");
            out.println(".nav { margin: 20px 0; }");
            out.println(".nav a { display: inline-block; padding: 8px 15px; background-color: #3366cc; color: white; text-decoration: none; border-radius: 3px; }");
            out.println("</style>");
            out.println("</head>");
            out.println("<body>");
            out.println("<div class=\"container\">");
            out.println("<h1>안녕하세요! Java 7 서블릿입니다.</h1>");
            
            out.println("<div class=\"nav\">");
            out.println("<a href=\"index.jsp\">홈으로 돌아가기</a>");
            out.println("</div>");
            
            out.println("<div class=\"info\">");
            out.println("<h3>요청 정보:</h3>");
            out.println("<p>클라이언트 IP: " + request.getRemoteAddr() + "</p>");
            out.println("<p>요청 방식: " + request.getMethod() + "</p>");
            out.println("<p>서버 이름: " + request.getServerName() + "</p>");
            out.println("<p>서버 포트: " + request.getServerPort() + "</p>");
            out.println("<p>사용자 에이전트: " + request.getHeader("User-Agent") + "</p>");
            out.println("<p>현재 시간: " + new java.util.Date() + "</p>");
            out.println("</div>");
            
            out.println("<p>이 서블릿은 Tomcat 및 Java 7 환경에서 실행 중입니다.</p>");
            out.println("</div>");
            out.println("</body>");
            out.println("</html>");
        } finally {
            out.close();
        }
    }
} 