<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Response.Expires = 0

    Dim err As New tError()

    Dim archivo As Dictionary(Of String, Object)
    Try
        For Each campo In Request.Files.AllKeys
            archivo = New Dictionary(Of String, Object)
            If Request.Files(campo).FileName <> "" Then
                ' //Guarda los archivos en el directorio_archivos
                archivo.Add("existe", True)
                archivo.Add("filename", System.IO.Path.GetFileName(Request.Files(campo).FileName))
                archivo.Add("extencion", System.IO.Path.GetExtension(archivo("filename")))
                archivo.Add("size", Request.Files(campo).ContentLength)
                archivo.Add("path", archivo("filename"))

                Dim binaryData As Byte()
                Dim binaryReader As New System.IO.BinaryReader(Request.Files(campo).InputStream)
                binaryData = binaryReader.ReadBytes(Request.Files(campo).ContentLength)
                archivo.Add("binaryData", binaryData)

                nvFW.nvReportUtiles.create_folder(archivo("path"))
                Request.Files(campo).SaveAs(archivo("path"))

            Else
                archivo.Add("existe", False)
                archivo.Add("filename", "")
                archivo.Add("extencion", "")
                archivo.Add("size", "")
                archivo.Add("path", "")
            End If
            'Transf.Archivos.Add(campo, archivo)
        Next
    Catch ex As Exception
        err.parse_error_script(ex)
        err.titulo = "Error al intentar cargar el certificado."
        err.mensaje = "Error al intentar cargar los parametro/s de archivo/s."
        err.mostrar_error()
    End Try


    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim idpki = nvFW.nvUtiles.obtenerValor("idpki", "")
    Dim pki = nvFW.nvUtiles.obtenerValor("pki", "")
    Dim pki_comentario = nvFW.nvUtiles.obtenerValor("pki_comentario", "")
    Dim acraiz As Integer = nvFW.nvUtiles.obtenerValor("acraiz", 0)
    Dim esConfiable As Boolean = IIf(nvUtiles.obtenerValor("esConfiable") = "on", True, False)
    Dim urlTsa As String = nvFW.nvUtiles.obtenerValor("urlTsa", "")
    
    If (modo = "") Then
        modo = "VA"
    End If
    
    If modo = "VA" Then
        Me.contents("consulta_verPKI") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI'><campos>*</campos><orden></orden><filtro><IDPKI type='igual'>'" & idpki & "'</IDPKI></filtro></select></criterio>")
        Me.contents("consulta_ver_certificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verpki_certificados'><campos>*</campos><orden></orden><filtro><IDCert type='igual'>" & acraiz & "</IDCert></filtro></select></criterio>")
        Me.contents("consulta_ver_certificados_extensiones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='PKI_Certificados_extensiones'><campos>*</campos><orden></orden><filtro><idcert type='igual'>" & acraiz & "</idcert></filtro></select></criterio>")
    End If
    
    If (modo.ToUpper <> "VA") Then

        Try
            Dim cert_name As String = archivo("filename").split(".")(0)
            Dim cert_hasPrivateKey As Boolean = False
            Dim cert_exportable As Boolean = False
            Dim cert_secure As Boolean = False

            Dim cert_extensions As String = ""
            Dim pwd As String = ""

            
            Dim cer As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing
            If Not (IsNothing(archivo)) Then
                If (archivo.Count > 0 And archivo("existe") = True) Then

                    cer = New System.Security.Cryptography.X509Certificates.X509Certificate2
                    cer.Import(rawData:=archivo("binaryData"), password:=pwd, keyStorageFlags:=2 + 4 + 16) 
                End If
            End If
            
            If modo = "A" Then
                err = nvFW.PKINovaDBUtil.dbAddPKI(idpki, pki, pki_comentario, esConfiable, urlTsa, archivo("filename"), cer)
            ElseIf modo = "M" Then
                err = nvFW.PKINovaDBUtil.dbUpdatePKI(idpki, pki, pki_comentario, acraiz, esConfiable, urlTsa, archivo("filename"), cer)
            Else
                err = nvFW.PKINovaDBUtil.dbDeletePKI(idpki)
            End If

        Catch ex As Exception

            err.parse_error_script(ex)

            err.titulo = "Error Guardar PKI"
            err.mensaje = ex.Message
            err.comentario = ""

        End Try

        err.salida_tipo = "adjunto"
        err.debug_src = "PKI_abm.aspx"
        err.mostrar_error()

    End If

