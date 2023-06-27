<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%

    Dim paramXML As String = nvFW.nvUtiles.obtenerValor("paramXML", "")
    If (paramXML <> "") Then
        Dim err As New tError()

        'If (Not op.tienePermiso("permisos_comentarios", 5)) Then Response.Redirect("/FW/error/httpError_401.aspx")

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("cire_com_detalle_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, paramXML.Length, paramXML)
        Try
            Dim rs As ADODB.Recordset = cmd.Execute()

            err = New nvFW.tError(rs)

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 105
            err.titulo = "Error en el SP"
            err.mensaje = "Error en el SP cire_com_detalle_abm"
        End Try

        err.response()
    End If

    Dim id_cire_com_detalle As Integer = nvFW.nvUtiles.obtenerValor("id_cire_com_detalle", 0)

    Dim nro_circuito As Integer = nvFW.nvUtiles.obtenerValor("nro_circuito", 0)
    Dim nro_com_tipo_origen As Integer = nvFW.nvUtiles.obtenerValor("nro_com_tipo_origen", 0)
    Dim nro_com_estado_origen As Integer = nvFW.nvUtiles.obtenerValor("nro_com_estado_origen", 0)

    Dim nro_com_tipo As String = ""
    Dim nro_com_estado As String = ""
    Dim nro_com_estado_origen_nuevo As String = ""
    Dim vigente As String = "True"

    Dim com_tipo_origen As String = ""
    Dim com_estado_origen As String = ""


    If id_cire_com_detalle > 0 Then
        'Edición
        Dim strSQLIBS As String = "Select TOP 1 nro_circuito, ISNULL(nro_com_tipo_origen, 0) As nro_com_tipo_origen, ISNULL(nro_com_estado_origen, 0) As nro_com_estado_origen, " +
                                                "ISNULL(com_tipo_origen, '') as com_tipo_origen, ISNULL(com_estado_origen, '') as com_estado_origen, " +
                                                "nro_com_tipo, nro_com_estado, ISNULL(nro_com_estado_origen_nuevo, 0) as nro_com_estado_origen_nuevo, vigente " +
                                  "FROM verCire_com_detalle WHERE id_cire_com_detalle = " + id_cire_com_detalle.ToString
        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQLIBS)

        If Not rs.EOF Then
            nro_circuito = rs.Fields("nro_circuito").Value
            nro_com_tipo_origen = rs.Fields("nro_com_tipo_origen").Value
            nro_com_estado_origen = rs.Fields("nro_com_estado_origen").Value
            com_tipo_origen = rs.Fields("com_tipo_origen").Value
            com_estado_origen = rs.Fields("com_estado_origen").Value

            nro_com_tipo = rs.Fields("nro_com_tipo").Value
            nro_com_estado = rs.Fields("nro_com_estado").Value
            nro_com_estado_origen_nuevo = rs.Fields("nro_com_estado_origen_nuevo").Value

            vigente = rs.Fields("vigente").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
    Else
        'Alta
        Dim tStrSQLIBS As String = "SELECT TOP 1 nro_com_tipo, com_tipo FROM com_tipos WHERE nro_com_tipo = " + nro_com_tipo_origen.ToString
        Dim tRs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(tStrSQLIBS)
        If Not tRs.EOF Then
            'nro_com_tipo_origen = tRs.Fields("nro_com_tipo").Value
            com_tipo_origen = tRs.Fields("com_tipo").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(tRs)

        Dim eStrSQLIBS As String = "SELECT TOP 1 nro_com_estado, com_estado FROM com_estados WHERE nro_com_estado = " + nro_com_estado_origen.ToString
        Dim eRs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(eStrSQLIBS)
        If Not eRs.EOF Then
            'nro_com_estado_origen = eRs.Fields("nro_com_estado").Value
            com_estado_origen = eRs.Fields("com_estado").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(eRs)
    End If

    Me.contents("id_cire_com_detalle") = id_cire_com_detalle
    Me.contents("nro_circuito") = nro_circuito

    Me.contents("nro_com_tipo_origen") = nro_com_tipo_origen
    Me.contents("com_tipo_origen") = com_tipo_origen
    Me.contents("nro_com_estado_origen") = nro_com_estado_origen
    Me.contents("com_estado_origen") = com_estado_origen

    Me.contents("nro_com_tipo") = nro_com_tipo
    Me.contents("nro_com_estado") = nro_com_estado
    Me.contents("nro_com_estado_origen_nuevo") = nro_com_estado_origen_nuevo
    Me.contents("vigente") = vigente

    Me.contents("filtroTipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>nro_com_tipo as id, com_tipo as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_estados'><campos>distinct nro_com_estado as id, com_estado as [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Circuito detalle</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var myWindow

        function window_onload() {
            myWindow = nvFW.getMyWindow()

            var vButtonItems = {}
            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "Aceptar";
            vButtonItems[0]["etiqueta"] = "Aceptar";
            vButtonItems[0]["imagen"] = "confirmar";
            vButtonItems[0]["onclick"] = "return guardar()";
            vButtonItems[1] = {}
            vButtonItems[1]["nombre"] = "Cancelar";
            vButtonItems[1]["etiqueta"] = "Cancelar";
            vButtonItems[1]["imagen"] = "cancelar";
            vButtonItems[1]["onclick"] = "return cancelar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("confirmar", '/FW/image/icons/confirmar.png');
            vListButton.loadImage("cancelar", '/FW/image/icons/cancelar.png');
            vListButton.MostrarListButton()


            if (!myWindow.options.userData)
                myWindow.options.userData = {}
            myWindow.options.userData.hay_modificacion = false

            if($('vigente'))
                $('vigente').checked = nvFW.pageContents.vigente == "True"
            
        }

        function cancelar() { myWindow.close() }

        function guardar() {

            // Validaciones
            var msg = ""
            if (campos_defs.get_value("nro_com_tipo") == "")
                msg += "No ha ingresado el valor para <b>Tipo</b><br>"
            if (campos_defs.get_value("nro_com_estado") == "") 
                msg += "No ha ingresado el valor para <b>Estado</b><br>"
            if (nvFW.pageContents.nro_com_estado_origen != 0 && campos_defs.get_value("nro_com_estado_origen_nuevo") == "")
                msg += "No ha ingresado el valor para <b>Estado Origen Nuevo</b><br>"
            if (msg != "") {
                alert(msg)
                return
            }

            //var modo = nvFW.pageContents.id_cire_com_detalle ? 'M' : 'A'
            var pXML = "<cire_com_detalle modo='" + (nvFW.pageContents.id_cire_com_detalle ? 'M' : 'A') + "' nro_circuito='" + nvFW.pageContents.nro_circuito + "' " + 
                "nro_com_tipo='" + campos_defs.get_value("nro_com_tipo") + "' nro_com_estado='" + campos_defs.get_value("nro_com_estado") + "' "
            if (nvFW.pageContents.id_cire_com_detalle)
                pXML += "id_cire_com_detalle='" + nvFW.pageContents.id_cire_com_detalle + "' "
            if (nvFW.pageContents.nro_com_tipo_origen)
                pXML += "nro_com_tipo_origen='" + nvFW.pageContents.nro_com_tipo_origen + "' "
            if (nvFW.pageContents.nro_com_estado_origen)
                pXML += "nro_com_estado_origen='" + nvFW.pageContents.nro_com_estado_origen + "' "
            if (nvFW.pageContents.nro_com_estado_origen)
                pXML += "nro_com_estado_origen_nuevo='" + campos_defs.get_value("nro_com_estado_origen_nuevo") + "' "
            if ($('vigente'))
                pXML += "vigente='" + ($('vigente').checked ? "1" : "0") + "' "
            pXML += " />"

            nvFW.error_ajax_request('cire_com_detalle_abm.aspx', {
                parameters: { paramXML: pXML },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        myWindow.options.userData = { res: 'ok' }
                        myWindow.options.userData.hay_modificacion = true
                    }
                    myWindow.close()
                },
                error_alert: true
            });

        }

        function abmTipo() {
            
                var win = top.nvFW.createWindow({
                    url: "/FW/comentario/com_tipos_abm.aspx",
                    width: 1024,
                    height: 600,
                    resizable: true,
                    maximizable: false,
                    minimizable: false,
                    //height: height,
                    //width: width,
                    onShow: function (win) {

                    },
                    onClose: function (win) {

                        //Forzamos la carga del combo
                        var campo = campos_defs.items["nro_com_tipo"].input_select
                        if (campo)
                            campos_defs.items["nro_com_tipo"].input_select.length = 0
                    }

                });

                win.showCenter(true)
            
        }


    </script>
