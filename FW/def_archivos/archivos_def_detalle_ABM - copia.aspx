<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim indice As String = nvFW.nvUtiles.obtenerValor("indice", "-1")

    Dim err As New tError()
    If modo = "ALTAPARAM" Then

        Dim archivo_descripcion As String = nvFW.nvUtiles.obtenerValor("archivo_descripcion", "")
        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_param_def_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

        cmd.addParameter("@archivo_descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, archivo_descripcion.Length, archivo_descripcion)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()
            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception

            err.numError = -1
            err.mensaje = "Error inesperado"
            err.titulo = "Error al tratar de realizar la operación"
            err.debug_desc = ex.Message.ToString
            err.debug_src = "FW_param_def_abm"

        End Try

        err.response()
    End If



    Me.contents("indice") = nvFW.nvUtiles.obtenerValor("indice", "-1")

    'Me.contents("filtroPerf") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_def_perfil' ><campos>*</campos><orden>id</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>*</campos><orden>nro_archivo_def_grupo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroPerfil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_perfil'><campos>archivo_def_perfil</campos><filtro><id type='igual'>%nro_def_perfil%</id></filtro></select></criterio>")
    Me.contents("filtroTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_tipo'><campos>archivo_def_tipo</campos><filtro><nro_archivo_def_tipo type='igual'>%nro_archivo_def_tipo%</nro_archivo_def_tipo></filtro></select></criterio>")
    Me.contents("filtroVencimiento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_venc_tipos'><campos>nro_venc_tipo as id,venc_tipo as campo</campos><orden>campo</orden></select></criterio>")
    Me.contents("filtroFunciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='sys.objects'><campos>type as id,name as campo</campos><filtro><name type='like'>%fn_%</name></filtro></select></criterio>")
    Me.contents("filtroUbicacion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_file_ubis'><campos>f_nro_ubi as id,f_ubi as campo</campos></select></criterio>")
    Me.contents("filtro_archivos_parametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_parametro_def'><campos>*</campos><filtro></filtro><orden>orden ASC</orden></select></criterio>")

%>
<html>
<head>
    <title>Definición de Archivos Detalle ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    
     <%= Me.getHeadInit() %>

    <script type="text/javascript">
    
    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

    var filtroGrupo = nvFW.pageContents.filtroGrupo
    var filtroPerfil = nvFW.pageContents.filtroPerfil 
    var filtroTipo = nvFW.pageContents.filtroTipo

    var archivos
    var params
    var indice = nvFW.pageContents.indice
    var win = nvFW.getMyWindow()
    var grupos = new Array()

   

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuArchivosDefDetalleABM_h = $('divMenuArchivosDefDetalleABM').getHeight()
            tb_archivos_def_detalle_h = $('tb_archivos_def_detalle').getHeight()
            divMenuArchivosABM_h = $('divMenuArchivosABM').getHeight()
            tb_archivos_def_detalle1_h = $('tb_archivos_def_detalle1').getHeight()
            tb_archivos_def_detalle2_h = $('tb_archivos_def_detalle2').getHeight()
            tb_archivos_def_detalle3_h = $('tb_archivos_def_detalle3').getHeight()
            tb_archivos_def_detalle4_h = $('tb_archivos_def_detalle4').getHeight()
            divMenuArchivosColor_h = $('divMenuArchivosColor').getHeight()
            tb_archivos_def_grupo_cab_h = $('tb_archivos_def_grupo_cab').getHeight()

            $('div_grupos').setStyle({ 'height': body_height - divMenuArchivosDefDetalleABM_h - tb_archivos_def_detalle_h - divMenuArchivosABM_h - tb_archivos_def_detalle1_h - tb_archivos_def_detalle2_h - tb_archivos_def_detalle3_h - tb_archivos_def_detalle4_h - divMenuArchivosColor_h - tb_archivos_def_grupo_cab_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() {
        archivos = win.options.userData.archivos

        cargar_archivos_def_detalle()
        onclick_request_usr()
        window_onresize()
        mostrar_param()
        //mostrar_datos_perf()
    }

    function cargar_archivos_def_detalle()  {
        //var indice = $('indice').value == '' ? -1 : $('indice').value

        //Cuando se edita un Archivo Def Detalle
        if (indice >= 0) {

            $('nro_def_detalle').value = archivos[indice]['nro_def_detalle']
            $('archivo_descripcion').value = archivos[indice]['archivo_descripcion']

            campos_defs.set_value('orden', archivos[indice]['orden'])

            $('readonly').checked = archivos[indice]['readonly'] == "True" ? 'checked' : ''
            $('requerido').checked = archivos[indice]['requerido'] == "True" ? 'checked' : ''
            $('reutilizable').checked = archivos[indice]['reutilizable'] == "True" ? 'checked' : ''
            $('repetido').checked = archivos[indice]['repetido'] == "True" ? 'checked' : ''
            $('print_auto').checked = archivos[indice]['print_auto'] == "True" ? 'checked' : ''

            campos_defs.set_value('nro_def_perfil', archivos[indice]['perfil'])
            campos_defs.set_value('nro_def_tipo', archivos[indice]['nro_archivo_def_tipo'])
            $('file_filtro').value = archivos[indice]['file_filtro']
            campos_defs.set_value('file_max_size', (archivos[indice]['file_max_size'] / 1000000).toFixed(2))

            $('request_usr').checked = archivos[indice]['request_usr'] == "True" ? 'checked' : ''
            if ($('request_usr').checked) 
            {
                campos_defs.set_value('ppi', archivos[indice]['ppi'])
                campos_defs.set_value('nro_depthcolor', archivos[indice]['nro_depthcolor'])
            }
            grupos_cargar(indice)

            campos_defs.set_value('nro_venc_tipo', !archivos[indice]['nro_venc_tipo'] ? 0 : archivos[indice]['nro_venc_tipo'])
            campos_defs.set_value('venc_dias', !archivos[indice]['venc_dias'] ? 0 : archivos[indice]['venc_dias'])
            $('venc_function_desc').value = !archivos[indice]['venc_function'] ? '' : archivos[indice]['venc_function']

            campos_defs.set_value('f_nro_ubi', !archivos[indice]['f_nro_ubi'] ? 1 : archivos[indice]['f_nro_ubi'])
            campos_defs.set_value('f_path', !archivos[indice]['f_path'] ? '' : archivos[indice]['f_path'])

        } else {
            //Cuando se da de alta un nuevo Archivo Def Detalle

            $('nro_def_detalle').value = 0
            $('archivo_descripcion').value = ''
            campos_defs.clear('orden')

            $('readonly').checked = ''
            $('requerido').checked = ''
            $('reutilizable').checked = ''
            $('repetido').checked = ''
            $('print_auto').checked = ''

            campos_defs.clear('nro_def_perfil')
            campos_defs.clear('nro_def_tipo')

            //$('file_filtro').value = '*.pdf'
            campos_defs.set_value('file_max_size', 10)

            $('request_usr').checked = ''
            onclick_request_usr()
            grupos_cargar(-1)

            campos_defs.clear('nro_venc_tipo')
            campos_defs.clear('venc_dias')
            campos_defs.clear('venc_function')

            campos_defs.clear('f_nro_ubi')
            campos_defs.clear('f_path')
        }
    }

    function grupos_cargar(indice) {
        grupos = new Array()
        var k = 0
        var rs = new tRS();
        var vacio
        rs.async = true
        rs.onComplete = function (rs) {
            while (!rs.eof()) {
                vacio = new Array()
                vacio['nro_archivo_def_grupo'] = rs.getdata('nro_archivo_def_grupo')
                vacio['archivo_def_grupo'] = ((rs.getdata('archivo_def_grupo') == null) || (rs.getdata('archivo_def_grupo') == '')) ? '' : rs.getdata('archivo_def_grupo')
                vacio['abreviacion'] = ((rs.getdata('abreviacion') == null) || (rs.getdata('abreviacion') == '')) ? '' : rs.getdata('abreviacion')
                grupos[k] = vacio
                k++
                rs.movenext()
            }
            grupos_dibujar(indice)
        }
        rs.open(filtroGrupo)
    }

    function grupos_dibujar(indice) {
        var agregar_grupo = ''
        var archivo_def_grupo = ''
        var abreviacion = ''
        if (grupos.length >= 0) 
        {
            $('div_grupos').innerHTML = ''

            var strHTML = '<table id="tb_archivos_def_grupo_det" class="tb1" style="width:100%;">'
//            strHTML += '<tr class="tbLabel0">'
//            strHTML += '<td style="width:5%;text-align:center">-</td>'
//            strHTML += '<td style="width:10%;text-align:center">Id Grupo</td>'
//            strHTML += '<td style="width:65%;text-align:center">Grupo</td>'
//            strHTML += '<td style="width:20%;text-align:center">Abreviación</td>'
//            strHTML += '</tr>'

            grupos.each(function (arreglo, i) {

                agregar_grupo = '<input type="checkbox" name="agregar_grupo" id="grupo_' + arreglo['nro_archivo_def_grupo'] + '" value="' + arreglo['nro_archivo_def_grupo'] + '" style="border:none"></input>'

                archivo_def_grupo = arreglo['archivo_def_grupo']
                archivo_def_grupo = (archivo_def_grupo.length > 50) ? archivo_def_grupo.substr(0, 50) : archivo_def_grupo
                abreviacion = arreglo['abreviacion']
                abreviacion = (abreviacion.length > 30) ? abreviacion.substr(0, 30) : abreviacion

                strHTML += '<tr>'
                strHTML += "<td style='width:5%;text-align:center'>" + agregar_grupo + "</td>"
                strHTML += '<td style="width:10%;text-align:center">' + arreglo['nro_archivo_def_grupo'] + '</input></td>'
                strHTML += '<td style="width:65%;text-align:left" title="' + arreglo['archivo_def_grupo'] + '">' + archivo_def_grupo + '</td>'
                strHTML += '<td style="width:18%;text-align:left" title="' + arreglo['abreviacion'] + '">' + abreviacion + '</td>'                
                strHTML += '</tr>'
            });
            strHTML += '</table>'

            $('div_grupos').insert({ top: strHTML })

            var nro_archivo_def_grupo
            var archivos_def_grupo_det = new Array()
            if (indice >= 0 && archivos[indice]['grupos'].length > 0) {
                archivos_def_grupo_det = archivos[indice]['grupos'].split(',')
                if (archivos_def_grupo_det.length > 0) {
                    var k = 0
                    while (k < archivos_def_grupo_det.length) {
                        nro_archivo_def_grupo = 'grupo_' + archivos_def_grupo_det[k]
                        $(nro_archivo_def_grupo).checked = true
                        k++;
                    }
                }              
            }
        }
    }

    function archivos_def_detalle_abm(accion) {
        //Nuevo archivo def detalle

        if (accion == 'N') {
            $('indice').value = -1
            cargar_archivos_def_detalle()
        }
    }

    function onclick_request_usr() { 
        if ($('request_usr').checked) {
            campos_defs.habilitar('ppi', true)
            campos_defs.habilitar('nro_depthcolor', true)
        }
        else {
            campos_defs.clear('ppi')
            campos_defs.clear('nro_depthcolor')
            campos_defs.habilitar('ppi', false)
            campos_defs.habilitar('nro_depthcolor', false)
        }
    }

    //ABM Tipos de Archivos Def
    var win_archivos_def_tipo_abm
    function archivos_def_tipo_abm(nro_archivo_def_tipo) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_tipo_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_tipo_ABM.aspx?nro_archivo_def_tipo=' + nro_archivo_def_tipo,
            title: '<b>ABM Tipo de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 700,
            height: 200,
            onClose: function () {
                campos_defs.items['nro_def_tipo']['input_select'].options.length = 0
            }
        });

        win_archivos_def_tipo_abm.options.userData = { nro_archivo_def_tipo: nro_archivo_def_tipo }
        win_archivos_def_tipo_abm.showCenter()
    }

    //ABM Perfil Archivos Def
    var win_archivos_def_perfil_abm
    function archivos_def_perfil_abm(nro_archivo_def_perfil) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_perfil_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_perfil_ABM.aspx?nro_archivo_def_perfil=' + nro_archivo_def_perfil,
            title: '<b>ABM Perfil de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 700,
            height: 200,
            onClose: function () {
                campos_defs.items['nro_def_perfil']['input_select'].options.length = 0
            }
        });

        win_archivos_def_perfil_abm.options.userData = { nro_archivo_def_perfil: nro_archivo_def_perfil }
        win_archivos_def_perfil_abm.showCenter()
    }

  //------------------------------------------------//
 //--------------------RESOLVER--------------------//
