<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    'Stop
    Dim id_calc_det = obtenerValor("id_calc_det")
    Dim id_calc_cab = obtenerValor("id_calc_cab")
    Dim strXML = obtenerValor("strXML", "")
    Dim modo = obtenerValor("modo", "")
    Dim Err


    Me.contents("filtro_ver_calc_cab_pers_calc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_cal_cab_pers_calc'><campos> id_calc_cab, calc_cab, nro_tipo_persona, tipo_persona, convert(varchar, fe_desde, 103) as fe_desde, convert(varchar, fe_hasta, 103) as fe_hasta, id_calculo, calculo </campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_ver_calc_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_calc_cab'><campos>id_calc_cab, calc_cab, nro_tipo_persona, id_calc_det, calc_det, convert(varchar, fe_desde_cab, 103) as fe_desde_cab, convert(varchar, fe_hasta_cab, 103) as fe_hasta_cab, calc_id_tipo, nro_calc_id_tipo, parametro </campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_calc_var_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_var_tipos'><campos>distinct id_calc_var_tipo as id, calc_var_tipo as [campo] </campos><orden>[campo]</orden></select></criterio>")

    Me.contents("filtro_calc_acumuladores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_acumuladores'><campos>distinct nro_calc_acum as id, calc_acum as [campo] </campos><orden>[campo]</orden></select></criterio>")

    Me.contents("filtro_calc_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_cab'><campos>distinct id_calc_cab as id, calc_cab as [campo] </campos><orden>[campo]</orden><filtro><fe_hasta type='isnull'></fe_hasta><nro_empresa type='igual'>" & nvFW.nvSession.Contents("nv_nro_empresa_activa") & "</nro_empresa></filtro></select></criterio>")

    Me.contents("filtro_calc_cab2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_cab'><campos>nro_perfil,nro_empresa</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_calc_cab3") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_cab'><campos>id_calc_cab</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_ver_calc_det_variables") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_calc_det_variables'><campos>id_calc_var,calc_variable,calculo,tipo_variable,id_calc_var_tipo,calc_var_tipo,nro_calc_acum,calc_acum,case when calc_variable = 'monto_comision' then SUBSTRING (prioridad ,2 , LEN(prioridad)) else prioridad end as prioridad</campos><orden>prioridad</orden><filtro></filtro></select></criterio>")


    Me.contents("filtro_nro_calc_id_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_id_tipo'><campos>nro_calc_id_tipo as id, calc_id_tipo as campo, campo_def</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_nro_pizarra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPizarras'><campos>nro_calc_pizarra as id, calc_pizarra as campo</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_ver_calc_valores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_calc_valores'><campos>top 1 id_liquidacion</campos><orden></orden><filtro></filtro></select></criterio>")


    If (modo.ToUpper() = "M") Then
        Err = New tError()

        'Obtener Datos
        Try

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_calculo_detalle_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            'Dim rs = Cmd.Execute()
            If (Not rs.EOF) Then
                If rs.Fields("numError").Value <> 0 Then
                    Err.numError = rs.Fields("numError").Value
                    Err.mensaje = ""
                    Err.debug_desc = rs.Fields("debug_desc").Value
                    Err.debug_src = "calculos_detalle_abm::M"
                    Err.response()
                End If
                id_calc_det = rs.Fields("id_calc_det").Value
                Err.params("id_calc_det") = id_calc_det
                Err.numError = 0
                Err.mensaje = id_calc_det

            End If

        Catch e As Exception
            Err.parse_error_script(e)
        End Try
        Err.response()

    End If

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
        var id_calc_det = '<%=id_calc_det %>'
        var id_calc_cab = '<%=id_calc_cab %>'
        var Calculo = new Array()
        var Variables = new Array()
        var fecha = new Date()

        var id_calc_cab
        var cambio_acumulador = false


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()

            }
            catch (e) { }
        }

        var _campo_def = ""


        function window_onload() {
            //campos_defs.add('fe_desde_det', { target: 'td_fe_desde_det', enDB: false, nro_campo_tipo: 103 })
            //campos_defs.add('fe_hasta_det', { target: 'td_fe_hasta_det', enDB: false, nro_campo_tipo: 103 })

            campos_defs.add('nro_calc_id_tipo', {
                despliega: 'abajo',
                enDB: false,
                target: 'td_nro_calc_id_tipo',
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_nro_calc_id_tipo,
                onchange: function () {
                    campos_defs.remove(_campo_def)
                    campos_defs.remove("id_tipo")

                    $("td_id_tipo").innerHTML = ""

                    if (typeof (campos_defs.items["nro_matriz"]) != "object") {
                        _campo_def = campos_defs.items["nro_calc_id_tipo"].rs.data[campos_defs.items["nro_calc_id_tipo"].input_select.selectedIndex - 1].campo_def

                        try {

                            if (_campo_def != "")
                                campos_defs.add(_campo_def, {
                                    enDB: true,
                                    target: 'td_id_tipo'
                                })


                            if (_campo_def in campos_defs.items) {
                                if (campos_defs.items[_campo_def].filtroXML == undefined) { //si no tiene filtro xml yo se que no existe

                                    campos_defs.remove(_campo_def)

                                    campos_defs.add("id_tipo", {
                                        enDB: false,
                                        nro_campo_tipo: 100,
                                        target: "td_id_tipo"
                                    })
                                }
                            }
                        }
                        catch (e) {

                        }
                    }
                }
            })

            campos_defs.add('id_calc_var_tipo', {
                despliega: 'arriba',
                enDB: true,
                target: 'td_id_calc_var_tipo',
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_calc_var_tipos,
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>"
            })

            campos_defs.items['id_calc_var_tipo']['onchange'] = calculo_pizarra_mostrar

            campos_defs.add('nro_calc_acum', {
                despliega: 'arriba',
                enDB: false,
                target: 'td_nro_calc_acum',
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_calc_acumuladores,
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>"
            })
                        
            if (id_calc_det == 0) {
                calculo_datos_cargar(0)
            } else {
                calculo_datos_cargar()
            }

            variables_cargar()

            window_onresize()
        }


        function armar_descripcion_calculo() {
            var descripcion = ''
            var estructura = ''
            var tipo = ''
            var categoria = ''

            if (campos_defs.get_value('id_calc_cab') == id_calc_cab) {
                if ((campos_defs.get_value('nro_tipo_comision') != nro_tipo_comision)) {

                    campos_defs.set_value('id_calc_cab', '')
                    nro_tipo_comision = campos_defs.get_value('nro_tipo_comision')
                    id_calc_cab = campos_defs.get_value('id_calc_cab')
                }
            }

            if (campos_defs.get_value('nro_tipo_comision') != '') {

                estructura = estructura.replace(/\s/g, '_').toLowerCase()
                tipo = campos_defs.get_desc('nro_tipo_comision').split(' (')[0]
                tipo = tipo.split(' ')[0]
                tipo = tipo.replace(/\s/g, '_').toLowerCase()
                categoria = categoria.replace(/\s/g, '_').toLowerCase()

                descripcion = tipo + '_' + categoria + estructura

                $('calc_det').value = descripcion
            }
        }


        function calculo_pizarra_mostrar() {
            //if (campos_defs.get_value('id_calc_var_tipo') == 4) {

            //    $('btnEditarCalculo').disabled = false
            //    $('calculo').disabled = true
            //    $('calculo').value = ""
            //    campos_defs.set_value('nro_calc_acum', '')
            //    campos_defs.habilitar('nro_calc_acum', false)

            //} else {
            //    $('btnEditarCalculo').disabled = true
            //    $('calculo').disabled = false
            //    campos_defs.habilitar('nro_calc_acum', true)
            //}

            if (campos_defs.get_value('id_calc_var_tipo') == 7) {
                campos_defs.set_value('nro_calc_acum', '')
                campos_defs.habilitar('nro_calc_acum', false)
            } else {
                campos_defs.habilitar('nro_calc_acum', true)
            }
        }


        function calculo_datos_cargar(id_calc_det_nuevo) {
            var editar_detalle = false
            var rs = new tRS();

            if (id_calc_det_nuevo == 0) {
                rs.open(nvFW.pageContents.filtro_ver_calc_cab_pers_calc, "", "<id_calc_cab type='igual'>" + id_calc_cab + "</id_calc_cab>")
                if (!rs.eof()) {
                    $('id_calc_cab').value = id_calc_cab
                    $('id_calc_det').value = id_calc_det_nuevo
                    $('calc_det').value = ''
                    $('fe_desde_det').value = rs.getdata('fe_desde')
                    $('fe_hasta_det').value = rs.getdata('fe_hasta')
                }
                //debugger
                //if (campos_defs.get_value("nro_calc_id_tipo")) {
                //    campos_defs.set_value("nro_calc_id_tipo", "")
                //}
                //$("td_id_tipo").innerHTML = ""

                //campos_defs.add("id_tipo", {
                //    enDB: false,
                //    nro_campo_tipo: 100,
                //    target: "td_id_tipo"
                //})


                Variables = new Array()
                variables_dibujar()

            } else if (id_calc_det_nuevo > 0) {
                nuevo_detalle = true
                rs.open(nvFW.pageContents.filtro_ver_calc_cab, "", "<id_calc_det type='igual'>" + id_calc_det_nuevo + "</id_calc_det>")
            } else {
                editar_detalle = true
                rs.open(nvFW.pageContents.filtro_ver_calc_cab, "", "<id_calc_det type='igual'>" + id_calc_det + "</id_calc_det>")
            }

            if (editar_detalle && !rs.eof()) {

                Calculo['id_calc_cab'] = rs.getdata('id_calc_cab')
                Calculo['id_calc_det'] = rs.getdata('id_calc_det')
                Calculo['calc_det'] = rs.getdata('calc_det')
                Calculo['nro_calc_id_tipo'] = rs.getdata('nro_calc_id_tipo') == null ? '' : rs.getdata('nro_calc_id_tipo')
                Calculo['id_tipo'] = rs.getdata('id_tipo') == null ? '' : rs.getdata('id_tipo')
                Calculo['fe_desde_det'] = rs.getdata('fe_desde_cab')
                Calculo['fe_hasta_det'] = rs.getdata('fe_hasta_cab') == null ? '' : rs.getdata('fe_hasta_cab')

                $('id_calc_cab').value = rs.getdata('id_calc_cab')
                $('id_calc_det').value = rs.getdata('id_calc_det')
                $('calc_det').value = rs.getdata('calc_det')

                if (rs.getdata('nro_calc_id_tipo') == null) {
                    campos_defs.remove(_campo_def)
                    $("td_id_tipo").innerHTML = ""

                    campos_defs.add("id_tipo", {
                        enDB: false,
                        nro_campo_tipo: 100,
                        target: "td_id_tipo"
                    })

                    campos_defs.set_value("id_tipo", Calculo['id_tipo'])
                } else {
                    //campos_defs.set_value('nro_calc_id_tipo', rs.getdata('nro_calc_id_tipo'))
                    campos_defs.set_value('nro_calc_id_tipo', Calculo['nro_calc_id_tipo'])

                    if (typeof campos_defs.items[_campo_def] != 'undefined') {
                        campos_defs.set_value(_campo_def, Calculo['id_tipo'])
                    }
                    else if (typeof campos_defs.items["id_tipo"] != 'undefined') {
                        campos_defs.set_value("id_tipo", Calculo['id_tipo'])
                    }
                }

                id_calc_cab = Calculo['id_calc_cab']
                //calculo_verificar_liquidacion()
            }
        }

        /*    
        function calculo_verificar_liquidacion() {
            var rs = new tRS();
            rs.open(nvFW.pageContents.filtro_ver_calc_valores, "", "<id_calc_det type='igual'>" + id_calc_det + "</id_calc_det><estado type='distinto'>'Z'</estado>")
            
            if (!rs.eof()) {

                $('id_calc_det').disabled = 'disabled'
                campos_defs.habilitar('id_calc_cab', false)
                $('calc_det').disabled = 'disabled'
                campos_defs.habilitar('nro_tipo_comision', false)
                campos_defs.habilitar('nro_categoria', false)
                campos_defs.habilitar('nro_estructura', false)
                $('fe_desde_det').disabled = 'disabled'
            }
        }
        */


        function variables_cargar(_id_calc_det) {
            var i = 0
            var rs = new tRS();

            if (_id_calc_det) {
                rs.open(nvFW.pageContents.filtro_ver_calc_det_variables, "", "<id_calc_det type='igual'>" + _id_calc_det + "</id_calc_det>")
            } else {
                rs.open(nvFW.pageContents.filtro_ver_calc_det_variables, "", "<id_calc_det type='igual'>" + id_calc_det + "</id_calc_det>")
            }

            while (!rs.eof()) {
                Variables[i] = new Array();
                Variables[i]["id_calc_var"] = rs.getdata("id_calc_var")
                Variables[i]["calc_variable"] = rs.getdata("calc_variable")
                Variables[i]["calculo"] = rs.getdata("calculo")
                Variables[i]["tipo_variable"] = rs.getdata("tipo_variable")
                Variables[i]["prioridad"] = rs.getdata("prioridad")
                Variables[i]["id_calc_var_tipo"] = rs.getdata("id_calc_var_tipo")
                Variables[i]["calc_var_tipo"] = rs.getdata("calc_var_tipo")
                Variables[i]["nro_calc_acum"] = rs.getdata("nro_calc_acum") == null ? '' : rs.getdata("nro_calc_acum")
                Variables[i]["calc_acum"] = rs.getdata("calc_acum") == null ? '' : rs.getdata("calc_acum")
                Variables[i]["estado"] = 'ACTIVA'
                Variables[i]["nro_calc_pizarra"] = rs.getdata("nro_calc_pizarra") == null ? '' : rs.getdata("nro_calc_pizarra")

                i = i + 1
                rs.movenext()
            }
            
            variables_dibujar()
        }


        function calculos_acumulador_ABM(nro_calc_acum) {
            win = nvFW.createWindow({
                className: 'alphacube',
                url: 'calculos_acumulador_ABM.aspx',
                title: '<b>Acumulador ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 300,
                onClose: function () {
                    variables_cargar()
                    //variables_cargar(id_calc_det)
                }
            });

            win.options.userData = { nro_calc_acum: nro_calc_acum }
            win.showCenter(true)
        }


        function variables_dibujar() {
            var checkeado = ""
            var deshabilitado = ""
            
            $('div_variables').innerHTML = ""
            strHTML = "<table class='tb1 highlightEven highlightTROver layout_fixed' width='100%'><tr class='tbLabel0'><td style='width:3%'>-</td><td style='width:18%'>Variable</td><td>Calculo</td><td style='width:10%'>Tipo Dato</td><td style='width:10%'>Tipo Variable</td><td style='width:8%'>Prioridad</td><td style='width:10%'>Acumulador</td><td style='width:3%'>-</td></tr>"
            Variables.each(function (arreglo, i) {
                if (arreglo["estado"] != 'BORRADA') {
                    
                    calculo = arreglo["calculo"].length > 75 ? arreglo["calculo"].substr(0, 75) + "..." : arreglo["calculo"]
                    strHTML += "<tr id='tr_ver" + i + "' >"
                    strHTML += "<td style='width:3%'><input type='radio' name='rd_variable' id='rd_variable_" + i + "' value=" + i + " " + checkeado + " onclick='variable_editar(this)' " + deshabilitado + "></td>"
                    if (arreglo["calc_var_tipo"] == "Acumulador") {
                        strHTML += "<td nowrap style='width:18%'><a href='javascript:calculos_acumulador_ABM(" + arreglo["nro_calc_acum"] + ")'>" + arreglo["calc_variable"] + "</a></td>"
                    } else {
                        strHTML += "<td nowrap style='width:18%'>" + arreglo["calc_variable"] + "</td>"
                    }
                    strHTML += '<td nowrap title="' + arreglo["calculo"] + '">' + calculo + '</td>'
                    strHTML += "<td nowrap style='width:10%'>" + arreglo["tipo_variable"] + "</td>"
                    strHTML += "<td nowrap style='width:10%'>" + arreglo["calc_var_tipo"] + "</td>"
                    strHTML += "<td nowrap style='width:8%'>" + arreglo["prioridad"] + "</td>"
                    strHTML += "<td nowrap style='width:10%'>" + arreglo["calc_acum"] + "</td>"
                    strHTML += "<td style='width:3%'><img alt='' title='Eliminar variable' src='../../FW/image/icons/eliminar.png' style='cursor:pointer;cursor:hand' onclick='variable_eliminar(" + i + ")' /></td>"
                    strHTML += "</tr>"
                }
            });

            strHTML += "</table>"
            $('div_variables').insert({ top: strHTML })
        }


        function variable_editar(_this) {
            var i = _this.value
            if ((i != '') && (Variables[i] != undefined)) {

                $('indice').value = i
                $('id_calc_var').value = Variables[i]['id_calc_var'] == null ? '' : Variables[i]['id_calc_var']
                $('calc_variable').value = Variables[i]['calc_variable'] == null ? '' : Variables[i]['calc_variable']
                $('calculo').value = Variables[i]['calculo'] == null ? '' : Variables[i]['calculo']
                campos_defs.set_value('id_calc_var_tipo', Variables[i]['id_calc_var_tipo'])
                $('prioridad').value = Variables[i]['prioridad'] == null ? '' : Variables[i]['prioridad']
                campos_defs.set_value('nro_calc_acum', Variables[i]['nro_calc_acum'])
                $('tipo_var').value = Variables[i]['tipo_variable']
                $('nro_calc_pizarra').value = Variables[i]['nro_calc_pizarra']
            }
        }


        function variable_eliminar(indice) {
            var i = indice

            Dialog.confirm("¿Desea eliminar la variable seleccionada?", {
                width: 300,
                className: "alphacube",
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {

                    Variables[i]["id_calc_var"] = Variables[i]["id_calc_var"] * -1
                    Variables[i]["estado"] = 'BORRADA'
                    if (Variables[i]["id_calc_var"] == 0)
                        Variables.splice(i, 1)

                    variables_dibujar()

                    win.close()
                }
            });
        }


        function variable_nueva() {
            $('indice').value = Variables.length
            $('id_calc_var').value = 0
            $('calc_variable').value = ''
            $('calculo').value = ''
            campos_defs.clear('id_calc_var_tipo')
            campos_defs.clear('nro_calc_acum')
            $('prioridad').value = ''
            $('tipo_var').value = ''
            $('nro_calc_pizarra').value = ''
        }


        function variable_agregar() {

            if ($('calc_variable').value == '') {
                alert('Por favor, ingrese un Nombre de Variable.')
                return
            }
            if ($('calculo').value == '') {
                alert('Por favor, ingrese una Definición de Cálculo.')
                return
            }
            if ($('tipo_var').value == '') {
                alert('Por favor, ingrese un Tipo de Dato.')
                return
            }
            if (campos_defs.value('id_calc_var_tipo') == '') {
                alert('Por favor, ingrese un Tipo de Variable.')
                return
            }
            if ($('prioridad').value == '') {
                alert('Por favor, ingrese la Prioridad.')
                return
            }

            var error = ''
            error = nombre_variable_verificar()
            if (error != '') {
                alert(error)
                return
            }

            error = tipo_variable_verificar() //validación según tipo variable
            if (error != '') {
                alert(error)
                return
            }

            var indice = ($('indice').value == '') ? Variables.length : $('indice').value

            Variables[indice] = new Array()
            Variables[indice]['id_calc_var'] = ($('id_calc_var').value != '' && $('id_calc_var').value > 0) ? $('id_calc_var').value : 0
            Variables[indice]['calc_variable'] = $('calc_variable').value
            Variables[indice]['calculo'] = $('calculo').value
            Variables[indice]['tipo_variable'] = $('tipo_var').value
            Variables[indice]['id_calc_var_tipo'] = campos_defs.get_value('id_calc_var_tipo')
            Variables[indice]['calc_var_tipo'] = campos_defs.get_desc('id_calc_var_tipo').split('  (')[0]
            Variables[indice]['nro_calc_acum'] = campos_defs.get_value('nro_calc_acum')
            Variables[indice]['calc_acum'] = campos_defs.get_desc('nro_calc_acum').split('  (')[0]
            Variables[indice]['prioridad'] = $('prioridad').value
            Variables[indice]['nro_calc_pizarra'] = campos_defs.get_value('id_calc_var_tipo') == 4 ? $('nro_calc_pizarra').value : ''

            variables_dibujar()
            variable_nueva()
        }


        function nombre_variable_verificar() {
            var error = ''
            if ($('calc_variable').value.split(' ')[1])
                error = 'NO deben existir espacios vacíos en el nombre de variable'

            return error
        }


        function tipo_variable_verificar() {
            var error = ''
            if (campos_defs.get_value('id_calc_var_tipo') == 1) { //Constante
                if (campos_defs.get_value('nro_calc_acum') != '')
                    error += 'Una variable constante no puede tener acumulador asociado'

                if ($('calc_variable').value != $('calculo').value.split('@')[1])
                    error += 'El cálculo debe ser igual al nombre de variable precedido por @'
            }

            if (campos_defs.get_value('id_calc_var_tipo') == 2) { //Calculo

            }

            if (campos_defs.get_value('id_calc_var_tipo') == 3) { //Acumulador
                if (campos_defs.get_value('nro_calc_acum') == '')
                    error += 'Una variable Acumulador debe tener acumulador asociado'
            }

            if (campos_defs.get_value('id_calc_var_tipo') == 4) { //Fcion pizarra

            }

            return error
        }


        var win_editar
        function ver_editor(_this) {
            var texto = _this.value
            var name_campo = _this.name
            win_editar = new Window({
                className: 'alphacube',
                title: '<b>Editar Texo</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                recenterAuto: false,
                width: 650,
                height: 200,
                onClose: function () { }
            });

            var tr_pizarra = ""
            var pizarra = false
            var rows = '9'
            if (campos_defs.get_value("id_calc_var_tipo") == 7) {
                pizarra = true
                rows = '8'
                tr_pizarra = "<tr><td colspan='3'><table class='tb1' style='width:100%'><tbody></tr><tr><td style='width:100%' id='td_cd_pizarra'></td></tr></tbody></table></td></tr>"
            }

            var html = "<html><head></head><body style='width: 100%; height: 100%;'><form><table class='tb1'>" + tr_pizarra + "<tr><td colspan='3' align='center'><input type='hidden' name='name_campo' id='name_campo' value='" + name_campo + "'/><textarea style='overflow-x: hidden; overflow-y: auto; resize: none; width: 630px;' rows=" + rows + " cols='1' name='editar_texto' id='editar_texto' >" + texto + "</textarea></td></tr><tr><td style='width:33%'></td><td style='width:33%; align:center'><input style='width:100%' type='button' name='aceptar' id='aceptar' value='Aceptar' onclick='actualizar_texto(win_editar)'/></td><td style='width:33%'></td></tr></table></form></body>";

            win_editar.setHTMLContent(html)

            if (pizarra) {
                campos_defs.add("nro_pizarra", {
                    nro_campo_tipo: 1,
                    enDB: false,
                    filtroXML: nvFW.pageContents.filtro_nro_pizarra,
                    target: "td_cd_pizarra",
                    onchange: function () {
                        if ($('editar_texto').value == "" || texto.length == 0) {
                            $('editar_texto').value = campos_defs.get_desc('nro_pizarra').split(' (')[0]
                        }
                    }
                })
            }

            var id = win_editar.getId()
            focus(id)
            win_editar.showCenter(true)
        }


        function actualizar_texto(win_editar) {
            var editar_texto = $('editar_texto').value
            var name_campo = $('name_campo').value
            win_editar.close()
            $(name_campo).value = editar_texto
        }


        function guardar(id_calc_det) {
            if ($('calc_det').value == '') {
                alert('Debe completar el detalle.')
                return
            } else {

                calculo_datos_actualizar(id_calc_det)

                if ((campos_defs.get_value("nro_calc_id_tipo") != "" &&
                    ((typeof campos_defs.items["id_tipo"] != 'undefined' && campos_defs.get_value("id_tipo") == "") ||
                        (typeof campos_defs.items["id_tipo"] != 'undefined' && campos_defs.get_value("id_tipo") == "") ||
                        (typeof campos_defs.items[_campo_def] != 'undefined' && campos_defs.get_value(_campo_def) == ""))) ||
                    campos_defs.get_value("nro_calc_id_tipo") == "" && campos_defs.get_value("id_tipo") != "") {
                    alert("Debe completar el Tipo y el Código.")
                } else {

                    var xmldato = ''
                    xmldato = "<?xml version='1.0' encoding='iso-8859-1' ?><calculo>"
                    xmldato += "<calc_det id_calc_det = '" + Calculo['id_calc_det'] + "' id_calc_cab = '" + Calculo['id_calc_cab'] + "' calc_det = '" + Calculo['calc_det'] + "' fe_desde = '" + Calculo['fe_desde_det'] + "' fe_hasta = '" + Calculo['fe_hasta_det'] + "' id_tipo = '" + Calculo['id_tipo'] + "' nro_calc_id_tipo = '" + Calculo['nro_calc_id_tipo'] + "' >"
                    xmldato += "<variables>"

                    if (Calculo['id_calc_det'] == 0) {
                        Variables.each(function (arreglo, i) {
                            arreglo["id_calc_var"] = 0
                        });
                    }

                    Variables.each(function (arreglo, i) {

                        calculo = '<![CDATA[' + arreglo['calculo'] + ']]>'
                        xmldato += "<calc_variables id_calc_var = '" + arreglo["id_calc_var"] + "' calc_variable = '" + arreglo["calc_variable"] + "' tipo_variable = '" + arreglo["tipo_variable"] + "' prioridad = '" + arreglo["prioridad"] + "' id_calc_var_tipo = '" + arreglo["id_calc_var_tipo"] + "' nro_calc_acum = '" + arreglo["nro_calc_acum"] + "' nro_calc_pizarra = '" + arreglo["nro_calc_pizarra"] + "'>"
                        xmldato += "<calculo>" + calculo + "</calculo>"
                        xmldato += "</calc_variables>"
                    });
                    xmldato += "</variables>"
                    xmldato += "</calc_det>"
                    xmldato += "</calculo>"

                    nvFW.error_ajax_request('calculos_detalle_ABM.aspx', {
                        parameters: { modo: 'M', strXML: xmldato },
                        onSuccess: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            else {
                                //id_calc_det = err.params['id_calc_det']
                                calculo_datos_cargar(err.params['id_calc_det'])
                                variables_cargar(err.params['id_calc_det'])
                                win.options.userData.hayModificacion = true
                                win.options.userData.id_calc_cab = $('id_calc_cab').value
                                //win.close()
                            }
                        }
                    });
                }
            }
        }


        function guardar_como() {
            Dialog.confirm('¿Desea guardar este Cálculo como uno nuevo?', {
                width: 300, className: "alphacube",
                onOk: function (win) {
                    guardar(0)
                    win.close()
                },
                onCancel: function (win) { win.close() }
            })
        }


        function calculo_datos_actualizar(id_calc_det) {
            id_calc_det == 0 ? Calculo['id_calc_det'] = id_calc_det : Calculo['id_calc_det'] = $('id_calc_det').value

            Calculo['id_calc_cab'] = $('id_calc_cab').value

            Calculo['calc_det'] = $('calc_det').value
            Calculo['fe_desde_det'] = $('fe_desde_det').value
            Calculo['fe_hasta_det'] = $('fe_hasta_det').value == null ? '' : $('fe_hasta_det').value

            if (typeof campos_defs.items[_campo_def] != 'undefined') {
                Calculo['id_tipo'] = campos_defs.get_value(_campo_def)
            }
            else if (typeof campos_defs.items["id_tipo"] != 'undefined') {
                Calculo['id_tipo'] = campos_defs.get_value("id_tipo")
            }
            else {
                Calculo['id_tipo'] = ""
            }

            Calculo['nro_calc_id_tipo'] = campos_defs.get_value('nro_calc_id_tipo')
        }


        function acumulador_ABM() {
            win = nvFW.createWindow({
                className: 'alphacube',
                url: 'calculos_acumuladores.aspx',
                title: '<b>Acumuladores</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 970,
                height: 400,
                onClose: calculos_acumulador_return
            });

            //win.options.userData = { calculo: cambio_acumulador }
            win.showCenter(true)
        }


        function calculos_acumulador_return() {
            //if (cambio_acumulador) {
            $('td_nro_calc_acum').innerHTML = ''
            if ($('cbnro_calc_acum')) {
                $('cbnro_calc_acum').length = 0
            }
            campos_defs.clear('nro_calc_acum')
            campos_defs.remove('nro_calc_acum')

            campos_defs.add('nro_calc_acum', {
                despliega: 'arriba',
                enDB: false,
                target: 'td_nro_calc_acum',
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_calc_acumuladores,
                filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                depende_de: null,
                depende_de_campo: null
            })           
        }


        function calculo_detalle_nuevo() {
            $('id_calc_det').value = 0
            $('calc_det').value = ''
            campos_defs.clear()
            //$('fe_desde_det').disabled = ''
            $('fe_desde_det').value = FechaToSTR(fecha, 1)
            $('fe_hasta_det').value = ''
            //campos_defs.habilitar('id_calc_cab', true)
            Variables = new Array()
            variables_dibujar()
        }


        function calculo_nuevo() {
            win = nvFW.createWindow({
                className: 'alphacube',
                url: 'calculos_ABM.aspx',
                title: '<b>Calculo Definición ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 350,
                onClose: calculo_nuevo_return
            });

            win.showCenter(true)
        }


        function calculo_nuevo_return() {
            var id_calc_cab
            if (win.options.userData) {
                $('td_id_calc_cab').innerHTML = ''
                campos_defs.clear('id_calc_cab')
                campos_defs.remove('id_calc_cab')
                //$('cbid_calc_cab').length = 0
                
                campos_defs.add('id_calc_cab', {
                    despliega: 'abajo',
                    enDB: false,
                    target: 'td_id_calc_cab',
                    nro_campo_tipo: 1,
                    filtroXML: nvFW.pageContents.filtro_calc_cab,
                    filtroWhere: "<campo_def type='in'>%campo_value%</campo_def>",
                    depende_de: "nro_perfil"
                })

                id_calc_cab = win.options.userData.id_calc_cab
                campos_defs.set_value('id_calc_cab', id_calc_cab)

                campos_defs.items['id_calc_cab']['onchange'] = calculo_onchange
            }
        }


        function calculo_pizarra_armar() {
            var indice = $('indice').value

            var parametros = new Array()
            parametros['calculo'] = $('calculo').value
            parametros['nro_calc_pizarra'] = $('nro_calc_pizarra').value


            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win = w.createWindow({
                className: 'alphacube',
                url: 'calculo_pizarra.aspx',
                title: '<b>Cálculo Función Pizarra</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 550,
                height: 350,
                onClose: calculo_pizarra_return
            });

            win.options.userData = { parametros: parametros }
            win.showCenter(true)
        }


        function calculo_pizarra_return() {
            if (win.options.userData.parametros) {

                $('calculo').value = win.options.userData.parametros['calculo']
                $('nro_calc_pizarra').value = win.options.userData.parametros['nro_calc_pizarra']
            }
        }


        function pizarra_ABM() {
            win = nvFW.createWindow({
                className: 'alphacube',
                url: '/FW/pizarra/calculos_pizarra_buscar.aspx',
                title: '<b>Pizarras</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 970,
                height: 400
                //onClose: calculos_acumulador_return
            });

            //win.options.userData = { calculo: cambio_acumulador }
            win.showCenter(true)
        }


        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divGuardar_h = $('divGuardar').getHeight()
                var divCalculoDatos_h = $('divCalculoDatos').getHeight()
                var divVariablesDatos_h = $('divVariablesDatos').getHeight()
                var div_variable_calculo_am_h = $('div_variable_calculo_am').getHeight()
                $('div_variables').setStyle({ 'height': body_h - divGuardar_h - divCalculoDatos_h - divVariablesDatos_h - div_variable_calculo_am_h - dif })

            }
            catch (e) { }
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="calculos_comisiones_editar.aspx" method="post" name="form1" target="frmEnviar">
        <input type="hidden" id="nro_calc_pizarra" value='' />
        <div id="divGuardar">
            <div id="divMenuABMCalculos" style="width: 100%"></div>
            <script type="text/javascript" language="javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenuABMCalculos = new tMenu('divMenuABMCalculos', 'vMenuABMCalculos');
                Menus["vMenuABMCalculos"] = vMenuABMCalculos
                Menus["vMenuABMCalculos"].alineacion = 'centro';
                Menus["vMenuABMCalculos"].estilo = 'A';

                vMenuABMCalculos.loadImage("nuevo", "/FW/image/icons/nueva.png");
                vMenuABMCalculos.loadImage("guardar", '/FW/image/icons/guardar.png')

                Menus["vMenuABMCalculos"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMCalculos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar Como</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMCalculos"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuABMCalculos"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Detalle</Desc><Acciones><Ejecutar Tipo='script'><Codigo>calculo_datos_cargar(0)</Codigo></Ejecutar></Acciones></MenuItem>")
               /* Menus["vMenuABMCalculos"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Calculo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>calculo_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")*/

                vMenuABMCalculos.MostrarMenu()
            </script>
        </div>
        <div id="divCalculoDatos">
            <table class="tb1" style="width:100%">
                <tr class="tbLabel">
                    <td style="width: 10%; text-align: center"><b>ID</b></td>
                    <td style="width: 15%;text-align: center"><b>Detalle</b></td>
                    <td style="width: 15%;text-align: center"><b>Tipo</b></td>
                    <td style="width: 25%;text-align: center"><b>Código</b></td>
                    <%--<td style="width: 15%; text-align: center"><b>Fe. Desde</b></td>
                    <td style="width: 15%; text-align: center"><b>Fe. Hasta</b></td>--%>
                </tr>
                <tr>
                    <td style="width: 10%">
                        <input type="text" name="id_calc_cab" id="id_calc_cab" value="" style="width: 100%" maxlength="200" hidden />
                        <input type="text" name="id_calc_det" id="id_calc_det" value="" style="width: 100%" maxlength="200" disabled />
                        <input type="text" name="fe_desde_det" id="fe_desde_det" hidden />
                        <input type="text" name="fe_hasta_det" id="fe_hasta_det" hidden />
                    </td>
                    <td style="width: 15%">
                        <input type="text" name="calc_det" id="calc_det" value="" style="width: 100%" maxlength="200" />
                    <td style="width: 15%" id="td_nro_calc_id_tipo"></td>
                    <td style="width: 25%" id="td_id_tipo"></td>
                </tr>
            </table>
        </div>

        <div id="div_variables" style="width: 100%; height: 100%; overflow: auto"></div>

        <div id="divVariablesDatos">
            <div id="divMenuVariables" style="width: 100%; margin: 0px; padding: 0px"></div>
            <script type="text/javascript">
                var vMenuVariables = new tMenu('divMenuVariables', 'vMenuVariables');
                Menus["vMenuVariables"] = vMenuVariables
                Menus["vMenuVariables"].alineacion = 'centro';
                Menus["vMenuVariables"].estilo = 'A';
                Menus["vMenuVariables"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuVariables"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Nueva Variable</Desc><Acciones><Ejecutar Tipo='script'><Codigo>variable_nueva()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuVariables"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Acumulador ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>acumulador_ABM()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuVariables"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Pizarra ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_ABM()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenuVariables.MostrarMenu()
            </script>
        </div>
        <div id="div_variable_calculo_am">
            <table id="tb_variable_calculo_am" class="tb1">
                <tr class="tbLabel0">
                    <td style="width: 4%; text-align: center">Nro.</td>
                    <td style="width: 12%; text-align: center">Tipo Variable</td>
                    <td style="width: 18%; text-align: center">Variable</td>
                    <td style="width: 29%; text-align: center">Cálculo</td>
                    <td style="width: 8%; text-align: center">Tipo Dato</td>
                    <td style="width: 6%; text-align: center">Prioridad</td>
                    <td style="width: 20%; text-align: center">Acumulador</td>
                    <td style="width: 3%; text-align: center">-</td>
                </tr>
                <tr>
                    <td style="width: 4%; text-align: center">
                        <input type="hidden" id="indice" name="indice" value="" style="width: 100%" /><input type="text" id="id_calc_var" name="id_calc_var" disabled="disabled" value="" style="width: 100%" /></td>
                    <td style="width: 12%; text-align: left" id="td_id_calc_var_tipo"></td>
                    <td style="width: 18%; text-align: left">
                        <input type="text" id="calc_variable" name="calc_variable" value="" style="width: 100%" /></td>
                    <td style="text-align: left">
                        <input type="text" id="calculo" name="calculo" value="" style="width: 100%" ondblclick="ver_editor(this)" /></td>
                    <td style="width: 8%; text-align: left" id="td_tipo_variable">
                        <select name="tipo_var" id="tipo_var" style="width: 100%">
                            <option value="int">int</option>
                            <option value="datetime">datetime</option>
                            <option value="money">money</option>
                        </select>
                    </td>
                    <td style="width: 6%; text-align: left">
                        <input type="text" id="prioridad" name="prioridad" value="" style="width: 100%" /></td>
                    <td style="width: 20%; text-align: left" id="td_nro_calc_acum"></td>
                    <td style="width: 3%; text-align: center">
                        <img alt="" title="Agregar Variable" src="../../FW/image/icons/agregar_cargo.png" style="cursor: pointer; cursor: hand" onclick="variable_agregar()" /></td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
