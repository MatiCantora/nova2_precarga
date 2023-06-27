<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	
    <xsl:output method="html" version="1.0" encoding="iso-8859-1" omit-xml-declaration="yes"/>
	
    <msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
        function parseFecha(strFecha) {
		    var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
			a = a.substr(0, a.indexOf('.'))

            return new Date(Date.parse(a))
        }

        // Retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
		function formatoDDMMYYYY(fecha_date) {
			var fecha_retorno = ''
			var fecha         = parseFecha(fecha_date)
            var dia           = fecha.getDate()
            var mes           = fecha.getMonth()

            fecha_retorno = (dia < 9) ? '0' + dia + '/' : dia + '/'
            fecha_retorno += (mes < 9) ? '0' + (mes + 1) + '/' : (mes + 1) + '/'
            fecha_retorno += fecha.getFullYear()

			return fecha_retorno.toString()
		}

        // Retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
        function formatoHHMM(fecha_date) {
			var fecha_retorno = ""
			var fecha         = parseFecha(fecha_date)
            var horas         = fecha.getHours()
            var minutos       = fecha.getMinutes()
            
            fecha_retorno = (horas < 9) ? "0" + horas + ":" : horas + ":"
            fecha_retorno += (minutos < 9) ? "0" + minutos : minutos
				
			return fecha_retorno.toString()
		}

		var dayArray = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
        
        function obtenerDia(fecha) {
            var fecha = parseFecha(fecha)
      
            try {
                return dayArray[fecha.getDay()].toString()
            }
            catch(e) {
                return ''
            }
        }

        function cortar_string(cadena) {
            return cadena.substring(0,60).toString()
        }		
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title></title>
                
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
                
                <script type="text/javascript" src="/FW/script/nvFW.js"></script>
                <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
                <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
                <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
                <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
				        
                <script type="text/javascript" language="javascript">
                <![CDATA[
                    function tarea_rep(nro_tarea, fe_inicio, nro_rep, nro_tipo_period)
                    {
                        if (nro_rep == 1 && nro_tipo_period == '')
                            nro_rep = 0

                        parent.tarea_rep(nro_tarea, fe_inicio, nro_rep)
                    }
                    
		            function window_onload()
                    {
		                window_onresize()
			            $('tb_cuerpo').getHeight() - $('div_consulta').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
	                }
					
		            function window_onresize()
                    { 
		                try
			            {
			                var dif           = Prototype.Browser.IE ? 5 : 2
				            var body_height   = $$('body')[0].getHeight()
				            var titulo_height = $('tb_titulo').getHeight()
				            
                            $('div_consulta').setStyle({ height: body_height - titulo_height - dif + 'px' })
		                }
			            catch(e) {}
	                }
					
                    var total_filas = 0
		                
                    function tdScroll_hide_show(show)
                    {
                        var i = 1
                        while(i < total_filas)
                        {
                            if (show &&  $('tdScroll'+ i) != undefined)
                                $('tdScroll'+ i).show()

                            if (!show &&  $('tdScroll'+ i) != undefined)
                                $('tdScroll'+ i).hide()

                            i++
                        }
                    }
					
		            function tarea_eliminar(nro_tarea,nro_rep)
                    {
		                parent.tarea_eliminar(nro_tarea,nro_rep)
		            } 
                ]]>
			    </script>
                <style type="text/css">
                    .tr_cel TD { background-color: #F0FFFF !important }
                    .tr_cel_click TD { background-color: #BDD3EF !Important, color : #0000A0 !Important }
                </style>
            </head>
			<body onload="window_onload()" onresize="window_onresize()"  style="width:100%;height:100%;overflow:hidden">
				<form name="frmConsultar" id="frmConsultar" style="width:100%;height:100%;overflow:hidden">
					<table class="tb1" id="tb_titulo">
						<tr class="tbLabel">
                            <td colspan="2" style="width:6%; text-align: center">-</td>
                            <td style="width:15%">Inicio</td>
                            <td style="width:31%">Asunto</td>
                            <td style="width:10%">Estado</td>
                            <td style="width:15%">Vencimiento</td>
                            <td style="width:10%">Prioridad</td>
                            <td style="width:8%">%</td>
                            <td style="width:5%; text-align: center"><!--<div style="overflow:scroll;height:1px;width:1px">&#160;</div>-->-</td>
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
        <tr id="tr_ver{$pos}">
            <!--<xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>-->
            <!--<xsl:attribute name="onmousemove">seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <xsl:attribute name="onmouseout">no_seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>-->
            
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

            <td style='width:3%; text-align:center'>
                <xsl:if test='@tarea_editable = 1'>
                    <img title="Eliminar Tarea" src="/FW/image/icons/eliminar.png" onclick="tarea_eliminar({@nro_tarea}, {@nro_rep})" style="cursor: poniter; cursor: hand;" />
                        <!--<xsl:attribute name='onclick'>
                            tarea_eliminar(<xsl:value-of select='@nro_tarea'/>,<xsl:value-of select='@nro_rep'/>)
                        </xsl:attribute>
                        <xsl:attribute name='style'>cursor:poniter;cursor:hand</xsl:attribute>-->
                    <!--</img>-->
                </xsl:if>
            </td>
            <td style="width:3%; text-align:center">
                <img src='/FW/image/icons/editar.png' alt='Ver Reporte' title='Editar tarea' onclick='tarea_rep("{@nro_tarea}", "{@fe_inicio}", "{@nro_rep}", "{@nro_tipo_period}")' style='cursor: hand; cursor: pointer; border: none; margin: 1px; vertical-align: middle;' />
                    <!--<xsl:attribute name='onclick'>tarea_rep('<xsl:value-of select='@nro_tarea'/>','<xsl:value-of select='@fe_inicio'/>','<xsl:value-of select='@nro_rep'/>','<xsl:value-of select='@nro_tipo_period'/>')</xsl:attribute>-->
                    <!--<xsl:attribute name='style'>cursor:hand;cursor:pointer</xsl:attribute>-->
                <!--</img>-->
            </td>
            <td style='width:15%; text-align:left'>
                <xsl:if test='string(@fe_inicio) != ""'>
                    <xsl:value-of  select="foo:obtenerDia(string(@fe_inicio))" />,&#160;<xsl:value-of  select="foo:formatoDDMMYYYY(string(@fe_inicio))" />&#160;<xsl:value-of  select="foo:formatoHHMM(string(@fe_inicio))" />
                </xsl:if>
            </td>
			<td style='text-align:left; width:31%'>
                <xsl:if test='@nro_rep > 1'>
                   <img title='Tarea Periodica' src='/FW/image/icons/periodicidad.png' style='vertical-align:middle !Important' />
                </xsl:if>
                <xsl:if test='@nro_rep = 1 and string(@nro_tipo_period) != ""'>
                   <img title='Tarea Origen Periodica' src='/wiki/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />
                </xsl:if>
                <xsl:if test='string(@tiene_autorun) = "True"'>
                    &#160;<img src='/wiki/image/icons/auto_run.png' style='vertical-align:middle !Important' title='Ejecución Automática' />
                            <!--<xsl:attribute name="title">Ejecución Automática</xsl:attribute>-->
                          <!--</img>-->
                </xsl:if>&#160;<xsl:value-of select='foo:cortar_string(string(@asunto))'/>
            </td>
            <td style='width:10%'>
                <xsl:value-of select='@tarea_estado'/>
            </td>
			<td style='width:15%; text-align:left'>
			    <xsl:if test='string(@fe_vencimiento) != ""'>
                  <xsl:value-of  select="foo:obtenerDia(string(@fe_vencimiento))" />,&#160;<xsl:value-of  select="foo:formatoDDMMYYYY(string(@fe_vencimiento))" />&#160;<xsl:value-of  select="foo:formatoHHMM(string(@fe_inicio))" />
                </xsl:if>
            </td>
            <td style='width:10%'>
                <xsl:if test='@nro_tarea_pri = 1'>
                    <img title='Prioridad Alta' src='/wiki/image/icons/pri_alta.png' style='vertical-align:middle !Important'/>
                </xsl:if>
                <xsl:if test='@nro_tarea_pri = 2'>
                    <img title='Prioridad Normal' src='/wiki/image/icons/pri_normal.png' style='vertical-align:middle !Important' />
                </xsl:if>
                <xsl:if test='@nro_tarea_pri = 3'>
                    <img title='Prioridad Baja' src='/wiki/image/icons/pri_baja.png' style='vertical-align:middle !Important'/>
                </xsl:if>

                <xsl:value-of select='@tarea_pri'/>
            </td>
            <td style='width:8%; text-align:right'>
                % <xsl:value-of select='@completado'/>
            </td>
            <td style='width:5%' id='tdScroll{$pos}'>
                <!--<xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>-->
                &#160;&#160;
            </td>
		</tr>
    </xsl:template>
</xsl:stylesheet>