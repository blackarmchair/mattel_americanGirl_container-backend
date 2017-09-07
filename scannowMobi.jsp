<%@ page language="java" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

  <sql:transaction dataSource="srvbase">

    <%-- Check if already exists --%>
    <sql:query var="exists">
      SELECT * FROM `nep`.`client_downloads` WHERE `app_title` = ?;
      <sql:param value="American Girl Central" />
    </sql:query>
    <c:set var="exists" value="${exists.rowCount}"></c:set>

    <%-- If account does not already exist --%>
    <c:if test="${exists eq 0}">
      <sql:update var="update">
        INSERT INTO
          `nep`.`client_downloads`
        (
          `app_title`,
          `app_image`,
          `app_image_width`,
          `app_image_height`,
          `fb_text`,
          `fb_appId`,
          `ios_url`,
          `android_url`,
          `textcolor`,
          `background`
        )
        VALUES (?,?,?,?,?,?,?,?,?,?);
        <sql:param value="American Girl Central"></sql:param>
        <sql:param value="https://s3.amazonaws.com/bluesoho-production/mattel/ag/companion/img/app-icon.png"></sql:param>
        <sql:param value="324"></sql:param>
        <sql:param value="324"></sql:param>
        <sql:param value="Check out the AG Central app - scannow.mobi/agcentral"></sql:param>
        <sql:param value="125521068098920"></sql:param>
        <sql:param value="https://itunes.apple.com/us/"></sql:param>
        <sql:param value="https://play.google.com/store/apps/"></sql:param>
        <sql:param value="#000000"></sql:param>
        <sql:param value="#fbfbfb"></sql:param>
      </sql:update>

      <sql:query var="lastInsertId">SELECT LAST_INSERT_ID() as lastId</sql:query>
      <c:set var="appGateUrl" value="http://m.bsh.io/nep/microsite/nellymos/util/companio/appGate.jsp?app_id="></c:set>
      <c:set var="lastId" value="${ lastInsertId.rows[0].lastId }"></c:set>

      <sql:update var="update">
        INSERT INTO `nep`.`scannow_mobi` (`name`, `url`) VALUES (?,?);
        <sql:param value="agcentral"></sql:param>
        <sql:param value="${appGateUrl}${lastId}"></sql:param>
      </sql:update>

    </c:if>

    <%-- If account already exists --%>
    <c:if test="${exists gt 0}">
      <sql:update var="update">
        UPDATE
          `nep`.`client_downloads`
        SET
          `app_image` = ?,
          `app_image_width` = ?,
          `app_image_height` = ?,
          `fb_text` = ?,
          `fb_appId` = ?,
          `ios_url` = ?,
          `android_url` = ?,
          `textcolor` = ?,
          `background` = ?
        WHERE
          `app_title` = ?;
        <sql:param value="https://s3.amazonaws.com/bluesoho-production/mattel/ag/companion/img/app-icon.png"></sql:param>
        <sql:param value="324"></sql:param>
        <sql:param value="324"></sql:param>
        <sql:param value="Check out the AG Central app - scannow.mobi/agcentral"></sql:param>
        <sql:param value="125521068098920"></sql:param>
        <sql:param value="https://itunes.apple.com/us/"></sql:param>
        <sql:param value="https://play.google.com/store/apps/"></sql:param>
        <sql:param value="#000000"></sql:param>
        <sql:param value="#fbfbfb"></sql:param>

        <sql:param value="American Girl Central"></sql:param>
      </sql:update>
    </c:if>

  </sql:transaction>
