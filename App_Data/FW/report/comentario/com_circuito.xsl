<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl" />
  <xsl:output method="html" version="4.01" encoding="ISO-8859-1" omit-xml-declaration="yes" />

  <xsl:template match="/">
    <html>
      <xsl:choose>
        <xsl:when test="count(xml/rs:data/z:row) = 0">
            <head>
              <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
              <style type="text/css">
                .tab
                {
                  border-radius: 0;
                  border-left:<xsl:value-of select="/xml/parametros/tab"/>px solid lightgrey;
                }
        
              </style>
              <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
              <script type="text/javascript" language="javascript">
                <xsl:comment>
                  <![CDATA[
                  
                    ]]>
                </xsl:comment>
              </script>
            </head>
            <body  style="width:100%; overflow:hidden; background-color:#e6e3e3; ">
              <table id="tabla_contenido" cellspacing="0" class="tb1">
                <tr>
                  
                  <td style='width: 50px; text-align: center;' nowrap=''>
                    <img src="../../FW/image/icons/agregar.png" style="visibility:hidden;"></img>
                    <img src="../../FW/image/icons/editar.png" style="visibility:hidden;"></img>
                  </td>
                  <td class="tab" style="background-color: #e6e3e3;border-radius:0;">&#160;</td>
                </tr>
              </table>
            </body>
      </xsl:when>
      <xsl:otherwise>
      <head>
        <title>Circuito de comentarios</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
        <style type="text/css">
          body{
            width:100%; background-color:white;
          }
          .tab
          {
            border-radius: 0;
            border-left: 0<xsl:value-of select="/xml/parametros/tab"/>px solid lightgrey;
          }
          .baja{
            color: red;
          }
        
        </style>
        
        <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>

        <script type="text/javascript" language="javascript">
          <xsl:comment>

          </xsl:comment>
        </script>

       <script type="text/javascript">
         var profundidad = 0
 
         var nro_com_tipo_origen    = '<xsl:value-of select="xml/parametros/nro_com_tipo_origen"/>'
         var nro_com_estado_origen  = '<xsl:value-of select="xml/parametros/nro_com_estado_origen"/>'
         var filtroCircuitoComRegistros
            <![CDATA[
                function onload() {
                  
                   filtroCircuitoComRegistros = parent.filtroCircuitoComRegistros
                   editCire_com_detalle = parent.editCire_com_detalle
                  
                   profundidad = (parent.profundidad == undefined ? 0 : parent.profundidad) + 1
                   if(nro_com_tipo_origen)
                      $("divCabeceras").hide()
                    
                   window.onresize();
                }

                function onresize() {
                  if(profundidad > 1)
                    return;
                    
                  try{
                      var contenido = $('tabla_contenido');
                      var body = $(document.body);
                      var tamanio = (body.clientHeight - 40) > 80 ? (body.clientHeight - 40) : 100; 

                      contenido.style.height = tamanio;
                    }
                    catch(e){}
                }
              
                function resize(h){
                  var parentFrameId = "frame_t" + nro_com_tipo_origen + "_e" + nro_com_estado_origen
                  var selfFrameSelector = parent.document.querySelector('[id^="' + parentFrameId + '"]')
                  if(selfFrameSelector){
                    var selfFrame = parent.document.getElementById(selfFrameSelector.id)
                    if(selfFrame)
                      selfFrame.height = parseInt(selfFrame.height, 10) + h
                  }
                
                  if(parent.resize)
                        parent.resize(h)
                }
              
              
                function verHijos(id_cire_com_detalle, tipo_origen, estado_origen, frameId){
              
                  var iframeHijos = window.document.getElementById(frameId)
                
                  if(iframeHijos.contentDocument.loaded){
                    var h = iframeHijos.contentDocument.getElementById("tabla_contenido").getHeight()
                    h = h ? h : 0
                  
                    frameDoc = iframeHijos.contentDocument || iframeHijos.contentWindow.document;
                    frameDoc.removeChild(frameDoc.documentElement);
                    iframeHijos.contentDocument.loaded = false;

                    $("show" + frameId).src = "../../FW/image/icons/mas.gif"
                    iframeHijos.height = "0px"
                    if(parent.resize)
                      resize(-h)
                        
                    return;
                  }
                
                  nvFW.exportarReporte({
                      filtroXML: filtroCircuitoComRegistros,
                      //async:false,
                      filtroWhere: '<criterio><select><filtro><id_cire_com_detalle type="distinto">'+id_cire_com_detalle+'</id_cire_com_detalle><nro_com_tipo_origen type="igual">'+tipo_origen+'</nro_com_tipo_origen><nro_com_estado_origen type="igual">'+estado_origen+'</nro_com_estado_origen></filtro></select></criterio>',
                      bloq_contenedor: iframeHijos,
                      path_xsl: 'report/comentario/com_circuito.xsl',
                      bloq_msg: 'Cargando...',
                      formTarget: frameId,
                      nvFW_mantener_origen: true,
                      parametros: '<parametros><nro_com_tipo_origen>'+tipo_origen+'</nro_com_tipo_origen><nro_com_estado_origen>'+estado_origen+'</nro_com_estado_origen><tab>'+(profundidad*16)+'</tab></parametros>',
                      funComplete: function(){
                        $("show" + frameId).src = "../../FW/image/icons/menos.gif"
                    
                        var h = iframeHijos.contentDocument.getElementById("tabla_contenido").getHeight()
                        h = h ? h : 0
                        window.document.getElementById(frameId).height = h
                        if(parent.resize)
                          resize(h)
                      }
                  })
                }
              
                function nuevo(nroTipo_origen, nroEstado_origen){
                  parent.editCire_com_detalle(0, nroTipo_origen, nroEstado_origen, reloadGrid)
                }
                function editar(id){
                  parent.editCire_com_detalle(id, 0, 0, reloadGrid)
                }
              
                 function reloadGrid(){
                    location.reload()
                 }
               
            ]]>
        </script>
      </head>
      <xsl:variable name="estadoOrigen" select="xml/parametros/nro_com_estado_origen" />
      <body style="width:100%; background-color:white; " onload="return onload()" onresize="onresize()">
        <xsl:if test="$estadoOrigen">
          <xsl:attribute name="style">
            overflow:hidden;
          </xsl:attribute>
        </xsl:if>
          
        <div style="width: 100%; text-align: center;" id="divCabeceras">
          <table class="tb1" id="header_tbl" name="header_tbl">
            <xsl:if test="$estadoOrigen">
              <xsl:attribute name="cellspacing">
                    0
              </xsl:attribute>
            </xsl:if>
            <tr class='tbLabel'>
              <td style='width: 50px; text-align: center;' nowrap=''>
                <img src="../../FW/image/icons/agregar.png" style="visibility:hidden;"></img>
                <img src="../../FW/image/icons/editar.png" style="visibility:hidden;"></img>
              </td>
              <td style='width: 35%; text-align: center;'>Tipo</td>
              <td style='width: 30%; text-align: center;'>Estado</td>
              <td style='width: 30%; text-align: center;'>Estado Origen Nuevo</td>
            </tr>
          </table>
        </div>
        <div style="overflow-y: auto; overflow-x: hidden; width:100%; background-color: white;clear: both;" id="tabla_contenido">
          <table class="tb1 highlightTROver scroll" id="tblog" name="tblog">
            <xsl:if test="$estadoOrigen">
              <xsl:attribute name="cellspacing">
                    0
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="xml/rs:data/z:row" />
            
            <xsl:if test="not($estadoOrigen)">
            <tr>
              <td colspan="4" style="text-align: center; background-color: white;">
                <img id="addInicial" src="../../FW/image/icons/agregar.png" style="cursor:pointer;" title="Agregar estado inicial" onclick="nuevo()">
                  <xsl:attribute name="onclick">
                    nuevo(0, 0)
                  </xsl:attribute>
                </img>
              </td>
            </tr>
            </xsl:if>
          
          </table>
          
        </div>
        <div style="clear: both;"></div>
        
      </body>
            </xsl:otherwise>
        </xsl:choose>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()" />
    <xsl:variable name="frameHijosId" select="concat('_t', @nro_com_tipo, '_e', @nro_com_estado, '_to', @nro_com_tipo_origen, '_eo', @nro_com_estado_origen)" />
    
    <tr>
      <xsl:if test="@vigente = 'False'">
        <xsl:attribute name="class">
          baja
        </xsl:attribute>
      </xsl:if>
      <td style="width:50px; text-align: center;" nowrap="">
        <img id="add{$frameHijosId}" src="../../FW/image/icons/agregar.png" style="cursor:pointer;" title="Agregar hijo" onclick="nuevo()">
          <xsl:attribute name="onclick">
            nuevo('<xsl:value-of select="@nro_com_tipo"/>', '<xsl:value-of select="@nro_com_estado"/>')
          </xsl:attribute>
        </img>
        <img src="../../FW/image/icons/editar.png" style="cursor:pointer;" title="Editar">
          <xsl:attribute name="onclick">
            editar('<xsl:value-of select="@id_cire_com_detalle"/>')
          </xsl:attribute>
        </img>
      </td>
      <td style="width: 35%; padding-left:0">
        <nav class="tab">
          <img id="showframe{$frameHijosId}" src="../../FW/image/icons/mas.gif" style="cursor:pointer; vertical-align: middle;" title="Ver Hijos">
            <xsl:attribute name="onclick">
              verHijos('<xsl:value-of select="@id_cire_com_detalle"/>', '<xsl:value-of select="@nro_com_tipo"/>', '<xsl:value-of select="@nro_com_estado"/>', 'frame<xsl:value-of select="$frameHijosId"/>')
            </xsl:attribute>  
          </img>
          <xsl:value-of  select="@com_tipo" />
        </nav>
      </td>
      <td style='width: 30%;'>
        <xsl:value-of  select="@com_estado" />
      </td>
      <td style='width: 30%;'>
        <xsl:value-of  select="@com_estado_origen_nuevo" />
      </td>
      
    </tr>
    <tr>
      <td colspan="4" style="padding: 0;">
        <iframe id="frame{$frameHijosId}" name="frame{$frameHijosId}" height="0px" style="width: 100%; border: none; ">
        </iframe>
      </td>
    </tr>
  </xsl:template>
  

</xsl:stylesheet>


