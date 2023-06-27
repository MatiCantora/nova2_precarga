<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consulta Localidad</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript">

        var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Buscar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/fw/image/security/buscar.png')

        var win = nvFW.getMyWindow()

        function Buscar() {
            var filtro = ""
            //$('divLocalidades').innerHTML = ""

            var postal_real = $('postal_real').value
            var cadena = $('strLocalidad').value 
            
            if (cadena != "")
                filtro += "<localidad type='like'>%" + cadena + "%</localidad>"
                
            if (postal_real != "")
                filtro += "<postal_real type='like'>%" + postal_real + "%</postal_real>"
            
            if (filtro != ""){
                   nvFW.exportarReporte({
                        filtroXML: "<criterio><select vista='verlocalidad' PageSize='11' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>",
                        path_xsl: 'report\\funciones\\verLocalidad\\HTML_verlocalidad.xsl', 
                        formTarget: 'iframe_localidades',
                        nvFW_mantener_origen: true,
                        bloq_contenedor: $('iframe_localidades'),
                        cls_contenedor: 'iframe_localidades'
                    })

           }else{
                alert('Por favor, seleccione un criterio de búsqueda.')
                return
           }
        }

        function icons_seleccionar(e) {
            srcElement = Event.element(e)
            srcElement.src = "../../meridiano/image/icons/ok_seleccionado.png"
        }

        function icons_no_seleccionar(e) {
            srcElement = Event.element(e)
            srcElement.src = "../../meridiano/image/icons/ok_no_seleccionado.png"
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
            
            //parent.top.localidad.returnValue = res
            //parent.top.localidad.close()

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
            var postal = 0
            //var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_localidad = window.top.nvFW.createWindow({ className: 'alphacube',
            //win_localidad = new Window({ className: 'alphacube',
                url: '../../<%=Session.Contents("app_path_rel")%>/localidad_abm.asp',
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
           //win_localidad.showCenter(true)
        }
        
        function actualizar() {
            var params = ''
            /*if (win_localidad.returnValue != undefined) {
                params = win_localidad.returnValue
            }*/
            if (win_localidad.options.userData.params)
                params = win_localidad.options.userData.params
            if ((params['postal_real'] != undefined) || (params['localidad'] != undefined)) {
                $('postal_real').value = params['postal_real']
                $('strLocalidad').value = params['localidad']
                Buscar()
            }
        }
        
        

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                cab_height = $('tbFiltro').getHeight()
                divMenu_height = $('divMenuLocalidadesSeleccion').getHeight() 
                $('iframe_localidades').setStyle({ 'height': body_height - divMenu_height - cab_height - dif })
            }
            catch (e) { }
        }
 
    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuLocalidadesSeleccion"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuLocalidadesSeleccion = new tMenu('divMenuLocalidadesSeleccion', 'vMenuLocalidadesSeleccion');
        Menus["vMenuLocalidadesSeleccion"] = vMenuLocalidadesSeleccion
        Menus["vMenuLocalidadesSeleccion"].alineacion = 'centro';
        Menus["vMenuLocalidadesSeleccion"].estilo = 'A';
        Menus["vMenuLocalidadesSeleccion"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuLocalidadesSeleccion"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_localidad()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuLocalidadesSeleccion"].loadImage("nueva", '/fw/image/security/nueva.png')
        vMenuLocalidadesSeleccion.MostrarMenu()
    </script>

    <table class="tb1" id="tbFiltro">
        <tr class="tbLabel">
            <td style="width: 20%">Código Postal</td>
            <td style="width: 50%">Localidad</td>
             <td rowspan='2' style="width: 20%; text-align:center"><div id="divBuscar" /></td>
        </tr>
        <tr>
            <td>
                <input style="width: 100%; text-align: left" type="text" id="postal_real" name="postal_real"
                    value="" onkeypress="buscar_onkeypress(event)" />
            </td>
            <td>
                <input style="width: 100%; text-align: left" type="text" name="strLocalidad" id="strLocalidad"
                    value="" onkeypress="buscar_onkeypress(event)" />
            </td>
           
        </tr>
    </table>
    <iframe name="iframe_localidades" id="iframe_localidades" style="width: 100%; height: 100%; overflow: auto;" frameborder="0" src=""></iframe>
    <!--<div style="width: 100%; height: 100%; overflow: auto" id="divLocalidades">
    </div>-->
</body>
</html>
