<%@ page language="java" pageEncoding="UTF-8" %>
<%@ page import="
	java.sql.*,
	javax.sql.*,
	java.util.HashMap,
	java.util.ArrayList,
	javax.naming.InitialContext,
	javax.naming.Context,
	org.json.*"
%>

<%!
class ContentMap {
	private DataSource 			  dataSource;
	private PreparedStatement preparedStatement;
	private Connection 			  connection;
	private String sortColumn	 	= "cmap_id";
	private String sortOrder 		= "ASC";
  private String today        = "";
  private String url          = "";
	private boolean skipArrays  = false;
	public void setSortColumn(String column) {
		sortColumn = column;
	}
	public void setSortASC() {
		sortOrder = "ASC";
	}
	public void setSortDESC() {
		sortOrder = "DESC";
	}
	public void setArraySkip(boolean skip) {
		skipArrays = skip;
	}
  public void setToday(String current) {
    today = current;
  }
  public String getToday() {
    return today;
  }
	public HashMap fetchTemplate(int account, String templateName) throws Exception {
		HashMap map = null;
		try {
			// init db connection
			InitialContext context = new InitialContext();
			dataSource = (DataSource) context.lookup("java:comp/env/srvbase");
			connection = dataSource.getConnection();
      String query = "SELECT * FROM ccms_content T1";
      query       += " LEFT JOIN ccms_content_map T2 ON T2.child_cid = T1.content_id";
      query       += " WHERE parent_cid = ";
      query       += " (SELECT - template_id FROM ccms_templates WHERE template_name = ? AND account_id = ? LIMIT 1);";
			preparedStatement = connection.prepareStatement(query);
			preparedStatement.setString(1, templateName);
			preparedStatement.setInt(2, account);
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			// figure out top level cid by using template_id
			//int tid = rs.getInt("template_id");
			//preparedStatement = connection.prepareStatement("SELECT * FROM ccms_content T1 LEFT JOIN ccms_content_map T2 ON T2.child_cid=T1.content_id WHERE parent_cid=?");
			//preparedStatement.setInt(1, -tid);
			//rs = preparedStatement.executeQuery();
			//rs.next();
			int cid = rs.getInt("content_id");
			// run recursive methods and get a HashMap with content
			map = getMapById(cid);
		} catch (Exception e) {
			map = new HashMap<String, Object>();
			map.put("error", "fetchContent");
			map.put("exception", e);
		} finally {
			// close db connection
			if (connection != null)  { connection.close(); }
			if (preparedStatement != null) { preparedStatement.close(); }
		}
		return map;
	}
	public HashMap fetchContent(int cid) throws Exception {
		HashMap map = null;
		try {
			// init db connection
			InitialContext context = new InitialContext();
			dataSource = (DataSource) context.lookup("java:comp/env/srvbase");
			connection = dataSource.getConnection();
			// run recursive methods and get a HashMap with content
			map = getMapById(cid);
			//return getMapById(cid);
		} catch (Exception e) {
			map = new HashMap<String, Object>();
			map.put("error", "fetchContent");
			map.put("exception", e);
			//return map;
		} finally {
			// close db connection
			if (connection != null)  { connection.close(); }
			if (preparedStatement != null) { preparedStatement.close(); }
		}
		return map;
	}
	private HashMap getMapById(int cid) throws Exception {
		HashMap map = new HashMap<String, Object>();
		preparedStatement = connection.prepareStatement("SELECT * FROM ccms_content T1 LEFT JOIN ccms_content_map T2 ON T2.child_cid=T1.content_id LEFT JOIN ccms_blocks T3 ON T1.block_id=T3.block_id LEFT JOIN ccms_content_metadata T4 ON T4.parent_content_id=T1.content_id WHERE T1.content_id=?");
		preparedStatement.setInt(1, cid);
		ResultSet rs = preparedStatement.executeQuery();
		rs.next();
		//return getValueFromRow(rs);
		if (rs.getBoolean("isArray")) {
			map.put(rs.getString("key"), getValueFromRow(rs));
			return map;
		} else {
			return (HashMap)getValueFromRow(rs);
		}
	}
	private Object getValueFromRow(ResultSet row) throws Exception {
		if (row.getBoolean("isArray")) {
			ArrayList list = new ArrayList();
			if (skipArrays == true) {
				return list;
			}
      if ( getToday() == "") {
        preparedStatement = connection.prepareStatement("CALL cms_dbmethod(?, ?);");
        preparedStatement.setInt(1, row.getInt("content_id"));
        preparedStatement.setString(2, sortColumn);
      } else {
        preparedStatement = connection.prepareStatement("CALL cms_dbmethod_date(?, ?, ?);");
        preparedStatement.setInt(1, row.getInt("content_id"));
        preparedStatement.setString(2, today);
        preparedStatement.setString(3, sortColumn);
      }
			ResultSet rs = preparedStatement.executeQuery();
			while (rs.next()) {
        // Here we add some logic for special snowflake cases on default menus
        // and carousels. We need to make sure that these top-level templates do
        // not overwrite real content when time traveling.
        if (
          list.size() > 0
          &&
          rs.getString("template_name").compareTo("Exchange Extra App : Default Home Carousel") != 0
          &&
          rs.getString("template_name").compareTo("Default Carousel") != 0
          &&
          rs.getString("template_name").compareTo("Exchange Extra App : Default Stacked Menu") != 0
        )
        {
          list.add(getValueFromRow(rs));
        }
        if ( list.size() == 0 ) {
          list.add(getValueFromRow(rs));
        }
      }
			rs.close();
			return list;
		} else if (row.getString("type").equals("composite")) {
			// get all children as map
      preparedStatement = connection.prepareStatement("SELECT * FROM ccms_content T1 LEFT JOIN ccms_content_map T2 ON T2.child_cid=T1.content_id LEFT JOIN ccms_blocks T3 ON T1.block_id=T3.block_id LEFT JOIN ccms_content_metadata T4 ON T4.parent_content_id=T1.content_id WHERE parent_cid=?;");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			HashMap map = new HashMap<String, Object>();
			map.put("content_id", row.getInt("content_id"));
			map.put("date_publish", row.getDate("date_publish").toString());
			map.put("date_expire", row.getDate("date_expire").toString());
			try {
        map.put("sort_order", row.getInt("sort_order"));
        map.put("never_expire", row.getBoolean("never_expire"));
				map.put("template_name", row.getString("template_name"));
				map.put("ua_number", row.getString("ua_number"));
				map.put("camp_alias", row.getString("camp_alias"));
				map.put("css", row.getString("css"));
			} catch (Exception e) {
			}
			while (rs.next()) {
				map.put(rs.getString("key"), getValueFromRow(rs));
			}
			rs.close();
			return map;
		} else if (row.getString("type").equals("label") || row.getString("type").equals("choice")) {
			preparedStatement = connection.prepareStatement("SELECT text FROM ccms_primitive_labels WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			String s = rs.getString("text");
			rs.close();
			return s;
		} else if (row.getString("type").equals("paragraph")) {
			preparedStatement = connection.prepareStatement("SELECT text FROM ccms_primitive_paragraphs WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			String s = rs.getString("text");
			rs.close();
			return s;
		} else if (row.getString("type").equals("text")) {
			preparedStatement = connection.prepareStatement("SELECT text FROM ccms_primitive_texts WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			String s = rs.getString("text");
			rs.close();
			return s;
		} else if (row.getString("type").equals("button")) {
			preparedStatement = connection.prepareStatement("SELECT caption, url FROM ccms_primitive_buttons WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			HashMap map = new HashMap<String, Object>();
			map.put("caption", rs.getString("caption"));
			map.put("url", rs.getString("url"));
			rs.close();
			return map;
		} else if (row.getString("type").equals("image")) {
			preparedStatement = connection.prepareStatement("SELECT * FROM ccms_primitive_images WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			String s = rs.getString("image_url");
			rs.close();
			return s;
		} else if (row.getString("type").equals("event")) {
			preparedStatement = connection.prepareStatement("SELECT begin_date, end_date, begin_time, end_time, timezone FROM ccms_primitive_events WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			HashMap map = new HashMap<String, Object>();
			map.put("begin_date", rs.getDate("begin_date"));
			map.put("end_date", rs.getDate("end_date"));
			map.put("begin_time", rs.getTime("begin_time"));
			map.put("end_time", rs.getTime("end_time"));
			map.put("time_zone", rs.getString("timezone"));
			rs.close();
			return map;
		} else if (row.getString("type").equals("location")) {
			preparedStatement = connection.prepareStatement("SELECT address, city, state, zip, lat, lng FROM ccms_primitive_locations WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			HashMap map = new HashMap<String, Object>();
			map.put("address", rs.getString("address"));
			map.put("city", rs.getString("city"));
			map.put("state", rs.getString("state"));
			map.put("zip", rs.getString("zip"));
			map.put("lat", rs.getDouble("lat"));
			map.put("lng", rs.getDouble("lng"));
			rs.close();
			return map;
		} else if (row.getString("type").equals("instagram")) {
			preparedStatement = connection.prepareStatement("SELECT `key`, `value` FROM ccms_primitive_keyvals WHERE parent_id = ?");
			preparedStatement.setInt(1, row.getInt("content_id"));
			ResultSet rs = preparedStatement.executeQuery();
			rs.next();
			HashMap map = new HashMap<String, Object>();
			map.put("key", rs.getString("key"));
			map.put("value", rs.getString("value"));
			rs.close();
			return map;
		}
		return null;
	}
}
%>
