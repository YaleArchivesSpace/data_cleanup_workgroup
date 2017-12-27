<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:mdc="http://mdc"
    exclude-result-prefixes="xs math" version="3.0">
    
    <!--update this awful list as needed.  i can't just remove all non-numerica values, though, since 10b is difference than 10c, or 10 d and 10(e), etc. -->
    <xsl:variable name="container-stop-word-list" select="'(assumedbox|restricted|fragile|cold|storage|reel|bpx|record|album|folio|on-site|film|container|portfolio|port|volume|vol.|vol|bsd|broadside|roll|oversize|box|art|,|;|folder|\(|\))'"/>

    <!-- add sort container function -->
    
    <xsl:function name="mdc:normalize-box-indicators" as="element()">
        <xsl:param name="boxes-per-collection" as="element()"/>
        <xsl:for-each select="$boxes-per-collection">
            <box>
                <xsl:value-of select="mdc:normalize-indicator(.)"/>
            </box>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="mdc:normalize-indicator" as="xs:string">
        <xsl:param name="current-box" as="xs:string"/>
        <xsl:value-of
            select="
            (: adding this first part in case we have an indicator like 'bsd' only, we don't want the end result for matching to be '', instead of 'bsd'. :)
               if (matches(normalize-space(lower-case($current-box)), '^\D$') and not(matches(normalize-space($current-box), '\d')))
               then normalize-space(lower-case($current-box))
               else
            (:
            hack for MSSA boxes in accessions (still need to review and see if this 
            works for all of their wacky box numbers in Voyager or not) 
            :)
                if (contains(normalize-space(lower-case($current-box)), 'acc'))
                then
                    replace(replace(substring-before(lower-case($current-box), 'acc'), $container-stop-word-list, ''), '\s', '')
                else
                if (contains(normalize-space(lower-case($current-box)), 'series'))
                then
                replace(replace(substring-before(lower-case($current-box), 'series'), $container-stop-word-list, ''), '\s', '')
                
                else
                replace(replace(lower-case($current-box), $container-stop-word-list, ''), '\s', '')"
        />
    </xsl:function>
    
    <!-- sorts container numbers in order, generally :) -->
    <xsl:function name="mdc:container-to-number" as="xs:decimal">
        <xsl:param name="current-container" as="element()"/>
        <xsl:variable name="primary-container-number" select="if (contains($current-container, '-')) then replace(substring-before($current-container, '-'), '\D', '') else replace($current-container, '\D', '')"/>
        <xsl:variable name="primary-container-modify">
            <xsl:choose>
                <xsl:when test="matches($current-container, '\D')">
                    <xsl:analyze-string select="$current-container" regex="(\D)(\s?)">
                        <xsl:matching-substring>
                            <xsl:value-of select="number(string-to-codepoints(upper-case(regex-group(1))))"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="00"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="xs:decimal(concat($primary-container-number, '.', $primary-container-modify))"/>
    </xsl:function>

</xsl:stylesheet>
