<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Campo Def Tipo 3</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <% = Me.getHeadInit() %>
    
    <style type="text/css">
        input[type="button"]:hover { cursor: pointer; }
    </style>

    <script type="text/javascript">
        var win = nvFW.getMyWindow()
        var oCampo_def
        var rs

        function window_onload() 
        {
            nvFW.enterToTab = false
            oCampo_def = win.options.parameters.campo_def
            win.cancelado = true //por defecto si cierra la ventana
            win.campo_def_value = ""
            win.campo_desc = ""
            win.rs = null
 
            //Si viene con un valor cargado asignarlo
            var cb = $('cbLista')

            if (oCampo_def.input_hidden.value != '') {
                cb.options.length = 0
                cb.options.length++
                cb.options[cb.options.length-1].value = oCampo_def.input_hidden.value
                cb.options[cb.options.length-1].text = oCampo_def.input_text.value
            }

            cb.selectedIndex = 0
 
            try {
                $('txt_buscar').focus()
            }
            catch(e) {}
        }


        function buscar()
        {
            var filtroWhere = ""
            var cadena = $('txt_buscar').value
            var codigo = $('cod_buscar').value

            if (cadena == "" && codigo == "") {
                nvFW.alert("No hay valores de busqueda cargados",{width:370})
                return
            }
  
            if (cadena != "" && cadena.length < 3) {
                nvFW.alert("El texto ingresado tiene menos de 3 caracteres",{width:370})
                return
            }
  
            var campo_desc = oCampo_def.campo_desc  
            var campo_codigo = oCampo_def.campo_codigo  
            
            if (cadena != "")
                filtroWhere = "<" + campo_desc + " type='like'>%" + cadena + "%</" + campo_desc + ">"
            else if (oCampo_def.StringValueIncludeQuote)
                    filtroWhere = "<" + campo_codigo + " type='igual'>'" + codigo + "'</" + campo_codigo + ">"
                else
                    filtroWhere = "<" + campo_codigo + " type='igual'>" + codigo + "</" + campo_codigo + ">"

            $('cbLista').length = 0
            var objCb = $('cbLista')
            contros_disabled()
            xml_format = oCampo_def.json ? 'rs_xml_json' : 'rs_xml'
            cacheControl = oCampo_def.cacheControl
            filtroXML = oCampo_def.filtroXML
            vistaGuardada = oCampo_def.vistaGuardada
            rs = cargar_cbCodigo(objCb, '', 'id', 'campo', filtroWhere, '', 1, 1, filtroXML, true, function(){contros_enabled()}, function(){contros_enabled()}, xml_format, cacheControl, vistaGuardada, oCampo_def.StringValueIncludeQuote)
        }


        function contros_disabled()
        {
            $("txt_buscar").disabled = true
            $("cod_buscar").disabled = true
            $("btnBuscar").disabled = true
            $("btnOK").disabled = true
        }


        function contros_enabled()
        {
            $("txt_buscar").disabled = false
            $("cod_buscar").disabled = false
            $("btnBuscar").disabled = false
            $("btnOK").disabled = false
        }  


        function txt_buscar_onkeypress(e)
        {
            var key = Prototype.Browser.IE ? event.keyCode : e.which
            if (key == 13)
                buscar()
        }


        function cancelar()
        {
            win.close()
        }


        function aceptar()
        {
            var cb = $('cbLista')
            win.cancelado = false
            win.campo_def_value = cb.options[cb.selectedIndex].value
            win.campo_desc = cb.options[cb.selectedIndex].text
            //win.input_select = $('cbLista')
            win.input_select = cbLista_input_select()
            win.rs = rs
            win.close()
        }


        function limpiar()
        {
            $('cbLista').options.length = 0
            win.campo_def_value = ''
            win.campo_desc = ''
            // limpiar campos de busqueda
            $('txt_buscar').value = ""
            $('cod_buscar').value = ""
            win.close()
        }

        
        function cbLista_ondblclick() 
        {
            aceptar()
        }


        function cbLista_onkeypress(e) 
        {
            var key = !!e.srcElement ? event.keyCode : e.which
            if (key == 13)
              aceptar()
        }

        function cbLista_input_select() {
            var cbLista = {};
            cbLista.options = {};
            cbLista.options.length = $('cbLista').options.length;
            cbLista.options.selectedIndex = $('cbLista').options.selectedIndex;
            for (var i = 0; i < $('cbLista').options.length; i++)
                cbLista.options[i] = $('cbLista').options[i];
            return cbLista;

        }
    </script>
</head>
<body onload="return window_onload()" style="width:100%; height: 100%; overflow: hidden; background-color: #FFFFFF;">
    <table class="tb1">
        <tr class="tbLabel">
            <td colspan="3">Seleccionar</td>
        </tr>
        <tr class="tbLabel0">
            <td style="width: 70%">Descripción</td>
            <td style="width: 15%">&nbsp;Código&nbsp;</td>
            <td style="width: 15%">&nbsp;</td>
        </tr>
        <tr>
            <td style="width: 70%">
                <input type="text" id="txt_buscar" style="width: 100%" onkeypress="return txt_buscar_onkeypress(event)" onfocus="$('cod_buscar').value = ''" />
            </td>
            <td style="width: 15%">
                <input type="text" id="cod_buscar" style="width: 100%" onkeypress="return txt_buscar_onkeypress(event)" onfocus="$('txt_buscar').value = ''" />
            </td>
            <td style="width: 15%">
                <input type="button" id="btnBuscar" value="Buscar" style="width: 100%" onclick="return buscar()" />
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width: 100%" colspan="3">
                <select id='cbLista' style="width: 100%" size="9" ondblclick="return cbLista_ondblclick()" onkeypress="return cbLista_onkeypress(event)">
                    <option value=""></option>
                </select>
            </td>
        </tr>
        <tr>
            <td style="width: 33.3333%">
                <input type="button" id="btnOK" style="width: 100%" value="OK" onclick="return aceptar()" />
            </td>
            <td style="width: 33.3333%">
                <input type="button" id="btnCancelar" style="width: 100%" value="Cancelar" onclick="return cancelar()" />
            </td>
            <td style="width: 33.3333%">
                <input type="button" id="btnlimpiar" style="width: 100%" value="Limpiar" onclick="return limpiar()" />
            </td>
        </tr>
    </table>
</body>
</html>
