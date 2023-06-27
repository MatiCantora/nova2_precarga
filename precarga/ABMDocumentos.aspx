<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim nro_def_archivo As String = nvFW.nvUtiles.obtenerValor("nro_def_archivo", "")

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim folder As String = Server.MapPath("~/Uploads")
    Dim ordenes As String = nvFW.nvUtiles.obtenerValor("orden", "")
    Dim id_tipo As String = nvFW.nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_com_id_tipo As String = nvFW.nvUtiles.obtenerValor("nro_com_id_tipo", "")
    Dim descripciones As String = nvFW.nvUtiles.obtenerValor("descripciones", "")
    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")
    Dim server_name As String = nvApp.cod_servidor
    Dim ids As String = ""
    Dim err As New nvFW.tError()
    Dim operador As Object = nvFW.nvApp.getInstance().operador

    Try
        If (modo = "http_post") Then
            Dim contador As Integer = 0
            If (accion = "ABM") Then
                Stop
                err.salida_tipo = "estado"
                Dim pathtemp As String = "\\" & server_name & "\d$\MeridianoWeb\Meridiano\archivos\"  ' cargar un parametro

                Dim path_rova As String = ""
                Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = 'nv_mutual' and cod_servidor = '" & server_name & "' and cod_ss_dir = 'nvArchivosDefault'")
                path_rova = rsRova.Fields("path").Value.Replace("\", "\\")

                Dim archivo As Dictionary(Of String, Object)
                Dim archivos As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
                Dim Files As HttpFileCollection
                Dim archivos_string As String = ""
                Files = Request.Files ' Load File collection into HttpFileCollection variable.                
                For Each campo In Request.Files.AllKeys
                    Dim descripcion = descripciones.ToString().Split(",")(contador)
                    Dim orden = ordenes.ToString().Split(",")(contador)
                    contador = contador + 1
                    archivo = New Dictionary(Of String, Object)


                    If Request.Files(campo).FileName <> "" Then
                        ' //Guarda los archivos en el directorio_archivos
                        archivo.Add("existe", True)
                        archivo.Add("filename", System.IO.Path.GetFileName(Request.Files(campo).FileName))
                        Dim ext As String = System.IO.Path.GetExtension(archivo("filename")).ToLower
                        If ((ext = ".pdf") Or (ext = ".jpg") Or (ext = ".jpeg") Or (ext = ".bmp") Or (ext = ".png") Or (ext = ".pif") Or (ext = ".html") Or (ext = ".htm") Or (ext = ".txt")) Then   'OJO pendiente de modificar
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

                                Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset("Select isnull(max(nro_archivo), 0) + 1 As maxArchivo from archivos")
                                Dim nro_archivo As Integer = rsA.Fields("maxArchivo").Value
                                nvFW.nvDBUtiles.DBCloseRecordset(rsA)

                                Dim strSQL As String = "Insert Into archivos (nro_archivo,Descripcion,nro_credito,momento,nro_def_detalle,operador,nro_archivo_estado,nro_img_origen) values('" & nro_archivo & "','" & descripcion & "','" & nro_credito & "',getdate(),'" & nro_def_detalle & "','" & nvApp.operador.operador & "',1,1)"
                                nvFW.nvDBUtiles.DBExecute(strSQL)
                                Dim carpeta As String = DateTime.Now.ToString("yyyyMM")

                                archivo.Add("id", nro_archivo)
                                ids = ids & nro_archivo & ","
                                archivo.Add("nro_def_archivo", nvFW.nvUtiles.obtenerValor("nro_def_archivo_" + orden, ""))

                                'archivo.Add("path", pathtemp & carpeta & "\\" & nro_archivo & archivo("extencion"))
                                'nvFW.nvReportUtiles.create_folder(archivo("path"))
                                'Request.Files(campo).SaveAs(archivo("path"))

                                'If (path_rova <> "") Then
                                archivo.Add("path_rova", path_rova & carpeta & "\\" & nro_archivo & archivo("extencion"))
                                nvFW.nvReportUtiles.create_folder(archivo("path_rova"))
                                Request.Files(campo).SaveAs(archivo("path_rova"))
                                'End If

                                strSQL = "update archivos set path = '" & carpeta & "\" & nro_archivo & archivo("extencion") & "' where nro_archivo = " & nro_archivo

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
                        archivos_string += ","
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

    Me.contents("nro_com_id_tipo") = nro_com_id_tipo
    Me.contents("id_tipo") = id_tipo
    Me.contents.Add("archivos_def", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_detalle'><campos>*</campos><orden>orden</orden><filtro><nro_def_archivo type='igual'>%nro_def_archivo%</nro_def_archivo><nro_def_detalle type='distinto'>2677</nro_def_detalle></filtro></select></criterio>"))
    Me.contents("nro_def_archivo") = nro_def_archivo
    Me.contents("orden") = ordenes

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>ABM Documentos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="script/precarga.js"></script>
    <% = Me.getHeadInit()%>


    <style type="text/css">
        .dropOver
        {
            border: 1px dashed green !important;
        }
    </style>
    <script type="text/javascript" language="javascript">
        //var alert = function (msg) { window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); };

        var nro_credito = 0
        var ismobile = false
        var win = nvFW.getMyWindow();
        var id_tipo = nvFW.pageContents.id_tipo;
        var nro_com_id_tipo = nvFW.pageContents.nro_com_id_tipo;

        var nro_def_archivo = nvFW.pageContents.nro_def_archivo;
        var success = nvFW.pageContents.success;
        var archivos = nvFW.pageContents.archivos;
        var descripciones = nvFW.pageContents.descripciones;
        var ids = nvFW.pageContents.ids;

        var orden = nvFW.pageContents.orden;

        var archivos_ordenes = [];

        function tryGetValue(nombre, rs) {
            var valor = rs.getdata(nombre);
            return (valor ? valor : '');
        }

        function window_onload() {
            if (success == 1) {
                //Establecemos como exitoso el resultado de la subida de archivos.
                win.options.userData.success = true;
                //Quitamos el ultimo elemento de los nombres de archivos
                var arc = archivos.split(',');
                arc.pop();
                win.options.userData.archivos = arc;
                //Quitamos el ultimo elemento de la descripciones
                var descs = descripciones.split(',');
                descs.pop();
                win.options.userData.descripciones = arc;
                //Quitamos el ultimo id por que es vacio.
                var ids_aux = ids.split(',');
                ids_aux.pop();
                win.options.userData.ids = ids_aux;
                nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                win.close();
            }
            nro_credito = win.options.userData.param['nro_credito']
            ismobile = (isMobile()) ? true : false
            cargarDefArchivos();

             //??
             // Limpiar cache de archivos del escaner de cámara si
             // se inicio el formulario abmDocumentos en la webapp
             if (nvFW.nvInterOP) {
                nvFW.nvInterOP.clearScannedDocumentsCache()
            }
            //alert("25/04/2019 - ABMDocumentos.aspx modificado para la nueva version de la webapp con nvmobilescan 1.0.9")
        }

        var def_archivos = {}

        function cargarDefArchivos() {
            nvFW.bloqueo_activar($(document.body), 'Cargando Definición');
            var style_width = 'width:60%'
            if (ismobile)
                style_width = 'width:85%'

            var tabla_archivos = '<tr class="tbLabel">' +
                                       '<td style=' + style_width + ' >Descripcion</td>' +
                                       '<td>-</td>' +
                                    '</tr>'
            var rs = new tRS();
            rs.async = true
            rs.onComplete = function (rs) {
                while (!rs.eof()) {
                    var orden = rs.getdata('orden')
                    archivos_ordenes.push(orden);
                    def_archivos[orden] = {}
                    def_archivos[orden].orden = orden
                    def_archivos[orden].input_text_id = "text_" + rs.getdata('orden')
                    def_archivos[orden].input_file_id = "archivo_" + rs.getdata('archivo_descripcion')
                    var nro_orden = rs.getdata('orden');
                    //Creamos el input text para la descripcion del archivo
                    tabla_archivos += '<tr><td> <input  style="width:99%" type="text"  id="text_' + rs.getdata("orden") + '" ondblclick="file_seleccionar(\'' + rs.getdata('archivo_descripcion') + '\')"';
                    if (rs.getdata('readonly') == 'True') {
                        tabla_archivos += " readonly value='" + rs.getdata('archivo_descripcion') + "'";
                    } else {
                        if (rs.getdata('requerido') == 'True') {
                            tabla_archivos += " required ";
                        }
                    }
                    tabla_archivos += " /> ";
                    tabla_archivos += '<input type="hidden" id="nro_def_archivo_' + nro_orden + '" name="nro_def_archivo_' + nro_orden + '" value="' + rs.getdata('nro_def_archivo') + '"/>'
                    tabla_archivos += '<input type="hidden" id="nro_def_detalle_' + nro_orden + '" name="nro_def_detalle_' + nro_orden + '" value="' + rs.getdata('nro_def_detalle') + '"/>'
                    tabla_archivos += '<input type="hidden" name="orden' + nro_orden + '" id="orden' + nro_orden + '" value="' + nro_orden + '"/>'
                    tabla_archivos += '<input type="hidden" name="tipo' + nro_orden + '" id="tipo' + nro_orden + '" value="' + rs.getdata('nro_archivo_def_tipo') + '"/> </td> '

                    tabla_archivos += '<td><input type="file" orden="' + rs.getdata("orden") + '" archivo_descripcion="' + rs.getdata("archivo_descripcion") + '" style="width:99%;display:none" id="archivo_' + rs.getdata("archivo_descripcion") + '" name="archivo_' + rs.getdata("archivo_descripcion") + '" onchange="file_onchange(\'' + rs.getdata('archivo_descripcion') + '\',' + nro_orden + ')" ';
                    //En caso de ser obligatorio lo definimos como required
                    if (rs.getdata('requerido') == 'True') {
                        tabla_archivos += " required ";
                    }
                    tabla_archivos += ' /><img class="file_upload" id="img_upload_' + rs.getdata("archivo_descripcion") + '"  src="/fw/image/icons/upload24.png" alt="Seleccionar archivo" title="Seleccionar archivo" height="24" width="24" border="0" align="absmiddle" hspace="1" onclick="file_seleccionar(\'' + rs.getdata('archivo_descripcion') + '\')" style="margin-left: 5px" /> ';
                    if (!ismobile) {
                        tabla_archivos += '<span onclick="file_seleccionar(\'' + rs.getdata('archivo_descripcion') + '\')" id="img_span_' + rs.getdata("archivo_descripcion") + '">Seleccionar</span></td>'
                    }
                    else {
                        tabla_archivos += '</td>'
                    }

                    rs.movenext()
                }
                $('tbdefArchivos').innerHTML = tabla_archivos;
                for (orden in def_archivos) {
                    nvFW.enableDropFile($(def_archivos[orden].input_text_id), "dropOver ", function (evt) {
                        var orden = Event.element(evt).id.split("_")[1]
                        $(def_archivos[orden].input_file_id).files = evt.dataTransfer.files;
                    })
                }
                nvFW.bloqueo_desactivar($(document.body), 'Cargando Definición');


                // ?? - cambiar el chooser nativo de los input file por el chooser del esqueleto
                if (nvFW.nvInterOP) {
                    var input_files = document.querySelectorAll("input[type=file]");
                    for (var i = 0; i < input_files.length; i++) {
                        var input_file = input_files[i]
                        nvFW.nvInterOP.file_changeChooser(input_file)
                    }
                }


            }
            rs.open({ filtroXML: nvFW.pageContents["archivos_def"], params: "<criterio><params nro_def_archivo='89'/></criterio>" })


        }

        var win_control
        var btn_aceptar = false


        function file_seleccionar(name) {
            if ($('archivo_' + name).value != '') {
                var tamanio = Math.ceil(document.getElementsByName('archivo_' + name)[0].files[0].size / 1024)
                var filepath = $('archivo_' + name).value
                var filename = filepath.substring(filepath.lastIndexOf('\\') + 1)
                win_control = createWindow2({
                    title: '<b>Adjuntar Archivo</b>',
                    parentWidthPercent: 0.8,
                    parentWidthElement: $("formArchivos"),
                    maxWidth: 450,
                    maxHeight: 430,
                    centerHFromElement: $("formArchivos"),
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: true,
                    closable: false,
                    recenterAuto: true,
                    setHeightToContent: true,
                    onClose: function () {
                        if (btn_aceptar)
                            $('archivo_' + name).click()
                    }
                });
                var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
                html += '<table class="tb1">'
                html += '<tbody><tr><td colspan="2">Ya seleccionó el archivo "' + filename + '" (' + tamanio + ' kb) para esta descripción.<br><br>Desea reemplazarlo?<br></td></tr>'
                html += '<tr><td style="text-align:center;width:50%"><br><input type="button" style="width:99%" value="Reemplazar" onclick="win_control_cerrar(true)" style="cursor: pointer !important" /></td><td style="text-align:center;width:60%"><br><input type="button" style="width:99%" value="Cancelar" onclick="win_control_cerrar(false)" style="cursor: pointer !important" /></td></tr>'
                html += '</tbody></table></body></html>'

                win_control.setHTMLContent(html)
                win_control.showCenter(true)
            }
            else
                $('archivo_' + name).click()
        }





        //??
        // Esto debe ir en el framework
        if (nvFW.nvInterOP) {


            var base64toBlob = function (base64Data, contentType) {
                contentType = contentType || '';
                var sliceSize = 1024;
                var byteCharacters = atob(base64Data);
                var bytesLength = byteCharacters.length;
                var slicesCount = Math.ceil(bytesLength / sliceSize);
                var byteArrays = new Array(slicesCount);

                for (var sliceIndex = 0; sliceIndex < slicesCount; ++sliceIndex) {
                    var begin = sliceIndex * sliceSize;
                    var end = Math.min(begin + sliceSize, bytesLength);

                    var bytes = new Array(end - begin);
                    for (var offset = begin, i = 0; offset < end; ++i, ++offset) {
                        bytes[i] = byteCharacters[offset].charCodeAt(0);
                    }
                    byteArrays[sliceIndex] = new Uint8Array(bytes);
                }
                return new Blob(byteArrays, { type: contentType });
            }

            // diccionario para mantener los id de documentos
            // que pueden ser editables por el escnaer de cámara
            var dictDocsEditar = {};

            nvFW.nvInterOP.file_changeChooser = function (element) {
                element = $(element)


                if (nvFW.nvInterOP) {
                    var onclick1 = function (evt) {
                        evt.preventDefault()

                        var docId = evt.target.id
                        var archivo_descripcion = evt.target.attributes.archivo_descripcion.value
                        var orden = evt.target.attributes.orden.value

                        if (!dictDocsEditar[docId] || dictDocsEditar[docId] == null) {

                            var jsonres = nvFW.nvInterOP.getDocumentFromChooser(archivo_descripcion)

                            //var b64str = jsonres
                            //var name = "foo.pdf"
                            //var filename = "foo.pdf"

                            // jsonres es undfined cuando el chooser no devuelve resultado (cuando se sale del chooser mediante tecla back)
                            if (jsonres != undefined) {

                                var res = JSON.parse(jsonres)
                                var b64str = res.b64str
                                var name = res.filename
                                var filename = res.filename


                                // obtener el id de edicion del documento, 
                                // en caso de que sea un archivo tomado desde
                                // el escáner de cámara
                                var docEditId = res.docEditId
                                if (docEditId && docEditId != "null") {   //docEditId es null cuando se retorna un archivo desde la galeria o file explorer; docEdit es -1 cuando en el escaner se guarda un documento vacio 

                                    if (docEditId != -1) {
                                        dictDocsEditar[docId] = docEditId
                                    } else {
                                        return // si generó un pdf vacio, no hay que subir nada
                                    }

                                } else {
                                    dictDocsEditar[docId] = null
                                }


                                if (b64str) { // si no es documento vacio
                                    var f1 = {}
                                    f1.value = base64toBlob(b64str)
                                    f1.name = name
                                    f1.filename = filename
                                    f1.size = f1.value.size
                                    this._file = f1
                                    if (this.onchange != null) {
                                        this.onchange()
                                    }
                                }

                            }

                        } else {

                            var docEditId = dictDocsEditar[docId]
                            if (docEditId) { // la subida es editable cuando se subio archivo desde el scanner

                                var jsonres = nvFW.nvInterOP.editScannedDocument(docEditId)
                                if (jsonres != undefined) {
                                    var res = JSON.parse(jsonres)
                                    var b64str = res.b64str
                                    var name = res.filename
                                    var filename = res.filename


                                    var docEditId = res.docEditId
                                    if (docEditId && docEditId != "null") { //siempre deberia devolver docEditId

                                        if (docEditId != -1) {
                                            dictDocsEditar[docId] = docEditId
                                        } else {

                                            // se ha guardado documento vacio, hay que hacer clear al input file
                                            dictDocsEditar[docId] = null

                                            // limpiar input file
                                            this._file = undefined
                                            $('text_' + orden).setStyle({ color: "" })
                                            $('img_upload_' + archivo_descripcion).src = './image/cloud.svg'

                                            // salir
                                            return
                                        }

                                    } else {
                                        alert("No deberia salir por acá")
                                    }


                                    if (b64str) { // si no es documento vacio
                                        var f1 = {}
                                        f1.value = base64toBlob(b64str)
                                        f1.name = name
                                        f1.filename = filename
                                        f1.size = f1.value.size
                                        this._file = f1
                                        if (this.onchange != null) {
                                            this.onchange()
                                        }
                                    }



                                }
                            }

                        }

                    }
                    element.addEventListener("click", onclick1);
                }
            }



            nvFW.nvInterOP.file_addFormdata = function (formData, input_file) {
                input_file = $(input_file)

                if (input_file._file) {
                    formData.set(input_file.name, input_file._file.value, input_file._file.filename);
                }
            }

            nvFW.nvInterOP.file_getFile = function (input_file) {
                input_file = $(input_file)
                if (input_file._file != undefined) return input_file._file
                else return input_file.files[0]
            }

        }

        function win_control_cerrar(aceptar) {
            btn_aceptar = aceptar
            win_control.close()
        }

        function file_onchange(name, nro_orden) {
            var strError = ''

            if (nvFW.nvInterOP) {
                var file = nvFW.nvInterOP.file_getFile(document.getElementsByName('archivo_' + name)[0])
            } else {
                var file = document.getElementsByName('archivo_' + name)[0].files[0]
            }

            var tamanio = 0
            if (file.size != 0) tamanio = Math.ceil(file.size / 1024)
            var nombre = file.name


            //var ext = nombre.substring(nombre.indexOf(".") + 1, nombre.length)
            var ext = nombre.split(".")[nombre.split(".").length - 1]

            if (tamanio > 8192)
                strError += 'El tamaño del archivo seleccionado es mayor al permitido (8 MB).<br>'
            if (!((ext == 'pdf') || (ext == 'jpg') || (ext == 'jpeg') || (ext == 'bmp') || (ext == 'png') || (ext == 'pif') || (ext == 'html') || (ext == 'htm') || (ext == 'txt')))
                strError += 'Los archivos con la extensión <b>.' + ext + '</b> no se pueden adjuntar.<br>'

            if (strError != '') {
                $('archivo_' + name).value = ''
                nvFW.alert(strError)
                return
            }

            if (!ismobile) {
                var filepath = $('archivo_' + name).value
                var filename = filepath.substring(filepath.lastIndexOf('\\') + 1) + ' ' + tamanio + ' kb'
                $('img_span_' + name).innerHTML = ''
                $('img_span_' + name).insert({ bottom: filename })
                $('img_span_' + name).setStyle({ color: "blue" })
            }
            //'text_" + rs.getdata('orden') + "'
            $('text_' + nro_orden).setStyle({ color: "blue" })
            $('img_upload_' + name).src = '/fw/image/icons/upload24_blue.png'
        }

        function key_Enter() {
            if (window.event.keyCode == 13)
                submit_archivos();
        }

        function window_onresize() {
            //var body_h = $(document.body).clientHeight;
            //var divGuardar_h = $('divGuardar').getHeight();

            //var tamanio = body_h - divGuardar_h//de titulos 
            //$('tabla_archivos').style.height = tamanio * 1 + "px"
        }

        var win_detener
        var btn_aceptar_d = false

        function file_cancelar(xhr) {
            try { xhr.abort() }
            catch (e) { }
            $("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "" })
            nvFW.bloqueo_desactivar(null, 'Ajax_bloqueo')

            win_detener = createWindow2({
                title: '<b>Detener subida de archivos</b>',
                parentWidthPercent: 0.8,
                parentWidthElement: $("formArchivos"),
                maxWidth: 450,
                centerHFromElement: $("formArchivos"),
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: true,
                closable: false,
                recenterAuto: true,
                setHeightToContent: true,
                onClose: function () {
                    if (btn_aceptar_d)
                        cargarDefArchivos()
                }
            });
            var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
            html += '<table class="tb1">'
            html += '<tbody><tr><td colspan="2">¿Desea suspender o cancelar la subida de archivos?</td></tr>'
            html += '<tr><td style="text-align:center;width:50%"><br><input type="button" style="width:99%" value="Suspender" onclick="win_detener_cerrar(false)" style="cursor: pointer !important" /></td><td style="text-align:center;width:60%"><br><input type="button" style="width:99%" value="Cancelar" onclick="win_detener_cerrar(true)" style="cursor: pointer !important" /></td></tr>'
            html += '</tbody></table></body></html>'

            win_detener.setHTMLContent(html)
            win_detener.showCenter(true)

            //nvFW.alert('Se canceló la subida de los archivos.')
        }

        function win_detener_cerrar(limpiar) {
            btn_aceptar_d = limpiar
            win_detener.close()
        }

        var upload_files = false

        function file_ok() {
            nvFW.bloqueo_desactivar(null, 'Ajax_bloqueo')
            nvFW.alert('Se subieron los archivos seleccionados.')
            $('descripciones').value = ''
            $('orden').value = ''
            upload_files = true
            win.options.userData.success = upload_files
            cargarDefArchivos()
            
            // limpiar el diccionario de documentos editables del scanner
            if (nvFW.nvInterOP) {nvFW.nvInterOP.dictDocsEditar = {} }
			nvFW.getMyWindow().close()
        }

        function submit_archivos() {
            var time_ini = new Date()
            nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
            //formArchivos.action = "ABMDocumentos.aspx?modo=http_post&accion=ABM&nro_def_archivo=" + nro_def_archivo + "&id_tipo=" + id_tipo + "&nro_com_id_tipo=" + nro_com_id_tipo + "&orden=" + orden + "&nro_credito=" + nro_credito;

            for (var index = 0; index < archivos_ordenes.length; index++) {
                var orden = archivos_ordenes[index];
                $('descripciones').value += ($('text_' + orden).value).replace(',', '') + ',';
                $('orden').value += orden + ',';
            }

            var file_name = ''
            var tamanio = 0

            for (var x in def_archivos) {
                file_name = def_archivos[x].input_file_id

                if (nvFW.nvInterOP) {
                    var file = nvFW.nvInterOP.file_getFile(document.getElementsByName(file_name)[0])
                } else {
                    var file = document.getElementsByName(file_name)[0].files[0]
                }

                if (file) {
                    tamanio = tamanio + Math.ceil(file.size / 1024)
                }
            }

            //??
            var frm = document.forms.namedItem("formArchivos")
            var data = new FormData(frm)
            // si esta el esqueleto, hay que agregar a mano los binarios cargados en los input files
            if (nvFW.nvInterOP) {
                var input_files = document.querySelectorAll("input[type=file]");
                for (var i = 0; i < input_files.length; i++) {
                    var input_file = input_files[i]
                    nvFW.nvInterOP.file_addFormdata(data, input_file)
                }
            }


            data.append("modo", "http_post")
            data.append("accion", "ABM")
            data.append("nro_def_archivo", nro_def_archivo)
            data.append("id_tipo", id_tipo)
            data.append("nro_com_id_tipo", nro_com_id_tipo)
            data.append("nro_credito", nro_credito)

            var percent = 0
            var HTML_bloqueo = "<span id='Msg_bloqueo'>Subiendo archivos (" + tamanio + " kb)... " + percent.toFixed(0) + "%</span><input type='button' id='btn_cancelar' style='width:99%' value='Detener' style='cursor: pointer !important' />"
            nvFW.bloqueo_msg('Ajax_bloqueo', HTML_bloqueo)

            nvFW.error_ajax_request("", {
                parameters: data,
                bloq_contenedor_on : false,
                onSuccess: function () { file_ok() },
                onFailure: function () { nvFW.bloqueo_desactivar(null, 'Ajax_bloqueo') },
                onUploadProgress: function (e) {
                    if (e.lengthComputable) {
                        percent = (e.loaded * 100) / e.total
                        $('Msg_bloqueo').innerHTML = ''
                        $('Msg_bloqueo').insert({ bottom: "Subiendo archivos (" + tamanio + " kb) ... " + percent.toFixed(0) + "%" })
                        $("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "linear-gradient(to right, rgba(0, 255, 0, 0.4) 0%, rgba(0, 255, 0, 0.4) " + percent + "%, transparent " + percent + "%), white" })
                    }
                }
})


            //var oXML = new tXML()
            //oXML.async = true
            //oXML.onFailure = function () {
            //    debugger;
            //    file_cancelar(oXML, false)
            //}
            //oXML.onComplete = function () {
            //    debugger
            //    file_ok()
            //}
            //oXML.onUploadProgress = function (e) {
            //    if (e.lengthComputable) {
            //        percent = (e.loaded * 100) / e.total
            //        $('Msg_bloqueo').innerHTML = ''
            //        $('Msg_bloqueo').insert({ bottom: "Subiendo archivos (" + tamanio + " kb) ... " + percent.toFixed(0) + "%" })
            //        $("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "linear-gradient(to right, rgba(0, 255, 0, 0.4) 0%, rgba(0, 255, 0, 0.4) " + percent + "%, transparent " + percent + "%), white" })
            //    }
            //}
            //$("divBloq_" + 'Ajax_bloqueo')._DivMsg.setStyle({ background: "linear-gradient(to right, rgba(0, 255, 0, 0.4) 0%, rgba(0, 255, 0, 0.4) " + percent + "%, transparent " + percent + "%), white" })
            //$('btn_cancelar').observe("click", function () { file_cancelar(oXML) })
            //oXML.load("", data, null)

            var time_fin = new Date()
            var diff = (time_fin - time_ini) / 100
            try {
                mixpanel.track("UPLOAD_FILE", { "TIME": diff });
            }
            catch (e) {  }

            //formArchivos.submit();
        }
    </script>
</head>
<body onload='return window_onload()' onkeypress='return key_Enter()' onresize="return window_onresize()" style='overflow: hidden'>
    <form name="formArchivos" id="formArchivos" method="post" enctype="multipart/form-data">
        <input type="hidden" id="descripciones" name="descripciones" />
        <input type="hidden" id="orden" name="orden" />
        <div id="tabla_archivos" style="width: 99.9%; background-color: white; overflow: hidden">
            <table class="tb1 scroll" id="tbdefArchivos">
            </table>
        </div>
        <div id="divGuardar" style="display: flex; justify-content: center; align-items: center;width: 80px; margin-inline: auto; margin-top:10px"></div>
        <script type="text/javascript">

            var vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Guardar";
            vButtonItems[0]["etiqueta"] = "Subir";
            vButtonItems[0]["imagen"] = "cloud";
            vButtonItems[0]["estilo"] = "M";
            vButtonItems[0]["onclick"] = "return submit_archivos()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('cloud', './image/cloud.svg')

            vListButton.MostrarListButton();

        </script>
    </form>
</body>
</html>
