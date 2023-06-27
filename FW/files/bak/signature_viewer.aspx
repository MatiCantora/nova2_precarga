<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>

<%
    
    Dim f_id As String = nvFW.nvUtiles.obtenerValor("f_id", "")
    Dim pki As String = nvFW.nvUtiles.obtenerValor("pki", "")
    Dim signatureName As String = nvFW.nvUtiles.obtenerValor("signatureName", "")


    Dim paramas As New Dictionary(Of String, Object)
    paramas.Add("f_id", f_id)
    Dim cElemnt As nvFW.nvCacheElement = nvFW.nvCache.getCache("FileSignValidations", paramas)

    If cElemnt Is Nothing Then
        Dim err = New nvFW.tError
        err.numError = -1
        err.mensaje = "Debe revalidar las firmas del documento para poder acceder a la información de sus certificados."
        err.response()
    End If

    Dim sigVal As nvFW.nvPKIDBUtil.tnvFileSignatureValidation = cElemnt.Valores("FileSignatureValidation")
    Dim signatureStatus As nvFW.tnvSignVerifyStatus = sigVal.signaturesStatus(signatureName)(pki)

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo = "" Then

        Dim SignatureInfo As New trsParam
        SignatureInfo.Add("contact", signatureStatus.contact)
        SignatureInfo.Add("IncludeCRLs", signatureStatus.IncludeCRLs)
        SignatureInfo.Add("IncludeOCSPResponse", signatureStatus.IncludeOCSPResponse)
        SignatureInfo.Add("isKnownCertificate", signatureStatus.isKnownCertificate)
        SignatureInfo.Add("isLTV", signatureStatus.isLTV)
        SignatureInfo.Add("isMyCertificate", signatureStatus.isMyCertificate)
        SignatureInfo.Add("isRevoked", signatureStatus.isRevoked)
        SignatureInfo.Add("location", signatureStatus.location)
        SignatureInfo.Add("pkiName", signatureStatus.pkiName)
        SignatureInfo.Add("reason", signatureStatus.reason)
        SignatureInfo.Add("SignDate", signatureStatus.SignDate)
        SignatureInfo.Add("trusedCertificate", signatureStatus.trusedCertificate)
        SignatureInfo.Add("trustedChain", signatureStatus.trustedChain)
        SignatureInfo.Add("useTimestam", signatureStatus.useTimestam)
        SignatureInfo.Add("validSignatureDate", signatureStatus.validSignatureDate)

        Dim certificates As New trsParam

       
        Dim nCerts As Integer = 1
        
        ' cadena construida a partir de la pki, puede ser parcial (untrusted), o completa (trusted)
        nCerts = signatureStatus.chain.Count
        Dim strTrusted As String = "false"
        If signatureStatus.trustedChain Then
            strTrusted = "true"
        End If
        
        Dim resp As String = "<?xml version='1.0'?><SignatureInfo><Certificates trustedchain='" + strTrusted + "'>"

        For i As Integer = 0 To nCerts - 1
            Dim cert As X509Certificate2 = New X509Certificate2(Org.BouncyCastle.Security.DotNetUtilities.ToX509Certificate(signatureStatus.chain(i)))
            Dim certificate As New trsParam
            certificate.Add("Subject", cert.Subject)
            certificate.Add("SubjectName", cert.SubjectName.ToString)
            certificates.Add(i, certificate)


            resp += "<Certificate>"


            ' Resumen
            Dim cert_cn As String = cert.GetNameInfo(X509NameType.SimpleName, False)
            Dim cert_issuer As String = cert.GetNameInfo(X509NameType.SimpleName, True)
            Dim cert_notAfter As String = cert.NotAfter
            Dim cert_notBefore As String = cert.NotBefore


            resp += "<Resumen>"
            resp += "<campo name='Subject' value='" & cert_cn & "'/>"
            resp += "<campo name='Emisor' value='" & cert_issuer & "'/>"
            resp += "<campo name='Válido desde' value='" & cert_notBefore & "'/>"
            resp += "<campo name='Válido hasta' value='" & cert_notAfter & "'/>"

            For Each ext In cert.Extensions
                If ext.Oid.Value = "2.5.29.15" Or ext.Oid.Value = "2.5.29.37" Then
                    Dim asndata As New System.Security.Cryptography.AsnEncodedData(ext.Oid, ext.RawData)
                    resp += "<campo name='" & ext.Oid.FriendlyName & "' value='" & asndata.Format(True) & "'/>"
                End If

            Next
            resp += "</Resumen>"

            ' Detalles
            resp += "<Detalles>"
            resp += "<campo name='Version' value='" & cert.Version & "'/>"
            resp += "<campo name='Algoritmo de firma' value='" & cert.SignatureAlgorithm.FriendlyName & "'/>"
            resp += "<campo name='Subject' value='" & cert.Subject & "'/>"
            resp += "<campo name='Emisor' value='" & cert.Issuer & "'/>"
            resp += "<campo name='Serial Number' value='" & cert.SerialNumber & "'/>"
            resp += "<campo name='Válido desde' value='" & cert_notBefore & "'/>"
            resp += "<campo name='Válido hasta' value='" & cert_notAfter & "'/>"

            For Each ext In cert.Extensions
                Dim asndata As New System.Security.Cryptography.AsnEncodedData(ext.Oid, ext.RawData)
                Dim name As String = ext.Oid.FriendlyName
                resp += "<campo name='" & name & "' value='" & asndata.Format(True) & "'/>"
            Next

            resp += "<campo name='Clave Pública' value='" & BitConverter.ToString(cert.PublicKey.EncodedKeyValue.RawData) & "'/>"
            'resp += "<PublicKey_sha1>" & &"</PublicKey_sha1>"
            resp += "<campo name='X509 Data' value='" & BitConverter.ToString(cert.RawData) & "'/>"
            resp += "<campo name='X509 Digesto SHA1' value='" & cert.GetCertHashString & "'/>"

            resp += "</Detalles>"
            resp += "</Certificate>"
        Next
        resp += "</Certificates>"


        Dim message As String = ""
        If signatureStatus.IncludeCRLs Then
            If signatureStatus.CRLs.Count > 0 Then
                message = "La firma tiene incrustada las CRLs de la cadena de certificados."
            Else
                message = "La firma tiene incrustada la CRL del certificado firmante."
            End If
        Else
            message = "La firma no incluye listas de revocación."
        End If
        resp &= "<Revocation isRevoked='" & signatureStatus.isRevoked & "'>"
        resp &= "<CRL message='" & message & "'>"
        For Each crl In signatureStatus.CRLs
            resp &= "<CRLInfo issuer='" & crl.IssuerDN.ToString() & "' nextUpdate='" & crl.NextUpdate.ToString & "' thisUpdate='" & crl.ThisUpdate.ToString & "'/>"
        Next
        resp &= "</CRL>"

        If signatureStatus.IncludeOCSPResponse Then
            Dim version As String = signatureStatus.OSCPResponse.Version
            Dim issuer As String = Org.BouncyCastle.X509.PrincipalUtilities.GetSubjectX509Principal(signatureStatus.OSCPResponse.GetCerts(0)).GetValues(Org.BouncyCastle.Asn1.X509.X509Name.CN)(0)
            Dim NextUpdate As String = signatureStatus.OSCPResponse.Responses(0).NextUpdate.ToString
            Dim ThisUpdate As String = signatureStatus.OSCPResponse.Responses(0).ThisUpdate.ToString
            message = "La firma tiene incrustada la respuesta OCSP para comprobar revocación del certificado firmante."
            resp &= "<OCSP message='" & message & "' version='" & version & "' issuer='" & issuer & "' nextUpdate='" & NextUpdate & "' thisUpdate='" & ThisUpdate & "'/>"
        Else
            resp &= "<OCSP message='La firma no incluye respuestas OCSP para revocación del certificado firmante.'/>"
        End If

        message = ""
        If signatureStatus.isLTV Then
            message = "La firma está activada para LTV"
        Else
            message = "La firma no está activada para LTV"
        End If
        resp &= "<LTV message='" & message & "'/>"
        resp &= "</Revocation>"
        resp &= "</SignatureInfo>"



        Me.contents("resp") = resp
        Me.contents("f_id") = f_id
        Me.contents("signatureName") = signatureName
        Me.contents("pki") = pki
        SignatureInfo.Add("certificates", certificates)
        Me.contents("SignatureInfo") = SignatureInfo

    End If




    If modo = "download_cert" Then
        Dim index As Integer = nvFW.nvUtiles.obtenerValor("index", 0)
        Dim fileName As String = signatureStatus.chain(index).SerialNumber.ToString & ".crt"
        Response.ContentType = "application/octet-stream"
        Response.AddHeader("Content-Disposition", "attachment;filename=" & fileName)
        Response.BinaryWrite(signatureStatus.chain(index).GetEncoded())
        Response.End()
    End If


    If modo = "download_crl" Then
        Dim crl_id As Integer = nvFW.nvUtiles.obtenerValor("crl_id")
        Dim fileName As String = signatureStatus.chain(crl_id).SerialNumber.ToString & ".crl"
        Response.ContentType = "application/octet-stream"
        Response.AddHeader("Content-Disposition", "attachment;filename=" & fileName)
        Response.BinaryWrite(signatureStatus.CRLs(crl_id).GetEncoded())
        Response.End()
    End If




