<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>

<%
    Dim f_id As String = nvFW.nvUtiles.obtenerValor("f_id", "")
    Dim ref_files_path = nvFW.nvUtiles.obtenerValor("ref_files_path", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim force_validation As Boolean = nvFW.nvUtiles.obtenerValor("force_validation", False)

    Me.contents("f_id") = f_id

    'Dim arpkis As Dictionary(Of String, tnvPKI) = nvApp.PKIs

    Dim sigVal As nvFW.nvPKIDBUtil.tnvFileSignatureValidation

    If modo = "getSignatures" Then
    
        Dim err As New nvFW.tError()

        'Dim sigVal As New nvFW.PKINovaDBUtil.tnvFileSignatureValidation

        Dim file As nvFile.tnvFile = nvFile.getFile(f_id:=f_id, ref_files_path:=ref_files_path)
        If file Is Nothing Then
            err.numError = 10
            err.mensaje = "Archivo no encontrado"
            err.debug_desc = "El archivo con el f_id indicado no existe en la base de datos"
            err.response()
        End If

        If Not file Is Nothing Then
            'TODO: quitar este bloque
            If file.f_ext.ToLower <> "pdf" Then
                err.numError = 0
                err.response()
            End If

            Dim paramas As New Dictionary(Of String, Object)
            paramas.Add("f_id", f_id)
            Dim cElemnt As nvFW.nvCacheElement = nvFW.nvCache.getCache("FileSignValidations", paramas)


            If Not cElemnt Is Nothing And Not force_validation Then
                sigVal = cElemnt.Valores("FileSignatureValidation")
            Else
                '  *********** Cargar documento
                Dim doc As nvFW.tnvLegDocument = New nvFW.tnvLegDocument("foo", file.filename)
                Try
                    doc.load(file.BinaryData)
                Catch ex As Exception
                    err.numError = -1
                    err.mensaje = "No se pudo acceder al archivo."
                    err.debug_desc = ex.Message
                    err.debug_src = ""
                    err.response()
                End Try

                '  *********** Cargar las PKIs que se ha establecido para validar documentos
                'Dim csvPKI As String
                'csvPKI = nvFW.nvUtiles.getParametroValor("pki_validacion_documentos", "")
                'Dim pkis As String() = csvPKI.Split(",".ToCharArray(), StringSplitOptions.RemoveEmptyEntries)

                sigVal = New nvFW.nvPKIDBUtil.tnvFileSignatureValidation
                sigVal.file_id = f_id
                sigVal.validationTime = Now
                For Each pki In nvApp.PKIs.Values
                    'If Not nvFW.PKINovaDBUtil.SharedGlobals.PKIBasics.ContainsKey(nvApp.cod_sistema) Then nvFW.PKINovaDBUtil.SharedGlobals.PKIBasics.Add(nvApp.cod_sistema, New Dictionary(Of String, nvFW.tnvPKI))
                    'Dim oPKI As nvFW.tnvPKI
                    'If Not nvFW.PKINovaDBUtil.SharedGlobals.PKIBasics(nvApp.cod_sistema).ContainsKey(pki) Then
                    'nvFW.PKINovaDBUtil.SharedGlobals.PKIBasics(nvApp.cod_sistema).Add(pki, nvFW.PKINovaDBUtil.LoadPKIFromDB(pki, loadDBOptions:=nvFW.PKINovaDBUtil.nveunmloadDBOptions.loadTrusted))
                    'End If


                    ' Clonar y agregar My 
                    'oPKI = nvFW.PKINovaDBUtil.SharedGlobals.PKIBasics(nvApp.cod_sistema)(pki).clone(nvFW.PKINovaDBUtil.nveunmloadDBOptions.loadTrusted)

                    'Dim rsCert As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("Select * from certificates where PKI = '" & pki & "' and cuil = 'XXXXX'")

                    'oPKI.createFolder("my", False, True)
                    'While Not rsCert.EOF
                    '    'oPKI.addCert()
                    '    rsCert.MoveNext()
                    'End While


                    '  *********** validar firmas del documento
                    Dim signaturesStatus As Dictionary(Of String, nvFW.tnvSignVerifyStatus) = doc.verifyFileSignatures(pki, nvFW.enumnvRevocationOptions.OCSP_FAIL_CRL)

                    
                    For Each signName In signaturesStatus.Keys
                        If Not sigVal.signaturesStatus.ContainsKey(signName) Then sigVal.signaturesStatus.Add(signName, New Dictionary(Of String, nvFW.tnvSignVerifyStatus))
                        sigVal.signaturesStatus(signName).Add(pki.name, signaturesStatus(signName))
                    Next

                Next

                Dim valores As New Dictionary(Of String, Object)
                valores.Add("FileSignatureValidation", sigVal)
                Dim cElement As New nvFW.nvCacheElement("FileSignValidations", paramas, valores, 60)
                nvFW.nvCache.add("FileSignValidations", cElement)
            End If

            ' Estado de las firmas

            Dim respXML As String = ""
            For Each signatureName In sigVal.signaturesStatus.Keys
                Dim PKIEncontrado As Boolean = False
                Dim pkiKey As String = ""
                Dim VerifyStatys As nvFW.tnvSignVerifyStatus = Nothing
                For Each pki In sigVal.signaturesStatus(signatureName).Keys
                    'Dim signPKIName As String = sigVal.signaturesStatus(signatureName)(pki).pkiName
                    Dim max_index As Integer = sigVal.signaturesStatus(signatureName)(pki).chain.Count - 1
                    Dim rootSubjectDN As String = sigVal.signaturesStatus(signatureName)(pki).chain(max_index).SubjectDN.ToString
                    If nvApp.PKIs(pki).rootCert.SubjectDN.ToString = rootSubjectDN Then
                        VerifyStatys = sigVal.signaturesStatus(signatureName)(pki)
                        PKIEncontrado = True
                        pkiKey = pki
                        Exit For
                    End If
                Next
                If Not PKIEncontrado Then
                    pkiKey = sigVal.signaturesStatus(signatureName).Keys(0)
                    VerifyStatys = sigVal.signaturesStatus(signatureName)(pkiKey)
                End If

                Dim subject As String = Org.BouncyCastle.X509.PrincipalUtilities.GetSubjectX509Principal(VerifyStatys.SigningCertificate).GetValues(Org.BouncyCastle.Asn1.X509.X509Name.CN)(0)

                respXML &= "<Signature name='" & signatureName & "' subject='" & subject & "' pki='" & pkiKey & "' pkiName='" & VerifyStatys.pkiName & "' signDate='" & VerifyStatys.SignDate & "'>"
                Dim strStatus As String = VerifyStatys.getStatusmsgXML(includeBin:=False)
                respXML &= strStatus
                respXML &= "</Signature>"

            Next
            respXML = "<Signatures>" & respXML & "</Signatures>"


            err.params.Add("respXML", respXML)
            err.response()


        End If

    End If






%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Firmas del Documento</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% =Me.getHeadInit()%>
    <script type="text/javascript">

        function window_onload() {
            showSignatures()
        }

        var f_id = nvFW.pageContents.f_id
        function showSignatures() {

            nvFW.error_ajax_request('file_signatures.aspx', {
                parameters: {
                    modo: 'getSignatures',
                    f_id: f_id
                },
                onSuccess: function (err) {
                    
                    if (err.numError == 0) {
                        if (err.params["respXML"]) {
                            var respXML = err.params["respXML"]
                            if (respXML != "") {
                                parseOutput(respXML)
                            }
                        }
                    }
                }
            });
        }






        function colapsar(elem) {
            $(elem).toggle()
            if ($(elem).style.display == "none") {
                $(elem + '_img').src = '/fw/image/icons/play.png'
            } else {
                $(elem + '_img').src = '/fw/image/icons/down_a.png'
            }
        }



        function verFirmaDetalle(signatureName, pki) {
            
            //var signatureName = this.attributes.signatureName.value
            var win =
                parent.nvFW.createWindow({ className: 'alphacube',
                    url: 'signature_viewer.aspx?f_id=' + f_id + "&signatureName=" + signatureName + "&pki=" + pki,
                    title: '<b>Visor de Firmas</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    modulo: true,
                    width: 850,
                    height: 450,
                    destroyOnClose: true,
                    onClose: function () {
                    }
                });
            var Parametros = new Array();
            win.options.userData = { retorno: Parametros }
            win.showCenter()
            //win.maximize()
        }


        function parseOutput(respXML) {
            
            var objXML = new tXML()
            objXML.loadXML(respXML)

            var signatures = objXML.selectNodes("Signatures/Signature")
            
            for (var i = 0; i < signatures.length; i++) {

                var strHTML = ""

                var signature = signatures[i]
                var signatureName = signature.getAttribute("name")
                var signDate = signature.getAttribute("signDate")
                var pkiName = signature.getAttribute("pkiName")
                var pki = signature.getAttribute("pki")
                var subject = signature.getAttribute("subject")

                var icon = "/FW/image/icons/ok.png"
                var countWarning = parseInt(getAttribute_path(signature, "SignVerifyStatus/messages/@countWarning", "0"))
                if (countWarning > 0) {
                    icon = "/FW/image/icons/warning.png"
                }

                var messages = selectNodes("SignVerifyStatus/messages/statusmsg", signature)
                var signingCertificate = selectNodes("SignVerifyStatus/signElemets/SigningCertificate", signature)[0]
                var commonName = signingCertificate.getAttribute("SubjectDN")

                strHTML += "<div style='cursor:pointer;'>"
                strHTML += "<table class='tb1'>"
                strHTML += "<tr class='tbLabel'>"
                strHTML += "<td onclick='colapsar(\"elemSig" + i + "\")' style='text-align:left; !important'><img id='elemSig" + i + "_img' src='/fw/image/icons/play.png' />&nbsp;<img style='width:16px; height:16px' src=" + icon + " />&nbsp;&nbsp;Firmado por " + subject + " según " + pkiName + " - Fecha: " + signDate + " (" + signatureName + ")</td>"
                strHTML += "<td onclick='verFirmaDetalle(\"" + signatureName + "\", \"" + pki + "\")' style='width:50px;white-space: nowrap !important;'><div id='btnCert" + i + "' signatureName='" + signatureName + "'><img src='/fw/image/icons/info.png' title='ver detalle firma'/></div></td>"
                strHTML += "</tr>"
                strHTML += "</table>"
                strHTML += "</div>"

                //strHTML += "<div style='display:none' id='elemSig" + i + "'>"
                //strHTML += "<table class='tb1'>"
                //strHTML += "<tr><td>Nombre de la firma:</td><td>" + signatureName + "</td></tr>"
                //strHTML += "<tr><td>Fecha:</td><td>" + signDate + "</td></tr>"
                
                //strHTML += "<table class='tb1'>"
                //for (var j = 0; j < messages.length; j++) {
                //    var statusmsg = messages[j]
                //    var style = ""
                //    if (statusmsg.getAttribute("tipo") == "warning") {
                //        style = "style='color:orange;'"
                //    }
                //    strHTML += "<tr><td><span style='font-size:small'>-&nbsp;</span><span " + style + ">" + statusmsg.getAttribute("msg") + "</span></td></tr>"
                //}
                //strHTML += "</table></div>"


                strHTML += "<div style='display:none' id='elemSig" + i + "'>"
                strHTML += "<table class='tb1'>"
                for (var j = 0; j < messages.length; j++) {
                    var statusmsg = messages[j]
                    var style = ""
                    if (statusmsg.getAttribute("tipo") == "warning") {
                        style = "style='color:orange;'"
                    }
                    strHTML += "<tr><td><span style='font-size:small'>-&nbsp;</span><span " + style + ">" + statusmsg.getAttribute("msg") + "</span></td></tr>"
                }
                strHTML += "</table></div>"

                $('divFirmas').innerHTML += strHTML

            }
        }


        function validarFirmas() {
        
            $('divFirmas').innerHTML = ""
            nvFW.error_ajax_request('file_signatures.aspx', {
                parameters: {
                    modo: 'getSignatures',
                    f_id: f_id,
                    force_validation: "true"
                },
                onSuccess: function (err) {

                    if (err.numError == 0) {
                        if (err.params["respXML"]){
                            var respXML = err.params["respXML"]
                            if (respXML != "") {
                                parseOutput(respXML)
                            }
                        }
                    }
                }
            });

        }



        function window_onresize() {
            try {
                // error de browser en pixels
                var dif = Prototype.Browser.IE ? 5 : 2

                // se tiene en cuenta el height de la cabecera del panel de firmas
                dif += 30 

                var body_height = $$('body')[0].getHeight()
                $('divFirmas').setStyle({ height: body_height - dif + 'px', overflow: 'auto' })
            }
            catch (e) { }
        }


      </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%;
    overflow: hidden">

    
    <div style="width:100%" id="divMenuFirma"></div>
    <script type="text/javascript">

        var vMenuFirma = new tMenu('divMenuFirma', 'vMenuFirma');
        vMenuFirma.loadImage("firma", "/FW/image/icons/signature.png");
        vMenuFirma.loadImage("validar", "/FW/image/icons/periodicidad.png");

        Menus["vMenuFirma"] = vMenuFirma
        Menus["vMenuFirma"].alineacion = 'centro';
        Menus["vMenuFirma"].estilo = '0';

        Menus["vMenuFirma"].CargarMenuItemXML("<MenuItem id='0' style='font-size:small;width: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>firma</icono><Desc>Firmas del Documento</Desc></MenuItem>")
        Menus["vMenuFirma"].CargarMenuItemXML("<MenuItem id='1' style='width: 20%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>validar</icono><Desc>Validar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>validarFirmas()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuFirma.MostrarMenu()
    </script>
    <div id="divFirmas" >
    </div>
</body>
</html>
