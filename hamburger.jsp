<%@ page language="java" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<c:set var="accountName" value="AmericanGirl" />

<%@ include file="account.jsp" %>
<%@ include file="getAcct.jsp" %>
<%@ include file="getURL.jsp" %>

<%--  HAMBURGER MENU --%>
<sql:transaction dataSource="srvbase">

	<sql:update var="ctable">
		INSERT INTO `ccms_templates` (`template_name`,`account_id`,`template_url`)
		VALUES ('Hamburger Menu', ${accnt}, NULL)
	</sql:update>
	<sql:query var="q" sql="SELECT LAST_INSERT_ID() AS id" />


		<sql:update var="ctable">
			INSERT INTO `ccms_blocks` (`parent_id`,`type`,`key`,`min`,`max`, `editor_question`, `editor_instance_name`, `view_url`)
			VALUES (-${q.rows[0].id}, 'composite', 'hamburgers', 1, 15, 'Select a Menu to edit', 'Menu', null)
		</sql:update>
		<sql:query var="q" sql="SELECT LAST_INSERT_ID() AS id" />

			<%-- multiple arrays  --%>
			<sql:update var="ctable">
				INSERT INTO `ccms_blocks` (`parent_id`,`type`,`key`,`min`,`max`, `editor_question`, `editor_instance_name`, `view_url`)
				VALUES (${q.rows[0].id}, 'composite', 'hamburger', 1, 15, 'Select a Menu Item', 'Menu Item', null)
			</sql:update>
			<sql:query var="q" sql="SELECT LAST_INSERT_ID() AS id" />

				<sql:update var="ctable">
					INSERT INTO `ccms_blocks` (`parent_id`,`type`,`key`,`min`,`max`, `editor_question`, `editor_required`, `rich`)
					VALUES (${q.rows[0].id}, 'label', 'title', 1, 1, 'Title', true, false)
				</sql:update>
				<sql:update var="ctable">
					INSERT INTO `ccms_blocks` (`parent_id`,`type`,`key`,`min`,`max`, `editor_question`, `editor_required`, `rich`)
					VALUES (${q.rows[0].id}, 'paragraph', 'link', 1, 1, 'Link', true, false)
				</sql:update>

</sql:transaction>
