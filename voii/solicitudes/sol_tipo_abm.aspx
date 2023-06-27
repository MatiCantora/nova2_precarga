<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim op = nvFW.nvApp.getInstance.operador

    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_sol_tipo = nvFW.nvUtiles.obtenerValor("nro_sol_tipo", "")

    If (modo <> "") Then
        Dim err As New tError()

        If (Not op.tienePermiso("permisos_sol_tipos", 2)) Then
            err.numError = 101
            err.titulo = "Error al guardar"
            err.mensaje = "No tiene permisos para realizar esta acción."
            err.debug_src = "sol_tipo_abm.aspx"
            err.response()
        End If

        Try

            Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sol_tipo_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value

        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al guardar"
            err.mensaje = "No se pudo relizar el guardado." & vbCrLf & err.mensaje
            err.debug_src = "sol_tipo_abm.aspx"
        End Try

        err.response()
    End If

    Me.contents("nro_sol_tipo") = nro_sol_tipo
    Me.contents("sol_tiposXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='sol_tipos'><campos>nro_sol_tipo, sol_tipo, nro_circuito</campos><orden></orden><filtro><nro_sol_tipo type='igual'>'" + nro_sol_tipo + "'</nro_sol_tipo></filtro></select></criterio>")

    Me.contents("circuitosXML") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cire_circuito'><campos>nro_circuito as id, circuito as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Tipo de Solicitud</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
     

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var default_accion = ""
        var ventana

        function window_onload()
        {
            ventana = nvFW.getMyWindow()

            if (ventana.options.userData == undefined)
                ventana.options.userData = {}

            ventana.options.userData.hay_modificacion = false

            var id = nvFW.pageContents.nro_sol_tipo
            default_accion = id == "" ? "A" : "M"

            // Si "nro_sol_tipo" esta vacio, no hacer la query
            if (id != "") {

                var rs = new tRS()
                rs.asyc = true
                rs.onComplete = function (rs) {
                    nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload");

                    campos_defs.set_value("nro_sol_tipo", rs.getdata("nro_sol_tipo"))
                    campos_defs.set_value("sol_tipo", rs.getdata("sol_tipo"))
                    campos_defs.set_value("nro_circuito", rs.getdata("nro_circuito"))
                }

                nvFW.bloqueo_activar($$("BODY")[0], "rsOnload");
                rs.open({ filtroXML: nvFW.pageContents.sol_tiposXML });

                campos_defs.habilitar("nro_sol_tipo", false)
            }
            else
                campos_defs.focus("nro_sol_tipo")
            
        }

        function tipo_guardar()
        {
            var nro_sol_tipo = campos_defs.get_value("nro_sol_tipo")
            var sol_tipo = campos_defs.get_value("sol_tipo")
            var nro_circuito = campos_defs.get_value("nro_circuito")

            // Validaciones
            if (nro_sol_tipo == "") {
                alert("No ha ingresado el valor para <b>Tipo</b>")
                return
            }
            if (sol_tipo == "") {
                alert("No ha ingresado el valor para <b>Nombre</b>")
                return
            }
            //if (nro_circuito == "") {
            //    alert("No ha ingresado el valor para <b>Circuito</b>")
            //    return
            //}

            var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>";
            strXML += "<sol_tipo modo='" + default_accion + "' nro_sol_tipo='" + nro_sol_tipo + "' sol_tipo='" + sol_tipo + "' nro_circuito='" + nro_circuito + "'>";
            strXML += "</sol_tipo>";

            nvFW.error_ajax_request('sol_tipo_abm.aspx', {
                parameters: { modo: default_accion, strXML: strXML },
                onSuccess: function (err, transport) {
                    if (err.numError == 0)
                        ventana.options.userData = { res: 'ok', hay_modificacion: true }
                    else
                        alert(err.mensaje)
                    ventana.close()
                },
                error_alert: true
            });

            
        }


    </script>
</head>
<body style="overflow: hidden;" onload="window_onload()">
    <table class="tb1">
        <tr>
            <td colspan="7">
                <div id="DIV_Menu" style="WIDTH: 100%"></div>
            </td>
        </tr>
        <script type="text/javascript">
            var vMenu = new tMenu('DIV_Menu','vMenu');
            vMenu.alineacion = 'centro'
            vMenu.estilo     = 'A'
   
            vMenu.loadImage("guardar", '/FW/image/icons/guardar.png')

            vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + (nvFW.pageContents.nro_sol_tipo == '' ? 'Nuevo' : 'Editar') + " Tipo de Solicitud</Desc></MenuItem>")
            vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tipo_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenu.MostrarMenu();
        </script>
        <tr id="numeroOp">
            <td class="Tit1" style="width: 40px">Tipo:</td>
            <td>
                <script>
                    campos_defs.add('nro_sol_tipo', { enDB: false, nro_campo_tipo: 104 });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 40px">Nombre:</td>
            <td>
                <script>
                    campos_defs.add('sol_tipo', { enDB: false, nro_campo_tipo: 104 });
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 40px">Circuito:</td>
            <td>
                <script>
                    campos_defs.add("nro_circuito", {
                        enDB: false,
                        filtroXML: nvFW.pageContents.circuitosXML,
                        nro_campo_tipo: 2
                    });
                </script>
            </td>
        </tr>
    </table>
</body>
</html>