<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageFW" %>

<%
 
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Seleccionar Calle</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
     <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Buscar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.imagenes = Imagenes
        
        var win = nvFW.getMyWindow()
        var parametros_calle
        
        function window_onload() { 
            
            vListButtons.MostrarListButton()
            window_onresize()

            campos_defs.add('cod_prov', { despliega: 'abajo',
                enDB: false,
                target: 'td_cod_prov',
                nro_campo_tipo: 1,
                filtroXML: "<criterio><select vista='Provincia'><campos>cod_prov as id, provincia as [campo]</campos><filtro><nro_nacion type='igual'>1</nro_nacion></filtro><orden>[campo]</orden></select></criterio>",
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                depende_de: null,
                depende_de_campo: null
            })

            parametros_calle = win.options.userData.parametros_calle
            $('calle').value = parametros_calle['calle']
            $('localidad').value = parametros_calle['localidad']
            campos_defs.set_value('cod_prov', parametros_calle['cod_prov'])
            //cod_prov_ant = parametros_CPA['cod_prov']
            //cod_veraz_prov = parametros_CPA['cod_veraz_prov']

            if ($('calle').value != '' && $('localidad').value != '' && campos_defs.get_value('cod_prov') != '')
                Buscar()
            
        }



        function Buscar() {
            
            var filtro = ""
            
            var calle = $('calle').value
           // var postal_real = $('postal_real').value
            var localidad = $('localidad').value 
            var cod_prov = campos_defs.get_value('cod_prov')

            if (localidad == '' || cod_prov == '') {
                alert('Debe ingresar Localidad y Provincia')
                return
            }

            var cod_veraz_prov = buscar_cod_veraz(cod_prov)

            if (calle != '') {
                filtro += "<OR><nombrecalle type='like'>%" + calle + "%</nombrecalle><nombrealt type='like'>%" + calle + "%</nombrealt><barrio type='like'>%" + calle + "%</barrio></OR>"
            }
            filtro += "<OR><localidad type='like'>%" + localidad + "%</localidad><partido type='like'>%" + localidad + "%</partido></OR>"
            filtro += "<codprov type='igual'>'" + cod_veraz_prov + "'</codprov>"
            //filtro += "<postal_real type='like'>%" + postal_real + "%</postal_real>"
            
            if (filtro != ""){
                   nvFW.exportarReporte({
                       filtroXML: "<criterio><select vista='verCPA_calles' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>*, " + cod_prov + " as cod_prov</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>",
                        path_xsl: 'report\\verSelCPA_calle\\HTML_SelCPA_calle.xsl', //xsl_name
                        formTarget: 'iframe_calles',
                        nvFW_mantener_origen: true,
                        bloq_contenedor: $('iframe_calles'),
                        cls_contenedor: 'iframe_calles'
                    })

                }
                else {
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

        function selCalle(nombrecalle, barrio, nombre_alt, localidad, cod_prov, cod_veraz_prov, codcalle) {
            
            var descripcion = ''

            if (nombrecalle != 'TAB')
                descripcion = nombrecalle
            else if (barrio != 'TAB')
                descripcion = barrio
            else descripcion = nombre_alt            

            var res = new Array()
            res["calle"] = descripcion
            res["localidad"] = localidad
            res["cod_prov"] = cod_prov
            res["cod_veraz_prov"] = cod_veraz_prov
            res["codcalle"] = codcalle
                        
            win.options.userData = {res: res}
            win.close();
       
        }


        function buscar_onkeypress(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which
            if (key == 13)
                Buscar()
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


        function buscar_cod_veraz(cod_prov) {

            var rs = new tRS();
            rs.open("<criterio><select vista='Provincia'><campos>cod_veraz</campos><orden></orden><filtro><cod_prov type='igual'>" + cod_prov + "</cod_prov></filtro></select></criterio>")
            if (!rs.eof()) {
                return rs.getdata('cod_veraz')
            }
            else
                return ''
        }



        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                cab_height = $('tbFiltro').getHeight()
                $('iframe_calles').setStyle({ 'height': body_height - cab_height - dif })
            }
            catch (e) { }
        }
 
    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
   <table style="width: 100%" id="tbFiltro">
        <tr>
            <td style="width: 86%">
                <table class="tb1" >
                    <tr class="tbLabel">
                        <td style="width: 30%">Calle</td>
                        <td style="width: 30%">Localidad</td>
                        <td style="width: 30%">Provincia</td>
                        <!--<td rowspan='2' style="width: 20%; text-align:center"><div id="divBuscar" /></td>-->
                    </tr>
                    <tr>
                        <td><input style="width: 100%; text-align: left" type="text" id="calle" name="calle" value="" onkeypress="buscar_onkeypress(event)" /></td>
                        <td><input style="width: 100%; text-align: left" type="text" name="localidad" id="localidad" value="" onkeypress="buscar_onkeypress(event)" /></td>
                        <td id="td_cod_prov"></td>
                    </tr>
                </table>
            </td>
            <td>
                <div id="divBuscar" />
            </td>
        </tr>
    </table>
    <iframe name="iframe_calles" id="iframe_calles" style="width: 100%; height: 100%; overflow: auto;" frameborder="0" src=""></iframe>
    <!--<div style="width: 100%; height: 100%; overflow: auto" id="divLocalidades">
    </div>-->
</body>
</html>
