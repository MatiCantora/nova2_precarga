<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageAdmin" %>

<%
    Stop
    Dim nro_credito = nvUtiles.obtenerValor("nro_credito", "5196927")
    Dim modo = nvUtiles.obtenerValor("modo", "F")
    Dim estado_acambiar = nvUtiles.obtenerValor("estado_acambiar", "")
    Dim GenerarCC = nvUtiles.obtenerValor("GenerarCC", "")
    Dim fe_estado_nuevo = nvUtiles.obtenerValor("fe_estado_nuevo", "")
    Dim estado As String = ""


    Dim docbytes As Byte()
    ReDim docbytes(Request.Files(0).InputStream.Length - 1)
    Request.Files(0).InputStream.Read(docbytes, 0, Request.Files(0).InputStream.Length)

    Dim err As New tError()


    'If (modo.ToUpper <> "M") Then

    '    Dim StrSQL As String = ""
    '    StrSQL = "select nro_docu,tipo_docu,sexo,fe_credito,convert(varchar,fe_credito,103) as fe_credito_str,descripcion,convert(varchar,fe_estado,103) as fe_estado,estado,banco,mutual,clave_banco,nro_envio"
    '    StrSQL += ",nombre_operador,login,vendedor,plan_banco,detalle_cobro,importe_bruto,importe_neto,importe_documentado"
    '    StrSQL += ",gasto_administrativo,cuotas,importe_cuota,primer_vencimiento,mes_vencimiento,saldo_cancelado"
    '    StrSQL += ",operador,id_srv,nro_operatoria,cobro from lausana..WRP_infoCredito where nro_credito = " & nro_credito
    '    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(StrSQL)
    '    If (rs.EOF = False) Then

    '        Dim nro_docu = rs.Fields("nro_docu").Value
    '        Dim tipo_docu = rs.Fields("tipo_docu").Value
    '        Dim sexo = rs.Fields("sexo").Value
    '        Dim fe_credito = rs.Fields("fe_credito").Value
    '        Dim fe_credito_str = rs.Fields("fe_credito_str").Value
    '        Dim descripcion = rs.Fields("descripcion").Value
    '        Dim fe_estado = rs.Fields("fe_estado").Value
    '        estado = rs.Fields("estado").Value
    '        Dim banco = rs.Fields("banco").Value
    '        Dim mutual = rs.Fields("mutual").Value
    '        Dim clave_banco = rs.Fields("clave_banco").Value
    '        Dim nro_envio = rs.Fields("nro_envio").Value
    '        Dim nombre_operador = rs.Fields("nombre_operador").Value
    '        Dim login = rs.Fields("login").Value
    '        Dim vendedor = rs.Fields("vendedor").Value
    '        Dim plan_banco = rs.Fields("plan_banco").Value
    '        Dim detalle_cobro = rs.Fields("detalle_cobro").Value
    '        Dim importe_bruto = rs.Fields("importe_bruto").Value
    '        Dim importe_neto = rs.Fields("importe_neto").Value
    '        Dim importe_documentado = rs.Fields("importe_documentado").Value
    '        Dim gasto_administrativo = rs.Fields("gasto_administrativo").Value
    '        Dim cuotas = rs.Fields("cuotas").Value
    '        Dim importe_cuota = rs.Fields("importe_cuota").Value
    '        Dim primer_vencimiento = rs.Fields("primer_vencimiento").Value
    '        Dim mes_vencimiento = rs.Fields("mes_vencimiento").Value
    '        Dim saldo_cancelado = rs.Fields("saldo_cancelado").Value
    '        Dim nro_operador = rs.Fields("operador").Value
    '        Dim id_srv = rs.Fields("id_srv").Value
    '        Dim nro_operatoria = rs.Fields("nro_operatoria").Value
    '        Dim cobro = rs.Fields("cobro").Value
    '    End If

    '    nvDBUtiles.DBCloseRecordset(rs)
    'End If


    If modo.ToUpper = "F" Then
        Try

            Dim metadatarequest As New Dictionary(Of String, String)

            ' es necesario agregar un esquema de definicine de rm0
            'Dim url As String = nvFW.nvUtiles.getParametroValor("cac_uri_retorno") '"https://novatest.improntasolutions.com/services/nvCertiServiceAprobarSolicitud.aspx"

            Dim cod_rm0_seg As String = "nvMUTUAL" & Guid.NewGuid().ToString("N")
            Dim filename As String = ""
            'dim email As string=""
            'dim cuit As string = ""
            'Dim apellido_nombre As String = ""
            'Dim nro_def_archivo As Integer

            Dim oLegajo As New tnvLegContainer
            Dim oDocumento As tnvLegDocument
            Dim oSign As tnvSignature


            '**********************************************************
            'Estructura params.
            'Permite agregar al legajo parámetros para uso interno
            '**********************************************************
            filename = "prestamo_xxxxx_cuil_2025940354.rm0"
            oLegajo.paramAdd("cod_rm0_seg", cod_rm0_seg)
            oLegajo.paramAdd("filename", filename)


            '****************************************************************************
            'Estructura returns.
            'Permite agregar la definición de donde y como se enviará el legajo firmado
            'Hay dos métodos posible 
            '    1) por HTTPs a una URL donde se adjuntará el legajo firmado. 
            '    2) Por mail donde se adjuntará el legajo firmado
            '****************************************************************************
            Dim url As String = "https://www.improntasolutions.com.ar/services/legajo_recepcion.aspx"
            oLegajo.returnHTTPAdd(filename, url, "file01")
            oLegajo.returnMailAdd(filename, "recepcion@improntasolutions.com.ar", "Legajo nro 2134657")


            '**********************************************************
            'Agregar los documentos a firmar
            '**********************************************************
            Dim filename_doc As String = "archivo1.pdf"
            oDocumento = New tnvLegDocument("archivo1", filename_doc)
            oDocumento.load(docbytes)
            oLegajo.documents.Add(10, oDocumento)

            oSign = New nvFW.tnvSignature(oDocumento)
            oSign.PKI = New nvFW.tnvPKI
            oSign.name = "nvUserSign1"
            oSign.use = nvFW.nvSignUse.user_sign

            'Configurar parámetros de la firma
            oSign.PDFSignParams = New nvFW.tnvPDFSignParam
            With oSign.PDFSignParams

                .visible_signature = True
                .appendToExistingOnes = True
                .certificationLevel = nvFW.nvPDFCertificationLevel.not_certified
                .cryptoStandard = nvFW.nvPDFCryptoStandard.CADES
                .hashAlgorithm = nvFW.nvHashAlgorithm.SHA1

                'Posicion
                .page = 1
                .x1 = 0
                .x2 = 0
                .y1 = 0
                .y2 = 0


                .fieldname = "nvUserSign1"
                .display = nvPDFSingDisplay.description_only
                .signature_text = "Firmado digitalmente por Juan Perez. CUIT: 2025904035"
                .reason = "Aceptación de condiciones del crédito"
                .Location = "Santa Fe"
            End With
            oSign.signatoryID = "SERIALNUMBER=CUIT 2025904035"

            oDocumento.Signatures.Add(oSign)



            '********************************************
            'Primer pantalla del asistente.
            'Mostrar condiciones de la operación
            '********************************************
            oLegajo.titulo = "Solicitud de préstamo - Banco BICA"
            oLegajo.comentario = "Datos de la operación"


            'Metadatos que se deben mostrar al usuario. Condiciones de lo que estaría firmando
            oLegajo.metadataAdd(0, "CUIT", "20-25904035-4")
            oLegajo.metadataAdd(1, "Apellido y Nombres", "Juan Perez")
            oLegajo.metadataAdd(2, "Nro. crédito", "1324657")
            oLegajo.metadataAdd(3, "Fecha emisión", CDate(Now()).ToString("dd/MM/yyyy"))
            oLegajo.metadataAdd(4, "Hora emisión", CDate(Now()).ToString("hh:mm:ss"))
            oLegajo.metadataAdd(5, "Primer vencimiento", CDate(Now().AddDays(Now().Day * -1).AddMonths(1).AddDays(10)).ToString("dd/MM/yyyy"))
            oLegajo.metadataAdd(6, "Importe retirado", "$ 10.000,00")
            oLegajo.metadataAdd(7, "Importe solicitado", "$ 10.250,00")
            oLegajo.metadataAdd(8, "Plan", "12 cuotas de $ 1.000,00")
            oLegajo.metadataAdd(9, "Banco", "BICA")



            '********************************************
            'Segunda pantalla del asistente (Opcional).
            'Solicitar la incorportación de documentos al legajo
            '********************************************
            'Archivo requerido
            Dim filename_dni As String = "DNI.pdf"
            oDocumento = New tnvLegDocument("DNI", filename_dni)
            oDocumento.metadataRequest = New Dictionary(Of String, String)
            oDocumento.metadataRequest.Add("ppi", 120)
            oDocumento.metadataRequest.Add("depthcolor", "truecolor")
            oDocumento.metadataRequest.Add("requerido", "true")
            'oDocumento.metadataRequest.Add("requesterID", "SERIALNUMBER=CUIT 2025904035")
            oLegajo.documents.Add(0, oDocumento)

            'Archivo no requerido
            Dim filename_servicio As String = "servicio.pdf"
            oDocumento = New tnvLegDocument("servicio", filename_servicio)
            oDocumento.metadataRequest = New Dictionary(Of String, String)
            oDocumento.metadataRequest.Add("ppi", 120)
            oDocumento.metadataRequest.Add("depthcolor", "truecolor")
            oDocumento.metadataRequest.Add("requerido", "true")
            'oDocumento.metadataRequest.Add("requesterID", "SERIALNUMBER=CUIT 2025904035")
            oLegajo.documents.Add(1, oDocumento)

            '**************************************************
            'Tercer pantalla del asistente. Norequiere código.
            'Muestra los documentos a firmar
            '**************************************************


            '**************************************************
            'Cuarta pantalla del asistente.
            'Configuración de la firma.
            '**************************************************

            'Reason de las firmas. Principalmente se utiliza en PDF.
            'Se puede pasar valores tabulados para que el cliente seleccione o "editable" para que ingrese la rason escribíendola
            oLegajo.reason_editable = False
            oLegajo.reasonAdd("Aceptación de condiciones del crédito", True)
            oLegajo.reasonAdd("Rechazo de condiciones del crédito", False)

            'Location de las firmas. Principalmente se utiliza en PDF. 
            'Se puede pasar valores tabulados para que el cliente seleccione o "editable" para que ingrese la localidad escribíendola.
            oLegajo.location_editable = True
            oLegajo.locationAdd("Santa Fe", True)
            oLegajo.locationAdd("Entre Rios", False)
            oLegajo.locationAdd("Buenos Aires", False)
            oLegajo.locationAdd("Misiones", False)
            oLegajo.locationAdd("Mendoza", False)


            'System.IO.Directory.Delete("d:\prueba_legajo\")
            'System.IO.Directory.CreateDirectory("d:\prueba_legajo\")
            For Each f In System.IO.Directory.EnumerateFiles("d:\prueba_legajo")
                System.IO.File.Delete(f)
            Next

            oLegajo.exportToFile("d:\prueba_legajo\" & filename)

            Dim oLegajo2 As New tnvLegContainer
            oLegajo2.importFromFile("d:\prueba_legajo\" & filename)
            oLegajo2.saveFilesToDir("d:\prueba_legajo\", True)

            err.params.Add("nro_credito", nro_credito)



        Catch ex As Exception

            err.numError = -99
            err.mensaje = "Error inesperado"
            err.titulo = "Error al tratar de realizar la operación"
            err.debug_desc = ex.Message
            err.debug_src = "Generar archivo RM0"

        End Try
    End If

    err.response()


%>

