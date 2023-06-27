<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Procesos</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
                <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
                <script language="javascript" type="text/javascript">
                
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>

                    if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW

                    <![CDATA[ 
                    
                    function verDetalle_Proceso(nro_proceso, pr_estado){

                        win = window.top.nvFW.createWindow({ className: 'alphacube',
                        title: "<b>Proceso Log</b>",
                        minimizable: false,
                        maximizable: true,
                        draggable: true,
                        width: 800,
                        height: 500,
                        resizable: true,
                        onClose: verDetalle_Proceso_return
                        });
                        win.nro_proceso =   nro_proceso
                        win.pr_estado = pr_estado
                        var url = '/FW/procesos/Proceso_mostrar_log.aspx?nro_proceso='+nro_proceso+'&pr_estado='+pr_estado
                        win.setURL(url)
                        win.showCenter(true)

                    }

                    function verDetalle_Proceso_return(){
                        parent.MostrarProcesos()
                    }

                   								
                    
                    function window_onresize(){
					    try {
					     var dif = Prototype.Browser.IE ? 5 : 2
					     var body_height = $$('body')[0].getHeight()
					     var tbCabe_height = $('tbCabe').getHeight()

					     var total = body_height - tbCabe_height - dif 
					     
					     $('tbDetalle').setStyle({height: total + 'px'})
					     
					    }
					     catch(e){}
					} 
					
					
               ]]>     					  					  
					
				</script>
			</head>
			<body style="width:100%;height:100%;overflow:hidden" onload="return window_onresize()" onresize="return window_onresize()">
				<xsl:if test='count(xml/rs:data/z:row[@pr_estado = 2]) > 0'>
					<!--<xsl:attribute name='onload'>return window.setTimeout('parent.actualizar_estado_proceso()',3000)</xsl:attribute>-->
                    <xsl:attribute name='onload'>return window.setTimeout('verDetalle_Proceso_return()',3000)</xsl:attribute>
				</xsl:if>
				<table class="tb1" id="tbCabe" >
					<tr class="tbLabel">
                        <td style="width:15%">
                            <script>campos_head.agregar('Fecha', 'true', 'fecha_proceso')</script></td>
                        <td style="width:8%">Nro.</td>
                        <td style="width:15%">Tipo</td>
                        <td style="width:10%">Operador</td>
                        <td style="width:30%">Comentario</td>
                        <td style="width:8%">Estado</td>
                        <td style="width:8%">&#160;</td>
					</tr>
				</table>
                <div style="width: 100%; overflow-y:auto;" id="tbDetalle">
                    <table class="tb1 highlightOdd highlightTROver ">
                        <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
                    </table>
                </div>
                <script type="text/javascript">
                    document.write(campos_head.paginas_getHTML())
                </script>

                <script type="text/javascript">
                    campos_head.resize("tbCabe", "tbDetalle")
                </script>
			</body>
		</html>
	</xsl:template>
    <xsl:template match="z:row" mode="row1">
        <xsl:variable name="pos" select="position()"/>
		<tr>
			<td style="text-align: center;width:15%">
				<xsl:value-of select="foo:FechaToSTR(string(@fecha_proceso))"/> - <xsl:value-of select="foo:HoraToSTR(string(@fecha_proceso))"/>
			</td>
			<td  style='text-align: center;width:8%'>
				<a href='#'>
                    <!--<xsl:if test='@pr_estado != 2'>-->
                        <xsl:attribute name='onclick'>
                            return verDetalle_Proceso(<xsl:value-of select='@nro_proceso'/>, <xsl:value-of select='@pr_estado'/>)
                        </xsl:attribute>
                    <!--</xsl:if>-->
					<xsl:value-of select="format-number(@nro_proceso, '00000')"/>
				</a>
			</td>
			<td style="text-align: left;width:15%">
                <xsl:attribute name='title'><xsl:value-of select="@tipo_proceso_desc" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@tipo_proceso_desc) &#62; 25">
                        <xsl:value-of select="substring(@tipo_proceso_desc,1,25)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@tipo_proceso_desc"/>
                    </xsl:otherwise>
                </xsl:choose>
			</td>
			<td style="text-align: left; width:10%">
                <xsl:attribute name='title'><xsl:value-of select="@nombre_operador" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@nombre_operador) &#62; 15">
                        <xsl:value-of select="substring(@nombre_operador,1,15)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@nombre_operador"/>
                    </xsl:otherwise>
                </xsl:choose>
			</td>
			<td style="text-align: left; width:30%">
                <xsl:attribute name='title'><xsl:value-of select="@observaciones" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@observaciones) &#62; 70">
                        <xsl:value-of select="substring(@observaciones,1,70)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@observaciones"/>
                    </xsl:otherwise>
                </xsl:choose>
			</td>
			<td style="text-align: left; width:8%">
				<xsl:if test="@pr_estado = 2">
					<xsl:attribute name="style">color:red;font-weight:bolder</xsl:attribute>
				</xsl:if>
                <xsl:attribute name='title'><xsl:value-of select="@pr_estado_desc" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@pr_estado_desc) &#62; 70">
                        <xsl:value-of select="substring(@pr_estado_desc,1,70)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@pr_estado_desc"/>
                    </xsl:otherwise>
                </xsl:choose>
			</td>
			<td style="text-align: left; width:7%">
                <xsl:attribute name='id'><xsl:value-of select="@nro_proceso" /></xsl:attribute>
                <xsl:if test="count(@porc_ejec) > 0 and @pr_estado = 2">
				<font color="red"><b><xsl:value-of select="format-number(@porc_ejec, '0.00')"/>%</b></font>
				</xsl:if>
			</td>
		    </tr>
	</xsl:template>
</xsl:stylesheet>