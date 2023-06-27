<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 3)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then

        Dim nro_tope_def As String = nvFW.nvUtiles.obtenerValor("nro_tope_def", "")
        Dim nro_tope_tipo As String = nvFW.nvUtiles.obtenerValor("nro_tope_tipo", "")
        Dim nro_tope As String = nvFW.nvUtiles.obtenerValor("nro_tope", "")
        Dim tope_def As String = nvFW.nvUtiles.obtenerValor("tope_def", "")
        Dim origen As String = nvFW.nvUtiles.obtenerValor("origen", "")
        Dim vigente As String = nvFW.nvUtiles.obtenerValor("vigente", "")
        Dim movs_propios As String = nvFW.nvUtiles.obtenerValor("movs_propios", "")
        Dim tipo_periodo As String = nvFW.nvUtiles.obtenerValor("tipo_periodo", "")
        Dim id_tipo_alarma As String = nvFW.nvUtiles.obtenerValor("id_tipo_alarma", "")
        Dim StrSQL As String = ""
        Dim Err = New nvFW.tError()

        Try
            Select Case modo.ToUpper
                Case "A"
                    Dim rsTest As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT nro_tope_def FROM nv_psp_topes_def WHERE vigente=1 and id_tipo_alarma=" & id_tipo_alarma, cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rsTest.EOF Then
                        Err.numError = -1
                        Err.titulo = "Creación de definición no permitida"
                        Err.mensaje = "Ya existe otra definición vigente para ese tipo de alarma seleccionada."
                        Err.response()
                        Return
                    End If

                    If (Not op.tienePermiso("permisos_alarmas_pld", 6)) Then
                        Err.numError = 0
                        Err.titulo = "Edición de definición no permitida"
                        Err.mensaje = "No tiene permiso para realizar esta acción."
                        Err.response()
                        Return
                    End If

                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT nro_tope_def FROM nv_psp_topes_def WHERE nro_tope='" & nro_tope & "' and vigente=1 and id_tipo_alarma=" & id_tipo_alarma & " and origen='" & origen & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If rs.EOF Then
                        StrSQL = "INSERT INTO nv_psp_topes_def (nro_tope_tipo, nro_tope, tope_def, origen, vigente, fe_alta, tipo_periodo, id_tipo_alarma, movs_propios) VALUES (" & nro_tope_tipo & ",'" & nro_tope & "','" & tope_def & "','" & origen & "'," & vigente & ", getdate() ,'" & tipo_periodo & "'," & id_tipo_alarma & "," & movs_propios & ")"
                    Else
                        Err.numError = -2
                        Err.titulo = "Creación de definición no permitida"
                        Err.mensaje = "No se puede crear una nueva definición con ese número de tope y ese tipo de alarma porque ya existe una definicion con esas condiciones."
                        Err.response()
                        Return
                    End If

                Case "M"
                    Dim rsTest As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT nro_tope_def FROM nv_psp_topes_def WHERE vigente=1 and id_tipo_alarma=" & id_tipo_alarma & "and nro_tope <> '" & nro_tope & "'", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rsTest.EOF Then
                        Err.numError = -1
                        Err.titulo = "Modificacion de definición no permitida"
                        Err.mensaje = "Ya existe otra definición vigente para ese tipo de alarma seleccionada."
                        Err.response()
                        Return
                    End If

                    If (Not op.tienePermiso("permisos_alarmas_pld", 6)) Then
                        Err.numError = 0
                        Err.titulo = "Edición de definición no permitida"
                        Err.mensaje = "No tiene permiso para realizar esta acción."
                        Err.response()
                        Return
                    End If

                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT nro_tope_def FROM nv_psp_topes_def WHERE nro_tope='" & nro_tope & "' and vigente=1 and id_tipo_alarma=" & id_tipo_alarma & " and nro_tope_def !=" & nro_tope_def, cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If rs.EOF Then
                        StrSQL = "UPDATE nv_psp_topes_def SET nro_tope_tipo='" & nro_tope_tipo & "',nro_tope='" & nro_tope & "',tope_def='" & tope_def & "',vigente=" & vigente & " ,tipo_periodo='" & tipo_periodo & "', id_tipo_alarma=" & id_tipo_alarma & ", origen='" & origen & "', movs_propios=" & movs_propios & " WHERE nro_tope_def = " & nro_tope_def
                    Else
                        Err.numError = -3
                        Err.titulo = "Modificación de definición no permitida"
                        Err.mensaje = "No se puede establecer una definición con ese número de tope y ese tipo de alarma porque ya existe una definicion con esas condiciones."
                        Err.response()
                        Return
                    End If

                Case "B"
                    If (Not op.tienePermiso("permisos_alarmas_pld", 6)) Then
                        Err.numError = 0
                        Err.titulo = "Edición de definición no permitida"
                        Err.mensaje = "No tiene permiso para realizar esta acción."
                        Err.response()
                        Return
                    End If

                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="Select nro_topes_det FROM nv_psp_topes_det WHERE nro_tope_def=" & nro_tope_def, cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)
                    If rs.EOF Then
                        StrSQL = "DELETE FROM nv_psp_topes_def_mov_tipo WHERE nro_tope_def = " & nro_tope_def & "; DELETE FROM nv_psp_topes_def WHERE nro_tope_def = " & nro_tope_def
                    Else
                        StrSQL = "UPDATE nv_psp_topes_def SET vigente=0 WHERE nro_tope_def =" & nro_tope_def & "; update nv_psp_topes_det set fecha_baja=getdate() where nro_tope_def=" & nro_tope_def
                    End If
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

    Me.contents("filtro_tipo_periodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_listar_psp_topes_def' cn='UNIDATO'><campos>distinct tipo_periodo as [id], tipo_periodo as [campo]</campos><filtro><NOT><tipo_periodo type='isnull'/></NOT></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipo_alarma") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='TPCSC_TIPO_ALARMA' cn='UNIDATO'><campos>id_tipo_alarma as [id], tipo_alarma as [campo]</campos><filtro><tipo_alarma type='like'>%psp%</tipo_alarma></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipo_tope") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_tipos' cn='UNIDATO'><campos>nro_tope_tipo as [id], tope_tipo as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipos_movs") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_mov_tipos' cn='UNIDATO'><campos>mov_tipo as [id], mov_tipo_desc as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_topes_def_mov_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_mov_tipos' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_topes_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Def Topes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();
        var modo = 'A'

        function window_onload() {
            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            pMenu.loadImage("guardar", "../image/icons/guardar.png");
            pMenu.MostrarMenu();

            cargar_datos_ventana();
            window_onresize();
        }

        function window_onresize() {
            try {
                let dif = Prototype.Browser.IE ? 10 : 0;
                let body_heigth = $$('body')[0].getHeight();
                let cab_heigth = $('tb_contenido').getHeight();
                let menu_heigth = $('divMenuPrincipal').getHeight();

                $('ver_tipo_movs').setStyle({ 'height': body_heigth - cab_heigth - menu_heigth - dif + 'px' });
            }
            catch (e) { }
        }

        function cargar_datos_ventana() {
            if (win.options.userData != null) {
                campos_defs.set_value('tope_def', win.options.userData.tope_def);
                campos_defs.set_value('nro_tope_tipo', win.options.userData.nro_tope_tipo);
                campos_defs.set_value('nro_tope', win.options.userData.nro_tope);
                campos_defs.set_value('id_tipo_alarma', win.options.userData.id_tipo_alarma);
                campos_defs.set_value('tipo_periodo', win.options.userData.tipo_periodo);
                document.getElementById('origen').value = win.options.userData.origen;
                modo = win.options.userData.modo;

                if (win.options.userData.vigente == "True")
                    document.getElementById('vigente').value = "1";
                else
                    document.getElementById('vigente').value = "0";

                if (win.options.userData.movs_propios == "True")
                    document.getElementById('movs_propios').value = "1";
                else
                    document.getElementById('movs_propios').value = "0";

                cargar_tipos_movs();
            } 

        }

        function cargar_tipos_movs() {
            if (win.options.userData.nro_tope_def != undefined) {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_topes_def_mov_tipo,
                    filtroWhere: "<criterio><select><filtro><nro_tope_def type='igual'>'" + win.options.userData.nro_tope_def + "'</nro_tope_def></filtro></select></criterio>",
                    path_xsl: 'report/unidato/verNv_psp_def_topes_tipos_movs.xsl',
                    formTarget: 'ver_tipo_movs',
                    nvFW_mantener_origen: true,
                    cls_contenedor: 'ver_tipo_movs'
                });
            }
        }

        function guardar() {
            let nro_tope_def = "";
            if (win.options.userData.nro_tope_def != "")
                nro_tope_def = win.options.userData.nro_tope_def;
            let errores = validar();

            if (errores == 0) {
                nvFW.error_ajax_request('abm_def_topes.aspx', {
                    parameters:
                    {
                        modo: modo,
                        nro_tope_def: nro_tope_def,
                        nro_tope_tipo: campos_defs.get_value('nro_tope_tipo'),
                        nro_tope: campos_defs.get_value('nro_tope'),
                        tope_def: campos_defs.get_value('tope_def'),
                        tipo_periodo: campos_defs.get_value('tipo_periodo'),
                        origen: document.getElementById("origen").value,
                        movs_propios: document.getElementById("movs_propios").value,
                        vigente: document.getElementById("vigente").value,
                        id_tipo_alarma: campos_defs.get_value('id_tipo_alarma')
                    },
                    onSuccess: function (err, transport) {
                        win.options.userData.hay_modificacion = true;
                    }
                });
            }

            else if (errores == -1)
                nvFW.alert("Error. Debe completar todos los campos para proceder.");

            else if (errores == -2)
                nvFW.alert("Error.Ya existe una definición vigente con ese tipo de alarma seleccionada.");

        }

        function validar() {
            if (campos_defs.get_value('tope_def') == '')
                return -1;
            else if (campos_defs.get_value('nro_tope_tipo') == '')
                return -1;
            else if (campos_defs.get_value('nro_tope') == '')
                return -1;
            else if (campos_defs.get_value('tipo_periodo') == '')
                return -1;
            else if (campos_defs.get_value('id_tipo_alarma') == '')
                return -1;
            else if (document.getElementById('origen').value == '0')
                return -1;
            else {
                //Validar que un tipo de alarma solo pueda estar en una def_tope
                let rs = new tRS();
                let filtroWhere = "<criterio><select><filtro><NOT><nro_tope type='igual'>'" + campos_defs.get_value('nro_tope') + "'</nro_tope></NOT><id_tipo_alarma type='igual'>" + campos_defs.get_value('id_tipo_alarma') + "</id_tipo_alarma><vigente type='igual'>1</vigente></filtro></select></criterio>";
                rs.open({ filtroXML: nvFW.pageContents.filtro_topes_def, filtroWhere: filtroWhere });

                if (rs.eof())
                    return 0;
                else
                    return -2;
            }
        }

        function eliminar_tipo_mov(mov_tipo) {
            if (win.options.userData.nro_tope_def == undefined) {
                nvFW.alert("No se puede eliminar un movimiento sin definición asociada.");
                return;
            }

            Dialog.confirm("¿Está seguro que desea elimar este movimiento para esta definición?", {
                width: 450,
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar',
                className: "alphacube",
                onOk: function (winDialog) {
                    nvFW.error_ajax_request('abm_def_tipos_movs.aspx', {
                        parameters:
                        {
                            modo: 'BM',
                            mov_tipo: mov_tipo,
                            nro_tope_def: win.options.userData.nro_tope_def
                        },
                        onSuccess: function (err, transport) {
                            cargar_tipos_movs();
                            winDialog.close();
                        }
                    });
                }
            }); 
        }

        function asociar_nuevo_movimiento() {
            let winMov = nvFW.createWindow({
                className: 'alphacube',
                url: 'abm_def_tipos_movs.aspx',
                title: '<b>Asociar Nuevo Movimiento</b>',
                minimizable: false,
                maximizable: false,
                resizable: false,
                draggable: true,
                width: 400,
                height: 250,
                destroyOnClose: true,
                onClose: function () {
                    if (winMov.options.userData.hay_modificacion)
                        cargar_tipos_movs();
                }

            });

            winMov.options.userData = { nro_tope_def: win.options.userData.nro_tope_def, hay_modificacion: false}
            winMov.showCenter(true);
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <table id="tb_contenido" class="tb1 layout_fixed">
        <tr>
            <td style="width: 30%">Definición de Tope</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tope_def', { nro_campo_tipo: 104, enDB: false });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 30%">Tipo de Tope</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_tope_tipo', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipo_tope,
                        filtroWhere: "<nro_tope_tipo type='igual'>%campo_value%</nro_tope_tipo>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 30%">Número de Tope</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_tope', { nro_campo_tipo: 104, enDB: false });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 30%">Origen</td>
            <td style="text-align: center; width: 5%;">
                <select name="origen" id="origen" style="width: 100%">
                    <option value="0"></option>
                    <option value="Titular">Titular</option>
                    <option value="Contraparte">Contraparte</option>
                </select>
            </td>
        </tr>
        <tr>
            <td style="width: 30%" title="¿Toma movimientos propios?">Toma movimientos propios</td>
            <td style="text-align: center; width: 5%;">
                <select name="movs_propios" id="movs_propios" style="width: 100%">
                    <option value="0">No</option>
                    <option value="1">Si</option>
                </select>
            </td>
        </tr>
        <tr>
            <td style="width: 30%">Vigente</td>
            <td style="text-align: center; width: 5%;">
                <select name="vigente" id="vigente" style="width: 100%">
                    <option value="1">Si</option>
                    <option value="0">No</option>
                </select>
            </td>
        </tr>
        <tr>
            <td style="width: 30%">Tipo de Período</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tipo_periodo', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipo_periodo,
                        filtroWhere: "<tipo_periodo type='igual'>'%campo_value%'</tipo_periodo>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
        </tr>
        <tr>
            <td style="width: 30%">Tipo de Alarma</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id_tipo_alarma', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipo_alarma,
                        filtroWhere: "<id_tipo_alarma type='igual'>'%campo_value%'</id_tipo_alarma>"
                    });
                </script>
            </td>
        </tr>
    </table>

    <iframe name="ver_tipo_movs" id="ver_tipo_movs" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>

</body>
</html>
