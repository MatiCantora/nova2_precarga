<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim dir_raiz = Request.ServerVariables("APPL_PHYSICAL_PATH")
    Dim dir_aplicacion = Session.Contents("app_path_rel")

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim criterio As String = nvFW.nvUtiles.obtenerValor("criterio", "")
    Dim privado As Integer = nvFW.nvUtiles.obtenerValor("privado", 0)
    Dim nro_vista As Integer = nvFW.nvUtiles.obtenerValor("nro_vista", 0)
    'Dim op = nvFW.nvApp.getInstance.operador
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador = op.operador

    If accion = "guardarvista" Then
        Dim e As New tError

        'Dim strXML As String = ""
        Try
            criterio = nvFW.nvUtiles.obtenerValor("criterio", "")
            Dim objXML As New System.Xml.XmlDocument
            objXML.LoadXml(criterio)
            Dim nombre_vista As String = nvXMLUtiles.getAttribute_path(objXML, "criterio/select/@nombre_vista", "")
            Dim xmlconfig = nvFW.nvUtiles.obtenerValor("xmlconfig", "")

            Dim strSQL As String = ""
            Dim nro_save As Integer = nvFW.nvUtiles.obtenerValor("nro_save", 0)
            If nro_save <> 0 Then
                strSQL = "IF EXISTS (SELECT * FROM rptadmin_saves WHERE vista = '" + Replace(nombre_vista, "'", "''") + "' AND nro_save <>" + nro_save.ToString() + ") "
                strSQL += "BEGIN SELECT 'Nombre de vista ya utilizado.' AS mensaje, 101 AS numError, 'Error' AS titulo END "
                strSQL += "ELSE BEGIN "
                If privado = 1 Then
                    strSQL += "UPDATE rptadmin_saves SET vista = '" + Replace(nombre_vista, "'", "''") + "', strXML = '" + Replace(criterio, "'", "''") + "', privado = " + privado.ToString() + ", usuario = " + nro_operador.ToString() + ", nro_vista = " + nro_vista.ToString() + ", xmlconfig = '" + Replace(xmlconfig, "'", "''") + "' WHERE nro_save = " + nro_save.ToString()
                Else
                    strSQL += "UPDATE rptadmin_saves SET vista = '" + Replace(nombre_vista, "'", "''") + "', strXML = '" + Replace(criterio, "'", "''") + "', privado = " + privado.ToString() + ", nro_vista = " + nro_vista.ToString() + ", xmlconfig = '" + Replace(xmlconfig, "'", "''") + "' WHERE nro_save = " + nro_save.ToString()
                End If
                strSQL += " SELECT 'Vista <b>" + nombre_vista + "</b> guardada con exito.' AS mensaje, 0 AS numError, '' AS titulo END"
            Else
                strSQL = "IF EXISTS (SELECT * FROM rptadmin_saves WHERE vista = '" + Replace(nombre_vista, "'", "''") + "') "
                strSQL += "BEGIN SELECT 'Nombre de vista ya utilizado.' AS mensaje, 101 AS numError, 'Error' AS titulo END "
                strSQL += "ELSE BEGIN "
                If privado = 1 Then
                    strSQL += "INSERT INTO rptadmin_saves (vista, strXML, privado, usuario, nro_vista, xmlconfig) VALUES ('" + Replace(nombre_vista, "'", "''") + "', " + "'" + Replace(criterio, "'", "''") + "'," + privado.ToString() + "," + nro_operador.ToString() + "," + nro_vista.ToString() + ",'" + Replace(xmlconfig, "'", "''") + "')"
                Else
                    strSQL += "INSERT INTO rptadmin_saves (vista, strXML, privado, nro_vista, xmlconfig) VALUES ('" + Replace(nombre_vista, "'", "''") + "', " + "'" + Replace(criterio, "'", "''") + "'," + privado.ToString() + "," + nro_vista.ToString() + ", '" + Replace(xmlconfig, "'", "''") + "')"
                End If
                strSQL += " SELECT 'Vista <b>" + nombre_vista + "</b> guardada con exito.' AS mensaje, 0 AS numError, '' AS titulo END"
            End If

            Dim rsSave As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)

            e.mensaje = rsSave.Fields("mensaje").Value
            e.numError = rsSave.Fields("numError").Value
            e.titulo = rsSave.Fields("titulo").Value

        Catch ex As Exception
            e.parse_error_script(ex)
            e.mensaje = "Error al actualizar la vista."
            e.numError = 100
            e.titulo = "Error"
        End Try

        e.response()

    End If

    If accion = "eliminarvista" Then
        Dim e As New tError
        Dim nro_save As Integer = nvFW.nvUtiles.obtenerValor("nro_save")
        Try

            'veo si la vista es publica o privada
            Dim strSQL As String = "SELECT vista, privado from rptadmin_saves"
            Dim rsVista As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
            Dim nombre_vista As String = rsVista.Fields("vista").Value
            privado = rsVista.Fields("privado").Value

            If privado = 0 Then
                strSQL = "IF (SELECT dbo.rm_tiene_permiso('permisos_administrador_reportes',3)) > 0	BEGIN DELETE FROM rptadmin_saves WHERE nro_save = " & nro_save.ToString() & " SELECT 'Vista <b>" + nombre_vista + "</b> eliminada con exito.' AS mensaje, 0 AS numError	END "
                strSQL += "ELSE BEGIN SELECT 'No posee permisos para realizar la operacion' AS mensaje, 401 AS numError END"
                rsVista = nvDBUtiles.DBExecute(strSQL)

                e.mensaje = rsVista.Fields("mensaje").Value
                e.numError = rsVista.Fields("numError").Value
            Else
                strSQL = "DELETE FROM rptadmin_saves WHERE nro_save = '" & nro_save.ToString() & "'"
                nvDBUtiles.DBExecute(strSQL)

                e.mensaje = "Vista <b>" + nombre_vista + "</b> eliminada con exito."
                e.numError = 0

            End If

        Catch ex As Exception
            e.parse_error_script(ex)
            e.mensaje = "Error al eliminar vista."
            e.numError = 100
            e.titulo = "Error"
        End Try

        e.response()

    End If

    If accion = "generarSQL" Then
        Dim e As New tError

        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

        Try

            Dim strSQL As String = nvFW.nvXMLSQL.XMLtoSQL(strXML)
            e.params.Add("strSQL", strSQL)

        Catch ex As Exception
            e.parse_error_script(ex)
            e.mensaje = "Error al generar SQL."
            e.numError = 102
            e.titulo = "Error"
        End Try
        e.response()
    End If


    Me.contents("filtro_rptadmin_saves") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRptadmin_saves'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroVistas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRptadmin_vistas'><campos>nro_vista as id, concat(descripcion, ' (', nombre_vista, ')') as campo, vista_columnas</campos><filtro></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtroCbGuardado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRptadmin_saves'><campos>nro_save as id, concat(vista, case when privado = 0 then ' [Publica]' when privado = 1 then ' [Pirvada]' end) as campo</campos><filtro><or><usuario type='igual'>" + nro_operador.ToString() + "</usuario><usuario type='isnull'></usuario></or></filtro><orden>campo</orden></select></criterio>")
    Me.contents("filtro_conexion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='rptadmin_vistas'><campos>distinct cn AS id, cn AS campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")


    Me.contents("filtroColumnas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRptadmin_columnas' cn='%conexion%'><campos>columna</campos><filtro><vista type='igual'>'%nombre_vista%'</vista></filtro><orden>columna</orden></select></criterio>")

    Dim path_filtros As String = "/" + nvFW.nvApp.getInstance.path_rel + "/rptadmin/rptadmin_filtros.aspx"

    If Not System.IO.File.Exists(HttpContext.Current.Server.MapPath(path_filtros)) Then
        path_filtros = "/FW/enBlanco.htm"
    End If
    Me.contents("path_filtros") = path_filtros

    Me.addPermisoGrupo("permisos_administrador_reportes")

    If (Not op.tienePermiso("permisos_administrador_reportes", 1)) Then Response.Redirect("/FW/error/httpError_401.aspx")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administrador de vistas y reportes</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var verResultado = new Array();
        var btncolor;
        var xmlconfig = '';
        var cargarConfig = false;
        var resNum = 0;
        var nombre_vista = '';
        var ventanaFiltros;
        var vista_cacheCampos = {};
        var flagVistasGuardadas_onchange = false;
        var objXML;

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "BtnVer";
        vButtonItems[0]["etiqueta"] = "Ejecutar";
        vButtonItems[0]["imagen"] = "ejecutar";
        vButtonItems[0]["onclick"] = "return resultado_exportar()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "BtnAgregar";
        vButtonItems[1]["etiqueta"] = "";
        vButtonItems[1]["imagen"] = "agregar";
        vButtonItems[1]["onclick"] = "return campos_ondblclick()";

        vButtonItems[2] = {};
        vButtonItems[2]["nombre"] = "BtnQuitar";
        vButtonItems[2]["etiqueta"] = "";
        vButtonItems[2]["imagen"] = "quitar";
        vButtonItems[2]["onclick"] = "return resultado_ondblclick()";

        vButtonItems[3] = {};
        vButtonItems[3]["nombre"] = "BtnAgregarTodo";
        vButtonItems[3]["etiqueta"] = "";
        vButtonItems[3]["imagen"] = "agregartodo";
        vButtonItems[3]["onclick"] = "return btnTodo_onclick()";

        vButtonItems[4] = {};
        vButtonItems[4]["nombre"] = "BtnQuitarTodo";
        vButtonItems[4]["etiqueta"] = "";
        vButtonItems[4]["imagen"] = "quitartodo";
        vButtonItems[4]["onclick"] = "return btnLimpiar_onclick()";

        vButtonItems[5] = {};
        vButtonItems[5]["nombre"] = "BtnSubir";
        vButtonItems[5]["etiqueta"] = "";
        vButtonItems[5]["imagen"] = "subir";
        vButtonItems[5]["onclick"] = "return btnSubir_onclick()";

        vButtonItems[6] = {};
        vButtonItems[6]["nombre"] = "BtnBajar";
        vButtonItems[6]["etiqueta"] = "";
        vButtonItems[6]["imagen"] = "bajar";
        vButtonItems[6]["onclick"] = "return btnBajar_onclick()";

        vButtonItems[7] = {};
        vButtonItems[7]["nombre"] = "BtnImprimir";
        vButtonItems[7]["etiqueta"] = "Ejecutar";
        vButtonItems[7]["imagen"] = "ejecutar";
        vButtonItems[7]["onclick"] = "return resultado_reporte()";

        vButtonItems[8] = {};
        vButtonItems[8]["nombre"] = "BtnSQL_Portapapeles";
        vButtonItems[8]["etiqueta"] = "SQL";
        vButtonItems[8]["imagen"] = "";
        vButtonItems[8]["onclick"] = "return btnSQL_Portapapeles_onclick()";

        vButtonItems[9] = {};
        vButtonItems[9]["nombre"] = "BtnXML_Portapapeles";
        vButtonItems[9]["etiqueta"] = "XML";
        vButtonItems[9]["imagen"] = "";
        vButtonItems[9]["onclick"] = "return btnXML_Portapapeles_onclick()";

        vButtonItems[10] = {};
        vButtonItems[10]["nombre"] = "BtnExcelxlsx";
        vButtonItems[10]["etiqueta"] = "Ejecutar";
        vButtonItems[10]["imagen"] = "ejecutar";
        vButtonItems[10]["onclick"] = "return resultado_excel_xlsx()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage('ejecutar', '/FW/image/icons/reporte.png')
        vListButton.loadImage('excel', '/FW/image/icons/excel.png')
        vListButton.loadImage('agregar', '/FW/image/icons/agregar_seleccion.png')
        vListButton.loadImage('quitar', '/FW/image/icons/quitar_seleccion.png')
        vListButton.loadImage('agregartodo', '/FW/image/icons/agregartodo_seleccion.png')
        vListButton.loadImage('quitartodo', '/FW/image/icons/quitartodo_seleccion.png')
        vListButton.loadImage('subir', '/FW/image/icons/up_a.png')
        vListButton.loadImage('bajar', '/FW/image/icons/down_a.png')

        var path_filtros = nvFW.pageContents.path_filtros;

        function window_onload() {

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 4))
                $('timeout').disabled = true;
            if (!nvFW.tienePermiso('permisos_administrador_reportes', 7)) {
                $('textareaFiltroWhere').disabled = true;
                $('checkFiltro').disabled = true;
            }

            sel_metodo(1);
            paginar_resultado();
            vListButton.MostrarListButton();

            ObtenerVentana('frmFiltros').location.href = path_filtros;
            ventanaFiltros = ObtenerVentana('frmFiltros');

            cargarCampos_defs();
            mostrar_filtroWhere();
            //mostrar_orden();
            window_onresize();
            flagVistasGuardadas_onchange = false;

        }

        function cargarCampos_defs() {

            campos_defs.set_first('conexion');
            campos_defs.set_value('cbGuardado', '');

        }

        function filtro_XML(campos, toprows, saltar_filtros) {
            var i
            var strXML = '<criterio>';
            var strSelect = '';
            var orden = '';
            var Top = 0;
            var Vista = '';
            verResultado = new Array();

            for (i = 0; i < $('resultado').options.length; i++)
                verResultado[i] = $('resultado').options[i].text

            orden = ''
            if (campos == '*')
                orden = ''
            else
                if (verResultado.length > 0)//si no: carga los campos
                {
                    campos = ''
                    verResultado.each(function (arreglo, i) {
                        campos += ',' + arreglo
                        if (i < parseInt($('cont_orden').value) && arreglo != '*')
                            orden += ',' + arreglo
                    });
                    orden = orden.substr(1)
                    campos = campos.substr(1)
                }
                else {
                    // si no especifica campos en el resultado
                    // coloca todos
                    campos = '*'
                }

            if (toprows == undefined) {
                if (!isNaN(parseInt($('toprows').value)))
                    Top = $('toprows').value
            }
            else {
                toprows = $('percent').checked == true && toprows == '' ? 100 : toprows
                Top = $('percent').checked == true ? toprows + " percent" : toprows
            }

            Vista = nombre_vista;

            var timeout = 0;
            if ($('timeout').value != '')
                timeout = $('timeout').value;

            if (Top == 0)
                var timeout = 0; //ms
            //var timeout = 10; //ms

            if (campos_defs.get_value('conexion').toLowerCase()  == 'primaria' || campos_defs.get_value('conexion').toLowerCase()  == 'default')
                strXML += '<select top="' + Top + '" vista="' + Vista + '" cont_orden="' + $('cont_orden').value + '" cn="default" CommandTimeout="' + timeout + '"><campos>' + campos + '</campos><orden>' + orden + '</orden><filtro>'
            else strXML += '<select top="' + Top + '" vista="' + Vista + '" cont_orden="' + $('cont_orden').value + '" cn="' + campos_defs.get_value('conexion') + '" CommandTimeout="' + timeout + '"><campos>' + campos + '</campos><orden>' + orden + '</orden><filtro>'
            //*************************
            //si hay que generar los filtros
            if (saltar_filtros != true) {

                strXML += campos_defs.filtroWhere()

                if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.getStrXML != 'undefined'))
                    strXML += ventanaFiltros.getStrXML();
                strXML = strXML.replace(/, /g, ",");        //ver si hace falta en algun caso        

                //FiltroWhere textarea
                if ($('textareaFiltroWhere').value != '')
                    strXML += '<AND origen="userFilter">' + $('textareaFiltroWhere').value + '</AND>';

            }//aplica_filtro    

            strXML += '</filtro></select></criterio>'

            return strXML
        }

        function resultado_mostrar_onclick() {
            //Recupera el filtro XML
            var strXML = filtro_XML()
            XML1.async = false

            frmCreditos.document.all.divCreditos.innerHTML = ""
            var strHTML = '<table class="tb1">'
            strHTML += '<tr class="tbLabel"><td>&nbsp;</td>'
            verResultado.each(function (arreglo, j) { strHTML += '<td>' + arreglo + '</td>' });
            strHTML += '</tr>'

            if (XML1.load("GetXML.aspx?accion=filtroCredito&criterio=" + strXML)) {
                NOD = XML1.getElementsByTagName('xml/rs:data')[0]
                for (var i = 0; i < NOD.childNodes.length; i++) {
                    strHTML += '<tr><td>' + (i + 1) + '</td>'
                    verResultado.each(function (arreglo, j) { strHTML += '<td nowrap>' + getAttribute(NOD.childNodes[i], arreglo) + '</td>' });
                    strHTML += '</tr>'
                }
                strHTML += '</table>'
                $('strSQL').value = XML1.getElementsByTagName('xml/strSQL')[0].text
                frmCreditos.document.all.divCreditos.insertAdjacentHTML('AfterBegin', strHTML)
            }
            else {
                alert('Error')
            }
        }


        function resultado_reporte() {

            if (campos_defs.get_value('nro_vista') == '') {
                alertVista("Debe seleccionar una vista.");
                return;
            }

            var filename = nombre_vista;
            var ContentType = $('cb_contenttype_reporte').options[$('cb_contenttype_reporte').selectedIndex].text;
            var formtarget = '';

            switch (ContentType) {
                case 'application/vnd.ms-excel':
                    filename = filename + ".xls";
                    break;
                case 'application/msword':
                    filename = filename + ".doc";
                    break;
                case 'application/pdf':
                    filename = filename + ".pdf";
                    formtarget = '_blank';
                    break;
                default:
                    filename = filename + ".pdf";
                    formtarget = '_blank';
                    break;
            }

            if ($('reporte').selectedIndex > -1) {

                var criterio = filtro_XML('', $('toprows').value);

                var path_report = $('reporte').options[$('reporte').selectedIndex].value

                nvFW.mostrarReporte({
                    filtroXML: criterio,
                    path_reporte: path_report,
                    filename: filename,
                    salida_tipo: 'adjunto',
                    formTarget: formtarget,
                    ContentType: ContentType
                });

            }
        }

        function resultado_excel_xlsx() {

            if (campos_defs.get_value('nro_vista') == '') {
                alertVista("Debe seleccionar una vista.");
                return;
            }

            var filename = nombre_vista + ".xlsx";
            var ContentType = $('cb_contenttype_excelxlsx').options[$('cb_contenttype_excelxlsx').selectedIndex].text;

            nvFW.exportarReporte({
                filtroXML: filtro_XML('', $('toprows').value),
                filtroWhere: '',
                salida_tipo: 'adjunto',
                filename: filename,
                ContentType: ContentType,
                export_exeption: 'RSXMLtoExcel'
            });

        }


        var alertVista = function (msg) { window.top.Dialog.alert(msg, { title: "<b>Error</b>", className: "alphacube", width: 200, height: 100, okLabel: "cerrar" }); };
        function resultado_exportar() {

            if (campos_defs.get_value('nro_vista') == '') {
                alertVista("Debe seleccionar una vista.");
                return;
            }


            var path_xsl = '';
            var export_exeption = ''
            var filename = '';
            var ContentType = '';
            var formTarget = '';
            //var nvFW_mantener_origen = false;
            var parametros = '';

            if ($('plantilla').options[$('plantilla').selectedIndex].value == '')
                switch ($('plantilla').options[$('plantilla').selectedIndex].text) {
                    case 'HTML base':
                        path_xsl = '/report/HTML_base.xsl';
                        break;
                    case 'EXCEL base': path_xsl = '/report/EXCEL_base.xsl';
                        break;
                    case 'CSV base': path_xsl = '/report/csv_base.xsl';
                        break;
                    default:
                        path_xsl = '/report/HTML_base.xsl';
                        break;
                }
            else {
                path_xsl = $('plantilla').options[$('plantilla').selectedIndex].value;

            }

            ContentType = $('cb_contenttype').options[$('cb_contenttype').selectedIndex].text;
            formTarget = '_blank';

            if ($('cb_contenttype').options[$('cb_contenttype').selectedIndex].text == 'application/vnd.ms-excel') {
                filename = nombre_vista + ".xls";
                formTarget = '';
            }

            if ($('cb_contenttype').options[$('cb_contenttype').selectedIndex].text == 'application/msword') {
                filename = nombre_vista + ".doc";
                formTarget = '';
            }

            if (window.name == "")
                window.name = 'ventanaParentABMReportes';
            parametros = "<parametros><ABMReportes window_parentName='" + window.name + "'/></parametros>";

            var filtro = '';

            if ($('chckPaginar').checked && ContentType == 'text/html') {
                if ($('cant_filas').value != '') {

                    //if (window.name == "")
                    //    window.name = 'ventanaParentABMReportes';

                    filtro = "<criterio><select PageSize='" + $('cant_filas').value + "' AbsolutePage='" + $('nro_pag').value + "' expire_minutes='1' cacheControl='Session'><filtro></filtro></select></criterio>";
                    //parametros = "<parametros><ABMReportes window_parentName='" + window.name + "'/></parametros>";

                } else { alert('Debe ingresar la cantidad de filas por pagina.'); return; }
                //nvFW_mantener_origen = true;
            }

            if (formTarget == '_blank') { //text/html
                resNum += 1;
                formTarget = "ventena_resultado" + resNum;
            }

            nvFW.exportarReporte({
                filtroXML: filtro_XML('', $('toprows').value),
                filtroWhere: filtro,
                parametros: parametros,
                path_xsl: path_xsl,
                formTarget: formTarget,
                salida_tipo: 'adjunto',
                filename: filename,
                nvFW_mantener_origen: true,//nvFW_mantener_origen,
                ContentType: ContentType,
                export_exeption: export_exeption
            });

        }

        function vista_onchange() {

            cargarNombreVista();
            campos_limpiar();
            if (campos_defs.get_value('nro_vista') != '') {
                vista_cargar_campos();
                reportes_cargar();
                plantillas_cargar();
                window_onresize();
            } else {
                $('resultado').options.length = 0
                $('campos').options.length = 0
                $('reporte').options.length = 0;
                $('plantilla').options.length = 0;
                if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                    ventanaFiltros.filtros_habilitar();
            }
        }

        function cargarNombreVista() {
            nombre_vista = campos_defs.get_desc('nro_vista');
            nombre_vista = nombre_vista.slice(nombre_vista.indexOf('(') + 1, nombre_vista.indexOf(')'));
        }


        function vista_cargar_campos() {

            var nro_vista = campos_defs.get_value('nro_vista') == '' ? 0 : campos_defs.get_value('nro_vista');
            $('resultado').options.length = 0
            $('campos').options.length = 0

            oOption = document.createElement("OPTION")
            $('resultado').options.add(oOption, 0)
            oOption.innerText = '*'

            if (typeof vista_cacheCampos[nro_vista] != "undefined") { //CAMPOS CACHEADOS

                for (var i = 0; i < vista_cacheCampos[nro_vista].campos.length; i++) {
                    strCampo = vista_cacheCampos[nro_vista].campos[i]
                    for (j = 0; j < $('campos').options.length; j++)
                        if (strCampo.toLowerCase() < $('campos').options[j].text.toLowerCase())
                            break
                    oOption = document.createElement("OPTION")
                    $('campos').options.add(oOption, j)
                    oOption.innerText = strCampo
                }

                if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                    ventanaFiltros.filtros_habilitar();

                if (flagVistasGuardadas_onchange && nro_vista != 0) {
                    CargarFiltroXML();
                    flagVistasGuardadas_onchange = false;
                }

                nvFW.bloqueo_desactivar(null, 'cargar_vista_guardada');

            } else { //CAMPOS NO CACHEADOS

                nvFW.bloqueo_activar($(document.body), 'cargar', '<table class="tb1"><tr><td>Cargando...</td><td><img id="btnCancelRS" title="Cancelar" style="cursor: pointer;" src="/FW/image/icons/cancelar.png"/></td></tr></table>');

                if (flagVistasGuardadas_onchange)
                    nvFW.bloqueo_desactivar(null, 'cargar_vista_guardada');

                //VERIFICO VALOR DE VISTA_COLUMNAS, SI VISTA_COLUMNAS = true, EXISTE LA VISTA EN LA BASE PARA CARGAR LAS COLUMNAS, SI NO, SELECT TOP 0
                var indice = 0;
                if (campos_defs.items['nro_vista'].sin_seleccion)
                    indice = 1;

                var vista_columnas = false;
                if (nro_vista > 0)
                    vista_columnas = campos_defs.items['nro_vista'].rs.data[campos_defs.items['nro_vista'].input_select.options.selectedIndex - indice]['vista_columnas'];

                var rs = new tRS();
                rs.async = true;

                if (vista_columnas) { //SI EXISTE VISTA COLUMNAS

                    var strXML = nvFW.pageContents.filtroColumnas;
                    var parametrosFiltroColumnas = '<criterio><params nombre_vista="' + nombre_vista + '" conexion="' + campos_defs.get_value('conexion') + '" /></criterio>';

                    rs.onError = function () {
                        alert('Error al cargar vista.')
                        nvFW.bloqueo_desactivar(null, 'cargar');
                    }

                    rs.onComplete = function () {

                        var i
                        var j
                        var strCampo
                        var oOption

                        vista_cacheCampos[nro_vista] = { campos: [] };

                        while (!rs.eof()) {

                            if (rs.getdata('columna') != undefined) {

                                strCampo = rs.getdata('columna')
                                for (j = 0; j < $('campos').options.length; j++)
                                    if (strCampo.toLowerCase() < $('campos').options[j].text.toLowerCase())
                                        break
                                oOption = document.createElement("OPTION")
                                $('campos').options.add(oOption, j)
                                oOption.innerText = strCampo

                                vista_cacheCampos[nro_vista].campos.push(strCampo);
                            }

                            rs.movenext();
                        }

                        if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                            ventanaFiltros.filtros_habilitar();

                        if (flagVistasGuardadas_onchange && nro_vista != 0) {
                            CargarFiltroXML();
                            flagVistasGuardadas_onchange = false;
                        }
                        nvFW.bloqueo_desactivar(null, 'cargar');
                    }

                    rs.open(strXML, "", "", "", parametrosFiltroColumnas);

                } else { //SELECT TOP 0                    

                    var strXML = filtro_XML('*', 0, true)

                    rs.onError = function () {
                        alert('Error al cargar vista.')
                        nvFW.bloqueo_desactivar(null, 'cargar');
                    }

                    rs.onComplete = function () {

                        var i
                        var j
                        var strCampo
                        var oOption

                        vista_cacheCampos[nro_vista] = { campos: [] };

                        rs.fields.each(function (arreglo, index) {

                            if (arreglo['name'] != undefined) {

                                strCampo = arreglo['name']
                                for (j = 0; j < $('campos').options.length; j++)
                                    if (strCampo.toLowerCase() < $('campos').options[j].text.toLowerCase())
                                        break
                                oOption = document.createElement("OPTION")
                                $('campos').options.add(oOption, j)
                                oOption.innerText = strCampo

                                vista_cacheCampos[nro_vista].campos.push(strCampo);
                            }
                        });

                        if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                            ventanaFiltros.filtros_habilitar();

                        if (flagVistasGuardadas_onchange && nro_vista != 0) {
                            CargarFiltroXML();
                            flagVistasGuardadas_onchange = false;
                        }
                        nvFW.bloqueo_desactivar(null, 'cargar');
                    }

                    rs.open(strXML);

                }

                $('btnCancelRS').observe('click', function () {   //BOTON PARA CANCELAR EL RS.OPEN
                    rs.objXML.abort();
                    rs = null;
                    if (typeof vista_cacheCampos[nro_vista] != 'undefined')
                        vista_cacheCampos[nro_vista] = undefined
                    if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                        ventanaFiltros.filtros_habilitar();
                    nvFW.bloqueo_desactivar(null, 'cargar');
                });


            }

            if (campos_defs.get_value('nro_vista') == 0)
                nvFW.bloqueo_desactivar(null, 'cargar');


        }


        function habilitar(campo) {
            for (var i = 0; i < $('campos').options.length; i++)
                if ($('campos').options[i].text == campo)
                    return true
            return false
        }


        function selVendedor_onclick() {
            var a = new Array()

            var res = window.showModalDialog("funciones/selVendedor.aspx", a, 'dialogHeight: 300px; dialogWidth: 500px; edge: Raised; center: Yes; help: No; resizable: No; status: No;')
            var e
            try {
                $('nro_vendedor').value = res["nro_vendedor"]
                $('selVendedor').value = "Vendedor(" + res["vendedor"] + ")"
            }
            catch (e) {
                $('nro_vendedor').value = ""
                $('selVendedor').value = "Vendedor()"
            }

        }

        function btnSQL_Portapapeles_onclick() {

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 5)) {
                alert('No posee permisos para realizar esta acción.');
                return;
            }

            if (campos_defs.get_value('nro_vista') == '') {
                alert('Debe seleccionar una vista.')
                return;
            }

            var strXML = filtro_XML('', $('toprows').value)

            nvFW.error_ajax_request('ABMReportes.aspx', {
                parameters: {
                    accion: 'generarSQL',
                    strXML: strXML
                },
                onSuccess: function (err, transport) {
                    var strSQL = err.params['strSQL']

                    var strHTML = '<textarea id="textareaSQL" style="width: 650px; height: 150px">' + strSQL + '</textarea>'

                    var win = window.top.nvFW.createWindow({
                        className: "alphacube",
                        width: 650, height: 160,
                        resizable: true,
                        draggable: true,
                        closable: true,
                        minimizable: true,
                        maximizable: false,
                        title: "<b>Sentencia SQL</b>"
                    })
                    win.getContent().innerHTML = strHTML
                    win.showCenter();

                }
            });

        }

        function btnXML_Portapapeles_onclick() {

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 6)) {
                alert('No posee permisos para realizar esta acción.');
                return;
            }

            if (campos_defs.get_value('nro_vista') == '') {
                alert('Debe seleccionar una vista.')
                return;
            }

            var strXML = filtro_XML('', $('toprows').value)

            var blob = new Blob([strXML.replace(/'/g, '"')], { type: 'text/xml' });
            var url = URL.createObjectURL(blob);
            window.open(url, null, "width=800, height=500, top=150, left=150");
            URL.revokeObjectURL(url); // Liberar recursos


        }

        function campos_ondblclick() {
            if ($('campos').selectedIndex > -1 && Existe($('resultado'), $('campos').options[$('campos').options.selectedIndex].text) == false) {
                if (Existe($('resultado'), '*') == true) {
                    $('resultado').remove($('resultado').options.length - 1)
                }
                $('resultado').options.length++
                $('resultado').options[$('resultado').options.length - 1].text = $('campos').options[$('campos').selectedIndex].text
            }
        }

        function resultado_ondblclick() {
            if ($('resultado').selectedIndex > -1)
                $('resultado').remove($('resultado').selectedIndex)
            if (Existe($('resultado'), '*') == false && $('resultado').length == 0) {
                $('resultado').options.length++
                $('resultado').options[$('resultado').options.length - 1].text = '*'
            }
        }

        function btnLimpiar_onclick() {
            $('resultado').options.length = 0
            oOption = document.createElement("OPTION")
            $('resultado').options.add(oOption, 0)
            oOption.innerText = '*'
        }

        function btnTodo_onclick() {
            $('resultado').options.length = $('campos').options.length
            for (var i = 0; i < $('campos').options.length; i++)
                $('resultado').options[i].text = $('campos').options[i].text
        }

        function btnSubir_onclick() {
            if ($('resultado').selectedIndex > 0) {
                var a = $('resultado').options[$('resultado').selectedIndex].text
                $('resultado').options[$('resultado').selectedIndex].text = $('resultado').options[$('resultado').selectedIndex - 1].text
                $('resultado').options[$('resultado').selectedIndex - 1].text = a
                $('resultado').selectedIndex--
            }
        }

        function btnBajar_onclick() {
            if ($('resultado').selectedIndex < $('resultado').options.length - 1) {
                var a = $('resultado').options[$('resultado').selectedIndex].text
                $('resultado').options[$('resultado').selectedIndex].text = $('resultado').options[$('resultado').selectedIndex + 1].text
                $('resultado').options[$('resultado').selectedIndex + 1].text = a
                $('resultado').selectedIndex++
            }
        }


        function cbVistasGuardadas_onchange() {

            flagVistasGuardadas_onchange = true;

            if (campos_defs.get_value('cbGuardado') == '') {
                flagVistasGuardadas_onchange = false;
                return;
            }


            nvFW.bloqueo_activar($(document.body), 'cargar_vista_guardada', 'Cargando...');

            var rsVistaGuardada = new tRS();
            rsVistaGuardada.async = true;

            rsVistaGuardada.onComplete = function (resp) {

                var strXML = rsVistaGuardada.getdata('strXML'); //XML PARA CARGAR LOS FILTROS
                var nro_vista = rsVistaGuardada.getdata('nro_vista');
                var conexion = rsVistaGuardada.getdata('conexion');
                xmlconfig = rsVistaGuardada.getdata('xmlconfig');

                objXML = new tXML();
                if (objXML.loadXML(strXML)) {
                    cargarConfig = true;

                    //Limpiar los campos filtros
                    campos_limpiar()
                    campos_defs.set_value('conexion', conexion); //SI rsVistaGuardada.async = true, CARGA LOS FILTROS EN EL ONCHANGE
                    campos_defs.set_value('nro_vista', nro_vista);

                    window_onresize()
                } else {
                    nvFW.bloqueo_desactivar(null, 'cargar_vista_guardada');
                    objXML = new tXML();
                    alert("Error al cargar vista guardada.")
                }

            }

            rsVistaGuardada.open(nvFW.pageContents.filtro_rptadmin_saves, "", "<nro_save type='igual'>" + campos_defs.get_value('cbGuardado') + "</nro_save>")

        }


        function Existe(combo, valor) {
            if (combo.length != 0) {
                for (i = 0; i < combo.length; i++) {
                    if (combo.options[i].text == valor) {
                        return (true)
                    }
                }
            }
            return (false)
        }

        function campos_limpiar() {

            $('textareaFiltroWhere').value = "";

            if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.limpiar_filtros != 'undefined'))
                ventanaFiltros.limpiar_filtros();

            //Setear campos configuracion por defecto
            $('timeout').value = 90;
            $('chckPaginar').checked = false;
            paginar_resultado();
            $('toprows').value = 200;
            $('cont_orden').value = 0;
            $('percent').checked = false;
        }


        //function CargarFiltroXML(objXML, nro_vista, conexion) {
        function CargarFiltroXML() {
            ////Limpiar los campos filtros
            //campos_limpiar()

            //campos_defs.set_value('conexion', conexion);
            //campos_defs.set_value('nro_vista', nro_vista);

            var toprows = ""
            toprows = objXML.selectNodes('criterio/select/@top')[0].nodeValue
            //parseo la variable  @top 
            var porcentaje = toprows.split(" ")
            porcentaje.each(function (arreglo, i) {
                if (isNaN(parseInt(arreglo)) == false)
                    $('toprows').value = parseInt(arreglo)
                if (arreglo == "percent")
                    $('percent').checked = true
            });
            $('cont_orden').value = objXML.selectNodes('criterio/select/@cont_orden')[0].nodeValue
            $('resultado').options.length = 0
            var campos = XMLText(objXML.selectNodes('criterio/select/campos')[0])
            var campo
            while (campos.indexOf(',') > 0) {
                campo = campos.substr(0, campos.indexOf(','))
                campos = campos.substr(campos.indexOf(',') + 1)
                $('resultado').length++
                $('resultado').options[$('resultado').options.length - 1].text = campo
            }
            $('resultado').length++
            $('resultado').options[$('resultado').options.length - 1].text = campos

            //**************************************************
            //  Cargar filtros
            //**************************************************  
            if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.cargar_filtros != 'undefined'))
                ventanaFiltros.cargar_filtros(objXML);

            //cargar textarea de filtroWhere
            var userFilterXML = '';
            if (typeof objXML.selectNodes('criterio/select/filtro/AND/@origen') != "undefined" && objXML.selectNodes('criterio/select/filtro/AND/@origen').length > 0) {
                var nodosUserFilter = objXML.selectNodes('criterio/select/filtro/AND/@origen')[0].ownerElement.childNodes;
                for (var j = 0; j < nodosUserFilter.length; j++) {
                    userFilterXML += nodosUserFilter[j].outerHTML;
                }
                $('textareaFiltroWhere').value = userFilterXML;
            }

        }

        function selectItemCb(cb, valor) {
            for (var i = 0; i < cb.options.length; i++)
                if (parseInt(cb.options[i].value) == parseInt(valor)) {
                    cb.selectedIndex = i
                    break
                }
        }

        function selectItemList(cb, strValue) {
            var res = parseSTR(strValue)
            for (var i = 0; i < cb.options.length; i++) {
                cb.options(i).selected = false
                for (var j = 0; j < res.length; j++)
                    if (parseInt(cb.options(i).value) == parseInt(res[j])) {
                        cb.options(i).selected = true
                        break
                    }
            }
        }

        function parseSTR(strValue) {
            var pos1
            var res = new Array()
            pos1 = strValue.indexOf(',')
            while (pos1 != -1) {
                res[res.length] = strValue.substr(0, pos1)
                strValue = strValue.substr(pos1 + 1)
                pos1 = strValue.indexOf(',')
            }
            if (strValue.length != 0)
                res[res.length] = strValue

            return res
        }

        function reportes_cargar() {

            var nombreVista = nombre_vista;

            var criterio = '<criterio><select vista="' + nombreVista + '"></select></criterio>'

            $('reporte').options.length = 0

            new Ajax.Request('/FW/GetXML.aspx', {
                method: 'get',
                encoding: 'ISO-8859-1',
                contentType: 'application/xml',
                parameters: { accion: 'get_reportes', criterio: criterio },
                onSuccess: reportes_cargar_return
            });

        }

        function reportes_cargar_return(transport) {

            var objXML = new tXML();
            objXML.loadXML(transport.responseText)
            NODs = objXML.selectNodes('xml/rs:data')[0]
            for (var i = 0; i < NODs.childNodes.length; i++) {
                $('reporte').options.length++
                $('reporte').options[$('reporte').options.length - 1].value = selectNodes('@path', NODs.childNodes[i])[0].nodeValue // getAttribute(NODs.childNodes[i], 'path')
                $('reporte').options[$('reporte').options.length - 1].text = selectNodes('@name', NODs.childNodes[i])[0].nodeValue //getAttribute(NODs.childNodes[i], 'name')
            }
        }

        function plantilla_onchange() {
            if ($('plantilla').options[$('plantilla').options.selectedIndex].text == 'HTML base') {
                $('cb_contenttype').selectedIndex = 1;
                $('cb_contenttype').disabled = true;
                return
            }
            if ($('plantilla').options[$('plantilla').options.selectedIndex].text == 'EXCEL base') {
                $('cb_contenttype').selectedIndex = 0;
                $('cb_contenttype').disabled = true;
                return
            }
            if ($('plantilla').options[$('plantilla').options.selectedIndex].text == 'CSV base') {
                $('cb_contenttype').selectedIndex = 1;
                $('cb_contenttype').disabled = true;
                return
            }

            $('cb_contenttype').disabled = false
        }

        function plantillas_cargar() {

            var nombreVista = nombre_vista;

            var criterio = '<criterio><select vista="' + nombreVista + '"></select></criterio>';

            $('plantilla').options.length = 0;
            $('plantilla').options.length++;
            $('plantilla').options[$('plantilla').options.length - 1].value = '';
            $('plantilla').options[$('plantilla').options.length - 1].text = 'HTML base';
            $('plantilla').options.length++;
            $('plantilla').options[$('plantilla').options.length - 1].value = '';
            $('plantilla').options[$('plantilla').options.length - 1].text = 'EXCEL base';
            $('plantilla').options.length++;
            $('plantilla').options[$('plantilla').options.length - 1].value = '';
            $('plantilla').options[$('plantilla').options.length - 1].text = 'CSV base';

            new Ajax.Request('/FW/getXML.aspx', {
                method: 'get',
                encoding: 'ISO-8859-1',
                contentType: 'application/xml',
                parameters: { accion: 'get_plantillas', criterio: criterio },
                onSuccess: plantillas_cargar_return
            });

        }

        function plantillas_cargar_return(transport) {

            var objXML = new tXML();
            objXML.loadXML(transport.responseText);
            NODs = objXML.selectNodes('xml/rs:data')[0];
            for (var i = 0; i < NODs.childNodes.length; i++) {
                $('plantilla').options.length++;
                $('plantilla').options[$('plantilla').options.length - 1].value = selectNodes('@path', NODs.childNodes[i])[0].nodeValue; //getAttribute(NODs.childNodes[i], 'path')
                $('plantilla').options[$('plantilla').options.length - 1].text = selectNodes('@name', NODs.childNodes[i])[0].nodeValue; //getAttribute(NODs.childNodes[i], 'name')
            }

            plantilla_onchange();

            if (cargarConfig) {
                cargarConfiguracion();
            }

        }

        function btnEliminar_onclick() {

            var nombrevista = campos_defs.get_desc('cbGuardado');
            nombrevista = nombrevista.slice(0, nombrevista.indexOf(" ["));

            Dialog.confirm("¿Desea Eliminar la vista: " + nombrevista + "?",
                {
                    width: 350,
                    className: "alphacube",
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    onCancel: function (win) { win.close(); return },
                    onOk: function (win) { vista_eliminar(); win.close() }
                });
        }

        function vista_eliminar() {

            nvFW.error_ajax_request('ABMReportes.aspx', {
                parameters: {
                    accion: 'eliminarvista',
                    nro_save: campos_defs.get_value("cbGuardado")
                },
                onSuccess: function (err, transport) {
                    campos_defs.clear_list('cbGuardado');
                    campos_defs.set_value('cbGuardado', '');
                    if (err.numError != 0)
                        alert(err.mensaje);
                }
            });

        }

        function btnGuardarComo_onclick() {

            if (campos_defs.get_value('nro_vista') == '') {
                alert('Debe seleccionar una vista antes de guardar.');
                return;
            }

            var desc = '';
            var strHTML = '';
            var nro_save = 0;

            if (nvFW.tienePermiso('permisos_administrador_reportes', 2)) {
                strHTML = "<b>Guardar como:</b><div style='width:100%' id='divNC'><br/><input id='vista_a_guardar' style='width:50%' value='" + desc + "' /><br><br><input type='radio' style='cursor: pointer' name='privado' value='1' checked>Privada<input type='radio' style='cursor: pointer' name='privado' value='0'>Publica</div>";
            } else {
                strHTML = "<b>Guardar como:</b><div style='width:100%' id='divNC'><br/><input id='vista_a_guardar' style='width:50%' value='" + desc + "' /><br><br><input type='radio' style='cursor: pointer' name='privado' value='1' checked disabled>Privada<input type='radio' style='cursor: pointer' name='privado' value='0' disabled>Publica</div>";
            }

            Dialog.confirm(strHTML,
                {
                    width: 350,
                    className: "alphacube",
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    onCancel: function (win) { win.close(); return },
                    onOk: function (win) {
                        if ($('vista_a_guardar').value != "") {

                            var privado = 0;
                            if (document.getElementsByName('privado')[0].checked)
                                privado = document.getElementsByName('privado')[0].value;

                            GuardarVista($('vista_a_guardar').value, privado, nro_save)
                        }
                        else {
                            alert("Ingrese el nombre de la vista")
                            return
                        }
                        win.close()
                    }
                });

        }

        function btnGuardar_onclick() {

            if (campos_defs.get_value('nro_vista') == '') {
                alert('Debe seleccionar una vista antes de guardar.');
                return;
            }

            if (campos_defs.getRS('cbGuardado').recordcount == 0 || campos_defs.get_value('cbGuardado') == '')
                btnGuardarComo_onclick();
            else {

                var nro_save;
                if (campos_defs.get_value('cbGuardado') != '')
                    nro_save = campos_defs.get_value('cbGuardado');

                var rs = new tRS();
                rs.open(nvFW.pageContents.filtro_rptadmin_saves, "", "<nro_save type='igual'>'" + campos_defs.get_value('cbGuardado') + "'</nro_save>");
                var desc = rs.getdata('vista');
                var vistaprivada = rs.getdata('privado');

                var strHTML = '';

                if (nvFW.tienePermiso('permisos_administrador_reportes', 2)) {
                    strHTML = "<b>La vista ya existe.\n¿Desea sobreescribirla?</b><div style='width:100%' id='divNC'><br/><input id='vista_a_guardar' style='width:50%' value='" + desc + "' /><br><br><input type='radio' style='cursor: pointer' name='privado' value='1'>Privada<input type='radio' style='cursor: pointer' name='privado' value='0'>Publica</div>";
                } else {
                    if (vistaprivada == 'False') {
                        alert('No tiene permisos para modificar una vista publica.');
                        return;
                    }
                    strHTML = "<b>La vista ya existe.\n¿Desea sobreescribirlo?:</b><div style='width:100%' id='divNC'><br/><input id='vista_a_guardar' style='width:50%' value='" + desc + "' /><br><br><input type='radio' name='privado' value='1' style='cursor: pointer' disabled>Privada<input type='radio' style='cursor: pointer' name='privado' value='0' disabled>Publica</div>";
                }

                Dialog.confirm(strHTML,
                    {
                        width: 350,
                        className: "alphacube",
                        okLabel: "Aceptar",
                        cancelLabel: "Cancelar",
                        onCancel: function (win) { win.close(); return },
                        onShow: function (win) {

                            if (vistaprivada == 'True')
                                document.getElementsByName('privado')[0].checked = true;
                            else document.getElementsByName('privado')[1].checked = true;
                        },
                        onOk: function (win) {
                            if ($('vista_a_guardar').value != "") {

                                var privado = 0;
                                if (document.getElementsByName('privado')[0].checked)
                                    privado = document.getElementsByName('privado')[0].value;

                                GuardarVista($('vista_a_guardar').value, privado, nro_save);
                            }
                            else {
                                alert("Ingrese el nombre de la vista");
                                return;
                            }
                            win.close();
                        }
                    });
            }

        }


        function GuardarVista(nombrevista, privado, nro_save) {
            var strXML = filtro_XML('', $('toprows').value);
            var xmlconfig = guardarXMLConfig();

            if (xmlconfig == 'error') {
                alert('La <b>cantidad de filas</b> y el <b>Nro. de pagina</b> no pueden ser campos vacios.');
                return;
            }

            var r = RegExp("<select", "ig");
            var criterio = strXML.replace('<select', '<select nombre_vista="' + nombrevista + '" ');

            nvFW.error_ajax_request('ABMReportes.aspx', {
                parameters: {
                    accion: 'guardarvista',
                    criterio: criterio,
                    xmlconfig: xmlconfig,
                    privado: privado,
                    nro_save: nro_save,
                    nro_vista: campos_defs.get_value('nro_vista')
                },
                onSuccess: function (err, transport) {
                    campos_defs.clear_list('cbGuardado');
                    campos_defs.set_value('cbGuardado', '');
                    if (err.numError != 0)
                        alert(err.mensaje);
                }
            })
        }


        var win;
        var objScriptEditar;
        

        function VerificarValor_onchange() {
            if ($('toprows').value > 100 && $('percent').checked == true) {
                alert("Los valores porcentuales deben estar entre 0 y 100.");
                $('toprows').value = "100";
                return;
            }
        }

        function div_mostrar(nombre) {
            var objDiv = $(nombre);
            if (objDiv.getStyle('display') == 'block')
                objDiv.hide();
            else
                objDiv.show();
            window_onresize();
        }


        function nro_operatoria_onfocus() {
            if ($('nro_operatoria').options.length == 0)
                cargar_cbCodigo($('nro_operatoria'), 'operatorias', 'nro_operatoria', 'operatoria', '', 'operatoria', 1, 1);
        }

        function operador_onfocus() {
            if ($('operador').options.length == 0)
                cargar_cbCodigo($('operador'), 'operadores', 'operador', 'nombre_operador', '', 'nombre_operador', 1, 1);
        }

        function nro_cobro_onfocus() {
            if ($('nro_cobro').options.length == 0)
                cargar_cbCodigo($('nro_cobro'), 'cobro', 'cobro', 'detalle', '', 'detalle', 1, 1);
        }

        var iframe_h;
        function window_onresize() {

            //var dif = Prototype.Browser.IE ? 5 : 2
            var body_h = $$('body')[0].getHeight()

            var tbTextareaFiltroWhere_h = $('tbTextareaFiltroWhere').getHeight();
            //var tbTextareaOrden_h = $('tbTextareaOrden').getHeight();
            var tbSalidaTipo_h = $('tbSalidaTipo').getHeight();
            var tbConfiguracion_h = $('tbConfiguracion').getHeight();
            var vMenuSelect_h = $('vMenuSelect').getHeight();

            var tbSelect_h = tbConfiguracion_h + tbSalidaTipo_h + tbTextareaFiltroWhere_h// + tbTextareaOrden_h;
            $('tbSelect').setStyle({ height: tbSelect_h + 30 });
            $('campos').setStyle({ height: tbSelect_h });
            $('resultado').setStyle({ height: tbSelect_h });

            var divMenuSelect_h = tbSelect_h + vMenuSelect_h + 30;
            $('divMenuSelect').setStyle({ height: divMenuSelect_h });

            var vMenuGral = $('vMenuGral').getHeight();
            var divGral_h = $('divGral').getHeight();

            iframe_h = body_h - divMenuSelect_h - vMenuGral - divGral_h;

        }

        function sel_metodo(modo) {

            switch (modo) {
                case 1:
                    $("tdReportes").hide();
                    $("tdPlantillas").show();
                    $("divBtnVer").show();
                    $("divBtnExcelxlsx").hide();
                    $("divBtnImprimir").hide();
                    $('tdExcelxlsx').hide();
                    break;
                case 2:
                    $("tdReportes").show();
                    $("tdPlantillas").hide();
                    $("divBtnVer").hide();
                    $("divBtnExcelxlsx").hide();
                    $("divBtnImprimir").show();
                    $('tdExcelxlsx').hide();
                    break;
                case 3:
                    $('tdExcelxlsx').show();
                    $('divBtnExcelxlsx').show();
                    $("tdReportes").hide();
                    $("tdPlantillas").hide();
                    $("divBtnVer").hide();
                    $("divBtnImprimir").hide();
            }


        }

        function paginar_resultado() {
            if ($('chckPaginar').checked) {
                $('cant_filas').disabled = false;
                $('nro_pag').disabled = false;
                $('cant_filas').value = 50;
                $('nro_pag').value = 1;
            } else {
                $('cant_filas').value = '';
                $('nro_pag').value = '';
                $('cant_filas').disabled = true;
                $('nro_pag').disabled = true;
            }
        }

        function cargarConfiguracion() {

            cargarConfig = false;

            var objXMLConfig = new tXML();
            if (xmlconfig != '' && objXMLConfig.loadXML(xmlconfig)) {
                xmlconfig = '';
            } else {
                xmlconfig = '';
                $('chckPaginar').checked = false;
                paginar_resultado();
                return;
            }

            //paginacion
            if (objXMLConfig.selectSingleNode('config/paginacion') != null) {
                var chckPaginar = objXMLConfig.selectNodes('config/paginacion/@chckPaginar')[0].nodeValue;
                var cant_filas = objXMLConfig.selectNodes('config/paginacion/@cant_filas')[0].nodeValue;
                var nro_pag = objXMLConfig.selectNodes('config/paginacion/@nro_pag')[0].nodeValue;

                $('chckPaginar').checked = chckPaginar;
                paginar_resultado();
                $('cant_filas').value = cant_filas;
                $('nro_pag').value = nro_pag;
            } else {
                $('chckPaginar').checked = false;
                paginar_resultado();
            }

            //plantilla
            if (objXMLConfig.selectSingleNode('config/plantilla') != null) {
                var nombre_plantilla = objXMLConfig.selectNodes('config/plantilla/@nombre_plantilla')[0].nodeValue;
                var cb_contenttype = objXMLConfig.selectNodes('config/plantilla/@cb_contenttype')[0].nodeValue;

                $('plantilla').value = nombre_plantilla;
                $("cb_contenttype").value = cb_contenttype;

                plantilla_onchange();
            }

            //reporte
            if (objXMLConfig.selectSingleNode('config/reporte') != null) {
                var nombre_reporte = objXMLConfig.selectNodes('config/reporte/@nombre_reporte')[0].nodeValue;
                var cb_contenttype_reporte = objXMLConfig.selectNodes('config/reporte/@cb_contenttype_reporte')[0].nodeValue;

                $("nombre_reporte").value = nombre_reporte;
                $("cb_contenttype_reporte").value = cb_contenttype_reporte;

            }

            if (objXMLConfig.selectSingleNode('config/timeout') != null) {
                $('timeout').value = objXMLConfig.selectNodes('config/timeout/@valor')[0].nodeValue;
            }

            //metodo plantilla/reporte (plantilla por defecto)
            if (objXMLConfig.selectSingleNode('config/metodo') != null) {
                $('btnPlantilla').value = XMLText(objXMLConfig.selectSingleNode('config/metodo'));
                sel_metodo($('btnPlantilla').selectedIndex + 1);
            } else {
                $('btnPlantilla').value = 'Plantilla'
                sel_metodo(1);
            }

        }

        function guardarXMLConfig() {

            var xmlconfig = '';

            if ($('chckPaginar').checked) {
                if ($('cant_filas').value != '' && $('nro_pag').value != '')
                    xmlconfig += "<paginacion chckPaginar='" + $('chckPaginar').checked + "' cant_filas='" + $('cant_filas').value + "' nro_pag='" + $('nro_pag').value + "'></paginacion>"
                else {
                    return 'error';
                }
            }

            if ($('plantilla').options[$('plantilla').selectedIndex].value != '' || $('cb_contenttype').options[$('cb_contenttype').selectedIndex].value != 'html')
                xmlconfig += "<plantilla nombre_plantilla='" + $('plantilla').options[$('plantilla').selectedIndex].value + "' cb_contenttype='" + $('cb_contenttype').options[$('cb_contenttype').selectedIndex].value + "'></plantilla>"

            if (($('reporte').selectedIndex != -1 && $('reporte').selectedIndex != 0) || ($('cb_contenttype_reporte').options[$('cb_contenttype_reporte').selectedIndex].value != 'pdf' && $('reporte').selectedIndex != -1))
                xmlconfig += "<reporte nombre_reporte='" + $('reporte').options[$('reporte').selectedIndex].value + "' cb_contenttype_reporte='" + $('cb_contenttype_reporte').options[$('cb_contenttype_reporte').selectedIndex].value + "'></reporte>"

            if ($('timeout').value != '' && $('timeout').value != 90) {
                xmlconfig += '<timeout valor="' + $('timeout').value + '"></timeout>'
            }

            if ($('btnPlantilla').value != 'Plantilla')
                xmlconfig += "<metodo>" + $('btnPlantilla').value + "</metodo>";

            if (xmlconfig != '') {
                xmlconfig = '<config>' + xmlconfig + '</config>';
            }

            return xmlconfig;

        }


        function ABM_reportes() {

            if (campos_defs.get_value('nro_vista') == '') {
                alert('Debe seleccionar una vista.');
                return;
            }

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 8)) {
                alert('No posee permisos para agregar reportes.');
                return;
            } else {

                var url = '/FW/administrador_reporte/importar_reporte.aspx?sp=' + 1 + '&nombre_vista=' + nombre_vista;

                var Parametros = new Array();
                var readonly = false;
                Parametros["nro_credito"] = 0;
                Parametros["filein"] = "";
                if (readonly == 'False')
                    Parametros["nro_archivo"] = 0;

                window.top.documento = window.top.nvFW.createWindow({
                    className: 'alphacube',
                    url: url,
                    title: '<b>Agregar Reporte</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 700,
                    height: 200,
                    onShow: function () {
                        window.top.documento.returnValue = Parametros
                    },
                    onClose: abmdocumentos_return
                });

                window.top.documento.showCenter(true)
            }

        }

        function abmdocumentos_return(win) {
            //if (typeof (win.returnValue) == 'string') {
            if (typeof win.options.userData.success != 'undefined' && win.options.userData.success) {
                reportes_cargar();
                plantillas_cargar();
            }
            if (win.returnValue != '') {
                parent.btnMostrarArchivos_onclick();
            }
        }

        function mostrar_filtroWhere() {
            if ($('checkFiltro').checked)
                $('textareaFiltroWhere').show();
            else $('textareaFiltroWhere').hide();
            window_onresize();
            var ventanaIframe = ObtenerVentana('frmFiltros');
            if (ventanaIframe.onresize != null)
                ventanaIframe.onresize();
        }
        
        //function mostrar_orden() {
        //    if ($('checkOrden').checked)
        //        $('textareaOrden').show();
        //    else $('textareaOrden').hide();
        //    window_onresize();
        //    var ventanaIframe = ObtenerVentana('frmFiltros');
        //    if (ventanaIframe.onresize != null)
        //        ventanaIframe.onresize();
        //}


        function ABM_vistas() {

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 9)) {
                alert('No posee permisos para agregar vistas.')
                return
            }

            window_ABMvistas = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/FW/administrador_reporte/rptadmin_ABM_vistas.aspx',
                title: '<b>ABM Vistas</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 1000,
                height: 400,
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) {
                        campos_defs.clear_list('nro_vista');
                        campos_defs.clear_list('conexion');
                        campos_defs.set_first('conexion');
                        if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                            ventanaFiltros.filtros_habilitar();
                    }
                }
            });

            window_ABMvistas.showCenter(true)

        }


        function vista_actualizar_campos() {

            var nro_vista = campos_defs.get_value('nro_vista') == '' ? 0 : campos_defs.get_value('nro_vista');

            if (nro_vista == 0)
                return

            $('campos').options.length = 0


            nvFW.bloqueo_activar($(document.body), 'cargar', '<table class="tb1"><tr><td>Cargando...</td><td><img id="btnCancelRS" title="Cancelar" style="cursor: pointer;" src="/FW/image/icons/cancelar.png"/></td></tr></table>');

            //VERIFICO VALOR DE VISTA_COLUMNAS, SI VISTA_COLUMNAS = true, EXISTE LA VISTA EN LA BASE PARA CARGAR LAS COLUMNAS, SI NO, SELECT TOP 0
            var indice = 0;
            if (campos_defs.items['nro_vista'].sin_seleccion)
                indice = 1;

            var vista_columnas = false;
            if (nro_vista > 0)
                vista_columnas = campos_defs.items['nro_vista'].rs.data[campos_defs.items['nro_vista'].input_select.options.selectedIndex - indice]['vista_columnas'];

            var rs = new tRS();
            rs.async = true;

            if (vista_columnas) { //SI EXISTE VISTA COLUMNAS

                var strXML = nvFW.pageContents.filtroColumnas;
                var parametrosFiltroColumnas = '<criterio><params nombre_vista="' + nombre_vista + '" conexion="' + campos_defs.get_value('conexion') + '" /></criterio>';

                rs.onComplete = function () {

                    var i
                    var j
                    var strCampo
                    var oOption

                    vista_cacheCampos[nro_vista] = { campos: [] };

                    while (!rs.eof()) {

                        if (rs.getdata('columna') != undefined) {

                            strCampo = rs.getdata('columna')
                            for (j = 0; j < $('campos').options.length; j++)
                                if (strCampo.toLowerCase() < $('campos').options[j].text.toLowerCase())
                                    break
                            oOption = document.createElement("OPTION")
                            $('campos').options.add(oOption, j)
                            oOption.innerText = strCampo

                            vista_cacheCampos[nro_vista].campos.push(strCampo);
                        }

                        rs.movenext();
                    }

                    if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                        ventanaFiltros.filtros_habilitar();

                    if (flagVistasGuardadas_onchange && nro_vista != 0) {
                        CargarFiltroXML();
                        flagVistasGuardadas_onchange = false;
                    }
                    nvFW.bloqueo_desactivar(null, 'cargar');
                }

                rs.open(strXML, "", "", "", parametrosFiltroColumnas);

            } else { //SELECT TOP 0                    

                var strXML = filtro_XML('*', 0, true)

                rs.onComplete = function () {

                    var i
                    var j
                    var strCampo
                    var oOption

                    vista_cacheCampos[nro_vista] = { campos: [] };

                    rs.fields.each(function (arreglo, index) {

                        if (arreglo['name'] != undefined) {

                            strCampo = arreglo['name']
                            for (j = 0; j < $('campos').options.length; j++)
                                if (strCampo.toLowerCase() < $('campos').options[j].text.toLowerCase())
                                    break
                            oOption = document.createElement("OPTION")
                            $('campos').options.add(oOption, j)
                            oOption.innerText = strCampo

                            vista_cacheCampos[nro_vista].campos.push(strCampo);
                        }
                    });

                    if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                        ventanaFiltros.filtros_habilitar();

                    if (flagVistasGuardadas_onchange && nro_vista != 0) {
                        CargarFiltroXML();
                        flagVistasGuardadas_onchange = false;
                    }
                    nvFW.bloqueo_desactivar(null, 'cargar');
                }

                rs.open(strXML);

            }

            $('btnCancelRS').observe('click', function () {   //BOTON PARA CANCELAR EL RS.OPEN
                rs.objXML.abort();
                rs = null;
                if (typeof vista_cacheCampos[nro_vista] != 'undefined')
                    vista_cacheCampos[nro_vista] = undefined
                if ((path_filtros != '/FW/enBlanco.htm') && (typeof ventanaFiltros.filtros_habilitar != 'undefined'))
                    ventanaFiltros.filtros_habilitar();
                nvFW.bloqueo_desactivar(null, 'cargar');
            });


        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <form name="frmFiltro" action="" style="width: 100%; height: 100%; overflow: auto">
        <input type="hidden" name="dir_raiz" id="dir_raiz" value="<%= dir_raiz %>" />
        <input type="hidden" name="dir_aplicacion" id="dir_aplicacion" value="<%= dir_aplicacion %>" />
        <input type="hidden" name="nro_vendedor" id="nro_vendedor" />
        <div id="divMenuGral" style="width: 100%; height: 100%; overflow: hidden">
            <script language="javascript" type="text/javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenuGral = new tMenu('divMenuGral', 'vMenuGral');
                Menus["vMenuGral"] = vMenuGral
                Menus["vMenuGral"].alineacion = 'centro';
                Menus["vMenuGral"].estilo = 'A';

                vMenuGral.loadImage('mas', '/FW/image/tTree/mas.jpg')

                Menus["vMenuGral"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Administrador de reportes</Desc></MenuItem>")
                vMenuGral.MostrarMenu()
            </script>
            <table class="tb1" cellspacing="0" cellpadding="0" id="divGral" style="width: 100%">
                <tr>
                    <td>
                        <table class="tb1" id="tbEstaticos" style="width: 100%">
                            <tr>
                                <td style="width: 30%" nowrap>
                                    <div id="divMenuReporteTitulo" style="width: 100%; height: 100%; overflow: hidden"></div>
                                    <script language="javascript" type="text/javascript">

                                        var vMenuReporteTitulo = new tMenu('divMenuReporteTitulo', 'vMenuReporteTitulo');

                                        Menus["vMenuReporteTitulo"] = vMenuReporteTitulo
                                        Menus["vMenuReporteTitulo"].alineacion = 'centro';
                                        Menus["vMenuReporteTitulo"].estilo = 'P';

                                        Menus["vMenuReporteTitulo"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Vistas Guardadas</Desc></MenuItem>")

                                        vMenuReporteTitulo.MostrarMenu()
                                    </script>
                                </td>
                                <td style="width: 40%">
                                    <script>
                                        campos_defs.add('cbGuardado', {
                                            enDB: false,
                                            filtroXML: nvFW.pageContents.filtroCbGuardado,
                                            nro_campo_tipo: 1
                                        })
                                        campos_defs.items['cbGuardado'].onchange = cbVistasGuardadas_onchange;
                                    </script>
                                </td>
                                <td>
                                    <div id="divMenuReporte" style="width: 100%; height: 100%; overflow: hidden"></div>
                                    <script language="javascript" type="text/javascript">
                                        var DocumentMNG = new tDMOffLine;
                                        var vMenuReporte = new tMenu('divMenuReporte', 'vMenuReporte');

                                        Menus["vMenuReporte"] = vMenuReporte
                                        Menus["vMenuReporte"].alineacion = 'centro';
                                        Menus["vMenuReporte"].estilo = 'P';

                                        Menus["vMenuReporte"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnGuardar_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                                        Menus["vMenuReporte"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_como</icono><Desc>Guardar como</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnGuardarComo_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                                        Menus["vMenuReporte"].CargarMenuItemXML("<MenuItem id='3' style='WIDTH: 10%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnEliminar_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")

                                        vMenuReporte.loadImage('guardar', '/FW/image/icons/guardar.png')
                                        vMenuReporte.loadImage('guardar_como', '/FW/image/icons/guardar_como.png')
                                        vMenuReporte.loadImage('eliminar', '/FW/image/icons/eliminar.png')

                                        vMenuReporte.MostrarMenu()
                                    </script>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <div id="divMenuSelect" style="width: 100%; height: 100%; overflow: hidden">
                <script language="javascript" type="text/javascript">
                    var DocumentMNG = new tDMOffLine;
                    var vMenuSelect = new tMenu('divMenuSelect', 'vMenuSelect');
                    Menus["vMenuSelect"] = vMenuSelect
                    Menus["vMenuSelect"].alineacion = 'centro';
                    Menus["vMenuSelect"].estilo = 'A';

                    vMenuSelect.loadImage('mas', '/FW/image/tTree/mas.jpg')
                    vMenuSelect.loadImage('abm', '/FW/image/icons/abm.png')

                    Menus["vMenuSelect"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Configuración de visualización</Desc></MenuItem>")
                    Menus["vMenuSelect"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Agregar Reporte</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ABM_reportes()</Codigo></Ejecutar></Acciones></MenuItem>")
                    Menus["vMenuSelect"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>ABM Vistas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ABM_vistas()</Codigo></Ejecutar></Acciones></MenuItem>")
                    vMenuSelect.MostrarMenu()
                </script>
                <table class="tb1" id="tbSelect">
                    <tr class="tbLabel">
                        <td style="width: 25px">&nbsp;</td>
                        <td style="width: 20%; vertical-align: middle">
                            <%--<input type="checkbox" title="Campos precargados" name="checkCamposPrecargados" id="checkCamposPrecargados" style="cursor: pointer; vertical-align: middle" />--%>Campos<img src="/FW/image/icons/periodicidad.png" style="cursor: pointer; /*margin: 3px 0px 3px 0px; */ float: right;" onclick="return vista_actualizar_campos()" title="Actualizar campos"></td>
                        <%--<td style="width: 20%">Campos</td>--%>
                        <td style="width: 10%">&nbsp;</td>
                        <td style="width: 20%">Resultado</td>
                        <td style="width: 5%">&nbsp;</td>
                        <td>Opciones</td>
                    </tr>
                    <tr>
                        <td style="width: 25px">&nbsp;</td>
                        <td style="vertical-align: top">
                            <select style="width: 100%" size="18" name="campos" id="campos" ondblclick="return campos_ondblclick()"></select>
                        </td>
                        <td style="text-align: center; vertical-align: middle;">
                            <table class="tb1">
                                <tr style="width: 100%">
                                    <td style="width: 25%;"></td>
                                    <td style="width: 50%;">
                                        <div id="divBtnAgregar" style="width: 100%;"></div>
                                    </td>
                                    <td style="width: 25%;"></td>
                                </tr>
                                <tr>
                                    <td style="width: 25%;"></td>
                                    <td style="width: 50%;">
                                        <div id="divBtnQuitar" style="width: 100%;"></div>
                                    </td>
                                    <td style="width: 25%;"></td>
                                </tr>
                                <tr>
                                    <td colspan="3">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="width: 25%;"></td>
                                    <td style="width: 50%;">
                                        <div id="divBtnAgregarTodo" style="width: 100%;"></div>
                                    </td>
                                    <td style="width: 25%;"></td>
                                </tr>
                                <tr>
                                    <td style="width: 25%;"></td>
                                    <td style="width: 50%;">
                                        <div id="divBtnQuitarTodo" style="width: 100%;"></div>
                                    </td>
                                    <td style="width: 25%;"></td>
                                </tr>
                            </table>
                        </td>
                        <td style="vertical-align: top">
                            <select style="width: 100%" size="18" name="resultado" id="resultado" ondblclick="return resultado_ondblclick()"></select>
                        </td>
                        <td style="text-align: center; vertical-align: middle">
                            <table style="width: 50%">
                                <tr>
                                    <td>
                                        <div id="divBtnSubir" style="width: 100%"></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="divBtnBajar" style="width: 100%"></div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="text-align: center; vertical-align: top !important">
                            <table class='tb1' id="tbConfiguracion">
                                <tr>
                                    <td colspan="4">
                                        <table class='tb1'>
                                            <tr>
                                                <td style="width: 10%" class="Tit1">Conexión:</td>
                                                <td style="width: 25%">
                                                    <script>
                                                        campos_defs.add("conexion", {
                                                            enDB: false,
                                                            nro_campo_tipo: 1,
                                                            filtroXML: nvFW.pageContents.filtro_conexion,
                                                            mostrar_codigo: false
                                                        });
                                                    </script>
                                                </td>
                                                <td style="width: 10%" class="Tit1">Vistas:</td>
                                                <td>
                                                    <script>
                                                        campos_defs.add("nro_vista", {
                                                            enDB: false,
                                                            nro_campo_tipo: 1,
                                                            filtroXML: nvFW.pageContents.filtroVistas,
                                                            depende_de: 'conexion',
                                                            depende_de_campo: 'conexion',
                                                            mostrar_codigo: false
                                                        });
                                                        campos_defs.items['nro_vista'].onchange = vista_onchange;
                                                    </script>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap style="text-align: left" colspan="3">&nbsp;Limitar a&nbsp;<input name="toprows" id="toprows" size="2" value="200" onkeypress='return valDigito(event)' onchange="return VerificarValor_onchange()" style="text-align: right" />
                                        filas.&nbsp;&nbsp;%:<input type="checkbox" name="percent" id="percent" onclick="return VerificarValor_onchange()" style="vertical-align: middle; cursor: pointer" />&nbsp;&nbsp;-&nbsp;&nbsp;Max.Orden&nbsp;<input name="cont_orden" id="cont_orden" size="1" value="0" onkeypress='return valDigito(event)' style="text-align: right" />
                                        &nbsp;&nbsp;-&nbsp;&nbsp;Timeout:&nbsp;<input name="timeout" id="timeout" value="90" onkeypress='return valDigito(event)' style="width: 40px; text-align: right" />
                                        Seg.</td>
                                </tr>
                                <tr>
                                    <td style="width: 50%" nowrap>&nbsp;Paginar:<input type="checkbox" name="chckPaginar" id="chckPaginar" onchange="return paginar_resultado()" style="vertical-align: middle; cursor: pointer" />
                                        &nbsp;Cant. Filas:  
                                                                <input name="cant_filas" id="cant_filas" size="2" value="" onkeypress='return valDigito(event)' style="text-align: right" />
                                        &nbsp; Nro. Pagina:  
                                                                <input name="nro_pag" id="nro_pag" size="2" value="" onkeypress='return valDigito(event)' style="text-align: right" />&nbsp;
                                    </td>
                                    <td style="width: 25%">
                                        <div id="divBtnXML_Portapapeles"></div>
                                    </td>
                                    <td style="width: 25%">
                                        <div id="divBtnSQL_Portapapeles"></div>
                                    </td>
                                </tr>
                            </table>
                            <table class="tb1" id="tbTextareaFiltroWhere">
                                <tr class="tbLabel">
                                    <td style="vertical-align: middle">
                                        <input type="checkbox" title="Agregar filtroWhere" name="checkFiltro" id="checkFiltro" onclick="return mostrar_filtroWhere()" style="vertical-align: middle; cursor: pointer" />FiltroWhere</td>
                                </tr>
                                <tr>
                                    <td>
                                        <textarea id="textareaFiltroWhere" style="width: 100%; height: 50px; display: none"></textarea>
                                    </td>
                                </tr>
                            </table>
                           <%-- <table class="tb1" id="tbTextareaOrden">
                                <tr class="tbLabel">
                                    <td style="vertical-align: middle">
                                        <input type="checkbox" title="Agregar orden" name="checkFiltro" id="checkOrden" onclick="return mostrar_orden()" style="vertical-align: middle; cursor: pointer" />Orden</td>
                                </tr>
                                <tr>
                                    <td>
                                        <textarea id="textareaOrden" style="width: 100%; height: 50px; display: none"></textarea>
                                    </td>
                                </tr>
                            </table>--%>
                            <table class="tb1" id="tbSalidaTipo" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td style="width: 15%">
                                        <table class="tb1">
                                            <tr class="tbLabel">
                                                <td>Metodo</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <select name="btnPlantilla" id="btnPlantilla" style="width: 100%" onchange="sel_metodo(this.selectedIndex + 1)">
                                                        <option selected="selected">Plantilla</option>
                                                        <option>Reporte</option>
                                                        <option>Excel</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td id="tdReportes" style="display: none">
                                        <table id="tbRPT" class='tb1'>
                                            <tr class='tbLabel'>
                                                <td style="width: 70%">Reportes</td>
                                                <td style="width: 30%" nowrap>Tipo Contenido</td>
                                            </tr>
                                            <tr>
                                                <td style="width: 70%">
                                                    <select name="reporte" id="reporte" style="width: 100%">
                                                        <option selected="selected">&nbsp;</option>
                                                    </select>
                                                </td>
                                                <td style="width: 30%">
                                                    <select name="cb_contenttype_reporte" id="cb_contenttype_reporte" style="width: 100%">
                                                        <option value="xls">application/vnd.ms-excel</option>
                                                        <option value="doc">application/msword</option>
                                                        <option selected="selected" value="pdf">application/pdf</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td id="tdPlantillas">
                                        <table id="tbReporteExcel" class='tb1'>
                                            <tr class='tbLabel'>
                                                <td style="width: 70%">Plantillas</td>
                                                <td style="width: 30%" nowrap>Tipo Contenido</td>
                                            </tr>
                                            <tr>
                                                <td style="width: 70%">
                                                    <select name="plantilla" id="plantilla" style="width: 100%" onchange="plantilla_onchange()">
                                                        <option selected="selected">&nbsp;</option>
                                                    </select>
                                                </td>
                                                <td style="width: 30%">
                                                    <select name="cb_contenttype" id="cb_contenttype" style="width: 100%">
                                                        <option value="xls">application/vnd.ms-excel</option>
                                                        <option selected="selected" value="html">text/html</option>
                                                        <option value="doc">application/msword</option>
                                                        <option value="xml">text/xml</option>
                                                        <option value="txt">text/plain</option>
                                                        <option value="pdf">application/pdf</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td id="tdExcelxlsx" style="display: none">
                                        <table id="tbReporteExcelxlsx" class='tb1'>
                                            <tr class='tbLabel'>
                                                <td style="width: 70%">Plantillas</td>
                                                <td style="width: 30%" nowrap>Tipo Contenido</td>
                                            </tr>
                                            <tr>
                                                <td style="width: 70%">
                                                    <select name="excelxlsx" id="excelxlsx" style="width: 100%" disabled>
                                                        <option selected="selected">&nbsp;</option>
                                                    </select>
                                                </td>
                                                <td style="width: 30%">
                                                    <select name="cb_contenttype_excelxlsx" id="cb_contenttype_excelxlsx" style="width: 100%" disabled>
                                                        <option value="xlsx" selected="selected">application/vnd.ms-excel</option>
                                                    </select>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <div id="divBtnImprimir" style="width: 100%; display: none"></div>
                                        <div id="divBtnVer" style="width: 100%"></div>
                                        <div id="divBtnExcelxlsx" style="width: 100%; display: none"></div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
            <div id="divFiltros" style="width: 100%;">
                <table class="tb1" id="tbFrmFiltros" cellpadding="0" cellspacing="0" style="height: 100%">
                    <tr>
                        <td style="width: 100%; vertical-align: top;" id="tdFrmFiltros">
                            <iframe name="frmFiltros" id="frmFiltros" style="width: 100%; height: 100%; overflow: hidden; border: none;"></iframe>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
    <%--<form name="frmFiltro2" action="">
        <input type="hidden" name="nro_vendedor" />
        <!--*************************************************-->
        <!--*************************************************-->
        <!--*************************************************-->
        <!--<input name="btnBuscar" id="btnBuscar" type="button" style="width: 100%" value="Buscar"  onclick="return btnBuscar_onclick()" />-->
        <iframe style="width: 100%" src="enBlanco.htm" name="frmCreditos" id="frmCreditos"></iframe>
    </form>
    <textarea name="strSQL" id="strSQL" style="display: none" rows='1' cols='1'></textarea>
    <form name="frmReporte" id="frmReporte" method="post" action="reportViewer\mostrarReporte.aspx"
        target="_blanck">
        <input type="hidden" name="path_reporte" value="" />
        <input type="hidden" name="target" value="" />
        <input type="hidden" name="ContectType" value="" />
        <input type="hidden" name="salida_tipo" value="" />
        <input type="hidden" name="filtroXML" value="" />
    </form>
    <form name="frmExportar" id="Form1" method="post" action="reportViewer\ExportarReporte.aspx"
        target="_blanck">
        <input type="hidden" name="path_xsl" value="" />
        <input type="hidden" name="target" value="" />
        <input type="hidden" name="ContectType" value="" />
        <input type="hidden" name="salida_tipo" value="" />
        <input type="hidden" name="filtroXML" value="" />
    </form>--%>
</body>
</html>
