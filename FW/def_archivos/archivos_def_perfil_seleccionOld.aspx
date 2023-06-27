<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "N"
    End If
    
    Dim filtroPerfiles = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_def_perfil' PageSize='14' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden>id</orden><filtro></filtro></select></criterio>")
    Dim filtroDetalle = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_detalle'><campos>COUNT(*) as cant_detalles</campos><filtro><perfil type='igual'>%id%</perfil></filtro></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Perfiles de Archivos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var filtroPerfiles = '<%= filtroPerfiles %>'
        var filtroDetalle = '<%= filtroDetalle %>'

    var vButtonItems = {}

    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "Buscar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return buscar_archivos_def_perfil()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar","/fw/image/icons/buscar.png")

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuArchivosDefPerfilSeleccion_h = $('divMenuArchivosDefPerfilSeleccion').getHeight()
            tb_definicion_perfil_archivos_h = $('tb_definicion_perfil_archivos').getHeight()

            $('iframe_definicion_perfil_archivos').setStyle({ 'height': body_height - divMenuArchivosDefPerfilSeleccion_h - tb_definicion_perfil_archivos_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() 
    {
        // mostramos los botones creados
        vListButtons.MostrarListButton()
        window_onresize()
    }

    function buscar_archivos_def_perfil()
    {
        var nro_def_perfil = campos_defs.get_value('nro_def_perfil')
        var filtro = ''

        if (nro_def_perfil != '')
            filtro = "<id type='igual'>" + nro_def_perfil + "</id>"

        var filtroXML = filtroPerfiles
        var filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"
        
        nvFW.exportarReporte({
            filtroXML: filtroXML,
            filtroWhere: filtroWhere,
            path_xsl: 'report\\def_archivos\\verArchivos_def_perfil\\HTML_verArchivos_def_perfil.xsl',
            formTarget: 'iframe_definicion_perfil_archivos',
            nvFW_mantener_origen: true,
            id_exp_origen: 0,
            bloq_contenedor: $('iframe_definicion_perfil_archivos'),
            cls_contenedor: 'iframe_definicion_perfil_archivos'
         })
            
    }

    //Elimina un Perfil de Archivos
    function eliminar_archivos_def_perfil(id) {

        //Para poder eliminar un perfil de archivos, no deben existir detalles de definición que usen dicho perfil
        var rs = new tRS()

        var params = "<criterio><params id='" + id + "'/></criterio>"
        rs.open(filtroDetalle, '', '', '', params)        

        if (!rs.eof()) {
            if (rs.getdata('cant_detalles') > 0) {
                alert('No se puede eliminar el Perfil de Archivo seleccionado. Existen "Archivos Def Detalles" que lo utilizan.')
                return
            } else {
                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<archivos_def_perfil modo='B' id='-" + id + "'>"
                xmldato += "</archivos_def_perfil>"

                Dialog.confirm('¿Desea eliminar el Perfil de Archivos seleccionado.?', { width: 300, className: "alphacube",
                    onOk: function (win) {
                        nvFW.error_ajax_request('/fw/def_archivos/archivos_def_perfil_ABM.aspx', {
                            parameters: { modo: 'B', strXML: escape(xmldato) },
                            onSuccess: function (err, transport) {
                                if (err.numError == 0) {
                                    buscar_archivos_def_perfil()
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

    //ABM Perfil Archivos Def
    var win_archivos_def_perfil_abm
    function archivos_def_perfil_abm(nro_archivo_def_perfil) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_archivos_def_perfil_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/archivos_def_perfil_ABM.aspx?nro_archivo_def_perfil=' + nro_archivo_def_perfil,
            title: '<b>ABM Perfil de Archivos</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 700,
            height: 200,
            onClose: function () {
                if (win_archivos_def_perfil_abm.options.userData.nro_archivo_def_perfil != 0)
                    buscar_archivos_def_perfil()
            }
        });

        win_archivos_def_perfil_abm.options.userData = { nro_archivo_def_perfil: nro_archivo_def_perfil }
        win_archivos_def_perfil_abm.showCenter()
    }
    
    </script>
</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frm_definicion_perfil_archivos" id="frm_definicion_perfil_archivos" action="" method="post" style='width:100%;height:100%;overflow:hidden'>
<div id="divMenuArchivosDefPerfilSeleccion" style="margin: 0px; padding: 0px;"></div>
<script language="javascript" type="text/javascript">
    var vMenuArchivosDefPerfilSeleccion = new tMenu('divMenuArchivosDefPerfilSeleccion', 'vMenuArchivosDefPerfilSeleccion');
    vMenuArchivosDefPerfilSeleccion.loadImage("nuevo","/fw/image/icons/nueva.png")
    Menus["vMenuArchivosDefPerfilSeleccion"] = vMenuArchivosDefPerfilSeleccion
    Menus["vMenuArchivosDefPerfilSeleccion"].alineacion = 'centro';
    Menus["vMenuArchivosDefPerfilSeleccion"].estilo = 'A';
    Menus["vMenuArchivosDefPerfilSeleccion"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
    Menus["vMenuArchivosDefPerfilSeleccion"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_perfil_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuArchivosDefPerfilSeleccion.MostrarMenu()
</script>
<table width="100%" id="tb_definicion_perfil_archivos">
     <tr>
       <td style="width:80%">
          <table class="tb1" width="100%">
            <tr class="tbLabel">
                <td style='width:100%'><b>Perfiles de Archivos</b></td>
            </tr>
            <tr>                
                <td><%= nvFW.nvCampo_def.get_html_input("nro_def_perfil")%></td>
            </tr>
          </table>
       </td>
       <td style="width:20%"><div id="divBuscar"></div></td>
     </tr> 
</table>
<iframe name="iframe_definicion_perfil_archivos" id="iframe_definicion_perfil_archivos" style='width: 100%; height: 100%; overflow: auto; border:none' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>