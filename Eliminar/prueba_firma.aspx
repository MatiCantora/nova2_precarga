<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%

    'Dim oPKI As nvFW.tnvPKI = New nvFW.tnvPKI("PKI Red Mutual 55", True, "D:\certificados\pki_revoked\ca.cer")
    'oPKI.createFolder("trusted_certs", True)
    'oPKI.addCert("trusted_certs", "D:\certificados\pki_revoked\id.cer")
    ''Dim doc1 As nvFW.tnvLegDocument = New nvFW.tnvLegDocument("midoc", "midoc", "application/pdf")
    'Dim cert As System.Security.Cryptography.X509Certificates.X509Certificate2 = New System.Security.Cryptography.X509Certificates.X509Certificate2("D:\certificados\pki_revoked\revoked.cer")
    'Dim SignVerifyStatus As New tnvSignVerifyStatus
    'Dim a = nvFW.nvSignatureVerify.certIsRevoked(SignVerifyStatus, Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cert), oPKI, Now)

    'Dim oPKI As nvFW.tnvPKI = New nvFW.tnvPKI("PKI Red Mutual 55", True, "D:\certificados\pki_hotmail\verysign.crt")
    'oPKI.createFolder("trusted_certs", True)
    'oPKI.addCert("trusted_certs", "D:\certificados\pki_hotmail\symantec.crt")
    ''Dim doc1 As nvFW.tnvLegDocument = New nvFW.tnvLegDocument("midoc", "midoc", "application/pdf")
    'Dim cert As System.Security.Cryptography.X509Certificates.X509Certificate2 = New System.Security.Cryptography.X509Certificates.X509Certificate2("D:\certificados\pki_hotmail\hotmail.cer")
    'Dim SignVerifyStatus As New tnvSignVerifyStatus
    'Dim a = nvFW.nvSignatureVerify.certIsRevoked(SignVerifyStatus, Org.BouncyCastle.Security.DotNetUtilities.FromX509Certificate(cert), oPKI, Now)


    Dim action As String = obtenerValor("action", "")
    If action = "firma" Then
        Dim PDF_bytes() As Byte
        If Request.Files.Count > 0 Then
            ReDim PDF_bytes(Request.Files(0).InputStream.Length - 1)
            Request.Files(0).InputStream.Read(PDF_bytes, 0, PDF_bytes.Length)
        End If
        Dim PKI_trustedRoot As Boolean = obtenerValor("PKI_trustedRoot", "") = "on"
        Dim PKI_includeIntermedia As Boolean = obtenerValor("PKI_includeIntermedia", "") = "on"
        Dim PKI_trustedIntermedia As Boolean = obtenerValor("PKI_trustedIntermedia", "") = "on"
        Dim PKI_includeMy As Boolean = obtenerValor("PKI_includeMy", "") = "on"
        Dim PKI_includeOtherFolder As Boolean = obtenerValor("PKI_includeOtherFolder", "") = "on"

        Dim PKI As New tnvPKI("FDRA", PKI_trustedRoot, "D:\Dropbox\Certificados\ca.crt")
        If PKI_includeIntermedia Then
            PKI.createFolder("intermedias", trusted:=PKI_trustedIntermedia, isMy:=False)
            'agregar autoridad intermedia
            PKI.addCert("intermedias", filePath:="D:\Dropbox\Certificados\ACTrainSolutions.crt")
        End If

        If PKI_includeMy Then
            PKI.createFolder("my", trusted:=False, isMy:=True)
            PKI.addCert("my", filePath:="D:\Dropbox\Certificados\Personal\TrainSolutions\0b9c58f31010f178e99674cb91304df2.cer")
        End If

        If PKI_includeOtherFolder Then
            PKI.createFolder("otros", trusted:=False, isMy:=False)
            PKI.addCert("otros", filePath:="D:\Dropbox\Certificados\Personal\TrainSolutions\0b9c58f31010f178e99674cb91304df2.cer")
        End If
        'Stop
        'Dim parser As New Org.BouncyCastle.X509.X509CertificateParser
        'Dim fs2 As New System.IO.FileStream("D:\Dropbox\Certificados\Personal\TrainSolutions\0b9c58f31010f178e99674cb91304df2.cer", IO.FileMode.Open)
        'Dim cert As Org.BouncyCastle.X509.X509Certificate = parser.ReadCertificate(fs2)
        'fs2.Close()
        'Dim includeRoot As Boolean
        'Dim listElements As List(Of Org.BouncyCastle.X509.X509Certificate) = PKI.getChainElement(cert, includeRoot)


        Dim doc As New tnvLegDocument("doc1", "doc1.pdf")
        doc.load(PDF_bytes)
        Dim oSign As New tnvSignature(doc)
        oSign.PKI = PKI
        oSign.name = "firma1"
        oSign.use = nvSignUse.user_sign

        'Revocación
        oSign.includeRevocationInfo = obtenerValor("includeRevocationInfo", 0)

        'TSA
        oSign.use_timestamp_server = obtenerValor("use_timestamp_server") = "on"
        oSign.TSA_URL = obtenerValor("TSA_URL", "")
        oSign.TSA_hash_algorithm = obtenerValor("TSA_hash_algorithm", "SHA-256")

        oSign.PDFSignParams = New tnvPDFSignParam
        With oSign.PDFSignParams

            .appendToExistingOnes = obtenerValor("appendToExistingOnes") = "on"
            .certificationLevel = obtenerValor("certificationLevel")
            .cryptoStandard = obtenerValor("cryptoStandard")
            .hashAlgorithm = obtenerValor("hashAlgorithm")

            .fieldname = obtenerValor("fieldname")
            .visible_signature = True

            .display = obtenerValor("display")


            .reason = obtenerValor("reason")
            .Location = obtenerValor("Location")


            'Posición de la firma
            .page = obtenerValor("page")
            .x1 = obtenerValor("x1")
            .x2 = obtenerValor("x2")
            .y1 = obtenerValor("y1")
            .y2 = obtenerValor("y2")
        End With

        oSign.signDate = Now

        Dim objCert As New System.Security.Cryptography.X509Certificates.X509Certificate2
        Dim KeyStorageFlags As System.Security.Cryptography.X509Certificates.X509KeyStorageFlags = System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.MachineKeySet
        Dim PWD As String = "phantom99"
        Dim path As String = "D:\Dropbox\Certificados\Personal\TrainSolutions\TrainSolutionsJMO2.pfx"
        objCert.Import(path, PWD, KeyStorageFlags)

        Stop
        doc.sign(oSign, objCert)

        Dim verifySignatures As Dictionary(Of String, nvFW.tnvSignVerifyStatus) = doc.verifyFileSignatures(PKI, enumnvRevocationOptions.CRL)
        Dim strXML As String = "<retultado>"
        For Each vs As nvFW.tnvSignVerifyStatus In verifySignatures.Values
            strXML += vs.getStatusmsgXML()
        Next
        strXML += "</retultado>"
        Response.ContentType = "application/xml"
        Response.Write(strXML)
        'Response.End()

        'Response.ContentType = "application/pdf"
        'Response.AddHeader("filename", "archivo_firmado.pdf")
        'Response.BinaryWrite(doc.bytes)
        Dim filename As String
        Dim i As Integer = 0
        Do
            i += 1
            filename = "d:\pdf_firmado" & i & ".pdf"
        Loop While System.IO.File.Exists(filename)

        doc.saveToFile(filename)

        Stop

        Dim readerMain As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(filename)
        readerMain.RemoveUsageRights()
        Dim readerSecond As iTextSharp.text.pdf.PdfReader = New iTextSharp.text.pdf.PdfReader(PDF_bytes)
        readerSecond.RemoveUsageRights()



        Dim outStream As System.IO.FileStream = New System.IO.FileStream("d:\pdf_firmado" & i & "_copy.pdf", IO.FileMode.Create, IO.FileAccess.Write)

        Dim stamp As iTextSharp.text.pdf.PdfStamper = New iTextSharp.text.pdf.PdfStamper(readerSecond, outStream)

        Dim af As iTextSharp.text.pdf.AcroFields = readerMain.AcroFields
        Dim names As List(Of String) = af.GetSignatureNames()
        Dim name As String

        ' Recorrer firmas
        For Each name In names
            Dim pk As iTextSharp.text.pdf.security.PdfPKCS7 = af.VerifySignature(name)
            Dim digesto = pk.GetType().GetField("digest", System.Reflection.BindingFlags.NonPublic Or System.Reflection.BindingFlags.Instance).GetValue(pk)
            Dim dict As iTextSharp.text.pdf.PdfDictionary = af.GetSignatureDictionary(name)
            Dim contents As iTextSharp.text.pdf.PdfString = iTextSharp.text.pdf.PdfReader.GetPdfObject(dict.Get(iTextSharp.text.pdf.PdfName.CONTENTS))

            Dim originalBytes() As Byte = contents.GetOriginalBytes()

            Dim signature As New iTextSharp.text.pdf.security.PdfPKCS7(originalBytes, pk.GetFilterSubtype())


        Next

        Dim fields As IDictionary(Of String, iTextSharp.text.pdf.AcroFields.Item) = readerMain.AcroFields.Fields


        For Each field In fields
            If field.Key = "signature1" Then
                stamp.AcroFields.Fields.Add(field)
            End If
        Next

        stamp.Close()
        outStream.Close()

        'Dim fs As New System.IO.FileStream(filename, IO.FileMode.Create)
        'fs.Write(doc.bytes, 0, doc.bytes.Length)
        'fs.Close()


        Response.End()
    End If
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">
    function validateForm() 
      {
      if ($("file01").value == "")
        {
        alert('No ha seleccionado el archivo a firmar')
        return false
        }
      return true 
      }

    </script>
