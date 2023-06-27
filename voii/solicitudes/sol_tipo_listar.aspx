<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim op = nvFW.nvApp.getInstance.operador

    Dim ErrPermiso As New nvFW.tError()
    If Not op.tienePermiso("permisos_sol_tipos", 1) Then
        Response.Redirect("/FW/error/httpError_401.aspx")
    End If

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "C")         '//Modos --->    'C': Consulta - M: Modif.Parámetros

    If modo.ToUpper() = "M" Then
        Dim pErr As New tError()

        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sol_param_def_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()


            pErr.numError = rs.Fields("numError").Value
            pErr.titulo = rs.Fields("titulo").Value
            pErr.mensaje = rs.Fields("mensaje").Value
            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception

            pErr.numError = -1
            pErr.mensaje = "Error inesperado"
            pErr.titulo = "Error al tratar de realizar la operación"
            pErr.debug_desc = ex.Message.ToString
            pErr.debug_src = "sol_param_def_abm"

        End Try

        pErr.response()

    End If

    Me.contents("filtro_sol_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='verSol_tipos'><campos>nro_sol_tipo, sol_tipo, circuito</campos><orden>sol_tipo</orden><filtro></filtro></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Tipos de Solicitud</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <% = Me.getHeadInit()%>
    
    <script type="text/javascript">
        //Cargar botones
        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "BuscarTipo";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscarTipo()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');

        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

        function window_onload() {
            vListButton.MostrarListButton();

            buscarTipo()
        }

        function window_onresize() {
            try {

                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var menuTipo_h = $('divMenuSolTipos').getHeight()
                var tbTipos_h = $('solTipos').getHeight() + 1

                var calculo = body_h - menuTipo_h - dif

                if (tbTipos_h > calculo)
                    $('divParametros').setStyle({ 'height': (body_h - menuTipo_h - dif) + 'px' })
                else {
                    $('divParametros').setStyle({ 'height': (tbTipos_h) + 'px' })
                    //$('divPie').setStyle({ 'height': (body_h - tbParametros_h - dif) + 'px' })
                }

            }
            catch (e) { console.log(e.message) }
        }


        function buscarTipo() {

            var tipoRs = new tRS();
            var filtro = ''

            if (campos_defs.get_value('tipo_search')) {
                filtro += "<criterio><select><filtro><nro_sol_tipo type='like'>%" + campos_defs.get_value('tipo_search') + "%</nro_sol_tipo></filtro></select></criterio>"
            }
            
            tipoRs.open(nvFW.pageContents.filtro_sol_tipos, "", filtro);
            var tiposTbody = $('solTipos')
            tBodyHTML = '<tr class="tbLabel0"><td style="width:19%">Tipo</td><td style="width:60%">Descripción</td><td style="width:30%">Circuito</td><td></td><td></td></tr>'
            
            while (!tipoRs.eof()) {

                tBodyHTML += '<tr><td style="width:19%">' + tipoRs.getdata("nro_sol_tipo") + '</td>' +
                    '<td style="width:60%">' + tipoRs.getdata("sol_tipo") + '</td>' +
                    '<td style="width:30%">' + (tipoRs.getdata("circuito") ? tipoRs.getdata("circuito") : '') + '</td>' +
                    '<td><a onclick="abm_sol_tipo(\'' + tipoRs.getdata("nro_sol_tipo") + '\')"><img title="Editar" src="/fw/image/icons/editar.png" style="cursor:pointer" border="0"></a></td>' +
                    '<td><a onclick="eliminar_sol_tipo(\'' + tipoRs.getdata(" nro_sol_tipo") + '\')" > <img title="Eliminar" src="/fw/image/icons/eliminar.png" style="cursor:pointer" border="0"></a></td ></tr>';

                tipoRs.movenext()
            }

            tiposTbody.innerHTML = tBodyHTML;

            window_onresize();
        }

        function key_Buscar() {
            if (window.event.keyCode == 13)
                buscarTipo(0);
        }


        


        var win_tipo_solicitud_abm
        function abm_sol_tipo(nro_sol_tipo) {
            var urlABM = '/voii/solicitudes/sol_tipo_abm.aspx'
            if (nro_sol_tipo)
                urlABM += '?nro_sol_tipo=' + nro_sol_tipo
            
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_tipo_solicitud_abm = w.createWindow({
                className: 'alphacube',
                url: urlABM,
                title: '<b>ABM Tipo Solicitud</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                resizable: false,
                modal: true,
                width: 400,
                height: 250,
                onClose: function () {
                    if (win_tipo_solicitud_abm.options.userData.hay_modificacion)
                        buscarTipo();
                }
            });
            win_tipo_solicitud_abm.showCenter(true);
         
        }

        function eliminar_sol_tipo(nro_sol_tipo) {

            Dialog.confirm('¿Desea eliminar el tipo de solicitud?', {
                width: 350,
                className: "alphacube",
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                onOk: function (win) {
                    win.close();
                    var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>";
                    strXML += "<sol_tipo modo='B' nro_sol_tipo='" + nro_sol_tipo + "'></sol_tipo>";

                    nvFW.error_ajax_request('sol_tipo_abm.aspx', {
                        parameters: { modo: 'B', strXML: strXML },
                        onSuccess: function (err, transport) {

                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }

                            buscarTipo();

                        },
                        error_alert: true
                    });
                },
                onCancel: function (win) {
                    //window_onload()
                    win.close()
                }
            });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  onkeypress="return key_Buscar()" style='width: 100%; height: 100%; overflow: hidden;'>
    
        <div id="divMenuSolTipos"></div>
        <script type="text/javascript">
            var vMenuSolTipos = new tMenu('divMenuSolTipos', 'vMenuSolTipos');
            Menus["vMenuSolTipos"] = vMenuSolTipos;
            Menus["vMenuSolTipos"].alineacion = 'centro';
            Menus["vMenuSolTipos"].estilo = 'A';
            Menus["vMenuSolTipos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuSolTipos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_sol_tipo()</Codigo></Ejecutar></Acciones></MenuItem>")

            Menus["vMenuSolTipos"].loadImage('hoja', '/FW/image/icons/nueva.png')
            vMenuSolTipos.MostrarMenu()
        </script>
        <table class="tb1">
            <tr>
                <td class="Tit1" style="width:100px" nowrap>Tipo:</td>
                <td >
                    <script>
                        campos_defs.add('tipo_search', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
                <td style="width: 100px"><div id="divBuscarTipo"></div></td>
            </tr>
        </table>
        
        <div id="divParametros" style="width:100%;overflow:auto;">
            <table class="tb1 highlightOdd highlightTROver layout_fixe">   
                <tbody id="solTipos"></tbody>
            </table>
        </div>
        
</body>
</html>
