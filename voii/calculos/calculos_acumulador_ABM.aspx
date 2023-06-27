<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim strXML = obtenerValor("strXML", "")
    Dim modo = obtenerValor("modo", "")

    Me.contents("filtro_calc_acumuladores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_acumuladores'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    If (modo.ToUpper() = "M") then
        Dim err = new tError()
        ' Obtener Datos
        Try

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_calculo_acumulador_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            If (Not rs.EOF) Then

                Dim nro_calc_acum = rs.Fields("nro_calc_acum").Value
                err.params("nro_calc_acum") = nro_calc_acum
                err.numError = 0
                err.mensaje = nro_calc_acum


            End If

        Catch e as exception
            err.parse_error_script(e)
        end try
        err.response()
    end if

%>

<html>
<head>
    <title>Cálculo de Comisiones</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()
        var Acumulador = new Array()
        var nro_calc_acum

        function window_onload() {
            if (win.options.userData.nro_calc_acum) {
                nro_calc_acum = win.options.userData.nro_calc_acum
                acumulador_datos_cargar(nro_calc_acum)
            }
            else
                acumulador_nuevo()
            window_onresize()
        }



        function acumulador_datos_cargar() {
            var rs = new tRS();
            rs.open(nvFW.pageContents.filtro_calc_acumuladores, "", "<nro_calc_acum type='igual'>" + nro_calc_acum + "</nro_calc_acum>")
            if (!rs.eof()) {
                Acumulador['nro_calc_acum'] = rs.getdata('nro_calc_acum')
                Acumulador['calc_acum'] = rs.getdata('calc_acum')
                Acumulador['base_calc'] = rs.getdata('base_calc')
                Acumulador['calc_tipo'] = rs.getdata('calc_tipo')
                Acumulador['calc_campo'] = rs.getdata('calc_campo')
                Acumulador['cond_var'] = rs.getdata('cond_var')
                Acumulador['cond_fija'] = rs.getdata('cond_fija')
                Acumulador['suma_dependientes'] = rs.getdata('suma_dependientes') == 'True' ? 1 : 0
            }

            //$('indice').value = i
            $('nro_calc_acum').value = Acumulador['nro_calc_acum'] == null ? '' : Acumulador['nro_calc_acum']
            $('calc_acum').value = Acumulador['calc_acum'] == null ? '' : Acumulador['calc_acum']
            $('base_calc').value = Acumulador['base_calc'] == null ? '' : Acumulador['base_calc']
            $('calc_tipo').value = Acumulador['calc_tipo'] == null ? '' : Acumulador['calc_tipo']
            $('calc_campo').value = Acumulador['calc_campo'] == null ? '' : Acumulador['calc_campo']
            $('suma_dependientes').checked = Acumulador['suma_dependientes']
            $('cond_var').value = Acumulador['cond_var'] == null ? '' : Acumulador['cond_var']
            $('cond_fija').value = Acumulador['cond_fija'] == null ? '' : Acumulador['cond_fija']
        }


        function acumulador_nuevo() {
            //$('indice').value = Acumuladores.length
            $('nro_calc_acum').value = 0
            $('calc_acum').value = ''
            $('base_calc').value = ''
            $('calc_tipo').value = ''
            $('calc_campo').value = ''
            $('suma_dependientes').checked = false
            $('cond_var').value = ''
            $('cond_fija').value = ''
        }


        function acumulador_guardar() {
            var cond_var = '<![CDATA[' + $('cond_var').value + ']]>'
            var cond_fija = '<![CDATA[' + $('cond_fija').value + ']]>'

            var xmldato = ''
            xmldato = "<?xml version='1.0' encoding='iso-8859-1' ?>"
            xmldato += "<calc_acumuladores nro_calc_acum = '" + $('nro_calc_acum').value + "' calc_acum = '" + $('calc_acum').value + "' base_calc = '" + $('base_calc').value + "' calc_tipo = '" + $('calc_tipo').value + "' calc_campo = '" + $('calc_campo').value + "' suma_dependientes = '" + $('suma_dependientes').checked + "'>"
            xmldato += "<cond_var>" + cond_var + "</cond_var>"
            xmldato += "<cond_fija>" + cond_fija + "</cond_fija>"
            xmldato += "</calc_acumuladores>"

            nvFW.error_ajax_request('calculos_acumulador_ABM.aspx', {
                parameters: { modo: 'M', strXML: xmldato },
                onSuccess: function (err, transport) {

                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    else {
                        nro_calc_acum = err.params['nro_calc_acum']
                        win.options.userData = { parametros: nro_calc_acum }
                        win.close()
                    }
                }
            });

        }


        function acumulador_guardar_como() {
            Acumulador['nro_calc_acum'] = 0
            $('nro_calc_acum').value = 0
        }


        function acumulador_eliminar() {
            Dialog.confirm("¿Desea eliminar el Acumulador seleccionado?", {
                width: 300,
                className: "alphacube",
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {

                    $('nro_calc_acum').value = $('nro_calc_acum').value * -1
                    acumulador_guardar()
                    win.close()
                }
            });
        }

        function window_onresize() {

        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuAcumulador" style="width: 100%; margin: 0px; padding: 0px"></div>
    <script type="text/javascript">
        var vMenuAcumulador = new tMenu('divMenuAcumulador', 'vMenuAcumulador');
        Menus["vMenuAcumulador"] = vMenuAcumulador
        Menus["vMenuAcumulador"].alineacion = 'centro';
        Menus["vMenuAcumulador"].estilo = 'A';

        vMenuAcumulador.loadImage("guardar", '/FW/image/icons/guardar.png')
        vMenuAcumulador.loadImage("nuevo", "/FW/image/icons/nueva.png");
        vMenuAcumulador.loadImage('eliminar', '/FW/image/icons/eliminar.png')

        Menus["vMenuAcumulador"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>acumulador_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAcumulador"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar Como</Desc><Acciones><Ejecutar Tipo='script'><Codigo>acumulador_guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAcumulador"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuAcumulador"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>acumulador_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAcumulador"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>acumulador_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuAcumulador.MostrarMenu()
    </script>

    <table id="tb_acumulador_abm" class="tb1" style="vertical-align: top">
        <tr class="tbLabel0">
            <td style="width: 4%; text-align: center">Nro.</td>
            <td style="width: 20%; text-align: center">Acumulador</td>
            <td style="text-align: center">Base</td>
            <td style="width: 10%; text-align: center">Tipo Calculo</td>
            <td style="width: 15%; text-align: center">Campo</td>
            <td style="width: 15%; text-align: center">Suma Dependientes</td>
        </tr>
        <tr>
            <td style="width: 4%; text-align: center">
                <input type="hidden" id="indice" name="indice" value="" style="width: 100%" /><input type="text" id="nro_calc_acum" name="nro_calc_acum" disabled="disabled" value="" style="width: 100%" /></td>
            <td style="width: 18%; text-align: left">
                <input type="text" id="calc_acum" name="calc_acum" value="" style="width: 100%" /></td>
            <td style="text-align: left">
                <input type="text" id="base_calc" name="base_calc" value="" style="width: 100%" ondblclick="ver_editor(this)" /></td>
            <td style="width: 8%; text-align: left">
                <select name="calc_tipo" id="calc_tipo" style="width: 100%">
                    <option value="sum">sum</option>
                    <option value="count">count</option>
                </select>
            </td>
            <td style="width: 18%; text-align: left">
                <input type="text" id="calc_campo" name="calc_campo" value="" style="width: 100%" /></td>
            <td style="width: 6%; text-align: right">
                <input type="checkbox" id="suma_dependientes" name="suma_dependientes" style="width: 100%" /></td>
        </tr>
        <tr class="tbLabel0">
            <td style="width: 50%; text-align: center" colspan='3'>Condición Variable</td>
            <td style="width: 50%; text-align: center" colspan='4'>Condición Fija</td>
        </tr>
        <tr>
            <td style="width: 50%; text-align: left" colspan='3'>
                <textarea style='text-align: left; width: 100%; overflow: auto; resize: none' rows="8" cols="135" name="cond_var" id="cond_var"></textarea></td>
            <td style="width: 50%; text-align: left" colspan='4'>
                <textarea style='text-align: left; width: 100%; overflow: auto; resize: none' rows="8" cols="135" name="cond_fija" id="cond_fija"></textarea></td>
        </tr>
    </table>

</body>
</html>
