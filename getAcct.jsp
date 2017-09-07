<sql:transaction dataSource="srvbase">
  <sql:query var="query">
    SELECT `account_id` FROM `nep`.`ccms_accounts` WHERE `account_name` = ?;
    <sql:param value="${accountName}" />
  </sql:query>
  <c:set var="accnt" value="${query.rows[0].account_id}"></c:set>
</sql:transaction>
