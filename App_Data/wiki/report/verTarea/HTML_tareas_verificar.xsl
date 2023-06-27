<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\..\..\App_data\fw\report\xsl_includes\js_formato.xsl"  />
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
			function obtenerDia(fecha) {
                var fecha = parseFecha(fecha)
                var dayArray = new Array('Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado');

                for (var i = 0, n = dayArray.length; i <= n; i++) {
                    if (i == fecha.getDay())
                        return dayArray[i]
                }

                return ''
            } 
             
            function cortar_string(cadena) {
                return cadena.substring(0,40) 
            }		
		]]>
	</msxsl:script>

	<xsl:template match="/">
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
			<title>Tareas verificar xsl</title>
            <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
			
            <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
            <script type="text/javascript" src="/fw/script/nvFW_basicControls.js" language="JavaScript"></script>
            <script type="text/javascript" src="/fw/script/nvFW_windows.js" language="JavaScript"></script>
            <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
            <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
            
			<script type="text/javascript" language="javascript">
				<![CDATA[
                function tarea_rep(nro_tarea, fe_inicio, nro_rep) {
                    parent.tarea_rep(nro_tarea, fe_inicio, nro_rep)
                }

				function window_onload() {
					window_onresize()
					$('tb_cuerpo').getHeight() - $('div_consulta').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
				}
					
				function window_onresize() {
					try {
						var dif = Prototype.Browser.IE ? 5 : 2
						body_height = $$('body')[0].getHeight()
						titulo_height = $('tb_titulo').getHeight()
						$('div_consulta').setStyle({height: body_height - titulo_height - dif + 'px'})
					}
					catch(e) {}
				}

                var total_filas = 0
				function tdScroll_hide_show(show) {
                    var i = 1
                    
                    while (i < total_filas) {
                        if (show &&  $('tdScroll'+ i) != undefined)
                            $('tdScroll'+ i).show() 

                        if (!show &&  $('tdScroll'+ i) != undefined)
                            $('tdScroll'+ i).hide() 

                        i++
                    }
                }

				function seleccionar(indice) {
					$('tr_ver'+indice).addClassName('tr_cel')
				}

                function no_seleccionar(indice) {
					$('tr_ver'+indice).removeClassName('tr_cel')
				}

				function tarea_eliminar(nro_tarea, nro_rep) {
					parent.tarea_eliminar(nro_tarea, nro_rep)
				}
				]]>
			</script>
            <style type="text/css">
                .tr_cel TD { background-color: #F0FFFF !Important }
                .tr_cel_click TD { background-color: #BDD3EF !Important, color : #0000A0 !Important }
            </style>
        </head>
			<body onload="window_onload()" onresize="window_onresize()"  style="width:100%;height:100%;overflow:hidden">
				<form name="frmConsultar" id="frmConsultar" style="width:100%;height:100%;overflow:hidden">
					<table class="tb1" id="tb_titulo">
                        <tr class="tbLabel" style="height:20px !Important">
                            <td colspan="5" style="font-weight:bold !Important;font-size:12px !Important">Si desea guardar esta tarea periodica, esto generará la pérdida de tareas anteriores pertenecientes a la serie:</td>
                        </tr>
                        <tr class="tbLabel">
                            <td style="width:25%">Inicio</td>
                            <td>Asunto</td>
                            <td style="width:25%">Vencimiento</td>
                            <td><div style="overflow:scroll;height:1px;width:1px">&#160;</div></td>
						</tr>
					</table>
					<div id="div_consulta"  style="width:100%; overflow:auto">
						<table class="tb1 highlightTROver" id="tb_cuerpo">
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>
		        </form>
	        </body>
	    </html>
	</xsl:template>

	<xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <script type="text/javascript" language="javascript">
            total_filas = <xsl:value-of select="$pos"/> + 1
        </script>
        <tr>
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
            
            <script type="text/javascript">
                <xsl:if test="@nro_tarea_estado = 3">
                    $('tr_ver'+ <xsl:value-of select="$pos"/>).setStyle({'textDecoration' :'line-through' })
                </xsl:if>
                <xsl:if test="@tarea_vencida = 1">
                    $('tr_ver'+ <xsl:value-of select="$pos"/>).setStyle({'color' : 'red' })
                </xsl:if>
                <xsl:if test="@nro_tarea_estado = 1 or @nro_tarea_estado = 2">
                    $('tr_ver'+ <xsl:value-of select="$pos"/>).setStyle({'color' : 'blue' })
                </xsl:if>
            </script>
            <td style='width:25%; text-align:left'>
                <xsl:if test='string(@fe_inicio) != ""'>
                    <xsl:value-of  select="foo:obtenerDia(string(@fe_inicio))" />&#160;<xsl:value-of  select="foo:FechaToSTR(string(@fe_inicio))" />&#160;<xsl:value-of  select="foo:HoraToSTR(string(@fe_inicio))" />
                </xsl:if>
            </td>
			<td style='text-align:left'>
                <xsl:if test='@nro_rep > 1'>
                    <img title='Tarea Periodica' src='/fw/image/icons/periodicidad.png' style='vertical-align:middle !Important' />
                </xsl:if>
                <xsl:if test='@nro_rep = 1 and string(@nro_tipo_period) != ""'>
                    <img title='Tarea Origen Periodica' src='/fw/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />
                </xsl:if>
               &#160;<xsl:value-of select='foo:cortar_string(string(@asunto))'/>
            </td>
			<td style='width:25%; text-align:left'>
			    <xsl:if test='string(@fe_vencimiento) != ""'>
                    <xsl:value-of  select="foo:obtenerDia(string(@fe_vencimiento))" />&#160;<xsl:value-of  select="foo:FechaToSTR(string(@fe_vencimiento))" />&#160;<xsl:value-of  select="foo:HoraToSTR(string(@fe_vencimiento))" />
                </xsl:if>
            </td>
            <td style='width:10px'>
                <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>
                &#160;&#160;
            </td>
		</tr>
    </xsl:template>
</xsl:stylesheet>