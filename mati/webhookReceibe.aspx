<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMatiInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Obtener token cliente
    '--------------------------------------------------------------------------

    Dim err As New tError

    Try
        ' Recuperar el stream de body
        'Dim _request_body_stream_OK As Boolean = IIf(HttpContext.Current.Items("_request_body_stream_OK") Is Nothing, True, HttpContext.Current.Items("_request_body_stream_OK"))
        Dim io As System.IO.Stream = HttpContext.Current.Request.InputStream

        If io.Length > 1 Then ' Solo si el body trae info. puede ser mayor que 0 pero un JSON le pongo 3
            Try
                
                ' Ir al inicio de stream y leerlo
                io.Position = 0
                Dim bufferInput(io.Length - 1) As Byte
                io.Read(bufferInput, 0, bufferInput.Length)
                'Dim errMATI As New tError
                'errMATI = nvFW.nvMATI.saveWebHooks(bufferInput)
                'agregar trhead
                'Dim t As New System.Threading.Thread(Sub(buffer() As Byte)
                '                                         nvFW.nvMATI.saveWebHooks(buffer)
                '                                     End Sub)
                
                't.Start(bufferInput)

            Catch ex As Exception
                
            End Try
        End If

    Catch ex As Exception
        err.numError = -99
        err.mensaje = "Error inesperado. mensaje:" & ex.Message
    End Try

    err.response()


%>