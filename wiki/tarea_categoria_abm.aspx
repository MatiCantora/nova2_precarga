<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    ' Obtenemos valores del submit()
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")      '//M:'Modo Actualización'  
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")

    Me.contents("filtroTareaCargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Tarea_cat'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroCargarTarea") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerTarea_Cat_Operador'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroOperadorNuevo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>distinct *</campos><filtro><SQL type='sql'>operador = dbo.rm_nro_operador()</SQL></filtro></select></criterio>")

    If (modo.ToUpper() <> "") Then
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("tarea_categoria_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, , , strXML)
        Dim rs As ADODB.Recordset = cmd.Execute()
        Dim err As New nvFW.tError(rs)
        If (Not rs.EOF) Then
            err.params("nro_tarea_cat") = rs.Fields("nro_tarea_cat").Value
        End If
        err.response()
    End If
%>
<html>
<head>
    <title>Tarea Categoria ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    
    <%= Me.getHeadInit()%>
    
    <script type="text/javascript">
        var modo = ''
        
        function window_onload() {
            campos_defs.items['nro_operador']['onchange']=onchange_operadores
            tarea_cat_cargar()
            window_onresize()
        }

        function validar() {
            var strError = ''
            
            if ($('tarea_cat').value == '')
                strError = "Ingrese la descripción </br>"

            return strError
        }

        function guardar() {
            var strError = validar()

            if (strError != '') {
                alert(strError)
                return
            }

            notificaciones_actualizar()
            
            var xmldato = ""
            xmldato += "<tarea_cat_abm nro_tarea_cat='" + $('nro_tarea_cat_txt').value + "' tarea_cat='" + $('tarea_cat').value + "'>"
            xmldato += "<cat_operador>"
            TareaCatOperador.each(function(arreglo,i) {
                if (arreglo['estado'] != 'BORRADO' && arreglo['estado'] != 'VACIO')
                    xmldato += "<tarea_cat_operador  operador='" + arreglo['operador'] + "' notificador='" + arreglo['notificador'] + "'/>"
            });
            xmldato += "</cat_operador>"
            xmldato += "</tarea_cat_abm>"

            nvFW.error_ajax_request('tarea_categoria_abm.aspx', {
                parameters: { modo: 'M', strXML: xmldato },
                onSuccess: actualizar_return, 
                onFailure: function (err, b) {},
                error_alert: true
            })
        }

        function actualizar_return(err) {
            switch(err.numError) {
                case 0:
                    $('nro_tarea_cat_txt').value = err.params['nro_tarea_cat']
                    TareaCat = []
                    window_onload()
                    break
                default:
                    nvFW.alert(err.numError + ' - ' + err.mensaje, {
                        width: 300,
                        height: 100,
                        okLabel: "cerrar",
                        onOk: function(ver) {
                            ver.close();
                            winActualizar.close()
                        }
                    });
                    break
            }
        }

        var TareaCat = []
        
        function tarea_cat_cargar() {
            var i = 0,
                rs = new tRS(),
                filtroXML = nvFW.pageContents.filtroTareaCargar

            rs.open(filtroXML)

            while(!rs.eof()) {
                TareaCat[i] = []
                TareaCat[i]['nro_tarea_cat_txt'] = rs.getdata('nro_tarea_cat')
                TareaCat[i]['tarea_cat'] = rs.getdata('tarea_cat')
                rs.movenext()
                i++
            }
            tarea_cat_dibujar()
        }

        var checkeador_indice

        function tarea_cat_dibujar() {
            $('divTareaCat').innerHTML = ''

            var checkeador = '',
                checkeador_indice = 0,
                strHTML = "<table class='tb1'>"

            TareaCat.each(function(arreglo, j) {
                checkeador = ''
                
                if (arreglo['nro_tarea_cat_txt'] == $('nro_tarea_cat_txt').value || j == 0) {
                    checkeador = 'checked'
                    checkeador_indice = j
                }

                strHTML += "<tr><td style='width:4%; text-align: center'><input type='radio' " + checkeador + "  name='RCat' id='RCat' value='" + j + "' onclick='return RCat_onclick(event)' style='border:0px'>"
                strHTML += "</td><td style='text-align: left'><b>" + arreglo["tarea_cat"] + "</b></td>"
                strHTML += "</td><td style='width:20px;text-align: left' style='cursor:pointer;cursor:hand'><img src='../FW/image/icons/editar.png' onclick='editar_categoria(" + j + ")'></td></tr>"
            });

            strHTML += "</table>"
            $('divTareaCat').insert({ top: strHTML })

            CargarDatos(checkeador_indice)
        }

        function CargarDatos(indice) {
            $('nro_tarea_cat_txt').value = TareaCat[indice]["nro_tarea_cat_txt"]
            $('tarea_cat').value = TareaCat[indice]["tarea_cat"]
            cargar_tarea_cat_operador()
        }

        function RCat_onclick(e) {
            var i = 0,
                e
            try {
                i = Event.element(e).value
            }
            catch(e) {
                if (!FrmTarea.RCat.length)
                    FrmTarea.RCat.checked = true
                else
                    FrmTarea.RCat[(0)].checked = true
                i = 0
            }

            CargarDatos(i)
        }

        function editar_categoria(indice) {
            nvFW.confirm("<b>Editar descripción:</b><div style='width:100%' id='divNC'><br/><input id='categoria' style='width:80%' value='" + TareaCat[indice]["tarea_cat"] + "'/></div>", {
                width: 350,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                onShow: function(win) { $('categoria').focus() },
                cancel: function(win) { win.close(); return; },
                ok: function(win) {
                    if ($('categoria').value != "") {
                        $('nro_tarea_cat_txt').value = TareaCat[indice]["nro_tarea_cat_txt"]
                        $('tarea_cat').value = $('categoria').value
                        guardar()
                    }
                    else {
                        alert("Ingrese el nombre de la categoria")
                        return
                    }
                    win.close()
                }
            });
        }

        function nueva() {
            nvFW.confirm("<b>Ingrese una nueva categoria:</b><div style='width:100%' id='divNC'><br/><input id='nueva_categoria' style='width:80%' value=''/></div>", {
                width: 350,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                onShow: function(win) { $('nueva_categoria').focus() },
                cancel: function(win) { win.close(); return },
                ok: function(win) {
                    if ($('nueva_categoria').value != "") {
                        $('nro_tarea_cat_txt').value = 0
                        $('tarea_cat').value = $('nueva_categoria').value
                        TareaCatOperador = []
                        operador_nuevo()
                        guardar()
                    }
                    else {
                        alert("Ingrese el nombre de la categoria")
                        return
                    }
                    win.close()
                }
            });
        }

        var TareaCatOperador = []

        function cargar_tarea_cat_operador() {
            TareaCatOperador.length = 0
            var i = 0,
                rs = new tRS(),
                filtroXML = nvFW.pageContents.filtroCargarTarea,
                filtrowhere = "<nro_tarea_cat type='igual'>" + $('nro_tarea_cat_txt').value + "</nro_tarea_cat>"
            
            rs.open(filtroXML, '', filtrowhere)
            
            while (!rs.eof()) {
                TareaCatOperador[i] = []
                TareaCatOperador[i]['operador'] = rs.getdata('operador')
                TareaCatOperador[i]['strNombreCompleto'] = rs.getdata('strNombreCompleto')
                TareaCatOperador[i]['notificador'] = rs.getdata('notificador') == '' ? 0 : parseInt(rs.getdata('notificador'))
                TareaCatOperador[i]['estado'] = 'GUARDADO'
                i++
                rs.movenext()
            }
            agregar_nuevo_vinculacion(TareaCatOperador.length)
            dibujar_tarea_cat_operador()
        }

        function agregar_nuevo_vinculacion(indice) {
            TareaCatOperador[indice] = []
            TareaCatOperador[indice]['operador'] = ''
            TareaCatOperador[indice]['strNombreCompleto'] = ''
            TareaCatOperador[indice]['nro_tarea_tipo_rel'] = ''
            TareaCatOperador[indice]['tarea_tipo_rel'] = ''
            TareaCatOperador[indice]['notificador'] = 0
            TareaCatOperador[indice]['estado'] = 'VACIO'
        }

        function dibujar_tarea_cat_operador() {
            $('divTareaCatOperador').innerHTML = ''

            var checkear = '',
                strHTML = "<table id='tbCuerpo' class='tb1'>",
                value_button = '',
                notificador

            TareaCatOperador.each(function(arreglo, i) {
                if (arreglo['estado'] != 'BORRADO') {
                    value_button = arreglo["estado"] == 'VACIO' ? 'value = " + "' : 'value = "..."'

                    notificador = arreglo['notificador']

                    if (notificador >= 0) {
                        checkear_ce = (Math.pow(2, 1 - 1) & notificador) == 0 ? '' : "checked='checked'"
                        checkear_p = (Math.pow(2, 2 - 1) & notificador) == 0 ? '' : "checked='checked'"
                        checkear_c = (Math.pow(2, 3 - 1) & notificador) == 0 ? '' : "checked='checked'"
                    }

                    etiqueta_img = '<img alt="" title="Desvincular Operador" src="/wiki/image/icons/eliminar.png" style="cursor:pointer;cursor:hand" onclick="operador_eliminar(' + i + ')" />'

                    strHTML += "<tr>"
                    strHTML += "<td style='width:5%;text-align:center'>" + etiqueta_img + "</td>"
                    strHTML += "<td id='td_ope" + i + "' style='width:70%'>" + arreglo['operador'] + " " + arreglo['strNombreCompleto'] + "</td>"
                    strHTML += "<td style='width:8%; text-align:center'><input type='button' onclick='return operador_asignar(\"EDITAR_OPERADOR~" + i + "\")' " + value_button + "/></td>"
                    strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:5%; text-align:left'><input type='checkbox' id='check_ce~" + i + "~" + Math.pow(2, 1 - 1) + "'name='check_ce~" + i + "~" + Math.pow(2, 1 - 1) + "' value='' " + checkear_ce + "/></td>" : "<td style='width:5%; text-align:left'></td>"
                    strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:5%; text-align:left'><input type='checkbox' id='check_p~" + i + "~" + Math.pow(2, 2 - 1) + "' name='check_p~" + i + "~" + Math.pow(2, 2 - 1) + "' value='' " + checkear_p + "/></td>" : "<td style='width:5%; text-align:left'></td>"
                    strHTML += arreglo["estado"] != 'VACIO' ? "<td style='width:5%; text-align:left'><input type='checkbox' id='check_c~" + i + "~" + Math.pow(2, 3 - 1) + "' name='check_c~" + i + "~" + Math.pow(2, 3 - 1) + "' value='' " + checkear_c + "/></td>" : "<td style='width:5%; text-align:left'></td>"
                    strHTML += "<td id='tdScroll" + i + "' style='width:2%'>&nbsp;&nbsp;&nbsp;&nbsp;</td>"
                    strHTML += "</tr>"

                    arreglo['notificador'] = 0 // Una vez dibujado lo seteo en 0 para despues actualizar
                }
            });

            strHTML += "</table>"
            $('divTareaCatOperador').insert({ top: strHTML })

            $('tbCuerpo').getHeight() - $('divTareaCatOperador').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
        }

        function tdScroll_hide_show(show) {
            var i = 0

            while (i < TareaCatOperador.length) {
                if (show && $('tdScroll' + i) != undefined)
                    $('tdScroll' + i).show()

                if (!show && $('tdScroll' + i) != undefined)
                    $('tdScroll' + i).hide()

                i++
            }
        }

        function notificaciones_inicializar() {
            TareaCatOperador.each(function(arreglo, i) {
                arreglo['notificador'] = 0
            });
        }

        function notificaciones_actualizar() {
            notificaciones_inicializar()

            var i = 0,
                ele,
                res = 0

            if ($('nro_tarea_cat_txt').value > 0) {
                for (; ele = $('FrmTarea').elements[i]; i++) {
                    res = 0
                    if (ele.type == 'checkbox' && ele.disabled != true)
                        if (ele.name.split('~').length > 1) {
                            if (ele.checked) {
                                var indice = parseInt(ele.name.split('~')[1]),
                                    numero = parseInt(ele.name.split('~')[2])

                                res = TareaCatOperador[indice]['notificador']
                                res = numero + res
                                TareaCatOperador[indice]['notificador'] = res
                            }
                        }
                }
            }
        }

        var asignar

        function operador_asignar(modo)
        {
            asignar = modo
            campos_defs.onclick('', 'nro_operador', true)
        }

        function onchange_operadores() {
            var res = []
            res = asignar != undefined ? asignar.split('~') : res
            
            if (res[0] == 'EDITAR_OPERADOR')
                operador_editar(res[1])
        }

        function operador_editar(indice) {
            if (!operador_existe()) {
                TareaCatOperador[indice]['operador'] = campos_defs.value('nro_operador')
                TareaCatOperador[indice]['strNombreCompleto'] = campos_defs.desc('nro_operador')
                TareaCatOperador[indice]['estado'] = TareaCatOperador[indice]['estado'] == 'VACIO' ? 'NUEVO' : 'VACIO' // si la fila es la ultima y estaba vacia 

                $('td_ope' + indice).innerHTML = ''
                $('td_ope' + indice).insert({ top: TareaCatOperador[indice]['strNombreCompleto'] })

                if (TareaCatOperador[TareaCatOperador.length - 1]['estado'] == 'NUEVO') {
                    notificaciones_actualizar()
                    agregar_nuevo_vinculacion(TareaCatOperador.length)
                    dibujar_tarea_cat_operador()
                }
            }
            else
                dibujar_tarea_cat_operador()
        }
        
        function operador_existe() {
            var existe = false

            TareaCatOperador.each(function(arreglo, i) {
                if (arreglo['operador'] == campos_defs.value('nro_operador')) {
                    existe = true
                    if (arreglo['estado'] == 'BORRADO')
                        arreglo['estado'] = 'GUARDADO'
                }
            });
            return existe
        }
        
        function operador_nuevo() {
            if (!operador_existe()) {
                var operador = '',
                    strNombreCompleto = '',
                    indice = TareaCatOperador.length > 0 ? TareaCatOperador.length : 0

                if (indice == 0) {
                    var rs = new tRS(),
                        filtroXML = nvFW.pageContents.filtroOperadorNuevo

                    rs.open(filtroXML)

                    if (!rs.eof()) {
                        operador = rs.getdata('operador')
                        strNombreCompleto = rs.getdata('strNombreCompleto')
                    }
                }
                else {
                    operador = campos_defs.value('nro_operador')
                    strNombreCompleto = campos_defs.desc('nro_operador')
                }
            }

            notificaciones_actualizar()
            agregar_nuevo_vinculacion(TareaCatOperador.length)
            dibujar_tarea_cat_operador()
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_h = $$('body')[0].getHeight(),
                    divCabe_h=$('divCabe').getHeight()

                $('divTareaCatOperador').setStyle({ 'height': body_h - divCabe_h - dif })
            }
            catch(e) {}
        }

        function operador_eliminar(indice) {
            if (TareaCatOperador[indice]['estado'] == 'VACIO')
                return

            notificaciones_actualizar()
            primera_vez = false

            if (TareaCatOperador[indice]['estado'] == 'GUARDADO')
                TareaCatOperador[indice]['estado'] = 'BORRADO'
            
            if (TareaCatOperador[indice]['estado'] == 'NUEVO')
                TareaCatOperador.splice(indice, 1)

            dibujar_tarea_cat_operador()
        }

        function eliminar() {
            if ($('nro_tarea_cat_txt').value == 0)
                return

            nvFW.confirm("¿Desea eliminar esta categoria?", {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function(win) { win.close(); return },
                ok: function(win) {
                    $('nro_tarea_cat_txt').value = -$('nro_tarea_cat_txt').value //parseInt($('nro_tarea_cat_txt').value)* -1
                    guardar()
                    win.close()
                }
            });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF;">
    <form action="" id="FrmTarea" style="width: 100%; height: 100%; overflow: hidden">
        <input type="hidden" name="nro_tarea_cat_txt" id="nro_tarea_cat_txt" />
        <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
            <script language="javascript" type="text/javascript">
                var DocumentMNG = new tDMOffLine,
                    vMenu = new tMenu('divMenu','vMenu');

                Menus["vMenu"] = vMenu
                vMenu.alineacion = 'centro';
                vMenu.estilo = 'A';
                vMenu.loadImage("guardar", "/fw/image/icons/guardar.png")
                vMenu.loadImage("eliminar", "/wiki/image/icons/eliminar.png")
                vMenu.loadImage("nueva", "/fw/image/icons/nueva.png")
                
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva Categoria</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva()</Codigo></Ejecutar></Acciones></MenuItem>")
                
                vMenu.MostrarMenu()
            </script>
            <div id="divCabe" style="width: 100%">
            <table class="tb1">
                <tr style='height: 40px'>
                    <td colspan="6" style="width: 100%">
                        <table style="width: 100%">
                            <tr class='tbLabel'>
                                <td style='width: 4%'>- </td>
                                <td colspan="2">Listado de Categorías</td>
                            </tr>
                        </table>
                        <div id="divTareaCat" style='width: 100%; height: 120px; overflow: auto'></div>
                    </td>
                </tr>
            </table>
            <table style="display: none">
                <tr><td><%= nvFW.nvCampo_def.get_html_input("nro_operador")%></td></tr>
            </table>

            <table class='tb1'>
                <tr>
                    <td class='Tit1' style="width: 20%; text-align: right">Categoría:</td>
                    <td><input type="text" name="tarea_cat" id="tarea_cat" style='width: 100%' /></td>
                    <td class='Tit1' style="width: 20%">&nbsp;</td>
                </tr>
            </table>
            <div id="divMenuO" style="margin: 0px; padding: 0px;"></div>
            <script language="javascript" type="text/javascript">
                var DocumentMNG = new tDMOffLine,
                    vMenuO = new tMenu('divMenuO','vMenuO');

                Menus["vMenuO"]=vMenuO
                vMenuO.alineacion='centro';
                vMenuO.estilo='A';
                vMenuO.loadImage("vincular", "/wiki/image/icons/vincular.png")      
                vMenuO.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vincular</icono><Desc>Seleccionar Operador</Desc></MenuItem>")
                vMenuO.MostrarMenu()
            </script>
            <table id="tbCabe" class='tb1'>
                <tr class='tbLabel'>
                    <td style='width: 5%'></td>
                    <td colspan="2" style="width: 78%">Operador</td>
                    <td style='width: 5%; text-align:center' title='Cambiar Estado'>CE</td>
                    <td style='width: 5%; text-align:center' title='Progreso'>P</td>
                    <td style='width: 5%; text-align:center' title='Completo'>C</td>
                    <td style='width: 2%'><div style="overflow: scroll; height: 1px; width: 1px"></div></td>
                </tr>
            </table>
        </div>
        <div id="divTareaCatOperador" style="width: 100%; overflow: auto"></div>
    </form>
</body>
</html>
