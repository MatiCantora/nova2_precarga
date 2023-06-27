<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%@ Import Namespace="nvFW.nvDBUtiles" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%    

    Dim err As New nvFW.tError
    Dim nro_archivo As Integer = nvFW.nvUtiles.obtenerValor("nro_archivo", "0") 'obtenerValor("nro_archivo")
    Dim path_archivo As String

    Dim server_name As String = nvApp.cod_servidor
    Try
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select path, descripcion from archivos where nro_archivo=" & nro_archivo)
        Dim nombre_archivo As String = rs.Fields("path").Value
        Dim descripcion_archivo As String = isNUll(rs.Fields("descripcion").Value, "") & " - " & nro_archivo
        Dim path_rova As String = ""
        path_archivo = ""
        ''Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = 'nv_mutual' and cod_servidor = '" & server_name & "'")
        Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select distinct path from nvAdmin.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select distinct cod_ss_dir from  nvAdmin.dbo.nv_servidor_sistema_dir) And [path]<>'' and cod_sistema = 'nv_mutuales' and cod_servidor = '" & server_name & "'")
        While Not rsRova.EOF
            path_rova = rsRova.Fields("path").Value.Replace("\", "\\")
            path_archivo = path_rova & nombre_archivo
            If (System.IO.File.Exists(path_archivo)) Then
                Exit While
            End If
            rsRova.MoveNext()
        End While
        'path_archivo = "\\" & server_name & "\d$\MeridianoWeb\Meridiano\archivos\" & nombre_archivo
        If (path_archivo <> "") Then
            Dim extension As String = System.IO.Path.GetExtension(path_archivo)
            Dim name As String = descripcion_archivo & extension 'System.IO.Path.GetFileName(path_archivo)
            Dim rs1 As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("Select top 1 mime_type from Mime_type where extencion='" & extension.Substring(1) & "'")
            If rs1.EOF = True Then
                Response.Redirect("../errores_personalizados/error_600.html")
            Else

                Dim fileMode As String = "attachment"
                If Request.Browser.IsMobileDevice = True Then
                    fileMode = "attachment"
                Else
                    fileMode = "inline"
                End If

                Response.AddHeader("Content-Disposition", fileMode + ";filename=" + name)
                Response.ContentType = rs1.Fields("mime_type").Value
                'Response.AddHeader("filename", name)


                If Request.HttpMethod = "HEAD" Then  ' Agregado para que el download Manager de android consulte el nombre del archivo por head request
                    Dim buffer(-1) As Byte
                    Response.BinaryWrite(buffer)
                    Response.End()
                Else
                    Dim objStream As System.IO.Stream
                    Dim FileSize As Long
                    objStream = New System.IO.FileStream(path_archivo, System.IO.FileMode.Open)
                    FileSize = objStream.Length
                    Dim Buffer(CInt(FileSize)) As Byte
                    objStream.Read(Buffer, 0, CInt(FileSize))
                    objStream.Close()
                    Response.BinaryWrite(Buffer)
                    Response.End()
                End If
            End If

        Else
            err.numError = 101
            err.titulo = "Error archivo"
            err.mensaje = "El archivo especificado no se encuentra en el directorio de archivos."
            err.debug_src = "get_file.aspx"
            err.debug_desc = "archivo inexistente"

        End If
    Catch ex As Exception
        err.parse_error_script(ex)
    End Try
    err.response()
















 %>