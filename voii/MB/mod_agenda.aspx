<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' insertar log
    '--------------------------------------------------------------------------

    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim tipo_docu As Integer = nvUtiles.obtenerValor("tipo_docu", 0)
    Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "")
    Dim cbu As String = nvUtiles.obtenerValor("cbu", "")
    Dim [alias] As String = nvUtiles.obtenerValor("alias", "")

    Dim er As New terror()
    If modo = "" Then
        er.numError = -99
        er.titulo = "Error de consulta"
        er.mensaje = "Acción es desconocido."
        er.debug_src = ""
        er.response()
    End If

    If modo = "C" Then

        Dim strFiltro As String = "<criterio><select vista='verCliente_contacto'>" &
        "<campos>*</campos>" &
        "<filtro><vigente type='igual'>1</vigente>" &
        "<tipo_docu type='igual'>" & tipo_docu & "</tipo_docu>" &
        "<nro_docu type='igual'>" & nro_docu & "</nro_docu></filtro>" &
        "<orden></orden>" &
        "</select></criterio>"
        Dim filtroXML As String = nvXMLSQL.encXMLSQL(strFiltro)

        ' Cargar datos adicionales al flujo de la request mediante body stream
        nvUtiles.definirValor("accion", "getterror")
        nvUtiles.definirValor("filtroXML", filtroXML)

        ' Seguir la ejecución en getXML
        Server.Execute("~/FW/getXML.aspx")

    End If

    If "ABM".IndexOf(modo) <> -1 Then


        Try
            'Dim tipdoc_cli As Integer = nvUtiles.obtenerValor("tipdoc_cli", "")
            'Dim nrodoc_cli As String = nvUtiles.obtenerValor("nrodoc_cli", "")
            'Dim cbu As String = nvUtiles.obtenerValor("cbu", "")
            'Dim [alias] As String = nvUtiles.obtenerValor("alias", "")
            Dim moneda As String = nvUtiles.obtenerValor("moneda", "032")
            Dim cuitcuil As String = nvUtiles.obtenerValor("cuitcuil", "")
            Dim razon_social As String = nvUtiles.obtenerValor("razon_social", "")
            Dim email As String = nvUtiles.obtenerValor("email", "")
            Dim phone As String = nvUtiles.obtenerValor("phone", "")
            Dim referencia As String = nvUtiles.obtenerValor("referencia", "")
            Dim banco As String = nvUtiles.obtenerValor("banco", "")
            Dim nro_cta As String = nvUtiles.obtenerValor("nro_cta", "")
            Dim esCta_propia As Integer = nvUtiles.obtenerValor("esCta_propia", 0)
            Dim mismoTitular As Integer = nvUtiles.obtenerValor("mismoTitular", 0)
            Dim campo01 As String = nvUtiles.obtenerValor("campo01", "")
            Dim campo02 As String = nvUtiles.obtenerValor("campo02", "")
            Dim campo03 As String = nvUtiles.obtenerValor("campo03", "")
            Dim campo04 As String = nvUtiles.obtenerValor("campo04", "")
            Dim campo05 As String = nvUtiles.obtenerValor("campo05", "")
            Dim campo06 As String = nvUtiles.obtenerValor("campo06", "")
            Dim campo07 As String = nvUtiles.obtenerValor("campo07", "")
            Dim campo08 As String = nvUtiles.obtenerValor("campo08", "")
            Dim campo09 As String = nvUtiles.obtenerValor("campo09", "")
            Dim campo10 As String = nvUtiles.obtenerValor("campo10", "")
            Dim campocbu01 As String = nvUtiles.obtenerValor("campocbu01", "")
            Dim campocbu02 As String = nvUtiles.obtenerValor("campocbu02", "")
            Dim campocbu03 As String = nvUtiles.obtenerValor("campocbu03", "")
            Dim campocbu04 As String = nvUtiles.obtenerValor("campocbu04", "")
            Dim campocbu05 As String = nvUtiles.obtenerValor("campocbu05", "")

            Dim cmd As New nvDBUtiles.tnvDBCommand("dbo.mb_cliente_contactos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, modo)
            cmd.addParameter("@tipo_docu", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, -1, tipo_docu)
            cmd.addParameter("@nro_docu", ADODB.DataTypeEnum.adBigInt, ADODB.ParameterDirectionEnum.adParamInput, -1, nro_docu)
            cmd.addParameter("@cuitcuil", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, cuitcuil)
            cmd.addParameter("@moneda", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, moneda)
            cmd.addParameter("@cbu", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, cbu)
            cmd.addParameter("@alias", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, [alias])
            cmd.addParameter("@razon_social", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, razon_social)
            cmd.addParameter("@email", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, email)
            cmd.addParameter("@phone", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, phone)
            cmd.addParameter("@referencia", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, referencia)
            cmd.addParameter("@banco", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, banco)
            cmd.addParameter("@nro_cta", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, nro_cta)
            cmd.addParameter("@esCta_propia", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, -1, esCta_propia)
            cmd.addParameter("@mismoTitular", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, -1, mismoTitular)
            cmd.addParameter("@campo01", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo01)
            cmd.addParameter("@campo02", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo02)
            cmd.addParameter("@campo03", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo03)
            cmd.addParameter("@campo04", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo04)
            cmd.addParameter("@campo05", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo05)
            cmd.addParameter("@campo06", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo06)
            cmd.addParameter("@campo07", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo07)
            cmd.addParameter("@campo08", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo08)
            cmd.addParameter("@campo09", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo09)
            cmd.addParameter("@campo10", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campo10)
            cmd.addParameter("@campocbu01", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campocbu01)
            cmd.addParameter("@campocbu02", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campocbu02)
            cmd.addParameter("@campocbu03", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campocbu03)
            cmd.addParameter("@campocbu04", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campocbu04)
            cmd.addParameter("@campocbu05", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, campocbu05)

            Dim rs As ADODB.Recordset = cmd.Execute()

            If Not rs.EOF Then
                er.numError = rs.Fields("numError").Value
                er.mensaje = rs.Fields("mensaje").Value
                er.titulo = rs.Fields("titulo").Value
            End If


        Catch ex As Exception
            er.numError = -99
            er.titulo = "Error de agenda"
            er.mensaje = "La acción es desconocido. " & ex.message
            er.debug_src = "Contants"
        End Try

        er.response()

    End If


%>