<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    ' Agregar un nuevo recurso para el cliente seleccionado
    Dim action As String = obtenerValor({"action", "ac"}, "")
    Dim ids_deviceid As String = obtenerValor("ids_deviceid", "")
    Dim ids_device As String = obtenerValor("ids_device", "")
    Dim ids_device_desc As String = obtenerValor("ids_device_desc", "")
    Dim publicKeyB64 As String = obtenerValor("publicKeyB64", "")

    Dim err As New tError
    Select Case action.ToLower
        Case "alta"
            err = nvFW.nvIDS.nvDevice.add(operador.ids_cli_id, ids_deviceid, ids_device, ids_device_desc, publicKeyB64)
            err.response()

        Case "baja"
            err = nvFW.nvIDS.nvDevice.remove(operador.ids_cli_id, ids_deviceid)
            err.response()

        Case "modificacion"
            'no se puede modificar un dispositivo
        Case Else

            err.numError = 15
            err.titulo = "Error en la llamada"
            err.mensaje = "La acción no existe"
            err.debug_src = "ids_device_abm"
            err.response()
    End Select

%>