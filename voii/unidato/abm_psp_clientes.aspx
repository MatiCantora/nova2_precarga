<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 5)) Then
        Response.Redirect("/FW/error/httpError_403.aspx")
    End If

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        Dim id_cliente As String = nvFW.nvUtiles.obtenerValor("id_cliente")
        Dim tipo_docu As String = nvFW.nvUtiles.obtenerValor("tipo_docu")
        Dim nro_docu As String = nvFW.nvUtiles.obtenerValor("nro_docu")
        Dim cuitcuil As String = nvFW.nvUtiles.obtenerValor("cuitcuil", "")
        Dim razon_social As String = nvFW.nvUtiles.obtenerValor("razon_social", "")
        Dim tipo_persona As String = nvFW.nvUtiles.obtenerValor("tipo_persona", "")
        Dim gran_cliente As String = nvFW.nvUtiles.obtenerValor("gran_cliente", "")
        'Dim aceptado As String = nvFW.nvUtiles.obtenerValor("aceptado", "")
        Dim StrSQL As String = ""
        Dim Err = New nvFW.tError()

        If id_cliente = "" Or tipo_docu = "" Or nro_docu = "" Then
            Err.numError = -1
            Err.titulo = "Error al procesar el comando"
            Err.mensaje = "Faltan completar campos obligarios"
            Err.response()
            Return
        End If

        Try
            Select Case modo.ToUpper
                Case "A"
                    StrSQL = "INSERT INTO nv_psp_clientes VALUES ('" & id_cliente & "','" & tipo_docu & "','" & nro_docu & "','" & cuitcuil & "','" & razon_social & "','" & tipo_persona & "','" & gran_cliente & "','" & nvApp.operador.login & "', getdate())"
                Case "M"
                    StrSQL = "UPDATE nv_psp_clientes Set cuitcuil='" & cuitcuil & "',razon_social='" & razon_social & "',tipo_persona='" & tipo_persona & "',gran_cliente='" & gran_cliente & "',login='" & nvApp.operador.login & "', momento=getdate() WHERE id_cliente = '" & id_cliente & "' and " & "tipo_docu= " & tipo_docu & " and nro_docu='" & nro_docu & "'"
                Case "B"
                    StrSQL = "DELETE FROM nv_psp_clientes WHERE id_cliente = '" & id_cliente & "' and " & "tipo_docu= " & tipo_docu & " and nro_docu='" & nro_docu & "'"
            End Select

            nvFW.nvDBUtiles.DBExecute(StrSQL, cod_cn:="UNIDATO")
            Err.numError = 0

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al procesar el comando"
            Err.mensaje = "No se pudo realizar la acción solicitada"
        End Try

        Err.response()
    End If

    Me.contents("filtro_psp_clientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_clientes' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_unidato_tipo_doc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPLAV_TIPO_DOC' cn='UNIDATO'><campos>ID_TIPO_DOC as id, TIPO_DOC as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Clientes PSP</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win_evento = nvFW.getMyWindow();
        var modo = '';

        function window_onload() {
            cargar_menu();
            cargar_datos();
            window_onresize();
        }

        function cargar_datos() {
            if (win_evento.options.userData.modo == 'M') {
                campos_defs.set_value('id_cliente', win_evento.options.userData.id_cliente);
                campos_defs.set_value('unidato_tipo_doc', win_evento.options.userData.tipo_docu);
                campos_defs.set_value('nro_docu', win_evento.options.userData.nro_docu);

                campos_defs.habilitar('id_cliente', false);
                campos_defs.habilitar('unidato_tipo_doc', false);
                campos_defs.habilitar('nro_docu', false);
                campos_defs.habilitar('cuitcuil', false);

                let rs = new tRS();
                let filtroWhere = "<criterio><select><filtro><id_cliente type='igual'>'" + campos_defs.get_value('id_cliente') + "'</id_cliente><tipo_docu type='igual'>" + campos_defs.get_value('unidato_tipo_doc') + "</tipo_docu><nro_docu type='igual'>'" + campos_defs.get_value('nro_docu') + "'</nro_docu></filtro></select></criterio>"
                rs.open(nvFW.pageContents.filtro_psp_clientes, '', filtroWhere, '');

                if (!rs.eof()) {
                    modo = 'M';
                    campos_defs.set_value('cuitcuil', parseInt(rs.getdata('cuitcuil')));
                    campos_defs.set_value('razon_social', rs.getdata('razon_social'));
                    document.getElementById("tipo_persona").value = rs.getdata('tipo_persona');
                    if (rs.getdata('gran_cliente') == 'True')
                        document.getElementById("check_gran_cliente").checked = true;
                    else
                        document.getElementById("check_gran_cliente").checked = false;
                    if (rs.getdata('aceptado') == 1)
                        document.getElementById("check_aceptado").checked = true;
                    else
                        document.getElementById("check_aceptado").checked = false;
                    document.getElementById("check_aceptado").disabled = true;

                }
            }
            else {
                modo = 'A';
                document.getElementById('menuItem_divMenu_0').hidden = true;
                document.getElementById('lb_ver_detalle').hidden = true;
                document.getElementById("check_aceptado").disabled = true;
            }            
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 3 : 6,
                    body_h = $$('body')[0].getHeight(),
                    divCabecera_height = $('divCabecera').getHeight();

                $('ver_detalle_operaciones').setStyle({ 'height': body_h - divCabecera_height - dif + 'px' });
            }
            catch (e) { }

        }

        function cargar_menu() {
            Menu = new tMenu('divMenu', 'Menu');

            Menus["Menu"] = Menu;
            Menus["Menu"].alineacion = "centro";
            Menus["Menu"].estilo = "A";

            Menu.loadImage("guardar", "/voii/image/icons/guardar.png");
            Menu.loadImage("aceptacion", "/voii/image/icons/tilde_verde.png");

            Menus["Menu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>aceptacion</icono><Desc>Agregar en Lista Aceptación</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_lista_aceptacion()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["Menu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["Menu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>");
          
            Menu.MostrarMenu();
        }

        function guardar() {
            if (campos_defs.get_value('id_cliente') == '' || campos_defs.get_value('unidato_tipo_doc') == '' || campos_defs.get_value('nro_docu') == '' || campos_defs.get_value('cuitcuil') == '') {
                nvFW.alert("Faltan completar campos obligatorios.");
                return;
            }

            nvFW.error_ajax_request('abm_psp_clientes.aspx',{
                parameters:
                {
                    modo: modo,
                    id_cliente: campos_defs.get_value('id_cliente'),
                    tipo_docu: campos_defs.get_value('unidato_tipo_doc'),
                    nro_docu: campos_defs.get_value('nro_docu'),
                    cuitcuil: campos_defs.get_value('cuitcuil'),
                    razon_social: campos_defs.get_value('razon_social'),
                    tipo_persona: document.getElementById("tipo_persona").value,
                    gran_cliente: document.getElementById("check_gran_cliente").checked
                },
                onSuccess: function (err, transport) {
                    win_evento.options.userData.hay_modificacion = true;
                    document.getElementById('menuItem_divMenu_0').hidden = false;
                    modo = 'M';
                    win_evento.options.userData.modo = 'M';
                    document.getElementById('lb_ver_detalle').hidden = false;
                }
            });
        }

        function ver_detalle_aceptado() {
            let win_evento = top.nvFW.createWindow({
                className: 'alphacube',
                url: '/voii/unidato/listar_topes_det.aspx',
                title: '<b> ABM Topes Detalle </b>',
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                parentWidthElement: parent.document.body,
                parentWidthPercent: 0.95,
                parentHeightElement: parent.document.body,
                parentHeightPercent: 0.95,
                centerHFromElement: parent.parent.parent.document.body,
                centerVFromElement: parent.parent.parent.document.body,
                destroyOnClose: true

            });

            win_evento.options.userData = { id_cliente: campos_defs.get_value('id_cliente'), cuitcuil: campos_defs.get_value('cuitcuil') };
            win_evento.showCenter(false);
        }

        function agregar_lista_aceptacion() {
            if ((campos_defs.get_value('id_cliente') != '') && (campos_defs.get_value('cuitcuil') != '')) {
                let win_evento = nvFW.createWindow({
                    className: 'alphacube',
                    url: 'topes_det_lote.aspx',
                    title: 'Agregar a Lista Aceptacion',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: true,
                    parentWidthElement: document.body,
                    parentWidthPercent: 0.70,
                    parentHeightElement: document.body,
                    parentHeightPercent: 0.70,
                    centerHFromElement: document.body,
                    centerVFromElement: document.body,
                    destroyOnClose: true
                });

                win_evento.options.userData = { id_psp_from: campos_defs.get_value('id_cliente'), cuitcuil: campos_defs.get_value('cuitcuil'), modo: 1 };
                win_evento.showCenter();
            }      
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenu"></div>

    <table id="divCabecera" class="tb1">
        <tr>
            <td class="Tit1">PSP </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_cliente', {enDB: true, mostrar_codigo: false });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Tipo Documento </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('unidato_tipo_doc', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_unidato_tipo_doc,
                        filtroWhere: "<id_tipo_doc type='igual'>%campo_value%</id_tipo_doc>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Nro Documento Cliente</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_docu', { nro_campo_tipo: 100, enDB: false });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1">CUIT/CUIL Cliente</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('cuitcuil', { nro_campo_tipo: 100, enDB: false });
                </script>
            </td>
        </tr>

         <tr>
            <td class="Tit1">Tipo Persona</td>
            <td>
                <select name="tipo_persona" id="tipo_persona" style="width: 100%">
                    <option value=""></option>
                    <option value="PH">Persona Humana </option>
                    <option value="PJ">Persona Jurídica </option>
                </select>
            </td>
        </tr>

        <tr>
            <td class="Tit1">Razón Social Cliente</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('razon_social', { nro_campo_tipo: 104, enDB: false });
                </script>
            </td>
        </tr>

         <tr>
            <td class="Tit1">Gran Cliente</td>
            <td>
                <input type="checkbox" name="check_gran_cliente" id="check_gran_cliente" />
            </td>
        </tr>

        <tr>
            <td class="Tit1">En Lista Aceptación</td>
            <td>
                <input type="checkbox" name="check_aceptado" id="check_aceptado" />
                <label id=lb_ver_detalle style="cursor:pointer;cursor:pointer;text-decoration:underline;" onclick="ver_detalle_aceptado()"> (Ver Detalle) </label>

            </td>
        </tr>

    </table>


</body>
</html>
