<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[

			function completarNoObligatorio(valor)
			{
				if(valor=='')
				{
				return 0
				}else
				{
				return valor;
				}
			}
		
		]]>
	</msxsl:script>
	<xsl:output method="text" />
	<xsl:template match="/">
<xsl:text>C</xsl:text>   
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:value-of select="string(/xml/rs:data/z:row/@fecvuelco)"/>             
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:value-of select="string(/xml/rs:data/z:row/@codafinidad)"/>
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>    
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text> 
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:value-of select="format-number(sum(/xml/rs:data/z:row[@importecap > 0]/@importecap),'#0.00')"/>
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:value-of select="format-number(sum(/xml/rs:data/z:row/@importeint),'#0.00')"/>
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>    
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>  
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>    
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>  
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>    
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>  
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>  
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text></xsl:text>    
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>   
<xsl:value-of select="string(/xml/rs:data/z:row/@separador)"/>
<xsl:text>0</xsl:text>     
	<xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:apply-templates select="xml/rs:data/z:row" />
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:text>D</xsl:text>  
		<xsl:value-of select="string(@separador)"/> 
		<xsl:value-of select="string(@fecvuelco)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@codafinidad)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="format-number(@tasadesc,'#0.0000')" />
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="format-number(@tasaorig,'#0.0000')" />
		<xsl:value-of select="string(@separador)"/>
	  	<xsl:value-of select="format-number(@importecap,'#0.00')" />
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="format-number(@importeint,'#0.00')" />
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@otrosacc1)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@otrosacc2)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@otrosacc3)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@tipdoc)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@nrodoc)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@nroreferencia)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@nrocuo)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@fecven_str)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@destino)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@seguros)"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>