<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    
   
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    Me.contents("modo") = modo
    Me.contents("accion") = accion
    
 

    If modo = "config_firma_esquema" Then
        Dim nombre_doc As String = nvUtiles.obtenerValor("nombre_doc", "")
        Dim extension As String = nvUtiles.obtenerValor("extension", "")
        Dim doc_adjuntable As String = nvUtiles.obtenerValor("doc_adjuntable", "")
        Me.contents("doc_adjuntable") = doc_adjuntable
    End If


    
    ' Cuando selecciona visualizar pagina con la flecha
    If accion = "ver_pagina" Then

        
        Dim fileBytes As Byte() = Nothing
        Dim pageCount As String
        
        
        ' Obtener el binario  de la tabla documentos_firma
        Dim tmp_file_path As String = nvUtiles.obtenerValor("tmp_file_path", "")
        If tmp_file_path <> "" Then
            fileBytes = System.IO.File.ReadAllBytes(tmp_file_path)
        End If
            
        
        ' Obtener el binario de la tabla ref_file_bin de la wiki
        Dim f_id As String = nvUtiles.obtenerValor("f_id", "")
        If f_id <> "" Then
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT f_path, f_nro_ubi, BinaryData FROM verRef_files WHERE f_id=" + f_id + "")
            If Not rs.EOF Then
                If rs.Fields("f_nro_ubi").Value = 1 Then
                    fileBytes = System.IO.File.ReadAllBytes(rs.Fields("f_path").Value)
                Else
                    fileBytes = rs.Fields("BinaryData").Value
                End If
            End If
            nvDBUtiles.DBCloseRecordset(rs)
            
        End If
        
        
        ' Obtener el binario  de la tabla documentos_firma
        Dim id_documento_firma As String = nvUtiles.obtenerValor("id_documento_firma", "")
        If id_documento_firma <> "" Then
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT doc_binary FROM documentos_firma WHERE id_documento_firma=" + id_documento_firma + "")
            If Not rs.EOF Then
                fileBytes = rs.Fields("doc_binary").Value
            End If
            nvDBUtiles.DBCloseRecordset(rs)
        End If
        
        
        
        

        Dim err = New tError()
        Dim page = nvUtiles.obtenerValor("page", "")
        
        Dim reader As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(fileBytes)
        Dim pdfHeight As Integer = reader.GetPageSize(page).Top
        Dim pdfWidth As Integer = reader.GetPageSize(page).Width

        reader.Close()
        reader.Dispose()
        
        
        Dim img As System.Drawing.Image
        Dim version As New Ghostscript.NET.GhostscriptVersionInfo(New System.Version("9.20"), Server.MapPath("~") & "Bin\gs\gsdll32.dll", "", Ghostscript.NET.GhostscriptLicense.GPL)
        Using Rasterizer = New Ghostscript.NET.Rasterizer.GhostscriptRasterizer()
            Rasterizer.Open(New IO.MemoryStream(fileBytes), version, False)
            img = Rasterizer.GetPage(150, 150, page)
            pageCount = Rasterizer.PageCount.ToString
            Rasterizer.Close()
        End Using
        


        Try

            Dim im As System.Drawing.Bitmap = New System.Drawing.Bitmap(img)
            
            Dim bytes As Byte()
            Using stream As New IO.MemoryStream()
                img.Save(stream, System.Drawing.Imaging.ImageFormat.Png)
                bytes = stream.ToArray()
            End Using
            im.Dispose()
            im = Nothing

            err.params("img") = Convert.ToBase64String(bytes)
            err.params("pdf_height") = pdfHeight.ToString
            err.params("pdf_width") = pdfWidth.ToString
            err.params("page_count") = pageCount

  
        Catch e As Exception
            err.parse_error_script(e)
        End Try

        err.response()
    End If
    
    
    If accion = "check_signature_finalized" Then
        
        Dim requestPendingId As String = nvUtiles.obtenerValor("requestPendingId", "")
        Dim err As New tError
        err.params("signatureFinalized") = "false"
        If nvFW.nvResponsePending.get(requestPendingId).element.ContainsKey("sign_pending") Then
            If nvFW.nvResponsePending.get(requestPendingId).state = nvResponsePending.enumPendingSatate.terminado Then
                err.params("signatureFinalized") = "true"
            End If
        Else
            err.numError = -1
            err.mensaje = "Error: el proceso de firma con el id especificado no existe"
        End If
        err.response()
    End If
    
    


    
 
    
    If modo = "sign_file" Then
        
        Dim f_id As String = nvUtiles.obtenerValor("f_id", "")
        
        Dim nro_entidad As String = ""
        Dim operador As String = nvApp.operador.operador
        
 
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM verOperadores_mobile_devices WHERE operador=" & nvApp.operador.operador)
        Dim hasDevices As Boolean = False
        If Not rs.EOF Then
            hasDevices = True
        End If
        nvDBUtiles.DBCloseRecordset(rs)
        If Not hasDevices Then
            Response.Redirect("qr_binding_scan.aspx?f_id=" + f_id)
        End If
        
        
        Dim nombre_doc As String = ""
        Dim extension As String = ""
        Dim f_depende_de As String = ""
        nro_entidad = nvApp.operador.nro_entidad

        rs = nvDBUtiles.DBOpenRecordset("SELECT f_nombre, f_ext, f_depende_de FROM verRef_files WHERE f_id=" + f_id + "")
        If Not rs.EOF Then
            nombre_doc = rs.Fields("f_nombre").Value
            extension = rs.Fields("f_ext").Value
            f_depende_de = rs.Fields("f_depende_de").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)

        Me.contents("nombre_doc") = nombre_doc
        Me.contents("extension") = extension
        Me.contents("f_id") = f_id
        Me.contents("f_depende_de") = f_depende_de
        Me.contents("nro_entidad") = nro_entidad

        Me.contents("filtroMobileDevices") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_mobile_devices'><campos>cod_binding  as id, device_name + ' (' + app_name + ')' as [campo]</campos><filtro><operador type='igual'>" & operador & "</operador></filtro><orden>[cod_binding]</orden></select></criterio>")
        Me.contents("filtroCertificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vernotification_bindings_signing_certificates'><campos>IDCert  as [id], cert_name as  [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
        Me.contents("filtroConfigDefault") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vernotification_bindings_signing_certificates'><campos>top 1 cod_binding, idcert</campos><filtro><default_config type='igual'>1</default_config><operador type='igual'>" & operador & "</operador></filtro><orden>idcert desc</orden></select></criterio>")
        
        
        ' Binding + certificado por defecto 
        Dim default_idcert As String = ""
        Dim default_cod_binding As String = ""
        rs = nvDBUtiles.DBOpenRecordset("SELECT top 1 cod_binding, idcert FROM [vernotification_bindings_signing_certificates] WHERE default_config=1 and operador=" & operador & " order by idcert desc ")
        If Not rs.EOF Then
            default_idcert = rs.Fields("idcert").Value
            default_cod_binding = rs.Fields("cod_binding").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)
        Me.contents("default_cod_binding") = default_cod_binding
        Me.contents("default_idcert") = default_idcert
        
    End If

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Configuración de firma</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <style type="text/css">
        #canvas
        {
            width: 1000px;
            height: 1000px;
            border: 10px solid transparent;
        }
        
        .rectangle
        {
            border: 1px solid #FF0000;
            position: absolute;
        }
    </style>
    <script type="text/javascript">

        // modo
        var modo

        // menu principal
        var vMenu

        var paginaActual = 0
        var totalPaginas = 0

        // relacion de aspecto, y tamaño de la pagina pdf actual
        var aspectRatio
        var pdfWidth
        var pdfHeight

        // configuracion del recuadro de firma en pixels(left, top, width, height, pagina)
        var signaturePos = null

        // estado actual de config de la firma
        var firma_params
        var nombre_doc
        var tmp_file_path
        var extension
        var id_documento_firma

        // nuevo estado de las opciones avanzadas de config de firma
        var firma_avanzadas = {}

        // valores por defecto
        firma_avanzadas["setLTV"] = true
        firma_avanzadas["hashAlgorithm"] = 1
        firma_avanzadas["certificationLevel"] = 0
        firma_avanzadas["cryptoStandard"] = 1
        firma_avanzadas["signatureEstimatedSize"] = 0 //calculo automatico

        var f_id


        function window_onload() {
            
            
            modo = nvFW.pageContents.modo

            if (modo == "config_firma_esquema") {

                //firma_params = nvFW.pageContents["firma_params"]
                var win = nvFW.getMyWindow()
                var docu = win.options.userData.input.docu

                firma_params = win.options.userData.input.firma_params
                nombre_doc = docu.nombre_doc
                tmp_file_path = docu.tmp_file_path
                id_documento_firma = docu.id_documento_firma
                extension = docu.extension

                // cargar menu principal
                loadMenu()

                // habilitar campo descripcion de firma
                habilitar_textoFirma()

                //setear variables
                loadFirmaConfig()


                if (nvFW.pageContents.doc_adjuntable != "true") {
                    // mostrar pdf
                    mostrarSegunExtension()
                } else {

                    
                    var x1 = firma_params["PDF_params"]["PDF_appereance"]["x1"]
                    var x2 = firma_params["PDF_params"]["PDF_appereance"]["x2"]
                    var y1 = firma_params["PDF_params"]["PDF_appereance"]["y1"]
                    var y2 = firma_params["PDF_params"]["PDF_appereance"]["y2"]
                    var page = firma_params["PDF_params"]["PDF_appereance"]["page"]
                    var visible = firma_params["PDF_params"]["visible"]

                    $('input_x1').value = x1
                    $('input_x2').value = x2
                    $('input_y1').value = y1
                    $('input_y2').value = y2
                    $('input_page').value = page


                    if (visible) {
                        // mostrar cajas de texto para x1,x2,y1,y2
                        $('divPositionParams').show()
                    } else {
                        $('divPositionParams').hide()
                    }
                    
                }

            }




            if (modo == "sign_file") {

                //loadCamposDef()

                f_id = nvFW.pageContents.f_id
                extension = nvFW.pageContents.extension
                nombre_doc = nvFW.pageContents.nombre_doc

                loadSignFileMenu()

                $('tbCertificados').style.display = '';
                //$('saveAs').value = nvFW.pageContents.wikiPath;


                if (nvFW.pageContents.default_cod_binding) {
                    campos_defs.set_value("cod_binding", nvFW.pageContents.default_cod_binding)
                    campos_defs.set_value("IDCert", nvFW.pageContents.default_idcert)
                }

                switch (extension) {
                    case "pdf":

                        PDFInitCanvas()
                        hiddenIframe_load(1)

                        break;
                    default:
                        break
                }
            }



            // Este evento funciona solo en modo pdf, y desde
            // el momento en que se carga por primera vez el documento
            nvFW.window_key_action["13"] = function (e) {
                var pagina = $('txtCurrentPage').value
                if (pagina && totalPaginas) {
                    if (parseInt(pagina) <= parseInt(totalPaginas)) {
                        hiddenIframe_load(pagina)
                    }
                }
            }




        }


        function loadFirmaConfig() {

            if (firma_params) {

                $("requerido").value = firma_params["requerido"]
                $("orden").value = firma_params["orden"]
                campos_defs.set_value("nombreFirma", firma_params["fieldname"])

                if (firma_params["PDF_params"]["visible"]) {

                    if (firma_params["PDF_params"]["PDF_appereance"]["signatureText"])
                        campos_defs.set_value("textoFirma", firma_params["PDF_params"]["PDF_appereance"]["signatureText"])

                    if (firma_params["PDF_params"]["PDF_appereance"]["fontFamily"])
                        $("select_fuente").value = firma_params["PDF_params"]["PDF_appereance"]["fontFamily"]

                    if (firma_params["PDF_params"]["PDF_appereance"]["fontStyle"])
                        $("select_estilo").value = firma_params["PDF_params"]["PDF_appereance"]["fontStyle"]

                    if (firma_params["PDF_params"]["PDF_appereance"]["fontColor"])
                        $("select_color").value = firma_params["PDF_params"]["PDF_appereance"]["fontColor"]

                    if (firma_params["PDF_params"]["PDF_appereance"]["fontSize"])
                        $("select_size").value = firma_params["PDF_params"]["PDF_appereance"]["fontSize"]

                    if (firma_params["PDF_params"]["PDF_appereance"]["display"])
                        $("select_visualizacion").value = firma_params["PDF_params"]["PDF_appereance"]["display"]

                    $('checkbox_visible').checked = true
                    onclick_visible()

                    var x1 = firma_params["PDF_params"]["PDF_appereance"]["x1"]
                    var x2 = firma_params["PDF_params"]["PDF_appereance"]["x2"]
                    var y1 = firma_params["PDF_params"]["PDF_appereance"]["y1"]
                    var y2 = firma_params["PDF_params"]["PDF_appereance"]["y2"]
                    var page = firma_params["PDF_params"]["PDF_appereance"]["page"]

                    signaturePos = {}
                    signaturePos["x1"] = x1
                    signaturePos["y1"] = y1
                    signaturePos["x2"] = x2
                    signaturePos["y2"] = y2
                    signaturePos["page"] = page
                }


                firma_avanzadas = {}
                firma_avanzadas["setLTV"] = firma_params["setLTV"]
                firma_avanzadas["hashAlgorithm"] = firma_params["hashAlgorithm"]
                firma_avanzadas["certificationLevel"] = firma_params["PDF_params"]["certificationLevel"]
                firma_avanzadas["cryptoStandard"] = firma_params["PDF_params"]["cryptoStandard"]
                firma_avanzadas["signatureEstimatedSize"] = firma_params["PDF_params"]["signatureEstimatedSize"]
            }
        }


        function mostrarSegunExtension() {

            switch (extension) {
                case "pdf":

                    PDFInitCanvas()

                    // si tiene una firma visible, mostrarla. Sino mostrar la primer pagina
                    var visible = firma_params["PDF_params"]["visible"]
                    if (visible) {
                        var page = firma_params["PDF_params"]["PDF_appereance"]["page"]
                        hiddenIframe_load(page)
                    } else {
                        hiddenIframe_load(1)
                    }

                    break;
                default:
                    break
            }
        }


        function setFirmaRecuadro() {

            if (signaturePos == null) return

            // si hay una firma en la pagina actual....
            if (signaturePos["page"] == paginaActual) {

                var pageWidth = $("canvas").getWidth()
                var pageHeight = $("canvas").getHeight()

                // si el recuadro de firma esta definido en unidades de pdf...
                // hay que normalizar y convertir a pixels
                if (!signaturePos["width"]) {

                    // Pasar a coordenadas normalizadas.
                    var x1 = signaturePos["x1"] / pdfWidth
                    var x2 = signaturePos["x2"] / pdfWidth

                    // En pdf, el origen de las ordenadas esta en el bottom,
                    // por lo que hay que invertirlas
                    var y1 = 1 - (signaturePos["y1"] / pdfHeight)
                    var y2 = 1 - (signaturePos["y2"] / pdfHeight)

                    signaturePos = {}
                    signaturePos["left"] = x1
                    signaturePos["top"] = y2
                    signaturePos["width"] = x2 - x1
                    signaturePos["height"] = y1 - y2
                    signaturePos["page"] = paginaActual
                    signaturePos["pdfWidth"] = pdfWidth
                    signaturePos["pdfHeight"] = pdfHeight
                }

                var element = document.createElement('div');
                element.className = 'rectangle'
                element.style.left = $("canvas").offsetLeft + signaturePos["left"] * pageWidth
                element.style.top = $("canvas").offsetTop + signaturePos["top"] * pageHeight
                element.style.width = signaturePos["width"] * pageWidth
                element.style.height = signaturePos["height"] * pageHeight
                $('canvas').appendChild(element)
            }
        }


        function verConfiguracion() {

            var win = nvFW.createWindow({
                url: 'firmas_configuracion.aspx?',
                title: '<b>Configuracion ABM</b>',
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                width: 500,
                height: 150,
                onClose: function () {
                    if (win.options.userData.retorno["success"]) {
                        firma_avanzadas = win.options.userData.retorno["firma_avanzadas"]
                    }
                }
            });

            win.showCenter(true)
            win.options.userData = { input: { firma_avanzadas: firma_avanzadas, extension: extension }, retorno: { firma_avanzadas: {}} }
        }


        function window_onresize() {

            var bodyHeight = $$('body')[0].getHeight()
            var divHeadHeight = $("divHead").getHeight()
            var divCanvasHeight = $("divCanvas").getHeight()
            var divCanvasWidth = $("divCanvas").getWidth()
            var divOpcionesFirmaHeight = $("divOpcionesFirma").getHeight()

            var height = bodyHeight - divHeadHeight - divOpcionesFirmaHeight - 10
            var width = height * aspectRatio
            $("divCanvas").setStyle({ height: (height) + "px" })
            $("canvas").setStyle({ height: (height) + 'px', width: (width) + "px", overflow: "hidden" });

            if ($("canvas").childNodes.length > 0) {

                var rect = $("canvas").childNodes[0]
                var pageWidth = $("canvas").getWidth()
                var pageHeight = $("canvas").getHeight()

                // escalado del left del rectangulo y traslado
                var left = signaturePos["left"] * pageWidth
                rect.style.left = ($('canvas').offsetLeft + left) + "px"

                // escalado del top del rectangulo, y traslado 
                var top = signaturePos["top"] * pageHeight
                rect.style.top = ($('canvas').offsetTop + top) + "px"

                var width = signaturePos["width"] * pageWidth
                rect.style.width = width + "px"

                var height = signaturePos["height"] * pageHeight
                rect.style.height = height + "px"
            }
        }


        function PDFInitCanvas() {
            initDraw($('canvas'));
        }


        function canvasRemoveChilds() {
            while (canvas.childNodes.length > 0) {
                canvas.removeChild(canvas.childNodes[canvas.childNodes.length - 1]);
            }
        }


        function hiddenIframe_load(pagina) {


            var params = { accion: 'ver_pagina', page: pagina }

            if (f_id) {
                params["f_id"] = f_id
            } else if (tmp_file_path) {
                params["tmp_file_path"] = tmp_file_path
            } else if (id_documento_firma) {
                params["id_documento_firma"] = id_documento_firma
            } else {
                return
            }



            nvFW.error_ajax_request('pdf_signature_editor.aspx', {
                parameters: params,
                onSuccess: function (err, transport) {
                    if (err.numError != 0) {
                    }
                    else {

                        // eliminar recuadros de firma del canvas
                        canvasRemoveChilds()

                        paginaActual = pagina
                        totalPaginas = err.params["page_count"]

                        $('txtCurrentPage').value = paginaActual
                        $("divCantPaginas").innerHTML = "/" + totalPaginas

                        $("canvas").style.backgroundImage = "url('data:image/png;base64," + err.params["img"] + "')"

                        aspectRatio = err.params["pdf_width"] / err.params["pdf_height"]
                        pdfWidth = err.params["pdf_width"]
                        pdfHeight = err.params["pdf_height"]

                        // ajustar la imagen del pdf
                        window_onresize()

                        // posicionar el recuadro de firma
                        setFirmaRecuadro()
                    }
                }
            });
        }


        function pagSiguiente() {

            if (!totalPaginas) return
            if (paginaActual == totalPaginas) return
            hiddenIframe_load(paginaActual + 1)
        }


        function pagAnterior() {

            if (!totalPaginas) return
            if (paginaActual == 1) return;
            hiddenIframe_load(paginaActual - 1)
        }


        function initDraw(canvas) {
            function setMousePosition(e) {
                var ev = e || window.event; //Moz || IE
                if (ev.pageX) { //Moz
                    mouse.x = ev.pageX + window.pageXOffset;
                    mouse.y = ev.pageY + window.pageYOffset;
                } else if (ev.clientX) { //IE
                    mouse.x = ev.clientX + document.body.scrollLeft;
                    mouse.y = ev.clientY + document.body.scrollTop;
                }
            };

            var mouse = {
                x: 0,
                y: 0,
                startX: 0,
                startY: 0
            };

            var element = null;

            canvas.onmousemove = function (e) {
                setMousePosition(e);
                if (element !== null) {
                    element.style.width = Math.abs(mouse.x - mouse.startX) + 'px';
                    element.style.height = Math.abs(mouse.y - mouse.startY) + 'px';
                    element.style.left = (mouse.x - mouse.startX < 0) ? mouse.x + 'px' : mouse.startX + 'px';
                    element.style.top = (mouse.y - mouse.startY < 0) ? mouse.y + 'px' : mouse.startY + 'px';
                }
            }

            canvas.onclick = function (e) {

                if (signaturePos != null) {
                    // eliminar rectangulo dibujado previamente
                    if (canvas.childNodes.length > 0) {
                        canvas.removeChild(canvas.childNodes[canvas.childNodes.length - 1]);
                    }
                }

                if (element !== null) {

                    var pageWidth = $("canvas").getWidth()
                    var pageHeight = $("canvas").getHeight()

                    signaturePos = {}
                    signaturePos["width"] = element.getWidth() / pageWidth
                    signaturePos["height"] = element.getHeight() / pageHeight
                    signaturePos["left"] = (parseFloat(element.style.left) - canvas.offsetLeft) / pageWidth
                    signaturePos["top"] = (parseFloat(element.style.top) - canvas.offsetTop) / pageHeight
                    signaturePos["page"] = paginaActual
                    signaturePos["pdfHeight"] = pdfHeight
                    signaturePos["pdfWidth"] = pdfWidth

                    element = null;
                    canvas.style.cursor = "default";
                } else {

                    signaturePos = null
                    width_previous = null

                    mouse.startX = mouse.x;
                    mouse.startY = mouse.y;
                    element = document.createElement('div');
                    element.className = 'rectangle'

                    element.style.left = mouse.x + 'px';
                    element.style.top = mouse.y + 'px';

                    canvas.appendChild(element)
                    canvas.style.cursor = "crosshair";
                }
            }
        }


        function canvasReloadChilds() {

            if (!posicionesFirmas[paginaActual])
                return

            for (var i = 0; i < posicionesFirmas[paginaActual].length; i++) {
                var element

                if (!posicionesFirmas[paginaActual][i])
                    continue

                var left = posicionesFirmas[paginaActual][i]["left"]
                var top = posicionesFirmas[paginaActual][i]["top"]
                var width = posicionesFirmas[paginaActual][i]["width"]
                var height = posicionesFirmas[paginaActual][i]["height"]

                var element = document.createElement('div');
                element.className = 'rectangle'
                element.style.left = left;
                element.style.top = top;
                element.style.height = height;
                element.style.width = width;

                $("canvas").appendChild(element)
            }
        }


        function getFirmaParamsAsXML() {

            var params = getFirmaParams()

            var strXML = ""
            strXML += "<firma_params"
            strXML += " reason='" + params["reason"] + "' "
            strXML += " location='" + params["location"] + "' "
            strXML += " hashAlgorithm='" + params["hashAlgorithm"] + "'"
            strXML += " setLTV='" + params["setLTV"] + "'"
            strXML += " fieldname='" + params["fieldname"] + "'"
            strXML += " >"

            strXML += "<PDF_params "
            strXML += " appendToExistingOnes='true'"
            strXML += " certificationLevel='" + params["PDF_params"]["certificationLevel"] + "'"
            strXML += " cryptoStandard='" + params["PDF_params"]["cryptoStandard"] + "'"
            strXML += " visible='" + params["PDF_params"]["visible"] + "'"
            strXML += " signatureEstimatedSize='" + params["PDF_params"]["signatureEstimatedSize"] + "'"
            strXML += " >"

            if (params["PDF_params"]["visible"]) {
                strXML += "<PDF_appereance "
                strXML += " x1='" + params["PDF_params"]["PDF_appereance"]["x1"] + "'"
                strXML += " y1='" + params["PDF_params"]["PDF_appereance"]["y1"] + "'"
                strXML += " x2='" + params["PDF_params"]["PDF_appereance"]["x2"] + "'"
                strXML += " y2='" + params["PDF_params"]["PDF_appereance"]["y2"] + "'"
                strXML += " page='" + params["PDF_params"]["PDF_appereance"]["page"] + "'"
                strXML += " fontFamily='" + params["PDF_params"]["PDF_appereance"]["fontFamily"] + "'"
                strXML += " fontColor='" + params["PDF_params"]["PDF_appereance"]["fontColor"] + "'"
                strXML += " fontSize='" + params["PDF_params"]["PDF_appereance"]["fontSize"] + "'"
                strXML += " fontStyle='" + params["PDF_params"]["PDF_appereance"]["fontStyle"] + "'"
                strXML += " display='" + params["PDF_params"]["PDF_appereance"]["display"] + "'"
                strXML += " signatureText='" + params["PDF_params"]["PDF_appereance"]["signatureText"] + "'"
                strXML += " signatureImage='" + params["PDF_params"]["PDF_appereance"]["signatureImage"] + "'"
                strXML += " backgroundImage='" + params["PDF_params"]["PDF_appereance"]["backgroundImage"] + "'"
                strXML += "/>"
            }

            strXML += "</PDF_params>"
            strXML += "</firma_params>"

            return strXML
        }



        function onclick_firmar(guardarComo) {

            if (guardarComo) {
                var msg = "Ingrese el nuevo nombre:";
                Dialog.confirm('<b>' + msg + '</br><input type="text" id="saveAs"/>' + "." + extension
                    , { width: 280, className: "alphacube",
                        onShow: function () {
                        },
                        onOk: function (win) {
                            var saveAs = win.element.ownerDocument.getElementById('saveAs').value
                            win.close();
                            if (!saveAs) {
                                alert("Entrada no válida")
                            } else {

                                firmar(saveAs)
                            }
                        },
                        onCancel: function (win) { win.close() },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
            } else {

                firmar()
            }
        }


        function firmar(saveAs) {
            
            switch (extension) {
                case "pdf":

                    var modo_firma = "deferred_sign"

                    var idCert = campos_defs.get_value("IDCert")
                    if (!idCert) {
                        alert("Debe seleccionar un certificado para firma")
                        return
                    }

                    var cod_binding = campos_defs.get_value("cod_binding")

                    var fieldname = campos_defs.get_value("nombreFirma")

                    if ($('checkbox_visible').checked && signaturePos == null) {
                        alert('Debe especificar el recuadro de la firma')
                        return
                    }

                    var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                    strXML += getFirmaParamsAsXML()


                    var f_ext = ""
                    var f_depende_de = ""
                    if (!saveAs) {
                        saveAs = ""
                    } else {
                        f_ext = extension
                        f_depende_de = nvFW.pageContents.f_depende_de
                    }

                    nvFW.error_ajax_request('/fw/document_signing/document_sign.aspx', {
                        parameters: { modo_firma: modo_firma, strXML: strXML, f_id: f_id, cod_binding: cod_binding, idCert: idCert, saveAs: saveAs, f_ext: f_ext, f_depende_de: f_depende_de },
                        method: 'POST',
                        onSuccess: function (err, transport) {
                            if (err.numError == 0) {
                                // poner spinner a la espera de la firma remota
                                //nvFW_bloqueo_activar(contenedor, id, msg) 
                                nvFW.bloqueo_activar($$('body')[0], 'bloqBody', "Esperando la firma...")
                                requestPendingId = err.params["requestPendingId"]
                                handlerCheckSignatureReady = setInterval(checkSignatureReady, 4000)

                                // cerrar la ventana si pasa mucho tiempo sin completar el proceso
                                setTimeout(destroyWindow, 600000)
                            }
                            else {

                            }
                        }
                    });

                    break;

                default:
                    break;
            }

        }





        var requestPendingId = -1
        var handlerCheckSignatureReady
        function checkSignatureReady() {
            nvFW.error_ajax_request('pdf_signature_editor.aspx', {
                bloq_contenedor_on: false,
                parameters: { accion: "check_signature_finalized", requestPendingId: requestPendingId },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        var signatureFinalized = err.params["signatureFinalized"]
                        if (signatureFinalized == "true") {
                            nvFW.bloqueo_desactivar('bloqBody')
                            clearInterval(handlerCheckSignatureReady)
                            alert("Se ha firmado el documento")
                            try {
                                nvFW.getMyWindow().options.userData.retorno["success"] = true
                            } catch (ee) {
                            }
                            nvFW.getMyWindow().close()
                        }
                    } else {
                        nvFW.bloqueo_desactivar('bloqBody')
                        clearInterval(handlerCheckSignatureReady)
                        alert("Ocurrió un error inesperado al consultar el estado de la firma. Verifique el documento para corroborar que haya sido firmado")
                    }
                },
                onFailure: function (err) {
                }
            })
        }

        function destroyWindow() {
            clearInterval(handlerCheckSignatureReady)
            nvFW.getMyWindow().setDestroyOnClose()
            nvFW.getMyWindow().close()
        }



        function onclick_aceptar() {

            switch (extension) {

                case "pdf":

                    // validar posicion firma
                    if ($('checkbox_visible').checked) {
                        if (nvFW.pageContents.doc_adjuntable != "true") {
                            if (signaturePos == null) {
                                alert('Debe especificar el recuadro de la firma')
                                return
                            }
                        } else {
                            var x1 = $('input_x1').value
                            var y1 = $('input_y1').value
                            var x2 = $('input_x2').value
                            var y2 = $('input_y2').value
                            var page = $('input_page').value
                            if (x1 == "" || y1 == "" || x2 == "" || y2 == "" || page == "") {
                                alert("Complete los datos de posición de la firma")
                                return
                            }
                        }
                    }


                    var firmaParams = getFirmaParams()
                    var win = nvFW.getMyWindow()
                    win.options.userData.retorno["success"] = true
                    win.options.userData.retorno["firma_params"] = firmaParams
                    win.close()

                    /*var strXML = "<?xml version='1.0' encoding='iso-8859-1'?><firmantes_abm><firmantes_modificacion>"
                    strXML += "<firmante id_entidad_firma_config='" + nvFW.pageContents.id_entidad_firma_config + "'>"
                    strXML += getFirmaParamsAsXML()
                    strXML += "</firmante>"
                    strXML += "</firmantes_modificacion></firmantes_abm>"

                    nvFW.error_ajax_request('firmas_abm.aspx?strXML=' + encodeURIComponent(strXML), {
                    parameters: { accion: 'firmante_abm' },
                    method: 'POST',
                    onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                    nvFW.getMyWindow().close() 
                    }
                    }
                    });*/

                    break;

                default:
                    break;
            }
        }



        function getFirmaParams() {

            // params generales de firma
            var location = $('itxtLocacion').value
            var reason = $('itxtRazon').value
            
            var setLTV = firma_avanzadas["setLTV"]
            var hashAlgorithm = firma_avanzadas["hashAlgorithm"]


            var requerido = $("requerido").value == "true" ? true : false
            var orden = parseInt($("orden").value)

            //pdf
            var certificationLevel = firma_avanzadas["certificationLevel"]
            var cryptoStandard = firma_avanzadas["cryptoStandard"]
            var signatureEstimatedSize = firma_avanzadas["signatureEstimatedSize"]

            // pdf apariencia
            var visible = $("checkbox_visible").checked
            var fieldname = campos_defs.get_value("nombreFirma")

            var firma_params = {}

            firma_params["setLTV"] = setLTV
            firma_params["hashAlgorithm"] = hashAlgorithm
            firma_params["location"] = location
            firma_params["reason"] = reason
            firma_params["requerido"] = requerido
            firma_params["orden"] = orden
            firma_params["fieldname"] = fieldname

            firma_params["PDF_params"] = {}
            firma_params["PDF_params"]["certificationLevel"] = certificationLevel
            firma_params["PDF_params"]["cryptoStandard"] = cryptoStandard
            firma_params["PDF_params"]["visible"] = visible
            firma_params["PDF_params"]["appendToExistingOnes"] = true
            firma_params["PDF_params"]["signatureEstimatedSize"] = signatureEstimatedSize

            if (visible) {

                if (nvFW.pageContents.doc_adjuntable != "true") {
                    var left = signaturePos["left"]
                    var top = signaturePos["top"]
                    var right = signaturePos["left"] + signaturePos["width"]
                    var bottom = signaturePos["top"] + signaturePos["height"]
                    var pdfWidth = signaturePos["pdfWidth"]
                    var pdfHeight = signaturePos["pdfHeight"]
                    var x1 = (left * pdfWidth).toFixed(4)
                    var y1 = (pdfHeight - (bottom * pdfHeight)).toFixed(4)
                    var x2 = (right * pdfWidth).toFixed(4)
                    var y2 = (pdfHeight - (top * pdfHeight)).toFixed(4)
                    var page = signaturePos["page"]
                } else {
                    var x1 = $('input_x1').value
                    var y1 = $('input_y1').value
                    var x2 = $('input_x2').value
                    var y2 = $('input_y2').value
                    var page = $('input_page').value
                }


                var fontFamily = $("select_fuente").value
                var fontStyle = $("select_estilo").value
                var fontColor = $("select_color").value
                var fontSize = $("select_size").value
                var display = $("select_visualizacion").value
                var signatureText = campos_defs.get_value("textoFirma")
                var signatureImage = ""
                var backgroundImage = ""


                firma_params["PDF_params"]["PDF_appereance"] = {}
                firma_params["PDF_params"]["PDF_appereance"]["x1"] = x1
                firma_params["PDF_params"]["PDF_appereance"]["y1"] = y1
                firma_params["PDF_params"]["PDF_appereance"]["x2"] = x2
                firma_params["PDF_params"]["PDF_appereance"]["y2"] = y2
                firma_params["PDF_params"]["PDF_appereance"]["page"] = page
                firma_params["PDF_params"]["PDF_appereance"]["fontFamily"] = fontFamily
                firma_params["PDF_params"]["PDF_appereance"]["fontSize"] = fontSize
                firma_params["PDF_params"]["PDF_appereance"]["fontStyle"] = fontStyle
                firma_params["PDF_params"]["PDF_appereance"]["fontColor"] = fontColor
                firma_params["PDF_params"]["PDF_appereance"]["display"] = display
                firma_params["PDF_params"]["PDF_appereance"]["signatureText"] = signatureText
                firma_params["PDF_params"]["PDF_appereance"]["backgroundImage"] = backgroundImage
                firma_params["PDF_params"]["PDF_appereance"]["signatureImage"] = signatureImage
            }

            return firma_params
        }



        function onclick_visible() {

            if (nvFW.pageContents.doc_adjuntable != "true") {
                if ($("checkbox_visible").checked) {
                    $("divOpcionesFirma").show()
                    $("divCanvas").show()
                }
                else {
                    $("divOpcionesFirma").hide()
                    $("divCanvas").hide()
                }
            } else {
                if ($("checkbox_visible").checked) {
                    $("divOpcionesFirma").show()
                    $("divPositionParams").show()
                }
                else {
                    $("divOpcionesFirma").hide()
                    $("divPositionParams").hide()
                } 
            }
            
            

        }


        function habilitar_textoFirma() {

            if ($("select_visualizacion").value !== "0" && $("select_visualizacion").value !== "1") {
                campos_defs.habilitar("textoFirma", false)
            } else {
                campos_defs.habilitar("textoFirma", true)
            }
        }


        function loadMenu() {
            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;font-weight:bold;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + nombre_doc + "</Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Configuracion Firma</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verConfiguracion()</Codigo></Ejecutar></Acciones></MenuItem>")


            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Aceptar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")


            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
            Menus["vMenu"].loadImage("abm", "/FW/image/icons/abm.png")
            vMenu.MostrarMenu()
        }



        function loadSignFileMenu() {
            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 60%;font-weight:bold;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + nombre_doc + "</Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Configuracion Firma</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verConfiguracion()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Firmar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_firmar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='WIDTH: 20%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Firmar y Guardar como...</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_firmar(true)</Codigo></Ejecutar></Acciones></MenuItem>")

            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
            Menus["vMenu"].loadImage("abm", "/FW/image/icons/abm.png")
            vMenu.MostrarMenu()
        }




        function newBinding() {
            var win = window.top.nvFW.createWindow({
                title: 'Vincular Dispositivo',
                url: '/fw/document_signing/qr_binding_scan.aspx?',
                width: 600,
                height: 560,
                destroyOnClose: true, //importante, ya que la window maneja intervals que pueden quedar corriendo si no se la destruye
                onClose: function (err) {
                    var success = win.options.userData.retorno["success"];
                    if (success) {
                        setDefaultBinding()
                    }
                }
            })
            win.options.userData = { retorno: {} }
            win.showCenter(true)

        }

        function editBindings() {
            var win = window.top.nvFW.createWindow({
                title: 'Editar Vinculaciones',
                url: '/fw/document_signing/bindings_edit.aspx?',
                width: 600,
                height: 560,
                destroyOnClose: true,
                onClose: function (err) {
                    var success = win.options.userData.retorno["success"];
                    if (success) {
                        setDefaultBinding()
                    }
                }
            })
            win.options.userData = { retorno: {} }
            win.showCenter(true)

        }


        function setDefaultBinding() {
        
            resetCamposDef()

            var rs = new tRS()
            rs.async = true
            rs.onComplete = function () {
                if (!rs.eof()) {
                    campos_defs.set_value("cod_binding", rs.getdata("cod_binding"))
                    campos_defs.set_value("IDCert", rs.getdata("idcert"))
                } else {
                    campos_defs.clear("cod_binding, IDCert")
                }
            }
            rs.open(nvFW.pageContents.filtroConfigDefault);

        }


        function resetCamposDef() {

            if (nvFW.pageContents.modo == "sign_file") {


                $("cbcod_binding").options.length = 0
                $("cbIDCert").options.length = 0

                //$("btnSel_cod_binding").performClick()

                /*try {
                    campos_defs.remove("cod_binding")
                } catch (e) {
                }
                try {
                    campos_defs.remove("IDCert")
                } catch (e) {
                }


                campos_defs.add("cod_binding", {
                    enDB: false,
                    nro_campo_tipo: 1,
                    filtroXML: nvFW.pageContents.filtroMobileDevices,
                    target: "divCampoDefCodBinding"
                });

                campos_defs.add("IDCert", {
                    enDB: false,
                    nro_campo_tipo: 1,
                    filtroXML: nvFW.pageContents.filtroCertificados,
                    depende_de: "cod_binding",
                    target: "divCampoDefIdCert"
                });
                */
                

            }
        }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id='divHead'>
        <div id="divMenu">
        </div>
        <div id="tbCertificados" style='display: none'>
            <table class="tb1">
                <tr>
                    <td style="width: 25%">
                        <div style="float: left">
                            Dispositivo/App:
                        </div>
                    </td>
                    <td style="width: 75%">
                        <div style="float: left;width:80%" id='divCampoDefCodBinding'>
                            <script type="text/javascript">

                                campos_defs.add("cod_binding", {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroMobileDevices
                                });

                            </script>

                            <!--=nvFW.nvCampo_def.get_html_input(campo_def:="cod_binding", enDB:=False, filtroXML:="<criterio><select vista='verOperadores_mobile_devices'><campos>cod_binding  as id, device_manufacturer + ' ' + device_model + ' - ' + cod_mobile_app as [campo]</campos><filtro><operador type='igual'>" & operador & "</operador></filtro><orden>[cod_binding]</orden></select></criterio>")-->
                        </div>
                        <img src='/fw/image/icons/agregar.png' style="cursor:pointer" onclick='newBinding()' title='vincular nuevo dispositivo/app de firma'/>
                        <img src='/fw/image/icons/editar.png' style="cursor:pointer" onclick='editBindings()' title='editar vinculaciones' />
                    </td>
                </tr>
                <tr>
                    <td style="width: 25%">
                        <div style="float: left">
                            Certificado:
                        </div>
                    </td>
                    <td style="width: 75%">
                        <div style="float: left;width:100%" id='divCampoDefIdCert'>
                            <script type="text/javascript">

                                campos_defs.add("IDCert", {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroCertificados,
                                    depende_de: "cod_binding"
                                });

                            </script>
                            <!--nvFW.nvCampo_def.get_html_input("IDCert", enDB:=False,
                                            filtroXML:="<criterio><select vista='vernotification_bindings_signing_certificates'><campos>IDCert  as [id], cert_name as  [campo] </campos><filtro><cod_binding type='igual'>" & cod_binding & "</cod_binding></filtro><orden>[campo]</orden></select></criterio>")-->
                        </div>
                    </td>
                </tr>
            </table>
            <table class="tb1" id="Table1">
                <tr>
                    <td style="width: 25%">
                        <div style="float: left">
                            Razón:
                        </div>
                    </td>
                    <td style="width: 75%">
                        <div style="float: left; width: 100%">
                            <input type="text" id='itxtRazon' style="width: 100%" />
                        </div>
                    </td>
                </tr>
            </table>
            <table class="tb1" id="Table2">
                <tr>
                    <td style="width: 25%">
                        <div style="float: left">
                            Locación:
                        </div>
                    </td>
                    <td style="width: 75%">
                        <div style="float: left; width: 100%">
                            <input type="text" id='itxtLocacion' style="width: 100%" />
                        </div>
                    </td>
                </tr>
            </table>
            <!--<table class="tb1" id="Table4">
                <tr>
                    <td style="width: 25%">
                        <div style="float: left">
                            Guardar como...
                        </div>
                    </td>
                    <td style="width: 75%">
                        <div style="float: left; width: 100%">
                            <input type="text" id='saveAs' style="width: 100%" />
                        </div>
                    </td>
                </tr>
            </table>-->
        </div>
        <table class="tb1" id="Table3">
            <tr>
                <td style="width: 25%">
                    Nombre de la Firma
                </td>
                <td style="width: 75%">
                    <script type="text/javascript">
                        campos_defs.add('nombreFirma', {
                            nro_campo_tipo: 104,
                            enDB: false
                        });
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td>
                    <div style="float: left">
                        Firma Visible
                        <input type="checkbox" id="checkbox_visible" onclick="onclick_visible()" />
                        <input type="hidden" id='requerido' />
                        <input type="hidden" id='orden' />
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <div id="divCanvas" style='margin: 5px; display: none'>
        <center>
            <div id="canvas" style='border: 0px; background-size: cover; background-repeat: no-repeat;'>
            </div>
        </center>

        <table id="botones_de_desplazamiento" style="width: 40%; margin: 0 auto">
            <tr>
                <td style="width: 2%; text-align: center">
                    <img src="/fw/image/icons/izquierda.png" alt="" style="cursor: pointer" onclick="pagAnterior()" />
                </td>
                <td style="width: 1%">
                    <input type="text" id="txtCurrentPage" style="width: 100%" />
                </td>
                <td style="width: 1%">
                    <p id="divCantPaginas">
                        /15</p>
                </td>
                <td style="width: 2%">
                    <img src="/fw/image/icons/derecha.png" alt="" style="cursor: pointer" onclick="pagSiguiente()" />
                </td>
            </tr>
        </table>
    </div>

    <div id="divPositionParams" style='display:none'>
    <table class="tb1">
    <tr><td>x1: </td><td><input type="text" id="input_x1" value="" /></td></tr>
    <tr><td>x2: </td><td><input type="text" id="input_x2" value="" /></td></tr>
    <tr><td>y1: </td><td><input type="text" id="input_y1" value="" /></td></tr>
    <tr><td>y2: </td><td><input type="text" id="input_y2" value="" /></td></tr>
    <tr><td>page: </td><td><input type="text" id="input_page" value="" /></td></tr>
    </table>
    </div>


    <div id="divOpcionesFirma" style="width: 100%; display: none">
        <!--<table id="botones_de_desplazamiento" style="width: 40%; margin: 0 auto">
            <tr>
                <td style="width: 2%; text-align: center">
                    <img src="/fw/image/icons/izquierda.png" alt="" style="cursor: pointer" onclick="pagAnterior()" />
                </td>
                <td style="width: 1%">
                    <input type="text" id="txtCurrentPage" style="width: 100%" />
                </td>
                <td style="width: 1%">
                    <p id="divCantPaginas">
                        /15</p>
                </td>
                <td style="width: 2%">
                    <img src="/fw/image/icons/derecha.png" alt="" style="cursor: pointer" onclick="pagSiguiente()" />
                </td>
            </tr>
        </table>-->
        <table class="tb1">
            <tr>
                <td colspan="10">
                    Fuente
                </td>
            </tr>
            <tr>
                <td>
                    Familia
                </td>
                <td>
                    <select id="select_fuente" style="width: 100%">
                        <option value="0">Courier</option>
                        <option value="1">Helvetica</option>
                        <option value="2">Times-Roman</option>
                        <option value="3">Symbol</option>
                        <option value="-1">Undefined</option>
                    </select>
                </td>
                <td>
                    Estilo
                </td>
                <td>
                    <select id="select_estilo" style="width: 100%">
                        <option value="0">Normal</option>
                        <option value="1">Negrita</option>
                        <option value="2">Italica</option>
                        <option value="3">Negrita Italica</option>
                        <option value="4">Subrayado</option>
                        <option value="8">Tachado</option>
                        <option value="12">Default size</option>
                        <option value="-1">Undefined</option>
                    </select>
                </td>
                <td>
                    Color
                </td>
                <td>
                    <select id="select_color" style="width: 100%">
                        <option value="0">Negro</option>
                        <option value="1">Blanco</option>
                        <option value="2">Gris</option>
                        <option value="3">Rojo</option>
                        <option value="4">Rosado</option>
                        <option value="5">Naranja</option>
                        <option value="6">Amarillo</option>
                        <option value="7">Verde</option>
                        <option value="8">Magenta</option>
                        <option value="9">Cyan</option>
                        <option value="10">Azul</option>
                        <option value="11">Gris claro</option>
                        <option value="12">Gris oscuro</option>
                    </select>
                </td>
                <td>
                    Tamaño
                </td>
                <td>
                    <select id="select_size" style="width: 100%">
                        <option value="9">9</option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                        <option value="13">13</option>
                        <option value="14">14</option>
                        <option value="15">15</option>
                        <option value="16">16</option>
                        <option value="17">17</option>
                        <option value="18">18</option>
                        <option value="19">19</option>
                        <option value="20">20</option>
                        <option value="21">21</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    Visualizacion
                </td>
                <td colspan="2">
                    <select id="select_visualizacion" onchange="habilitar_textoFirma()" style="width: 100%">
                        <option value="0">Sólo descripcion</option>
                        <option value="1">Nombre de firma y descripción</option>
                        <option value="2">Imagen y descripcion</option>
                        <option value="3">Sólo Imagen</option>
                    </select>
                </td>
                <td>
                    Texto de Firma
                </td>
                <td colspan="2">
                    <script type="text/javascript">
                        campos_defs.add('textoFirma', { nro_campo_tipo: 104, enDB: false });
                    </script>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
