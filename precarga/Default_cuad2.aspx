<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%    

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")
    Dim login As String = nvApp.operador.login
    Dim ip_usr As String = Request.ServerVariables("REMOTE_ADDR") 'Request.UserHostAddress 'System.Net.Dns.GetHostEntry(System.Net.Dns.GetHostName()).AddressList(1).ToString() 'nvApp.host_ip
    Dim ip_srv As String = Request.ServerVariables("LOCAL_ADDR") 'System.Net.Dns.GetHostEntry(Request.ServerVariables("SERVER_NAME")).AddressList(1).ToString() 'nvApp.server_ip
    Select Case modo.ToUpper
        Case "C"
            Dim err As New nvFW.tError
            Try
                Dim nvCUADInfo As New nvFW.infoRecibos.tnvCUADinfo
                Dim respuesta = nvCUADInfo.CargarCaptcha
                Stop
                Dim csname1 As String = "PopupScript"
                Dim cstype As Type = Me.GetType()
                Dim cs As ClientScriptManager = Page.ClientScript

                If (Not cs.IsStartupScriptRegistered(cstype, csname1)) Then
                    Dim cstext1 As String = "alert('Hello World');"
                    cs.RegisterStartupScript(cstype, csname1, cstext1, True)

                End If
                Dim scriptText As String
                scriptText = "return confirm('Do you want to submit the page?')"
                ClientScript.RegisterOnSubmitStatement(Me.GetType(), "ConfirmSubmit", scriptText)
            Catch ex As Exception

            End Try
            err.response()
        Case "L"
            Dim err As New nvFW.tError
            Try
                Dim xmlLog As String = nvFW.nvUtiles.obtenerValor("xmlLog", "")
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_precarga_log", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@xmlLog", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlLog.Length, xmlLog)
                Dim rs As ADODB.Recordset = cmd.Execute()
                Dim numError As Integer = rs.Fields("numError").Value
                Dim mensaje As String = rs.Fields("mensaje").Value
                err.mensaje = mensaje
                err.numError = numError
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error en el registro del log"
                err.comentario = ""
            End Try
            err.response()

        Case "F"    'Actualizar Fuentes de Nosis

            Dim err As New nvFW.tError
            Try

                Dim documento As String = nvFW.nvUtiles.obtenerValor("cuit", "")
                Dim url As String = nvFW.nvUtiles.obtenerValor("url", "")

                Dim nvNosisFuentes As New nvFW.servicios.tnvNosisFuentes
                nvNosisFuentes.URL = url
                nvNosisFuentes.timeOut = 20
                Dim respuesta = nvNosisFuentes.ActualizarFuentesNosis(documento)
                err.numError = 0
                err.titulo = ""
                err.mensaje = ""
                If (respuesta <> 1) Then
                    err.numError = 99
                    err.titulo = "Error al actualizar las fuentes externas."
                    err.mensaje = "Intente Nuevamente."
                End If
                err.params("respuesta") = respuesta
            Catch ex As Exception
                err.parse_error_script(ex)
                err.titulo = "Error al actualizar las fuentes externas"
                err.comentario = ""
            End Try
            err.response()

        Case "S"    'Generar Solicitud
            'Stop
            Dim err As New nvFW.tError
            Try
                'Stop
                Dim persona_existe As Boolean
                If nvFW.nvUtiles.obtenerValor("persona_existe", "") = "true" Then
                    persona_existe = True
                End If

                Dim xmlpersona As String = nvFW.nvUtiles.obtenerValor("xmlpersona", "")
                Dim xmltrabajo As String = nvFW.nvUtiles.obtenerValor("xmltrabajo", "")
                Dim xmlcredito As String = nvFW.nvUtiles.obtenerValor("xmlcredito", "")
                Dim xmlanalisis As String = nvFW.nvUtiles.obtenerValor("xmlanalisis", "")
                Dim xmlcancelaciones As String = nvFW.nvUtiles.obtenerValor("xmlcancelaciones", "")
                Dim xmlparametros As String = nvFW.nvUtiles.obtenerValor("xmlparametros")
                Dim estado As String = nvFW.nvUtiles.obtenerValor("estado")
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_cr_solicitud", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                cmd.addParameter("@persona_existe", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, persona_existe)
                cmd.addParameter("@XMLpersona", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlpersona.Length, xmlpersona)
                cmd.addParameter("@XMLtrabajo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmltrabajo.Length, xmltrabajo)
                cmd.addParameter("@XMLcredito", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcredito.Length, xmlcredito)
                cmd.addParameter("@XMLanalisis", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlanalisis.Length, xmlanalisis)
                cmd.addParameter("@XMLcancelaciones", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcancelaciones.Length, xmlcancelaciones)
                cmd.addParameter("@XMLparametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlparametros.Length, xmlparametros)

                Dim rs As ADODB.Recordset = cmd.Execute()
                nro_credito = rs.Fields("nro_credito").Value
                Dim modo1 As String = rs.Fields("modo").Value
                Dim numError As Integer = rs.Fields("numError").Value
                Dim mensaje As String = rs.Fields("mensaje").Value
                err.params("nro_credito") = nro_credito
                err.params("estado") = estado
                err.mensaje = mensaje
                err.numError = numError

                If numError = 0 And modo1 = "A" Then
                    Try

                        'Incorporar archivo Nosis al credito
                        Dim objXML As System.Xml.XmlDocument
                        Dim NosisXML As String = nvFW.nvUtiles.obtenerValor("NosisXML")
                        objXML = New System.Xml.XmlDocument
                        objXML.LoadXml(NosisXML)
                        Dim strHTML As String = objXML.SelectSingleNode("Respuesta/ParteHTML").InnerText

                        Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset("Select isnull(max(nro_archivo), 0) + 1 As maxArchivo from archivos")
                        Dim nro_archivo As Integer = rsA.Fields("maxArchivo").Value
                        nvFW.nvDBUtiles.DBCloseRecordset(rsA)

                        nvFW.nvDBUtiles.DBExecute("Insert Into archivos (nro_archivo, path, operador,nro_img_origen,nro_archivo_estado) values(" & nro_archivo & ", '" & nro_archivo & "','" & nvApp.operador.operador & "',1,1)")
                        Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
                        Dim filename As String = nro_archivo & ".html"

                        'Guardado en Nova

                        Dim path_carpeta As String
                        path_carpeta = "\\\\nova8\\d$\\MeridianoWeb\\Meridiano\\archivos\\" & carpeta
                        If System.IO.Directory.Exists(path_carpeta) = False Then
                            System.IO.Directory.CreateDirectory(path_carpeta)
                        End If
                        Dim path As String = path_carpeta & "\\" & filename
                        Dim fs2 As New System.IO.FileStream(path, IO.FileMode.Create)
                        Dim buffer() As Byte = nvFW.nvConvertUtiles.StringToBytes(strHTML)
                        fs2.Write(buffer, 0, buffer.Length)
                        fs2.Close()

                        'Guardado en Rova

                        'Dim path_rova As String
                        'Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = 'nv_mutual' and cod_servidor = 'nova8' and cod_ss_dir = 'nvArchivosDefault'")
                        'path_rova = rsRova.Fields("path").Value
                        'If System.IO.Directory.Exists(path_rova) = False Then
                        '    System.IO.Directory.CreateDirectory(path_rova)
                        'End If
                        'Dim pathR As String = path_rova & "\\" & filename
                        'System.IO.File.Copy(path, pathR, True)

                        'Dim fs3 As New System.IO.FileStream(pathR, IO.FileMode.Create)
                        'Dim buffer1() As Byte = nvFW.nvConvertUtiles.StringToBytes(strHTML)
                        'fs3.Write(buffer1, 0, buffer1.Length)
                        'fs3.Close()

                        Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset("select nro_def_detalle,archivo_descripcion from verArchivos_def where nro_credito = " & nro_credito & " and  archivo_descripcion like 'NOSIS%'")
                        Dim nro_def_detalle As Integer = rsDef.Fields("nro_def_detalle").Value
                        Dim archivo_descripcion As String = rsDef.Fields("archivo_descripcion").Value

                        nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 2 where nro_def_detalle = " & nro_def_detalle & " and nro_credito = " & nro_credito & " and nro_archivo <> " & nro_archivo)
                        nvFW.nvDBUtiles.DBExecute("update archivos set path = '" & carpeta & "\" & filename & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo)

                        'Incorporar parametros del CDA al archivo de Nosis
                        Dim strParteXML As String = "<?xml version=""1.0"" encoding=""ISO-8859-1""?>" & objXML.SelectSingleNode("Respuesta/ParteXML").OuterXml
                        Dim ParteXML As System.Xml.XmlDocument
                        ParteXML = New System.Xml.XmlDocument
                        ParteXML.LoadXml(strParteXML)

                        Dim XmlNodeList As System.Xml.XmlNodeList
                        Dim node As System.Xml.XmlNode

                        XmlNodeList = ParteXML.SelectNodes("/ParteXML/Dato/CalculoCDA")

                        Dim strSQL As String = ""

                        For Each node In XmlNodeList
                            Dim Titulo = node.Attributes.GetNamedItem("Titulo").Value
                            strSQL = "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'EMPRESA' , '" & Titulo & "', getdate(),dbo.rm_nro_operador()) "
                            Dim NroCDA = node.Attributes.GetNamedItem("NroCDA").Value
                            strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CDA' , '" & NroCDA & "', getdate(),dbo.rm_nro_operador()) "
                            Dim Version = node.Attributes.GetNamedItem("Version").Value
                            strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CDA_VERSION' , '" & Version & "', getdate(),dbo.rm_nro_operador()) "
                            Dim Fecha = node.Attributes.GetNamedItem("Fecha").Value
                            strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'FECHA' , '" & Fecha & "', getdate(),dbo.rm_nro_operador()) "
                            Dim Documento = node.SelectSingleNode("Documento").InnerText
                            strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CUIL' , '" & Documento & "', getdate(),dbo.rm_nro_operador()) "
                            Dim RazonSocial = node.SelectSingleNode("RazonSocial").InnerText
                            strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'RAZON_SOCIAL' , '" & RazonSocial & "', getdate(),dbo.rm_nro_operador()) "
                            Dim ItemList As System.Xml.XmlNodeList
                            Dim ItemNode As System.Xml.XmlNode
                            ItemList = node.SelectNodes("Item")
                            For Each ItemNode In ItemList
                                Dim parametro = ItemNode.Attributes.GetNamedItem("Clave").Value
                                Dim valor = ItemNode.SelectSingleNode("Valor").InnerText
                                strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'" & parametro & "' , '" & valor & "', getdate(),dbo.rm_nro_operador()) "
                            Next
                            nvFW.nvDBUtiles.DBExecute(strSQL)
                        Next

                    Catch ex As Exception

                    End Try

                End If

            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            err.response()

    End Select

    Me.contents.Add("operador", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='veroperadores'><campos>sucursal_cod_prov, nro_docu, sucursal_provincia, sucursal_postal_real</campos><orden></orden><filtro><operador type='igual'>" & nvApp.operador.operador & "</operador></filtro></select></criterio>"))
    Me.contents.Add("vendedor", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vervendedores'><campos>nro_vendedor, strNombreCompleto</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
    Me.contents.Add("trabajo", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBTrabajo_cuad_anexa'><campos>tipo,nro_sistema,sistema,nro_lote,lote,clave_sueldo,nro_docu,nombre,disponible,dbo.conv_fecha_to_str(fecha_actualizacion,'dd/mm') as fecha_actualizacion</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu><cod_prov type='igual'>%cod_prov%</cod_prov></filtro></select></criterio>"))
    Me.contents.Add("persona", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,sexo,nro_docu,tipo_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad</campos><orden></orden><filtro><cuit type='like'>%cuit%</cuit></filtro></select></criterio>"))
    Me.contents.Add("saldos", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_calc_credito_precarga' CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo></parametros></procedure></criterio>"))
    'Me.contents.Add("creditos_cs", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>nro_credito,nro_banco,banco,nro_mutual,mutual,convert(varchar,fe_estado,103) as fe_estado,importe_cuota</campos><orden></orden><filtro><cuit type='like'>%cuit%</cuit><estado type='igual'>'T'</estado><nro_banco type='igual'>200</nro_banco></filtro></select></criterio>"))
    'Me.contents.Add("creditos_cs_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>nro_credito,nro_banco,banco,nro_mutual,mutual,convert(varchar,fe_estado,103) as fe_estado,importe_cuota</campos><orden></orden><filtro><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo><estado type='igual'>'T'</estado><nro_banco type='igual'>200</nro_banco></filtro></select></criterio>"))
    Me.contents.Add("creditos_cs", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio'  CommantTimeOut='1500' vista='verCreditos'><parametros><cuit>%cuit%</cuit></parametros></procedure></criterio>"))
    Me.contents.Add("creditos_cs_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio'  CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo></parametros></procedure></criterio>"))
    Me.contents.Add("operatorias", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_auxbanco_mutual_linea_grupo_analisis'  CommantTimeOut='1500' vista='verCreditos'><parametros><cuit>%cuit%</cuit><nro_sistema DataType='int'>%nro_sistema%</nro_sistema><nro_lote DataType='int'>%nro_lote%</nro_lote><sitbcra DataType='int'>%sit_bcra%</sitbcra><nro_banco DataType='int'>%nro_banco%</nro_banco><nro_mutual DataType='int'>%nro_mutual%</nro_mutual><salida>%salida%</salida></parametros></procedure></criterio>"))
    Me.contents.Add("sit_bcra", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='lausana_anexa..nosis_consulta'><campos>dbo.rm_sit_bcra_nosis(id_consulta) as situacion</campos><orden></orden><filtro><id_consulta type='igual'>%id_consulta%</id_consulta></filtro></select></criterio>"))
    Me.contents.Add("persona_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,sexo,nro_docu,tipo_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))

    Dim operador As Object
    Try
        operador = nvFW.nvApp.getInstance().operador
    Catch ex As Exception
    End Try

 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="FW/image/icons/nv_login.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>
    <script type="text/javascript" language='javascript' src="/precarga/script/precarga.js" ></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript" class="table_window">

    var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    var win

    var vButtonItems = {}
    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "PBuscar";
    vButtonItems[0]["etiqueta"] = "";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return Persona_Trabajos_cargar()";
    vButtonItems[1] = {}
    vButtonItems[1]["nombre"] = "PlanBuscar";
    vButtonItems[1]["etiqueta"] = "";
    vButtonItems[1]["imagen"] = "buscar";
    vButtonItems[1]["onclick"] = "return Validar_datos()";
    //vButtonItems[2] = {}
    //vButtonItems[2]["nombre"] = "Limpiar";
    //vButtonItems[2]["etiqueta"] = "Limpiar";
    //vButtonItems[2]["imagen"] = "nuevo";
    //vButtonItems[2]["onclick"] = "return Precarga_Limpiar()";
    vButtonItems[3] = {}
    vButtonItems[3]["nombre"] = "VerCreditos";
    vButtonItems[3]["etiqueta"] = "";
    vButtonItems[3]["imagen"] = "credito";
    vButtonItems[3]["onclick"] = "return VerCreditos('V')";
    vButtonItems[4] = {}
    vButtonItems[4]["nombre"] = "BuscarVendedor";
    vButtonItems[4]["etiqueta"] = "";
    vButtonItems[4]["imagen"] = "buscar";
    vButtonItems[4]["onclick"] = "return selVendedor_onclick()";
    /*vButtonItems[5] = {}
    vButtonItems[5]["nombre"] = "Presupuesto";
    vButtonItems[5]["etiqueta"] = "Presupuesto";
    vButtonItems[5]["imagen"] = "guardar";
    vButtonItems[5]["onclick"] = "return GuardarSolicitud('M')";*/
    //vButtonItems[6] = {}
    //vButtonItems[6]["nombre"] = "Solicitud";
    //vButtonItems[6]["etiqueta"] = "Solicitud";
    //vButtonItems[6]["imagen"] = "guardar";
    //vButtonItems[6]["onclick"] = "return GuardarSolicitud('P')";
    vButtonItems[7] = {}
    vButtonItems[7]["nombre"] = "Nosis";
    vButtonItems[7]["etiqueta"] = "";
    vButtonItems[7]["imagen"] = "ver";
    vButtonItems[7]["onclick"] = "return VerInformeNosis()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons');
    vListButtons.loadImage("buscar", "/precarga/image/search_16.png");
    vListButtons.loadImage("credito", "/precarga/image/us_dollar_16.png");
    vListButtons.loadImage("nuevo", "/precarga/image/text_document_24.png");
    vListButtons.loadImage("guardar", "/precarga/image/guardar.png");
    vListButtons.loadImage("ver", "/precarga/image/preview_16.png");
    
    var vendedor = ''
    var WinTipo = ''    

    function window_onload() 
    {
      UbicacionObtener()
      vListButtons.MostrarListButton()
      Precarga_Limpiar()
      /* Obtener vendedor desde operador */
      ObtenerSucursalOperador()
    }

    function UbicacionObtener() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(Ubicacion,UbicacionErrores);
        } else {
           alert('No disponible')
        }
    }

    var geoloc_lat = 0
    var geoloc_long = 0
    var geoloc_domicilio = ''
    var geoloc_localidad = ''
    var geoloc_provincia = ''
    var geoloc_pais = ''
    var ismobile = false

    function Ubicacion(position) {
        geoloc_lat = position.coords.latitude
        geoloc_long = position.coords.longitude
        UbicacionDescripcion()
    }

    function UbicacionErrores(error)
    {
        var desc_error = ""
        switch (error.code) {
            case error.PERMISSION_DENIED:
                //x.innerHTML = "User denied the request for Geolocation."
                desc_error = "Permiso denegado para acceder a la ubicación."
                break;
            case error.POSITION_UNAVAILABLE:
                //x.innerHTML = "Location information is unavailable."
                desc_error = "La información de la ubicación no se encuentra disponible."
                break;
            case error.TIMEOUT:
                //x.innerHTML = "The request to get user location timed out."
                desc_error = "Tiempo de respuesta agotado para obtener la ubicación."
                break;
            case error.UNKNOWN_ERROR:
                //x.innerHTML = "An unknown error occurred."
                desc_error = "Error Desconocido."
                break;
        }
        if (desc_error != "")
            window.location.href = "../../precarga/error_precarga.aspx?desc_error=" + desc_error
    }

    function UbicacionDescripcion() {
        var request = new XMLHttpRequest();

        var method = 'GET';
        var url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + geoloc_lat + ',' + geoloc_long + '&sensor=true';
        var async = true;

        request.open(method, url, async);
        request.onreadystatechange = function () {
            if (request.readyState == 4 && request.status == 200) {
                var data = JSON.parse(request.responseText);
                //var address = data.results[0];
                geoloc_domicilio = data.results[0].formatted_address
                geoloc_localidad = data.results[0].address_components[2]['long_name']
                geoloc_provincia = data.results[0].address_components[4]['long_name']
                geoloc_pais = data.results[0].address_components[5]['long_name']                
            }
        };
        request.send();
    };

    var cupo_disponible = 0
    var nro_sistema = 0
    var sistema = ''
    var nro_lote = 0
    var lote = ''
    var clave_sueldo = ''

    /* Variables persona */
    var fe_naci = ''
    var sexo = ''
    var tipo_docu = 0
    var nro_docu = 0
    var cuit = ''
    var razon_social = ''
    var domicilio = ''
    var localidad = ''
    var CP = ''
    var provincia = ''
    var nro_archivo_nosis = 0

    var Cancel = {}

    var TotalCancelaciones = 0
    var LiberaCuota = 0
    var cancelaciones = 0
    var importe_max_cuota = 0

    function Precarga_Limpiar()
    {
        Trabajos = {}
        Creditos = {}
        Cancel = {}
        $('divVendedor').show()
        $('divDatosPersonales').hide()
        $('divSelTrabajo').show()
        $('divTrabajo').hide()
        $('divSocio').hide()
        $('divFiltros').hide()
        $('divFiltrosLeft').hide()
        $('divFiltrosRight').hide()
        $('divFiltros2Left').hide()
        $('divProducto').hide()
        $('divMostrarTrabajos').hide()

        $('strApeyNomb').innerHTML = ''
        $('strCUIT').innerHTML = ''
        $('strFNac').innerHTML = ''
        $('strTrabajo').innerHTML = ''
        $('divMostrarTrabajos').innerHTML = ''
        $('strSitBCRA').innerHTML = ''
        $('strDictamen').innerHTML = ''
        $('nro_docu').value = ''
        $('tbButtons').hide()

        $('retirado_desde').value = ''
        $('retirado_hasta').value = ''
        $('importe_cuota_desde').value = ''
        $('importe_cuota_hasta').value = ''
        $('cuota_desde').value = ''
        $('cuota_hasta').value = ''

        cupo_disponible = 0
        nro_sistema = 0
        sistema = ''
        nro_lote = 0
        lote = ''
        clave_sueldo = ''
        prueba = ''
        NroConsulta = 0
        razon_social = ''
        domicilio = ''
        localidad = ''
        CP = ''
        provincia = ''
        edad = ''
        sexo = ''
        fe_naci = ''
        fe_naci_str = ''
        tipo_docu = 0
        nro_docu = 0
        cuit = ''
        NosisXML = ''
        nro_archivo_nosis = 0
        sit_bcra = 99
        HTMLCDA = ''
        TotalCancelaciones = 0
        LiberaCuota = 0
        cancelaciones = 0
        importe_max_cuota = 0
        strHTMLNosis = ''
        persona_existe = true
        fe_naci_socio = ''
        nro_plan_sel = 0
        plan_lineas = ''
        btnStatus(false)
    }

    var BodyWidth = 0
    var widthWin = 0
    var heightWin = 0
    var leftWin = 0
    var topWin = 0

    function Ajustar_ventana()
    {
        BodyWidth = $$('body')[0].getWidth()
        widthWin = $('contenedor').getWidth() - 100
        heightWin = 300
        topWin = ($('contenedor').getHeight() / 2) + 150
        if ((BodyWidth < 1024) && (window.matchMedia("(orientation: portrait)").matches)) {
            widthWin = $('contenedor').getWidth() - 20
            heightWin = this.screen.availHeight - 200 //$$('body')[0].getWidth()//$('contenedor').getWidth()
            topWin = 10
        }
        if ((BodyWidth < 1024) && (window.matchMedia("(orientation: landscape)").matches)) {
            widthWin = $('contenedor').getWidth() - 20
            heightWin = this.screen.availHeight - 140
            topWin = 10
        }
        leftWin = ((BodyWidth - $('contenedor').getWidth()) / 2) + 3
    }

    var win_vendedor
    function selVendedor_onclick() {
        Ajustar_ventana()
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_vendedor = w.createWindow({
            className: 'alphacube',
            url: 'selVendedor.aspx',
            title: '<b>Seleccionar Vendedor</b>',
            minimizable: false,
            maximizable: false,
            draggable: true,
            top: topWin,
            left: leftWin,
            width: widthWin,
            height: heightWin,
            resizable: false,
            onClose: selVendedor_return
        });
        win_vendedor.options.userData = { res: '' }
        if (BodyWidth < 1024)
            win_vendedor.show()
        else
            win_vendedor.showCenter(true)
    }
   
    var nro_vendedor = 0
    function selVendedor_return() {
        var retorno = win_vendedor.options.userData.res
        if (retorno) 
          {
          $('strVendedor').innerText = retorno["vendedor"]
          nro_vendedor = retorno['nro_vendedor']
          $('vendedor_provincia').innerText = "Provincia:  " + retorno['provincia']
          cod_prov_op = retorno['cod_prov']
          sucursal_postal_real = retorno['postal_real']
          Precarga_Limpiar()
        }     
    }
    var cod_prov_op
    var sucursal_postal_real
    function ObtenerSucursalOperador() 
      {
      var rs01 = new tRS();
      rs01.open(nvFW.pageContents["operador"])
      if (!rs01.eof()) 
      {
        $('vendedor_provincia').innerText = "Provincia:  " + rs01.getdata('sucursal_provincia')
        cod_prov_op = rs01.getdata('sucursal_cod_prov')
        sucursal_postal_real = rs01.getdata('sucursal_postal_real')
        var rs02 = new tRS();
        var nro_docu = rs01.getdata('nro_docu') // 24411232 //rs01.getdata('nro_docu')
        rs02.open({filtroXML: nvFW.pageContents["vendedor"], params: "<criterio><params nro_docu='" + nro_docu + "' /></criterio>"})
        if (!rs02.eof())
          {
          $('strVendedor').innerText = rs02.getdata('strNombreCompleto')
          nro_vendedor = rs02.getdata('nro_vendedor')
          }
        else
          selVendedor_onclick()
        }
      }

    function btnBuscar_trabajo_onclick(e) {
        var key = Prototype.Browser.IE ? e.keyCode : e.which
        if (key == 13)
            Persona_Trabajos_cargar()
        else
            return valDigito(e)
    }

    var Trabajos = {}

    function Persona_Trabajos_cargar()
    {
        if ($('nro_docu').value == '')
        {
            alert('Ingrese un número de documento para realizar la busqueda.')
            return
        }
        if (nro_vendedor == 0)
        {
            alert('Seleccione un vendedor para realizar la búsqueda.')
            return
        }
        nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
        var rs = new tRS();
        Trabajos = {}
        var i = 0
        var nro_docu = $('nro_docu').value
        var cod_prov = cod_prov_op
        rs.open({filtroXML: nvFW.pageContents["trabajo"], params:"<criterio><params nro_docu='" + nro_docu + "' cod_prov='" + cod_prov + "'  /></criterio>"})
        while (!rs.eof()) {
            i++
            Trabajos[i] = {}
            Trabajos[i]['tipo'] = rs.getdata('tipo')
            Trabajos[i]['sistema'] = rs.getdata('sistema')
            Trabajos[i]['nro_sistema'] = rs.getdata('nro_sistema')
            Trabajos[i]['lote'] = rs.getdata('lote')
            Trabajos[i]['nro_lote'] = rs.getdata('nro_lote')
            Trabajos[i]['clave_sueldo'] = rs.getdata('clave_sueldo')
            Trabajos[i]['nro_docu'] = rs.getdata('nro_docu')
            Trabajos[i]['nombre'] = rs.getdata('nombre')
            Trabajos[i]['disponible'] = rs.getdata('disponible')
            Trabajos[i]['fecha_actualizacion'] = rs.getdata('fecha_actualizacion')
            rs.movenext()
        }


        if (rs.recordcount == 1)
            Log_registro(i, false)
        else
            Persona_Trabajos_dibujar()       
        //var filtro = "<fe_estado type='sql'><![CDATA[fe_estado >= dbo.finac_inicio_mes(getdate())]]></fe_estado><estado type='in'>'A','D','E','L','M','N','O','P','Q','R','T','U','Z'</estado><nro_docu type='igual'>" + $('nro_docu').value + "</nro_docu>"
        //var rs = new tRS();
        //rs.open("<criterio><select vista='credito'><campos>nro_credito</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>")
        //if (!rs.eof())        
        //    VerCreditos('S')
    }

    function Persona_Trabajos_dibujar() {
        $('divMostrarTrabajos').innerHTML = ''
        $('divMostrarTrabajos').show()    
        var strHTML = ""
        strHTML += "<table class='tb1 highlightEven highlightTROver' cellspacing='1' cellpadding='1'>"

        if (!Trabajos[1])
            strHTML += "<tr><td class='Tit1'>No se encontro información para el documento ingresado</td></tr>"
        else
            {
            strHTML += "<tr><td class='Tit1' style='width:5px'></td><td class='Tit1' style='width:40%'>Nombre</td><td class='Tit1' style='width:30%'>Trabajo</td><td class='Tit1' style='width:30%'>Clave</td></tr>"

            for (var x in Trabajos)
                strHTML += "<tr style='text-align:center' onclick='return Log_registro(" + x + ",true)'><td style='text-align:center' title='Seleccionar persona'><img class='img_button_sel' src='/precarga/image/seleccionar_32.png'/></td><td>" + Trabajos[x]['nombre'] + "</td><td>" + Trabajos[x]['sistema'] + " - " + Trabajos[x]['lote'] + "</td><td>" + Trabajos[x]['clave_sueldo'] + "</td></tr>"
            //<input type='radio' style='border:none' name='RTrabajo' id='RTrabajo' value='' onclick='return RTrabajo_onclick(" + x + ")'>
            }
        strHTML += "</table>"
        $('divMostrarTrabajos').insert({ bottom: strHTML })
        nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
    }

    var CDA = 0
    var nro_banco = '800'
    //var nro_vendedor = 0
    var win_sel_cuit
    var login = '<%= login %>'
    var ip_usr = '<%= ip_usr %>'
    var ip_srv = '<%= ip_srv %>'

    function Log_registro(x,bloqueo)
    {
        if (bloqueo)
            nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')

        ismobile = (isMobile()) ? true : false
        var socio_nro_docu = $('nro_docu').value
        var socio_cupo = parseFloat(Trabajos[x]['disponible']).toFixed(2)

        var xmlLog = ""
        xmlLog = "<?xml version='1.0' encoding='iso-8859-1'?>"
        xmlLog += "<log login='" + login + "' nro_vendedor='" + nro_vendedor + "' cod_prov='" + cod_prov_op + "' ismobile='" + ismobile + "' ip_usr='" + ip_usr + "' ip_srv='" + ip_srv + "' "
        xmlLog += "geoloc_lat='" + geoloc_lat + "' geoloc_long='" + geoloc_long + "' geoloc_domicilio='" + geoloc_domicilio + "' geoloc_localidad='" + geoloc_localidad + "' "
        xmlLog += "geoloc_provincia='" + geoloc_provincia + "' geoloc_pais='" + geoloc_pais + "' socio_nro_docu='" + socio_nro_docu + "' socio_cupo='" + socio_cupo + "'></log>"    
            
        nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')

        nvFW.error_ajax_request('Default.aspx', {
            parameters: { modo: "C" },
            onSuccess: function (err, transport) {
                //if (err.numError == 0) 
                //    alert('ok')
                    //NOSIS_evaluar_identidad(x, bloqueo)
            }
        });

        //nvFW.error_ajax_request('Default.aspx', {
        //    parameters: { modo: "L", xmlLog: xmlLog },
        //    onSuccess: function (err, transport) {
        //        if (err.numError == 0) 
        //            NOSIS_evaluar_identidad(x, bloqueo)
        //    }
        //});
    }

    function NOSIS_evaluar_identidad(x,bloqueo) 
    {
        $('divSelTrabajo').hide()
        $('divTrabajo').show()
        $('divDatosPersonales').show()
        cupo_disponible = parseFloat(Trabajos[x]['disponible']).toFixed(2)
        nro_sistema = Trabajos[x]['nro_sistema']
        nro_lote = Trabajos[x]['nro_lote']
        sistema = Trabajos[x]['sistema']
        lote = Trabajos[x]['lote']
        clave_sueldo = Trabajos[x]['clave_sueldo']
        $('cupo_disponible').innerHTML = '$ ' + parseFloat(cupo_disponible).toFixed(2)
        $('fecha_actualizacion').innerHTML = '(' + Trabajos[x]['fecha_actualizacion'] + ')'
        var strXML = ""
        var strHTML = ""
        if ($('nro_docu').value != '') {
            var oXML = new tXML();
            oXML.async = true

            var existe
            oXML.load('/precarga/NOSIS/GetXML.aspx', 'accion=SAC_identidad&criterio=<criterio><nro_docu>' + $('nro_docu').value + '</nro_docu><CDA>' + CDA + '</CDA><nro_vendedor>' + nro_vendedor + '</nro_vendedor><nro_banco>' + nro_banco + '</nro_banco></criterio>',
                function () {
                    var NODs = oXML.selectNodes('Resultado/Personas/Persona')
                    if (NODs.length == 0)
                    {
                        alert('No se encontro información con el documento ingresado.')
                        Precarga_Limpiar()
                        nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                    }
                    if (NODs.length == 1) 
                    {
                      cuit = XMLText(selectSingleNode('Doc', NODs[0]))
                      existe = selectSingleNode('@existe', NODs[0]).nodeValue
                      NOSIS_actualizar_fuentes(cuit, existe)
                      }
                    if (NODs.length > 1) 
                      {
                        //var widthWin = $('contenedor').getWidth() - 50
                      Ajustar_ventana()
                      win_sel_cuit = window.top.createWindow2({
                            title: '<b>Seleccionar Persona</b>',
                            minimizable: false,
                            maximizable: false,
                            draggable: true,
                            top: topWin,
                            left: leftWin,
                            width: widthWin,
                            height: heightWin,
                            resizable: false,
                            onClose: function (win) {
                                var e
                                try {
                                    cuit = win.options.userData.res['cuit']
                                    existe = win.options.userData.res['existe']
                                }
                                catch (e) {
                                    Precarga_Limpiar()
                                    return
                                }

                                NOSIS_actualizar_fuentes(cuit, existe)
                            }
                        });
                      win_sel_cuit.options.userData = { NODs: oXML }
                      win_sel_cuit.setURL('NOSIS_sel_cuit.aspx')
                      if (BodyWidth < 1024)
                          win_sel_cuit.show()
                      else
                          win_sel_cuit.showCenter(true)
                    }
                    nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                }
                );
        }
        //nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
    }    

    function NOSIS_actualizar_fuentes(cuit,existe)
    {
        if ((existe == "false") || (existe == false))
        {
            var url = ""
            var oXML1 = new tXML();
            oXML1.async = false
            if (oXML1.load('/precarga/NOSIS/GetXML.aspx?accion=sac_get_token&criterio=<criterio><nro_banco>' + nro_banco + '</nro_banco></criterio>')) 
              {
              var NODs = oXML1.selectNodes('resultado/url')
              if (NODs.length == 1)
                    url = XMLText(NODs[0])
              }
            if (url != "")
              {
              nvFW.error_ajax_request('default.aspx', {
                    parameters: { modo: 'F', cuit: cuit, url: url },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0)
                            NOSIS_generar_informe(cuit)
                        else
                            {
                            alert(err.titulo + '<br>' + err.mensaje)
                            Precarga_Limpiar()
                            }
                    },
                    onFailure: function (err) {
                        Precarga_Limpiar()
                    }
                });
              }
        }
        else
            NOSIS_generar_informe(cuit)
    }

    var NosisXML = ''
    var strHTMLNosis = ''

    function NOSIS_generar_informe(cuit)
    {
        
        var oXML = new tXML();
        oXML.async = false
        if (oXML.load('/precarga/NOSIS/GetXML.aspx?accion=SAC_informe&criterio=<criterio><cuit>' + cuit + '</cuit><CDA>' + CDA + '</CDA><nro_vendedor>' + nro_vendedor + '</nro_vendedor><nro_banco>' + nro_banco + '</nro_banco></criterio>')) {
            strXML = XMLtoString(oXML.xml)
            NosisXML = strXML
            BCRA_obtener(strXML)
            objXML = new tXML();
            objXML.async = false
            if (objXML.loadXML(strXML))
                var NODs = objXML.selectNodes('Respuesta/ParteHTML')
            if (NODs.length == 1)
                strHTMLNosis = XMLText(NODs[0])
            //$('HTMLNosis').value = strHTML
        }
    }
    
    var prueba = ''
    var NroConsulta = 0    
    var edad = ''
    var fe_naci_str = ''
    var sit_bcra = 99
    var HTMLCDA = ''

    function BCRA_obtener(strXML)
    {
        try {
            var SitBCRA = {}
            objXML = new tXML();
            objXML.async = false
            if (objXML.loadXML(strXML)) {
                Deuda = objXML.getElementsByTagName('Deuda')
                NroConsulta = XMLText(objXML.selectSingleNode('Respuesta/Consulta/NroConsulta'))
                cuit = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Doc'))
                razon_social = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/RZ'))
                edad = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/Edad')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Edad')) : '99'
                documento = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Tipo'))
                domicilio = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Dom')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Dom')) : ''
                localidad = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Loc')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Loc')) : ''
                CP = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/CP')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/CP')) : sucursal_postal_real
                provincia = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Prov')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/DomFiscal/Prov')) : ''
                switch (documento) {
                    case 'DNI':
                        tipo_docu = 3
                        break;
                    case 'LE':
                        tipo_docu = 1
                        break;
                    case 'LC':
                        tipo_docu = 2
                        break;
                    default:
                        tipo_docu = 3
                }

                nro_docu = cuit.substring(2, 10)
                sexo = 'M'
                sexo_desc = XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/Sexo'))
                if (sexo_desc == 'Femenino')
                    sexo = 'F'
                fe_naci_str = (objXML.selectSingleNode('Respuesta/ParteXML/Dato/FecNac')) ? XMLText(objXML.selectSingleNode('Respuesta/ParteXML/Dato/FecNac')) : ''
                fe_naci = (fe_naci_str != '') ? fe_naci_str.substring(6, 8) + '/' + fe_naci_str.substring(4, 6) + '/' + fe_naci_str.substring(0, 4) : ''
                $('strApeyNomb').innerHTML = ''
                $('strApeyNomb').insert({ bottom: razon_social })
                $('strCUIT').innerHTML = ''
                $('strCUIT').insert({ bottom: cuit })
                $('strTrabajo').innerHTML = ''
                $('strTrabajo').insert({ bottom: sistema + ' - ' + lote })
                $('strClave').innerHTML = ''
                $('strClave').insert({ bottom: clave_sueldo })
                $('strFNac').innerHTML = ''
                if (fe_naci != '')                    
                    $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                var rs = new tRS();
                rs.open({ filtroXML: nvFW.pageContents["sit_bcra"], params: "<criterio><params id_consulta='" + NroConsulta + "' /></criterio>" })
                if (!rs.eof())
                    sit_bcra = rs.getdata('situacion')

                $('strSitBCRA').innerHTML = ''
                $('strSitBCRA').insert({ bottom: sit_bcra })
                $('strSitBCRA').removeClassName($('strSitBCRA').className)
                switch (sit_bcra) {
                    case '1':
                        $('strSitBCRA').addClassName('sit1')
                        break;
                    case '2':
                        $('strSitBCRA').addClassName('sit2')
                        break;
                    case '3':
                        $('strSitBCRA').addClassName('sit3')
                        break;
                    case '4':
                        $('strSitBCRA').addClassName('sit4')
                        break;
                    case '5':
                        $('strSitBCRA').addClassName('sit5')
                        break;
                    case '6':
                        $('strSitBCRA').addClassName('sit6')
                        break;
                }
                empresa = objXML.getElementsByTagName('CalculoCDA')[0].getAttribute('Titulo')
                HTMLCDA += "<html><head></head><body style='width:100%;height:100%;overflow:hidden'><table class='tb1 highlightEven' style='width:100%'><tr><td style='width:30%'><b>CDA</b></td><td style='width:80%' class='Tit1'>" + empresa + "</td></tr>"

                itemsCDA = objXML.getElementsByTagName('Item')
                for (var i = 0; i < itemsCDA.length; i++) {
                    descripcion = XMLText(itemsCDA[i].childNodes[0])
                    if (descripcion == 'Dictamen') {
                        valor = "<b>" + XMLText(itemsCDA[i].childNodes[1]) + "</b>"
                        dictamen = XMLText(itemsCDA[i].childNodes[1])
                        $('strDictamen').innerHTML = ''
                        $('strDictamen').insert({ bottom: dictamen })
                        $('strDictamen').removeClassName($('strDictamen').className)
                        switch (dictamen) {
                            case 'APROBADO':
                                $('strDictamen').addClassName('cdaAC')
                                break;
                            case 'OBSERVADO':
                                $('strDictamen').addClassName('cdaOB')
                                break;
                            case 'RECHAZADO':
                                $('strDictamen').addClassName('cdaRC')
                                break;
                        }
                    }
                    else
                        valor = XMLText(itemsCDA[i].childNodes[1])
                    HTMLCDA += "<tr><td style='width:30%'>" + descripcion + "</td><td style='text-align:center'>" + valor + "</td></tr>"
                }
                HTMLCDA += "</table></body></html>"
                nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
                CargarSocio(true)
            }
        }
        catch (err)
        {
            alert('Error al recuperar la información de la persona. Consulte al administrador del sistema.')
        }
    }

    function VerInformeNosis()
    {
        if (strHTMLNosis == '')
        {
            alert('No existe el informe de Nosis.')
            return
        }
            strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
            var win = window.open()
            win.document.write(strHTMLNosis)
    }

    var win_cda
    function VerCDA()
    {
        /*var heightWin = $$('body')[0].getHeight()
        var widthWin = $('contenedor').getWidth() - 50
        var BodyWidth = $$('body')[0].getWidth()*/
        Ajustar_ventana()
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_cda = w.createWindow({
            className: 'alphacube',
            title: '<b>Criterio de Aceptación</b>',
            minimizable: false,
            maximizable: false,
            draggable: true,
            top: topWin,
            left: leftWin,
            width: widthWin,
            height: heightWin,
            resizable: false,
        });

        win_cda.setHTMLContent(HTMLCDA)
        if (BodyWidth < 1024)
            win_cda.show()
        else
            win_cda.showCenter(true)

        /*
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_vendedor = w.createWindow({
            className: 'alphacube',
            url: 'selVendedor.aspx',
            title: '<b>Seleccionar Vendedor</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            top: topWin,
            left: leftWin,
            width: widthWin,
            height: heightWin,
            resizable: false,
            onClose: selVendedor_return
        });
        win_vendedor.options.userData = { res: '' }
        if (BodyWidth < 1024)
            win_vendedor.show()
        else
            win_vendedor.showCenter(true)
        */

    }

    var Creditos = {}
    var win_persona
    
    var persona_existe = true
    var fe_naci_socio = ''
    var edad_socio = 0
    var win_sel_persona

    var datos_persona = {}

    function CargarSocio(bloqueo)
    {
        
        $('tbCredVigente').innerHTML = ''
        $('tbCuotaSocial').innerHTML = ''
        var rs = new tRS();
        rs.async = true
        rs.onComplete = function (rs) {
            if (rs.recordcount == 0) {
                var rsPr = new tRS();
                rsPr.open({ filtroXML: nvFW.pageContents["persona_docu"], params: "<criterio><params nro_docu='" + nro_docu + "' /></criterio>" })
                if (!rsPr.eof())
                {
                    if (bloqueo)
                        nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                    datos_persona['nro_docu'] = nro_docu
                    datos_persona['cuit'] = cuit
                    Ajustar_ventana()
                    win_sel_persona = window.top.createWindow2({
                        title: '<b>Seleccionar Persona</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        top: topWin,
                        left: leftWin,
                        width: widthWin,
                        height: heightWin,
                        resizable: false,
                        onClose: function (win) {
                            if (win.options.userData.res != undefined)
                            {
                                nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
                                var filtros = {}
                                filtros['nro_docu'] = win.options.userData.res['nro_docu']
                                filtros['tipo_docu'] = win.options.userData.res['tipo_docu']
                                filtros['sexo'] = win.options.userData.res['sexo']
                                filtros['cuit'] = ''
                                var nombre = win.options.userData.res['nombre']
                                fe_naci_socio = win.options.userData.res['fe_naci']
                                edad_socio = win.options.userData.res['edad']
                                $('divSocio').show()
                                $('strSApeyNomb').innerHTML = ''
                                $('strSApeyNomb').insert({ bottom: nombre })
                                rs = null
                                CargarSocio_Creditos(filtros, bloqueo)
                            }
                            else
                            {                                
                                nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
                                $('divSocio').hide()
                                persona_existe = false
                                SeleccionarPlanesMostrar()
                                CargarBancos()
                                banco_onchange()
                                //if (bloqueo)
                                nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                            }                           
                        }
                    });
                    win_sel_persona.options.userData = { datos_persona: datos_persona }
                    win_sel_persona.setURL('precarga_sel_persona.aspx')
                    if (BodyWidth < 1024)
                        win_sel_persona.show()
                    else
                        win_sel_persona.showCenter(true)
                }
                else
                {
                    $('divSocio').hide()
                    persona_existe = false
                    SeleccionarPlanesMostrar()
                    CargarBancos()
                    banco_onchange()
                    if (bloqueo)
                        nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                }
            }
            if (!rs.eof()) {
                if (rs.recordcount == 1) {  // Si la búsqueda de la persona por cuit da un resultado -> Carga creditos y CS
                    nro_docu = rs.getdata('nro_docu')
                    tipo_docu = rs.getdata('tipo_docu')
                    sexo = rs.getdata('sexo')
                    var filtros = {}
                    filtros['nro_docu'] = nro_docu
                    filtros['tipo_docu'] = tipo_docu
                    filtros['sexo'] = sexo
                    filtros['cuit'] = cuit
                    $('divSocio').show()
                    $('strSApeyNomb').innerHTML = ''
                    $('strSApeyNomb').insert({ bottom: rs.getdata('strNombreCompleto') })
                    fe_naci_socio = rs.getdata('fe_naci')
                    edad_socio = rs.getdata('edad')                    
                    CargarSocio_Creditos(filtros, bloqueo)
                }
                if (rs.recordcount > 1) {                      // Si la búsqueda da más de un resultado
                    if (bloqueo)
                        nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                    datos_persona['nro_docu'] = ''
                    datos_persona['cuit'] = cuit
                    Ajustar_ventana()
                    win_sel_persona = window.top.createWindow2({
                        title: '<b>Seleccionar Persona</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        top: topWin,
                        left: leftWin,
                        width: widthWin,
                        height: heightWin,
                        resizable: false,
                        onClose: function (win) {
                            if (win.options.userData.res != undefined) {
                                nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
                                var filtros = {}
                                filtros['nro_docu'] = win.options.userData.res['nro_docu']
                                filtros['tipo_docu'] = win.options.userData.res['tipo_docu']
                                filtros['sexo'] = win.options.userData.res['sexo']
                                filtros['cuit'] = ''
                                var nombre = win.options.userData.res['nombre']
                                fe_naci_socio = win.options.userData.res['fe_naci']
                                $('divSocio').show()
                                $('strSApeyNomb').innerHTML = ''
                                $('strSApeyNomb').insert({ bottom: nombre })
                                rs = null
                                CargarSocio_Creditos(filtros, bloqueo)
                            }
                            else {
                                nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
                                $('divSocio').hide()
                                persona_existe = false
                                SeleccionarPlanesMostrar()
                                CargarBancos()
                                banco_onchange()
                                //if (bloqueo)
                                nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                            }
                        }
                    });
                    win_sel_persona.options.userData = { datos_persona: datos_persona }
                    win_sel_persona.setURL('precarga_sel_persona.aspx')
                    if (BodyWidth < 1024)
                        win_sel_persona.show()
                    else
                        win_sel_persona.showCenter(true)
                }
            }
        }
        rs.open({ filtroXML: nvFW.pageContents["persona"], params: "<criterio><params cuit='" + cuit + "' /></criterio>" })
    }

    function CargarSocio_Creditos(filtros,bloqueo)
    {
        var strHTMLS = "<table class='tb1' cellspacing='1' cellpadding='1' style='vertical-align:top'>"
        strHTMLS += "<tr><td class='Tit1' style='width:70%'>Mutual</td><td class='Tit1' style='width:30%;text-align:right'>Cuota</td><tr>"
        var strHTMLC = "<table id='tbCred' class='tb1 highlightEven highlightTROver' cellspacing='1' cellpadding='1' style='vertical-align:top;'><tr><td class='Tit1' style='width:10%'>Credito</td><td class='Tit1' width:30%>Banco</td><td class='Tit1' width:30%>Mutual</td><td class='Tit1' style='width:12%;text-align:right'>Cuota</td><td class='Tit1' style='width:13%;text-align:right'>Saldo</td><td class='Tit1' style='width:5%;text-align:center'>C</td></tr>"
        var i = 0
        var rsC = new tRS();
        rsC.async = true
        rsC.onComplete = function (rsC) {
            while (!rsC.eof()) {
                i++
                Creditos[i] = {}
                Creditos[i]['nro_credito'] = rsC.getdata('nro_credito')
                Creditos[i]['nro_banco'] = rsC.getdata('nro_banco')
                Creditos[i]['nro_mutual'] = rsC.getdata('nro_mutual')
                Creditos[i]['importe_cuota'] = (rsC.getdata('nro_calc_tipo') == 4) ? parseFloat(rsC.getdata('importe_cuota_seg')).toFixed(2) : parseFloat(rsC.getdata('importe_cuota')).toFixed(2)
                Creditos[i]['saldo'] = parseFloat(rsC.getdata('saldo_importe')).toFixed(2)
                Creditos[i]['saldo_nro_entidad'] = rsC.getdata('saldo_entidad')
                Creditos[i]['cancela_vence'] = FechaToSTR(new Date(parseFecha(rsC.getdata('saldo_vencimiento'))))
                Creditos[i]['cancela_cuota_paga'] = rsC.getdata('cuotas_pagadas')
                Creditos[i]['nro_credito_seguro'] = rsC.getdata('nro_credito_seguro')
                Creditos[i]['nro_calc_tipo'] = rsC.getdata('nro_calc_tipo')
                Creditos[i]['cancela'] = false
                var strChek = ''
                var strClass = ''
                for (j in Cancel) {
                    if (Creditos[i]['nro_credito'] == Cancel[j]['cancela_nro_credito']) {
                        Creditos[i]['cancela'] = true
                        TotalCancelaciones = parseFloat(parseFloat(TotalCancelaciones) + parseFloat(Creditos[i]['saldo'])).toFixed(2)
                        LiberaCuota = parseFloat(parseFloat(LiberaCuota) + parseFloat(Creditos[i]['importe_cuota'])).toFixed(2)
                        strChek = 'checked'
                        strClass = "class='tr_sel'"
                        break
                    }
                }
                strHTMLC += "<tr id='trCr_" + i + "' style='cursor:pointer;' " + strClass + " onclick='btnCancela_onClick(" + i + ")'><td nowrap='true'>" + rsC.getdata('nro_credito') + "</td><td>" + rsC.getdata('banco') + "</td><td nowrap='true'>" + rsC.getdata('mutual') + "</td><td style='text-align:right' nowrap='true'>$ " + Creditos[i]['importe_cuota'] + "</td><td style='text-align:right' nowrap='true'>$ " + parseFloat(rsC.getdata('saldo_importe')).toFixed(2) + "</td><td nowrap='true' style='text-align:center'><input type='checkbox' id='chkCred_" + i + "' style='border:0' " + strChek + " /></td></tr>"
                rsC.movenext()
            }
            var rsCS = new tRS();
            if (filtros['cuit'] == '')
                rsCS.open({ filtroXML: nvFW.pageContents["creditos_cs_docu"], params: "<criterio><params nro_docu='" + filtros['nro_docu'] + "' tipo_docu='" + filtros['tipo_docu'] + "' sexo='" + filtros['sexo'] + "' /></criterio>" })
            else
                rsCS.open({ filtroXML: nvFW.pageContents["creditos_cs"], params: "<criterio><params cuit='" + filtros['cuit'] + "' /></criterio>" })
            while (!rsCS.eof()) {
                i++
                Creditos[i] = {}
                Creditos[i]['nro_credito'] = 0
                Creditos[i]['nro_banco'] = 200
                Creditos[i]['nro_mutual'] = rsCS.getdata('nro_mutual')
                Creditos[i]['importe_cuota'] = parseFloat(rsCS.getdata('importe_cuota')).toFixed(2)
                Creditos[i]['saldo'] = 0
                Creditos[i]['saldo_nro_entidad'] = 0
                Creditos[i]['cancela_vence'] = ''
                Creditos[i]['cancela_cuota_paga'] = 0
                Creditos[i]['nro_credito_seguro'] = 0
                Creditos[i]['nro_calc_tipo'] = 0
                Creditos[i]['cancela'] = false
                strHTMLS += "<tr><td>" + rsCS.getdata('mutual') + "</td><td style='text-align:right'>$ " + parseFloat(rsCS.getdata('importe_cuota')).toFixed(2) + "</td></tr>"
                rsCS.movenext()
            }

            strHTMLS += "</table>"
            strHTMLC += "</table>"
            $('tbCuotaSocial').insert({ bottom: strHTMLS })
            $('tbCredVigente').insert({ bottom: strHTMLC })
            SeleccionarPlanesMostrar()
            CargarBancos()
            banco_onchange()
            if (bloqueo)
                nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
        }
        rsC.open({ filtroXML: nvFW.pageContents["saldos"], params: "<criterio><params nro_docu='" + filtros['nro_docu'] + "' tipo_docu='" + filtros['tipo_docu'] + "' sexo='" + filtros['sexo'] + "' /></criterio>" })
    }

    function Sel_persona_return()
    {
        if (win_persona.options.userData) {
            var retorno = win_persona.options.userData.res
            var filtrop = {}
            filtrop['cuit'] = ''
            filtrop['nro_docu'] = retorno['nro_docu']
            filtrop['tipo_docu'] = retorno['tipo_docu']
            filtrop['sexo'] = retorno['sexo']
            nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
            CargarSocio(filtrop,true)
        }
    }

    function btnCancela_onClick(i)
    {
        var tr = $('trCr_' + i)
        if (tr.className == 'tbLabel')
            {
            tr.removeClassName('tbLabel')
            $('chkCred_' + i).checked = false
            }            
        else
            {
            tr.addClassName('tbLabel')
            $('chkCred_' + i).checked = true        
            }
        TotalCancelaciones = 0
        LiberaCuota = 0

        //Si tiene seguro forzar la selección
        for (var j in Creditos) {
            if (j != i) {
                if ((Creditos[j]['nro_credito_seguro'] != 0) && (Creditos[i]['nro_credito_seguro'] == Creditos[j]['nro_credito_seguro'])) {
                    var trS = $('trCr_' + j)
                    if ($('chkCred_' + i).checked == true) {
                        trS.addClassName('tbLabel')
                        $('chkCred_' + j).checked = true
                        Creditos[j]['cancela'] = true
                    }
                    else {
                        trS.removeClassName('tbLabel')
                        $('chkCred_' + j).checked = false
                        Creditos[j]['cancela'] = false
                    }
                }
            }
        }
        
        for (var x in Creditos) {
            if (x == i)
                if ($('chkCred_' + i).checked == true)
                    Creditos[x]['cancela'] = true
                else
                    Creditos[x]['cancela'] = false
            if (Creditos[x]['cancela'] == true) {
                TotalCancelaciones = parseFloat(parseFloat(TotalCancelaciones) + parseFloat(Creditos[x]['saldo'])).toFixed(2)
                LiberaCuota = parseFloat(parseFloat(LiberaCuota) + parseFloat(Creditos[x]['importe_cuota'])).toFixed(2)
            }
        }

        $('strCancelaciones').innerHTML = ''
        $('strCancelaciones').insert({ bottom: '$ ' + parseFloat(TotalCancelaciones).toFixed(2) })
        $('strCuotaLiberada').innerHTML = ''
        $('strCuotaLiberada').insert({ bottom: '$ ' + parseFloat(LiberaCuota).toFixed(2) })
        importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
        $('strCuotaMaxima').innerHTML = ''
        $('strCuotaMaxima').insert({ bottom: '$ ' + parseFloat(importe_max_cuota).toFixed(2) })
        //btnBuscarPLanes_onclick()
        Validar_datos()
    }

    var plan_lineas = ''

    function CargarBancos() {
        
        $('banco').options.length = 0
        var i = 0
        var rs = new tRS();
        rs.open({ filtroXML: nvFW.pageContents["operatorias"], params: "<criterio><params cuit='" + cuit + "' nro_sistema='" + nro_sistema + "' nro_lote='" + nro_lote + "' sit_bcra='" + sit_bcra + "' nro_banco='0' nro_mutual='0' salida='B' /></criterio>" })
        while (!rs.eof()) {
            $('banco').insert(new Element('option', { value: rs.getdata('nro_banco') }).update(rs.getdata('banco')))
            rs.movenext()
        }
        $('banco').setStyle({ width: '100%' })
    }

    function banco_onchange() {
        var nro_banco_filtro = $('banco').value
        CargarMutuales(nro_banco_filtro)
        mutual_onchange()
    }

    function CargarMutuales(nro_banco_filtro) {
        $('mutual').options.length = 0
        var i = 0
        var sel = false
        var rs = new tRS();
        rs.open({ filtroXML: nvFW.pageContents["operatorias"], params: "<criterio><params cuit='" + cuit + "' nro_sistema='" + nro_sistema + "' nro_lote='" + nro_lote + "' sit_bcra='" + sit_bcra + "' nro_banco='" + nro_banco_filtro + "' nro_mutual='0' salida='M' /></criterio>" })
        while (!rs.eof()) {
            var descripcion = ''
            for (var j in Creditos)
            {
                if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == rs.getdata('nro_mutual'))
                    {
                    descripcion = ' (Socio)'
                    break
                    }                    
            }
            $('mutual').insert(new Element('option', { value: rs.getdata('nro_mutual') }).update(rs.getdata('mutual') + descripcion))
                if ((descripcion != '') && (sel == false))
                    $('mutual').selectedIndex = $('mutual').options.length - 1
            i++
            rs.movenext()
        }
        $('mutual').setStyle({ width: '100%' })
    }
    
    var importe_cuota_social = 0 

    function mutual_onchange() {
        var rs_cs = new tRS();
        rs_cs.open("<criterio><select vista='auxMutual_cuota'><campos>top 1 importe_cuota as importe_cuota_social</campos><filtro><nro_mutual type='igual'>" + $('mutual').value + "</nro_mutual></filtro><orden></orden></select></criterio>")
        if (!rs_cs.eof())
            importe_cuota_social = parseFloat(rs_cs.getdata('importe_cuota_social')).toFixed(2)

        var filtro = "<nro_banco DataType='int'>" + $('banco').value + "</nro_banco><nro_mutual DataType='int'>" + $('mutual').value + "</nro_mutual>"
        var rs = new tRS();
        rs.open({ filtroXML: nvFW.pageContents["operatorias"], params: "<criterio><params cuit='" + cuit + "' nro_sistema='" + nro_sistema + "' nro_lote='" + nro_lote + "' sit_bcra='" + sit_bcra + "' nro_banco='" + $('banco').value + "' nro_mutual='" + $('mutual').value + "' salida='L' /></criterio>" })
        while (!rs.eof()) {
            plan_lineas += plan_lineas != '' ? ', ' + rs.getdata('nro_plan_linea') : rs.getdata('nro_plan_linea')
            rs.movenext()
        }
        SeleccionarPlanesMostrar()
        //btnBuscarPLanes_onclick()
        Validar_datos()
    }

    function win_edad_cerrar(aceptar) {
        if (aceptar) {
            if ($('fe_naci').value == '') {
                alert('Ingrese la fecha de nacimiento.')
                return
            }
        }
        btn_aceptar = aceptar
        win_edad.close()
    }

    var win_edad
    var btn_aceptar = false

    function getEdad(dateString) {
        var dia = dateString.substring(0,dateString.indexOf("/"))
        var mes = dateString.substring(dateString.indexOf("/") + 1, dateString.indexOf("/", dateString.indexOf("/")+1))
        var anio = dateString.substring(dateString.indexOf("/", dateString.indexOf("/") + 1) + 1, dateString.length)
        dateString = mes + "/" + dia + "/" + anio
        var today = new Date();
        var birthDate = new Date(dateString);
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    }

    function Validar_datos()
    {
        if (fe_naci == '')
        {
            fe_naci = fe_naci_socio
            edad = edad_socio
            $('strFNac').innerHTML = ''
            $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
        }            

        if (fe_naci == '') {
            var widthWin = 0
            var BodyWidth = $$('body')[0].getWidth()
            if (BodyWidth < 1024)
                widthWin = $('contenedor').getWidth() - 50
            else
                widthWin = 400
            nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
            //campos_defs.add('fe_naci', { target: 'tdfe_naci', enDB: false, nro_campo_tipo: 103 })
            win_edad = new Window({
                className: 'alphacube',
                title: '<b>No se pudo obtener la edad de la persona</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                recenterAuto: false,
                width: widthWin,
                height: 100,
                onClose: function () {
                    fe_naci = $('fe_naci').value
                    edad = getEdad(fe_naci)
                    $('strFNac').innerHTML = ''
                    $('strFNac').insert({ bottom: fe_naci + ' (' + edad + ')' })
                    if (btn_aceptar)
                        btnBuscarPLanes_onclick()
                }
            });
            var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
            html += '<table class="tb1">'
            html += '<tbody><tr><td class="Tit1"><b>Ingrese la fecha de nacimiento</b></td><td><input type="text" value="" id="fe_naci" style="width:100%" onkeypress="return valDigito(event, \'/\')" onchange="valFecha(event)" /></td></tr>'
            html += '<tr><td style="text-align:center;width:50%"><br><input type="button" style="width:80%" value="Cancelar" onclick="win_edad_cerrar(false)" style="cursor:pointer" /></td><td style="text-align:center;width:50%"><br><input type="button" style="width:80%" value="Aceptar" onclick="win_edad_cerrar(true)" style="cursor:pointer"/></td></tr>'
            html += '</tbody></table></body></html>'

            win_edad.setHTMLContent(html)
            win_edad.showCenter(true)            
            //alert('Error al obtener la fecha de nacimiento. Verifique.')
            //return
        }
        else
            btnBuscarPLanes_onclick()
    }

    
    function btnBuscarPLanes_onclick()
    {        
        var nro_mutual = $('mutual').value
        var nro_banco = $('banco').value
        if ((nro_mutual != '') && (nro_banco != ''))
        {
            nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
            var strWhere = ''
            strWhere += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
            strWhere += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"
            strWhere += "<nro_sistema type='igual'>" + nro_sistema + "</nro_sistema>"
            strWhere += "<nro_lote type='igual'>" + nro_lote + "</nro_lote>"
            strWhere += "<marca type='igual'>'S'</marca>"
            strWhere += "<falta type='menos'>getdate()</falta>"
            strWhere += "<fbaja type='sql'>(fbaja > getdate() or fbaja is null)</fbaja>"
            strWhere += "<vigente type='igual'>1</vigente>"
            strWhere += "<nro_tabla_tipo type='igual'>1</nro_tabla_tipo>"

            if (plan_lineas != '')
                strWhere += "<nro_plan_linea type='in'>" + plan_lineas + "</nro_plan_linea>"

            var campo_max
            var campo_min
            if (sexo == 'M') {
                campo_max = 'edad_max_masc'
                campo_min = 'edad_min_masc'
            }
            else {
                campo_max = 'edad_max_fem'
                campo_min = 'edad_min_fem'
            }

            strWhere += "<sql type='sql'><![CDATA[datediff(year," + ajustarFecha(fe_naci) + ", getdate()) >= " + campo_min + "]]></sql>"

            strWhere += "<sql type='sql'><![CDATA[datediff(year, " + ajustarFecha(fe_naci) + ", dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) <= " + campo_max + "]]></sql>"

            var maxImporte = TotalCancelaciones

            if ($('chkmax_disp').checked) {
                var strIn = '(Select max(importe_cuota) from planes where planes.nroTabla = verPlanes_lotes.nroTabla and planes.importe_cuota <= ' + importe_max_cuota + ')'
                strWhere += "<importe_cuota type='igual'><![CDATA[" + strIn + "]]></importe_cuota>"
                strWhere += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
            }
            else {
                strWhere += "<importe_cuota type='menos'>" + importe_max_cuota + "</importe_cuota>"
                if ($('retirado_desde').value != "")
                    if (parseFloat($('retirado_desde').value) > parseFloat(TotalCancelaciones))
                        maxImporte = $('retirado_desde').value
                strWhere += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
                if ($('retirado_hasta').value != '')
                    strWhere += "<importe_neto type='menos'>" + $('retirado_hasta').value + "</importe_neto>"
                if ($('importe_cuota_desde').value != '')
                    strWhere += "<importe_cuota type='mas'>" + $('importe_cuota_desde').value + "</importe_cuota>"
                if ($('importe_cuota_hasta').value != '')
                    strWhere += "<importe_cuota type='menos'>" + $('importe_cuota_hasta').value + "</importe_cuota>"
                if ($('cuota_desde').value != '')
                    strWhere += "<cuotas type='mas'>" + $('cuota_desde').value + "</cuotas>"
                if ($('cuota_hasta').value != '')
                    strWhere += "<cuotas type='menos'>" + $('cuota_hasta').value + "</cuotas>"
            }

            var heightWin = $$('body')[0].getHeight()
            var widthWin = $('contenedor').getWidth() - 50
            var BodyWidth = $$('body')[0].getWidth()
            //if (BodyWidth < 1024)
            //    WinTipo = 'S'
            //else
            //    WinTipo = 'C'
            WinTipo = 'C'

            var filtroXML = "<criterio><select vista='verPlanes_lotes' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos><![CDATA[datediff(year, " + ajustarFecha(fe_naci) + ", dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) as edad_fin, nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,nro_tipo_cobro,gastoscomerc,mes_vencimiento,'" + WinTipo + "' as WinTipo]]></campos><orden>nro_plan</orden><filtro>" + strWhere + "</filtro></select></criterio>"
            nvFW.exportarReporte({
                filtroXML: filtroXML,
                xsl_name: 'lst_planes_precarga_HTML.xsl',
                formTarget: 'ifrplanes',
                async: true,
                funComplete: function (e) {
                    nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                    var tbCabe_h = $('ifrplanes').contentWindow.document.getElementById('tbCabe').getHeight()
                    var div_lst_creditos_h = $('ifrplanes').contentWindow.document.getElementById('div_lst_creditos').getHeight()
                    var div_pag_h = $('ifrplanes').contentWindow.document.getElementById('div_pag').getHeight()
                    $('ifrplanes').setStyle({ height: tbCabe_h + div_lst_creditos_h + div_pag_h + 25 + 'px' })
                },
                nvFW_mantener_origen: true/*,
            bloq_contenedor: 'ifrplanes',
            cls_contenedor: 'ifrplanes'*/
            })
        }

    }
    
    function SeleccionarPlanesMostrar()
    {
        $('divProducto').show()
        $('divFiltros').show()
        $('tbButtons').show()
        $('strCancelaciones').innerText = ''
        $('strCuotaMaxima').innerText = ''
        $('strCuotaLiberada').innerHTML = ''
        $('strCuotaSocial').innerHTML = ''
        $('chkmax_disp').checked = true
        $('strCancelaciones').insert({ bottom: '$ ' + parseFloat(TotalCancelaciones).toFixed(2) })
        $('strCuotaLiberada').insert({ bottom: '$ ' + parseFloat(LiberaCuota).toFixed(2) })
        $('strCuotaSocial').insert({ bottom: '$ ' + parseFloat(importe_cuota_social).toFixed(2) })
        importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
        var socio = false
        for (var j in Creditos) {
            if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == $('mutual').value) {
                socio = true
                break
            }
        }
        if (!socio)
            importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)
        $('strCuotaMaxima').insert({ bottom: '$ ' + parseFloat(importe_max_cuota).toFixed(2) })
    }    

    function chkmax_disp_on_click()
    {
        if ($('chkmax_disp').checked)
            {
            $('divFiltrosLeft').hide()
            $('divFiltrosRight').hide()
            $('divFiltros2Left').hide()
            }            
        else
            {
            $('divFiltrosLeft').show()
            $('divFiltrosRight').show()
            $('divFiltros2Left').show()
            }
    }

    var win_creditos

    function VerCreditos(modo)
    {
        Ajustar_ventana()
        var filtros = {}        
        filtros['modo'] = modo
        filtros['nro_vendedor'] = nro_vendedor
        filtros['nro_docu'] = nro_docu
        filtros['BodyWidth'] = BodyWidth
        if (modo == 'V')
            if (nro_vendedor == 0)
            {
                alert('Debe seleccionar un vendedor para realizar la consulta.')
                return
            }
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_creditos = w.createWindow({
            className: 'alphacube',
            url: 'Precarga_solicitud_creditos.aspx',
            title: '<b>Créditos del Mes</b>',
            minimizable: false,
            maximizable: false,
            draggable: true,
            top: topWin,
            left: leftWin,
            width: widthWin,
            height: heightWin,
            resizable: false,
        });
        win_creditos.options.userData = { filtros: filtros }
        if (BodyWidth < 1024)
            win_creditos.show()
        else
            win_creditos.showCenter(true)
    }

    var nro_plan_sel = 0

    function btnStatus(progress)
    {
        if (progress)
        {
            document.getElementById('btn1').onclick = null
            document.getElementById('btn1').style.cursor = 'progress'
            document.getElementById('img1').style.cursor = 'progress'
            document.getElementById('btn2').onclick = null
            document.getElementById('btn2').style.cursor = 'progress'
            document.getElementById('img2').style.cursor = 'progress'
            document.getElementById('btn3').onclick = null
            document.getElementById('btn3').style.cursor = 'progress'
            document.getElementById('img3').style.cursor = 'progress'
        }
        else
        {
            document.getElementById('btn1').onclick = function () { GuardarSolicitud('M') }
            document.getElementById('btn1').style.cursor = 'pointer'
            document.getElementById('img1').style.cursor = 'pointer'
            document.getElementById('btn2').onclick = function () { GuardarSolicitud('H') } 
            document.getElementById('btn2').style.cursor = 'pointer'
            document.getElementById('img2').style.cursor = 'pointer'
            document.getElementById('btn3').onclick = function () { Precarga_Limpiar() }
            document.getElementById('btn3').style.cursor = 'pointer'
            document.getElementById('img3').style.cursor = 'pointer'
        }
    }



    function GuardarSolicitud(estado)
    {
            btnStatus(true)
            nvFW.bloqueo_activar($(document.documentElement), 'Ajax_bloqueo')
            var modo = 'S'
            nro_plan_sel = 0            
            var iframe = $('ifrplanes');
            var radioGrp = iframe.contentDocument.forms.frmplanes.rdplan
            if (radioGrp.length == undefined)
                if (iframe.contentDocument.forms.frmplanes.rdplan.checked)
                    nro_plan_sel = iframe.contentDocument.forms.frmplanes.rdplan.value
            for (i = 0; i < radioGrp.length; i++) {
                if (radioGrp[i].checked == true)
                    nro_plan_sel = radioGrp[i].value
            }
            if (nro_plan_sel != 0)
            {
                /* XML Persona  */
                var xmlpersona = ""
                xmlpersona = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmlpersona += "<persona nro_docu='" + nro_docu + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' cuit='" + cuit + "' fe_naci='" + fe_naci + "' razon_social='" + razon_social + "' "
                xmlpersona += "domicilio='" + domicilio + "' CP='" + CP + "' localidad='" + localidad + "' provincia='" + provincia + "'></persona>"
                /* XML Trabajo */
                var xmltrabajo = ""
                xmltrabajo = "<?xml version='1.0' encoding='iso-8859-1'?><trabajo nro_sistema='" + nro_sistema + "' nro_lote='" + nro_lote + "' clave_sueldo='" + clave_sueldo + "'></trabajo>"
                /* XML Credito */
                var xmlcredito = ""
                xmlcredito = "<?xml version='1.0' encoding='iso-8859-1'?><credito estado='" + estado + "' nro_vendedor='" + nro_vendedor + "' nro_plan='" + nro_plan_sel + "'></credito>"
                /* XML Analisis */
                var xmlanalisis = ""
                xmlanalisis = "<?xml version='1.0' encoding='iso-8859-1'?><analisis cupo='" + cupo_disponible + "' sitBCRA='" + sit_bcra + "' cancelaciones='" + TotalCancelaciones + "' cuota_maxima='" + importe_max_cuota + "'></analisis>"
                /* XML Cancelaciones */
                var xmlcancelaciones = ""
                xmlcancelaciones = "<?xml version='1.0' encoding='iso-8859-1'?><cancelaciones>"
                for (var x in Creditos) {
                    if (Creditos[x]['cancela'] == true)
                        {
                        var nro_credito_calc = (Creditos[x]['nro_calc_tipo'] == 4) ? Creditos[x]['nro_credito_seguro'] : Creditos[x]['nro_credito']
                        xmlcancelaciones += "<cancelacion importe_pago='" + Creditos[x]['saldo'] + "' nro_entidad_destino='" + Creditos[x]['saldo_nro_entidad'] + "' cancela_cuota='" + Creditos[x]['importe_cuota'] + "' cancela_vence='" + Creditos[x]['cancela_vence'] + "' cancela_nro_credito='" + nro_credito_calc + "' cancela_cuota_paga='" + Creditos[x]['cancela_cuota_paga'] + "' />"
                        }
                }
                xmlcancelaciones += "</cancelaciones>"
                /* XML Parametros */
                var xmlparametros = ""
                xmlparametros = "<?xml version='1.0' encoding='iso-8859-1'?><parametros>"
                var rs = new tRS();
                rs.open("<criterio><select vista='verPlanes_Parametros'><campos>*</campos><orden></orden><filtro><nro_plan type='igual'>" + nro_plan_sel + "</nro_plan></filtro></select></criterio>")
                while (!rs.eof()) {
                    xmlparametros += "<parametro nombre='" + rs.getdata('parametro') + "' valor='" + rs.getdata('valor_defecto') + "' />"
                    rs.movenext()
                }
                xmlparametros += "</parametros>"
                var nro_credito = 0
                nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                nvFW.error_ajax_request('Default.aspx', {
                    parameters: { modo: modo, estado: estado, nro_credito: nro_credito, persona_existe: persona_existe, xmlpersona: xmlpersona, xmltrabajo: xmltrabajo, xmlcredito: xmlcredito, xmlanalisis: xmlanalisis, xmlcancelaciones: xmlcancelaciones, xmlparametros: xmlparametros, NosisXML: NosisXML },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0)
                            Precarga_Limpiar()
                        else
                            alert('Error al guardar el crédito.<br>' + err.numError + ' : ' + err.mensaje)
                        //{                        
                        //var nro_credito = err.params['nro_credito']
                        //var estado = err.params['estado']
                        //var descripcion = estado == 'M' ? 'Presupuesto generado correctamente' : 'Solicitud Enviada'
                        //var strAlert = "<table class='tb1' style='width:100%'><tr><td colspan='2' class='Tit1'><b>" + descripcion + "</b></td></tr><tr><td><b>Nro.credito:</b></td><td><a target='_blank' href='credito_mostrar.asp?nro_credito=" + nro_credito + "'><b>" + nro_credito + "</b></a></td></table>"
                        //alert(strAlert)                        
                        //}

                        /*if (err.numError == 0)
                            window.location.href = "../../meridiano/Precarga_solicitud.asp?nro_credito=" + nro_credito*/
                    }
                });

            }
            else
            {
                nvFW.bloqueo_desactivar($(document.documentElement), 'Ajax_bloqueo')
                btnStatus(false)
                alert('Seleccione un plan')
            }
                

            
    }

    function window_onresize() {
        try {
            Ajustar_ventana()
            if (win_vendedor != undefined)
            {
                win_vendedor.setLocation(topWin, leftWin)
                win_vendedor.setSize(widthWin, heightWin)
            }
            if (win_creditos != undefined)
            {
                win_creditos.setLocation(topWin, leftWin)
                win_creditos.setSize(widthWin, heightWin)
            }
            if (win_sel_cuit != undefined)
            {
                win_sel_cuit.setLocation(topWin, leftWin)
                win_sel_cuit.setSize(widthWin, heightWin)
            }
            if (win_cda != undefined)
            {
                win_cda.setLocation(topWin, leftWin)
                win_cda.setSize(widthWin, heightWin)
            }
            if (win_sel_persona != undefined)
            {
                win_sel_persona.setLocation(topWin, leftWin)
                win_sel_persona.setSize(widthWin, heightWin)
            }
        }
        catch (e) { }
    }
    

    </script>
    
