<%@ page
  language="java"
  contentType="text/html; charset=UTF-8"
  pageEncoding="UTF-8"
  trimDirectiveWhitespaces="true"
%>
<%
  String url = request.getRequestURL().toString();
  url = url.substring(0, url.length() - request.getRequestURI().length()) + request.getContextPath() + "/";
  pageContext.setAttribute("baseURL", url);
%>