%>
<html>
<head>
    <title>PKI ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()

        function window_onload() {

            var idpki = $('idpki').value
            if (idpki != '')
                pki_cargar(idpki)
            else
                $('modo').value = 'A'

            window_onresize()
        }

        function pki_cargar(idpki) {
            $('modo').value = 'M'

            var rs = new tRS()
            rs.open(nvFW.pageContents.consulta_verPKI);
            if (!rs.eof()) {
                $('idpki').value = rs.getdata('IDPKI')
                $('idpki').disabled = true
                $('pki').value = rs.getdata('PKI')
                $('esConfiable').checked = rs.getdata('esConfiable') == "True"
                $('pki_comentario').value = rs.getdata('PKI_Comentario')
                $('acraiz').value = rs.getdata('ACRaiz')
                pki_certificado_cargar($('acraiz').value)
                $('div_cert').show()
                $('tbacraiz').hide()
            }
        }

        function pki_certificado_cargar(acraiz) {

            $('div_cert').innerHTML = ''
            var strHTML = ''
            var rs = new tRS()
            rs.open(nvFW.pageContents.consulta_ver_certificados);
            if (!rs.eof()) {
                strHTML += '<table class="tb1">'
                strHTML += '<tr class="tbLabel"><td style="width:20%" colspan="4">AC Raiz</td></tr>'
                strHTML += '<tr><td class="Tit1" style="width:25%"><b>Valido no antes de:</b></td><td style="width:25%">' + FechaToSTR(parseFecha(rs.getdata('cert_notbefore'))) + ' ' + HoraToSTR(parseFecha(rs.getdata('cert_notbefore'))) + '</td>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Valido no despues de:</b></td><td>' + FechaToSTR(parseFecha(rs.getdata('cert_notafter'))) + ' ' + HoraToSTR(parseFecha(rs.getdata('cert_notafter'))) + '</td></tr>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Versión:</b></td><td>' + rs.getdata('cert_version') + '</td></tr>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Issuer:</b></td><td colspan="3">' + rs.getdata('cert_issuer') + '</td></tr>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Subject:</b></td><td colspan="3">' + rs.getdata('cert_subject') + '</td></tr>'
                strHTML += '</table>'
                strHTML += '<table class="tb1" width="100%">'
                strHTML += '<tr class="tbLabel"><td style="width:40%"><b>Descripción</b></td><td><b>Valor</b></td></tr>'
                strHTML += '</table>'
                strHTML += '<div id="divRow" width="100%">'
                strHTML += '<table class="tb1" width="100%">'
                
                var rsE = new tRS()
                rsE.open(nvFW.pageContents.consulta_ver_certificados_extensiones);
                while (!rsE.eof()) {
                    strHTML += '<tr><td class="Tit1" style="width:40%"><b>' + rsE.getdata('descripcion') + '</b></td><td>' + rsE.getdata('valor') + '</td></tr>'
                    rsE.movenext()
                }
                strHTML += '</table>'
                strHTML += '</div>'
            }
            $('div_cert').insert({ bottom: strHTML })

            window_onresize()
        }

        function window_onresize() {
            try {

                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('BODY')[0].getHeight()
                var cabe_height = $('divCabe').getHeight()
                var pie_height = $('divPie').getHeight()

                $('div_cert').setStyle({ height: body_height - cabe_height - pie_height - dif })
            }
            catch (e) { }
        }

        function guardar() {
            var modo = $('modo').value
            var idpki = $('idpki').value
            var pki = $('pki').value
            var pki_comentario = $('pki_comentario').value
            var acraiz = $('acraiz').value
            var strMsg = ''
            if (idpki == '')
                strMsg += 'Debe ingresar un ID para la PKI.<br>'
            if (pki == '')
                strMsg += 'Debe ingresar el nombre de la PKI.<br>'
            if ($('acraiz').value == '' && $('facraiz').value == "")
                strMsg += 'Debe seleccionar el certificado del AC Raiz.<br>'
            if (strMsg != '') {
                alert(strMsg)
                return
            }
            $('idpki').disabled = false
            nvFW.bloqueo_activar($$('body')[0], 'bloqueo')

            form_pki_abm.submit()

        }


        function abm_certificados() {

            win = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: 'pki_certificados.aspx',
                title: '<b>ABM Certificado</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 300,
                resizable: true,
                destroyOnClose: true
            });

            win.options.userData = {}
            win.showCenter(true);

        }

        function hiddenIframe_load() {
            try {

                nvFW.bloqueo_desactivar($$('body')[0], "bloqueo")
                var strHTML = $('iframeCargar').contentWindow.document.body.innerHTML
                var strXML = $('iframeCargar').contentWindow.error_xml.value
                var oXML = new tXML()
                oXML.loadXML(strXML)

                nroError = oXML.selectSingleNode('error_mensajes/error_mensaje/@numError').nodeValue
                mensaje = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/mensaje'))

                if (nroError > 0) {
                    alert(mensaje)
                    return
                }
                else {
                    $('idpki').value = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/idpki'))
                    $('idpki').disabled = true
                    win.options.userData = $('idpki').value
                    if ($('modo').value == 'B' && $('idpki').value != "")
                        win.close()
                }
            }
            catch (e)
            { }
        }

        function desvincular_acraiz() {

            Dialog.confirm('¿Desea desvincular el certificado AC Raíz?'
                          , {
                              width: 350, className: "alphacube",
                              onShow: function () {
                              },
                              onOk: function (win) {
                                  $('div_cert').hide()
                                  $('tbacraiz').show()
                                  //$('acraiz').value = 0
                                  win.close()
                              },
                              onCancel: function (win) { win.close() },
                              okLabel: 'Aceptar',
                              cancelLabel: 'Cancelar'
                          });

        }

        function eliminar_pki() {

            Dialog.confirm('¿Desea eliminar la PKI?'
                       , {
                           width: 350, className: "alphacube",
                           onShow: function () {
                           },
                           onOk: function (win) {
                               $('modo').value = 'B'
                               guardar()
                               win.close()
                           },
                           onCancel: function (win) { win.close() },
                           okLabel: 'Aceptar',
                           cancelLabel: 'Cancelar'
                       });

        }

        function window_unonload() {
            $('idpki').disabled = false
            win.options.userData = $('idpki').value
            win.close()
        }
    </script>
