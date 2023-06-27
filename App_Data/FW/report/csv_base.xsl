<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
        xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	
  <xsl:output method="text" />
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
    function StrToDblQuoteStr(cadena)
      {
      var strreg = '"'
      var reg = new RegExp(strreg, "ig")
      return '"'  + cadena.replace(reg, '""') + '"'
      }
      
    function DecimalToDblQuoteStr(cadena)
      {
      var strreg = '\\.'
      var reg = new RegExp(strreg, "ig")
      return  cadena.replace(reg, ',') 
      }      
      ]]>
  
  </msxsl:script>

  <xsl:template match="/">
    <xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
    <xsl:text>&#xd;&#xa;</xsl:text>
    <xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template>

  <xsl:template match="s:AttributeType" mode="titulo">
          <xsl:value-of select="foo:StrToDblQuoteStr(string(@name))"/>
          <xsl:text>;</xsl:text>
  </xsl:template>
  
  <xsl:template match="z:row">
    <xsl:variable name="fila" select="."/>
    <xsl:for-each select="/xml/s:Schema/s:ElementType/s:AttributeType"  >
        <xsl:variable name="attr" select="@name" />
        <xsl:variable name="valor" select="string($fila/@*[name() = $attr])"/>
        <xsl:variable name="existe" select="count($fila/@*[name() = $attr])"/>
        <xsl:variable name="tipo_dato" select="./s:datatype/@dt:type" />
        <xsl:choose>
          <xsl:when test="$existe=0"></xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$tipo_dato = 'string'">
                  <xsl:value-of select="foo:StrToDblQuoteStr($valor)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="foo:DecimalToDblQuoteStr($valor)"/>
              </xsl:otherwise>
            </xsl:choose>
            
          </xsl:otherwise>
        </xsl:choose>
      <xsl:text>;</xsl:text> 
    </xsl:for-each>
    <xsl:text>&#xd;&#xa;</xsl:text>

  </xsl:template>



</xsl:stylesheet>