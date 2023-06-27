<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

    Dim nombreOperador = nvApp.operador.operador
    Me.contents("nombreOperador") = nombreOperador

    Dim accion = nvUtiles.obtenerValor("accion", "")

    Me.contents("id_Circuito") = nvUtiles.obtenerValor("id_Circuito", "")
    Me.contents("entidadSeleccionada") = nvUtiles.obtenerValor("entidadSeleccionada", "")

    Me.contents("filtroDatos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Circuito_Datos'><campos>label,value</campos><orden></orden></select></criterio>")
    Me.contents("filtroMotivo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Circuito_Motivo'><campos>motivo</campos><orden></orden></select></criterio>")
    Me.contents("filtroLocalidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Circuito_Localidad'><campos>localidad</campos><orden></orden></select></criterio>")
    Me.contents("filtroParametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Circuito_Parametros'><campos>value,label</campos><orden></orden></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var nombreOperador = nvFW.pageContents.nombreOperador
        var id_Circuito = nvFW.pageContents.id_Circuito
        var entidadSeleccionada = nvFW.pageContents.entidadSeleccionada

        var win = nvFW.getMyWindow();

        function window_onload() {
            //cargar_tabla();
            cargar_textos_libres()
            cargar_tabla_parametros();
            cargar_tabla_localidad();
            cargar_tabla_motivo();

            window_onresize()
        }

        var localidadCount = 0
        var motivoCount = 0
        function cargar_textos_libres() {
            var rs_texto_libre = new tRS()

            var filtro
            if (id_Circuito)
                filtro = "<id_Circuito type='igual'>" + id_Circuito + "</id_Circuito>"
            else
                filtro = "<id_Circuito type='igual'>" + -1 + "</id_Circuito>"

            rs_texto_libre.open(nvFW.pageContents.filtroLocalidad, "", filtro)

            localidadCount = rs_texto_libre.recordcount
            if (rs_texto_libre.recordcount == 0) {
                $("check_localidad_texto_libre").checked = true
                //$("input_texto_libre_localidad").value = rs_texto_libre.getdata("localidad");
            }

            rs_texto_libre = new tRS()
            if (id_Circuito)
                filtro = "<id_Circuito type='igual'>" + id_Circuito + "</id_Circuito>"
            else
                filtro = "<id_Circuito type='igual'>" + -1 + "</id_Circuito>"

            rs_texto_libre.open(nvFW.pageContents.filtroMotivo, "", filtro)

            motivoCount = rs_texto_libre.recordcount
            if (rs_texto_libre.recordcount == 0) {
                $("check_motivo_texto_libre").checked = true
                //$("input_texto_libre_motivo").value = rs_texto_libre.getdata("motivo");
            }

            rs_texto_libre = null
            onchange_texto_libre()
        }

        function onchange_texto_libre() {
            if ($("check_localidad_texto_libre").checked) {
                $("div_texto_libre_localidad").show()
                $("tabla_localidad").hide()
            }
            else {
                $("div_texto_libre_localidad").hide()
                $("tabla_localidad").show()
            }

            if ($("check_motivo_texto_libre").checked) {
                $("div_texto_libre_motivo").show()
                $("tabla_motivo").hide()
            }
            else {
                $("div_texto_libre_motivo").hide()
                $("tabla_motivo").show()
            }

            window_onresize()
        }

        function window_onresize() {

            try {
                var body_h = $$('body')[0].getHeight()
                var divMenu_h = $("divMenu").getHeight()

                var div_metadatos_fijos_h = $("div_metadatos_fijos").getHeight()
                var div_titulo_parametros_h = $("div_titulo_parametros").getHeight()

                $("div_tabla_parametros").setStyle({ height: (body_h - divMenu_h - div_metadatos_fijos_h - 20) + 'px' });
                //tabla_metadatos.resize();
                tabla_localidad.resize();
                tabla_motivo.resize();
                tabla_parametros.resize();
            }
            catch (e) { }
        }

        var tabla_parametros;
        function cargar_tabla_parametros() {
            tabla_parametros = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_parametros.nombreTabla = "tabla_parametros";
            //Agregamos consulta XML
            tabla_parametros.filtroXML = nvFW.pageContents.filtroParametros

            if (id_Circuito)
                tabla_parametros.filtroWhere = "<id_RM0 type='igual'>" + id_Circuito + "</id_RM0>"
            else
                tabla_parametros.filtroWhere = "<id_RM0 type='igual'>" + -1 + "</id_RM0>"

            tabla_parametros.async = true;
            tabla_parametros.cabeceras = ["Nombre de Parametro", "Valor"];

            tabla_parametros.editable = false;

            tabla_parametros.campos = [
                 {
                     nombreCampo: "label", nro_campo_tipo: 104, width: "40%"
                 },
                 {
                     nombreCampo: "value", nro_campo_tipo: 104, width: "40%"
                 }
            ];

            tabla_parametros.table_load_html();

        }

        var tabla_localidad;
        function cargar_tabla_localidad() {
            tabla_localidad = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_localidad.nombreTabla = "tabla_localidad";
            //Agregamos consulta XML
            tabla_localidad.filtroXML = nvFW.pageContents.filtroLocalidad

            if (id_Circuito && localidadCount !== 1)
                tabla_localidad.filtroWhere = "<id_Circuito type='igual'>" + id_Circuito + "</id_Circuito>"
            else
                tabla_localidad.filtroWhere = "<id_Circuito type='igual'>" + -1 + "</id_Circuito>"

            tabla_localidad.async = true;
            tabla_localidad.cabeceras = ["Localidad"];

            tabla_localidad.editable = false;

            tabla_localidad.campos = [
                 {
                     nombreCampo: "localidad", nro_campo_tipo: 104, enBD: false
                 }
            ];

            tabla_localidad.table_load_html();

        }


        var tabla_motivo;
        function cargar_tabla_motivo() {
            tabla_motivo = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_motivo.nombreTabla = "tabla_motivo";
            //Agregamos consulta XML
            tabla_motivo.filtroXML = nvFW.pageContents.filtroMotivo

            if (id_Circuito && motivoCount !== 1)
                tabla_motivo.filtroWhere = "<id_Circuito type='igual'>" + id_Circuito + "</id_Circuito>"
            else
                tabla_motivo.filtroWhere = "<id_Circuito type='igual'>" + -1 + "</id_Circuito>"

            tabla_motivo.async = true;
            tabla_motivo.cabeceras = ["Motivo"];

            tabla_motivo.editable = false;

            tabla_motivo.campos = [
                 {
                     nombreCampo: "motivo", nro_campo_tipo: 104, enBD: false
                 }
            ];
            tabla_motivo.table_load_html();

        }

        function onclick_aceptar() {

            var xml = "";

            if ($("check_localidad_texto_libre").checked) {
                xml = xml + "<localidades><localidad accion='eliminar' localidad='undefined' /></localidades>"
            }
            else if (generarXML(tabla_localidad, "localidades", "localidad") + tabla_localidad.generarXML("localidades")) {
                xml = xml + "<localidades>" + generarXML(tabla_localidad, "localidades", "localidad") + tabla_localidad.generarXML("localidades") + "</localidades>"
            }
            else
                xml = xml + "<localidades><localidades><localidad accion='eliminar' localidad='undefined' /></localidades></localidades>"

            if ($("check_motivo_texto_libre").checked) {
                xml = xml + "<motivos><motivos><motivo accion='eliminar' motivo='undefined' /></motivos></motivos>"
            }
            else if (generarXML(tabla_motivo, "motivos", "motivo") + tabla_motivo.generarXML("motivos")) {
                xml = xml + "<motivos>" + generarXML(tabla_motivo, "motivos", "motivo") + tabla_motivo.generarXML("motivos") + "</motivos>"
            }
            else
                xml = xml + "<motivos><motivos><motivo accion='eliminar' motivo='undefined' /></motivos></motivos>"

            if (generarXMLParametros() + tabla_parametros.generarXML("parametro"))
                xml = xml + "<parametros>" + generarXMLParametros() + tabla_parametros.generarXML("parametro") + "</parametros>"
            else
                xml = xml + "<parametros><parametros><parametro accion='eliminar' label='undefined' value='undefined' /></parametros></parametros>"

            win.options.userData = xml

            win.close();
        }


        function generarXML(tabla, label, nombreParametro) {
            var xml = ""
            for (var i = 1 ; i < tabla.data.length; i++) {
                if (!tabla.data[i].tabla_control.eliminado && tabla.data[i].tabla_control.existeEnBd) {
                    var value = tabla.data[i][nombreParametro]
                    xml += "<" + label + " accion='agregar' " + nombreParametro + "='" + value + "' " + nombreParametro + "Anterior='" + value + "'  />"
                }
            }

            return xml
        }

        function generarXMLParametros() {
            var xml = ""
            for (var i = 1 ; i < tabla_parametros.data.length; i++) {
                if (!tabla_parametros.data[i].tabla_control.eliminado && tabla_parametros.data[i].tabla_control.existeEnBd) {
                    var value = tabla_parametros.data[i].value
                    var label = tabla_parametros.data[i].label
                    //var ckey = tabla_parametros.data[i].ckey
                    xml += "<parametro accion='agregar' label='" + label + "' labelAnterior='" + label + "' value='" + value + "' valueAnterior='" + value + "' />"
                }
            }

            return xml
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <div id="divMenu"></div>
    <script type="text/javascript">

        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Configuracion Avanzada</Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Aceptar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
        vMenu.MostrarMenu()
    </script>

    <div id="div_metadatos_fijos">
        <table style="width: 100%">
            <tr style="width: 50%">
                <td>
                    <table class="tb1 ">
                        <tr>
                            <td>
                                <div id="divMenuLocalidad"></div>
                                <script type="text/javascript">

                                    var vMenu = new tMenu('divMenuLocalidad', 'vMenu');
                                    Menus["vMenu"] = vMenu
                                    Menus["vMenu"].alineacion = 'centro';
                                    Menus["vMenu"].estilo = 'A';
                                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Localidad</Desc></MenuItem>")
                                    vMenu.MostrarMenu()
                                </script>
                                <div id="div_tabla_localidad" style="width: 100%; height: 160px; overflow: hidden">
                                    <div id="tabla_localidad" style="width: 100%; height: 100%; overflow: hidden"></div>
                                    <div id="div_texto_libre_localidad">
                                        <!--Localidad:<textarea rows="100" cols="100" id="input_texto_libre_localidad" name="input_texto_libre_localidad" style="width: 100%; height: 100%;font-family: Calibri" ></textarea>-->
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="checkbox" id="check_localidad_texto_libre" onchange="onchange_texto_libre()" />
                                Texto Libre
                            </td>
                        </tr>
                    </table>
                </td>
                <td style="width: 50%">
                    <table class="tb1 ">
                        <tr>
                            <td>
                                <div id="divMenuMotivo"></div>
                                <script type="text/javascript">

                                    var vMenu = new tMenu('divMenuMotivo', 'vMenu');
                                    Menus["vMenu"] = vMenu
                                    Menus["vMenu"].alineacion = 'centro';
                                    Menus["vMenu"].estilo = 'A';
                                    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Motivo</Desc></MenuItem>")
                                    vMenu.MostrarMenu()
                                </script>
                                <div id="div_tabla_motivo" style="width: 100%; height: 160px; overflow: hidden">
                                    <div id="tabla_motivo" style="width: 100%; height: 100%; overflow: hidden"></div>
                                    <div id="div_texto_libre_motivo">
                                        <!--Motivo:<textarea rows="100" cols="100" id="input_texto_libre_motivo" name="input_texto_libre_localidad" style="width: 100%; height: 100%;font-family: Calibri" ></textarea>-->
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="checkbox" id="check_motivo_texto_libre" onchange="onchange_texto_libre()" />
                                Texto Libre
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

    </div>

    <!--div id="div_titulo_metadatos" >Metadatos</!--div>
    <div id="div_tabla_metadatos" style="width: 100%; height: 100%; overflow: hidden">
        <div id="tabla_metadatos" style="width: 100%; height: 100%; overflow: hidden"></div>
    </div-->

    <div id="div_titulo_parametros">
        <div id="divMenuParametros"></div>
        <script type="text/javascript">

            var vMenu = new tMenu('divMenuParametros', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Parametros</Desc></MenuItem>")
            vMenu.MostrarMenu()
        </script>
    </div>
    <div id="div_tabla_parametros" style="width: 100%; height: 100%; overflow: hidden">
        <div id="tabla_parametros" style="width: 100%; height: 100%; overflow: hidden"></div>
    </div>

    <!--input style="width: 100%" id="input_cargar_firmas" value="Cargar Firmas y Documentos" type="button" onclick="firmasABM()" /-->

</body>
</html>
