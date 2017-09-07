<%@ include file="dbmethod.jsp" %>
<% pageContext.setAttribute("newLineChar", "\n");%>
<% pageContext.setAttribute("lineFeedChar", "\r"); %>
<%
  if (request.getParameter("cid") != null && request.getParameter("cid").toString() != "") {
    int cid = 0;
    cid = Integer.parseInt(request.getParameter("cid").toString());
    if (cid != 0) {
      ContentMap cMap = new ContentMap();
      cMap.setSortColumn("sort_order");
      HashMap map = cMap.fetchContent(cid);
      pageContext.setAttribute("content", map);
    }
  }
%>
