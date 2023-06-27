<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	      xmlns:foo="http://www.broadbase.com/foo" 
        extension-element-prefixes="msxsl"
        exclude-result-prefixes="foo" 
        xmlns:user="urn:vb-scripts">
  
  <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  <xsl:include href="..\..\..\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <msxsl:script language="vb" implements-prefix="user">
    <msxsl:assembly name="System.Web"/>
    <msxsl:using namespace="System.Web" />
    <![CDATA[
            Dim nvFW_interOp As Object = HttpContext.current.application.contents("_nvFW_interOp")

            Public function getfiltrosXML() As String
            Page.contents("filtroverTransf_log_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_subproc'><campos>distinct esSubproceso,id_transf_log_dep,id_transf_log,fe_inicio,fe_fin,estado,id_transferencia,nombre,operador_det,Login_det, nombre_operador,resumen </campos><filtro></filtro><orden>id_transf_log_dep,id_transf_log</orden></select></criterio>")

		        return ""
            End Function

		    Dim a As String = getfiltrosXML()
		]]>
  </msxsl:script>
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
        
        function MMDDYYYY(strFecha) 
         {
          return strFecha.split('/')[1] + '/' + strFecha.split('/')[0] + '/' + strFecha.split('/')[2]
         }
        
        function getDuracion(str_fe_inicio, str_fe_fin) 
        {
          try {
              if (str_fe_inicio == null || str_fe_fin == null)
                  return ''
              var fe_fin
              var fe_inicio
              if(str_fe_fin == 'hoy')
                fe_fin = new Date((new Date().getTime()))
              else
                fe_fin = new Date(MMDDYYYY(str_fe_fin).split(' ')[0] + " " + str_fe_fin.split(' ')[1])
                 
              fe_inicio = new Date(MMDDYYYY(str_fe_inicio).split(' ')[0] + " " + str_fe_inicio.split(' ')[1])

              var diferencia = (fe_fin.getTime() - fe_inicio.getTime()) / 1000

              var dias = Math.floor(diferencia / 86400)
              diferencia = diferencia - (86400 * dias)

              var horas = Math.floor(diferencia / 3600)
              diferencia = diferencia - (3600 * horas)

              var minutos = Math.floor(diferencia / 60)
              diferencia = diferencia - (60 * minutos)

              var segundos = Math.floor(diferencia)

              var str_durac = ''
              str_durac = dias > 0 ? dias.toString() + ' días -' : ''
              str_durac = str_durac + '' + (horas >= 0 ? ' ' + (horas < 10 ? ('0' + horas.toString()) : horas.toString()) + ':' : '').toString()
              str_durac = str_durac + '' +(minutos >= 0 ? '' + (minutos < 10 ? ('0' + minutos.toString()) : minutos.toString()) + ':' : '').toString()
              str_durac = str_durac + '' +(segundos >= 0 ? '' + (segundos < 10 ? ('0' + segundos.toString()) : segundos.toString()) : '').toString()
          }
          catch (e) { str_durac = '' }

          return str_durac
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

        <script type="text/javascript"  src="/FW/transferencia/script/transf_seg_utiles.js" language="javascript"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script type="text/javascript" src="/FW/script/tError.js" language="JavaScript"></script>
        
        <script language="javascript" type="text/javascript">
          <xsl:comment>
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
         </xsl:comment>
        </script>
				<!--definicion del template por defecto-->

        <script language="javascript" type="text/javascript">
          <xsl:comment>
          <![CDATA[
          
          function window_onload()
		  {
		 	 window_onresize()
		  }
                              
         function window_onresize()
            {
             try
			          {
			           var dif = Prototype.Browser.IE ? 5 : 2
			           var body_height = $$('body')[0].getHeight()
			           var tbCabe_height = $('tbCabe').getHeight()
		             var divPie_height = $('divPie').getHeight()
			           $('divRow').setStyle({height: body_height - tbCabe_height - divPie_height - dif + 'px'})
			     
                 campos_head.resize("tbCabe", "tbRow")
			          }
			        catch(e){}
            }

       
			 function nodo_onclick(id_transf_log)
				 { 
			    var contenedor = $('trSubproc' + id_transf_log)
					var img = $('img' + id_transf_log)

          if (contenedor.style.display == 'none') {
				    img.src = '/fw/image/security/menos.gif'
						contenedor.show()
            exportar_plantilla(id_transf_log)
					}
					else {
					  img.src = '/fw/image/security/mas.gif'
						contenedor.hide()
			    }
        }
       
       function exportar_plantilla(id_transf_log)
			    {
                    var filtroWhere = "<criterio><select><campos></campos><filtro><id_transf_log_dep type='igual'>"+ id_transf_log +"</id_transf_log_dep></filtro><orden></orden></select></criterio>"
                    var path_xsl = "\\report\\transferencia\\verTransf_log\\HTML_verTransf_seg.xsl"

                    nvFW.exportarReporte({
                          filtroXML: parent.nvFW.pageContents.filtroverTransf_log_subproc
                        , filtroWhere: filtroWhere
                        , path_xsl: path_xsl
                        , formTarget: 'iframeSubproc' + id_transf_log
                        , nvFW_mantener_origen: true
                        , id_exp_origen: 0
                        , bloq_contenedor: 'iframeSubproc' + id_transf_log
                        , cls_contenedor: 'iframeSubproc' + id_transf_log
                        , cls_contenedor_msg: ' '
                        , bloq_msg: 'Cargando...'
                    })
		        }
       
		   function verXMLResultado(id_transf_log)
		    { 
          //parent.exportarXML(id_transf_log)
        
  	      $('formXML').XML_id_transf_log.value = id_transf_log
		      $('formXML').submit()
	        }
          
       function mostrar_transf(id_transf_log)
       {
         
         if(parent.mostrar_transf)
           parent.mostrar_transf(id_transf_log)
         
         if(parent.mostrar_transf)
           parent.parent.mostrar_transf(id_transf_log)
         
       }
      ]]>
          </xsl:comment>
        </script>

			</head>
         <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCabe" >
        <tr class="tbLabel">
                    <td style="width:4%;text-align:center">&#160;-&#160;</td>
                    <td style='width:10%;text-align:center'>
                      <script>
                        campos_head.agregar('Estado', true, 'estado')
                      </script>
                    </td>
                    <td style='width:5%;text-align:center'  nowrap='nowrap'>
                        <script>
                            campos_head.agregar('Id. log.', true, 'id_transf_log')
                        </script>
                    </td>
			        <td style='width:10%;text-align:center'  nowrap='nowrap'>
                        <script>
                            campos_head.agregar('Fe. Inicio', true, 'fe_inicio')
                        </script>
                    </td>
                    <td style='width:10%;text-align:center' nowrap='nowrap'>
                        <script>
                            campos_head.agregar('Fe. Fin', true, 'fe_fin')
                        </script>
                    </td>
			        <td style='width:5%;text-align:center'>
                        <script>
                            campos_head.agregar('Duración', true, 'time_seg')
                        </script>
                    </td>
                    <xsl:if test ="count(/xml/rs:data[z:row/@resumen != '']) > 0">
                      <td>
                          <script>
                            campos_head.agregar('Resumen', true, 'resumen')
                          </script>
                      </td>
                    </xsl:if>
                    <td>
                        <script>
                            campos_head.agregar('id transferencia.', true, 'id_transferencia')
                            campos_head.agregar('Nombre', true, 'nombre')
                        </script>
                    </td>
                    <td style='width:10%;text-align:center'>
                        <script>
                            campos_head.agregar('Operador', true, 'nombre_operador')
                        </script>
                    </td>
                    <td class="Tit1" style='text-align:center;width:5%;'>&#160;-&#160;</td>
                    <td class="Tit1" style='text-align:center;width:5%;'>&#160;-&#160;</td>
                    <td class="Tit1" style='text-align:center;width:5%;'>&#160;-&#160;</td>
                    <td class="Tit1" style='text-align:center;width:5%;'>&#160;-&#160;</td>
        </tr>
 		    </table>
        <div style="width:100%;overflow:auto" id="divRow">
          <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>

      <div id="divPie" class="divPages">
        <script type="text/javascript">
          document.write(campos_head.paginas_getHTML())
        </script>
      </div>

      <script type="text/javascript">
          campos_head.resize("tbCabe", "tbRow")
        </script>
           <form id="formXML" name="formXML" target="_blank"  action="/FW/transferencia/XML_resultado.aspx" style="display:none" method="post">
             <input name="XML_id_transf_log" id="XML_id_transf_log"/>
           </form>
	  </body>
	</html>
	 </xsl:template>

	
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="id_transf_log" select="@id_transf_log"></xsl:variable>
    <xsl:variable name="str_fe_inicio" select="concat(foo:FechaToSTR(string(@fe_inicio)),' ',foo:HoraToSTR(string(@fe_inicio)))"/>
    <xsl:variable name="str_fe_fin" select="concat(foo:FechaToSTR(string(@fe_fin)),' ',foo:HoraToSTR(string(@fe_fin)))"/>

    <tr>
      <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
    
      <td style="width:5%;text-align:center">
        <xsl:if test ="@esSubproceso = 0 and @tieneSubprocesos = 1">
          <img border='0' align='absmiddle' hspace='1'>
            <xsl:attribute name='src'>/fw/image/icons/mas.gif</xsl:attribute>
            <xsl:attribute name='id'>img<xsl:value-of select="$id_transf_log" /></xsl:attribute>
            <xsl:attribute name="onclick">nodo_onclick('<xsl:value-of select="$id_transf_log" />')</xsl:attribute>
          </img>
        </xsl:if>
        <xsl:if test ="@esSubproceso = 1 or @tieneSubprocesos = 0">
          <img border='0' align='absmiddle' hspace='1'>
            <xsl:attribute name='src'>/fw/image/icons/punto.gif</xsl:attribute>
          </img>
        </xsl:if>
        <img border='0' align='absmiddle' hspace='1'>
             <xsl:choose>
                 <xsl:when test='@estado = "finalizado"'>
                     <xsl:attribute name='src'>/fw/image/transferencia/seg_fin.png</xsl:attribute>
                 </xsl:when>
                 <xsl:when test='@estado = "Pendiente"'>
                     <xsl:attribute name='src'>/fw/image/transferencia/seg_pen.png</xsl:attribute>
                 </xsl:when>
               <xsl:when test='@estado = "error"'>
                 <xsl:attribute name='src'>/fw/image/transferencia/seg_err.png</xsl:attribute>
               </xsl:when>
                 <xsl:otherwise>
                     <xsl:attribute name='src'>/fw/image/transferencia/seg_ini.png</xsl:attribute>
                 </xsl:otherwise>
             </xsl:choose>
         </img>
        </td>
      <td style='width:5%;'>
        <xsl:choose>
          <xsl:when test='@estado = "finalizado"'>
            <xsl:attribute name='style'>text-align:center;color:green;width:5%</xsl:attribute>
            <xsl:value-of select="@estado"/>
          </xsl:when>
          <xsl:when test='@estado = "Pendiente"'>
            <xsl:attribute name='style'>text-align:center;color:blue;width:5%</xsl:attribute>
            <xsl:value-of select="@estado"/>
          </xsl:when>
          <xsl:when test='@estado = "ejecutando"'>
            <xsl:attribute name='style'>text-align:center;width:5%</xsl:attribute>
            <img border='0' align='absmiddle' hspace='1'>
              <xsl:attribute name='src'>/fw/image/transferencia/spinner24x24_azul.gif</xsl:attribute>
            </img>
          </xsl:when>
          <xsl:when test='@estado = "iniciando"'>
            <xsl:attribute name='style'>text-align:center;width:5%</xsl:attribute>
            <img border='0' align='absmiddle' hspace='1'>
              <xsl:attribute name='src'>/fw/image/transferencia/spinner24x24_azul.gif</xsl:attribute>
            </img>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name='style'>text-align:center;color:red;width:5%</xsl:attribute>
            <xsl:value-of select="@estado"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
        <td style='width:5%;text-align:right'>
            <xsl:value-of select="$id_transf_log"/>
        </td>
		 <td style='width:10%;'>
           <xsl:attribute name='title'>Tiempo Estimado: <xsl:value-of select="foo:getDuracion($str_fe_inicio,$str_fe_fin)"/></xsl:attribute>
          <xsl:value-of select="foo:FechaToSTR(string(@fe_inicio))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_inicio))"/>
        </td>
        <td style='width:10%;'>
           <xsl:attribute name='title'>Tiempo Estimado: <xsl:value-of select="foo:getDuracion($str_fe_inicio,$str_fe_fin)"/></xsl:attribute>
          <xsl:value-of select="foo:FechaToSTR(string(@fe_fin))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_fin))"/>
        </td>
        <td style='width:5%;text-align:right'>
            <xsl:if test='string(@time_seg) != ""'>
                <xsl:value-of select="foo:getDuracion($str_fe_inicio,$str_fe_fin)"/>
            </xsl:if>
        </td>		
      <xsl:if test ="count(/xml/rs:data[z:row/@resumen != '']) > 0">
        <td>
          <xsl:if test ="string(@resumen) != ''">
            <xsl:attribute name='title'>
              <xsl:value-of select="@resumen"/>
            </xsl:attribute>
            <xsl:value-of select="@resumen"/>
          </xsl:if>
        </td>
      </xsl:if>
		    <td>
            <xsl:if test='string(@nombre) != ""'>
                <xsl:attribute name='title'>(<xsl:value-of select="@id_transferencia"/>) - <xsl:value-of select="@nombre"/></xsl:attribute>
                (<xsl:value-of select="@id_transferencia"/>) - <xsl:value-of select="@nombre"/>
            </xsl:if>
		    </td>
        <td style='width:10%;'>
            <xsl:if test='string(@nombre_operador) != ""'>
                <xsl:attribute name='title'>
                    <xsl:value-of select="@nombre_operador"/>
                </xsl:attribute>
                <xsl:value-of select="@nombre_operador"/>
            </xsl:if>
        </td>
        <td style="text-align:center; width:5%" >
            <img>
                <xsl:attribute name="onclick">mostrar_transf('<xsl:value-of select="$id_transf_log" />')</xsl:attribute>
                <xsl:attribute name="src">/FW/image/transferencia/ojo.png</xsl:attribute>
                <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
				<xsl:attribute name="title">Seguir</xsl:attribute>
            </img>
        </td>
       <td style="text-align:center; width:5%" >
            <a target='_blank'>
                <xsl:attribute name="href">/fw/transferencia/transferencia_abm.aspx?id_transferencia=<xsl:value-of select="@id_transferencia"/></xsl:attribute>
                <img>
                <xsl:attribute name="src">/FW/image/transferencia/editar.png</xsl:attribute>
                <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
				<xsl:attribute name="border">0</xsl:attribute>
				<xsl:attribute name="title">Editar</xsl:attribute>
            </img>
          </a> 
        </td>
		<td style="text-align:center; width:5%">
			<xsl:choose>
				<xsl:when test='@estado != "finalizado" and @estado != "Pendiente" and @estado != "error"'>
					<img>
						<xsl:attribute name="onclick">parent.finalizar_transf('<xsl:value-of select="$id_transf_log" />','btnMostrar_transferencia()')</xsl:attribute>
						<xsl:attribute name="src">/FW/image/transferencia/eliminar.png</xsl:attribute>
						<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
						<xsl:attribute name="title">Finalizar Seguimiento</xsl:attribute>
					</img>				
				</xsl:when>
				<xsl:otherwise>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>
    <td style="text-align:center; width:28px">
					<img>
						<xsl:attribute name="onclick">
							verXMLResultado('<xsl:value-of select="$id_transf_log" />')
						</xsl:attribute>
						<xsl:attribute name="src">/FW/image/docs/xml.png</xsl:attribute>
						<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
						<xsl:attribute name="title">Ver XML Resultado</xsl:attribute>
					</img>
		</td>
      </tr>
    <tr id='trSubproc{$id_transf_log}' style='display: none;'>
      <td style="width: 3%;">&#160;</td>
      <td colspan="11">
        <iframe id="iframeSubproc{$id_transf_log}" name="iframeSubproc{$id_transf_log}" style="width: 100%; overflow-y: auto; height: 180px; border: none;"></iframe>
      </td>
    </tr>
    </xsl:template>
	
</xsl:stylesheet>