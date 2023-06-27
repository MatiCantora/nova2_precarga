<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim Rs = DBOpenRecordset("select distinct elemento from nv_codigos_externos")

    Dim strHTML As String = "<select name='elemento' id='elemento' style='width: 100%'><option value=''></option>"

    While Not (Rs.EOF)

        strHTML += "<option value=" + Rs.Fields("elemento").Value + ">" + Rs.Fields("elemento").Value + "</option>"

        Rs.MoveNext()
    End While

    strHTML += "</select>"

    If modo <> "" Then

        Dim Err = New tError()

        Dim elemento = nvFW.nvUtiles.obtenerValor("elemento", "")
        Dim cod_interno = nvFW.nvUtiles.obtenerValor("cod_interno", "")
        Dim sistema_externo = nvFW.nvUtiles.obtenerValor("sistema_externo", "")
        Dim cod_externo = nvFW.nvUtiles.obtenerValor("cod_externo", "")
        Dim desc_externo = nvFW.nvUtiles.obtenerValor("desc_externo", "")

        If modo = "A" Then

            Try

                Dim strSQL As String = "SELECT * FROM nv_codigos_externos WHERE elemento='" + elemento + "' AND cod_interno='" + cod_interno + "' AND sistema_externo='" + sistema_externo + "'"

                Rs = DBOpenRecordset(strSQL)

                If Rs.EOF Then 'si no existe

                    strSQL = "INSERT INTO nv_codigos_externos (elemento,cod_interno,sistema_externo,cod_externo,desc_externo) VALUES ('" + elemento + "','" + cod_interno + "','" + sistema_externo + "','" + cod_externo + "','" + desc_externo + "')"

                    nvFW.nvDBUtiles.DBExecute(strSQL)

                    Err.numError = 0

                Else

                    Err.numError = 104
                    Err.titulo = "Error"
                    Err.mensaje = "Ya existe el registro"

                End If

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.numError = 104
                Err.titulo = "Error"
                Err.mensaje = "Error en el alta"
            End Try

            Err.response()

        End If

        If modo = "M" Then

            Try

                Dim strSQL As String = "UPDATE nv_codigos_externos SET cod_externo='" + cod_externo + "', desc_externo='" + desc_externo + "' WHERE elemento='" + elemento + "' AND cod_interno='" + cod_interno + "' AND sistema_externo='" + sistema_externo + "'"

                nvFW.nvDBUtiles.DBExecute(strSQL)

                Err.numError = 0

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.numError = 104
                Err.titulo = "Error"
                Err.mensaje = "Error al actualizar"
            End Try

            Err.response()

        End If

        If modo = "B" Then

            Try

                Dim strSQL As String = "DELETE FROM nv_codigos_externos WHERE elemento='" + elemento + "' AND cod_interno='" + cod_interno + "' AND sistema_externo='" + sistema_externo + "'"

                nvFW.nvDBUtiles.DBExecute(strSQL)

                Err.numError = 0

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.numError = 104
                Err.titulo = "Error"
                Err.mensaje = "Error al eliminar"
            End Try

            Err.response()

        End If

    End If

    Me.contents("filtroCodigos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

    Me.contents("strHTML") = strHTML
    Me.addPermisoGrupo("permisos_codigos")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM CODIGOS EXTERNOS</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />


    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscarCodigos()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

        function window_onload() {

            nvFW.enterToTab = false;

            vListButton.MostrarListButton();

            cargarhtml();

            window_onresize();

        }

        function window_onresize() {
            $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('divFiltroDatos').getHeight() })
        }

        function cargarhtml() {
            $('tdselect_elemento').innerHTML = nvFW.pageContents.strHTML;
        }

        function buscarCodigos() {

            var filtro = "";

            if (campos_defs.get_value("sistema_externo") != "") {
                filtro += "<sistema_externo type='igual'>'" + campos_defs.get_value("sistema_externo") + "'</sistema_externo>";
            }

            if ($('elemento').value != "") {
                filtro += "<elemento type='igual'>'" + $('elemento').value + "'</elemento>"
            }

            var cantFilas = Math.floor(($("frameDatos").getHeight() - 18) / 22)

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroCodigos,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: "/report/funciones/HTML_codigos_externos.xsl",
                salida_tipo: 'adjunto',
                ContentType: 'text/html',
                formTarget: 'frameDatos',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando codigos externos...',
                cls_contenedor: 'frameDatos'

            });

        }

        function key_Buscar() {
            if (window.event.keyCode == 13)
                buscarCodigos();
        }


        function nuevo_registro() {

            var strhtml = ""

            strhtml = "<table class='tb1' style='width:100%'><tr class='tbLabel'><td style='width:30%; text-align: center' nowrap>Elemento</td><td style='width:20%; text-align: center' nowrap>Cod. Interno</td>";
            strhtml += "<td style='width:30%; text-align: center' nowrap>Sistema</td><td style='width:20%; text-align: center' nowrap>cod. externo</td></tr>"

            strhtml += "<tr><td style='width:15%'><input type='text' value='' id='input_elemento' style='width:100%' /></td>"
            strhtml += "<td style='width:15%'><input type='text' value='' id='input_cod_interno' style='width:100%' /></td>"
            strhtml += "<td style='width:15%'><input type='text' value='' id='input_sistema' style='width:100%' /></td>"
            strhtml += "<td style='width:15%'><input type='text' value='' id='input_cod_externo' style='width:100%' /></td></tr>"


            strhtml += "<tr class='tbLabel'><td style='width:100%; text-align: center' nowrap colspan=4>Descripción Externa</td></tr>"
            strhtml += "<td style='width:100%' colspan=4><input type='text' value='' id='input_descripcion' style='width:100%' /></td>"
            strhtml += "</tr></table>"

            //$('contenedor').update(strhtml)

            Dialog.confirm(strhtml, {
                width: 600,
                height: 160,
                className: "alphacube",
                okLabel: "Guardar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    if (agregar_nuevo_registro() != false) win.close()
                }
            });

        } //fin de la funcion nuevo registro

        function agregar_nuevo_registro() {

            if (!nvFW.tienePermiso("permisos_codigos", 3)) {
                alert('No posee permisos para agregar registro')
                return
            }


            var input_elemento = $('input_elemento').value;
            var input_cod_interno = $('input_cod_interno').value;
            var input_sistema = $('input_sistema').value;
            var input_cod_externo = $('input_cod_externo').value;
            var input_descripcion = $('input_descripcion').value;

            var strError = '';

            if (input_elemento == "") {
                strError += ' No ha ingresado <b>elemento</b></br>'
            }

            if (input_cod_interno == "") {
                strError += ' No ha ingresado <b>Cod. Interno</b></br>'
            }

            if (input_sistema == "") {
                strError += ' No ha ingresado <b>Sistema Externo</b></br>'
            }

            if (strError != "") {
                alert(strError)
                return
            }

            nvFW.error_ajax_request('abmcodigos_externos.aspx', {
                parameters: { modo: 'A', elemento: input_elemento, cod_interno: input_cod_interno, sistema_externo: input_sistema, cod_externo: input_cod_externo, desc_externo: input_descripcion },
                onCreate: actualizar_start,
                onSuccess: function (err, transport) {
                    //actualizar_return(err, transport)
                    if (err.numError == 0) {
                        nvFW.bloqueo_desactivar($$("body")[0], 'guardar')
                        buscarCodigos();
                        return true
                    }
                    else {
                        nvFW.bloqueo_desactivar($$("body")[0], 'guardar')
                        nvFW.alert(err.numError + ' - ' + err.mensaje)
                        return false
                    }
                } // fin del onsuccess
            });

        }//fin de agregar registro

        function editar_registro(elemento, cod_interno, sistema_externo) {

            var strhtml = "";

            var filtro = "<criterio><select><filtro><elemento type='igual'>'" + elemento + "'</elemento><cod_interno>'" + cod_interno + "'</cod_interno><sistema_externo>'" + sistema_externo + "'</sistema_externo></filtro></select></criterio>";

            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroCodigos, "", filtro)

            strhtml = "<table class='tb1' style='width:100%'><tr class='tbLabel'><td style='width:30%; text-align: center' nowrap>Elemento</td><td style='width:20%; text-align: center' nowrap>Cod. Interno</td>";
            strhtml += "<td style='width:30%; text-align: center' nowrap>Sistema</td><td style='width:20%; text-align: center' nowrap>cod. externo</td></tr>"

            strhtml += "<tr><td style='width:15%'><input type='text' value='" + elemento + "' id='input_elemento' style='width:100%' disabled /></td>"
            strhtml += "<td style='width:15%'><input type='text' value='" + cod_interno + "' id='input_cod_interno' style='width:100%' disabled /></td>"
            strhtml += "<td style='width:15%'><input type='text' value='" + sistema_externo + "' id='input_sistema' style='width:100%' disabled /></td>"
            strhtml += "<td style='width:15%'><input type='text' value='" + rs.getdata("cod_externo") + "' id='input_cod_externo' style='width:100%' /></td></tr>"


            strhtml += "<tr class='tbLabel'><td style='width:100%; text-align: center' nowrap colspan=4>Descripción Externa</td></tr>"
            strhtml += "<td style='width:100%' colspan=4><input type='text' value='" + rs.getdata("desc_externo") + "' id='input_descripcion' style='width:100%' /></td>"
            strhtml += "</tr></table>"

            //$('contenedor').update(strhtml)

            Dialog.confirm(strhtml, {
                width: 600,
                height: 160,
                className: "alphacube",
                okLabel: "Guardar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    if (actualizar_registro(elemento, cod_interno, sistema_externo) != false) win.close()
                }
            });

        } //fin de la funcion nuevo registro

        function actualizar_registro(elemento, cod_interno, sistema_externo) {

            var input_elemento = $('input_elemento').value;
            var input_cod_interno = $('input_cod_interno').value;
            var input_sistema = $('input_sistema').value;
            var input_cod_externo = $('input_cod_externo').value;
            var input_descripcion = $('input_descripcion').value;

            //if (nueva_desc == "") {
            //    alert("No ha ingresado una descripcion ")
            //    return false
            //}

            if (!nvFW.tienePermiso("permisos_codigos", 3)) {
                alert('No posee permisos para modificar registro')
                return
            }

            nvFW.error_ajax_request('abmcodigos_externos.aspx', {
                parameters: { modo: 'M', elemento: input_elemento, cod_interno: input_cod_interno, sistema_externo: input_sistema, cod_externo: input_cod_externo, desc_externo: input_descripcion },
                onCreate: actualizar_start,
                onSuccess: function (err, transport) {
                    //actualizar_return(err, transport)                    
                    if (err.numError == 0) {
                        nvFW.bloqueo_desactivar($$("body")[0], 'guardar')
                        buscarCodigos();
                        return true
                    }
                    else {
                        nvFW.bloqueo_desactivar($$("body")[0], 'guardar')
                        nvFW.alert(err.numError + ' - ' + err.mensaje)
                        return false
                    }
                } // fin del onsuccess
            });

        }       


        function eliminar_registro(elemento, cod_interno, sistema_externo) {

            if (!nvFW.tienePermiso("permisos_codigos", 3)) {
                alert('No posee permisos para eliminar registro')
                return
            }

            nvFW.confirm("¿Desea eliminar realmente este registro?",
                {
                    title: "Eliminar",
                    onOk: function (win) {
                        nvFW.error_ajax_request('abmcodigos_externos.aspx', {
                            parameters: { modo: 'B', elemento: elemento, cod_interno: cod_interno, sistema_externo: sistema_externo },
                            onCreate: actualizar_start,
                            onSuccess: function (err, transport) {
                                //actualizar_return(err, transport)
                                if (err.numError == 0) {
                                    nvFW.bloqueo_desactivar($$("body")[0], 'guardar')
                                    buscarCodigos();
                                    return true
                                }
                                else {
                                    nvFW.bloqueo_desactivar($$("body")[0], 'guardar')
                                    nvFW.alert(err.numError + ' - ' + err.mensaje)
                                    return false
                                }
                            } // fin del onsuccess
                        });


                        win.close()
                    },
                    onCancel: function () {
                        return;
                    }
                }
            );
        } //fin de la funcion eliminar

        function actualizar_start() {

            nvFW.bloqueo_activar($$("body")[0], 'guardar')
        } //fin del actualizar

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden" onkeypress="return key_Buscar()">
    <div id="divFiltroDatos">
        <div id="divMenuABMSimples">
        </div>

        <script type="text/javascript" language="javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuABMSimples = new tMenu('divMenuABMSimples', 'vMenuABMSimples');
            Menus["vMenuABMSimples"] = vMenuABMSimples
            Menus["vMenuABMSimples"].alineacion = 'centro';
            Menus["vMenuABMSimples"].estilo = 'A';
            //Menus["vMenuABMSimples"].imagenes = Imagenes //Imagenes se declara en pvUtiles
            vMenuABMSimples.loadImage("hoja", "/FW/image/icons/nueva.png");
            vMenuABMSimples.loadImage("abm", "/FW/image/icons/abm.png");

            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_registro()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuABMSimples.MostrarMenu()
        </script>

        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: center">Elemento</td>
                <td style="text-align: center">Sistema</td>
            </tr>
            <tr>
                <td id="tdselect_elemento" style='text-align: Left'></td>
                <td>
                    <script>
                        campos_defs.add("sistema_externo", {
                            nro_campo_tipo: 104,
                            enDB: false,
                        });
                    </script>
                </td>
                <td>
                    <div id="divBuscar" />
                </td>
            </tr>
        </table>
    </div>
    <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>
</body>
</html>
