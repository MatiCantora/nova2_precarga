<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title></title>
                <link href="../../fw/css/base.css" type="text/css" rel="stylesheet"/>
                <script type="text/javascript" src="/fw/script/prototype.js"></script>
                <script language="javascript">
				        <![CDATA[
                    function seleccionar(nro_entidad,apellido,nombres,documento,nro_docu,sexo,tipo_docu)
                    {
                      window.parent.AgregarEntidad(nro_entidad,apellido,nombres,documento,nro_docu,sexo,tipo_docu)
                    }
                    
                    function window_onresize()
                    {
                     
                     try
                      {
                       var dif = Prototype.Browser.IE ? 5 : 2
					             var body_h = $$('body')[0].getHeight()
					             var tbCabe_h = $('tbCabe').getHeight()
					             $('divCuerpo').setStyle({'height' : body_h - tbCabe_h - dif + 'px'})
                      }
                      catch(e){}
                      
                    }
                    
                    function window_onload()
                    {
                     window_onresize()
                    }
                ]]>
                </script>	
					
			</head>
			<body onresize="window_onresize()" onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden" >
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
						<td>-</td>
						<td>Nro.</td>
						<td>Apellido</td>
						<td>Nombres</td>
					    <td>Documento</td>
					</tr>
				</table>
				<div id="divCuerpo" style="width: 100%; overflow: auto" >
                    <table class="tb1">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table>
				</div>	
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
	  <tr>
		   <td>
               <img src='../../fw/image/icons/agregar_cargo.png' border='0' align='absmiddle' hspace='2' style='cursor:hand;cursor:pointer'>
                   <xsl:attribute name='onclick'>seleccionar(<xsl:value-of select="@nro_entidad"/>,'<xsl:value-of select="@apellido"/>','<xsl:value-of select="@nombres"/>','<xsl:value-of  select="@documento" />', '<xsl:value-of  select="@nro_docu" />','<xsl:value-of  select="@sexo" />',<xsl:value-of  select="@tipo_docu" />)</xsl:attribute>
               </img>
		  </td>
		  <td align="center">
			  <xsl:value-of  select="@nro_entidad" />
		  </td>
		  <td>
			  <xsl:value-of  select="@apellido" />
		  </td>
		  <td>
			  <xsl:value-of  select="@nombres" />
		  </td>
    	  <td>
			  <xsl:value-of  select="@documento" /> - <xsl:value-of  select="@nro_docu" />
		  </td>

	  </tr>	  
	</xsl:template>
</xsl:stylesheet>