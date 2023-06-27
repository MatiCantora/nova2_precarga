<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\FW\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <msxsl:script language="vb" implements-prefix="user">
    <msxsl:assembly name="System.Web"/>
    <msxsl:using namespace="System.Web"/>
    <![CDATA[
    Public function getFecha() As String
      Page.contents("fecha_hoy") = DateTime.Today.ToString("dd/MM/yyyy")
      return DateTime.Today.ToString("dd/MM/yyyy")
    End Function
    
    Dim a As String = getFecha()
    ]]>
  </msxsl:script>

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[]]>
  </msxsl:script>


  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

        <title>Consultar Talonarios</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>

        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>

          campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW

          var cantVinculosNv = '<xsl:value-of select="count(xml/rs:data/z:row)"></xsl:value-of>'

        </script>
        <script type="text/javascript"  language="javascript" >
          <xsl:comment>
            <![CDATA[ 
                                
                        function window_onload()
                        {
                                                        
                            var fecha_hoy = nvFW.pageContents.fecha_hoy;                            
                            //si no hay vinculos de nova, muestra solo los vinculos externos
                            
                            if (cantVinculosNv == 0) {
                            
                                var strHTML = "";

                                if (typeof parent.vinculosExternos != "undefined") {
                                    for (var i = 0; i < parent.vinculosExternos.length; i++){                                                                               

                                        var fecha_desde = parent.vinculosExternos[i].vinc_desde == "" ? "" : FechaToSTR(new Date(parent.vinculosExternos[i].vinc_desde),1);
                                        var fecha_hasta = parent.vinculosExternos[i].vinc_hasta == "" ? "" : FechaToSTR(new Date(parent.vinculosExternos[i].vinc_hasta),1);
                                                                                
                                        var color = 'black';

                                        if (fecha_hasta != '' && new Date(parent.vinculosExternos[i].vinc_hasta) < new Date(fecha_hoy))
                                            color = '#D8000C';

                                        strHTML += '<tr>'
                                        strHTML += '<td style="width: 5%; text-align: center"><img title="Ver Entidad" src="../../FW/image/icons/ver.png" style="cursor:pointer"';
                                        strHTML += ' onclick="verVinculo(event, 0, \'' + parent.vinculosExternos[i].razon_social_vinc + '\', ' + parent.vinculosExternos[i].vinc_tipocli + ', ' + parent.vinculosExternos[i].tipo_docu_vinc + ', ' + parent.vinculosExternos[i].nro_docu_vinc + ', \'\', ' + parent.vinculosExternos[i].vinc_tiporel + ')" >';
                                        strHTML += '</img></td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].vinc_grupo + '</td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].vinc_tipo + '</td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].documento_vinc + '</td>'
                                        strHTML += '<td style="text-align: right; color: ' + color + '">' + parent.vinculosExternos[i].nro_docu_vinc + '</td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].razon_social_vinc + '</td>'
                                        strHTML += '<td style="text-align: right; color: ' + color + '">' + fecha_desde + '</td>'
                                        strHTML += '<td style="text-align: right; color: ' + color + '">' + fecha_hasta + '</td>'
                                        strHTML += '<td colspan="2" style="color: #270; background-color: #DFF2BF !important">Vínculo ' + parent.vinculosExternos[i].sistema + '</td>'
                                        //strHTML += '<td></td>'
                                        strHTML += '</tr>'
                                    }
                                    $('tbDetalle').innerHTML = strHTML;
                                }
                            //si hay vinculos de nova, agrega a la plantilla los vinculos externos
                            //si es repetido, remplaza el de nova con el vinculo externo
                            } else {
                                var strHTML = "";
                                
                                for (var i = 0; i < parent.vinculosExternos.length; i++){                                                                               
                                        
                                        var fecha_desde = parent.vinculosExternos[i].vinc_desde == "" ? "" : FechaToSTR(new Date(parent.vinculosExternos[i].vinc_desde),1);
                                        var fecha_hasta = parent.vinculosExternos[i].vinc_hasta == "" ? "" : FechaToSTR(new Date(parent.vinculosExternos[i].vinc_hasta),1);
                                        
                                        var color = 'black';

                                        if (fecha_hasta != '' && new Date(parent.vinculosExternos[i].vinc_hasta) < new Date(fecha_hoy))
                                            color = '#D8000C';                                            
                                        
                                        strHTML = '<tr>'
                                        strHTML += '<td style="width: 5%; text-align: center"><img title="Ver Entidad" src="../../FW/image/icons/ver.png" style="cursor:pointer"';
                                        strHTML += ' onclick="verVinculo(event, 0, \'' + parent.vinculosExternos[i].razon_social_vinc + '\', ' + parent.vinculosExternos[i].vinc_tipocli + ', ' + parent.vinculosExternos[i].tipo_docu_vinc + ', ' + parent.vinculosExternos[i].nro_docu_vinc + ', \'\', ' + parent.vinculosExternos[i].vinc_tiporel + ')" >';
                                        strHTML += '</img></td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].vinc_grupo + '</td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].vinc_tipo + '</td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].documento_vinc + '</td>'
                                        strHTML += '<td style="text-align: right; color: ' + color + '">' + parent.vinculosExternos[i].nro_docu_vinc + '</td>'
                                        strHTML += '<td style="color: ' + color + '">' + parent.vinculosExternos[i].razon_social_vinc + '</td>'
                                        strHTML += '<td style="text-align: right; color: ' + color + '">' + fecha_desde + '</td>'
                                        strHTML += '<td style="text-align: right; color: ' + color + '">' + fecha_hasta + '</td>'
                                        strHTML += '<td colspan="2" style="color: #270; background-color: #DFF2BF !important">Vínculo ' + parent.vinculosExternos[i].sistema + '</td>'
                                        //strHTML += '<td></td>'
                                        strHTML += '</tr>'
                                        
                                        if (parent.vinculosExternos[i].coincide) {                                           
                                            document.getElementById("tr_vinculo_" + parent.vinculosExternos[i].posicion).remove();
                                        }
                                        $('tbDetalle').getElementsByTagName('tbody')[0].innerHTML += strHTML;
                                    }
                            
                                
                            }
                            
                            if (parent.nro_entidad == 0) {
                              $('div_boton_agregar').hide();
                              $('check_master').hide();
                            }  
                            
                            $('check_master').checked = parent.verTodos;
                               
                            window_onresize()                            
                            
                        } 
                        
                        function window_onresize()
                        {
                            try
                            {
                                var dif = Prototype.Browser.IE ? 5 : 2
                                body_height = $$('body')[0].getHeight()
                                cab_height = $('tbCabecera').getHeight()
                                div_pag_height = $('div_pag').getHeight()
                                
                                //$('divDetalle').setStyle({'height': body_height - cab_height - div_pag_height - dif + 'px'})
                                
                                //$('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
                            }
                            catch(e){}
                            
                            campos_head.resize('tbCabecera','tbDetalle');
                        }
                        
                        
                        function editar_vinculo(id_ent_vinc) {
                            win_abm_entidad = parent.parent.nvFW.createWindow({
                                  url: '/FW/entidades/vinculos/ent_vinculos_abm.aspx?id_ent_vinc=' + id_ent_vinc,
                                  title: '<b>ABM Vínculos</b>',
                                  minimizable: false,
                                  maximizable: false,
                                  resizable: false,
                                  draggable: true,
                                  width: 850,
                                  height: 300,                                  
                                  onClose: function (win) { if (win.options.userData.hay_modificacion) { parent.buscarVinculos() } },
                                  destroyOnClose: true
                            })

                            win_abm_entidad.showCenter(true)
                        }



                        function eliminar_vinculo(id_ent_vinc) {
                        
                              var pXML = "<ent_vinculo modo='E' id_ent_vinc='" + id_ent_vinc + "' />"
                        
                               nvFW.confirm("¿Desea eliminar realmente este vínculo?",
                                            {
                                              title: "Eliminar",
                                              onOk: function (win) {                        
                                                  nvFW.error_ajax_request('/FW/entidades/vinculos/ent_vinculos_abm.aspx', {
                                                  parameters: { paramXML: pXML },
                                                  bloq_msg: "Guardar",
                                                  onSuccess: function (err, transport) {
                                                        if (err.numError == 0) {
                                                              //var win = nvFW.getMyWindow()
                                                              //window.options.userData = { res: 'ok' }
                                                              //win.options.userData.hay_modificacion = true
                                                              //win.close()
                                                              parent.buscarVinculos()
                                                        }
                    
                                              },
                                              error_alert: true
                                            });
                                         },
                                           onCancel: function () {
                                                return;
                                           }
                              }
                            );
                        
                         }
                         
                         function verVinculo(event, vinc_nro_entidad, vinc_nombre, vinc_tipocli, vinc_tipdoc, vinc_nrodoc, vinc_nro_entidad_aux, vinc_tiporel)
                        {
                            nvFW.selection_clear()
                            parent.verVinculo(event, vinc_nro_entidad, vinc_nombre, vinc_tipocli, vinc_tipdoc, vinc_nrodoc, vinc_nro_entidad_aux, vinc_tiporel)
                        }
                      
					   
                    ]]>
          </xsl:comment>
        </script>
        <style type="text/css">
          .tr_cel TD {
          background-color: #F0FFFF !Important
          }
        </style>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
        <form name="frm1" id="frm1" style="width:100%;height:100%;overflow:hidden">
          <table class="tb1" id="tbCabecera" cellspacig="0" colspacing="0">
            <tr class="tbLabel">
              <td style='text-align: center; width:5%' >
                <input title="Ver historico" type='checkbox' id='check_master' onclick='parent.verHistoricoVinculos()'/>
              </td>
              <td style='text-align: center; width:15%' nowrap='true'>
                Grupo Vínculo
                <!--<script>
                  campos_head.agregar('Grupo Vínculo', true, 'vinc_grupo')
                </script>-->
              </td>
              <td style='text-align: center; width:14%' nowrap='true'>
                Tipo Vínc.
                <!--<script>
                  campos_head.agregar('Tipo Vínc.', true, 'vinc_tipo')
                </script>-->
              </td>
              <td style='text-align: center; width:6.5%' nowrap='true'>
                Tipo Doc.
                <!--<script>
                  campos_head.agregar('Tipo Doc.', true, 'documento_vinc')
                </script>-->
              </td>
              <td style='text-align: center; width:11.5%' nowrap='true'>
                Documento vínc.
                <!--<script>
                  campos_head.agregar('Documento vinc.', true, 'nro_docu_vinc')
                </script>-->
              </td>
              <td style='text-align: center; width:15%' nowrap='true'>
                Nombre vínc.
                <!--<script>
                  campos_head.agregar('Nombre vínc.', true, 'razon_social_vinc')
                </script>-->
              </td>
              <td style='text-align: center; width:11.5%' nowrap='true'>
                Desde
                <!--<script>
                  campos_head.agregar('Desde', true, 'vinc_desde')
                </script>-->
              </td>
              <td style='text-align: center; width:11.5%' nowrap='true'>
                Hasta
                <!--<script>
                  campos_head.agregar('Hasta', true, 'vinc_hasta')
                </script>-->
              </td>
              <td style='text-align: center; width:5%' ></td>
              <td style='text-align: center; width:5%' ></td>
              <!--<td style='width:14px'>&#160;</td>-->
            </tr>
          </table>

          <div id='divDetalle' style="width:100%; overflow:auto">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
              <xsl:apply-templates select="xml/rs:data/z:row" />
            </table>
          </div>

          <div id="div_boton_agregar" style="margin-top: 0.5em;">
            <center>
              <img onclick="window.parent.agregar_vinculo()" src="/FW/image/icons/agregar.png" style="cursor:pointer" title="Agregar Vínculo" />
            </center>
          </div>


          <!-- DIV DE PAGINACION -->
          <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; background: #FFFFFF; height: 18px;">
            <script type="text/javascript">
              if (campos_head.PageCount > 1)
              document.write(campos_head.paginas_getHTML())
            </script>
          </div>

        </form>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position() - 1"/>

    <tr id="tr_vinculo_{$pos}">

      <!--<xsl:choose>
        <xsl:when test="@nro_entidad > 0">-->

      <td style="width: 5%; text-align: center">
        <img title="Ver Entidad" src="../../FW/image/icons/ver.png" style="cursor:pointer">
          <xsl:choose>
            <xsl:when test="@origen != 'Nova' and @origen != ''">
              <xsl:attribute name="onclick">
                verVinculo(event, '', '<xsl:value-of select="@razon_social_vinc"/>', '<xsl:value-of select="@vinc_tipocli"/>', '<xsl:value-of select="@tipo_docu_vinc"/>', '<xsl:value-of select="@nro_docu_vinc"/>', '<xsl:value-of select="@nro_entidad_vinc"/>', '<xsl:value-of select="@vinc_tiporel"/>')
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="onclick">
                verVinculo(event, '<xsl:value-of select="@nro_entidad_vinc"/>', '<xsl:value-of select="@razon_social_vinc"/>', '<xsl:value-of select="@vinc_tipocli"/>', '<xsl:value-of select="@tipo_docu_vinc"/>', '<xsl:value-of select="@nro_docu_vinc"/>', '<xsl:value-of select="@vinc_tiporel"/>')
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </img>
        <script>
          parent.vinculosArray['<xsl:value-of select="$pos"/>'] = {
          razon_social_vinc: '<xsl:value-of select="@razon_social_vinc"/>',
          vinc_tipocli: '<xsl:value-of select="@vinc_tipocli"/>',
          tipo_docu_vinc:'<xsl:value-of select="@tipo_docu_vinc"/>',
          nro_docu_vinc: '<xsl:value-of select="@nro_docu_vinc"/>',
          nro_entidad_vinc:'<xsl:value-of select="@nro_entidad_vinc"/>',
          vinc_grupo: '<xsl:value-of select="@vinc_grupo"/>',
          nro_vinc_grupo: '<xsl:value-of select="@nro_vinc_grupo"/>',
          vinc_tipo: '<xsl:value-of select="@vinc_tipo"/>',
          nro_vinc_tipo: '<xsl:value-of select="@nro_vinc_tipo"/>',
          vinc_baja: '<xsl:value-of select="@vinc_baja"/>'}

        </script>
        <script language="javascript" type="text/javascript">
          <![CDATA[ 
                  
                  var pos = ]]>'<xsl:value-of select="$pos"/>'<![CDATA[          
            
          if (typeof parent.vinculosExternos != "undefined") {
          
          for(var i = 0; i < parent.vinculosExternos.length; i++) {
          
              if (parent.vinculosExternos[i].tipo_docu_vinc == parent.vinculosArray[pos].tipo_docu_vinc &&
                  parent.vinculosExternos[i].nro_docu_vinc == parent.vinculosArray[pos].nro_docu_vinc &&
                  parent.vinculosExternos[i].nro_vinc_tipo == parent.vinculosArray[pos].nro_vinc_tipo &&
                  parent.vinculosArray[pos].vinc_baja == ''){
                  
                parent.vinculosExternos[i].coincide = 1; parent.vinculosExternos[i].posicion = pos;                
              } else { if (parent.vinculosExternos[i].coincide != 1) parent.vinculosExternos[i].coincide = 0; }

            }
                                   
          }
            
          
          
       ]]>
        </script>
      </td>

      <!--</xsl:when>
        <xsl:otherwise>
          <td style="width: 5%; text-align: center"></td>
        </xsl:otherwise>
      </xsl:choose>-->

      <td style='text-align: left; width:15%'>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@vinc_grupo"/>
      </td>
      <td style='text-align: left; width:14%'>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@vinc_tipo"/>
      </td>
      <td style='text-align: left; width:6.5%'>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@documento_vinc"/>
      </td>
      <td style='text-align: right; width:11.5%'>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;text-align: right; width:11.5%'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@nro_docu_vinc"/>
      </td>
      <td style='text-align: left; width:15%'>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@razon_social_vinc"/>
      </td>
      <td style='text-align: right; width:11.5%'>
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@vinc_desde))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@vinc_desde))"/>
        </xsl:attribute>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;text-align: right; width:11.5%'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="foo:FechaToSTR(string(@vinc_desde))"/>
      </td>
      <td style='text-align: right; width:11.5%'>
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@vinc_hasta))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@vinc_hasta))"/>
        </xsl:attribute>
        <xsl:if test="@vinc_baja != '' or foo:fecha_vencida(string(@vinc_hasta))">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: #D8000C;text-align: right; width:11.5%'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="foo:FechaToSTR(string(@vinc_hasta))"/>
      </td>
      <xsl:choose>
        <xsl:when test="@nro_entidad > 0">
          <td style='text-align: center; width:5%'>
            <xsl:if test="not(@vinc_baja != '')">
              <img title="Editar Vínculo" src="../../fw/image/icons/editar.png" style="cursor:pointer">
                <xsl:attribute name="onclick">
                  editar_vinculo(<xsl:value-of select='@id_ent_vinc'/>)
                </xsl:attribute>
              </img>&#160;
            </xsl:if>
          </td>
          <td style='text-align: center; width:5%'>
            <xsl:if test="not(@vinc_baja != '')">
              <img title="Eliminar Vínculo" src="../../fw/image/icons/eliminar.png" style="cursor:pointer">
                <xsl:attribute name="onclick">
                  eliminar_vinculo(<xsl:value-of select='@id_ent_vinc'/>)
                </xsl:attribute>
              </img>
            </xsl:if>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td style="width: 5%; text-align: center"></td>
          <td style="width: 5%; text-align: center"></td>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </xsl:template>
</xsl:stylesheet>