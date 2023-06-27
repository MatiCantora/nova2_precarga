<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%
    Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")
    Dim modotest As Boolean = True
    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim Err As New tError

    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
    Dim id_ambiente As String = "1"
    Select Case accion.ToLower
        Case "obtener_preguntas"
            Try

                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                'XML.SelectSingleNode("criterio/id_ambiente").InnerText
                Dim nro_docu As String = XML.SelectSingleNode("criterio/nro_docu").InnerText
                Dim sexo As String = XML.SelectSingleNode("criterio/sexo").InnerText
                Dim apellido As String = XML.SelectSingleNode("criterio/apellido").InnerText
                Dim nombres As String = XML.SelectSingleNode("criterio/nombres").InnerText

                Err.params.Add("lote", "")
                Err.params.Add("xmlpreguntas", "")
                strXML = "<questions>"

                Dim eqAmbiente As New nvFW.servicios.veraz.eqAmbiente  '.IDValidator.eqAmbiente
                Dim eqPreguntasResponse As New nvFW.servicios.veraz.eqPreguntasResponse  '.IDValidator.eqPreguntasResponse
                Dim objQuestion As New nvFW.servicios.veraz.question  '.IDValidator.question
                Dim objAnswerOption As New nvFW.servicios.veraz.answerOption  '.IIDValidator.answerOption

                Dim StrSQL As String = ""
                StrSQL = "select id_ambiente,matriz,usuario,password,cliente,sector,url,sucursal,id_cuestionario from eqAmbientes where id_ambiente=" + id_ambiente
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
                    Err.mensaje = "No se cargaron las credenciales para el webservice"
                End If


                If Err.numError = 0 Then
                    Dim cn As ADODB.Connection = DBConectar()
                    eqPreguntasResponse.cn = cn
                    eqPreguntasResponse.guardarbd = True
                    eqPreguntasResponse.timeout=100000
                    eqPreguntasResponse.obtenerPreguntas(eqAmbiente, "", apellido, nombres, nro_docu, sexo, 0, False)
                    If eqPreguntasResponse.numError = 0 Then

                        Err.params("lote") = eqPreguntasResponse.lote.ToString

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
                        Err.mensaje = eqPreguntasResponse.descError
                    End If
                End If

            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error en la importación de la consulta"
                Err.mensaje = "Salida por excepcion"
                Err.debug_src = "getxml::obtener_preguntas"
            End Try

            strXML = Err.get_error_xml()

        Case "validar"
            Try

                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)

                Dim lote As String = XML.SelectSingleNode("criterio/lote").InnerText
                Dim xmlrespuestas As String = XML.SelectSingleNode("criterio/xmlrespuestas").InnerXml

                Err.params.Add("resultado", "")
                Err.params.Add("autorizacion", "")
                Err.params.Add("score", "")
                Err.params.Add("valor", "")
                Err.params.Add("estado", "")

                Dim eqAmbiente As New nvFW.servicios.veraz.eqAmbiente
                Dim eqPreguntasResponse As New nvFW.servicios.veraz.eqPreguntasResponse
                Dim objQuestion As New nvFW.servicios.veraz.question
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
                    Err.mensaje = "No se cargaron las credenciales para el webservice"
                End If


                If Err.numError = 0 Then
                    Try
                        Dim cn As ADODB.Connection = DBConectar()

                        eqPreguntasResponse.cn = cn
                        eqPreguntasResponse.guardarbd = True

                        eqPreguntasResponse.loadQuestionDb(lote, eqAmbiente)
                        If (eqPreguntasResponse.numError = 0) Then
                            Dim objAlerta As New nvFW.servicios.veraz.alerta
                            Dim objIntegrante As New nvFW.servicios.veraz.integrante
                            XML.LoadXml(xmlrespuestas)

                            Dim NODs As System.Xml.XmlNodeList = XML.SelectNodes("respuesta/opcion")
                            For Each nod As System.Xml.XmlNode In NODs
                                'Dim opcion = nod.SelectSingleNode("opcion")[0]
                                Dim questionID = nod.Attributes("questionID").Value
                                Dim answerID = nod.Attributes("answerID").Value

                                eqPreguntasResponse.SetRespuesta(questionID, answerID)

                            Next
                            eqPreguntasResponse.enviarRespuestas()
                            If eqPreguntasResponse.numError = 0 Then

                                Dim integrantes As Object = eqPreguntasResponse.integrantes()
                                
                                Err.params("resultado") = eqPreguntasResponse.resultado
                                Err.params("autorizacion") = eqPreguntasResponse.autorizacion
                                Dim integrante As Object = objIntegrante.getItem(integrantes, 0)
                                Err.params("score") = integrante.score
                                Err.params("valor") = integrante.valor
                                if(modotest)Then
                                    Err.params("estado") = 1
                                Else
                                 Err.params("estado") = integrante.estado
                                end if
                                

                                ''Session.Contents("webservice") = Nothing
                            Else
                                Err.numError = eqPreguntasResponse.numError
                                Err.mensaje = eqPreguntasResponse.descError
                            End If
                        Else
                            Err.numError = eqPreguntasResponse.numError
                            Err.mensaje  = eqPreguntasResponse.descError
                        End If


                    Catch ex As Exception
                        Err.parse_error_script(ex)
                        Err.titulo = "Error en la importación de la consulta"
                        Err.mensaje = "Salida por excepcion"
                        Err.debug_src = "getxml::validar"
                    End Try
                End If







            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.titulo = "Error al actualizar las fuentes externas"
                Err.debug_src = "getxml::validar"
            End Try

            strXML = Err.get_error_xml()

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