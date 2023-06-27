Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Namespace nvFW
    <Serializable()>
    Public Class tnvPDFSignParam

        ''' <summary>
        ''' Tiene que ser unico para cada firma del documento. Si es vacio o nothing asigna un nombre nuevo automaticamente "Signature1", "Signature2", "SignatureN"
        ''' </summary>
        ''' <remarks></remarks>
        Public fieldname As String = ""


        ''' <summary>
        ''' Determina cual es el nivel de certificacion de la firma en función del uso de la misma
        ''' </summary>
        ''' <remarks> 
        ''' not_certified = 0 'NOT_CERTIFIED— creates an ordinary signature aka an approval or a recipient signature. A document can be signed for approval by one or more recipients.
        ''' not_change_allowed = 1 'CERTIFIED_NO_CHANGES_ALLOWED— creates a certification signature aka an author signature. After the signature is applied, no changes to the document will be allowed.
        ''' form_filling_allowed = 2 'CERTIFIED_FORM_FILLING— creates a certification signature for the author of the document. Other people can still fill out form fields or add approval signatures without invalidating the signature.
        ''' form_filling_and_anotation_allowed = 3 'CERTIFIED_FORM_FILLING_AND_ANNOTATIONS— creates a certification signature. Other people can still fill out form fields- or add approval signatures as well as annotations without invalidating the signature.
        ''' </remarks>
        Public certificationLevel As nvPDFCertificationLevel = nvPDFCertificationLevel.not_certified


        ''' <summary>
        ''' Indica si se debe anexar la firma a las ya existentes
        ''' </summary>
        ''' <remarks></remarks>
        Public appendToExistingOnes As Boolean = False

        ''' <summary>
        ''' Identifica cuales son los componentes a mostrar de la firma
        ''' </summary>
        ''' <remarks>
        '''  description_only = 0
        '''  signaturename_and_description = 1
        '''  image_and_description = 2
        '''  image_only = 3
        '''</remarks>
        Public display As nvPDFSingDisplay = nvPDFSingDisplay.image_and_description


        ''' <summary>
        ''' Define el texto de la firma. Tener en cuenta que este campo anula el uso de los componentes individuales de la misma (razon, localidad, etc)
        ''' </summary>
        ''' <remarks></remarks>
        Public signature_text As String = ""

        Public reason As String = "" 'Motivo de la firma
        Public Location As String = "" 'Lugar de firma
        Public LocationCaption As String = "Localidad: " 'Etiqueta que precede a la locacion
        Public ReasonCaption As String = "Motivo: " 'Etiqueta que precede al motivo
        Public contact As String = "" '???
        Public SignatureCreator As String = "" 'Identifica al software que realiza la firma
        Public status_text As String = "" '???

        'Identifica la fuente de la firma
        Public signature_text_fontSize As Double = 0
        Public signature_text_fontFamily As iTextSharp.text.Font.FontFamily = iTextSharp.text.Font.FontFamily.UNDEFINED
        Public signature_text_fontstyle As Integer = iTextSharp.text.Font.NORMAL 'iTextSharp.text.Font.BOLD, iTextSharp.text.Font.ITALIC, iTextSharp.text.Font.STRIKETHRU, iTextSharp.text.Font.UNDERLINE

        'Public signature_text_fontColor As iTextSharp.text.BaseColor = Nothing
        Public signature_text_fontColor As nvPDFSignFontColor = New nvPDFSignFontColor


        'Imagenes de la firma
        Public image_path As String = "" 'Imagen que se coloca al lado de la firma
        Public backgroundimage_path As String = ""
        Public backgroundimage_scale As Single = -1.0

        'Determina el algoritmo de hash a utilizar
        Public hashAlgorithm As nvHashAlgorithm = nvHashAlgorithm.SHA1
        Public cryptoStandard As nvPDFCryptoStandard = nvPDFCryptoStandard.CMS

        ' Tamaño estimado de la firma
        Public estimatedSize As Long = 0

        'Determina si la firma es visible y su posicion
        Public visible_signature As Boolean = True
        Public page As Integer = 1
        Public x1 As Single = 1
        Public y1 As Single = 1
        Public x2 As Single = 100
        Public y2 As Single = 100

        Public AcrobatLayer6Mode As Boolean = True

        ''Si utiliza sellos de tiempo
        'Public use_timestamp_server As Boolean = False
        'Public TSA_URL As String
        'Public TSA_authentication As String
        'Public TSA_police As String
        'Public TSA_hash_algorithm As String

        'Public enable_OSCP As Boolean
        'Public default_OCSP_server As String

        'Public enable_CRL As Boolean

    End Class

    Public Enum nvPDFSingDisplay 'iTextSharp.text.pdf.PdfSignatureAppearance.RenderingMode
        description_only = 0
        signaturename_and_description = 1
        image_and_description = 2
        image_only = 3
    End Enum
    Public Enum nvPDFEncryption
        not_encrypted = 0
        passwords = 1
        certificate = 2
    End Enum
    Public Enum nvPDFCertificationLevel
        not_certified = 0 'NOT_CERTIFIED— creates an ordinary signature aka an approval or a recipient signature. A document can be signed for approval by one or more recipients.
        not_change_allowed = 1 'CERTIFIED_NO_CHANGES_ALLOWED— creates a certification signature aka an author signature. After the signature is applied, no changes to the document will be allowed.
        form_filling_allowed = 2 'CERTIFIED_FORM_FILLING— creates a certification signature for the author of the document. Other people can still fill out form fields or add approval signatures without invalidating the signature.
        form_filling_and_anotation_allowed = 3 'CERTIFIED_FORM_FILLING_AND_ANNOTATIONS— creates a certification signature. Other people can still fill out form fields- or add approval signatures as well as annotations without invalidating the signature.
    End Enum

    Public Enum nvPDFCryptoStandard
        CMS = 0
        CADES = 1
    End Enum


    <Serializable()>
    Public Class nvPDFSignFontColor


        Private r As Integer = 0
        Private g As Integer = 0
        Private b As Integer = 0


        Public Sub setColor(color As String)

            Select Case color
                Case "BLACK", "0"
                    r = 0
                    g = 0
                    b = 0
                Case "WHITE", "1"
                    r = 255
                    g = 255
                    b = 255
                Case "GRAY", "2"
                    r = 128
                    g = 128
                    b = 128
                Case "RED", "3"
                    r = 255
                    g = 0
                    b = 0
                Case "PINK", "4"
                    r = 255
                    g = 175
                    b = 175
                Case "ORANGE", "5"
                    r = 255
                    g = 200
                    b = 0
                Case "YELLOW", "6"
                    r = 255
                    g = 255
                    b = 0
                Case "GREEN", "7"
                    r = 0
                    g = 255
                    b = 0
                Case "MAGENTA", "8"
                    r = 255
                    g = 0
                    b = 255
                Case "CYAN", "9"
                    r = 0
                    g = 255
                    b = 255
                Case "BLUE", "10"
                    r = 0
                    g = 0
                    b = 255
                Case "LIGHT_GRAY", "11"
                    r = 192
                    g = 192
                    b = 192
                Case "DARK_GRAY", "12"
                    r = 64
                    g = 64
                    b = 64
            End Select
        End Sub

        Public Sub setColor(r As Integer, g As Integer, b As Integer)
            Me.r = r
            Me.g = g
            Me.b = b
        End Sub


        Public Function getColor() As iTextSharp.text.BaseColor
            Return New iTextSharp.text.BaseColor(r, g, b)
        End Function

    End Class

End Namespace