<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Response.Expires = 0
    Dim modo As String = obtenerValor("modo", "")      ' VA:'Modo Vista Vacia'  A:'Modo Alta'  M:'Modo Actualización'
    Dim codigoID As String = nvFW.nvUtiles.obtenerValor("codigoID", "")


    If (modo <> "") Then


        If modo <> "B" Then 'ABM

            Dim err = New tError()

            Try

                Dim strXML As String = nvFW.nvUtiles.obtenerValor("strxml", "")

                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nv_codigos_simples_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)

                cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

                Dim rs As ADODB.Recordset = cmd.Execute()

                err.titulo = "Error"
                err.numError = rs.Fields("numError").Value
                err.mensaje = rs.Fields("mensaje").Value

            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = 104
                err.titulo = "Error"
                err.mensaje = "Error en el alta"
            End Try
            err.response()

        End If 'fin de la alta


        If (modo.ToUpper() = "B") Then 'BUSQUEDA
            Dim err = New tError()
            Try

                Dim strSQL = ""
                Dim nro_tabla_simple = obtenerValor("nro_tabla_simple", "")
                Dim descripcion = obtenerValor("descripcion", "")
                Dim columna1 = ""
                Dim columna2 = ""
                Dim tabla = ""

                Dim Rs = DBOpenRecordset("SELECT Column_Name, TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS where Table_Name = (select nombre_tabla from nv_tablas_simples where nro_tabla_simple = " + nro_tabla_simple + ") ")

                If Not (Rs.EOF) Then
                    columna1 = Rs.Fields("Column_name").Value       'recupero la primera ocurrencia de la consulta que se corresponde con      
                    ' el nombre de la primera columna (por lo general) que contiene el ID de la tabla 
                    Rs.MoveNext()
                    columna2 = Rs.Fields("Column_name").Value       'recupero la segunda ocurrencia de la consulta que se corresponde con      
                    ' el nombre de la segunda columna (por lo general) que contiene la descripcion de la tabla 
                    tabla = Rs.Fields("TABLE_NAME").Value
                    Dim filas = Rs.RecordCount
                    DBCloseRecordset(Rs)

                    If descripcion <> "" Then
                        strSQL = "SELECT " + columna1 + ", " + columna2 + " from " + tabla + " where " + columna2 + " like '%" + descripcion + "%'"
                    Else
                        strSQL = "SELECT " + columna1 + ", " + columna2 + " from " + tabla
                    End If

                    Rs = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)

                    Dim cantdatos = 0
                    Dim strhtml As String = ""
                    While Not Rs.EOF

                        Dim datoColumna1 = IIf(TypeOf Rs.Fields(columna1).Value Is String, Rs.Fields(columna1).Value, Rs.Fields(columna1).Value.ToString())

                        strhtml += "<tr>"
                        strhtml += "<td style='text-align: right'>" + datoColumna1 + "</td>"
                        strhtml += "<td>" + Rs.Fields(columna2).Value + "</td>"
                        strhtml += "<td style='text-align: center;'><img src='/fw/image/icons/editar.png'  onclick='modificar(""" + datoColumna1 + """,""" + Rs.Fields(columna2).Value + """)' style='cursor:pointer' /></td>"
                        strhtml += "<td style='text-align: center;'><img src='/fw/image/icons/eliminar.png'  onclick='eliminar(""" + datoColumna1 + """)' style='cursor:pointer' /></td>"
                        strhtml += "</tr>"
                        Rs.MoveNext()
                        cantdatos += 1

                    End While

                    err.numError = 0
                    err.mensaje = tabla
                    err.params.Add("strhtml", strhtml)
                    err.params.Add("cantdatos", cantdatos)

                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = 104
                err.titulo = "Error"
                err.mensaje = "Error en la busqueda"
            End Try

            err.response()


        End If 'fin del modo BUSQUEDA

    Else
        modo = "VA"
    End If


    Me.contents("filtro_tablasSimples") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNV_tablas_simples'><campos>nro_inc_actual, descripcion, nro_permiso</campos><filtro><nro_tabla_simple type='igual'>'%tabla%'</nro_tabla_simple></filtro><orden></orden></select></criterio>")

    Me.contents("codigoID") = codigoID
    Me.addPermisoGrupo("permisos_codigos")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM CODIGOS SIMPLES</title>
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
        vButtonItems[0]["onclick"] = "return registro_buscar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png')

        var win

        var codigoID = nvFW.pageContents.codigoID;

        function nuevo_registro() {

            var strhtml = ""

            if (campos_defs.get_value('nro_tabla_simple') == "") {
                nvFW.alert("Debe seleccionar una tabla")
                return
            }

            var desc_tb = ""

            var rs = new tRS();

            var parametroFiltro = "<criterio><params tabla='" + campos_defs.get_value('nro_tabla_simple') + "' /></criterio>";

            rs.open(nvFW.pageContents.filtro_tablasSimples, "", "", "", parametroFiltro);

            var nro_inc_actual = rs.getdata('nro_inc_actual');

            desc_tb = rs.getdata('descripcion')


            strhtml = "<table class='tb1' style='width:390'><tr class='tbLabel'><td style='width:15%; text-align: center'>ID</td><td style='width:85%; text-align: center'>Ingrese " + desc_tb + "</td></tr>"
            if (nro_inc_actual > 0) //si ID autoincremental, campo desabilitado
                strhtml += "<tr><td style='width:15%'><input type='text' value='' id='id_registro' style='width:100%' disabled /></td>"
            else strhtml += "<tr><td style='width:15%'><input type='text' value='' id='id_registro' style='width:100%' /></td>"

            strhtml += "<td><input type='text' value='' id='id_desc' style='width:100%;' /></td></tr>"
            strhtml += "</table>"

            //$('contenedor').update(strhtml)

            Dialog.confirm(strhtml, {
                width: 400,
                className: "alphacube",
                okLabel: "Guardar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    if (agregar_nuevo_registro(nro_inc_actual, rs.getdata('nro_permiso')) != false) win.close()
                }
            });

        } //fin de la funcion nuevo registro

        function abm_codigosExternos() {

            if (!nvFW.tienePermiso("permisos_codigos", 3)) {
                alert('No posee permisos para agregar codigos externos')
                return
            }

            var win = window.top.nvFW.createWindow({
                url: "/FW/funciones/abmcodigos_externos.aspx", width: "800", height: "400", top: "50",
                title: "<b>ABM Códigos Externos</b>",
                maximizable: true,
                resizable: true
                //onClose: function (win) {
                //    if (win.options.userData.hay_modificacion) {
                //        //actualizar campo def                        

                //    }

                //}
            })

            win.showCenter()

        }

        function agregar_tabla() {

            if (!nvFW.tienePermiso("permisos_codigos", 1)) {
                alert('No posee permisos para agregar tabla')
                return
            }

            var win = window.top.nvFW.createWindow({
                url: "/FW/funciones/abmTablasSimples_seleccion.aspx", width: "800", height: "400", top: "50",
                title: "<b>ABM Tablas Simples</b>",
                maximizable: true,
                resizable: true,
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) {
                        //actualizar campo def
                        campos_defs.clear_list("nro_tabla_simple")

                    }

                }
            })

            win.showCenter(true)

        } //fin de la funcion nueva tabla


        function agregar_nuevo_registro(nro_inc_actual, nro_permiso) {

            if (!nvFW.tienePermiso("permisos_codigos", nro_permiso)) {
                alert('No posee permisos para agregar registro')
                return
            }

            var tabla = campos_defs.get_value('nro_tabla_simple')
            var id_registro = $F('id_registro')
            var desc = $F('id_desc')
            var strxml = ''

            if (tabla == "") {
                strError += ' No ha seleccionado una tabla de registro</br>'
            }


            //VERIFICA SI EL ID ES AUTO INCREMENTAL
            if (nro_inc_actual > 0) //si nro_inc_actual es mayor a cero, la tabla tiene id autoincremental sino requiere el ingreso de id para este campo
            {
                if (id_registro != '') {
                    nvFW.alert('El campo de la clave primaria de la tabla ' + tabla + ' no requiere ID ya que es autoincremental')
                    return
                }

                id_registro = -1;

            } else {

                if (id_registro == '') {
                    nvFW.alert('El campo de la clave primaria de la tabla ' + tabla + ' requiere un ID , por favor ingrese este dato.')
                    return
                }
            }

            var strxml = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            strxml += "<abm_registro nro_tabla_simple='" + campos_defs.get_value('nro_tabla_simple') + "' id_registro='" + id_registro + "' descripcion='" + desc + "' nro_permiso='" + nro_permiso + "' modo='A' ></abm_registro>";

            nvFW.error_ajax_request('abmcodigos_seleccion.aspx', {
                parameters: { modo: 'A', strxml: strxml },
                onCreate: actualizar_start,
                onSuccess: function (err, transport) {
                    actualizar_return(err, transport)
                } // fin del onsuccess
            });

        }//fin de agregar registro


        function eliminar(id_registro) {
            var modo = 'E'

            var rs = new tRS();

            var parametroFiltro = "<criterio><params tabla='" + campos_defs.get_value('nro_tabla_simple') + "' /></criterio>";

            rs.open(nvFW.pageContents.filtro_tablasSimples, "", "", "", parametroFiltro);

            var strxml = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            strxml += "<abm_registro nro_tabla_simple='" + campos_defs.get_value('nro_tabla_simple') + "' id_registro='" + id_registro + "' descripcion='' nro_permiso='" + rs.getdata('nro_permiso') + "' modo='E' ></abm_registro>";

            if (!nvFW.tienePermiso("permisos_codigos", rs.getdata('nro_permiso'))) {
                alert('No posee permisos para eliminar registro')
                return
            }

            nvFW.confirm("¿Desea eliminar realmente este registro?",
                {
                    title: "Eliminar",
                    onOk: function (win) {
                        nvFW.error_ajax_request('abmcodigos_seleccion.aspx', {
                            parameters: { modo: modo, strxml: strxml },
                            onCreate: actualizar_start,
                            onSuccess: function (err, transport) {
                                actualizar_return(err, transport)
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

            nvFW.bloqueo_activar($(document.body), 'guardar')
        } //fin del actualizar

        function actualizar_return(err, transport) {


            var numError = err.numError
            var respuesta = err.mensaje
            var desc = err.params['desc']

            if (numError == 0) {
                window.setTimeout("nvFW.bloqueo_desactivar($(document.body), 'guardar')", 1000)
                registro_buscar(respuesta, desc)//cargo el contenedor con el listado d los Simples
            }
            else {
                nvFW.bloqueo_desactivar($(document.body), 'guardar')
                nvFW.alert(numError + ' - ' + respuesta)
            }

        } //fin de la funcion actualziar_return


        //inicializar ventana

        function window_onload() {

            vListButton.MostrarListButton()

            if (codigoID != "") {
                campos_defs.set_value('nro_tabla_simple', codigoID);
                $('nro_tabla_simple').disabled = true;
            }

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
                //
                //    $('contenedor').setStyle({ height: (cantdatos + 1) * 18 });
                //parent.win.setSize($$('body')[0].getWidth(), body_h)
            }
            catch (e) { }
        }



        function Cerrar_Ventanas() {

            window.top.Windows.getFocusedWindow().close()
        }

        function ver(alertError) {
            alertError.close()

        }

        function window_onunload() {

        }

        function evaluar(e) {
            var esIE = (document.all); //obtengo el tipo de explorador

            tecla = (esIE) ? event.keyCode : e.which;
            if (tecla == 13) {//si se presiona el enter que busque
                registro_buscar();
            }
        }

        var cantdatos;
        function registro_buscar(tabla, desc) {

            if (campos_defs.get_value('nro_tabla_simple') == "") {
                nvFW.alert("Debe seleccionar tabla")
                return
            }

            nvFW.bloqueo_activar($(document.body), 'guardar')

            nvFW.error_ajax_request('abmcodigos_seleccion.aspx', {
                parameters: { modo: 'B', descripcion: $('desc').value, nro_tabla_simple: campos_defs.get_value('nro_tabla_simple') },
                //onCreate: actualizar_start,
                onSuccess: function (err, transport) {

                    var strhtml = '<table class="tb1 highlightOdd highlightTROver" id="tbcontenedor_detalle">'
                    strhtml += err.params['strhtml'];
                    strhtml += '</table>'
                    cantdatos = err.params['cantdatos'];

                    nvFW.bloqueo_desactivar($(document.body), 'guardar')
                    $('contenedor').update(strhtml);

                    if (cantdatos != 0) {
                        $('tbcontenedor_cab').show()
                        window_onresize();
                    }


                }, // fin del onsuccess
                onFailure: function (err) {
                    //if (typeof err == 'object') {
                    //    nvFW.alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                    //}
                },
            });

        } // fin de la funcion buscar




        function modificar(id_registro, desc_old) {
            var strhtml = ""
            //$('modo').value = 'M'

            strhtml += '<table class="tb1" style="width:390" ><tr class="tblabel"><td  style="width:10%; text-align: center">ID</td><td style="width:90%; text-align: center">Descripción</td></tr>'
            strhtml += '<tr><td style="text-align: right">' + id_registro + '</td><td ><input type="text" value="' + desc_old + '" id="mod_desc"  style="width:100%"/></td></tr>'
            strhtml += '</table>'

            //$('contenedor').update(strhtml)
            nvFW.confirm(strhtml, {
                width: 400,
                className: "alphacube",
                okLabel: "Guardar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    if (actualizar_registro(id_registro) != false) win.close()
                }
            });
        } // fin de la funcion modificar


        function actualizar_registro(id_registro) {
            var nueva_desc = $F('mod_desc')
            var strxml = ""

            if (nueva_desc == "") {
                alert("No ha ingresado una descripcion ")
                return false
            }

            var rs = new tRS();

            var parametroFiltro = "<criterio><params tabla='" + campos_defs.get_value('nro_tabla_simple') + "' /></criterio>";

            rs.open(nvFW.pageContents.filtro_tablasSimples, "", "", "", parametroFiltro);

            var strxml = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            strxml += "<abm_registro nro_tabla_simple='" + campos_defs.get_value('nro_tabla_simple') + "' id_registro='" + id_registro + "' descripcion='" + nueva_desc + "' nro_permiso='" + rs.getdata('nro_permiso') + "' modo='M' ></abm_registro>";

            if (!nvFW.tienePermiso("permisos_codigos", rs.getdata('nro_permiso'))) {
                alert('No posee permisos para modificar registro')
                return
            }

            nvFW.error_ajax_request('abmcodigos_seleccion.aspx', {
                parameters: { modo: 'M', strxml: strxml },
                onCreate: actualizar_start,
                onSuccess: function (err, transport) {
                    actualizar_return(err, transport)

                } // fin del onsuccess
            });

        }


        function seleccionar_tabla(tabla) {

            $$('select#tabla option').each(function (o) {
                if (o.readAttribute('value') == tabla) { // note, this compares strings
                    o.selected = true;

                }
            });



        }

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
            vMenuABMSimples.loadImage("abm", "/FW/image/icons/abm.png");

            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Seleccione tabla ABM</Desc></MenuItem>")
            if (codigoID == "") {
                Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Agregar Tabla</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_tabla()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Códigos Externos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_codigosExternos()</Codigo></Ejecutar></Acciones></MenuItem>")
            }
            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_registro()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuABMSimples.MostrarMenu()
        </script>

        <table class="tb1">
            <tr class="tbLabel">
                <td style="width: 20%; text-align: center">Tabla
                </td>
                <td style="text-align: center">Descripción
                </td>
                <td style="width: 10%"></td>
            </tr>
            <tr>
                <td>
                    <script>
                        campos_defs.add('nro_tabla_simple')
                    </script>
                </td>
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
            <td style="width: 13.5%; text-align: center">ID</td>
            <td style="width: 66.5%; text-align: center">Descripción</td>
            <td style="width: 10%; text-align: center">-</td>
            <td style="width: 10%; text-align: center">-</td>
        </tr>
    </table>
    <div id="contenedor" style="width: 100%; overflow-y: auto">
    </div>
</body>
</html>
