<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>

<%

    Response.Expires = 0
    
    Dim err As New tError()
    Dim modo = nvUtiles.obtenerValor("modo", "")
    Dim idcert = nvUtiles.obtenerValor("idcert")
    Dim cert_name = nvUtiles.obtenerValor("cert_name")
    Dim cert_hasPrivateKey = IIf(nvUtiles.obtenerValor("cert_hasPrivateKey") = "true", True, False)
    Dim cert_exportable = IIf(nvUtiles.obtenerValor("cert_exportable") = "true", True, False)
    Dim cert_secure = IIf(nvUtiles.obtenerValor("cert_secure") = "true", True, False)
    Dim pwd = nvUtiles.obtenerValor("pwd", "")
    Dim pki = nvUtiles.obtenerValor("pki", "")
    Dim id_carpeta = nvUtiles.obtenerValor("id_carpeta", "")
    Dim graba_cert = nvUtiles.obtenerValor("graba_cert", "")

    
    Me.contents("modo") = modo
    Me.contents("idcert") = idcert
    Me.contents("id_carpeta") = id_carpeta
    
    
    If modo = "" Then
        
        Me.contents("consulta_ver_carpetas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI_carpetas'><campos>idpki, carpeta_path</campos><orden></orden><filtro><id_carpeta type='igual'>" & id_carpeta & "</id_carpeta></filtro></select></criterio>")
        Me.contents("consulta_ver_certificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[verPKI_certificados_carpetas]'><campos>idpki, carpeta_path, cert_name, cert_exportable, cert_secure, cert_notbefore, cert_notafter, cert_version, cert_issuer, cert_subject</campos><orden></orden><filtro><IDCert type='igual'>%IDCert%</IDCert><id_carpeta type='igual'>" & id_carpeta & "</id_carpeta></filtro></select></criterio>")
        Me.contents("consulta_ver_certificado_extensiones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='PKI_Certificados_extensiones'><campos>descripcion, valor</campos><orden></orden><filtro><idcert type='igual'>%idcert%</idcert></filtro></select></criterio>")
        
    ElseIf modo = "GUARDAR" Then
        
        
        Dim archivo As Dictionary(Of String, Object) = Nothing
        Try
            For Each campo In Request.Files.AllKeys
                archivo = New Dictionary(Of String, Object)
                If Request.Files(campo).FileName <> "" Then
                    
                    archivo.Add("existe", True)
                    archivo.Add("filename", System.IO.Path.GetFileName(Request.Files(campo).FileName))
                    archivo.Add("extension", System.IO.Path.GetExtension(archivo("filename")))
                    archivo.Add("size", Request.Files(campo).ContentLength)
                    archivo.Add("path", archivo("filename"))

                    Dim binaryData As Byte()
                    Dim binaryReader As New System.IO.BinaryReader(Request.Files(campo).InputStream)
                    binaryData = binaryReader.ReadBytes(Request.Files(campo).ContentLength)
                    archivo.Add("binaryData", binaryData)

                Else
                    archivo.Add("existe", False)
                    archivo.Add("filename", "")
                    archivo.Add("extencion", "")
                    archivo.Add("size", "")
                    archivo.Add("path", "")
                End If
            Next
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al intentar cargar el certificado."
            err.mensaje = "Error al intentar cargar los parametro/s de archivo/s."
            err.salida_tipo = "adjunto"
            err.mostrar_error()
        End Try

        
        Dim binary_serialnumber As Byte() = Nothing
        Dim binary_huella As Byte() = Nothing
        Dim binary_cert As Byte() = Nothing
        Dim cert_notafter As Date = Nothing
        Dim cert_notbefore As Date = Nothing
        Dim cert_version As String = ""
        Dim cert_issuer As String = ""
        Dim cert_subject As String = ""
        Dim cert_extensions As String = ""
            
        Dim cer As System.Security.Cryptography.X509Certificates.X509Certificate2 = Nothing
        
        Try
            If Not (IsNothing(archivo)) Then
                If (archivo.Count > 0 And archivo("existe") = True) Then
                    cer = New System.Security.Cryptography.X509Certificates.X509Certificate2
                    Dim keyStorageFlags = System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.PersistKeySet Or System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.MachineKeySet Or System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable
                    cer.Import(rawData:=archivo("binaryData"), password:=pwd, keyStorageFlags:=keyStorageFlags)
                End If
            End If

            If idcert = 0 Then
                err = nvFW.nvPKIDBUtil.dbAddCert(id_carpeta, cer)
            ElseIf idcert > 0 Then
                err = nvFW.nvPKIDBUtil.dbUpdateCert(idcert, id_carpeta, cer)
            ElseIf idcert < 0 Then
                err = nvFW.nvPKIDBUtil.dbDeleteCert(idcert, id_carpeta)
            End If
            idcert = err.params("idcert")

        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al Guardar Certificado"
            err.mensaje = "Error inesperado"
        End Try
        
        err.salida_tipo = "adjunto"
        err.mostrar_error()
    End If
    

