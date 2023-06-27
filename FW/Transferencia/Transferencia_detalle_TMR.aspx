<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
<head>
<title>Transferencia Detalle TMP</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javaScript" src="/FW/script/tScript.js"></script>     
    <script type="text/javascript" language="javaScript" src="/FW/script/tCampo_def.js"></script>     
             
    <style type="text/css">
            hr.clear {
                clear: both;
                margin: 1px;
            }
            #table_cont td {
                vertical-align: top;
            }
            .radios label {
                position: relative;
                top: -2px;
            }
            div.radios {
                width: 100px;
                float: left;
                min-height: 20px;
            }
            div.ocultable {
                width: 100%;
                margin-left: 100px;
            }
            div.ocultable select,
            div.ocultable input[type="text"]{
                height: 19px;
            }
            input[type=text],
            select {
                min-width: 150px;
                margin: 2px;
            }
        </style>
        <script type="text/javascript" language="javascript">
            var transferencia;
            var timer;
            var indice = parseInt('<%= nvUtiles.obtenerValor("indice") %>');
            function makeDom() {
                campos_defs.add('r_valor_desp_cd', {
                    enDB: false,
                    target: 'r_valor_desp',
                    nro_campo_tipo: 100
                });
                campos_defs.add('a_valor_base_cd', {
                    enDB: false,
                    target: 'a_valor_base',
                    nro_campo_tipo: 103
                });
                
                $$('.ocultable').each(function(ocultable) {
                    ocultable.hide();
                });
                var datetime_options = '';
                var int_options = '';
//                var datetime_options = '<option value=""></option>';
//                var int_options = '<option value=""></option>';
                transferencia.parametros.each(function(parametro) {
                    if (parametro.tipo_dato == 'datetime') {
                        datetime_options += '<option value="' + parametro.parametro + '">' + parametro.parametro + '</option>';
                    } else if (parametro.tipo_dato == 'int') {
                        int_options += '<option value="' + parametro.parametro + '">' + parametro.parametro + '</option>';
                    }
                });
                $$('select.params_datetime').each(function(select) {
                    select.update(datetime_options);
                });
                $$('select.params_int').each(function(select) {
                    select.update(int_options);
                });
                $$('input[type="radio"]').each(function(radio) {
                    radio.observe('change', function() {
                        listener_radio_change(radio);
                    });
                });
                $('r_a_que').observe('change', function(){
                    listener_relativo();
                });
                $('usa_param_check').observe('change', function(){
                    listener_checkbox();
                });
                $('a_a_que').observe('change', function(){
                    listener_absoluto();
                });
            }
            function window_onload() {
                transferencia = parent.return_Transferencia();
                timer = transferencia['detalle'][indice];
                
                makeDom();
                loadParameters();
            }
            function loadParameters() {
                if (timer.parametros_extra.tipo == 'relativo') {
                    $('rel').checked = true;
                    listener_radio_change($('rel'));
                    
                    setValue($('r_a_que'), timer.parametros_extra.r_a_que);
                    setValue($('r_parametro_base'), timer.parametros_extra.r_parametro_base);
                    setValue($('r_unidad'), timer.parametros_extra.r_unidad);

                    $('usa_param_check').checked = timer.parametros_extra.r_parametro_desp != '';

                    setValue($('r_parametro_desp'), timer.parametros_extra.r_parametro_desp);
                    setValue($('r_valor_desp'), timer.parametros_extra.r_valor_desp);
                } else {
                    $('abs').checked = true;
                    listener_radio_change($('abs'));
                    if (timer.parametros_extra.a_parametro_base) {//usa parametro
                        setValue($('a_a_que'), 'parametro');
                    } else {//usa fecha
                        setValue($('a_a_que'), 'fecha');
                    }

                    setValue($('a_valor_base'), timer.parametros_extra.a_valor_base);
                    setValue($('a_parametro_base'), timer.parametros_extra.a_parametro_base);
                }
                listener_relativo();
                listener_checkbox();
                listener_absoluto();
            }
            function Aceptar() {
                if($$('#rel:checked').length > 0) {
                    timer.parametros_extra.tipo = 'relativo';
                    
                    timer.parametros_extra.r_a_que = getValue('r_a_que');
                    timer.parametros_extra.r_parametro_base = getValue('r_parametro_base');
                    timer.parametros_extra.r_unidad = getValue('r_unidad');
                    if($$('#usa_param_check:checked').length > 0) {//usa parametro
                        timer.parametros_extra.r_valor_desp = '';
                        timer.parametros_extra.r_parametro_desp = getValue('r_parametro_desp');
                    } else {
                        timer.parametros_extra.r_valor_desp = getValue('r_valor_desp');
                        timer.parametros_extra.r_parametro_desp = '';
                    }
                    
                    timer.parametros_extra.a_valor_base = getValue('a_valor_base');
                    timer.parametros_extra.a_parametro_base = getValue('a_parametro_base');
                } else {
                    timer.parametros_extra.tipo = 'absoluto';

                    timer.parametros_extra.r_a_que = getValue('r_a_que');
                    timer.parametros_extra.r_parametro_base = getValue('r_parametro_base');
                    timer.parametros_extra.r_unidad = getValue('r_unidad');
                    timer.parametros_extra.r_valor_desp = getValue('r_valor_desp');
                    timer.parametros_extra.r_parametro_desp = getValue('r_parametro_desp');
                    
                    if(getValue($('a_a_que')) == 'fecha') {
                        timer.parametros_extra.a_valor_base = getValue('a_valor_base');
                        timer.parametros_extra.a_parametro_base = '';
                    } else {
                        timer.parametros_extra.a_valor_base = '';
                        timer.parametros_extra.a_parametro_base = getValue('a_parametro_base');
                    }
                }
                //Carga El Objeto  
                timer["orden"] = indice;
                timer["transferencia"] = parent.frmTransferencia.transferencia.value;
                timer["opcional"] = parent.frmTransferencia.opcional.checked;
                timer["transf_estado"] = parent.frmTransferencia.estado.value;
                
                return transferencia;
            }
            
            function listener_radio_change(radio) {
                radio.up().up().addClassName('selected');
                radio.up().up().up().select('.ocultable:not(.selected)').each(function(obj) {
                    obj.hide();
                });
                radio.up().up().removeClassName('selected');
                radio.up().next().show();
            }
            function listener_relativo() {
                if (getValue($('r_a_que')) == 'parametro') {
                    $('r_parametro_base').show();
                } else {
                    $('r_parametro_base').hide();
                }
            }
            function listener_checkbox() {
                if ($$('#usa_param_check:checked').length) {
                    $('r_parametro_desp').show();
                    $('r_valor_desp').hide();
                } else {
                    $('r_parametro_desp').hide();
                    $('r_valor_desp').show();
                }
            }
            function listener_absoluto() {
                if (getValue($('a_a_que')) == 'parametro') {
                    $('a_parametro_base').show();
                    $('a_valor_base').hide();
                } else {
                    $('a_parametro_base').hide();
                    $('a_valor_base').show();
                }
            }
            
            function setValue(element, value) {
                if(element.tagName == undefined) {
                    element = $(element);
                }
                switch (element.tagName.toUpperCase()) {
                    case  'SELECT':
                        var option = element.select('option[value="' + value + '"]');
                        if (option.length > 0) {
                            option[0].selected = true;
                        }
                        break;
                    case 'INPUT':
                        element.value = value;
                        break;
                    case 'DIV'://es un campodef
                        campos_defs.set_value(element.getAttribute('id') + '_cd', value);
                        break;
                }
            }
            function getValue(element) {
                if(element.tagName == undefined) {
                    element = $(element);
                }
                var value = null;
                switch (element.tagName.toUpperCase()) {
                    case 'SELECT':
                        element.select('option').each(function(option) {
                            if (option.selected) {
                                value = option.value;
                                throw $break;
                            }
                        });
                        break;
                    case 'INPUT':
                        value = element.value;
                        break;
                    case 'DIV':
                        value = campos_defs.get_value(element.getAttribute('id') + '_cd');
                        break;
                }
                return value;
            }
            function window_onunload() {

            }
        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" onunload="return window_onunload()" style="width:100%;height:100%;overflow:hidden">
        <div id="divCabe" style="width:100%">
            <div class="rel">
                <hr class="clear" />
                <div class="radios">
                    <input id="rel" type="radio" name="radio_name"/>
                    <label for="rel">Relativo</label>
                </div>
                <div class="ocultable">
                    <div class="radios">
                        <select id="r_a_que">
                            <option value="fecha">Relativo a la fecha y hora de ingreso</option>
                            <option value="dia">Relativo a las cero horas del día de ingreso</option>
                            <option value="mes">Relativo a las cero horas del primer día del mes de ingreso</option>
                            <option value="parametro">Parametro</option>
                        </select>
                        <select id="r_parametro_base" exid="params_a_que" class="params_datetime">
                        </select>
                        <select id="r_unidad" exid="measure">
                            <option value="minutos">Minutos</option>
                            <option value="horas">Horas</option>
                            <option value="dias">Días</option>
                            <option value="semanas">Semanas</option>
                            <option value="meses">Meses</option>
                        </select>
                        <div>
                            <input type="checkbox" id="usa_param_check"/>
                            <label for="param">Parametro</label>
                        </div>
                        <select id="r_parametro_desp" exid="measure_select" class="params_int"></select><!-- parametro -->
                        <div id="r_valor_desp" exid="measure_text"></div><!-- fecha -->
                    </div>
                </div>
            </div>
            <hr class="clear" />
            <div class="abs">
                <div class="radios">
                    <input id="abs" type="radio" name="radio_name"/>
                    <label for="abs">Absoluto</label>
                </div>
                <div class="ocultable">
                    <select id="a_a_que">
                        <option value="fecha">Fecha</option>
                        <option value="parametro">Parametro</option>
                    </select>
                    <div>
                        <div id="a_valor_base" style="width: 150px; display: inline-block;"></div>
                        <select class="params_datetime" id="a_parametro_base" ></select>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>