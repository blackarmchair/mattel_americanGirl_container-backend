<%@ page language="java" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<sql:transaction dataSource="srvbase">

  <%-- Determine if account already exists --%>
  <sql:query var="exists">
    SELECT
      `account_id`
    FROM
      `nep`.`ccms_accounts`
    WHERE
      `account_name` = ?
    LIMIT 1;
    <sql:param value="${accountName}" />
  </sql:query>

  <c:choose>
    <c:when test="${exists.rowCount eq 0}">

      <%-- Insert new account --%>
      <sql:update var="insertAccount">
        INSERT INTO
          `nep`.`ccms_accounts` (`account_name`, `admin`)
        VALUES
          (?, 0);
        <sql:param value="${accountName}" />
      </sql:update>

      <%-- Capture the newly-created account's ID number --%>
      <sql:query var="lastId" >SELECT LAST_INSERT_ID() as lastId</sql:query >
      <c:set var="lastId" value="${lastId.rows[0].lastId}"/>
      <c:set var="accnt" value="${lastId}"/>

      <%-- Insert a new user for the newly-created account --%>
      <sql:update var="insertUser">
        INSERT INTO
          `nep`.`ccms_users` (`parent_account_id`, `user_name`, `user_password`)
        VALUES
          (?, ?, 'ran_FIGHTING_zero_15');
        <sql:param value="${lastId}"/>
        <sql:param value="${accountName}" />
      </sql:update>

    </c:when>
    <c:otherwise>
      <c:set var="accnt" value="${exists.rows[0].account_id}"/>
    </c:otherwise>
  </c:choose>

</sql:transaction>
