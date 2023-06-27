<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%
    Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")

    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim Err As New tError
    Dim MaximosIntentos As Integer = 4
    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
    

    Try

        XML = New System.Xml.XmlDocument
        XML.LoadXml(criterio)
        Err.params.Add("xmlresponse", "")
        Dim xmlresponse As String=""
        Dim oNsValidate = XML.SelectNodes("criterio/validate/item")
        Dim cn As ADODB.Connection = DBConectar()

        strXML = "<validate>"
        For each item in oNsValidate
            ''Dim tipo=item.SelectSingleNode("@type").Value
            ''Dim identificador=item.SelectSingleNode("@identificador").Value                    
            ''Dim cuit=item.SelectSingleNode("@cuit").Value
            Dim codigo = LTrim(RTrim(item.SelectSingleNode("@validador").Value))
            Dim token = LTrim(RTrim(item.SelectSingleNode("@token").Value))
            Dim validacion As String = "fallida"
            Dim intentos = 0
            Dim rs1 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select count(*) from validaciones where token='" & token & "' and estado='E' ") ''consulto si hay token en estado enviado o validos
            If Not (rs1.EOF) Then
                Dim cant = CInt(rs1.Fields(0).Value)
                ''token existe
                If (cant > 0) Then
                    rs1 = nvDBUtiles.DBOpenRecordset("select isnull(intentos,0) as intentos from validaciones where token='" & token & "' ")
                    If Not (rs1.EOF) Then
                        intentos = CInt(rs1.Fields("intentos").Value)
                        If (intentos < MaximosIntentos) Then
                            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select count(*) as c from validaciones where token='" & token & "' and validador='" & codigo & "'")
                            Dim c = 0
                            If rs.EOF = False Then
                                c = CInt(rs.Fields("c").Value)
                                validacion = IIf(c > 0, "OK", "fallida")
                                If (validacion = "fallida") Then
                                    nvDBUtiles.DBExecute("update validaciones set intentos=intentos+1 where token='" & token & "'")
                                Else
                                    nvDBUtiles.DBExecute("update validaciones set intentos=intentos+1,estado='A',momento=getdate() where token='" & token & "'") ''estado aprobada de la validacion
                                End If
                            End If
                        Else
                            nvDBUtiles.DBExecute("update validaciones set intentos=intentos+1,estado='R',momento=getdate() where token='" & token & "'") '' cambio estado de validacion a rechazado
                            validacion = "error" ''cantidad de intentos maximos superados
                        End If
                    End If

                Else
                    validacion = "error" ''token invalido
                End If
            End If





            strXML = strXML & "<item token='" & token & "'  validacion='" & validacion & "'  />"

        Next
        strXML = strXML & "</validate>"
        Err.params("xmlresponse")= strXML

    Catch ex As Exception
        Err.parse_error_script(ex)
        Err.titulo = "Error en la importación de la consulta"
        Err.mensaje = "Salida por excepcion"
        Err.debug_src = "getxml::getvalidate"

    End Try
    strXML = Err.get_error_xml()






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
