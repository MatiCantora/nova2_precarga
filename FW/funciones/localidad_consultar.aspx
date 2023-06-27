<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Me.contents("filtroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verlocalidad' PageSize='11' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    
    Me.addPermisoGrupo("permisos_localidades")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consulta Localidad</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <%= Me.getHeadInit()%>
    <script type="text/javascript">
    
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Buscar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/fw/image/icons/buscar.png')

        var win = nvFW.getMyWindow()

        function Buscar() {
            var filtro = ""
            var postal_real = $('postal_real').value
            var cadena = $('strLocalidad').value 
            
            if (cadena != "")
                filtro += "<localidad type='like'>%" + cadena + "%</localidad>"
                
            if (postal_real != "")
                filtro += "<postal_real type='like'>%" + postal_real + "%</postal_real>"
            
            if (filtro != ""){
                   nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtroBuscar,
                        filtroWhere: "<criterio><select ><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro><grupo></grupo></select></criterio>",
                        path_xsl: 'report\\funciones\\verLocalidad\\HTML_verlocalidad.xsl', 
                        formTarget: 'iframe_localidades',
                        nvFW_mantener_origen: true,
                        id_exp_origen: 0,
                        bloq_contenedor: $('iframe_localidades'),
                        cls_contenedor: 'iframe_localidades',
                        cls_contenedor_msg: ' ',
                        bloq_msg: 'Buscando...'
                    })

           }else{
                alert('Por favor, seleccione un criterio de búsqueda.')
                return
           }

    }
        function selLocalidad(postal, desc, car_tel, provincia, localidad, cod_prov, cod_veraz_prov) {
                        
            var res = {}
            res["postal"] = postal
            res["desc"] = desc
            res["car_tel"] = car_tel
            res["provincia"] = provincia
            res["localidad"] = localidad
            res["cod_prov"] = cod_prov
            res["cod_veraz_prov"] = cod_veraz_prov
            
            win.options.userData = {res: res}
            win.close();
            
        }

        function buscar_onkeypress(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which
            if (key == 13)
                Buscar()
        }
        
        function window_onload() {
            vListButtons.MostrarListButton()
            window_onresize()
            $('postal_real').focus()
        }
                
        var win_localidad
        function nueva_localidad() {
            if(!nvFW.tienePermiso("permisos_localidades", 1)) {
                alert("No tiene permisos para acceder a esta opción", { title: "Permisos insuficientes", height: 70, width: 300 })
                return     
            }
            var postal = 0
            win_localidad = window.top.nvFW.createWindow({
                url: '/FW/funciones/localidad_abm.aspx',
                title: '<b>Nueva Localidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                width: 500,
                height: 310,
                resizable: false,
                onClose: actualizar
            });
            win_localidad.options.userData = { params: '' }
            win_localidad.showCenter(true)
        }
        
        function actualizar() {
            var params = ''
            if (win_localidad.options.userData.params)
                params = win_localidad.options.userData.params
            if ((params['postal_real'] != undefined) || (params['localidad'] != undefined)) {
                $('postal_real').value = params['postal_real']
                $('strLocalidad').value = params['localidad']
                Buscar()
            }
        }


        var dif = Prototype.Browser.IE ? 5 : 0

        function window_onresize()
        {
            try {
                var body_height    = $$('body')[0].getHeight()
                var cab_height     = $('tbFiltro').getHeight()
                var divMenu_height = $('divMenuLocalidadesSeleccion').getHeight()

                $('iframe_localidades').setStyle({ 'height': body_height - divMenu_height - cab_height - dif + 'px' })
            }
            catch(e) {}
        }
    </script>
</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden;">
    <div id="divMenuLocalidadesSeleccion"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuLocalidadesSeleccion = new tMenu('divMenuLocalidadesSeleccion', 'vMenuLocalidadesSeleccion');
        Menus["vMenuLocalidadesSeleccion"] = vMenuLocalidadesSeleccion
        Menus["vMenuLocalidadesSeleccion"].alineacion = 'centro';
        Menus["vMenuLocalidadesSeleccion"].estilo = 'A';
        Menus["vMenuLocalidadesSeleccion"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuLocalidadesSeleccion"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_localidad()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuLocalidadesSeleccion"].loadImage("nueva", '/fw/image/icons/nueva.png')
        vMenuLocalidadesSeleccion.MostrarMenu()
    </script>

    <table class="tb1" id="tbFiltro" style="overflow:hidden">
        <tr class="tbLabel">
            <td style="width: 20%">Código Postal</td>
            <td style="width: 50%">Localidad</td>
             <td></td>
        </tr>
        <tr>
            <td>
                <input style="width: 100%; text-align: left" type="text" id="postal_real" name="postal_real" value="" onkeypress="buscar_onkeypress(event)" />
            </td>
            <td>
                <input style="width: 100%; text-align: left" type="text" name="strLocalidad" id="strLocalidad" value="" onkeypress="buscar_onkeypress(event)" />
            </td>
            <td style="width: 20%; text-align:center"><div id="divBuscar" style="overflow:hidden"/></td>
        </tr>
    </table>
    <iframe name="iframe_localidades" id="iframe_localidades" style="width: 100%; height: 100%; overflow:hidden;" frameborder="0" src=""></iframe>
</body>
</html>
