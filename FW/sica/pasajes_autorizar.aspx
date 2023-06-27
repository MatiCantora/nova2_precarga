<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor")
    Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema")
    Dim port As String = nvUtiles.obtenerValor("port", "")

    Dim cod_pasajes As String = nvUtiles.obtenerValor("cod_pasajes")
    Dim err As New tError

    ' Permisos
    ' Debe contar con el permiso para autorizar servidor-sistema
    '------------------------------------------------------------
    ' GRUPO:        permisos_sica
    ' PERMISO NRO:  20
    ' PERMISO DESC: Autorizar Pasajes en Servidor Sistemas
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    If Not op.tienePermiso("permisos_sica", 20) Then
        err.numError = -1
        err.mensaje = "No tiene permisos para autorizar pasajes al sistema <b>" & cod_sistema & "</b> en este servidor."
        err.response()
        Return
    End If

    
    Dim cod_pasajes_list() As String = cod_pasajes.Split(",")

    Dim query As String
    Dim rs As ADODB.Recordset
    Dim pasaje_no_autorizado As Boolean
    Dim cod_pasaje_dep As String
    Dim json As New List(Of String)

    For Each cod_pasaje As String In cod_pasajes_list
        query = String.Format("SELECT cod_pasaje FROM nv_servidor_sistema_pasajes_autorizaciones WHERE cod_servidor='{0}' AND cod_sistema='{1}' AND cod_pasaje={2}", cod_servidor, cod_sistema, cod_pasaje)
        rs = nvDBUtiles.ADMDBOpenRecordset(query)
        pasaje_no_autorizado = rs.EOF
        nvDBUtiles.DBCloseRecordset(rs)

        If pasaje_no_autorizado Then
            query = String.Format("SELECT DISTINCT cod_pasaje_depende AS cod_pasaje_dep, level, pasaje_nom FROM nvGetPasajeDependencias({0}) A " &
                                  "WHERE cod_pasaje_depende NOT IN (" &
                                                                    "SELECT cod_pasaje FROM nv_servidor_sistema_pasajes_autorizaciones " &
                                                                    "WHERE cod_servidor='{1}' AND cod_sistema='{2}') " &
                                  "ORDER BY A.level DESC", cod_pasaje, cod_servidor, cod_sistema)
            rs = nvDBUtiles.ADMDBOpenRecordset(query)

            While Not rs.EOF
                cod_pasaje_dep = rs.Fields("cod_pasaje_dep").Value
                query = String.Format("INSERT INTO nv_servidor_sistema_pasajes_autorizaciones(cod_servidor, cod_sistema, cod_pasaje, autorizante, fecha_autorizacion) " &
                                      "VALUES('{0}', '{1}', {2}, {3}, GETDATE())", cod_servidor, cod_sistema, cod_pasaje_dep, nvApp.operador.operador.ToString())
                nvDBUtiles.DBExecute(query)
                rs.MoveNext()
            End While

            nvDBUtiles.DBCloseRecordset(rs)
            query = String.Format("INSERT INTO nv_servidor_sistema_pasajes_autorizaciones(cod_servidor, cod_sistema, cod_pasaje, autorizante, fecha_autorizacion) " &
                                  "VALUES('{0}', '{1}', {2}, {3}, GETDATE())", cod_servidor, cod_sistema, cod_pasaje, nvApp.operador.operador.ToString()) & vbCrLf
            query &= "SELECT a.cod_pasaje, b.nombre_operador, CONVERT(VARCHAR(50), fecha_autorizacion, 103) + ' ' + CONVERT(VARCHAR(50), fecha_autorizacion, 8) AS fecha " &
                     "FROM nv_servidor_sistema_pasajes_autorizaciones a " &
                        "INNER JOIN operadores b ON a.autorizante = b.operador " &
                     "WHERE a.cod_pasaje=" & cod_pasaje
            rs = nvDBUtiles.DBExecute(query)

            json.Add(String.Format("""cod_pasaje"":{0}, ""fecha_autorizacion"":""{1}"", ""autorizante"":""{2}""", cod_pasaje, rs.Fields("fecha").Value, rs.Fields("nombre_operador").Value))
            nvDBUtiles.DBCloseRecordset(rs)
        End If
    Next

    err.params("autorizados") = "[{" & String.Join("},{", json) & "}]"
    err.response()
%>