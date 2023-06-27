<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:vbuser="urn:vb-scripts">

    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\report\xsl_includes\js_formato.xsl"  />

    
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Onboarding</title>
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
                    var body = $$("BODY")[0].getHeight()
                    var tbCabe = $("tbCabe").getHeight()
                    var divBody = $("divBody").getHeight()

                    $("divBody").setStyle({height: body - tbCabe - 30 + "px" })

                    campos_head.resize("tbCabe", "tbDetalle")
                    }

                    function window_onload(){
                    window_onresize()
                    }

                    <![CDATA[
                    function credito_mostrar(e,nro_credito){
                        var path = "../../meridiano/credito_mostrar.aspx?nro_credito=" + nro_credito
                        var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'

                        window.top.abrir_ventana_emergente(path, descripcion,"permisos_visualizacion",2, 500, 1000, true, true, true, true, false)
                    }



                    function mostrar_persona(e,nro_docu,tipo_docu,sexo) {
                        var descripcion = '<b>' + tipo_docu + ' ' + nro_docu  + '</b>'
                        var path = "../../meridiano/persona_mostrar.aspx?nro_docu=" + nro_docu + "&tipo_docu=" + tipo_docu + "&sexo=" + sexo + "&modal=1"

                        if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                        $(link).href = path;
                        else if (e.altKey) { //con la tecla "Alt", abre una ventana emergente
                        window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)
                        } else if (e.shiftKey) { //con la tecla "Shift", abre una nueva ventana _blank
                        $(link).target = '_blank'
                        $(link).href = path;
                        } else {
                        window.top.event = e
                        window.top.abrir_ventana_emergente(path, descripcion,"permisos_visualizacion",1, 500, 1000, true, true, true, true, false)
                        }
                    }


                    function mostrar_transf(id_transf_log, id_transferencia, nombre, fe_inicio, fe_fin, nombre_operador, estado) {
                        
                        window.top.win = window.top.nvFW.createWindow({ 
                        title: '<b>Seguimiento transferencia</b>',
                            url: '../../fw/transferencia/transf_seguimiento_pool_control_exec.aspx?id_transf_log=' + id_transf_log,
                            minimizable: false,
                            maximizable: false,
                            draggable: true,
                            width: 800,
                            height: 440,
                            resizable: true,
                            destroyOnClose: true
                        })

                        window.top.win.options.userData = { interval: null, id_transf_log: id_transf_log, estado: estado, id_transferencia: id_transferencia, nombre: nombre, fe_inicio: fe_inicio, fe_fin: fe_fin, nombre_operador: nombre_operador }
                        window.top.win.showCenter(true)
                    }
                    ]]>
                </script>

                </head>
            <body>
                <table class="tb1 highlightEven  highlightTROver" >
                    <tr class="tbLabel">
                        <xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
                        <td style="width: 40px; cursor: pointer; text-align: center;">
                            <script>campos_head.agregar_exportar()</script>
                        </td>
                    </tr>
                    <xsl:apply-templates select="xml/rs:data/z:row" />
                </table>
                <script type="text/javascript">
                    document.write(campos_head.paginas_getHTML())
                </script>
            </body>
		</html>
	</xsl:template>
  
	<xsl:template match="s:AttributeType" mode="titulo">
		<td>
            <xsl:choose >
				<xsl:when test="@name = 'fe_inicio'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:15%</xsl:attribute> <script>campos_head.agregar('Fecha inicio', true, 'fe_inicio')</script></xsl:when>
                <xsl:when test="@name = 'fe_consulta'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:15%</xsl:attribute> <script>campos_head.agregar('Fecha inicio', true, 'fe_consulta')</script></xsl:when>
				<xsl:when test="@name = 'fe_fin'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:15%</xsl:attribute><script>campos_head.agregar('Fecha fin', true, 'fe_fin')</script> </xsl:when>
				<xsl:when test="@name = 'nombre_operador'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:15%</xsl:attribute> <script>campos_head.agregar('Operador', true, 'nombre_operador')</script></xsl:when>
				<xsl:when test="@name = 'id_transf_log'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:10%</xsl:attribute> <script>campos_head.agregar('Id transf. log', true, '_id_transf_log')</script></xsl:when>
				<xsl:when test="@name = 'estado'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:10%</xsl:attribute> <script>campos_head.agregar('Estado', true, 'estado')</script></xsl:when>
				<xsl:when test="@name = 'transferencia'"><xsl:attribute name='style'>white-space:nowrap;text-align:center;width:25%</xsl:attribute> <script>campos_head.agregar('Transferencia', true, 'transferencia')</script></xsl:when>
                <xsl:when test="@name = 'nro_docu'"><xsl:attribute name='style'>white-space:nowrap;text-align:center</xsl:attribute> <script>campos_head.agregar('Documento', true, 'nro_docu')</script> </xsl:when>
                <xsl:when test="@name = 'VI_DNI'"><xsl:attribute name='style'>white-space:nowrap;text-align:center</xsl:attribute><script>campos_head.agregar('Documento', true, 'VI_DNI')</script></xsl:when>
                <xsl:when test="@name = 'nro_credito'"><xsl:attribute name='style'>white-space:nowrap;text-align:center</xsl:attribute><script>campos_head.agregar('Crédito', true, 'nro_credito')</script>
                </xsl:when>
				<xsl:otherwise>
                    <xsl:attribute name="style">white-space:nowrap</xsl:attribute>
					<xsl:value-of disable-output-escaping="yes" select="@name"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

    <xsl:template match="z:row">
        <tr>
            <xsl:variable name="fila" select="."/>
            <xsl:for-each select="/xml/s:Schema/s:ElementType/s:AttributeType"  >
                <td>
                    <xsl:attribute name="style">white-space:nowrap</xsl:attribute>
                    <xsl:variable name="attr" select="@name" />
                    <xsl:variable name="valor" select="string($fila/@*[name() = $attr])"/>
            
                    <xsl:choose>
                        <xsl:when test="$attr='fe_inicio'">
                            <xsl:value-of select="foo:FechaToSTR($valor)"/> &#160;<xsl:value-of select="foo:HoraToSTR(string($valor))"/>
                        </xsl:when>
                         <xsl:when test="$attr='fe_consulta'">
                            <xsl:value-of select="foo:FechaToSTR($valor)"/> &#160;<xsl:value-of select="foo:HoraToSTR(string($valor))"/>
                        </xsl:when>
                        <xsl:when test="$attr='fe_fin'">
                            <xsl:value-of select="foo:FechaToSTR($valor)"/> &#160;<xsl:value-of select="foo:HoraToSTR(string($valor))"/>
                        </xsl:when>
                        <xsl:when test="$attr='transferencia'">
                            <xsl:value-of select="$valor"/>
                        </xsl:when>
                        <xsl:when test="$attr='id_transf_log'">
                            <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;color:#0505f5</xsl:attribute>
                            <xsl:attribute name='onclick'>
                                mostrar_transf('<xsl:value-of select="$valor" />')
                            </xsl:attribute>
                            <xsl:value-of select="$valor"/>
                        </xsl:when>
                        <xsl:when test="$attr='nro_docu'">
                            <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;color:#0505f5</xsl:attribute>
                            <xsl:attribute name='onclick'>
                                mostrar_persona(event,'<xsl:value-of select="$valor"/>','<xsl:value-of select="@tipo_docu"/>','<xsl:value-of select="@sexo"/>')
                            </xsl:attribute>
                            <xsl:value-of select="$valor"/>
                        </xsl:when>
                        <xsl:when test="$attr='nro_credito'">
                            <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;color:#0505f5</xsl:attribute>
                            <xsl:attribute name='onclick'>credito_mostrar(event, <xsl:value-of select="$valor"/>)
                            </xsl:attribute>
                            <xsl:value-of select="$valor"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="string-length($valor) &#62; 30">
                                    <xsl:attribute name="title"><xsl:value-of select="$valor"/></xsl:attribute>
                                    <xsl:value-of select="substring($valor,1,30)"/>...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$valor"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </xsl:for-each>
            <td style="width: 40px;"></td>
        </tr>
    </xsl:template>
	
	<xsl:template match="@*">
		<xsl:variable name="tipo_dato" select="." />
		<td style="text-align: right">
			<xsl:value-of select="." /> 
		</td>
	</xsl:template>
</xsl:stylesheet>