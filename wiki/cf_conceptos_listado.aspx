<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Me.contents("filtro_conceptos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCf_conceptos'><campos>*</campos><orden></orden></select></criterio>")
 %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Conceptos Listado</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <style type="text/css">
        .botonBuscar {
            border-width: 2px;
            width:100%;
            background-image: url('/FW/image/icons/buscar.png');
            background-repeat: no-repeat;
            background-position: 3px 1px;
        }
        .botonBuscar:hover {border-color: #b0b0b0; cursor:pointer;}
    </style>

    <%= Me.getHeadInit() %>
    
    <script type="text/javascript">
        function window_onload() {
            window_onresize()
			buscar()
        }

        function window_onresize() {
            var h_body = $$("BODY")[0].getHeight(),
                h_table = $("tbMenu").getHeight(),
                frame = $("tablaConcepto")
                
            frame.setStyle({ height: h_body - h_table - 20 })
        }

		function nuevo_concepto(){
		    var win = nvFW.createWindow({
		        url: "/wiki/cf_conceptos_abm.aspx?cf_id=",
                title: "<b>ABM Conceptos Financieros</b>",
                width: "500",
                height: "170",
                top:"50",
                destroyOnClose: true
		    })

          	win.showCenter(true)
    	}

        function concepto_editar(cf_id){
		    var win = nvFW.createWindow({url: "/wiki/cf_conceptos_abm.aspx?cf_id=" + cf_id, 
                                            title: "<b>ABM Conceptos Financieros</b>",
		                                    width: "500", 
		                                    height: "170", 
		                                    top:"50",
                                            destroyOnClose: true
		                                    })
		    win.showCenter(true)
		}

        function buscar() {
            var concepto_value = campos_defs.value("cf_concepto"),
                tipo_value = campos_defs.value("cf_tipo"),
                filtroWhere = "<criterio><select cacheControl='session' expire_minutes='2'><orden>cf_id</orden><filtro>"

            if (concepto_value != "")
                filtroWhere += "<cf_concepto type='like'>%" + concepto_value + "%</cf_concepto>"

            if (tipo_value != "")
                filtroWhere += "<cf_tipo type='like'>%" + tipo_value + "%</cf_tipo>"

            filtroWhere += "</filtro></select></criterio>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_conceptos
                , filtroWhere : filtroWhere
                , path_xsl: "report\\cf_conceptos_listado.xsl"
                , formTarget: 'tablaConcepto'
                , nvFW_mantener_origen: true
                , id_exp_origen: 0
                , bloq_contenedor: $('tablaConcepto')
                , cls_contenedor: 'tablaConcepto'
            })
        }

        var winTipo = {},
            tipo_desc = null,
            tipo_id = null

        function open_abm_tipo() {
            winTipo = nvFW.createWindow({
                url: "/wiki/cf_tipos_listar.aspx?open_abm=1",
                title: "<b>ABM Tipos de CF</b>",
                width: 500,
                height: 400,
                destroyOnClose: true,
                minimizable: true,
                maximizable: true
            })

            winTipo.showCenter(true)
        }

    </script>
</head>

<body onload="window_onload()" onresize="window_onresize()" style="background: white; width:100%; height:100%; overflow:hidden">
    <table class="tb1" id="tbMenu" style="overflow: hidden">
        <tr>
            <td colspan="5">
                <div id="divMenu" style="width: 100%; display: block"></div>
                <script language="javascript" type="text/javascript">
                    var vMenu = new tMenu('divMenu', 'vMenu');
                    vMenu.loadImage("nuevo", "/FW/image/icons/file.png");

                    Menus["vMenu"] = vMenu
                    Menus["vMenu"].alineacion = 'centro';
                    Menus["vMenu"].estilo = 'A';
                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 20%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>ABM Tipo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>open_abm_tipo()</Codigo></Ejecutar></Acciones></MenuItem>");
                    vMenu.MostrarMenu();
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Concepto:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("cf_concepto", enDB:=False, nro_campo_tipo:=104) %></td>
            <td class="Tit1">Tipo:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("cf_tipo", enDB:=False, nro_campo_tipo:=104) %></td>
            <td>
                <input type="button" name="buscar" value="Buscar" onclick="return buscar()" class="botonBuscar" />
            </td>
        </tr>
    </table>

    <iframe id="tablaConcepto" name="tablaConcepto" src="enBlanco.htm" style="width:100%; height:200px; overflow:hidden;" frameborder="0"></iframe>

    <div style="width: 100%; height:20px;position:absolute; bottom:0">
        <span style="background-image: url(/fw/image/icons/agregar.png); background-repeat: no-repeat; display:block; width:20px; height:20px; margin:0 auto; cursor:pointer" onclick="return nuevo_concepto()" title="Agregar Concepto">&nbsp;</span>
    </div>
</body>
</html>
