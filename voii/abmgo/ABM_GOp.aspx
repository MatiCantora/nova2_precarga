<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 

    Dim op = nvFW.nvApp.getInstance.operador
    'If Not op.tienePermiso("", 1) Then
    ' Response.Redirect("/FW/error/httpError_401.aspx")
    ' End If

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")


    If accion.ToUpper() = "GUARDAR" Then


        Dim err As New tError()

        Try

            Dim nro_gerencia As String = nvFW.nvUtiles.obtenerValor("nro_gerencia", "")

            Dim nro_tareas As String = nvFW.nvUtiles.obtenerValor("nro_tareas", "")

            nvFW.nvDBUtiles.DBExecute("IF NOT EXISTS (SELECT * FROM Gerencias_Tareas WHERE nro_gerencia = " & nro_gerencia & " AND nro_tarea = " & nro_tareas & ") BEGIN INSERT INTO Gerencias_Tareas  values(" & nro_gerencia & ", " & nro_tareas & ") END ")

        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try

        err.response()

    End If


    If accion.ToUpper() = "BORRAR" Then


        Dim err As New tError()

        Try

            Dim nro_gerencia As String = nvFW.nvUtiles.obtenerValor("nro_gerencia", "")

            Dim nro_tareas As String = nvFW.nvUtiles.obtenerValor("nro_tareas", "")

            nvFW.nvDBUtiles.DBExecute("IF EXISTS (SELECT * FROM Gerencias_Tareas WHERE nro_gerencia = " & nro_gerencia & " AND nro_tarea = " & nro_tareas & ") BEGIN DELETE FROM Gerencias_Tareas  WHERE nro_gerencia = " & nro_gerencia & " and nro_tarea = " & nro_tareas & " END ")

        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try

        err.response()

    End If


    If accion.ToUpper() = "NUEVATAREA" Then


        Dim err As New tError()

        Try

            Dim nro_tarea As String = nvFW.nvUtiles.obtenerValor("nro_tarea", "")
            Dim tarea As String = nvFW.nvUtiles.obtenerValor("tarea", "")

            nvFW.nvDBUtiles.DBExecute("INSERT INTO Tareas(nro_tarea, tarea) values(" & nro_tarea & ",'" & tarea & "')")


        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try

        err.response()

    End If


    If accion.ToUpper() = "NUEVAGERENCIA" Then


        Dim err As New tError()

        Try

            Dim gerencia As String = nvFW.nvUtiles.obtenerValor("gerencia", "")

            nvFW.nvDBUtiles.DBExecute("INSERT INTO Gerencias (gerencia) values('" & gerencia & "' )")


        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try

        err.response()

    End If

    Me.contents("ger_tar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Gerencias_Tareas'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("verGerencias_Tareas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verGerencias_Tareas'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("tareas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verGerencias_Tareas'><campos>nro_tarea</campos><filtro></filtro></select></criterio>")
    Me.contents("tareas1") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='tareas'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Gerencia - Tareas</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="application/javascript">

        var win = nvFW.getMyWindow()
        var cant_tareas = 0
        var mayor_nro_tarea = 0
        function buscar() {
            
            let rs = new tRS();
            
            rs.async = true;

            rs.onComplete = function () {
                var t = 1
                
                
                while (t < mayor_nro_tarea +1) {
                    if (document.getElementById('c' + t) != undefined) {
                        $('c' + t).checked = false
                        
                    }
                    t += 1
                 
                }

                while (!rs.eof()) {
                    if (rs.getdata("nro_tarea")) {
                        $('c' + rs.getdata("nro_tarea")).checked = true
                    }
                    rs.movenext()
                }

            }

            rs.onError = function () {

            }
           
            var filtroWhere = "<criterio><select><filtro><nro_gerencia_dep type='igual'>"+ campos_defs.get_value('nro_gerencia') + "</nro_gerencia_dep></filtro></select></criterio>"
            
            rs.open({ filtroXML:nvFW.pageContents.tareas, filtroWhere: filtroWhere })
        }



        function guardar() {
            if (campos_defs.get_value('nro_gerencia') != "") {
                var t = 1
                while (t != cant_tareas + 1) {
                    if ($('c' + t).checked) {
                        nvFW.error_ajax_request('ABM_GOp.aspx', {
                            parameters: {
                                accion: 'GUARDAR',
                                nro_gerencia: campos_defs.get_value('nro_gerencia'),
                                nro_tareas: t
                            },
                            onSuccess: function () {
                                console.log("paso")

                            },
                            onFailure: function (err, transport) {
                            },
                            bloq_msg: 'Guardando...'
                        });
                    }

                    t += 1
                }
                nvFW.bloqueo_activar($$('body')[0], 'nro_tarea', 'Cargando tareas...');
                var rs = new tRS();

                rs.async = true;

                rs.onComplete = function () {

                    while (!rs.eof()) {
                        if (rs.getdata("nro_tarea") && !$('c' + rs.getdata("nro_tarea")).checked)
                            nvFW.error_ajax_request('ABM_GOp.aspx', {
                                parameters: {
                                    accion: 'BORRAR',
                                    nro_gerencia: campos_defs.get_value('nro_gerencia'),
                                    nro_tareas: rs.getdata("nro_tarea")
                                },
                                onSuccess: function () {
                                    console.log("paso")

                                    nvFW.bloqueo_desactivar(null, 'nro_tarea');

                                },
                                onFailure: function (err, transport) {
                                    nvFW.bloqueo_desactivar(null, 'nro_tarea');
                                },
                                bloq_msg: 'Guardando...'
                            });
                        rs.movenext()
                    }

                    rs.onError = function () {

                    }

                    var params = "<criterio><params gerencia='" + campos_defs.get_value('nro_gerencia') + "' /></criterio>"
                    rs.open(nvFW.pageContents.tareas, "", "", "", params)
                }

            }
        }

        function nueva_tarea() {
            var nombre = ""

            var strHTML = "<br/><table class='tb1'><tr><td nowrap>Nombre de la nueva tarea: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><input type='text' id='nombre' value='" + nombre + "' style='width:100%;text-align:right' /></td></tr></table>"
            nvFW.confirm(strHTML,
                {
                    title: "Nueva Tarea",

                    onShow: function (win) {
                        $("nombre").focus()
                    },
                    onOk: function (win) {
                        nombre = $("nombre").value

                        nvFW.error_ajax_request('ABM_GOp.aspx', {
                            parameters: {
                                accion: 'NUEVATAREA',
                                tarea: nombre,
                                nro_tarea: cant_tareas + 1
                            },
                            onSuccess: function () {
                                cant_tareas += 1
                                cargar_tarea()
                            },
                            onFailure: function (err, transport) {

                            },
                            bloq_msg: 'Guardando...'
                        });

                        win.close()

                    }
                })


        }



        function nueva_gerencia() {
            var nombre = ""

            var strHTML = "<br/><table class='tb1'><tr><td nowrap>Nombre de la nueva gerencia: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><input type='text' id='nombre' value='" + nombre + "' style='width:100%;text-align:right' /></td></tr> </table > "
            nvFW.confirm(strHTML,
                {
                    title: "Nueva Gerencia",

                    onShow: function (win) {
                        $("nombre").focus()
                    },
                    onOk: function (win) {
                        nombre = $("nombre").value

                        nvFW.error_ajax_request('ABM_GOp.aspx', {
                            parameters: {
                                accion: 'NUEVAGERENCIA',
                                gerencia: nombre

                            },
                            onSuccess: function () {

                            },
                            onFailure: function (err, transport) {
                                //**********************
                            },
                            bloq_msg: 'Guardando...'
                        });

                        win.close()

                    }
                })


        }

        function cargar_tarea() {

            $('divTareas').innerHTML = ""

            var rs = new tRS();

            rs.async = true;

            rs.onComplete = function () {

                var strHTML = "<table style='width: 100%' class='highlightOdd'>"
                while (!rs.eof()) {

                    strHTML += "<tr>"
                    strHTML += "<td><input type='checkbox' id='c" + rs.getdata("nro_tarea") + "' />" + rs.getdata("tarea") + "</td>"
                    strHTML += "</tr>"

                     
                    cant_tareas += 1
                    if (parseInt(rs.getdata("nro_tarea")) > parseInt(mayor_nro_tarea))
                        mayor_nro_tarea = parseInt(rs.getdata("nro_tarea"))

                    rs.movenext()

                }
                strHTML += "</table>"

                $('divTareas').insert({ top: strHTML })

            }
            rs.onError = function () {
            }

            rs.onchange = function () { rs.onComplete() }
            rs.open(nvFW.pageContents.tareas1, "", "", "", "")

        }

        function window_onresize() {

        }

        function window_onload() {
            typeof campos_defs.items[document.activeElement.id] != 'undefined'
            cargar_tarea()

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;'>
    <div id="divCabecera" style="width: 100%">

        <table id="tbFiltros" class="tb1" style="width: 100%">
            <tr>
            <td colspan="4">
                <div id="divMenu" style="width: 100%"></div>
            </td>


            <script type="text/javascript">

                var vMenuModulos = new tMenu('divMenu', 'vMenuModulos');

                Menus["vMenuModulos"] = vMenuModulos
                Menus["vMenuModulos"].alineacion = 'center';
                Menus["vMenuModulos"].estilo = 'A';


                Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='width: 5%;'> <Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1' style='width: 85%;'> <Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='2' style='width: 5%;'> <Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevatarea</icono><Desc>Nueva Tarea</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_tarea()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='3' style='width: 5%;'> <Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevatarea</icono><Desc>Nueva Gerencia</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_gerencia()</Codigo></Ejecutar></Acciones></MenuItem>")


                vMenuModulos.loadImage("guardar", "/FW/image/icons/guardar.png");
                vMenuModulos.loadImage("nuevatarea", "/FW/image/icons/nueva.png");

                vMenuModulos.MostrarMenu()

            </script>

            <tr>
                <td class="Tit1" style="text-align: center; width: 5%">Gerencia:</td>

                <td style="width: 90%">
                    <script type="text/javascript">
                        campos_defs.add("nro_gerencia", { enDB: true, nro_campo_tipo: 1, onchange: function () { buscar() } })
                    </script>
                </td>
                <td style="width: 5%">
                    <input type="button" value="Buscar" onclick="buscar()" style="width: 100%">
                </td>

            </tr>
            <tr>
                <td class="Tit1" style="text-align: center; width: 5%">Tareas:</td>
                <td style="width: 100%">
                    <div style="width: 103%" id="divTareas"></div>
                </td>
            </tr>

        </table>
    </div>
</body>
</html>
