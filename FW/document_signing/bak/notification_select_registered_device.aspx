<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>


<%
    
    
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    Dim operador As String = nvApp.operador.operador
    
    If accion = "" Then

        Dim f_id As String = nvUtiles.obtenerValor("f_id", "")
        Me.contents("f_id") = f_id
        
        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT * FROM verOperadores_mobile_devices WHERE operador=" & nvApp.operador.operador)
        Dim hasDevices As Boolean = False
        If Not rs.EOF Then
            hasDevices = True
        End If
        nvDBUtiles.DBCloseRecordset(rs)
    
        If Not hasDevices Then
            Response.Redirect("qr_vinculo_scan.aspx?f_id=" + f_id)
        End If
       
    End If
    

    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Elegir dipositivo</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="initial-scale=1"/>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/clipboard/clipboard.js"></script>
    <% = Me.getHeadInit()%>
    <script type='text/javascript'>

        var vButtonItems = {};
        var vMenu;

        function window_onload() {
            loadMenuAndButton()
        }

        function loadMenuAndButton() {

            vMenu = new tMenu('divMenu', 'vMenu');
            vMenu.loadImage("guardar", "/FW/image/icons/guardar.png");
            vMenu.loadImage("subir", "/FW/image/icons/subir.png");
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardarArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Seleccione dispositivo</Desc></MenuItem>")
            vMenu.MostrarMenu()

            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Aceptar";
            vButtonItems[0]["etiqueta"] = "Aceptar";
            vButtonItems[0]["imagen"] = "aceptar";
            vButtonItems[0]["onclick"] = "aceptar()";

            var vListButtons = new tListButton(vButtonItems, 'vListButtons');
            vListButtons.loadImage('aceptar', '/FW/image/icons/buscar.png');
            vListButtons.MostrarListButton();
        }

        function destroyWindow() {
            nvFW.getMyWindow().setDestroyOnClose() //si no se destruye, los intervals corriendo seguiran ejecutandose
            nvFW.getMyWindow().close()
        }

        function window_onresize() {

        }

        function aceptar() {


            // enviar notificacion de firma
            var cod_binding = campos_defs.get_value("cod_binding")
            var f_id = nvFW.pageContents.f_id

            var win = window.top.nvFW.createWindow({
                title: 'Firmar archivo',
                url: '/fw/document_signing/pdf_signature_editor.aspx?modo=sign_file&f_id=' + f_id + "&cod_binding=" + cod_binding,
                width: 600,
                height: 400
            })
            win.showCenter(true)



        }



        


    </script>
</head>
<body style="width: 100%; height: 100%;" onload="window_onload()" onresize="window_onresize()">

    
    <div id='divMenu'></div>
    <div>
    
    <%=nvFW.nvCampo_def.get_html_input(campo_def:="cod_binding", enDB:=False, filtroXML:="<criterio><select vista='verOperadores_mobile_devices'><campos>cod_binding  as id, device_manufacturer + ' ' + device_model + ' - ' + cod_mobile_app as [campo]</campos><filtro><operador type='igual'>" & operador & "</operador></filtro><orden>[cod_binding]</orden></select></criterio>")%>
    </div>

    <div id='divAceptar'></div>

</body>
</html>
