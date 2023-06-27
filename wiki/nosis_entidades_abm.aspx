<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nro_entidad As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad", -1)
    Me.contents("nro_entidad") = nro_entidad

    ' Captura de variables para la DB
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If strXML <> "" Then
        Dim err As New tError
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nosis_entidades_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app, , , , , , , )
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
            Dim rs = cmd.Execute()

            err.parse_rs(rs)
            err.response()
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error en Nosis Entidades ABM"
            err.mensaje = "No se pudo ejecutar el SP"
        End Try
    End If
    
    Me.contents("filtroEntidadEnUso") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vernosis_consulta'><campos>count(*) as contador</campos></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Nosis Entidades ABM</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <%= Me.getHeadInit() %>

        <script type="text/javascript" language="javascript">
            var nro_entidad = nvFW.pageContents.nro_entidad,
                data = parent.options.userData,
                data_actual = {},
                hay_cambios = false,
                modificar = nro_entidad != -1 ? true : false
            
            function window_onload() {
                cargar_menu()
                modificar ? setear_campos_defs(data) : setear_campos_defs_onchange()
            }

            function cargar_menu() {
                vMenu = new tMenu('divMenuEntidades', 'vMenu');
                vMenu.loadImage("guardar", "/FW/image/icons/guardar.png");
                vMenu.loadImage("eliminar", "/FW/image/icons/eliminar.png");
                Menus["vMenu"] = vMenu
                Menus["vMenu"].alineacion = 'centro';
                Menus["vMenu"].estilo = 'A';

                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 60%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenu.MostrarMenu();
            }

            function guardar(borrar) {
                borrar = borrar || false

                // ALTA
                if (!modificar) {
                    if (+campos_defs.get_value("nro_entidades") == 0) {
                        alert("Debe seleccionar una empresa (entidad) antes de guardar", { title: "<b>Seleccione una empresa</b>", height: 80 })
                        return false
                    }
                    
                    // verificar UID y PWD solo si NO estamos borrando
                    if (!borrar) {
                        if (campos_defs.get_value("param_uid") == "") {
                            alert("Debe seleccionar el parámetro de UID", { title: "<b>Seleccione el UID</b>", height: 80 })
                            return false
                        }

                        if (campos_defs.get_value("param_pwd") == "") {
                            alert("Debe seleccionar el parámetro de PWD", { title: "<b>Seleccione el PWD</b>", height: 80 })
                            return false
                        }
                    }

                    // si paso las validaciones anteriores y estoy agregando, actualizar el valor de nro_entidad
                    nro_entidad = +campos_defs.get_value("nro_entidades")
                    hay_cambios = true
                }

                // Actualizar los valores solo si no estoy borrando
                if (!borrar) {
                    if (data_actual.param_uid != null && data_actual.param_uid != data.param_uid) {
                        parent.options.userData.param_uid = data_actual.param_uid
                        hay_cambios = true
                    }

                    if (data_actual.param_pwd != null && data_actual.param_pwd != data.param_pwd) {
                        parent.options.userData.param_pwd = data_actual.param_pwd
                        hay_cambios = true
                    }
                }
                else {
                    // BAJA => hay cambios que salvar => borrar
                    hay_cambios = true
                }

                if (hay_cambios) {
                    // guardar en la DB
                    nvFW.error_ajax_request("/wiki/nosis_entidades_abm.aspx", {
                        parameters: {strXML: obtenerXML(borrar)},
                        onSuccess: function (err) {
                            parent.campos_defs.items["nosis_entidades"].input_select.length = 0 // solo para actualizar los items del selector
                            
                            // BAJA => limpiar el campo_defs de la ventana padre
                            if (borrar) {
                                parent.campos_defs.clear("nosis_entidades") // limpiar la ultima opcion elegida
                                parent.$("tabla_nosis_abm").contentDocument.body.innerHTML = ""
                                parent.nro_entidad = null
                                parent.listaCdas.length = 0
                                parent.nosis_entidades_actualizar(true)
                                parent.lipiar_tabla_cdas_bancos()
                                parent.actualizar_orden_maximo(true)
                                parent.ultima_empresa_cargada = -1
                            }

                            // cerrar la ventana
                            parent.win_nosis_entidades.close()
                        },
                        error_alert: true,
                        bloq_contenedor_on: true
                    })
                }
                else
                    parent.win_nosis_entidades.close()
            }

            function eliminar() {
                if (nro_entidad == -1 || !modificar)
                    return

                nvFW.confirm("¿Está seguro de querer eliminar la empresa (entidad) <b>" + nro_entidad + "</b>?", {
                    title: "<b>Eliminar</b>",
                    height: 80,
                    onCancel: function() {
                        return false
                    },
                    onOk: function() {
                        // antes de la eliminacion, comprobar que esta entidad no esté en uso por algún circuito operativo
                        var rs = new tRS(),
                            filtroXML = nvFW.pageContents.filtroEntidadEnUso,
                            filtroWhere = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>",
                            empresa_esta_en_uso = false

                        rs.onComplete = function(resultado) {
                            if (resultado.lastError.numError == 0) {
                                while (!resultado.eof()) {
                                    // verificar si la empresa a eliminar esta en uso
                                    empresa_esta_en_uso = +resultado.getdata("contador") > 0 ? true : false
                                    resultado.movenext()
                                }

                                // eliminar solo si la empresa NO esta en uso
                                if (empresa_esta_en_uso) {
                                    // No eliminar
                                    alert("No es posible eliminar la empresa porque está en uso en alguno de los circuitos operativos", { title: "Imposible eliminar", height: 80 })
                                    parent.win_nosis_entidades.close()
                                }
                                else {
                                    // Eliminar
                                    guardar(true) // el 'true' indica eliminacion
                                }
                            }
                        }

                        rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere })
                    }
                })
            }

            function setear_campos_defs() {
                campos_defs.set_value("param_uid", data.param_uid)
                campos_defs.set_value("param_pwd", data.param_pwd)

                // setar evento onChange para los campos defs()
                setear_campos_defs_onchange()
            }

            function setear_campos_defs_onchange() {
                if (!modificar) {
                    // este campo def esta disponible solo si esta en modo de ALTA
                    campos_defs.items["nro_entidades"].onchange = function() {
                        nro_entidad = campos_defs.get_value("nro_entidades") != "" ? +campos_defs.get_value("nro_entidades") : -1
                    }
                }

                campos_defs.items["param_uid"].onchange = function() {
                    data_actual.param_uid = campos_defs.get_value("param_uid") != "" ? campos_defs.get_value("param_uid") : ""
                }

                campos_defs.items["param_pwd"].onchange = function() {
                    data_actual.param_pwd = campos_defs.get_value("param_pwd") != "" ? campos_defs.get_value("param_pwd") : ""
                }
            }

            function obtenerXML(eliminar) {
                return xml = "<nosis nro_entidad='" + (eliminar ? nro_entidad * -1 : nro_entidad) + "'" 
                            + " param_uid='" + campos_defs.get_value("param_uid") + "'" 
                            + " param_pwd='" + campos_defs.get_value("param_pwd") + "'></nosis>"
            }
        </script>
    </head>
    <body onload="window_onload()" style="background-color: white;">
        <div id="divMenuEntidades"></div>
        <table class="tb1">
            <tr>
                <td class="Tit2">Nro Empresa:</td>
                <td>
                    <%
                        If nro_entidad = -1 Then
                            ' ALTA => inserto el campo_def
                            Response.Write(nvFW.nvCampo_def.get_html_input("nro_entidades", nro_campo_tipo:=3, enDB:=True))
                        Else
                            ' MODIFICACION => muestro un input deshabilitado
                            Response.Write("<input disabled='disabled' id='nro_entidad_tag' style='width: 100%; text-align:right;' type='text' value='" & nro_entidad & "' />")
                        End If
                    %>

                </td>
            </tr>
            <tr>
                <td class="Tit2">Parámetro UID:</td>
                <td><%= nvFW.nvCampo_def.get_html_input("param_uid", nro_campo_tipo:=3, enDB:=False, filtroXML:="<criterio><select vista='verParametros'><campos>id_param as id, param as [campo]</campos><orden>[campo]</orden></select></criterio>") %></td>
            </tr>
            <tr>
                <td class="Tit2">Parámetro PWD:</td>
                <td><%= nvFW.nvCampo_def.get_html_input("param_pwd", nro_campo_tipo:=3, enDB:=False, filtroXML:="<criterio><select vista='verParametros'><campos>id_param as id, param as [campo]</campos><orden>[campo]</orden></select></criterio>") %></td>
            </tr>
        </table>
    </body>
</html>