%>
<html>
<head>
    <title>PKI Cert ABM</title>
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

        var idcert
        var id_carpeta

        function window_onload() {
            
            idcert = nvFW.pageContents.idcert
            id_carpeta = nvFW.pageContents.id_carpeta

            $('id_carpeta').value = id_carpeta
            $('idcert').value = idcert

            if (idcert != '' && idcert != 0)
                certificado_cargar(idcert)
            else
                certificado_nuevo()

            window_onresize()
        }

        function certificado_nuevo() {
            $('div_cert_name').hide()
            $('sel_file').show()
            $('graba_cert').value = 1

            var rs = new tRS()
            rs.open(nvFW.pageContents.consulta_ver_carpetas);
            if (!rs.eof()) {
                $('pki').value = rs.getdata('idpki')
                $('carpeta_path').value = rs.getdata('carpeta_path')
            }
            $('div_cert').innerHTML= ""
        }

        function certificado_cargar(idcert) {
            $('graba_cert').value = 0
            $('sel_file').hide()

            var rs = new tRS()
            var params = "<criterio><params IDCert= '" + idcert + "' /></criterio>"
            rs.open(nvFW.pageContents.consulta_ver_certificados, '', '', '', params)
            if (!rs.eof()) {

                $('pki').value = rs.getdata('idpki')
                $('carpeta_path').value = rs.getdata('carpeta_path')
                $('cert_name').value = rs.getdata('cert_name')
                $('cert_hasPrivateKey').checked = false
                var strprivatekey = 'No'
                var strexportable = 'No'
                var strsecure = 'No'
                if (rs.getdata('cert_hasPrivateKey') == 'True') {
                    $('cert_hasPrivateKey').checked = true
                    strprivatekey = 'Si'
                }
                $('cert_exportable').checked = false
                if (rs.getdata('cert_exportable') == 'True') {
                    $('cert_exportable').checked = true
                    strexportable = 'Si'
                }
                $('cert_secure').checked = false
                if (rs.getdata('cert_secure') == 'True') {
                    $('cert_secure').checked = true
                    strsecure = 'Si'
                }

                var strHTML = ''
                strHTML += '<table class="tb1" style="width:100%"><tr class="tbLabel"><td>Clave Privada</td><td>Exportable</td><td>Protección Segura</td></tr>'
                strHTML += '<tr><td style="text-align:center">' + strprivatekey + '</td><td style="text-align:center">' + strexportable + '</td><td style="text-align:center">' + strsecure + '</td></tr></table>'

                strHTML += '<table class="tb1">'
                strHTML += '<tr><td class="Tit1" style="width:25%"><b>Valido no antes de:</b></td><td style="width:25%">' + FechaToSTR(parseFecha(rs.getdata('cert_notbefore'))) + ' ' + HoraToSTR(parseFecha(rs.getdata('cert_notbefore'))) + '</td>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Valido no despues de:</b></td><td>' + FechaToSTR(parseFecha(rs.getdata('cert_notafter'))) + ' ' + HoraToSTR(parseFecha(rs.getdata('cert_notafter'))) + '</td></tr>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Versión:</b></td><td>' + rs.getdata('cert_version') + '</td></tr>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Issuer:</b></td><td colspan="3">' + rs.getdata('cert_issuer') + '</td></tr>'
                strHTML += '<td class="Tit1" style="width:25%"><b>Subject:</b></td><td colspan="3">' + rs.getdata('cert_subject') + '</td></tr>'
                strHTML += '</table>'

                strHTML += '<table class="tb1" width="100%">'
                strHTML += '<tr class="tbLabel"><td style="width:40%"><b>Descripción</b></td><td><b>Valor</b></td></tr>'
                var rsE = new tRS()
                var params = "<criterio><params idcert= '" + idcert + "' /></criterio>"
                rsE.open(nvFW.pageContents.consulta_ver_certificado_extensiones, '', '' , '', params)
                while (!rsE.eof()) {
                    strHTML += '<tr><td class="Tit1" style="width:40%"><b>' + rsE.getdata('descripcion') + '</b></td><td>' + rsE.getdata('valor') + '</td></tr>'
                    rsE.movenext()
                }
                strHTML += '</table>'

                $('div_cert').innerHTML = strHTML
                window_onresize()
            }
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('BODY')[0].getHeight()
                var cabe_height = $('divCabe').getHeight()
                $('div_cert').setStyle({ height: body_height - cabe_height - dif })
            }
            catch (e) { }
        }

        var extension = ''
        function validar_extension() {
            var archivo = $('file').value
            Extensiones = new Array(".cer", ".pfx", ".crt")
            strerror = ""
            if (!archivo)
                strerror = "No ha seleccionado ningún archivo";
            else {
                extension = (archivo.substring(archivo.lastIndexOf("."))).toLowerCase();
                var permitida = false;
                for (var i = 0; i < Extensiones.length; i++) {
                    if (Extensiones[i] == extension) {
                        permitida = true;
                        break;
                    }
                }
                if (!permitida)
                    strerror = "El archivo seleccionado no es un certificado válido."

            }
            return strerror
        }

        var win_private
        var btn_aceptar = false
        function onclick_guardar() {
            if ($('graba_cert').value == 1) {
                if ($('file').value == '') {
                    alert('Seleccione un archivo')
                    return
                }
                var strerror = validar_extension()
                if (strerror != '') {
                    alert(strerror)
                    return
                }
                if (extension == '.pfx') {
                    $('cert_hasPrivateKey').value = true
                    win_private = new Window({ className: 'alphacube',
                        title: '<b>Ingreso contraseña para Clave Privada</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: false,
                        resizable: false,
                        recenterAuto: false,
                        width: 400,
                        height: 150,
                        onClose: function () {
                            $('pwd').value = $('pwd_w').value
                            $('cert_secure').value = $('cert_secure_w').checked
                            $('cert_exportable').value = $('cert_exportable_w').checked
                            if (btn_aceptar)
                                guardar()
                        }
                    });

                    var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
                    html += "<table class='tb1'>"
                    html += "<tbody><tr><td><b>Contraseña:&nbsp;&nbsp;</b><input type='password' value='' id='pwd_w' style='width:70%' /></td></tr>"
                    html += "<tr><td><input style='border:0' type='checkbox' id='cert_secure_w' /><b>Habilitar protección segura de claves privadas</b></td></tr>"
                    html += "<tr><td><input style='border:0' type='checkbox' id='cert_exportable_w' /><b>Marcar clave como exportable</b></td></tr>"
                    html += "<tr><td style='text-align:center' ><br><input type='button' value='Aceptar' onclick='win_private_cerrar(true)'/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Cancelar' onclick='win_private_cerrar(false)'/><br><br></td></tr>"
                    html += "</tbody></table></body></html>"

                    win_private.setHTMLContent(html)
                    win_private.showCenter(true)
                }
                else
                    guardar()
            }
            else
                guardar()

        }

        function win_private_cerrar(aceptar) {
            if (aceptar) {
                if ($('pwd_w').value == '') {
                    alert('Ingrese una contraseña para continuar.')
                    return
                }
            }
            btn_aceptar = aceptar
            win_private.close()
        }

        function guardar() {
            
            var strMsg = ''
            var idcert = $('idcert').value
            var cert_name = $('cert_name').value
            var cert_hasPrivateKey = $('cert_hasPrivateKey').value
            var cert_exportable = $('cert_exportable').value
            var cert_secure = $('cert_secure').value
            var pwd = $('pwd').value
            var graba_cert = $('graba_cert').value
            var name = $('name').value

            if (pki == '')
                strMsg += 'Debe seleccionar una PKI.<br>'
            if (id_carpeta == '')
                strMsg += 'Debe seleccionar una carpeta.<br>'
            if (strMsg != '') {
                alert(strMsg)
                return
            }

            $('modo').value = 'GUARDAR'
            
            nvFW.bloqueo_activar($$('body')[0], 'bloqueo')
            formDocs.submit()

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

                if (nroError != 0) {
                    alert(mensaje)
                    return
                }
                else {

                    $('idcert').value = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/idcert'))
                    win.options.userData.respuesta["idcert"] = $('idcert').value
                    win.options.userData.respuesta["numError"] = 0
                    win.close()
//                    if ($('modo').value == 'B' && $('idcert').value != "")
//                        win.close()
//                    certificado_cargar($('idcert').value)
                }
            }
            catch (e)
        { }
        }

        function desvincular_certificado() {

            Dialog.confirm('¿Desea desvincular el certificado?'
                      , {
                          width: 350, className: "alphacube",
                          onShow: function () {
                          },
                          onOk: function (win) {
                              $('graba_cert').value = 1
                              $('sel_file').show()
                              $('div_cert').innerHTML = ""
                              win.close()
                          },
                          onCancel: function (win) { win.close() },
                          okLabel: 'Aceptar',
                          cancelLabel: 'Cancelar'
                      });

        }


        function eliminar_certificado() {

            Dialog.confirm('¿Desea eliminar el certificado?'
                   , {
                       width: 350, className: "alphacube",
                       onShow: function () {
                       },
                       onOk: function (win) {
                           $('modo').value == 'B'
                           $('idcert').value = $('idcert').value * -1
                           guardar()
                           win.close()
                       },
                       onCancel: function (win) { win.close() },
                       okLabel: 'Aceptar',
                       cancelLabel: 'Cancelar'
                   });

        }


        function window_unonload() {
            $('idcert').disabled = false
            win.options.userData = $('idcert').value
            win.close()
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <form name="formDocs" method="post" action="pki_certificados.aspx" enctype="multipart/form-data"
    target="iframeCargar" style="width: 100%; height: 100%; overflow: hidden">
    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none">
    </iframe>
    <input type="hidden" id='modo' name='modo'/>
    <input type="hidden" id='idcert' name='idcert' />
    <input type="hidden" id='cert_hasPrivateKey' name='cert_hasPrivateKey' value="false" />
    <input type="hidden" id='pwd' name='pwd' value="" />
    <input type="hidden" id='cert_secure' name='cert_secure' value="false" />
    <input type="hidden" id='cert_exportable' name='cert_exportable' value="false" />
    <input type="hidden" id="id_carpeta" name="id_carpeta" />
    <input type="hidden" id="name" name="name" value='' />
    <input type="hidden" id="graba_cert" name="graba_cert" value="1" />
    <div id="divCabe" style="width: 100%; margin: 0px; padding: 0px; overflow: hidden">
        <div id="divMenuABM_pki_certificados">
        </div>
        <script type="text/javascript">

            var vMenuABM_pki_certificados = new tMenu('divMenuABM_pki_certificados', 'vMenuABM_pki_certificados');
            Menus["vMenuABM_pki_certificados"] = vMenuABM_pki_certificados
            Menus["vMenuABM_pki_certificados"].alineacion = 'centro';
            Menus["vMenuABM_pki_certificados"].estilo = 'A';
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vincular</icono><Desc>Desvincular</Desc><Acciones><Ejecutar Tipo='script'><Codigo>desvincular_certificado()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Certificados</Desc></MenuItem>")
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar_certificado()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABM_pki_certificados"].loadImage("vincular", "/FW/image/icons/eliminar.png")
            Menus["vMenuABM_pki_certificados"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
            Menus["vMenuABM_pki_certificados"].loadImage("guardar", "/FW/image/icons/guardar.png")
            vMenuABM_pki_certificados.MostrarMenu()
        </script>
        <div id="div_pki_certificados" style="margin: 0px; padding: 0px">
            <table class="tb1" width='100%'>
                <tr class="tbLabel">
                    <td style='width: 50%'>
                        PKI
                    </td>
                    <td style='width: 50%'>
                        Carpeta
                    </td>
                </tr>
                <tr>
                    <td>
                    <input type="text" style="width:100%;"  id="pki" name="pki" readonly="readonly"/>
                    </td>
                    <td>
                    <input type="text" style="width:100%"  id="carpeta_path" name="carpeta_path" readonly="readonly"/>
                    </td>
                </tr>
            </table>
            <div id="div_cert_name">
            <table class="tb1" width='100%'>
                <tr class="tbLabel">
                    <td style='width: 100%'>
                        Nombre
                    </td>
                </tr>
                <tr>
                    <td>
                        <input name="cert_name" id="cert_name" type="text" value="" style="width: 100%" readonly="readonly"/>
                    </td>
                </tr>
            </table>
            </div>
            <table id="sel_file" class="tb1" style="width: 100%; display: none">
                <tr class="tbLabel">
                    <td>
                        Seleccionar Certificado
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="file" name="file" id="file" style="width: 100%" />
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div id="div_cert" style="margin: 0px; padding: 0px; overflow: auto; width: 100%">
    </div>
    </form>
</body>
</html>