//------------------------------------------------//

        function clear() {
            $('td1').innerHTML = ''
            $('td2').innerHTML = ''
            $('td3').innerHTML = ''
            $('td4').innerHTML = ''
            $('td5').innerHTML = ''
            //$('td6').innerHTML = ''
            $('td7').innerHTML = ''
        }

        function mostrar_datos_perf() {
        var rs = new tRS()
        var desc_def_perfil = campos_defs.get_value('nro_def_perfil')


        if (desc_def_perfil == '') {
            clear()
            return
            }
            var rs = campos_defs.items["nro_def_perfil"].rs
            rs.position = campos_defs.items["nro_def_perfil"].input_select.selectedIndex-1
            
            $('td1').innerHTML = rs.getdata('id')
            $('td2').innerHTML = rs.getdata('resolucion')
            $('td3').innerHTML = rs.getdata('tipo_color')
            $('td4').innerHTML = rs.getdata('formato')
            $('td5').innerHTML = rs.getdata('multipagina')
            //$('td6').innerHTML = rs.getdata('archivo_def_perfil')
            $('td7').innerHTML = rs.getdata('compresion')

        //rs.open({
        //    filtroXML: nvFW.pageContents.filtroPerf,
        //    filtroWhere: "<criterio><select><campos>*</campos><orden></orden><filtro><id type='igual'>" + desc_def_perfil + "</id></filtro></select></criterio>"
        //})
        //clear()
        //var html = ''
        //if (desc_def_perfil != '') {
        //    while (!rs.eof()) {

        //        $('td1').innerHTML = rs.getdata('id')
        //        $('td2').innerHTML = rs.getdata('resolucion')
        //        $('td3').innerHTML = rs.getdata('tipo_color')
        //        $('td4').innerHTML = rs.getdata('formato')
        //        $('td5').innerHTML = rs.getdata('multipagina')
        //        $('td6').innerHTML = rs.getdata('archivo_def_perfil')
        //        $('td7').innerHTML = rs.getdata('compresion')
        //        rs.movenext()
        //    }
            
        //} 
        }

    //ABM Colores
    var win_img_depthcolor_abm
    function img_depthcolor_abm(nro_depthcolor) {
        
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_img_depthcolor_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/img_depthcolor_ABM.aspx?nro_depthcolor=' + nro_depthcolor,
            title: '<b>ABM Color</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 700,
            height: 200,
            onClose: function () {
                if ($('request_usr').checked)
                    campos_defs.items['nro_depthcolor']['input_select'].options.length = 0
            }
        });

        win_img_depthcolor_abm.options.userData = { nro_depthcolor: nro_depthcolor }
        win_img_depthcolor_abm.showCenter()
    }

    //Arma la información del arreglo con el Detalle de los archivos de la Definición
    function actualizar_archivos_def_detalle() 
    {
        
        //var indice = $('indice').value == '' ? -1 : $('indice').value

        var nro_def_detalle = $('nro_def_detalle').value == '' ? 0 : $('nro_def_detalle').value
        var archivo_descripcion = $('archivo_descripcion').value      

        //Busco la descripción del "Perfil" de escaneo seleccionado para agregarla al arreglo.
        var nro_def_perfil = campos_defs.get_value('nro_def_perfil')
        var archivo_def_perfil = ''
        if (nro_def_perfil != '') {
            var rs = new tRS()
            
            var params0 = "<criterio><params nro_def_perfil='" + nro_def_perfil + "'/></criterio>"
            rs.open(filtroPerfil, '', '', '', params0)

            if (!rs.eof())
                archivo_def_perfil = rs.getdata('archivo_def_perfil')
        }

        //Busco la descripción del "Tipo" de archivo seleccionado para agregarlo al arreglo.
        var nro_archivo_def_tipo = campos_defs.get_value('nro_def_tipo')
        var archivo_def_tipo = ''
        if (nro_archivo_def_tipo != '') {
            var rs1 = new tRS()
            
            var params1 = "<criterio><params nro_archivo_def_tipo='" + nro_archivo_def_tipo + "'/></criterio>"
            rs1.open(filtroTipo, '', '', '', params1)

            if (!rs1.eof())
                archivo_def_tipo = rs1.getdata('archivo_def_tipo')
        }

        var file_filtro = $('file_filtro').value
        var file_max_size = campos_defs.get_value('file_max_size')*1000000

        var request_usr = $('request_usr').checked ? 'True' : 'False'
        var ppi = (request_usr == 'True') ? campos_defs.get_value('ppi') : null
        var nro_depthcolor = (request_usr == 'True') ? campos_defs.get_value('nro_depthcolor') : null

        var nro_venc_tipo = campos_defs.get_value('nro_venc_tipo')
        var venc_dias = campos_defs.get_value('venc_dias')
        var venc_function = $('venc_function_desc').value

        var f_nro_ubi = $('f_nro_ubi').value
        var f_path = $('f_path').value

        var str_error = ''

        //Controlar que no haya mas de un Detalle con el mismo "Tipo" de archivo
        //var tipo_repetido = 0
        //archivos.each(function (arreglo, i) {
        //    if ((i != indice) && (nro_archivo_def_tipo != '') && (arreglo['nro_archivo_def_tipo'] == nro_archivo_def_tipo))
        //        tipo_repetido++
        //});

        //Cuando el tipo de archivo es "Sin definición (0)", la descripción puede ir vacía. En otro caso, SE DEBE especificar una descripción
        if (archivo_descripcion == '' && nro_archivo_def_tipo != 0)
            str_error += 'Debe ingresar "Descripción".</br>';
        if (file_max_size == '')
            str_error += 'Debe ingresar "Tamaño Máximo" de archivo.</br>';
        if (nro_archivo_def_tipo == '')
            str_error += 'Debe seleccionar un "Tipo" de archivo.</br>';
        //if (tipo_repetido > 0)
          //  str_error += 'Existe otro detalle con el mismo "Tipo" de archivo seleccionado. Una definición no puede tener "Tipos" de archivos repetidos.</br>';
        if (f_nro_ubi == 2 && f_path == '')
            str_error += 'Debe ingresar el "Path" de la ubicación.</br>';

        if (str_error != '') {
            alert(str_error)
            return
        }

        //Cuando se da de alta un nuevo Archivo Detalle
        var orden = $('orden').value == '' ? 0 : $('orden').value
        if (indice < 0) {
            indice = archivos.length
            archivos[indice] = new Array()
            
            if (orden > 0)
                archivos[indice]['orden'] = orden
            else
                archivos[indice]['orden'] = (indice > 0) ? parseInt(archivos[indice - 1]['orden']) + 1 : 1

            archivos[indice]['estado'] = 'NUEVO'
        } else {
            archivos[indice]['orden'] = orden
            archivos[indice]['estado'] = (nro_def_detalle == 0) ? 'NUEVO' : 'EDITADO'
        }

        archivos[indice]['nro_def_detalle'] = nro_def_detalle        
        archivos[indice]['archivo_descripcion'] = archivo_descripcion

        archivos[indice]['readonly'] = $('readonly').checked ? 'True' : 'False'
        archivos[indice]['file_filtro'] = file_filtro
        archivos[indice]['file_max_size'] = file_max_size 

        archivos[indice]['perfil'] = nro_def_perfil
        archivos[indice]['archivo_def_perfil'] = archivo_def_perfil

        archivos[indice]['requerido'] = $('requerido').checked ? 'True' : 'False'
        archivos[indice]['reutilizable'] = $('reutilizable').checked ? 'True' : 'False'
        archivos[indice]['repetido'] = $('repetido').checked ? 'True' : 'False'
        archivos[indice]['print_auto'] = $('print_auto').checked ? 'True' : 'False'

        archivos[indice]['nro_archivo_def_tipo'] = nro_archivo_def_tipo
        archivos[indice]['archivo_def_tipo'] = archivo_def_tipo

        archivos[indice]['request_usr'] = request_usr
        archivos[indice]['ppi'] = ppi
        archivos[indice]['nro_depthcolor'] = nro_depthcolor


        var grupos = ''
        var input
        var id
        for (i = 0; i < document.getElementsByTagName("input").length; i++) {
            input = document.getElementsByTagName("input")[i]
            if (input.type == "checkbox" && input.name == "agregar_grupo") {
                if (input.checked) {
                    id = input.id.split('_')[0]
                    nro_archivo_def_grupo = input.id.split('_')[1]
                    if (id == 'grupo') {
                        grupos = (grupos == '') ? nro_archivo_def_grupo : grupos + ',' + nro_archivo_def_grupo
                    }
                }
            }
        }
        archivos[indice]['grupos'] = grupos

        archivos[indice]['nro_venc_tipo'] = nro_venc_tipo == 'undefined' ? 0 : nro_venc_tipo
        archivos[indice]['venc_dias'] = venc_dias == 'undefined' ? 0 : venc_dias
        archivos[indice]['venc_function'] = venc_function

        archivos[indice]['f_nro_ubi'] = f_nro_ubi
        archivos[indice]['f_path'] = f_path

        var win = nvFW.getMyWindow()
        win.options.userData = { archivos: archivos }
        win.close();

        /////ABM PARAMS//////

        if (!params) {
            var paramsABM = {
                'archivo_desc': '',
                'xml': ''
            }
            paramsXML = JSON.parse(sessionStorage.getItem("paramsXML"))
            paramsXML.push(paramsABM)
            sessionStorage.setItem("paramsXML", JSON.stringify(paramsXML))


            //console.log(paramsABM)
            //JSON.parse(sessionStorage.getItem("paramsXML")).push(paramsABM)
            //console.log(JSON.parse(sessionStorage.getItem("paramsXML")))
            //hola = JSON.parse(sessionStorage.getItem("paramsXML"))

            /*
            nvFW.error_ajax_request('archivos_def_detalle_ABM.aspx', {
                parameters: { archivo_descripcion: $('archivo_descripcion').value, strXML: strXML, modo: "ALTAPARAM" },
                onSuccess: function (err, transport) {

                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    winParam_def.close()
                },
                error_alert: true
            });
            */
        } else {
            strXML = "<param_def>"
            params.each(function (arr, i) {
                strXML += "<param parametro = '" + arr.parametro + "' visible = '" + arr.visible + "' orden= '" + arr.orden + "' tipo_dato= '" + arr.tipo_dato + "' requerido= '" + arr.requerido + "' editable = '" + arr.editable + "'>"
                strXML += "<valor_defecto><![CDATA[" + arr.valor_defecto + "]]></valor_defecto>"
                strXML += "<etiqueta><![CDATA[" + arr.etiqueta + "]]></etiqueta></param>"
            });
            strXML += "</param_def>"

            var paramsABM = {
                'archivo_desc': $('archivo_descripcion').value,
                'xml': strXML
            }
            paramsXML = JSON.parse(sessionStorage.getItem("paramsXML"))
            paramsXML.push(paramsABM)
            sessionStorage.setItem("paramsXML", JSON.stringify(paramsXML))

        }
    }

    function setDias() {
        if ($('nro_venc_tipo').value == 1) {
            $('venc_dias').value = 365
            cleanCampoFunction()
        } else if ($('nro_venc_tipo').value == 2) {
            $('venc_dias').value = 30
            cleanCampoFunction()
        } else if ($('nro_venc_tipo').value == 3) {
            $('venc_dias').value = ''
            $('venc_function_desc').value = ''
            campos_defs.habilitar('venc_function', true)
        } else {
            cleanCampoFunction()
            $('venc_dias').value = ''
        }
    }

    function cleanCampoFunction() {
        $('venc_function').value = ''
        $('venc_function_desc').value = ''
        campos_defs.habilitar('venc_function', false)
    }

    function pathAbil() {
        if ($('f_nro_ubi').value == 1) {
            campos_defs.clear('f_path')
            campos_defs.habilitar('f_path', false)
        } else if ($('f_nro_ubi').value == 2) {
            campos_defs.habilitar('f_path', true)
        } else if ($('f_nro_ubi').value == '') {
            campos_defs.clear('f_path')
            campos_defs.habilitar('f_path', false)
        }
    }

     ///////////////////////////////////
    //******Muestra parametros*******//
   ///////////////////////////////////
    function mostrar_param(params) {
        if (!params) {
            var strCriterio = nvFW.pageContents.filtro_archivos_parametros
            var rs = new tRS();
            rs.open(strCriterio, "", "<archivo_descripcion type='igual'>'" + $('archivo_descripcion').value + "'</archivo_descripcion>", "", "")
            var strHTMLparams = '<table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr></tr>'//'<table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr class="tbLabel0"><td>Par&aacute;metro</td><td>Etiqueta</td></tr>'
            while (!rs.eof()) {
                strHTMLparams += '<tr><td style="width:40%">' + rs.getdata('parametro') + '</td>'
                strHTMLparams += '<td style="width:60%">' + rs.getdata('etiqueta') + '</td></tr>'
                rs.movenext()
            }
            strHTMLparams += '</table>'
            //console.log(strHTMLparams)
            $('parametros_detalle').innerHTML = strHTMLparams
        } else {
            var strHTMLparams = '<table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr></tr>' //'<table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr class="tbLabel0"><td>Par&aacute;metro</td><td>Etiqueta</td></tr>'
            params.each(function (arreglo, i) {
                strHTMLparams += '<tr><td>' + arreglo['parametro'] + '</td>'
                strHTMLparams += '<td>' + arreglo['etiqueta'] + '</td></tr>'
            })
            strHTMLparams += '</table>'
            //console.log(strHTMLparams)
            $('parametros_detalle').innerHTML = strHTMLparams
        }
    }

        var winParam_def
        function param_def_abm() {

            var param = []
           
            if (!params) {
                var strCriterio = nvFW.pageContents.filtro_archivos_parametros
                var rs = new tRS();
                rs.open(strCriterio, "", "<archivo_descripcion type='igual'>'" + $('archivo_descripcion').value + "'</archivo_descripcion>", "", "")
                while (!rs.eof()) {
                    parametro = {}
                    parametro = new tParam_def({
                        parametro: rs.getdata('parametro'),
                        tipo_dato: rs.getdata('tipo_dato'),
                        etiqueta: rs.getdata('etiqueta'),
                        requerido: rs.getdata('requerido').toLowerCase() == 'true',
                        editable: rs.getdata('editable').toLowerCase() == 'true',
                        visible: rs.getdata('visible').toLowerCase() == 'true',
                        valor_defecto: rs.getdata('valor_defecto')
                    })

                    param.push(parametro);
                    rs.movenext()
                }
            } else {
                params.each(function (arreglo, i) {
                    parametro = {}

                    parametro = new tParam_def({
                        parametro: arreglo['parametro'],
                        tipo_dato: arreglo['tipo_dato'],
                        etiqueta: arreglo['etiqueta'],
                        requerido: arreglo['requerido'],
                        editable: arreglo['editable'],
                        visible: arreglo['visible'],
                        valor_defecto: arreglo['valor_defecto']
                    })
                    param.push(parametro);
                })
            }

            var options = {
                title: "<b>Editar Parámetros</b>",
                maximizable: true,
                minimizable: false,
                /*  centerHFromElement: $$("BODY")[0],
                  parentWidthElement:$$("BODY")[0],
                  parentWidthPercent: 0.9,
                  parentHeightElement: $$("BODY")[0],
                  parentHeightPercent: 0.9,*/
                height: 500,
                width: 980,
                resizable: true,
                destroyOnClose: true,
                title: '<b>Parámetros Def Archivo</b>',
                modal: true,
                drawButtonSave: true
            }

            winParam_def = window.top.nvFW.param_def_edit(param, function () { onSave(); }, options)

        }

        function onSave() {

            params = winParam_def.options.userData.params
            //console.log(params)

            //validacion personalizada
            //guardar
            //strXML = "<param_def>"
            //params.each(function (arr, i) {
            //    strXML += "<param parametro = '" + arr.parametro + "' visible = '" + arr.visible + "' orden= '" + arr.orden + "' tipo_dato= '" + arr.tipo_dato + "' requerido= '" + arr.requerido + "' editable = '" + arr.editable + "'>"
            //    strXML += "<valor_defecto><![CDATA[" + arr.valor_defecto + "]]></valor_defecto>"
            //    strXML += "<etiqueta><![CDATA[" + arr.etiqueta + "]]></etiqueta></param>"
            //});
            //strXML += "</param_def>"

            //nvFW.error_ajax_request('archivos_def_detalle_ABM.aspx', {
            //    parameters: { archivo_descripcion: $('archivo_descripcion').value, strXML: strXML, modo: "ALTAPARAM" },
            //    onSuccess: function (err, transport) {

            //        if (err.numError != 0) {
            //            alert(err.mensaje)
            //            return
            //        }
            //        winParam_def.close()
            //    },
            //    error_alert: true
            //});
            var archivo_desc = $('archivo_descripcion').value
            //sessionStorage.getItem("archivo_desc","archivo_desc")
            //sessionStorage.setItem("params", JSON.stringify(params))
            mostrar_param(params)
            winParam_def.close()
            return params
        }


    </script>
