<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim vista = nvFW.nvUtiles.obtenerValor("vista", "lineal")

    Dim perfil = nvFW.nvUtiles.obtenerValor("perfil", 1)

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>ABM Permisos</title>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
        <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
        <script type="text/javascript" src="/fw/script/tCampo_head.js"></script>
        <script type="text/javascript" src="/fw/script/tTable.js"></script>
        <% = Me.getHeadInit()%>

        <script type="text/javascript">
            var vista_actual= '<% =vista %>'
            var ventana
            var perfil_selec = ''
            var perfil_comparar = ''
            var comparar = false
            
            function window_onload(){
               ventana = ObtenerVentana("frame_permisos") 
               
            }

            function cambiarPerfil(nuevo_perfil, perfil_comp){
                perfil_selec = nuevo_perfil
                cargar_vista("", perfil_comp)
            }

            function cambiarPerfilComparar(nuevo_perfil){
                if(vista_actual == 'arbol'){
                    ventana.comparar(nuevo_perfil)       
                }
                else{
                    ventana.location.href='permiso_abm_view_standard.aspx?tipo_operador_get=' + perfil_selec + '&tipo_operador_comp_get='+nuevo_perfil+'&comparar=true'
                }
            }
            
            function cargar_vista(vistaNueva, perfil_comp){
                if(vistaNueva){
                    vista_actual = vistaNueva
                }
                if (!perfil_comp)
                    perfil_comp = ''
                switch (vista_actual) {
                    case 'lineal':
                        ObtenerVentana("frame_permisos").location.href='permiso_abm_view_standard.aspx?tipo_operador_get=' + perfil_selec + '&tipo_operador_comp_get=' + perfil_comp
                        break;
                    case 'arbol':
                        ObtenerVentana("frame_permisos").location.href='permiso_abm_view_tree.aspx?tipo_operador_get=' + perfil_selec + '&tipo_operador_comp_get=' + perfil_comp
                        break;
                }
            }
        </script>

    </head>
    <body style="width:100%;height:100%;overflow:hidden" onload="window_onload()">
       <iframe id="frame_usuarios" name="frame_usuarios" src="permiso_perfiles.aspx?tipo_operador_get=<%= perfil  %>" style="width:24%;height:100%;overflow:hidden" align="left" frameborder="0"></iframe>
       <iframe id="frame_permisos" name="frame_permisos" src="../enBlanco.htm" style="width:75%;height:100%;overflow:hidden" align="right" frameborder="0"></iframe>
    </body>
</html>