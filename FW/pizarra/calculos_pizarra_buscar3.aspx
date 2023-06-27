<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Me.contents("filtro_pizarra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPizarras'><campos>*</campos></select></criterio>")

    ' Verificar si el operador actual tiene permiso para crear una nueva Pizarra
    Dim nro_permiso As Integer = 8
    Dim tiene_permiso_creacion As Boolean = nvFW.nvApp.getInstance().operador.tienePermiso("permisos_web5", Math.Pow(2, nro_permiso - 1))
    Dim desplegarPizarra As Boolean = nvFW.nvUtiles.obtenerValor("desplegarPizarra", "True")
    Me.contents.Add("desplegarPizarra", desplegarPizarra)
%>
<html>
<head>
    <title>Pizarra Buscar</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% = Me.getHeadInit() %>
    
    <script type="text/javascript">
        var dif = Prototype.Browser.IE ? 5 : 0
        var $body
        var $divMenuPizarra
        var $tablaMenu
        var $iframe1


        function window_onload()
        {
            $body           = $$('body')[0]
            <% If tiene_permiso_creacion Then %>
            $divMenuPizarra = $('divMenuPizarra')
            <% End If %>
            $tablaMenu      = $('tablaMenu')
            $iframe1        = $('iframe1')

            window_onresize()
            nvFW.enterToTab = false
            buscar_onclick()
        }


        function window_onresize()
        {
            try {
                <% If tiene_permiso_creacion Then %>
                $iframe1.style.height = $body.getHeight() - $divMenuPizarra.getHeight() - $tablaMenu.getHeight() - dif + "px"
                <% Else %>
                $iframe1.style.height = $body.getHeight() - $tablaMenu.getHeight() - dif + "px"
                <% End If %>
            }
            catch(e) {}
        }


        function buscar_onclick()
        {
            var filtroWhere = ''

            if ($('calc_pizarra_text').value != '')
                filtroWhere += "<calc_pizarra type='like'>%" + $('calc_pizarra_text').value + "%</calc_pizarra>"

            if ($('prefijo').value != '')
                filtroWhere += "<prefijo type='igual'>'" + $('prefijo').value + "'</prefijo>"

            if ($('posfijo').value != '')
                filtroWhere += "<posfijo type='igual'>'" + $('posfijo').value + "'</posfijo>"

            if (campos_defs.get_value("tipo_datos") != '')
                filtroWhere += "<tipo_dato type='igual'>'" + campos_defs.get_value("tipo_datos") + "'</tipo_dato>"

            nvFW.exportarReporte({
                filtroXML:            nvFW.pageContents.filtro_pizarra,
                filtroWhere:          "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl:             "report/pizarra/verCalculoPizarra/pizarra_buscar.xsl",
                formTarget:           "iframe1",
                nvFW_mantener_origen: true,
                bloq_contenedor:      $$("BODY")[0],
                bloq_msg:             "Cargando pizarras...",
                cls_contenedor:       "iframe1",
                cls_contenedor_msg:   " " // solo para limpiar, pasarle un espacio en blanco
            })
        }


        top.win_pizarra = []


        function seleccionar(event, nro_calc_pizarra)
        {
            if (!nvFW.pageContents.desplegarPizarra) {
                var win = nvFW.getMyWindow()
                win.options.userData.nro_calc_pizarra = nro_calc_pizarra
                win.close()
                return false;
            }
            else {
                var pos = top.win_pizarra.length

                if (nro_calc_pizarra != null && nro_calc_pizarra != 0) {
                    // Abrir la pantalla según el modificador activado

                    // CONTROL => Nueva pestaña
                    if (event.ctrlKey) {
                        top.win_pizarra[pos] = window.open("/FW/pizarra/calculos_pizarra_ABM.aspx?nro_calc_pizarra=" + nro_calc_pizarra + "&id_win=" + pos)
                        top.win_pizarra[pos].addEventListener("beforeunload", function(e) {
                            if (top.win_pizarra[pos].options != undefined)
                                if (top.win_pizarra[pos].options.userData.recargar)
                                    buscar_onclick()

                            top.win_pizarra[pos] = undefined
                        }, false)
                    }
                    // SHIFT => Nueva ventana de browser
                    else if (event.shiftKey) {
                        top.win_pizarra[pos] = window.open("/FW/pizarra/calculos_pizarra_ABM.aspx?nro_calc_pizarra=" + nro_calc_pizarra + "&id_win=" + pos, null, "width=800")
                        top.win_pizarra[pos].addEventListener("beforeunload", function(e) {
                            if (top.win_pizarra[pos].options != undefined)
                                if (top.win_pizarra[pos].options.userData.recargar)
                                    buscar_onclick()

                            top.win_pizarra[pos] = undefined
                        }, false)
                    }
                    // ALT => Ventana modal (por defecto, Win Prototype) == ningún modificador activado
                    else {
                        top.win_pizarra[pos] = top.nvFW.createWindow({
                            title:               "<b>Pizarra</b>",
                            width:               1200,
                            height:              640,
                            minWidth:            850,
                            minHeight:           400,
                            resizable:           true,
                            parentWidthPercent:  0.9,
                            parentWidthElement:  parent.$$("body")[0],
                            parentHeightPercent: 0.9,
                            parentHeightElement: parent.$$("body")[0],
                            onClose: function(win) {
                                if (top.win_pizarra[pos].options != undefined)
                                    if (top.win_pizarra[pos].options.userData.recargar)
                                        buscar_onclick()
                                top.win_pizarra[pos] = undefined
                            }
                        })

                        top.win_pizarra[pos].setURL("/FW/pizarra/calculos_pizarra_ABM.aspx?nro_calc_pizarra=" + nro_calc_pizarra + "&id_win=" + pos)
                        top.win_pizarra[pos].options.userData = { recargar: false }
                        top.win_pizarra[pos].showCenter()
                    }
                }
            
            }
        }


        function enter_onkeypress(e)
        {
            (e.keyCode || e.which) == 13 && buscar_onclick()
        }


        function pizarra_crear_nueva()
        {
            var pos = top.win_pizarra.length

            top.win_pizarra[pos] = top.nvFW.createWindow({
                title:               "<b>Nueva Pizarra</b>",
                width:               1200,
                height:              640,
                minWidth:            850,
                minHeight:           400,
                resizable:           true,
                parentWidthPercent:  0.9,
                parentWidthElement:  parent.$$("body")[0],
                parentHeightPercent: 0.9,
                parentHeightElement: parent.$$("body")[0],
                onClose: function(win) {
                    if (top.win_pizarra[pos].options != undefined)
                        if (top.win_pizarra[pos].options.userData.recargar)
                            buscar_onclick()
                    top.win_pizarra[pos] = undefined
                }
            })

            top.win_pizarra[pos].setURL("/FW/pizarra/calculos_pizarra_ABM.aspx?nro_calc_pizarra=0&id_win=" + pos)
            top.win_pizarra[pos].options.userData = { recargar: false }
            top.win_pizarra[pos].showCenter()
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <% If tiene_permiso_creacion Then %>
    <div id="divMenuPizarra"></div>
    <script type="application/javascript">
        var vMenu = new tMenu('divMenuPizarra', 'vMenu')
        vMenu.loadImage("nuevo", "/FW/image/icons/agregar.png")
        Menus["vMenu"]            = vMenu
        Menus["vMenu"].alineacion = "centro"
        Menus["vMenu"].estilo     = "A"
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva Pizarra</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_crear_nueva()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.MostrarMenu()
    </script>
    <% End If %>

    <table class="tb1" id="tablaMenu">
        <tr class="tbLabel">
            <td class="Tit1" style="width: 30%; text-align: center;">Nombre Pizarra</td>
            <td class="Tit1" style="width: 10%; text-align: center;">Prefijo</td>
            <td class="Tit1" style="width: 10%; text-align: center;">Posfijo</td>
            <td class="Tit1" style="width: 30%; text-align: center;">Tipo dato</td>
            <td class="Tit1" style="width: 20%; text-align: center;">&nbsp;</td>
        </tr>
        <tr>
            <td style="width: 30%">
                <input style="width: 100%;" id="calc_pizarra_text" name="calc_pizarra_text" type="text" value="" onkeypress="return enter_onkeypress(event)" />
            </td>
            <td style="width: 10%">
                <input style="width: 100%;" id="prefijo" name="prefijo" type="text" value="" onkeypress="return enter_onkeypress(event)" />
            </td>
            <td style="width: 10%">
                <input style="width: 100%;" id="posfijo" name="posfijo" type="text" value="" onkeypress="return enter_onkeypress(event)" />
            </td>
            <td style="width: 30%">
                <%= nvFW.nvCampo_def.get_html_input("tipo_datos", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='dato_tipos'><campos>id_dato_tipo AS id, dato_tipo AS campo</campos></select></criterio>") %>
            </td>
            <td style="width: 20%">
                <div id="divBuscar"></div>
                <script type="text/javascript">
                    var vButtonItems = {};
                    vButtonItems[0] = {};
                    vButtonItems[0]["nombre"]   = "Buscar";
                    vButtonItems[0]["etiqueta"] = "Buscar";
                    vButtonItems[0]["imagen"]   = "buscar";
                    vButtonItems[0]["onclick"]  = "return buscar_onclick()";

                    var vListButton = new tListButton(vButtonItems, 'vListButton');
                    vListButton.loadImage('buscar', '/FW/image/icons/buscar.png')

                    vListButton.MostrarListButton();
                </script>
            </td> 
        </tr>
    </table>
    
    <iframe id="iframe1" name="iframe1" style="width: 100%; height:100%; border: none;"></iframe>
</body>
</html>