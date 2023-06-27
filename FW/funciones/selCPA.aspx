<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageFW" %>

<%

    Me.contents("filtro_provincia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Provincia'><campos>cod_prov as id, provincia as [campo]</campos><filtro><nro_nacion type='igual'>1</nro_nacion></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_sp_cpa_domicilio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_cpa_domicilio' CommantTimeOut='1500' PageSize='10' AbsolutePage='1' cacheControl='Session'><parametros></parametros></procedure></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Seleccionar CPA</title>
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
        vListButtons.loadImage("buscar", "/fw/image/icons/buscar.png");

        var win = nvFW.getMyWindow()
        var parametros_CPA
        var cod_veraz_prov
        var cod_prov_ant
        var codcalle
        var calle_ant
        var loc_ant
       
        function window_onload() { 
            vListButtons.MostrarListButton()
            window_onresize()

            campos_defs.add('cod_prov', { despliega: 'abajo',
                enDB: false,
                target: 'td_cod_prov',
                nro_campo_tipo: 1,
                filtroXML:  nvFW.pageContents.filtro_provincia,
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                depende_de: null,
                depende_de_campo: null
            })

            parametros_CPA = win.options.userData.parametros_CPA
            $('calle').value = parametros_CPA['calle']
            calle_ant = parametros_CPA['calle']
            $('numero').value = parametros_CPA['numero']
            $('localidad').value = parametros_CPA['localidad']
            loc_ant = parametros_CPA['localidad']
            campos_defs.set_value('cod_prov', parametros_CPA['cod_prov'])
            cod_prov_ant = parametros_CPA['cod_prov']
            cod_veraz_prov = parametros_CPA['cod_veraz_prov']
            $('check_numero').checked = true
            codcalle = 0

            if (($('calle').value != '') && ($('numero').value != '') && ($('localidad').value != '') && (cod_veraz_prov != ''))
            { Buscar() }
            
        }


        function Buscar() { 
            var parametros = ""
            //$('divLocalidades').innerHTML = ""

            var calle = $('calle').value
            var numero = $('numero').value
            var localidad = $('localidad').value
            var cod_prov = campos_defs.get_value('cod_prov')

            if (calle_ant.toUpperCase() != calle.toUpperCase() || loc_ant.toUpperCase() != localidad.toUpperCase() || cod_prov_ant != cod_prov)
                codcalle = 0

            if (numero == ''){
                numero = 0
                $('numero').value = 0
            }

            if (!$('check_numero').checked) { 
                numero=0
            }

            if ((cod_veraz_prov == '') && (cod_prov != '')) {
                cod_veraz_prov = buscar_cod_veraz(cod_prov)
            }

            if (cod_prov_ant != cod_prov) {
                cod_veraz_prov = buscar_cod_veraz(cod_prov)
                cod_prov_ant = cod_prov
            }
            
            if ((calle == '') || (localidad == '') || (cod_veraz_prov == '')) {
                alert('ingrese todos los campos de busqueda')
                return
            }

            parametros += "<codprov DataType='varchar'>S</codprov>"

            parametros += "<localidad DataType='varchar'>" + localidad + "</localidad>"

            parametros += "<calle DataType='varchar'>" + calle + "</calle>"

            parametros += "<numero DataType='int'>" + numero + "</numero>"

            parametros += "<codcalle DataType='int'>" + codcalle + "</codcalle>"


            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_sp_cpa_domicilio,
                filtroWhere: "<criterio><procedure><parametros>" + parametros +"</parametros></procedure></criterio>",
                path_xsl: 'report\\funciones\\cpa\\HTML_sel_CPA.xsl', //xsl_name
                formTarget: 'iframe_CPA',
                nvFW_mantener_origen: true,
                bloq_contenedor: $('iframe_CPA'),
                cls_contenedor: 'iframe_CPA'
            })

        }
        

        function icons_seleccionar(e) {
            srcElement = Event.element(e)
            srcElement.src = "/fw/image/icons/ok_seleccionado.png"
        }

        function icons_no_seleccionar(e) {
            srcElement = Event.element(e)
            srcElement.src = "/fw/image/icons/ok_no_seleccionado.png"
        }

        function selCPA(CPA, codprov, provincia, localidad) {
            
            var res = new Array()
            res["CPA"] = CPA
            res["cod_veraz_prov"] = codprov
            res["provincia"] = provincia
            res["localidad"] = localidad
            res["calle"] = $('calle').value
            res["cod_prov"] = campos_defs.get_value('cod_prov')
            res["numero"] = $('numero').value
            
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

        function buscar_cod_veraz(cod_prov) {

            var rs = new tRS();

            rs.open(nvFW.pageContents.nvFW.pageContents.filtro_provincia, "", "<criterio><select><filtro><cod_prov type='igual'>" + cod_prov + "</cod_prov></filtro></select></criterio>","","")
            if (!rs.eof()) {
                return rs.getdata('cod_veraz')
            }
            else
             return ''
        }

        var win_CPA_calle
        function selCPA_Calle() { 

            var parametros_calle = new Array()
            parametros_calle['calle'] = $('calle').value
            parametros_calle['localidad'] = $('localidad').value
            parametros_calle['cod_prov'] = campos_defs.get_value('cod_prov')

            
            win_CPA_calle = new Window({
                className: 'alphacube',
                url: '/fw/funciones/selCPA_calle.aspx',
                title: '<b>Seleccionar Calle</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                width: 770,
                height: 180,
                onClose: selCPA_calle_return
            });

            win_CPA_calle.options.userData = { parametros_calle: parametros_calle }
            win_CPA_calle.showCenter(true)
        
        }


        function selCPA_calle_return() {

            if (win_CPA_calle.options.userData.res) {

                var objRetorno = win_CPA_calle.options.userData.res

                if (objRetorno['calle'] != '') {
                    calle_ant = objRetorno['calle']
                    $('calle').value = objRetorno['calle']
                }
                if (objRetorno['localidad'] != '') {
                    loc_ant = objRetorno['localidad']
                    $('localidad').value = objRetorno['localidad']
                }
                if (objRetorno['cod_prov'] != '') {
                        cod_prov_ant = objRetorno['cod_prov']
                        $('cod_prov').value = objRetorno['cod_prov']
                        campos_defs.set_value('cod_prov', objRetorno['cod_prov'])
                        }
               if (objRetorno['cod_veraz_prov'] != '')
                   cod_veraz_prov = objRetorno['cod_veraz_prov']
               if (objRetorno['codcalle'] != '')
                   codcalle = objRetorno['codcalle']

            Buscar()
            }
        }

       
        function busqueda_numero() { 

            if ($('check_numero').checked) {
                $('numero').disabled = false
            }
            else {
                //$('numero').value = 0
                $('numero').disabled = true
            }
        }


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                cab_height = $('tbFiltro').getHeight()
                divMenu_height = $('divMenuCPASeleccion').getHeight()
                $('iframe_CPA').setStyle({ 'height': body_height - divMenu_height - cab_height - dif })
            }
            catch (e) { }
        }
 
    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuCPASeleccion"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuCPASeleccion = new tMenu('divMenuCPASeleccion', 'vMenuCPASeleccion');
        Menus["vMenuCPASeleccion"] = vMenuCPASeleccion
        Menus["vMenuCPASeleccion"].alineacion = 'centro';
        Menus["vMenuCPASeleccion"].estilo = 'A';
        Menus["vMenuCPASeleccion"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenuCPASeleccion.MostrarMenu()
    </script>
    <table style="width: 100%">
        <tr>
            <td style="width: 86%">
                <table class="tb1" id="tbFiltro">
                    <tr class="tbLabel">
                        <td colspan='2'>Calle</td>
                        <td style="width: 10%" colspan='2'>Numero</td>
                        <td style="width: 30%">Localidad</td>
                        <td style="width: 30%">Provincia</td>
                    </tr>
                    <tr>
                        <td><input style="width: 100%; text-align: left" type="text" id="calle" name="calle" value="" onkeypress="buscar_onkeypress(event)" /></td>
                        <td style="width: 2%"><a href=#><img src='../image/icons/buscar.png' border='0' align='absmiddle' hspace='1' onclick='selCPA_Calle()'/></a></td>
                        <td style="width: 1%; text-align: center" title="Habilitar/Desabilitar número"><input style='border: none' type="checkbox" name="check_numero" id="check_numero" value="" onclick='busqueda_numero()'/></td>
                        <td><input style="width: 100%; text-align: left" type="text" id="numero" name="numero" value="" onkeypress="buscar_onkeypress(event)" /></td>
                        <td><input style="width: 100%; text-align: left" type="text" name="localidad" id="localidad" value="" onkeypress="buscar_onkeypress(event)" /></td>
                        <!--<td><input style="width: 100%; text-align: left" type="text" id="cod_prov" name="cod_prov" value="" onkeypress="buscar_onkeypress(event)" /></td>-->
                         <td id="td_cod_prov"></td>
                    </tr>
                 </table>
            </td>
            <td style="text-align:center"><div id="divBuscar" /></td>
        </tr>
    </table>
    <iframe name="iframe_CPA" id="iframe_CPA" style="width: 100%; height: 100%; overflow: auto;" frameborder="0" src=""></iframe>
</body>
</html>
