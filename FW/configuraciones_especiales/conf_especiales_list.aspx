<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("filtro_confEspeciales") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especiales'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.addPermisoGrupo("permisos_conf_especiales_gral")
    
    '----Cargar los permisos especiales de las configuraciones'
    Dim strSQL As String = "select distinct nro_permiso_grupo, permiso_grupo from verConf_especiales"
    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
    While Not rs.EOF()
        Me.addPermisoGrupo(rs.Fields("permiso_grupo").Value)
        rs.MoveNext()
    End While
    nvDBUtiles.DBCloseRecordset(rs)
   
 %>
<html>
<head>
    <title>Listado Configuraciones Especiales</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>   
   <% =Me.getHeadInit() %>
    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return cargarConfiguraciones()";
        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')

        function window_onload(){
            vListButtons.MostrarListButton()
            cargarConfiguraciones()    
            window_onresize()
        }

        function window_onresize(){
            var body=$$("BODY")[0]
            var tbmenu = $("divMenuLoca").clientHeight
            var tbBuscar = $("buscar").clientHeight
            var alto=body.clientHeight- tbBuscar - tbmenu - 20
            $("frame_listado").setStyle({ height: alto+"px" })
        }

        function cargarConfiguraciones() {
            var filtroWhere = ""
            if (campos_defs.get_value("configuraciones") != '')
                filtroWhere = "<nombre_conf type='like'>%" + campos_defs.get_value("configuraciones") + "%</nombre_conf>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_confEspeciales
                ,filtroWhere: filtroWhere
                , path_xsl: "report\\verConfiguracionesEspeciales\\HTML_configuracionesEsperciales.xsl"
                , formTarget: "frame_listado"
                , nvFW_mantener_origen: true
                , id_exp_origen: 0
                , bloq_contenedor: $$("BODY")[0]
                , cls_contenedor: "frame_listado"
            })
        }

        function nueva_conf() {
            if (nvFW.tienePermiso('permisos_conf_especiales_gral', 2)){
                var Height_body = document.getElementsByTagName('body')[0].clientHeight 
                var Height = 700
                if (Height_body < Height) Height = Height_body
                
                var win = nvFW.top.createWindow({
                    url: '/fw/configuraciones_especiales/conf_especiales.aspx',
                    title: '<b>Nueva Configuración</b>',
                    width: 1200,
                    height: Height,
                    maximizable: true,
                    minimizable: false,
                    setWidthMaxWindow: true,
                    draggable: true,
                    destroyOnClose: true,
                    onClose: function(win) { if (win.actualizar) cargarConfiguraciones() }
                });
                win.showCenter()
            }
            else{ 
                nvFW.alert('No tiene permisos para crear una nueva configuración. Comuniquese con el administrador de sistemas.')
           }
        }

        function editar_configuracion(id_conf, permiso_grupo, nro_permiso){     
            var Height_body = document.getElementsByTagName('body')[0].clientHeight 
            var Height = 700
            if (Height_body < Height){
                Height = Height_body
            }
            
            if (nvFW.tienePermiso(permiso_grupo, nro_permiso)){
                var win = nvFW.top.createWindow({
                    url: "/FW/configuraciones_especiales/conf_especiales.aspx?id_conf=" + id_conf,
                    title: '<b>Editar Configuración</b>',
                    width: 1200,
                    height: Height,
                    maximizable: true,
                    minimizable: false,
                    setWidthMaxWindow: true,
                    draggable: true,
                    destroyOnClose: true,
                    onClose: function(win) { if (win.actualizar) cargarConfiguraciones() }
                });
                win.showCenter()
            }
            else{
                nvFW.alert('No tiene permisos para ver esta configuración. Pongase en contacto con un administrador de sistemas. ')
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="overflow: hidden">
    <div id="divMenuLoca" style="margin: 0px; padding: 0px;">
    </div>
    <script type="text/javascript">
        var DocumentMNG=new tDMOffLine;
        var vMenuLoca=new tMenu('divMenuLoca','vMenuLoca');
        Menus["vMenuLoca"]=vMenuLoca
        Menus["vMenuLoca"].alineacion='centro';
        Menus["vMenuLoca"].estilo='A';
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_conf()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuLoca.loadImage('nueva', '/FW/image/icons/nueva.png')
        vMenuLoca.MostrarMenu()
    </script>
    <table id="buscar" class="tb1" style="width:100%">
        <tr>
            <td style="30px" class="Tit1">Buscar:</td>
            <td ><%= nvFW.nvCampo_def.get_html_input("configuraciones", enDB:=False, nro_campo_tipo:=104)%></td>
            <td style="10%"> <div id="divBuscar" style="width: 100%" /></td>
        </tr>
    </table>
    <iframe name="frame_listado" id="frame_listado" src="../enBlanco.htm" style="width: 100%;height: 100%" frameborder='0'></iframe>
</body>
</html>
