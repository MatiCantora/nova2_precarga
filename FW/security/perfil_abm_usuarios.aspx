<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    
   Dim err As New nvFW.tError()
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim tipo_operador As String = nvFW.nvUtiles.obtenerValor("tipo_operador", "0")
    Dim tipo_operador_desc As String = nvFW.nvUtiles.obtenerValor("tipo_operador_desc", "")
     
    If modo <> "" Then
        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_operadores_perfiles_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
         
        Dim param1 = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        'param2 = cmd.CreateParameter("@tipo_operador", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 0, tipo_operador)
        'param3 = cmd.CreateParameter("@tipo_operador_desc", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, tipo_operador_txt.Length, tipo_operador_txt)
       
        'cmd.Parameters.Append(param1)
        'cmd.Parameters.Append(param2)
        'cmd.Parameters.Append(param3)
        
        'Try
        '    Dim rs As ADODB.Recordset = cmd.Execute()
        '    nvFW.nvDBUtiles.DBCloseRecordset(rs)
        'Catch ex As Exception
            
        '    err.numError = -1
        '    err.mensaje = "Error inesperado"
        '    err.titulo = "Error al tratar de realizar la operación"
        '    err.debug_desc = ex.Message
        '    err.debug_src = "FW_perfil_ABM"
            
        'End Try
        
        err.response()
    End If
    
    Me.contents("filtroverOperadores_operador_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>operador,Login </campos><filtro><tipo_operador type='igual'>" + tipo_operador + "</tipo_operador></filtro><orden></orden></select></criterio>")
    Me.contents("filtroUsuario") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>distinct operador as id, strNombreCompleto as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Perfil ABM usuarios</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript"  src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript"  src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript"  src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript"  src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript"  src="/fw/script/tcampo_head.js"></script>
    <script type="text/javascript"  src="/fw/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var tablaUsuarios
        var win=nvFW.getMyWindow()

        function window_onload(){
            tablaUsuarios = new tTable();
            window_onresize()
         
            tablaUsuarios.nombreTabla = "tablaUsuarios";
            tablaUsuarios.filtroXML = nvFW.pageContents.filtroverOperadores_operador_tipo
            tablaUsuarios.cabeceras = ["Id", "Usuario"];
            tablaUsuarios.eliminable = true;
            tablaUsuarios.editable = false;
            tablaUsuarios.async = true;
            tablaUsuarios.campos = [
                 { nombreCampo: "operador", width: "20%", ordenable: true, editable:false },
                 { nombreCampo: "Login",
                    id: "operador",
                    get_campo: function (nombreTabla, id) {
                        campos_defs.add(nombreTabla + "_campos_defs" + id, { nro_campo_tipo: 3, campo_codigo: "operador",
                            enDB: false,
                            campo_desc: "Login",
                            filtroXML: nvFW.pageContents.filtroUsuario,
                            target: 'campos_tb_' + nombreTabla + id
                        });
                    },
                    enDB: false,
                    width: "70%",
                    unico: true
                }
            ];

            tablaUsuarios.table_load_html();
        }
   

        function guardar(){
            var xml = tablaUsuarios.generarXML("perfiles");
            if(xml != ""){
                var strxml = "<?xml version='1.0' encoding='ISO-8859-1'?>" + xml
                nvFW_error_ajax_request('perfil_abm_usuarios.aspx',{ 
                    parameters: {modo:"M", strXML: strxml },
                    onSuccess: actualizar_return
                });
            }
            else{
                win.close()
            }
        }

        function actualizar_return(er, transport){
            switch(er.numError) {
                case 0:
                    window.setTimeout('win.close()',1000)
                    break
                default:
                    Dialog.alert(numError+' - '+ er.descripcion,{ className: "alphacube",
                        width: 300,
                        height: 100,
                        okLabel: "cerrar",
                        onOk: function(ver) { ver.close(); }
                    });
            }
        }

        function window_onresize(){
            try {
                var dif=Prototype.Browser.IE?5:2
                body_height=$$('body')[0].getHeight()
                cab_height=$('tbFiltro').getHeight()
                div_height = $('divMenu').getHeight()

                $('div_tablaUsuarios').setStyle({ 'height': body_height-cab_height-div_height-dif })
            }
            catch(e) { }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style='width:100%;height:100%;overflow:hidden'>
<input type="hidden" id='modo' name="modo" />

  <div id="divMenu" style="margin: 0px;padding: 0px;"></div>
    <script type="text/javascript" language="javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        vMenu.loadImage("guardar", "/fw/image/icons/guardar.png")
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu.MostrarMenu()

    </script> 
    <table id="tbFiltro" class='tb1'>
        <tr class=''>
           <td class="Tit1" style='width:30%'>Perfil:</td>
           <td style='width:70%'><input type="text" disabled="disabled" value="<%= tipo_operador_desc%>"/></td>
        </tr>
    </table>       
    <div style="width: 100%; height: 100%; overflow: auto;" id='div_tablaUsuarios'>
        <div id='tablaUsuarios' style="overflow: hidden;"></div>
    </div>
    
</body>
</html>