<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim operador As nvFW.nvPages.tnvOperadorVOII
    Dim sucursal As String = ""

    Try
        operador = nvFW.nvApp.getInstance().operador

        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("SELECT sucursal FROM sucursal WHERE nro_sucursal=" & operador.datos("nro_sucursal").value)

        If Not rs.EOF Then
            sucursal = rs.Fields("sucursal").Value
        Else
            sucursal = "Sin Sucursal"
        End If

        nvFW.nvDBUtiles.DBCloseRecordset(rs)
    Catch ex As Exception
    End Try

    Me.addPermisoGrupo("permisos_solicitudes")

 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />

    <title>NOVA VOII</title>
    
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet"/>
    <link rel="shortcut icon" href="/fw/image/icons/nv_voii.ico"/>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>

    <% = Me.getHeadInit() %>

    <script  type="text/javascript" >
        var sistema
        var canal
        var win 
        var winActualizar 



        function window_onresize()
        {
            var dif         = Prototype.Browser.IE ? 5 : 0
            var body_heigth = $$('body')[0].getHeight()
            //var cab_heigth  = $('tb_cab').getHeight()

            $('tb_body').setStyle({ 'height': body_heigth - dif + 'px' })
        }


        function window_onload()
        {
            window_onresize()
        }


      
    </script>
    <script type="text/javascript">
        function tb_body_resize_inicio()
        {
            var body = $$('BODY')[0]

            if ($('tb_body_div_hide') == null) {
                var strHTML = '<div id="tb_body_div_hide" style="width: 100%; height: 100%; position: absolute; z-index: 1000; float: left; background-color: gray; opacity: 0.1;"></div>'
                $$('BODY')[0].insert({ top: strHTML })
                //var oDIV = $("tb_body_div_hide")
                //Element.setOpacity(oDIV, 0.0)
                strHTML = '<div id="tb_body_div_rec" style="position: absolute; z-index: 1000; float: left; background-color: gray; opacity: 0.5;"></div>'
                $$('BODY')[0].insert({ top: strHTML })
                var oDIV_rec = $("tb_body_div_rec")
                //Element.setOpacity(oDIV_rec, 0.5)
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

            Event.observe($$('BODY')[0], 'mousemove', tb_body_resize_mousemove);
            Event.observe($$('BODY')[0], 'mouseup', tb_body_resize_fin);
        }


        function tb_body_resize_fin()
        {
            //var body = $$('BODY')[0]
            var oDIV_rec = $('tb_body_div_rec')

            $('tb_body_td').setStyle({ width: oDIV_rec.getStyle('left') })
            Event.stopObserving($$('BODY')[0], 'mousemove', tb_body_resize_mousemove);
            var oDIV = $("tb_body_div_hide")
            $$('BODY')[0].setStyle({ cursor: '' })
            oDIV.hide()
            oDIV_rec.hide()
        }


        function tb_body_resize_mousemove(e)
        {
            try {
                var nuevoX = Event.pointerX(e) - 4
                $('tb_body_div_rec').setStyle({ left: nuevoX + 'px' })
                document.selection.clear()
            }
            catch(e) {}  
        }
    </script>
</head>
<body id="iframeWindows" onload="window_onload()" onresize='window_onresize()' style="overflow: hidden;">
    <%--<form action='' id="ventana_nueva" target="_blank" method="get" style="display: none"></form>--%>
    
    <table id="tb_body" cellpadding="0" cellspacing="0" border="0" style="width: 100%; height: 100%;">
        <tr>
            <td id="tb_body_td" style="width: 288px;">
                <iframe src="buscar.aspx" name="frame_buscar" id="frame_buscar" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
            <td id="tb_body_td_move" style="width: 2px; cursor: w-resize;" onmousedown="javascript:tb_body_resize_inicio()">&nbsp;</td>
            <td>
                <iframe src="enBlanco.htm" name="frame_consulta" id="frame_consulta" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
        </tr>
    </table>

</body>
</html>
