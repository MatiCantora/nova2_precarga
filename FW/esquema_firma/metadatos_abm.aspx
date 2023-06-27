<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    
    If modo = "" Then
        Dim id_circuito_firma As String = nvUtiles.obtenerValor("id_circuito_firma", "")
        Me.contents("filtroMetadatos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='circuito_firma_metadatos'><campos>*</campos><filtro><id_circuito_firma type='igual'>" &
                                                               id_circuito_firma & "</id_circuito_firma></filtro></select></criterio>")
        Me.contents("filtroParams") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='circuito_firma_parametros'><campos>*</campos><filtro><id_circuito_firma type='igual'>" &
                                                               id_circuito_firma & "</id_circuito_firma></filtro></select></criterio>")
        Me.contents("id_circuito_firma") = id_circuito_firma
        
    ElseIf modo = "GUARDAR" Then
        
        Dim err As New tError
        Dim xml As String = nvUtiles.obtenerValor("xml", "")
        Dim oXML As New System.Xml.XmlDocument
        oXML.LoadXml(xml)
        
        Dim id_circuito_firma As String = oXML.SelectSingleNode("circuito_firma_data").Attributes("id_circuito_firma").Value
        Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("/circuito_firma_data/metadatos/metadato")

        Dim strSQL As String = "SET XACT_ABORT ON " & vbLf & " BEGIN TRAN " & vbLf
        
        For i As Integer = 0 To nodes.Count - 1
            Dim node As System.Xml.XmlNode = nodes(i)
            Dim accion As String = node.Attributes("accion").Value
            Dim key As String = node.Attributes("key").Value
            Dim label As String = node.Attributes("label").Value
            Dim value As String = node.Attributes("value").Value

            If accion.ToLower = "eliminar" Then
                strSQL += "DELETE FROM circuito_firma_metadatos WHERE [key]='" & key & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            ElseIf accion.ToLower = "agregar" Then
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_metadatos  WHERE [key]='" & key & "' AND id_circuito_firma=" & id_circuito_firma & "")
                Dim NoExisteReg As Boolean = rs.EOF
                nvDBUtiles.DBCloseRecordset(rs)
                If NoExisteReg Then
                    strSQL += "INSERT INTO circuito_firma_metadatos(id_circuito_firma, [key], label, value) VALUES (" & id_circuito_firma & ", '" & key & "', '" & label & "', '" & value & "') " & vbLf
                Else
                    err.numError = -1
                    err.mensaje = "El metadato con key=" & key & " ya existe"
                    err.response()
                End If
            ElseIf accion.ToLower = "modificar" Then
                strSQL += "UPDATE circuito_firma_metadatos SET label='" & label & "', value='" & value & "' WHERE [key]='" & key & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            End If
        Next
        
        
        nodes = oXML.SelectNodes("/circuito_firma_data/params/param")
        For i As Integer = 0 To nodes.Count - 1
            Dim node As System.Xml.XmlNode = nodes(i)
            Dim accion As String = node.Attributes("accion").Value
            Dim param_id As String = node.Attributes("param_id").Value
            Dim value As String = node.Attributes("value").Value
        
            If accion.ToLower = "eliminar" Then
                strSQL += "DELETE FROM circuito_firma_parametros WHERE [param_id]='" & param_id & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            ElseIf accion.ToLower = "agregar" Then
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_parametros  WHERE [param_id]='" & param_id & "' AND id_circuito_firma=" & id_circuito_firma & "")
                Dim NoExisteReg As Boolean = rs.EOF
                nvDBUtiles.DBCloseRecordset(rs)
                If NoExisteReg Then
                    strSQL += "INSERT INTO circuito_firma_parametros(id_circuito_firma, param_id, value) VALUES (" & id_circuito_firma & ", '" & param_id & "', '" & value & "') " & vbLf
                Else
                    err.numError = -1
                    err.mensaje = "El param con param_id=" & param_id & " ya existe"
                    err.response()
                End If
            ElseIf accion.ToLower = "modificar" Then
                strSQL += "UPDATE circuito_firma_parametros SET value='" & value & "' WHERE param_id='" & param_id & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            End If
        Next
        strSQL += " COMMIT TRAN"
        
        Try
            nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If
    

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Metadatos abm</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var tabla_metadatos

        function window_onload() {
            tabla_metadatos = new tTable()
            tabla_metadatos.nombreTabla = "tabla_metadatos";

            //Agregamos consulta XML
            tabla_metadatos.filtroXML = nvFW.pageContents.filtroMetadatos;
            tabla_metadatos.cabeceras = ["Key", "Label", "Value"];

            tabla_metadatos.height = "250px";
            tabla_metadatos.async = true;
            tabla_metadatos.campos = [

                { nombreCampo: "key", nro_campo_tipo: 104, enDB: false, width: "25%", unico: true
                    //Permite establecer campos que permitan el valor null o vacio
                    //, nulleable: true
                },
                { nombreCampo: "label", nro_campo_tipo: 104, enDB: false, width: "25%", nulleable: true
                },
                { nombreCampo: "value", nro_campo_tipo: 104, enDB: false, width: "25%", nulleable: true
                }
            ]

            //Metodo que se ejecuta cuando se elimina una fila
            tabla_metadatos.eliminar = function (fila) {
            }

            tabla_metadatos.modificar = function (fila) {
            }




            tabla_params = new tTable()
            tabla_params.nombreTabla = "tabla_params";

            //Agregamos consulta XML
            tabla_params.filtroXML = nvFW.pageContents.filtroParams;
            tabla_params.cabeceras = ["Param Id", "Value"];

            tabla_params.height = "250px";
            tabla_params.async = true;
            tabla_params.campos = [

                { nombreCampo: "param_id", nro_campo_tipo: 104, enDB: false, width: "25%", unico: true
                },
                { nombreCampo: "value", nro_campo_tipo: 104, enDB: false, width: "25%", nulleable: true
                }
            ]
            tabla_params.eliminar = function (fila) {
            }

            tabla_params.modificar = function (fila) {
            }

            tabla_params.addOnComplete(window_onresize)
            var f = function () {
                tabla_params.table_load_html()
            }
            tabla_metadatos.addOnComplete(f)
            tabla_metadatos.table_load_html()
        }

        function guardar() {


            if (!tabla_metadatos.validar()) {
                alert("Verifique que las claves de los metadatos no sean cadena vacía y no se dupliquen .");
                return;
            }

            if (!tabla_params.validar()) {
                alert("Verifique que las claves de los parámetros no sean cadena vacía no se dupliquen.");
                return;
            }


            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"

            xml += "<circuito_firma_data id_circuito_firma='" + nvFW.pageContents.id_circuito_firma + "'>"
            xml += "<metadatos>"
            xml += tabla_metadatos.generarXML("metadato");
            xml += "</metadatos> "

            xml += "<params>"
            xml += tabla_params.generarXML("param");
            xml += "</params> "
            xml += "</circuito_firma_data>"


            nvFW.error_ajax_request('metadatos_abm.aspx', {
                parameters: {
                    modo: "GUARDAR",
                    xml: xml
                },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        tabla_metadatos.refresh()
                        tabla_params.refresh()
                    }
                }

            });
        }



        function window_onresize() {
            var body_h = $$('body')[0].getHeight()
            var divHead_h = $('divHead').getHeight()
            var h = body_h - divHead_h - 10
            if (h > 5) {
                $('divData').setStyle({ height: h + 'px', overflow: "hidden" });
                tabla_metadatos.resize()
                tabla_params.resize()
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; vertical-align: top; overflow: hidden;">
    <div id='divHead'>
        <div id='divMenu'>
        </div>
        <script type="text/javascript">

            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Metadatos/Parámetros</Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"].loadImage("abm", "/FW/image/icons/agregar.png")
            vMenu.MostrarMenu()

        </script>
    </div>
    <div id='divData'>
        <div id='divMetadatos' style="width: 100%; height: 50%; margin-left: auto; margin-right: auto;
            overflow: hidden; text-align: center;">
            <div id="tabla_metadatos" style="width: 100%; height: 100%; overflow: hidden; background-color: white">
            </div>
        </div>
        <div id='divParams' style="width: 100%; height: 50%; margin-left: auto; margin-right: auto;
            overflow: hidden; text-align: center;">
            <div id="tabla_params" style="width: 100%; height: 100%; overflow: hidden; background-color: white">
            </div>
        </div>
    </div>
</body>
</html>
