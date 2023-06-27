<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 

    Me.contents.Add("verStatsPrecarga", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verStatsPrecarga'><campos>aprobados, manual, rechazados, total, cred_liq, cred_gestion</campos><orden></orden><filtro><nro_operador type='igual'>%nro_operador%</nro_operador></filtro></select></criterio>"))

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador As Integer = op.operador

    ' Si no tiene los permisos necesarios, no lo dejo seguir
    'If (Not op.tienePermiso("permisos_precarga", 16)) Then

    '    Response.Redirect("/FW/error/httpError_401.aspx")

    'End If

    'Dim rs
    'Dim err As New tError()

    'Try

    '    rs = nvDBUtiles.DBOpenRecordset("select id_transf_log as id_calificacion, fe_inicio as fecha, cuil, nro_docu, apellido, nombres, dictamen from [horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1 where fe_inicio >= dbo.finac_inicio_mes(getdate()) and operador_det = " & nro_operador)

    '    If (Not rs.EOF) Then

    '        Dim id_calificacion As String = rs.Fields("id_calificacion").Value
    '        Dim fecha As String = rs.Fields("fecha").Value
    '        Dim cuil As String = rs.Fields("cuil").Value
    '        Dim nro_docu As String = rs.Fields("nro_docu").Value
    '        Dim apellido As String = rs.Fields("apellido").Value
    '        Dim nombres As String = rs.Fields("nombres").Value
    '        Dim dictamen As String = rs.Fields("dictamen").Value

    '    End If

    '    nvDBUtiles.DBCloseRecordset(rs)

    '    Me.contents("id_calificacion") = id_calificacion
    '    Me.contents("fecha") = fecha
    '    Me.contents("cuil") = cuil
    '    Me.contents("nro_docu") = nro_docu
    '    Me.contents("apellido") = apellido
    '    Me.contents("nombres") = nombres
    '    Me.contents("dictamen") = dictamen

    'Catch ex As Exception
    '    err.numError = -1
    '    err.mensaje = ex.Message
    '    err.debug_desc = ex.Message
    '    err.titulo = "Error"
    'End Try

    'Me.contents("statType") = nvFW.nvUtiles.obtenerValor("type", "")
    'Me.contents("nro_operador") = nro_operador

    ''select id_transf_log as id_calificacion, fe_inicio as fecha, cuil, nro_docu, apellido, nombres, dictamen from [horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1 where fe_inicio >= dbo.finac_inicio_mes(getdate()) and operador_det = 
    'Me.contents("filtro_verEstadisticas_consultas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>id_transf_log as id_calificacion, fe_inicio as fecha, cuil, nro_docu, apellido, nombres, dictamen, explicacion</campos><orden></orden><filtro></filtro></select></criterio>")

    'Me.contents("filtro_verEstadisticas_consultas2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>id_calificacion, fe_inicio as fecha, nro_docu, apellido + ', ' + nombres as razon_social, dictamen, explicacion</campos><orden></orden><filtro></filtro></select></criterio>")

    ''select * from VerAutogestion_creditos where fe_inicio >= dbo.finac_inicio_mes(getdate()) and nro_operador = 12872
    'Me.contents("filtro_verEstadisticas_creditos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerAutogestion_creditos' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>nro_docu, razon_social, banco, mutual, estado, descripcion_estado, fecha, importe_retirado, importe_solicitado</campos><orden></orden><filtro></filtro></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="initial-scale=1">
    <title>Estadísticas</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>
    <script type="text/javascript" src="../script/estadisticas.js"></script>

    <% = Me.getHeadInit()%>
   
    <script type="text/javascript">

    
        function window_onload() {
            cargarValoresEstadisticas();
        }

       

    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">

    <div id="vMenuLeft.menuMobile" style="margin: 0px; padding: 0px; width:100%; height:100%"></div>

</body>
</html>
