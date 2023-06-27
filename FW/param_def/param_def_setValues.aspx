<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Editar</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
     

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var default_accion = ""
        var params
        var callback_onSave
        var filtroHistorico
        var myWindow
        var vListButton
        var _parametro, cantidad_params_visibles, divMenuParametros_height = 0, _permite_titulo

        function window_onload()
        {
            myWindow = nvFW.getMyWindow()

            callback_onSave = myWindow.options.userData.onSave
            filtroHistorico = myWindow.options.userData.filtroHistorico

            params = myWindow.options.userData.params
            _permite_titulo = myWindow.options.userData.permite_titulo

            cantidad_params_visibles = params_dibujar()

            nvFW.bloqueo_desactivar($$('body')[0], 'bloq_params')

            if (cantidad_params_visibles > 1 || filtroHistorico == null) {
                $("divMenuParametros").hide()
            } else
                divMenuParametros_height = $$("#divMenuParametros")[0].getHeight()

            vListButton.MostrarListButton()

            window_onresize()
        }


        function window_onresize() {
            $('paramTbl').setStyle({ 'height': $$("body")[0].getHeight() - $$("#btnActions")[0].getHeight() - divMenuParametros_height });
        }


        function params_dibujar() {
            
            cantidad_params_visibles = 0
            
            $('tableEdit').innerHTML = "";

            for (var i = 0; i < params.length; i++) {
                var param = params[i];

                if (param.visible === false && param.tipo_dato != "title")
                  $$('#tableNoVisible')[0].insert('<tr><td id="tnv_' + i + '" ></td></tr>');

                if (param.visible !== false && param.tipo_dato != "title")
                    $$('#tableEdit')[0].insert('<tr><td class="Tit2" width="10%" nowrap>' + param.etiqueta + ':</td><td id="t_' + i + '" ></td></tr>');
                
                if (param.tipo_dato == "title" && _permite_titulo == true)
                    $$('#tableEdit')[0].insert('<tr class="Tit2"><td id="param_' + param.parametro + '"style="text-align:center" colspan="2"><b>' + param.etiqueta + '</b></td></tr >');
            }
            
            for (var i = 0; i < params.length; i++) {
                var param = params[i];
                if (param.tipo_dato != "title") {

                    if (param.visible === false) {
                        if (param.campo_def == "") {
                            var tc = 104
                            if (param.tipo_dato == 'int')
                                tc = 100
                            if (param.tipo_dato == 'datetime')
                                tc = 103
                            campos_defs.add(param.parametro, { target: "tnv_" + i, nro_campo_tipo: tc, enDB: false })
                            campos_defs.set_value(param.parametro, param.valor)
                        }
                        else if (param.campo_def != "") {
                            campos_defs.add(param.campo_def, { target: "tnv_" + i })
                            campos_defs.set_value(param.campo_def, param.valor)
                        }
                    }
                    else {
                    
                        _parametro = param
                        cantidad_params_visibles = cantidad_params_visibles += 1

                        if (param.campo_def != "") {
                            campos_defs.add(param.campo_def, { target: "t_" + i })
                            campos_defs.set_value(param.campo_def, param.valor)
                            campos_defs.habilitar(param.campo_def, param.editable === true)
                        }
                        else if (param.tipo_dato == 'bit') {
                            $('t_' + i).innerHTML = '<input style="text-align:left" id="' + param.parametro + '" type= "checkbox" value="' + param.valor + '" title="' + param.valor + '" ' + (param.editable == false ? "disabled" : "") + '/>'
                            param.valor == '1' ? $(param.parametro).checked = true : $(param.parametro).checked = false
                        }
                        else {
                            var valor = param.valor
                            switch (param.tipo_dato) {
                                case 'int':
                                    campos_defs.add(param.parametro, { nro_campo_tipo: 100, enDB: false, target: "t_" + i })
                                    break
                                case 'datetime':
                                    campos_defs.add(param.parametro, { nro_campo_tipo: 103, enDB: false, target: "t_" + i })
                                    break
                                case 'decimal':
                                case 'money':
                                    campos_defs.add(param.parametro, { nro_campo_tipo: 102, enDB: false, target: "t_" + i })
                                    break
                                default:
                                    campos_defs.add(param.parametro, { nro_campo_tipo: 104, enDB: false, target: "t_" + i })
                            }
                            campos_defs.set_value(param.parametro, valor)
                            campos_defs.habilitar(param.parametro, param.editable === true)
                        }
                    }
                }
            }

            return cantidad_params_visibles
        }

        function cancelar() { myWindow.close() }

        function guardar() {
            var paramsTemp = []
            //validar los requeridos
            for (var i = 0; i < params.length; i++) {
                var param = params[i];
                var valor = param.valor
                if (param.visible !== false && param.tipo_dato != "title") {
                    if (param.editable) {
                        if (param.tipo_dato == 'bit') {
                            valor = $(param.parametro).checked ? "1" : "0"
                        }
                        else {
                            valor = param.campo_def ? campos_defs.get_value(param.campo_def) : campos_defs.get_value(param.parametro)
                        }

                        if (param.requerido && !valor) {
                            alert("No ha ingresado el valor para <b>" + param.etiqueta + "</b>")
                            return
                        }   
                    }
                }
                
                paramsTemp.push(new tParam_def({
                    parametro: param.parametro
                    , valor: valor
                    , etiqueta: param.etiqueta
                    , tipo_dato: param.tipo_dato
                    , campo_def: param.campo_def
                    , requerido: param.requerido
                    , editable: param.editable
                    , visible: param.visible
                }))
            }

            var er = callback_onSave(paramsTemp)
            if (er.numError != 0)
                alert(er.message)
            else
                myWindow.close()
        }


        function listar_log_ent_param_valor() {
            var options = {
                    width: 400,
                    height: 200,
                    maximizable: true,
                    minimizable: false,
                    title: "<b>Histórico " + _parametro.etiqueta + "</b>"
            }

            nvFW.param_def_history(_parametro.parametro, options, filtroHistorico)
        }

    </script>
