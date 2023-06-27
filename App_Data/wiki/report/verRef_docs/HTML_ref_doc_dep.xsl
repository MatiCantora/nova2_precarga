<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	
    <xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<xsl:if test="count(xml/rs:data/z:row) > 0">
			<hr/>
			<table class="resumen_tb tb1" >
				<tr class="resumen_titulo">
					<td>Tema</td>
					<td>Descripción</td>
				</tr>
				<xsl:apply-templates select="xml/rs:data/z:row" mode="tipo" />
			</table>
                <!--</body>
                </html>-->
		</xsl:if>
	</xsl:template>
	<xsl:template match="z:row" mode="tipo">
		<tr>
			<td style="width: 25%">
				<a>
					<xsl:attribute name="href">javascript:ref_mostrar(<xsl:value-of select="@nro_ref"/>)</xsl:attribute>
					<xsl:value-of select="@referencia"/>
				</a>
			</td>
			<td>
				<div>
					<xsl:attribute name='id'>divDOC<xsl:value-of select='@id_ref_doc'/></xsl:attribute>
                    <xsl:value-of select='@docHTML' disable-output-escaping='yes' />
				</div>
                <!--<script type="text/javascript" language="javascript">
                        var id_ref_doc = '<xsl:value-of select='@id_ref_doc'/>'
                        var divID = 'divDOC' + id_ref_doc;
                        nvFW.insertFileInto(id_ref_doc, divID)
                </script>-->
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>