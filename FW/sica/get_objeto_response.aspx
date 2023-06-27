<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%
    ' GET_DEFINITION
    '   cod_objeto               
    ' OR
    '   cod_obj_tipo + objeto +  path + cod_modulo_version

    ' GET IMPLEMENTATION
    '   cod_servidor, cod_sistema, port
    ' OR
    '   objeto + path + cod_obj_tipo

    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim cod_objeto As String = nvUtiles.obtenerValor("cod_objeto", "")
    Dim path As String = nvUtiles.obtenerValor("path", "")
    Dim cod_obj_tipo As String = nvUtiles.obtenerValor("cod_obj_tipo", "")
    Dim objeto As String = nvUtiles.obtenerValor("objeto", "")
    Dim cod_modulo_version As String = nvUtiles.obtenerValor("cod_modulo_version", "")
    Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor", "")
    Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema", "")
    Dim port As String = nvUtiles.obtenerValor("port", "")
    Dim encoding As String = nvUtiles.obtenerValor("encoding", "ISO-8859-1")
    Dim oSica As nvSICA.tSicaObjeto = Nothing

    Select Case modo

        Case "GET_DEF"
            Try
                If cod_objeto = "" Then
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT cod_objeto from verNv_modulo_version_objetos WHERE objeto='" & objeto & "' AND path='" & path & "' AND cod_modulo_version=" & cod_modulo_version & " AND cod_obj_tipo=" & cod_obj_tipo)

                    If Not rs.EOF Then
                        cod_objeto = rs.Fields("cod_objeto").Value
                    End If

                    nvDBUtiles.DBCloseRecordset(rs)
                End If

                ' Obtener Definicion de objeto
                oSica = New nvSICA.tSicaObjeto
                oSica.loadFromDefinition(cod_objeto)
            Catch e As Exception
                Response.End()
            End Try



        Case "GET_IMP"
            Try
                ' si se envio como parametro unicamente el cod_objeto 
                ' recuperar el nombre del objeto y el tipo
                If (cod_objeto <> "") AndAlso (objeto = "" OrElse cod_obj_tipo = "") Then
                    oSica = New nvSICA.tSicaObjeto
                    oSica.loadFromDefinition(cod_objeto)
                    cod_obj_tipo = oSica.cod_obj_tipo
                    objeto = oSica.objeto
                End If

                ' obtener objeto desde la implementacion
                Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance()

                If (cod_servidor <> "") Then
                    nvApp = New nvFW.tnvApp
                    nvApp.loadFromDefinition(cod_servidor, cod_sistema, port)
                End If

                oSica = New nvSICA.tSicaObjeto
                oSica.loadFromImplementation(nvApp, cod_obj_tipo, path, objeto, 0, True)
            Catch e As Exception
                Response.End()
            End Try

    End Select


    If oSica.bytes() Is Nothing Then
        Response.End()
    End If

    Dim extension As String = oSica.extension

    If cod_obj_tipo = "8" Then
        extension = ".xml"
    End If

    Select Case extension
        Case ".pdf"
            Response.ContentType = "application/pdf"

        Case ".doc", ".docx"
            Response.ContentType = "application/msword"

        Case ".xls", ".xlsx"
            Response.ContentType = "application/vnd.ms-excel"

        Case ".gif"
            Response.ContentType = "image/gif"

        Case ".jpg", ".jpe", ".jpeg"
            Response.ContentType = "image/jpeg"

        Case ".tif", ".tiff"
            Response.ContentType = "image/tiff"

        Case ".ico"
            Response.ContentType = "image/x-icon"

        Case ".png"
            Response.ContentType = "image/png"

        Case ".bmp"
            Response.ContentType = "image/bmp"

        Case ".svg"
            Response.ContentType = "image/svg+xml"

        Case ".xml"
            Response.ContentType = "text/xml"

        Case ".svg"
            Response.ContentType = "image/svg+xml"

        Case ".swf"
            Response.ContentType = "application/x-shockwave-flash"
            Response.AddHeader("Content-Disposition", "inline; filename=file.swf")

        Case Else
            Response.End()

    End Select


    Response.Charset = encoding
    Response.BinaryWrite(oSica.bytes)
    Response.End()
%>