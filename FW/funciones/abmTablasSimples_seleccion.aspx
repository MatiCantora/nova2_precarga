<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")      ' VA:'Modo Vista Vacia'  A:'Modo Alta'  M:'Modo Actualización'   

    If (modo <> "") Then

        Dim Err = New tError()

        Try

            Dim strSQL = ""
            Dim nombre_tabla As String = nvFW.nvUtiles.obtenerValor("nombre_tabla", "")
            Dim descripcion As String = nvFW.nvUtiles.obtenerValor("descripcion", "")
            Dim nro_permiso As Integer = nvFW.nvUtiles.obtenerValor("nro_permiso", 0)
            Dim nro_tabla_simple As Integer = nvFW.nvUtiles.obtenerValor("nro_tabla_simple", 0)

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nv_tablas_simples_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)

            cmd.addParameter("@nombre_tabla", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, , nombre_tabla)
            cmd.addParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, , descripcion)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, , modo)
            cmd.addParameter("@nro_permiso", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , nro_permiso)
            cmd.addParameter("@nro_tabla_simple", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , nro_tabla_simple)

            Dim rs As ADODB.Recordset = cmd.Execute()

            nro_tabla_simple = rs.Fields("nro_tabla_simple").Value
            Err.numError = rs.Fields("numError").Value
            Err.titulo = rs.Fields("titulo").Value
            Err.mensaje = rs.Fields("mensaje").Value
            Err.params.Add("nro_tabla_simple", nro_tabla_simple)

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.numError = 104
            Err.titulo = "Error"
            Err.mensaje = "Error en el alta"
        End Try
        Err.response()

    End If

    Me.addPermisoGrupo("permisos_codigos")

    Me.contents("filtro_tabla") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_tablas_simples'><campos>nro_tabla_simple, descripcion, nro_permiso</campos><orden></orden><filtro></filtro></select></criterio>")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM TABLAS SIMPLES</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />


    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "btn_buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_tabla_simple()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png')

        function window_onload() {

            var ventana_actual = window.top.Windows.getFocusedWindow()

            ventana_actual.options.userData = {
                modificacion: false,
                hay_modificacion: false,
                recargar: false
            }

            vListButton.MostrarListButton()


        } // fin de la funcion window_onload  


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var contenedor_cab_h = $('tbcontenedor_cab').getHeight()
                var FiltroDatos_h = $('divFiltroDatos').getHeight()
                $('contenedor').setStyle({ height: body_h - FiltroDatos_h - contenedor_cab_h - dif });

                if ((cantdatos) * 18 > $('contenedor').getHeight()) {
                    $('contenedor').setStyle({ overflowY: 'scroll' });
                } else $('contenedor').setStyle({ overflowY: 'auto' });

                campos_head.resize('tbcontenedor_cab', 'tbcontenedor_detalle');

            }
            catch (e) { }
        }

        function nueva_tabla() {


            strhtml = "<table class='tb1' style='width:395'><tr class='tbLabel'><td style='width:25%; text-align: center' nowrap>Nombre Tabla</td>"
            strhtml += "<td style='width:55%; text-align: center'>Descripcion</td>"
            strhtml += "<td style='width:20%; text-align: center' nowrap>Nro. Permiso</td></tr>"
            strhtml += "<tr><td><input type='text' value='' id='nombre_tabla' style='width:100%;' /></td>"
            strhtml += "<td><input type='text' value='' id='descripcion' style='width:100%;' /></td>"
            strhtml += "<td><input type='text' value='' id='nro_permiso' style='width:100%; text-align: right;' /></td></tr>"
            strhtml += "</table>"
            
            Dialog.confirm(strhtml, {
                width: 400,
                className: "alphacube",
                okLabel: "Guardar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    if (agregar_nueva_tabla() != false) win.close()
                }
            });

        }


        function agregar_nueva_tabla() {

            if (!nvFW.tienePermiso("permisos_codigos", 1)) {
                alert('No posee permisos para agregar tabla')
                return
            }

            var strError = "";

            if ($F('nombre_tabla') == "")
                strError += "<b>Nombre Tabla</b><br>"
            if ($F('descripcion') == "")
                strError += "<b>Descripcion</b><br>"
            if ($F('nro_permiso') == "")
                strError += "<b>Nro. Permiso</b><br>"

            if (strError != "") {
                strError = "Completar campo<br>" + strError;
                nvFW.alert(strError);
                return false;
            } else {

                nvFW.error_ajax_request('abmTablasSimples_seleccion.aspx', {
                    parameters: { modo: 'A', nombre_tabla: $F('nombre_tabla'), descripcion: $F('descripcion'), nro_permiso: $F('nro_permiso') },
                    //onCreate: actualizar_start,
                    onSuccess: function (err, transport) {
                        var nro_tabla_simple = err.params['nro_tabla_simple']
                        var ventana_actual = window.top.Windows.getFocusedWindow()
                        var params = []

                        params['nro_tabla_simple'] = nro_tabla_simple

                        ventana_actual.options.userData = {
                            modificacion: true,
                            hay_modificacion: true,
                            recargar: true
                        }
                        //ventana_actual.returnValue = params
                        //ventana_actual.close()
                        buscar_tabla_simple();
                    },
                    onFailure: function (err) {
                        if (typeof err == 'object') {
                            nvFW.alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                        }
                    },
                    error_alert: false,
                    bloq_msg: "Guardando..."
                });

            }

        }//fin de agregar registro

        var cantdatos;
        function buscar_tabla_simple() {

            var filtro = "";

            if ($('desc').value != "")
                filtro += "<descripcion type='like'>%" + $('desc').value + "%</descripcion>"

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtro_tabla, "", filtro)
            //rs.open(nvFW.pageContents.filtro_registro, "", "", "", parametrosRegistro)

            cantdatos = 0;


            var strhtml = '<table class="tb1 highlightOdd highlightTROver" id="tbcontenedor_detalle">'
            while (!rs.eof()) {
                strhtml += '<tr >'
                strhtml += '<td style="text-align: right">' + rs.getdata("nro_tabla_simple") + '</td>'
                strhtml += '<td >' + rs.getdata("descripcion") + '</td>'
                strhtml += '<td style="text-align:center">' + rs.getdata("nro_permiso") + '</td>'
                strhtml += '<td style="text-align: center;"><img src="/fw/image/icons/editar.png"  onclick="modificar(' + rs.getdata("nro_tabla_simple") + ',\'' + rs.getdata("descripcion") + '\',' + rs.getdata("nro_permiso") + ')"   style="cursor:pointer" /></td>'//&#160;'
                strhtml += '<td style="text-align: center;"><img src="/fw/image/icons/eliminar.png"  onclick="eliminar(' + rs.getdata("nro_tabla_simple") + ')"   style="cursor:pointer" /> </td>'
                strhtml += '</tr>'
                rs.movenext()
                cantdatos++;
            }
            strhtml += '</table>'
            nvFW.bloqueo_desactivar($(document.body), 'guardar')
            $('contenedor').update(strhtml);

            if (cantdatos != 0) {
                $('tbcontenedor_cab').show()
                window_onresize();
            }



        }


        function evaluar(e) {
            var esIE = (document.all); //obtengo el tipo de explorador

            tecla = (esIE) ? event.keyCode : e.which;
            if (tecla == 13) {//si se presiona el enter que busque
                buscar_tabla_simple();
            }
        }


        function modificar(nro_tabla_simple, descripcion, nro_permiso) {
            var strhtml = ""
            //$('modo').value = 'M'

            strhtml += '<table class="tb1" style="width:400" ><tr class="tblabel"><td  style="width:15%; text-align: center">ID</td><td style="width:55%; text-align: center">Descripción</td><td style="width:30%; text-align: center" nowrap>Nro. Permiso</td></tr>'
            strhtml += '<tr><td><input type="text" value="' + nro_tabla_simple + '" id="mod_nro_tabla_simple"  style="width:100%; text-align: right" disabled/></td><td><input type="text" value="' + descripcion + '" id="mod_desc"  style="width:100%"/></td><td><input type="text" value="' + nro_permiso + '" id="mod_permiso"  style="width:100%; text-align: right"/></td></tr>'
            strhtml += '</table>'

            //$('contenedor').update(strhtml)
            nvFW.confirm(strhtml, {
                width: 400,
                className: "alphacube",
                okLabel: "Guardar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    if (actualizar_tabla_simple(nro_tabla_simple) != false) win.close()
                }
            });
        } // fin de la funcion modificar

        function actualizar_tabla_simple(nro_tabla_simple) {

            if (!nvFW.tienePermiso("permisos_codigos", 1)) {
                alert('No posee permisos para agregar tabla')
                return
            }

            var strError = "";

            if ($F('mod_desc') == "")
                strError += "<b>Descripcion</b><br>"
            if ($F('mod_permiso') == "")
                strError += "<b>Nro. Permiso</b><br>"

            if (strError != "") {
                strError = "Completar campo<br>" + strError;
                nvFW.alert(strError);
                return false;
            }


            nvFW.error_ajax_request('abmTablasSimples_seleccion.aspx', {
                parameters: { modo: 'M', descripcion: $F('mod_desc'), nro_permiso: $F('mod_permiso'), nro_tabla_simple: nro_tabla_simple },
                //onCreate: actualizar_start,
                onSuccess: function (err, transport) {

                    var ventana_actual = window.top.Windows.getFocusedWindow()

                    ventana_actual.options.userData = {
                        modificacion: true,
                        hay_modificacion: true,
                        recargar: true
                    }

                    buscar_tabla_simple();

                }, // fin del onsuccess
                onFailure: function (err) {
                    if (typeof err == 'object') {
                        nvFW.alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                    }
                },
            });

        }

        function eliminar(nro_tabla_simple) {

            if (!nvFW.tienePermiso("permisos_codigos", 1)) {
                alert('No posee permisos para agregar tabla')
                return
            }

            nvFW.confirm("¿Desea eliminar realmente este registro?",
                {
                    title: "Eliminar",
                    onOk: function (win) {
                        nvFW.error_ajax_request('abmTablasSimples_seleccion.aspx', {
                            parameters: { modo: "B", nro_tabla_simple: nro_tabla_simple },
                            //onCreate: actualizar_start,
                            onSuccess: function (err, transport) {
                               
                                var ventana_actual = window.top.Windows.getFocusedWindow()

                                ventana_actual.options.userData = {
                                    modificacion: true,
                                    hay_modificacion: true,
                                    recargar: true
                                }

                                buscar_tabla_simple();
                            }, // fin del onsuccess
                            onFailure: function (err) {
                                if (typeof err == 'object') {
                                    nvFW.alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                                }
                            },
                        });


                        win.close()
                    },
                    onCancel: function () {
                        return;
                    }
                }
            );
        } //fin de la funcion eliminar

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
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

            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Seleccione tabla ABM</Desc></MenuItem>")
            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_tabla()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuABMSimples.MostrarMenu()
        </script>

        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: center">Descripción
                </td>
                <td style="width: 10%"></td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="desc" value="" onkeyup="evaluar(event)" style="width: 100%" />
                </td>
                <td>
                    <div id="divbtn_buscar" />
                </td>
            </tr>
        </table>
    </div>
    <table class="tb1" id="tbcontenedor_cab" style="display: none">
        <tr class="tbLabel">
            <td style="width: 7%; text-align: center">ID</td>
            <td style="width: 60%; text-align: center">Descripción</td>
            <td style="width: 19%; text-align: center">Nro. Permiso</td>
            <td style="width: 7%; text-align: center">-</td>
            <td style="width: 7%; text-align: center">-</td>
        </tr>
    </table>
    <div id="contenedor" style="width: 100%; overflow-y: auto">
    </div>
</body>
</html>
