<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim id_ent_vinc As Integer = nvFW.nvUtiles.obtenerValor("id_ent_vinc", 0)
    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")

    Dim entidad_consultar As String = nvFW.nvUtiles.obtenerValor("entidad_consultar", "/fw/funciones/entidad_consultar.aspx")


    Dim paramXML As String = nvFW.nvUtiles.obtenerValor("paramXML", "")
    If (paramXML <> "") Then
        Dim err As New tError()

        'If (Not op.tienePermiso("permisos_solicitudes", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx")

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("ent_vinculos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, paramXML.Length, paramXML)
        Try
            Dim rs As ADODB.Recordset = cmd.Execute()

            err = New nvFW.tError(rs)

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 105
            err.titulo = "Error en el SP"
            err.mensaje = "Error en el SP ent_vinculos_abm"
        End Try

        err.response()
    End If

    Dim razon_social As String = ""
    Dim razon_social_vinc As String = ""
    Dim nro_entidad_vinc As String = ""
    Dim vinc_desde As String = ""
    Dim vinc_hasta As String = ""
    Dim vinc_alta As String = ""
    Dim nro_vinc_grupo As String = ""
    Dim nro_vinc_tipo As String = ""
    Dim nro_vinc_tipo_rel As String = ""


    If id_ent_vinc > 0 Then
        Dim strSQLIBS As String = "SELECT TOP 1 id_ent_vinc, Razon_social, nro_entidad, razon_social_vinc, nro_entidad_vinc, vinc_desde, vinc_hasta, vinc_alta, operador, nro_vinc_grupo, nro_vinc_tipo, nro_vinc_tipo_rel, id_ent_vinc_rel " +
                "FROM VerEnt_vinculos WHERE id_ent_vinc = " + id_ent_vinc.ToString
        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQLIBS)

        If Not rs.EOF Then
            nro_entidad = rs.Fields("nro_entidad").Value

            razon_social = rs.Fields("Razon_social").Value
            razon_social_vinc = rs.Fields("razon_social_vinc").Value
            nro_entidad_vinc = rs.Fields("nro_entidad_vinc").Value
            If Not IsDBNull(rs.Fields("vinc_desde").Value) Then
                vinc_desde = rs.Fields("vinc_desde").Value
            End If
            If Not IsDBNull(rs.Fields("vinc_hasta").Value) Then
                vinc_hasta = rs.Fields("vinc_hasta").Value
            End If

            vinc_alta = rs.Fields("vinc_alta").Value
            nro_vinc_grupo = rs.Fields("nro_vinc_grupo").Value
            nro_vinc_tipo = rs.Fields("nro_vinc_tipo").Value
            nro_vinc_tipo_rel = rs.Fields("nro_vinc_tipo_rel").Value

        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)

    End If



    Me.contents("id_ent_vinc") = id_ent_vinc
    Me.contents("nro_entidad") = nro_entidad
    Me.contents("nro_entidad_vinc") = nro_entidad_vinc
    Me.contents("razon_social_vinc") = razon_social_vinc
    Me.contents("vinc_desde") = vinc_desde
    Me.contents("vinc_hasta") = vinc_hasta
    Me.contents("vinc_alta") = vinc_alta
    Me.contents("nro_vinc_grupo") = nro_vinc_grupo
    Me.contents("nro_vinc_tipo") = nro_vinc_tipo
    Me.contents("nro_vinc_tipo_rel") = nro_vinc_tipo_rel

    Me.contents("entidad_consultar") = entidad_consultar

    Me.contents("filtroXML_vinc_grupos") = nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_grupos'><campos>nro_vinc_grupo as id, vinc_grupo as campo</campos><orden>vinc_grupo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_vinc_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_tipos'><campos>nro_vinc_tipo as id, vinc_tipo as campo</campos><orden>vinc_tipo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_vinc_tipos_rel") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_vinc_tipo_rel'><campos>nro_vinc_tipo_rel as id, vinc_tipo_rel as campo</campos><orden>vinc_tipo_rel</orden><filtro></filtro></select></criterio>")

    Me.addPermisoGrupo("permisos_vinculos")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Vínculo</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        

        function window_onload()
        {
            if (nvFW.pageContents.nro_entidad_vinc)
                setEntidad_vinc(nvFW.pageContents.razon_social_vinc, nvFW.pageContents.nro_entidad_vinc);
            else
                entidades_abm();

            var win = nvFW.getMyWindow()
            if (!win.options.userData)
                win.options.userData = {}
            win.options.userData.hay_modificacion = false



            window_onresize();
        }


        function window_onresize()
        {
            
        }

        function setEntidad_vinc(razonSocial, nroEntidad) {
            $("entidadVinculo").value = razonSocial + " (" + nroEntidad + ")"
            $('nro_entidad_vinc').value = nroEntidad;
        }

        function entidades_abm() {
            //En la edición del vinculo no se permite cambiar la entidad
            if (nvFW.pageContents.id_ent_vinc > 0)
                return;

            var w = window.parent.nvFW != undefined ? window.parent.nvFW : nvFW;
            win = w.createWindow(
                {
                    url: nvFW.pageContents.entidad_consultar + '?nro_entidad_get=' + $('nro_entidad_vinc').value + '&consulta_default=0',
                    width: 860,
                    height: 420,
                    draggable: true,
                    resizable: true,
                    closable: true,
                    minimizable: false,
                    maximizable: false,
                    destroyOnClose: true,
                    title: "<b>Buscar Entidad</b>",
                    onClose: entidad_abm_return
                });

            win.options.userData = {};
            win.options.userData.entidad = {};
            win.showCenter(true);
        }


        function entidad_abm_return() {
            if (win.options.userData.entidad.nro_entidad) {
                var arr = win.options.userData.entidad;

                if (arr.nro_entidad == nvFW.pageContents.nro_entidad) {
                    alert("No puede crear un vínculo con la misma entidad.")
                    return
                }

                setEntidad_vinc(arr.razon_social, arr.nro_entidad)
            }
            //else
            //    window.close()
        }

        function agregar_tipo_vinculo() {
            win_abm_entidad = window.top.nvFW.createWindow({
                url: '/FW/entidades/vinculos/ent_vinculos_tipos_listar.aspx',
                title: '<b>ABM Tipo Vínculos</b>',
                minimizable: false,
                maximizable: true,
                draggable: true,
                width: 900,
                height: 562,
                resizable: true
            })

            win_abm_entidad.showCenter(true)
        }


        function vinculo_guardar()
        {
            var modo = nvFW.pageContents.id_ent_vinc ? 'M' : 'A'

            var nro_entidad_vinc = $('nro_entidad_vinc').value
            var vinc_desde = campos_defs.get_value("vinc_desde")
            var vinc_hasta = campos_defs.get_value("vinc_hasta")
            var nro_vinc_tipo = campos_defs.get_value("nro_vinc_tipo")
            var nro_vinc_tipo_rel = campos_defs.get_value("nro_vinc_tipo_rel")

            if (!nro_entidad_vinc || nro_entidad_vinc == "0") {
                alert("No ha seleccionado la entidad.")
                return
            }
            if (!nro_vinc_tipo) {
                alert("No ha seleccionado el tipo de vínculo.")
                return
            }
            if (!nro_vinc_tipo_rel) {
                if (nvFW.tienePermiso('permisos_vinculos', 5))
                    confirm("No ha seleccionado el tipo de vínculo inverso.<br>¿Desea editar el tipo de vínculo?", { ok: function (win) { editar_tipo_vinculo(); win.close() } })
                else
                    alert("No ha seleccionado el tipo de vínculo inverso.")
                return
            }

            var pXML = "<ent_vinculo modo='" + modo + "' id_ent_vinc='" + nvFW.pageContents.id_ent_vinc + "' nro_entidad='" + nvFW.pageContents.nro_entidad + "' nro_entidad_vinc='" + nro_entidad_vinc + "' vinc_desde='" + vinc_desde + "' vinc_hasta='" + vinc_hasta + "' nro_vinc_tipo='" + nro_vinc_tipo + "' nro_vinc_tipo_rel='" + nro_vinc_tipo_rel +"' />"

            nvFW.error_ajax_request('ent_vinculos_abm.aspx', {
                parameters: { paramXML: pXML },
                bloq_msg: "Guardar",
                onSuccess: function (err, transport) {

                    if (err.numError == 0) {

                        var win = nvFW.getMyWindow()
                        win.options.userData = { res: 'ok' }
                        win.options.userData.hay_modificacion = true
                        win.close()
                            
                    }

                    window.close()
                },
                error_alert: true
            });

        }

        function editar_tipo_vinculo() {
            var nro_vinc_grupo = campos_defs.get_value("nro_vinc_grupo")
            var nro_vinc_tipo = campos_defs.get_value("nro_vinc_tipo")
            var desc_vinc_tipo = campos_defs.getRS("nro_vinc_tipo").getdata("campo")

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_grupos_vinculos_abm = w.createWindow({
                className: 'alphacube',
                url: '/FW/entidades/vinculos/ent_vinculos_tipos_ABM.aspx?codigoID=' + nro_vinc_tipo + '&descTipo=' + desc_vinc_tipo + '&nroGrupo=' + nro_vinc_grupo + '&modo=E',
                title: '<b>ABM Grupos Vinculos</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                resizable: false,
                modal: true,
                width: 800,
                height: 400,
                onClose: function (win_grupos_vinculos_abm) {
                    //if (win_grupos_vinculos_abm.options.userData.recargar)
                    campos_defs.set_value("nro_vinc_tipo_rel", '')
                    campos_defs.clear("nro_vinc_tipo_rel")
                }
            });
            win_grupos_vinculos_abm.showCenter()
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">

    <div id="divFiltroDatos" style="width: 100%; height: 97%; overflow: hidden;">
        <input type="hidden" name="nro_entidad_vinc" id="nro_entidad_vinc" value="0" />
        <div id="divMenuABM"></div>

        <script type="text/javascript">
            var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
            Menus["vMenuABM"] = vMenuABM;
            Menus["vMenuABM"].alineacion = 'centro';
            Menus["vMenuABM"].estilo = 'A';
            Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>vinculo_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

            if (nvFW.tienePermiso('permisos_vinculos', 2)) {
                Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>ABM Tipos Vínculos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_tipo_vinculo()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenuABM.loadImage("abm", '/FW/image/icons/abm.png');
            }


            Menus["vMenuABM"].loadImage('guardar', '/FW/image/icons/guardar.png')
            Menus["vMenuABM"].loadImage('hoja', '/FW/image/icons/nueva.png')
            vMenuABM.MostrarMenu()
        </script>

        <form onsubmit="return false;" autocomplete="off">
            <table class="tb1">
                <%--<tr>
                    <td class="Tit2">Entidad</td>
                    <td class="Tit4" colspan="3" id="entidad">
                        <% = razon_social & " (" & nro_entidad & ")" %>
                    </td>
                </tr>--%>
                
                <tr>
                    <td class="Tit2" width="10%" nowrap="">Entidad</td>
                    <td colspan="3">
                        <table class="tb1" cellspacing="0" cellpadding="0" style="width: 100%" border="0">
                            <tr>
                                <td style="width: 100%" nowrap>
                                    <input id="entidadVinculo" style="width: 100%" disabled/>
                                </td>
                                <% if id_ent_vinc = 0 Then %>
                                <td>
                                    <img src="/FW/image/icons/buscar.png" border="0" align="absmiddle" hspace="1" onclick="entidades_abm()">
                                </td>
                                <%End If%>
                            </tr>
                        </table>
                    </td> 
                </tr>
                <tr>
                    <td class="Tit2">Desde</td>
                    <td>
                        <script>
                            campos_defs.add("vinc_desde",
                                {
                                    enDB: false,
                                    nro_campo_tipo: 103
                                })
                            campos_defs.set_value("vinc_desde", nvFW.pageContents.vinc_desde)
                        </script>
                    </td>
                    <td class="Tit2">Hasta</td>
                    <td>
                        <script>
                            campos_defs.add("vinc_hasta",
                                {
                                    enDB: false,
                                    nro_campo_tipo: 103
                                })
                            campos_defs.set_value("vinc_hasta", nvFW.pageContents.vinc_hasta)
                        </script>
                    </td>
                </tr>
                <tr>
                    <td class="Tit2">Grupo</td>
                    <td>
                        <script>
                            campos_defs.add("nro_vinc_grupo",
                                {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroXML_vinc_grupos
                                })
                            campos_defs.set_value("nro_vinc_grupo", nvFW.pageContents.nro_vinc_grupo)
                            campos_defs.items["nro_vinc_grupo"]["onchange"] = function (e, campo) {
                                campos_defs.set_value("nro_vinc_tipo_rel", '')
                                campos_defs.clear("nro_vinc_tipo_rel")
                            }
                        </script>
                    </td>
                    <td class="Tit2">Tipo</td>
                    <td>
                        <script>
                            campos_defs.add("nro_vinc_tipo",
                                {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroXML_vinc_tipos,
                                    depende_de: "nro_vinc_grupo"
                                })
                            campos_defs.set_value("nro_vinc_tipo", nvFW.pageContents.nro_vinc_tipo)
                            campos_defs.items["nro_vinc_tipo"]["onchange"] = function (e, campo) {
                                campos_defs.set_value("nro_vinc_tipo_rel", '')
                                campos_defs.clear("nro_vinc_tipo_rel")
                                campos_defs.set_first("nro_vinc_tipo_rel")
                            }
                        </script>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">&nbsp;</td>
                    <td class="Tit2">Inverso</td>
                    <td>
                        <script>
                            campos_defs.add("nro_vinc_tipo_rel",
                                {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroXML_vinc_tipos_rel,
                                    depende_de: "nro_vinc_tipo"
                                })
                            campos_defs.set_value("nro_vinc_tipo_rel", nvFW.pageContents.nro_vinc_tipo_rel)
                        </script>
                    </td>
                </tr>
                
            </table>
        </form>
        

    </div>
</body>
</html>
