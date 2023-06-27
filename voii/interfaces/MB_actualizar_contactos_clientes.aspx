<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>
<%
    '--------------------------------------------------------------------------
    ' Consultar maestro de tarjeta
    '--------------------------------------------------------------------------
    Dim tipo_docu As Integer = nvUtiles.obtenerValor("tipo_docu", 0)
    Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "")

    Dim email As String = nvUtiles.obtenerValor("email", "")
    Dim tel_area As String = nvUtiles.obtenerValor("tel_area", "")
    Dim tel_numero As String = nvUtiles.obtenerValor("tel_numero", "")
    Dim tel_tipo As String = nvUtiles.obtenerValor("tel_tipo", "celular")

    Dim nro_entidad As Integer

    Dim er As New terror()

    er.titulo = "Actualizar Datos de Contactos"
    Try

        Dim strSQL As String = "select nro_entidad from entidades where tipo_docu = " & tipo_docu & " and nro_docu = " & nro_docu

        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)
        If Not rs.EOF Then
            nro_entidad = rs.Fields("nro_entidad").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)

        If nro_entidad > 0 Then

            Dim strXML_contacto As String = ""
            strXML_contacto = String.Format(<![CDATA[
			DECLARE @xmldato_contact varchar(max)
            DECLARE @nro_entidad int = {0}
            DECLARE @email varchar(500) = '{1}'
            DECLARE @tel_area varchar(500) = '{2}'
            DECLARE @tel_numero varchar(500) = '{3}'
            
            DECLARE @tel_tipo varchar(500) 
            DECLARE @id_telefono varchar(10) = '0'
            DECLARE @id_email varchar(10) = '0'
            DECLARE @postal_tel as varchar(10) 
            DECLARE @operador as varchar(10) = dbo.rm_nro_operador()
            DECLARE @fecha_estado as varchar(10) = convert(varchar(10), getdate(),103)
            
            select top 1 @postal_tel = postal from localidad where car_tel = @tel_area
   
            if(@postal_tel is null)
             set @postal_tel = ''

            -- telefono
            select top 1 @id_telefono = id_telefono 
            from verContacto_telefono 
            where nro_id_tipo = 1 and id_tipo = @nro_entidad and postal = @postal_tel and telefono = @tel_numero

            -- email 
            select top 1 @id_email = id_email 
            from verContacto_email 
            where nro_id_tipo = 1 and id_tipo = @nro_entidad and email = @email 

            --armar XML

             set @xmldato_contact = '<?xml version="1.0" encoding="iso-8859-1"?>'
             set @xmldato_contact += '<contactos>'
             set @xmldato_contact += '<domicilios><domicilio></domicilio></domicilios >'
  
             If (@tel_numero <> '') 
	         begin
              set @xmldato_contact += '<telefonos>'
              set @xmldato_contact += '<telefono id_telefono ="'+ @id_telefono +'" car_tel="'+ @tel_area +'" telefono ="' + @tel_numero + '" postal ="' + @postal_tel  + '" observacion ="" nro_operador ="'+ @operador +'" fecha_estado ="'+ @fecha_estado +'" nro_contacto_tipo ="99" predeterminado= "1" orden= "1" vigente="True" incorrecto="" id_ro_telefono = ""/>'
              set @xmldato_contact += '</telefonos>'
             end

             If (@email <> '') 
	             begin
                  set @xmldato_contact += '<emails>'
                  set @xmldato_contact += '<email id_email = "'+ @id_email +'" email ="' + @email + '" nro_operador ="'+ @operador +'" fecha_estado ="'+ @fecha_estado +'" observacion ="" nro_contacto_tipo ="99" orden= "1" predeterminado= "1"  vigente="True" incorrecto="False"/>'
                  set @xmldato_contact += '</emails>'
                 end
               set @xmldato_contact += '</contactos>'

			 select @xmldato_contact as xmldato_contact

        ]]>.Value(), nro_entidad, email, tel_area, tel_numero)

            rs = nvFW.nvDBUtiles.DBExecute(strXML_contacto)
            If Not rs.EOF Then
                strXML_contacto = rs.Fields("xmldato_contact").Value
            End If
            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            Dim cmd1 As New nvFW.nvDBUtiles.tnvDBCommand("rm_contacto_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)

            Dim BinaryData() As Byte
            BinaryData = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(strXML_contacto)

            cmd1.Parameters.Append(cmd1.CreateParameter("@strXML0", 205, 1, BinaryData.Length, BinaryData))
            cmd1.Parameters.Append(cmd1.CreateParameter("@id_tipo", 3, 1, 1, nro_entidad))
            cmd1.Parameters.Append(cmd1.CreateParameter("@nro_id_tipo", 3, 1, 1, 1))

            Dim rs1 As ADODB.Recordset = cmd1.Execute()

            er.numError = rs1.Fields("numError").Value
            er.mensaje = rs1.Fields("mensaje").Value

        Else
            er.numError = -99
        End If

        If er.numerror <> 0 Then
            er.mensaje = "No se realizaron cambios sobre los datos de contacto"
            er.params("user_message") = "No se realizaron cambios sobre los datos de contacto"
        End If

    Catch ex As Exception

        er.parse_error_script(ex)
        er.titulo = "Error al actualizar datos de contacto"
        er.mensaje = "Salida por excepción"
        er.debug_src = "mb_ibs_update_cliente"

        er.params("user_message") = "Error al intentar actualizar. Intente más tarde."
    End Try

    er.response()

%>