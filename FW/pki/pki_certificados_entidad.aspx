<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.Xml" %>

<%@ Import Namespace="nvFW" %>

<%


    Dim nombre_entidad = nvUtiles.obtenerValor("nombre_entidad", "")
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
   
    
    If modo = "" Then
        
        Dim nro_entidad As String = nvUtiles.obtenerValor("nro_entidad", "")
        Me.contents("filtroCargarCertificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[verEntidad_certificados]'><campos>added_by_device_binding, IDCert, cert_name, id_carpeta</campos><orden></orden><filtro><nro_entidad type='igual'>" & nro_entidad & "</nro_entidad></filtro></select></criterio>")
        Me.contents("nro_entidad") = nro_entidad
        Me.contents("nombre_entidad") = nombre_entidad
        Me.contents("modo") = modo
        
    ElseIf modo = "ELIMINAR" Then
        
        Dim err As New tError
        Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
        Dim idcert As String = nvUtiles.obtenerValor("idcert", "")
        Dim idcarpeta As String = nvUtiles.obtenerValor("id_carpeta", "")
        
        Try
            DBExecute("DELETE FROM entidad_certificados WHERE nro_entidad=" & nro_entidad & " AND idcert=" & idcert)
        
            ' borrar el binario del certificado siempre y cuando no este asociado a un entidad en la tabla notification_bindings_signing_certificates
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM notification_bindings_signing_certificates WHERE idcert=" & idcert)
            If rs.EOF Then
                nvFW.nvPKIDBUtil.dbDeleteCert(idcert, idcarpeta)
            End If
            nvDBUtiles.DBCloseRecordset(rs)
        Catch e As Exception
            err.parse_error_script(e)
        End Try
        err.response()

        ElseIf modo = "GUARDAR" Then
        
            Dim err As New tError()
            Dim idcert As String
            Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
            Dim pwd As String = nvUtiles.obtenerValor("pwd", "")
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
            Catch ex As Exception
                err.parse_error_script(ex)
                err.salida_tipo = "adjunto"
                err.mostrar_error()
            End Try
        
        
            ' corroborar que certificado pertenece a algunas de las pkis
            Dim idpki As String = ""
            For Each pkiId In nvApp.PKIs.Keys
                Dim pki As tnvPKI = nvApp.PKIs(pkiId)
                Dim includeRoot As Boolean = False
                pki.getChainElement(Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cer), includeRoot)
                If includeRoot Then
                    idpki = pkiId
                    Exit For
                End If
            Next
            
            If idpki = "" Then
                err.numError = -1
                err.titulo = "Error"
                err.mensaje = "La PKI del certificado es desconocida"
                err.debug_desc = "La PKI del certificado es desconocida"
                err.debug_src = "device_notifications_binding.aspx"
                err.salida_tipo = "adjunto"
                err.mostrar_error()
            End If
            
            ' crear carpeta entidades si no existe
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM PKI_carpetas WHERE idpki='" & idpki & "' AND carpeta_path='Entidades' AND carpeta_nombre='Entidades'")
            Dim noExisteCarpetaEntidades As Boolean = rs.EOF
            DBCloseRecordset(rs)
            If noExisteCarpetaEntidades Then
                err = nvPKIDBUtil.pkiFolderABM(idpki, 0, "Entidades", "Entidades", False, False)
                If err.numError <> 0 Then
                    err.salida_tipo = "adjunto"
                    err.mostrar_error()
                End If
            End If
            
            ' Agregar certificado en la carpeta entidades (si no existe)
        
            Dim output As tError = nvFW.nvPKIDBUtil.dbAddCert(idpki, "Entidades", cer)
            idcert = output.params("idcert")
            
            ' vincular el certificado a la entidad
            Try
                'rs = nvDBUtiles.DBOpenRecordset("SELECT * FROM verEntidad_certificados WHERE NRO_entidad=" & nro_entidad & " AND idcert=" & idcert & "")
                'Dim certNoExiste As Boolean = rs.EOF
                'DBCloseRecordset(rs)
                'If certNoExiste Then
                '    nvDBUtiles.DBExecute("INSERT INTO entidad_certificados(nro_entidad, idcert) VALUES(" & nro_entidad & "," & idcert & ")")
                'Else
                '    err.numError = -1
                '    err.mensaje = "El certificado ya se encuentra vinculado"
                'End If
            
            
                rs = nvDBUtiles.DBOpenRecordset("SELECT * FROM entidad_certificados WHERE NRO_entidad=" & nro_entidad & " AND idcert=" & idcert & "")
                Dim certNoExiste As Boolean = rs.EOF
                DBCloseRecordset(rs)
                If certNoExiste Then
                    nvDBUtiles.DBExecute("INSERT INTO entidad_certificados(nro_entidad, idcert) VALUES(" & nro_entidad & "," & idcert & ")")
                Else
                    err.numError = -1
                    err.mensaje = "El certificado ya se encuentra vinculado"
                End If
            
            
            Catch e As Exception
                err.parse_error_script(e)
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
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        function window_onload() {
                
            $('nombre_entidad').value = nvFW.pageContents.nombre_entidad
            $('nro_entidad').value = nvFW.pageContents.nro_entidad
            cargarTablaCertificados()
            window_onresize()
        }


        function eliminarCertificados() {
            var strXML = "<info>";
            strXML += tabla_certificados.generarXML("certificados");    
            strXML += "</info>";

            nvFW.error_ajax_request('pki_certificados_entidad.aspx?nro_entidad=' + $('nro_entidad').value, {
                parameters: {
                    modo: "ELIMINAR",
                    strXML: strXML
                },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        tabla_certificados.refresh();
                    }
                }
            });
        }


        function onclick_guardar() {

            var archivo = $('file').value
            if (!archivo) {
                alert("No ha seleccionado ningún archivo")
                return
            }

            // validar extension
            var extension = (archivo.substring(archivo.lastIndexOf("."))).toLowerCase();
            var extensiones = [".cer", ".pfx", ".crt"]
            var permitida = false;
            for (var i = 0; i < extensiones.length; i++) {
                if (extensiones[i] == extension) {
                    permitida = true;
                    break;
                }
            }
            if (!permitida) {
                alert("El archivo seleccionado no es un certificado válido.")
                return
            }

            if (extension == '.pfx') {
                $('cert_hasPrivateKey').value = true
                win_private = nvFW.createWindow({
                    title: '<b>Ingreso contraseña para Clave Privada</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    recenterAuto: false,
                    width: 400,
                    height: 150
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


        var win_private
        function win_private_cerrar(aceptar) {
            if (aceptar) {
                if ($('pwd_w').value == '') {
                    alert('Ingrese una contraseña para continuar.')
                    return
                }
                $('pwd').value = $('pwd_w').value
                guardar()
            }
            win_private.close()
        }


        function guardar() {

            nvFW.bloqueo_activar($$('body')[0], 'bloqueo')
            $('modo').value = 'GUARDAR'
            formDocs.submit()
            $('file').value = ''

        }


        function cargarTablaCertificados() {

            var rs = new tRS()
            rs.async = true
            rs.onComplete = function () {

                var strHTML = "<table class='tb1'><tr class='tbLabel'><td>id</td><td>Certificado</td><td>Pertenece a device</td><td>Eliminar</td></tr>"
                while (!rs.eof()) {

                    strHTML += "<tr>"
                    strHTML += "<td>" + rs.getdata("IDCert") + "</td>"
                    strHTML += "<td>" + rs.getdata("cert_name") + "</td>"
                   
                    //strHTML += "<td><input id='input_" + rs.getdata("cod_binding") + "' type='text' value='" + rs.getdata("device_operador_desc") + "'/></td>"
                    if (rs.getdata("added_by_device_binding") != "1") {
                        strHTML += "<td></td>"
                        strHTML += "<td><img src='/fw/image/icons/eliminar.png' style='cursor:pointer' title='eliminar'/ onclick='confirmEliminarCert(" + rs.getdata("IDCert") + "," + rs.getdata("id_carpeta") + ")'></td>"
                    } else {
                        strHTML += "<td><img src='/fw/image/icons/tilde.png'/></td>"
                        strHTML += "<td></td>"
                    }

                    strHTML += "</tr>"
                    rs.movenext()
                }
                strHTML += "</table>"

                $('div_tabla_certificados').innerHTML = strHTML;
            }
            rs.open(nvFW.pageContents.filtroCargarCertificados)

        }


        function confirmEliminarCert(idcert, id_carpeta) {

            // se necesita permisos para eliminar device
            //            if (!tienePermisoEliminarDevice(operador)) {
            //                return
            //            }

            Dialog.confirm('<b>"Esta seguro que desea eliminar el certificado?"</br>'
                    , { width: 280, className: "alphacube",
                        onShow: function () {
                        },
                        onOk: function (win) {
                            eliminarCert(idcert, id_carpeta);
                            win.close();
                        },
                        onCancel: function (win) { win.close() },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
                }



                function eliminarCert(idcert, id_carpeta) {
                    nvFW.error_ajax_request('pki_certificados_entidad.aspx', {
                        parameters: {
                            modo: "ELIMINAR",
                            idcert: idcert,
                            id_carpeta: id_carpeta,
                            nro_entidad: nvFW.pageContents.nro_entidad
                        },
                        onSuccess: function (error, transport) {
                            if (error.numError == 0) {
                                cargarTablaCertificados()
                            }
                        }
                    });
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
                }
                else {
                    cargarTablaCertificados()
                }
            }
            catch (e) { }
        }


        function window_onresize() {
            try {
                /*var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('BODY')[0].getHeight()
                var cabe_height = $('divCabe').getHeight()
                var div_tabla_certificados = $('div_tabla_certificados').getHeight()
                $('div_cert').setStyle({ height: body_height - cabe_height - dif - div_tabla_certificados })*/
            }
            catch (e) { }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <form name="formDocs" method="post" action="pki_certificados_entidad.aspx" enctype="multipart/form-data" target="iframeCargar" >
    <input type="hidden" id='modo' name='modo'/>
    <input type="hidden" id='pwd' name='pwd' value="" />
    <input type="hidden" id="nro_entidad" name="nro_entidad" value="" />
    <input type="hidden" id='cert_hasPrivateKey' name='cert_hasPrivateKey' value="false" />
   


    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none"></iframe>


    <div id="divCabe" style="width: 100%; margin: 0px; padding: 0px; overflow: hidden">

        <div id="divMenuABM_pki_certificados"></div>
        <script type="text/javascript">

            var vMenuABM_pki_certificados = new tMenu('divMenuABM_pki_certificados', 'vMenuABM_pki_certificados');
            Menus["vMenuABM_pki_certificados"] = vMenuABM_pki_certificados
            Menus["vMenuABM_pki_certificados"].alineacion = 'centro';
            Menus["vMenuABM_pki_certificados"].estilo = 'A';
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Certificados</Desc></MenuItem>")
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABM_pki_certificados"].loadImage("vincular", "/FW/image/icons/eliminar.png")
            Menus["vMenuABM_pki_certificados"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
            Menus["vMenuABM_pki_certificados"].loadImage("guardar", "/FW/image/icons/guardar.png")
            vMenuABM_pki_certificados.MostrarMenu()

        </script>

        <div id="div_pki_certificados" style="margin: 0px; padding: 0px">
            <table class="tb1" >
                <tr class="tbLabel">
                    <td style='width: 50%'>
                        Nombre Entidad
                    </td>
                </tr>
                <tr>
                    <td>
                    <input type="text" style="width:100%;"  id="nombre_entidad" name="nombre_entidad" readonly="readonly"/>
                    </td>
                </tr>
            </table>

            <table id="sel_file" class="tb1" style="width: 100%;">
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




    <div id="div_tabla_certificados" style="width: 100%; height: 100%;overflow:auto">

    </div>

    
    </form>
</body>
</html>
