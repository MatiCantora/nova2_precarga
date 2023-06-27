<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim parametro_valor = nvUtiles.obtenerValor("parametro_valor", "")
    Dim parametro = nvUtiles.obtenerValor("parametro", "")
    Dim nro_archivo_params = nvUtiles.obtenerValor("nro_archivo_params", "")
    Dim tipo = nvUtiles.obtenerValor("tipo", "")

    Dim nro_archivo = nvUtiles.obtenerValor("nro_archivo", "")
    Dim nro_registro = nvUtiles.obtenerValor("nro_registro", "")
    Dim estado = nvUtiles.obtenerValor("estado", "")
    Dim accion = nvUtiles.obtenerValor("accion", "")

    If accion.Tolower = "guardar" Then
        Dim err As New tError

        If (nro_archivo <> "" And estado <> "") Or (nro_archivo_params <> "") Then
            Try
                If (estado <> "") Then
                    DBExecute("update archivos set nro_archivo_estado = " & estado & " where nro_archivo = " & nro_archivo)
                End If
                If (nro_registro <> "") Then
                    DBExecute("update com_registro set nro_com_estado = 3 where nro_registro =" & nro_registro)
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = -99
                err.titulo = "Error en la actualización del estado"
                err.mensaje = "Mensaje:  " & ex.Message
            End Try


            'If (parametro_valor <> "" Or parametro.toLower = "ar_fe_forzar") Then
            If parametro <> "" Then
                Try
                    DBExecute("update archivos_parametros set parametro_valor = '" & parametro_valor & "' where nro_archivo = " & nro_archivo_params & " and parametro = '" & parametro & "'")
                    If parametro.toLower = "ar_fe_documento" Or parametro.toLower = "ar_fe_forzar" Then
                        err = nvArchivo.recalcacular_vencimientos_archivo(nro_archivo_params)
                        If err.numError <> 0 Then
                            err.numError = -99
                            err.titulo = "Actualización del vencimiento"
                            err.mensaje = "Error en la actualización del el vencimiento del archivo" '& parametro & " valor " & parametro_valor & " archivo " & nro_archivo_params
                        End If
                    End If

                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.numError = -99
                    err.titulo = "Error en la actualización del parámetro"
                    err.mensaje = ex.Message
                End Try

            End If
        Else
            err.numError = -99
            err.titulo = "Error en la actualización del parámetro"
            err.mensaje = "falta definir el archivo"
        End If

        err.response()

    End If

    Me.addPermisoGrupo("permisos_def_archivo")

    Me.contents("filtro_estado_1") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_estado'><campos>nro_archivo_estado as id, archivo_estado as campo</campos><filtro><nro_archivo_estado type='in'>2,3</nro_archivo_estado></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_estado_2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_estado'><campos>nro_archivo_estado as id, archivo_estado as campo</campos><filtro><nro_archivo_estado type='in'>1,2</nro_archivo_estado></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_estado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_estado'><campos>nro_archivo_estado as id, archivo_estado as campo</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_verArchivos_idtipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_VerArchivos_estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerArchivos_estados'><campos>*</campos><filtro></filtro><orden>momento DESC, nro_archivo DESC</orden></select></criterio>")
    Me.contents("filtro_archivos_parametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_parametros'><campos>*</campos><filtro></filtro><orden>orden ASC</orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Editar Estado</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

        <style type="text/css">
        .param_editable{
            position:relative;
            cursor:pointer;
            padding-right: 16px;
            background-image: url(../../fw/image/icons/editar.png);
            background-size: 16px;
            background-repeat: no-repeat;
            background-position: right center;
        }

        </style>

    <script type="text/javascript">

  ///////////////////////////////////////////////////////////
 //********************EDITAR-ESTADO**********************//
///////////////////////////////////////////////////////////
        var tipo
        var nro_archivo
        var winActualizar

        function parseFecha(strFecha) {
            var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
            a = a.substr(0, a.indexOf('.'))
            var fe = new Date(Date.parse(a))
            return fe
        }

        function FechaToSTR(cadena) {
            var objFecha = parseFecha(cadena)
            if (isNaN(objFecha.getDate()))
                return ''
            var dia
            var mes
            var anio
            if (objFecha.getDate() < 10)
                dia = '0' + objFecha.getDate().toString()
            else
                dia = objFecha.getDate().toString()

            if ((objFecha.getMonth() + 1) < 10)
                mes = '0' + (objFecha.getMonth() + 1).toString()
            else
                mes = (objFecha.getMonth() + 1).toString()
            anio = objFecha.getFullYear()
            var modo = 1
            if (modo == 1)
                return dia + '/' + mes + '/' + anio + " " + objFecha.getHours() + ":" + objFecha.getMinutes() + ":" + objFecha.getSeconds()
            else
                return mes + '/' + dia + '/' + anio
        }
        var wine = nvFW.getMyWindow();

        function window_onload() {
            
            //////INFORMACION DOCUMENTO//////
            var Parametros = wine.options.userData.retorno
            nro_archivo = Parametros["nro_archivo"]
            $('nro_archivo').value = nro_archivo
            $('nro_registro').value = Parametros["nro_registro"]            
            $('titulo_nro').update(Parametros["nro_archivo"])




             //////HISTORIAL//////
            id_tipo = Parametros["id_tipo"]
            nro_archivo_id_tipo = Parametros["nro_archivo_id_tipo"]
            nro_def_detalle = Parametros["nro_def_detalle"]
            //$('titulo').update(Parametros["titulo"])
            
            var rsDoc = new tRS();
            var filtroXMLdoc = nvFW.pageContents.filtro_verArchivos_idtipo
            rsDoc.open(filtroXMLdoc, "", "<nro_archivo type='igual'>" + nro_archivo + "</nro_archivo><id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo>", "", "")

            $('documento').update(rsDoc.getdata('archivo_descripcion'))
            $('tipo').update(rsDoc.getdata('def_archivo'))
            tipo = rsDoc.getdata('nro_def_archivo')
            
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_VerArchivos_estados,
                filtroWhere: "<criterio><select ><filtro><nro_def_detalle type='igual'>" + nro_def_detalle + "</nro_def_detalle><id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo></filtro></select></criterio>",
                path_xsl: "report\\archivo\\HTML_historial_archivos.xsl",
                formTarget: 'tbDocs',
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                bloq_contenedor: $('tbDocs'),
                cls_contenedor: 'tbDocs'
            })


            cargarParametros()

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //var strCriterio = nvFW.pageContents.filtro_VerArchivos_estados
            //var rs = new tRS();
            //rs.open(strCriterio, "", "<nro_def_detalle type='igual'>" + nro_def_detalle + "</nro_def_detalle><id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo>")
            //var strHTML = '<table class="tb1  highlightOdd highlightTROver layout_fixed highlightOdd highlightTROver layout_fixed" style="width:100%; maxi-width:800px;">'
            //while (!rs.eof()) {
            //    strHTML += '<tr><td><a target="_blank" href="/fw/archivo/get_file.aspx?nro_archivo=' + rs.getdata('nro_archivo') + '">' + rs.getdata('Descripcion') + '</a></td>'
            //    //strHTML += '<td><a target="_blank" href="/fw/archivo/get_file.aspx?nro_archivo=' + rs.getdata('nro_archivo') + '">' + rs.getdata('path') + '</a></td>'
            //    strHTML += '<td>' + FechaToSTR(rs.getdata('momento')) + '</td><td>' + rs.getdata('nombre_operador') + '</td><td>' + rs.getdata('estado') + '</td></tr>'
            //
            //    //vListButton.MostrarListButton()
            //    rs.movenext()
            //}
            //strHTML += '</table>'
            //$('tbDocs').insert({
            //    top: strHTML
            //})
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            window_onresize()
        }

        function cargarParametros() {

             //////PARAMETROS//////
            $('tbDocsParams').innerHTML = ""
            parametros_archivo = []
            var strCriterioParams = nvFW.pageContents.filtro_archivos_parametros
            var rs1 = new tRS();
            rs1.open(strCriterioParams, "", "<NOT><etiqueta type='isnull'/></NOT><nro_archivo_estado type='in'>1,3</nro_archivo_estado><nro_archivo type='igual'>" + nro_archivo + "</nro_archivo><nro_def_detalle type='igual'>" + nro_def_detalle + "</nro_def_detalle><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo><id_tipo type='igual'>" + id_tipo + "</id_tipo>", "", "")
            var strHTMLparams = '<table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr class="tbLabel0"></tr>' //'<table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr class="tbLabel0"><td>Par&aacute;metro</td><td>Valor</td></tr>'
            var cont = 0
            while (!rs1.eof()) {
                parametros_archivo.push(new tParam_def({
                    parametro: rs1.getdata('parametro'),
                    valor: rs1.getdata('parametro_valor'),
                    etiqueta: rs1.getdata('etiqueta'),
                    tipo_dato: rs1.getdata('tipo_dato'),
                    requerido:  rs1.getdata('requerido') == "True" ? true : false,
                    editable: rs1.getdata('editable') == "True" ? true : false,
                    orden: rs1.getdata('orden'),
                    campo_def: rs1.getdata('campo_def')
                }))
                if (rs1.getdata('editable') == 'True') {
                    strHTMLparams += '<tr><td title="' + rs1.getdata('etiqueta') + '"style="width:70%"><strong>' + rs1.getdata('etiqueta') + '</strong></td><td class="param_editable" onClick="editar_parametros_archivo(' + cont + ',' + nro_archivo + ')">' + rs1.getdata('parametro_valor') + '</td></tr>'
                } else {
                    strHTMLparams += '<tr><td title="' + rs1.getdata('etiqueta') + '"style="width:70%"><strong>' + rs1.getdata('etiqueta') + '</strong></td><td>' + rs1.getdata('parametro_valor') + '</td></tr>'
                }
                cont = cont + 1
                rs1.movenext()
            }
            strHTMLparams += '</table>'
            $('tbDocsParams').insert({ top: strHTMLparams })

        }

        function btnAceptar_onclick_1() {   
            
            nvFW.error_ajax_request('archivo_editar.aspx', {                
                parameters: {
                    nro_archivo: $('nro_archivo').value,
                    nro_registro: $('nro_registro').value,
                    estado: $('estado').value,
                    accion: "guardar"
                },
                onSuccess: function () {
                    wine.options.userData = { retorno: "refresh" }
                    wine.close()
                },
                error_alert: true,
                bloq_msg: 'CARGANDO...'
            })
            
            //Dialog.confirm('¿Esta seguro de que desea cambiar el estado? <br> Una vez realizado el cambio, no se podra revertir por medios convencionales.', {
            //            width: 350,
            //            className: "alphacube",
            //            okLabel: "SI",
            //            cancelLabel: "NO",
            //            onOk: function(win) {
            //                win.close()      
            //                nvFW.error_ajax_request('archivo_editar_estado.aspx', {
            //                    parameters: {
            //                        nro_archivo: $('nro_archivo').value,
            //                        nro_registro: $('nro_registro').value,
            //                        estado: $('estado').value
            //                    },
            //                    onSuccess: function () {
            //                        console.log('success')
            //                        //win.close()
            //                        winPa.options.userData = { retorno: "refresh" }
            //                        $('estado').disabled = true
            //                        winPa.close()
            //                    },
            //                    error_alert: true,
            //                    bloq_msg: 'CARGANDO...'
            //                })
            //            },
            //            onCancel: function (win) {
            //                $('estado').value = 1   
            //            }
            //  
            //})
            //
            //if (browser_confirm('Desea cambiar el estado?') == true) {
            //    $('frm1').submit()
            //    var win = nvFW.getMyWindow()
            //    win.options.userData = { retorno: "refresh" }
            //    win.close()
            //    console.log('true')
            //    return true
            //} else {
            //    console.log('false')
            //    $('estado').value = 1   
            //    return false
            //}
        }

        function editar_parametros_archivo(cont, nro_archivo) {

            var options = {
                width: 600,
                height: 250,
                modal: true,
                title: 'Editar Parámetros',
                minimizable: false,
                maximizable: false,
                closable:true
            }
            
            paramsValue = []
            paramsValue.push(new tParam_def({
                parametro: parametros_archivo[cont].parametro,
                valor: parametros_archivo[cont].valor,
                etiqueta: parametros_archivo[cont].etiqueta,
                tipo_dato: parametros_archivo[cont].tipo_dato,
                requerido: parametros_archivo[cont].requerido,
                editable: parametros_archivo[cont].editable,
                orden: parametros_archivo[cont].orden,
                campo_def: parametros_archivo[cont].campo_def,
                id_param: nro_archivo
            }))

            return nvFW.param_def_setValues(paramsValue, onSave/*(nro_archivo)*/, options)    
            
        }

        function onSave(params) {
            var er = new tError()
            var win = nvFW.getMyWindow()
            try {
                
                //var nro_archivo_params = params[0].id_param
                //console.log(nro_archivo_params)
                nvFW.error_ajax_request('archivo_editar.aspx', {
                    parameters: {
                        parametro_valor: params[0].valor,
                        parametro: params[0].parametro,
                        nro_archivo_params: nro_archivo,
                        accion: "guardar"
                    }, onSuccess: function () {
                        cargarParametros()
                        wine.options.userData = { retorno: "refresh" }
                    },
                    error_alert: true,
                    bloq_msg: 'CARGANDO...'
                })
            } catch (err) {
                alert(err)
            }

            return er
        }

        //function actualizar_start() {
        //    winActualizar = Dialog.info('Actualizando', {
        //        className: "alphacube", width: 250,
        //        contentType: "text/plain",
        //        height: 50,
        //        showProgress: true
        //    });
        //}

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                pie_height = $('topThings').getHeight()
                //divDocs_height = $('tbDocsParams').getHeight()
                //var height = divDocs_height + pie_height + 50
                var height = body_height - pie_height
                $('tbDocsParams').setStyle({ height: height - dif + 'px' })

                window.top.documento.setSize(820, height)
                if (divDocs_height >= 200)
                    var top = window.top.documento.element.offsetTop - divDocs_height + 250
                else
                var top = window.top.documento.element.offsetTop - divDocs_height + 150
                var left = window.top.documento.element.offsetLeft - 50
                window.top.documento.setLocation(top, left)

                window_onresize_historial()
            }
            catch (e) { }
        }

        function def_archivo(nro_def_archivo, accion) { 

                if (!nvFW.tienePermiso('permisos_def_archivo', 2)) {
                    alert('No tiene permiso para Altas ni Edición. Comuniquese con el administrador de sistemas.')
                    return
                }
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_archivos_def_abm = w.createWindow({
                    className: 'alphacube',
                    url: '/fw/def_archivos/archivos_def_ABM.aspx?nro_def_archivo=' + tipo + '&nroArDef=' + $$('span#documento')[0].innerText + '&accion="C"',
                    title: '<b>ABM Definición de Archivos</b>',
                    minimizable: true,
                    maximizable: false,
                    draggable: true,
                    resizable: false,
                    width: 1000,
                    height: 500,
                    onClose: function () {
                        buscar_archivos_def()
                        sessionStorage.clear()
                    }
                });

                win_archivos_def_abm.options.userData = { nro_def_archivo: nro_def_archivo }
                win_archivos_def_abm.showCenter()
        }
        


    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <div id="topThings">
            <div id="divMenuEstado" style="margin: 0px; padding: 0px;"></div>
            <script>
                    var vMenuEstado = new tMenu('divMenuEstado', 'vMenuEstado');
                    vMenuEstado.loadImage("guardar", "/fw/image/icons/guardar.png")
                    Menus["vMenuEstado"] = vMenuEstado
                    Menus["vMenuEstado"].alineacion = 'centro';
                    Menus["vMenuEstado"].estilo = 'A';
                    Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='0' style='width: 86%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Información Documento</Desc></MenuItem>")
                    Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='1' style='width: 14%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnAceptar_onclick_1()</Codigo></Ejecutar></Acciones></MenuItem>")
                    vMenuEstado.MostrarMenu()
            </script>

            <input type="hidden" name="nro_archivo" id="nro_archivo" value="<%= nro_archivo %>" />
            <input type="hidden" name="nro_registro" id="nro_registro" value="<%= nro_registro %>" />

            <table style="width: 100%; vertical-align:top;" class='tb1'>
                <tr class="tbLabel">
                    <td style="text-align:center">Tipo</td>
                    <td style="text-align:center">Documento</td>
                    <td style="text-align:center">Número</td>
                    <td style="text-align:center">Estado</td>
                </tr>

                <tr>
                    <td style="width: 30%"><span id="tipo"></span></td>
                    <td style="width: 30%"><a style="cursor: pointer; text-decoration:underline; color:blue" onClick="def_archivo()"><span id="documento"></span></a></td>
                    <td style="width: 20%; text-align:right"><span id="titulo_nro"></span></td>
                    <td style="width: 20%">
                        <script>
                            var Parametros = wine.options.userData.retorno
                            if (Parametros["nro_archivo_estado"] == 1) {

                                campos_defs.add('estado', {
                                    filtroXML: nvFW.pageContents.filtro_estado_2,
                                    enDB: false,
                                    nro_campo_tipo: 1
                                })

                            } else if (Parametros["nro_archivo_estado"] == 3) {

                                campos_defs.add('estado', {
                                    filtroXML: nvFW.pageContents.filtro_estado_1,
                                    enDB: false,
                                    nro_campo_tipo: 1
                                })
                            }

                            campos_defs.set_value('estado', Parametros["nro_archivo_estado"])
                        </script>