</head>
<body style="overflow: hidden;background-color: white;" onload="window_onload()">
    <div id="divMenu" class="no-print"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        //vMenu.loadImage("arbol", '/FW/image/icons/arbol.png')

        vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Tipos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abmTipo()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu()
    </script>
    <table class="tb1">
        <%  If nro_com_tipo_origen > 0 Then %>
        <tr>
            <td class="Tit2">Tipo Origen</td>
            <td>
                <script>
                    campos_defs.add("com_tipo_origen", { enDB: false, nro_campo_tipo: 104 })
                    campos_defs.set_value("com_tipo_origen", nvFW.pageContents.com_tipo_origen)
                    campos_defs.habilitar("com_tipo_origen", false)
                </script>
            </td>
            <td class="Tit2">Estado Origen</td>
            <td>
                <script>
                    campos_defs.add("com_estado_origen", { enDB: false, nro_campo_tipo: 104 })
                    campos_defs.set_value("com_estado_origen", nvFW.pageContents.com_estado_origen)
                    campos_defs.habilitar("com_estado_origen", false)
                </script>
            </td>
        </tr>
        <%End If%>
        <tr>
            <td class="Tit2">Tipo</td>
            <td>
                <script>
                    campos_defs.add("nro_com_tipo",
                        {
                            enDB: false,
                            nro_campo_tipo: 1,
                            filtroXML: nvFW.pageContents.filtroTipos
                        })
                    campos_defs.set_value("nro_com_tipo", nvFW.pageContents.nro_com_tipo)
                </script>
            </td>
            <td class="Tit2">Estado</td>
            <td>
                <script>
                    campos_defs.add("nro_com_estado",
                        {
                            enDB: false,
                            nro_campo_tipo: 1,
                            filtroXML: nvFW.pageContents.filtroEstados
                        })
                    campos_defs.set_value("nro_com_estado", nvFW.pageContents.nro_com_estado)
                </script>
            </td>
        </tr>
        <%  If nro_com_tipo_origen > 0 Then %>
        <tr>
            <td colspan="2">&nbsp;</td>
            <td class="Tit2">Estado Origen Nuevo</td>
            <td>
                <script>
                    campos_defs.add("nro_com_estado_origen_nuevo",
                        {
                            enDB: false,
                            nro_campo_tipo: 1,
                            filtroXML: nvFW.pageContents.filtroEstados
                        })
                    campos_defs.set_value("nro_com_estado_origen_nuevo", nvFW.pageContents.nro_com_estado_origen_nuevo)
                </script>
            </td>
        </tr>
        <%End If%>
        <%  If id_cire_com_detalle > 0 Then %>
        <tr>
            <td class="Tit2">Vigente</td>
            <td><input style="border: 0;" type="checkbox" name="vigente" id="vigente" style="width: 100%" /></td>
        </tr>
        <%End If%>
    </table>
    <table class="tb1" style="position:absolute; bottom:0">
        <tr>
            <td style="width:10%"></td>
            <td style="width:40%">
                <div id="divAceptar" style="width: 100%"></div>
            </td>
            <td style="width:40%">
                <div id="divCancelar" style="width: 100%"></div>
            </td>
            <td style="width:10%"></td>
        </tr>
    </table>
</body>
</html>
