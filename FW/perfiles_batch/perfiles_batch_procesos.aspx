<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("ver_proceso_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verProceso_trasferencia'><campos>*</campos><orden>nro_proceso</orden><filtro></filtro></select></criterio>")
    Me.contents("verProcesos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPerfiles_rel_procesos'><campos>*</campos><orden>nro_proceso</orden><filtro></filtro></select></criterio>")
     
    Dim nro_proceso = nvUtiles.obtenerValor("nro_proceso", "")
    
    %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administracion Procesos ABM</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" language='javascript'></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
     <% =Me.getHeadInit()%>
<script>

    var nro_proceso = '<%= nro_proceso %>'
 
   var criterio = ''
    
    function window_onload(){     
                                                              
        campos_defs.set_value('nro_proceso', nro_proceso)     
        campos_defs.habilitar("nro_proceso", false)
        var rs = new tRS()
        rs.open(nvFW.pageContents.verProcesos , '', "<nro_proceso type='igual'>"+nro_proceso+"</nro_proceso>" )
        if (!rs.eof()){                              
               $('id_batch').value = rs.getdata('id_bpm_batch')
               $('batch').value = rs.getdata('bpm_batch')
               $('fecha').value = rs.getdata('fecha_proceso')
               campos_defs.set_value('nro_operador',rs.getdata('operador'))
               campos_defs.habilitar('nro_operador',false)
           }
        MostrarProcesos()
        window_onresize()
    }  
    

    function MostrarProcesos(){
        var altura_contenedor = $("FrameResultado").getHeight() - 20 // 22px: altura aproximada del paginador
        var altura_fila = 28 // "px" aproximados
        var cant_filas = Math.floor(altura_contenedor / altura_fila)
         

        nvFW.exportarReporte({ filtroXML: nvFW.pageContents.ver_proceso_detalle,
                            filtroWhere: "<criterio><select PageSize='" + cant_filas + "' AbsolutePage='1'><filtro><nro_proceso type='igual'> " + nro_proceso + "</nro_proceso></filtro></select></criterio>",
                            path_xsl: 'report\\perfiles_batch\\verProceso_batch_transf.xsl',
                            formTarget: 'FrameResultado',
                            bloq_contenedor: $('FrameResultado'),
                            cls_contenedor: 'FrameResultado',
                            nvFW_mantener_origen: true,
                            id_exp_origen: 0
                        })
    }

    function mostrar_transf(id_transf_log){
        var win_seg = window.top.nvFW.createWindow({
            url: '/fw/transferencia/transf_seguimiento_pool_control_exec.aspx?id_transf_log=' + id_transf_log,
            minimizable: false,
            maximizable: true,
            draggable: true,
            width: 750,
            height: 350,
            resizable: true,
            destroyOnClose: true
        })

        win_seg.showCenter()
    }

    function ejecutarTransferencia(id_transf_log){
        if (nvFW.tienePermiso('permisos_transferencia', 1))
        {
            var param = '<parametros>'
            var rs = new tRS()
            rs.open(nvFW.pageContents.ver_log_transf_det, '', "<id_transf_log type='igual'>" + id_transf_log + "</id_transf_log>")
            if (!rs.eof())
            {
                var rs_param = new tRS()
                rs_param.open(nvFW.pageContents.ver_log_transf_param, '', "<id_transf_log_det type='igual'>" + rs.getdata("id_transf_log_det") + "</id_transf_log_det>")
                while (!rs_param.eof())
                {
                    if (rs_param.getdata("valor") != "null")
                        param += "<" + rs_param.getdata("parametro") + ">" + rs_param.getdata("valor") + "</" + rs_param.getdata("parametro") + ">"
                    rs_param.movenext()
                }
                param += "</parametros>"
            }

            nvFW.transferenciaEjecutar({
                id_transferencia: campos_defs.get_value("id_transferencia"),
                xml_param: param,
                pasada: 0,
                formTarget: 'winPrototype',
                async: false,
                ej_mostrar: true,
                winPrototype: {
                    modal: true,
                    center: true,
                    bloquear: false,
                    url: '/fw/enBlanco.htm',
                    title: '<b>Transferencia</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 800,
                    height: 400,
                    resizable: true,
                    destroyOnClose: true
                }
            })
        }
        else
        {
            alert("No tiene permisos para ejecutar la transferencia")
        }
    }

    function window_onresize(){           
        var dif = Prototype.Browser.IE ? 5 : 2
        body_heigth = $$('body')[0].getHeight()
        cab_heigth = $('divFiltro').getHeight()
        $('FrameResultado').setStyle({'height': body_heigth - cab_heigth - dif })
     }

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; width:100%; overflow: hidden;margin: 0px; padding: 0px">
<div id="divFiltro" style="margin: 0px; padding: 0px;width:100%">
<div id="divMenu" style="margin: 0px; padding: 0px" ></div>
    <script type="text/javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenu = new tMenu('divMenu', 'vMenu');
     Menus["vMenu"] = vMenu
     Menus["vMenu"].alineacion = 'centro';
     Menus["vMenu"].estilo = 'A';
      Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
     vMenu.loadImage('buscar','/FW/image/icons/buscar.png')
     vMenu.MostrarMenu()
    </script>
    <table class="tb1" style="width: 100%">
        <tr>
            <td class="Tit1">Batch:</td>
            <td style="width: 30%"><input id="id_batch" disabled="disabled" type="text" style="width:10%"/><input id="batch" disabled="disabled" type="text" style="width : 89%"/></td>
            <td class="Tit1" style="width: 10%">Operador:</td>
            <td style="width: 30%"> <%= nvFW.nvCampo_def.get_html_input("nro_operador")%></td>
        <tr/>
        <tr> 
            <td class="Tit1" style="width: 11%">Nro. Proceso:</td>
            <td style="width:"><%= nvFW.nvCampo_def.get_html_input("nro_proceso", nro_campo_tipo:=104, enDB:=False)%></td>   
            <td class="Tit1" style="width: 11%">Fecha:</td>
            <td style="width:15%" id="fe_desde_proceso"><input  id="fecha" disabled="disabled" type="text" style="width:100%"/></td>
        </tr>
       <%-- <tr>
            <td class="Tit1" style="width: 10%">Estado:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("estado_procesos")%></td>
        </tr>--%>
    </table>
</div>
<iframe name="FrameResultado" id="FrameResultado" style='height:100%; width:100%;overflow:hidden' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</body>
</html>