<%--                        <script>
                            campos_defs.add('estado', {
                                filtroXML: nvFW.pageContents.filtro_estado,
                                enDB: false,
                                nro_campo_tipo: 1
                            })
                        </script>--%>
      <%--                  <select name="estado" id="estado" style="width: 100%">
                            <option value="1">Activo</option>
                            <option value="2">Anulado</option>
                            <option value="3">Legajo Fisico</option>
                        </select>--%>
                    </td>
                </tr>
            </table>

            <div id="divMenuHistorial" style="margin: 0px; padding: 0px;"></div>
            <script>
                var vMenuHistorial = new tMenu('divMenuHistorial', 'vMenuHistorial');
                Menus["vMenuHistorial"] = vMenuHistorial
                Menus["vMenuHistorial"].alineacion = 'centro';
                Menus["vMenuHistorial"].estilo = 'A';
                Menus["vMenuHistorial"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Historial</Desc></MenuItem>")
                vMenuHistorial.MostrarMenu()
            </script>
            <iframe name="tbDocs" id='tbDocs'  style="width:100%; max-height:114px;overflow-y: auto; border:none;"></iframe>
            <table id='tbPie' style="width:100%;">
<%--                <tr style="HEIGHT: 8px !Important"><td></td></tr>
                <tr style="HEIGHT: 8px !Important"><td></td></tr>--%>
            </table>
    
            <div id="divMenuParams" style="margin: 0px; padding: 0px;"></div>
            <script>
                var vMenuParams = new tMenu('divMenuParams', 'vMenuParams');
                //vMenuParams.loadImage("hoja", "/fw/image/icons/nueva.png")
                Menus["vMenuParams"] = vMenuParams
                Menus["vMenuParams"].alineacion = 'centro';
                Menus["vMenuParams"].estilo = 'A';
                Menus["vMenuParams"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Parámetros</Desc></MenuItem>")
                //Menus["vMenuParams"].CargarMenuItemXML("<MenuItem id='1' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editar_parametros_archivo()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenuParams.MostrarMenu()
            </script>
      <table class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr class="tbLabel0"><td style="width:70%">Descripción</td><td>Valor</td></tr></table>
    </div>
      
    <div id='tbDocsParams' style="width:100%;overflow-y:auto;"></div>
    <table id='tbPieParams'>
<%--        <tr style="HEIGHT: 8px !Important"><td></td></tr>
        <tr style="HEIGHT: 8px !Important"><td></td></tr>--%>
      </table>

</body>
</html>
