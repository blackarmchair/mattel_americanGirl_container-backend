<%@ page language="java"  contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x"%>
<%@ include file="dbmethod.jsp" %>
<%@ page import="org.json.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="java.text.Normalizer" %>
<%@ page import="java.net.URLDecoder" %>

<% // DISABLE CACHING SO THE CAROUSEL SORT ORDER UPDATES !!!
response.setHeader( "Pragma", "no-cache" );
response.setHeader( "Cache-Control", "no-cache" );
response.setDateHeader( "Expires", 0 );
response.addHeader( "Cache-Control", "no-cache" );
response.addHeader("Cache-Control", "no-store");
response.addHeader("Cache-Control", "max-age=0");
%>

<%
ContentMap cMap = new ContentMap();
cMap.setSortColumn("sort_first");

HashMap map   = cMap.fetchTemplate(76, "Tiles");
ArrayList arr = (ArrayList)map.get("tileset");
int ind       = 0;

for (int i = 0; i < arr.size(); i++) {
  String date_publish = ((HashMap)arr.get(i)).get("date_publish").toString();
	try {
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd");;
    Date date     = (Date)df.parse(date_publish);
    Date today    = new Date();

    if (!today.before(date)) { ind = i; break; }
  }
  catch (Exception e) {}
}

JSONObject json = new JSONObject((HashMap)arr.get(ind));
JSONArray jarr;
String tiles    = "[]";

if (json.has("tiles")) {
	jarr = json.getJSONArray("tiles");
	tiles = jarr.toString(2).trim();
}

map = cMap.fetchTemplate(76, "Hamburger Menu");
arr = (ArrayList)map.get("hamburgers");

for (int i=0; i < arr.size(); i++) {
	String date_publish = ((HashMap)arr.get(i)).get("date_publish").toString();
	try {
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd");;
    Date date     = (Date)df.parse(date_publish);
 	  Date today    = new Date();
    if (!today.before(date)) { ind = i; break; }
  }
  catch (Exception e) {}
}
json             = new JSONObject((HashMap)arr.get(ind));
String hamburger = "[]";
if (json.has("hamburger")) {
	jarr = json.getJSONArray("hamburger");
	hamburger = jarr.toString(2).trim();
}

String jsonres = "{ \"tiles\": " + tiles + ", \"hamburger\": " + hamburger + " }";
response.getWriter().write(jsonres);

%>
