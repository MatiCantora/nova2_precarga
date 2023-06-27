<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Me.contents("campo_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='verCampos_def'><campos>*</campos><orden>campo_def</orden><filtro></filtro></select></criterio>")

    Dim campo_def = nvFW.nvUtiles.obtenerValor("campo_def", "")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Campos def</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript" >

    var campo_def = '<%=campo_def %>'
        var isIE = Prototype.Browser.IE ? true : false
        var tbBuscar_height = 0

        function listaCampoDefs_resize()
          {
          //var body = $$("BODY")[0]
          //var tbBuscar = $("tbBuscar")
          //var alto = body.clientHeight -  tbBuscar.clientHeight
          $("listaCampoDefs").setStyle({ height: ($$("BODY")[0].getHeight() - tbBuscar_height) + "px" })
          }
         
        function window_onload(){     
              nvFW.enterToTab = false
              tbBuscar_height = $("tbBuscar").getHeight() // La altura de los campos de búsqueda no cambian
              listaCampoDefs_resize()
              setearListenerInputs()
              if(campo_def != ''){
                  campos_defs.set_value("campo_def", campo_def)
              }       
              buscar_onclick()
       }

        function window_onresize()
          {
          listaCampoDefs_resize()
          }

        function setearListenerInputs()
          {
          // Iterar sobre los IDs de campos de busqueda
          ["campo_def", "descripcion", "depende_de"].each(function(idElement)
            {
            var elemento = $(idElement)
            elemento.addEventListener("keyup", function(e) { checkKey(e, this) }, false)
            })
          }

        var ENTER_KEY = 13
        var ESCAPE_KEY = 27

        function checkKey(event, element)
          {
          return (isIE ? event.keyCode : event.which) == ENTER_KEY 
                    ? buscar_onclick() 
                    : (isIE ? event.keyCode : event.which) == ESCAPE_KEY 
                        ? element.value = "" 
                        : true
          }

        function buscar_onclick()
         {
         var strWhere = ""
         if (campos_defs.value("campo_def") != '')
             {
             strWhere = "<campo_def type='like'>%" + campos_defs.value("campo_def")  + "%</campo_def>" 
             } 
         if (campos_defs.value("descripcion") != '')
             {
             strWhere += "<descripcion type='like'>%" + campos_defs.value("descripcion")  + "%</descripcion>" 
             }              
         if (campos_defs.value("nro_campo_tipo") != '')
             {
             strWhere += "<nro_campo_tipo type='igual'>" + campos_defs.value("nro_campo_tipo")  + "</nro_campo_tipo>" 
             }              
         
         //if ($("depende_de").checked)
         if (campos_defs.get_value("depende_de") == 1)
            strWhere += "<NOT><depende_de type='isnull'/></NOT>" 
         else if (campos_defs.get_value("depende_de") == 2)
            strWhere += "<depende_de type='isnull'/>" 
         
         var alto = $("listaCampoDefs").clientHeight
         var filas = alto / 22.6 // 22.6px es la altura aproximada de cada fila
         var filtroWhere = "<criterio><select PageSize='" + filas.toFixed(0) + "' AbsolutePage='1' cacheControl='session' expire_minutes='2'><filtro>" + strWhere + "</filtro></select></criterio>"  
         nvFW.exportarReporte({
                           filtroXML: nvFW.pageContents.campo_def
                         ,filtroWhere: filtroWhere
                         , path_xsl: "report\\campo_def\\campo_def_listar.xsl"
                         //, xsl_name: "algo.xsl"
                         , salida_tipo: "adjunto"
                         , ContentType: "text/html" //default opcional
                         , formTarget: "listaCampoDefs"
                         , bloq_contenedor: $$("BODY")[0]
                         , cls_contenedor: "listaCampoDefs"
                         , nvFW_mantener_origen: true
                         , cls_contenedor_msg: " "
                         , bloq_msg: "Cargando lista..."
            }) 
         }

        function nuevo_onclick()
        {
            var win = top.nvFW.createWindow(
                        {
                            url: "/fw/campo_def/campos_def_abm.aspx?campo_def=",
                            width: "1100",
                            height: "400",
                            top:"50"
                        }
                    )
            //centered = true;
            //centerTop = top;
            //centerLeft = left;
            //win.show()
            //win.show(true)
            win.showCenter(true)
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="overflow: hidden; background-color: white;">
    <table class="tb1" id="tbBuscar">
        <tr>
            <td colspan="9">
                <div id="menuLista" style="width: 100%"></div>
            </td>
            <script type="text/javascript">
                var vMenu = new tMenu('menuLista','vMenu');
                vMenu.alineacion = 'centro'
                vMenu.estilo     = 'A'
   
                vMenu.loadImage('nuevo','/FW/image/icons/nueva.png')
 
                // Importante: Nombre de la ventana que contendrá los documentos 
                //var TargetDocumentos = 'lado';
                //var e;
    
                vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenu.MostrarMenu();
            </script>
        </tr>
        <tr>
            <td class="Tit1" style="width: 40px" >id:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("campo_def", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1">Descripción:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("descripcion", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1">Tipo:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("nro_campo_tipo", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='campos_def_tipo'><campos> distinct nro_campo_tipo as id, campo_tipo as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>") %>
            </td>
            <td class="Tit1">Dependiente:</td>
            <td style="width:100px">
                <%--<input name="depende_de" id="depende_de" type="checkbox" style="cursor: pointer;" title="Obtiene todos los campos def dependientes de otro" />--%>
                <script>
                    var rs = new tRS()
                    rs.xml_format = "rs_xml_json"
                    rs.addField("id", "int")
                    rs.addField("campo", "string")
                    rs.addRecord({ id: 1, campo: "Sí" })
                    rs.addRecord({ id: 2, campo: "No" })
                    campos_defs.add('depende_de', {
                        filtroXML: "",
                        filtroWhere: "",
                        nro_campo_tipo: 1, enDB: false, json: true, mostrar_codigo: false
                    });

                    campos_defs.items['depende_de'].rs = rs
                </script>
            </td>
            <td style="width: 90px">
                <input type="button" value="Buscar" onclick="buscar_onclick()" style="width: 100%; background-image: url('/FW/image/icons/buscar.png'); background-repeat: no-repeat; background-position: 2px 3px; background-size: 12px; cursor: pointer;" title="Buscar campos defs" />
            </td>            
        </tr>
    </table>

    <iframe name="listaCampoDefs" id="listaCampoDefs" style="width: 100%; border: none;" src="/FW/enBlanco.htm" frameborder="0"></iframe>
</body>
</html>        