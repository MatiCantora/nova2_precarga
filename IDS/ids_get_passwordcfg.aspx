<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Obtener las configuraciones de Password a partir de:
    '   ID de cliente (ids_cli_id)
    '   ID de recurso (ids_res_id)
    '   ID de evento (ids_event_id)
    '--------------------------------------------------------------------------
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")

    ' 1) Consultar en la base de recursos con la combinación ids_res_id + ids_event_id para obtener el ID de configuración de password
    Dim strSQL As String = String.Format("SELECT ids_pwdcfg_id FROM ids_res_config WHERE ids_cli_id={0} AND ids_res_id='{1}' AND ids_event_id='{2}'", ids_cli_id, ids_res_id, ids_event_id)
    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)

    If rs.EOF Then
        Dim err As New tError
        err.numError = 120
        err.titulo = "API Error"
        err.mensaje = "No se obtuvo ninguna configuración de password con los datos proporcionados"
        err.debug_src = "IDS::ids_get_passwordcfg"
        err.response()
    End If

    Dim ids_pwdcfg_id As Integer = rs.Fields("ids_pwdcfg_id").Value
    nvDBUtiles.DBCloseRecordset(rs)

    ' Armado del filtro de consulta
    Dim strFiltro As String = "<criterio><select vista='ids_pwdcfgs'>" &
                              "<campos>ids_pwdcfg_id, ids_pwdcfg, pwd_minlength, pwd_maxlength, pwd_includeUpperCase, pwd_includeLowerCase, pwd_includeSpecialChars, pwd_maxPasswordAge, " &
                                    "pwd_minPasswordAge, pwd_LockoutThreshold, pwd_LockoutObsWin, pwd_LockoutDuration, pwd_historyDays, pwd_version</campos>" &
                              "<filtro>" &
                                "<ids_cli_id>'" & ids_cli_id & "'</ids_cli_id>" &
                                "<ids_pwdcfg_id>'" & ids_pwdcfg_id & "'</ids_pwdcfg_id>" &
                              "</filtro><orden></orden></select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales (necesarios para el getXML) al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>