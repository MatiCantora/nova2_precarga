<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>NOSIS - Seleccionar CUIT</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>
    
    <% = Me.getHeadInit()%>
    
    <script type="text/javascript" language="javascript">


        function window_onload() {

            var e

            var win = nvFW.getMyWindow()
            //$(document.body).insert({top: win.options.userData.NODs})
            var NODs = win.options.userData.NODs

            $('divAceptar').innerHTML = ""

            var strHTML = '<table class="tb1 highlightEven highlightTROver" id="tbCUIT"><tr class="tbLabel"><td colspan="3" class="Tit4">Seleccionar CUIT/CUIL</td></tr>'
            strHTML += '<tr><td class="Tit1"></td><td class="Tit1">CUIT/CUIL</td><td class="Tit1">Razon social</td></tr>'

            //var Per = new tXML();
            var Per = NODs.selectNodes('Resultado/Personas/Persona')
            for (var i = 0; i < Per.length; i++) {
                Doc = XMLText(selectSingleNode('Doc', Per[i]))
                RazonSoc = XMLText(selectSingleNode('RazonSoc', Per[i]))
                existe = selectSingleNode('@existe', Per[i]).nodeValue
                strHTML += "<tr onclick='cuit_seleccionar(" + Doc + "," + existe + ")'><td style='cursor:pointer;text-align:center' onclick='cuit_seleccionar(" + Doc + "," + existe + ")' title='Seleccionar persona'><img class='img_button_sel' src='/precarga/image/seleccionar_32.png'/></td><td>" + Doc + "</td><td>" + RazonSoc + "</td></tr>\n"
            }

            strHTML += '</table>'

            $('divAceptar').insert({ top: strHTML })

        }


function cuit_seleccionar(cuit,existe)
{
    var cuit_orig = ''
    var apellido_orig = ''
    var nombres_orig = ''
    
    var res = new Array()
    res['cuit'] = cuit
    res['existe'] = existe

    var win = nvFW.getMyWindow()
    win.options.userData = { res: res }
    win.close()
  }

</script>
</head>
<body onload="window_onload()"  style="width:100%;height:100%; overflow:auto">
  <div id="divAceptar"></div>
</body>
</html>
