<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%
    ' GET DEFINICION
    '   cod_objeto
    ' OR
    '   cod_obj_tipo + objeto +  path + cod_modulo_version

    ' GET IMPLEMENTACION
    '   cod_servidor + cod_sistema + port
    '   objeto + path + cod_obj_tipo

    'Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim cod_objeto As String = nvUtiles.obtenerValor("cod_objeto", "")
    Dim path_ori As String = nvUtiles.obtenerValor("path", "")
    Dim cod_obj_tipo As String = nvUtiles.obtenerValor("cod_obj_tipo", "")
    Dim objeto As String = nvUtiles.obtenerValor("objeto", "")
    'Dim cod_modulo_version As String = nvUtiles.obtenerValor("cod_modulo_version", "")
    Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor", "")
    Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema", "")
    Dim port As String = nvUtiles.obtenerValor("port", "")
    Dim encoding_implementation As String = nvUtiles.obtenerValor("encoding", "ISO-8859-1")

    'If encoding_implementation = String.Empty Then encoding_implementation = "ISO-8859-1"

    Dim err As New nvFW.tError
    Dim oSica As nvSICA.tSicaObjeto

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
        oSica.loadFromImplementation(nvApp, cod_obj_tipo, path_ori, objeto, 0, True)

        Dim objetoContent As String = ""

        ' Encerrar con try-catch porque el binario puede no estar cargado
        Try
            If oSica.bytes.Count = 1 AndAlso oSica.bytes(0) = &H0 Then
                objetoContent = ""
            Else
                ' Se verifica si el binario comienza con un caracter BOM, que indica que esta codificado en utf-8 
                ' El carcater BOM viene representado por  0xef 0xbb 0xbf
                If oSica.bytes(0) = &HEF AndAlso oSica.bytes(1) = &HBB AndAlso oSica.bytes(2) = &HBF Then
                    Dim bytes(oSica.bytes.Length - 4) As Byte
                    Array.Copy(oSica.bytes, 3, bytes, 0, oSica.bytes.Length - 3)
                    objetoContent = System.Text.Encoding.GetEncoding("UTF-8").GetString(bytes)
                    encoding_implementation = "UTF-8"
                Else
                    objetoContent = System.Text.Encoding.GetEncoding(encoding_implementation).GetString(oSica.bytes)
                End If
            End If
        Catch ex As Exception
            err.numError = 101
            err.titulo = "Error"
            err.mensaje = "No se cargo el binario desde la implementación solicitada"
            objetoContent = ""
        End Try

        ' Si el contenido es XSL o XML encerrarlo con CDATA porque tError se puede romper
        err.params("objetoContent") = If(oSica.extension <> ".xsl" AndAlso oSica.extension <> ".xml", objetoContent, "<![CDATA[" & objetoContent & "]]>")
        err.params("objeto") = oSica.objeto
        ' Si el objeto SICA es de tipo TABLA, definir la extensión como XML (ya que ahora viene embebido en un documento XML)
        err.params("extension") = If(oSica.extension <> "", oSica.extension, If(oSica.cod_obj_tipo = nvSICA.tSicaObjeto.nvEnumObjeto_tipo.tabla, ".xml", ""))
        err.params("encoding") = encoding_implementation
        err.params("cod_obj_tipo") = oSica.cod_obj_tipo
    Catch e As Exception
        err.parse_error_script(e)
    End Try

    err.response()
%>