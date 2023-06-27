<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Microsoft.Office.Interop" %>

<%
   
    Me.contents("filtroBatch") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPerfiles_batch'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("filtroParametro_transf") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("filtroCampoDef_parametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros'><campos>parametro as id, parametro as [campo]</campos><orden>[campo]</orden></select></criterio>")
    'Me.contents("procesos_ejecutados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verProceso_trasferencia'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("procesos_ejecutados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPerfiles_rel_procesos'><campos>*</campos><orden>nro_proceso asc</orden></select></criterio>")
    Me.contents("ver_log_transf_det") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_det'><campos>id_transf_log_det</campos><orden>id_transf_log_det</orden></select></criterio>")
    Me.contents("ver_log_transf_param") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_param'><campos>parametro, valor</campos><orden></orden></select></criterio>")
    Me.contents("verProcesos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verProcesos'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("exportarParam") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.perfiles_batch_export_param' CommantTimeOut='1500'><parametros><nro_proceso DataType='int'>%nro_proceso%</nro_proceso></parametros></procedure></criterio>")

    Dim edicion = nvFW.nvUtiles.obtenerValor("edicion", False)
    Dim id_batch = nvFW.nvUtiles.obtenerValor("id_batch", 0)
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    Dim strXML As String = nvUtiles.obtenerValor("strXML", "")
    Dim parametros As String = nvUtiles.obtenerValor("parametros", "")
    Dim nro_proceso As Integer = nvUtiles.obtenerValor("nro_proceso", 0)
    Dim hojaExcel = nvFW.nvUtiles.obtenerValor("hojaExcel", "Hoja1")
    Dim Er = New nvFW.tError


    '*********guardar proceso********
    If accion.ToLower() = "guardar" Then
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("perfiles_batch_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , "M")
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
            cmd.addParameter("@datos_excel", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, , DBNull.Value)
            cmd.addParameter("@parametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , parametros)
            Dim rs As ADODB.Recordset = cmd.Execute()
            Er = New nvFW.tError(rs)
        Catch e As Exception
            Er.parse_error_xml(e)
            Er.numError = 100
            Er.mensaje = "No se pudo guardar el proceso."
        End Try
        Er.response()
    End If

    '************** Procesar batch*****************
    If accion.ToLower() = "procesar" Then
        Try
            Dim id_transferencia As Integer
            Dim primera_fila As Boolean
            Dim parametrosStr As String = ""
            Dim nombre_excel As String = ""
            Dim nombre_hoja As String = ""
            Dim rs_xml As Byte() = Nothing
            Dim cantRegistrosAprocesar As Integer = 0

            ' Leer los datos del batch
            Dim rs_batch As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from verPerfiles_batch where id_bpm_batch = " + id_batch)
            If Not rs_batch.EOF Then
                id_transferencia = rs_batch.Fields("id_transferencia").Value
                primera_fila = rs_batch.Fields("primera_fila_excel").Value
                parametrosStr = rs_batch.Fields("parametros").Value
                nombre_excel = rs_batch.Fields("nombre_excel").Value
                nombre_hoja = rs_batch.Fields("hoja_selecc").Value
                rs_xml = rs_batch.Fields("rs_xml").Value
            End If
            nvDBUtiles.DBCloseRecordset(rs_batch)

            'Cargar los parmetros de la transferncia asociados al excel
            Dim param_xml As New System.Xml.XmlDocument
            Try
                param_xml.LoadXml(parametrosStr)
            Catch e As Exception
                Er.parse_error_script(e)
                Er.mensaje = "Error al leer los parametros."
                Er.numError = 101
                Er.response()
            End Try


            '*Crear el objeto transferencia a partir del id_transferencia
            Dim transf As New nvTransferencia.tTransfererncia
            Dim errTransf As tError = transf.cargar(id_transferencia)
            If errTransf.numError <> 0 Then 'Salir
                Er = errTransf
                Er.mensaje = "Error al cargar la transferencia. \n Nro transferencia: " + id_transferencia
                Er.titulo = "Error en el objeto transferencia"
                Er.response()
            End If
               
             
            ' Cargar el excel en un recorset para recorrerlo luego al ejecutar la batch
            Dim path_modelo = System.IO.Path.GetTempFileName() + ".xls"
            
            System.IO.File.WriteAllBytes(path_modelo, rs_xml)
            
            
            ''********
            'Dim exAPP As Excel.Application = New Excel.Application
            'exAPP.Visible = true
            'exAPP.DisplayAlerts = true
            'Dim exLibro As Excel.Workbook
            'exLibro = exAPP.Workbooks.Open(path_modelo)
            'exLibro.SaveAs()

            'Dim ohoja As Excel.Worksheet
            
            Dim rs As New ADODB.Recordset
            Try
                Dim excel As New nvFW.tExcel
                excel.filename = path_modelo
                ' Stop 
                rs = excel.ExcelLeerDatos3(primera_fila, hojaExcel)
                
                'Dim terr As New tError
                'terr = excel.ExcelLeerDatos2(primera_fila, hojaExcel)
                'If terr.numError <> 0 Then
                '    System.IO.File.Delete(path_modelo)
                    
                'Else
                '    terr.numError = 0
                '    terr.mensaje = "ok"
                '    System.IO.File.Delete(path_modelo)
                '    cantRegistrosAprocesar = excel.adoRecordset.RecordCount
                'End If
                 
                
                'terr.response()
                cantRegistrosAprocesar = rs.RecordCount
                
            Catch ex As Exception
                System.IO.File.Delete(path_modelo)
                nvDBUtiles.DBCloseRecordset(rs)
                Er.parse_error_script(ex)
                Er.mensaje = "Error al leer el archivo excel. " + ex.Message
                Er.numError = 102
                Er.response()
            End Try
              
            'Validar que los parametros requeridos de la transferencia tengan asociado una columna del excel
            Dim paramExcel As System.Xml.XmlNodeList = param_xml.SelectNodes("parametros/parametro")
            For Each p In transf.param.Values
                Dim req = False
                If p("requerido") Then  'Tiene que estar en la definici�n del excel
                    For Each c In paramExcel
                        If p("parametro").ToString = c.Attributes("valor").value Then
                            req = True
                            Exit For
                        End If
                    Next
                    If req = False Then
                        Er.numError = 100
                        Er.mensaje = "La transferencia tiene parametros requeridos que no fueron asignados a una columna del archivo. Parametro: " + p("parametro")
                        Er.titulo = "Error en los parametros de la transferencia"
                        nvDBUtiles.DBCloseRecordset(rs)
                        Er.response()
                        Exit For
                    End If
                End If
            Next
             
            '** Crear Proceso **     
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_prCrearProceso", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@tipo_proceso", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , "TB")
            cmd.addParameter("@observaciones", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , "Ejecucion batch transferencias")
            Dim rs0 As ADODB.Recordset = cmd.Execute(True, True)
            nro_proceso = cmd.Parameters("@RETURN_VALUE").Value
            DBCloseRecordset(rs0)

            Er.params("nro_proceso") = nro_proceso
            Er.params("status") = "Ejecutando"

            'Actualizar en el proceso cantidad de registros a procesar y estado 2 (ejecutando)
            nvFW.nvDBUtiles.DBExecute("update procesos set cantidad_registros = " + cantRegistrosAprocesar.ToString + " , pr_estado = 2 where nro_proceso = " + nro_proceso.ToString)
            nvFW.nvDBUtiles.DBExecute("insert into perfiles_batch_rel_proceso (id_bpm_batch , nro_proceso) values (" & id_batch & " , " & nro_proceso & ")")


            
            Dim oHTTP As New nvHTTPRequest
            
            If transf.transf_version = "1.0" Then
                '*Crear el objeto http para las transferencias 1.0* 
                '//obtener puerto
                Dim ports As nvServer.tParPorts = nvServer.getPortsTransf(nvApp.server_name)
                Dim protocolo As String = nvApp.server_protocol
                Dim port As Integer
                If nvApp.server_protocol = "https" Then
                    port = ports.https
                Else
                    port = ports.http
                End If
                
                Dim URL As String = protocolo & "://" & nvApp.server_name & ":" & port
                
                 
                Dim hash As String = ""
                Try
                    Dim Er_hash = nvLogin.execute(nvApp, "get_hash", nvApp.operador.login, "", "", "", "", "")
                    hash = Er_hash.params("hash")
                Catch e As Exception
                End Try

               
                oHTTP.url = URL & "/FW/Transferencia/transf_ejecutar.asp"
                oHTTP.persistSession = True
                oHTTP.param_add("async", "false")
                oHTTP.param_add("id_transferencia", id_transferencia)
                oHTTP.param_add("app_cod_sistema", "nv_mutual")
                oHTTP.param_add("app_path_rel", nvApp.path_rel)
                oHTTP.param_add("nv_hash", hash)
                oHTTP.param_add("hash", hash)
                oHTTP.param_add("salida_tipo", "estado")
                oHTTP.multi_part = True
                oHTTP.param_add("ej_mostrar", "false")
                oHTTP.param_add("xml_param", "")
            End If
            '  transf.transf_version = "2.0"

            Dim nT As New System.Threading.Thread(Sub(objeto As Object())
                                                      Dim nro_proceso1 As Integer
                                                      Dim rs1 As ADODB.Recordset    'Datos del excel
                                                      Dim err As New tError()
                                                      Try
                                                          'Cargar los parametros 
                                                          
                                                          Dim oHTTP1 As nvHTTPRequest = objeto.GetValue(0)
                                                          rs1 = objeto.GetValue(1)
                                                          Dim nvApp1 As tnvApp = objeto.GetValue(2)
                                                          nro_proceso1 = objeto.GetValue(3)
                                                          Dim parametros1 As System.Xml.XmlNodeList = objeto.GetValue(4)
                                                          Dim transferencia As nvTransferencia.tTransfererncia = objeto.GetValue(5)
                                                          Dim id_transf = transferencia.id_transferencia
                                                          
                                                          nvFW.nvApp._nvApp_ThreadStatic = nvApp1

                                                          Dim countReg As Integer = 1
                                                          Dim estadoProceso As Integer = 2

                                                          Dim sql_ejec As String = "" ' variable para sql que guarda el log del proceso
                                                          sql_ejec = "insert into proceso_log (nro_proceso, momento, observacion ) values (" + nro_proceso1.ToString + ", getdate(), 'Inicio: iniciando proceso ejecuci�n batch.')"
                                                          nvFW.nvDBUtiles.DBExecute(sql_ejec)

                                                          While Not rs1.EOF And estadoProceso = 2
                                                               
                                                              transferencia = New nvTransferencia.tTransfererncia
                                                              transferencia.cargar(id_transf)
                                                              transferencia.log_param_save = nvTransferencia.enum_log_param_save.inicio_y_fin
                                                              'transferencia.limpiar()
                                                              Dim strParam = "<parametros>"
                                                              For i As Integer = 0 To parametros1.Count - 1   'recorrer la lista de parametros y agregarlo a la transferencia

                                                                  Dim parametro = parametros1.Item(i)
                                                                  
                                                                  Dim param_id As String = parametro.Attributes("id").InnerText
                                                                  Dim param_name As String = parametro.Attributes("valor").InnerText
                                                                    
                                                                  Dim param_valor = rs1.Fields(param_id).Value.ToString
                                                                  If param_name <> "" Then
                                                                      If transferencia.transf_version = "2.0" Then
                                                                          transferencia.param(param_name)("valor") = param_valor
                                                                      Else
                                                                          strParam += "<" + param_name + ">" + param_valor + "</" + param_name + ">"
                                                                      End If
                                                                  End If
                                                              Next
                                                              strParam += "</parametros>"

                                                              Dim id_transf_log As Integer = 0
                                                              rs1.MoveNext()
                                                              
                                                              Try
                                                                  If transferencia.transf_version = "2.0" Then 'Ejecutar transferencia 2.0
                                                                      Try
                                                                          err = transferencia.ejecutar()
                                                                      Catch e As Exception
                                                                          'Stop
                                                                          sql_ejec = "insert into proceso_log (nro_proceso, momento, observacion ) values (" & nro_proceso1 & ", getdate(), 'Error al ejecutar la transferencia. " & Replace(e.ToString, "'", "''") & "')"
                                                                          nvFW.nvDBUtiles.DBExecute(sql_ejec)
                                                                      End Try
                                                                      
                                                                      If transferencia.id_transf_log And transferencia.id_transf_log <> 0 Then
                                                                          id_transf_log = transferencia.id_transf_log
                                                                      Else
                                                                          id_transf_log = 0
                                                                      End If
                                                                      
                                                                  Else       'Ejecutar transferencia 1.0
                                                                      oHTTP1.param_remove("xml_param")
                                                                      oHTTP1.param_add("xml_param", strParam)
                                                                      err.loadXML(oHTTP1.getResponse())
                                                                      If err.numError = 0 Then
                                                                          Dim xml_result As New System.Xml.XmlDocument
                                                                          xml_result.LoadXml(err.params.Values(1))
                                                                          id_transf_log = xml_result.SelectSingleNode("elements/params/_transf_id_transf_log").InnerText
                                                                          transferencia.estado = nvTransferencia.tTransfererncia.nvenumTransfEstado.finalizado
                                                                      Else
                                                                          transferencia.estado = nvTransferencia.tTransfererncia.nvenumTransfEstado.error
                                                                      End If
                                                                  End If

                                                                  'Relacionar el proceso con la transferencia y agregar el log al proceso.
                                                                  sql_ejec = "insert into proceso_transferencia_batch (nro_proceso, id_bpm_batch, id_transferencia, id_transferencia_log) VALUES (" & nro_proceso1 & "," & id_batch & " ," & id_transferencia & ", " & id_transf_log & ");  "
                                                                  Dim log = "Registro " & countReg & " - Ejecutando transferencia: " & transferencia.estado & ". Id_transf_log:" & id_transf_log & ". " & err.mensaje
                                                                  sql_ejec += "insert into proceso_log (nro_proceso, momento, observacion ) values (" & nro_proceso1 & ", getdate(), '" & log & "')"

                                                                  nvFW.nvDBUtiles.DBExecute(sql_ejec)
                                                                 
                                                                 
                                                              Catch ex As Exception
                                                                  sql_ejec = "insert into proceso_log (nro_proceso, momento, observacion ) values (" & nro_proceso1 & ", getdate(), 'Registro " & countReg & " - Ejecutando transferencia: Error. Params: " & strParam & " ')"
                                                                  nvFW.nvDBUtiles.DBExecute(sql_ejec)
                                                                  Er.parse_error_script(ex)
                                                                  Er.numError = 101
                                                                  Er.mensaje = "Hubo errores al ejecutar algunas transferencias del proceso."
                                                              End Try
                                                              
                                                              'Actualizar proceso
                                                              Dim rs_estado = nvFW.nvDBUtiles.DBExecute("update procesos set registro_actual = " & countReg & " Output inserted.pr_estado where nro_proceso = " & nro_proceso1)
                                                              countReg = countReg + 1
                                                              estadoProceso = rs_estado.Fields("pr_estado").Value
                                                          End While

                                                          nvDBUtiles.DBCloseRecordset(rs1)
                                                          
                                                          If estadoProceso = 2 Then
                                                              nvFW.nvDBUtiles.DBExecute("update procesos set pr_estado = 1 where nro_proceso = " & nro_proceso1 & "; insert into proceso_log (nro_proceso, momento, observacion ) values (" & nro_proceso1 & ", getdate(), ' Fin ejecuci�n batch.')")
                                                          Else
                                                              nvFW.nvDBUtiles.DBExecute("update procesos set pr_estado = " & estadoProceso & " where nro_proceso = " & nro_proceso1 & "; insert into proceso_log (nro_proceso, momento, observacion ) values (" & nro_proceso1 & ", getdate(), ' Fin ejecuci�n batch.')")
                                                          End If
                                                          
                                                      Catch e As Exception
                                                          nvDBUtiles.DBCloseRecordset(rs1)
                                                          nvFW.nvDBUtiles.DBExecute("update procesos set pr_estado = 4 where nro_proceso = " & nro_proceso1 & "; insert into proceso_log (nro_proceso, momento, observacion ) values (" & nro_proceso1 & ", getdate(), 'Fin. Error ejecuci�n batch. " & e.Message & "')")
                                                      End Try
                                                  End Sub)

            nT.Start(New Object() {oHTTP, rs, nvApp, nro_proceso, paramExcel, transf})
            
        Catch e As Exception
            Er.parse_error_script(e)
            Er.mensaje = "Error al ejecutar el proceso." + e.Message
            
            Er.params("status") = "Error"
        End Try

        Er.response()
    End If

    If accion.ToLower() = "exportar" Then
        Dim rs_batch As ADODB.Recordset = nvDBUtiles.DBExecute("select * from verPerfiles_batch where id_bpm_batch = " + id_batch)
        Try
            If Not rs_batch.EOF Then
                Dim name = (rs_batch.Fields("nombre_Excel").Value).Split(".")(0) + ".xls"
                Response.AddHeader("Content-Disposition", "attachment;filename=" + name)
                Response.ContentType = "application/x-excel"
                Response.AddHeader("filename", name)
                Response.BinaryWrite(rs_batch.Fields("rs_xml").Value)
                Response.End()
            End If
        Catch ex As Exception
            Er.parse_error_script(ex)
            Er.numError = 100
            Er.mensaje = "Error al leer el archivo excel." + ex.Message
        End Try 
    End If

    If accion.ToLower() = "eliminar" Then
        Try
            Dim str As String = "<bpm_batch id_bpm='" + id_batch + "' nombre='' id_transferencia='' tipos='' excel_name='' primera_fila=''></bpm_batch>"
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("perfiles_batch_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , "E")
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , str)
            cmd.addParameter("@datos_excel", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, , )
            cmd.addParameter("@parametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , )
            Dim rs As ADODB.Recordset = cmd.Execute()
            Er = New nvFW.tError(rs)
            nvDBUtiles.DBCloseRecordset(rs)

        Catch e As Exception
            Er.parse_error_script(e)
            Er.titulo = "Error al eliminar perfil."
            Er.mensaje = e.Message

        End Try
        Er.response()
    End If

    If accion.ToLower = "obtenerparametros" Then
        Dim path_modelo As String
        Try
            Dim rs_batch As ADODB.Recordset = nvDBUtiles.DBExecute("select * from verPerfiles_batch where id_bpm_batch = " + id_batch)
            If Not rs_batch.EOF Then
                Dim primeraFila = rs_batch.Fields("primera_fila_excel").Value
                path_modelo = System.IO.Path.GetTempPath() + rs_batch.Fields("nombre_Excel").Value
                System.IO.File.WriteAllBytes(path_modelo, rs_batch.Fields("rs_xml").Value)
                nvDBUtiles.DBCloseRecordset(rs_batch)

                Dim excel As New nvFW.tExcel
                excel.filename = path_modelo
                Er = excel.ExcelLeerCabecera(primeraFila, hojaExcel)
                Dim xml_excel As String = Er.params("strXML")

                If (Er.numError <> 0) Then
                    Er.numError = 1
                    Er.mensaje = "No se pudo leer la cabecera del excel"
                Else
                    Dim oxml As New System.Xml.XmlDocument
                    oxml.LoadXml(xml_excel)
                    Dim nsmanager As New System.Xml.XmlNamespaceManager(oxml.NameTable)

                    nsmanager.AddNamespace("s", "uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882")
                    nsmanager.AddNamespace("dt", "uuid:C2F41010-65B3-11d1-A29F-00AA00C14882")
                    nsmanager.AddNamespace("z", "#RowsetSchema")

                    Dim cabecera As System.Xml.XmlNodeList = oxml.SelectNodes("xml/s:Schema/s:ElementType/s:AttributeType", nsmanager)

                    Dim newParam = "<parametros>"

                    For i As Integer = 0 To cabecera.Count - 1
                        newParam += "<parametro id='" + cabecera.Item(i).Attributes("name").InnerText + "' valor=''></parametro>"
                    Next
                    newParam += "</parametros>"

                    Er.numError = 0
                    Er.params("parametros") = newParam
                End If
                System.IO.File.Delete(path_modelo)
            End If
        Catch ex As Exception
            Er.numError = 100
            Er.mensaje = "Error al cargar los parametros"
        End Try

        Er.response()
    End If

    Me.addPermisoGrupo("permisos_grupos_procesos")
    Me.addPermisoGrupo("permisos_procesar")
    Me.addPermisoGrupo("permisos_transferencia")

 %>
<html>
<head>
    <title>Perfiles BPM Batch</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    
   <% =Me.getHeadInit()%>
    <script type="text/javascript">

        var id_batch = '<%= id_batch %>'
        var edicion = '<%= edicion %>'
        var cabecera = [] 
        var buscar = false
        var parametros = new tXML()
        var nombre_excel = ''
        var nro_proceso = 0
        var hoja_seleccionada
        var interval
        var estado_proceso = "No iniciado"

        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Transferencia";
        vButtonItems[0]["etiqueta"] = "Ejecutar Proceso";
        vButtonItems[0]["imagen"] = "transferencia";
        vButtonItems[0]["onclick"] = "return ejecutarLoteTransferencia()";
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar Proceso acual";
        vButtonItems[1]["imagen"] = "cancelar";
        vButtonItems[1]["onclick"] = "return cancelarProceso()";
        vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "Procesos";
        vButtonItems[2]["etiqueta"] = "Administrador procesos";
        vButtonItems[2]["imagen"] = "proceso";
        vButtonItems[2]["onclick"] = "return verProcesos()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage('transferencia', '/FW/image/icons/procesar.png')
        vListButtons.loadImage('cancelar', '/FW/image/icons/cancelar.png')
        vListButtons.loadImage('proceso', '/FW/image/icons/info.png')

        function window_onload(){
            vListButtons.MostrarListButton()
            campos_defs.habilitar("id_bpm", false)
            campos_defs.habilitar("transf", false)
            campos_defs.habilitar("id_transferencia", false)
            cargarBatch(id_batch)
            window_onresize()
              
            if (edicion == 'False'){
                campos_defs.habilitar("batch", false)
            }
            mostrarProcesos()            
        }

        function cargarBatch(id) {
            var rs = new tRS()
            rs.open(nvFW.pageContents.filtroBatch, '', "<id_bpm_batch type='igual'>" + id + "</id_bpm_batch>") 
            if (!rs.eof()){            
                campos_defs.set_value("id_bpm", rs.getdata("id_bpm_batch"))
                campos_defs.set_value("batch", rs.getdata("bpm_batch"))
                campos_defs.set_value("id_transferencia", rs.getdata("id_transferencia") )
                campos_defs.set_value("transf", rs.getdata("nombre_transf"))
                nombre_excel = rs.getdata("nombre_excel")
                var lista_hojas_excel = rs.getdata("lista_hojas_excel")
                hoja_seleccionada = rs.getdata("hoja_selecc")
                
                if (rs.getdata("parametros") != null)
                    parametros.loadXML(rs.getdata("parametros"))

                cargarHojasExcel(lista_hojas_excel)
                dibujarAtributos()
            }
        }

        function cargarHojasExcel(hojasExcel) {
             var html = ''
            if (edicion == 'False'){
                html = '<input type="text" readonly ="readonly" value ="' + hoja_seleccionada + '" disabled="disabled"/>'
            }
            else{
                html = '<select id="select_hojas" style="width:100%" onchange="onclick_hoja()"> '
                var listHojas = hojasExcel.split(",")
             
                for (var i = 0; i < listHojas.length; i++){
                    if (hoja_seleccionada == listHojas[i])
                        html += '<option id="' + listHojas[i] + '" value="' + listHojas[i] + '" selected="selected">' + listHojas[i] + '</option>  '
                    else
                        html += '<option id="' + listHojas[i] + '" value="' + listHojas[i] + '">' + listHojas[i] + '</option>  '
                }
                html += '</select>'
            }
            $('hojas').innerHTML = html

        }

        function dibujarAtributos(){ 
            var strHTML = '', tdAttr = '' 
            $('atributos').innerHTML = ''
            cabecera = []
   
            var nods = parametros.selectNodes('parametros/parametro')
            for (var i = 0; i < nods.length; i++){
                cabecera.push(nods[i].getAttribute("id"));
            }

            strHTML = "<table class='tb1' style='width:100%; overflow-x:auto;' id='tableAttr'>"
            strHTML += "<tr class='tblabel'>"
            for (var i = 0; i < cabecera.length; i++){
                strHTML += "<td>" + cabecera[i] + "</td>"
                tdAttr += "<td id='td_select_" + i + "' style='min-width: 180px'></td>"
             }
              
            strHTML += "</tr><tr>" + tdAttr + "</tr>"
            strHTML += "</table>"

            $('atributos').innerHTML = strHTML
            
            //cargar el combo con los parametros
            for (i = 0; i < cabecera.length; i++) {
                campos_defs.add("select_" + i, { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.filtroCampoDef_parametro, target: "td_select_" + i,
                    filtroWhere: "<criterio><id_transferencia type='igual'>" + id_transferencia + "</id_transferencia></criterio>", depende_de_campo: "id_transferencia", depende_de: "id_transferencia"
                })
                  
            if (parametros.xml != null && parametros.selectNodes('parametros/parametro')[i])
                campos_defs.set_value("select_" + i, parametros.selectNodes('parametros/parametro')[i].getAttribute("valor"))
        
            if (edicion == 'False') { campos_defs.habilitar("select_" + i, false)  }
            
            }
              
                        
        }

        function guardar(mostrarMensaje){
            if (nvFW.tienePermiso('permisos_grupos_procesos', 2)){
                if (campos_defs.get_value('id_bpm') == ''){
                    alert("No hay proceso seleccionado.")
                    return
                }

                if (edicion == 'False') { alert("Para guardar el proceso debe estar en modo edici�n."); return }
                      
               var param = '<parametros>';
               var cabecera = $('tableAttr').getElementsByTagName("tr");
                          
               var nombre = cabecera[0].cells
               for (var i = 0; i < nombre.length; i++){
                    param += "<parametro id='" + nombre[i].innerText + "' valor='" + campos_defs.get_value("select_"+i) + "' ></parametro>"
               }
               param += '</parametros>';
               parametros.loadXML(param)

               var xml = "<?xml version='1.0' encoding='UTF-8'?><bpm_batch id_bpm='"+ campos_defs.get_value('id_bpm')+"' nombre='"+ campos_defs.get_value('batch') +"' "
               xml += " id_transferencia='" + campos_defs.get_value('id_transferencia') + "' tipos='' hoja_selecc='" + hoja_seleccionada + "'></bpm_batch>  "
                                 
               nvFW.error_ajax_request("perfiles_batch.aspx",
                                                    { parameters: { strXML: xml, accion: "guardar", id_batch: campos_defs.get_value("id_bpm"), parametros: param, hojaExcel: hoja_seleccionada }
                                                    , onSuccess: function(){
                                                        if(mostrarMensaje)  {alert("Datos guardados exitosamente"); nvFW.getMyWindow().buscar = true}
                                                    }
                                                    , error_alert: true
                                                    })

            }
            else{
                alert("No tiene permisos para modificar el proceso")
            }
       }

        function mostrarProcesos(){
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.procesos_ejecutados
                                        , filtroWhere: "<criterio><select PageSize='17' AbsolutePage='1'><filtro><id_bpm_batch type='igual'>" + id_batch + "</id_bpm_batch></filtro></select></criterio>"
                                        , path_xsl: "report\\perfiles_batch\\verProcesos_batch.xsl"
                                        , formTarget: 'resultados'
                                        , nvFW_mantener_origen: true
                                        , id_exp_origen: 0
                                        , bloq_contenedor: $('resultados')
                                        , cls_contenedor: 'resultados'
            })
        }
        
        function mostrarResultado(){
            nvFW.bloqueo_activar($('resultados'), 'idProcesos')
            interval = setInterval('procesando()', 4000)
        }

        function procesando(){
            var rs = new tRS()
            rs.async = true
            rs.onComplete = function () {   
                            if (!rs.eof()){  
                                 if (rs.getdata("pr_estado") == 2) {          
                                     $('myBar').style.width = rs.getdata("porc_ejec") + '%';
                                     $("label").innerHTML = "Ejecutando proceso: " + (rs.getdata("porc_ejec") ? parseInt(rs.getdata("porc_ejec")) : 0) + '%'
                                     return
                                }

                                if (rs.getdata("pr_estado") == 4) {  //error proceso
                                    nvFW.alert("Estado del proceso: Error.")
                                    $('myBar').style.width = '100%';
                                    $("label").innerHTML = "Error"
                                    clearInterval(interval)
                                    nvFW.bloqueo_desactivar($('resultados'), 'idProcesos')
                                    estado_proceso = "Error"
                                }

                                if (rs.getdata("pr_estado") == 1 || rs.getdata("pr_estado") == 3){ //proceso terminado
                                    $('myBar').style.width = '100%';
                                    $("label").innerHTML = "Finalizado 100%"
                                    clearInterval(interval);
                                    nvFW.bloqueo_desactivar($('resultados'), 'idProcesos')
                                    estado_proceso = "finalizado"
                               
                                 }
                                
                                mostrarProcesos()
                                nvFW.bloqueo_desactivar($('resultados'), 'idProcesos')
                           }
                           else{
                               clearInterval(interval);
                               nvFW.bloqueo_desactivar($('resultados'), 'idProcesos')
                           }
            
            }
            
            rs.open(nvFW.pageContents.verProcesos, '', "<nro_proceso type='igual'>" + nro_proceso + "</nro_proceso>")      
    }

        function descargarExcel(){
            window.open('/fw/perfiles_batch/perfiles_batch.aspx?accion=exportar&id_batch=' + campos_defs.get_value("id_bpm"))                	  
        }

        function ejecutarLoteTransferencia(){            
            if (nvFW.tienePermiso('permisos_procesar', 18)){
                if (edicion=='True' && nvFW.tienePermiso('permisos_grupos_procesos', 2)) guardar(false)
                nvFW.error_ajax_request("perfiles_batch.aspx",
                                        { parameters: { accion: "procesar", id_batch: campos_defs.get_value("id_bpm") }
                                            , onSuccess: function(er, a){
                                                if (er.numError != 0) {  
                                                    nro_proceso = er.params.nro_proceso 
                                                    estado_proceso = er.params.status 
                                                    mostrarResultado()
                                                    nvFW.alert(er.mensaje)
                                                }
                                                else {          
                                                    estado_proceso = er.params.status 
                                                    nro_proceso = er.params.nro_proceso
                                                    mostrarResultado()
                                                }
                                            }
                                            , onFailure: function (err, b) {}
                                        })
             }
             else{
                nvFW.alert("No tiene permisos para ejecutar el proceso batch.")
             }
        }
                            
        function eliminar(){
            if (nvFW.tienePermiso('permisos_grupos_procesos', 2)){
                if (edicion == 'False') {alert("Para eliminar el proceso debe estar en modo edici�n.");  return}
                nvFW.confirm("�Desea eliminar el perfil batch?",{
                    title: "Eliminar perfil batch",
                                onOk: function() {
                                    var er = nvFW.error_ajax_request("perfiles_batch.aspx",
                                                    { parameters: { accion:"eliminar", id_batch: campos_defs.get_value("id_bpm") }
                                                    , onSuccess: function (err, transport) { 
                                                        if (err.numError == 0) {
                                                            nvFW.getMyWindow().buscar = true
                                                            nvFW.getMyWindow().close()
                                                            return
                                                        }
                                                        else{
                                                            alert(err.mensaje)
                                                            return
                                                        }
                                                        return
                                                    }
                                                     , onFailure: function () {return }
                                                    , error_alert: true
                                                    })
                                },
                                onCancel: function(){ return }
                            })
             }
             else{
                alert("No tiene permisos para eliminar el proceso.")
             }
        }
        
        function window_onresize() {
            var h_body = $$("BODY")[0].getHeight(),
                h_menu = $("divMenu").getHeight(),
                h_batch = $("bacth").getHeight(),
                h_atributos = $("atributos").getHeight(),
                h_seguimiento = $('seguimiento').getHeight(),
                h_hoja = $('tb_hoja').getHeight(),
                frame = $("resultados")

            frame.setStyle({ height: h_body - h_menu - h_batch - h_hoja - h_seguimiento - h_atributos - 80 })
        }

        function cancelarProceso() {
            if(nro_proceso <= 0) {
                nvFW.alert("No existe proceso seleccionado para cancelar")
            }
            else  {
                if (nvFW.tienePermiso('permisos_procesar', 5)){ 
                   var win = window.top.nvFW.createWindow({ title: '<b>Anular Proceso</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: false,
                        width: 500,
                        height: 250,
                        resizable: false
                     //  , onClose: Eliminar_Proceso_Confirma_return
                    });

                    var url = '/FW/procesos/Proceso_anular.aspx?nro_proceso=' + nro_proceso + "&tipo_proceso=TB"
                    win.setURL(url)
                    win.returnValue = ''
                    win.showCenter(true)
               }
               else{
                  nvFW.alert("No tiene los permisos necesarios para anular el proceso.")
               }
            }
        }

        function verProcesos(){
            if(nvFW.tienePermiso('permisos_grupos_procesos',1)){
                var win = nvFW.top.createWindow({
                    title: '<b>Procesos ejecutados</b>',
                    url: "/fw/procesos/EjecutarProcesos_Administracion.aspx?nro_proceso=" + nro_proceso + "&tipo_proceso=TB",
                    minimizable: true,
                    maximizable: true,
                    resizable: true,
                    draggable: true,
                    width: 950,
                    height: 400,
                    destroyOnClose: true,
                    onClose: function() { } 
                });

                win.showCenter(true);
            }
            else{
                nvFW.alert("No tiene permisos para ver el administrador de procesos.")
            }
        }

        function cambiarArchivo(){
            if (edicion == 'False') {alert("Para editar el archivo debe estar en modo edici�n."); return }
            var win = nvFW.createWindow({
                title: "<b>Seleccionar nuevo archivo</b>",
                url: "/fw/perfiles_batch/perfiles_batch_nuevo_archivo.aspx?id_batch=" + id_batch,
                width: "500",
                height: "350",
                top: "50",
                setWidthMaxWindow: true,
                destroyOnClose: true,
                onClose: function(win) { }
            })
            win.showCenter(center)
        }

        function onclick_hoja(){
            nvFW.confirm("�Desea volver a dibujar los par�metros en base a la hoja seleccionada?", {
                title: "Redibujar par�metros",
                onOk: function(win){
                    var hoja_sel = $('select_hojas').value
                    var er = nvFW.error_ajax_request("perfiles_batch.aspx",
                                                { parameters: { accion: "obtenerparametros", id_batch: campos_defs.get_value("id_bpm"), hojaExcel: hoja_sel }
                                                , onSuccess: function(err, transport)
                                                {
                                                    if (err.numError == 0)
                                                    {     
                                                        parametros.loadXML(err.params.parametros)
                                                        dibujarAtributos()
                                                        hoja_seleccionada = hoja_sel
                                                        return
                                                        win.close()
                                                    }
                                                    else
                                                    {
                                                        alert(err.mensaje)
                                                        $(hoja_seleccionada).selected = "selected"
                                                        return
                                                    }
                                                }
                                                 , onFailure: function() {  }
                                                , error_alert: true
                                                });

                                            win.close()
                },
                onCancel: function(){
                    $(hoja_seleccionada).selected = "selected"
                    return
                }
            })

        }

        function verResultados(num_proceso){
            var win = nvFW.createWindow({
                title: "<b>Resultados proceso: " + num_proceso + "</b>",
                url: "/fw/perfiles_batch/perfiles_batch_procesos.aspx?nro_proceso=" + num_proceso,
                width: "980",
                height: "600",
                top: "50",
                setWidthMaxWindow: true,
                destroyOnClose: true,
                onClose: function(win) { }
            })
            win.showCenter(true)
        }

        function cancelarSeguimiento(){  
            if(estado_proceso == "Ejecutando"){
                clearInterval(interval)
                nvFW.bloqueo_desactivar($('resultados'), 'idProcesos')
                $('myBar').style.width = '100%';
                $("label").innerHTML = "Seguimiento cancelado"
                estado_proceso = "Cancelado"
                mostrarProcesos()     
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="overflow: hidden">
    <div id="divMenu" style="margin: 0px; padding: 0px;">
    </div>
    <script type="text/javascript">
        var DocumentMNG=new tDMOffLine;
        var vMenu=new tMenu('divMenu','vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar(true)</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.loadImage('guardar', '/FW/image/icons/guardar.png')
        vMenu.loadImage('eliminar', '/FW/image/icons/eliminar.png')
        vMenu.MostrarMenu()
    </script>

    <table id="bacth" class="tb1" style="width:100%">
        <tr class="tbLabel">
            <td >ID</td>
            <td >Proceso</td>
            <td >Transf. ID</td>
            <td >Transferencia</td>
            <td style="width:30px">Ver</td>
            <td style="width:100px"></td>  
        </tr>
        <tr>
            <td style="width:20px"><%= nvFW.nvCampo_def.get_html_input("id_bpm", enDB:=False, nro_campo_tipo:=104)%></td>
             <td><%= nvFW.nvCampo_def.get_html_input("batch", enDB:=False, nro_campo_tipo:=104)%></td>
             <td style="width:10px" ><%= nvFW.nvCampo_def.get_html_input("id_transferencia", enDB:=False, nro_campo_tipo:=100)%></td>
             <td style="width:30px" ><%= nvFW.nvCampo_def.get_html_input("transf", enDB:=False, nro_campo_tipo:=104)%></td>
             <td style="width:30px"><img title="" src="/fw/image/filetype/excel.png" style="cursor:pointer" onclick="descargarExcel()"></td>
             <td style="width:100px"><button style="width:;" title="Reemplazar el archivo actual" onclick="cambiarArchivo()">Editar archivo</button></td>
        </tr>
    </table>
    
    <br />
    <div id="divMenuParam" style="margin: 0px; padding: 0px; overflow:auto"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var MenuParam = new tMenu('divMenuParam', 'MenuParam');
        Menus["MenuParam"] = MenuParam
        Menus["MenuParam"].alineacion = 'centro';
        Menus["MenuParam"].estilo = 'A';
        Menus["MenuParam"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%; text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Par�metros</Desc></MenuItem>")
        MenuParam.MostrarMenu()
    </script> 
    <table class="tb1" id="tb_hoja">
        <tr>
            <td style="width: 200px" class="Tit1">Hoja excel a procesar:</td>
            <td id="hojas" style="width:20%"></td><td style="60%"></td>
        </tr>
    </table>
    <div id="atributos" style="width:100%; overflow:auto"></div>
    
    <table class="tb1">
        <tr></tr>
        <tr style="width:100%;">
             <td style="width:33%;"><div id="divTransferencia" style="width:100%;"></div></td>
             <td style="width:33%;"><div id="divCancelar" style="width:100%;"></div></td>
             <td style="width:33%;"><div id="divProcesos" style="width:100%;"></div></td>
        </tr>
    </table>
    <br />   
    <table class="tb1" id="seguimiento">
        <tr style="width:100%;">
            <td style="width: 16%" class="Tit1" >Estado del proceso:</td>
            <td style="width: 84%">
                <div style='width: 100%;background-color: #ffffff;'>
                    <div id='myBar' style='width: 0%; background-color: #4CAF50;'>
                        <div id='label' style='text-align:center; white-space:nowrap; line-height:20px; color:black;'>No iniciado</div>
                    </div>
                </div>
            </td>  
            <td><button style="width: 100%" onclick="cancelarSeguimiento()" title="Cancelar Seguimiento">Cancelar</button></td>
            <td><button style="width: 100%" onclick="mostrarProcesos()" title="Actualizar"><img  src ="../image/icons/periodicidad.png"/></button></td>
        </tr>  
    </table>
    <iframe id="resultados" name="resultados" src="/FW/enBlanco.htm" style="width:100%;  overflow:hidden;" frameborder="0"></iframe>
</body>
</html>

