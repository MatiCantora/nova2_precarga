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
              <script type="text/javascript">
                <![CDATA[
                function nuevoBase(){
                  parent.editCire_com_detalle(0, 0, 0, reloadGrid)
                }
              
                 function reloadGrid(){
                    parent.location.reload()
                 }
                ]]>
              </script>
                
            </head>
            <body  style="width:100%; overflow:hidden; background-color:#e6e3e3; ">
              <table id="tabla_contenido" cellspacing="0" class="tb1">
                <tr>
                  
                  <td style='width: 50px; text-align: center;' nowrap=''>
                    <img src="../../FW/image/icons/agregar.png" style="visibility:hidden;"></img>
                    <img src="../../FW/image/icons/editar.png" style="visibility:hidden;"></img>
                  </td>
                  <td class="tab" style="border-radius:0;">&#160;</td>
                </tr>
              <tr class="no-print">
              <td colspan="4" style="text-align: center; background-color: white;">
                <img id="addInicial" src="../../FW/image/icons/agregar.png" style="cursor:pointer;" title="Agregar estado inicial" onclick="nuevo()">
                  <xsl:attribute name="onclick">
                    nuevoBase()
                  </xsl:attribute>
                </img>
              </td>
            </tr>
              </table>
            </body>
      </xsl:when>
      <xsl:otherwise>
      <head>
        <title>Circuito <xsl:value-of select="/xml/parametros/circuito"/></title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
        <style type="text/css">
          body{
            width:100%; background-color:white;
          }
          .tab
          {
            border-radius: 0;
            width: 0<xsl:value-of select="/xml/parametros/tab"/>px;
          height: 100%;
          border-right: 2px solid grey;
          background-color: lightgrey;
          float:left;
          }
          .baja{
          color: red;
          }
          td.expanded{
          box-shadow: 0 0 0 1px lightgrey !important;
          border-top-left-radius: 0 !important;
          padding: 0;
          }

          td.expanded table{
            margin-left: -2px;
          }

          @media print
          {
            td.no-print *
            {
              display: none; !important;
            }
            td.no-print
            {
              width: 0px; !important;
              visibility: hidden; !important;
            }
            div.no-print, div.no-print *
            {
              display: none !important;
            }
            #tabla_contenido
            {
              overflow: visible !important
            }
          }

        </style>
        
        <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>

        <script type="text/javascript" language="javascript">
          <xsl:comment>

          </xsl:comment>
        </script>

       <script type="text/javascript">
         var profundidad = 0
 
         var nro_com_tipo_origen    = '<xsl:value-of select="xml/parametros/nro_com_tipo_origen"/>'
         var nro_com_estado_origen  = '<xsl:value-of select="xml/parametros/nro_com_estado_origen"/>'
         
         var expandir    = <xsl:value-of select="xml/parametros/expandir"/>
         
         var filtroCircuitoRegistros
         var frame_circuito = parent.frame_circuito
         
         var arrFrameHijosId = []
         var arrFrameHijosIdAcumulado = []
            <![CDATA[
                function onload() {
                  
                   filtroCircuitoRegistros = parent.filtroCircuitoRegistros
                   editCire_com_detalle = parent.editCire_com_detalle
                   frame_circuito = parent.frame_circuito
                  
                   profundidad = (parent.profundidad == undefined ? 0 : parent.profundidad) + 1
                      
                    if(parent.arrFrameHijosIdAcumulado)
                      arrFrameHijosIdAcumulado = Array.from(parent.arrFrameHijosIdAcumulado)
                    if(expandir){
                      arrFrameHijosId.forEach(function(frameHijoId){
                        var nodeStr = frameHijoId.substring(0,frameHijoId.indexOf("_tab"))
                        if(!parent.arrFrameHijosIdAcumulado.includes(nodeStr))
                          window["expandirFrame"+frameHijoId]();
                        if(!arrFrameHijosIdAcumulado.includes(nodeStr))
                          arrFrameHijosIdAcumulado.push(nodeStr)
                      })
                    }
                    
                    var h = $("tabla_contenido").getHeight()
                    var parentFrameId = "frame_t" + nro_com_tipo_origen + "_e" + nro_com_estado_origen
                    var selfFrameSelector = parent.document.querySelector('[id^="' + parentFrameId + '"]')
                    if(selfFrameSelector){
                      var selfFrame = parent.document.getElementById(selfFrameSelector.id)
                      if(selfFrame)
                        selfFrame.height = h
                    }
                  
                    
                   window.onresize();
                }

                function onresize() {
                  if(profundidad > 1)
                    return;
                    
                  try{
                      var contenido = $('tabla_contenido');
                      var cabecera = $('divCabeceras');
                      var body = $(document.body);
                      
                      var tamanio = body.clientHeight - ($("divCabeceras") != null ? $("divCabeceras").clientHeight : 0);//(body.clientHeight - 90) > 80 ? (body.clientHeight - 90) : 90; 

                      contenido.style.height = tamanio;
                    }
                    catch(e){}
                }
              
                function resizeNode(h){
                  var parentFrameId = "frame_t" + nro_com_tipo_origen + "_e" + nro_com_estado_origen
                  var selfFrameSelector = parent.document.querySelector('[id^="' + parentFrameId + '"]')
                  if(selfFrameSelector){
                    var selfFrame = parent.document.getElementById(selfFrameSelector.id)
                    if(selfFrame)
                      selfFrame.height = parseInt(selfFrame.height, 10) + h
                  }
                
                  if(parent.resizeNode)
                        parent.resizeNode(h)
                }
              
              
                function verHijos(id_cire_com_detalle, tipo_origen, estado_origen, frameId, cTab, element){
              
                  var tableHijos = (element == null) ? document.getElementById("frame"+frameId) : element.closest('tr').next().getElementsBySelector("#frame"+frameId)[0]
                
                  if(tableHijos.parentElement.parentElement.style.display == "table-row")//(iframeHijos.contentDocument.loaded)
                    contraerFrame1(frameId, element)
                  else
                  {
                    expandirFrame1(id_cire_com_detalle, tipo_origen, estado_origen, frameId, cTab, element)
                  }
                  
                }
                
                function expandirFrame1(id_cire_com_detalle, tipo_origen, estado_origen, frameId, cTab, element){
                
                  var rs = new tRS();
                  rs.open(parent.filtroCircuitoRegistros, '', '<criterio><select><filtro><id_cire_com_detalle type="distinto">'+id_cire_com_detalle+'</id_cire_com_detalle><nro_com_tipo_origen type="igual">'+tipo_origen+'</nro_com_tipo_origen><nro_com_estado_origen type="igual">'+estado_origen+'</nro_com_estado_origen></filtro></select></criterio>');
                  //var table = '<table class="tb1" style="width: 100%;">'
                  var table = (element == null) ? document.getElementById("frame"+frameId) : element.closest('tr').next().getElementsBySelector("#frame"+frameId)[0]
                  
                  //var table = document.getElementById("frame"+frameId);
                  
                  var new_tbody = document.createElement('tbody');
                  new_tbody.width = "100%"
                  if(table.tBodies.length)
                    table.replaceChild(new_tbody, table.tBodies[0])
                  else
                    table.appendChild(new_tbody);

                  while (!rs.eof()) {
                    rs.getdata("estado")
                    var newFrameId = '_t' + rs.getdata("nro_com_tipo") + '_e' + rs.getdata("nro_com_estado") + '_to' + rs.getdata("nro_com_tipo_origen") + '_eo' + rs.getdata("nro_com_estado_origen") + '_tab1'
                    
                    var row1 = new_tbody.insertRow(0);
                    var cell11 = row1.insertCell(0);
                    var cell12 = row1.insertCell(1);
                    var cell13 = row1.insertCell(2);
                    var cell14 = row1.insertCell(3);
                    
                    cell11.noWrap = true
                    cell11.innerHTML = '<img id="add_'+ frameId +'" src="../../FW/image/icons/agregar.png" style="cursor:pointer;" title="Agregar hijo" onclick="nuevo(' + rs.getdata("nro_com_tipo") + ', ' + rs.getdata("nro_com_estado") + ')"><img src="../../FW/image/icons/editar.png" style="cursor:pointer;" title="Editar" onclick="editar(\''+ rs.getdata("id_cire_com_detalle") +'\')">'
                    cell12.innerHTML = '<div class="tab" style="width:'+(15*cTab)+'">&nbsp;</div>' +
                      (rs.getdata("hijos") == "0" ? '<img id="showframe'+newFrameId+'" src="../../FW/image/icons/punto.gif" style="cursor:pointer; float: left;" title="Ocultar Hijos" onclick="verHijos('+rs.getdata("id_cire_com_detalle")+', ' + rs.getdata("nro_com_tipo") + ', ' + rs.getdata("nro_com_estado") + ', \''+newFrameId+'\', ' + (cTab+1) + ', this)">' : '<img id="showframe'+newFrameId+'" src="../../FW/image/icons/mas.gif" style="cursor:pointer; float: left;" title="Ver Hijos" onclick="verHijos('+rs.getdata("id_cire_com_detalle")+', ' + rs.getdata("nro_com_tipo") + ', ' + rs.getdata("nro_com_estado") + ', \''+newFrameId+'\', ' + (cTab+1) + ', this)">') +
                      '(' + rs.getdata("hijos") + ") " + rs.getdata("com_tipo") ;
                    
                    
                    cell13.innerHTML = rs.getdata("com_estado");
                    cell14.innerHTML = rs.getdata("com_estado_origen_nuevo") ? rs.getdata("com_estado_origen_nuevo") : "&nbsp;";
                    
                    //cell11.width = "50"
                    cell11.style = "width:30px; text-align: center;"
                    cell11.classList.add("no-print")
                    cell12.noWrap = true
                    cell12.width = "150px"
                    cell13.width = "130px"
                    cell14.width = "130px"
                    
                    var parentFrameId = '_t' + rs.getdata("nro_com_tipo") + '_e' + rs.getdata("nro_com_estado") + '_to' + rs.getdata("nro_com_tipo_origen") + '_eo' + rs.getdata("nro_com_estado_origen") + '_tab' + "1";//"tab";
                    
                    var row2 = new_tbody.insertRow(1);
                    var cell21 = row2.insertCell(0);
                    cell21.colSpan = 4
                    cell21.style = "padding: 0;"
                    cell21.innerHTML = '<table id="frame'+ parentFrameId +'" class="tb1" style="width: 100%" ></table>';
                    
                    //table.parentElement.parentElement.style.display = "table-row"
                    
                    /*
                    table += '<tr><td class="no-print" style="width:50px; text-align: center;" nowrap=""></td>'+
                            '<td style="width: 40%;">'+ rs.getdata("com_tipo") +'</td><td style="width: 30%;">'+ rs.getdata("com_estado") +'</td><td style="width: 30%;">'+ rs.getdata("com_estado_origen_nuevo") +'</td></tr>' +
                                                      '<tr><td id="frame'+ parentFrameId +'" colspan="4"></td></tr>'
                    */
                    rs.movenext()
                  }
                  
                  if(element == null){
                    $("showframe" + frameId).src = "../../FW/image/icons/menos.gif"
                    $("showframe" + frameId).title = "Ocultar Hijos"
                  }
                  else{
                    element.src = "../../FW/image/icons/menos.gif"
                    element.title = "Ocultar Hijos"
                  }
                  
                  table.parentElement.addClassName("expanded")
                  table.parentElement.parentElement.style.display = "table-row"
                  //table += '</table>'
                  //$("frame"+frameId).innerHTML = table;
                  
                }
                
                function expandirFrame(id_cire_com_detalle, tipo_origen, estado_origen, frameId){
                  var iframeHijos = window.document.getElementById("frame"+frameId)
                  
                  
                  if(iframeHijos.contentDocument.loaded && !expandir)
                    return;
                  
                  nvFW.exportarReporte({
                      filtroXML: parent.filtroCircuitoRegistros,
                      //async: false,
                      filtroWhere: '<criterio><select><filtro><id_cire_com_detalle type="distinto">'+id_cire_com_detalle+'</id_cire_com_detalle><nro_com_tipo_origen type="igual">'+tipo_origen+'</nro_com_tipo_origen><nro_com_estado_origen type="igual">'+estado_origen+'</nro_com_estado_origen></filtro></select></criterio>',
                      bloq_contenedor:  $('tabla_contenido'),//$$("BODY")[0],//iframeHijos,
                      bloq_id: "bloq"+frameId,
                      path_xsl: 'report/circuito/cire_com_detalle_tree.xsl',
                      //bloq_msg: 'Cargando...',
                      formTarget: "frame"+frameId,
                      nvFW_mantener_origen: true,
                      parametros: '<parametros><expandir>'+ expandir +'</expandir><nro_com_tipo_origen>'+tipo_origen+'</nro_com_tipo_origen><nro_com_estado_origen>'+estado_origen+'</nro_com_estado_origen><tab>'+(profundidad*16)+'</tab></parametros>',
                      funComplete: function(e){
                        $("showframe" + frameId).src = "../../FW/image/icons/menos.gif"
                        $("showframe" + frameId).title = "Ocultar Hijos"
                        iframeHijos.parentElement.addClassName("expanded")
                    
                        frameDoc = iframeHijos.contentDocument || iframeHijos.contentWindow.document;
                        var h = frameDoc.getElementById("tabla_contenido") ? frameDoc.getElementById("tabla_contenido").getHeight() : 0
                        
                        window.document.getElementById("frame"+frameId).height = h
                        if(parent.resizeNode)
                          resizeNode(h)
                      }
                  })
                }
                
                function contraerFrame(frameId){
                  var iframeHijos = window.document.getElementById("frame"+frameId)
                
                  if(!iframeHijos.contentDocument.loaded)
                    return;
                  var h = iframeHijos.contentDocument.getElementById("tabla_contenido").getHeight()
                  h = h ? h : 0
                  
                  frameDoc = iframeHijos.contentDocument || iframeHijos.contentWindow.document;
                  frameDoc.removeChild(frameDoc.documentElement);
                  iframeHijos.contentDocument.loaded = false;

                  $("showframe" + frameId).src = "../../FW/image/icons/mas.gif"
                  $("showframe" + frameId).title = "Ver Hijos"
                  iframeHijos.parentElement.removeClassName("expanded")
                  iframeHijos.height = "0px"
                  if(parent.resizeNode)
                    resizeNode(-h)
                   
                }
                
                function contraerFrame1(frameId, element){
                  var table = (element == null) ? document.getElementById("frame"+frameId) : element.closest('tr').next().getElementsBySelector("#frame"+frameId)[0]
                  
                  var contentTr = table.parentElement.parentElement
                
                  if(contentTr.style.display == "none")
                    return;
                    
                    //var table = document.getElementById("frame"+frameId);
                    contentTr.style.display = "none"
                    
                  if(element == null){
                    $("showframe" + frameId).src = "../../FW/image/icons/mas.gif"
                    $("showframe" + frameId).title = "Ver Hijos"
                  }
                  else{
                    element.src = "../../FW/image/icons/mas.gif"
                    element.title = "Ver Hijos"
                  }
                  contentTr.removeClassName("expanded")
                  //table.height = "0px"
                  //if(parent.resizeNode)
                    //resizeNode(-h)
                   
                }
              
                function nuevo(nroTipo_origen, nroEstado_origen){
                  parent.editCire_com_detalle(0, nroTipo_origen, nroEstado_origen, reloadGrid)
                }
                function editar(id){
                  parent.editCire_com_detalle(id, 0, 0, reloadGrid)
                }
              
                 function reloadGrid(){
                    parent.location.reload()
                 }
                 
                 function expandirContraer(){
                  expandir = expandir ? 0 : 1
                    
                  //parent.nvFW.bloqueo_activar(frame_circuito, "rsOnload");
                   
                  arrFrameHijosId.forEach(function(frameHijoId){
                      if(expandir){
                          window["expandirFrame"+frameHijoId]();
                      }
                      else
                        contraerFrame1(frameHijoId)
                  })
                    
                  //parent.nvFW.bloqueo_desactivar(frame_circuito, "rsOnload");
                  
                 }
                 
                 function imprimirEstructura(){
                  window.print()
                 }
               
            ]]>
        </script>
      </head>
      <xsl:variable name="estadoOrigen" select="xml/parametros/nro_com_estado_origen" />
        
      <body style="width:100%; background-color:white; overflow: hidden;" onload="return onload()" onresize="onresize()">
        <xsl:if test="$estadoOrigen">
          <xsl:attribute name="style">
            overflow:visible;
          </xsl:attribute>
        </xsl:if>
          
        <xsl:if test="not($estadoOrigen)">
          <div style="width: 100%; text-align: center;" id="divCabeceras">
          <div id="divEstructuraMenu" class="no-print"></div>
          <script type="text/javascript">
            <![CDATA[
              var vEstructura = new tMenu('divEstructuraMenu', 'vEstructura');
              Menus["vEstructura"] = vEstructura
              Menus["vEstructura"].alineacion = 'centro';
              Menus["vEstructura"].estilo = 'A';


              vEstructura.loadImage("arbol", '/FW/image/icons/arbol.png')
              vEstructura.loadImage("imprimir", '/FW/image/icons/imprimir.png')
              
              vEstructura.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
              vEstructura.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>arbol</icono><Desc>Expandir / Contraer</Desc><Acciones><Ejecutar Tipo='script'><Codigo>expandirContraer()</Codigo></Ejecutar></Acciones></MenuItem>")
              vEstructura.CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>Imprimir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>imprimirEstructura()</Codigo></Ejecutar></Acciones></MenuItem>")

              vEstructura.MostrarMenu()
              
            ]]>
          </script>
        
              
          
            <table class="tb1" id="header_tbl" name="header_tbl">
              <xsl:if test="$estadoOrigen">
                <xsl:attribute name="cellspacing">
                      0
                </xsl:attribute>
              </xsl:if>
              <tr class='tbLabel'>
                <td class='no-print' style='width: 30px; text-align: center;' nowrap=''>
                  <img src="../../FW/image/icons/agregar.png" style="visibility:hidden;"></img>
                  <img src="../../FW/image/icons/editar.png" style="visibility:hidden;"></img>
                </td>
                <td style='width: 150px; text-align: center;'>Tipo</td>
                <td style='width: 130px; text-align: center;'>Estado</td>
                <td style='width: 130px; text-align: center;'>Estado Origen Nuevo</td>
              </tr>
            </table>
          </div>
        </xsl:if>
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
              <td class="no-print" colspan="4" style="text-align: center; background-color: white;">
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
    <xsl:variable name="tab" select="/xml/parametros/tab" />
    <xsl:variable name="frameHijosId" select="concat('_t', @nro_com_tipo, '_e', @nro_com_estado, '_to', @nro_com_tipo_origen, '_eo', @nro_com_estado_origen, '_tab', $tab)" />
    
    
    <tr>
      <xsl:if test="@vigente = 'False'">
        <xsl:attribute name="class">
          baja
        </xsl:attribute>
      </xsl:if>
      <td class="no-print" style="width:30px; text-align: center;" nowrap="">
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
      <td style="width: 150px; height: 21px; padding-top: 0;padding-bottom: 0;border-top-left-radius: 0px;border-bottom-left-radius: 0px;">
        <div class="tab"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></div>
        <xsl:choose>
            <xsl:when test="@hijos > 0">
              <img id="showframe{$frameHijosId}" src="../../FW/image/icons/mas.gif" style="cursor:pointer; float: left;" title="Ver Hijos" onclick="verHijos{$frameHijosId}()"></img>
            </xsl:when>
            <xsl:otherwise>
              <img id="showframe{$frameHijosId}" src="../../FW/image/icons/punto.gif" style="float: left;" title=""></img>
            </xsl:otherwise>
          </xsl:choose>
        <span>
          (<xsl:value-of  select="@hijos" />)
          <xsl:value-of  select="@com_tipo" />
        
        </span>
      </td>
      <td style='width: 130px;'>
        <xsl:value-of  select="@com_estado" />
      </td>
      <td style='width: 130px;'>
        <xsl:value-of  select="@com_estado_origen_nuevo" />
      </td>
      
    </tr>
    <tr style="display:none;">
      <td colspan="4" style="padding: 0;">
        <table class="tb1" id="frame{$frameHijosId}" ></table>
        <!--<iframe id="frame{$frameHijosId}" name="frame{$frameHijosId}" height="0px" style="width: 100%; border: none; ">
        </iframe>-->
        <script type="text/javascript">
      
          function verHijos<xsl:value-of select="$frameHijosId"/>(){
            if(<xsl:value-of  select="@hijos" /> > 0 ){
                verHijos(<xsl:value-of select="@id_cire_com_detalle"/>, '<xsl:value-of select="@nro_com_tipo"/>', '<xsl:value-of select="@nro_com_estado"/>', '<xsl:value-of select="$frameHijosId"/>', 1);          
            }
          }
      
          function expandirFrame<xsl:value-of select="$frameHijosId"/>(){
            if(<xsl:value-of  select="@hijos" /> > 0 ){
                expandirFrame1(<xsl:value-of select="@id_cire_com_detalle"/>, '<xsl:value-of select="@nro_com_tipo"/>', '<xsl:value-of select="@nro_com_estado"/>', '<xsl:value-of select="$frameHijosId"/>', 1);          
            }
          }
                
          arrFrameHijosId.push('<xsl:value-of select="$frameHijosId"/>');
        </script>
      </td>
    </tr>
    
  </xsl:template>
  

</xsl:stylesheet>


