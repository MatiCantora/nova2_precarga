<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim tipdoc = nvUtiles.obtenerValor("tipdoc", "")
    Dim accion = nvUtiles.obtenerValor("accion", -1)
    Dim nrodoc = nvUtiles.obtenerValor("nrodoc", "")
    Dim cuit_cuil = nvUtiles.obtenerValor("cuit_cuil", "")
    Dim razon_social = nvUtiles.obtenerValor("razon_social", "")
    Dim codafinidad = nvUtiles.obtenerValor("codafinidad", "")

    Dim tipdoc1 = nvUtiles.obtenerValor("tipdoc1", "")
    Dim nrodoc1 = nvUtiles.obtenerValor("nrodoc1", "")
    Dim cuit_cuil1 = nvUtiles.obtenerValor("cuit_cuil1", "")
    Dim razon_social1 = nvUtiles.obtenerValor("razon_social1", "")
    Dim codafinidad1 = nvUtiles.obtenerValor("codafinidad1", "")

    'Me.contents("tipdoc") = nvUtiles.obtenerValor("tipdoc", "")
    'Me.contents("nrodoc") = nvUtiles.obtenerValor("nrodoc", "")
    'Me.contents("cuit_cuil") = nvUtiles.obtenerValor("cuit_cuil", "")
    'Me.contents("razon_social") = nvUtiles.obtenerValor("razon_social", "")
    'Me.contents("codafinidad") = nvUtiles.obtenerValor("codafinidad", "")


    Me.contents("filtroAsig") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_asignacion' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    If (accion <> -1) Then
        If (codafinidad <> "" And accion = 0) Then
            Dim err As New tError
            Try
                If (nrodoc = "") Then
                    DBExecute("INSERT INTO ga_asignacion (tipdoc,cuit_cuil,razon_social,codafinidad) VALUES (" & tipdoc & ",'" & cuit_cuil & "','" & razon_social & "'," & codafinidad & ")",, "BD_IBS_ANEXA")
                ElseIf (cuit_cuil = "") Then
                    DBExecute("INSERT INTO ga_asignacion (tipdoc,nrodoc,razon_social,codafinidad) VALUES (" & tipdoc & "," & nrodoc & ",'" & razon_social & "'," & codafinidad & ")",, "BD_IBS_ANEXA")
                Else
                    DBExecute("INSERT INTO ga_asignacion (tipdoc,nrodoc,cuit_cuil,razon_social,codafinidad) VALUES (" & tipdoc & "," & nrodoc & ",'" & cuit_cuil & "','" & razon_social & "'," & codafinidad & ")",, "BD_IBS_ANEXA")
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = -99
                err.titulo = "Error en la actualización del estado"
                err.mensaje = "Mensaje:  " & ex.Message
            End Try
            err.response()

        ElseIf (codafinidad <> "" And accion = 1) Then
            Dim err As New tError
            Try
                If (nrodoc = "") Then
                    DBExecute("DELETE FROM ga_asignacion WHERE tipdoc =" & tipdoc & " and cuit_cuil ='" & cuit_cuil & "' and razon_social ='" & razon_social & "' and codafinidad =" & codafinidad,, "BD_IBS_ANEXA")
                ElseIf (cuit_cuil = "") Then
                    DBExecute("DELETE FROM ga_asignacion WHERE tipdoc =" & tipdoc & " and nrodoc =" & nrodoc & " and razon_social ='" & razon_social & "' and codafinidad =" & codafinidad,, "BD_IBS_ANEXA")
                Else
                    DBExecute("DELETE FROM ga_asignacion WHERE tipdoc =" & tipdoc & " and nrodoc =" & nrodoc & " and cuit_cuil ='" & cuit_cuil & "' and razon_social ='" & razon_social & "' and codafinidad =" & codafinidad,, "BD_IBS_ANEXA")
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = -99
                err.titulo = "Error en la actualización del estado"
                err.mensaje = "Mensaje:  " & ex.Message
            End Try
            err.response()

        ElseIf (codafinidad <> "" And accion = 3) Then
            Dim err As New tError
            Try
                If (cuit_cuil = "" And cuit_cuil1 <> "" And nrodoc <> "" And nrodoc1 = "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc =" & nrodoc & ", cuit_cuil = null, razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and cuit_cuil ='" & cuit_cuil1 & "' and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (cuit_cuil <> "" And cuit_cuil1 = "" And nrodoc = "" And nrodoc1 <> "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc = null, cuit_cuil ='" & cuit_cuil & "', razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and nrodoc =" & nrodoc1 & " and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (nrodoc <> "" And nrodoc1 = "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc =" & nrodoc & ", cuit_cuil ='" & cuit_cuil & "', razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and cuit_cuil ='" & cuit_cuil1 & "' and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (cuit_cuil <> "" And cuit_cuil1 = "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc =" & nrodoc & ", cuit_cuil ='" & cuit_cuil & "', razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and nrodoc =" & nrodoc1 & " and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (nrodoc = "" And nrodoc1 <> "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc = null, cuit_cuil ='" & cuit_cuil & "', razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and nrodoc =" & nrodoc1 & " and cuit_cuil ='" & cuit_cuil1 & "' and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (cuit_cuil = "" And cuit_cuil1 <> "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc =" & nrodoc & ", cuit_cuil = null, razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and nrodoc =" & nrodoc1 & " and cuit_cuil ='" & cuit_cuil1 & "' and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (nrodoc = "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", cuit_cuil ='" & cuit_cuil & "', razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and cuit_cuil ='" & cuit_cuil1 & "' and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                ElseIf (cuit_cuil = "") Then
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc =" & nrodoc & ", razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and nrodoc =" & nrodoc1 & " and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                Else
                    DBExecute("UPDATE ga_asignacion SET tipdoc =" & tipdoc & ", nrodoc =" & nrodoc & ", cuit_cuil ='" & cuit_cuil & "', razon_social ='" & razon_social & "', codafinidad =" & codafinidad & " WHERE tipdoc =" & tipdoc1 & " and nrodoc =" & nrodoc1 & " and cuit_cuil ='" & cuit_cuil1 & "' and razon_social ='" & razon_social1 & "' and codafinidad =" & codafinidad1,, "BD_IBS_ANEXA")
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = -99
                err.titulo = "Error en la actualización del estado"
                err.mensaje = "Mensaje:  " & ex.Message
            End Try
            err.response()

        End If
    End If

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administrador de Movimientos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit() %>


    <script type="text/javascript">
        var tipdoc1
        var razon_social1
        var nrodoc1
        var cuit_cuil1
        var codafinidad1
        var accion

        var data

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "saveAsig()";
        vButtonItems[1] = new Array();
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "cancelar";
        vButtonItems[1]["onclick"] = "cancelar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("guardar", "/fw/image/icons/guardar.png")
        vListButton.loadImage("cancelar", "/fw/image/icons/cancelar.png")

        function window_onload() {
            vListButton.MostrarListButton()

            var win = nvFW.getMyWindow();
            data = win.options.userData;

            if (data.tipdoc != '') {
                campos_defs.set_value('codafinidad', data.codafinidad)
                campos_defs.set_value('tipdoc', data.tipdoc)
                $('razonsocial').value = data.razon_social
                $('nrocuil').value = data.cuit_cuil
                $('nrodoc').value = data.nrodoc

                codafinidad1 = data.codafinidad
                tipdoc1 = data.tipdoc
                razon_social1 = data.razon_social
                cuit_cuil1 = $('nrocuil').value
                nrodoc1 = data.nrodoc
                accion = 3
            }
        }

        function cancelar() {
            nvFW.getMyWindow().close()
        }

        function saveAsig() {
            var codafinidad
            var filtWhere = ''
            var nrodoc 
            var tipdoc
            var cuit_cuil = ''
            var razonsocial = ''
            var b = 0


            if ($('codafinidad').value != '') {
                codafinidad = $('codafinidad').value
                filtWhere += "<codafinidad type=' in'>" + codafinidad + "</codafinidad>"
            } else {
                alert('ingresar el Codigo de Afinidad por favor')
                return
            }

            if ($('tipdoc').value != '') {
                tipdoc = $('tipdoc').value
                filtWhere += "<tipdoc type='igual'>" + tipdoc + "</tipdoc>"
            } else {
                alert('ingresar el Tipo de Documento por favor')
                return
            }

            if ($('razonsocial').value != '') {
                razonsocial = $('razonsocial').value
                filtWhere += "<razon_social type='igual'>'" + razonsocial + "'</razon_social>"
            } else {
                alert('ingresar el Razon Social por favor')
                return
            }

            if ($('nrodoc').value == '' && $('nrocuil').value == '') {
                alert('ingresar el Numero de documento o CUIT-CUIL por favor')
                return
            } else {
                if ($('nrodoc').value != '') {
                    nrodoc = $('nrodoc').value
                    filtWhere += "<nrodoc type='igual'>" + nrodoc + "</nrodoc>"
                }

                if ($('nrocuil').value != '') {
                    cuit_cuil = $('nrocuil').value
                    filtWhere += "<cuit_cuil type='igual'>'" + cuit_cuil + "'</cuit_cuil>"
                }
            }

            var rs = new tRS();
            rs.open({
                filtroXML: nvFW.pageContents.filtroAsig,
                filtroWhere: "<criterio><select><filtro>" + filtWhere + "</filtro></select></criterio>"
            })
            if (rs.recordcount != 0) {
                if (accion == 3)    {
                    if (nrodoc == rs.getdata('nrodoc') && cuit_cuil == rs.getdata('cuit_cuil')) {
                        alert('Esta asignacion ya existe')
                        return
                    }
                } else {
                    if (nrodoc == rs.getdata('nrodoc') || cuit_cuil == rs.getdata('cuit_cuil')) {
                        alert('Esta asignacion ya existe')
                        return
                    }
                }

            }

            var winClose = nvFW.getMyWindow()
            if (accion == 3) {
                nvFW.error_ajax_request('asignacion_ABM.aspx', {
                    parameters: { accion: accion, codafinidad: codafinidad, tipdoc: tipdoc, razon_social: razonsocial, nrodoc: nrodoc, cuit_cuil: cuit_cuil, codafinidad1: codafinidad1, tipdoc1: tipdoc1, razon_social1: razon_social1, nrodoc1: nrodoc1, cuit_cuil1: cuit_cuil1 },
                    onSuccess: function (err, transport) {
                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                        parent.buscar_asignacion()
                        winClose.close()
                    },
                })

            } else {
                nvFW.error_ajax_request('asignacion_ABM.aspx', {
                    parameters: { accion: 0, codafinidad: codafinidad, tipdoc: tipdoc, razon_social: razonsocial, nrodoc: nrodoc, cuit_cuil: cuit_cuil },
                    onSuccess: function (err, transport) {
                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                        parent.buscar_asignacion()
                        //winClose.close()
                    },
                })
            }
        }


    </script>

</head>
<body onload="return window_onload()" <%--onresize="window_onresize()"--%> style="width: 100%; height: 100%; overflow: auto;">
<table id="tablaCont" style="width:100%" class="tb1">   
    <tr>
        <td style="width:80%">
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center" colspan="2">Razón Social</td>
                    <td style="text-align:center">Cod Afinidad</td>
                </tr>
                <tr>
                    <td colspan="2">
                        <input id="razonsocial" style="width:100%" type="text" />
                    </td>
                    <td>
                        <script>
                            campos_defs.add('codafinidad', {
                                enDB: true,
                                nro_campo_tipo: 1,
                            })

                            /*$("codafinidad").addEventListener("keypress", function (evt) {
                                if (evt.which != 186 || evt.which < 64 || evt.which > 91)
                                {
                                    evt.preventDefault();
                                }
                            });*/
                        </script>
                    </td>
                </tr>
                <tr class="tbLabel">
                    <td style="text-align:center; width:20%">Tipo Documento</td>
                    <td style="text-align:center">Nro Documento</td>
                    <td style="text-align:center">CUIT-CUIL</td>
                </tr>
                <tr>
                    <td>
                        <script>
                            campos_defs.add('tipdoc', {
                                enDB: true,
                                nro_campo_tipo: 1,
                            })
                        </script>
                    </td>
                    <td>
                        <input id="nrodoc" style="width:100%" type="text" maxlength="9"/>
                        <script>
                            $("nrodoc").addEventListener("keypress", function (evt) {
                                if (evt.which != 8 && evt.which != 0 && evt.which < 48 || evt.which > 57)
                                {
                                    evt.preventDefault();
                                }
                            });
                        </script>
                    </td>
                    <td>
                        <input id="nrocuil" style="width:100%" type="text" maxlength="11"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table id=""  style="width:100%" class="tb1">
                <tr>
                    <td style="width:100%; margin:0 auto; align-content:center; padding-left: 100px; padding-right: 100px">
                        
                            <div style="width:49%; margin:auto; float: left; display:inline-block" id="divGuardar"></div>
                            <div style="width:49%; margin:auto; float: right; display:inline-block" id="divCancelar"></div>

                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</body>
</html>
