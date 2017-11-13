<%@ page language="java" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

  <c:set var="name" value="American Girl"></c:set>
  <c:set var="nameShort" value="A G"></c:set>
  <c:set var="description" value="American Girl - Inspiring girls with dolls, books, games, and more"></c:set>
  <c:set var="url" value="ag"></c:set> <%-- (e.g. scannow.mobi/xxx) --%>
  <c:set var="image" value="https://s3.amazonaws.com/bluesoho-production/mattel/ag/companion/img/app-icon.png"></c:set>
  <c:set var="imageSize" value="324"></c:set>
  <c:set var="facebookID" value="125521068098920"></c:set>
  <c:set var="facebookText" value="Check out the AG Central app - scannow.mobi/${appUrl}"></c:set>
  <c:set var="playStoreLink" value="https://play.google.com/store/apps/details?id=com.bluesoho.android.americangirl"></c:set>
  <c:set var="appStoreLink" value="https://itunes.apple.com/us/app/american-girl-catalogue/id482067432?mt=8"></c:set>
  <c:set var="textColor" value="#000000"></c:set>
  <c:set var="bgColor" value="#fbfbfb"></c:set>


  <sql:transaction dataSource="srvbase">

    <%-- Check if already exists --%>
    <sql:query var="exists">
      SELECT * FROM `nep`.`client_downloads` WHERE `app_title` = ?;
      <sql:param value="${name}" />
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
        <sql:param value="${name}"></sql:param>
        <sql:param value="${image}"></sql:param>
        <sql:param value="${imageSize}"></sql:param>
        <sql:param value="${imageSize}"></sql:param>
        <sql:param value="${facebookText}"></sql:param>
        <sql:param value="${facebookID}"></sql:param>
        <sql:param value="${appStoreLink}"></sql:param>
        <sql:param value="${playStoreLink}"></sql:param>
        <sql:param value="${textColor}"></sql:param>
        <sql:param value="${bgColor}"></sql:param>
      </sql:update>

      <sql:query var="lastInsertId">SELECT LAST_INSERT_ID() as lastId</sql:query>
      <c:set var="appGateUrl" value="http://m.bsh.io/nep/microsite/nellymos/util/companio/appGate.jsp?app_id="></c:set>
      <c:set var="lastId" value="${ lastInsertId.rows[0].lastId }"></c:set>

      <sql:update var="update">
        INSERT INTO `nep`.`scannow_mobi` (`name`, `url`) VALUES (?,?);
        <sql:param value="${url}"></sql:param>
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
        <sql:param value="${image}"></sql:param>
        <sql:param value="${imageSize}"></sql:param>
        <sql:param value="${imageSize}"></sql:param>
        <sql:param value="${facebookText}"></sql:param>
        <sql:param value="${facebookID}"></sql:param>
        <sql:param value="${appStoreLink}"></sql:param>
        <sql:param value="${playStoreLink}"></sql:param>
        <sql:param value="${textColor}"></sql:param>
        <sql:param value="${bgColor}"></sql:param>
        <sql:param value="${name}"></sql:param>
      </sql:update>
    </c:if>

  </sql:transaction>
