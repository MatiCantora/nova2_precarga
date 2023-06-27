<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>

<% 

    Me.contents("campo_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='verCampos_def'><campos>*</campos><orden>campo_def</orden><filtro></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Campos def</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% =Me.getHeadInit() %>

    <script type="text/javascript" >

        function listaCampoDefs_resize()
          {
          var body = $$("BODY")[0]
          var tbBuscar = $("tbBuscar")
          var alto = body.clientHeight -  tbBuscar.clientHeight
          $("listaCampoDefs").setStyle({height: alto + "px"}) 
          }
         
        function window_onload()
          {
          listaCampoDefs_resize()
          }

        function window_onresize()
          {
          listaCampoDefs_resize()
          }

        function buscar_onlick()
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
         
         if ($("depende_de").checked)
            strWhere += "<NOT><depende_de type='isnull'/></NOT>" 
         else
           strWhere += "<depende_de type='isnull'/>" 
         
         var alto = $("listaCampoDefs").clientHeight
         var filas = alto / 25
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
<body onload="window_onload()" onresize="window_onresize()" style="overflow:hidden">
    <table class="tb1" id="tbBuscar">
        <tr>
            <td colspan="9"><div id="menuLista" style="width: 100%"></div></td>
            
            <script type="text/javascript" language="javascript">
                var vMenu = new tMenu('menuLista','vMenu');
                vMenu.alineacion = 'centro';
                vMenu.estilo = 'A'
   
                //vMenu.loadImage("guardar",'/FW/image/icons/guardar.png')
                //vMenu.loadImage('eliminar','/FW/image/icons/eliminar.png')
                vMenu.loadImage('nuevo','/FW/image/icons/nueva.png')
                //vMenu.imagenes = Imagenes //Imagenes se declara en pvUtiles
 
                //Importante: Nombre de la ventana que contendrá los documentos 
                var TargetDocumentos = 'lado';
                var e;
    
                //var oXML = new tXML();
                //oXML.loadXML("<Menu><Menu>")
                //vMenu.CargarXML(oXML);
                //vMenu.CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Campos defs</Desc></MenuItem>")
                //vMenu.CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenu.MostrarMenu();
            </script>
            <!--<td colspan="8">ABM Campos defs</td>
            <td style="width: 90px"><input type="button" value="Nuevo" onclick="nuevo_onclick()" style="width:100%; background-image: url('/FW/image/icons/agregar.png'); background-repeat: no-repeat; background-position: 2px 3px; background-size: 12px" /></td>-->
        </tr>
        <tr>
            <td class="Tit1" style="width: 40px" >id:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("campo_def", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td  class="Tit1">Descripción:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("descripcion", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td  class="Tit1">Tipo:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_campo_tipo", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='campos_def_tipo'><campos> distinct nro_campo_tipo as id, campo_tipo as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>")  %></td>
            <td  class="Tit1">Dependiente:</td>
            <td><input name="depende_de" id="depende_de" type="checkbox" /></td>
            <td style="width: 90px"><input type="button" value="Buscar" onclick="buscar_onlick()" style="width:100%; background-image: url('/FW/image/icons/buscar.png'); background-repeat: no-repeat; background-position: 2px 3px; background-size: 12px" /></td>            
        </tr>
    </table>
    <iframe name="listaCampoDefs" id="listaCampoDefs" style="width: 100%" src="/admin/enBlanco.htm" frameborder="0"></iframe>


</body>
</html>        