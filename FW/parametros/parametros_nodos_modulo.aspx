<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%
      
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim menu_left As String
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    
    If (accion.ToUpper() = "ASIGNAR") Then
        menu_left = "parametros_nodos_tree_editar_valor.aspx"
    Else
        menu_left = "parametros_nodos_tree.aspx"
    End If
    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Modulo Permiso</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% =Me.getHeadInit()%>
    
    <script type="text/javascript" language="javascript" >
    
    window.alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); }
   
 function window_onresize()
    {
    try {
        var dif = Prototype.Browser.IE ? 5 : 2
        body_height = $$('body')[0].getHeight()
        $('tb_body').setStyle({'height': body_height - dif + 'px'})
     }
    catch(e){}
    } 
    
 function window_onload()
    {
     window_onresize()
    }
  
  function tb_body_resize_inicio() {
        var body = $$('BODY')[0]
        if ($('tb_body_div_hide') == null) {
            var strHTML = '<div id="tb_body_div_hide" style="width: 100%; height: 100%; position: absolute; z-index: 1000; float: left; background-color: gray"></div>'
            body.insert({ top: strHTML })
            var oDIV = $("tb_body_div_hide")
            Element.setOpacity(oDIV, 0.0)
            strHTML = '<div id="tb_body_div_rec" style="position: absolute;z-index: 1000; float: left; background-color: gray"></div>'
            body.insert({ top: strHTML })
            var oDIV_rec = $("tb_body_div_rec")
            Element.setOpacity(oDIV_rec, 0.5)
            td_move = $('tb_body_td_move')
            oDIV_rec.setStyle({ width: td_move.getWidth(), height: td_move.getHeight() })

        }
        else {
            $('tb_body_div_hide').show()
            var oDIV_rec = $('tb_body_div_rec')
            oDIV_rec.show()
        }

        Element.clonePosition(oDIV_rec, td_move)
        body.setStyle({ cursor: 'w-resize' })

        Event.observe(body, 'mousemove', tb_body_resize_mousemove);
        Event.observe(body, 'mouseup', tb_body_resize_fin);
    }

    function tb_body_resize_fin() {
        var body = $$('BODY')[0]
        var oDIV_rec = $('tb_body_div_rec')
        $('tb_body_td').setStyle({ width: oDIV_rec.getStyle('left') })
        Event.stopObserving(body, 'mousemove', tb_body_resize_mousemove);
        var oDIV = $("tb_body_div_hide")
        body.setStyle({ cursor: '' })
        oDIV.hide()
        oDIV_rec.hide()
    }

    function tb_body_resize_mousemove(e) {
        try {
            nuevoX = Event.pointerX(e) - 4
            $('tb_body_div_rec').setStyle({ left: nuevoX })
            document.selection.clear()
        }
        catch (e) { }

    }

 </script>

</head>
<body onload="window_onload()" onresize='return window_onresize()' style="width: 100%;height:100%;overflow: hidden">
    <form action='' id="ventana_nueva" target="_blank" method="get" style="display:none;"></form>
        <table id="tb_body" cellpadding="0" cellspacing="0" border="0" style="width: 100%">
            <tr>
                <td id="tb_body_td" style="width: 30%;">
                    <iframe name="menu_left" id="menu_left" style="width: 100%; HEIGHT: 100%; overflow:hidden " frameborder="0" marginheight="0" marginwidth="0" > </iframe>
                </td>
                <script type="text/javascript">
                    $("menu_left").src = '<% =menu_left %>'
                </script>

                <% 
                    If (accion <> "" And op.tienePermiso("permisos_parametros", 2)) Then
            
                        Response.Write("<td id='tb_body_td_move' style='font-size:10;width: 2px;height:100%; cursor: w-resize; background-color: #b9b7b7 !important' onmousedown='javascript:tb_body_resize_inicio()'>&nbsp;</td>")
                        Response.Write("<td>")
                        Response.Write("<iframe src='enBlanco.htm' name='frame_nodo_parametro' id='frame_nodo_parametro' style='width: 100%;height: 100%;' frameborder='0' marginheight='0' marginwidth='0'></iframe>")
                        Response.Write("</td>")
            
                    End If
                %>
            </tr>
    </table>
</body>
</html>
