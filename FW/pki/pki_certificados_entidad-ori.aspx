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
    Dim id_carpeta = nvUtiles.obtenerValor("id_carpeta", "")
    Dim graba_cert = nvUtiles.obtenerValor("graba_cert", "")
    Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
    Dim strXML = nvUtiles.obtenerValor("strXML", "")

    Dim nombre_entidad = nvUtiles.obtenerValor("nombre_entidad", "")

    Me.contents("modo") = modo
    Me.contents("idcert") = idcert
    Me.contents("id_carpeta") = id_carpeta
    Me.contents("nombre_entidad") = nombre_entidad
    Me.contents("nro_entidad") = nro_entidad
    Dim rs

    If modo = "" Then

        Me.contents("consulta_ver_carpetas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI_carpetas'><campos>idpki, carpeta_path</campos><orden></orden><filtro><id_carpeta type='igual'>" & id_carpeta & "</id_carpeta></filtro></select></criterio>")
        Me.contents("consulta_ver_certificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[verPKI_certificados_carpetas]'><campos>idpki, carpeta_path, cert_name, cert_exportable, cert_secure, cert_notbefore, cert_notafter, cert_version, cert_issuer, cert_subject</campos><orden></orden><filtro><IDCert type='igual'>'" & idcert & "'</IDCert><id_carpeta type='igual'>" & id_carpeta & "</id_carpeta></filtro></select></criterio>")
        Me.contents("consulta_ver_certificado_extensiones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='PKI_Certificados_extensiones'><campos>descripcion, valor</campos><orden></orden><filtro><idcert type='igual'>" & idcert & "</idcert></filtro></select></criterio>")
        Me.contents("filtroCargarCertificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI_Entidad_Certificado'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    ElseIf modo = "ELIMINAR" Then

        Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()

        objXML.LoadXml(strXML)

        Dim NODS = objXML.SelectNodes("/info/certificados")

        Try
            For i As Integer = 0 To NODS.Count - 1
                Dim nod = NODS(i)

                Dim IDPKIe = nod.Attributes("IDPKI").Value
                Dim carpeta_pathe = nod.Attributes("carpeta_path").Value
                Dim idcerte = nod.Attributes("idcert").Value
                Dim idcarpeta = nod.Attributes("id_carpeta").Value

                rs = nvFW.nvDBUtiles.DBExecute("Delete entidad_certificados where nro_entidad=" + nro_entidad + " and idcert=" + idcerte + "")
                rs = nvFW.nvDBUtiles.DBExecute("Delete PKI_carpeta_certificados where IDPKI='" + IDPKIe + "' and carpeta_path='" + carpeta_pathe + "' and IDCert='" + idcerte + "'")
                nvFW.nvPKIDBUtil.dbDeleteCert(idcerte, idcarpeta)
            Next


        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al eliminar Certificado"
            err.mensaje = "Error al eliminar el certificado."


        End Try
        err.salida_tipo = "adjunto"
        err.response()

    ElseIf modo = "GUARDAR" Then

        Dim archivo As Dictionary(Of String, Object) = Nothing
        Try
            For Each campo In Request.Files.AllKeys
                archivo = New Dictionary(Of String, Object)
                If Request.Files(campo).FileName <> "" Then

                    archivo.Add("existe", True)
                    archivo.Add("filename", System.IO.Path.GetFileName(Request.Files(campo).FileName))
                    archivo.Add("extencion", System.IO.Path.GetExtension(archivo("filename")))
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
                    cer.Import(rawData:=archivo("binaryData"), password:=pwd, keyStorageFlags:=System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.DefaultKeySet)
                End If
            End If

            Dim carpeta_path = "Entidades"

            Dim StrSQL = "Select * from pki"

            Dim pkis = nvFW.nvDBUtiles.DBExecute(StrSQL)
            Dim pki_certif = ""
            Dim includeroot As Boolean = False


            While (Not pkis.EOF() And Not includeroot)

                Dim pki = nvPKIDBUtil.LoadPKIFromDB(pkis.Fields(0).Value)

                includeroot = False

                Dim listadoDeCertificados = pki.getTrustedCertsList()
                Dim listadoDeCertificadosCast(listadoDeCertificados.Count - 1) As Org.BouncyCastle.X509.X509Certificate

                Dim certif = Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cer)
                Dim i As Integer = 0

                For Each certificadoC In listadoDeCertificados
                    listadoDeCertificadosCast(i) = certificadoC
                    i = i + 1
                Next

                nvSignatureVerify.getChain(certif, listadoDeCertificadosCast, includeroot)

                If includeroot Then
                    pki_certif = pkis.Fields(0).Value
                End If

                pkis.MoveNext()

            End While

            If includeroot Then
                err = nvFW.nvPKIDBUtil.dbAddCert(pki_certif, carpeta_path, cer)
                idcert = err.params("idcert")
                rs = nvFW.nvDBUtiles.DBExecute("select 1 from entidad_certificados where  nro_entidad = '" + nro_entidad + "' and idcert='" + idcert + "'")

                

                If rs.EOF() Then
                    rs = nvFW.nvDBUtiles.DBExecute("insert into entidad_certificados(nro_entidad,idcert) values(" + nro_entidad + "," + idcert + ")")
                    'rs = nvFW.nvDBUtiles.DBExecute("insert into PKI_carpeta_certificados(IDPKI,carpeta_path,IDCert) values('" + pki_certif + "','" + carpeta_path + "','" + idcert + "')")
                Else
                    err.titulo = "Error al Guardar Certificado"
                    err.mensaje = "El certificado ya existe en la BD."
                    err.mostrar_error()
                End If
            End If
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al Guardar Certificado"
            err.mensaje = "El certificado ya está asociado."
            err.mostrar_error()
        End Try

        err.salida_tipo = "adjunto"
        err.response()
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
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()

        var idcert
        var id_carpeta

        function window_onload() {

            idcert = nvFW.pageContents.idcert
            id_carpeta = nvFW.pageContents.id_carpeta

            $('id_carpeta').value = id_carpeta
            $('idcert').value = idcert

            $('nombre_entidad').value = nvFW.pageContents.nombre_entidad
            $('nro_entidad').value = nvFW.pageContents.nro_entidad

            certificado_nuevo()
            cargarTablaCertificados()

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
            $('div_cert').innerHTML = ""
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('BODY')[0].getHeight()
                var cabe_height = $('divCabe').getHeight()
                var div_tabla_certificados = $('div_tabla_certificados').getHeight()
                $('div_cert').setStyle({ height: body_height - cabe_height - dif - div_tabla_certificados })
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
        var archivoSeleccionado = true;
        function onclick_guardar() {
            if ($('graba_cert').value == 1) {
                archivoSeleccionado = true
                if ($('file').value == '') {
                    archivoSeleccionado = false;
                    guardar();
                    return;
                }

                var strerror = validar_extension()
                if (strerror != '') {
                    alert(strerror)
                    return
                }
                if (extension == '.pfx') {
                    $('cert_hasPrivateKey').value = true
                    win_private = new Window({
                        className: 'alphacube',
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
            else {
                guardar()
            }

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

            if (archivoSeleccionado) {

                var strMsg = ''
                var idcert = $('idcert').value
                var cert_name = $('cert_name').value
                var cert_hasPrivateKey = $('cert_hasPrivateKey').value
                var cert_exportable = $('cert_exportable').value
                var cert_secure = $('cert_secure').value
                var pwd = $('pwd').value
                var graba_cert = $('graba_cert').value
                var name = $('name').value
                var nro_ent = $('nro_entidad').value

                pki = ''

                carpeta_path = 'Entidades'
                id_carpeta = 'Entidades'

                $('modo').value = 'GUARDAR'

                nvFW.bloqueo_activar($$('body')[0], 'bloqueo')
                formDocs.submit()
                $('file').value = ''
            }
            else {
                eliminarCertificados();
            }
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

        function hiddenIframe_load() {
            try {
                eliminarCertificados();

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
                    eliminarCertificados();
                    $('idcert').value = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/params/idcert'))
                    win.options.userData.respuesta["idcert"] = $('idcert').value
                    win.options.userData.respuesta["numError"] = 0
                    win.close()

                }
            }
            catch (e) { }

        }
        /*
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
        */

        function window_unonload() {
            $('idcert').disabled = false
            win.options.userData = $('idcert').value
            win.close()
        }

        var tabla_certificados
        function cargarTablaCertificados() {
            tabla_certificados = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_certificados.nombreTabla = "tabla_certificados";
            //Agregamos consulta XML
            tabla_certificados.filtroXML = nvFW.pageContents.filtroCargarCertificados
            //tabla_oficina.filtroWhere = filtroWhere;
            tabla_certificados.filtroWhere = "<nro_entidad>" + $('nro_entidad').value + "</nro_entidad>";

            tabla_certificados.cabeceras = ["Nombre Certificado", "Id Certificado"];
            tabla_certificados.camposHide = [{ nombreCampo: "IDPKI" }, { nombreCampo: "carpeta_path" }, { nombreCampo: "id_carpeta"}]

            tabla_certificados.async = true;

            tabla_certificados.editable = false;
            tabla_certificados.mostrarAgregar = false;

            tabla_certificados.campos = [
             {
                 nombreCampo: "cert_name", nro_campo_tipo: 104, width: "70%"
             },
             {
                 nombreCampo: "idcert", nro_campo_tipo: 104
             }
            ];

            tabla_certificados.table_load_html();
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <form name="formDocs" method="post" action="pki_certificados_entidad.aspx" enctype="multipart/form-data" target="iframeCargar" style="width: 100%; height: 100%; overflow: hidden" >

    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none"></iframe>

    <input type="hidden" id='modo' name='modo'/>
    <input type="hidden" id='idcert' name='idcert' />
    <input type="hidden" id='cert_hasPrivateKey' name='cert_hasPrivateKey' value="false" />
    <input type="hidden" id='pwd' name='pwd' value="" />
    <input type="hidden" id='cert_secure' name='cert_secure' value="false" />
    <input type="hidden" id='cert_exportable' name='cert_exportable' value="false" />
    <input type="hidden" id="id_carpeta" name="id_carpeta" />
    <input type="hidden" id="name" name="name" value='' />
    <input type="hidden" id="graba_cert" name="graba_cert" value="1" />
    <input type="hidden" id="carpeta_path" name="graba_cert" value="Entidades" />
    <input type="hidden" id="nro_entidad" name="nro_entidad" value="" />

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
            <div id="div_cert_name">
            <table class="tb1" >
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

    <div id="div_tabla_certificados" style="width: 100%; height: 100%;overflow:hidden">
        <div id="tabla_certificados"  style="width:100%;height:100%;overflow:hidden"></div>
    </div>

    </form>

</body>
</html>
