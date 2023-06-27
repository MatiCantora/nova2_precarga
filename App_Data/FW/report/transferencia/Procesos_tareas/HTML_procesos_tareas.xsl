<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl" />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
           function MMDDYYYY(strFecha) 
         {
          return strFecha.split('/')[1] + '/' + strFecha.split('/')[0] + '/' + strFecha.split('/')[2]
         }
        
        function getDuracion(str_fe_inicio, str_fe_fin) 
        {
          try {
    
              if (str_fe_fin == null && str_fe_inicio == null)
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
              str_durac = dias > 0 ? dias.toString() + ' d�as -' : ''
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
        <title>HTML Procesos Tareas</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
        <!--<link href="/FW/css/btnSvr.css" type="text/css" rel="stylesheet" />-->
        <!--<link href="/FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />-->
        <!--<link href="/FW/css/window_themes/default.css" rel="stylesheet" type="text/css" />-->
        <!--<link href="/FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />-->
       
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>

        <script type="text/javascript"  src="/FW/transferencia/script/transf_seg_utiles.js" language="javascript"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        
        <script language="javascript" type="text/javascript">
          <xsl:comment>
            var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'
            campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
            campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID"/>'
            campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl"/>'
            campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
            campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount"/>
            campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize"/>
            campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage"/>
            campos_head.orden         = '<xsl:value-of select="xml/params/@orden"/>'
            var control_estado        = '<xsl:value-of select="xml/parametros/control_estado"/>'
            
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

     
]]>
        </xsl:comment>
        </script>
			</head>
         <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				 <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCabe">
                <tr class="tbLabel">
                  <xsl:choose>
                    <xsl:when test="string(/xml/rs:data/z:row/@id_transf_log) != ''">
                      <xsl:if test ="count(/xml/rs:data[z:row/@resumen != '']) > 0">
                        <td style='width:15%;text-align:center'>
                          <script  type="text/javascript">
                            campos_head.agregar('Resumen', true, 'resumen')
                          </script>
                        </td>
                      </xsl:if >
                      <td style='width:15%;text-align:center'>
                        <script  type="text/javascript">
                          campos_head.agregar('Usuario', true, 'login_det')
                        </script>
                      </td>
                      <xsl:if test="/xml/parametros/control_estado = 'ejecutando' or /xml/parametros/control_estado = 'pendiente' or /xml/parametros/control_estado = 'terminado'">
                        <td>
                          <xsl:if test="/xml/parametros/control_estado = 'ejecutando'">
                            <xsl:attribute name="style">width:15%;text-align:center</xsl:attribute>
                            <script  type="text/javascript">
                              campos_head.agregar('Tiempo Transcurrido', true, 'fe_ini')
                            </script>
                          </xsl:if>
                          <xsl:if test="/xml/parametros/control_estado = 'pendiente'">
                            <xsl:attribute name="style">width:15%;text-align:center</xsl:attribute>
                            <script  type="text/javascript">
                              campos_head.agregar('Pendiente desde', true, 'fe_fin')
                            </script>
                          </xsl:if>
                          <xsl:if test="/xml/parametros/control_estado = 'terminado'">
                            <xsl:attribute name="style">width:20%;text-align:center</xsl:attribute>
                            <script  type="text/javascript">
                              campos_head.agregar('Iniciado ', true, 'fe_ini_transf');campos_head.agregar('Finalizado', true, 'fe_fin_transf')
                            </script>
                          </xsl:if>
                        </td>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                  </xsl:choose>
                      <td style="text-align:center">
                        <xsl:if test ="count(/xml/rs:data/z:row[@resumen != '']) > 0">
                          <xsl:attribute name="style">width:15%;text-align:center</xsl:attribute>
                        </xsl:if>
                        <script  type="text/javascript">
                          campos_head.agregar('Procesos', true, 'descripcion')
                        </script>
                      </td>
                  
                      <xsl:if test ="string(/xml/rs:data/z:row/@transf_pt_param1_eti) != ''">
                      <td nowrap='nowrap' style='width:10%;text-align:center'>
                        <script  type="text/javascript">
                            campos_head.agregar("<xsl:value-of select="/xml/rs:data/z:row/@transf_pt_param1_eti"/>", true, 'transf_pt_param1')
                        </script>
                      </td>
                      </xsl:if>
                      <xsl:if test ="string(/xml/rs:data/z:row/@transf_pt_param2_eti) != ''">
                      <td nowrap='nowrap' style='width:10%;text-align:center'>
                        <script  type="text/javascript">
                          campos_head.agregar("<xsl:value-of select="/xml/rs:data/z:row/@transf_pt_param2_eti"/>", true, 'transf_pt_param2')
                        </script>
                      </td>
                      </xsl:if>
                      <xsl:if test ="string(/xml/rs:data/z:row/@transf_pt_param3_eti) != ''">
                      <td nowrap='nowrap' style='width:10%;text-align:center'>
                        <script  type="text/javascript">
                          campos_head.agregar("<xsl:value-of select="/xml/rs:data/z:row/@transf_pt_param3_eti"/>", true, 'transf_pt_param3')
                        </script>
                      </td>
                      </xsl:if>
                  <xsl:if test='count(/xml/rs:data[string(z:row/@tiene_permiso_edicion) = "True"]) > 0'>
                    <td style='width:8%;text-align:center'>Edici�n</td>
                  </xsl:if>
                  <xsl:if test='count(/xml/rs:data[z:row/@id_transf_log > 0]) > 0'>
                    <td style='width:8%;text-align:center'>Seguimiento</td>
                  </xsl:if>
                  <xsl:if test ="/xml/parametros/control_estado != 'terminado'  and /xml/parametros/control_estado != 'ejecutando'">
                    <td style='width:10%;text-align:center'>-</td>
                  </xsl:if>
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
           <script type="text/javascript">
             campos_head.resize("tbCabe", "tbRow")
           </script>
         </div>
	  </body>
	</html>
	 </xsl:template>

	
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="id_transf_log" select="@id_transf_log"></xsl:variable>
    <xsl:variable name="str_fe_ini" select="concat(foo:FechaToSTR(string(@fe_ini)),' ',foo:HoraToSTR(string(@fe_ini)))"/>
    <xsl:variable name="str_fe_fin" select="concat(foo:FechaToSTR(string(@fe_fin)),' ',foo:HoraToSTR(string(@fe_fin)))"/>
    <xsl:variable name="str_fe_consulta" select="concat(foo:FechaToSTR(string(@fe_consulta)),' ',foo:HoraToSTR(string(@fe_consulta)))"/>
    
    <tr>
      <xsl:attribute name="id">id_transf_log_<xsl:value-of select="$id_transf_log"/></xsl:attribute>
      <xsl:attribute name="style">cursor:hand;cursor:pointer;
      <xsl:choose>
        <xsl:when test ="/xml/parametros/control_estado = 'ejecutando'">
          color:red
        </xsl:when>
        <xsl:when test ="/xml/parametros/control_estado = 'pendiente'">
          color:blue
        </xsl:when>
        <xsl:when test ="/xml/parametros/control_estado = 'iniciar'">
          color:green
        </xsl:when>
      </xsl:choose>
     </xsl:attribute>
     <xsl:choose>
        <xsl:when test="string(@id_transf_log) != ''">
          <xsl:if test ="count(/xml/rs:data[z:row/@resumen != '']) > 0">
            <td>
               <xsl:if test ="string(@resumen) != ''">
                <xsl:attribute name='title'><xsl:value-of select="@resumen"/></xsl:attribute>
                <xsl:value-of select="@resumen"/>
               </xsl:if>
            </td>
          </xsl:if>
          <td>
            <xsl:attribute name="style">width:15%</xsl:attribute>
            <xsl:attribute name='title'>
              <xsl:value-of select="@login_det"/>
            </xsl:attribute>
            <xsl:value-of select="@login_det"/>
          </td>
          <xsl:if test="/xml/parametros/control_estado = 'ejecutando' or /xml/parametros/control_estado = 'pendiente' or /xml/parametros/control_estado = 'terminado'">
          <td>
            <xsl:attribute name="id">td_id_transf_log_<xsl:value-of select="$id_transf_log"/></xsl:attribute>
            <xsl:if test="/xml/parametros/control_estado = 'ejecutando'">
              <xsl:attribute name="style">width:15%</xsl:attribute>
              <xsl:attribute name='title'>Tiempo Transcurrido: <xsl:value-of select="foo:getDuracion($str_fe_ini,$str_fe_consulta)"/></xsl:attribute>
              <span>
                 <xsl:attribute name="id">span_id_transf_log_<xsl:value-of select="$id_transf_log"/>_fecha</xsl:attribute>
                 <xsl:value-of select="foo:getDuracion($str_fe_ini,$str_fe_consulta)"/>
              </span>
            </xsl:if>
            <xsl:if test="/xml/parametros/control_estado = 'pendiente'">
             <xsl:attribute name="style">width:15%</xsl:attribute>
              <xsl:attribute name='title'>
               <xsl:value-of select="$str_fe_fin"/>&#160;Tiempo Transcurrido: <xsl:value-of select="foo:getDuracion($str_fe_fin,$str_fe_consulta)"/>
              </xsl:attribute>
            <xsl:value-of select="foo:FechaToSTR(string(@fe_fin))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_fin))"/>
            </xsl:if>
            <xsl:if test="/xml/parametros/control_estado = 'terminado'">
              <xsl:attribute name="style">width:20%</xsl:attribute>
              <xsl:attribute name='title'>inicio: <xsl:value-of select="foo:FechaToSTR(string(@fe_ini_transf))"/> - Fin: <xsl:value-of select="foo:FechaToSTR(string(@fe_fin_transf))"/>
              </xsl:attribute>
              <xsl:value-of select="foo:FechaToSTR(string(@fe_ini_transf))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_ini_transf))"/>&#160;al&#160;<xsl:value-of select="foo:FechaToSTR(string(@fe_fin_transf))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_fin_transf))"/>
            </xsl:if>
            <input>
                <xsl:attribute name="id">id_transf_log_<xsl:value-of select="$id_transf_log"/>_fecha</xsl:attribute>
                <xsl:attribute name="type">hidden</xsl:attribute>
                <xsl:attribute name="value"><xsl:value-of select="$str_fe_ini"/></xsl:attribute>
              </input>
          </td>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
      <td>
         <xsl:if test ="count(/xml/rs:data/z:row[@resumen != '']) > 0">
             <xsl:attribute name="style">width:15%</xsl:attribute>
        </xsl:if>
        <!--<xsl:attribute name="onclick">parent.grupos_procesos_tareas_abm(<xsl:value-of select="@nro_transf_pt_ref"/>)</xsl:attribute >-->
        <xsl:if test ="/xml/parametros/control_estado != 'terminado' and /xml/parametros/control_estado != 'ejecutando'">
          <xsl:attribute name="onclick">
            parent.detalle_dibujar('<xsl:value-of select="$id_transf_log"/>','<xsl:value-of select="@id_transferencia"/>','<xsl:value-of select="@nombre"/>',event)
          </xsl:attribute>
        </xsl:if>        <xsl:attribute name='title'><xsl:value-of select="@descripcion"/></xsl:attribute>
        <xsl:value-of select="@descripcion"/>
      </td>
      <xsl:if test ="string(/xml/rs:data/z:row/@transf_pt_param1_eti) != ''">
      <td>
        <xsl:attribute name="style">cursor:hand;cursor:pointer;width:10%</xsl:attribute >
        <!--<xsl:attribute name="onclick">parent.grupos_procesos_tareas_abm(<xsl:value-of select="@nro_transf_pt_ref"/>)</xsl:attribute >-->
        <xsl:if test ="/xml/parametros/control_estado != 'terminado' and /xml/parametros/control_estado != 'ejecutando'">
          <xsl:attribute name="onclick">
            parent.detalle_dibujar('<xsl:value-of select="$id_transf_log"/>','<xsl:value-of select="@id_transferencia"/>','<xsl:value-of select="@nombre"/>',event)
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name='title'>
          <xsl:value-of select="@transf_pt_param1"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="string-length(@transf_pt_param1) = 0">
            &#160;
          </xsl:when>
          <xsl:otherwise>
           <xsl:value-of select="@transf_pt_param1"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      </xsl:if >
        <xsl:if test ="string(/xml/rs:data/z:row/@transf_pt_param2_eti) != ''">
          <td>
            <xsl:attribute name="style">cursor:hand;cursor:pointer;width:10%</xsl:attribute >
            <!--<xsl:attribute name="onclick">parent.grupos_procesos_tareas_abm(<xsl:value-of select="@nro_transf_pt_ref"/>)</xsl:attribute >-->
            <xsl:if test ="/xml/parametros/control_estado != 'terminado' and /xml/parametros/control_estado != 'ejecutando'">
              <xsl:attribute name="onclick">
                parent.detalle_dibujar('<xsl:value-of select="$id_transf_log"/>','<xsl:value-of select="@id_transferencia"/>','<xsl:value-of select="@nombre"/>',event)
              </xsl:attribute>
            </xsl:if>
            <xsl:attribute name='title'>
              <xsl:value-of select="@transf_pt_param2"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="string-length(@transf_pt_param2) = 0">
                &#160;
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@transf_pt_param2"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </xsl:if >
       <xsl:if test ="string(/xml/rs:data/z:row/@transf_pt_param3_eti) != ''">
       <td>
        <xsl:attribute name="style">cursor:hand;cursor:pointer;width:10%</xsl:attribute >
        <!--<xsl:attribute name="onclick">parent.grupos_procesos_tareas_abm(<xsl:value-of select="@nro_transf_pt_ref"/>)</xsl:attribute >-->
         <xsl:if test ="/xml/parametros/control_estado != 'terminado' and /xml/parametros/control_estado != 'ejecutando'">
           <xsl:attribute name="onclick">parent.detalle_dibujar('<xsl:value-of select="$id_transf_log"/>','<xsl:value-of select="@id_transferencia"/>','<xsl:value-of select="@nombre"/>',event)</xsl:attribute>
         </xsl:if>
         <xsl:attribute name='title'>
          <xsl:value-of select="@transf_pt_param3"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="string-length(@transf_pt_param3) = 0">
            &#160;
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@transf_pt_param3"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      </xsl:if>
      <xsl:if test='count(/xml/rs:data[string(z:row/@tiene_permiso_edicion) = "True"]) > 0'>
      <td>
        <xsl:attribute name="style">text-align:center;width:8%</xsl:attribute>

        <xsl:choose>
          <xsl:when test='string(@tiene_permiso_edicion) = "True"'>
           <xsl:attribute name="style">text-align:center;width:8%</xsl:attribute>
  				 <xsl:if test='@estado_det != "terminado" and @estado_det != "finalizado" and @estado_det != "iniciar"'>
            <img>
             <xsl:attribute name="onclick">parent.finalizar_transf('<xsl:value-of select="$id_transf_log" />','onclick_buscar()')</xsl:attribute>
             <xsl:attribute name="src">/FW/image/icons/eliminar.png</xsl:attribute>
             <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
             <xsl:attribute name="title">Finalizar Proceso</xsl:attribute>
           </img>
	  	 		</xsl:if>
          <img>
            <xsl:attribute name="onclick">parent.transferencia_abm('<xsl:value-of select="@id_transferencia"/>')</xsl:attribute>
						<xsl:attribute name="src">/FW/image/icons/editar.png</xsl:attribute>
						<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
						<xsl:attribute name="title">Transferencia ABM</xsl:attribute>
          </img>
       </xsl:when>
       <xsl:otherwise>
         &#160;
       </xsl:otherwise>
      </xsl:choose>
      </td>
      </xsl:if>
      <xsl:if test='$id_transf_log != ""'>
       <td style="text-align:center; width:8%">
          <xsl:choose>
          <xsl:when test='@estado_det != "iniciar"'>
            <img>
              <xsl:attribute name="onclick">parent.fn_verlog({'id_transf_log': '<xsl:value-of select="$id_transf_log" />','tiene_permiso': 'true'})</xsl:attribute>
              <xsl:attribute name="src">/FW/image/transferencia/ojo.png</xsl:attribute>
              <xsl:attribute name="style">cursor:hand;cursor:pointer;</xsl:attribute>
              <xsl:attribute name="title">Seguimiento</xsl:attribute>
            </img>&#160;
          </xsl:when>
        </xsl:choose>
          <img>
            <xsl:attribute name="src">/FW/image/transferencia/comentario.png</xsl:attribute>
            <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
            <xsl:attribute name="title">Comentarios</xsl:attribute>
            <xsl:attribute name="onclick">
              parent.comentario('<xsl:value-of select="$id_transf_log" />','<xsl:value-of select="@descripcion" />. <xsl:value-of select="@resumen" />')
            </xsl:attribute>
          </img>
       </td>
      </xsl:if>

      <xsl:choose>
        <xsl:when test ="/xml/parametros/control_estado != 'terminado' and /xml/parametros/control_estado != 'ejecutando'">
           <td style="text-align:center; width:10% !Important" >
                <div>
                   <xsl:attribute name="id">divProcesar<xsl:value-of select="$pos"/></xsl:attribute>
                </div>
                <script type="text/javascript">
                  <xsl:comment>
                    if("<xsl:value-of select="@estado_det"/>" != "terminado")
                     {
                      var vButtonItems = {};
                      vButtonItems[<xsl:value-of select="$pos"/>] = {};
                      vButtonItems[<xsl:value-of select="$pos"/>]["nombre"] = "Procesar<xsl:value-of select="$pos"/>";
                      vButtonItems[<xsl:value-of select="$pos"/>]["etiqueta"] = "Ejecutar";
                      vButtonItems[<xsl:value-of select="$pos"/>]["imagen"] = "procesar";
                      vButtonItems[<xsl:value-of select="$pos"/>]["onclick"] = "parent.detalle_dibujar('<xsl:value-of select="$id_transf_log"/>','<xsl:value-of select="@id_transferencia"/>','<xsl:value-of select="@nombre"/>',event,'<xsl:value-of select="@id_transf_pt_param1"/>','<xsl:value-of select="@id_transf_pt_param2"/>','<xsl:value-of select="@id_transf_pt_param3"/>','<xsl:value-of select="@async"/>')" 

                      var vListButtons = new tListButton(vButtonItems, 'vListButtons') 
                      vListButtons.loadImage("procesar", '/fw/image/icons/procesar.png')

                      vListButtons.MostrarListButton()
                     }
                  </xsl:comment>
                </script>
              </td>
          </xsl:when>
      </xsl:choose>
     </tr>
    </xsl:template>
	
</xsl:stylesheet>