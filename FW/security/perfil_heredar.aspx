<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
   
    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Perfil ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript"  src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript"  src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript"  src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript"  src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript"  src="/fw/script/tcampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var vButtonItems=new Array();
        vButtonItems[0]=new Array();
        vButtonItems[0]["nombre"]="Aceptar";
        vButtonItems[0]["etiqueta"]="Aceptar";
        vButtonItems[0]["imagen"]="aceptar";
        vButtonItems[0]["onclick"]="return aceptar()";

        var vListButtons=new tListButton(vButtonItems,'vListButtons')
        vListButtons.loadImage("aceptar","/fw/image/icons/seleccionar.png")
        var win=nvFW.getMyWindow()

        function window_onload(){
            vListButtons.MostrarListButton()
        }

       function aceptar(){
            win.returnValue = campos_defs.get_value('perfilHeredar')
            win.close()
       }





    </script>
</head>
<body onload="return window_onload()" style='width:100%;height:100%;overflow:hidden'>
<form name="frmPerfil" action='' style='width:100%;height:100%;overflow:hidden'>

    <table id="tbFiltro" class='tb1'>
        <tr class='tbLabel'>
           <td style='width:10%'>Seleccione el perfil del cual desea heredar los permisos</td>
        </tr>
        <tr>
        <td><%= nvFW.nvCampo_def.get_html_input("perfilHeredar", nro_campo_tipo:=1, enDB:=False, filtroXML:="<criterio><select vista='operador_tipo'><campos>distinct tipo_operador as id,rtrim(tipo_operador_desc) as [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")%></td>
        </tr>
        <tr>
        <td><div id="divAceptar"></div></td>
        </tr>
    </table>
</form>
</body>
</html>