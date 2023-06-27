<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%


    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If Not op.tienePermiso("permisos_def_archivo", 1) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.mostrar_error()
    End If

    Dim nro_def_archivo As String = nvFW.nvUtiles.obtenerValor("nro_def_archivo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "VA"
    End If

    Me.contents("filtroArchivoCab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_cab'><campos>nro_def_archivo,def_archivo,def_fe_baja</campos><filtro><nro_def_archivo type='igual'>%nro_def_archivo%</nro_def_archivo></filtro></select></criterio>")
    Me.contents("filtroGrupoDet") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo_det'><campos>nro_archivo_def_grupo</campos><filtro><nro_def_detalle type='igual'>%nro_def_detalle%</nro_def_detalle></filtro><orden>nro_archivo_def_grupo</orden></select></criterio>")
    Me.contents("filtroArchivoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_def_detalle'><campos>nro_def_detalle,nro_def_archivo,orden,archivo_descripcion,readonly,file_filtro,file_max_size,perfil,archivo_def_perfil,requerido,reutilizable,repetido,print_auto,nro_archivo_def_tipo,archivo_def_tipo,request_usr,ppi,nro_depthcolor,nro_venc_tipo,venc_dias,venc_function,f_nro_ubi,f_path</campos><filtro><nro_def_archivo type='igual'>%nro_def_archivo%</nro_def_archivo></filtro><orden>%campo_orden%" + " " + "%sentido_orden%</orden></select></criterio>")
    Me.contents("filtroArchivo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos'><campos>COUNT(*) as cant_archivos</campos><filtro><nro_def_detalle type='igual'>%nro_def_detalle%</nro_def_detalle><nro_archivo_estado type='igual'>1</nro_archivo_estado></filtro></select></criterio>")

    Dim err = New nvFW.tError()
    Dim strXML = HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""))

    If (modo.ToUpper <> "VA") Then
        Try
            If Not op.tienePermiso("permisos_def_archivo", 2) Then
                Dim errPerm = New tError()
                errPerm.numError = -1
                errPerm.titulo = "No se pudo completar la operación. "
                errPerm.mensaje = "No tiene permisos para Alta ni Edición."
                errPerm.mostrar_error()
            End If

            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "archivos_def_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = strXML.Length
            Cmd.Parameters("@strXML").value = strXML

            Dim rs = Cmd.Execute()

            Dim NumError As Integer = rs.Fields.Item("numError").Value
            err.params.Add("nro_def_archivo", rs.Fields("nro_def_archivo").Value)

            If NumError <> 0 Then
                err.numError = rs.Fields("numError").Value
                err.titulo = rs.Fields("titulo").Value
                err.mensaje = rs.Fields("mensaje").Value
                err.comentario = rs.Fields("mensaje").Value ' rs.Fields("comentario").Value
                nvDBUtiles.DBCloseRecordset(rs)
            End If

            If err.params("nro_def_archivo") <> "" Then
                err = nvArchivo.recalcacular_vencimientos_archivo_def(err.params("nro_def_archivo"))
            End If

        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al guardar la Definición de Archivos."
            err.mensaje = "No se actualizaron los datos." & vbCrLf & err.mensaje
        End Try

        err.response()
    End If

    Me.addPermisoGrupo("permisos_def_archivo")

