<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_transferencia", 27)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.addPermisoGrupo("permisos_transferencia")

    Me.contents("transf_conf") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Ver_transf_conf' ><campos> [id_transf_conf],[transf_conf],[transf_conf_tipo],[transf_conf_tipo_id],[transf_conf_default],[server],[port],[user],[password],[esSSL],[from],[from_title]</campos><filtro></filtro><orden></orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Transferencias conf</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">  

        function window_onload() {
            //########## BOTONES ###########
            var vButtonItems = {}

            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "BtnBuscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

            vListButton.MostrarListButton()

            onresize()

          
        }

        function buscar() {

            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            
            var id_transf = campos_defs.get_value('id_transf')
            var transf_conf = campos_defs.get_value('transf_conf')
            var transf_conf_tipo = campos_defs.get_desc('transf_conf_tipo')
            var transf_conf_tipo_id = campos_defs.get_value('transf_conf_tipo')
            var filtroWhere=""

            if (!id_transf == "") {
               filtroWhere += "<id_transf_conf type=\"igual\">" + id_transf + "</id_transf_conf>"
            }
            if (!transf_conf == "") {
                filtroWhere += "<transf_conf type=\"like\">" + transf_conf + "</transf_conf>"
            }
            if (!transf_conf_tipo == "") {
                filtroWhere += "<transf_conf_tipo type=\"like\">" + transf_conf_tipo + "</transf_conf_tipo>"
            }

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.transf_conf,
                filtroWhere: filtroWhere,
                path_xsl: "report/HTML_transf_conf.xsl",
                formTarget: "iframe1",
                ContentType: "text/html",
                bloq_contenedor: $('iframe1'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe1',
                bloq_msg: "cargando"
            });

            onresize()
        }

        function editarNuevo(modo) {
            alert('anda')
        }
        
        function editar(id_transf_conf, trans_conf, transf_conf_tipo, transf_conf_tipo_id, server, port, user, password, esSSL, from, from_title) {
            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            var winAgregar
            winAgregar = nvFW.createWindow({
                className: 'alphacube',
                url: 'trans_conf_ABM.aspx',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 255,
                resizable: true,
                onClose: function (win) {
                    buscar()
                }
            });
          
                winAgregar.options.userData = {
                    modo:'M',
                    id_transf_conf: id_transf_conf,
                    trans_conf: trans_conf,
                    transf_conf_tipo: transf_conf_tipo,
                    server: server,
                    port: port,
                    user: user,
                    password: password,
                    esSSL: esSSL,
                    from: from,
                    from_title: from_title,
                    transf_conf_tipo_id: transf_conf_tipo_id,
                    modificado:false
                }

            winAgregar.showCenter(true)
        }

        function nuevo() {
            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            var winAgregar
            winAgregar = nvFW.createWindow({
                className: 'alphacube',
                url: 'trans_conf_ABM.aspx',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 255,
                resizable: false,
                onClose: function (win) {
                        buscar()
                }
            });
            winAgregar.options.userData = {
                modo: 'A',
                modificado:false
            }
            winAgregar.showCenter(true)
        }

        function onresize() {
            var alto_body = $$('BODY')[0].getHeight()
            var alta_main = $('divCabe').getHeight()
            var alto_div = alto_body - alta_main
            $('iframe1').style.height = alto_div + 'px'
                       
        }


    </script>
</head>
<body id="cuerpo" onload="return window_onload()" onresize="onresize()"  style="width: 100%; /*height: 100%; */ /*overflow: auto*/">
  
   

    <div id="divCabe" style="width: 100%; overflow: auto;">
          <div id="divMenuDig"></div>
         <script type="text/javascript">
             //########## MENU ###########

             var vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
             Menus["vMenuDig"] = vMenuDig
             Menus["vMenuDig"].alineacion = 'centro';
             Menus["vMenuDig"].estilo = 'A';

             vMenuDig.loadImage("nueva", "/fw/image/icons/nueva.png");

             Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 85%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
             Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
             vMenuDig.MostrarMenu()
         </script>
        <table id='contenedor' class="tb1">
            <tr class="tbLabel">
                <td>ID
                </td>
                <td>Configuración
                </td>
                <td>Tipo
                </td>
            </tr>
            <tr>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('id_transf', { nro_campo_tipo: 100, enDB: false })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('transf_conf', { nro_campo_tipo: 104 })
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('transf_conf_tipo', {autocomplete:true})
                    </script>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div id="divBtnBuscar"></div>
                </td>
            </tr>
        </table>
    </div>

    <iframe name="iframe1" id="iframe1" style="width: 100%; height: auto; max-height: 817px; overflow: auto" frameborder='0'></iframe>
</body>
</html>
