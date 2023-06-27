<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>

<%

    Dim nro_ref As String = nvFW.nvUtiles.obtenerValor("nro_ref2", "0")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    
    Dim procedimiento As String = "rm_ref_abm_v4"
    If modo.ToUpper() = "AUTOGUARDADO" Then
        procedimiento = "rm_ref_autoguardado_abm"
        modo = "M"
    End If
    
    
    If modo.ToUpper() = "M" Then
        Dim err As New nvFW.tError
        
        nro_ref = nvFW.nvUtiles.obtenerValor("nro_ref", "")
        Dim referencia As String = nvFW.nvUtiles.obtenerValor("referencia", "")
        Dim id_ref_auto As String = nvFW.nvUtiles.obtenerValor("id_ref_auto", "")
        Dim ref_no_guardada As String = nvFW.nvUtiles.obtenerValor("ref_no_guardada", "")
        Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

        
        Try
            Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand(procedimiento, ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app, CommandTimeout:=1500)

            If procedimiento = "rm_ref_autoguardado_abm" Then
                Dim BinaryData() As Byte = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(HttpUtility.UrlDecode(strXML))
                Cmd.addParameter("@strXML0", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, BinaryData.Length, BinaryData)
                Cmd.addParameter("@id_ref_auto", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, id_ref_auto.Length, id_ref_auto)
                Cmd.addParameter("@referencia", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 255, referencia)
                Cmd.addParameter("@nro_ref", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, nro_ref.Length, nro_ref)
            Else
                Cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            End If

            Dim rs As ADODB.Recordset = Cmd.Execute()

            If Not rs.EOF Then
                If procedimiento = "rm_ref_autoguardado_abm" Then
                    id_ref_auto = rs.Fields("id_ref_auto").Value
                    err.params("id_ref_auto") = id_ref_auto
                    err.numError = 0
                    err.mensaje = id_ref_auto
                Else
                    nro_ref = rs.Fields("nro_ref").Value
                    err.params("nro_ref") = nro_ref
                    err.numError = rs.Fields("numError").Value
                    err.mensaje = rs.Fields("mensaje").Value
                    err.debug_desc = rs.Fields("debug_desc").Value
                    err.debug_src = rs.Fields("debug_src").Value
                End If
            End If

            nvDBUtiles.DBCloseRecordset(rs)
        Catch e As Exception
            err.parse_error_script(e)
            err.mensaje = "Ocurrió un error con el Procedimiento Almacenado de Referencias"
        End Try

        err.response()
    End If
    
    
    
    If modo = "" Then
        
        Dim op As nvFW.nvSecurity.tnvOperador = nvFW.nvApp.getInstance.operador
        Dim operador As Integer = op.operador
        Dim nombre_operador As String = op.nombre_operador
        Dim nombre_operador_origen As String = op.login
        
        Dim ref_editar As Integer = 0
        Dim ref_eliminar As Integer = 0
        
        If nro_ref <> "" Then
            Dim rsRef As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("SELECT DISTINCT ref_editar, ref_eliminar FROM verReferencia WHERE nro_ref=" & nro_ref)
            If Not rsRef.EOF Then
                ref_editar = rsRef.Fields("ref_editar").Value
                ref_eliminar = rsRef.Fields("ref_eliminar").Value
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rsRef)
        End If
        
        Me.contents("nro_operador") = operador
        Me.contents("nombre_operador") = nombre_operador
        Me.contents("nombre_operador_origen") = nombre_operador_origen
    
        Me.contents("filtro_referencia_cargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='referencias'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
        Me.contents("filtro_documento_cargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>nro_ref_doc, ref_doc_version, doc_orden, ref_doc_titulo, nro_ref_estado, ref_estado, nro_ref_doc_tipo, ref_doc_tipo, ref_doc_version, id_ref_doc</campos><filtro><ref_doc_activo type='igual'>1</ref_doc_activo></filtro><orden>doc_orden</orden></select></criterio>")
        Me.contents("filtro_verRef_doc_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_doc_tipos'><campos>distinct nro_ref_doc_tipo as id, ref_doc_tipo as [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
        Me.contents("filtro_ref_estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_estados'><campos>distinct nro_ref_estado as id, ref_estado as [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
        Me.contents("filtro_dependencia_padre_cargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_doc_dep'><campos>nro_ref_padre,referencia_padre,ref_dep_orden</campos><filtro></filtro><orden>ref_dep_orden</orden><grupo>nro_ref_padre,referencia_padre,ref_dep_orden</grupo></select></criterio>")
        Me.contents("filtro_dependencia_hijo_cargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_doc_dep'><campos>nro_ref,referencia,ref_dep_orden</campos><filtro></filtro><orden>ref_dep_orden</orden><grupo>nro_ref,referencia,ref_dep_orden</grupo></select></criterio>")
        
        Me.contents("filtro_suscripcion_pendiente") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ref_sus_operador'><campos>*,dbo.rm_nro_operador() as operador_actual</campos><filtro></filtro><orden></orden></select></criterio>")
        Me.contents("filtro_tiene_permiso") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores_operador_tipo'><campos>tipo_operador</campos></select></criterio>")
        Me.contents("filtro_tiene_permiso2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.ref_obtener_permisos' CommantTimeOut='1500'><parametros><nro_ref DataType='int'>%p_s_nro_ref2%</nro_ref><vista DataType='int'>%p_vista%</vista></parametros></procedure></criterio>")
        
        Me.contents("filtro_verificar_autoguardado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ref_autoguardado'><campos>*</campos><filtro></filtro></select></criterio>")
        Me.contents("id_ref_auto") = nvFW.nvUtiles.obtenerValor("id_ref_auto", "")
        Me.contents("ref_no_guardada") = nvFW.nvUtiles.obtenerValor("ref_no_guardada", "")
        Me.contents("nro_ref") = nro_ref
    End If
    
    
    Me.addPermisoGrupo("permisos_referencias")
    Me.addPermisoGrupo("permisos_web")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Referencias ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>
    <% = Me.getHeadInit() %>
    <style type="text/css">
        .tr_cel TD
        {
            background-color: #9ecbf7 !important;
        }
        .tr_cel_click TD
        {
            background-color: #BDD3EF !important;
            color: #0000A0 !important;
        }
    </style>
    <script type="text/javascript">

        var nro_ref = nvFW.pageContents.nro_ref
        var referencia = []
        var myWin = nvFW.getMyWindow()
        var existen_modificaciones = false
        var cerrar_win_por_codigo = false
        var win_divMenuContent = ObtenerVentana('divMenu_content')
        var win_frameRef = ObtenerVentana('frame_ref')


        var nro_operador = nvFW.pageContents.nro_operador
        var nombre_operador = nvFW.pageContents.nombre_operador
        var nombre_operador_origen = nvFW.pageContents.nombre_operador_origen

       

        var s_orden; // orden seleccionado
        var s_radio; // radio seleccionado


        function window_onload() {


            nvFW.enterToTab = false;

            vMenuDatosRefDoc1.MostrarMenu()

            campos_defs.items['nro_operador']['onchange'] = nro_operador_onload

            //?? campos_defs.items['nro_ref']['onchange'] = referencia_cargar
            campos_defs.items['nro_ref']['onchange'] = function () {
                s_radio = undefined
                referencia_cargar()
            }

            CKEDITOR.instances.editor.config.basicEntities = false;
            $('nro_ref_desc').hide()
            intervalos_iniciar()

            if (nro_ref != 0) {

                campos_defs.items['nro_ref']['input_hidden'].value = nro_ref


                if (verificar_autoguardado()) {

                    if (ref_no_guardada == "1")
                        referencia_auto_cargar(Autoguardado['xml'])
                    else
                        confirmar_autoguardado()

                } else {

                    // s_radio se seteara en cantidad de docs - 1
                    // se seteara s_orden de acuerdo a s_radio
                    referencia_cargar()
                }

            }
            else {
                //s_orden se setea en undefined
                //s_radio sera 0 ya que no hay documentos
                referencia_nueva()
            }

            window_onresize()
            $('referencia').focus()
        }


        function window_onresize() {
            try {
                var body_h = $$('body')[0].getHeight()
                var divMenuDatosRef_h = $('divMenuDatosRef').getHeight()
                var tbNombreReferencia_h = $('tbNombreReferencia').getHeight()
                var divMenuDatosRefDoc1_h = $('divMenuDatosRefDoc1').getHeight()
                var tbDocs_h = $('tbDocs').getHeight()
                var divDocumentos_h = $('divDocumentos').getHeight()

                var height = body_h - (divMenuDatosRef_h + divMenuDatosRefDoc1_h + divDocumentos_h + tbNombreReferencia_h + tbDocs_h)
                var editor = CKEDITOR.instances['editor'];

                if (editor.status != "unloaded")
                    editor.resize('auto', height)
                else {
                    // comprobar cada 100ms si el editor está cargado, solo si falló el IF anterior
                    var editor_onresize = setInterval(function () {
                        if (editor.status != "unloaded") {
                            clearInterval(editor_onresize)
                            editor.resize('auto', height);
                        }
                    }, 100)
                }
            }
            catch (e) { }
        }


        function window_onunload() {

        }




        function referencia_cargar() {

            if (campos_defs.items['nro_ref']['input_hidden'].value != "")
                nro_ref = campos_defs.items['nro_ref']['input_hidden'].value

            var criterio = "<nro_ref type='igual'>" + nro_ref + "</nro_ref>"
            var rs = new tRS();
            rs.open(nvFW.pageContents.filtro_referencia_cargar, '', criterio, '', '')

            if (!rs.eof()) {
                nro_ref = rs.getdata('nro_ref')
                $('referencia').value = rs.getdata('referencia')
                referencia['nro_ref'] = rs.getdata('nro_ref')
                referencia['referencia'] = $('referencia').value
                referencia['nro_ref_estado'] = rs.getdata('nro_ref_estado')
                referencia['id_ref_auto'] = 0

                campos_defs.set_value("nro_ref_estado", rs.getdata('nro_ref_estado'))
                //campos_defs.set_value("nro_ref", rs.getdata('nro_ref'))

                documentos_cargar()
                dependencia_padre_cargar()
                dependencia_hijo_cargar()
            }
            rs = null

            loadSuscriptions()
        }


        function documentos_cargar() {

            referencia['documento'] = []
            var rs = new tRS()
            var i = 0
            var criterio = "<nro_ref type='igual'>" + nro_ref + "</nro_ref>"

            rs.open(nvFW.pageContents.filtro_documento_cargar, '', criterio, '', '')

            while (!rs.eof()) {
                referencia['documento'][i] = {};
                referencia['documento'][i]["nro_ref_doc"] = rs.getdata('nro_ref_doc')
                referencia['documento'][i]["ref_doc_version"] = rs.getdata('ref_doc_version')
                referencia['documento'][i]["orden"] = rs.getdata('doc_orden')
                referencia['documento'][i]["ref_doc_titulo"] = rs.getdata('ref_doc_titulo')
                referencia['documento'][i]["nro_ref_estado_doc"] = rs.getdata('nro_ref_estado')
                referencia['documento'][i]["nro_ref_doc_tipo"] = rs.getdata('nro_ref_doc_tipo')
                referencia['documento'][i]["ref_estado"] = rs.getdata('ref_estado') + ' (' + rs.getdata('nro_ref_estado') + ')'
                referencia['documento'][i]["ref_doc_tipo"] = rs.getdata('ref_doc_tipo') + ' (' + rs.getdata('nro_ref_doc_tipo') + ')'

                referencia['documento'][i]['ref_doc_html'] = nvFW.getFile({
                    accion: 'return',
                    id_ref_doc: rs.getdata('id_ref_doc')
                })

                referencia['documento'][i]['ref_doc_html_original'] = referencia['documento'][i]['ref_doc_html']

                // Mantener estos de titulo, tipo y estado del documento
                referencia['documento'][i]['ref_doc_titulo_original'] = referencia['documento'][i]['ref_doc_titulo']
                referencia['documento'][i]['nro_ref_doc_tipo_original'] = referencia['documento'][i]['nro_ref_doc_tipo']
                referencia['documento'][i]['nro_ref_estado_doc_original'] = referencia['documento'][i]['nro_ref_estado_doc']

                i++
                rs.movenext()
            }

            rs = null

            //?? s_radio = referencia['documento'].length - 1
            if (s_radio == undefined) {
                s_radio = referencia['documento'].length - 1
            }

            documentos_dibujar()
        }



        function documentos_dibujar() {

            var divDocumentos = $('divDocumentos')
            divDocumentos.innerHTML = ""

            var strHTML = "<table class='tb1 highlightOdd highlightTROver'>"

            var indice_radio = 0

            var strCamposDefsAdd = ""
            var strCamposDefsSet = ""
            var strCamposDefsOnClick = ""

            referencia.documento.each(function (documento, index) {
                documento['indice_radio'] = -1

                if (parseInt(documento.nro_ref_doc) >= 0) {
                    documento['indice_radio'] = indice_radio


                    strHTML += '<tr id="tr_seleccion_' + index + '">'
                    strHTML += '<td style="text-align: center; width: 50px;">'
                    strHTML += '<input type="radio" name="rdocumento" id="' + documento.nro_ref_doc + '" value="' + index + '" onclick="return rdocumento_onclick(' + indice_radio + ', ' + index + ')" style="cursor: pointer; border: none;" title="Seleccionar" /></td>'
                    strHTML += '<td id="td_ref_doc_titulo_' + index + '"></td>'
                    strHTML += '<td id="td_ref_doc_tipo_' + index + '" style="width: 150px;"></td>'
                    strHTML += '<td id="td_ref_estado_' + index + '" style="width: 150px;"></td>'
                    strHTML += '<td style="width: 40px; text-align: center;"><img alt="eliminar" src="/FW/image/icons/eliminar.png" onclick="return documento_eliminar(' + indice_radio + ',' + index + ')" style="cursor: pointer;" title="Eliminar" /></td>'
                    strHTML += '<td style="width: 40px; text-align: center;"><img alt="subir" src="/FW/image/icons/up_a.png" onclick="return documento_subir(' + indice_radio + ',' + index + ')" style="cursor: pointer; position: relative; top: -5px; left: 9px;" title="Subir" />'
                    strHTML += '&nbsp;&nbsp;<img alt="bajar" src="/FW/image/icons/down_a.png" onclick="return documento_bajar(' + indice_radio + ',' + index + ')" style="cursor: pointer; position: relative; top: 5px; left: -9px;" title="Bajar" /></td>'
                    strHTML += '<input type="hidden" name="nro_ref_doc_' + index + '" id="nro_ref_doc_' + index + '" value="' + documento.nro_ref_doc + '" />'
                    strHTML += '<input type="hidden" name="nro_ref_doc_tipo_' + index + '" id="nro_ref_doc_tipo_' + index + '" value="' + documento.nro_ref_doc_tipo + '" />'
                    strHTML += '<input type="hidden" name="nro_ref_estado_doc_' + index + '" id="nro_ref_estado_doc_' + index + '" value="' + documento.nro_ref_estado_doc + '" />'
                    strHTML += '</tr>'

                    // Carga de los campos defs correspondientes
                    strCamposDefsAdd += "campos_defs.add('ref_doc_titulo_" + index + "', { enDB: false, nro_campo_tipo: 104, target: 'td_ref_doc_titulo_" + index + "' });campos_defs.add('ref_doc_tipo_" + index + "', { enDB: false, nro_campo_tipo: 1, target: 'td_ref_doc_tipo_" + index + "', filtroXML: nvFW.pageContents.filtro_verRef_doc_tipos });campos_defs.add('ref_estado_" + index + "', { enDB: false, nro_campo_tipo: 1, target: 'td_ref_estado_" + index + "', filtroXML: nvFW.pageContents.filtro_ref_estados });"
                    // Seteo de valores de los campos defs definidos
                    strCamposDefsSet += "campos_defs.set_value('ref_doc_titulo_" + index + "', '" + (documento.ref_doc_titulo || 'Documento nuevo') + "');campos_defs.set_value('ref_doc_tipo_" + index + "', $('nro_ref_doc_tipo_" + index + "').value);campos_defs.set_value('ref_estado_" + index + "', $('nro_ref_estado_doc_" + index + "').value);"
                    // Setear eventos onclick()
                    strCamposDefsOnClick += "$('ref_doc_titulo_" + index + "').onclick = seleccionarRadioFila;campos_defs.items['ref_doc_tipo_" + index + "'].input_button.addEventListener('click', seleccionarRadioFila, true);campos_defs.items['ref_estado_" + index + "'].input_button.addEventListener('click', seleccionarRadioFila, true);"

                    indice_radio = indice_radio + 1
                }
            })

            strHTML += "</table>"
            divDocumentos.insert({ top: strHTML })

            if (strCamposDefsAdd != "")
                eval(strCamposDefsAdd)

            if (strCamposDefsSet != "")
                eval(strCamposDefsSet)

            if (strCamposDefsOnClick != "")
                eval(strCamposDefsOnClick)

            // scroll hasta el final
            divDocumentos.scrollTop = divDocumentos.scrollHeight

            if (FrmRef.rdocumento.length > 0)
                FrmRef.rdocumento[s_radio].checked = true
            else
                FrmRef.rdocumento.checked = true

            pintarRadioSeleccionado()
            documento_mostrar_html()
        }


        function pintarRadioSeleccionado() {
            document.getElementsByName("rdocumento").forEach(function (radio) {
                if (radio.checked) {
                    radio.up('tr').addClassName('tr_cel')
                }
                else {
                    radio.up('tr').removeClassName('tr_cel')
                }
            })
        }


        function documento_mostrar_html() {

            for (index in referencia.documento) {
                var documento = referencia.documento[index]
                if (parseInt(documento.nro_ref_doc) >= 0) {
                    if (documento['indice_radio'] == s_radio) {
                        s_orden = index
                        break
                    }
                }
            }

            if (referencia.documento[s_orden])
                CKEDITOR.instances.editor.setData(referencia.documento[s_orden].ref_doc_html)
            else
                CKEDITOR.instances.editor.setData("")
        }


        function seleccionarRadioFila(event) {
            try {
                //documento_actualizar()
                var radio = null

                if (this.campo_def !== undefined)
                    radio = this.input_text.up("table.tb1").up("tr").select("input[type=radio]")[0] //?? acá nunca entra
                else
                    radio = this.up("table.tb1").up("tr").select("input[type=radio]")[0]

                if (!radio.checked)
                    radio.click()

                if (this.id.indexOf("ref_doc_titulo") > -1)
                    this.focus()
            }
            catch (e) { }
        }


        function rdocumento_onclick(radio_index) {

            documento_actualizar()
            s_radio = radio_index
            documentos_dibujar()
            pintarRadioSeleccionado()
        }


        function documento_actualizar() {

            // Si el s_orden no está definido, retorno el control al llamante
            if (s_orden === undefined || s_orden === null) {
                return;
            }

            s_orden = parseInt(s_orden, 10);

            referencia['referencia'] = $('referencia').value;
            referencia['nro_ref_estado'] = campos_defs.items['nro_ref_estado']['input_hidden'].value;

            if (referencia['documento'][s_orden] == undefined) {
                referencia['documento'][s_orden] = {};
            }

            try {
                referencia['documento'][s_orden]["orden"] = s_orden;
                referencia['documento'][s_orden]["ref_doc_titulo"] = campos_defs.get_value('ref_doc_titulo_' + s_orden);
                referencia['documento'][s_orden]["nro_ref_doc_tipo"] = campos_defs.get_value('ref_doc_tipo_' + s_orden);
                referencia['documento'][s_orden]["ref_doc_tipo"] = campos_defs.get_desc('ref_doc_tipo_' + s_orden);
                referencia['documento'][s_orden]["nro_ref_estado_doc"] = campos_defs.get_value('ref_estado_' + s_orden);
                referencia['documento'][s_orden]["ref_estado"] = campos_defs.get_desc('ref_estado_' + s_orden);
                referencia['documento'][s_orden]["ref_doc_html"] = CKEDITOR.instances.editor.getData();
            }
            catch (e) { }
        }


        function dependencia_padre_cargar() {
            referencia['dependencia_padre'] = []
            var rs = new tRS();
            var i = 0
            var fitroWhere = "<nro_ref type='igual'>" + referencia['nro_ref'] + "</nro_ref><NOT><nro_ref_padre type='isnull'></nro_ref_padre></NOT>"
            rs.open(nvFW.pageContents.filtro_dependencia_padre_cargar, '', fitroWhere, '', '')
            while (!rs.eof()) {
                referencia['dependencia_padre'][i] = []
                referencia['dependencia_padre'][i]['nro_ref_padre'] = rs.getdata('nro_ref_padre')
                referencia['dependencia_padre'][i]['referencia_padre'] = rs.getdata('referencia_padre')
                referencia['dependencia_padre'][i]['ref_dep_orden'] = rs.getdata('ref_dep_orden')
                i++
                rs.movenext()
            }
            rs = null
        }


        function dependencia_hijo_cargar() {
            referencia['dependencia_hijo'] = []
            var rs = new tRS();
            var i = 0
            var fitroWhere = "<nro_ref_padre type='igual'>" + referencia['nro_ref'] + "</nro_ref_padre>"
            rs.open(nvFW.pageContents.filtro_dependencia_hijo_cargar, '', fitroWhere, '', '')
            while (!rs.eof()) {
                referencia['dependencia_hijo'][i] = []
                referencia['dependencia_hijo'][i]['nro_ref'] = rs.getdata('nro_ref')
                referencia['dependencia_hijo'][i]['referencia'] = rs.getdata('referencia')
                referencia['dependencia_hijo'][i]['ref_dep_orden'] = rs.getdata('ref_dep_orden')
                i++
                rs.movenext()
            }
            rs = null
        }



        function referencia_nueva() {
            nro_ref = 0
            $('referencia').value = ""
            s_orden = undefined
            $('divDocumentos').innerHTML = ""
            campos_defs.set_value("nro_ref_estado", '1')

            // nueva referencia
            referencia = {};
            referencia['documento'] = []
            referencia['nro_ref'] = 0
            referencia['referencia'] = ''
            referencia['id_ref_auto'] = 0

            dependencia_nueva()
            documento_nuevo()
        }


        function dependencia_nueva() {
            referencia['dependencia_padre'] = []
            referencia['dependencia_hijo'] = []
        }


        function documento_nuevo() {

            if (s_orden || s_orden === 0) {
                documento_actualizar()
            }

            var orden = referencia['documento'].length
            referencia['documento'][orden] = {}
            referencia['documento'][orden]["nro_ref_doc"] = '0' + orden
            referencia['documento'][orden]["orden"] = orden
            referencia['documento'][orden]["ref_doc_titulo"] = ''
            referencia['documento'][orden]["nro_ref_doc_tipo"] = '1'
            referencia['documento'][orden]["ref_doc_tipo"] = orden == 0 ? 'Resumen (1)' : 'Help (2)'
            referencia['documento'][orden]["nro_ref_estado_doc"] = '1'
            referencia['documento'][orden]["ref_estado"] = 'Activado (1)'
            referencia['documento'][orden]["ref_doc_html"] = ''
            referencia['documento'][orden]["ref_doc_version"] = '0'
            referencia['documento'][orden]["ref_doc_html_original"] = ''
            referencia['documento'][orden]['ref_doc_titulo_original'] = ''
            referencia['documento'][orden]['nro_ref_doc_tipo_original'] = '1'
            referencia['documento'][orden]['nro_ref_estado_doc_original'] = '1'


            if (!FrmRef.rdocumento) { // si no hay documentos
                s_radio = 0
            } else {
                if (FrmRef.rdocumento.length) // si hay más de un documento
                    s_radio = FrmRef.rdocumento.length
                else
                    s_radio = 1  // si hay un sólo documento
            }

            rdocumento_onclick(s_radio)
            documento_editar(s_orden)
        }


        function documento_editar(index) {

            // Actualizar todos los datos de la estructura (referencia.documento)
            referencia.documento[index].ref_doc_titulo = $('ref_doc_titulo_' + index).value
            referencia.documento[index].nro_ref_estado_doc = $('nro_ref_estado_doc_' + index).value
            referencia.documento[index].nro_ref_doc_tipo = $('nro_ref_doc_tipo_' + index).value
            referencia.documento[index].ref_estado = $('ref_estado_' + index).value
            referencia.documento[index].ref_doc_tipo = $('ref_doc_tipo_' + index).value
            referencia.documento[index].ref_doc_html_original = referencia.documento[index].ref_doc_html ? referencia.documento[index].ref_doc_html : ''
            referencia.documento[index].ref_doc_html = CKEDITOR.instances.editor.getData()

            campos_defs.focus('ref_doc_titulo_' + index)
        }






        function documento_eliminar(radio_index, orden) {

            if (!FrmRef.rdocumento.length) {
                alert("La referencia debe contar con al menos un documento")
                return
            }

            var titulo = $('ref_doc_titulo_' + orden).value || 'Sin Título';

            nvFW.confirm('¿Está seguro de querer eliminar el documento <b>"' + titulo + '"</b>?',
            {
                width: 350,
                onOk: function (win) {
                    documento_actualizar()
                    documento_eliminar_return(radio_index, orden)
                    win.close()
                },
                onCancel: function (win) {
                    win.close()
                }
            })
        }


        function documento_eliminar_return(radio_index, orden) {

            if (referencia['documento'][orden]['nro_ref_doc'].toString()[0] == "0") {
                referencia['documento'].splice(orden, 1)
            }
            else {
                referencia['documento'][orden]['nro_ref_doc'] = "-" + referencia['documento'][orden]['nro_ref_doc']
            }


            if (radio_index == s_radio) { // si se elimina un doc chequeado
                if (radio_index == FrmRef.rdocumento.length - 1) { // si es el ultimo radio
                    s_radio = s_radio - 1
                }

            } else if (radio_index < s_radio) {
                s_radio = s_radio - 1
            }

            documentos_dibujar()
        }






        function referencia_guardar(cerrar) {

            cerrar = cerrar || false;

            if (referencia['nro_ref'] >= 0) // si es alta/modificacion
            {
                // No es necesario controlar permiso de modificacion, porque no llega a esta pantalla en caso de que no tenga dicho permiso
                // Controla que pueda crear permiso en el raiz
                if (!nvFW.tienePermiso('permisos_referencias', 4) && ((referencia['dependencia_padre'].length) == 0) && (referencia["nro_ref"] == 0)) {
                    alert('No tiene permiso para crear referencias en el raíz')
                    return
                }
            }

            clearInterval(id_interval_120)
            documento_actualizar()
            var strErrorValidar = validar()

            if (strErrorValidar != undefined && parseInt(referencia["nro_ref"]) > -1) {
                alert(strErrorValidar)
                return
            }

            // Asignar el orden correcto a cada documento (tal como se visualiza en pantalla)
            documento_asignar_orden()

            nvFW.error_ajax_request('referencias_abm.aspx',
                {
                    bloq_msg: 'Guardando...',
                    error_alert: false,
                    parameters:
                    {
                        modo: 'M',
                        strXML: generar_xml()
                    },
                    onSuccess: function (err, transport) {
                        nro_ref = err.params['nro_ref'];
                        var es_alta_ref = parseInt(referencia["nro_ref"]) == 0
                        var es_baja_ref = parseInt(referencia["nro_ref"]) < 0

                        if (nro_ref != undefined && nro_ref != '') {
                            myWin.options.userData = nro_ref
                            referencia["nro_ref"] = nro_ref

                            // si se llamo a eliminar referencia, cerrar ventana
                            if (es_baja_ref) {

                                // Recargar el arbol
                                win_divMenuContent.location.href = 'ref_tree.aspx';

                                // Redirigir al HOME
                                win_frameRef.location.href = 'inicio.aspx'

                                cerrar_win_por_codigo = true
                                myWin.close()
                            }
                            else {

                                if (es_alta_ref || force_reload_tree) {
                                    win_divMenuContent.location.href = 'ref_tree.aspx'
                                    force_reload_tree = false
                                }

                                if (cerrar) {

                                    win_divMenuContent.ref_mostrar(nro_ref)
                                    cerrar_win_por_codigo = true
                                    myWin.close()
                                }
                                else {
                                    campos_defs.items['nro_ref']['input_hidden'].value = nro_ref
                                    referencia_cargar()
                                    intervalos_iniciar()
                                }
                            }
                        }
                    },
                    onFailure: function (err) {

                        referencia['nro_ref'] = (referencia['nro_ref'] < 0 ? parseInt(referencia['nro_ref']) * -1 : referencia['nro_ref'])
                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                    }
                });
        }





        function validar() {
            if (referencia['referencia'] == "")
                return "Por favor ingrese la referencia</br>"

            if (referencia['nro_ref_estado'] == "")
                return "Por favor ingrese el estado de referencia</br>"

            var ErrorStr = ""

            referencia['documento'].each(function (documento, index) {
                if (Number(documento['nro_ref_doc']) > 0) {
                    if (documento['ref_doc_titulo'] == "")
                        ErrorStr += "Por favor ingrese el titulo</br>"

                    if (documento['nro_ref_doc_tipo'] == "")
                        ErrorStr += "Por favor ingrese el tipo del documento</br>"

                    if (documento['nro_ref_estado_doc'] == "")
                        ErrorStr += "Por favor ingrese el estado del documento</br>"

                    return (ErrorStr != "" ? ErrorStr : undefined)
                }
            });
        }



        function documento_asignar_orden() {
            var orden = 0
            referencia['documento'].each(function (documento) {
                if (parseInt(documento['nro_ref_doc']) > -1) {
                    documento['orden'] = orden.toString()
                    orden += 1
                }
            })
        }


        function generar_xml(es_autoguardado) {
            es_autoguardado = es_autoguardado || false
            var xmldato = ''
            xmldato = '<?xml version="1.0" encoding="iso-8859-1"?>'
            xmldato += '<referencia nro_ref="' + referencia['nro_ref'] + '"'
            xmldato += ' referencia="' + referencia['referencia'] + '"'
            xmldato += ' nro_ref_estado="' + referencia['nro_ref_estado'] + '"'
            xmldato += ' id_ref_auto="' + referencia['id_ref_auto'] + '">'
            xmldato += '<referencia_dependencia_padres>'

            referencia['dependencia_padre'].each(function (dependencia_p, index_p) {
                xmldato += '<ref_dependencias_padres'
                xmldato += ' nro_ref_padre="' + dependencia_p['nro_ref_padre'] + '"'
                xmldato += ' ref_dep_orden="' + index_p + '"'

                if (es_autoguardado) xmldato += ' referencia_padre="' + dependencia_p['referencia_padre'] + '"'

                xmldato += '/>'
            });

            xmldato += '</referencia_dependencia_padres>'
            xmldato += '<referencia_dependencia_hijos>'

            referencia['dependencia_hijo'].each(function (dependencia_h, index_h) {
                xmldato += '<ref_dependencias_hijos'
                xmldato += ' nro_ref="' + dependencia_h['nro_ref'] + '"'
                xmldato += ' ref_dep_orden="' + index_h + '"'

                if (es_autoguardado)
                    xmldato += ' referencia="' + dependencia_h['referencia'] + '"'

                xmldato += '/>'
            });

            xmldato += '</referencia_dependencia_hijos>'
            xmldato += '<operadores>'

            subscriptions.each(function (suscripcion) {
                if (suscripcion['estado'] == 'ACTIVO') {
                    xmldato += '<operador'
                    xmldato += ' operador="' + suscripcion['operador'] + '"'
                    xmldato += ' nro_ref_sus_estado="' + suscripcion['nro_ref_sus_estado'] + '"'
                    xmldato += ' operador_origen="' + suscripcion['operador_origen'] + '"'

                    if (es_autoguardado) {
                        xmldato += ' nombre_operador="' + suscripcion['nombre_operador'] + '"'
                        xmldato += ' ref_sus_estado="' + suscripcion['ref_sus_estado'] + '"'
                        xmldato += ' nombre_operador_origen="' + suscripcion['nombre_operador_origen'] + '"'
                    }

                    xmldato += '/>'
                }
            });

            xmldato += '</operadores>'
            xmldato += '<ref_docs>'

            var nro_ref_doc = null

            referencia['documento'].each(function (doc, doc_pos) {
                nro_ref_doc = doc['nro_ref_doc'].toString()[0] == '0' ? 0 : doc['nro_ref_doc']

                xmldato += '<ref_doc'
                xmldato += ' nro_ref_doc="' + nro_ref_doc + '"'
                xmldato += ' ref_doc_version="' + doc['ref_doc_version'] + '"'
                xmldato += ' orden="' + doc['orden'] + '"'
                xmldato += ' ref_doc_titulo="' + doc['ref_doc_titulo'] + '"'
                xmldato += ' nro_ref_estado="' + doc['nro_ref_estado_doc'] + '"'
                xmldato += ' nro_ref_doc_tipo="' + doc['nro_ref_doc_tipo'] + '"'

                if (es_autoguardado) {
                    xmldato += ' ref_estado="' + doc['ref_estado'] + '"'
                    xmldato += ' ref_doc_tipo="' + doc['ref_doc_tipo'] + '"'
                }

                xmldato += documento_esModificado(doc_pos) ? ' modificado="true">' : ' modificado="false">'
                xmldato += '<ref_doc_html><![CDATA[' + doc['ref_doc_html'] + ']]></ref_doc_html></ref_doc>'
            });

            xmldato += '</ref_docs>'
            xmldato += '</referencia>'
            return xmldato
        }



        function documento_esModificado(i) {
            var documento_modificado = false
            var reg = /\s*/ig
            var doc = referencia['documento'][i]

            // Titulo
            if (doc['ref_doc_titulo'].replace(reg, '') != doc['ref_doc_titulo_original'].replace(reg, '')) {
                documento_modificado = true
                existen_modificaciones = true
                return documento_modificado
            }

            // Tipo
            if (doc['nro_ref_doc_tipo'].replace(reg, '') != doc['nro_ref_doc_tipo_original'].replace(reg, '')) {
                documento_modificado = true
                existen_modificaciones = true
                return documento_modificado
            }

            // Estado
            if (doc['nro_ref_estado_doc'].replace(reg, '') != doc['nro_ref_estado_doc_original'].replace(reg, '')) {
                documento_modificado = true
                existen_modificaciones = true
                return documento_modificado
            }

            if (doc['ref_doc_html_original'] != undefined) {
                var original = doc['ref_doc_html_original'].replace(reg, "")
                var nuevo = doc['ref_doc_html'].replace(reg, "")

                // Obtengo el resultado
                documento_modificado = original != nuevo

                // Si hay al menos una modificacion => la guardo
                if (documento_modificado)
                    existen_modificaciones = true

                return documento_modificado
            }

            return documento_modificado
        }


        var referencia_eliminada = false
        function referencia_eliminar() {
            if (referencia['nro_ref'] == 0)
                return

            if (nvFW.pageContents.ref_eliminar == "0" && !nvFW.tienePermiso('permisos_referencias', 7)) {
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
                return
            }

            nvFW.confirm('¿Eliminar la referencia <b>' + referencia.referencia + '</b>?', {
                width: 300,
                onOk: function (win) {
                    referencia['nro_ref'] = parseInt(referencia['nro_ref']) * -1
                    referencia_eliminada = true
                    referencia_guardar(true)
                    win.close()
                },
                onCancel: function (win) {
                    win.close()
                }
            })
        }

        function referencia_guardar_como() {

            referencia["nro_ref"] = 0
            $("nro_ref").value = 0

            referencia['documento'].each(function (documento) {
                documento["nro_ref_doc"] = '0'
                documento["ref_doc_version"] = 1
            });

            referencia_guardar()
        }


        function referencia_eliminar() {
            if (referencia['nro_ref'] == 0)
                return

            if (nvFW.pageContents.ref_eliminar == "0" && !nvFW.tienePermiso('permisos_referencias', 7)) {
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
                return
            }

            nvFW.confirm('¿Eliminar la referencia <b>' + referencia.referencia + '</b>?', {
                width: 300,
                onOk: function (win) {
                    referencia['nro_ref'] = parseInt(referencia['nro_ref']) * -1
                    //referencia_eliminada = true
                    referencia_guardar(true)
                    win.close()
                },
                onCancel: function (win) {
                    win.close()
                }
            })
        }



        var force_reload_tree = false
        function dependencia_abm(es_padre) {
            documento_actualizar()

            var url = ''
            var title = ''

            if (es_padre) {
                url = 'ref_dependencias_padre_abm.aspx?gethijo=' + referencia['nro_ref']
                title = 'Seleccionar dependencia padre'
            }
            else {
                url = 'ref_dependencias_hijo_abm.aspx?getpadre=' + referencia['nro_ref']
                title = 'Seleccionar dependencia hijas'
            }

            win_dependencia = nvFW.createWindow({
                url: url,
                title: title,
                minimizable: false,
                maximizable: false,
                draggable: true,
                minWidth: 350,
                minHeight: 350,
                maxHeight: 350,
                width: 450,
                height: 350,
                destroyOnClose: true,
                onClose: function () {
                    if (win_dependencia.options.userData.retorno["success"]) {
                        force_reload_tree = true
                    }
                }
            });
            var Parametros = new Array()
            win_dependencia.options.userData = { retorno: Parametros }
            win_dependencia.showCenter(true)
        }


        function administrador_archivos() {
            nvFW.file_dialog_show()
        }


        function documento_bajar(orden_radio, orden_doc) {

            documento_actualizar()

            var orden = parseInt(s_orden)

            var orden_dest = -1
            var radio_dest

            for (var i = orden_doc + 1; i < referencia.documento.length; i++)
                if (referencia.documento[i]['nro_ref_doc'] >= 0) {
                    orden_dest = i
                    radio_dest = referencia.documento[i]['indice_radio']
                    break;
                }

            if (orden_dest != -1) {
                var aux = referencia.documento[orden_doc]

                referencia.documento[orden_doc] = referencia.documento[orden_dest]
                referencia.documento[orden_dest] = aux

                /* verificar */
                //referencia.documento[orden_doc]['orden'] = orden_doc
                //referencia.documento[orden_dest]['orden'] = orden_dest

                /*if (orden == orden_doc)
                s_orden = orden_dest
                else
                if (orden == orden_dest)
                s_orden = orden_doc*/


                if (s_radio == orden_radio) {
                    s_radio = radio_dest
                } else if (s_radio == radio_dest) {
                    s_radio = orden_radio
                }

                documentos_dibujar()
            }
        }


        function documento_subir(orden_radio, orden_doc) {

            documento_actualizar()

            var orden = parseInt(s_orden)

            var orden_dest = -1
            var radio_dest

            for (var i = orden_doc - 1; i >= 0; i--)
                if (referencia.documento[i]['nro_ref_doc'] >= 0) {
                    orden_dest = i
                    radio_dest = referencia.documento[i]['indice_radio']
                    break;
                }

            if (orden_dest != -1) {
                var aux = referencia.documento[orden_doc]
                referencia.documento[orden_doc] = referencia.documento[orden_dest]
                referencia.documento[orden_dest] = aux

                /* verificar */
                //Referencia.Documento[orden_doc]['orden'] = orden_doc
                //Referencia.Documento[orden_dest]['orden'] = orden_dest

                /*if (orden == orden_doc)
                orden = orden_dest
                else
                if (orden == orden_dest)
                orden = orden_doc*/

                if (s_radio == orden_radio) {
                    s_radio = radio_dest
                } else if (s_radio == radio_dest) {
                    s_radio = orden_radio
                }

                documentos_dibujar()
            }
        }


        function window_onunload() {
            // Limpiar la funcion que corre por intervalos de tiempo
            clearInterval(id_interval_120);
            // Si hubo algun cambio y la ventana NO se cerro por codigo => actualizar el frame principal
            if (existen_modificaciones && !cerrar_win_por_codigo) {
                try {
                    if (campos_defs.get_value('nro_ref')) {
                        win_frameRef.ref_mostrar(campos_defs.get_value('nro_ref'))
                    }
                    else {
                        ObtenerVentana('frame_ref').location.href = '/wiki/inicio.aspx'
                    }
                }
                catch (e) {
                    ObtenerVentana('frame_ref').location.href = '/wiki/inicio.aspx'
                }
            }
        }





        /**************************************************************************
        ***** SUSCRIPCIONES *******************************************************
        ***************************************************************************/
        var subs_loaded = false;
        var subscriptions = [];
        var win_subscriptions = null

        var suscripcion_pendiente = false
        var operador_actual

        subscriptions.add = function (op) {
            if (op.operador) {
                var exist_in_array = false;
                //this.each(function (arr_op) {
                //    if (arr_op.operador == op.operador) {
                //        exist_in_array = true;
                //    }
                //});
                for (var p = 0, n = subscriptions.length; p < n; p++) {
                    if (subscriptions[p]['operador'] == op['operador']) {
                        exist_in_array = true
                        break
                    }
                }

                if (!exist_in_array) {
                    this.push(op);
                    return true;
                }
            }

            return false;
        }


        function suscriptions() {
            if (campos_defs.get_value("nro_ref") === "") {
                alert("Debe seleccionar una referencia");
                return
            }

            if (win_subscriptions == null) {
                win_subscriptions = nvFW.createWindow({
                    title: '<b>Suscripciones</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 600,
                    height: 200,
                    resizable: false
                });
            }

            drawSuscriptions()
            win_subscriptions.showCenter(true)
        }

        function drawSuscriptions() {
            var html = ''
            html += '<table class="tb1 highlightOdd highlightTROver" style="font-size: 13px;">'
            html += '<tbody>'
            html += '<tr class="tbLabel">'
            html += '<td style="width: 30px;">&nbsp;</td>'
            html += '<td style="text-align: center;">Operador</td>'
            html += '<td style="width: 140px; text-align: center;">Estado</td>'
            html += '<td style="width: 140px; text-align: center;">Operador Suscriptor</td>'
            html += '</tr>'

            subscriptions.each(function (subscription, posicion) {
                if (subscription.estado != 'BORRADO') {
                    html += '<tr style="height: 19px;">'
                    html += '<td style="text-align: center;">'
                    html += '<img alt="eliminar" src="/FW/image/icons/eliminar.png" title="Eliminar" style="cursor: pointer;" onclick="return eliminar_suscripcion(' + posicion + ');" />'
                    html += '</td>'
                    html += '<td>&nbsp;' + subscription.nombre_operador + '</td>'

                    if (subscription.ref_sus_estado)
                        html += '<td>&nbsp;' + subscription.ref_sus_estado + '</td>'
                    else
                        html += '<td>&nbsp;Suscripcion Pendiente</td>'

                    if (subscription.operador_origen)
                        html += '<td>&nbsp;' + subscription.nombre_operador_origen + '</td>'
                    else
                        html += '<td>&nbsp;' + nombre_operador + '</td>'

                    html += '</tr>'
                }
            });

            html += '</tbody>'
            html += '</table>'

            html += '<table class="tb1" style="font-size: 13px;">'
            html += '<tbody>'
            html += '<tr style="height: 19px;">'
            html += '<td colspan="5" style="text-align: center;">'
            html += '<img alt="agregar" src="/FW/image/icons/agregar.png" title="Agregar" style="cursor: pointer;" onclick="return agregar_suscripcion();">'
            html += '</td>'
            html += '</tr>'
            html += '</tbody>'
            html += '</table>'

            win_subscriptions.setHTMLContent(html)
        }


        function loadSuscriptions() {
            if (subs_loaded)
                return

            nro_ref = campos_defs.get_value("nro_ref")

            if (campos_defs.items['nro_ref']['input_hidden'].value != "") {
                nro_ref = campos_defs.items['nro_ref']['input_hidden'].value;
            }

            var rs = new tRS();
            var criterio = "<criterio><select><filtro><nro_ref type='igual'>" + nro_ref + "</nro_ref></filtro></select></criterio>"

            rs.open(nvFW.pageContents.filtro_suscripcion_pendiente, '', criterio, '', '');

            var reg = {};

            while (!rs.eof()) {
                reg = {};
                reg.operador = rs.getdata('operador');
                reg.nombre_operador = rs.getdata('full_operador');
                reg.ref_sus_estado = rs.getdata('ref_sus_estado');
                reg.nro_ref_sus_estado = rs.getdata('nro_ref_sus_estado');
                reg.operador_origen = rs.getdata('operador_origen') == null ? nro_operador : rs.getdata('operador_origen')
                reg.nombre_operador_origen = rs.getdata('nombre_operador_origen') == null ? nombre_operador : rs.getdata('nombre_operador_origen')
                reg.estado = 'ACTIVO'

                subscriptions.add(reg);

                if ((rs.getdata('operador') == rs.getdata('operador_actual')) && (rs.getdata('notificador') == 2)) {
                    suscripcion_pendiente = true
                    operador_actual = rs.getdata('operador_actual')
                }

                rs.movenext();
            }

            subs_loaded = true;
        }

        function agregar_suscripcion() {
            if (campos_defs.items['nro_operador']["window"] != undefined && campos_defs.items['nro_operador']["window"].campo_def_value != '') {
                campos_defs.items['nro_operador']["window"] = undefined;
            }

            campos_defs.clear('nro_operador');
            campos_defs.onclick('', 'nro_operador', true);
        }

        function eliminar_suscripcion(posicion) {
            if (nro_operador == subscriptions[posicion].operador) {
                subscriptions[posicion].estado = 'BORRADO'
                drawSuscriptions();
            }
        }

        function nro_operador_onload() {
            if (campos_defs.get_value('nro_operador') != '') {
                if (campos_defs.get_value("nro_ref") === "") {
                    alert('Seleccione una referencia')
                    return
                }
                else {
                    if (ref_tiene_permiso(campos_defs.get_value('nro_operador'))) {
                        var newOperator = {};
                        newOperator.operador = campos_defs.get_value('nro_operador');
                        newOperator.nombre_operador = campos_defs.get_desc('nro_operador');
                        newOperator.ref_sus_estado = 'Suscripcion Pendiente';
                        newOperator.nro_ref_sus_estado = 2;
                        newOperator.operador_origen = nro_operador
                        newOperator.nombre_operador_origen = nombre_operador_origen ? nombre_operador_origen : nombre_operador
                        newOperator.estado = 'ACTIVO';

                        if (newOperator.operador == nro_operador) {
                            newOperator.nro_ref_sus_estado = 1;
                            newOperator.ref_sus_estado = 'Suscripto'
                        }

                        if (!subscriptions.add(newOperator)) {
                            subscriptions.each(function (suscripcion) {
                                if (suscripcion['operador'] == newOperator.operador) {
                                    suscripcion['estado'] = 'ACTIVO'
                                }
                            });
                        }
                    }
                    else {
                        alert('El operador seleccionado no tiene permiso para ver esta Referencia')
                        return
                    }
                }
            }

            drawSuscriptions();
        }


        function ref_tiene_permiso(operador_suscripcion) {
            var retorno = false
            var vista = 1 // Todos los permisos
            //var tipo_operador = ''
            var tipo_operador = [] // con el nuevo modelo de permisos se puede tener mas de un perfil (tipo_operador)
            tipo_operador.push('999') //todo los permisos
            var rs = new tRS();
            var filtro = ''
            filtro += "<operador type='igual'>" + operador_suscripcion + "</operador>"
            rs.open(nvFW.pageContents.filtro_tiene_permiso, '', filtro, '', '')

            //if (!rs.eof()) {
            //    tipo_operador = rs.getdata('tipo_operador')
            //}
            while (!rs.eof()) {
                tipo_operador.push(rs.getdata('tipo_operador'))
                rs.movenext()
            }

            rs = null
            rs = new tRS()

            //var param = "<criterio><params p_s_nro_ref2=\"" + campos_defs.get_value("nro_ref") + "\" /><params p_vista=\"" + vista + "\" /></criterio>"
            //var param = '<criterio><params p_s_nro_ref2="' + campos_defs.get_value("nro_ref") + '" /><params p_vista="' + vista + '" /></criterio>'
            var param = '<criterio><params p_s_nro_ref2="' + campos_defs.get_value("nro_ref") + '" p_vista="' + vista + '" /></criterio>'
            rs.open(nvFW.pageContents.filtro_tiene_permiso2, '', '', '', param)

            while (!rs.eof()) {
                if ((rs.getdata('nro_operador') == operador_suscripcion) && ((rs.getdata('permiso') & 8) == 8))
                    retorno = true

                //if ((rs.getdata('tipo_operador') == tipo_operador) && ((rs.getdata('permiso') & 8) == 8))
                if ((tipo_operador.indexOf(rs.getdata('tipo_operador')) > -1) && ((rs.getdata('permiso') & 8) == 8))
                    retorno = true

                rs.movenext()
            }

            return retorno
        }




        /**************************************************************************
        ***** AUTOGUARDADO  *******************************************************
        ***************************************************************************/
        var Autoguardado = []
        var id_ref_auto = nvFW.pageContents.id_ref_auto
        var id_interval_120

        var ref_no_guardada = nvFW.pageContents.ref_no_guardada

        function intervalos_iniciar() {
            id_interval_120 = setInterval('referencia_auto_guardado()', 120000)
        }

        // Verifica si existe un autoguardado pendiente
        function verificar_autoguardado() {
            var filtro = ''

            if (nro_ref != 0)
                filtro = "<nro_ref type='igual'>" + nro_ref + "</nro_ref>"

            filtro += "<operador type='igual'>" + nro_operador + "</operador>"

            if (id_ref_auto != 0)
                filtro += "<id_ref_auto type='igual'>" + id_ref_auto + "</id_ref_auto>"

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtro_verificar_autoguardado, '', filtro, '', '')

            if (!rs.eof()) {
                Autoguardado['id_ref_auto'] = rs.getdata('id_ref_auto')
                Autoguardado['nro_ref'] = rs.getdata('nro_ref')
                Autoguardado['ref_auto_fecha'] = FechaToSTR(parseFecha(rs.getdata('ref_auto_fecha'))) + ' ' + TiempoToSTR(parseFecha(rs.getdata('ref_auto_fecha')))
                Autoguardado['referencia'] = rs.getdata('referencia')

                var xml_autoguardado = ''

                try {
                    xml_autoguardado = nvFW.getFile({
                        accion: 'return',
                        type: 'OTROS',
                        select: 'SELECT str_xml FROM ref_autoguardado WHERE id_ref_auto=' + rs.getdata('id_ref_auto')
                    })
                }
                catch (e) { }

                Autoguardado['xml'] = xml_autoguardado

                if (rs.getdata('ref_doc_fe_estado_ultima') != null) {
                    Autoguardado['ref_doc_fe_estado_ultima'] = FechaToSTR(parseFecha(rs.getdata('ref_doc_fe_estado_ultima'))) + ' ' + TiempoToSTR(parseFecha(rs.getdata('ref_doc_fe_estado_ultima')))
                    Autoguardado['ref_doc_fecha_ultima'] = FechaToSTR(parseFecha(rs.getdata('ref_doc_fe_estado_ultima')))
                    Autoguardado['ref_doc_hora_ultima'] = TiempoToSTR(parseFecha(rs.getdata('ref_doc_fe_estado_ultima')))
                    Autoguardado['nombre_operador_ultima'] = rs.getdata('nombre_operador_ultima')
                }
            }

            if (xml_autoguardado)
                return true
            else
                return false
        }


        function confirmar_autoguardado() {
            var msj = "Existe un guardado pendiente para esta referencia. ¿Desea recuperarlo?."

            nvFW.confirm(msj, {
                width: 300,
                okLabel: "Si",
                cancelLabel: "No",
                cancel: function (win) {
                    win.close();
                    referencia_cargar()
                    referencia['id_ref_auto'] = parseInt(Autoguardado['id_ref_auto']) * -1
                },
                ok: function (win) {
                    win.close()
                    referencia_auto_cargar(Autoguardado['xml'])
                }
            });
        }


        function referencia_auto_cargar(xml) {
            if (Autoguardado['ref_doc_fe_estado_ultima'] != null)
                var comparacion = comparar_fechasyhora(Autoguardado['ref_auto_fecha'], Autoguardado['ref_doc_fe_estado_ultima'])

            if (comparacion == -1) {
                msj = "<b>AVISO:</b> Existe una modificación posterior a esta versión, realizada por el operador <b>" + Autoguardado['nombre_operador_ultima'] + "</b> el día <b>" + Autoguardado['ref_doc_fecha_ultima'] + "</b>, a las <b>" + Autoguardado['ref_doc_hora_ultima'] + "</b>"
                alert(msj)
            }

            var oXML = new tXML();

            try {
                oXML.loadXML(xml)

                // cargar referencia
                var s_txt_nro_ref = oXML.selectSingleNode('referencia/@nro_ref').nodeValue
                $('referencia').value = oXML.selectSingleNode('referencia/@referencia').nodeValue
                campos_defs.set_value("nro_ref_estado", oXML.selectSingleNode('referencia/@nro_ref_estado').nodeValue)
                referencia['nro_ref'] = s_txt_nro_ref
                referencia['referencia'] = $('referencia').value
                referencia['nro_ref_estado'] = oXML.selectSingleNode('referencia/@nro_ref_estado').nodeValue
                referencia['id_ref_auto'] = Autoguardado['id_ref_auto']

                // cargar documentos
                referencia['documento'] = []

                NODs = oXML.selectNodes('/referencia/ref_docs/ref_doc')

                for (var i = 0; i < NODs.length; i++) {
                    referencia['documento'][i] = {};
                    referencia['documento'][i]["nro_ref_doc"] = NODs[i].getAttribute("nro_ref_doc")
                    referencia['documento'][i]["ref_doc_version"] = NODs[i].getAttribute("ref_doc_version")
                    referencia['documento'][i]["orden"] = NODs[i].getAttribute("orden")
                    referencia['documento'][i]["ref_doc_titulo"] = NODs[i].getAttribute("ref_doc_titulo")
                    referencia['documento'][i]["nro_ref_estado_doc"] = NODs[i].getAttribute("nro_ref_estado")
                    referencia['documento'][i]["nro_ref_doc_tipo"] = NODs[i].getAttribute("nro_ref_doc_tipo")
                    referencia['documento'][i]["ref_estado"] = NODs[i].getAttribute("ref_estado")
                    referencia['documento'][i]["ref_doc_tipo"] = NODs[i].getAttribute("ref_doc_tipo")

                    if (Prototype.Browser.IE)
                        referencia['documento'][i]["ref_doc_html"] = NODs[i].text
                    else
                        referencia['documento'][i]["ref_doc_html"] = NODs[i].textContent

                    referencia['documento'][i]['ref_doc_html_original'] = ''
                    referencia['documento'][i]['ref_doc_titulo_original'] = ''
                    referencia['documento'][i]['nro_ref_doc_tipo_original'] = ''
                    referencia['documento'][i]['nro_ref_estado_doc_original'] = ''
                }
                s_radio = referencia['documento'].length -1 
                documentos_dibujar()

                // cargar dependencia padre
                referencia['dependencia_padre'] = []

                for (var i = 0, max_parents = oXML.selectNodes('/referencia/referencia_dependencia_padres/ref_dependencias_padres').length; i < max_parents; i++) {
                    nod = oXML.selectNodes('/referencia/referencia_dependencia_padres/ref_dependencias_padres')[i]
                    referencia['dependencia_padre'][i] = []
                    referencia['dependencia_padre'][i]['nro_ref_padre'] = nod.getAttribute("nro_ref_padre")
                    referencia['dependencia_padre'][i]['referencia_padre'] = nod.getAttribute("referencia_padre")
                    referencia['dependencia_padre'][i]['ref_dep_orden'] = nod.getAttribute("ref_dep_orden")
                }

                // cargar dependencia hija
                referencia['dependencia_hijo'] = []

                for (var i = 0, max_children = oXML.selectNodes('/referencia/referencia_dependencia_hijos/ref_dependencias_hijos').length; i < max_children; i++) {
                    nod = oXML.selectNodes('/referencia/referencia_dependencia_hijos/ref_dependencias_hijos')[i]
                    referencia['dependencia_hijo'][i] = []
                    referencia['dependencia_hijo'][i]['nro_ref'] = nod.getAttribute("nro_ref")
                    referencia['dependencia_hijo'][i]['referencia'] = nod.getAttribute("referencia")
                    referencia['dependencia_hijo'][i]['ref_dep_orden'] = nod.getAttribute("ref_dep_orden")
                }

                // suscripciones
                subscriptions = []

                for (var i = 0, max_suscriptions = oXML.selectNodes('/referencia/operadores/operador').length; i < max_suscriptions; i++) {
                    nod = oXML.selectNodes('/referencia/operadores/operador')[i]
                    subscriptions[i] = []
                    subscriptions[i]['operador'] = nod.getAttribute('operador')
                    subscriptions[i]['nombre_operador'] = nod.getAttribute('nombre_operador')
                    subscriptions[i]['nro_ref_sus_estado'] = nod.getAttribute('nro_ref_sus_estado')
                    subscriptions[i]['ref_sus_estado'] = nod.getAttribute('ref_sus_estado')
                    subscriptions[i]['operador_origen'] = nod.getAttribute('operador_origen')
                    subscriptions[i]['nombre_operador_origen'] = nod.getAttribute('nombre_operador_origen')
                    subscriptions[i]['estado'] = 'ACTIVO'
                }
            }
            catch (e) {
                alert('Error XML')
            }
        }



        var nro_ref_auto_guardado = 0
        function referencia_auto_guardado() {
            var modificado = false
            documento_actualizar()

            referencia['documento'].each(function (doc, index) {
                if (doc.indice_radio > -1) {
                    if (documento_esModificado(doc.indice_radio)) {
                        modificado = true;
                    }
                }
            });

            if (modificado) {
                nvFW.error_ajax_request('referencias_ABM.aspx',
                {
                    parameters:
                    {
                        modo: 'AUTOGUARDADO',
                        strXML: generar_xml(true),
                        nro_ref: referencia["nro_ref"],
                        referencia: referencia["referencia"],
                        id_ref_auto: referencia["id_ref_auto"]
                    },
                    onSuccess: function (err) {
                        nro_ref_auto_guardado = parseInt(err.params.id_ref_auto, 10);
                        referencia["id_ref_auto"] = nro_ref_auto_guardado; // Actualizar el valor para no generar otro registro en al auto-guardado
                    },
                    error_alert: false,
                    bloq_msg: 'Autoguardado...'
                })
            }
        }



        function TiempoToSTR(objFecha) {
            var horas = nvFW.rellenar_izq(parseInt(objFecha.getHours(), 10), 2, '0')
            var minutos = nvFW.rellenar_izq(parseInt(objFecha.getMinutes(), 10), 2, '0')
            return horas + ':' + minutos
        }


        function comparar_fechasyhora(Inicio, Vencimiento) {
            var arr_inicio = Inicio.split(' ')
            var arr_vencimiento = Vencimiento.split(' ')
            var resF = comparar_fechas(arr_inicio[0], arr_vencimiento[0])
            var resH = comparar_horas(arr_inicio[1], arr_vencimiento[1])

            if (resF == 1)
                return 1
            else
                if (resF == -1)
                    return -1
                else
                    if (resF == 0 && resH == 1)
                        return 1
                    else
                        if (resF == 0 && resH == -1)
                            return -1
                        else
                            return 0
        }


        function comparar_fechas(fecha1, fecha2) {
            fecha1 = fecha1.split('/')
            fecha2 = fecha2.split('/')

            var ano1 = parseInt(fecha1[2])
            var ano2 = parseInt(fecha2[2])
            var mes1 = parseInt(fecha1[1])
            var mes2 = parseInt(fecha2[1])
            var dia1 = parseInt(fecha1[0])
            var dia2 = parseInt(fecha2[0])

            if (ano1 > ano2)
                return 1
            else
                if (ano1 < ano2)
                    return -1
                else
                    if (mes1 > mes2)
                        return 1
                    else
                        if (mes1 < mes2)
                            return -1
                        else
                            if (dia1 > dia2)
                                return 1
                            else
                                if (dia1 < dia2)
                                    return -1
                                else
                                    return 0
        }


        function comparar_horas(hora1, hora2) {
            var arr_hora_1 = hora1.split(":");
            var arr_hora_2 = hora2.split(":");
            // Obtener horas y minutos (hora 1) 
            var hh1 = isNaN(parseInt(arr_hora_1[0], 10)) ? 0 : parseInt(arr_hora_1[0], 10)
            var mm1 = isNaN(parseInt(arr_hora_1[1], 10)) ? 0 : parseInt(arr_hora_1[1], 10)
            // Obtener horas y minutos (hora 2) 
            var hh2 = isNaN(parseInt(arr_hora_2[0], 10)) ? 0 : parseInt(arr_hora_2[0], 10)
            var mm2 = isNaN(parseInt(arr_hora_2[1], 10)) ? 0 : parseInt(arr_hora_2[1], 10)

            // Comparar 
            if (hh1 < hh2 || (hh1 == hh2 && mm1 < mm2))
                return -1
            else if (hh1 > hh2 || (hh1 == hh2 && mm1 > mm2))
                return 1
            else
                return 0
        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" onbeforeunload="return alert('hola mundo')"
    onunload="return window_onunload()" style="height: 100%; width: 100%; margin: 0px;
    padding: 0px; overflow: hidden;">
    <form id="FrmRef" name="FrmRef" action="Referencias_ABM.aspx" method="post" target="frameEnviar"
    style="width: 100%; margin: 0;" autocomplete="off">
    <div id="divMenuDatosRef" style="margin: 0px; padding: 0px">
    </div>
    <script type="text/javascript">
        var vMenuDatosRef = new tMenu('divMenuDatosRef', 'vMenuDatosRef');

        vMenuDatosRef.loadImage("guardar", '/FW/image/icons/guardar.png')
        vMenuDatosRef.loadImage("guardar_cerrar", '/wiki/image/icons/guardar_cerrar.png')
        vMenuDatosRef.loadImage("guardar_como", '/wiki/image/icons/guardar_como.png')
        vMenuDatosRef.loadImage("eliminar", '/wiki/image/icons/eliminar.png')
        vMenuDatosRef.loadImage("dep_hijo", '/wiki/image/icons/dep_hijo.png')
        vMenuDatosRef.loadImage("dep_padre", '/wiki/image/icons/dep_padre.png')
        vMenuDatosRef.loadImage("upload", '/wiki/image/icons/upload.png')
        vMenuDatosRef.loadImage("favorito_si", '/wiki/image/icons/favorito_si.png')
        vMenuDatosRef.loadImage("info", '/FW/image/icons/info.png')

        Menus["vMenuDatosRef"] = vMenuDatosRef
        Menus["vMenuDatosRef"].alineacion = 'centro';
        Menus["vMenuDatosRef"].estilo = 'A';
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='0' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>referencia_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='1' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_cerrar</icono><Desc>Guardar y Cerrar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>referencia_guardar(true)</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='2' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_como</icono><Desc>Guardar Como</Desc><Acciones><Ejecutar Tipo='script'><Codigo>referencia_guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='3' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>referencia_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='4' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>dep_hijo</icono><Desc>Dep. Hijos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>dependencia_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='5' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>dep_padre</icono><Desc>Dep. Padres</Desc><Acciones><Ejecutar Tipo='script'><Codigo>dependencia_abm(true)</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='6' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>upload</icono><Desc>Abm Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>administrador_archivos()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='7' style='width: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>favorito_si</icono><Desc>Suscripciones</Desc><Acciones><Ejecutar Tipo='script'><Codigo>suscriptions()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='8' style='width: 50%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='9' style='width: 10%; text-align:right; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>info</icono><Desc>Nueva Referencia</Desc><Acciones><Ejecutar Tipo='script'><Codigo>referencia_nueva()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuDatosRef.MostrarMenu()
    </script>
    <!-- Nombre referencia y estado-->
    <table id="tbNombreReferencia" class="tb1">
        <tr class="tbLabel">
            <td colspan="5">
                &nbsp;
            </td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 3%; text-align: right">
                Referencia:
            </td>
            <td style="width: 70%; vertical-align: middle">
                <input type="text" style="width: 100%; text-align: left" name="referencia" id="referencia" />
            </td>
            <td style="width: 1px">
                <% = nvFW.nvCampo_def.get_html_input("nro_ref") %>
            </td>
            <td class="Tit1" style="width: 4%; text-align: right">
                Estado:
            </td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("nro_ref_estado") %>
            </td>
        </tr>
    </table>
    <!-- Menu Nuevo Documento -->
    <div id="divMenuDatosRefDoc1" style="margin: 0px; padding: 0px;">
    </div>
    <script type="text/javascript">

        var vMenuDatosRefDoc1 = new tMenu('divMenuDatosRefDoc1', 'vMenuDatosRefDoc1');
        vMenuDatosRefDoc1.loadImage("nueva", '/FW/image/icons/nueva.png')
        Menus["vMenuDatosRefDoc1"] = vMenuDatosRefDoc1
        Menus["vMenuDatosRefDoc1"].alineacion = 'centro';
        Menus["vMenuDatosRefDoc1"].estilo = 'A';
        Menus["vMenuDatosRefDoc1"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuDatosRefDoc1"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo Documento</Desc><Acciones><Ejecutar Tipo='script'><Codigo>documento_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
    </script>
    <!-- Tabla de documentos -->
    <table id="tbDocs" class="tb1">
        <tr class="tbLabel">
            <td style="width: 50px; text-align: center;">
                -
            </td>
            <td style="text-align: center;">
                Titulo
            </td>
            <td style="width: 150px; text-align: center;">
                Tipo
            </td>
            <td style="width: 150px; text-align: center;">
                Estado
            </td>
            <td style="width: 40px; text-align: center;">
                -
            </td>
            <td style="width: 40px; text-align: center;">
                -
            </td>
            <td style="width: 15px;">
                &nbsp;
            </td>
        </tr>
    </table>
    <div id="divDocumentos" style="width: 100%; height: 120px; overflow-y: scroll;">
    </div>
    <!-- Editor de documento -->
    <div id="editor" style="width: 100%; height: 100%; top: 0; margin: 0px; padding: 0px;">
    </div>
    <script type="text/javascript">
        CKEDITOR.replace('editor', { toolbar: 'referencias', height: 420, width: 'auto' });
    </script>
    </form>
    <div style="display: none;">
        <% = nvFW.nvCampo_def.get_html_input("nro_operador") %>
    </div>
</body>
</html>
