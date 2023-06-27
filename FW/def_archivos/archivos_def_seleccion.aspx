<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    ' Me.contents("filtroBusquedaCab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_cab' PageSize='19' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden>nro_def_archivo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroBusquedaCab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_cab'><campos>*</campos><orden>nro_def_archivo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroDetalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_detalle'><campos>nro_def_detalle</campos><filtro><nro_def_archivo type='igual'>%nro_def_archivo%</nro_def_archivo></filtro></select></criterio>")
    Me.contents("filtroArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos'><campos>COUNT(*) as cant_archivos</campos><filtro><nro_def_detalle type='igual'>%nro_def_detalle%</nro_def_detalle></filtro></select></criterio>")


    Me.addPermisoGrupo("permisos_def_archivo")
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Definición de Archivos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    
    <%= Me.getHeadInit() %>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var filtroBusquedaCab = nvFW.pageContents.filtroBusquedaCab
        var filtroDetalle = nvFW.pageContents.filtroDetalle
        var filtroArchivos = nvFW.pageContents.filtroArchivos        

    var vButtonItems = {}

    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "Buscar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return buscar_archivos_def()";

    vButtonItems[1] = {}
    vButtonItems[1]["nombre"] = "Exportar";
    vButtonItems[1]["etiqueta"] = "Exportar";
    vButtonItems[1]["imagen"] = "excel";
    vButtonItems[1]["onclick"] = "return exportar_archivos_def()";


    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    //vListButtons.imagenes = Imagenes                                                // "Imagenes" está definida en "pvUtiles.asp"
    vListButtons.loadImage("buscar", "/FW/image/icons/buscar.png")
    vListButtons.loadImage("excel", "/FW/image/icons/excel.png")

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            tb_definicion_archivos_h = $('tb_definicion_archivos').getHeight()
            divMenuArchivosDefSeleccion_h = $('divMenuArchivosDefSeleccion').getHeight()
            $('iframe_definicion_archivos').setStyle({ 'height': body_height - divMenuArchivosDefSeleccion_h - tb_definicion_archivos_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() 
    {
        // mostramos los botones creados
        vListButtons.MostrarListButton()
        window_onresize()
    }

    //Muestra en pantalla el resultado de una búsqueda de Definiciones de Archivos
    function buscar_archivos_def()
    {
        var nro_def_archivo = campos_defs.get_value('nro_def_archivos3')
        var desc_def_archivo = campos_defs.get_value('desc_def_archivos3')
        var filtro = ''
        
        if (nro_def_archivo != '') {
            filtro = "<nro_def_archivo type='igual'>" + nro_def_archivo + "</nro_def_archivo>"
        } else if (desc_def_archivo != '') {
            filtro = "<def_archivo type='like'>%" + desc_def_archivo + "%</def_archivo>"
        }

        if ($('vigente').value == 'si') {
            filtro = "<def_fe_baja type='isnull'></def_fe_baja>"

        } else if ($('vigente').value == 'no') {
            filtro = "<def_fe_baja type='like'>%0%</def_fe_baja>"

        }

        var filtroXML = filtroBusquedaCab
        var filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"

        nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere : filtroWhere,
                path_xsl: 'report\\def_archivos\\verArchivos_def_cab\\HTML_verArchivos_def_cab.xsl',
                formTarget: 'iframe_definicion_archivos',
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                bloq_contenedor: $('iframe_definicion_archivos'),
                cls_contenedor: 'iframe_definicion_archivos'
        })          
    }

    function exportar_archivos_def() {
        var nro_def_archivo = campos_defs.get_value('nro_def_archivos3')
        var filtro = ''

        if (nro_def_archivo != '')
            filtro = "<nro_def_archivo>" + nro_def_archivo + "</nro_def_archivo>"
        else {
            alert('Para generar el reporte debe seleccionar una Definición de Archivos')
            return 
        }

        var strXML_parm = '<parametros>' + filtro + '</parametros>'

        alert('Falta pasar la transferencia')
        return

        nvFW.transferenciaEjecutar({
            id_transferencia: 789,
            xml_param: strXML_parm,
            pasada: 0,
            ej_mostrar: true,
            formTarget: 'winPrototype',
            winPrototype: { 
                modal: false,
                center: true,
                bloquear: false,
                url: 'enBlanco.htm',
                title: '<b>Reportes Definición de Archivos</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 800,
                height: 400,
                resizable: true,
                destroyOnClose: true,
                onClose: function () { }
            }
        })
    }

    //ABM Definición de Archivos 
    var win_archivos_def_abm
    function archivos_def_abm(nro_def_archivo, accion) {
        
        if (!nvFW.tienePermiso('permisos_def_archivo', 2)) {
            alert('No tiene permiso para Altas ni Edición. Comuniquese con el administrador de sistemas.')
            return
        }
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_ABM.aspx?nro_def_archivo=' + nro_def_archivo + '&accion=' + accion,
            title: '<b>ABM Definición de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 1000,
            height: 500,
            onClose: function () {
                buscar_archivos_def
                sessionStorage.clear()
            }
        });

        win_archivos_def_abm.options.userData = { nro_def_archivo: nro_def_archivo }
        win_archivos_def_abm.showCenter()
    }

    //Elimina una Definición de Archivos
    function eliminar_archivos_def(nro_def_archivo) {

        if (!nvFW.tienePermiso('permisos_def_archivo', 3)) {
            alert('No tiene permiso para Eliminar definiciones de archivo. Comuniquese con el administrador de sistemas.')
            return
        }

        var cant_archivos = 0
        var nro_def_detalle = 0

        var rs1 = new tRS()
        var params1 = "<criterio><params nro_def_archivo='" + nro_def_archivo + "'/></criterio>"
        rs1.open(filtroDetalle, '', '', '', params1)

        while (!rs1.eof()) {
            nro_def_detalle = rs1.getdata('nro_def_detalle')

            var rs2 = new tRS()
            var params2 = "<criterio><params nro_def_detalle='" + nro_def_detalle + "'/></criterio>"
            rs2.open(filtroArchivos, '', '', '', params2)

            if (!rs2.eof())
                cant_archivos = cant_archivos + parseInt(rs2.getdata('cant_archivos'))
                        
            rs1.movenext()
        }

        if (cant_archivos > 0) {
            alert('No se puede eliminar la Definición de Archivos. Existen "archivos" cargados a los detalles de la definición.')
        } else {
            var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xmldato += "<archivos_def_cab accion='B' nro_def_archivo= '-" + nro_def_archivo + "' ></archivos_def_cab>"
            Dialog.confirm('¿Desea eliminar la Definición de Archivos seleccionada.?', { width: 300, className: "alphacube",
                onOk: function(win) {
                    nvFW.error_ajax_request('/fw/def_archivos/archivos_def_ABM.aspx', {
                        parameters: { modo: 'B', strXML: escape(xmldato) },
                        onSuccess: function(err, transport) {
                                        if (err.numError == 0) {
                                            buscar_archivos_def()
                                            win.close()
                                        }
                                        else {
                                            alert(err.mensaje)
                                            return
                                        }
                        }
                    });
                },
                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar',
                onCancel: function(win) { win.close() }
            })
        }
    }

    //ABM Tipos de Archivos Def
    var win_archivos_def_tipo_abm
    function archivos_def_tipo_abm() {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_tipo_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_tipo_seleccion.aspx',
            title: '<b>Tipos de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 800,
            height: 400,
            onClose: function () {}
        });

        win_archivos_def_tipo_abm.showCenter()
    }

    //ABM Perfil Archivos Def
    var win_archivos_def_perfil_abm
    function archivos_def_perfil_abm() {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_perfil_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_perfil_seleccion.aspx',
            title: '<b>Perfil de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 800,
            height: 400,
            onClose: function () {}
        });

        win_archivos_def_perfil_abm.showCenter()
    }

    //ABM Colores
    var win_img_depthcolor_abm
    function img_depthcolor_abm() {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_img_depthcolor_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/img_depthcolor_seleccion.aspx',
            title: '<b>ABM Color</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 800,
            height: 400,
            onClose: function () {}
        });

        win_img_depthcolor_abm.showCenter()
    }

    //ABM Grupos
    var win_img_grupo_abm
    function img_grupo_abm() {

        //if (!nvFW.tienePermiso(permiso, nro_permiso)) {
        //    alert('No posee los permisos necesarios para realizar esta acción.');
        //    return;
        //} else {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_img_grupo_abm = w.createWindow({
                className: 'alphacube',
                url: '/fw/def_archivos/archivos_def_grupo_seleccion.aspx',
                title: '<b>ABM Grupo</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                resizable: false,
                width: 800,
                height: 400,
                onClose: function () {}
            });

            win_img_grupo_abm.showCenter()
        //}
    }

    </script>


