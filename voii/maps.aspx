<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" EnableSessionState="ReadOnly" %>
<%
    Dim GOOGLE_MAPS_API_KEY_BROWSER As String = "AIzaSyD2RFgtiLhf6rSioyy0U6IVDLuFtz_EtLo"
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html lang="es-ar" xml:lang="es-ar" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Google Maps API</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        .pac-container.pac-logo::after { content: none; }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <%-- Google Maps API --%>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=<% = GOOGLE_MAPS_API_KEY_BROWSER %>&libraries=places&region=AR">
        document.write("NO SE PUEDE CARGAR LA LIBRERIA GOOGLE_MAPS")
    </script>

    <script type="text/javascript">

        // Maps
        var autocomplete;
        var autocomplete_city;



        function windowOnload()
        {
            nvFW.enterToTab = false;
            inicializarMaps();
        }



        function inicializarMaps()
        {
            // Box general
            var configs = {
                types: ['address'],
                //types: ['(cities)'],
                //types: ['geocode'],
                componentRestrictions: { country: 'ar' }
            };
            
            var input = $('calle');
            input.placeholder = 'Ingrese una dirección. Ej: Bv. Oroño 126, Rosario, Santa Fe';
            input.autocomplete = 'on';

            autocomplete = new google.maps.places.Autocomplete(input, configs);
            autocomplete.setFields(['address_components']);
            autocomplete.addListener('place_changed', setDataMapCallback); // Evento seleccionar


            // Box ciudad
            var config_city = {
                types: ['(cities)'],
                componentRestrictions: { country: 'ar' }
            };

            var input_city = $('ciudad');
            input_city.placeholder = 'Ej: Santa Fe';
            input_city.autocomplete = 'on';

            autocomplete_city = new google.maps.places.Autocomplete(input_city, config_city);
            autocomplete_city.setFields(['address_components']);
            autocomplete_city.addListener('place_changed', setDataCityCallback); // Evento seleccionar (input de ciudad)
        }



        function setDataMapCallback()
        {
            var place = autocomplete.getPlace();

            if (place.address_components) {
                var item;

                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];
                        
                    switch (item.types[0]) {
                        case 'route':
                            if (item.long_name) campos_defs.set_value('calle', item.long_name);
                            break;

                        case 'street_number':
                            if (item.long_name) campos_defs.set_value('numero', item.long_name);
                            break;

                        case 'locality':
                            if (item.long_name) campos_defs.set_value('ciudad', item.long_name);
                            break;

                        case 'postal_code':
                            if (item.long_name) campos_defs.set_value('postal', item.long_name);
                            break;
                            
                        case 'administrative_area_level_1':
                            if (item.long_name) campos_defs.set_value('provincia', item.long_name);
                            break;
                    }
                }
            }
        }



        function setDataCityCallback()
        {
            // Obtener los datos y setear solo la ciudad (locality)
            var place = autocomplete_city.getPlace();

            if (place.address_components) {
                var item;

                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];

                    if (item.types[0] === 'locality') {
                        campos_defs.set_value('ciudad', item.long_name);
                        break;
                    }
                }
            }
        }



        function limpiarCamposDefs()
        {
            campos_defs.set_value('calle', '');
            campos_defs.set_value('numero', '');
            campos_defs.set_value('piso', '');
            campos_defs.set_value('departamento', '');
            campos_defs.set_value('ciudad', '');
            campos_defs.set_value('postal', '');
            campos_defs.set_value('provincia', '');
        }



        function nuevaBusqueda()
        {
            limpiarCamposDefs();
        }
    </script>
</head>
<body onload="windowOnload()" style="width: 100%; height: 100%; margin: 0; overflow: hidden;">

    <div style="width:960px; margin: 0 auto; padding: 10px; border-bottom: 1px solid #ccc; background: white;" id="divDatos">
        <h2 style="font-family: Roboto, sans-serif; font-size: 200%; margin: 20px 0; text-align: center; color: #212529;">Normalizador de direcciones</h2>

        <div id="divMenu"></div>
        <script type="text/javascript">
            var menu = new tMenu('divMenu', 'menu');
            menu.loadImage('buscar', '/FW/image/icons/buscar.png');
            Menus["menu"] = menu;
            Menus["menu"].alineacion = 'centro';
            Menus["menu"].estilo = 'A';
            Menus["menu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
            Menus["menu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Nueva búsqueda</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevaBusqueda()</Codigo></Ejecutar></Acciones></MenuItem>");
            menu.MostrarMenu();
        </script>

        <table class="tb1">
            <tr>
                <td class="Tit1">Calle</td>
                <td style="width: 60%;">
                    <% = nvCampo_def.get_html_input("calle", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td class="Tit1">Nro.</td>
                <td style="width: 10%;">
                    <% = nvCampo_def.get_html_input("numero", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td class="Tit1">Piso</td>
                <td style="width: 5%;">
                    <% = nvCampo_def.get_html_input("piso", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td class="Tit1">Dpto.</td>
                <td style="width: 5%;">
                    <% = nvCampo_def.get_html_input("departamento", enDB:=False, nro_campo_tipo:=104) %>
                </td>
            </tr>
        </table>

        <table class="tb1">
            <tr>
                <td class="Tit1">Ciudad</td>
                <td>
                    <% = nvCampo_def.get_html_input("ciudad", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td class="Tit1">Postal</td>
                <td style="width: 10%;">
                    <% = nvCampo_def.get_html_input("postal", enDB:=False, nro_campo_tipo:=104) %>
                </td>
                <td class="Tit1">Provincia</td>
                <td>
                    <% = nvCampo_def.get_html_input("provincia", enDB:=False, nro_campo_tipo:=104) %>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
