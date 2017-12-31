<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math mdc map"
    xmlns:mdc="http://mdc" version="3.0">
    <!-- 
try out streaming with xslt3's source-document ???
  -->

    <!-- start with archivesspace-top-container-export-TEST.xml as
       source document -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:include href="container-functions.xsl"/>
    <xsl:include href="repository-name-mappings.xsl"/>

    <xsl:param name="test-or-all" select="'all'"/>
    <xsl:variable name="all-voyager-boxes-filename">
        <xsl:choose>
            <xsl:when test="$test-or-all eq 'test'">
                <xsl:value-of select="'voyager-item-record-export-all-TEST.xml'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'voyager-item-record-export-all.xml'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="all-voyager-boxes" select="document($all-voyager-boxes-filename)"/>

    <xsl:key name="voyager-bib-id-match" match="row" use="BIB_ID"/>

    <xsl:template match="root">
        <xsl:for-each-group select="row" group-by="name[2]">
            <!-- also have to remove slashes, since Medical had a slash in its repository name in ASpace, 
                resulting in another directory being created, e.g. medical/libraryname-report.xml
                instead of medical-report.xml
            hence the translate function added most recently.-->
            <xsl:variable name="repo" select="if (map:contains($repo-map, current-grouping-key()))
                then $repo-map(current-grouping-key())
                else translate(replace(current-grouping-key(), '\s', ''), '/\', '')"/>

            <!--output one report per repository -->
            <xsl:result-document href="reports/{$repo}-report-TWO.xml">

                <xsl:copy>
                    <xsl:for-each-group select="current-group()" group-by="string_2">
                        <xsl:for-each select="current-group()">
                            <xsl:sort select="mdc:container-to-number(indicator)"/>
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </xsl:copy>

            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="row">
        <xsl:variable name="current-box" select="mdc:normalize-indicator(indicator)"/>
        <xsl:variable name="bib-id" select="string_2"/>
        <xsl:variable name="voyager-match">
            <xsl:for-each select="$all-voyager-boxes">
                <xsl:copy-of
                    select="key('voyager-bib-id-match', $bib-id)[mdc:normalize-indicator(ITEM_ENUM) eq $current-box]"
                />
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <top-container-URI>
                <xsl:apply-templates select="tc_uri_fragment"/>
            </top-container-URI>
            <top-container-type>
                <xsl:apply-templates select="value"/>
            </top-container-type>
            <container-profile>
                <xsl:apply-templates select="name[1]"/>
            </container-profile>
            <top-container-indicator>
                <xsl:value-of select="indicator"/>
            </top-container-indicator>
            <collection-title>
                <xsl:value-of select="title[2]"/>
            </collection-title>
            <!-- i'm using string-join(distinct-values)), and later [last()], with the voyager-matches since my SQL
                result set will include two rows for every stat cat code.
                i would've kept that to one row per result, but i don't know of a way 
                to do that in Oracle 10 without being able to write new functions to the database
                and i only have read access-->
            <bib-id>
                <xsl:value-of select="string-join(distinct-values($voyager-match/row/BIB_ID), '; ')"/>
            </bib-id>
            <mfhd-id>
                <xsl:value-of select="string-join(distinct-values($voyager-match/row/MFHD_ID), '; ')"/>
            </mfhd-id>
            <item-id>
                <xsl:value-of select="string-join(distinct-values($voyager-match/row/ITEM_ID), '; ')"/>
            </item-id>
            <repository>
                <xsl:value-of select="name[2]"/>
            </repository>
            <voyager-item-enum>
                <xsl:value-of
                    select="
                        if ($voyager-match/normalize-space()) then
                            string-join(distinct-values($voyager-match/row/ITEM_ENUM), '; ')
                        else
                            '***NO-MATCH***'"
                />
            </voyager-item-enum>
            <voyager-barcode>
                <xsl:value-of select="string-join(distinct-values($voyager-match/row/ITEM_BARCODE), '; ')"/>
            </voyager-barcode>
            <aspace-barcode>
                <xsl:value-of select="barcode"/>
            </aspace-barcode>
            <voyager-location>
                <xsl:value-of select="$voyager-match/row[last()]/LOCATION_NAME"/>
            </voyager-location>
            <aspace-location>
                <xsl:value-of select="title[1]"/>
            </aspace-location>
            <aspace-location-URI-to-post>
                <xsl:value-of
                    select="
                        if ($voyager-match/row[last()]/LOCATION_NAME/starts-with(normalize-space(), 'lsf'))
                        then
                            '/locations/9'
                        else
                            ''"
                />
            </aspace-location-URI-to-post>
            <!-- in the case of 2 or more stat cats, the results will be split by semi-colons-->
            <voyager-stat-cat>
                <xsl:value-of select="string-join($voyager-match/row/ITEM_STAT_ID, '; ')"/>
            </voyager-stat-cat>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
