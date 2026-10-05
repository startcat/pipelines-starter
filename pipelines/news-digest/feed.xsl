<?xml version="1.0" encoding="UTF-8"?>
<!--
  Turns an RSS 2.0, RSS 1.0 (RDF) or Atom feed (YouTube's included) into one
  line per item, with tab-separated fields:
    feed title, item title, link, date, summary
  Namespaces are matched with local-name() so any prefix works. Tabs and line
  breaks inside values become spaces, so a line is always one record.
  Used by the fetch step of pipeline.yaml (xsltproc, bundled with macOS).
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:variable name="ws" select="'&#9;&#10;&#13;'"/>
  <xsl:variable name="sp" select="'   '"/>

  <xsl:template name="clean">
    <xsl:param name="v"/>
    <xsl:param name="max" select="300"/>
    <xsl:value-of select="normalize-space(translate(substring($v, 1, $max), $ws, $sp))"/>
  </xsl:template>

  <xsl:template match="/">
    <xsl:variable name="feed"
      select="(/*[local-name()='feed']/*[local-name()='title']
              | /*/*[local-name()='channel']/*[local-name()='title'])[1]"/>
    <xsl:for-each select="//*[local-name()='item' or local-name()='entry']">
      <xsl:variable name="link">
        <xsl:choose>
          <xsl:when test="*[local-name()='link'][@rel='alternate']/@href">
            <xsl:value-of select="*[local-name()='link'][@rel='alternate'][1]/@href"/>
          </xsl:when>
          <xsl:when test="*[local-name()='link'][not(@rel)]/@href">
            <xsl:value-of select="*[local-name()='link'][not(@rel)][1]/@href"/>
          </xsl:when>
          <xsl:when test="normalize-space(*[local-name()='link'][1])">
            <xsl:value-of select="*[local-name()='link'][1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="*[local-name()='guid'][not(@isPermaLink='false')]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- Publication date (Atom published, RSS pubDate, RSS 1.0 dc:date), else Atom updated. -->
      <xsl:variable name="date">
        <xsl:choose>
          <xsl:when test="*[local-name()='published' or local-name()='pubDate' or local-name()='date'][normalize-space()]">
            <xsl:value-of select="(*[local-name()='published' or local-name()='pubDate' or local-name()='date'][normalize-space()])[1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="*[local-name()='updated'][1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- First non-empty summary: Atom summary/content, YouTube media:group/media:description, RSS description. -->
      <xsl:variable name="summary"
        select="(*[local-name()='summary' or local-name()='description' or local-name()='content'][normalize-space()]
                 | *[local-name()='group']/*[local-name()='description'][normalize-space()])[1]"/>
      <xsl:call-template name="clean"><xsl:with-param name="v" select="$feed"/></xsl:call-template>
      <xsl:text>&#9;</xsl:text>
      <xsl:call-template name="clean"><xsl:with-param name="v" select="*[local-name()='title']"/></xsl:call-template>
      <xsl:text>&#9;</xsl:text>
      <xsl:call-template name="clean"><xsl:with-param name="v" select="$link"/><xsl:with-param name="max" select="2000"/></xsl:call-template>
      <xsl:text>&#9;</xsl:text>
      <xsl:call-template name="clean"><xsl:with-param name="v" select="$date"/></xsl:call-template>
      <xsl:text>&#9;</xsl:text>
      <xsl:call-template name="clean"><xsl:with-param name="v" select="$summary"/><xsl:with-param name="max" select="3000"/></xsl:call-template>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
