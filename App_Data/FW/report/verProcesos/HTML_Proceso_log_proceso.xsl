<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Detalle log del Proceso</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

                <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

                    if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW

                    function window_onresize() {
                        var body = $$("BODY")[0]
                        var altoDiv = body.clientHeight - 50
                        $("divBody").setStyle({height: altoDiv + "px" })

                        campos_head.resize("tbCabe", "tbDetalle")
                    }

                    function window_onload(){
                        window_onresize()
                    }

                </script>
                </head>
			<body>
                <table class="tb1 " id="tbCabe">
					<tr class="tbLabel">
						<td style="width:102px">ID</td>
						<td style="width:202px">Fecha y Hora</td>
						<td nowrap="true">Observación</td>
					</tr>
				</table>
				<div style="width:100%; height:300px ">
                 <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
						<xsl:apply-templates select="xml/rs:data/z:row" />
				</table>
				</div>
				<!--<xsl:if test="count(xml/rs:data/z:row/@momento) > 0">
				<table class="tb1">
					<tr>
						<td class="Tit1">Fecha Inicio:</td>
						<td>
							<xsl:variable name="fecha_min" select="/xml/rs:data/z:row[position()=1]/@momento"/>
							<xsl:value-of select="foo:FechaToSTR(string($fecha_min))"/>
						</td>
						<td class="Tit1">Duración:</td>
						<xsl:variable name="fecha_max" select="/xml/rs:data/z:row[position()=count(/xml/rs:data/z:row)]/@momento"/>
                        <td>
                            <xsl:value-of select="foo:Dif_Fecha(string($fecha_min),string($fecha_max))"/> seg.</td>
                        </td>
						<td class="Tit1">Cant. Registros:</td>
						<td>
							<xsl:value-of select="count(/xml/rs:data/z:row/@id_det)"/>
						</td>						
					</tr>
				</table>
				</xsl:if>-->
                <script type="text/javascript">
                    document.write(campos_head.paginas_getHTML())
                </script>
                <script type="text/javascript">
                    campos_head.resize("tbCabe", "tbDetalle")
                </script>
			</body>
		</html>
	</xsl:template>
		<xsl:template match="z:row">
			<tr>
				<td style='text-align: left; width: 98px'>
					<xsl:value-of select="@id_plog"/>
				</td>
				<td  style=' width: 198px'>
                    <xsl:value-of select="foo:FechaToSTR(string(@momento))"/> - <xsl:value-of select="foo:HoraToSTR(string(@momento))"/>
				</td>
				<td  style='' nowrap='true' >
                    <xsl:attribute name='title'>
                        <xsl:value-of select="@observacion" />
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="string-length(@observacion) &#62; 300">
                            <xsl:value-of select="substring(@observacion,1,300)"/>...
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@observacion"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>				
			</tr>
		</xsl:template>
</xsl:stylesheet>