</head>
<body style="height: 100%; overflow: hidden">
<form name="form1" method="post" target='_blank' action="prueba_firma.aspx" enctype="multipart/form-data"  onsubmit="return validateForm()" >
<input type="hidden"  name='action' value='firma' />
    <table class="tb1">
        <tr class="tbLabel">
            <td colspan="2">
                PKI
            </td>
        </tr>
        <tr>
            <td>
                <input type="checkbox"  name="PKI_trustedRoot" checked="checked" />PKI Incluir root en confianza
            </td>
            <td>
                <input type="checkbox" name="PKI_includeIntermedia" checked="checked" />PKI Incluir intermedia -
                <input type="checkbox" name="PKI_trustedIntermedia" checked="checked" />En confianza
            </td>
            </tr>
            <tr>
            <td>
                <input type="checkbox" name="PKI_includeMy" checked="checked" />PKI Incluir my
            </td>
            <td>
                <input type="checkbox" name="PKI_includeOtherFolder" />PKI Incluir otro folder
            </td>
        </tr>
    </table>

<table class="tb1">
    <tr class="tbLabel">
        <td colspan="2">
            Parámetros generales
        </td>
    </tr>
    <tr>
        <td>
            Incluir CRL:
            <select name='includeRevocationInfo'>
                <option value='0'>No incluir</option>
                <option value='1'>Incluir CRL</option>
                <option value='2'>Inluir OCSP</option>
                <option value='3' selected="selected">Incluir OCSP opcional CRL</option>
            </select>
        </td>
    </tr>
    <tr>
        <td>
            <input type="checkbox" name='use_timestamp_server' /> Incluir sello de tiempo
         - URL TSA: <input type='text' name='TSA_URL'  style='width: 300px' value='http://dse200.ncipher.com/TSS/HttpTspServer' /></td>
    </tr>
