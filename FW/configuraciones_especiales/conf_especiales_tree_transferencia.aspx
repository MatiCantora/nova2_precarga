<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim id_conf As String = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    Dim transferencia As Integer = nvFW.nvUtiles.obtenerValor("id_transferencia", 0)
    Dim comentario As String = nvFW.nvUtiles.obtenerValor("comentario", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    
    If modo = "G" Then
        Dim er As New tError()
        Try
            Dim res As ADODB.Recordset = nvDBUtiles.DBExecute("insert into conf_especiales_transferencia(id_cfg_especial, id_transferencia, comentario_rel_transf) values (" & id_conf & ", " & transferencia & " , '" & comentario & "')")
            er.numError = 0
        Catch e As Exception
            er.numError = 100
            er.parse_error_script(e)
            er.mensaje = e.Message 
        End Try
        er.response()
            
    End If
   
    Me.contents("filtroTransferencia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especial_transferencia'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    
        
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Arbol Conf. especiales transferencia</title>

    <link href='/fw/css/base.css' type='text/css' rel='stylesheet' />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var id_conf = '<%= id_conf %>'
        var win = nvFW.getMyWindow()
        win.actualizar = false

        function window_onload() {   
                                   
        }
        
       function guardar(){
           if (campos_defs.get_value("id_transferencia") == ""){
                alert("Debe seleccionar una transferencia.")
                return
            }

           var rs = new tRS()
           rs.open(nvFW.pageContents.filtroTransferencia, "", "<id_transferencia>" + campos_defs.get_value("id_transferencia") + "</id_transferencia><id_cfg_especial>" + id_conf + "</id_cfg_especial>")
            if (!rs.eof()){
                alert("La transferencia ya se encuentra asociada a la configuración.")
                return
            }

            nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales_tree_transferencia.aspx', {
                parameters: { modo: 'G', id_conf: id_conf, id_transferencia: campos_defs.get_value("id_transferencia"), comentario: $('comentario').value },
                onSuccess: function(err, transport){   
                    if (err.numError == 0){
                        win.actualizar = true
                        win.close() 
                    }
                    else{ alert(err.mensaje) }
                    }
            })
        }

     
    </script>
    
</head>
<body onload="window_onload()" onresize="" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
     <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuLoca = new tMenu('divMenu', 'vMenuLoca');
        Menus["vMenuLoca"] = vMenuLoca
        Menus["vMenuLoca"].alineacion = 'centro';
        Menus["vMenuLoca"].estilo = 'A';
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenuLoca.loadImage('guardar', '/FW/image/icons/guardar.png')
        vMenuLoca.MostrarMenu()
    </script> 
    <table class="tb1" style="width: 100%">
        <tr>
            <td style="width: 15%">Transferencia:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("id_transferencia", nro_campo_tipo:=3)%> </td>
        </tr>
        <tr>
            <td>Comentario:</td>
            <td><input style="width:100%" type=""  size="3" id="comentario" /></td>
        </tr>
    </table>
</html>

