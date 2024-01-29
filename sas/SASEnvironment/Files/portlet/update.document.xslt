<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Main Entry Point -->

<xsl:template match="/">

<xsl:variable name="objectId" select="Mod_Request/GetMetadata/Metadata/Document/@Id"/>

<xsl:variable name="oldName" select="Mod_Request/GetMetadata/Metadata/Document/@Name"/>
<xsl:variable name="newName">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/Name"><xsl:value-of select="Mod_Request/NewMetadata/Name"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldName"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="oldDesc" select="Mod_Request/GetMetadata/Metadata/Document/@Desc"/>
<xsl:variable name="newDesc">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/Desc"><xsl:value-of select="Mod_Request/NewMetadata/Desc"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldDesc"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="oldURI" select="Mod_Request/GetMetadata/Metadata/Document/@URI"/>
<xsl:variable name="newURI">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/URI"><xsl:value-of select="Mod_Request/NewMetadata/URI"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldURI"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:choose>

  <xsl:when test="not($oldName = $newName) or not($oldDesc = $newDesc) or not($oldURI = $newURI)">

    <UpdateMetadata>

      <Metadata>

         <Document>
           <xsl:attribute name="Id"><xsl:value-of select="$objectId"/></xsl:attribute>

           <xsl:if test="not($oldName = $newName)">
              <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>
              </xsl:if>

           <xsl:if test="not($oldDesc = $newDesc)">
              <xsl:attribute name="Desc"><xsl:value-of select="$newDesc"/></xsl:attribute>
              </xsl:if>

           <xsl:if test="not($oldURI = $newURI)">
              <xsl:attribute name="URI"><xsl:value-of select="$newURI"/></xsl:attribute>
              </xsl:if>

         </Document>

      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

  </xsl:when>

  <xsl:otherwise>
     <Root/>
     <xsl:comment>NOTE: No update required.</xsl:comment>
  </xsl:otherwise>

 </xsl:choose>

</xsl:template>

</xsl:stylesheet>