%>
<html>
<head>
    <title>ABM Definición de Archivos</title>
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

    var filtroArchivoCab = nvFW.pageContents.filtroArchivoCab
    var filtroGrupoDet = nvFW.pageContents.filtroGrupoDet
    var filtroArchivoDef = nvFW.pageContents.filtroArchivoDef 
    var filtroArchivo = nvFW.pageContents.filtroArchivo

    var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    var archivos = new Array()
    var params
    var win = nvFW.getMyWindow()

    var paramsXML = []
    sessionStorage.setItem("paramsXML", JSON.stringify(paramsXML))

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuArchivosDefABM_h = $('divMenuArchivosDefABM').getHeight()
            tb_archivos_def_h = $('tb_archivos_def').getHeight()
            divMenuABMArchivosDefDetalle_h = $('divMenuABMArchivosDefDetalle').getHeight()
            $('div_archivos_def_detalle').setStyle({ 'height': body_height - divMenuArchivosDefABM_h - tb_archivos_def_h - divMenuABMArchivosDefDetalle_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() {
        cargar_archivos_def()
        window_onresize()
    }

    //Busca una Definición de Archivos
    function cargar_archivos_def() 
    {
        var nro_def_archivo = $('nro_def_archivo').value == '' ? 0 : $('nro_def_archivo').value

        if (nro_def_archivo > 0) {
            var rs = new tRS()

            var params = "<criterio><params nro_def_archivo='" + nro_def_archivo + "'/></criterio>"
            rs.open(filtroArchivoCab, '', '', '', params)
            
            if (!rs.eof()) {
                $('def_archivo').value = rs.getdata('def_archivo') == null ? '' : rs.getdata('def_archivo')
                $('def_archivo_aux').value = rs.getdata('def_archivo') == null ? '' : rs.getdata('def_archivo')
                $('chk_vigente').checked = rs.getdata('def_fe_baja') == null ? 'checked' : ''
                onclick_vigente()

                var def_fe_baja = rs.getdata('def_fe_baja') == null ? '' : FechaToSTR(parseFecha(rs.getdata('def_fe_baja')))                
                campos_defs.set_value('def_fe_baja', def_fe_baja)
            }

            cargar_archivos_def_detalle()

            /***
            accion = "Copiar como"
            Cuando se quiere copiar una definición de archivos existente, se setea en 0 el ID de la definición (nro_def_archivo),
            para dar de alta una nueva definición
            ***/
            if ($('accion').value == 'C')
                $('nro_def_archivo').value = 0
        }
    }

    //Busca todos los archivos de la Definición de Archivos (detalle)
    function cargar_archivos_def_detalle(orden, sentido) {

        var grupos = ''
        var campo_orden = 'orden'
        var sentido_orden = 'asc'
        if (orden != '' && orden != null && orden != undefined)
            campo_orden = orden
        if (sentido != '' && sentido != null && sentido != undefined)
            sentido_orden = sentido

        archivos = new Array()
        var nro_def_archivo = $('nro_def_archivo').value

        if ($('accion').value == 'C')
            nro_def_archivo = $('nro_def_archivo_aux').value

        if (nro_def_archivo > 0) {
            var k = 0
            var vacio
            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (rs) {
                while (!rs.eof()) {
                    vacio = new Array()
                    vacio['nro_def_detalle'] = rs.getdata('nro_def_detalle')
                    vacio['orden'] = rs.getdata('orden') == null ? '' : rs.getdata('orden')
                    vacio['archivo_descripcion'] = rs.getdata('archivo_descripcion') == null ? '' : rs.getdata('archivo_descripcion')
                    vacio['readonly'] = rs.getdata('readonly')
                    vacio['file_filtro'] = rs.getdata('file_filtro') == null ? '' : rs.getdata('file_filtro')
                    vacio['file_max_size'] = rs.getdata('file_max_size') == null ? '' : rs.getdata('file_max_size')
                    vacio['perfil'] = rs.getdata('perfil')
                    vacio['archivo_def_perfil'] = rs.getdata('archivo_def_perfil') == null ? '' : rs.getdata('archivo_def_perfil')
                    vacio['requerido'] = rs.getdata('requerido')
                    vacio['reutilizable'] = rs.getdata('reutilizable')
                    vacio['repetido'] = rs.getdata('repetido')
                    vacio['print_auto'] = rs.getdata('print_auto')
                    vacio['nro_archivo_def_tipo'] = rs.getdata('nro_archivo_def_tipo') == null ? '' : rs.getdata('nro_archivo_def_tipo')
                    vacio['archivo_def_tipo'] = rs.getdata('archivo_def_tipo') == null ? '' : rs.getdata('archivo_def_tipo')
                    vacio['request_usr'] = rs.getdata('request_usr') == null ? '' : rs.getdata('request_usr')
                    vacio['ppi'] = rs.getdata('ppi') == null ? '' : rs.getdata('ppi')
                    vacio['nro_depthcolor'] = rs.getdata('nro_depthcolor') == null ? '' : rs.getdata('nro_depthcolor')
                    vacio['estado'] = "GUARDADO"

                    /********************************************/
                    /*******************Detalle******************/
                    /********************************************/
                    grupos = ''
                    var rs1 = new tRS()                  
                    var params1 = "<criterio><params nro_def_detalle='" + rs.getdata('nro_def_detalle') + "'/></criterio>"
                    rs1.open(filtroGrupoDet, '', '', '', params1)

                    while (!rs1.eof()) 
                    {
                    grupos = (grupos == '') ? rs1.getdata('nro_archivo_def_grupo') : grupos + ',' + rs1.getdata('nro_archivo_def_grupo')
                    rs1.movenext()
                    }
                    vacio['grupos'] = grupos
                    /********************************************/

                    vacio['nro_venc_tipo'] = !rs.getdata('nro_venc_tipo') ? '' : rs.getdata('nro_venc_tipo')
                    vacio['venc_dias'] = !rs.getdata('venc_dias') ? '' : rs.getdata('venc_dias')
                    vacio['venc_function'] = !rs.getdata('venc_function') ? '' : rs.getdata('venc_function')

                    vacio['f_nro_ubi'] = rs.getdata('f_nro_ubi')
                    vacio['f_path'] = rs.getdata('f_path')

                    archivos[k] = vacio
                    k++
                    rs.movenext()
                }

                dibujar_cargar_archivos_def_detalle()
            }
            
            var params = "<criterio><params nro_def_archivo='" + nro_def_archivo + "' campo_orden = '" + campo_orden + "' sentido_orden = '" + sentido_orden + "'/></criterio>"
            rs.open(filtroArchivoDef, '', '', '', params)

        } else {
            dibujar_cargar_archivos_def_detalle()
        }
    }


    //Dibuja todos los archivos de la Definición de Archivos (detalle)
    function dibujar_cargar_archivos_def_detalle() 
    {
        if (archivos.length >= 0) {
            $('div_archivos_def_detalle').innerHTML = ''

            var strHTML = '<table id="tb_archivos_def_detalle" class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%; vertical-align: top;">'
            strHTML += '<tr class="tbLabel0">'
            strHTML += '<td style="width:18%;text-align:center"><a href="#" onclick="ordenar_desc(\'archivo_descripcion\')"><img src="/fw/image/icons/up_a.png" border="0" hspace="0"/></a><a href="#" onclick="ordenar_asc(\'archivo_descripcion\')"><img src="/fw/image/icons/down_a.png" border="0" hspace="0"/></a> Descripción</td>'
            //strHTML += '<td style="width:10%;text-align:center"><a href="#" onclick="ordenar_desc(\'archivo_def_perfil\')"><img src="/fw/image/icons/up_a.png" border="0" hspace="0"/></a><a href="#" onclick="ordenar_asc(\'archivo_def_perfil\')"><img src="/fw/image/icons/down_a.png" border="0" hspace="0"/></a> Perfil</td>'
            strHTML += '<td style="width:15%;text-align:center"><a href="#" onclick="ordenar_desc(\'archivo_def_tipo\')"><img src="/fw/image/icons/up_a.png" border="0" hspace="0"/></a><a href="#" onclick="ordenar_asc(\'archivo_def_tipo\')"><img src="/fw/image/icons/down_a.png" border="0" hspace="0"/></a> Tipo</td>'
            //strHTML += '<td style="width:8%;text-align:center">Filtro</td>'
            //strHTML += '<td style="width:7%;text-align:center">Tamaño</td>'
            strHTML += '<td style="width:8%;text-align:center">Solo Lectura</td>'
            strHTML += '<td style="width:8%;text-align:center">Requerido</td>'
            strHTML += '<td style="width:8%;text-align:center">Reutilizable</td>'
            strHTML += '<td style="width:8%;text-align:center">Repetido</td>'
            //strHTML += '<td style="width:8%;text-align:center">Print auto</td>'
            strHTML += '<td style="width:5%;text-align:center"><a href="#" onclick="ordenar_desc(\'orden\')"><img src="/fw/image/icons/up_a.png" border="0" hspace="0"/></a><a href="#" onclick="ordenar_asc(\'orden\')"><img src="/fw/image/icons/down_a.png" border="0" hspace="0"/></a> Orden</td>'
            strHTML += '<td style="width:2%;text-align:center">-</td>'
            strHTML += '<td style="width:2%;text-align:center">-</td>'
            strHTML += '</tr>'

            archivos.each(function (arreglo, i) {
                if (arreglo['estado'] != 'BORRADO') {
                    strHTML += '<tr>'
                    strHTML += '<td style="width:18%;text-align:left" title="' + arreglo['archivo_descripcion'] + '">' + arreglo['archivo_descripcion'] + '</td>'
                    //strHTML += '<td style="width:10%;text-align:left" title="' + arreglo['archivo_def_perfil'] + '">' + arreglo['archivo_def_perfil'] + '</td>'
                    strHTML += '<td style="width:15%;text-align:left" title="' + arreglo['archivo_def_tipo'] + '">' + arreglo['archivo_def_tipo'] + '</td>'
                    //strHTML += '<td style="width:8%;text-align:right" title="' + arreglo['file_filtro'] + '"><input type="hidden" id="file_filtro' + i + '"  value="' + arreglo['file_filtro'] + '" style="width:100%">' + arreglo['file_filtro'] + '</td>'
                    //strHTML += '<td style="width:7%;text-align:center" title="' + arreglo['file_max_size'] + '"><input type="hidden" id="file_max_size' + i + '"  value="' + arreglo['file_max_size'] + '" style="width:100%">' + arreglo['file_max_size'] + '</td>'

                    var readonly = arreglo['readonly'] == 'True' ? 'checked="checked"' : ''
                    strHTML += '<td class="Tit1" style="width:8%;text-align:right"><input type="checkbox" ' + readonly + ' id="readonly' + i + '" disabled="disabled" style="width:100%;border:none;"></input></td>'

                    var requerido = arreglo['requerido'] == 'True' ? 'checked="checked"' : ''
                    strHTML += '<td class="Tit1" style="width:8%;text-align:right"><input type="checkbox" ' + requerido + ' id="requerido' + i + '" disabled="disabled" style="width:100%;border:none;"></input></td>'

                    var reutilizable = arreglo['reutilizable'] == 'True' ? 'checked="checked"' : ''
                    strHTML += '<td class="Tit1" style="width:8%;text-align:right"><input type="checkbox" ' + reutilizable + ' id="reutilizable' + i + '" disabled="disabled" style="width:100%;border:none;"></input></td>'

                    var repetido = arreglo['repetido'] == 'True' ? 'checked="checked"' : ''
                    strHTML += '<td class="Tit1" style="width:8%;text-align:right"><input type="checkbox" ' + repetido + ' id="repetido' + i + '" disabled="disabled" style="width:100%;border:none;"></input></td>'

                    var print_auto = arreglo['print_auto'] == 'True' ? 'checked="checked"' : ''
                    //strHTML += '<td class="Tit1" style="width:8%;text-align:right"><input type="checkbox" ' + print_auto + ' id="print_auto' + i + '" disabled="disabled" style="width:100%;border:none;"></input></td>'

                    strHTML += '<td style="width:5%;text-align:center" title="' + arreglo['orden'] + '"><input type="hidden" id="orden' + i + '"  value="' + arreglo['orden'] + '" style="width:100%">' + arreglo['orden'] + '</td>'

                    strHTML += '<td style="width:2%; text-align:center"><img alt="" title="Editar" src="/fw/image/icons/editar.png" style="cursor:pointer;cursor:hand" onclick="archivos_def_detalle_abm(' + i + ')" /></td>'
                    strHTML += '<td style="width:2%; text-align:center"><img alt="" title="Eliminar" src="/fw/image/icons/eliminar.png" style="cursor:pointer;cursor:hand" onclick="archivos_def_detalle_eliminar(' + i + ')" /></td>'
                    strHTML += '</tr>'
                }
            });
            strHTML += '</table>'

            $('div_archivos_def_detalle').insert({ top: strHTML })
        }
    }

    function ordenar_desc(orden) {
        if (orden != '' && orden != null && orden != undefined)
            cargar_archivos_def_detalle(orden, 'desc')
    }

    function ordenar_asc(orden) {
        if (orden != '' && orden != null && orden != undefined)
            cargar_archivos_def_detalle(orden, 'asc')
    }

    //Permite modificar la vigencia de una Definición de Archivos
    function onclick_vigente() {
        var fecha_hoy = new Date()
        if ($('chk_vigente').checked) {
            campos_defs.clear('def_fe_baja')
            campos_defs.habilitar('def_fe_baja', false)
        }
        else {
            campos_defs.habilitar('def_fe_baja', true)
            if (campos_defs.get_value('def_fe_baja') == '')
                campos_defs.set_value('def_fe_baja', FechaToSTR(fecha_hoy))
        }
    }

    function archivos_def_abm(accion)  {
        $('accion').value = accion

        //Copiar como "Definición de Archivos"
        if (accion == 'C')         
            $('nro_def_archivo').value = 0
       
        //Nueva "Definición de Archivos"
        if (accion == 'N') {
            $('nro_def_archivo').value = 0
            $('def_archivo').value = ''
            $('chk_vigente').checked = 'checked'
            campos_defs.clear('def_fe_baja')

            cargar_archivos_def_detalle()        
        }        
    }

    var win_archivos_def_detalle_abm
    function archivos_def_detalle_abm(indice) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_detalle_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_detalle_ABM.aspx?indice=' + indice,
            title: '<b>ABM Archivos Def Detalle</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            modal: true,
            width: 800,
            height: 664,
            onClose: function () {
                dibujar_cargar_archivos_def_detalle
                //return params
            }
        });

        win_archivos_def_detalle_abm.options.userData = { archivos: archivos }
        win_archivos_def_detalle_abm.showCenter()

    }

    //Elimina un detalle
    function archivos_def_detalle_eliminar(indice) 
    {
        if (!nvFW.tienePermiso('permisos_def_archivo', 3)) {
            alert('No tiene permiso para eliminar. Comuniquese con el administrador de sistemas.')
            return
        }

        var nro_def_archivo = $('nro_def_archivo').value == '' ? 0 : $('nro_def_archivo').value
        Dialog.confirm("¿Desea borrar el Detalle seleccionado?", {
            width: 300,
            className: "alphacube",
            okLabel: "Aceptar",
            cancelLabel: "Cancelar",
            cancel: function (win) { win.close(); return },
            ok: function (win) {

                //Si la definición no está guardado en la db o si el detalle no esta guardado en la db, 
                //se elimina directamente del arreglo, sino se marca el estado como "BORRADO" y despues se resuelve en el procedimiento
                if (nro_def_archivo == 0 || archivos[indice]['nro_def_detalle'] == 0) {
                    archivos.splice(indice, 1)
                    dibujar_cargar_archivos_def_detalle()
                } else {
//                    archivos[indice]['nro_def_detalle'] = archivos[indice]['nro_def_detalle'] * -1
//                    archivos[indice]['estado'] = 'BORRADO'
//                    dibujar_cargar_archivos_def_detalle()

                    //Para poder eliminar un detalle, no deben existir archivos "activos"
                    var rs = new tRS()
                    var params = "<criterio><params nro_def_detalle='" + archivos[indice]['nro_def_detalle'] + "'/></criterio>"
                    rs.open(filtroArchivo, '', '', '', params)

                    if (!rs.eof()) {
                        if (rs.getdata('cant_archivos') > 0) {
                            alert('No se puede eliminar el Detalle. Existen archivos "activos" cargados.')
                            //win.close()
                            //return
                        } else {
                            archivos[indice]['nro_def_detalle'] = archivos[indice]['nro_def_detalle'] * -1
                            archivos[indice]['estado'] = 'BORRADO'
                            dibujar_cargar_archivos_def_detalle()
                        }
                    }
                }

                win.close()
            }
        });
    }

    function trim(myString) {
        return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
    }



                  //////////////////////////
                 //ESTA FUNCION NO SE USA//
                //////////////////////////

        //Verifica si existe mas de un Detalle con el mismo "Tipo" de archivo
    //Una "Definición de Archivos" no puede tener detalles con tipos de archivo repetidos 
    var win_tipo_repetido
    function archivo_def_tipo_repetido() {
        var indice_repetido
        var vacio
        var k = 0
        var tipos_archivos = new Array()
        var indice = 0
        archivos.each(function (arreglo, i) {
            if (arreglo["estado"] != 'BORRADO') {
                if (tipos_archivos.length == 0) {
                    vacio = new Array()
                    vacio["nro_archivo_def_tipo"] = arreglo["nro_archivo_def_tipo"]
                    vacio["archivo_def_tipo"] = arreglo["archivo_def_tipo"]
                    vacio["cantidad"] = 1
                    tipos_archivos[k] = vacio
                    k++
                } else {
                    indice_repetido = -1

                    tipos_archivos.each(function (arreglo_tipos, j) {
                        if (arreglo_tipos['nro_archivo_def_tipo'] == arreglo["nro_archivo_def_tipo"])
                            indice_repetido = j
                    });

                    if (indice_repetido >= 0)
                        tipos_archivos[indice_repetido]["cantidad"] = tipos_archivos[indice_repetido]["cantidad"] + 1
                    else {
                        vacio = new Array()
                        vacio["nro_archivo_def_tipo"] = arreglo["nro_archivo_def_tipo"]
                        vacio["archivo_def_tipo"] = arreglo["archivo_def_tipo"]
                        vacio["cantidad"] = 1
                        tipos_archivos[k] = vacio
                        k++
                    }
                }
            }
        });

        var tipos_repetidos = false
        var j = 0
        while (!tipos_repetidos && j < tipos_archivos.length) {
            if (tipos_archivos[j]["cantidad"] > 1)
                tipos_repetidos = true
            j++
        }

        //return tipos_repetidos;
        if (tipos_repetidos) {
            var strHTML = '<html><head></head><body style="width: 100%; height: 100%;"><form><table class="tb2" style="width:100%;overflow:hidden">'
            //strHTML += '<tr class="tbLabel" style="width:100%"><td><b>Tipos de archivo Repetidos</b></td></tr>'
            strHTML += '<tr class="tbLabel0" style="width:100%"><td colspan="3" style="text-align:left">Antes de guardar la "Definición de Archivos", debe resolver los siguientes Tipos de archivo repetidos:</td></tr>'
            strHTML += '<tr><td colspan="3">&nbsp</td></tr>'
            strHTML += '<tr><td colspan="3">'
            strHTML += '<div style="width:100%;height:90px;overflow:auto">'
            strHTML += '<table class="tb1" style="width:100%;overflow:hidden">'
            strHTML += '<tr class="tbLabel" style="width:100%"><td style="width:85%; text-align:center">Tipo</td><td style="width:85%; text-align:center">Repetidos</td></tr>'
            tipos_archivos.each(function (arreglo, i) {
                if (tipos_archivos[i]["cantidad"] > 1) {
                    //strHTML += '<tr><td style="width:5%;" class="Tit1">&nbsp</td>'
                    strHTML += '<tr><td style="width:85%; text-align:left">' + tipos_archivos[i]["archivo_def_tipo"] + '</td>'
                    strHTML += '<td style="width:15%; text-align:center">' + tipos_archivos[i]["cantidad"] + '</td></tr>'
                }
            });
            strHTML += '</table>'
            strHTML += '</div>'
            strHTML += '</td></tr>'
            strHTML += '<tr><td style="width: 25%;"></td><td style="width: 50%;text-align:center"><input type="button" name="cerrar" id="cerrar" value="Cerrar" onclick="win_tipo_repetido.close();return"/></td><td style="width: 25%;"></td></tr>'
            strHTML += '<tr><td colspan="3">&nbsp</td></tr>'
            strHTML += '</table></form></body>'

            win_tipo_repetido = new Window({
                className: 'alphacube',
                title: '<b>Tipos de archivo Repetidos</b>',
                minimizable: true,
                maximizable: false,
                draggable: false,
                resizable: false,
                recenterAuto: false,
                width: 400,
                height: 200,
                onClose: function () { }
            });

            win_tipo_repetido.setHTMLContent(strHTML)
            var id = win_tipo_repetido.getId()
            focus(id)
            win_tipo_repetido.showCenter(true)
        } 
        else {
            actualizar_archivos_def()
        }
    }

    function validar_archivos_def() {

        var str_error = ''
        var accion = $('accion').value
        var nro_def_archivo = $('nro_def_archivo').value == '' ? 0 : $('nro_def_archivo').value
        var def_archivo = $('def_archivo').value
        var def_fe_baja = $('def_fe_baja').value
        var def_archivo_aux = $('def_archivo_aux').value        

        //Copiar como "Definición de Archivos"
        if (accion == 'C') {
            if (trim(def_archivo) == trim(def_archivo_aux))
                str_error += 'Ya existe una Definición de Archivos con la misma Descripción. Por favor, especifique una "Descripción" diferente.</br>'
        }

        if (def_archivo == '')
            str_error += 'Debe especificar una "Descripción".</br>'

        if (!$('chk_vigente').checked && def_fe_baja == '')
            str_error += 'Si la Definición de Archivos no se encuentra vigente, por favor, setear la Fecha de Baja.</br>'

        if (archivos.length == 0)
            str_error += 'La Definición no posee "Archivos Def Detalle".</br>'


        if (str_error != '') {
            alert(str_error)
            return
        } else {
            //Verifica si existe mas de un Detalle con el mismo "Tipo" de archivo
            //archivo_def_tipo_repetido()
            actualizar_archivos_def()
        }   
    }



    //Actualiza la información de la Definición de archivos
        function actualizar_archivos_def() {

            var accion = $('accion').value
            var nro_def_archivo = $('nro_def_archivo').value == '' ? 0 : $('nro_def_archivo').value
            var def_archivo = $('def_archivo').value
            var def_fe_baja = $('def_fe_baja').value
            var def_archivo_aux = $('def_archivo_aux').value

            var readonly
            var archivo_descripcion
            var requerido
            var reutilizable
            var repetido
            var print_auto
            var request_usr
            var ppi
            var nro_depthcolor
            var file_filtro
            var nro_def_detalle = 0
            var estado = ''

            def_archivo = '<![CDATA[' + def_archivo + ']]>'

            var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xmldato += "<archivos_def_cab accion='" + accion + "' nro_def_archivo='" + nro_def_archivo + "' def_fe_baja='" + def_fe_baja + "'>"
            xmldato += "<def_archivo>" + def_archivo + "</def_archivo>"

            xmldato += "<archivos_def_detalle>"

            archivos.each(function (arreglo, i) {
                readonly = (arreglo["readonly"] == null) ? "False" : arreglo["readonly"]
                archivo_descripcion = '<![CDATA[' + arreglo["archivo_descripcion"] + ']]>'
                requerido = (arreglo["requerido"] == null) ? "False" : arreglo["requerido"];
                reutilizable = (arreglo["reutilizable"] == null) ? "False" : arreglo["reutilizable"];
                repetido = (arreglo["repetido"] == null) ? "False" : arreglo["repetido"];
                print_auto = (arreglo["print_auto"] == null) ? "False" : arreglo["print_auto"];
                request_usr = (arreglo["request_usr"] == null) ? "False" : arreglo["request_usr"];
                ppi = (arreglo["ppi"] == null) ? 0 : arreglo["ppi"];
                nro_depthcolor = (arreglo["nro_depthcolor"] == null) ? 0 : arreglo["nro_depthcolor"];

                file_filtro = '<![CDATA[' + arreglo["file_filtro"] + ']]>'

                if (accion == 'C') {
                    nro_def_detalle = 0
                    estado = 'NUEVO'
                } else {
                    nro_def_detalle = arreglo["nro_def_detalle"]
                    estado = arreglo["estado"]
                }

                xmldato += "\n<archivo_def_detalle nro_def_detalle ='" + nro_def_detalle + "' orden ='" + arreglo["orden"] + "' readonly ='" + readonly + "' file_max_size ='" + arreglo["file_max_size"] + "' perfil='" + arreglo["perfil"] + "' requerido='" + arreglo["requerido"] + "' reutilizable='" + arreglo["reutilizable"] + "' repetido='" + arreglo["repetido"] + "' print_auto='" + arreglo["print_auto"] + "' nro_archivo_def_tipo='" + arreglo["nro_archivo_def_tipo"] + "' request_usr='" + arreglo["request_usr"] + "' ppi='" + ppi + "' nro_depthcolor='" + nro_depthcolor + "' estado='" + estado + "' grupos='" + arreglo["grupos"] + "' nro_venc_tipo='" + arreglo["nro_venc_tipo"] + "' venc_dias='" + arreglo["venc_dias"] + "' venc_function='" + arreglo["venc_function"] + "' f_nro_ubi='" + arreglo["f_nro_ubi"] + "' f_path='" + arreglo["f_path"] + "'>"
                xmldato += "<archivo_descripcion>" + archivo_descripcion + "</archivo_descripcion>"
                xmldato += "<file_filtro>" + file_filtro + "</file_filtro>"
                xmldato += "</archivo_def_detalle>"
            });
            xmldato += "</archivos_def_detalle>"

            xmldato += "</archivos_def_cab>"

            console.log(xmldato)

            //console.log(xmldato)

            //////GUARDADO*DE*ABM*PARAMETROS//////

            nvFW.error_ajax_request('/fw/def_archivos/archivos_def_ABM.aspx', {
                parameters: { modo: 'M', strXML: xmldato },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        nro_def_archivo = err.params['nro_def_archivo']
                        win.options.userData = { nro_def_archivo: nro_def_archivo }
                        win.close()
                    }
                    else {
                        alert(err.mensaje)
                        return
                    }
                },
                onError: function (err, transport) {
                    alert(err.mensaje)
                    return
                }
            });

            //params = JSON.parse(sessionStorage.getItem("params"))
            //if (params != "") {
            //    var strXML = "<param_def>"
            //    params.each(function (arr, i) {
            //        strXML += "<param parametro = '" + arr.parametro + "' visible = '" + arr.visible + "' orden= '" + arr.orden + "' tipo_dato= '" + arr.tipo_dato + "' requerido= '" + arr.requerido + "' editable = '" + arr.editable + "'>"
            //        strXML += "<valor_defecto><![CDATA[" + arr.valor_defecto + "]]></valor_defecto>"
            //        strXML += "<etiqueta><![CDATA[" + arr.etiqueta + "]]></etiqueta></param>"
            //    });
            //    strXML += "</param_def>"
            //    console.log(strXML)

            paramsXML = JSON.parse(sessionStorage.getItem("paramsXML"))
            //if (!paramsXML) { 
                if (paramsXML[0]['xml'] != '') {
                    paramsXML.each(function (arreglo, i) {
                        nvFW.error_ajax_request('archivos_def_detalle_ABM.aspx', {
                            parameters: { archivo_descripcion: arreglo['archivo_desc'], strXML: arreglo['xml'], modo: "ALTAPARAM" },
                            onSuccess: function (err, transport) {

                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }
                                //winParam_def.close()
                            },
                            error_alert: true
                        });
                    })
                }
            //}
            sessionStorage.clear()
            win.close()
        }
    </script>
