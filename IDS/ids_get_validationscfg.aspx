<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDSInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Obtener la configuración de Validaciones seteadas a partir de:
    '   ID de cliente (ids_cli_id)
    '   ID de recurso (ids_res_id)
    '   ID de evento (ids_event_id)
    '--------------------------------------------------------------------------
    Dim ids_cli_id As Integer = Me.operador.ids_cli_id
    Dim ids_res_id As String = nvUtiles.obtenerValor("ids_res_id", "")
    Dim ids_event_id As String = nvUtiles.obtenerValor("ids_event_id", "")

    ' 1) Consultar en la base de recursos con la combinación ids_res_id + ids_event_id para obtener el ID de configuración de password
    Dim strSQL As String = String.Format("SELECT ids_valcfg_id FROM ids_res_config WHERE ids_cli_id={0} AND ids_res_id='{1}' AND ids_event_id='{2}'", ids_cli_id, ids_res_id, ids_event_id)
    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)

    If rs.EOF Then
        Dim err As New tError
        err.numError = 120
        err.titulo = "API Error"
        err.mensaje = "No se obtuvo ninguna configuración de validaciones con los datos proporcionados"
        err.debug_src = "IDS::ids_get_validationscfg"
        err.response()
    End If

    Dim ids_valcfg_id As String = rs.Fields("ids_valcfg_id").Value
    nvDBUtiles.DBCloseRecordset(rs)

    ' Armado del filtro de consulta
    Dim strFiltro As String = "<criterio><select vista='ids_valcfgs'>" &
                              "<campos>" &
                                "ids_valcfg_id, ids_valcfg, req_email, req_email_cfg_id, req_email_codeLength, req_email_codeTimeout, req_email_codeMaxFails, req_phone, req_phone_text, " &
                                "req_phone_codeLength, req_phone_codeTimeout, req_verazID, req_nosisID, req_dni_frente, req_dni_dorso, req_selfie, val_dni_selfie, val_pre_selfie, " &
                                "val_bio_vida, val_renaper_basico, val_renaper_multifactor, req_facebook, req_google, req_instagram, req_twitter, req_cbu_mov, bpm_process, ids_status_id, " &
                                "ids_valtype_version" &
                              "</campos>" &
                              "<filtro>" &
                                "<ids_cli_id>" & ids_cli_id & "</ids_cli_id>" &
                                "<ids_valcfg_id>'" & ids_valcfg_id & "'</ids_valcfg_id>" &
                              "</filtro><orden></orden></select></criterio>"
    Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

    ' Cargar datos adicionales (necesarios para el getXML) al flujo de la request mediante body stream
    nvUtiles.definirValor("accion", "getterror")
    nvUtiles.definirValor("filtroXML", filtroXML)

    ' Seguir la ejecución en getXML
    Server.Execute("~/FW/getXML.aspx")
%>