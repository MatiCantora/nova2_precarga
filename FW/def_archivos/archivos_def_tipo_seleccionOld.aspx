<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "N"
    End If
    
    Dim filtroTipos = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_tipo' PageSize='14' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden>nro_archivo_def_tipo</orden><filtro></filtro></select></criterio>")
    Dim filtroDetalle = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_detalle'><campos>COUNT(*) as cant_detalles</campos><filtro><nro_archivo_def_tipo type='igual'>%nro_archivo_def_tipo%</nro_archivo_def_tipo></filtro></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Tipos de Archivos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var filtroTipos = '<%= filtroTipos %>'
        var filtroDetalle = '<%= filtroDetalle %>'

    var vButtonItems = {}

    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "Buscar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return buscar_archivos_def_tipo()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar","/fw/image/icons/buscar.png")

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuArchivosDefTipoSeleccion_h = $('divMenuArchivosDefTipoSeleccion').getHeight()
            tb_definicion_tipo_archivos_h = $('tb_definicion_tipo_archivos').getHeight()

            $('iframe_definicion_tipo_archivos').setStyle({ 'height': body_height - divMenuArchivosDefTipoSeleccion_h - tb_definicion_tipo_archivos_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() 
    {
        // mostramos los botones creados
        vListButtons.MostrarListButton()
        window_onresize()
    }

    function buscar_archivos_def_tipo()
    {
        var nro_archivo_def_tipo = campos_defs.get_value('nro_def_tipos3')
        var filtro = ''

        if (nro_archivo_def_tipo != '')
            filtro = "<nro_archivo_def_tipo type='igual'>" + nro_archivo_def_tipo + "</nro_archivo_def_tipo>"

        var filtroXML = filtroTipos
        var filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"

        nvFW.exportarReporte({
            filtroXML: filtroXML,
            filtroWhere: filtroWhere,
            path_xsl: 'report\\def_archivos\\verArchivos_def_tipo\\HTML_verArchivos_def_tipo.xsl',
            formTarget: 'iframe_definicion_tipo_archivos',
            nvFW_mantener_origen: true,
            id_exp_origen: 0,
            bloq_contenedor: $('iframe_definicion_tipo_archivos'),
            cls_contenedor: 'iframe_definicion_tipo_archivos'
         })
            
    }

    //Elimina un Tipo de Archivos
    function eliminar_archivos_def_tipo(nro_archivo_def_tipo) {

        //Para poder eliminar un tipo de archivos, no deben existir detalles de definición que usen dicho tipo
        var rs = new tRS()

        var params = "<criterio><params nro_archivo_def_tipo='" + nro_archivo_def_tipo + "'/></criterio>"
        rs.open(filtroDetalle, '', '', '', params)       

        if (!rs.eof()) {
            if (rs.getdata('cant_detalles') > 0) {
                alert('No se puede eliminar el Tipo de Archivo seleccionado. Existen "Archivos Def Detalles" que lo utilizan.')
                return
            } else {
                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<archivos_def_tipo modo='B' nro_archivo_def_tipo='-" + nro_archivo_def_tipo + "'>"
                xmldato += "</archivos_def_tipo>"

                Dialog.confirm('¿Desea eliminar el Tipo de Archivos seleccionado.?', { width: 300, className: "alphacube",
                    onOk: function (win) {
                        nvFW.error_ajax_request('/fw/def_archivos/archivos_def_tipo_ABM.aspx', {
                            parameters: { modo: 'B', strXML: escape(xmldato) },
                            onSuccess: function (err, transport) {
                                if (err.numError == 0) {
                                    buscar_archivos_def_tipo()
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
                    onCancel: function (win) { win.close() }
                })
            
            }
        }
    }

    //ABM Tipos de Archivos Def
    var win_archivos_def_tipo_abm
    function archivos_def_tipo_abm(nro_archivo_def_tipo) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_tipo_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_tipo_ABM.aspx?nro_archivo_def_tipo=' + nro_archivo_def_tipo,
            title: '<b>ABM Tipo de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 700,
            height: 200,
            onClose: function () {
                if (win_archivos_def_tipo_abm.options.userData.nro_archivo_def_tipo != -1)
                    buscar_archivos_def_tipo()
            }
        });

        win_archivos_def_tipo_abm.options.userData = { nro_archivo_def_tipo: nro_archivo_def_tipo }
        win_archivos_def_tipo_abm.showCenter()
    }
    
    </script>
</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frm_definicion_tipo_archivos" id="frm_definicion_tipo_archivos" action="" method="post" style='width:100%;height:100%;overflow:hidden'>
<div id="divMenuArchivosDefTipoSeleccion" style="margin: 0px; padding: 0px;"></div>
<script language="javascript" type="text/javascript">
    var vMenuArchivosDefTipoSeleccion = new tMenu('divMenuArchivosDefTipoSeleccion', 'vMenuArchivosDefTipoSeleccion');
    vMenuArchivosDefTipoSeleccion.loadImage("nuevo","/fw/image/icons/nueva.png")
    Menus["vMenuArchivosDefTipoSeleccion"] = vMenuArchivosDefTipoSeleccion
    Menus["vMenuArchivosDefTipoSeleccion"].alineacion = 'centro';
    Menus["vMenuArchivosDefTipoSeleccion"].estilo = 'A';
    Menus["vMenuArchivosDefTipoSeleccion"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
    Menus["vMenuArchivosDefTipoSeleccion"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_tipo_abm(-1)</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuArchivosDefTipoSeleccion.MostrarMenu()
</script>
<table width="100%" id="tb_definicion_tipo_archivos">
     <tr>
       <td style="width:80%">
          <table class="tb1" width="100%">
            <tr class="tbLabel">
                <td style='width:100%'><b>Tipos de Archivos</b></td>
            </tr>
            <tr>                
                <td><%= nvFW.nvCampo_def.get_html_input("nro_def_tipos3")%></td>
            </tr>
          </table>
       </td>
       <td style="width:20%"><div id="divBuscar"></div></td>
     </tr> 
</table>
<iframe name="iframe_definicion_tipo_archivos" id="iframe_definicion_tipo_archivos" style='width: 100%; height: 100%; overflow: auto; border:none' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>