</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frmArchivosDefABM" action="/fw/def_archivos/archivos_def_ABM.aspx" method="post" style='width:100%;height:100%;overflow:hidden'>
    <input type="hidden" name="modo" id="modo" value="<%= modo %>" />
    <input type="hidden" name="nro_def_archivo_aux" id="nro_def_archivo_aux" value="<%= nro_def_archivo %>" />
    <input type="hidden" name="def_archivo_aux" id="def_archivo_aux" value="" />    
    <input type="hidden" name="accion" id="accion" value="<%= accion %>" />
        <div id="divMenuArchivosDefABM" style="margin: 0px; padding: 0px;"></div>
        <script type="text/javascript">
            var vMenuArchivosDefABM = new tMenu('divMenuArchivosDefABM', 'vMenuArchivosDefABM');
            vMenuArchivosDefABM.loadImage("guardar", "/fw/image/icons/guardar.png")
            vMenuArchivosDefABM.loadImage("guardar_como", "/fw/image/icons/guardar.png")
            vMenuArchivosDefABM.loadImage("nuevo", "/fw/image/icons/nueva.png")
            Menus["vMenuArchivosDefABM"] = vMenuArchivosDefABM
            Menus["vMenuArchivosDefABM"].alineacion = 'centro';
            Menus["vMenuArchivosDefABM"].estilo = 'A';
            Menus["vMenuArchivosDefABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>validar_archivos_def()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuArchivosDefABM"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuArchivosDefABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar_como</icono><Desc>Copiar como</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_abm('C')</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuArchivosDefABM"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_abm('N')</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuArchivosDefABM.MostrarMenu()
        </script>
        <table class="tb1" id="tb_archivos_def">
            <tr class="tbLabel">
                <td style="width:8%; text-align:center">Nro. Def.</td> 
                <td style="width:70%; text-align:center">Descripción</td>
                <td style="width:10%; text-align:center">Vigente</td> 
                <td style="width:12%; text-align:center">Fecha Baja</td> 
            </tr>
            <tr>
                <td style="vertical-align:middle; text-align:center"><input type="text" name="nro_def_archivo" id="nro_def_archivo" style="width:100%;text-align:center;" disabled="disabled" value="<%= nro_def_archivo %>"/></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="def_archivo" id="def_archivo" style="width:100%;" value=""/></td>
                <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='chk_vigente' name='chk_vigente' onclick='return onclick_vigente()' /></td>
                <td style="vertical-align:middle; text-align:center">
                     <script type="text/javascript">
                         campos_defs.add('def_fe_baja', { enDB: false, nro_campo_tipo: 103 })
                     </script>            
                </td>
            </tr>
        </table>
        <div id="divMenuABMArchivosDefDetalle" style="width:100%"></div>
        <script type="text/javascript">
            var vMenuABMArchivosDefDetalle = new tMenu('divMenuABMArchivosDefDetalle', 'vMenuABMArchivosDefDetalle');
            vMenuABMArchivosDefDetalle.loadImage("hoja","/fw/image/icons/nueva.png")
            Menus["vMenuABMArchivosDefDetalle"] = vMenuABMArchivosDefDetalle
            Menus["vMenuABMArchivosDefDetalle"].alineacion = 'centro';
            Menus["vMenuABMArchivosDefDetalle"].estilo = 'A';
            Menus["vMenuABMArchivosDefDetalle"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Archivos Def Detalle</Desc></MenuItem>")
            Menus["vMenuABMArchivosDefDetalle"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo Detalle</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_detalle_abm(-1)</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuABMArchivosDefDetalle.MostrarMenu()
        </script>
        <div id="div_archivos_def_detalle" style="width: 100%; overflow: auto"></div>

</form>
</body>
</html>
