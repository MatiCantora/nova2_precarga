<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

	<xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<title>Seleccionar Sucursal</title>
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

                <script type="text/javascript" src="/FW/script/nvFW.js"></script>
                
				<script>
					<![CDATA[
					function Seleccion(id_banco_sucursal)
					{
					    window.parent.Seleccion(id_banco_sucursal)
					}
                    
                    function setAlturaContenedor()
                    {
                        // Setear altura contenedor
                        try {
                            var h_body   = $$("body")[0].getHeight()
                            var h_tbCabe = $("tbCabe").getHeight()
                            
                            $("divSucursales").setStyle({ height: h_body - h_tbCabe + "px" })
                        }
                        catch(e) {}
                    }
					]]>
				</script>
			</head>
			<body onload="return setAlturaContenedor()" style="width: 100%; height: 100%; background-color: white;">
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
						<td style='width: 30px; text-align: center;'>-</td>
						<td style='width: 90px; text-align: center;'>Código</td>
						<td style='width: 90px; text-align: center;'>Cód.CBU</td>
						<td>Sucursal</td>
                        <td style='width: 14px;'></td>
					</tr>
				</table>
				
                <div id="divSucursales" style="width: 100%; overflow-y: scroll;">
					<table class="tb1 highlightOdd highlightTROver" >
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
	    <tr>
	        <td style='text-align: center; width: 30px;'>
                <img src="/FW/image/icons/agregar.png" onclick="Seleccion({@id_banco_sucursal})" style="cursor: pointer;" title="Seleccionar {@Banco_sucursal}" />
			    <!--<input type='button' value='+' style='width:100%'>
				  <xsl:attribute name='onclick'>
					  Seleccion(<xsl:value-of select='@id_banco_sucursal'/>)
				  </xsl:attribute>
			  </input>-->
		    </td>
	        <td style='width: 90px; text-align: right;'>
		        <xsl:value-of select='@cod_sucursal'/>
	        </td>
	        <td style='width: 90px; text-align: right;'>
		        <xsl:value-of select='@cod_cbu'/>
	        </td>
	        <td>
		        <xsl:value-of select='@Banco_sucursal'/>
	        </td>
            <!--<td style='width: 14px; display: none;'>&#160;</td>-->
	    </tr>	  
	</xsl:template>
</xsl:stylesheet>