<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0"   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				                xmlns:rs='urn:schemas-microsoft-com:rowset'
				                xmlns:z='#RowsetSchema'
				                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	                            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl" />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  
    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[
	    function formatoDDMMYYYY(fecha_date)
        {	
            // retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
		    var fecha_retorno
		    var fecha = parseFecha(fecha_date)
				
		    if (fecha.getDate().toString().length == 1)
			    fecha_retorno = '0' + fecha.getDate() + '/'
		    else
			    fecha_retorno = fecha.getDate().toString() + '/'
					
		    if (fecha.getMonth() < 9)
			    fecha_retorno += '0' + (fecha.getMonth() + 1) + '/'
		    else
			    fecha_retorno += (fecha.getMonth() + 1).toString() + '/'
					
		    fecha_retorno += fecha.getFullYear().toString()
				
		    return fecha_retorno
	    }
			
	    function formatoHHMM(fecha_date)
        {	
            // retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
		    var fecha_retorno
		    var fecha = parseFecha(fecha_date)
				
		    if (fecha.getHours() < 9)
			    fecha_retorno = '0' + fecha.getHours() + ':'
		    else
			    fecha_retorno = fecha.getHours().toString() + ':'
				
		    if (fecha.getMinutes() < 9)
			    fecha_retorno += '0' + fecha.getMinutes() 
		    else
			    fecha_retorno += fecha.getMinutes().toString() 
				
		    return fecha_retorno
	    }
			
	    function obtenerDia(fecha)
        {
            var fecha = parseFecha(fecha)
            var dayArray = new Array('Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado');
            
            for (var i=0, daysLength = dayArray.length; i <= daysLength; i++)
            {
                if (i == fecha.getDay())
                    return dayArray[i]
            }
            
            return ''
        } 
             
        function cortar_string(cadena)
        {
            return cadena.substring(0,60) 
        }		
	    ]]>
    </msxsl:script>

    <xsl:template match="/">
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title></title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
        <script type="text/javascript" language="javascript" src="/wiki/script/tareas.js"></script>

        <script type="text/javascript" language="javascript">
            <xsl:comment>

            campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"  />'
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

            </xsl:comment>
        </script>
        <script type="text/javascript" language="javascript">
            <![CDATA[                    
		    function window_onload()
		    {
			    window_onresize()
			    $('tb_cuerpo').getHeight() - $('div_consulta').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
		    }

		    function window_onresize()
		    { 
			    try
			    {
				    var dif = Prototype.Browser.IE ? 5 : 2
				    body_height = $$('body')[0].getHeight()
				    titulo_height = $('tb_titulo').getHeight()
				    
                    $('div_consulta').setStyle({height: body_height - titulo_height - dif + 'px'})
			    }
				catch(e) {}
		    }
					
            var total_filas = 0
		    
            function tdScroll_hide_show(show)
            {
                var i = 1
                while (i < total_filas)
                {
                    if (show &&  $('tdScroll'+ i) != undefined)
                        $('tdScroll'+ i).show() 
                          
                    if (!show &&  $('tdScroll'+ i) != undefined)
                        $('tdScroll'+ i).hide() 

                    i++
                }
            }
					
		    function seleccionar(indice)
			{
			    $('tr_ver'+indice).addClassName('tr_cel')
			}
		    
            function no_seleccionar(indice)
			{
			    $('tr_ver'+indice).removeClassName('tr_cel')
			}
					 
		    function tarea_eliminar(nro_tarea,nro_rep)
		    {
			    parent.tarea_eliminar(nro_tarea,nro_rep)
		    }
		    ]]>
        </script>
    </head>
    <body style="width:100%; height:100%; overflow:hidden; background:#FFFFFF">
        <table class="tb1 highlightTROver">
            <xsl:apply-templates select="xml/rs:data/z:row" />
        </table>
    </body>
    </html>
    </xsl:template>

    <xsl:template match="z:row">
        <tr>
            <xsl:attribute name='onclick'>tarea_rep(<xsl:value-of select='@nro_tarea'/>)</xsl:attribute>
            <xsl:attribute name="style">cursor: pointer;</xsl:attribute>
            <td>
                <xsl:value-of select='@nro_tarea'/>
            </td>
            <td>
                <xsl:attribute name="style">
                    width: 70%;
                    <xsl:if test="@nro_tarea_estado = 3">
                        textDecoration : line-through;
                    </xsl:if>
                    <xsl:if test="@tarea_vencida = 1">
                        color : red;
                    </xsl:if>
                    <xsl:if test="@nro_tarea_estado = 1 or @nro_tarea_estado = 2">
                        color : blue;
                    </xsl:if>
                </xsl:attribute>
                <xsl:if test='@nro_rep > 1'>
                    <img title='Tarea Periodica' src='/wiki/image/icons/periodicidad.png' style='vertical-align:middle !Important' />
                </xsl:if>
                <xsl:if test='@nro_rep = 1 and string(@nro_tipo_period) != ""'>
                    <img title='Tarea Origen Periodica' src='/wiki/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />
                </xsl:if>
                &#160;<xsl:value-of select='foo:cortar_string(string(@asunto))'/>
            </td>
            <td>
                <xsl:value-of select='@tarea_estado'/>
            </td>
            <td>
                <xsl:if test='@nro_tarea_pri = 1'>
                    <img title='Prioridad Alta' src='/wiki/image/icons/pri_alta.png' style='vertical-align:middle !Important'/>
                </xsl:if>
                <xsl:if test='@nro_tarea_pri = 2'>
                    <img title='Prioridad Normal' src='/wiki/image/icons/pri_normal.png' style='vertical-align:middle !Important' />
                </xsl:if>
                <xsl:if test='@nro_tarea_pri = 3'>
                    <img title='Prioridad Baja' src='/wiki/image/icons/pri_baja.png' style='vertical-align:middle !Important'/>
                </xsl:if>
            </td>
            <td>
                <xsl:value-of select='@tarea_pri'/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>