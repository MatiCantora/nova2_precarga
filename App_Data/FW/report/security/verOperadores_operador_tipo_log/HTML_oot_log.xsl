<?xml version="1.0" encoding="iso-8859-1"?>
<!--#include virtual="meridiano/scripts/pvAccesoPagina.asp"-->
<!--#include virtual="meridiano/scripts/pvUtiles.asp"-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
	    function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
			
			function formatoDDMMYYYY(fecha_date){	// retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
			
        if(fecha_date == '')
          return ''
         
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
				
				return fecha_retorno.toString()
			}			

			function formatoHHMM(fecha_date){	// retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
				
        if(fecha_date == '')
         return ''
        
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
				
				return fecha_retorno.toString()
			}
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title></title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/window_utiles.js"></script>
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
          campos_head.nvFW = parent.nvFW
        </script>
				<script type='text/javascript' language="javascript" >
          <xsl:comment>
                 <![CDATA[
                   
                   var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 
                   
                    function window_onload()
					 {
					  window_onresize()
					 }
					
					function onmove_sel(indice)
					{
					 $('tr_ver'+indice).addClassName('tr_cel')
					}
					
					function onout_sel(indice)
					{
					 $('tr_ver'+indice).removeClassName('tr_cel')
					}

                    function window_onresize()
					{
					    try
					    {
					     var dif = Prototype.Browser.IE ? 5 : 2
					     var body_height = $$('body')[0].getHeight()
					     var divCabe_height = $('divCabe').getHeight()
					     $('divDetalle').setStyle({height: body_height - divCabe_height - dif + 'px'})
					     
					    }
					     catch(e){}
               
                   try
                    {
                     campos_head.resize("tbCabe","tbDetalle")                  
                    }
                    catch(e){}
					}

                 ]]>
            </xsl:comment>

                 </script>
                <style type="text/css">
                    .tr_cel TD
                    {
                     background-color: white !Important
                    }
                    .tr_cel_click TD
                    {
                     background-color: #BDD3EF !Important,
                     color : #0000A0 !Important
                    }
                </style>		
			</head>
			<body onload="window_onload()" onresize="window_onresize()"  style="width:100%; height:100%; overflow:hidden">
                <form name="Frm_seguimiento" style="width:100%;height:100%;overflow:hidden">
                <div id="divCabe" style="width:100%; margin: 0px; padding: 0px">
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td style="width:122px" nowrap="nowrap">
                              <script type="text/javascript" language="javascript">campos_head.agregar('F. Log', 'true', 'oot_momento_log')</script>
                            </td>
                            <td style="width:182px" nowrap="nowrap">
                                <script type="text/javascript" language="javascript">campos_head.agregar('Tipo Operador', 'true', 'tipo_operador_desc')</script>
                            </td>
                            <td style="width:122px" nowrap="nowrap">
                                <script type="text/javascript" language="javascript">campos_head.agregar('F. Alta', 'true', 'fe_alta')</script>
                            </td>
                            <td style="width:122px" nowrap="nowrap">
                                <script type="text/javascript" language="javascript">campos_head.agregar('F. Baja', 'true', 'fe_baja')</script>
                            </td>
                            <td style="width:122px" nowrap="nowrap">
                             <script type="text/javascript" language="javascript">campos_head.agregar('Comentario', 'true', 'comentario')</script>
                            </td>
                            <td>
                                <script type="text/javascript" language="javascript">campos_head.agregar('Usuario', 'true', 'login_abm')</script>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divDetalle" style="width:100%;overflow:auto">
                        <table class="tb1" id="tbDetalle">
                            <xsl:apply-templates select="xml/rs:data/z:row" />
                        </table>
                </div>
              </form>
				
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
	  <xsl:variable name="pos" select="position()"/>
		<tr>
        <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
	      <xsl:attribute name="onmousemove">onmove_sel(<xsl:value-of select="$pos"/>)</xsl:attribute>
	      <xsl:attribute name="onmouseout">onout_sel(<xsl:value-of select="$pos"/>)</xsl:attribute>
          <xsl:choose>
                <xsl:when test="@nro_oot_lote_log = 0">
                    <xsl:attribute name="style">color:blue</xsl:attribute>
                </xsl:when>
          </xsl:choose>
          <td style="width:120px !Important; text-align:right">
            <xsl:if test="@nro_oot_lote_log != 0">
              <xsl:value-of  select="foo:formatoDDMMYYYY(string(@oot_momento_log))" />&#160;<xsl:value-of  select="foo:formatoHHMM(string(@oot_momento_log))" />
            </xsl:if>
          </td>   
          <td style="width:180px !Important; text-align:left">
             <xsl:attribute name='title'>
               <xsl:value-of  select="@tipo_operador_desc" /> 
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@tipo_operador_desc) &#62; 50">
                       <xsl:value-of select="substring(@tipo_operador_desc,1,50)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@tipo_operador_desc"/> 
                    </xsl:otherwise>
                </xsl:choose> 
          </td>
          <td style="width:120px !Important; text-align:right">
            <xsl:value-of  select="foo:formatoDDMMYYYY(string(@fe_alta))" />&#160;<xsl:value-of  select="foo:formatoHHMM(string(@fe_alta))" />
          </td>
          <td style="width:120px !Important; text-align:right">
            <xsl:value-of  select="foo:formatoDDMMYYYY(string(@fe_baja))" />&#160;<xsl:value-of  select="foo:formatoHHMM(string(@fe_baja))" />
          </td>
          <td style="width:120px !Important; text-align:left">
                 <xsl:attribute name='title'>
                 <xsl:value-of select="@comentario"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@comentario) &#62; 20">
                       <xsl:value-of select="substring(@comentario,1,20)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@comentario"/> 
                    </xsl:otherwise>
                </xsl:choose>
          </td>
          <td style="text-align:left">
             <xsl:attribute name='title'>
                 <xsl:value-of select="@login_abm"/> - <xsl:value-of  select="foo:formatoDDMMYYYY(string(@momento))" />&#160;<xsl:value-of  select="foo:formatoHHMM(string(@momento))" />
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@login_abm) &#62; 20">
                       <xsl:value-of select="substring(@login_abm,1,20)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@login_abm"/> 
                    </xsl:otherwise>
                </xsl:choose> 
          </td>
        </tr>	  
	</xsl:template>
</xsl:stylesheet>