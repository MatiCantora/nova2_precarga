<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%
    ' GET_DEFINITION
    '   cod_objeto
    ' OR
    '   cod_obj_tipo + objeto +  path + cod_modulo_version

    ' GET_IMPLEMENTATION
    '   cod_servidor, cod_sistema, port
    ' OR
    '   objeto + path + cod_obj_tipo

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim cod_objeto As String = nvFW.nvUtiles.obtenerValor("cod_objeto", "")
    Dim path_ori As String = nvFW.nvUtiles.obtenerValor("path_ori", "")
    Dim path_dest As String = nvFW.nvUtiles.obtenerValor("path_dest", "")
    Dim cod_obj_tipo As String = nvFW.nvUtiles.obtenerValor("cod_obj_tipo", "")
    Dim objeto As String = nvFW.nvUtiles.obtenerValor("objeto", "")
    Dim cod_modulo_version As String = nvFW.nvUtiles.obtenerValor("cod_modulo_version", "")
    Dim cod_servidor As String = nvFW.nvUtiles.obtenerValor("cod_servidor", "")
    Dim cod_sistema As String = nvFW.nvUtiles.obtenerValor("cod_sistema", "")
    Dim port As String = nvFW.nvUtiles.obtenerValor("port", "")
    Dim encoding_implementation As String = nvFW.nvUtiles.obtenerValor("encoding_implementation", "ISO-8859-1")
    Dim encoding_definition As String = nvFW.nvUtiles.obtenerValor("encoding_definition", "ISO-8859-1")

    'If encoding_implementation = "" Then
    '    encoding_implementation = "iso-8859-1"
    'End If
    'If encoding_definition = "" Then
    '    encoding_definition = "iso-8859-1"
    'End If

    Dim err As New nvFW.tError
    Dim oSica As nvFW.nvSICA.tSicaObjeto

    If (modo = "GET_DEF" OrElse modo = "GET_DEF_AND_IMP") Then
        Try
            If cod_objeto = "" Then
                Dim rs As ADODB.Recordset
                rs = nvFW.nvDBUtiles.DBOpenRecordset("SELECT cod_objeto from verNv_modulo_version_objetos WHERE objeto='" & objeto & "' AND path='" & path_dest & "' AND cod_modulo_version=" & cod_modulo_version & " AND cod_obj_tipo=" & cod_obj_tipo)

                If Not rs.EOF Then cod_objeto = rs.Fields("cod_objeto").Value

                nvFW.nvDBUtiles.DBCloseRecordset(rs)
            End If

            ' Obtener Definicion de objeto
            oSica = New nvFW.nvSICA.tSicaObjeto
            oSica.loadFromDefinition(cod_objeto)

            Dim objetoContent As String = ""

            Try
                ' Se verifica si el binario comienza con un caracter BOM, que indica que esta codificado en utf-8 
                ' El carcater BOM viene representado por  0xef 0xbb 0xbf
                If oSica.bytes(0) = &HEF And oSica.bytes(1) = &HBB And oSica.bytes(2) = &HBF Then
                    Dim bytes(oSica.bytes.Length - 4) As Byte
                    Array.Copy(oSica.bytes, 3, bytes, 0, oSica.bytes.Length - 3)
                    objetoContent = System.Text.Encoding.GetEncoding("UTF-8").GetString(bytes)
                    encoding_definition = "UTF-8"
                Else
                    objetoContent = System.Text.Encoding.GetEncoding(encoding_definition).GetString(oSica.bytes)
                End If
            Catch ex As Exception
                objetoContent = ""
            End Try

            err.params("objetoContent_definition") = objetoContent
            err.params("objeto") = oSica.objeto
            err.params("extension") = oSica.extension
            err.params("encoding_definition") = encoding_definition
        Catch e As Exception
            err.parse_error_script(e)
            'err.response()
        End Try
    End If


    If (modo = "GET_IMP" Or modo = "GET_DEF_AND_IMP") Then
        Try
            ' si se envio como parametro unicamente el cod_objeto 
            ' recuperar el nombre del objeto y el tipo
            If (cod_objeto <> "") AndAlso (objeto = "" OrElse cod_obj_tipo = "") Then
                oSica = New nvFW.nvSICA.tSicaObjeto
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

            oSica = New nvFW.nvSICA.tSicaObjeto
            oSica.loadFromImplementation(nvApp, cod_obj_tipo, path_ori, objeto, 0, True)

            Dim objetoContent As String = ""

            Try
                ' Se verifica si el binario comienza con un caracter BOM, que indica que esta codificado en utf-8 
                ' El carcater BOM viene representado por  0xef 0xbb 0xbf
                If oSica.bytes(0) = &HEF And oSica.bytes(1) = &HBB And oSica.bytes(2) = &HBF Then
                    Dim bytes(oSica.bytes.Length - 4) As Byte
                    Array.Copy(oSica.bytes, 3, bytes, 0, oSica.bytes.Length - 3)
                    objetoContent = System.Text.Encoding.GetEncoding("UTF-8").GetString(bytes)
                    encoding_implementation = "UTF-8"
                Else
                    objetoContent = System.Text.Encoding.GetEncoding(encoding_implementation).GetString(oSica.bytes)
                End If
            Catch ex As Exception
                objetoContent = ""
            End Try


            'Dim objetoContent_implementation As String = System.Text.Encoding.GetEncoding(encoding_implementation).GetString(oSica.bytes)
            'err.params("objetoContent_implementation") = objetoContent_implementation
            err.params("objetoContent_implementation") = objetoContent
            err.params("objeto") = oSica.objeto
            err.params("extension") = oSica.extension
            err.params("encoding_implementation") = encoding_implementation
        Catch e As Exception
            err.parse_error_script(e)
            'err.response()
        End Try
    End If


    err.response()
%>