</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frmArchivosDefDetalleABM" action="/fw/def_archivos/archivos_def_detalle_ABM.aspx" method="post" style='width:100%;height:100%;overflow:hidden'>
    

    <div id="divMenuArchivosDefDetalleABM" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuArchivosDefDetalleABM = new tMenu('divMenuArchivosDefDetalleABM', 'vMenuArchivosDefDetalleABM');
        vMenuArchivosDefDetalleABM.loadImage("guardar", "/fw/image/icons/guardar.png")
        vMenuArchivosDefDetalleABM.loadImage("nuevo", "/fw/image/icons/nueva.png")
        vMenuArchivosDefDetalleABM.loadImage("hoja", "/fw/image/icons/nueva.png")
        Menus["vMenuArchivosDefDetalleABM"] = vMenuArchivosDefDetalleABM
        Menus["vMenuArchivosDefDetalleABM"].alineacion = 'centro';
        Menus["vMenuArchivosDefDetalleABM"].estilo = 'A';
        Menus["vMenuArchivosDefDetalleABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>actualizar_archivos_def_detalle()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuArchivosDefDetalleABM"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuArchivosDefDetalleABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_detalle_abm('N')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuArchivosDefDetalleABM"].CargarMenuItemXML("<MenuItem id='3' style='widtdh: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo Perfil</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_perfil_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuArchivosDefDetalleABM"].CargarMenuItemXML("<MenuItem id='4' style='widdth: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo Tipo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_tipo_abm(-1)</Codigo></Ejecutar></Acciones></MenuItem>")
       //Menus["vMenuArchivosDefDetalleABM"].CargarMenuItemXML("<MenuItem id='5' style='widdth: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>parametros ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>param_def_abm()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuArchivosDefDetalleABM.MostrarMenu()
    </script>
        
    <table class="tb1" id="tb_archivos_def_detalle">
        <tr class="tbLabel">
            <td style="width:10%; text-align:center">Nro. Def.</td> 
            <td style="width:40%; text-align:center">Descripción</td>
            <td style="width:40%; text-align:center">Tipo</td>
            <td style="width:10%; text-align:center">Orden</td> 
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:center"><input type="text" name="nro_def_detalle" id="nro_def_detalle" style="width:100%;text-align:center;" disabled="disabled" value=""/></td>
            <td style="vertical-align:middle; text-align:left"><input type="text" name="archivo_descripcion" id="archivo_descripcion" style="width:100%;" /></td>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('nro_def_tipo')
                </script>
            </td>
            <td style="vertical-align:middle; text-align:center">
                    <script type="text/javascript">
                        campos_defs.add('orden', { enDB: false, nro_campo_tipo: 101 })
                    </script>            
            </td>
        </tr>
    </table>
    <table class="tb1" id="tb_archivos_def_detalle2">
        <tr class="tbLabel">
            <td style="width:20%; text-align:center">Solo Lectura</td> 
            <td style="width:20%; text-align:center">Requerido</td>
            <td style="width:20%; text-align:center">Reutilizable</td> 
            <td style="width:20%; text-align:center">Repetido</td> 
            <td style="width:20%; text-align:center">Impresión automática</td> 
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='readonly' name='readonly' /></td>
            <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='requerido' name='requerido' /></td>
            <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='reutilizable' name='reutilizable' /></td>
            <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='repetido' name='repetido' /></td>
            <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='print_auto' name='print_auto' /></td>
        </tr>
    </table>
    <div id="divMenuArchivosUbiABM" style="width:100%"></div>
    <script type="text/javascript">
        var vMenuArchivosABM = new tMenu('divMenuArchivosUbiABM', 'vMenuArchivosUbiABM');
        Menus["vMenuArchivosUbiABM"] = vMenuArchivosABM
        Menus["vMenuArchivosUbiABM"].alineacion = 'centro';
        Menus["vMenuArchivosUbiABM"].estilo = 'A';
        Menus["vMenuArchivosUbiABM"].CargarMenuItemXML("<MenuItem id='0' style='width:'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Ubicación</Desc></MenuItem>")
        vMenuArchivosABM.MostrarMenu()
    </script>
    <table class="tb1">
        <tr class="tbLabel">
            <td style="width:30%; text-align:center">Ubicación</td> 
            <td style="width:50%; text-align:center;">Path</td>
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('f_nro_ubi', {
                        filtroXML: nvFW.pageContents.filtroUbicacion,
                        enDB: false,
                        nro_campo_tipo: 1
                    })

                    campos_defs.items['f_nro_ubi'].onchange = function (campo_def) {
                        pathAbil()
                    }

                </script>
            </td>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('f_path', { enDB: false, nro_campo_tipo: 104 })
                    campos_defs.habilitar('f_path', false)
                </script>
            </td>           
        </tr>
    </table>
        <div id="divMenuArchivosVencABM" style="width:100%"></div>
    <script type="text/javascript">
        var vMenuArchivosABM = new tMenu('divMenuArchivosVencABM', 'vMenuArchivosVencABM');
        Menus["vMenuArchivosVencABM"] = vMenuArchivosABM
        Menus["vMenuArchivosVencABM"].alineacion = 'centro';
        Menus["vMenuArchivosVencABM"].estilo = 'A';
        Menus["vMenuArchivosVencABM"].CargarMenuItemXML("<MenuItem id='0' style='width:'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Configuracion de Vencimiento</Desc></MenuItem>")
        vMenuArchivosABM.MostrarMenu()
    </script>
    <table class="tb1">
        <tr class="tbLabel">
            <td style="width:50%; text-align:center">Tipo</td> 
            <td style="width:20%; text-align:center;">Dias</td><td style="width:30%; text-align:center;">Funcion</td>
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('nro_venc_tipo', {
                        filtroXML: nvFW.pageContents.filtroVencimiento,
                        enDB: false,
                        nro_campo_tipo: 1
                    })

                    campos_defs.items['nro_venc_tipo'].onchange = function (campo_def) {
                        setDias()
                    }

                </script>
            </td>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('venc_dias', { enDB: false, nro_campo_tipo: 101  })
                </script>
            </td>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('venc_function', {
                        filtroXML: nvFW.pageContents.filtroFunciones,
                        enDB: false,
                        nro_campo_tipo: 1
                    })
                    campos_defs.habilitar('venc_function', false)
                </script>
            </td>
            
        </tr>
    </table>
    <div id="divMenuArchivosABM" style="width:100%"></div>
    <script type="text/javascript">
        var vMenuArchivosABM = new tMenu('divMenuArchivosABM', 'vMenuArchivosABM');        
        Menus["vMenuArchivosABM"] = vMenuArchivosABM
        Menus["vMenuArchivosABM"].alineacion = 'centro';
        Menus["vMenuArchivosABM"].estilo = 'A';
        Menus["vMenuArchivosABM"].CargarMenuItemXML("<MenuItem id='0' style='width: 38%%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Perfiles de Archivos</Desc></MenuItem>")  
        Menus["vMenuArchivosABM"].CargarMenuItemXML("<MenuItem id='1' style='width: 62%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>") 
        vMenuArchivosABM.MostrarMenu()
    </script>
    <table class="tb1" id="tb_archivos_def_detalle1">
        <tr class="tbLabel">
            <td style="width:38%; text-align:center">Perfil</td> 
            <td style="width:10%; text-align:center;">ID</td><td style="width:10%; text-align:center;">Resolucion</td><td style="width:10%; text-align:center;">Tipo</td><td style="width:10%; text-align:center;">Formato</td><td style="width:10%; text-align:center;">Multipagina</td><%--<td style="width:">Definicion</td>--%><td style="width:10%; text-align:center;">Compresión</td>
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('nro_def_perfil')
                    campos_defs.items['nro_def_perfil'].onchange = function (campo_def) {
                        mostrar_datos_perf()
                    }

                </script>
            </td>
            <td id="td1" style="text-align:center; border-right:1px solid grey; border-left:1px solid grey; border-radius:0;"></td>
            <td id="td2" style="text-align:center; border-right:1px solid grey; border-radius:0;"></td>
            <td id="td3" style="text-align:center; border-right:1px solid grey; border-radius:0;"></td>
            <td id="td4" style="text-align:center; border-right:1px solid grey; border-radius:0;"></td>
            <td id="td5" style="text-align:center; border-right:1px solid grey; border-radius:0;"></td>
            <%--<td id="td6" style="text-align:center; border-right:1px solid grey; border-radius:0;"></td>--%>
            <td id="td7" style="text-align:center; border-right:1px solid grey; border-radius:0;"></td>
        </tr>
    </table>
    <table class="tb1" id="tb_archivos_def_detalle3">
        <tr class="tbLabel">
            <td style="width:80%; text-align:center">Filtro Upload</td> 
            <td style="width:20%; text-align:center">Tamaño en Mb</td>
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:left"><input type="text" name="file_filtro" id="file_filtro" value="" placeholder="Ej. .pdf | .html" style="width:100%;" /></td>
            <td style="vertical-align:middle; text-align:center">
                    <script type="text/javascript">
                        campos_defs.add('file_max_size', { enDB: false, nro_campo_tipo: 102 })
                        //$('file_max_size').style.text-aling = 'center'
                    </script>            
            </td>
        </tr>
    </table>
    <div id="divMenuArchivosColor" style="width:100%"></div>
    <script type="text/javascript" language="javascript">
        var vMenuArchivosColor = new tMenu('divMenuArchivosColor', 'vMenuArchivosColor');
        vMenuArchivosColor.loadImage("hoja", "/fw/image/icons/nueva.png")
        Menus["vMenuArchivosColor"] = vMenuArchivosColor
        Menus["vMenuArchivosColor"].alineacion = 'centro';
        Menus["vMenuArchivosColor"].estilo = 'A';
        Menus["vMenuArchivosColor"].CargarMenuItemXML("<MenuItem id='0' style='width: 93%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Opciones de Escaner (nvCliente)</Desc></MenuItem>")
        Menus["vMenuArchivosColor"].CargarMenuItemXML("<MenuItem id='1' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo Color</Desc><Acciones><Ejecutar Tipo='script'><Codigo>img_depthcolor_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuArchivosColor.MostrarMenu()
    </script>
    <table class="tb1" id="tb_archivos_def_detalle4">
        <tr class="tbLabel">
            <td style="width:33%; text-align:center">¿Requerir resolución?</td> 
            <td style="width:33%; text-align:center">dpi</td>
            <td style="width:33%; text-align:center">Profundidad de Color</td> 
        </tr>
        <tr>
            <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='request_usr' name='request_usr' onclick='return onclick_request_usr()' /></td>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('ppi', { enDB: false, nro_campo_tipo: 101 })
                </script>            
            </td>
            <td style="vertical-align:middle; text-align:center">
                <script type="text/javascript">
                    campos_defs.add('nro_depthcolor', { despliega: 'arriba'})
                </script>
            </td>                
        </tr>
    </table>
    <div id="divMenuGrupoABM" style="width:100%"></div>
    <script type="text/javascript">
        var vMenuGrupoABM = new tMenu('divMenuGrupoABM', 'vMenuGrupoABM');
        Menus["vMenuGrupoABM"] = vMenuGrupoABM
        Menus["vMenuGrupoABM"].alineacion = 'centro';
        Menus["vMenuGrupoABM"].estilo = 'A';
        Menus["vMenuGrupoABM"].CargarMenuItemXML("<MenuItem id='0' style='width:'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Grupos</Desc></MenuItem>")
        vMenuGrupoABM.MostrarMenu()
    </script>
    <table id="tb_archivos_def_grupo_cab" class="tb1" style="width:100%;">
        <tr class="tbLabel0">
            <td style="width:5%;text-align:center">-</td>
            <td style="width:10%;text-align:center">Id Grupo</td>
            <td style="width:65%;text-align:center">Grupo</td>
            <td style="width:20%;text-align:center">Abreviación</td>
        </tr>
    </table>
    <div id="div_grupos" style="width:100%;overflow-y: auto; max-height:48px;"></div> 
    <div id="divMenuABMParams" style="width:100%"></div>
    <script type="text/javascript">
        var vMenuABMParams = new tMenu('divMenuABMParams', 'vMenuABMParams');
        vMenuABMParams.loadImage("hoja", "/fw/image/icons/nueva.png")
        Menus["vMenuABMParams"] = vMenuABMParams
        Menus["vMenuABMParams"].alineacion = 'centro';
        Menus["vMenuABMParams"].estilo = 'A';
        Menus["vMenuABMParams"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Parametros</Desc></MenuItem>")
        Menus["vMenuABMParams"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>param_def_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuABMParams.MostrarMenu()
    </script>
    <table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr class="tbLabel0"><td style="width:39%">Par&aacute;metro</td><td style="width:60%">Etiqueta</td></tr></table>
    <div id="parametros_detalle" style="width:100%;overflow-y:auto;max-height:111px"></div>
</form>
</body>
</html>
