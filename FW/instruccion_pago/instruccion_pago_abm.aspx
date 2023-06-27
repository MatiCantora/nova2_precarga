<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    ' Parametros de llamada AJAX
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim nro_proceso As Integer = nvFW.nvUtiles.obtenerValor("nro_proceso", "0")
    Dim nro_com_grupo As Integer

    If strXML <> "" Then
        Dim err As New tError

        Try
            'Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_instruccion_pago_ABM", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            ' @@@@@@ modificar el nombre del SP
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_instruccion_pago_ABM_2", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@xmlInstruccion_pago", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            Dim rs As ADODB.Recordset = cmd.Execute()

            If Not rs.EOF Then
                nro_proceso = rs.Fields("nro_proceso").Value
                err.params("nro_proceso") = nro_proceso
                err.numError = rs.Fields("numError").Value
                err.mensaje = rs.Fields("mensaje").Value
            End If

        Catch ex As Exception
            err.parse_error_script(ex)
            err.mensaje = "Ocurrió un error al ejecutar el Procedimiento Almacenado. Consulte con el Administrador de Sistemas."
        End Try

        err.response()

    Else

        Dim strSQL = "SELECT distinct nro_com_grupo FROM com_grupos WHERE com_grupo = 'Instrucción de pago'"
        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
        If Not rs.EOF Then
            nro_com_grupo = rs.Fields("nro_com_grupo").Value
        End If

    End If

    ' Cargar el operador actual para tomar datos
    Dim operador As Object

    Try
        operador = nvFW.nvApp.getInstance().operador

        ' Pasar las variables al browser (cliente)
        Me.contents("operador_login") = operador.login
        Me.contents("operador_nombre") = operador.nombre_operador
        Me.contents("operador_nro") = operador.operador
        Me.contents("operador_nro_sucursal") = operador.nro_sucursal
        Me.contents("operador_sucursal") = operador.sucursal
    Catch ex As Exception
    End Try

    Dim path_ABM_entidad As String = "/" + nvFW.nvApp.getInstance.path_rel + "/entidad_abm.aspx" 'ASPX DE ALTA DE ENTIDAD
    If Not System.IO.File.Exists(HttpContext.Current.Server.MapPath(path_ABM_entidad)) Then
        path_ABM_entidad = "/FW/entidades/entidad_abm.aspx"
    End If
    Me.contents("path_ABM_entidad") = path_ABM_entidad

    ' Filtros XML encriptados
    Me.contents("filtro_entidadAdm") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Pago_entidad'><campos>nro_entidad AS id, ISNULL(Abreviacion, razon_social) AS [campo]</campos><orden>campo</orden><filtro><administrada type='igual'>1</administrada></filtro></select></criterio>")
    Me.contents("filtro_entidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>DISTINCT nro_entidad AS id, entidad_desc AS [campo]</campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_opCuenta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>id_cuenta, Razon_social, nro_banco, banco, banco_sucursal, id_banco_sucursal, tipo_cuenta, tipo_cuenta_desc, nro_cuenta, CBU, descripcion_cta, moneda</campos><orden>banco</orden><filtro><nro_entidad type='igual'>%entidad%</nro_entidad></filtro></select></criterio>")
    'Me.contents("filtro_opChequera") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Bj_Cuentas'><campos>DISTINCT chequera, cuenta, empresa, nro_bancoBCRA, banco, nro_moneda</campos><orden>cuenta</orden><filtro><nro_empresa type='igual'>%empresa%</nro_empresa><sql type='sql'>chequera IS NOT NULL</sql></filtro></select></criterio>")
    Me.contents("filtro_opChequera") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_cheques'><campos>id_chequera, nro_chequera AS chequera, nro_cuenta AS cuenta, id_tipo, nro_bancoBCRA, banco, nro_moneda</campos><orden>nro_cuenta</orden><filtro><id_tipo type='igual'>%nro_entidad%</id_tipo><nro_ent_id_tipo type='igual'>1</nro_ent_id_tipo></filtro></select></criterio>")
    Me.contents("filtro_pagoTipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_tipos'><campos>nro_pago_tipo, pago_tipo</campos><orden>nro_pago_tipo</orden><filtro><nro_pago_tipo type='in'>1, 4, 6</nro_pago_tipo></filtro></select></criterio>")
    Me.contents("filtro_inst_pago") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago'><campos>convert(varchar(10), fecha, 103) as fecha, nro_pago_concepto, nro_pago_estado, nro_entidad_origen, nro_entidad_destino, case when Abreviacion_destino is null or Abreviacion_destino = '' then Razon_social_destino else Abreviacion_destino end as Razon_social_destino, nro_pago_tipo, id_cuenta_orig, id_cuenta_dest, importe_pago_det, observaciones, nro_pago_detalle, nro_moneda, nro_pago_tipo_orig</campos><orden>nro_pago_detalle</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_pago_param_registro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_parametros_pertenece_reg'><campos>*</campos><orden>nro_pago_detalle</orden></select></criterio>")

    Me.contents("filtro_iso_cod") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='moneda'><campos>nro_moneda as id, ISO_cod as campo</campos><filtro><activo type='igual'>1</activo></filtro><orden>campo</orden></select></criterio>")

    '--------------------------------------------------------------------------
    ' Si no se cargan estos permisos, la funcion del nvFW.js "tienePermiso" 
    ' no encontrará nada y siempre validará como false
    '--------------------------------------------------------------------------
    Me.addPermisoGrupo("permisos_entidades")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Instruccion de Pago <% = IIf(nro_proceso <> 0, nro_proceso, "Nueva") %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tListButton.css" type="text/css" rel="stylesheet" />
    <%-- Se agrega a "pata" porque se usa una clase para botones --%>
    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <style type="text/css">
        select:disabled {
            background-color: #EBEBE4;
        }
    </style>

    <script type="text/javascript">
        /*---------------------------------------------------------------------
        | Funcion para determinar si un objeto esta vacio
        |--------------------------------------------------------------------*/
        function isEmpty(objeto) {
            for (var key in objeto) {
                if (objeto.hasOwnProperty(key))
                    return false
            }

            return true
        }
    </script>

    <script type="application/javascript">
        var count_instrucciones_pago = 0
        var strXML = ""
        var suma_total = 0
        var ultimo_indice = 0
        var indices = []
        var op_pago = []
        var nro_proceso = parseInt(<% = nro_proceso %>, 10)
        var modificar = nro_proceso != 0
        // Variables para guardar todos los datos segun se elige cuenta / chequera que luego se necesitaran en el armado XML
        var ar_detalles = []
        // Variable arreglo de resumen para pantalla de confirmacion
        var ar_resumen = []
        // Variable global habilitar o deshabilitar
        var deshabilitar_edicion = false
        // Menu principal
        var vMenu
        var arr_parametros_registro = {}
        var win_IP_abm = nvFW.getMyWindow()


        function window_onload() {
            dibujarMenu()
            window_onresize()

            // Setear la fecha con la actual
            campos_defs.set_value("fecha_ip", nvFW.FechaToSTR(new Date()))
            // Setear valor por defecto a Estado de Pago
            campos_defs.set_value("nro_pago_estado", "0")
            // Cargar las opciones de pago en un vector
            cargarPagoTipos()
            // Setear los datos del operador en el vector de resumen
            ar_resumen["operador"] = []
            ar_resumen["operador"]["login"] = nvFW.pageContents.operador_login
            ar_resumen["operador"]["nombre"] = nvFW.pageContents.operador_nombre
            ar_resumen["operador"]["nro"] = nvFW.pageContents.operador_nro
            ar_resumen["operador"]["nro_sucursal"] = nvFW.pageContents.operador_nro_sucursal
            ar_resumen["operador"]["sucursal"] = nvFW.pageContents.operador_sucursal

            // Si estoy en modificar => cargar todos los datos a partir del "nro_proceso"
            if (modificar)
                cargarDatosInstruccionPago()
            else {
                campos_defs.habilitar('nro_pago_estado', false)     // deshabilitar el selector para el Estado ("En espera" por defecto)
                campos_defs.set_value('nro_moneda', 1)
            }
        }


        function dibujarMenu() {
            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verResumen()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

            vMenu.loadImage("guardar", "/FW/image/icons/guardar.png");

            vMenu.MostrarMenu()
        }


        function window_onresize() {
            try {
                var hBody = $$("BODY")[0].getHeight()
                var hMenu = $("divMenu").getHeight()
                var hCabecera = $("cabecera").getHeight()
                var hMenuComentarios = modificar ? $("divMenuComentario").getHeight() : 0
                var hInstruccionesPago = hBody - hMenu - hCabecera - hMenuComentarios

                // Setear la altura para el contenedor de Instrucciones de pago
                // asi puede scrollear libremente si hay muchas instrucciones
                var htbCabeceraIP = $("tbCabeceraIP").getHeight()
                var hTbTotal = $("tbTotal").getHeight()
                var $divDatosIP = $("divDatosIP")

                var hFrameComentarios = modificar ? ($('frame_comentarios').visible() ? $('frame_comentarios').getHeight() : 0) : 4

                $divDatosIP.setStyle({ height: hInstruccionesPago - htbCabeceraIP - hTbTotal - hFrameComentarios + "px" })
                // Setear el scroll si los datos superan la altura del contenedor
                isScrolling($("datosIP").getHeight() > $divDatosIP.getHeight())
            }
            catch (e) { }
        }


        function isScrolling(scroll) {
            $$('.tdScroll').each(function (td) { scroll ? td.show() : td.hide() })
        }


        function setCamposDefsOnchange(fila) {
            // ENTIDAD ORIGEN
            campos_defs.items['entidad_origen_' + fila].onchange = function () {
                var selector_op_origen = $('op_pago_origen_' + fila)
                var selector_op_pago_origen_detalle = $('op_pago_origen_detalle_' + fila)

                if (campos_defs.get_value('entidad_origen_' + fila) != '') {
                    // Activar el selector tipo de operacion ORIGEN
                    selector_op_origen.disabled = false
                    selector_op_origen.onchange()

                    if (selector_op_origen.value == '4') {
                        var $entidad_destino = $('entidad_destino_' + fila + '_desc')
                        $entidad_destino.disabled = false
                        $entidad_destino.onchange()
                    }
                }
                else {
                    // Desactivar el selector tipo de operacion ORIGEN
                    selector_op_origen.value = '1'
                    selector_op_origen.disabled = true
                    selector_op_pago_origen_detalle.value = ''
                    selector_op_pago_origen_detalle.disabled = true
                }
            }

            // IMPORTE
            campos_defs.items['importe_' + fila].onchange = sumarImportes
            //campos_defs.items['importe_' + fila].onblur = formatImporte
        }


        function setearMoneda(e, campo_def) {

            var valor = campos_defs.get_desc('nro_moneda')

            for (var i = 0; i < count_instrucciones_pago; i++) {
                campos_defs.habilitar('nro_moneda_' + indices[i], true)
                campos_defs.set_value('nro_moneda_' + indices[i], valor)
                campos_defs.habilitar('nro_moneda_' + indices[i], false)
            }
        }


        function sumarImportes(e, campo_def) {

            if (typeof campos_defs.items[campo_def] != 'undefined') {
                var valor = parseFloat(campos_defs.get_value(campo_def)).toFixed(2)
                campos_defs.set_value(campo_def, valor)
            }

            // Sumar todos los importes
            var suma = 0

            for (var i = 0; i < count_instrucciones_pago; i++) {
                suma += +campos_defs.get_value('importe_' + indices[i])
            }

            $('totalPago').value = suma
            $('totalPagoFormateado').innerHTML = getPagoFormateado(suma)
        }


        function validar_moneda(fila, target) {
            if (fila == null) {
                var moneda_val = true
                for (var i = 0; i < count_instrucciones_pago; i++) {

                    var nro_fila = indices[i]

                    var id_cuenta_orig = $("op_pago_origen_detalle_" + nro_fila).value
                    //detalle = ar_detalles[nro_fila]["destino"][$("op_pago_destino_detalle_" + nro_fila).value]

                    var dep_id_cuenta = $("op_pago_destino_detalle_" + nro_fila).value

                    if ($('op_pago_destino_' + nro_fila).value != 4)
                        dep_nro_moneda = typeof ar_detalles[nro_fila]["destino"][dep_id_cuenta]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["destino"][dep_id_cuenta]["nro_moneda"] : ""
                    else nro_moneda_orig = campos_defs.get_value('nro_moneda')

                    if ($('op_pago_origen_' + nro_fila).value != 4)
                        nro_moneda_orig = typeof ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] : ""
                    else nro_moneda_orig = campos_defs.get_value('nro_moneda')

                    if (dep_nro_moneda != '' && dep_nro_moneda != campos_defs.get_value('nro_moneda')) {
                        moneda_val = false
                        break;
                    }

                    if (nro_moneda_orig != '' && nro_moneda_orig != campos_defs.get_value('nro_moneda')) {
                        moneda_val = false
                        break;
                    }

                }

                return moneda_val

            } else {

                var mensaje = ''
                var id = $('op_pago_' + target + '_detalle_' + fila).value

                if (id == '')
                    return

                var nro_moneda = ar_detalles[fila][target][id]['nro_moneda']

                var nro_cuenta = ar_detalles[fila][target][id]['nro_cuenta']
                var cbu = ar_detalles[fila][target][id]['CBU']

                if (campos_defs.get_value('nro_moneda') != nro_moneda) {
                    mensaje += 'La moneda del ' + target + ' es distinta a la moneda seleccionada.</br>'
                    $('op_pago_' + target + '_detalle_' + fila).value = ''
                }

                if (nro_cuenta == '' && cbu == "") {
                    mensaje += 'El ' + target + ' seleccionado no posee Nro. de cuenta y CBU.</br>'
                    $('op_pago_' + target + '_detalle_' + fila).value = ''
                }

                if (mensaje != '')
                    alert(mensaje)
            }
        }


        function addInstruccionPago(cargar_desde_rs) {
            // Limpiar cuaquier selección al clickear el botón
            nvFW.selection_clear()

            // Si esta deshabilitada la edicion => retornar
            if (deshabilitar_edicion && !cargar_desde_rs) {
                alert('No es posible agregar una instrucción en éste estado. Sólo se permite en modo <b>"En espera"</b>')
                return
            }

            var strHTML = ""
            var pos = ultimo_indice
            ultimo_indice++

            strHTML += '<tr id="tr_dato_' + pos + '">'
            strHTML += '<td style="width: 21.7%;" id="td_entidad_origen_' + pos + '"></td>'
            strHTML += '<td style="width: 21.5%;">'
            strHTML += '<table class="tb1" cellpading="0" cellspacing="0">'
            strHTML += '<tr><td style="padding: 0; width: 25%;">'
            strHTML += dibujar_selectFormaPago('O', pos)
            strHTML += '</td>'
            strHTML += '<td style="padding: 0; width: 75%;">'
            strHTML += '<select name="op_pago_origen_detalle_' + pos + '" id="op_pago_origen_detalle_' + pos + '" style="width: 100%;" onchange="validar_moneda(' + pos + ', \'origen\')" disabled>'
            strHTML += '<option value="">Seleccionar...</option>'
            strHTML += '</select>'
            strHTML += '</td></tr>'
            strHTML += '</table>'
            strHTML += '</td>'
            strHTML += '<td style="width: 21.5%;" id="td_entidad_destino_' + pos + '"></td>'
            strHTML += '<td style="padding: 0; width: 21.5%;">'
            strHTML += '<table class="tb1" cellpading="0" cellspacing="0">'
            strHTML += '<tr><td style="padding: 0; width: 25%;">'
            strHTML += dibujar_selectFormaPago('D', pos)
            strHTML += '</td>'
            strHTML += '<td style="padding: 0; width: 75%;">'
            strHTML += '<select name="op_pago_destino_detalle_' + pos + '" id="op_pago_destino_detalle_' + pos + '" style="width: 100%;" onchange="validar_moneda(' + pos + ', \'destino\')" disabled>'
            strHTML += '<option value="">Seleccionar...</option>'
            strHTML += '</select>'
            strHTML += '</td>'
            strHTML += '</tr>'
            strHTML += '</table>'
            strHTML += '</td>'
            strHTML += '<td style="width: 5%; text-align: right;"><div style="display: inline-block;" id="div_moneda_' + pos + '"></div></td>'
            strHTML += '<td style="text-align: right; padding: 0;">'
            strHTML += '<div style="width: 85%; display: inline-block;" id="div_importe_' + pos + '"></div>'
            strHTML += '<div style="display: inline-block; text-align: right; width: 15%;">'
            strHTML += '<img alt="Eliminar" src="/FW/image/icons/eliminar.png" title="Eliminar Instrucción de Pago" style="cursor: pointer;" onclick="eliminarInstruccionPago(' + pos + ')" />'
            strHTML += '</div>'
            strHTML += '<input type="hidden" name="nro_pago_detalle_' + pos + '" id="nro_pago_detalle_' + pos + '" value="">'
            strHTML += '</td>'
            strHTML += '</tr>'

            // Insertar el HTML antes del boton de agregar
            $('btnAgregarIP').insert({ before: strHTML })

            /*------------------------------------------------
            | Agregar los campos_defs en el HTML
            |-----------------------------------------------*/
            // entidad_origen
            campos_defs.add('entidad_origen_' + pos, {
                enDB: false,
                nro_campo_tipo: 1,
                filtroXML: nvFW.pageContents.filtro_entidadAdm,
                target: 'td_entidad_origen_' + pos
            })

            // entidad_destino
            //campos_defs.add('entidad_destino_' + pos, {
            //    enDB: false, 
            //    nro_campo_tipo: 3, 
            //    filtroXML: nvFW.pageContents.filtro_entidad, 
            //    campo_desc: 'entidad_desc',
            //    campo_codigo: 'nro_entidad',
            //    target: 'td_entidad_destino_' + pos
            //})

            dibujarEntidadDestino(pos)

            // importe
            campos_defs.add('importe_' + pos, {
                enDB: false,
                nro_campo_tipo: 102,
                target: 'div_importe_' + pos
            })

            campos_defs.add('nro_moneda_' + pos, {
                enDB: false,
                nro_campo_tipo: 104,
                filtroXML: nvFW.pageContents.filtro_iso_cod,
                target: 'div_moneda_' + pos
            })

            campos_defs.set_value('nro_moneda_' + pos, campos_defs.get_desc('nro_moneda'))
            campos_defs.habilitar('nro_moneda_' + pos, false)

            setCamposDefsOnchange(pos)  // Setear evento onchange para los campos_defs
            count_instrucciones_pago++
            actualizarIndices()

            if (!cargar_desde_rs && pos > 0 && campos_defs.get_value('entidad_origen_' + (pos - 1)) != '') {
                campos_defs.set_value('entidad_origen_' + pos, campos_defs.get_value('entidad_origen_' + (pos - 1)))
                if ($('op_pago_origen_' + (pos - 1))) { //Se puede controlar con un array de posiciones
                    $('op_pago_origen_' + pos).value = $('op_pago_origen_' + (pos - 1)).value
                    $('op_pago_origen_' + pos).onchange()
                    $('op_pago_origen_detalle_' + pos).value = $('op_pago_origen_detalle_' + (pos - 1)).value
                }
            }

            // Setear el scrollTop con un valor alto al DIV contenedor de registros para 
            // que no quede tapado el agregado (si es que hay scroll por cantidad)
            $('divDatosIP').scrollTop = 9999

            window_onresize()
        }


        function cargarDatosOpciones(target, tipo, fila) {
            /*-----------------------------------------------
            |       TARGET
            |------------------------------------------------
            |   "O" => ORIGEN
            |   "D" => DESTINO
            |------------------------------------------------
            |       TIPO
            |------------------------------------------------
            |   1 => Depósito / Cuenta
            |   4 => Efectivo
            |   6 => Cheque
            |----------------------------------------------*/

            /*-----------------------------------------------
            |       SELECT -> OPTIONS (posiciones)
            |------------------------------------------------
            |   0: Depósito / Cuenta (1)
            |   1: Efectivo (4)
            |   2: Cheque (6)
            |----------------------------------------------*/
            target = target == "O" ? "origen" : "destino"
            var selector = $("op_pago_" + target + "_detalle_" + fila)

            // Si el selector esta deshabilitado => solo limpiar y deshabilitar
            if ($("op_pago_" + target + "_" + fila).disabled) {
                selector.disabled = true
                selector.value = ""
            }
            else {
                // CU1: EFECTIVO
                if (tipo == "4") {
                    // Deshabilitar pago detalle
                    selector.value = ""
                    selector.disabled = true

                    if (target == "origen") {
                        var op_pago_destino = $("op_pago_destino_" + fila)
                        // Habilitar solo Depósito (1) y Efectivo (4)
                        op_pago_destino.options[0].disabled = false
                        op_pago_destino.options[1].disabled = false
                        op_pago_destino.options[2].disabled = true

                        op_pago_destino.value = "4" // Por defecto -> Efectivo
                        op_pago_destino.onchange()
                    }
                }
                // CU2: DEPOSITO - CHEQUE
                else {
                    if (target == "origen") {
                        var op_pago_destino = $("op_pago_destino_" + fila)

                        op_pago_destino.options[0].disabled = false

                        // CU2.1: Deposito
                        if (tipo == "1") {
                            // Sólo depósito queda habilitado
                            op_pago_destino.options[1].disabled = true
                            op_pago_destino.options[2].disabled = true
                        }
                        // CU2.2: Cheque
                        else if (tipo == "6") {
                            op_pago_destino.options[1].disabled = false
                            op_pago_destino.options[2].disabled = true
                        }

                        op_pago_destino.value = "1"
                        op_pago_destino.onchange()
                    }

                    var rs = new tRS()
                    var strHTML = ""
                    var id = ""

                    strHTML += "<option value=''>Seleccionar...</option>"

                    // Depósito
                    if (tipo == "1") {
                        var entidad_value = target == "origen" ? campos_defs.get_value("entidad_" + target + "_" + fila) : $("entidad_" + target + "_" + fila).value

                        rs.open({
                            filtroXML: nvFW.pageContents.filtro_opCuenta,
                            params: "<criterio><params entidad='" + entidad_value + "' /></criterio>"
                        })

                        if (ar_detalles[fila] == undefined) {
                            ar_detalles[fila] = []
                        }

                        ar_detalles[fila][target] = {}

                        while (!rs.eof()) {
                            id = rs.getdata("id_cuenta")

                            ar_detalles[fila][target][id] = []
                            ar_detalles[fila][target][id]["id_cuenta"] = id
                            ar_detalles[fila][target][id]["razon_social"] = rs.getdata("Razon_social")
                            ar_detalles[fila][target][id]["nro_banco"] = rs.getdata("nro_banco")
                            ar_detalles[fila][target][id]["banco"] = rs.getdata("banco")
                            ar_detalles[fila][target][id]["banco_sucursal"] = rs.getdata("banco_sucursal")
                            ar_detalles[fila][target][id]["id_banco_sucursal"] = rs.getdata("id_banco_sucursal")
                            ar_detalles[fila][target][id]["tipo_cuenta"] = rs.getdata("tipo_cuenta")
                            ar_detalles[fila][target][id]["tipo_cuenta_desc"] = rs.getdata("tipo_cuenta_desc")
                            ar_detalles[fila][target][id]["nro_cuenta"] = rs.getdata("nro_cuenta") == null ? "" : rs.getdata("nro_cuenta")
                            ar_detalles[fila][target][id]["CBU"] = rs.getdata("CBU")
                            ar_detalles[fila][target][id]["descripcion_cta"] = rs.getdata("descripcion_cta")
                            ar_detalles[fila][target][id]["nro_moneda"] = rs.getdata("moneda")

                            strHTML += "<option value='" + id + "'>" + rs.getdata("descripcion_cta") + "</option>"
                            rs.movenext()
                        }
                    }
                    // Cheque
                    else if (tipo == "6") {
                        //var empresa_value = target == "origen" ? campos_defs.get_value("entidad_" + target + "_" + fila) : $("entidad_" + target + "_" + fila).value
                        var nro_entidad = target == "origen" ? campos_defs.get_value("entidad_" + target + "_" + fila) : $("entidad_" + target + "_" + fila).value

                        rs.open({
                            filtroXML: nvFW.pageContents.filtro_opChequera,
                            //params: "<criterio><params empresa='" + empresa_value + "' /></criterio>"
                            params: "<criterio><params nro_entidad='" + nro_entidad + "' /></criterio>"
                        })

                        if (ar_detalles[fila] == undefined) {
                            ar_detalles[fila] = []
                        }

                        ar_detalles[fila][target] = {}

                        while (!rs.eof()) {
                            //id = rs.position //no sirve para identificar
                            id = rs.getdata("id_chequera")

                            ar_detalles[fila][target][id] = []
                            ar_detalles[fila][target][id]["id_cuenta"] = id
                            ar_detalles[fila][target][id]["chequera"] = rs.getdata("chequera")
                            ar_detalles[fila][target][id]["cuenta"] = rs.getdata("cuenta")
                            ar_detalles[fila][target][id]["empresa"] = rs.getdata("empresa")
                            ar_detalles[fila][target][id]["nro_bancoBCRA"] = rs.getdata("nro_bancoBCRA")
                            ar_detalles[fila][target][id]["banco"] = rs.getdata("banco")
                            ar_detalles[fila][target][id]["descripcion_chequera"] = rs.getdata("banco") + " - " + rs.getdata("cuenta")
                            ar_detalles[fila][target][id]["nro_moneda"] = typeof rs.getdata("nro_moneda") != 'undefined' ? rs.getdata("nro_moneda") : 1

                            strHTML += "<option value='" + id + "'>" + ar_detalles[fila][target][id]["descripcion_chequera"] + "</option>"
                            rs.movenext()
                        }
                    }

                    selector.innerHTML = strHTML
                    selector.disabled = false
                }
            }
        }


        function eliminarInstruccionPago(fila) {
            if (deshabilitar_edicion) {
                alert('No es posible eliminar una instrucción en éste estado. Sólo se permite en modo <b>"En espera"</b>')
                return
            }

            $("tr_dato_" + fila).remove()       // Elimiar fila
            ar_detalles[fila] = undefined       // Borrar datos de fila en Detalles
            count_instrucciones_pago--
            actualizarIndices()                 // Indices de filas
            sumarImportes()
            window_onresize()
        }


        function actualizarIndices() {
            var id = ''
            indices.length = 0

            $("datosIP").children[0].childElements().each(function (item, index) {
                if (index < count_instrucciones_pago) // Omitir el ultimo indice que pertenece al boton de agregar
                    indices.push(item.id.replace("tr_dato_", ""))
            })
        }


        function cargar_array_pago_parametro_registro() {
            // A) Obtener todos los # pago detalle
            var pagos_detalle = []

            for (var i = 0; i < count_instrucciones_pago; i++) {
                pagos_detalle.push($('nro_pago_detalle_' + indices[i]).value)
            }

            // B) Hacer la consulta con todos los numeros de pago detalle
            var rs = new tRS()
            rs.open(
                {
                    filtroXML: nvFW.pageContents.filtro_pago_param_registro,
                    filtroWhere: '<criterio><select><filtro><nro_pago_detalle type="in">' + pagos_detalle.join(',').replace(/(^,)|(,$)/g, '') + '</nro_pago_detalle></filtro></select></criterio>'
                })

            // C) Si hay registros, los guardamos en el arreglo
            if (rs.recordcount > 0) {
                while (!rs.eof()) {
                    if (arr_parametros_registro[rs.getdata('nro_pago_detalle')] == undefined) {
                        arr_parametros_registro[rs.getdata('nro_pago_detalle')] = []
                    }

                    arr_parametros_registro[rs.getdata('nro_pago_detalle')].push({ 'nro_pago_tipo': rs.getdata('nro_pago_tipo'), 'pago_parametro': rs.getdata('pago_parametro'), 'pago_parametro_valor': rs.getdata('pago_parametro_valor') })
                    rs.movenext()
                }
            }
        }


        function generarXML() {
            nvFW.selection_clear()

            // Agregar datos de cabecera al resumen
            if (ar_resumen["cabecera"] == undefined) {
                ar_resumen["cabecera"] = []
            }

            // Verificar fecha
            if (campos_defs.get_value("fecha_ip") == "") {
                alert("Seleccione una <b>fecha</b> antes de seguir", {
                    onOk: function (w) {
                        $("fecha_ip").focus()
                        w.close()
                    }
                })

                return false
            }

            ar_resumen["cabecera"]["fecha"] = campos_defs.get_value("fecha_ip")

            // Verificar Concepto
            if (campos_defs.get_value("concepto_ip") == "") {
                alert("Debe seleccionar un <b>concepto</b> para la instrucción de pago")
                return false
            }

            ar_resumen["cabecera"]["concepto"] = campos_defs.get_desc("concepto_ip")
            ar_resumen["cabecera"]["nro_pago_concepto"] = campos_defs.get_value("concepto_ip")

            if (count_instrucciones_pago == 0) {
                alert("No hay datos a guardar")
                return false
            }

            ar_resumen["cabecera"]["estado"] = campos_defs.get_desc("nro_pago_estado")
            ar_resumen["cabecera"]["nro_pago_estado"] = campos_defs.get_value("nro_pago_estado")
            ar_resumen["cabecera"]["observacion"] = campos_defs.get_value("observacion_ip")

            var data = []
            var pos

            // Chequear que cada dato este seteado, a medida que armamos un vector de datos
            for (var i = 0; i < count_instrucciones_pago; i++) {
                // recorrer la fila, comprobar el valor y completar el vector
                data[i] = {}
                pos = indices[i]
                data[i]["orden"] = i

                /*-------------------------------------
                |   ORIGEN
                |------------------------------------*/
                // Entidad
                if (campos_defs.get_value("entidad_origen_" + pos) == "") {
                    alert("Hay una o varias <b>Entidades origen</b> incompletas.")
                    return false
                }

                data[i]["nro_entidad_origen"] = campos_defs.get_value("entidad_origen_" + pos)
                data[i]["nombre_entidad_origen"] = campos_defs.get_desc("entidad_origen_" + pos).split(" (")[0]

                // Opcion de pago[efectivo (4), deposito (1), cheque (6)]
                data[i]["nro_pago_tipo_origen"] = $("op_pago_origen_" + pos).value

                if ($("op_pago_origen_" + pos).value == "4") {
                    data[i]["pago_origen_detalle"] = ""
                }
                else {
                    data[i]["pago_origen_detalle"] = $("op_pago_origen_detalle_" + pos).value
                }

                // Evalua que haya seleccionado cuenta de origen
                if ($("op_pago_origen_" + pos).value != "4" && $("op_pago_origen_detalle_" + pos).value == '') {
                    alert('Debe seleccionar el origen.')
                    return false
                }

                /*-------------------------------------
                |   DESTINO
                |------------------------------------*/
                // Entidad
                if ($("entidad_destino_" + pos).value == "") {
                    alert("Hay una o varias <b>Entidades destino</b> incompletas.")
                    return false
                }

                data[i]["nro_entidad_destino"] = $("entidad_destino_" + pos).value
                data[i]["nombre_entidad_destino"] = $("entidad_destino_" + pos + "_desc").value.split(" (")[0]
                data[i]["nro_pago_tipo_destino"] = $("op_pago_destino_" + pos).value

                // Opcion de pago[efectivo (4), deposito (1), cheque (6)]
                if ($("op_pago_destino_" + pos).value == "4") {
                    data[i]["pago_destino_detalle"] = ""
                }
                else {
                    data[i]["pago_destino_detalle"] = $("op_pago_destino_detalle_" + pos).value
                }

                // Evalua que haya seleccionado cuenta de destino
                if ($("op_pago_destino_" + pos).value == "1" && $("op_pago_destino_detalle_" + pos).value == '') {
                    alert('Debe seleccionar el destino.')
                    return false
                }

                /*-------------------------------------
                |   IMPORTE
                |-------------------------------------*/
                if ($("importe_" + pos).value == "") {
                    alert("Hay uno o más <b>importes</b> sin completar.", {
                        onOk: function (win_alert) {
                            $("importe_" + pos).focus()
                            win_alert.close()
                        }
                    })

                    return false
                }

                data[i]["importe"] = (+$("importe_" + pos).value).toFixed(2)

                // nro_pago_detalle
                data[i]['nro_pago_detalle'] = $('nro_pago_detalle_' + pos).value
            }

            // Vector con pares Origen-Destino
            var ar_pares_origen_destino = []
            data.each(function (item) {
                ar_pares_origen_destino.push(item.nro_entidad_origen + "-" + item.nro_entidad_destino)
            })

            // Usar Set() para eliminar todos los duplicados
            var ar_origen_destino_unicos = [...new Set(ar_pares_origen_destino)]
            // Determinar agrupamiento
            var agrupar = ar_origen_destino_unicos.length < count_instrucciones_pago // true => agrupar || false => no agrupar
            var nro_pago_concepto = campos_defs.get_value("concepto_ip")
            var fecha_pago_concepto = campos_defs.get_value("fecha_ip")
            var nro_pago_estado = campos_defs.get_value("nro_pago_estado")

            // Agregar el campo "datos" al resumen
            if (ar_resumen["datos"] == undefined) {
                ar_resumen["datos"] = []
            }
            else {
                // Si existe => limpiar
                ar_resumen["datos"].length = 0
            }

            // strXML es GLOBAL
            strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>"
            strXML += "<pagos nro_proceso='" + nro_proceso + "' importe='" + $("totalPago").value + "' observacion='" + campos_defs.get_value("observacion_ip") + "' nro_moneda='" + campos_defs.get_value('nro_moneda') + "'>"

            ar_resumen["datos"]["importe_total"] = $("totalPago").value

            // Cargar vector de pago parametros para tenerlo disponible
            cargar_array_pago_parametro_registro()

            /*------------------------------------------------
            | XML agrupado
            |-----------------------------------------------*/
            if (agrupar) {

                if (!validar_moneda(null)) {
                    alert('Un tipo de moneda es distinto al seleccionado.')
                    return false
                }

                ar_origen_destino_unicos.each(function (item, nro_agrupacion) {
                    var total_registro = 0
                    var strXMLdetalle = ""
                    var origen_destino = item.split("-")       // Ejemplo: "403-270" => ["403", "270"]
                    var entidad_origen = origen_destino[0]     // Ejemplo: "403"
                    var entidad_destino = origen_destino[1]     // Ejemplo: "270"
                    var nro_ip = 0                     // usado solo para el array de resumen
                    var fila
                    var param_registro

                    // Cargar datos en el resumen
                    ar_resumen["datos"][nro_agrupacion] = []

                    for (var i = 0; i < count_instrucciones_pago; i++) { // recorrer todos las filas
                        fila = data[i]

                        if (fila == undefined) // fila == undefined => fila que fue procesada, entonces continuar con la siguiente
                            continue

                        // Procesar las filas que coinciden unicamente con el vector ORIGEN-DESTINO unicos
                        if (entidad_origen == fila.nro_entidad_origen && entidad_destino == fila.nro_entidad_destino) {
                            var nro_fila = indices[i]
                            var detalle

                            // Resumen: Descripciones de entidades origen y destino
                            if (ar_resumen["datos"][nro_agrupacion]["entidad_origen"] == undefined) {
                                ar_resumen["datos"][nro_agrupacion]["entidad_origen"] = campos_defs.get_desc("entidad_origen_" + nro_fila)
                            }

                            if (ar_resumen["datos"][nro_agrupacion]["entidad_destino"] == undefined) {
                                ar_resumen["datos"][nro_agrupacion]["entidad_destino"] = $("entidad_destino_" + nro_fila + "_desc").value
                            }

                            // Resumen: Agregar la Instruccione de Pago si no existe
                            if (ar_resumen["datos"][nro_agrupacion]["instruccion_pago"] == undefined) {
                                ar_resumen["datos"][nro_agrupacion]["instruccion_pago"] = []
                            }

                            ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip] = []
                            ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_tipo_origen"] = fila.nro_pago_tipo_origen == "1" ? "Depósito" : fila.nro_pago_tipo_origen == "4" ? "Efectivo" : "Cheque"
                            ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_tipo_destino"] = fila.nro_pago_tipo_destino == "1" ? "Depósito" : fila.nro_pago_tipo_destino == "4" ? "Efectivo" : "Cheque"
                            ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["importe"] = fila.importe

                            strXMLdetalle += "<pago_registro_detalle nro_pago_estado='" + nro_pago_estado + "' nro_pago_tipo='" + fila.nro_pago_tipo_destino + "' nro_pago_tipo_orig='" + fila.nro_pago_tipo_origen + "' importe_pago='" + fila.importe + "' orden='" + fila.orden + "'"

                            total_registro += +fila.importe
                            //CAMBIAR POR SWITCH Y AÑADIR COMPORTAMIENTO DEFAULT SI HAY MAS TIPOS
                            if (fila.nro_pago_tipo_origen == "4") {
                                ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_origen_detalle"] = ""
                            }
                            else if (fila.nro_pago_tipo_origen == "6") {
                                detalle = ar_detalles[nro_fila]["origen"][$("op_pago_origen_detalle_" + nro_fila).value]
                                ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_origen_detalle"] = detalle ? detalle.banco + " - " + detalle.cuenta + " (" + detalle.chequera + ")" : ""
                            }
                            else if (fila.nro_pago_tipo_origen == "1") {
                                // Detalles depósito
                                detalle = ar_detalles[nro_fila]["origen"][$("op_pago_origen_detalle_" + nro_fila).value]
                                ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_origen_detalle"] = detalle ? detalle.descripcion_cta : ""
                            }

                            /*--------------------------------------------------
                            |   Valores de DESTINO
                            |-------------------------------------------------*/
                            // Efectivo
                            if (fila.nro_pago_tipo_destino == "4") {
                                ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_destino_detalle"] = ""
                                strXMLdetalle += " dep_id_cuenta=''"

                                if ($('op_pago_origen_' + nro_fila).value != 4) {
                                    var id_cuenta_orig = $("op_pago_origen_detalle_" + nro_fila).value
                                    nro_moneda_orig = typeof ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] : ""
                                    strXMLdetalle += " id_cuenta_orig='" + id_cuenta_orig + "' nro_moneda_orig='" + nro_moneda_orig + "' >"
                                } else strXMLdetalle += " id_cuenta_orig='' >"
                            }
                            // Depósito y Cheque
                            else {
                                var id_cuenta_orig = $("op_pago_origen_detalle_" + nro_fila).value
                                detalle = ar_detalles[nro_fila]["destino"][$("op_pago_destino_detalle_" + nro_fila).value]

                                var dep_id_cuenta = $("op_pago_destino_detalle_" + nro_fila).value

                                dep_nro_moneda = typeof ar_detalles[nro_fila]["destino"][dep_id_cuenta]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["destino"][dep_id_cuenta]["nro_moneda"] : ""
                                if ($('op_pago_origen_' + nro_fila).value != 4)
                                    nro_moneda_orig = typeof ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] : ""
                                else nro_moneda_orig = campos_defs.get_value('nro_moneda')

                                //if (dep_nro_moneda != '' && dep_nro_moneda != campos_defs.get_value('nro_moneda')) {
                                //    alert('El tipo de moneda de destino es distinto al seleccionado.')
                                //    return false
                                //}

                                //if (nro_moneda_orig != '' && nro_moneda_orig != campos_defs.get_value('nro_moneda')) {
                                //    alert('El tipo de moneda de origen es distinto al seleccionado.')
                                //    return false
                                //}

                                strXMLdetalle += " dep_id_cuenta='" + (detalle ? detalle.id_cuenta : "") + "' dep_nro_moneda='" + dep_nro_moneda + "' id_cuenta_orig='" + id_cuenta_orig + "' nro_moneda_orig='" + nro_moneda_orig + "' >"
                                strXMLdetalle += "<parametros>"
                                strXMLdetalle += "<pago_parametros nro_pago_tipo='1' pago_parametro='id_cuenta' pago_parametro_valor='" + (detalle ? detalle.id_cuenta : "") + "' />"
                                strXMLdetalle += "<pago_parametros nro_pago_tipo='1' pago_parametro='nro_banco' pago_parametro_valor='" + (detalle ? detalle.nro_banco : "") + "' />"
                                strXMLdetalle += "<pago_parametros nro_pago_tipo='1' pago_parametro='nro_banco_sucursal' pago_parametro_valor='" + (detalle ? detalle.id_banco_sucursal : "") + "' />"
                                strXMLdetalle += "<pago_parametros nro_pago_tipo='1' pago_parametro='nro_cuenta' pago_parametro_valor='" + (detalle ? (detalle.nro_cuenta != "" ? detalle.nro_cuenta : detalle.CBU) : "") + "' />"
                                strXMLdetalle += "<pago_parametros nro_pago_tipo='1' pago_parametro='tipo_cuenta' pago_parametro_valor='" + (detalle ? detalle.tipo_cuenta : "") + "' />"

                                // Obtener todos los pago_detalles que pertenecen a registro
                                param_registro = arr_parametros_registro[fila['nro_pago_detalle']]

                                if (param_registro != undefined && param_registro.length > 0) {
                                    param_registro.each(function (param) {
                                        strXMLdetalle += "<pago_parametros nro_pago_tipo='" + param['nro_pago_tipo'] + "' pago_parametro='" + param['pago_parametro'] + "' pago_parametro_valor='" + param['pago_parametro_valor'] + "' />"
                                    })
                                }

                                strXMLdetalle += '</parametros>'

                                ar_resumen["datos"][nro_agrupacion]["instruccion_pago"][nro_ip]["pago_destino_detalle"] = detalle ? detalle.descripcion_cta : ""
                            }

                            strXMLdetalle += '</pago_registro_detalle>'

                            data[i] = undefined // Quitar valores del dato para no volver a procesarlo
                            nro_ip++            // Incrementar contador de instrucciones de pago (solo para el loop "for")
                        }
                    }

                    // Agupar los resultados en el XML
                    strXML += "<pago_registro nro_pago_concepto='" + nro_pago_concepto + "' importe_pago='" + total_registro.toFixed(2) + "' nro_entidad_destino='" + entidad_destino + "' nro_entidad_origen='" + entidad_origen + "' fecha='" + fecha_pago_concepto + "' habilitado='1'>"
                    strXML += "<detalles>"
                    strXML += strXMLdetalle
                    strXML += "</detalles>"
                    strXML += "</pago_registro>"
                })
            }
            /*------------------------------------------------
            | XML sin agrupado - fila por fila
            |-----------------------------------------------*/
            else {
                var fila
                var detalle
                var nro_fila
                var param_registro

                for (var i = 0; i < count_instrucciones_pago; i++) {
                    fila = data[i]
                    nro_fila = indices[i]

                    // Resumen: inicializar nuevo registro
                    ar_resumen["datos"][i] = []

                    if (ar_resumen["datos"][i]["entidad_origen"] == undefined) {
                        ar_resumen["datos"][i]["entidad_origen"] = campos_defs.get_desc("entidad_origen_" + nro_fila)
                    }

                    if (ar_resumen["datos"][i]["entidad_destino"] == undefined) {
                        ar_resumen["datos"][i]["entidad_destino"] = $("entidad_destino_" + nro_fila + "_desc").value
                    }

                    // Agregar la Instruccione de Pago si no existe
                    if (ar_resumen["datos"][i]["instruccion_pago"] == undefined) {
                        ar_resumen["datos"][i]["instruccion_pago"] = []
                    }

                    ar_resumen["datos"][i]["instruccion_pago"][0] = []
                    ar_resumen["datos"][i]["instruccion_pago"][0]["pago_tipo_origen"] = fila.nro_pago_tipo_origen == "1" ? "Depósito" : fila.nro_pago_tipo_origen == "4" ? "Efectivo" : "Cheque"
                    ar_resumen["datos"][i]["instruccion_pago"][0]["pago_tipo_destino"] = fila.nro_pago_tipo_destino == "1" ? "Depósito" : fila.nro_pago_tipo_destino == "4" ? "Efectivo" : "Cheque"
                    ar_resumen["datos"][i]["instruccion_pago"][0]["importe"] = fila.importe

                    strXML += "<pago_registro nro_pago_concepto='" + nro_pago_concepto + "' importe_pago='" + fila.importe + "' nro_entidad_destino='" + fila.nro_entidad_destino + "' nro_entidad_origen='" + fila.nro_entidad_origen + "' fecha='" + fecha_pago_concepto + "' habilitado='1'>"
                    strXML += "<detalles>"

                    // Detalles con parametros segun corresponda
                    strXML += "<pago_registro_detalle nro_pago_estado='" + nro_pago_estado + "' nro_pago_tipo='" + fila.nro_pago_tipo_destino + "' nro_pago_tipo_orig='" + fila.nro_pago_tipo_origen + "' importe_pago='" + fila.importe + "'"
                    //CAMBIAR POR SWITCH Y AÑADIR COMPORTAMIENTO DEFAULT SI HAY MAS TIPOS
                    if (fila.nro_pago_tipo_origen == "4") {
                        ar_resumen["datos"][i]["instruccion_pago"][0]["pago_origen_detalle"] = ""
                    }
                    else if (fila.nro_pago_tipo_origen == "6") {
                        // Detalles de chequera
                        detalle = ar_detalles[nro_fila]["origen"][$("op_pago_origen_detalle_" + nro_fila).value]
                        ar_resumen["datos"][i]["instruccion_pago"][0]["pago_origen_detalle"] = detalle ? detalle.banco + " - " + detalle.cuenta + " (" + detalle.chequera + ")" : ""
                    }
                    else if (fila.nro_pago_tipo_origen == "1") {
                        // Detalles de cuenta
                        detalle = ar_detalles[nro_fila]["origen"][$("op_pago_origen_detalle_" + nro_fila).value]
                        ar_resumen["datos"][i]["instruccion_pago"][0]["pago_origen_detalle"] = detalle ? detalle.descripcion_cta : ""
                    }

                    /* DESTINO */
                    // Efectivo
                    if (fila.nro_pago_tipo_destino == "4") {
                        ar_resumen["datos"][i]["instruccion_pago"][0]["pago_destino_detalle"] = ""
                        strXML += " dep_id_cuenta=''"

                        if ($('op_pago_origen_' + nro_fila).value != 4) {
                            var id_cuenta_orig = $("op_pago_origen_detalle_" + nro_fila).value
                            nro_moneda_orig = typeof ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] : ""
                            strXML += " id_cuenta_orig='" + id_cuenta_orig + "' nro_moneda_orig='" + nro_moneda_orig + "' >"
                        } else strXML += " id_cuenta_orig='' >"
                    }
                    // Depósito
                    else {

                        var id_cuenta_orig = $("op_pago_origen_detalle_" + nro_fila).value
                        var dep_id_cuenta = $("op_pago_destino_detalle_" + nro_fila).value
                        detalle = ar_detalles[nro_fila]["destino"][$("op_pago_destino_detalle_" + nro_fila).value]

                        dep_nro_moneda = typeof ar_detalles[nro_fila]["destino"][dep_id_cuenta]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["destino"][dep_id_cuenta]["nro_moneda"] : ""

                        if ($('op_pago_origen_' + nro_fila).value != 4)
                            nro_moneda_orig = typeof ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] != 'undefined' ? ar_detalles[nro_fila]["origen"][id_cuenta_orig]["nro_moneda"] : ""
                        else nro_moneda_orig = campos_defs.get_value('nro_moneda')

                        if (dep_nro_moneda != '' && dep_nro_moneda != campos_defs.get_value('nro_moneda')) {
                            alert('El tipo de moneda de destino es distinto al seleccionado.')
                            return false
                        }

                        if (nro_moneda_orig != '' && nro_moneda_orig != campos_defs.get_value('nro_moneda')) {
                            alert('El tipo de moneda de origen es distinto al seleccionado.')
                            return false
                        }

                        strXML += " dep_id_cuenta='" + (detalle ? detalle.id_cuenta : "") + "' dep_nro_moneda='" + dep_nro_moneda + "' id_cuenta_orig='" + id_cuenta_orig + "' nro_moneda_orig='" + nro_moneda_orig + "' >"
                        strXML += "<parametros>"
                        strXML += "<pago_parametros nro_pago_tipo='1' pago_parametro='id_cuenta' pago_parametro_valor='" + (detalle ? detalle.id_cuenta : "") + "' />"
                        strXML += "<pago_parametros nro_pago_tipo='1' pago_parametro='nro_banco' pago_parametro_valor='" + (detalle ? detalle.nro_banco : "") + "' />"
                        strXML += "<pago_parametros nro_pago_tipo='1' pago_parametro='nro_banco_sucursal' pago_parametro_valor='" + (detalle ? detalle.id_banco_sucursal : "") + "' />"
                        strXML += "<pago_parametros nro_pago_tipo='1' pago_parametro='nro_cuenta' pago_parametro_valor='" + (detalle ? (detalle.nro_cuenta != "" ? detalle.nro_cuenta : detalle.CBU) : "") + "' />"
                        strXML += "<pago_parametros nro_pago_tipo='1' pago_parametro='tipo_cuenta' pago_parametro_valor='" + (detalle ? detalle.tipo_cuenta : "") + "' />"

                        // Obtener todos los pago_parametros que pertenecen a registro
                        param_registro = arr_parametros_registro[fila['nro_pago_detalle']]

                        if (param_registro != undefined && param_registro.length > 0) {
                            param_registro.each(function (param) {
                                strXML += "<pago_parametros nro_pago_tipo='" + param['nro_pago_tipo'] + "' pago_parametro='" + param['pago_parametro'] + "' pago_parametro_valor='" + param['pago_parametro_valor'] + "' />"
                            })
                        }

                        strXML += "</parametros>"

                        ar_resumen["datos"][i]["instruccion_pago"][0]["pago_destino_detalle"] = detalle ? detalle.descripcion_cta : ""
                    }

                    strXML += '</pago_registro_detalle>'
                    strXML += '</detalles>'
                    strXML += "</pago_registro>"
                }
            }

            strXML += "</pagos>"

            return true
        }


        function cargarPagoTipos() {
            var rs = new tRS()
            var pos
            rs.open(nvFW.pageContents.filtro_pagoTipos)

            while (!rs.eof()) {
                pos = rs.position
                op_pago[pos] = []
                op_pago[pos]["id"] = rs.getdata("nro_pago_tipo")
                op_pago[pos]["valor"] = rs.getdata("pago_tipo") //== "Cheque Bejerman" ? "Cheque" : rs.getdata("pago_tipo")

                rs.movenext()
            }
        }


        var op_pago_html = undefined


        function dibujar_selectFormaPago(target, pos) {
            var target_name = target == 'O' ? 'origen' : 'destino'
            var html = ''
            html += '<select name="op_pago_' + target_name + '_' + pos + '" id="op_pago_' + target_name + '_' + pos + '" onchange="cargarDatosOpciones(\'' + target + '\', this.value, ' + pos + ')" disabled style="width: 100%;">'

            if (op_pago_html == undefined) {
                op_pago_html = ""

                op_pago.each(function (item) {
                    op_pago_html += '<option value="' + item.id + '" ' + (item.id == 1 ? "selected" : "") + '>' + item.valor + '</option>'
                })
            }

            html += op_pago_html
            html += '</select>'

            return html
        }


        // Variable ventana de resumen
        var w_resumen


        function dibujarInstruccionesPago() {
            var strHTML = ''
            strHTML += '<table class="tb1" style="font-size: 13px;">'
            strHTML += '<style>tr.impar { background-color: #f4f4f4; } td.resumen-titulo { background-color: #333333; color: white; padding-left: 3px !important; }</style>'

            // A) Datos del Operador, fecha, concepto y observaciones
            strHTML += '<tr style="height: 20px;">'
            strHTML += '<td class="Tit1" style="width: 10%; padding-left: 3px;">Operador:</td>'
            strHTML += '<td style="width: 25%;"><b>' + ar_resumen.operador.nro + ' - ' + ar_resumen.operador.nombre + ' (' + ar_resumen.operador.login + ')</b></td>'
            strHTML += '<td class="Tit1" style="width: 10%; padding-left: 3px;">Fecha:</td>'
            strHTML += '<td style="width: 10%;"><b>' + ar_resumen.cabecera.fecha + '</b></td>'
            strHTML += '<td class="Tit1" style="width: 10%; padding-left: 3px;">Concepto:</td>'
            strHTML += '<td style="width: 20%;"><b>' + ar_resumen.cabecera.concepto + '</b></td>'
            strHTML += '</tr>'
            strHTML += '<tr style="height: 20px;">'
            strHTML += '<td class="Tit1" style="width: 10%; padding-left: 3px;">Estado:</td>'
            strHTML += '<td><b>' + ar_resumen.cabecera.estado + '</b></td>'
            strHTML += '<td class="Tit1" style="width: 10%; padding-left: 3px;">Observación:</td>'
            strHTML += '<td colspan="3"><i>' + ar_resumen.cabecera.observacion + '</i></td>'
            strHTML += '</tr>'
            strHTML += '</table>'

            // B) Instrucciones de Pago
            strHTML += '<div id="resumenDatos" style="width: 100%; overflow: auto;">'
            strHTML += '<table class="tb1" style="font-size: 13px;" cellpadding="0" cellspacing="0">'
            strHTML += '<tr class="tbLabel">'
            strHTML += '<td style="text-align: center;" colspan="5"><b>Instrucciones de Pago</b></td>'
            strHTML += '</tr>'
            strHTML += '<tr style="height: 20px;">'
            strHTML += '<td class="Tit1" style="text-align: center;" colspan="2"><b>ORIGEN</b></td>'
            strHTML += '<td class="Tit1" style="text-align: center;" colspan="2"><b>DESTINO</b></td>'
            strHTML += '<td class="Tit1" style="text-align: center;"><b>IMPORTE</b></td>'
            strHTML += '</tr>'

            // B.1) Loop sobre los registros
            ar_resumen.datos.each(function (item) {
                var subtotal = 0

                strHTML += '<tr style="height: 20px;">'
                strHTML += '<td class="resumen-titulo" colspan="2" style="width: 45%;"><b>' + quitarID(item.entidad_origen) + '</b></td>'
                strHTML += '<td class="resumen-titulo" colspan="2" style="width: 45%;"><b>' + quitarID(item.entidad_destino) + '</b></td>'
                strHTML += '<td class="resumen-titulo" style="width: 10%; text-align: center;">-</td>'
                strHTML += '</tr>'

                // B.2) Loop sobre las instrucciones de pago del item actual
                item.instruccion_pago.each(function (ip, index) {
                    strHTML += '<tr style="height: 20px;" ' + (index % 2 != 0 ? 'class="impar" ' : '') + '>'
                    strHTML += '<td style="width: 10%;"><b>' + ip.pago_tipo_origen + '</b></td>'
                    strHTML += '<td style="width: 35%;">' + (ip.pago_origen_detalle == "" ? "-" : quitarSinSucursal(ip.pago_origen_detalle)) + '</td>'
                    strHTML += '<td style="width: 10%;"><b>' + ip.pago_tipo_destino + '</b></td>'
                    strHTML += '<td style="width: 35%;">' + (ip.pago_destino_detalle == "" ? "-" : quitarSinSucursal(ip.pago_destino_detalle)) + '</td>'
                    strHTML += '<td style="text-align: right; width: 10%;">$ ' + getPagoFormateado(ip.importe) + '</td>'
                    strHTML += '</tr>'

                    subtotal += +ip.importe
                })

                // B.3) Fila con el sub-total
                strHTML += '<tr style="height: 20px;">'
                strHTML += '<td style="text-align: right; background-color: #dfdfdf !important;" colspan="4"><b>Subtotal&nbsp;</b></td>'
                strHTML += '<td style="text-align: right; background-color: #dfdfdf !important;"><b>$ ' + getPagoFormateado(subtotal.toFixed(2)) + '</b></td>'
                strHTML += '</tr>'
            })

            strHTML += '<tr class="tbLabel">'
            strHTML += '<td style="text-align: right;" colspan="4"><b>Total&nbsp;</b></td>'
            strHTML += '<td style="text-align: right;" colspan="5"><b>$ ' + getPagoFormateado(ar_resumen.datos.importe_total) + '</b></td>'
            strHTML += '</tr>'
            strHTML += '</table></div>'

            // C) Botones de acción
            strHTML += '<table class="tb1" style="font-size: 13px;">'
            strHTML += '<tr>'
            strHTML += '<td style="width: 10%;">&nbsp;</td>'
            strHTML += '<td style="width: 20%;">'
            strHTML += '<input type="checkbox" name="enviar_mail" id="enviar_mail" style="cursor: pointer; margin-right: 10px;" title="Notificar por email" />&nbsp;<b>Notificar por email</b>' //checked="true"
            strHTML += '</td>'
            strHTML += '<td style="width: 10%;">&nbsp;</td>'
            strHTML += '<td style="width: 20%;">'
            strHTML += '<input type="button" class="btnNormal_O" value="Cancelar" onclick="w_resumen.close()" onmouseover="this.className = \'btnOnOver_O\'" onmouseout="this.className = \'btnNormal_O\'" style="width: 100%; background-image: url(/FW/image/icons/eliminar.png); background-repeat: no-repeat; background-size: 16px; background-position: 5px 3px; padding: 2px 0;" />'
            strHTML += '</td>'
            strHTML += '<td style="width: 10%;">&nbsp;</td>'
            strHTML += '<td style="width: 20%;">'
            strHTML += '<input type="button" class="btnNormal_O" value="Confirmar" onclick="guardar()" onmouseover="this.className = \'btnOnOver_O\'" onmouseout="this.className = \'btnNormal_O\'" style="width: 100%; background-image: url(/FW/image/icons/tilde.png); background-repeat: no-repeat; background-size: 16px; background-position: 5px 3px; padding: 2px 0;" />'
            strHTML += '</td>'
            strHTML += '<td style="width: 10%;">&nbsp;</td>'
            strHTML += '</tr>'
            strHTML += '</table>'

            // D) Crear una ventana y pasarle el HTML
            w_resumen = nvFW.createWindow({
                title: "<b>Resumen Instrucción de Pago</b>",
                parentWidthElement: $$("body")[0],
                parentWidthPercent: 0.8,
                parentHeightElement: $$("body")[0],
                parentHeightPercent: 0.8,
                destroyOnClose: true,
                onShow: resizeWinResumen
            })

            w_resumen.setHTMLContent(strHTML)
            w_resumen.showCenter(true)
        }


        function resizeWinResumen(win) {
            try {
                var contenido = win.content
                var hBody = contenido.getHeight()
                var nodos = contenido.childNodes
                var hTableTop = nodos[0].getHeight()
                var hTableBottom = nodos[2].getHeight()

                nodos[1].setStyle({ height: hBody - hTableTop - hTableBottom + "px" })
            }
            catch (e) { }
        }


        function quitarID(str_descripcion) {
            return !str_descripcion ? "" : str_descripcion.split(" (")[0]
        }


        function quitarSinSucursal(str_detalle) {
            return !str_detalle ? "" : str_detalle.replace(" SIN SUCURSAL -", "")
        }


        function verResumen() {
            // SI XML se genero correctamente => dibujar el resumen con la Instruccion de Pago
            if (generarXML()) {
                dibujarInstruccionesPago()
            }
        }


        function guardar() {
            if (deshabilitar_edicion) {
                alert('No es posible guardar en éste estado. Sólo se permite en modo <b>"En espera"</b>')
                return
            }

            var enviar_mail = $("enviar_mail").checked

            error_ajax_request("/FW/instruccion_pago/instruccion_pago_abm.aspx",
                {
                    parameters:
                    {
                        strXML: strXML
                    },
                    onSuccess: function (err) {
                        // Actualizamos el numero de proceso en caso de que sea una instrucción de pago nueva
                        nro_proceso = err.params["nro_proceso"]

                        win_IP_abm.options.userData.hay_modificacion = true;
                        // Limpiar la pantalla principal y sus datos
                        //alert("Instrucción de pago " + (!modificar ? 'guardada' : 'modificada') + " correctamente.",
                        //{
                        //    width: 350,
                        //    onOk: function()
                        //    {
                        // Email
                        if (enviar_mail) {
                            w_resumen.close()
                            enviarMail()
                        }
                        else {
                            //window.location.reload()
                            w_resumen.close()
                            win_IP_abm.close()
                        }
                        //    }
                        //})
                    },
                    onFailure: function (err) {
                        w_resumen.close()
                        alert("Ocurrio un error al " + (!modificar ? 'guardar' : 'modificar') + " la instrucción de pago.<br>Por favor revise los datos ingresados.<br>(" + err.numError + ") " + err.mensaje, { width: 420, height: 150 })
                    },
                    bloq_msg: (!modificar ? 'Guardando' : 'Modificando') + " instrucción de pago...",
                    error_alert: false
                })
        }


        function enviarMail() {

            var subject = 'Notificación - Instrucción de Pago - ' + ar_resumen.cabecera.concepto.split("(")[0]
            var body = "<span><style type='text/css'>*{font-family:Tahoma,Arial,sans-serif;font-size:13px;}.tb{width:100%;border-collapse:collapse;}.tb th,.tb td{border:1px solid grey;text-align:center;}</style></span>"
            body += "<table class='tb'>"
            body += '<tr><th>Nro. Proceso</th><th>Concepto</th><th>Estado</th><th>Operador</th></tr>'
            body += '<tr>'

            try {
                body += '<td>' + nro_proceso + '</td>'
                body += '<td>' + ar_resumen.cabecera.concepto + '</td>'
                body += '<td>' + ar_resumen.cabecera.estado + '</td>'
                body += '<td>' + ar_resumen.operador.login.toUpperCase() + '</td>'
            }
            catch (e) {
                body += '<td colspan="4">Error al obtener datos para el email. Mensaje: ' + e.message + '</td>'
            }

            body += '</tr>'
            body += '</table>'
            body += '<p><b>Para más detalles, visite el siguiente enlace:</b>&nbsp;'

            var url = "/FW/instruccion_pago/instruccion_pago_consultar.aspx?nro_proceso=" + nro_proceso
            var url_href = nvFW.location.origin + "/FW/nvLogin.aspx?app_cod_sistema=" + top.nvSesion.app_cod_sistema + "&url=" + url
            //var url_href = nvFW.location.origin + "/FW/instruccion_pago/instruccion_pago_consultar.aspx?nro_proceso=" + nro_proceso
            body += "<a href='" + url_href + "' target='_blank' style='text-decoration: none;'>Ver instrucción de pago en NOVA</a></p>"
            body += "<br/><b>Observación:</b> " + campos_defs.get_value('observacion_ip') + "<br/>"
            body += "<div contenteditable='true' class='observacion' id='observacion'></div>"

            //var win_sendMail = nvFW.createWindow({
            //    title: "<b>Notificar por mail</b>",
            //    url: '/FW/sendMail.aspx?modo=IP&nro_pago_concepto=' + ar_resumen['cabecera']['nro_pago_concepto'] + '&nro_pago_estado=' + ar_resumen['cabecera']['nro_pago_estado'] + '&subject=' + subject + '&body=' + body,
            //    width: 750,
            //    height: 400,
            //    destroyOnClose: true,
            //    onClose: function () {
            //        window.location.reload()
            //        w_resumen.close()
            //    }
            //})

            //win_sendMail.options.userData = {
            //    adjuntar_pdf: 0,
            //    filtroXML: '',
            //    filtroWhere: '',
            //    path_reporte: '',
            //    filename: '',
            //    observaciones: campos_defs.get_value('observacion_ip')
            //}

            //win_sendMail.showCenter()

            var xmlDatos = "<mail>"
            xmlDatos += "<subject>" + subject + "</subject>"
            xmlDatos += "<body><![CDATA[" + body + "]]></body>"
            xmlDatos += "<nro_pago_concepto>" + ar_resumen['cabecera']['nro_pago_concepto'] + "</nro_pago_concepto>"
            xmlDatos += "</mail>"

            error_ajax_request("/FW/instruccion_pago/instruccion_pago_consultar.aspx",
                {
                    parameters:
                    {
                        nro_proceso: nro_proceso,
                        nro_pago_estado: ar_resumen['cabecera']['nro_pago_estado'],
                        strXMLmail: xmlDatos,
                        adjuntar_pdf: 0,
                        observaciones: campos_defs.get_value('observacion_ip'),
                        modo: 'SM'
                    },
                    onSuccess: function (err) {
                        //window.location.reload()
                        win_IP_abm.close()
                    },
                    onFailure: function (err) {
                    },
                    error_alert: false
                })

        }


        function verificarCombinacion(event) {
            event.ctrlKey && (event.keyCode == 13 || event.which == 13) && addInstruccionPago()
        }


        const locale = 'es-AR'

        function getPagoFormateado(strPago) {
            return (+strPago).toLocaleString(locale, { minimumFractionDigits: 2 })
        }


        function cargarDatosInstruccionPago() {
            // poner un vidrio al inicio de la carga
            nvFW.bloqueo_activar($$("BODY")[0], 'bloq_carga_instrucciones', 'Buscando instrucciones de pago...')

            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (resultado) {
                if (!resultado.eof()) {
                    for (var i = 0, MAX = resultado.recordcount; i < MAX; i++) {
                        // Solo con el primer registro completo informacion de cabecera
                        if (i == 0) {
                            // fecha
                            campos_defs.set_value('fecha_ip', resultado.getdata('fecha'))
                            // concepto
                            campos_defs.set_value('concepto_ip', resultado.getdata('nro_pago_concepto'))
                            // estado
                            campos_defs.set_value('nro_pago_estado', resultado.getdata('nro_pago_estado'))
                            campos_defs.habilitar('nro_pago_estado', false) // siempre deshabilitado
                            deshabilitar_edicion = resultado.getdata('nro_pago_estado') != '0' ? true : false
                            // observaciones
                            campos_defs.set_value('observacion_ip', resultado.getdata('observaciones'))

                            campos_defs.set_value('nro_moneda', typeof resultado.getdata('nro_moneda') == 'undefined' ? 1 : resultado.getdata('nro_moneda'))

                            // Si deshabilitar_edicion == true -> deshabilitar todos los campos de la cabecera
                            if (deshabilitar_edicion) {
                                campos_defs.habilitar('fecha_ip', false)
                                campos_defs.habilitar('concepto_ip', false)
                                campos_defs.habilitar('observacion_ip', false)
                                campos_defs.habilitar('nro_moneda', false)
                            }

                        }

                        addInstruccionPago(true)
                        // entidad origen
                        campos_defs.set_value('entidad_origen_' + i, resultado.getdata('nro_entidad_origen'))
                        // tipo de pago
                        $('op_pago_origen_' + i).value = resultado.getdata('nro_pago_tipo_orig')
                        if (resultado.getdata('nro_pago_tipo_orig') == 6)
                            cargarDatosOpciones('O', 6, i)
                        // cuenta o cbu
                        $('op_pago_origen_detalle_' + i).value = resultado.getdata('id_cuenta_orig')
                        if ($('op_pago_origen_' + i).value == 4) {
                            $('op_pago_origen_' + i).onchange()
                            $('op_pago_destino_detalle_' + i).disabled = false
                        }
                        // tipo de pago
                        $('op_pago_destino_' + i).value = resultado.getdata('nro_pago_tipo')
                        // entidad destino
                        //campos_defs.set_value('entidad_destino_' + i, resultado.getdata('nro_entidad_destino'))
                        $('entidad_destino_' + i).value = resultado.getdata('nro_entidad_destino')
                        $('entidad_destino_' + i + '_desc').value = resultado.getdata('Razon_social_destino') + ' (' + resultado.getdata('nro_entidad_destino') + ')'
                        $('entidad_destino_' + i + '_desc').onchange()
                        // cuenta o cbu
                        $('op_pago_destino_detalle_' + i).value = resultado.getdata('id_cuenta_dest')
                        if ($('op_pago_destino_' + i).value == 4)
                            $('op_pago_destino_detalle_' + i).disabled = true
                        // importe
                        var valor = parseFloat(resultado.getdata('importe_pago_det')).toFixed(2)
                        campos_defs.set_value('importe_' + i, valor)
                        campos_defs.set_value('nro_moneda_' + i, campos_defs.get_desc('nro_moneda'))
                        campos_defs.habilitar('nro_moneda_' + i)
                        //campos_defs.set_value('importe_' + i, resultado.getdata('importe_pago_det'))
                        // HIDDEN: nro_pago_detalle
                        $('nro_pago_detalle_' + i).value = resultado.getdata('nro_pago_detalle')

                        if (deshabilitar_edicion) {
                            campos_defs.habilitar('entidad_origen_' + i, false)
                            $('op_pago_origen_' + i).disabled = true
                            $('op_pago_origen_detalle_' + i).disabled = true
                            //campos_defs.habilitar('entidad_destino_' + i, false)
                            $('entidad_destino_' + i + '_desc').disabled = true
                            $('op_pago_destino_' + i).disabled = true
                            $('op_pago_destino_detalle_' + i).disabled = true
                            campos_defs.habilitar('importe_' + i, false)
                        }

                        // siguiente registro
                        resultado.movenext()
                    }

                    // quitar el vidrio
                    nvFW.bloqueo_desactivar(null, 'bloq_carga_instrucciones')
                }
            }

            rs.onError = function (resultado) {
                // quitar el vidrio, si entro por error
                nvFW.bloqueo_desactivar(null, 'bloq_carga_instrucciones')
                alert(rs.lastError.numError + ' : ' + rs.lastError.mensaje)
                return
            }

            rs.open({
                filtroXML: nvFW.pageContents.filtro_inst_pago,
                filtroWhere: '<nro_proceso type="igual">' + nro_proceso + '</nro_proceso>'
            })
        }


        var fila_en_edicion = -1

        function editarEntidad(elem, fila) {

            if (deshabilitar_edicion) {
                alert('No es posible ingresar al ABM de Entidades en éste estado. Sólo se permite en modo <b>"En espera"</b>')
                return
            }

            if (!nvFW.tienePermiso("permisos_entidades", 1)) {
                alert("No posee el permiso necesario para ingresar al ABM de Entidades. Consulte con el Administrador")
                return
            }

            var $input_hidden = $('entidad_destino_' + fila)

            var nro_entidad = $input_hidden.value

            if (nro_entidad != '') {
                var url = nvFW.pageContents.path_ABM_entidad + '?nro_entidad=' + nro_entidad

                var win_entidad_abm = window.top.nvFW.createWindow({
                    url: url,
                    title: '<b>Entidad ABM</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 1024,
                    height: 480,
                    resizable: true,
                    destroyOnClose: true,
                    onClose: function (win) { entidad_abm_onclose(win, nro_entidad); }
                })

                win_entidad_abm.options.userData = { recargar: false }
                win_entidad_abm.showCenter(true)
            }

        }

        function entidad_abm_onclose(win, nro_entidad) {
            if (win.options.userData.recargar) {
                for (var i = 0; i < count_instrucciones_pago; i++) {
                    var nro_entidad_destino = $('entidad_destino_' + i).value
                    //SI ES LA ENTIDAD MODIFICADA ACTUALIZO SELECT
                    if (nro_entidad == nro_entidad_destino) {
                        //GUARDO VALOR PARA VOLVER A SELECCIONARLO
                        var valorSelect = $('op_pago_destino_detalle_' + i).value
                        //RECARGO OPCIONES DEL SELECT
                        campoEntidadDestinoOnchange($('entidad_destino_' + i + '_desc'), i)
                        $('op_pago_destino_detalle_' + i).value = valorSelect
                        //SI ELIMINO LA CUENTA QUE ESTABA SELECCIONADA
                        if ($('op_pago_destino_detalle_' + i).options.selectedIndex == -1)
                            $('op_pago_destino_detalle_' + i).value = ""
                    }
                }
            }
        }

        function abrirEntidadABM(elem, con_seleccion, fila) {
            fila_en_edicion = fila == undefined ? -1 : fila

            // si el elemento está deshabilitado -> retornar
            if (elem != undefined)
                if (elem.disabled) return

            if (deshabilitar_edicion) {
                alert('No es posible ingresar al ABM de Entidades en éste estado. Sólo se permite en modo <b>"En espera"</b>')
                return
            }

            if (!nvFW.tienePermiso("permisos_entidades", 1)) {
                alert("No posee el permiso necesario para ingresar al ABM de Entidades. Consulte con el Administrador")
                return
            }
            else {
                con_seleccion = con_seleccion != undefined ? con_seleccion : false

                var win_ABMEntidad = top.nvFW.createWindow({
                    title: '<b>Entidades Buscar</b>',
                    //url: 'Entidad_seleccionar.aspx' + (con_seleccion ? '?origen=C' :  ''),
                    url: '/FW/funciones/entidad_consultar.aspx' + (con_seleccion ? '?alta_operador=1' : '?alta_operador=0'),
                    maximizable: true,
                    minimizable: true,
                    resizable: true,
                    draggable: true,
                    height: 500,
                    width: 1000,
                    destroyOnClose: true,
                    onClose: function (win) {
                        var datos = win.options.userData

                        if (fila_en_edicion != -1 && datos != null) {
                            // cargar el campo destino con los valores
                            //cargarDatosEntidadDestino(fila_en_edicion, datos.res.nro_entidad, datos.res.razon_social, datos.res.abreviacion)
                            cargarDatosEntidadDestino(fila_en_edicion, datos.entidad.nro_entidad, datos.entidad.razon_social, datos.entidad.abreviacion)
                        }
                    }
                })

                win_ABMEntidad.showCenter()
            }
        }


        function verComentarios() {
            var $frmComentarios = $('frame_comentarios')
            var $img = $('vMenuCom_img0')

            if (!$frmComentarios.visible()) {
                $frmComentarios.show()                  // Mostrar los comentarios
                $img.src = '/FW/image/tMenu/menos.gif'  // Cambiar icono del boton por el '-'
            }
            else {
                $frmComentarios.hide()                  // Volver todo al estado original
                $img.src = '/FW/image/tMenu/mas.gif'    // Cambiar icono del boton por el '+'
            }

            window_onresize()                           // Acomodar todos los elementos
        }


        // Funcion para dibujar un campo_def para la columna "Entidad destino"
        function dibujarEntidadDestino(fila) {
            if (fila == -1) return

            fila_en_edicion = fila

            var strHTML = ""
            strHTML += '<table class="tb1" id="campo_def_tbentidad_destino_' + fila + '" cellspacing="0" cellpadding="0" border="0">'
            strHTML += '<tbody><tr><td style="width: 100%; text-align:center; white-space:nowrap;">'
            strHTML += '<input type="hidden" name="entidad_destino_' + fila + '" id="entidad_destino_' + fila + '" value="" />'
            strHTML += '<input type="text" id="entidad_destino_' + fila + '_desc" style="width: 100%" readonly="true" ondblclick="return abrirEntidadABM(this, true, ' + fila + ')" onchange="return campoEntidadDestinoOnchange(this, ' + fila + ')" />'
            strHTML += '<img src="/FW/image/campo_def/down.png" class="img_down" border="0" align="absmiddle" hspace="1" id="img_down"  onclick="return abrirEntidadABM($(\'entidad_destino_' + fila + '_desc\'), true, ' + fila + ')">'
            //strHTML += '</td><td>'
            //strHTML += '<img src="/FW/image/campo_def/buscar.png" alt="Seleccionar" style="cursor: pointer;" id="btnSel_entidad_destino_' + fila + '" onclick="return abrirEntidadABM($(\'entidad_destino_' + fila + '_desc\'), true, ' + fila + ')" />'
            strHTML += '</td><td>'
            strHTML += '<img src="/FW/image/icons/editar.png" alt="Limpiar" style="cursor: pointer;" id="btnLim_entidad_destino_' + fila + '" onclick="return editarEntidad($(\'entidad_destino_' + fila + '_desc\'), ' + fila + ')" />'
            strHTML += '</td><td>'
            strHTML += '<img src="/FW/image/campo_def/cancelar.png" alt="Limpiar" style="cursor: pointer;" id="btnLim_entidad_destino_' + fila + '" onclick="return limpiarCampoEntidadDestino($(\'entidad_destino_' + fila + '_desc\'), ' + fila + ')" />'
            strHTML += '</td></tr></tbody></table>'

            $('td_entidad_destino_' + fila).insert({ top: strHTML })
        }


        function cargarDatosEntidadDestino(fila, nro_entidad, razon_social, abreviacion) {
            var $input_hidden = $('entidad_destino_' + fila)
            var $input_desc = $('entidad_destino_' + fila + '_desc')

            $input_hidden.value = nro_entidad   // ID va en campo hidden
            $input_desc.value = (abreviacion == "" || abreviacion == undefined ? razon_social : abreviacion) + ' (' + nro_entidad + ')'   // descripción
            $input_desc.onchange()
        }


        function limpiarCampoEntidadDestino(elem, fila) {
            if (elem.disabled) return

            elem.value = ""
            elem.previous().value = ""
            elem.onchange()
        }


        function campoEntidadDestinoOnchange(elem, fila) {
            if (elem.disabled) return

            var selector_op_destino = $("op_pago_destino_" + fila)
            var selector_op_pago_destino_detalle = $("op_pago_destino_detalle_" + fila)
            // campo hidden
            var $entidad_destino_hidden = elem.previous()

            if ($entidad_destino_hidden.value != "") {
                // Activar el selector tipo de operacion DESTINO
                selector_op_destino.disabled = false

                if (selector_op_destino.value != "4") {
                    cargarDatosOpciones("D", selector_op_destino.value, fila)
                }
            }
            else {
                // Desactivar los select de forma de pago y su detalle
                selector_op_destino.value = "1"
                selector_op_destino.disabled = true
                selector_op_pago_destino_detalle.value = ""
                selector_op_pago_destino_detalle.disabled = true
            }
        }
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;" onkeyup="return verificarCombinacion(event)">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;"></div>
    <table class="tb1" id="cabecera">
        <tr>
            <td class="Tit1">Fecha:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("fecha_ip", nro_campo_tipo:=103, enDB:=False) %>
            </td>
            <td class="Tit1">Concepto:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("concepto_ip", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='verPago_conceptos_instruccionPago'><campos>nro_pago_concepto AS id, pago_concepto AS [campo]</campos><orden>campo</orden></select></criterio>") %>
            </td>
            <td class="Tit1">Estado:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("nro_pago_estado") %>
            </td>
            <td class="Tit1">Moneda:</td>
            <td>
                <script>
                    campos_defs.add('nro_moneda', {
                        mostrar_codigo: false,
                        onchange: setearMoneda
                    })
                </script>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Observación:</td>
            <td colspan="7">
                <% = nvFW.nvCampo_def.get_html_input("observacion_ip", enDB:=False, nro_campo_tipo:=104) %>
            </td>
        </tr>
    </table>
    <div id="instruccionesPago">
        <%-- Cabecera de la tabla Instruccion de Pago --%>
        <table class="tb1" id="tbCabeceraIP">
            <tr class="tbLabel">
                <td colspan="2" style="text-align: center; font-weight: bold !important;">ORIGEN</td>
                <td colspan="2" style="text-align: center; font-weight: bold !important;">DESTINO</td>
                <td style="text-align: center; width: 14%; font-weight: bold !important;" colspan="2">Importe</td>
                <td style="width: 14px; display: none;" class="tdScroll">&nbsp;&nbsp;</td>
            </tr>
            <tr class="tbLabel0">
                <td style="text-align: center; width: 21.5%;">Entidad<img alt="abm entidad" src="/FW/image/icons/login.png" style="cursor: pointer; float: right;" onclick="abrirEntidadABM()" title="Abrir Entidad ABM" /></td>
                <td style="text-align: center; width: 21.5%;">Débito</td>
                <td style="text-align: center; width: 21.5%;">Entidad<img alt="abm entidad" src="/FW/image/icons/login.png" style="cursor: pointer; float: right;" onclick="abrirEntidadABM()" title="Abrir Entidad ABM" /></td>
                <td style="text-align: center; width: 21.5%;">Crédito</td>
                <td style="width: 14%;" colspan="2">&nbsp;</td>
                <td style="width: 14px; display: none;" class="tdScroll">&nbsp;&nbsp;</td>
            </tr>
        </table>
        <%-- Datos de la tabla Instruccion de Pago --%>
        <div id="divDatosIP" style="overflow: auto;">
            <table class="tb1" id="datosIP">
                <tbody>
                    <%-- Cada TR es una Instruccion de Pago --%>
                    <tr id="btnAgregarIP">
                        <td colspan="5" style="text-align: center;">
                            <img alt="Agregar instruccion de pago" src="/FW/image/icons/agregar.png" title="Agregar instrucción de pago" onclick="return addInstruccionPago()" style="cursor: pointer;" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <table class="tb1" id="tbTotal">
            <tr class="tbLabel">
                <td style="width: 90%; text-align: right; font-weight: bold !important;">TOTAL&nbsp;</td>
                <td style="text-align: right; font-weight: bold !important;">
                    <input type="hidden" value="" name="totalPago" id="totalPago" />
                    $ <span id="totalPagoFormateado">0,00</span>
                </td>
            </tr>
        </table>
    </div>

    <%-- Módulo de comentarios --%>
    <% If nro_proceso <> 0 Then %>
    <div id="divMenuComentario"></div>
    <script type="text/javascript">
        var vMenuCom = new tMenu('divMenuComentario', 'vMenuCom')

        vMenuCom.loadImage('mas', '/FW/image/tMenu/mas.gif')
        vMenuCom.alineacion = 'centro';
        vMenuCom.estilo = 'A';
        vMenuCom.CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>mas</icono><Desc>Ver comentarios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verComentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuCom.CargarMenuItemXML("<MenuItem id='1' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

        vMenuCom.MostrarMenu()
    </script>
    <%--
        nro_com_id_tipo = 8;    ID del nuevo tipo de comentario  => "Instruccion de pago"
        nro_com_grupo   = 27;   ID del nuevo grupo de comentario => "Instruccion de pago"
        id_tipo         = XYZ;  ID con el que se buscan todos los comentarios relacionados a éste grupo. Aquí se usa el Número de Proceso (nro_proceso)
    --%>
    <%--<iframe style='display: none; width: 100%; height: 235px; border: none;' name='frame_comentarios' id='frame_comentarios' src='/fw/comentario/verCom_registro.aspx?nro_com_id_tipo=8&nro_com_grupo=27&collapsed_fck=1&id_tipo=<% = nro_proceso %>&do_zoom=0'></iframe>--%>
    <iframe style='display: none; width: 100%; height: 235px; border: none;' name='frame_comentarios' id='frame_comentarios' src='/fw/comentario/verCom_registro.aspx?nro_com_id_tipo=8&nro_com_grupo=<% = nro_com_grupo %>&collapsed_fck=1&id_tipo=<% = nro_proceso %>&do_zoom=0'></iframe>
    <% End If %>
</body>
</html>
