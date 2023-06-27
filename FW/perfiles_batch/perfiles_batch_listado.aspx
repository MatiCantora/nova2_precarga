<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Me.contents("filtroBatch") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPerfiles_batch'><campos>*</campos><orden></orden></select></criterio>")
    
    Me.addPermisoGrupo("permisos_web5")
        
    
 %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Perfiles ejecución batch listado</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit() %>
    
    <script type="text/javascript">
    
    var vButtonItems = []
    vButtonItems[0] = []
    vButtonItems[0]["nombre"] = "Buscar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return buscar()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage('buscar', '/FW/image/icons/buscar.png')


    function window_onload(){
        nvFW.enterToTab = true
        vListButtons.MostrarListButton()
        window_onresize()
		buscar()
    }

    function window_onresize() {
        var h_body = $$("BODY")[0].getHeight(),
            h_table = $("tbMenu").getHeight(),
            frame = $("tablaConcepto")
                
        frame.setStyle({ height: h_body - h_table - 20 })
    }

	 	
    function buscar() {
        var perfil = campos_defs.value("perfil_batch")
        var transferencia = campos_defs.value("transferencia")
        var archivo = campos_defs.value("archivo")
        var filtroWhere = "<criterio><select cacheControl='session' expire_minutes='2'><orden>id_bpm_batch</orden><filtro>"

        if (perfil != "")
            filtroWhere += "<bpm_batch type='like'>%" + perfil + "%</bpm_batch>"

        if (transferencia != "")
            filtroWhere += "<nombre_transf type='like'>%" + transferencia + "%</nombre_transf>"

        if (archivo != "")
            filtroWhere += "<nombre_excel type='like'>%" + archivo + "%</nombre_excel>"

        filtroWhere += "</filtro></select></criterio>"

        nvFW.exportarReporte({
            filtroXML: nvFW.pageContents.filtroBatch
            , filtroWhere : filtroWhere
            , path_xsl: "report\\perfiles_batch\\perfiles_batch_listar.xsl"
            , formTarget: 'tablaConcepto'
            , nvFW_mantener_origen: true
            , id_exp_origen: 0
            , bloq_contenedor: $('tablaConcepto')
            , cls_contenedor: 'tablaConcepto'
        })
    }

    function nuevo_perfil() {
        if(nvFW.tienePermiso("permisos_web5", 18)){
            var win = nvFW.createWindow({
                url: 'perfiles_batch_nuevo.aspx',
                title: '<b>Nuevo perfil ejecución Batch</b>',
                width: 600,
                height: 400,
                maximizable: true,
                minimizable: false,
                draggable: true,
                setWidthMaxWindow: true,
                destroyOnClose: true,
                onClose: function(win) {  }
            });
            win.showCenter(true)
        }
        else{
            nvFW.alert("No tiene permisos para realizar esta acción. Contacte con el administrador de sistemas")
        }
    }

    function bpm_batch_editar(id_batch){
        if (nvFW.tienePermiso("permisos_web5", 18)) {
            var win = top.nvFW.createWindow({
                title: "<b>ABM Perfil ejecución batch</b>",
                url: "/fw/perfiles_batch/perfiles_batch.aspx?id_batch=" + id_batch + "&edicion=true",
                width: "1000",
                height: "700",
                top: "50",
                setWidthMaxWindow: true,
                destroyOnClose: true,
                onClose: function(win) { if(win.buscar) buscar() }
            })
            win.buscar= false
            win.showCenter()
         }
         else{
            nvFW.alert("No tiene permisos para realizar esta acción. Contacte con el administrador de sistemas")
        }
    }


    function bpm_batch_procesar(id_batch) {
        if (nvFW.tienePermiso("permisos_web5", 17)) {
            var win = top.nvFW.createWindow({
                title: "<b>ABM Perfil ejecución batch</b>",
                url: "/fw/perfiles_batch/perfiles_batch.aspx?id_batch=" + id_batch,
                width: "1000",
                height: "700",
                top: "50",
                setWidthMaxWindow: true,
                destroyOnClose: true,
                onClose: function(win) { if (win.buscar) buscar() }
            })
            win.buscar = false
            win.showCenter()
        }
        else{
            nvFW.alert("No tiene permisos para realizar esta acción. Contacte con el administrador de sistemas")
        }
    }

    function batch_descargar_excel(id_batch, nombre_excel){
        window.open('/fw/perfiles_batch/perfiles_batch.aspx?accion=exportar&id_batch=' + id_batch)  
    }

</script>
</head>

<body onload="window_onload()" onresize="window_onresize()" style="background: white; width:100%; height:100%; overflow:hidden">
    
    <div id="divMenu" style="width: 100%;"></div>
        <script language="javascript" type="text/javascript">
            var vMenu = new tMenu('divMenu', 'vMenu');
            vMenu.loadImage("nuevo", "/FW/image/icons/nueva.png");
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_perfil()</Codigo></Ejecutar></Acciones></MenuItem>");
            vMenu.MostrarMenu();
        </script>
    <table class="tb1" id="tbMenu" style="overflow: hidden">
        <tr>
            <td class="Tit1">Descripción:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("perfil_batch", enDB:=False, nro_campo_tipo:=104)%></td>
            <td class="Tit1">Transferencia:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("transferencia", enDB:=False, nro_campo_tipo:=104)%></td>  
            <td class="Tit1">Excel:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("archivo", enDB:=False, nro_campo_tipo:=104)%></td>
            <td><div id="divBuscar" style="width:100%"></div></td>
        </tr>
    </table>

    <iframe id="tablaConcepto" name="tablaConcepto" src="/FW/enBlanco.htm" style="width:100%;  overflow:hidden;" frameborder="0"></iframe>
</body>
</html>
