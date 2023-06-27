<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_herramientas", 10)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.addPermisoGrupo("permisos_herramientas")

    Me.contents("sms_mostrar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='send_request'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consulta de envios</title>
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

        if (nvFW.tienePermiso("permisos_herramientas", 10)) {
            alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        } 

        var busqueda = false
        var filtro
        function window_onload() {
            var vButtonItems = {}

            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "BtnBuscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

            vListButton.MostrarListButton()           

        }

        function window_onresize() {
            console.log(!busqueda)
            if (busqueda) {
                buscar()
            }
        }

        function buscar() {
            
            busqueda = true
            //var num_tel = campos_defs.get_value('numero').toString()
            //var filTel = campos_defs.get_value('numero') !="" ? ("<numero type=\"igual\">" + num_tel + "</numero>") : ""
            var filTel = campos_defs.get_value('numero')!="" ? campos_defs.filtroWhere('numero') : ""
            var filFeDes = campos_defs.filtroWhere('fe_desde')
            var filFeHas = campos_defs.filtroWhere('fe_hasta')
            var filTEx = campos_defs.get_value('texto') != "" ? "<body type='like'>%" + campos_defs.get_value('texto') + "%</body>" : ""
            var filEst = $('estado').value != "N" ? "<estado type=\"igual\">'" + $('estado').value + "'</estado>" : ""
            var filType = $('tipo').value != "N" ? "<type type=\"igual\">'" + $('tipo').value + "'</type>" : ""
            filtro = filTel + filFeDes + filFeHas + filEst + filTEx + filType
            console.log(filtro)


            cantFilas = Math.floor (($("cuerpo").getHeight() - ($('buscador').getHeight() )- (18 )) / 22);


            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.sms_mostrar,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>" ,
                path_xsl: "report/HTML_sms_consulta.xsl",
                formTarget: "iframe1",
                ContentType: "text/html",
                bloq_contenedor: $('iframe1'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe1',
                bloq_msg: "cargando"
            });
        }

        function onEnter(){
            if (window.event.keyCode == 13) {
                buscar()
            }
        }

        function exportar() {
            
            if (!filtro && busqueda!=true) {
                alert('debe elegir alguna variable para filtrar')
                return
            }

            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: nvFW.pageContents.sms_mostrar,
                filtroWhere:filtro
                , path_xsl: "report/HTML_sms.xsl"
                , salida_tipo: "adjunto"
                , formTarget: "_blank"
                , ContentType: "application/vnd.ms-excel"
                , formTarget: "iframe1"
                , filename: "prueba.xls"
            })

        }
    </script>
</head>
<body id="cuerpo" onload="window_onload()" onresize="window_onresize()" onkeypress="onEnter()"  style="width: 100%;height: 100%; overflow: hidden">
    <div id="divMenuAgregar"></div>
        <script type="text/javascript">
            var vMenuAgregar = new tMenu('divMenuAgregar', 'vMenuAgregar');
            Menus["vMenuAgregar"] = vMenuAgregar
            Menus["vMenuAgregar"].loadImage("nuevo", '/fw/image/icons/nueva.png')
            Menus["vMenuAgregar"].loadImage("exportar", '/fw/image/icons/excel.png')
            Menus["vMenuAgregar"].alineacion = 'centro';
            Menus["vMenuAgregar"].estilo = 'A';
            Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 90%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Consulta de envios</Desc></MenuItem>")
            Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>exportar</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportar()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuAgregar.MostrarMenu()
        </script>
    <table class="tb1 " style="width: 100%" id="buscador">
        <tr class="tbLabel">
            <td>Tipo</td>
            <td>Identificador</td>
            <td>Contenido</td>
            <td>Fecha Desde</td>
            <td>Fecha Hasta</td>
            <td>Estado</td>
        </tr>
        <tr>
            <td>
               <%-- <script type="text/javascript">
                    campos_defs.add('estado', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.estados })
                </script>--%>
                <select name="select" style="width:100%" id="tipo">
                    <option value="N" selected></option>
                    <option value="mail" >Mail</option>
                    <option value="sms">Sms</option>
                </select>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('numero', { nro_campo_tipo: 104, enDB: false, filtroWhere: "<identificador type='igual'>'%campo_value%'</identificador>"})
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('texto', { nro_campo_tipo: 104, enDB: false})
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fe_desde', { nro_campo_tipo: 103, enDB: false, filtroWhere: "<momento type='mas'>convert(datetime, '%campo_value%', 103)</momento>"})
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('fe_hasta', { nro_campo_tipo: 103, enDB: false, filtroWhere: "<momento type='menor'>dateadd(day ,1, convert(datetime, '%campo_value%', 103))</momento>"})
                </script>
            </td>
            <td>
               <%-- <script type="text/javascript">
                    campos_defs.add('estado', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.estados })
                </script>--%>
                <select name="select" style="width:100%" id="estado">
                    <option value="N" selected></option>
                    <option value="E" >Enviado</option>
                    <option value="P">Pendiente</option>
                    <option value="F">Error</option>
                </select>
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <div id="divBtnBuscar"></div>
            </td>
        </tr>
    </table>
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 100%; max-height: 817px; overflow: auto" frameborder='0'></iframe>
</body>
</html>