</head>
<body style="overflow: auto;" onload="window_onload()" onresize="window_onresize()">
    <script type="text/javascript">nvFW.bloqueo_activar($$('body')[0], 'bloq_params', 'Cargando...')</script>
    <form onsubmit="return false;" autocomplete="off">
        <div id="divMenuParametros"></div>
        <div id="paramTbl" style="overflow:auto">
            <table class="tb1" style="display:none !Important">
                <tbody id="tableNoVisible"></tbody>
            </table>
            <table class="tb1">
                <tbody id="tableEdit"></tbody>
            </table>
        </div>
        <table id="btnActions" class="tb1">
            <tr>
                <td style="width:10%"></td>
                <td style="width:40%">
                    <div id="divAceptar" style="width: 100%"></div>
                </td>
                <td style="width:40%">
                    <div id="divCancelar" style="width: 100%"></div>
                </td>
                <td style="width:10%"></td>
            </tr>
        </table>
        <script type="text/javascript">
            var vMenuParametros = new tMenu('divMenuParametros', 'vMenuParametros');
            Menus["vMenuParametros"] = vMenuParametros;
            Menus["vMenuParametros"].alineacion = 'centro';
            Menus["vMenuParametros"].estilo = 'A';
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Histórico</Desc><Acciones><Ejecutar Tipo='script'><Codigo>listar_log_ent_param_valor()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuParametros.MostrarMenu()

            var vButtonItems = {}
            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "Aceptar";
            vButtonItems[0]["etiqueta"] = "Aceptar";
            vButtonItems[0]["imagen"] = "confirmar";
            vButtonItems[0]["onclick"] = "return guardar()";
            vButtonItems[1] = {}
            vButtonItems[1]["nombre"] = "Cancelar";
            vButtonItems[1]["etiqueta"] = "Cancelar";
            vButtonItems[1]["imagen"] = "cancelar";
            vButtonItems[1]["onclick"] = "return cancelar()";

            vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("confirmar", '/FW/image/icons/confirmar.png');
            vListButton.loadImage("cancelar", '/FW/image/icons/cancelar.png');
        </script>
    </form>
</body>
</html>