<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim id_conf As String = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    Dim param As String = nvFW.nvUtiles.obtenerValor("param", "")
    Dim comentario As String = nvFW.nvUtiles.obtenerValor("comentario", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    
    If modo = "G" Then
        Dim er As New tError()
        Try    
            Dim res As ADODB.Recordset = nvDBUtiles.DBExecute("insert into conf_especiales_parametro(id_cfg_especial, nro_par_nodo, comentario_relacion) values (" & id_conf & ", '" & param & "' , '" & comentario & "')")
            er.numError = 0
        Catch e As Exception
            er.numError = 100
            er.parse_error_script(e)
        End Try
        er.response()
            
    End If
    
    Me.contents("filtroParametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especial_parametro'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    
        
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Arbol Conf. especiales paramretros</title>

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
           if ($("nro_par_nodo").value == "")
           {
                alert("Debe seleccionar un parmámetro.")
                return
            }

//            var rs = new tRS()
//            rs.open(nvFW.pageContents.filtroParametro, "", "<nro_par_nodo>" + campos_defs.get_value("nro_par_nodo") + "</nro_par_nodo><id_cfg_especial>" + id_conf + "</id_cfg_especial>")
//            if (!rs.eof()) {
//                alert("El parametro ya se encuentra asociado a la configuración.")
//                return
//            }
            nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales_tree_parametro.aspx', {
                parameters: { modo: 'G', id_conf: id_conf, param: nro_par_nodo , comentario: $('comentario').value },
                onSuccess: function(err, transport){
                    if (err.numError == 0)
                    {
                        win.actualizar = true
                        win.close()
                    }
                    else { alert(err.mensaje) }
                }
            })
        }

        var nro_par_nodo
        var par_nodo
        function campodef_param() {
            var win = top.nvFW.createWindow({
                title: "Seleccionar",
                width: 400, 
                height: 350,
                minimizable: false,
                minHeight: 350,
                maxHeight: 350,
                minWidth: 350,
                url: "/fw/configuraciones_especiales/conf_especiales_param_nodos.aspx",
                onClose: function(win){    
                if (win.cancelado == false) {
                    if (!paramExistente(win.campo_def_value)) {
                        nro_par_nodo = win.campo_def_value
                        par_nodo = win.campo_desc
                        $('nro_par_nodo').value = "("+ nro_par_nodo +") " + par_nodo 
                    }
                    else { top.nvFW.alert("El parametro ya ha sido agregado") }
                 }
               }
           })
            win.showCenter(true);
        }

        function paramExistente(nro_par_nodo) {
            var rs = new tRS()
            rs.open(nvFW.pageContents.filtroParametro, "", "<nro_par_nodo>" + nro_par_nodo + "</nro_par_nodo>")
            if (!rs.eof()) return true
            else return false
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
            <td style="width: 15%">Parámetro:</td>
            <td><input style="width:100%" type="text" id="nro_par_nodo" onclick="campodef_param(event)" /></td>
        </tr>
        <tr>
            <td>Comentario:</td>
            <td><input style="width:100%" type=""    size="3" id="comentario" /></td>
        </tr>
    </table>
</html>

