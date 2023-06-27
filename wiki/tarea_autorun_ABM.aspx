<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim numError = 0
    Dim nro_tarea = nvFW.nvUtiles.obtenerValor("nro_tarea", "nro_tarea")
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")

    If (modo <> "" And strXML <> "") Then

        Dim Err = New nvFW.tError()
        Try
            Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand("tarea_autorun_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvFW.nvDBUtiles.emunDBType.db_app, , , , , )
            Cmd.Parameters.Append(Cmd.CreateParameter("@strXML", 200, 1, 8000, strXML))

            Dim rs = Cmd.Execute()
            Dim nro_tarea_autorun = rs.Fields("nro_tarea_autorun").Value
            Err.params("nro_tarea_autorun") = nro_tarea_autorun
            rs.close()

            Err.numError = 0
            Err.mensaje = ""
        Catch e As Exception
            Err.parse_error_script(e)
        End Try
        Err.response()
    End If
%>
<html>
<head>
    <title>Tarea Autorun ABM</title>

    <meta http-equiv="x-ua-compatible" content="IE=8" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <script type="text/javascript">
        
        var Imagenes = [];
        
        Imagenes["eliminar"] = new Image();
        Imagenes["eliminar"].src = '/FW/image/icons/eliminar.png';
        Imagenes["guardar"] = new Image();
        Imagenes["guardar"].src = '/FW/image/icons/guardar.png';
        Imagenes["agregar"] = new Image();
        Imagenes["agregar"].src = '/FW/image/icons/agregar.png';
        Imagenes["nuevo"] = new Image();
        Imagenes["nuevo"].src = '/FW/image/icons/nueva.png';

        function isNULL(valor, retorno) {
            return valor == null ? retorno : valor
        }

        function tarea_autorun_cargar(evento, i) {
            //actualizar anterior
            actualizar()

            if (evento != null) {
                var strError = validar()
                if (strError != '') {
                    try {
                        if ($('indice').value >= 0)
                            document.all.radio[$('indice').value].checked = true
                    } catch (e) { }
                    alert(strError)
                    return
                }
            }

            //carga el seleccionado       
            $('indice').value = i
            $('nro_tarea_autorun').value = TareaAutorun[i].nro_tarea_autorun
            $('cod_sistema').value = TareaAutorun[i].cod_sistema
            $('servidor').value = isNULL(TareaAutorun[i].servidor, '')
            $('puerto').value = isNULL(TareaAutorun[i].puerto, '')
            $('url').value = isNULL(TareaAutorun[i].url, '')
            $('metodo').value = isNULL(TareaAutorun[i].metodo, '')
            $('id_transferencia').value = isNULL(TareaAutorun[i].id_transferencia, '')
            $('transferencia').value = isNULL(TareaAutorun[i].transferencia, '')

            if ($('id_transferencia').value > 0)
                $('ejecucion').value = 'T'
            else
                $('ejecucion').value = 'U'

            onchange_ejecucion()

            parametros_dibujar()

        }

        function parametros_dibujar() {
            $('divParametros').innerHTML = ""

            var strHTML = "<table style='width: 100%' id='tbParametros'>"
            TareaAutorun[$('indice').value].Parametros.each(function (arreglo_i, index) {
                strHTML += "<tr>"
                strHTML += "<td style='width:2%'><a style='cursor:hand;cursor:pointer'><img src='/FW/image/icons/eliminar.png' border='0' hspace='0' alt='Eliminar Parametro' onclick='parametro_eliminar(" + index + ")'/></a></td>"
                strHTML += "<td style='width: 30%; vertical-align:middle' nowrap><input type='text' id='parametro" + index + "' value='" + arreglo_i['parametro'] + "' style='width: 100%; text-align: left' /></td>"
                strHTML += "<td style='vertical-align:middle' nowrap><input type='text' id='valor" + index + "' value='" + arreglo_i['valor'] + "' style='width: 100%; text-align: left' /></td>"
                strHTML += "<td style='width:20px' id='tdScroll" + index + "'>&nbsp;</td>"
                strHTML += "</tr>"
            });

            strHTML += "</table>"
            $('divParametros').insert({ top: strHTML })
        }

        function parametro_nuevo() {
            if ($('indice').value == '' || $('indice').value == -1)
                nuevo()

            parametro_actualizar()

            var indice = TareaAutorun[$('indice').value].Parametros.length
            TareaAutorun[$('indice').value].Parametros[indice] = new Array()
            TareaAutorun[$('indice').value].Parametros[indice]['parametro'] = ''
            TareaAutorun[$('indice').value].Parametros[indice]['valor'] = ''

            parametros_dibujar()

            window_onresize()
        }

        function parametro_eliminar(indice) {
            parametro_actualizar()

            TareaAutorun[$('indice').value].Parametros.splice(indice, 1)
            parametros_dibujar()
        }

        function parametro_actualizar() {
            TareaAutorun[$('indice').value].Parametros.each(function (arreglo_h, inde_h) {
                arreglo_h["parametro"] = $('parametro' + inde_h).value
                arreglo_h["valor"] = $('valor' + inde_h).value
            });
        }

        function actualizar() {
            if ($('indice').value == '' || $('indice').value == -1)
                return

            var metodo = ""
            if ($('ejecucion').value == 'T')
                $('url').value = ''

            if ($('ejecucion').value == 'U') {
                metodo = $('metodo').value
                $('servidor').value = ''
                $('cod_sistema').value = ''
                $('id_transferencia').value = ''
                $('puerto').value = ''
            }

            TareaAutorun[$('indice').value].nro_tarea_autorun = $('nro_tarea_autorun').value
            TareaAutorun[$('indice').value].url = $('url').value
            TareaAutorun[$('indice').value].metodo = metodo
            TareaAutorun[$('indice').value].servidor = $('servidor').value
            TareaAutorun[$('indice').value].cod_sistema = $('cod_sistema').value
            TareaAutorun[$('indice').value].id_transferencia = $('id_transferencia').value
            TareaAutorun[$('indice').value].transferencia = $('transferencia').value
            TareaAutorun[$('indice').value].puerto = $('puerto').value

            TareaAutorun[$('indice').value].Parametros.each(function (arreglo_p, inde_p) {
                arreglo_p["parametro"] = $('parametro' + inde_p).value
                arreglo_p["valor"] = $('valor' + inde_p).value
            });
        }

        var TareaAutorun = new Array()
        function window_onload() {
            parent.TareaAutorun.each(function (array, i) {
                TareaAutorun[i] = new Array()
                TareaAutorun[i].nro_tarea_autorun = array.nro_tarea_autorun
                TareaAutorun[i].cod_sistema = array.cod_sistema
                TareaAutorun[i].servidor = array.servidor
                TareaAutorun[i].puerto = array.puerto
                TareaAutorun[i].url = array.url
                TareaAutorun[i].metodo = array.metodo
                TareaAutorun[i].id_transferencia = array.id_transferencia
                TareaAutorun[i].transferencia = array.transferencia
                TareaAutorun[i].estado = array.estado
                TareaAutorun[i].Parametros = new Array()

                array.Parametros.each(function (arreglo_p, p) {
                    TareaAutorun[i].Parametros[p] = new Array();
                    TareaAutorun[i].Parametros[p]["parametro"] = arreglo_p.parametro
                    TareaAutorun[i].Parametros[p]["valor"] = arreglo_p.valor
                });
            });

            $('ejecucion').value = 'T'
            onchange_ejecucion()

            if (TareaAutorun.length == 0) {
                $('tbCabe1').hide()
                $('tbCabeT').hide()
                $('tbCabeU').hide()
                $('tbCabeParametros').hide()
                $('divMenuP').hide()
            }

            autorun_de_tarea_cargar()
            window_onresize()

        }

        function guardar() {
            actualizar()

            var strError = validar()
            if (strError != '') {
                alert(strError)
                return
            }

            parent.TareaAutorun = new Array()
            TareaAutorun.each(function (array, i) {
                parent.TareaAutorun.push(array)
            });

            win.close()
        }

        var win = nvFW.getMyWindow()

        function validar() {

            var strError = ''

            if ($('indice').value == -1)
                return strError

            strError = validar_parametros()

            if (strError != '')
                return strError

            if ($('ejecucion').value == 'U') {
                if ($('url').value == '')
                    strError += 'El campo URL está vacio.</br>'

                if ($('metodo').value == '')
                    strError += 'El campo Metodo está vacio.</br>'
            }

            if ($('ejecucion').value == 'T') {
                if ($('servidor').value == '')
                    strError += 'El campo servidor está vacio.</br>'

                if ($('cod_sistema').value == '')
                    strError += 'El campo sistema está vacio.</br>'

                if ($('id_transferencia').value == '')
                    strError += 'El campo Transferencia está vacio.</br>'
            }

            return strError

        }

        function validar_parametros() {
            var strError = ''

            TareaAutorun[$('indice').value].Parametros.each(function (arreglo_p, p) {
                if (strError == '') {
                    if (arreglo_p.parametro == '')
                        strError = 'Un parametro se encuentra vacio.</br>'
                    //             if (arreglo_p.valor == '')
                    //                 strError = 'Un valor de algún parametro está vacio.</br>'
                }
            });

            return strError
        }

        function eliminar() {

            if ($('indice').value == -1)
                return

            nvFW.confirm("¿Desea eliminar el autorun?", {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function(win) {
                    win.close();
                    return
                },
                ok: function(win) {
                    if ($('nro_tarea_autorun').value == 0)
                        TareaAutorun.splice($('indice').value, 1)
                    else {
                        TareaAutorun[$('indice').value].estado = 'borrado'
                        TareaAutorun[$('indice').value].nro_tarea_autorun = parseInt($('nro_tarea_autorun').value) * -1
                    }

                    limpiar()
                    $('indice').value = -1
                    autorun_de_tarea_cargar()

                    if (TareaAutorun.length == 0) {
                        $('tbCabe1').hide()
                        $('tbCabeT').hide()
                        $('tbCabeU').hide()
                        $('tbCabeParametros').hide()
                        $('divMenuP').hide()
                    }

                    win.close()
                }
            });
        }

        function limpiar() {
            $('indice').value = -1
            $('nro_tarea_autorun').value = 0
            $('cod_sistema').value = ''
            $('servidor').value = ''
            $('puerto').value = ''
            $('url').value = ''
            $('metodo').value = 'get'
            $('id_transferencia').value = ''
            $('transferencia').value = ''
            $('ejecucion').value = 'T'
            onchange_ejecucion()
            $('divParametros').innerHTML = ""
        }

        function nuevo() {
            if (TareaAutorun.length == 0) {
                $('tbCabe1').show()
                $('tbCabeT').show()
                $('tbCabeU').show()
                $('tbCabeParametros').show()
                $('divMenuP').show()
            }

            //actualiza anterior si existe
            actualizar()

            var strError = validar()
            if (strError != '') {
                alert(strError)
                return
            }

            limpiar()

            var i = TareaAutorun.length
            //$('indice').value = i
            TareaAutorun[i] = new Array()
            TareaAutorun[i].nro_tarea_autorun = 0
            TareaAutorun[i].cod_sistema = ''
            TareaAutorun[i].servidor = ''
            TareaAutorun[i].puerto = ''
            TareaAutorun[i].url = ''
            TareaAutorun[i].metodo = 'get'
            TareaAutorun[i].id_transferencia = ''
            TareaAutorun[i].transferencia = ''
            TareaAutorun[i].estado = ''
            TareaAutorun[i].Parametros = new Array()

            autorun_de_tarea_cargar()

        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                divMenu_h = $('divMenu').getHeight()
                tbCabe1_h = $('tbCabe1').getHeight()
                tbCabeT_h = $('tbCabeT').getHeight()
                tbCabeU_h = $('tbCabeU').getHeight()
                divMenuP_h = $('divMenuP').getHeight()
                tbCabeParametros_height = $('tbCabeParametros').getHeight()
                divMenu0_h = $('divMenu0').getHeight()
                divRelacion_h = $('divRelacion').getHeight()
                tbRelacion_h = $('tbRelacion').getHeight()

                $('divParametros').setStyle({ 'height': body_height - divMenu_h - divMenuP_h - tbCabeT_h - tbCabeU_h - tbCabe1_h - tbCabe2_h - tbCabeParametros_height - divMenu0_h - tbRelacion_h - divRelacion_h - dif })

                $('tbParametros').getHeight() - $('divParametros').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
            }
            catch (e) { }
        }

        function tdScroll_hide_show(show) {
            var i = 0
            while (i < Parametros.length) {
                if (show && $('tdScroll' + i) != undefined)
                    $('tdScroll' + i).show()

                if (!show && $('tdScroll' + i) != undefined)
                    $('tdScroll' + i).hide()
                i++
            }
        }


        function autorun_de_tarea_cargar() {
            $('divRelacion').innerHTML = ""
            var strHTML = "<table class='tb1' style='width:100%'>"
            var ultimo = -1
            TareaAutorun.each(function (array, i) {

                if (array.estado == '') {
                    strHTML += '<tr>'
                    strHTML += '<td style="width:2%;text-align:center"><input type="radio" name="radio" value="' + array.nro_tarea_autorun + '" checked="checked" style="border:none" onclick="return tarea_autorun_cargar(event, ' + i + ')"></input></td>'
                    strHTML += '<td style="width:5%;text-align:right">' + array.nro_tarea_autorun + '</td>'
                    strHTML += '<td style="width:30%;text-align:left">' + array.servidor
                    if (isNULL(array.puerto, '') != '')
                        strHTML += ' : ' + isNULL(array.puerto, '')
                    strHTML += '</td>'
                    strHTML += '<td style="width:15%;text-align:left">' + array.cod_sistema + '</td>'
                    strHTML += '<td style="text-align:left">' + array.url + '</td>'
                    strHTML += '<td style="width:5%;text-align:left">' + isNULL(array.id_transferencia, '') + '</td>'
                    strHTML += '</tr>'
                    ultimo = i
                }
            });

            strHTML += "</table>"
            $('divRelacion').insert({ top: strHTML })

            try {
                //$('indice').value = ultimo
                tarea_autorun_cargar(null, ultimo)
                document.all.radio[ultimo].checked = true
            }
            catch (e) { }

        }

        function onchange_ejecucion() {

            if ($('ejecucion').value == 'U') {
                $('tbCabeT').hide()
                $('tbCabeU').show()
                $('btnBuscarTransf').hide()
            }

            if ($('ejecucion').value == 'T') {
                $('tbCabeU').hide()
                $('tbCabeT').show()
                $('btnBuscarTransf').show()
            }

            window_onresize()

        }

    </script>

    <style type="text/css">
        .tr_cel TD {
            background-color: #F0FFFF !Important;
        }
    </style>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="height: 100%; vertical-align: middle; overflow: hidden">
    <form name="Frm" action="" method="post" target="frameEnviar" style="height: 100%; vertical-align: middle; overflow: hidden">
        <div id="divMenu0" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenu0 = new tMenu('divMenu0', 'vMenu0');
            Menus["vMenu0"] = vMenu0
            Menus["vMenu0"].alineacion = 'centro';
            Menus["vMenu0"].estilo = 'A';
            Menus["vMenu0"].imagenes = Imagenes 
            Menus["vMenu0"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu0"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenu0"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenu0.MostrarMenu()
        </script>
        <table id="tbRelacion" class="tb1" style="width: 100%">
            <tr class="tbLabel">
                <td style='width: 2%'>&nbsp;</td>
                <td style='width: 5%; text-align: center'>Autorun</td>
                <td style='width: 30%; text-align: center'>Servidor :Puerto</td>
                <td style='width: 15%; text-align: center'>Sistema</td>
                <td style='text-align: center'>URL</td>
                <td style='width: 5%; text-align: center'>T</td>
            </tr>
        </table>
        <div id="divRelacion" style="width: 100%; height: 100px; overflow: auto"></div>
        <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].imagenes = Imagenes 
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 90%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenu.MostrarMenu()
        </script>

        <table class="tb1" id="tbCabe1" style='width: 100%'>
            <tr>
                <td class="Tit1" style="width: 2%">Nro.</td>
                <td style="width: 10%">
                    <input type="hidden" name="indice" id="indice" value="-1" /><input type="text" name="nro_tarea_autorun" id="nro_tarea_autorun" style="width: 100%" disabled="disabled" /></td>
                <td class="Tit1" style="width: 8%; text-align: right">Ejecución:</td>
                <td style="width: 40%">
                    <select id="ejecucion" style="width: 50%" onchange="return onchange_ejecucion()">
                        <option value="U">URL</option>
                        <option value="T">Transferencia</option>
                    </select>&nbsp;<input type="button" style="width: 48%" id="btnBuscarTransf" value="Buscar Transferencia" onclick="return alert('en desarrollo')" /></td>
                <td>&nbsp;</td>
            </tr>
        </table>
        <table class="tb1" id="tbCabeT" style='width: 100%'>
            <tr class="tbLabel">
                <td>Servidor :Puerto</td>
                <td style="width: 20%">Sistema</td>
                <td style="width: 40%">Transferencia</td>
            </tr>
            <tr>
                <td>
                    <input type="text" name="servidor" id="servidor" style="width: 80%" />&nbsp;:<input type="text" name="puerto" id="puerto" style="width: 15%; text-align: right" maxlength="6" onkeypress="return valDigito(event)" /></td>
                <td>
                    <input type="text" name="cod_sistema" id="cod_sistema" style="width: 100%" /></td>
                <td style="text-align: left">
                    <input type="text" name="id_transferencia" id="id_transferencia" onkeypress="return valDigito(event)" style="width: 15%" /><input type="text" style="width: 85%" name="transferencia" id="transferencia" value="" /></td>
            </tr>
        </table>
        <table class="tb1" id="tbCabeU" style='width: 100%'>
            <tr>
                <td class="Tit1" style="width: 8%">URL:</td>
                <td style="width: 70%">
                    <input type="text" style="width: 100%" name="url" id="url" /></td>
                <td class="Tit1" style="width: 8%">Metodo:</td>
                <td>
                    <select id="metodo" style="width: 100%">
                        <option value="get">GET</option>
                        <option value="post">POST</option>
                    </select></td>
            </tr>
        </table>

        <div id="divMenuP" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuP = new tMenu('divMenuP', 'vMenuP');
            Menus["vMenuP"] = vMenuP
            Menus["vMenuP"].alineacion = 'centro';
            Menus["vMenuP"].estilo = 'A';
            Menus["vMenuP"].imagenes = Imagenes 
            Menus["vMenuP"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Parametros</Desc></MenuItem>")
            Menus["vMenuP"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametro_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuP.MostrarMenu()
        </script>
        <table id="tbCabeParametros" class="tb1" style="width: 100%">
            <tr class='tbLabel'>
                <td style='width: 2%'>&nbsp;</td>
                <td style='width: 30%; text-align: center'>Parámetro</td>
                <td style='text-align: center'>Valor</td>
                <td style='width: 20px'>&nbsp;</td>
            </tr>
        </table>
        <div id="divParametros" style="width: 100%; overflow: auto"></div>

    </form>
</body>
</html>