%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Visor de Firmas Digital</title>
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

        var f_id = nvFW.pageContents.f_id
        var signatureName = nvFW.pageContents.signatureName
        var pki = nvFW.pageContents.pki
        var objXML
        var index = 0

        function window_onload() {
            
            objXML = new tXML()

            try {
                objXML.loadXML(nvFW.pageContents.resp)
            } catch (e) {
                return
            }

            showCertTree()
            showResumen(index)

            window_onresize()
        }



        function selectCert(idCert) {

            // la info de revocacion solo esta disponible para el cert firmante
            if (idCert == 0) {
                $('viewRevocacion').style.display = "inline"
            } else {
                $('viewRevocacion').style.display = "none"
            }

            // resaltar nodo del certificado elegido
            var nodes = window.event.srcElement.parentNode.childNodes
            for (var i = 0; i < nodes.length; i++) {
                nodes[i].style.background = "white"
            }
            window.event.srcElement.style.background = "lightGrey"

            // actualizar el indice que indica de que certificado se esta viendo info
            index = idCert

            // ir al panel "resumen"
            changeView(0)
        }


        function showCertTree() {
        
            var certs = objXML.selectNodes("SignatureInfo/Certificates/Certificate")

            var strHTML = ""
            for (var i = 0; i < certs.length; i++) {

                strHTML = "<li style='cursor:pointer' onclick='selectCert(" + i + ")'>" + selectNodes("Resumen/campo[@name='Subject']", certs[i])[0].getAttribute("value") + "</li>" + strHTML
            }
            strHTML = "<span>Certificados</span><ul>" + strHTML + "</ul>"

            $('divChain').innerHTML += strHTML


        }


        function showResumen(index) {

            var cert = objXML.selectNodes("SignatureInfo/Certificates/Certificate")[index]

            var campos = selectNodes("Resumen/campo", cert)

            var strHTML = "<table class='tb1'>"
            strHTML += "<tr class='tbLabel'><td>" + campos[0].getAttribute("value") + "</td></tr>"
            strHTML += "</table>"

            strHTML += "<table class='tb1'>"
            for (var i = 1; i < campos.length; i++) {
                strHTML += "<tr><td class='tit1'>" + campos[i].getAttribute("name") + "</td><td>" + campos[i].getAttribute("value") + "</td></tr>"
            }
            strHTML += "</table>"

            strHTML += "<input type='button' onclick='downloadCert(" + index + ")' value='Descargar Certificado'/>"


            $('divResumen').innerHTML = strHTML

        }





        function showDetalle(index) {

            var cert = objXML.selectNodes("SignatureInfo/Certificates/Certificate")[index]
            var campos = selectNodes("Detalles/campo", cert)
            strHTML = "<table class='tb1'>"
            for (var i = 0; i < campos.length; i++) {
               strHTML += "<tr><td class='tit1'>" + campos[i].getAttribute("name") + "</td><td>" + campos[i].getAttribute("value") + "</td></tr>"
           }
           strHTML += "</table>"

            $('divDetalle').innerHTML = strHTML

        }




        function showRevocacion(index) {
            
            // la info de revocacion unicamente para el certificado firmante
            if (index == 0) {

                var strHTML = ""
                var revoCationInfo = objXML.selectNodes("SignatureInfo/Revocation")[0]
                var isRevoked = revoCationInfo.getAttribute("isRevoked")
                var msg = ""
                if (isRevoked) {
                    msg = " El certificado está revocado."
                } else {
                    msg = " El certificado es válido."
                }

                strHTML += "<table class='tb1'>"
                strHTML += "<tr class='tbLabel'><td>" + msg + "</td></tr>"
                strHTML += "</table>"

                var CRLNod = selectNodes("CRL", revoCationInfo)[0]
                var CRLInfoNods = selectNodes("CRLInfo", CRLNod)

                strHTML += "<br/>"
                strHTML += "<table class='tb1'>"
                strHTML += "<tr><td class='tit1'>CRL</td><td>" + CRLNod.getAttribute("message") + "</td></tr>"
                strHTML += "</table>"

                if (CRLInfoNods.length > 0) {

                    strHTML += "<table class='tb1'>"
                    strHTML += "<tr><td class='tit1' colspan='5'>Info de CRLs</td></tr>"
                    strHTML += "<tr><td class='tit1'>id</td><td class='tit1'>Issuer</td><td class='tit1'>ThisUpdate</td><td class='tit1'>NextUpdate</td><td></td></tr>"
                    for (var i = 0; i < CRLInfoNods.length; i++) {
                        strHTML += "<tr><td>" + i + "</td><td>" + CRLInfoNods[i].getAttribute("issuer") + "</td><td>" + CRLInfoNods[i].getAttribute("thisUpdate") + "</td><td>" + CRLInfoNods[i].getAttribute("nextUpdate") + "</td><td><input value='Descargar CRL' type='button' onclick='downloadCRL(" + i + ")'></td></tr>"
                    }
                    strHTML += "</table>"
                }

                var ocspNod = selectNodes("OCSP", revoCationInfo)[0]

                strHTML += "<br/>"
                strHTML += "<table class='tb1'>"
                strHTML += "<tr><td class='tit1'>OCSP</td><td>" + ocspNod.getAttribute("message") + "</td></tr>"
                strHTML += "</table>"

                if (ocspNod.getAttribute("issuer")) { // si tiene ocsp
                    strHTML += "<table class='tb1'>"
                    strHTML += "<tr><td class='tit1' colspan='5'>Info de OCSP</td></tr>"
                    strHTML += "<tr><td class='tit1'>Issuer</td><td class='tit1'>ThisUpdate</td><td class='tit1'>NextUpdate</td></tr>"
                    strHTML += "<tr><td>" + ocspNod.getAttribute("issuer") + "</td><td>" + ocspNod.getAttribute("thisUpdate") + "</td><td>" + ocspNod.getAttribute("nextUpdate") + "</td></tr>"
                    strHTML += "</table>"
                }

                var ltvNod = selectNodes("LTV", revoCationInfo)[0]
                strHTML += "<br/>"
                strHTML += "<table class='tb1'>"
                strHTML += "<tr><td class='tit1'>LTV</td><td>" + ltvNod.getAttribute("message") + "</td></tr>"
                strHTML += "</table>"

                $('divRevocacion').innerHTML = strHTML

            }
            
        }




        function changeView(val) {

            if (val == 0) {

                $('divResumen').style.display = "inline"
                $('divDetalle').style.display = "none"
                $('divRevocacion').style.display = "none"

                showResumen(index)


            } else if (val == 1) {

                $('divResumen').style.display = "none"
                $('divDetalle').style.display = "inline"
                $('divRevocacion').style.display = "none"

                showDetalle(index)

            } else if (val == 2) {

                $('divResumen').style.display = "none"
                $('divDetalle').style.display = "none"
                $('divRevocacion').style.display = "inline"

                showRevocacion(index)
            }

        }



        function downloadCert(index) {

            $('iframeDownloadCert').src = 'signature_viewer.aspx?modo=download_cert&f_id=' + f_id + '&signatureName=' + encodeURIComponent(signatureName) + "&pki=" + pki + "&index=" + index
        }

        function downloadCRL(crl_id) {

            $('iframeDownloadCert').src = 'signature_viewer.aspx?modo=download_crl&f_id=' + f_id + '&signatureName=' + encodeURIComponent(signatureName) + "&pki=" + pki + "&crl_id=" + crl_id
        }


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                dif += 25 // por el height de los botones en la parte superior

                var body_height = $$('body')[0].getHeight()

                try {
                    $('divResumen').setStyle({ height: body_height - dif + 'px', overflow: 'auto' })
                } catch (e) {
                }
                try {
                    $('divDetalle').setStyle({ height: body_height - dif + 'px', overflow: 'auto' })
                } catch (e) {
                }
                try {
                    $('divChain').setStyle({ height: body_height - dif + 'px', overflow: 'auto' })
                } catch (e) {
                }

            }
            catch (e) { }
        }



    </script>

</head>

<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%;overflow: hidden">

    <input id="viewResumen" type="button" style="cursor:pointer;border:none;display: inline-block;height:25px;" onclick="changeView(0)" value="Resumen"/>
    <input id="viewDetalle" type="button" style="cursor:pointer;border:none;display: inline-block;height:25px;" onclick="changeView(1)" value="Detalle"/>
    <input id="viewRevocacion" type="button" style="cursor:pointer;border:none;display: inline-block;height:25px;" onclick="changeView(2)" value="Revocación"/>


    <div style="width:20%;height:100%;float:left;background-color:white" id="divChain"></div>


    <div style="width:80%;float:left" id='divResumen'></div>


     <div style="width:80%;float:left" id='divDetalle'></div>


     <div style="width:80%;float:left" id='divRevocacion'></div>


     <iframe id='iframeDownloadCert' style="display:none"></iframe>

</body>
</html>