</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frm_definicion_archivos" id="frm_definicion_archivos" action="" method="post" style='width:100%;height:100%;overflow:hidden'>
<div id="divMenuArchivosDefSeleccion" style="margin: 0px; padding: 0px;"></div>
<script language="javascript" type="text/javascript">
    var vMenuArchivosDefSeleccion = new tMenu('divMenuArchivosDefSeleccion', 'vMenuArchivosDefSeleccion');
    vMenuArchivosDefSeleccion.loadImage("nuevo", "/fw/image/icons/nueva.png")
    Menus["vMenuArchivosDefSeleccion"] = vMenuArchivosDefSeleccion
    Menus["vMenuArchivosDefSeleccion"].alineacion = 'centro';
    Menus["vMenuArchivosDefSeleccion"].estilo = 'A';
    Menus["vMenuArchivosDefSeleccion"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
    Menus["vMenuArchivosDefSeleccion"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Tipos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_tipo_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
    Menus["vMenuArchivosDefSeleccion"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Perfiles</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_perfil_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
    Menus["vMenuArchivosDefSeleccion"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Colores</Desc><Acciones><Ejecutar Tipo='script'><Codigo>img_depthcolor_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
    Menus["vMenuArchivosDefSeleccion"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Grupo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>img_grupo_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
    Menus["vMenuArchivosDefSeleccion"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva Def. de Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_abm(0,'N')</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuArchivosDefSeleccion.MostrarMenu()
</script>
<table class="tb1" id="tb_definicion_archivos">
     <tr>
       <td style="width:70%">
          <table class="tb1">
            <tr class="tbLabel">
                <td style='width:20%; text-align:center;'>ID</td>
                <td style='width:80%; text-align:center;'>Descripción</td>
                <td style='width:80%; text-align:center;'>Vigente</td>
            </tr>
            <tr>                
                <td style='width:20%; padding: 0;'><%= nvFW.nvCampo_def.get_html_input("nro_def_archivos3", enDB:=False, nro_campo_tipo:=100)%></td>
                <script type="text/javascript">
                    $('nro_def_archivos3').addEventListener('keydown', function (e) {
                        if (e.key === 'Enter') {
                            buscar_archivos_def()
                        }
                    })
                </script>
                <td style='width:80%; padding: 0;'><%= nvFW.nvCampo_def.get_html_input("desc_def_archivos3", enDB:=False, nro_campo_tipo:=104)%></td>
                <script type="text/javascript">
                    $('desc_def_archivos3').addEventListener('keydown', function (e) {
                        if (e.key === 'Enter') {
                            buscar_archivos_def()
                        }
                    })
                </script>
                <td>
                    <select id="vigente">
                        <option value=""></option>
                        <option value="si">Si</option>
                        <option value="no">No</option>
                    </select>
                </td>
            </tr>
          </table>
       </td>
       <td style="width:15%"><div id="divBuscar"></div></td>
       <td style="width:15%"><div id="divExportar" style="width:100%"></div></td>
     </tr> 
</table>
<iframe name="iframe_definicion_archivos" id="iframe_definicion_archivos" style='width: 100%; height: 100%; overflow: auto; border:none; max-height:1005px' frameborder="0" src="/FW/enBlanco.htm"></iframe>
</form>
</body>
</html>