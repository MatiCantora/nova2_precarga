<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Windows.Media.Imaging"%>
<%
    Dim id_ventana As String = nvFW.nvUtiles.obtenerValor("id_ventana", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim f_depende_de As String = nvFW.nvUtiles.obtenerValor("f_depende_de")
    Dim f_seleccionar = nvFW.nvUtiles.obtenerValor("f_seleccionar", "false") = "true"

    Dim base_f_nro_ubi_default = 1
    Dim strSQL As String

    Me.contents("f_seleccionar") = f_seleccionar
    Me.contents("link_mostrar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verref_files'><campos>f_id, f_nombre, f_nro_tipo, f_depende_de, ref_files_path,parent_ref_files_path</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("link_onclick") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_files'><campos>f_id, f_nombre, f_ext, f_size, f_falta, f_nro_tipo, f_depende_de, ref_files_path, parent_ref_files_path</campos><filtro><borrado type='igual'>0</borrado></filtro><orden>f_nro_tipo,f_nombre</orden></select></criterio>")
    'Me.contents("file_up_ondblclick") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verref_files'><campos>f_depende_de, parent_ref_files_path</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("buscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_files'><campos>f_id, f_nombre, f_ext, f_size, f_falta, f_nro_tipo, f_depende_de, ref_files_path, parent_ref_files_path</campos><filtro></filtro><orden>f_nro_tipo, f_nombre</orden></select></criterio>")

    Me.contents("imageTypes") = nvFW.nvFile.getFileTypes_rsParam()

    Dim err As New nvFW.tError()

    Try

        Select Case accion.ToLower()
            Case "disco_alta"

                Dim f_nombre As String = nvUtiles.obtenerValor("f_nombre")
                Dim f_ext As String = nvUtiles.obtenerValor("f_ext")
                Dim filename As String
                If f_ext <> "" Then
                    filename = f_nombre + "." + f_ext
                Else
                    filename = f_nombre
                End If

                strSQL = "Select count(*) as count from ref_files where borrado = 0 and f_depende_de is NULL and f_nombre = '" + Replace(System.IO.Path.GetFileName(filename), "'", "''") + "' and f_ext = '" + Replace(System.IO.Path.GetExtension(filename), "'", "''") + "'"
                Dim rs = nvDBUtiles.DBOpenRecordset(strSQL)
                If rs.Fields("count").Value > 0 Then
                    err.numError = 12
                    err.mensaje = "Ya existe un disco con ese nommbre"
                    err.response()

                End If
                nvDBUtiles.DBCloseRecordset(rs)

                strSQL = "INSERT INTO ref_files(f_nombre, f_ext, f_falta, f_nro_tipo, f_depende_de, hereda_permisos, f_nro_ubi, f_nro_ubi_default)"
                strSQL += " VALUES ('" + f_nombre + "', '" + f_ext + "',  getdate(), -1, NULL, 0, " + CType(base_f_nro_ubi_default, String) + "," + CType(base_f_nro_ubi_default, String) + ")"
                Dim cn = nvDBUtiles.DBConectar()
                cn.Execute(strSQL)
                strSQL = "Select @@identity as f_id"
                Dim rsID = cn.Execute(strSQL)
                Dim f_id As Integer = rsID.Fields("f_id").Value

                strSQL = "INSERT INTO ref_file_permisos(f_id,tipo_operador,permiso) VALUES (" + CType(f_id, String) + ", 4, 31)" 'todos los permisos al perfil administrador
                cn.Execute(strSQL)
                err.params("f_id") = f_id
                nvDBUtiles.DBCloseRecordset(rsID)
                nvDBUtiles.DBDesconectar(cn)


            Case "carpeta_alta"

                Dim rs = nvDBUtiles.DBOpenRecordset("select dbo.ref_file_permiso_operador( '" + f_depende_de + "') as permiso")
                Dim permiso = rs.Fields("permiso").Value
                nvDBUtiles.DBCloseRecordset(rs)

                If ((permiso And 2) = 0) Then
                    err.numError = 13
                    err.mensaje = "No tiene permiso de modificación sobre esta carpeta."
                    err.response()
                End If

                Dim f_nombre As String = nvUtiles.obtenerValor("f_nombre")
                Dim f_ext As String = nvUtiles.obtenerValor("f_ext")
                Dim f_nro_ubi As String = nvUtiles.obtenerValor("f_nro_ubi")
                Dim filename As String
                If f_ext <> "" Then
                    filename = f_nombre + "." + f_ext
                Else
                    filename = f_nombre
                End If

                strSQL = "Select count(*) as count from ref_files where borrado = 0 and f_depende_de = '" + f_depende_de + "' and f_nombre = '" + Replace(System.IO.Path.GetFileName(filename), "'", "''") + "' and f_ext = '" + Replace(System.IO.Path.GetExtension(filename), "'", "''") + "'"
                rs = nvDBUtiles.DBOpenRecordset(strSQL)
                If rs.Fields("count").Value > 0 Then
                    err.numError = 12
                    err.mensaje = "Ya existe una carpeta con ese nommbre"
                    err.response()
                End If
                nvDBUtiles.DBCloseRecordset(rs)


                Dim rsDep = nvDBUtiles.DBOpenRecordset("select * from ref_files where f_id = " + f_depende_de)
                Dim f_nro_ubi_default = rsDep.Fields("f_nro_ubi").Value
                nvDBUtiles.DBCloseRecordset(rsDep)
                If CType(f_nro_ubi_default, String) = "" Then
                    f_nro_ubi_default = base_f_nro_ubi_default
                End If

                Dim cn = nvDBUtiles.DBConectar()
                strSQL = "INSERT INTO ref_files(f_nombre, f_ext, f_falta, f_nro_tipo, f_depende_de, f_nro_ubi, f_nro_ubi_default)"
                strSQL += " VALUES ('" + f_nombre + "', '" + f_ext + "',  getdate(),0," + f_depende_de + ", " + CType(f_nro_ubi, String) + "," + CType(f_nro_ubi_default, String) + ")"
                cn.Execute(strSQL)
                strSQL = "Select @@identity as f_id"
                Dim rsID = cn.Execute(strSQL)
                Dim f_id As Integer = rsID.Fields("f_id").Value
                err.params("f_id") = f_id
                nvDBUtiles.DBCloseRecordset(rsID)
                nvDBUtiles.DBDesconectar(cn)


            Case "archivo_alta"
                Dim f_id = nvUtiles.obtenerValor("f_id")

                Dim file As tUpload = nvSession.Contents("upload_files")(f_id)

                'Dim path_destino As String = base_path + System.IO.Path.GetFileName(file.filename)
                Dim rs = nvDBUtiles.DBOpenRecordset("select dbo.ref_file_permiso_operador( '" + f_depende_de + "') as permiso")
                Dim permiso = rs.Fields("permiso").Value
                nvDBUtiles.DBCloseRecordset(rs)

                If (permiso And 1) = 0 Then
                    err.numError = 14
                    err.mensaje = "No tiene permiso para subir archivos en esta carpeta."
                    err.response()
                End If


                Dim f_ext As String = System.IO.Path.GetExtension(file.filename).Substring(1)
                Dim f_nombre As String = System.IO.Path.GetFileName(file.filename)
                f_nombre = Split(f_nombre, ".")(0)
                Dim path_tmp = System.IO.Path.GetTempFileName

                'Stop
                'Dim fs As New System.IO.FileStream(path_tmp, IO.FileMode.Open)
                'Dim decoder As New System.Windows.Media.Imaging.JpegBitmapDecoder(fs, BitmapCreateOptions.None, BitmapCacheOption.None)
                'Dim metadata As BitmapMetadata = decoder.Frames(0).Metadata

                'If (Not metadata Is Nothing) Then

                'End If


                'If file.path_tmp Then
                If path_tmp <> "" Then

                    'Controlar nombre de archivo duplicado
                    strSQL = "Select count(*) as count from ref_files where borrado = 0 and f_depende_de = '" + f_depende_de + "' and f_nombre = '" + Replace(f_nombre, "'", "''") + "' and f_ext = '" + Replace(f_ext, "'", "''") + "'"
                    Dim rs1 = nvDBUtiles.DBOpenRecordset(strSQL)
                    If rs1.Fields("count").Value > 0 Then
                        nvDBUtiles.DBCloseRecordset(rs1)
                        err.numError = 12
                        err.mensaje = "Ya existe un archivo con ese nombre"
                        err.response()

                    End If
                    nvDBUtiles.DBCloseRecordset(rs1)
                End If


                Dim rsDep = nvDBUtiles.DBOpenRecordset("select * from ref_files where f_id = " + f_depende_de)
                Dim f_nro_ubi As Integer = rsDep.Fields("f_nro_ubi").Value
                nvDBUtiles.DBCloseRecordset(rsDep)
                If f_nro_ubi = 0 Then
                    f_nro_ubi = base_f_nro_ubi_default

                End If

                Dim dirs() As String
                Dim base_path As String

                If f_nro_ubi = 1 Then
                    Try
                        dirs = nvApp.app_dirs("nvFiles").path.Split(";")
                        base_path = dirs(0)
                    Catch ex As Exception

                    End Try
                    If Not System.IO.Directory.Exists(base_path) Or base_path = "" Then
                        err.numError = 12
                        err.titulo = "Error al intentar subir el archivo"
                        err.mensaje = "La carpeta de detino no existe"
                    End If
                End If

                strSQL = "INSERT INTO ref_files(f_nombre, f_ext, f_descripcion, f_path, f_falta, f_nro_tipo, f_depende_de, f_size, f_nro_ubi, f_nro_ubi_default) VALUES ('" & f_nombre & "', '" & f_ext & "', '', '', getdate(), 1, " & f_depende_de & ", '" & CType(file.size / 1024, Integer) & "', " & CType(f_nro_ubi, String) & "," & CType(base_f_nro_ubi_default, String) & ")"
                'strSQL = strSQL + " "

                Dim cn = nvDBUtiles.DBConectar()
                cn.BeginTrans()
                Try
                    cn.Execute(strSQL)
                    strSQL = "Select @@identity as f_id"
                    Dim rsID = cn.Execute(strSQL)
                    f_id = rsID.Fields("f_id").Value
                    rsID.Close()
                    err.params("f_id") = CType(f_id, String)

                    'cuando se guarda en el sistema de archivos
                    If f_nro_ubi = 1 Then
                        Dim filename = base_path + "file" + f_id + "." + f_ext
                        strSQL = "UPDATE ref_files set f_path = '" + Replace(filename, "'", "''") + "' where f_id = " + f_id
                        cn.Execute(strSQL)
                        file.mover(filename, True)
                    Else
                        'cuando se guarda en BD
                        Dim datos = file.getBinaryData()
                        Dim cmd As New ADODB.Command()
                        cmd.CommandType = ADODB.CommandTypeEnum.adCmdStoredProc
                        cmd.CommandText = "ref_file_bin_actualizar"
                        cmd.ActiveConnection = cn
                        cmd.Parameters("@f_id").Value = f_id
                        cmd.Parameters("@BinaryData").Type = 205
                        cmd.Parameters("@BinaryData").Size = file.size
                        cmd.Parameters("@BinaryData").AppendChunk(datos)
                        cmd.Execute()

                    End If
                    cn.CommitTrans()
                Catch ex As Exception
                    cn.RollbackTrans()
                End Try
                cn.Close()


                'file.borrar() 'ya fue borrado en el mover

                'Incorporar información de archivo imagen


            Case "renombrar"

                Dim f_id = nvUtiles.obtenerValor("f_id")
                Dim f_nombre = nvUtiles.obtenerValor("f_nombre")
                Dim f_ext = nvUtiles.obtenerValor("f_ext")

                Dim rs = nvDBUtiles.DBOpenRecordset("select dbo.ref_file_permiso_operador( '" + CType(f_id, String) + "') as permiso")
                Dim permiso = rs.Fields("permiso").Value
                nvDBUtiles.DBCloseRecordset(rs)

                If ((permiso And 2) = 0) Then
                    err.numError = 13
                    err.mensaje = "No tiene permiso para realizar esta acción."
                    err.response()
                End If

                strSQL = "UPDATE ref_files SET f_nombre = '" + f_nombre + "', f_ext = '" + f_ext + "', f_falta = getdate() WHERE f_id = " + CType(f_id, String)
                rs = nvDBUtiles.DBExecute(strSQL)
                nvDBUtiles.DBCloseRecordset(rs)

            Case "eliminar"

                Dim f_id = nvUtiles.obtenerValor("f_id")
                Dim rs = nvDBUtiles.DBOpenRecordset("select dbo.ref_file_permiso_operador( '" + CType(f_id, String) + "') as permiso")
                Dim permiso = rs.Fields("permiso").Value
                nvDBUtiles.DBCloseRecordset(rs)

                If ((permiso And 4) = 0) Then
                    err.numError = 13
                    err.mensaje = "No tiene permiso para realizar esta acción."
                    err.response()
                End If

                strSQL = "UPDATE ref_files SET borrado = 1, f_falta = getdate(), nro_operador_borrado = dbo.rm_nro_operador() WHERE f_id = " + CType(f_id, String)
                rs = nvDBUtiles.DBExecute(strSQL)
                nvDBUtiles.DBCloseRecordset(rs)

                'falta eliminar el archivo

        End Select

    Catch ex As Exception
        
    End Try

    If accion <> "" Then
        err.response()
    End If

%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tUpload.js" language="javascript"></script>
        <% =Me.getHeadInit()%>

        
        <script type="text/javascript">
           
            var win = nvFW.getMyWindow();
            var links = {}
            var filters = {}
            var view
            var file_dialog
            var file_seleccionado = null
            var file = {}
            file.f_id = -1
            file.f_nombre = ''
            file.f_ext = ''
            file.f_depende_de = ''
            file.f_path = ''
            file.f_nro_tipo = 0

            function window_onload() 
                {
                
                //vListButton.MostrarListButton()
                //win = nvFW.getMyWindow() // window.parent.Windows.getWindow(id_ventana)
                
                if (win.options.file_dialog != undefined)
                    file_dialog = win.options.file_dialog

                if (file_dialog.links != undefined)
                    links = file_dialog.links

                if (file_dialog.filters != undefined)
                    filters = file_dialog.filters

                if (file_dialog.view != undefined)
                    view = file_dialog.view

                view = view == 'miniatura' ? view : 'detalle'

                vMenuDatosFile.MostrarMenu()
                window_onresize()
                window_onresize_iframe()

                link_mostrar()
                filters_mostrar()
                filter_upload()
            }

            function window_onresize() {
                try {
                    var dif = Prototype.Browser.IE ? 5 : 5
                    body_height = $$('body')[0].getHeight()
                    menu_height = $('divMenuDatosFile').getHeight()
                    //     tbCabe_height = $('tbCabe').getHeight()
                    //     tbCarpeta_height = $('tbCarpeta').getHeight()
                    //     tbUpload_height = $('tbUpload').getHeight()

                    var total = body_height - menu_height - dif + 'px' //- tbCarpeta_height - tbUpload_height
                    $('tbTree').setStyle({height: total})
                    window_onresize_iframe();
                }
                catch (e) {
                }
            }

            function window_onresize_iframe() {
                if (Prototype.Browser.IE) {
                    try {

                        body_height = $$('body')[0].getHeight()
                        menu_height = $('divMenuDatosFile').getHeight()
                        tbub_height = $('tbUb').getHeight()
                        tbex_height = $('tbEx').getHeight()

                        var total = body_height - menu_height - tbub_height - tbex_height - 10 + 'px' //- tbCarpeta_height - tbUpload_height
                        $('frmPreview').setStyle({ height: total + 'px' })
                       
                    }
                    catch (e) {
                    }
                }
            }

            function link_onclick(f_id, ref_files_path) { 
                if ((f_id == -1) && (ref_files_path == 'Busqueda')) {
                    buscar()
                } else {
                    file.f_id = f_id
                    file.ref_files_path = ref_files_path
                    $('txtPath').value = ref_files_path
                    var filter = $('cbFilters').options[$('cbFilters').selectedIndex].value
                    file_seleccionado = null;
                    var pageSize = $('pageSize').value;
                    if (pageSize == '-') {
                        pageSize = "";
                    } else {
                        pageSize = " PageSize='" + pageSize + "' AbsolutePage='1' cacheControl='Session'";
                    }
                    var thumbSize = $('thumbSize').value;
                    var options = {
                        //Parametros de consulta
                        //filtroXML: "<criterio><select vista='verRef_files'" + pageSize + "><campos>f_id, f_nombre, f_ext, f_size, f_falta, f_nro_tipo, f_depende_de, ref_files_path, parent_ref_files_path</campos><filtro><borrado type='igual'>0</borrado><f_depende_de type='igual'>" + f_id + "</f_depende_de></filtro><orden>f_nro_tipo, f_nombre</orden></select></criterio>",
                        filtroXML: nvFW.pageContents.link_onclick,
                        filtroWhere: "<criterio><select vista='verRef_files'" + pageSize + "><filtro><f_depende_de type='igual'>" + f_id + "</f_depende_de></filtro></select></criterio>",
                        parametros: '<parametros><filter>' + filter + '</filter><file f_depende_de="' + file.f_id + '" /><file thumbSize="' + thumbSize + '" /></parametros>',
                        path_xsl: "report\\file_dialog\\verRef_files\\html_detalle.xsl",
                        formTarget: "frmPreview",
                        nvFW_mantener_origen: true,
                        id_exp_origen: 0,
                        bloq_contenedor: "",
                        cls_contenedor: "frmPreview"
                    }
                    if (view != 'detalle') {
                        options.path_xsl = "report\\file_dialog\\verRef_files\\html_miniatura.xsl";
                        $$('.thumbSizeTd').each(function(div) {
                            div.show();
                        });
                    } else {
                        $$('.thumbSizeTd').each(function(div) {
                            div.hide();
                        });
                    }
                    nvFW.exportarReporte(options)
                    //$('frmPreview').src = 'file_preview.asp?f_id=' + f_id
                }
            }


            function link_mostrar() { 
            
                var ids = ''
                for (var i in links)
                    ids += links[i].f_id + ','
                if (ids.length > 0)
                    ids = ids.substring(0, ids.length - 1)
                var filtroWhere = "<f_id type='in'>" + ids + "</f_id>"
                var rs = new tRS()
                rs.async = true
                rs.onComplete = function(rs) { 
                    var f_id
                    while (!rs.eof()) {
                        f_id = rs.getdata('f_id')
                        links[f_id].f_id = rs.getdata('f_id')
                        links[f_id].f_nombre = rs.getdata('f_nombre')
                        links[f_id].f_nro_tipo = rs.getdata('f_nro_tipo')
                        links[f_id].f_depende_de = rs.getdata('f_depende_de')
                        links[f_id].ref_files_path = rs.getdata('ref_files_path')
                        rs.movenext()
                    }
                    var srtHTML = ''
                    var link
                    var div = $('divLink')
                    for (var i in links) {
                        link = links[i]
                        if (link.ref_files_path == undefined)
                            link.ref_files_path = ''
                        strHTML = "<br/><div onclick='link_onclick(" + link.f_id + ", \"" + replace(link.ref_files_path, "\\", "\\\\") + "\")' style='width: 100%; cursor: hand; cursor: pointer; text-align: center; vertical-align: middle; margin: auto;'><div style='width: 32px; height: 32px; background-image: url(/fw/image/file_dialog/" + link.icon + "); text-align: center; vertical-align: middle; margin: auto;'></div>" + link.titulo + "</div>"
                        div.insert({bottom: strHTML})

                        if (links[i].inicio == true)
                            link_onclick(links[i].f_id, links[i].ref_files_path)
                    }

                }
                rs.open(nvFW.pageContents.link_mostrar, '', filtroWhere, '', '')

            }

            function file_onclick(file) {
                //         if (file.f_nro_tipo == 1)
                //           {
                //           $('txtSeleccionado').value = file.f_nombre + "." + file.f_ext
                //           file_seleccionado = file
                //           }
                //         else
                //           $('txtSeleccionado').value = ''  
            }

            function file_ondblclick(file) 
              {
              if (file != null) 
                {
                if (file.f_nro_tipo != 1)
                  {
                  link_onclick(file.f_id, file.ref_files_path)
                  return
                  }
                if (file.f_nro_tipo == 1 && nvFW.pageContents.f_seleccionar) 
                    {
                    file_seleccionado = file
                    nvFW.getMyWindow().close()
                    return
                    }
                var width = window.top.innerWidth - 100
                var height = window.top.innerHeight - 100    
                if (width >1200) width = 1200
                if (height >800) height = 800
                var imageType = nvFW.pageContents.imageTypes[file.f_ext.toLowerCase()]
                if (imageType == undefined)
                  imageType = {hasThumb:false,browser_display:false}
                var win = window.top.nvFW.createWindow({url:'/fw/files/file_preview.aspx?f_id=' + file.f_id + '&height=0&width=0',
                                                            title: file.f_nombre + "." + file.f_ext,
                                                            width: width, height: height,
                                                            minimizable: true,
                                                            maximizable: true,
                                                            resizable: true,
                                                            draggable: true
                                                            })
                win.showCenter(true);
                return
                }
              }

            function file_up_ondblclick(f_id) {
                
                //var filtroXML = "<criterio><select vista='verref_files'><campos>f_depende_de, parent_ref_files_path</campos><filtro><f_id type='igual'>" + f_id + "</f_id></filtro><orden></orden></select></criterio>"
                var filtroXML = nvFW.pageContents.link_mostrar
                var filtroWhere = "<f_id type='igual'>" + f_id + "</f_id>"
                var rs = new tRS()
                rs.open(filtroXML, '', filtroWhere, '', '')
                if (!rs.eof()) {
                    var f_depende_de = rs.getdata('f_depende_de')
                    var parent_ref_files_path = rs.getdata('parent_ref_files_path')
                    if (f_depende_de != null)
                        link_onclick(f_depende_de, parent_ref_files_path)
                }
            }

            function btnActualizar_onclick() {
                link_onclick(file.f_id, file.ref_files_path)
            }

            function filters_mostrar() {
                var cb = $("cbFilters")
                var option
                cb.options.length = 0
                for (f in filters) {
                    cb.options.length++
                    option = cb.options[cb.options.length - 1]
                    option.text = filters[f]['titulo'] + " (" + filters[f]['filter'] + ")"
                    option.value = filters[f]['filter']
                    if (filters[f]['inicio'] == true)
                        cb.selectedIndex = cb.options.length - 1
                }
            }

            function filters_onchange() {
                filter_upload()
                link_onclick(file.f_id, file.ref_files_path)
            }

            function filter_upload() 
                {
                for (var i in filters)
                    if (filters[i].campo_def != undefined) {
                        campo_def = filters[i].campo_def
                        campos_defs.items[campo_def].upload.form.hide()
                    }

                var cb = $("cbFilters")
                var index = $("cbFilters").selectedIndex
                filter = filters[index]
                if (filter.campo_def == undefined) {
                    filter.campo_def = 'fileUpload_' + $("cbFilters").selectedIndex
                    campos_defs.add(filter.campo_def, {nro_campo_tipo: 200, target: "tdUpload", enDB: false, max_size: filter.max_size, filter: filter.filter})
                    campos_defs.items[filter.campo_def]["onchange"] = function(e, campo_def) {
                        if (campos_defs.get_value(campo_def) > 0) {
                            upload(campo_def)
                            campos_defs.clear(campo_def)
                        }
                    }
                    campos_defs.items[filter.campo_def]['upload'].onbeforesend = function(upload) {
                        nvFW.bloqueo_activar($(document.body), 'upload_bloqueo')
                    }
                    campos_defs.items[filter.campo_def]['upload'].onaftersend = function(upload) {
                        nvFW.bloqueo_desactivar($(document.body), 'upload_bloqueo')
                    }

                }
                else {
                    campo_def = filters[index].campo_def
                    campos_defs.items[campo_def].upload.form.show()
                }
            }



            function disco_alta() {

                var frm = $('frmPreview')
                var f_depende_de = frm.contentWindow.f_depende_de
                if (f_depende_de != 0)
                    return

                var permisos_web = 16

                if ((permisos_web & 16) == 0) {
                    alert('No posee permisos para realizar esta acción.')
                    return
                }


                Dialog.confirm("<table class='tb2' style='width:100%'><tr><td style='width:100%;text-align: center'><b>Ingrese el nombre del nuevo disco: </b></td></tr><tr><td style='width:100%'><div style='width:100%' id='divNC'><input id='txt_nc' style='width:100%'/></div></td></tr></td></tr></table>",
                        {
                            width: 390,
                            className: "alphacube",
                            okLabel: "Aceptar",
                            cancelLabel: "Cancelar",
                            cancel: function(win) {
                                win.close();
                                return
                            },
                            ok: function(win) { 
                                if ($('txt_nc').value != "") {
                                    if (!filename_validar($('txt_nc').value))
                                        return
                                    var filename = filename_parse($('txt_nc').value)
                                    //var f_nro_ubi = $('carpeta_ubi').value   
                                    nvFW.error_ajax_request('/fw/files/file_dialog.aspx', {
                                        bloq_contenedor_on: false,
                                        asynchronous: false,
                                        parameters: {accion: 'disco_alta', f_depende_de: file.f_id, f_nombre: filename.f_nombre, f_ext: filename.f_ext},
                                        onSuccess: function(err) {
                                            link_onclick(file.f_id, file.ref_files_path)
                                        },
                                        onFailure: function(err) {
                                        }
                                    })
                                    win.close()
                                }
                                else {
                                    alert("Ingrese el nombre del disco")
                                    return
                                }
                                win.close()
                            }

                        });
            }




            function carpeta_alta() { 
                var frm = $('frmPreview')
                var f_depende_de = frm.contentWindow.f_depende_de
                if (f_depende_de == 0)
                    return
                nvFW.confirm("<table class='tb1' ><tr><td style='width:100%;text-align: center'>Ingrese el nombre de la nueva carpeta:</td></tr><tr><td style='width:100%'><div style='width:100%' id='divNC'><input id='txt_nc' style='width:100%'/></div></td></tr></td></tr></table>",
                        {
                            width: 390,
                            cancel: function(win) {
                                win.close();
                                return
                            },
                            ok: function (win) {
                                
                                if ($('txt_nc').value != "") {
                                    if (!filename_validar($('txt_nc').value))
                                        return
                                    var filename = filename_parse($('txt_nc').value)
                                    var f_nro_ubi = 1
                                    
                                    nvFW.error_ajax_request('/fw/files/file_dialog.aspx', {
                                        bloq_contenedor_on: false,
                                        asynchronous: false,
                                        parameters: {accion: 'carpeta_alta', f_depende_de: file.f_id, f_nombre: filename.f_nombre, f_ext: filename.f_ext, f_nro_ubi: f_nro_ubi},
                                        onSuccess: function(err) {
                                            link_onclick(file.f_id, file.ref_files_path)
                                        },
                                        onFailure: function(err) {
                                        }
                                    })
                                    win.close()
                                }
                                else {
                                    alert("El nombre de la carpeta no puede ser vacío")
                                    return
                                }
                                win.close()
                            }

                        });
            }



            function renombrar() { 
                var frm = $('frmPreview')
                var f_id_sel = frm.contentWindow.f_id_sel
                if (f_id_sel == null)
                    return
                var file_sel = frm.contentWindow.files[f_id_sel]
                var filename_actual = file_sel.f_ext != '' ? file_sel.f_nombre + '.' + file_sel.f_ext : file_sel.f_nombre

                nvFW.confirm("Renombrar archivo:</b> <div style='width:100%' id='divNC'><input id='txt_nc' style='width:100%' value='" + filename_actual + "' /></div>",
                   {
                    width: 350,
                            cancel: function(win) {
                                win.close();
                                return
                            },
                            ok: function(win) {
                                if ($('txt_nc').value != "") {
                                    if (!filename_validar($('txt_nc').value))
                                        return
                                    var filename = filename_parse($('txt_nc').value)
                                    nvFW.error_ajax_request('/fw/files/file_dialog.aspx', {
                                        bloq_contenedor_on: false,
                                        asynchronous: false,
                                        parameters: {accion: 'renombrar', f_id: file_sel.f_id, f_nombre: filename.f_nombre, f_ext: filename.f_ext},
                                        onSuccess: function(err) {
                                            link_onclick(file.f_id, file.ref_files_path)
                                        },
                                        onFailure: function(err) {
                                        }
                                    })




                                    win.close()
                                }
                                else {
                                    alert("El nombre no puede estar vacío")
                                    return
                                }
                                win.close()
                            }
                   })
            }

            function filename_parse(filename) {
                var res = {}
                var pos = -1
                while (filename.indexOf('.', pos + 1) != - 1)
                    pos = filename.indexOf('.', pos)

                if (pos != -1) {
                    res.f_nombre = filename.substring(0, pos)
                    res.f_ext = filename.substring(pos + 1, filename.length)
                }
                else {
                    res.f_nombre = filename
                    res.f_ext = ''
                }
                return res
            }

            function filename_validar(filename) {
                char_valid = {}
                char_valid[32] = " "
                char_valid[33] = "!"
                char_valid[34] = "\""
                char_valid[35] = "#"
                char_valid[36] = "$"
                char_valid[37] = "%"
                char_valid[38] = "&"
                char_valid[39] = "'"
                char_valid[40] = "("
                char_valid[41] = ")"
                char_valid[43] = "+"
                char_valid[44] = ","
                char_valid[45] = "-"
                char_valid[46] = "."

                char_valid[48] = "0"
                char_valid[49] = "1"
                char_valid[50] = "2"
                char_valid[51] = "3"
                char_valid[52] = "4"
                char_valid[53] = "5"
                char_valid[54] = "6"
                char_valid[55] = "7"
                char_valid[56] = "8"
                char_valid[57] = "9"

                char_valid[61] = "="

                char_valid[64] = "@"
                char_valid[65] = "A"
                char_valid[66] = "B"
                char_valid[67] = "C"
                char_valid[68] = "D"
                char_valid[69] = "E"
                char_valid[70] = "F"
                char_valid[71] = "G"
                char_valid[72] = "H"
                char_valid[73] = "I"
                char_valid[74] = "J"
                char_valid[75] = "K"
                char_valid[76] = "L"
                char_valid[77] = "M"
                char_valid[78] = "N"
                char_valid[79] = "O"
                char_valid[80] = "P"
                char_valid[81] = "Q"
                char_valid[82] = "R"
                char_valid[83] = "S"
                char_valid[84] = "T"
                char_valid[85] = "U"
                char_valid[86] = "V"
                char_valid[87] = "W"
                char_valid[88] = "X"
                char_valid[89] = "Y"
                char_valid[90] = "Z"

                char_valid[91] = "["
                char_valid[93] = "]"
                char_valid[95] = "_"


                char_valid[97] = "a"
                char_valid[98] = "b"
                char_valid[99] = "c"
                char_valid[100] = "d"
                char_valid[101] = "e"
                char_valid[102] = "f"
                char_valid[103] = "g"
                char_valid[104] = "h"
                char_valid[105] = "i"
                char_valid[106] = "j"
                char_valid[107] = "k"
                char_valid[108] = "l"
                char_valid[109] = "m"
                char_valid[110] = "n"
                char_valid[111] = "o"
                char_valid[112] = "p"
                char_valid[113] = "q"
                char_valid[114] = "r"
                char_valid[115] = "s"
                char_valid[116] = "t"
                char_valid[117] = "u"
                char_valid[118] = "v"
                char_valid[119] = "w"
                char_valid[120] = "x"
                char_valid[121] = "y"
                char_valid[122] = "z"

                char_valid[123] = "{"
                char_valid[125] = "}"

                char_valid[193] = "Á"
                char_valid[201] = "É"
                char_valid[205] = "Í"
                char_valid[211] = "Ó"
                char_valid[218] = "Ú"

                char_valid[225] = "á"
                char_valid[233] = "é"
                char_valid[237] = "í"
                char_valid[243] = "ó"
                char_valid[250] = "ú"

                char_valid[209] = "Ñ"
                char_valid[241] = "ñ"

                for (var c = 0; c < filename.length; c++)
                    if (char_valid[filename.charCodeAt(c)] == undefined) {
                        alert("Carácter inválido (" + filename.charAt(c) + ")")
                        return false
                    }


                return true
            }

            function eliminar() { 
                var frm = $('frmPreview')
                var f_id_sel = frm.contentWindow.f_id_sel
                if (f_id_sel == null)
                    return
                var file_sel = frm.contentWindow.files[f_id_sel]
                var filename_actual = file_sel.f_ext != '' ? file_sel.f_nombre + '.' + file_sel.f_ext : file_sel.f_nombre
                nvFW.confirm("¿Desea eliminar \"" + filename_actual + "\"?",{cancel: function(win) 
                                                                                         {
                                                                                         win.close();
                                                                                         return
                                                                                         },
                                                                             ok: function(win) 
                                                                                    {
                                                                                    nvFW.error_ajax_request('/fw/files/file_dialog.aspx', {
                                                                                    bloq_contenedor_on: false,
                                                                                    asynchronous: false,
                                                                                    parameters: {accion: 'eliminar', f_id: file_sel.f_id},
                                                                                                 onSuccess: function(err) 
                                                                                                   { 
                                                                                                   link_onclick(file.f_id, file.ref_files_path)
                                                                                                   },
                                                                                                 onFailure: function(err) 
                                                                                                    {
                                                                                                    }
                                                                                                })
                                                                                    win.close()
                                                                                    } 
                                                                              } )

                return
                Dialog.confirm("<b>¿Desea eliminar \"" + filename_actual + "\"?</b>", {width: 350,
                    className: "alphacube",
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    cancel: function(win) {
                        win.close();
                        return
                    },
                    ok: function(win) {
                        nvFW.error_ajax_request('/fw/files/file_dialog.aspx', {
                            bloq_contenedor_on: false,
                            asynchronous: false,
                            parameters: {accion: 'eliminar', f_id: file_sel.f_id},
                            onSuccess: function(err) {
                                link_onclick(file.f_id, file.ref_files_path)
                            },
                            onFailure: function(err) {
                            }
                        })
                        win.close()
                    }
                });
            }

            function upload(campo_def) { 
                var f_id = campos_defs.get_value(campo_def)
                nvFW.error_ajax_request('/fw/files/file_dialog.aspx', {
                    bloq_contenedor_on: false,
                    asynchronous: false,
                    parameters: {accion: 'archivo_alta', f_depende_de: file.f_id, f_id: f_id},
                    onSuccess: function(err) {
                        link_onclick(file.f_id, file.ref_files_path)
                    },
                    onFailure: function(err) {
                    }
                })

            }
        </script>

        <script type="text/javascript">

            function btnMiniatura_onclick() {
                view = 'miniatura'
                link_onclick(file.f_id, file.ref_files_path)
            }

            function btnDetalle_onclick() {
                view = 'detalle'
                link_onclick(file.f_id, file.ref_files_path)
            }

            function btnSeguridad_onclick() {
                var frm = $('frmPreview')
                var f_id_sel = frm.contentWindow.f_id_sel
                if (f_id_sel == null) {
                    alert("Seleccione el archivo")
                    return
                }

                var win = window.top.nvFW.createWindow({
                    title: 'Seguridad',
                    url: '/fw/files/ref_file_permisos_abm.aspx?f_id=' + f_id_sel,
                    width: 700,
                    height: 450
                })
                win.showCenter(true)
               
            }

            function btnPropiedades_onclick(f_id_sel) {

                if (f_id_sel == undefined) {
                    var frm = $('frmPreview')
                    var f_id_sel = frm.contentWindow.f_id_sel
                    if (f_id_sel == null) {
                        alert("Seleccione el archivo")
                        return
                    }
                }

                var win = window.top.nvFW.createWindow({
                    title: 'Propiedades',
                    //url: '../fw/file_dialog/ref_file_pvalues_abm.aspx?f_id=' + f_id_sel,
                    url: '/fw/files/file_properties.aspx?f_id=' + f_id_sel,
                    width: 600,
                    height: 400
                })
                win.showCenter(true)


            }


            function btnFirmar_onclick(f_id_sel) {

                
                if (f_id_sel == undefined) {
                    var frm = $('frmPreview')
                    var f_id_sel = frm.contentWindow.f_id_sel
                    if (f_id_sel == null) {
                        alert("Seleccione el archivo")
                        return
                    }
                }

                nvFW.error_ajax_request('/eliminar/client_conection_status.aspx', {
                    bloq_contenedor_on: true,
                    onSuccess: function (err, transport) {
                        
                        if (err.numError == 0) {
                            var connected = err.params["status"]
                            if (connected=="connected") {
                                openSignDocumentWindow()
                            } else {
                                openQRScanWindow()
                            }
                        }
                    }
                })
            }


            function openSignDocumentWindow(f_id_sel) {

                if (f_id_sel == undefined) {
                    var frm = $('frmPreview')
                    var f_id_sel = frm.contentWindow.f_id_sel
                    if (f_id_sel == null) {
                        alert("Seleccione el archivo")
                        return
                    }
                }

                var win = window.top.nvFW.createWindow({
                    title: 'Firmar archivo',
                    url: '/fw/visor_pdf/pdf_visor.aspx?modo=sign_file&f_id=' + f_id_sel,
                    width: 600,
                    height: 400
                })
                win.showCenter(true)
            }


            function openQRScanWindow() {
                var win = window.top.nvFW.createWindow({
                    title: 'Vincular dispositivo a servidor',
                    url: '/eliminar/qr_vinculo_scan.aspx?',
                    width: 600,
                    height: 400,
                    onClose: function () {
                        var connectionEstablished = win.options.userData.retorno["connection_established"];
                        if (connectionEstablished) {
                            openSignDocumentWindow()
                        } 
                    },
                    destroyOnClose: true
                })
                win.options.userData = { retorno: {} }
                win.showCenter(true)
            }


            function buscar_onclick() {
                if ($('divBuscar').style.display == 'none') {
                    $('divLink').style.display = 'none'
                    $('divBuscar').style.display = 'block'
                } else {
                    $('divBuscar').style.display = 'none'
                    $('divLink').style.display = 'block'
                }

                window_onresize_iframe()
            }

            function capturar_enter_buscar(e) {
                if (e.keyCode == 13)
                    buscar()
            }

            function mostrar_opciones_fechas() {
                if ($('fecha_modificacion').checked)
                    $('div_opcion_fecha').style.display = 'block'
                else
                    $('div_opcion_fecha').style.display = 'none'
                $('fecha').value = ''
                campos_defs.set_value('db_fechadesde', '')
                campos_defs.set_value('db_fechahasta', '')
                $('div_especificar_fecha').style.display = 'none'
            }

            function mostrar_especificar_fechas(_this) {
                if (_this.value == '5')
                    $('div_especificar_fecha').style.display = 'block'
                else
                    $('div_especificar_fecha').style.display = 'none'
                campos_defs.set_value('db_fechadesde', '')
                campos_defs.set_value('db_fechahasta', '')
            }

            function mostrar_opciones_tamanios() {
                if ($('check_tamanio').checked)
                    $('div_opcion_tamanio').style.display = 'block'
                else
                    $('div_opcion_tamanio').style.display = 'none'
                $('tamanio').value = ''
                campos_defs.set_value('db_tamanio', '')
                $('div_especificar_tamanio').style.display = 'none'
            }

            function mostrar_especificar_tamanio(_this) {
                if (_this.value == '5')
                    $('div_especificar_tamanio').style.display = 'block'
                else
                    $('div_especificar_tamanio').style.display = 'none'
                campos_defs.set_value('db_tamanio', '')
            }

            function mostrar_categorias() {
                if ($('check_categoria').checked)
                    $('div_categorias').style.display = 'block'
                else
                    $('div_categorias').style.display = 'none'
                campos_defs.set_value('db_categorias', '')
            }

            function allTrim(myString) {
                return myString.replace(/\s/g, '');
            }

            var propiedades
            var nombres
            var filtros_generales
            var rtta_busqueda
            var categorias_db

            function buscar_old() {
                $('txtPath').value = ''
                var buscar_texto = $('buscar_texto').value
                var filtro_propiedades = ''
                var filtro_nombre = ''
                var filtro_categorias = ''
                var filtro = ''
                var categorias = ''
                propiedades = new Array()
                nombres = new Array()
                categorias_db = new Array()
                filtros_generales = new Array()
                rtta_busqueda = new Array()
                var vacio

                if (buscar_texto != '') {
                    //** Búsqueda por propiedades: categorías FIMD_IPTC y DB_METADATA **//
                    if ($('check_iptc').checked)
                        categorias += (categorias == '') ? '9' : ', 9'

                    if ($('check_db').checked)
                        categorias += (categorias == '') ? '15' : ', 15'

                    if (categorias != '') {
                        //CONTAINS(valor,'"+buscar_texto+"')
                        //Las consultas de búsqueda de texto que utilizan FREETEXT son menos precisas que las consultas de texto que utilizan CONTAINS
                        filtro_propiedades += "<SQL type='sql'>FREETEXT(valor,'" + buscar_texto + "')</SQL>"
                        filtro_propiedades += "<id_rfile_pcat type='in'>" + categorias + "</id_rfile_pcat>"
                    }
                }

                if (filtro_propiedades != '') {
                    var i = 0
                    var rs = new tRS();
                    rs.open("<criterio><select vista='verRef_file_texto'><campos>*</campos><orden></orden><filtro>" + filtro_propiedades + "</filtro></select></criterio>")

                    while (!rs.eof()) {
                        vacio = new Array()
                        vacio['f_id'] = rs.getdata('f_id')
                        propiedades[i] = vacio
                        i++
                        rs.movenext()
                    }
                    //rtta_busqueda = propiedades
                }

                //** Búsqueda por Todo o Parte del Nombre **//
                if ($('check_nombre').checked && ($('buscar_texto').value != ''))
                    filtro_nombre += "<filename type='like'>%" + $('buscar_texto').value + "%</filename>"

                if (filtro_nombre != '') {
                    var j = 0
                    var rs = new tRS();
                    rs.open("<criterio><select vista='verRef_files'><campos>*</campos><orden></orden><filtro>" + filtro_nombre + "</filtro></select></criterio>")

                    while (!rs.eof()) {
                        vacio = new Array()
                        vacio['f_id'] = rs.getdata('f_id')
                        nombres[j] = vacio
                        j++
                        rs.movenext()
                    }
                }
                rtta_busqueda = propiedades.concat(nombres)
                rtta_busqueda = unique(rtta_busqueda)


                //** Búsqueda por Categorías **//
                if ($('check_categoria').checked) {
                    var db_categorias = campos_defs.get_value('db_categorias')
                    if (db_categorias != '') { //"1, 20, 3, 4"

                        filtro_categorias += "<rfile_param type='igual'>'db_categorias'</rfile_param>"

                        var array_categorias = db_categorias.split(',')
                        for (var i = 0; i < array_categorias.length; i++)
                            filtro_categorias += "<SQL type='sql'>FREETEXT(valor,'" + allTrim(array_categorias[i]) + "')</SQL>"
                    }
                }

                if (filtro_categorias != '') {
                    var i = 0
                    var rs = new tRS();
                    rs.open("<criterio><select vista='verRef_file_texto'><campos>*</campos><orden></orden><filtro>" + filtro_categorias + "</filtro></select></criterio>")

                    while (!rs.eof()) {
                        vacio = new Array()
                        vacio['f_id'] = rs.getdata('f_id')
                        categorias_db[i] = vacio
                        i++
                        rs.movenext()
                    }

                    if ((rtta_busqueda.length == 0) && (filtro_propiedades == '') && (categorias_db.length > 0))
                        rtta_busqueda = categorias_db
                    else if (!((rtta_busqueda.length > 0) && (filtro_categorias == '') && (categorias_db.length == 0)))
                        rtta_busqueda = intersect(rtta_busqueda, categorias_db)

                }

                //** Búsqueda por Todo o Parte del Nombre **//
                if ($('check_nombre').checked)
                    filtro += "<filename type='like'>%" + $('buscar_texto').value + "%</filename>"


                //** Búsqueda por Tamaño **//
                if ($('check_tamanio').checked) {
                    if ($('tamanio').value > 0) {
                        filtro += "<f_nro_tipo type='igual'>1</f_nro_tipo>" //Solo para archivos

                        switch ($('tamanio').value) {
                            case "1": //No lo recuerdo
                                break
                            case "2": //Pequeño (menos de 100 KB)
                                filtro += "<f_size type='menor'>100</f_size>"
                                break
                            case "3": //Mediano (menos de 1 MB) (100MB*1024KB)
                                filtro += "<f_size type='menor'>102400</f_size>"
                                break
                            case "4": //Grande (más de 1 MB)
                                filtro += "<f_size type='mayor'>102400</f_size>"
                                break
                            case "5": //Especificar tamaño (en KB)
                                var db_tamanio = campos_defs.get_value('db_tamanio')
                                if ((db_tamanio != '') && (db_tamanio > 0))
                                    filtro += "<f_size type='igual'>" + db_tamanio + "</f_size>"
                                break
                        }
                    }
                }

                //** Búsqueda por Fecha de Modificación **//
                if ($('fecha_modificacion').checked) {
                    if ($('fecha').value > 0) {

                        var today = new Date()
                        var year = today.getYear()
                        var month = today.getMonth()
                        var day = today.getDate()

                        switch ($('fecha').value) {
                            case "1": //No lo recuerdo
                                break
                            case "2": //La semana pasada
                                var nMonth = today.getMonth() + 1
                                var nDOW = today.getDay()
                                var sFirstDate = ""
                                var sLastDate = ""
                                if (nDOW == 0)
                                    nDOW = 7
                                sLastDate = addToDate(makeDateFormat(day, nMonth, year), -1 * nDOW)
                                sFirstDate = addToDate(sLastDate, -6)
                                filtro += (sFirstDate != "") ? "<f_falta type='mayor'>CONVERT(datetime, '" + sFirstDate + "', 103)</f_falta>" : ""
                                filtro += (sLastDate != "") ? "<f_falta type='menor'>CONVERT(datetime, '" + sLastDate + "', 103)</f_falta>" : ""
                                break
                            case "3": //El mes pasado
                                var last_month = (month == 1) ? 12 : month - 1
                                var last_year = (month == 1) ? year - 1 : year
                                filtro += "<f_falta type='igual'>MONTH('" + last_month + "')</f_falta><f_falta type='igual'>YEAR('" + last_year + "')</f_falta>"
                                break
                            case "4": //El año pasado
                                var last_year = year - 1
                                filtro += "<f_falta type='igual'>YEAR('" + last_year + "')</f_falta>"
                                break
                            case "5": //Especificar fecha
                                var db_fechadesde = campos_defs.get_value('db_fechadesde')
                                var db_fechahasta = campos_defs.get_value('db_fechahasta')
                                filtro += (db_fechadesde != "") ? "<f_falta type='mayor'>CONVERT(datetime, '" + db_fechadesde + "', 103)</f_falta>" : ""
                                filtro += (db_fechahasta != "") ? "<f_falta type='menor'>CONVERT(datetime, '" + db_fechahasta + "', 103)</f_falta>" : ""
                                break
                        }
                    }
                }

                if (filtro != '') {
                    if (($('buscar_texto').value != '') && (!$('check_nombre').checked))
                        filtro += "<filename type='like'>%" + $('buscar_texto').value + "%</filename>"

                    var j = 0
                    var rs = new tRS();
                    rs.open("<criterio><select vista='verRef_files'><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>")

                    while (!rs.eof()) {
                        vacio = new Array()
                        vacio['f_id'] = rs.getdata('f_id')
                        filtros_generales[j] = vacio
                        j++
                        rs.movenext()
                    }
                }

                if ((rtta_busqueda.length == 0) && (filtro_categorias == '') && (filtros_generales.length > 0))
                    rtta_busqueda = filtros_generales
                else if (!((rtta_busqueda.length > 0) && (filtro == '') && (filtros_generales.length == 0)))
                    rtta_busqueda = intersect(rtta_busqueda, filtros_generales)


                var f_id = ''
                if (rtta_busqueda.length > 0) {
                    for (var i = 0; i < rtta_busqueda.length; i++)
                        f_id += (f_id == '') ? rtta_busqueda[i]['f_id'] : ', ' + rtta_busqueda[i]['f_id']
                }
                var filter = $('cbFilters').options[$('cbFilters').selectedIndex].value
                f_id = (f_id == '') ? '-1' : f_id
                file.f_id = -1
                file.ref_files_path = 'Busqueda'
                
                
                var filtroXML = "<criterio><select vista='verRef_files'><campos>f_id, f_nombre, f_ext, f_size, f_falta, f_nro_tipo, f_depende_de, ref_files_path, parent_ref_files_path</campos><filtro><f_id type='in'>" + f_id + "</f_id></filtro><orden>f_nro_tipo, f_nombre</orden></select></criterio>"
                nvFW.exportarReporte({
                    //Parametros de consulta
                    filtroXML: filtroXML,
                    //parametros: '<parametros><filter>' + filter + '</filter><file f_depende_de="' + file.f_id + '" /></parametros>',
                    parametros: '<parametros><filter>' + filter + '</filter></parametros>',
                    path_xsl: view == 'detalle' ? "report\\file_dialog\\verRef_files\\html_detalle.xsl" : "report\\file_dialog\\verRef_files\\html_miniatura.xsl",
                    formTarget: "frmPreview",
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0,
                    bloq_contenedor: "",
                    cls_contenedor: "frmPreview"
                })
            }

            function buscar() { 
                
                $('txtPath').value = ''
                var buscar_texto = $('buscar_texto').value

                var filtro_propiedades = ''
                var filtro_nombre = ''
                var filtro_categorias = ''
                var filtro = ''
                var categorias = ''
                var propiedades = ''

                var db = 0
                var iptc = 0
                var exif = 0
                var id_rfile_param = null


                if (buscar_texto != '') {
                    //** Búsqueda por propiedades: categorías FIMD_IPTC y DB_METADATA **//
                    if ($('check_iptc').checked)
                        iptc = 1

                    if ($('check_db').checked)
                        db = 1

                    if (iptc == 1 || db == 1)
                    {
                        var rs1
                        rs1 = new tRS();
                        rs1.open("<criterio><select vista=\"dbo.txt_ref_file('" + allTrim(buscar_texto) + "', " + db + ", " + iptc + ", " + exif + ", " + id_rfile_param + ")\"><campos>*</campos><orden></orden></select></criterio>")

                        while (!rs1.eof()) {
                            propiedades += (propiedades == '') ? rs1.getdata('f_id') : ', ' + rs1.getdata('f_id')
                            rs1.movenext()
                        }
                    }

                    filtro_propiedades = (propiedades != '') ? "<f_id type='in'>" + propiedades + "</f_id>" : ""

                    //filtro_propiedades = filtro_propiedades  != "" ? "<OR>" + filtro_propiedades + "<filename type='like'>%" + buscar_texto + "%</filename></OR>" : ""

                    //** Búsqueda por Todo o Parte del Nombre **//
                    if ($('check_nombre').checked)
                        filtro_nombre += "<filename type='like'>%" + buscar_texto + "%</filename>"

                    if (filtro_nombre == "" && filtro_propiedades == "")
                        filtro += "<filename type='like'>%" + buscar_texto + "%</filename>"

                    if (filtro_nombre != "" && filtro_propiedades != "")
                        filtro += "<OR>" + filtro_propiedades + filtro_nombre + "</OR>"

                    if (filtro_nombre != "" && filtro_propiedades == "")
                        filtro += filtro_nombre

                    if (filtro_nombre == "" && filtro_propiedades != "")
                        filtro += filtro_propiedades

                }


                //** Búsqueda por Categorías **//
                if ($('check_categoria').checked) {
                    var db_categorias = campos_defs.get_value('db_categorias')

                    if (db_categorias != '') {//"1, 20, 3, 4"
                        var array_categorias = db_categorias.split(',')
                        var rs

                        for (var i = 0; i < array_categorias.length; i++) {
                            rs = new tRS();
                            rs.open("<criterio><select vista='dbo.txt_ref_file(" + allTrim(array_categorias[i]) + ", 1, 0, 0, 54)'><campos>*</campos><orden></orden></select></criterio>")

                            while (!rs.eof()) {
                                categorias += (categorias == '') ? rs.getdata('f_id') : ', ' + rs.getdata('f_id')
                                rs.movenext()
                            }
                        }
                        filtro_categorias = (categorias != '') ? "<f_id type='in'>" + categorias + "</f_id>" : ""
                    }
                }

                //** Búsqueda por Tamaño **//
                if ($('check_tamanio').checked) {
                    if ($('tamanio').value > 0) {
                        filtro += "<f_nro_tipo type='igual'>1</f_nro_tipo>" //Solo para archivos

                        switch ($('tamanio').value) {
                            case "1": //No lo recuerdo
                                break
                            case "2": //Pequeño (menos de 100 KB)
                                filtro += "<f_size type='menor'>100</f_size>"
                                break
                            case "3": //Mediano (menos de 1 MB) (100MB*1024KB)
                                filtro += "<f_size type='menor'>1024</f_size>"
                                break
                            case "4": //Grande (más de 1 MB)
                                filtro += "<f_size type='mayor'>1024</f_size>"
                                break
                            case "5": //Especificar tamaño (en KB)
                                var db_tamanio = campos_defs.get_value('db_tamanio')
                                if ((db_tamanio != '') && (db_tamanio > 0))
                                    filtro += "<f_size type='igual'>" + db_tamanio + "</f_size>"
                                break
                        }
                    }
                }

                //** Búsqueda por Fecha de Modificación **//
                if ($('fecha_modificacion').checked) {
                    if ($('fecha').value > 0) {

                        var today = new Date()
                        var year = today.getYear()
                        var month = today.getMonth()
                        var day = today.getDate()

                        switch ($('fecha').value) {
                            case "1": //No lo recuerdo
                                break
                            case "2": //La semana pasada
                                var nMonth = today.getMonth() + 1
                                var nDOW = today.getDay()
                                var sFirstDate = ""
                                var sLastDate = ""
                                if (nDOW == 0)
                                    nDOW = 7
                                sLastDate = addToDate(makeDateFormat(day, nMonth, year), -1 * nDOW)
                                sFirstDate = addToDate(sLastDate, -6)
                                filtro += (sFirstDate != "") ? "<f_falta type='mas'>CONVERT(datetime, '" + sFirstDate + "', 103)</f_falta>" : ""
                                filtro += (sLastDate != "") ? "<f_falta type='menor'>DATEADD(dd,1,CONVERT(datetime, '" + sLastDate + "', 103))</f_falta>" : ""
                                break
                            case "3": //El mes pasado
                                //                            var last_month = (month == 1) ? 12 : month - 1
                                //                            var last_year = (month == 1) ? year - 1 : year
                                //                            filtro += "<f_falta type='igual'>MONTH(" + last_month + ")</f_falta><f_falta type='igual'>YEAR(" + last_year + ")</f_falta>"
                                filtro += "<SQL type='sql'>datepart(MONTH,f_falta) = datepart(MONTH,dateadd(mm,-1,getdate())) and "
                                filtro += "datepart(YEAR,f_falta) = datepart(YEAR,dateadd(yy,-1,getdate()))</SQL>"
                                break
                            case "4": //El año pasado
                                //var last_year = year - 1
                                //filtro += "<f_falta type='igual'>YEAR(" + last_year + ")</f_falta>"
                                filtro += "<SQL type='sql'>datepart(YEAR,f_falta) = datepart(YEAR,dateadd(yy,-1,getdate()))</SQL>"
                                break
                            case "5": //Especificar fecha
                                var db_fechadesde = campos_defs.get_value('db_fechadesde')
                                var db_fechahasta = campos_defs.get_value('db_fechahasta')
                                filtro += (db_fechadesde != "") ? "<f_falta type='mas'>CONVERT(datetime, '" + db_fechadesde + "', 103)</f_falta>" : ""
                                filtro += (db_fechahasta != "") ? "<f_falta type='menor'>DATEADD(dd,1,CONVERT(datetime,'" + db_fechahasta + "', 103))</f_falta>" : ""
                                break
                        }
                    }
                }

                if (filtro_categorias != "")
                    filtro += filtro_categorias

                if (filtro == "")
                    filtro += "<f_id type='in'>0</f_id>"

                //Controla que busque solamente sobre los archivos que no estan eliminados
                filtro += "<borrado type='igual'>0</borrado>"


                var filter = $('cbFilters').options[$('cbFilters').selectedIndex].value
                file.f_id = -1
                file.ref_files_path = 'Busqueda'

                var filtroXML = nvFW.pageContents.buscar
   
                //var filtroXML = "<criterio><select vista='verRef_files'><campos>f_id, f_nombre, f_ext, f_size, f_falta, f_nro_tipo, f_depende_de, ref_files_path, parent_ref_files_path</campos><filtro>" + filtro + "</filtro><orden>f_nro_tipo, f_nombre</orden></select></criterio>"
                nvFW.exportarReporte({
                    filtroXML: filtroXML,
                    filtroWhere: filtro,
                    //parametros: '<parametros><filter>' + filter + '</filter><file f_depende_de="' + file.f_id + '" /></parametros>',
                    parametros: '<parametros><filter>' + filter + '</filter></parametros>',
                    path_xsl: view == 'detalle' ? "report\\file_dialog\\verRef_files\\html_detalle.xsl" : "report\\file_dialog\\verRef_files\\html_miniatura.xsl",
                    formTarget: "frmPreview",
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0,
                    bloq_contenedor: "",
                    cls_contenedor: "frmPreview"
                })
            }

            function intersect(a, b) {
                var result = new Array();
                var vacio
                var k = 0
                for (var i = 0; i < a.length; i++) {
                    for (var j = 0; j < b.length; j++) {
                        if (b[j]['f_id'] == a[i]['f_id']) {
                            vacio = new Array()
                            vacio['f_id'] = b[j]['f_id'];
                            result[k] = vacio
                            k++
                        }
                    }
                }
                return result;
            }

            function unique(arrayName) {
                var newArray = new Array();
                label: for (var i = 0; i < arrayName.length; i++) {
                    for (var j = 0; j < newArray.length; j++) {
                        if (newArray[j]['f_id'] == arrayName[i]['f_id'])
                            continue label;
                    }
                    newArray[newArray.length] = arrayName[i];
                }
                return newArray;
            }


            function padNmb(nStr, nLen, sChr) {
                var sRes = String(nStr);
                for (var i = 0; i < nLen - String(nStr).length; i++)
                    sRes = sChr + sRes;
                return sRes;
            }

            function makeDateFormat(nDay, nMonth, nYear) {
                var sRes;
                sRes = padNmb(nDay, 2, "0") + "/" + padNmb(nMonth, 2, "0") + "/" + padNmb(nYear, 4, "0");
                return sRes;
            }

            function prevMonth(nMonth) {
                return ((nMonth + 10) % 12) + 1;
            }

            function prevMonth_Year(nMonth, nYear) {
                return nYear - (((nMonth + 10) % 12) + 1 == 12 ? 1 : 0);
            }

            function lastDayOfMonth(nMonth, nYear) {
                var aMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
                if ((nMonth == 2) && (nYear % 4 == 0))
                    return 29;
                else
                    return aMonth[nMonth - 1];
            }

            function incDate(sFec0) {
                var nDia = parseInt(sFec0.substr(0, 2), 10);
                var nMes = parseInt(sFec0.substr(3, 2), 10);
                var nAno = parseInt(sFec0.substr(6, 4), 10);
                nDia += 1;
                if (nDia > lastDayOfMonth(nMes, nAno)) {
                    nDia = 1;
                    nMes += 1;
                    if (nMes == 13) {
                        nMes = 1;
                        nAno += 1;
                    }
                }
                return makeDateFormat(nDia, nMes, nAno);
            }

            function decDate(sFec0) {
                var nDia = parseInt(sFec0.substr(0, 2), 10);
                var nMes = parseInt(sFec0.substr(3, 2), 10);
                var nAno = parseInt(sFec0.substr(6, 4), 10);
                nDia -= 1;
                if (nDia == 0) {
                    nMes -= 1;
                    if (nMes == 0) {
                        nMes = 12;
                        nAno -= 1;
                    }
                    nDia = lastDayOfMonth(nMes, nAno);
                }
                return makeDateFormat(nDia, nMes, nAno);
            }

            function addToDate(sFec0, nInc) {
                var nIncAbs = Math.abs(nInc);
                var sRes = sFec0;
                if (nInc >= 0)
                    for (var i = 0; i < nIncAbs; i++)
                        sRes = incDate(sRes);
                else
                    for (var i = 0; i < nIncAbs; i++)
                        sRes = decDate(sRes);
                return sRes;
            }

            function btnPreview_onclick(f_id) { 
                
                var win = window.top.nvFW.createWindow({className: "alphacube",
                    title: "Thumbnail",
                    width: 700, height: 500,
                    minimizable: true,
                    maximizable: true,
                    resizable: true,
                    draggable: true
                })
                var url = '/fw/files/file_preview.aspx?f_id=' + f_id + '&height=0&width=0&id_ventana=' + win.getId()
                win.setURL(url)
                win.showCenter(true);
            }

        </script>

    </head>
    <body onload="return window_onload()" onresize="window_onresize()" style="height: 100%;
          width: 100%; overflow: hidden;">
        <div id="divMenuDatosFile" style="margin: 0px; padding: 0px; width: 100%">
        </div>

        <script language="javascript" type="text/javascript">
            var vMenuDatosFile = new tMenu('divMenuDatosFile', 'vMenuDatosFile');
            vMenuDatosFile.loadImage("disco", "../image/file_dialog/disco.png")
            vMenuDatosFile.loadImage("carpeta", "../image/file_dialog/carpeta.png")
            vMenuDatosFile.loadImage("editar", "../image/file_dialog/editar.png")
            vMenuDatosFile.loadImage("eliminar", "../image/file_dialog/eliminar.png")
            vMenuDatosFile.loadImage("actualizar", "../image/file_dialog/actualizar.png")
            vMenuDatosFile.loadImage("upload", "../image/file_dialog/upload.png")
            vMenuDatosFile.loadImage("detalle", "../image/file_dialog/detalle.png")
            vMenuDatosFile.loadImage("miniatura", "../image/file_dialog/miniatura.png")
            vMenuDatosFile.loadImage("clave", "../image/file_dialog/clave.png")
            vMenuDatosFile.loadImage("propiedades", "../image/file_dialog/propiedades.png")
            vMenuDatosFile.loadImage("seguridad", "../image/file_dialog/seguridad.png")
            
            Menus["vMenuDatosFile"] = vMenuDatosFile
            Menus["vMenuDatosFile"].alineacion = 'centro';
            Menus["vMenuDatosFile"].estilo = 'A';

//            Menus["vMenuDatosFile"].imagenes = Imagenes //Imagenes se declara en pvUtiles                  
            //Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>exit</icono><Desc>Salir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnCancelar()</Codigo></Ejecutar></Acciones></MenuItem>")
            //Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Carpeta:</Desc><Acciones></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>disco</icono><Desc>Nuevo Disco</Desc><Acciones><Ejecutar Tipo='script'><Codigo>disco_alta()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>carpeta</icono><Desc>Nueva carpeta</Desc><Acciones><Ejecutar Tipo='script'><Codigo>carpeta_alta()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Renombrar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>renombrar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>actualizar</icono><Desc>Actualizar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnActualizar_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='6'><Lib TipoLib='offLine'>DocMNG</Lib><icono>detalle</icono><Desc>Detalle</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnDetalle_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='7'><Lib TipoLib='offLine'>DocMNG</Lib><icono>miniatura</icono><Desc>Miniatura</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnMiniatura_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='8'><Lib TipoLib='offLine'>DocMNG</Lib><icono>seguridad</icono><Desc>Seguridad</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnSeguridad_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='9'><Lib TipoLib='offLine'>DocMNG</Lib><icono>propiedades</icono><Desc>Propiedades</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnPropiedades_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuDatosFile"].CargarMenuItemXML("<MenuItem id='10'><Lib TipoLib='offLine'>DocMNG</Lib><icono>propiedades</icono><Desc>Firmar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnFirmar_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
        </script>

        <table class="tb1" id="tbTree">
            <tr id="trContenedor">
                <td style="width: 150px; height: 100%; vertical-align: top" rowspan="3">
                    <div id="divLink" style="width: 100%; text-align: center; overflow: auto"></div>
                    <br />
                    <div id="divImageBuscar" style="width: 100%; height: 50px; vertical-align: top; text-align: center;overflow: auto">
                        <img alt='' name='Buscar' src='../image/file_dialog/buscar32.png' style='cursor: pointer;
                             cursor: hand' onclick='buscar_onclick()' /><br />
                        Buscar Archivo
                    </div>
                    <div id="divBuscar" style="display: none; width: 150px; height: 320px; vertical-align: top;
                         text-align: center; overflow: auto">
                        <table class="tb1">
                            <tr>
                                <td style="width: 90%">
                                    <input style='text-align: left; width: 100%;' type="text" name="buscar_texto" id="buscar_texto"
                                           value="" onkeypress="capturar_enter_buscar(event)" />
                                </td>
                                <td style="width: 5%">
                                    <img alt='' name='Buscar' src='../image/icons/buscar.png' style='cursor: pointer;
                                         cursor: hand' onclick='buscar()' />
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr>
                                <td style="width: 100%; height: 20px" colspan="3">
                                    <p>
                                        <b>Buscar por:</b></p>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 100%">
                                    <input type="checkbox" name="check_nombre" id="check_nombre" value="" checked="checked" />
                                    Nombre
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 100%">
                                    <input type="checkbox" name="check_db" id="check_db" value="" checked="checked" />
                                    Prop. Base de Datos
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 100%">
                                    <input type="checkbox" name="check_iptc" id="check_iptc" value="" />
                                    Prop. IPTC
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 100%">
                                    <input type="checkbox" name="check_categoria" id="check_categoria" value="" onclick='mostrar_categorias()' />
                                    Categoría
                                </td>
                            </tr>
                            <tr style="display: none" id="div_categorias">
                                <td style="width: 100%;">

                                    <script type="text/javascript">

                                         campos_defs.add('db_categorias', {enDB: false,
                                            nro_campo_tipo: 2,
                                            depende_de: null,
                                            depende_de_campo: null,
                                            filtroXML: "<criterio><select vista='ref_file_db_categorias'><campos> distinct id_rfile_db_categoria as id, rfile_db_categoria as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                            filtroWhere: "<id_rfile_db_categoria  type='in'>%campo_value%</id_rfile_db_categoria>"
                                        })
                                    </script>

                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr>
                                <td style="width: 40%">
                                    <input type="checkbox" name="check_tamanio" id="check_tamanio" value="" onclick='mostrar_opciones_tamanios()' />
                                    Tamaño
                                </td>
                            </tr>
                            <tr style="display: none" id="div_opcion_tamanio">
                                <td style="width: 100%;">
                                    <select style="width: 100%;" id="tamanio" name="tamanio" onchange="mostrar_especificar_tamanio(this)">
                                        <option value="0"></option>
                                        <option value="1">No lo recuerdo</option>
                                        <option value="2">Pequeño (menos de 100 KB)</option>
                                        <option value="3">Mediano (menos de 1 MB)</option>
                                        <option value="4">Grande (más de 1 MB)</option>
                                        <option value="5">Especificar tamaño (en KB)</option>
                                    </select>
                                </td>
                            </tr>
                            <tr style="display: none" id="div_especificar_tamanio">
                                <td style="width: 100%;">

                                    <script type="text/javascript">
                                        campos_defs.add("db_tamanio", { nro_campo_tipo: 100, enDB: false })
                                    </script>

                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr>
                                <td style="width: 100%">
                                    <input type="checkbox" name="fecha_modificacion" id="fecha_modificacion" value=""
                                           onclick='mostrar_opciones_fechas()' />
                                    Fecha Modificación
                                </td>
                            </tr>
                            <tr style="display: none" id="div_opcion_fecha">
                                <td style="width: 100%;">
                                    <select style="width: 100%;" id="fecha" name="fecha" onchange="mostrar_especificar_fechas(this)">
                                        <option value="0"></option>
                                        <option value="1">No lo recuerdo</option>
                                        <option value="2">La semana pasada</option>
                                        <option value="3">El mes pasado</option>
                                        <option value="4">El año pasado</option>
                                        <option value="5">Especificar fecha</option>
                                    </select>
                                </td>
                            </tr>
                            <tr style="display: none" id="div_especificar_fecha">
                                <td style="width: 100%;">
                                    <table>
                                        <tr>
                                            <td style="width: 20%">
                                                Desde:
                                            </td>
                                            <td style="width: 80%">

                                                <script type="text/javascript">
                                                    campos_defs.add('db_fechadesde', {enDB: false, nro_campo_tipo: 103})
                                                </script>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 20%">
                                                Hasta:
                                            </td>
                                            <td style="width: 80%">

                                                <script type="text/javascript">
                                                    campos_defs.add('db_fechahasta', {enDB: false, nro_campo_tipo: 103})
                                                </script>

                                            </td>
                                        </tr>

                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
                <td id="tbUb" style='height: 20px'>
                    <table class="tb1">
                        <tr>
                            <td class="Tit4" style='height: 20px; width: 70px'>
                                &nbsp;Ubicación:&nbsp;&nbsp;
                            </td>
                            <td >
                                <input type="text" id='txtPath' style="width: 100%" readonly="true" value='' />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <iframe name='frmPreview' id="frmPreview" src="/fw/enBlanco.htm" style="width: 100%;height: 100%; overflow:auto" scrolling="yes" frameborder="0"></iframe>
                </td>
            </tr>
            <tr >
                <td id="tbEx" style='height: 20px'>
                    <table class="tb1">
                        <tr>
                            <td class="Tit4" style='height: 20px; white-space: nowrap;'>
                                &nbsp;Registros por página&nbsp;&nbsp;
                            </td>
                            <td style='white-space: nowrap; width: 250px'>
                                <select id="pageSize" onchange="return filters_onchange()" style="width: 100%; padding-right: 2px;">
                                    <option value="14">15</option>
                                    <option value="49" selected="selected">50</option>
                                    <option value="99">100</option>
                                    <option value="-">Todas</option>
                                </select>
                            </td>
                            <td class="Tit4" style='height: 20px; white-space: nowrap;'>
                                <div class="thumbSizeTd">
                                    &nbsp;Tamaño de miñatura&nbsp;&nbsp;
                                </div>
                            </td>
                            <td style='white-space: nowrap; width: 250px; padding-right: 2px;'>
                                <div class="thumbSizeTd">
                                    <select id="thumbSize" onchange="return filters_onchange()" style="width: 100%">
                                        <option value="80">Diminuta</option>
                                        <option value="150" selected="selected">Chica</option>
                                        <option value="250">Mediana</option>
                                        <option value="350">Grande</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td class="Tit4" style='height: 20px; white-space: nowrap'>
                                &nbsp;Filtro&nbsp;&nbsp;
                            </td>
                            <td  style='white-space: nowrap; width: 250px'>
                                <select id='cbFilters' onchange='return filters_onchange()' style='width: 100%; padding-right: 2px;'>
                                </select>
                            </td>
                            <td class="Tit4" style='white-space: nowrap;'>
                                &nbsp;Subir archivo&nbsp;&nbsp;
                            </td>
                            <td  id='tdUpload' style='width: 300px !Important; white-space: nowrap; padding-right: 2px;'>

                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <iframe name="frmEnviar" id="frmEnviar" src="enBlanco.htm" style="display: none" frameborder="0"></iframe>
    </body>
</html>
