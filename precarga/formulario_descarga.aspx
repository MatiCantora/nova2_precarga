<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%   

    Me.contents.Add("descargar", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verrpt_solicitudes_descarga'><campos>descripcion,nombre_archivo,path</campos><orden></orden><filtro></filtro></select></criterio>"))

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>
    <script type="text/javascript" language='javascript' src="script/precarga.js" ></script>

    <% = Me.getHeadInit()%>  

    <script type="text/javascript" language="javascript" class="table_window">

    var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }      

    var win = nvFW.getMyWindow()

    function window_onload() 
    {
        cargar_descargas()
        window_onresize()       
    }

    function window_onresize() {
        try {


            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            $('divDescargas').setStyle({ height: body_height - dif - 2 + 'px' })

        }
        catch (e) { }
    }

    function cargar_descargas()
    {
        $('divDescargas').innerHTML = ''
        var strHTML = ''
        strHTML = '<table width="100%" class="tb1 highlightEven highlightTROver"><tr class="tbLabel"><td>Archivos</td><td></td></tr>'
        var rs = new tRS();
        rs.open({ filtroXML: nvFW.pageContents["descargar"] })
        while (!rs.eof()) 
            {
            strHTML += "<tr style='cursor:hand' onclick=window.open('" + rs.getdata('path') + "')>"
            strHTML += "<td style = 'color:blue;width: 90%'> " + rs.getdata('descripcion') + "</td> "
            strHTML += "<td style='text-align:center'><img name="+rs.getdata('descripcion')+" src='/fw/image/icons/download.png' style='vertical-align:initial;'></img></td></tr> "
            rs.movenext() 
            }
        strHTML += "</table>"
        $('divDescargas').insert({ bottom: strHTML })
    }


</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; overflow: auto;background-color:white">
<div style="overflow:auto;-webkit-overflow-scrolling:touch;" id="divDescargas"></div>
</body>
</html>