</head>


<body onload="return window_onload()" onresize="window_onresize()" onunload="onunload()"
    style="width: 100%; height: 100%; overflow: hidden">
    <form action="pki_ABM.aspx" enctype="multipart/form-data" target="iframeCargar" method="post"
    name="form_pki_abm" style="width: 100%; height: 100%; overflow: hidden">
    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none">
    </iframe>
    <input type="hidden" id='modo' name='modo' value="<%=modo %>" />
    <div id="divMenuABM_pki">
    </div>
    <script type="text/javascript">
        var vMenuABM_pki = new tMenu('divMenuABM_pki', 'vMenuABM_pki');
        Menus["vMenuABM_pki"] = vMenuABM_pki
        Menus["vMenuABM_pki"].alineacion = 'centro';
        Menus["vMenuABM_pki"].estilo = 'A';
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vincular</icono><Desc>Desvincular AC Raiz</Desc><Acciones><Ejecutar Tipo='script'><Codigo>desvincular_acraiz()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM PKI</Desc></MenuItem>")
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar_pki()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki"].loadImage("guardar", "/FW/image/icons/guardar.png")
        Menus["vMenuABM_pki"].loadImage("vincular", "/FW/image/icons/eliminar.png")
        Menus["vMenuABM_pki"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
        vMenuABM_pki.MostrarMenu()
    </script>
    <div id="divCabe" style="margin: 0px; padding: 0px">
        <table class="tb1" style="width: 100%">
            <tr class="tbLabel">
                <td style='width: 30%'>
                    IDPKI
                </td>
                <td style='width: 30%'>
                    PKI
                </td>
                <td style='width: 20%'>
                    Es Confiable
                </td>
                <td style='width: 20%'>
                    TSA URL
                </td>
            </tr>
            <tr>
                <td>
                    <input name="idpki" id="idpki" type="text" value="<%=idpki %>" style="width: 100%" />
                </td>
                <td>
                    <input name="pki" id="pki" type="text" value="" style="width: 100%" />
                </td>
                <td style='text-align: center'>
                    <input style='border: 0' type="checkbox" id='esConfiable' name="esConfiable" />
                </td>
                <td>
                    <input name="urlTsa" id="urlTsa" type="text" value="" style="width: 100%" />
                </td>
            </tr>
        </table>
        <table class="tb1" id="tbacraiz">
            <tr class="tbLabel">
                <td>
                    AC Raiz
                </td>
            </tr>
            <tr>
                <td>
                    <input type="hidden" id='acraiz' name='acraiz' value="0" /><input name="facraiz"
                        id="facraiz" type="file" value="" style="width: 100%" />
                </td>
            </tr>
        </table>
    </div>
    <div id="divPie" style="margin: 0px; padding: 0px">
        <table class="tb1">
            <tr class="tbLabel">
                <td>
                    Comentario
                </td>
            </tr>
            <tr>
                <td style='width: 20%'>
                    <input name="pki_comentario" id="pki_comentario" type="text" value="" style="width: 100%" />
                </td>
            </tr>
        </table>
    </div>
    <div id="div_cert" style="margin: 0px; padding: 0px; display: none; overflow: auto">
    </div>
    </form>
</body>
</html>
