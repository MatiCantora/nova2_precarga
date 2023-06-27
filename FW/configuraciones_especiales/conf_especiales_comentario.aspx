<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    
    Dim texto = nvFW.nvUtiles.obtenerValor("texto", "")
    Dim configuracion = nvFW.nvUtiles.obtenerValor("configuracion", "")
    Dim accion = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim id_conf = nvFW.nvUtiles.obtenerValor("id_conf", "")
    
    If texto = "undefined" Then
        texto = ""
    End If
    
    If accion = "guardar" Then
        Dim tabla = "conf_especiales_" + configuracion
        Dim campo = "comentario_rel_" + configuracion
        
        nvFW.nvDBUtiles.DBExecute("update " + tabla + " set " + campo + " = '" + texto + "' where id_rel = " + id_conf)
        
    End If
    
%>
<html>
<head>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <% = Me.getHeadInit()%>

    
<script type="text/javascript">

    var win = nvFW.getMyWindow()
    win.cancelado = true
    win.texto = ""
    var configuracion = '<%= configuracion%>'
    var id_conf = '<%= id_conf%>'
   
    function window_onload() { }

    function aceptar(){

//        nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales_comentario.aspx', { parameters: { modo: 'guardar', texto: $('textarea').value, id_conf: id_conf, conf: configuracion },
//            onSuccess: function(err, transport)
//            {
//                win.cancelado = false
//       
//            }
//        }) 

        win.texto = $('textarea').value
        win.cancelado = false
        win.close()
    }

     
</script>

<body onload="window_onload()" style="width:100%;height: 100%; overflow: auto">
    <table id="tb_comentario" class="tb1" style="width:100%;height: 100%; vertical-align: top;">
        <tr style="width:100%;">
            <td style="width:100%; text-align:center"><textarea id="textarea" rows="6" cols="40" style="width:100%"><%=texto%></textarea></td>
        </tr>
        <tr style="width:100%;">
            <td style="width:100%; text-align:center"><button onclick="aceptar()">Aceptar</button></td>
       </tr>
   </table>
</body>
</html>
