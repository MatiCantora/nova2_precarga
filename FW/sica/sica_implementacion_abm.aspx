<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim currentApp As Boolean = nvUtiles.obtenerValor("currentApp", True)
    Dim strItems As String = nvUtiles.obtenerValor("strItems", "")
    Dim operador As nvSecurity.tnvOperador = nvFW.nvApp.getInstance().operador
    Dim nvApp As nvFW.tnvApp
    Dim err As New tError


    If currentApp Then
        nvApp = nvFW.nvApp.getInstance()
    Else
        nvApp = New nvFW.tnvApp
        Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor", "")
        Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema", "")
        Dim port As String = nvUtiles.obtenerValor("port", "")
        nvApp.loadFromDefinition(cod_servidor, cod_sistema, port)
    End If

    ' Controlar que tenga permiso para implementar en el servidor sistema
    If Not operador.tienePermiso("permisos_sica", 7) AndAlso Not operador.tienePermiso("permisos_servidor_" & nvApp.cod_servidor & "_sistema_" & nvApp.cod_sistema, 3) Then
        err.numError = -1
        err.mensaje = "Error. No posee permisos para ejecutar la operación solicitada."
        err.response()
    End If


    If strItems Is Nothing OrElse strItems = String.Empty Then
        err.numError = -2
        err.titulo = "Error"
        err.mensaje = "No hay objetos para procesar."
        err.response()
    End If

    Dim xml As New System.Xml.XmlDocument()
    xml.LoadXml(strItems)
    Dim nodes As System.Xml.XmlNodeList = xml.SelectNodes("/objetos/objeto")

    Try
        err.numError = 154
        err.titulo = "Error al ejecutar la tarea"

        Dim cod_objeto As Integer
        Dim cod_obj_tipo As nvSICA.tSicaObjeto.nvEnumObjeto_tipo
        Dim resStatus As nvSICA.nvenumResStatus
        Dim path0 As String
        Dim objeto As String
        Dim cod_modulo_version As Integer
        Dim cod_pasaje As Integer
        Dim oSica As nvSICA.tSicaObjeto

        For Each node As System.Xml.XmlElement In nodes
            cod_objeto = node.GetAttribute("cod_objeto")
            cod_obj_tipo = node.GetAttribute("cod_obj_tipo")
            resStatus = node.GetAttribute("resStatus")
            path0 = node.GetAttribute("path")
            objeto = node.GetAttribute("objeto")
            cod_modulo_version = node.GetAttribute("cod_modulo_version")
            cod_pasaje = If(node.GetAttribute("cod_pasaje") <> "", node.GetAttribute("cod_pasaje"), 0)

            err.mensaje = "No se ha podido realizar la tarea sobre el objeto '" & objeto & "'"

            '**************************************
            ' Actualizar implementación del modulo
            '**************************************
            If resStatus = nvSICA.nvenumResStatus.archivo_sobrante Then
                nvSICA.Implementation.objeto_eliminar(nvApp, cod_obj_tipo, path0, objeto)
            Else
                If resStatus = nvSICA.nvenumResStatus.objeto_modificado OrElse resStatus = nvSICA.nvenumResStatus.objeto_no_econtrado Then
                    oSica = New nvSICA.tSicaObjeto
                    oSica.loadFromDefinition(cod_objeto)
                    oSica.loadModuloVersion(cod_modulo_version, path0, cod_pasaje)
                    oSica.saveToImplementation(nvApp)
                End If
            End If
        Next

        err = New tError
    Catch ex As Exception
        err.parse_error_script(ex)
        err.mensaje = err.debug_desc
    End Try


    err.response()
%>