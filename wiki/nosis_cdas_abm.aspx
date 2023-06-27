<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim strXML_2 As String = nvFW.nvUtiles.obtenerValor("strXML_2", "")

    Dim err As New tError ' Almacenar variables y mensajes de error

    If strXML <> "" Then
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nosis_cdas_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app, , , , , , , )
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
            Dim rs = cmd.Execute()

            err.parse_rs(rs)
            err.response()
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error en Nosis CDAs ABM"
            err.mensaje = "No se pudo procesar el SP"
        End Try
    Else
        If strXML_2 <> "" Then
            Try
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nosis_cdas_bancos_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app, , , , , , , )
                cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML_2)
                Dim rs = cmd.Execute()

                err.parse_rs(rs)
                err.params("nosis_cda") = rs.Fields("nosis_cda").Value
                err.params("nro_banco") = rs.Fields("nro_banco").Value
                err.response()
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error en Nosis CDAs Bancos ABM"
                err.mensaje = "No se pudo procesar el SP"
            End Try
        End If
    End If

    Me.contents("filtroNosisCdas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNosisCdas'><campos>*</campos><orden>orden</orden></select></criterio>")
    Me.contents("filtroNosisEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nosis_entidades'><campos>*</campos></select></criterio>")
    Me.contents("filtroNosisCdasBancos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNOSISCdasBancos'><campos>*</campos><orden>nro_banco</orden></select></criterio>")
    Me.contents("filtroNroPermisoGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_grupo'><campos>distinct nro_permiso_grupo as id, permiso_grupo as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroNroPermisoDependiente") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_detalle'><campos>distinct nro_permiso as id,  permitir as [campo] </campos><filtro><permitir type='distinto'>'No utilizado'</permitir></filtro><orden>[ID]</orden></select></criterio>")
    Me.contents("filtroConsultarUsoCDA") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vernosis_consulta'><campos>count(*) as contador</campos></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Nosis CDAs ABM</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <%= Me.getHeadInit() %>

    <style type="text/css">
        #nro_cda_banco { font-weight: bold; }
    </style>

    <script type="text/javascript" language="javascript">
        var vMenu,
            win_nosis_entidades,
            options = {},
            cda_seleccionado,
            listaCdas = [],
            listaBancos = [],
            orden_maximo = -9999,
            nro_entidad = null,
            fila_edicion = {},
            ultima_empresa_cargada = -1

        function window_onload() {
            options.userData = {}
            cargar_menu()

            // vaciar los datos al cargar
            nosis_entidades_actualizar(true)

            // setear onchange al campo_def principal
            campos_defs.items["nosis_entidades"].onchange = function () {
                if (campos_defs.get_value("nosis_entidades") != "") {
                    nro_entidad = +campos_defs.get_value("nosis_entidades")
                    
                    // verificar si se cambio de empresa, asi evitamos cargar 2 veces algo que ya está
                    if (ultima_empresa_cargada != nro_entidad) {
                        cargar_tabla_cdas(nro_entidad)
                        ultima_empresa_cargada = nro_entidad
                        lipiar_tabla_cdas_bancos() // necesario para que no queden visibles relaciones de otra empresa
                    }
                }
                else {
                    // limpiar frame lista de nosis_cdas
                    $("tabla_nosis_abm").contentDocument.body.innerHTML = ""
                    nro_entidad = null
                    listaCdas.length = 0
                    nosis_entidades_actualizar(true)
                    lipiar_tabla_cdas_bancos()
                    actualizar_orden_maximo(true)
                    ultima_empresa_cargada = -1
                }
            }
            // Calcular altura para el contenido
            setear_altura_contenido()
        }

        function window_onresize() {
            setear_altura_contenido()
        }

        function cargar_menu() {
            vMenu = new tMenu('divMenuNosis', 'vMenu')
            vMenu.loadImage("editar", "/FW/image/icons/editar.png")

            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro'
            Menus["vMenu"].estilo = 'A'
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>ABM Empresa</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_empresa()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenu.MostrarMenu()
        }

        function cargar_tabla_cdas(nro_entidad) {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroNosisCdas,
                filtroWhere: "<criterio><select><filtro><nro_entidad type='igual'>" + nro_entidad + "</nro_entidad></filtro></select></criterio>",
                path_xsl: "report/nosis_cdas.xsl",
                formTarget: "tabla_nosis_abm",
                cls_contenedor: true,
                bloq_contenedor: $$("BODY")[0],
                mantener_origen: '0',
                nvFW_mantener_origen: true,
                funComplete: function(resp, err) {
                    actualizar_orden_maximo(false)
                    fila_edicion = {} // vaciar la fila de edicion
                    lipiar_tabla_cdas_bancos() // limpiar la lista de bancos relacionados a un CDA
                    cda_seleccionado = null // limpiar el ultimo CDA seleccionado
                }
            })
                    
            // actualizar los valores de nosis entidades (UID y PWD)
            nosis_entidades_actualizar(false)
        }

        function guardar(xml, recargarTabla) {
            if (xml == "")
                return

            recargarTabla = recargarTabla || false

            // Mandar el XML hacia un SP por AJAX
            nvFW.error_ajax_request("nosis_cdas_abm.aspx", {
                parameters: { strXML: xml },
                onSuccess: function (err) {
                    // Refrescar la tabla principal con el nuevo orden si es pedido
                    if (recargarTabla) {
                        cargar_tabla_cdas(nro_entidad)
                        lipiar_tabla_cdas_bancos()
                        fila_edicion = {}
                    }
                },
                error_alert: true,
                bloq_contenedor_on: true,
                onFailure: function(err) {
                    // Refrescar la tabla
                    cargar_tabla_cdas(nro_entidad)
                }
            })
        }

        function abm_empresa() {
            var parametro = campos_defs.get_value("nosis_entidades") != "" ? "?nro_entidad=" + campos_defs.get_value("nosis_entidades") : ""

            win_nosis_entidades = nvFW.createWindow({
                url: "/wiki/nosis_entidades_abm.aspx" + parametro,
                title: "<b>Nosis Empresa ABM</b>",
                minimizable: true,
                maximizable: false,
                width: 550,
                height: 150,
                destroyOnClose: true,
                resizable: false
            })

            win_nosis_entidades.showCenter(true)
        }

        function nosis_entidades_actualizar(vaciar_datos) {
            if (vaciar_datos) {
                options.userData.param_uid = ""
                options.userData.param_pwd = ""
            }
            else {
                var rs = new tRS(),
                    filtroXML = nvFW.pageContents.filtroNosisEntidades,
                    filtroWhere = "<nro_entidad type='igual'>" + campos_defs.get_value("nosis_entidades") + "</nro_entidad>"

                rs.onComplete = function (r) {
                    if (r.lastError.numError == 0) {
                        while (!r.eof()) {
                            options.userData.param_uid = r.getdata("param_uid")
                            options.userData.param_pwd = r.getdata("param_pwd")

                            r.movenext()
                        }
                    }
                }

                rs.onError = function (er) { console.log(er) }
                rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere })
            }
        }

        function setear_altura_contenido() {
            var h_body = $$("BODY")[0].getHeight(),
                h_menu = $("divMenuNosis").getHeight(),
                h_buscador_entidad = $("empresa").getHeight(),
                px_ajuste = 6,
                contenedor = $("contenido")

            contenedor.setStyle({ height: h_body - h_menu - h_buscador_entidad - px_ajuste + "px" })
        }

        function cargar_cdas_bancos(cda, recargar_lista) {
            // vaciar lista para que no se concatenen los bancos de diferentes cdas
            listaBancos.length = 0

            recargar_lista = recargar_lista || false // variable solo para recargar la lista de bancos relacionados, luego de agregar uno

            if ((cda != "undefined" && cda != cda_seleccionado) || recargar_lista) {
                // almaceno el valor del cda elegido en una variable global para no volver a cargarlo si se elige consecutivamente
                cda_seleccionado = cda
                $("cdaNumber").innerText = cda_seleccionado
                $("nosis_cdas_bancos").setStyle({ "display": "table" })

                // Mandar los resultados de una plantilla a un iframe o contenedor
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroNosisCdasBancos,
                    filtroWhere: "<criterio><select><filtro><nosis_cda type='igual'>" + cda_seleccionado + "</nosis_cda></filtro></select></criterio>",
                    path_xsl: "report/nosis_cdas_bancos_listado.xsl",
                    formTarget: "tabla_nosis_cdas_bancos",
                    cls_contenedor: true,
                    bloq_contenedor: $$("BODY")[0],
                    mantener_origen: '0',
                    nvFW_mantener_origen: true
                })
            }
        }

        var winNuevaRel,
            valorBancoNuevo = -1

        function agregar_relacion_cdas_bancos() {
            winNuevaRel = nvFW.createWindow({
                url: "/wiki/nosis_cdas_bancos_agregar.aspx",
                title: '<b>Seleccionar Banco</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 500,
                height: 180,
                onClose: function (win) {
                    if (valorBancoNuevo > -1) {
                        // guardar a la BD
                        var strXML = "<nosis nosis_cda='" + cda_seleccionado + "' nro_banco='" + valorBancoNuevo + "'></nosis>"
                        nvFW.error_ajax_request("/wiki/nosis_cdas_abm.aspx", {
                            parameters: { strXML_2: strXML },
                            onSuccess: function (er) {
                                // recargar lista de bancos relacionados
                                cargar_cdas_bancos(cda_seleccionado, true)
                            },
                            error_alert: true,
                            bloq_contenedor_on: true
                        })
                    }
                },
                destroyOnClose: true
            })
            winNuevaRel.showCenter(true)
        }

        function cdas_bancos_eliminar(nro_banco, desc_banco) {
            nvFW.confirm("¿Está seguro que desea eliminar la relación del banco <b>" + desc_banco + " (" + nro_banco + ")</b> con el CDA <b>" + cda_seleccionado + "</b>?", {
                title: "<b>Eliminar</b>",
                height: 80,
                onOk: function (win) {
                    // XML con informacion de la relación a eliminar
                    var xml = "<nosis nosis_cda='" + (cda_seleccionado * -1) + "' nro_banco='" + nro_banco + "'></nosis>"

                    nvFW.error_ajax_request("/wiki/nosis_cdas_abm.aspx", {
                        parameters: { strXML_2: xml },
                        onSuccess: function (er) {
                            // recargar lista de bancos relacionados
                            cargar_cdas_bancos(cda_seleccionado, true)
                        },
                        error_alert: true,
                        bloq_contenedor_on: true
                    })

                    win.close()
                },
                onCancel: function () { return }
            })
        }

        // Funcion para limpiar la tabla de cdas y bancos relacionados
        function lipiar_tabla_cdas_bancos() {
            $("nosis_cdas_bancos").setStyle({ "display": "none" }) // Ocultar el contenedor
            $("cdaNumber").innerText = "" // Limpiar el numero de CDA del titulo
            $("tabla_nosis_cdas_bancos").contentDocument.body.innerHTML = "" // Limpiar el contenedor del iframe
        }

        var winAgregarEditar

        function agregar_cda() {
            winAgregarEditar = nvFW.createWindow({
                url: "/wiki/nosis_cdas_agregar.aspx",
                title: '<b>Agregar CDA</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 250,
                onClose: function (win) {
                    win.close()
                },
                destroyOnClose: true,
                resizable: false
            })

            winAgregarEditar.showCenter(true)
        }

        function editar_cda(elemento, nosis_cda) {
            var fila = elemento.up("tr")
            cargar_fila_edicion(fila) // necesario para tener datos disponibles al editar en ventana hija

            winAgregarEditar = nvFW.createWindow({
                url: "/wiki/nosis_cdas_agregar.aspx?modificar=true",
                title: '<b>Editar CDA ' + nosis_cda + '</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 250,
                onClose: function (win) {
                    win.close()
                },
                destroyOnClose: true,
                resizable: false
            })

            winAgregarEditar.showCenter(true)
        }

        function eliminar_cda(elemento, nosis_cda) {
            var fila = elemento.up("tr")

            nvFW.confirm("¿Está seguro de eliminar el CDA <b>" + nosis_cda + "</b>?", {
                title: "<b>Eliminar</b>",
                height: 70,
                onOk: function(win) {
                    // antes de eliminar, verificar que no se este utilizando el CDA
                    var rs = new tRS()
                        filtroXML = nvFW.pageContents.filtroConsultarUsoCDA,
                        filtroWhere = "<cda type='igual'>" + nosis_cda + "</cda>",
                        esta_en_uso = false

                    rs.onComplete = function (r) {
                        if (r.lastError.numError == 0) {
                            while (!r.eof()) {
                                esta_en_uso = +r.getdata("contador") > 0 ? true : false
                                r.movenext()
                            }

                            if (esta_en_uso) {
                                alert("El CDA <b>" + nosis_cda + "</b> no se puede eliminar por está siendo utilizado en otros circuitos del sistema", {
                                    title: "<b>No es posible eliminar</b>",
                                    height: 70
                                })
                            }
                            else {
                                // ejecutar la eliminacion
                                var xml = "<nosis nro_entidad='" + campos_defs.get_value("nosis_entidades") + "'>" 
                                    + getXML("cda", "eliminar", fila) 
                                    + "</nosis>"
                        
                                listaCdas.length = 0 // limpiar lista de cdas

                                guardar(xml, true)
                            }

                            win.close()
                        }
                    }

                    rs.onError = function (er) { console.log(er) }
                    rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere })
                },
                onCancel: function(win) {
                    win.close()
                }
            })
        }

        function actualizar_orden_maximo(restablecer_orden) {
            if (restablecer_orden)
                orden_maximo = -9999
            else {
                var contenido = $("tabla_nosis_abm").contentDocument.body.children

                if (contenido["tbNosisCdas"]) {
                    contenido["tbNosisCdas"].select("tr:not(.tbLabel)").forEach(function(item, i) {
                        if (+item.getAttribute("data-orden") > orden_maximo)
                            orden_maximo = +item.getAttribute("data-orden")
                    })
                }
                else
                    orden_maximo = -9999
            }
        }

        function bajar_fila(elemento) {
            var fila = elemento.up("tr"),
                orden_aux,
                fila_siguiente,
                xml = ""
            
            // si es la ultima fila, retornamos el control
            if (!fila.next("tr"))
                return

            orden_aux = fila.getAttribute("data-orden"),
            fila_siguiente = fila.next("tr")
            
            // actualizar orden
            fila.setAttribute("data-orden", fila_siguiente.getAttribute("data-orden"))
            fila_siguiente.setAttribute("data-orden", orden_aux)
            
            // swap de filas
            fila_siguiente.insert({ after : fila })

            // armar XML para salvar cambios
            xml = "<nosis nro_entidad='" + campos_defs.get_value("nosis_entidades") + "'>" 
                + getXML("cda", "modificar", fila) 
                + getXML("cda", "modificar", fila_siguiente)
                + "</nosis>"

            guardar(xml)
        }

        function subir_fila(elemento) {
            var fila = elemento.up("tr"),
                orden_aux,
                fila_previa,
                xml = ""
            
            // si es la primer fila, retornamos el control
            if (!fila.previous("tr:not(.tbLabel)"))
                return

            orden_aux = fila.getAttribute("data-orden"),
            fila_previa = fila.previous("tr:not(.tbLabel)")
            
            // actualizar orden
            fila.setAttribute("data-orden", fila_previa.getAttribute("data-orden"))
            fila_previa.setAttribute("data-orden", orden_aux)

            // swap de filas
            fila_previa.insert({ before : fila })

            // armar XML para salvar cambios
            xml = "<nosis nro_entidad='" + campos_defs.get_value("nosis_entidades") + "'>" 
                + getXML("cda", "modificar", fila) 
                + getXML("cda", "modificar", fila_previa)
                + "</nosis>"

            guardar(xml)
        }

        function getXML(tag, accion, fila) {
            return "<" + tag
                    + " accion='" + accion + "'" 
                    + " nosis_cda='" + fila.getAttribute("data-nosis_cda") + "'" 
                    + " nosis_cda_desc='" + fila.getAttribute("data-nosis_cda_desc") + "'" 
                    + " nro_permiso_grupo='" + fila.getAttribute("data-nro_permiso_grupo") + "'"
                    + " nro_permiso='" + fila.getAttribute("data-nro_permiso") + "'"
                    + " orden='" + fila.getAttribute("data-orden") + "'"
                    + " vigente='" + fila.getAttribute("data-vigente") + "'"
                    + "/>"
        }

        function cargar_fila_edicion(fila) {
            if (typeof fila == "undefined") {
                fila_edicion = {}
                return
            }
            
            fila_edicion.nosis_cda = fila.getAttribute("data-nosis_cda")
            fila_edicion.nosis_cda_desc = fila.getAttribute("data-nosis_cda_desc")
            fila_edicion.nro_permiso_grupo = fila.getAttribute("data-nro_permiso_grupo")
            fila_edicion.nro_permiso = fila.getAttribute("data-nro_permiso")
            fila_edicion.orden = fila.getAttribute("data-orden")
            fila_edicion.vigente = fila.getAttribute("data-vigente")
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="background-color: white">
    <div id="divMenuNosis"></div>
    <div id="empresa">
        <table class="tb1">
            <tr>
                <td class="Tit2" style="width: 20%">Empresa:</td>
                <td><% = nvFW.nvCampo_def.get_html_input("nosis_entidades", nro_campo_tipo:=1, enDB:=True) %></td>
            </tr>
        </table>
    </div>
    <div id="contenido" style="width: 100%; height: 100%; overflow: hidden">
        <iframe id="tabla_nosis_abm" frameborder="0" name="tabla_nosis_abm" style="width: 100%; height: 60%; overflow: hidden"></iframe>

        <%-- Contenedor para ABM nosis_cdas_bancos --%>
        <table class="tb1" id="nosis_cdas_bancos" style="display: none; height: 40%;">
            <tr>
                <td class="Tit2" style="height: 22px;">Bancos relacionados al CDA <span id="cdaNumber" style="font-weight: bold; color: #012672;">123</span></td>
            </tr>
            <tr>
                <td style="vertical-align: top">
                    <iframe id="tabla_nosis_cdas_bancos" name="tabla_nosis_cdas_bancos" frameborder="0" style="width: 100%; height: 100%; overflow: hidden;"></iframe>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>