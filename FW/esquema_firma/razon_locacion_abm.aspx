<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    
    If modo = "" Then
        Dim id_circuito_firma As String = nvUtiles.obtenerValor("id_circuito_firma", "")
        Me.contents("filtroRazones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='circuito_firma_razones'><campos>*</campos><filtro><id_circuito_firma type='igual'>" &
                                                               id_circuito_firma & "</id_circuito_firma></filtro></select></criterio>")
        
        Me.contents("filtroLocaciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='circuito_firma_locaciones'><campos>*</campos><filtro><id_circuito_firma type='igual'>" &
                                                               id_circuito_firma & "</id_circuito_firma></filtro></select></criterio>")
        
        Me.contents("id_circuito_firma") = id_circuito_firma
        
    ElseIf modo = "GUARDAR" Then
        
        Dim err As New tError
        Dim xml As String = nvUtiles.obtenerValor("xml", "")
        Dim oXML As New System.Xml.XmlDocument
        oXML.LoadXml(xml)
        
        Dim id_circuito_firma As String = oXML.SelectSingleNode("circuito_firma_data").Attributes("id_circuito_firma").Value
        Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("/circuito_firma_data/razones/razon")

        Dim strSQL As String = "SET XACT_ABORT ON " & vbLf & " BEGIN TRAN " & vbLf
        
        For i As Integer = 0 To nodes.Count - 1
            Dim node As System.Xml.XmlNode = nodes(i)
            Dim accion As String = node.Attributes("accion").Value
            Dim razon_id As String = node.Attributes("razon_id").Value
            Dim label As String = node.Attributes("label").Value
            Dim selected As String = node.Attributes("selected").Value
            
            If accion.ToLower = "eliminar" Then
                strSQL += "DELETE FROM circuito_firma_razones WHERE [razon_id]='" & razon_id & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            ElseIf accion.ToLower = "agregar" Then
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_razones  WHERE [label]='" & label & "' AND id_circuito_firma=" & id_circuito_firma & "")
                Dim NoExisteReg As Boolean = rs.EOF
                nvDBUtiles.DBCloseRecordset(rs)
                If NoExisteReg Then
                    strSQL += "INSERT INTO circuito_firma_razones(id_circuito_firma, label, selected) VALUES (" & id_circuito_firma & ", '" & label & "', " & selected & ") " & vbLf
                Else
                    err.numError = -1
                    err.mensaje = "La razón ya existe"
                    err.response()
                End If
            ElseIf accion.ToLower = "modificar" Then
                strSQL += "UPDATE circuito_firma_razones SET label='" & label & "', selected=" & selected & " WHERE [razon_id]='" & razon_id & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            End If
        Next
        
        
        nodes = oXML.SelectNodes("/circuito_firma_data/locaciones/locacion")
        For i As Integer = 0 To nodes.Count - 1
            Dim node As System.Xml.XmlNode = nodes(i)
            Dim accion As String = node.Attributes("accion").Value
            Dim locacion_id As String = node.Attributes("locacion_id").Value
            Dim label As String = node.Attributes("label").Value
            Dim selected As String = node.Attributes("selected").Value
            
            If accion.ToLower = "eliminar" Then
                strSQL += "DELETE FROM circuito_firma_locaciones WHERE [locacion_id]='" & locacion_id & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
            ElseIf accion.ToLower = "agregar" Then
                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM circuito_firma_locaciones  WHERE [label]='" & label & "' AND id_circuito_firma=" & id_circuito_firma & "")
                Dim NoExisteReg As Boolean = rs.EOF
                nvDBUtiles.DBCloseRecordset(rs)
                If NoExisteReg Then
                    strSQL += "INSERT INTO circuito_firma_locaciones(id_circuito_firma, label, selected) VALUES (" & id_circuito_firma & ", '" & label & "', " & selected & ") " & vbLf
                Else
                    err.numError = -1
                    err.mensaje = "La locación ya existe"
                    err.response()
                End If
            ElseIf accion.ToLower = "modificar" Then
                strSQL += "UPDATE circuito_firma_locaciones SET label='" & label & "', selected=" & selected & " WHERE locacion_id='" & locacion_id & "' AND id_circuito_firma=" & id_circuito_firma & " " & vbLf
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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Razon/Locacion ABM</title>
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

        function window_onload() {

            tabla_razones = new tTable();
            tabla_razones.async = true;
            tabla_razones.height = 250;

            //Nombre de la tabla y id de la variable
            tabla_razones.nombreTabla = "tabla_razones";

            //Agregamos consulta XML
            tabla_razones.filtroXML = nvFW.pageContents.filtroRazones;
            tabla_razones.cabeceras = ["Default", "Razón"];

            //No se puede eliminar un radio seleccionado
            tabla_razones.verificarRadioButton = true;

            //Funcion auxiliar para agregar un combobox
            //tabla_razones.editable = false;
            //tabla_razones.eliminable = false;
            tabla_razones.camposHide = [{ nombreCampo: "razon_id"}]
            tabla_razones.campos = [
                {
                    nombreCampo: "selected",
                    width: "10%",
                    align: "center",
                    radioButton: true,
                    checkOnDelete: true,
                    convertirValorBD: function (valor) { return (valor == "True") ? 1 : 0 }
                },
                { nombreCampo: "label", nro_campo_tipo: 104, enDB: false, width: "25%"
                    //Permite establecer campos que permitan el valor null o vacio
                    //, nulleable: true
                }
            ]


            tabla_locaciones = new tTable();
            tabla_locaciones.async = true;
            tabla_locaciones.height = 250;

            //Nombre de la tabla y id de la variable
            tabla_locaciones.nombreTabla = "tabla_locaciones";

            //Agregamos consulta XML
            tabla_locaciones.filtroXML = nvFW.pageContents.filtroLocaciones;
            tabla_locaciones.cabeceras = ["Default", "Locación"];

            //No se puede eliminar un radio seleccionado
            tabla_locaciones.verificarRadioButton = true;

            //Funcion auxiliar para agregar un combobox
            //tabla_razones.editable = false;
            //tabla_razones.eliminable = false;

            tabla_locaciones.camposHide = [{ nombreCampo: "locacion_id"}]
            tabla_locaciones.campos = [
                {
                    nombreCampo: "selected",
                    width: "10%",
                    align: "center",
                    radioButton: true,
                    checkOnDelete: true,
                    convertirValorBD: function (valor) { return (valor == "True") ? 1 : 0 }
                },
                { nombreCampo: "label", nro_campo_tipo: 104, enDB: false, width: "25%"
                    //Permite establecer campos que permitan el valor null o vacio
                    //, nulleable: true
                }
            ]


            tabla_locaciones.addOnComplete(window_onresize)
            var f = function () {
                tabla_locaciones.table_load_html()
            }
            tabla_razones.addOnComplete(f)
            tabla_razones.table_load_html()
        }


        function window_onresize() {
            var body_h = $$('body')[0].getHeight()
            var divHead_h = $('divHead').getHeight()
            var h = body_h - divHead_h - 10
            if (h > 5) {
                $('divData').setStyle({ height: h + 'px', overflow: "hidden" });
                tabla_razones.resize()
                tabla_locaciones.resize()
            }
        }

        function guardar() {


            if (!tabla_razones.validar()) {
                alert("Verifique que las descripciones de las razones no esten vacías");
                return;
            }

            if (!tabla_locaciones.validar()) {
                alert("Verifique que la descripciones de las loaciones no esten vacías");
                return;
            }


            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"

            xml += "<circuito_firma_data id_circuito_firma='" + nvFW.pageContents.id_circuito_firma + "'>"
            xml += "<razones>"
            xml += tabla_razones.generarXML("razon");
            xml += "</razones> "

            xml += "<locaciones>"
            xml += tabla_locaciones.generarXML("locacion");
            xml += "</locaciones> "
            xml += "</circuito_firma_data>"


            nvFW.error_ajax_request('razon_locacion_abm.aspx', {
                parameters: {
                    modo: "GUARDAR",
                    xml: xml
                },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        tabla_razones.refresh()
                        tabla_locaciones.refresh()
                    }
                }

            });
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id='divHead'>
        <div id='divMenu'>
        </div>
        <script type="text/javascript">

            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Razones/Locaciones</Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"].loadImage("abm", "/FW/image/icons/agregar.png")
            vMenu.MostrarMenu()

        </script>
    </div>
    <div id='divData'>
        <div id='divRazones' style="width: 100%; height: 50%; margin-left: auto; margin-right: auto;
            overflow: hidden; text-align: center;">
            <div id="tabla_razones" style="width: 100%; height: 100%; overflow: hidden; background-color: white">
            </div>
        </div>
        <div id='divLocaciones' style="width: 100%; height: 50%; margin-left: auto; margin-right: auto;
            overflow: hidden; text-align: center;">
            <div id="tabla_locaciones" style="width: 100%; height: 100%; overflow: hidden; background-color: white">
            </div>
        </div>
    </div>
</body>
</html>
