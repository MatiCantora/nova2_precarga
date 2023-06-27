<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%

    Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")
    'Dim modotest As Boolean = IIf(nvUtiles.getParametroValor("siempre_ok", "0") = "1", True, False)
    Dim modotest As Boolean = False
    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim Err As New tError
    Dim ErrSave As New tError ''declaro esto terror para guardar en la bd log
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If op.tienePermiso("permisos_web5", 4194304) Then
        modotest = True
    End If
    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
    Dim id_ambiente As String = nvUtiles.getParametroValor("id_ambiente", "0")
    Dim eqAmbiente As New nvFW.servicios.veraz.eqAmbiente  '.IDValidator.eqAmbiente
    Dim eqPreguntasResponse As New nvFW.servicios.veraz.eqPreguntasResponse  '.IDValidator.eqPreguntasResponse
    Dim objQuestion As New nvFW.servicios.veraz.question  '.IDValidator.question
    Dim objAnswerOption As New nvFW.servicios.veraz.answerOption  '.IIDValidator.answerOption
    Dim cn As ADODB.Connection
    Dim msgEvent = ""
    Select Case accion.ToLower
        Case "obtener_preguntas"
            Dim nro_docu As String = ""
            Dim sexo As String = ""
            Dim apellido As String = ""
            Dim nombres As String = ""
            Dim lote As String = ""
            Try

                cn = DBConectar()
                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                'XML.SelectSingleNode("criterio/id_ambiente").InnerText
                nro_docu = XML.SelectSingleNode("criterio/nro_docu").InnerText
                sexo = XML.SelectSingleNode("criterio/sexo").InnerText
                apellido = XML.SelectSingleNode("criterio/apellido").InnerText
                nombres = XML.SelectSingleNode("criterio/nombres").InnerText

                msgEvent = nombres.Replace(";", "") & ";" & apellido.Replace(";", "") & ";" & nro_docu & ";" & sexo
                nvFW.nvLog.addEvent("vi_questions", msgEvent)

                Err.params.Add("lote", "")
                Err.params.Add("xmlpreguntas", "")
                strXML = "<questions>"



                Dim StrSQL As String = ""
                StrSQL = "select id_ambiente, matriz, usuario, password, cliente, sector, url, sucursal, id_cuestionario from eqAmbientes where id_ambiente=" + id_ambiente
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(StrSQL)
                If rs.EOF = False Then
                    Dim matriz = rs.Fields("matriz").Value
                    Dim usuario = rs.Fields("usuario").Value
                    Dim password = rs.Fields("password").Value
                    Dim cliente = IIf(Convert.IsDBNull(rs.Fields("cliente").Value) = True, "", rs.Fields("cliente").Value)
                    Dim sector = rs.Fields("sector").Value
                    Dim url = rs.Fields("url").Value
                    Dim sucursal = rs.Fields("sucursal").Value
                    Dim id_cuestionario = rs.Fields("id_cuestionario").Value
                    eqAmbiente.id = id_ambiente
                    eqAmbiente.matriz = matriz
                    eqAmbiente.usuario = usuario
                    eqAmbiente.password = password
                    eqAmbiente.cliente = cliente
                    eqAmbiente.sucursal = sucursal
                    eqAmbiente.sector = sector
                    eqAmbiente.url = url
                    eqAmbiente.cuestionario = id_cuestionario
                Else
                    Err.numError = 1
                    Err.titulo = "Error al obtener preguntas"
                    Err.mensaje = "Servicio momentaneamente no disponible"
                    Err.debug_desc = "No se pudieron cargar las credenciales"
                End If


                If Err.numError = 0 Then

                    eqPreguntasResponse.cn = cn
                    eqPreguntasResponse.timeout = 100000
                    eqPreguntasResponse.obtenerPreguntas(eqAmbiente, "", apellido, nombres, nro_docu, sexo, 0, False)
                    If eqPreguntasResponse.numError = 0 Then
                        lote = eqPreguntasResponse.lote.ToString
                        Err.params("lote") = lote

                        Dim preguntas As Object = eqPreguntasResponse.questions()
                        '   Dim listaQ As Integer = objQuestion.getCount(preguntas)
                        Dim i As Integer = 0
                        For i = 0 To preguntas.count - 1
                            Dim pregunta As nvFW.servicios.veraz.question = objQuestion.getItem(preguntas, i)
                            strXML += "<pregunta questionID='" & pregunta.questionID.ToString & "' orden='" & pregunta.orden.ToString & "'>"
                            strXML += "<text>" & pregunta.text.ToString & "</text>"
                            Dim opciones As Object = pregunta.answerOptions()
                            '   Dim listaO As Integer = objAnswerOption.getCount(opciones)
                            For j = 0 To opciones.count - 1
                                Dim opcion As nvFW.servicios.veraz.answerOption = objAnswerOption.getItem(opciones, j)
                                strXML += "<opcion optionId='" & opcion.optionId.ToString & "'>" & opcion.text.ToString & "</opcion>"

                            Next
                            strXML += "</pregunta>"

                        Next
                        strXML += "</questions>"

                        Err.params("xmlpreguntas") = strXML
                        ''eqPreguntasResponse.saveAllResultDb(cn)
                        'cambiar
                        'Session.Contents("webservice") = eqPreguntasResponse
                    Else

                        Err.numError = eqPreguntasResponse.numError
                        Err.titulo = "Error al obtener preguntas"
                        Err.mensaje = "El servicio no pudo obtener las preguntas: " & eqPreguntasResponse.descError
                        Err.debug_desc = "getxml:eqPreguntasResponse.obtenerPreguntas() : " & eqPreguntasResponse.descError
                    End If
                End If

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error en la importación de la consulta"
                Err.mensaje = "Salida por excepcion"
                Err.debug_src = "getxml::obtener_preguntas"

            End Try
            eqPreguntasResponse.saveSolicitudLote(cn:=cn, tErr:=Err) ''revisar que el seteo de xmlpreguntas no se borre
            strXML = Err.get_error_xml()

            If (Err.numError = 0) Then
                msgEvent = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss.fff") & ";" & nombres.Replace(";", "") & ";" & apellido.Replace(";", "") & ";" & nro_docu & ";" & sexo & ";" & lote
                nvFW.nvLog.addEvent("vi_questions_ok", msgEvent)
            Else
                msgEvent = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss.fff") & ";" & nombres.Replace(";", "") & ";" & apellido.Replace(";", "") & ";" & nro_docu & ";" & sexo & ";" & lote & ";" & (strXML.Replace(";", "")).Substring(0, 255)
                nvFW.nvLog.addEvent("vi_questions_error", msgEvent)
            End If


        Case "validar"
            Dim lote As String = ""
            Dim estado As String = ""
            Dim score As String = ""
            Try

                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                lote = XML.SelectSingleNode("criterio/lote").InnerText
                Dim xmlrespuestas As String = XML.SelectSingleNode("criterio/xmlrespuestas").InnerXml
                msgEvent = lote
                nvFW.nvLog.addEvent("vi_response", msgEvent)



                Err.params.Add("resultado", "")
                Err.params.Add("autorizacion", "")
                Err.params.Add("score", "")
                Err.params.Add("valor", "")
                Err.params.Add("estado", "")


                Dim StrSQL As String = ""
                StrSQL = "select id_ambiente,matriz,usuario,password,cliente,sector,url,sucursal,id_cuestionario from eqAmbientes where id_ambiente=" & id_ambiente
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(StrSQL)
                If rs.EOF = False Then
                    Dim matriz = rs.Fields("matriz").Value
                    Dim usuario = rs.Fields("usuario").Value
                    Dim password = rs.Fields("password").Value
                    Dim cliente = IIf(Convert.IsDBNull(rs.Fields("cliente").Value) = True, "", rs.Fields("cliente").Value)
                    Dim sector = rs.Fields("sector").Value
                    Dim url = rs.Fields("url").Value
                    Dim sucursal = rs.Fields("sucursal").Value
                    Dim id_cuestionario = rs.Fields("id_cuestionario").Value
                    eqAmbiente.id = id_ambiente
                    eqAmbiente.matriz = matriz
                    eqAmbiente.usuario = usuario
                    eqAmbiente.password = password
                    eqAmbiente.cliente = cliente
                    eqAmbiente.sucursal = sucursal
                    eqAmbiente.sector = sector
                    eqAmbiente.url = url
                    eqAmbiente.cuestionario = id_cuestionario
                Else
                    Err.numError = 1
                    Err.titulo = "Error al validar respuestas"
                    Err.mensaje = "Servicio momentaneamente no disponible"
                    Err.debug_desc = "getxml::validar.No se pudieron cargar las credenciales para el webservice"
                End If


                If Err.numError = 0 Then
                    Try
                        cn = DBConectar()
                        Dim objIntegrante As New nvFW.servicios.veraz.integrante
                        eqPreguntasResponse.cn = cn
                        ''eqPreguntasResponse.guardarbd = True

                        eqPreguntasResponse.loadLoteDb(lote, eqAmbiente)
                        If (eqPreguntasResponse.numError = 0) Then

                            XML.LoadXml(xmlrespuestas)

                            Dim NODs As System.Xml.XmlNodeList = XML.SelectNodes("respuesta/opcion")
                            For Each nod As System.Xml.XmlNode In NODs
                                'Dim opcion = nod.SelectSingleNode("opcion")[0]
                                Dim questionID = nod.Attributes("questionID").Value
                                Dim answerID = nod.Attributes("answerID").Value
                                eqPreguntasResponse.addAnswer(questionID, answerID)
                                ''eqPreguntasResponse.SetRespuesta(questionID, answerID)
                                ''Dim r As wsVeraz.Answer = New wsVeraz.Answer()
                                ''r.questionId = questionID
                                ''r.id = answerID
                                ''r.name = ""
                                ''Respuestas.Add(r)

                            Next
                            eqPreguntasResponse.enviarRespuestasLista()
                            If eqPreguntasResponse.numError = 0 Then

                                Dim integrantes As Object = eqPreguntasResponse.integrantes()

                                Err.params("resultado") = eqPreguntasResponse.resultado
                                Err.params("autorizacion") = eqPreguntasResponse.autorizacion
                                Dim integrante As Object = objIntegrante.getItem(integrantes, 0)
                                score = integrante.score
                                Err.params("score") = integrante.score
                                Err.params("valor") = integrante.valor
                                if(modotest)Then
                                    Err.params("estado") = 1
                                Else
                                    Err.params("estado") = integrante.estado
                                End If
                                estado = Err.params("estado")

                                ''Session.Contents("webservice") = Nothing
                            Else
                                Err.numError = eqPreguntasResponse.numError

                                Err.titulo = "Error al validar respuestas"
                                If (Err.numError = -1) Then
                                    Err.mensaje = eqPreguntasResponse.descError
                                Else
                                    Err.mensaje = "Servicio momentaneamente no disponible. Intente luego."
                                End If
                                Err.debug_desc = "getxml::eqPreguntasResponse.enviarRespuestasLista. Error al consultar webservice: " & eqPreguntasResponse.descError

                            End If
                        Else
                            Err.numError = eqPreguntasResponse.numError

                            Err.titulo = "Error al validar respuestas"
                            If (Err.numError = 99) Then
                                Err.mensaje = eqPreguntasResponse.descError
                            Else
                                Err.mensaje = "Servicio momentaneamente no disponible. Intente luego."
                            End If

                            Err.debug_desc = "getxml::loadLoteDb. Error al cargar el lote a validar " & eqPreguntasResponse.descError
                        End If


                    Catch ex As Exception
                        Err.parse_error_script(ex)
                        Err.titulo = "Error en la validacion de las preguntas"
                        Err.mensaje = "Salida por excepcion"
                        Err.debug_src = "getxml:: validar"
                    End Try
                End If


            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al intentar validar las respuestas"
                Err.debug_src = "getxml::validar"
            End Try
            eqPreguntasResponse.saveRespuestaLote(cn:=cn, Err:=Err)
            strXML = Err.get_error_xml()

            If (Err.numError = 0) Then
                msgEvent = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss.fff") & ";" & lote & ";" & estado & ";" & score
                nvFW.nvLog.addEvent("vi_response_ok", msgEvent)
            Else
                msgEvent = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss.fff") & ";" & lote & ";" & estado & ";" & score & ";" & (strXML.Replace(";", "")).Substring(0, 255)
                nvFW.nvLog.addEvent("vi_response_error", msgEvent)
            End If

    End Select

    nvXMLUtiles.responseXML(Response, strXML)
    Stopwatch.Stop()
    Dim ts As TimeSpan = Stopwatch.Elapsed
    'nvLog.addEvent("veraz_getXML", logTrack & ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)

    Response.End()

    'Response.Expires = -1
    'Response.ContentType = "text/xml"
    'Response.Charset = "ISO-8859-1" '"UTF-8"
    'strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>" + strXML
    'Dim buffer() As Byte = Encoding.GetEncoding("iso-8859-1").GetBytes(strXML)
    ''Response.Write(strXML)
    'Response.BinaryWrite(buffer)
    'Response.Flush()

%>