</head>
<body onload="return window_onload()" onresize="return window_onresize()">
    <!--<input type="hidden" id="nro_vendedor" />
    <input type="hidden" id="NroConsulta" />    
    <input type="hidden" id="nro_credito" value="" />
    <input type="hidden" id="nro_plan" value="0" />
    <input type="hidden" id="nro_banco_sel" value="0" />
    <input type="hidden" id="nro_mutual_sel" value="0" />    
    <input type="hidden" name="sit_bcra" id="sit_bcra" value="" />-->    
    
    <div id="contenedor" style="overflow:auto">
        <!-- Información de Sesión -->
        <table cellpadding="0" cellspacing="0" border="0" style="width: 100%" class="tb1">
            <tr>
                <td style="align: left; text-align: left">
                    <!-- <iframe id="novaLobo" src="image/nvLogin/nova.svg" style="border: 0px; width:150px; height:64px" marginheight="0" marginwidth="0" noresize scrolling="No" frameborder="0"></iframe>-->
<%--                    <object data="/fw/image/nvLogin/nova.svg" style="width: 10.54em; height: 4.5em" type="image/svg+xml">
                        <img src="/fw/image/nvLogin/nvLogin_logo.png" alt="PNG image of standAlone.svg" />
                    </object>--%>
                    <object data="/precarga/image/nova.svg" id="logo" type="image/svg+xml">
                        <img src="/fw/image/nvLogin/nvLogin_logo.png" alt="PNG image of standAlone.svg" />
                    </object>
                </td>
                <td id="data_user" style="text-align: right; vertical-align: middle" nowrap>
                    <span id="user_name" nowrap><% = operador.login.ToUpper%></span>
                    <br />
                    <span id="user_sucursal" nowrap><% = operador.sucursal%></span>
                    <br />
                    <img border="0" class="img_button_sesion" alt="Bloquear sesión" title="Bloquear sesión" src="/precarga/image/bloquear_sesion.png" onclick="nvSesion.bloquear()" />
                    <img border="0" class="img_button_sesion" alt="Cerrar sesión" title="Cerrar sesión" src="/precarga/image/sesion_cerrar.gif" onclick="nvSesion.cerrar()" />
                </td>
            </tr>
        </table>
        <table class='tb1' style='border-collapse:collapse; border:none'>
            <tr class="tbLabel">
                <td style="text-align:left !important">Vendedor</td>
                <td style="width:60px" title="Buscar vendedor"><div id="divBuscarVendedor"/></td>
                <td style="width:60px" title="Ver créditos del vendedor"><div id="divVerCreditos"/></td>                
            </tr>
        </table>
    <div id="divVendedor">
        <div id="divVendedorLeft">
        <table class="tb1" style="border-collapse:collapse; border:none; width:100%">
            <tr>
                <td><span id="strVendedor"></span></td>
            </tr>
        </table>
        </div>
        <div id="divVendedorRight">        
        <table class="tb1" style="border-collapse:collapse; border:none; width:100%">
            <tr>
                <td id="vendedor_provincia"></td>
            </tr>
        </table>
        </div>
    </div>
    <!-- Buscar Persona -->
    <div id="divSelTrabajo"> 
        <table class="tb1" style='border-collapse:collapse; border:none; width:100%'>
            <tr class="tbLabel">
                <td style="text-align:left !important">Buscar Persona</td>
            </tr>
        </table>       
        <table class="tb1" style="border-collapse:collapse; border:none; width:100%">
                        <tr>
                            <td style="text-align:center; margin-left: auto; margin-right: auto;  align: center; padding:0.6em" >                               
                                Documento: &nbsp;&nbsp;<input type="number" name="nro_docu" id="nro_docu" style="width: 9em; text-align: right" maxlength="8" onkeypress="return btnBuscar_trabajo_onclick(event)" />
                                <br />
                                <div style="width:15.5em; margin: auto; padding-top:0.6em" id="divPBuscar"></div>
                            </td>
                        </tr>                                        
       </table>
     <div id="divMostrarTrabajos" style="display:none"></div>
     </div>   
     <!-- Datos Personales -->
     <div id="divDatosPersonales" style="display:none">
        <table class="tb1" style="width:100%"><tr class="tbLabel"><td style="text-align:left !important">Datos Personales</td></tr></table>
        <div id="divDatosPersonalesLeft">
            <table class="tb1" style="width:100%;border-collapse:collapse; border:none">
            <tr>                
                <td class='Tit1' style="width:60%">CUIT</td>
                <td class="Tit1" style="width:40%">F.Nac.</td>
            </tr>
            <tr>
                <td><span id="strCUIT"></span></td>
                <td><span id="strFNac"></span></td>
            </tr>
            </table>
        </div>   
        <div id="divDatosPersonalesRight">            
            <table class="tb1" style="width:100%;border-collapse:collapse; border:none">
            <tr>
                <td class='Tit1' style="width:100%">Apellido y Nombres</td>
            </tr>
            <tr>
                <td><span id="strApeyNomb"></span></td>
            </tr>
            </table>
        </div>
         <div id="divInformeComercial">
            <table class="tb1" style="width:100%;border-collapse:collapse; border:none">
            <tr>                
                <td class='Tit1'>Informe Comercial</td>
                <td style="width:60px" title="Ver informe comercial"><div id="divNosis"/></td>
            </tr>
            </table>
            <table class="tb1" style="width:100%">
            <tr>
                <td style="width:50%">Situación: &nbsp;&nbsp;<b><span style="display:inline-block;width:50px !important" class="sit1" id="strSitBCRA"></span></b></td>
                <td style="width:50%">                    
                    CDA:&nbsp;&nbsp;<a href="#" style='cursor:pointer' onclick="VerCDA()"><span style="display:inline-block;width:100px !important" class="cdaAC" id="strDictamen"></span></a>
                </td>
                <!--<td title="Ver informe Nosis" style="width:15%;text-align:center">
                    <img style="cursor:pointer" src="../../FW/image/icons/ver.png" onclick="VerInformeNosis()"/>
                </td>--> 
            </tr>
            </table>
         </div>
     </div>
     <!--Datos del Trabajo -->
     <div id="divTrabajo" style="display:none">
         <div id="divTrabajoLeft">
         <table class='tb1' style='width:100%;border-collapse:collapse; border:none'>
            <tr>
                <td class='Tit1' style="width:100%">Trabajo</td>
            </tr>
            <tr>
                <td><span id="strTrabajo"></span></td>
            </tr>
         </table>
         </div>
         <div id="divTrabajoRight">
         <table class='tb1' style='width:100%;border-collapse:collapse; border:none'>
            <tr>
                <td class='Tit1' style="width:60%">Clave Sueldo</td>
                <!-- style="font-size:10px !important"-->
                <td class='Tit1' style="width:40%;text-align:right">Cupo <span id="fecha_actualizacion"></span></td>
            </tr>
            <tr>                
                <td><span id="strClave"></span></td>
                <td style="text-align:right"><b><span id="cupo_disponible"></span></b></td>
            </tr>
         </table>
         </div>
     </div>   
     <!-- Datos del Socio -->        
    <div id="divSocio" style="display:none">
        <div id="divSocioLeft">
            <table class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:left !important" >Socio</td>
                </tr>
            </table>
            <table class='tb1' style='width:100%'>
                <tr>
                    <!--<td class='Tit1' style="width:30%">CUIT</td>-->
                    <td class='Tit1'>Apellido y Nombres</td>
                </tr>
                <tr>
                    <!--<td><span id="strSCUIT"></span></td>-->
                    <td><span id="strSApeyNomb"></span></td>                        
                </tr>
                <tr>
                    <td style="width:100%; vertical-align:top" colspan="2">
                        <div id="tbCuotaSocial" style="vertical-align:top; width:100%"></div>
                    </td>   
                </tr>
            </table>
        </div>     
        <div id="divSocioRight">
            <table class="tb1" id="tbCreditos" style="width:100%">
                <tr class="tbLabel">
                    <td style="text-align:left !important">Cancelaciones</td>
                </tr>
            </table>
            <div id="tbCredVigente" style="vertical-align:top; width:100%"></div>
        </div>
    </div>        
    <!-- Seleccionar Producto -->        
    <div id="divProducto" style="display:none">  
        <table class="tb1" style='width:100%'>
            <tr class="tbLabel">
                <td style="text-align:left !important">Producto</td>
            </tr>
        </table> 
        <div id="divProductoLeft">
        <table class='tb1' style='width:100%'>
            <tr>
                <td class='Tit1' style="width:10%">Banco:</td>
                <td style="width:36%"><select id="banco" name="banco" style="width:100%" onchange="return banco_onchange()"></select></td>
            </tr>
            <tr>
                <td class='Tit1' style="width:10%">Mutual:</td>
                <td style="width:36%"><select id="mutual" name="mutual" style="width:100%" onchange="return mutual_onchange()"></select></td>
            </tr>
        </table>
        </div> 
        <div id="divProductoRight">
        <table class='tb1' style='width:100%'>
            <tr>
                <td class='Tit1' style="width:15%">Cancelaciones:</td>
                <td style="width:12%;text-align:right" nowrap="true"><span id="strCancelaciones"></span></td>
                <td class='Tit1' style="width:15%">Libera:</td>
                <td style="width:12%;text-align:right" nowrap="true"><span id="strCuotaLiberada"></span></td>
            </tr>
            <tr>
                <td class='Tit1' style="width:15%">Cta. Social:</td>
                <td style="width:12%;text-align:right" nowrap="true"><span id="strCuotaSocial"></span></td>
                <td class='Tit1' style="width:15%">Cta. Máxima:</td>
                <td style="width:12%;text-align:right" nowrap="true"><span id="strCuotaMaxima"></span></td>
            </tr>
        </table>
        </div>
    </div>
    <div id="divFiltros" style="display:none">
        <table class="tb1" style='width:100%'>
            <tr class="tbLabel">
                <td style="text-align:left !important">Filtros</td>
            </tr>
        </table>         
        <table class='tb1' style="width:100%;border-collapse:collapse; border:none;">
            <tr>
                <td>
                <div id="divFiltrosLeft" style="display:none">
                    <table class='tb1' style='width:100%'>
                        <tr>
                            <td class='Tit1' style="width:40%"></td>
                            <td class='Tit1' style="width:30%">Desde</td>
                            <td class='Tit1' style="width:30%">Hasta</td>
                        </tr>
                        <tr>
                            <td>Importe Retirado</td>
                            <td><script type="text/javascript">campos_defs.add('retirado_desde', { enDB: false, nro_campo_tipo: 102 })</script></td>
                            <td><script type="text/javascript">campos_defs.add('retirado_hasta', { enDB: false, nro_campo_tipo: 102 })</script></td>
                        </tr>
                    </table>
                </div>
                <div id="divFiltrosRight" style="display:none">
                    <table class='tb1' style='width:100%'>
                        <tr>
                            <td class='Tit1' style="width:40%"></td>
                            <td class='Tit1' style="width:30%">Desde</td>
                            <td class='Tit1' style="width:30%">Hasta</td>
                        </tr>
                        <tr>
                            <td>Importe Cuota</td>
                            <td><script type="text/javascript">campos_defs.add('importe_cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script></td>
                            <td><script type="text/javascript">campos_defs.add('importe_cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script></td>
                        </tr>
                    </table>
                </div>
                <div id="divFiltros2Left" style="display:none">
                    <table class='tb1' style='width:100%'>
                            <tr>
                                <td class='Tit1' style="width:40%"></td>
                                <td class='Tit1' style="width:30%">Desde</td>
                                <td class='Tit1' style="width:30%">Hasta</td>
                            </tr>
                            <tr>
                                <td>Cuotas</td>
                                <td><script type="text/javascript">campos_defs.add('cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script></td>
                                <td><script type="text/javascript">campos_defs.add('cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script></td>
                            </tr>
                    </table>
                </div>  
                <div id="divFiltros2Right">
                    <table class='tb1' style='width:100%;vertical-align:middle'>
                        <tr>
                            <td style="width:50%" >Importe máximo disponible</td>
                            <td style="text-align:center;width:20%"><input type="checkbox" style="border:none" id="chkmax_disp" checked onclick="chkmax_disp_on_click()" /></td>
                            <td style="width:30%"><div id="divPlanBuscar"></div></td>
                        </tr>
                    </table>
                </div>                              
                </td>
            </tr>
        </table>
        <iframe  style="width: 100%;height:200px; border:none" name="ifrplanes" id="ifrplanes" src="enBlanco.htm"></iframe>
    </div>
     <table style="width:100%;display:none" id="tbButtons">
        <tr>
            <td style="width:33%">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('M')" id="btn1">
                            <img src="/precarga/image/Save_icon.png" class="img_button" border="0" align="absmiddle" hspace="1" id="img1">&nbsp;Presupuesto
                        </td>
                       <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
            <td style="width:33%">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('H')" id="btn2">
                            <img src="/precarga/image/Save_icon.png" class="img_button" border="0" align="absmiddle" hspace="1" id="img2">&nbsp;Precarga
                        </td>
                       <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
            <td style="text-align:center">
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="this.disabled=true; Precarga_Limpiar()" id="btn3">
                            <img src="/precarga/image/limpiar.png" class="img_button" border="0" align="absmiddle" hspace="1" id="img3">&nbsp;Limpiar
                        </td>
                       <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
        </tr>
     </table>  
    </div>
</body>
</html>
