<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim accion = nvUtiles.obtenerValor("accion", "")
    Dim id_Circuito = nvUtiles.obtenerValor("id_Circuito", "")
    Me.contents("filtroCircuito") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_circuitos_firma'><campos>nro_entidad, id_circuito_firma,titulo,comentario, Razon_social</campos><orden></orden></select></criterio>")
    If accion = "eliminarCircuito" Then
        
        Dim err As New tError
        Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("circuitos_firma_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim pStrXML As ADODB.Parameter
        pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        cmd.Parameters.Append(pStrXML)
        Dim rs As ADODB.Recordset
        rs = cmd.Execute()
        err.numError = rs.Fields("numError").Value
        err.mensaje = rs.Fields("mensaje").Value
        err.titulo = rs.Fields("titulo").Value
        err.debug_desc = rs.Fields("debug_desc").Value
        err.debug_src = rs.Fields("debug_src").Value
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
        err.response()
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Selección Entidad Circuito</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">


        function window_onload() {
            cargarCircuitos()
            loadMenu()
        }


        function window_onresize() {
            try {
                var body_h = $$('body')[0].getHeight()
                var menu_h = $("divMenu").style.height
                $("divRM0").style.height = body_h - menu_h
            }
            catch (e) { }

            try {
                tabla_circuito.resize()
            }
            catch (e) { }
        }


        function seleccionarEntidad() {

            var win2 = nvFW.createWindow({
                //url: 'entidad_consultar.aspx?persona_fisica=false',
                url: '/fw/funciones/entidad_consultar.aspx?',
                title: '<b>Selecionar entidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 1100,
                height: 660,
                onClose: function () {
                    if (win2.options.userData)
                        if (!win2.options.userData.entidad)
                            win.close()
                        else {
                            entidadSeleccionada = win2.options.userData.entidad.nro_entidad
                            abrirFirmasABM(entidadSeleccionada)
                        }
                }
            });

            win2.options.userData = []
            win2.showCenter(true)
        }



        function abrirFirmasABM(nroEntidad) {


            var win = nvFW.createWindow({
                url: 'firmas_ABM.aspx?nro_entidad=' + nroEntidad,
                title: '<b>Nuevo Circuito</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 1100,
                height: 660,
                onClose: function () {
                    if (tabla_circuito && win.options.userData.retorno["success"]) {
                        tabla_circuito.refresh()
                    }
                }
            });
            win.options.userData = { retorno: {} }
            win.showCenter(true)
        }




        var tabla_circuito
        var tablaCargada = false;


        function cargarCircuitos(id) {
            tabla_circuito = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_circuito.nombreTabla = "tabla_circuito";
            //Agregamos consulta XML

            tabla_circuito.filtroXML = nvFW.pageContents.filtroCircuito
            if (id)
                tabla_circuito.filtroWhere = "<id_entidad type='igual'>" + id + "</id_entidad>";

            tabla_circuito.async = true;
            tabla_circuito.editable = false;
            tabla_circuito.eliminable = false;
            tabla_circuito.agregar_espacios_en_blanco_dir = function () { seleccionarEntidad() }
            tabla_circuito.cabeceras = ["Id Circuito", "Titulo", "Comentario", "Entidad", "ver", "Eliminar"];
            tabla_circuito.camposHide = [{ nombreCampo: "id_circuito_firma"}]
            tabla_circuito.campos = [
                 {
                     nombreCampo: "id_circuito_firma", width: "15%", nro_campo_tipo: 104, enBD: false
                 },
                 {
                     nombreCampo: "titulo", nro_campo_tipo: 104, enBD: false
                 },
                 {
                     nombreCampo: "comentario", nro_campo_tipo: 104, enBD: false
                 },
                 {
                     nombreCampo: "Razon_social", width: "30%"
                 },
                 {
                     nombreCampo: "ver", width: "10%", get_html:
                        function (campo, nombre, fila) {
                            return "<input style='width:100%' type='button' value='Ver' onclick='ver_rm0(" + campo.fila + ")' />"
                        }
                 },
                 {
                     nombreCampo: "Eliminar", width: "10%", get_html:
                        function (campo, nombre, fila) {
                            return '<center><img title="eliminar" style="cursor: pointer;" onclick="eliminar_fila_RM0(' + campo.fila + ')" src="/FW/image/icons/eliminar.png" border="0"></center>'
                        }
                 }
            ];
            tablaCargada = true
            tabla_circuito.addOnComplete(function () { window_onresize(); });
            tabla_circuito.table_load_html();
            debugger
        }


        function eliminar_fila_RM0(nro_fila) {
            var id_circuito_firma = tabla_circuito.getFila(nro_fila)["id_circuito_firma"]
            var strXML = "<?xml version='1.0'?><circuitos_firma_abm><circuito_firma_baja id_circuito_firma='" + id_circuito_firma + "'></circuito_firma_baja></circuitos_firma_abm>"

            //tabla_circuito.eliminar_fila(nro_fila)
            nvFW.error_ajax_request('seleccion_entidad_circuito.aspx', {
                parameters: {
                    strXML: strXML,
                    accion: 'eliminarCircuito'
                },
                onSuccess: function (error, transport) {
                    if (error.numError == 0) {
                        //tabla_entidad.refresh()
                        tabla_circuito.refresh()
                    }
                }
            });
        }


        function ver_rm0(fila) {
            var idCircuitoFirma = tabla_circuito.getFila(fila)["id_circuito_firma"]
            var nroEntidad = tabla_circuito.getFila(fila)["nro_entidad"]
            var Parametros = new Array();
            Parametros["foo"] = "foo";
            var wincomp =
                nvFW.createWindow({
                    url: 'firmas_ABM.aspx?id_circuito_firma=' + idCircuitoFirma + "&nro_entidad=" + nroEntidad,
                    title: '<b>Modificar Circuito</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 1100,
                    height: 660,
                    onClose: function () {
                        if (tabla_circuito)
                            tabla_circuito.refresh()
                    }
                });
            wincomp.options.userData = { retorno: Parametros }
            wincomp.showCenter(true)
        }


        function loadMenu() {
            var vMenu2 = new tMenu('divMenu', 'vMenu2');
            Menus["vMenu2"] = vMenu2
            Menus["vMenu2"].alineacion = 'centro';
            Menus["vMenu2"].estilo = 'A';
            Menus["vMenu2"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>RM0</Desc></MenuItem>")
            vMenu2.MostrarMenu()
        }
  

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id="divMenu">
    </div>
    <div id="divRM0">
        <div id="div_tabla_circuito" style="height: 100%; width: 100%; overflow: hidden">
            <div id="tabla_circuito" style="width: 100%; height: 100%;">
            </div>
        </div>
    </div>
</body>
</html>
