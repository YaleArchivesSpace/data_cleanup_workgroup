<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:variable name="repo-map" select="map{
          'Beinecke Rare Book and Manuscript Library': 'BRBL'
        , 'Manuscripts and Archives': 'MSSA'
        , 'Yale University Music Library': 'Music'
        , 'Medical Historical Library, Harvey Cushing / John Hay Whitney Medical Library': 'Medical'
        , 'The Lewis Walpole Library': 'Walpole'
        , 'Yale Center for British Art': 'YCBA-RBM'
        , 'Yale University Arts Library': 'Arts'
        , 'Yale University Divinity School Library': 'Divinity'
        , 'Yale University Library Fortunoff Video Archives for Holocaust Testimonies': 'Fortunoff'
        }"/>
    
</xsl:stylesheet>