<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "N"
    End If

    'Me.contents("filtroColores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_IMG_depthcolor' PageSize='14' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden>nro_depthcolor</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroColores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_IMG_depthcolor' ><campos>*</campos><orden>nro_depthcolor</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroPerfil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_perfil'><campos>COUNT(*) as cant_perfiles</campos><filtro><tipo_color type='igual'>%nro_depthcolor%</tipo_color></filtro></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Colores</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">

    var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

    var filtroColores = nvFW.pageContents.filtroColores
    var filtroPerfil = nvFW.pageContents.filtroPerfil

    var vButtonItems = {}

    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "Buscar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return buscar_colores()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar","/fw/image/icons/buscar.png")

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuColores_h = $('divMenuColores').getHeight()
            tb_colores_h = $('tb_colores').getHeight()

            $('iframe_colores').setStyle({ 'height': body_height - divMenuColores_h - tb_colores_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() 
    {
        // mostramos los botones creados
        vListButtons.MostrarListButton()
        window_onresize()
    }

    function buscar_colores()
    {
        var nro_depthcolor = campos_defs.get_value('nro_depthcolor')
        var desc_depthcolor = campos_defs.get_value('desc_depthcolor')
        var filtro = ''

        if (nro_depthcolor != '') {
            filtro = "<nro_depthcolor type='igual'>" + nro_depthcolor + "</nro_depthcolor>"
        } else if (desc_depthcolor != '') {
            filtro = "<descripcion type='like'>%" + desc_depthcolor + "%</descripcion>"
        }

        var filtroXML = filtroColores
        var filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"
        
        nvFW.exportarReporte({
            filtroXML: filtroXML,
            filtroWhere: filtroWhere,
            path_xsl: 'report\\def_archivos\\verIMG_depthcolor\\HTML_verIMG_depthcolor.xsl',
            formTarget: 'iframe_colores',
            nvFW_mantener_origen: true,
            id_exp_origen: 0,
            bloq_contenedor: $('iframe_colores'),
            cls_contenedor: 'iframe_colores'
        })
            
    }

    //Elimina un Color
    function eliminar_img_depthcolor(nro_depthcolor) {

        //Para poder eliminar un color, no deben existir perfiles de escaneo que usen dicho color
        var rs = new tRS()

        var params = "<criterio><params nro_depthcolor='" + nro_depthcolor + "'/></criterio>"
        rs.open(filtroPerfil, '', '', '', params)
        
        if (!rs.eof()) {
            if (rs.getdata('cant_perfiles') > 0) {
                alert('No se puede eliminar el Color seleccionado. Existen "Perfiles de Escaneo" que lo utilizan.')
                return
            } else {
                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<img_depthcolor modo='B' nro_depthcolor='-" + nro_depthcolor + "'>"
                xmldato += "</img_depthcolor>"

                Dialog.confirm('¿Desea eliminar el Color seleccionado.?', { width: 300, className: "alphacube",
                    onOk: function (win) {
                        nvFW.error_ajax_request('/fw/def_archivos/img_depthcolor_ABM.aspx', {
                            parameters: { modo: 'B', strXML: escape(xmldato) },
                            onSuccess: function (err, transport) {
                                if (err.numError == 0) {
                                    buscar_colores()
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

    //ABM Colores
    var win_img_depthcolor_abm
    function img_depthcolor_abm(nro_depthcolor) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_img_depthcolor_abm = w.createWindow({
            className: 'alphacube',
            url: '/fw/def_archivos/img_depthcolor_ABM.aspx?nro_depthcolor=' + nro_depthcolor,
            title: '<b>ABM Color</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            resizable: false,
            width: 700,
            height: 200,
            onClose: function () {
                if (win_img_depthcolor_abm.options.userData.nro_depthcolor != 0)
                    buscar_colores()
            }
        });

        win_img_depthcolor_abm.options.userData = { nro_depthcolor: nro_depthcolor }
        win_img_depthcolor_abm.showCenter()
    }
    
    </script>
</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frm_colores" id="frm_colores" action="" method="post" style='width:100%;height:100%;overflow:hidden'>
<div id="divMenuColores" style="margin: 0px; padding: 0px;"></div>
<script language="javascript" type="text/javascript">
    var vMenuColores = new tMenu('divMenuColores', 'vMenuColores');
    vMenuColores.loadImage("nuevo","/fw/image/icons/nueva.png")
    Menus["vMenuColores"] = vMenuColores
    Menus["vMenuColores"].alineacion = 'centro';
    Menus["vMenuColores"].estilo = 'A';
    Menus["vMenuColores"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
    Menus["vMenuColores"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>img_depthcolor_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuColores.MostrarMenu()
</script>
<table class="tb1" id="tb_colores">
     <tr>
       <td style="width:80%">
          <table class="tb1">
            <tr class="tbLabel">
                <td style='width:20%; text-align:center;'>ID</td>
                <td style='width:80%; text-align:center;'>Descripción</td>
            </tr>
            <tr>                
                <td style='width:20%; padding:0'><%= nvFW.nvCampo_def.get_html_input("nro_depthcolor", enDB:=False, nro_campo_tipo:=100) %></td>
                <script type="text/javascript">
                    $('nro_depthcolor').addEventListener('keydown', function (e) {
                        if (e.key === 'Enter') {
                            buscar_colores()
                        }
                    })
                </script>
                <td style='width:80%; padding:0'><%= nvFW.nvCampo_def.get_html_input("desc_depthcolor", enDB:=False, nro_campo_tipo:=104) %></td>
                <script type="text/javascript">
                    $('desc_depthcolor').addEventListener('keydown', function (e) {
                        if (e.key === 'Enter') {
                            buscar_colores()
                        }
                    })
                </script>
            </tr>
          </table>
       </td>
       <td style="width:20%"><div id="divBuscar"></div></td>
     </tr> 
</table>
<iframe name="iframe_colores" id="iframe_colores" style='width: 100%; height: 100%; overflow: auto; border:none; max-height:700px' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>