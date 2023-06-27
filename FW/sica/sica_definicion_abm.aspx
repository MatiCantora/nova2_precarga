<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim currentApp As Boolean = nvUtiles.obtenerValor("currentApp", True)
    Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor")
    Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema")
    Dim port As String = nvUtiles.obtenerValor("port")
    Dim strItems As String = nvUtiles.obtenerValor("strItems", "")

    Dim cod_objeto As String
    Dim cod_obj_tipo As nvSICA.tSicaObjeto.nvEnumObjeto_tipo
    Dim resStatus As nvSICA.nvenumResStatus
    Dim path0 As String
    Dim objeto As String
    Dim cod_modulo_version As String
    Dim path_destino As String
    Dim cod_sub_tipo As String
    Dim binary As Byte() = Nothing
    Dim strValue As String
    Dim depende_de As String
    Dim cod_pasaje As Integer
    Dim es_baja As Boolean

    Dim op As nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
    Dim nvApp As nvFW.tnvApp = Nothing

    If currentApp Then
        nvApp = nvFW.nvApp.getInstance()
    ElseIf cod_servidor <> "" Then
        nvApp = New nvFW.tnvApp
        nvApp.loadFromDefinition(cod_servidor, cod_sistema, port)
    End If

    Dim err As New tError
    Dim xml As New System.Xml.XmlDocument()
    xml.LoadXml(strItems)

    '<?xml version='1.0'?>
    '  <objetos>
    '    <objeto objeto='App_Code' path='%RAIZ%\' path_destino='%RAIZ%\' cod_obj_tipo='4' cod_modulo_version='806' resStatus='3' include_all='true' />
    '  </objetos>

    ' Si es una carpeta y está marcada como "include_all" se deden incluir todos los archivos y carpetas dependientes
    Dim nodesFolder As System.Xml.XmlNodeList = xml.SelectNodes("/objetos/objeto[@cod_obj_tipo='4' and @include_all='true' and @resStatus='3']")
    Dim nodeFolder As System.Xml.XmlNode
    Dim sicaFolder As nvSICA.tSicaObjeto
    Dim path_initial As String
    Dim path_detino_folder As String
    Dim dir As IO.DirectoryInfo
    Dim pila As Stack(Of IO.DirectoryInfo)
    Dim directories() As IO.DirectoryInfo
    Dim files() As IO.FileInfo
    Dim element As System.Xml.XmlElement
    Dim path As String

    For Each nodeFolder In nodesFolder
        path_initial = nodeFolder.Attributes("path").Value
        depende_de = nvXMLUtiles.getAttribute_path(nodeFolder, "@depende_de", "0")
        cod_pasaje = nvXMLUtiles.getAttribute_path(nodeFolder, "@cod_pasaje", "0")
        cod_modulo_version = nodeFolder.Attributes("cod_modulo_version").Value
        path_detino_folder = nodeFolder.Attributes("path_destino").Value
        sicaFolder = New nvSICA.tSicaObjeto
        sicaFolder.loadFromImplementation(nvApp, nvSICA.tSicaObjeto.nvEnumObjeto_tipo.directorio, nodeFolder.Attributes("path").Value, nodeFolder.Attributes("objeto").Value, 0)
        dir = New IO.DirectoryInfo(sicaFolder.physical_path)
        pila = New Stack(Of IO.DirectoryInfo)
        pila.Push(dir)

        While pila.Count > 0
            dir = pila.Pop
            directories = dir.GetDirectories("*.*")

            For i = LBound(directories) To UBound(directories)
                path = nvSICA.path.PhysicalToLogical(nvApp, directories(i).Parent.FullName) & "\"
                path_destino = directories(i).Parent.FullName.Replace(sicaFolder.physical_path, "")
                path_destino = path_detino_folder & sicaFolder.objeto & path_destino & "\"
                element = xml.CreateElement("objeto")
                element.SetAttribute("objeto", directories(i).Name)
                element.SetAttribute("path", path)
                element.SetAttribute("path_destino", path_destino)
                element.SetAttribute("cod_modulo_version", cod_modulo_version)
                element.SetAttribute("cod_obj_tipo", nvSICA.tSicaObjeto.nvEnumObjeto_tipo.directorio)
                element.SetAttribute("depende_de", depende_de)
                element.SetAttribute("cod_pasaje", cod_pasaje)
                element.SetAttribute("resStatus", nvSICA.nvenumResStatus.archivo_sobrante)
                xml.SelectSingleNode("/objetos").AppendChild(element)
                pila.Push(directories(i))
            Next

            files = dir.GetFiles("*.*")

            For i = LBound(files) To UBound(files)
                path = nvSICA.path.PhysicalToLogical(nvApp, files(i).DirectoryName) & "\"
                path_destino = files(i).DirectoryName.Replace(sicaFolder.physical_path, "")
                path_destino = path_detino_folder & sicaFolder.objeto & path_destino & "\"
                element = xml.CreateElement("objeto")
                element.SetAttribute("objeto", files(i).Name)
                element.SetAttribute("path", path)
                element.SetAttribute("path_destino", path_destino)
                element.SetAttribute("cod_modulo_version", cod_modulo_version)
                element.SetAttribute("cod_obj_tipo", nvSICA.tSicaObjeto.nvEnumObjeto_tipo.archivo)
                element.SetAttribute("depende_de", depende_de)
                element.SetAttribute("cod_pasaje", cod_pasaje)
                element.SetAttribute("resStatus", nvSICA.nvenumResStatus.archivo_sobrante)
                xml.SelectSingleNode("/objetos").AppendChild(element)
            Next
        End While
    Next

    Dim nodes As System.Xml.XmlNodeList = xml.SelectNodes("/objetos/objeto")
    Dim cn As New ADODB.Connection
    Dim cod_mod As New Dictionary(Of Integer, String)

    Try
        cn = nvDBUtiles.ADMDBConectar()
        cn.BeginTrans()
        Dim cont As Integer = 0
        Dim rs As ADODB.Recordset
        Dim oSica As nvSICA.tSicaObjeto

        For Each node As System.Xml.XmlElement In nodes
            cont += 1
            cod_objeto = nvXMLUtiles.getAttribute_path(node, "@cod_objeto", "")
            cod_obj_tipo = nvXMLUtiles.getAttribute_path(node, "@cod_obj_tipo", "0")
            resStatus = nvXMLUtiles.getAttribute_path(node, "@resStatus")
            path0 = nvXMLUtiles.getAttribute_path(node, "@path")
            objeto = nvXMLUtiles.getAttribute_path(node, "@objeto")
            cod_modulo_version = nvXMLUtiles.getAttribute_path(node, "@cod_modulo_version")
            path_destino = nvXMLUtiles.getAttribute_path(node, "@path_destino", "")
            cod_sub_tipo = nvXMLUtiles.getAttribute_path(node, "@cod_sub_tipo", "")
            depende_de = nvXMLUtiles.getAttribute_path(node, "@depende_de", "0")
            cod_pasaje = nvXMLUtiles.getAttribute_path(node, "@cod_pasaje", "0")
            es_baja = nvXMLUtiles.getAttribute_path(node, "@es_baja", False)
            binary = Nothing
            strValue = nvXMLUtiles.getNodeText(node, "value", "")

            If strValue <> "" Then binary = nvConvertUtiles.StringToBytes(strValue)
            If path_destino = "" Then path_destino = path0

            oSica = New nvSICA.tSicaObjeto

            ' Controlar que tenga permiso para editar el módulo
            If Not cod_mod.ContainsKey(cod_modulo_version) Then
                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_modulo FROM nv_modulo_version WHERE cod_modulo_version=" & cod_modulo_version)

                If Not rs.EOF Then cod_mod(cod_modulo_version) = rs.Fields("cod_modulo").Value

                nvDBUtiles.DBCloseRecordset(rs)
            End If

            If Not op.tienePermiso("permisos_sica", 12) AndAlso Not op.tienePermiso("permisos_modulo_" & cod_mod(cod_modulo_version), 2) Then
                Throw New Exception("Error. No posee permisos para ejecutar la operación solicitada.")
            End If

            '**********************************
            ' Actualizar definicion del modulo
            '**********************************
            If resStatus = nvSICA.nvenumResStatus.objeto_no_econtrado Then ' borrar definicion de objeto
                nvSICA.Definition.objeto_eliminar(cod_modulo_version, cod_objeto, path0, cod_pasaje:=cod_pasaje, cn:=cn)
            Else
                If resStatus = nvSICA.nvenumResStatus.objeto_modificado OrElse resStatus = nvSICA.nvenumResStatus.archivo_sobrante Then
                    If cod_objeto = "" Then
                        Dim loadBinary As Boolean = If(Not binary Is Nothing AndAlso binary.Length > 0, False, True)
                        oSica.loadFromImplementation(nvApp, cod_obj_tipo, path0, objeto, 0, loadBinary, binary)
                    Else
                        oSica.loadFromDefinition(cod_objeto)
                    End If

                    oSica.modulo_version_path = path_destino

                    If cod_sub_tipo <> "" Then oSica.modulo_version_cod_sub_tipo = cod_sub_tipo

                    oSica.saveToDefinition(cod_modulo_version, cn:=cn, depende_de:=depende_de, cod_pasaje:=cod_pasaje, es_baja:=es_baja)

                    ' guarda el cod_objeto del ultimo objeto creado:
                    ' Usado en las altas que se realizan de una a la vez, como en creación de un objeto script de pasaje
                    err.params("cod_objeto") = oSica.cod_objeto
                End If
            End If
        Next

        cn.CommitTrans()
    Catch ex As Exception
        Try
            cn.RollbackTrans()
        Catch ex1 As Exception
        End Try

        err.parse_error_script(ex)
        err.mensaje = err.debug_desc
    Finally
        nvDBUtiles.DBDesconectar(cn)
    End Try

    err.response()
%>