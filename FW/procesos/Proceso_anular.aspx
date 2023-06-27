<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim nro_proceso = nvFW.nvUtiles.obtenerValor("nro_proceso", 0)
    Dim tipo_proceso = nvFW.nvUtiles.obtenerValor("tipo_proceso", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim comentario As String = nvFW.nvUtiles.obtenerValor("comentario", "")
    Dim usuario As String = nvApp.operador.login
    If accion.ToLower = "anular" Then
        Dim er As New tError()
        Try    
            Dim rs = nvFW.nvDBUtiles.DBExecute("exec rm_proceso_anular " + nro_proceso + ", " + comentario)
            er.numError = 0
        Catch ex As Exception
            er.parse_error_script(ex)
            er.numError = 100
            er.mensaje = ex.Message
        End Try
        er.response()
    End If
   
%>
<html>
<head>
<title>Anular Proceso</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tUpload.js" language="javascript"></script>
        <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

     var vButtonItems = {}
     vButtonItems[0] = {}
     vButtonItems[0]["nombre"] = "Anular";
     vButtonItems[0]["etiqueta"] = "Anular Proceso";
     vButtonItems[0]["imagen"] = "guardar";
     vButtonItems[0]["onclick"] = "return btnAnular_onclick()";

     vButtonItems[1] = {}
     vButtonItems[1]["nombre"] = "Cancelar";
     vButtonItems[1]["etiqueta"] = "Cancelar";
     vButtonItems[1]["imagen"] = "cancelar";
     vButtonItems[1]["onclick"] = "return btnCancelar_onclick()";
  
     var vListButton = new tListButton(vButtonItems,'vListButton');
     vListButton.loadImage('guardar', '/fw/image/icons/guardar.png')
     vListButton.loadImage('cancelar', '/fw/image/icons/eliminar.png')

     var nro_proceso = '<%=nro_proceso %>'
     var tipo_proceso = '<%=tipo_proceso %>'
     var mywin = nvFW.getMyWindow()
    function window_onload() {               
        vListButton.MostrarListButton()
        $('nro_proceso').value = nro_proceso
        $('tipo_proceso').value = tipo_proceso
        $('usuario').value =  '<%= usuario %> '
    }

    function btnAnular_onclick(){
        if ($('observacion').value == ""){
            alert('Debe colocar un comentario para anular el proceso.')
            return
        }
        else{
            nvFW.error_ajax_request("Proceso_anular.aspx",
                        { parameters: { accion: "anular", nro_proceso: nro_proceso, comentario: $('observacion').value }
                        , onSuccess: function() {
                            if (mywin.returnValue) mywin.returnValue = 'ANULADO'               
                            mywin.close()
                        }
                        , error_alert: true
                        })
        }        
    }

    function btnCancelar_onclick(){
       
        mywin.close()
    }

</script>
</head>
<body onload="return window_onload()" style="height: 100%; width:100%; overflow: hidden;margin: 0px; padding: 0px">
    <table class="tb1">
      <tr>
        <td class='TIT1' style="width:30%">Nro. Proceso:</td><td><input type="text" style="width:100%" name="nro_proceso" id="nro_proceso" readonly /></td>
      </tr>
      <tr>  
        <td class='TIT1'>Tipo:</td><td><input type="text" style="width:100%" name="tipo_proceso" id="tipo_proceso" readonly /></td>
      </tr>
      <tr>  
        <td class='TIT1'>Usuario:</td><td><input type="text" name="usuario"  id="usuario" style="width:100%" readonly /></td>
      </tr>
    </table>
    <table class="tb1">
      <tr class="tbLabel">
        <td>Comentario de la Anulación:</td>
      </tr>
      <tr>      
        <td style="width: 100%"><textarea rows="4" style="width:100%" name="observacion" id="observacion"></textarea></td>
      </tr>   
    </table>           
    <table width="100%">     
      <tr>
        <td><br></td>
      </tr>
      <tr sstyle="text-align:center">
        <td style="width:50%; text-align:center"><div style="width:200px" id="divAnular"></div></td>
        <td style="width:50%; text-align:center"><div style="width:200px" id="divCancelar"></div></td>
      </tr>
    </table>
<iframe name="ifProceso_log" id="ifProceso_log" style='height:100%; width:100%;overflow:hidden' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</body>
</html>