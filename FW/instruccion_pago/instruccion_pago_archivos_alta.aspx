<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Const nro_def_archivo_default As Integer = 94
    Dim nro_proceso As Integer = nvFW.nvUtiles.obtenerValor("nro_proceso", "-1")
    Dim nro_def_archivo As Integer = nvFW.nvUtiles.obtenerValor("nro_def_archivo", nro_def_archivo_default.ToString)

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim folder As String = Server.MapPath("~/Uploads")
    Dim ordenes As String = nvFW.nvUtiles.obtenerValor("orden", "")
    Dim id_tipo As String = nvFW.nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_com_id_tipo As String = nvFW.nvUtiles.obtenerValor("nro_com_id_tipo", "")
    Dim descripciones As String = nvFW.nvUtiles.obtenerValor("descripciones", "")
    Dim server_name As String = nvApp.cod_servidor
    Dim ids As String = ""
    Dim err As New nvFW.tError()
    Dim operador As Object = nvFW.nvApp.getInstance().operador

    Try
        If modo = "http_post" Then
            Dim contador As Integer = 0

            If accion = "ABM" Then
                Dim pathtemp As String = "\\\\" & server_name & "\\d$\\MeridianoWeb\\Meridiano\\archivos\\"  ' cargar un parametro
                Dim strSQL As String = "SELECT path FROM helpdesk.dbo.nv_servidor_sistema_dir WHERE cod_ss_dir IN (SELECT cod_dir FROM helpdesk.dbo.nv_sistema_dir WHERE cod_directorio_tipo = 2 ) AND cod_sistema = 'nv_mutual' AND cod_servidor = '" & server_name & "' AND cod_ss_dir = 'nvArchivosDefault'"
                Dim rsRova As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
                Dim path_rova As String = ""

                If Not rsRova.EOF Then
                    path_rova = rsRova.Fields("path").Value.Replace("\", "\\")
                End If

                nvDBUtiles.DBCloseRecordset(rsRova)

                Dim archivo As Dictionary(Of String, Object)
                Dim archivos As New Dictionary(Of String, Object)
                Dim archivos_string As String = ""
                Dim Files As HttpFileCollection = Request.Files ' Load File collection into HttpFileCollection variable.          
                Dim extensiones_permitidas() As String = {".pdf", ".jpg", ".jpeg", ".bmp", ".png", ".pif", ".html", ".htm", ".txt"}

                For Each campo In Files.AllKeys
                    Dim descripcion As String = descripciones.ToString().Split(",")(contador)
                    Dim orden As String = ordenes.ToString().Split(",")(contador)
                    contador += 1
                    archivo = New Dictionary(Of String, Object)

                    If Request.Files(campo).FileName <> "" Then
                        ' Guarda los archivos en el directorio_archivos
                        archivo.Add("existe", True)
                        archivo.Add("filename", System.IO.Path.GetFileName(Request.Files(campo).FileName))
                        Dim ext As String = System.IO.Path.GetExtension(archivo("filename")).ToLower()

                        If Array.IndexOf(extensiones_permitidas, ext) > -1 Then
                            If (Request.Files(campo).ContentLength < 8388608) Then
                                archivo.Add("desc", descripcion)
                                archivo.Add("extencion", ext)
                                archivo.Add("orden", orden)

                                Dim nro_def_detalle As String = nvFW.nvUtiles.obtenerValor("nro_def_detalle_" + orden, "")
                                archivo.Add("nro_def_detalle", nro_def_detalle)
                                archivo.Add("size", Request.Files(campo).ContentLength)

                                archivos_string += archivo("filename").ToString().Replace(",", "") + ","

                                Dim binaryData As Byte()
                                Dim binaryReader As New System.IO.BinaryReader(Request.Files(campo).InputStream)
                                binaryData = binaryReader.ReadBytes(Request.Files(campo).ContentLength)
                                archivo.Add("binaryData", binaryData)

                                archivos.Add(orden, archivo)

                                Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset("SELECT ISNULL(MAX(nro_archivo), 0) + 1 AS maxArchivo FROM archivos")
                                Dim nro_archivo As Integer = 0

                                If Not rsA.EOF Then
                                    nro_archivo = rsA.Fields("maxArchivo").Value
                                End If

                                nvFW.nvDBUtiles.DBCloseRecordset(rsA)

                                strSQL = "INSERT INTO archivos (nro_archivo, Descripcion, momento, nro_def_detalle, operador, nro_archivo_estado, nro_img_origen) VALUES('" & nro_archivo & "', '" & descripcion & "', getdate(), '" & nro_def_detalle & "', '" & nvApp.operador.operador & "', 1, 1)"
                                nvFW.nvDBUtiles.DBExecute(strSQL)

                                Dim carpeta As String = DateTime.Now.ToString("yyyyMM")

                                ids &= nro_archivo & ","

                                archivo.Add("id", nro_archivo)
                                archivo.Add("nro_def_archivo", nvFW.nvUtiles.obtenerValor("nro_def_archivo_" + orden, ""))
                                archivo.Add("path", pathtemp & carpeta & "\\" & nro_archivo & archivo("extencion"))

                                nvFW.nvReportUtiles.create_folder(archivo("path"))

                                Request.Files(campo).SaveAs(archivo("path"))

                                If (path_rova <> "") Then
                                    archivo.Add("path_rova", path_rova & carpeta & "\\" & nro_archivo & archivo("extencion"))
                                    nvFW.nvReportUtiles.create_folder(archivo("path_rova"))
                                    Request.Files(campo).SaveAs(archivo("path_rova"))
                                End If

                                strSQL = "UPDATE archivos SET path = '" & carpeta & "\" & nro_archivo & archivo("extencion") & "' WHERE nro_archivo = " & nro_archivo
                                nvFW.nvDBUtiles.DBExecute(strSQL)

                                strSQL = "INSERT INTO proceso_archivo (nro_proceso, nro_archivo) VALUES (" & nro_proceso & ", " & nro_archivo & ")"
                                nvFW.nvDBUtiles.DBExecute(strSQL)
                            Else
                                err.titulo = "Tamaño excesivo"
                                err.mensaje = "El archivo <b>" + System.IO.Path.GetFileName(Request.Files(campo).FileName) + "</b> excede el tamaño permitido."
                                err.response()
                            End If
                        Else
                            err.titulo = "Formato incorrecto"
                            err.mensaje = "El tipo de el/los archivo/s no es valido."
                            err.response()
                        End If
                    Else
                        archivos_string &= ","
                        archivo.Add("existe", False)
                        archivo.Add("filename", "")
                        archivo.Add("extencion", "")
                        archivo.Add("size", "")
                        archivo.Add("path", "")
                        archivo.Add("desc", "")
                    End If
                Next

                Me.contents("success") = 1
                Me.contents("archivos") = archivos_string
                Me.contents("descripciones") = descripciones
                Me.contents("ids") = ids
            End If
        End If
    Catch ex As Exception
        err.parse_error_script(ex)
        err.titulo = "Error al subir los documentos."
        err.mensaje = "Error al subir los documentos."
        err.mostrar_error()
    End Try


    Me.contents.Add("filtro_archivos_def", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_detalle'><campos>*</campos><orden>orden</orden><filtro><nro_def_archivo type='igual'>" & nro_def_archivo & "</nro_def_archivo></filtro></select></criterio>"))
    Me.contents.Add("nro_def_archivo", nro_def_archivo)
    Me.contents.Add("nro_com_id_tipo", nro_com_id_tipo)
    Me.contents.Add("id_tipo", id_tipo)
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Alta de Archivos - Proceso Nº <% = nro_proceso %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
        .file_upload { margin: 0 5px; padding: 2px; cursor: pointer; }
        .file_upload:hover { box-shadow: 0 0 2px grey; }
    </style>

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <script type="application/javascript">
        var thisWindow       = nvFW.getMyWindow()
        var dif              = Prototype.Browser.isIE ? 5 : 0
        var nro_proceso      = parseInt(<% = nro_proceso %>)
        var def_archivos     = {}
        var archivos_ordenes = []
        var btn_aceptar      = false
        var btn_aceptar_d    = false
        var upload_files     = false
        var ext_permitidas   = ['pdf', 'jpg', 'jpeg', 'bmp', 'png', 'pif', 'html', 'htm', 'txt']
        var win_detener
        var win_control
        var $body
        var nro_com_id_tipo = nvFW.pageContents.nro_com_id_tipo;
        var nro_def_archivo = nvFW.pageContents.nro_def_archivo;
        var id_tipo         = nvFW.pageContents.id_tipo;
        var success         = nvFW.pageContents.success;


        function window_onload()
        {
            // cache
            $body = $$('body')[0]

            if (success == 1) {
                // Establecemos como exitoso el resultado de la subida de archivos.
                win.options.userData.success = true;
                // Quitamos el ultimo elemento de los nombres de archivos
                var arc = archivos.split(',');
                arc.pop();
                win.options.userData.archivos = arc;
                // Quitamos el ultimo elemento de la descripciones
                var descs = descripciones.split(',');
                descs.pop();
                win.options.userData.descripciones = arc;
                // Quitamos el ultimo id porque es vacio.
                var ids_aux = ids.split(',');
                ids_aux.pop();
                win.options.userData.ids = ids_aux;
                nvFW.bloqueo_desactivar(null, 'Ajax_bloqueo')
                win.close();
            }

            cargarDefArchivos()
        }


        function cargarDefArchivos()
        {
            nvFW.bloqueo_activar($body, 'bloq_def', 'Cargando Definición...');

            var tabla_archivos = '<tr class="tbLabel">' +
                                   '<td style="width: 50%; text-align: center;">Descripción</td>' +
                                   '<td style="text-align: center;">-</td>' +
                                 '</tr>';
            
            var rs        = new tRS();
            rs.async      = true

            rs.onComplete = function (result) {
                while (!result.eof()) {
                    var nro_orden           = result.getdata('orden')
                    var archivo_descripcion = result.getdata('archivo_descripcion')
                    
                    archivos_ordenes.push(nro_orden);
                    def_archivos[orden]               = {}
                    def_archivos[orden].orden         = nro_orden
                    def_archivos[orden].input_text_id = "text_" + nro_orden
                    def_archivos[orden].input_file_id = "archivo_" + archivo_descripcion
                    
                    // Creamos el input text para la descripcion del archivo
                    tabla_archivos += '<tr><td><input style="width: 100%;" type="text" id="text_' + nro_orden + '" ondblclick="file_seleccionar(\'' + archivo_descripcion + '\')"';
                    
                    if (result.getdata('readonly') == 'True') {
                        tabla_archivos += " readonly value='" + archivo_descripcion + "'";
                    }
                    else {
                        if (result.getdata('requerido') == 'True') {
                            tabla_archivos += " required ";
                        }
                    }

                    tabla_archivos += " /> ";
                    tabla_archivos += '<input type="hidden" name="nro_def_archivo_' + nro_orden + '" id="nro_def_archivo_' + nro_orden + '" value="' + result.getdata('nro_def_archivo') + '"/>'
                    tabla_archivos += '<input type="hidden" name="nro_def_detalle_' + nro_orden + '" id="nro_def_detalle_' + nro_orden + '" value="' + result.getdata('nro_def_detalle') + '"/>'
                    tabla_archivos += '<input type="hidden" name="orden' + nro_orden + '"            id="orden' + nro_orden + '"            value="' + nro_orden + '"/>'
                    tabla_archivos += '<input type="hidden" name="tipo' + nro_orden + '"             id="tipo' + nro_orden + '"             value="' + result.getdata('nro_archivo_def_tipo') + '"/></td>'
                    tabla_archivos += '<td>'
                    tabla_archivos +=   '<input type="file" name="archivo_' + archivo_descripcion + '" id="archivo_' + archivo_descripcion + '" style="display: none;" onchange="return file_onchange(\'' + archivo_descripcion + '\', ' + nro_orden + ');" ';
                    
                    // En caso de ser obligatorio lo definimos como required
                    if (result.getdata('requerido') == 'True') {
                        tabla_archivos += " required ";
                    }

                    tabla_archivos += ' /><img class="file_upload" id="img_upload_' + archivo_descripcion + '" src="/meridiano/image/icons/upload24.png" alt="Seleccionar archivo" title="Seleccionar archivo" height="20" width="20" border="0" align="absmiddle" hspace="1" onclick="return file_seleccionar(\'' + archivo_descripcion + '\');" />';
                    tabla_archivos += '<span onclick="return file_seleccionar(\'' + archivo_descripcion + '\');" id="img_span_' + archivo_descripcion + '" style="cursor: pointer;">Seleccionar</span></td></tr>'

                    result.movenext()
                }

                $('tbDefArchivos').innerHTML = tabla_archivos;

                for (orden in def_archivos) {
                    nvFW.enableDropFile($(def_archivos[orden].input_text_id), "dropOver ", function (evt) {
                        var orden = Event.element(evt).id.split("_")[1]
                        $(def_archivos[orden].input_file_id).files = evt.dataTransfer.files;
                    })
                }

                nvFW.bloqueo_desactivar(null, 'bloq_def');
            }

            rs.open(nvFW.pageContents["filtro_archivos_def"])
        }


        function file_seleccionar(name)
        {
            if ($('archivo_' + name).value != '') {
                var tamanio  = Math.ceil(document.getElementsByName('archivo_' + name)[0].files[0].size / 1024)
                var filepath = $('archivo_' + name).value
                var filename = filepath.substring(filepath.lastIndexOf('\\') + 1)

                win_control = nvFW.createWindow({
                    title:              '<b>Reemplazar Archivo</b>',
                    parentWidthPercent: 0.8,
                    parentWidthElement: $("formArchivos"),
                    maxWidth:           450,
                    centerHFromElement: $("formArchivos"),
                    minimizable:        false,
                    maximizable:        false,
                    draggable:          false,
                    resizable:          false,
                    closable:           false,
                    recenterAuto:       true,
                    setHeightToContent: true,
                    onClose:            function () {
                        if (btn_aceptar)
                            $('archivo_' + name).click()
                    }
                });

                var html = '<html><head></head><body style="width: 100%; height: 100%; overflow: hidden;">'
                html += '<table class="tb1" style="font-size: 13px;">'
                html += '<tbody><tr><td colspan="2">Ya seleccionó el archivo "<b>' + filename + '</b>" [' + tamanio + ' Kb] para ésta descripción.<br><br>¿Desea reemplazarlo?<br></td></tr>'
                html += '<tr><td style="text-align: center; width: 50%;"><br><input type="button" style="width: 100%; cursor: pointer;" value="Reemplazar" onclick="return win_control_cerrar(true);" /></td><td style="text-align: center; width: 50%;"><br><input type="button" style="width: 100%; cursor: pointer;" value="Cancelar" onclick="return win_control_cerrar(false);" /></td></tr>'
                html += '</tbody></table></body></html>'

                win_control.setHTMLContent(html)
                win_control.showCenter(true)
            }
            else
                $('archivo_' + name).click()
        }


        function win_control_cerrar(aceptar)
        {
            btn_aceptar = aceptar
            win_control.close()
        }


        function file_onchange(name, nro_orden)
        {
            var strError = ''
            var tamanio  = 0
            var nombre   = ''
            var files    = document.getElementsByName('archivo_' + name)[0].files

            if (files.length == 0) {
                // No se selecciono nada desde la pantalla de archivos
                return false;
            }
            else {
                tamanio = Math.ceil(files[0].size / 1024)
                nombre  = files[0].name
            }
            
            var ext = nombre.substring(nombre.indexOf(".") + 1, nombre.length).toLowerCase()

            if (tamanio > 8192)
                strError += 'El tamaño del archivo seleccionado es mayor al permitido (8 Mb).<br>'

            if (ext_permitidas.indexOf(ext) == -1)
                strError += 'Los archivos con la extensión <b>.' + ext + '</b> no se pueden adjuntar.<br>'

            if (strError != '') {
                $('archivo_' + name).value = ''
                nvFW.alert(strError)
                return
            }

            var filepath = $('archivo_' + name).value
            var filename = filepath.substring(filepath.lastIndexOf('\\')+1) + ' [' + tamanio + ' Kb]'
            
            $('img_span_' + name).innerHTML = ''
            $('img_span_' + name).insert({ bottom: filename })
            $('img_span_' + name).setStyle({ color: "blue" })
            $('text_' + nro_orden).setStyle({ color: "blue" })
            $('img_upload_' + name).src = '/meridiano/image/icons/upload24_blue.png'
        }


        function file_cancelar(xhr)
        {
            try {
                xhr.abort()
            }
            catch(e) {}

            $("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "" })
            nvFW.bloqueo_desactivar(null, 'Ajax_bloqueo')

            win_detener = nvFW.createWindow({
                title:              '<b>Detener subida de archivos</b>',
                parentWidthPercent: 0.8,
                parentWidthElement: $("formArchivos"),
                maxWidth:           450,
                centerHFromElement: $("formArchivos"),
                minimizable:        false,
                maximizable:        false,
                draggable:          false,
                resizable:          false,
                closable:           false,
                recenterAuto:       true,
                setHeightToContent: true,
                destroyOnClose:     true,
                onClose:            function() {
                    if (btn_aceptar_d)
                        cargarDefArchivos()
                }
            });

            var html = '<html><head></head><body style="width: 100%; height: 100%; overflow: hidden;">'
            html += '<table class="tb1" style="font-size: 13px;">'
            html += '<tbody><tr><td colspan="2">¿Desea suspender o cancelar la subida de archivos?</td></tr>'
            html += '<tr><td style="text-align: center; width: 50%;"><br><input type="button" style="width: 100%; cursor: pointer;" value="Suspender" onclick="return win_detener_cerrar(false);" /></td><td style="text-align: center; width: 50%;"><br><input type="button" style="width: 100%; cursor: pointer;" value="Cancelar" onclick="return win_detener_cerrar(true);" /></td></tr>'
            html += '</tbody></table></body></html>'

            win_detener.setHTMLContent(html)
            win_detener.showCenter(true) 
        }


        function win_detener_cerrar(limpiar)
        {
            btn_aceptar_d = limpiar
            win_detener.close()
        }


        function file_ok()
        {
            nvFW.bloqueo_desactivar(null, 'Ajax_bloqueo')
            nvFW.alert('Se subieron los archivos seleccionados.')

            $('descripciones').value                   = ''
            $('orden').value                           = ''
            upload_files                               = true
            thisWindow.options.userData.success        = upload_files
            thisWindow.options.userData.recargar_lista = true
            
            cargarDefArchivos()
        }


        function submit_archivos()
        {
            if (!filesToUpload()) {
                alert("Actualmente no existen archivos a subir.<br/>Por favor seleccione un archivo e inténtelo nuevamente.")
                return false;
            }

            nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo', 'Subiendo archivos...')

            var $descripciones = $('descripciones')
            var $orden         = $('orden')
            var orden

            for (var i = 0, n = archivos_ordenes.length; i < n; i++) {
                orden = archivos_ordenes[i];
                $descripciones.value += ($('text_' + orden).value).replace(',', '') + ',';
                $orden.value         += orden + ',';
            }      

            var tamanio = 0

            $$("input[type=file]").each(function(file) {
                if (file.files.length > 0)
                    tamanio += Math.ceil(file.files[0].size / 1024)
            })

            var percent      = 0
            var HTML_bloqueo = "<span id='Msg_bloqueo'>Subiendo archivos [" + tamanio + " Kb]... " + percent.toFixed(0) + "%</span><input type='button' id='btn_cancelar' style='width: 100%; cursor: pointer;' value='Detener' />"

            nvFW.bloqueo_msg('Ajax_bloqueo', HTML_bloqueo)

            var oXML              = new tXML()
            oXML.async            = true
            oXML.onFailure        = function() { file_cancelar(oXML, false) }
            oXML.onComplete       = function() { file_ok() }
            oXML.onUploadProgress = function(e) {
                if (e.lengthComputable) {
                    percent = (e.loaded * 100) / e.total
                    //$('Msg_bloqueo').innerHTML = ''
                    $('Msg_bloqueo').innerHTML = "Subiendo archivos [" + tamanio + " Kb]... " + percent.toFixed(0) + "%"
                    //$('Msg_bloqueo').insert({ bottom: "Subiendo archivos [" + tamanio + " Kb]... " + percent.toFixed(0) + "%" })
                    $("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "linear-gradient(to right, rgba(0, 255, 0, 0.4) 0%, rgba(0, 255, 0, 0.4) " + percent + "%, transparent " + percent + "%), white" })
                }
            }

            $("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "linear-gradient(to right, rgba(0, 255, 0, 0.4) 0%, rgba(0, 255, 0, 0.4) " + percent + "%, transparent " + percent + "%), white" })
            $('btn_cancelar').observe("click", function() { file_cancelar(oXML) })

            var frm  = document.forms.namedItem("formArchivos")
            var data = new FormData(frm)

            data.append("modo",            "http_post")
            data.append("accion",          "ABM")
            data.append("nro_def_archivo", nro_def_archivo)
            data.append("id_tipo",         id_tipo)
            data.append("nro_com_id_tipo", nro_com_id_tipo)

            oXML.load("", data, null)
        }


        function filesToUpload()
        {
            var has_any_file_to_upload = false

            $$("input[type=file]").each(function(file) {
                if (file.files.length > 0)
                    has_any_file_to_upload = true
            })

            return has_any_file_to_upload
        }
    </script>
</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <form name="formArchivos" id="formArchivos" method="post" enctype="multipart/form-data" style="width: 100%; height: 100%; margin: 0;">
        <input type="hidden" id="descripciones"   name="descripciones"   value="" />
        <input type="hidden" id="orden"           name="orden"           value="" />

        <div id="tabla_archivos" style="background-color: white; overflow: hidden;">
            <table class="tb1 scroll" id="tbDefArchivos"></table>
        </div>

        <div id="divSubir"></div>
        <script type="text/javascript">
            var vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"]   = "Subir";
            vButtonItems[0]["etiqueta"] = "Subir";
            vButtonItems[0]["imagen"]   = "guardar";
            vButtonItems[0]["onclick"]  = "return submit_archivos()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('guardar', '/FW/image/icons/guardar.png')

            vListButton.MostrarListButton();
        </script>
    </form>
</body>
</html>
