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


    <!--change this to two for-each-groups,
        in order to output separte files for each repository.-->
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
            <xsl:result-document href="reports/{$repo}-report-ONE.xml">
                <root>
                    <xsl:for-each-group select="current-group()" group-by="string_2">
                        <xsl:variable name="bib-id" select="current-grouping-key()"/>
                        <xsl:variable name="aspace-array" select="current-group()"/>
                        <xsl:variable name="voyager-array">
                            <xsl:for-each select="$all-voyager-boxes">
                                <xsl:sequence select="key('voyager-bib-id-match', $bib-id)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="current-aspace-count"
                            select="count($aspace-array/indicator)"/>
                        <!-- output from Voyager will have one row per Stat Code, rather than always one row per item record
                        i would've used group_concat() in MySQL, but it's easy enough to account for those extra rows post export-->
                        <xsl:variable name="current-voyager-count"
                            select="count(distinct-values($voyager-array/row/ITEM_ENUM))"/>
                        <xsl:variable name="aspace-boxes-normalized"
                            select="$aspace-array/mdc:normalize-box-indicators(indicator)"/>
                        <xsl:variable name="voyager-boxes-normalized"
                            select="$voyager-array/row/mdc:normalize-box-indicators(ITEM_ENUM)"/>

                        <xsl:for-each select=".">
                            <xsl:sort select="mdc:container-to-number(indicator)"/>
                            <row>
                                <collection-title>
                                    <xsl:value-of select="title[2]"/>
                                </collection-title>
                                <bib_id>
                                    <xsl:value-of select="$bib-id"/>
                                </bib_id>
                                <repository>
                                    <xsl:value-of select="name[2]"/>
                                </repository>
                                <aspace_count>
                                    <xsl:value-of select="$current-aspace-count"/>
                                </aspace_count>
                                <voyager_count>
                                    <xsl:value-of select="$current-voyager-count"/>
                                </voyager_count>
                                <difference>
                                    <xsl:value-of
                                        select="$current-aspace-count - $current-voyager-count"/>
                                </difference>
                                <!-- adding this as a blank column so that staff can review the results and indicate whether 
                                    the discrepency is OKAY as is, or has since been FIXED (which means I can re-run the report for that collection)
                                    -->
                                <OKAY-or-FIXED/>
                                <not-in-voyager>
                                    <xsl:sequence
                                        select="distinct-values($aspace-boxes-normalized[not(. = $voyager-boxes-normalized)])"
                                    />
                                </not-in-voyager>
                                <not-in-aspace>
                                    <xsl:sequence
                                        select="distinct-values($voyager-boxes-normalized[not(. = $aspace-boxes-normalized)])"
                                    />
                                </not-in-aspace>
                                <matches>
                                    <xsl:sequence
                                        select="distinct-values($aspace-boxes-normalized[. = $voyager-boxes-normalized])"
                                    />
                                </matches>
                            </row>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </root>
            </xsl:result-document>
        </xsl:for-each-group>

    </xsl:template>

</xsl:stylesheet>
