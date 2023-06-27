<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    'Stop

    Dim modo = obtenerValor("modo", "")
    Dim strXML = obtenerValor("strXML", "")
    Dim id_calc_cab = obtenerValor("id_calc_cab", "")


    If (modo.ToUpper() = "M") Then
        Dim Err = New tError()

        'Obtener Datos
        Try

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_calculo_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            If (Not rs.EOF) Then
                If rs.Fields("numError").Value <> 0 Then
                    Err.numError = rs.Fields("numError").Value
                    Err.mensaje = ""
                    Err.debug_desc = rs.Fields("debug_desc").Value
                    Err.debug_src = "calculos_abm::M"
                    Err.response()
                End If
                id_calc_cab = rs.Fields("id_calc_cab").Value
                Err.params("id_calc_cab") = id_calc_cab
                Err.numError = 0
                Err.mensaje = id_calc_cab

            End If

        Catch e As Exception
            Err.parse_error_script(e)
        End Try
        Err.response()
    End If


    Me.contents("filtro_calculos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calculos'><campos> id_calculo as id, calculo as [campo] </campos><orden>[campo]</orden></select></criterio>")

    Me.contents("filtro_tipo_persona") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='tipo_persona'><campos>nro_tipo_persona as id, tipo_persona as [campo] </campos><orden>[campo]</orden></select></criterio>")

    Me.contents("filtro_ver_calc_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_cab'><campos>calc_cab, nro_tipo_persona, convert(varchar, fe_desde, 103), convert(varchar, fe_hasta, 103), id_calculo </campos><orden></orden><filtro></filtro></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Liquidación</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>  

    <script type="text/javascript">

        var alert = function(msg) { window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 120, okLabel: "cerrar" }); }
        
        var win = nvFW.getMyWindow()
        var fecha = new Date()
        var id_calc_cab
        
        
        function window_onload() {

            campos_defs.add('nro_calculo', {
                target: 'td_nro_calculo',
                enDB: false,
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_calculos
            })

            campos_defs.add("nro_tipo_persona", {
                target: 'td_nro_tipo_persona',
                enDB: false,
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_tipo_persona,
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                onchange: function () {
                    //armar_descripcion_calculo()
                }
            })

            //campos_defs.items['nro_calculo']['onchange'] = armar_descripcion_calculo

            if (win.options.userData.id_calc_cab == 0) {
                $('id_calc_cab').value = 0
                $('calc_cab').value = ''
                campos_defs.add('fe_desde', { target: 'td_fe_desde', enDB: false, nro_campo_tipo: 103 })
                $('fe_desde').value = FechaToSTR(fecha, 1)

                campos_defs.add('fe_hasta', { target: 'td_fe_hasta', enDB: false, nro_campo_tipo: 103 })
            } else {
                $('id_calc_cab').value = win.options.userData.id_calc_cab
                $('calc_cab').value = win.options.userData.calc_cab
                $('td_fe_desde').innerHTML = "<input type='text' id='fe_desde' disabled=true style='width:100%; text-align: right' value=" + win.options.userData.fe_desde + ">"
                $('fe_desde').disabled = 'disabled'
                $('td_fe_hasta').innerHTML = "<input type='text' id='fe_hasta' disabled=true style='width:100%; text-align: right' value=" + win.options.userData.fe_hasta + ">"
                $('fe_hasta').disabled = 'disabled'

                campos_defs.set_value('nro_tipo_persona', win.options.userData.nro_tipo_persona)
                campos_defs.set_value('nro_calculo', win.options.userData.id_calculo)
            }
            $('id_calc_cab').disabled = 'disabled'
        }


        function guardar_calculo() {
            //debugger
            var xmldato = ''
            var fe_desde = ''
            var fe_hasta = ''

            if ($('id_calc_cab').value == 0) {
                fe_desde = campos_defs.get_value('fe_desde')
                fe_hasta = campos_defs.get_value('fe_hasta')
            } else {
                fe_desde = $('fe_desde').value
                fe_hasta = $('fe_hasta').value
            }

            if ($('calc_cab').value == '') {
                alert('Debe completar la descripción.')
                return
            }
            if ($('fe_desde').value == '') {
                alert('Debe ingresar fecha desde')
                return
            }

            xmldato = "<?xml version='1.0' encoding='iso-8859-1' ?><calculo>"
            xmldato += "<calc_cab id_calc_cab = '" + $('id_calc_cab').value + "' calc_cab = '" + $('calc_cab').value + "' fe_desde = '" + fe_desde + "' fe_hasta = '" + fe_hasta + "' id_calculo = '" + campos_defs.get_value('nro_calculo') + "' nro_tipo_persona = '" + campos_defs.get_value('nro_tipo_persona') + "' >"
            
            xmldato += "</calc_cab>"
            xmldato += "</calculo>"
            console.log(xmldato)

            nvFW.error_ajax_request('calculos_ABM.aspx', {
                parameters: { modo: 'M', strXML: xmldato },
                onSuccess: function(err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    else {
                        id_calc_cab = err.params['id_calc_cab']
                        win.options.userData = { id_calc_cab: id_calc_cab }
                        win.options.userData.hayModificacion = true
                        //calculo_datos_cargar()
                        //win.close();
                    }
                }
            });
        }
       
        
        function mayor(fecha, fecha2) {
            var xfecha = fecha.split('/')
            var yfecha = fecha2.split('/')

            var xDia = xfecha[0]
            var xMes = xfecha[1]
            var xAnio = xfecha[2]
            var yDia = yfecha[0]
            var yMes = yfecha[1]
            var yAnio = yfecha[2]

            if (parseInt(xAnio) > parseInt(yAnio)) {
                return (true);
            } else {
                if (parseInt(xAnio) == parseInt(yAnio)) {
                    if (parseInt(xMes) > parseInt(yMes)) {
                        return (true);
                    }
                    if (parseInt(xMes) == parseInt(yMes)) {
                        if (parseInt(xDia) > parseInt(yDia)) {
                            return (true);
                        } else {
                            return (false);
                        }
                    } else {
                        return (false);
                    }
                } else {
                    return (false);
                }
            }
        }
        
                
        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var divMenuABMLiquidacion_h = $('divMenuABMLiquidacion').getHeight()
                var tb_liq1_h = $('tb_liq1').getHeight()
                var tb_liq2_h = $('tb_liq2').getHeight()
                var tb_liq3_h = $('tb_liq3').getHeight()

                $('iframe_liquidacion').setStyle({ 'height': divMenuABMLiquidacion_h - tb_liq1_h - tb_liq2_h - tb_liq3_h - dif + 'px' })
            }
            catch (e) {
            }
        }
        
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
   <div id="divMenuABMCalculo"></div>
   <script type="text/javascript" language="javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenuABMCalculo = new tMenu('divMenuABMCalculo', 'vMenuABMCalculo');
                Menus["vMenuABMCalculo"] = vMenuABMCalculo
                Menus["vMenuABMCalculo"].alineacion = 'centro';
                Menus["vMenuABMCalculo"].estilo = 'A';

                vMenuABMCalculo.loadImage("guardar", '/FW/image/icons/guardar.png')

                Menus["vMenuABMCalculo"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_calculo()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMCalculo"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                vMenuABMCalculo.MostrarMenu()
   </script>
   <table class="tb1" id="tb_liq1">
       <tr class="tbLabel">
           <td style="width: 35%; text-align: center"><b>Cálculo</b></td>
           <td style="width: 35%; text-align: center"><b>Tipo Persona</b></td>
           <td style="width: 15%; text-align: center"><b>Fecha Desde</b></td>
           <td style="width: 15%; text-align: center"><b>Fecha Hasta</b></td> 
       </tr>
       <tr>
           <td style="width: 35%;" id="td_nro_calculo" ></td>
           <td style="width: 35%;" id="td_nro_tipo_persona">
               <%--<script>
                   campos_defs.add("nro_tipo_persona", {
                       target: 'td_nro_tipo_persona',
                       enDB: false,
                       nro_campo_tipo: 1,
                       filtroXML: nvFW.pageContents.filtro_tipo_persona,
                       filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                       onchange: function () {
                           armar_descripcion_calculo()
                       }
                   })

               </script>--%>
           </td>
           <td style="width: 15%;" id="td_fe_desde"></td>
           <td style="width: 15%;" id="td_fe_hasta"></td> 
       </tr>

    </table>

    <table class="tb1" id="tb_liq2">
        <tr class="tbLabel">
             <td style="width: 10%; text-align: center"><b>ID</b></td>
             <td style="width: 90%; text-align: center"><b>Descripción</b></td>
       </tr>
       <tr>
            <td style="width: 10%;">
                <input style='text-align: left; width: 100%' type="text" name="id_calc_cab" id="id_calc_cab" value="" />
            </td>
            <td style="width: 90%";>
                <input style='text-align: left; width: 100%' type="text" name="calc_cab" id="calc_cab" value="" />
            </td>
       </tr>
   </table>
   
   <iframe name="iframe_liquidacion" id="iframe_liquidacion" style="width: 100%; overflow: hidden; height: 100%" frameborder="0"></iframe>       
</body>
</html>
