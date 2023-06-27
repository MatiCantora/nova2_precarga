<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" EnableSessionState="ReadOnly" %>
<%@ Import Namespace="System.Threading" %>
<%
    Dim accion As String = nvUtiles.obtenerValor("accion", "").ToString().ToLower()

    If accion <> String.Empty Then

        Dim err As New tError
        err.params("response") = ""
        err.params("id") = ""
        err.params("date") = ""
        'Dim timer As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

        ' El user y el pass son el mismo para todos los servicios
        Dim Usuario As String = nvUtiles.getParametroValor("CUAD_ROBOT_USERNAME", "")
        Dim Password As String = nvUtiles.getParametroValor("CUAD_ROBOT_PASSWORD", "")

        If Usuario = String.Empty OrElse Password = String.Empty Then
            err.numError = 1
            err.titulo = "Error Parametría"
            err.mensaje = "No se pudo obtener una o mas credenciales de acceso mediante parametría."
            err.debug_desc = "El Usuario o el Password está vacío. Controlar que existen los parámetros y que sus valores estén cargados."
            err.response()
        End If

        ' Armado de la URL para el CallBack (luego se le anexa el ID para saber que servicio la mando)
        Dim aspxCallback As String = nvUtiles.getParametroValor("CUAD_ROBOT_ASPX_CALLBACK ", "")

        If aspxCallback = String.Empty OrElse IO.Path.GetExtension(aspxCallback) <> ".aspx" Then
            err.numError = 1
            err.titulo = "Error ASPX Callback"
            err.mensaje = "No se pudo obtener el nombre del ASPX para la Url Callback."
            err.debug_desc = "Controlar que existe el parámetro y que su valor esté cargado."
            err.response()
        End If

        Dim app = nvFW.nvApp.getInstance()
        Dim UrlCallBack As String = app.server_host_https & "/FW/servicios/CUAD/" & aspxCallback
        err.params("urlCallback") = UrlCallBack


        Select Case accion
            '------------------------------------------------------------------
            '
            '                          Get Cupo CUAD
            '
            '------------------------------------------------------------------
            Case "wsgetcupo"

                ' Parametros del tError adicionales
                err.params("date_robot") = ""
                err.params("exit_timeout") = ""
                err.params("return_callback") = ""
                err.params("response_robot") = ""
                err.params("neto") = ""
                err.params("bruto") = ""
                err.params("socio") = ""
                err.params("cupo_total") = ""
                err.params("disponible_1c") = ""
                err.params("disponible_nc") = ""
                err.params("disponible_1c_siguiente") = ""
                err.params("disponible_nc_siguiente") = ""
                err.params("deuda_agente_total") = ""

                Dim inicio As Date = Date.Now
                Dim customFormat As String = "yyyy-MM-dd HH:mm:ss.ffff"
                err.params("date") = inicio.ToString(customFormat)


                Dim Scu_Id As Integer = CInt(nvUtiles.obtenerValor("Scu_Id", "-1"))
                Dim Sce_Id As Integer = CInt(nvUtiles.obtenerValor("Sce_Id", "-1"))
                Dim Scm_Id As Integer = CInt(nvUtiles.obtenerValor("Scm_Id", "-1"))

                Dim clave_sueldo As String = nvUtiles.obtenerValor("clave_sueldo", "")
                Dim prioridad As Integer = CInt(nvUtiles.obtenerValor("prioridad", "-1"))
                Dim periodo_desc As Integer = CInt(nvUtiles.obtenerValor("periodo_desc", "-1"))

                Dim timeout As Long = CLng(nvUtiles.obtenerValor("timeout", "30"))  ' Segundos


                If Usuario = String.Empty OrElse Password = String.Empty OrElse Scu_Id = -1 OrElse Sce_Id = -1 OrElse Scm_Id = -1 OrElse clave_sueldo = String.Empty OrElse prioridad = -1 OrElse periodo_desc = -1 Then
                    err.numError = 3
                    err.titulo = "Error WS Get Cupo"
                    err.mensaje = "Ocurrió un error al enviar datos al WS CUAD. Uno o más parámetros están vacíos. Por favor comprobrar y volver a intentar."
                Else
                    Try
                        '----------------------------------------------------------------
                        '              Generar HASH con encriptación SHA256
                        '----------------------------------------------------------------
                        ' Como entrada para generar el HASH usamos la fecha obtenida al 
                        ' iniciar el "case" actual
                        '
                        ' El HASH generado con el algoritmo SHA256 tiene una longitud 
                        ' de 64 bytes
                        '----------------------------------------------------------------
                        Dim sha256 As System.Security.Cryptography.SHA256 = System.Security.Cryptography.SHA256.Create()
                        Dim hashBytes As Byte() = sha256.ComputeHash(nvConvertUtiles.currentEncoding.GetBytes(err.params("date")))
                        Dim hashIdBuilder As New StringBuilder(64)

                        ' Transformar el HASH en un string legible
                        For Each c As Byte In hashBytes
                            hashIdBuilder.Append(c.ToString("X2"))      ' "X2" es el formato para la representación Hexadecimal
                        Next

                        Dim hash As String = hashIdBuilder.ToString()
                        UrlCallBack &= "?op=" & accion & "&id=" & hash  ' Anexar a la URL el hash de identificacion

                        ' Guardar el log de la request realizada
                        Dim SP As String = "~~"
                        Dim strParametros As String = "Usuario=" & Usuario & SP & "Password=" & Password & SP &
                            "Scu_Id=" & Scu_Id & SP & "Sce_Id=" & Sce_Id & SP & "Scm_Id=" & Scm_Id & SP &
                            "clave_sueldo=" & clave_sueldo & SP & "prioridad=" & prioridad & SP & "periodo_desc=" & periodo_desc & SP & "timeout=" & timeout & SP & "UrlCallback=" & UrlCallBack
                        Dim strSQLInsert As String = "INSERT INTO ws_cuad_request (fecha, nro_operador, tipo_request, hash, parametros) VALUES (getdate(), dbo.rm_nro_operador(), '" & accion & "', '" & hash & "', '" & strParametros & "')"

                        Try
                            nvDBUtiles.DBExecute(strSQLInsert)
                        Catch ex As Exception
                        End Try

                        '----------------------------------------------------------------
                        '                    Llamada Web Service CUAD
                        '----------------------------------------------------------------
                        Dim oCUAD As New WsACUAD.WsACUADSoapClient
                        Dim response As String = oCUAD.WsGetCupo(Usuario, Password, UrlCallBack, Scu_Id, Sce_Id, Scm_Id, clave_sueldo, prioridad, periodo_desc)
                        oCUAD.Close()
                        err.params("response") = System.Web.HttpUtility.HtmlEncode(response.Replace("""", "'"))
                        err.params("id") = hash

                        ' Guardar Response del Servicio (encolado o error)
                        strSQLInsert = "INSERT INTO ws_cuad_response (fecha, nro_operador, tipo_response, hash, response) VALUES (getdate(), dbo.rm_nro_operador(), 'service_" & accion & "', '" & hash & "', '" & response & "')"

                        Try
                            nvDBUtiles.DBExecute(strSQLInsert)
                        Catch ex As Exception
                        End Try

                        ' Revisar si la respuesta del servicio es válida (numError == 0), sino salir con error
                        Dim xmlDoc As New System.Xml.XmlDocument
                        xmlDoc.LoadXml(response)
                        Dim node As System.Xml.XmlNode = xmlDoc.SelectSingleNode("//error_mensaje")

                        If Not node Is Nothing AndAlso node.Attributes("numError").Value <> "0" Then
                            err.numError = node.Attributes("numError").Value
                            err.titulo = "Error WS CUAD"
                            err.mensaje = "El servicio de CUAD contestó con error"
                            node = Nothing
                            xmlDoc = Nothing
                        Else
                            ' Si no está credo el diccionario => crearlo
                            If Application.Contents("cuadcupocallback") Is Nothing Then
                                Application.Contents("cuadcupocallback") = New Dictionary(Of String, Boolean)
                            End If

                            ' Si no está la clave creada => agregarla al diccionario
                            If Not Application.Contents("cuadcupocallback").ContainsKey(hash) Then
                                Application.Contents("cuadcupocallback").add(hash, False)
                            End If

                            Dim returnCallback As Boolean = False
                            Dim exitTimeout As Boolean = False
                            Dim elapsed As Long = 0

                            Do
                                Thread.Sleep(250)
                                returnCallback = Application.Contents("cuadcupocallback")(hash) ' Revisa si ya contesto el robot CUAD
                                elapsed = DateDiff(DateInterval.Second, inicio, Date.Now)       ' Obtener el tiempo transcurrido
                                exitTimeout = elapsed >= timeout                                ' Determina si ya está vencido el tiempo máximo
                            Loop While (Not returnCallback AndAlso Not exitTimeout)

                            err.params("date_robot") = Date.Now.ToString(customFormat)
                            ' Devolver el valor
                            err.params("exit_timeout") = If(exitTimeout, "1", "0")
                            err.params("return_callback") = If(returnCallback, "1", "0")

                            If returnCallback Then
                                Dim responseRobot As String = Application.Contents("cuadcupocallback_responses")(hash)
                                err.params("response_robot") = System.Web.HttpUtility.HtmlEncode(responseRobot.Replace("""", "'"))
                                ' Si hay respuesta XML, obtener todos los valores de retorno
                                xmlDoc = New System.Xml.XmlDocument
                                xmlDoc.LoadXml(responseRobot)
                                node = xmlDoc.SelectSingleNode("//error_mensaje/params")

                                If node.HasChildNodes Then
                                    err.params("neto") = nvXMLUtiles.getNodeText(node, "neto", "0.0")
                                    err.params("bruto") = nvXMLUtiles.getNodeText(node, "bruto", "0.0")
                                    err.params("socio") = nvXMLUtiles.getNodeText(node, "socio", "0.0")
                                    err.params("cupo_total") = nvXMLUtiles.getNodeText(node, "cupo_total", "0.0")
                                    err.params("disponible_1c") = nvXMLUtiles.getNodeText(node, "disponible_1c", "0.0")
                                    err.params("disponible_nc") = nvXMLUtiles.getNodeText(node, "disponible_nc", "0.0")
                                    err.params("disponible_1c_siguiente") = nvXMLUtiles.getNodeText(node, "disponible_1c_siguiente", "0.0")
                                    err.params("disponible_nc_siguiente") = nvXMLUtiles.getNodeText(node, "disponible_nc_siguiente", "0.0")
                                    err.params("deuda_agente_total") = nvXMLUtiles.getNodeText(node, "deuda_agente_total", "0.0")
                                End If

                                ' Guardar Response del Servicio (encolado o error)
                                strSQLInsert = "INSERT INTO ws_cuad_response (fecha, nro_operador, tipo_response, hash, response) VALUES (getdate(), dbo.rm_nro_operador(), 'robot_" & accion & "', '" & hash & "', '" & responseRobot & "')"

                                Try
                                    nvDBUtiles.DBExecute(strSQLInsert)
                                Catch ex As Exception
                                End Try
                            End If
                        End If
                    Catch ex As Exception
                        err.parse_error_script(ex)
                        err.numError = 3
                        err.titulo = "Error WS"
                        err.mensaje = "Ocurrió un error en el servicio de Obtención de Cupo CUAD."
                        err.params("response") = ex.Message
                    End Try
                End If



            '------------------------------------------------------------------
            '
            '                     Alta Consumo Directo CUAD
            '
            '------------------------------------------------------------------
            Case "wsaltaconsumodirecto"

                err.params("date_robot") = ""
                err.params("exit_timeout") = ""
                err.params("return_callback") = ""
                err.params("response_robot") = ""
                err.params("codigo_consumo") = ""
                err.params("nro_socio") = ""
                err.params("comprobante_filiacion_64") = ""
                err.params("comprobante_consumo_64") = ""

                Dim inicio As Date = Date.Now
                Dim customFormat As String = "yyyy-MM-dd HH:mm:ss.ffff"
                err.params("date") = inicio.ToString(customFormat)

                ' IDs de cuad, liquidador y cuad-mutual
                Dim Scu_Id As Integer = CInt(nvUtiles.obtenerValor("Scu_Id", "-1"))
                Dim Sce_Id As Integer = CInt(nvUtiles.obtenerValor("Sce_Id", "-1"))
                Dim Scm_Id As Integer = CInt(nvUtiles.obtenerValor("Scm_Id", "-1"))
                ' Agente
                Dim Clave_Sueldo As String = nvUtiles.obtenerValor("clave_sueldo", "")
                Dim Nro_Documento As String = nvUtiles.obtenerValor("Nro_Documento", "")

                Dim Prioridad As Integer = CInt(nvUtiles.obtenerValor("Prioridad", "-1"))  ' 1: urgente; 2: normal; 3: baja;
                Dim Ses_Id As Integer = CInt(nvUtiles.obtenerValor("Ses_Id", "-1"))        ' tipo de servicio a cargar como consumo

                Dim Cuotas As Integer = CInt(nvUtiles.obtenerValor("Cuotas", "-1"))
                Dim Importe As Decimal = Convert.ToDecimal(nvUtiles.obtenerValor("Importe", "0.0"), New System.Globalization.CultureInfo("en-US"))
                Dim Primer_Venc As Integer = CInt(nvUtiles.obtenerValor("Primer_Venc", "0"))

                Dim Categoria_Socio As String = nvUtiles.obtenerValor("Categoria_Socio", "")
                Dim Clave_Servicio As String = nvUtiles.obtenerValor("Clave_Servicio", "")
                Dim Comentario As String = nvUtiles.obtenerValor("Comentario", "")
                Dim timeout As Long = CLng(nvUtiles.obtenerValor("timeout", "60"))  ' Segundos

                If Usuario = String.Empty OrElse Password = String.Empty OrElse
                    Scu_Id = -1 OrElse Sce_Id = -1 OrElse Scm_Id = -1 OrElse Ses_Id = -1 OrElse
                    Clave_Sueldo = String.Empty OrElse Prioridad = -1 OrElse Cuotas = -1 OrElse Importe = 0.0 OrElse
                    Primer_Venc = 0 OrElse Categoria_Socio = String.Empty Then

                    err.numError = 3
                    err.titulo = "Error WS Alta Consumo Directo"
                    err.mensaje = "Ocurrió un error al enviar datos al WS CUAD. Uno o más parámetros están vacíos o su valor no es admitido. Por favor comprobrar y volver a intentar."
                Else
                    Try
                        '----------------------------------------------------------------
                        '              Generar HASH con encriptación SHA256
                        '----------------------------------------------------------------
                        ' Como entrada para generar el HASH usamos la fecha obtenida al 
                        ' iniciar el "case" actual
                        '
                        ' El HASH generado con el algoritmo SHA256 tiene una longitud 
                        ' de 64 bytes
                        '----------------------------------------------------------------
                        Dim sha256 As System.Security.Cryptography.SHA256 = System.Security.Cryptography.SHA256.Create()
                        Dim hashBytes As Byte() = sha256.ComputeHash(nvConvertUtiles.currentEncoding.GetBytes(err.params("date")))
                        Dim hashIdBuilder As New StringBuilder(64)

                        ' Transformar el HASH en un string legible
                        For Each c As Byte In hashBytes
                            hashIdBuilder.Append(c.ToString("X2"))  ' "X2" es el formato para la representación Hexadecimal
                        Next

                        Dim hash As String = hashIdBuilder.ToString()
                        UrlCallBack &= "?op=" & accion & "&id=" & hash                ' Anexar a la URL el hash de identificacion

                        ' Guardar el log de la request realizada
                        Dim SP As String = "~~"
                        Dim strParametros As String = "Usuario=" & Usuario & SP & "Password=" & Password & SP &
                            "Scu_Id=" & Scu_Id & SP & "Sce_Id=" & Sce_Id & SP & "Scm_Id=" & Scm_Id & SP &
                            "Clave_Sueldo=" & Clave_Sueldo & SP & "Nro_Documento=" & Nro_Documento & SP &
                            "Prioridad=" & Prioridad & SP & "Ses_Id=" & Ses_Id & SP &
                            "Cuotas=" & Cuotas & SP & "Importe=" & Importe & SP & "Primer_Venc=" & Primer_Venc & SP &
                            "Categoria_Socio=" & Categoria_Socio & SP & "Clave_Servicio=" & Clave_Servicio & SP & "Comentario=" & Comentario & SP &
                            "timeout=" & timeout & SP & "UrlCallback=" & UrlCallBack
                        Dim strSQLInsert As String = "INSERT INTO ws_cuad_request (fecha, nro_operador, tipo_request, hash, parametros) VALUES (getdate(), dbo.rm_nro_operador(), '" & accion & "', '" & hash & "', '" & strParametros & "')"

                        Try
                            nvDBUtiles.DBExecute(strSQLInsert)
                        Catch ex As Exception
                        End Try

                        '----------------------------------------------------------------
                        '                    Llamada Web Service CUAD
                        '----------------------------------------------------------------
                        Dim oCUAD As New WsACUAD.WsACUADSoapClient
                        Dim response As String = oCUAD.WsAltaConsumoDirecto(Usuario, Password, UrlCallBack, Scu_Id, Sce_Id, Scm_Id, Clave_Sueldo, Nro_Documento, Prioridad, Ses_Id, Cuotas, Importe, Primer_Venc, Categoria_Socio, Clave_Servicio, Comentario)
                        oCUAD.Close()
                        err.params("response") = System.Web.HttpUtility.HtmlEncode(response.Replace("""", "'"))
                        err.params("id") = hash

                        ' Guardar Response del Servicio (encolado o error)
                        strSQLInsert = "INSERT INTO ws_cuad_response (fecha, nro_operador, tipo_response, hash, response) VALUES (getdate(), dbo.rm_nro_operador(), 'service_" & accion & "', '" & hash & "', '" & response & "')"

                        Try
                            nvDBUtiles.DBExecute(strSQLInsert)
                        Catch ex As Exception
                        End Try

                        ' Revisar si la respuesta del servicio es válida (numError == 0), sino salir con error
                        Dim xmlDoc As New System.Xml.XmlDocument
                        xmlDoc.LoadXml(response)
                        Dim node As System.Xml.XmlNode = xmlDoc.SelectSingleNode("//error_mensaje")

                        If Not node Is Nothing AndAlso node.Attributes("numError").Value <> "0" Then
                            err.numError = node.Attributes("numError").Value
                            err.titulo = "Error WS CUAD"
                            err.mensaje = "El servicio de Alta de Consumo Directo CUAD contestó con error"
                            node = Nothing
                            xmlDoc = Nothing
                        Else
                            ' Si no está creado el diccionario => crearlo
                            If Application.Contents("cuadconsumocallback") Is Nothing Then
                                Application.Contents("cuadconsumocallback") = New Dictionary(Of String, Boolean)
                            End If

                            ' Si no está la clave creada => agregarla al diccionario
                            If Not Application.Contents("cuadconsumocallback").ContainsKey(hash) Then
                                Application.Contents("cuadconsumocallback").add(hash, False)
                            End If

                            Dim returnCallback As Boolean = False
                            Dim exitTimeout As Boolean = False
                            Dim elapsed As Long = 0

                            Do
                                Thread.Sleep(250)
                                returnCallback = Application.Contents("cuadconsumocallback")(hash)  ' Revisa si ya contesto el robot CUAD
                                elapsed = DateDiff(DateInterval.Second, inicio, Date.Now)           ' Obtener el tiempo transcurrido
                                exitTimeout = elapsed >= timeout                                    ' Determina si ya está vencido el tiempo máximo
                            Loop While (Not returnCallback And Not exitTimeout)

                            err.params("date_robot") = Date.Now.ToString(customFormat)
                            ' Devolver el valor
                            err.params("exit_timeout") = If(exitTimeout, "1", "0")
                            err.params("return_callback") = If(returnCallback, "1", "0")

                            If returnCallback Then
                                Dim responseRobot As String = Application.Contents("cuadconsumocallback_responses")(hash)
                                err.params("response_robot") = System.Web.HttpUtility.HtmlEncode(responseRobot.Replace("""", "'"))
                                ' Si hay respuesta XML, obtener todos los valores de retorno
                                xmlDoc = New System.Xml.XmlDocument
                                xmlDoc.LoadXml(responseRobot)
                                node = xmlDoc.SelectSingleNode("//error_mensaje/params")

                                If node.HasChildNodes Then
                                    err.params("codigo_consumo") = nvXMLUtiles.getNodeText(node, "codigo_consumo", "0")
                                    err.params("nro_socio") = nvXMLUtiles.getNodeText(node, "nro_socio", "0")
                                    err.params("comprobante_filiacion_64") = nvXMLUtiles.getNodeText(node, "comprobante_filiacion_64", "")
                                    err.params("comprobante_consumo_64") = nvXMLUtiles.getNodeText(node, "comprobante_consumo_64", "")
                                End If

                                ' Guardar Response del Servicio (encolado o error)
                                strSQLInsert = "INSERT INTO ws_cuad_response (fecha, nro_operador, tipo_response, hash, response) VALUES (getdate(), dbo.rm_nro_operador(), 'robot_" & accion & "', '" & hash & "', '" & responseRobot & "')"

                                Try
                                    nvDBUtiles.DBExecute(strSQLInsert)
                                Catch ex As Exception
                                End Try
                            End If
                        End If
                    Catch ex As Exception
                        err.parse_error_script(ex)
                        err.numError = 3
                        err.titulo = "Error WS"
                        err.mensaje = "Ocurrió un error en el servicio Alta de consumo directo de CUAD."
                        err.params("response") = ex.Message
                    End Try
                End If

        End Select

        'timer.Stop()
        'err.params("time") = timer.ElapsedMilliseconds
        err.response()
    End If
%>