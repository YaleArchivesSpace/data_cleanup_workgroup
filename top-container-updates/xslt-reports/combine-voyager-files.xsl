<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="xs ead xlink" version="3.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>


    <xsl:variable name="documents" select="collection('voyager-list-to-combine.xml')"/>

    <xsl:template match="/">
        <root>
            <xsl:for-each select="$documents">
                <xsl:apply-templates select="root/row"/>
            </xsl:for-each>
        </root>
    </xsl:template>


    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>





</xsl:stylesheet>