</table>

<table class="tb1">
    <tr class="tbLabel">
        <td colspan="5">
            Parámetros PDF
        </td>
    </tr>
    <tr>
        <td>
            Nombre de la firma: <input type="text" name="fieldname" value="signature1" />
        </td>
        <td>
            <input type="checkbox" name="appendToExistingOnes" checked="checked" />
            Aplicar a otras firmas existentes
        </td>
        <td>
            Nivel de certificación
            <select name="certificationLevel">
                <option value="0" selected="selected">not_certified</option>
                <option value="1">not_change_allowed</option>
                <option value="2">form_filling_allowed</option>
                <option value="3">form_filling_and_anotation_allowed</option>
                
            </select>
        </td>
        <td>
            Estandard
            <select name="cryptoStandard">
                <option value="1" selected="selected">CADES</option>
                <option value="0">CMS</option>
            </select>
        </td>
         <td>
            Algoritmo de hash
            <select name="hashAlgorithm">
                <option value="0" selected="selected">SHA1</option>
                <option value="1">SHA256</option>
                <option value="2">SHA384</option>
                <option value="3">SHA512</option>
                <option value="4">RIPEMD160</option>
            </select>
        </td>
    </tr>
    <tr class="tbLabel">
        <td colspan="5">
            Visausalización
        </td>
    </tr>
    <tr><td>Mostrar <select name="display">
                <option value="0">Solo descripción</option>
                <option value="1" selected="selected">Nombre y descripción</option>
                <option value="2">Imagen y descripción</option>
                <option value="3">Solo imagen</option>
            </select></td><td>Página <input  type="number" name='page' value='1' style='width:50px' /></td>
    </tr>
    <tr><td>Motivo <input type="text" name="reason" style="width: 300px" value="Acepto condiciones"/></td><td>X1 <input type="number" name='x1' value='0' style='width:60px; text-align:right' /> - Y1 <input  type="number" name='y1' value='0'  style='width:60px; text-align:right' /></td></tr>
    <tr><td>Ubicación <input type="text" name="location" style="width: 300px" value='Santa Fe' /></td><td>X2 <input type="number" name='x2' value='100'  style='width:60px; text-align:right' /> - Y2 <input  type="number" name='y2' value='100'  style='width:60px; text-align:right' /></td></tr>
   
</table>
<table class='tb1'>
    <tr>
        <td>
            <input type="file" name='file01' id="file01" style='width: 100%' />
        </td>
    </tr>
</table>
    
    <table class='tb1'>
    <tr><td><input type="submit" value="FIRMAR" style='font-size: 16px' /></td></tr></table>
    </form>
    <iframe name='iframe01' style='width:100%; height:200px; border: 1px solid blue'></iframe>
</body>
</html>
