<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import namespace="nvFW" %>
<%
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")
    'Stop
    Dim XML As System.Xml.XmlDocument
    Dim strXML As String = ""
    Dim st As New ADODB.Stream
    Dim Err As tError

    Dim logTrack As String = nvLog.getNewLogTrack()
    Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()

    Select Case accion.ToLower
        Case "cuad_login"
            'Stop
            Dim user As String
            Dim password As String
            Dim clave_sueldo As String
            Try
                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                user = XML.SelectSingleNode("criterio/user").InnerText
                password = XML.SelectSingleNode("criterio/password").InnerText
                clave_sueldo = XML.SelectSingleNode("criterio/clave_sueldo").InnerText
                strXML = nvFW.infoRecibos.nvCUADinfo.CargarCaptcha(user, password, clave_sueldo)
                'Stop
            Catch ex As Exception
            End Try

        Case "sac_identidad"
            Dim nro_vendedor As Integer
            Dim nro_banco As Integer
            Dim CDA As Integer
            Try
                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                criterio = XML.SelectSingleNode("criterio/nro_docu").InnerText
                nro_vendedor = XML.SelectSingleNode("criterio/nro_vendedor").InnerText
                nro_banco = XML.SelectSingleNode("criterio/nro_banco").InnerText
                CDA = nvXMLUtiles.getNodeText(XML, "criterio/CDA")
            Catch ex As Exception
            End Try
            strXML = nvFW.servicios.nvNOSIS.SAC_identidad(criterio, nro_vendedor, nro_banco, CDA)


        Case "sac_get_token"
            Try
                'Stop
                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                Dim nro_banco As Integer = XML.SelectSingleNode("criterio/nro_banco").InnerText
                strXML = nvFW.servicios.nvNOSIS.SAC_get_token(nro_banco)
            Catch ex As Exception

            End Try

        Case "sac_informe"
            Dim nro_vendedor As Integer
            Dim nro_banco As Integer
            Dim CDA As Integer
            Try

                XML = New System.Xml.XmlDocument
                XML.LoadXml(criterio)
                criterio = XML.SelectSingleNode("criterio/cuit").InnerText
                nro_vendedor = XML.SelectSingleNode("criterio/nro_vendedor").InnerText
                nro_banco = XML.SelectSingleNode("criterio/nro_banco").InnerText
                CDA = nvFW.nvXMLUtiles.getNodeText(XML, "criterio/CDA", 0)
                strXML = nvFW.servicios.nvNOSIS.SAC_informe(criterio, nro_vendedor, nro_banco, CDA)
            Catch ex As Exception

            End Try


    End Select

    nvXMLUtiles.responseXML(Response, strXML)
    Stopwatch.Stop()
    Dim ts As TimeSpan = Stopwatch.Elapsed

    'nvLog.addEvent("rd_getXML", logTrack & ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)
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