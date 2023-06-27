<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%

    Dim paramXML As String = nvFW.nvUtiles.obtenerValor("paramXML", "")
    If (paramXML <> "") Then
        Dim err As New tError()

        'If (Not op.tienePermiso("permisos_comentarios", 5)) Then Response.Redirect("/FW/error/httpError_401.aspx")

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("cire_estado_detalle_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, paramXML.Length, paramXML)
        Try
            Dim rs As ADODB.Recordset = cmd.Execute()

            err = New nvFW.tError(rs)

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 105
            err.titulo = "Error en el SP"
            err.mensaje = "Error en el SP cire_estado_detalle_abm"
        End Try

        err.response()
    End If

    Dim id_cire_estado As Integer = nvFW.nvUtiles.obtenerValor("id_cire_estado", 0)

    Dim nro_circuito As Integer = nvFW.nvUtiles.obtenerValor("nro_circuito", 0)
    Dim estado_origen As String = nvFW.nvUtiles.obtenerValor("estado_origen", "")

    Dim estado As String = ""

    Dim vigente As String = "True"

    Dim estado_origen_desc As String = ""


    If id_cire_estado > 0 Then
        'Edición
        Dim strSQLIBS As String = "Select TOP 1 nro_circuito, ISNULL(estado_origen, '') As estado_origen, " +
                                                "ISNULL(estado_origen_desc, '') as estado_origen_desc, " +
                                                " estado, vigente " +
                                  "FROM verCire_estado_detalle WHERE id_cire_estado = " + id_cire_estado.ToString
        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQLIBS)

        If Not rs.EOF Then
            nro_circuito = rs.Fields("nro_circuito").Value
            estado_origen = rs.Fields("estado_origen").Value
            estado_origen_desc = rs.Fields("estado_origen_desc").Value

            estado = rs.Fields("estado").Value

            vigente = rs.Fields("vigente").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
    ElseIf estado_origen <> "" Then
        'Alta
        Dim tStrSQLIBS As String = "SELECT TOP 1 sol_estado_desc FROM sol_estados WHERE sol_estado = " + estado_origen
        Dim tRs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(tStrSQLIBS)
        If Not tRs.EOF Then
            'nro_com_tipo_origen = tRs.Fields("nro_com_tipo").Value
            estado_origen_desc = tRs.Fields("sol_estado_desc").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(tRs)

    End If

    Me.contents("id_cire_estado") = id_cire_estado
    Me.contents("nro_circuito") = nro_circuito

    Me.contents("estado_origen") = estado_origen
    Me.contents("estado_origen_desc") = estado_origen_desc

    Me.contents("estado") = estado

    Me.contents("vigente") = vigente

    Me.contents("filtroEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='sol_estados'><campos>distinct sol_estado as id, sol_estado_desc as [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

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
            if (campos_defs.get_value("estado") == "") 
                msg += "No ha ingresado el valor para <b>Estado</b><br>"
            if (msg != "") {
                alert(msg)
                return
            }

            //var modo = nvFW.pageContents.id_cire_estado ? 'M' : 'A'
            var pXML = "<cire_estado_detalle modo='" + (nvFW.pageContents.id_cire_estado ? 'M' : 'A') + "' nro_circuito='" + nvFW.pageContents.nro_circuito + "' " + 
                " estado='" + campos_defs.get_value("estado") + "' "
            if (nvFW.pageContents.id_cire_estado)
                pXML += "id_cire_estado='" + nvFW.pageContents.id_cire_estado + "' "
            if (nvFW.pageContents.estado_origen)
                pXML += "estado_origen='" + nvFW.pageContents.estado_origen + "' "
            if ($('vigente'))
                pXML += "vigente='" + ($('vigente').checked ? "1" : "0") + "' "
            pXML += " />"

            nvFW.error_ajax_request('cire_estado_detalle_abm.aspx', {
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
    </script>
</head>
<body style="overflow: hidden;background-color: white;" onload="window_onload()">
    <table class="tb1">
        <%  If estado_origen <> "" Then %>
        <tr>
            <td class="Tit2">Estado Origen</td>
            <td>
                <script>
                    campos_defs.add("estado_origen_desc", { enDB: false, nro_campo_tipo: 104 })
                    campos_defs.set_value("estado_origen_desc", nvFW.pageContents.estado_origen_desc)
                    campos_defs.habilitar("estado_origen_desc", false)
                </script>
            </td>
        </tr>
        <%End If%>
        <tr>
            <td class="Tit2">Estado</td>
            <td>
                <script>
                    campos_defs.add("estado",
                        {
                            enDB: false,
                            nro_campo_tipo: 1,
                            filtroXML: nvFW.pageContents.filtroEstados
                        })
                    campos_defs.set_value("estado", nvFW.pageContents.estado)
                </script>
            </td>
        </tr>
        <%  If id_cire_estado > 0 Then %>
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
