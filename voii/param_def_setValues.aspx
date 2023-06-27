<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageVOII" %>
<%

    Dim typevalue = nvUtiles.obtenerValor("typevalue", "")
    Dim param = nvUtiles.obtenerValor("param", "")
    Dim nro_archivo = nvUtiles.obtenerValor("nro_archivo", "")
    Dim param_valor = nvUtiles.obtenerValor("param_valor", "")
    Dim err As New tError


    'If (parametro_valor <> "" Or parametro.toLower = "ar_fe_forzar") Then
    If param <> "" Then
        Try

            DBExecute("update archivos_parametros set parametro_valor = '" & param_valor & "' where nro_archivo = " & nro_archivo & " and parametro = '" & param & "'")
            If param.toLower = "ar_fe_documento" Or param.toLower = "ar_fe_forzar" Then
                err = nvArchivo.recalcacular_vencimientos_archivo(nro_archivo)
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
        err.response()
    End If

    'If param <> "" Then
    '    Stop
    '    Dim err As New tError
    '    Try
    '        DBExecute("update archivos_parametros set parametro_valor = '" & param_valor & "' where nro_archivo = " & nro_archivo & " and parametro = '" & param & "'")
    '    Catch ex As Exception
    '        err.parse_error_script(ex)
    '        err.numError = -99
    '        err.titulo = "Error en la actualización del parametro"
    '        err.mensaje = "Mensaje:  " & ex.Message
    '    End Try
    '    err.response()
    'End If

    Me.contents("filtroReclamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReclamo_documentacion'><campos>documento,tipo_docu,tipreldesc,ofinrodoc,nro_docu,cuil,nro_op,Razon_social_sol,tiprel,fecha_docu,reclamable,fecha_forzada,[Razon_social],[f_id],[path],[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[def_archivo],[nro_def_detalle],[nro_def_archivo],[archivo_descripcion],[requerido],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[momento],[operador],[nro_archivo_estado],[nro_registro],[fe_venc],fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento, getdate() as todayDate</campos><filtro></filtro><orden>id_tipo</orden></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Editar</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var default_accion = ""
        var callback_onSave
        var myWindow

        var winParam = nvFW.getMyWindow()

        var param
        var nro_archivo 
        var def_archivos 
        var venc 
        var td 
        var documentos
        var razon_social 
        var tip_doc 
        var nro_doc
        var def
        var param_valor
        var typevalue = 0
        
        function window_onload()
        {
            nro_archivo = winParam.options.userData.nro_archivo
            param = winParam.options.userData.parametro
            def_archivos = winParam.options.userData.def_archivos
            documentos = winParam.options.userData.documentos
            razon_social = winParam.options.userData.razon_social
            tip_doc = winParam.options.userData.tip_doc
            nro_doc = winParam.options.userData.nro_doc
            param_valor = winParam.options.userData.param_valor
            venc = winParam.options.userData.venc
            td = winParam.options.userData.td

            console.log(nro_archivo)

            $('tipo').innerHTML = def_archivos
            $('documento').innerHTML = documentos
            $('titulo_nro').innerHTML = nro_archivo
            $('razon_social').innerHTML = razon_social
            $('tip_doc').innerHTML = tip_doc
            $('nro_doc').innerHTML = nro_doc

            if (param == 'ar_param_seg') {
                $('parametro_tit').innerHTML = 'Forzar Seguimiento'
                campos_defs.add('id_ar_param_seg', {
                    enDB: true,
                    target: 'parametro_val'
                })
                campos_defs.items['id_ar_param_seg'].onchange = function (campo_def) {
                    setValues()
                }
                def = 'id_ar_param_seg'
                campos_defs.set_value('id_ar_param_seg', td.innerHTML)

            } else if (param == 'ar_fe_forzar') {
                typevalue = 1
                $('parametro_tit').innerHTML = 'Forzar Vencimiento'
                campos_defs.add('ar_fe_forzar', {
                    enDB: false,
                    nro_campo_tipo: 103,
                    target: 'parametro_val'
                })
                campos_defs.items['ar_fe_forzar'].onchange = function (campo_def) {
                    setValues()
                }
                def = 'ar_fe_forzar'
                campos_defs.set_value('ar_fe_forzar', td.innerHTML)

            } else if (param == 'ar_fe_documento') {
                typevalue = 1
                $('parametro_tit').innerHTML = 'Fecha del Documento'
                campos_defs.add('ar_fe_documento', {
                    enDB: false,
                    nro_campo_tipo: 103,
                    target: 'parametro_val'
                })
                campos_defs.items['ar_fe_documento'].onchange = function (campo_def) {
                    setValues()
                }
                def = 'ar_fe_documento'
                campos_defs.set_value('ar_fe_documento', td.innerHTML)
            }

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

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("confirmar", '/FW/image/icons/confirmar.png');
            vListButton.loadImage("cancelar", '/FW/image/icons/cancelar.png');
            vListButton.MostrarListButton()

        }

        function setValues() {
            param_valor = $(def).value
        }

        function cancelar() { winParam.close() }

        function guardar() {
            var valueParam = param_valor

            if (param != 'ar_param_seg' && param_valor != '') {
                //param_valor = param_valor.substr(3, 2) + "/" + param_valor.substr(0, 2) + "/" + param_valor.substr(6, 4)
            }

            nvFW.error_ajax_request('param_def_setValues.aspx', {
                parameters: { param: param, nro_archivo: nro_archivo, param_valor: param_valor, typevalue: typevalue},
                onSuccess: function (err, transport) {
                    td.innerHTML = valueParam

                    //if (nro_archivo != '') {
                        var rs = new tRS()

                        rs.open({
                            filtroXML: nvFW.pageContents.filtroReclamos,
                            filtroWhere: '<criterio><select><filtro><nro_archivo type="igual">' + nro_archivo + '</nro_archivo></filtro></select></criterio>'
                        })
                    console.log(rs.getdata('fe_venc'))
                    if (!rs.getdata('fe_venc')) {        
                        winParam.close()
                    } {
                        var fecha = rs.getdata('fe_venc')
                        venc.innerHTML = fecha.substr(8, 2) + "/" + fecha.substr(5, 2) + "/" + fecha.substr(0, 4)
                    }


                    winParam.close()
                }
            });
              
        }



    </script>
</head>
<body style="overflow: hidden;" onload="window_onload()">
    <form onsubmit="return false;" autocomplete="off">
            <table style="width: 100%; vertical-align:top;" class='tb1 highlightEven highlightTROver layout_fixed'>
                <tr class="tbLabel">
                    <td style="width: 40%; text-align:center">Tipo</td>
                    <td style="width: 40%; text-align:center">Documento</td>
                    <td style="width: 20%; text-align:center">Número</td>
                </tr>

                <tr>
                    <td style="width: 40%"><span id="tipo"></span></td>
                    <td style="width: 40%"><span id="documento"></span></td>
                    <td style="width: 20%; text-align:right"><span id="titulo_nro"></span></td>
                </tr>
            </table>
            <table style="width: 100%; vertical-align:top;" class='tb1 highlightEven highlightTROver layout_fixed'>
                <tr class="tbLabel">
                    <td style="width: 40%; text-align:center">Razon Social</td>
                    <td style="width: 20%; text-align:center">Tipo Documento</td>
                    <td style="width: 40%; text-align:center">Nro. Documento</td>
                </tr>

                <tr>
                    <td style="width: 45%"><span id="razon_social"></span></td>
                    <td style="width: 10%"><span id="tip_doc"></span></td>
                    <td style="width: 45%; text-align:right"><span id="nro_doc"></span></td>
                </tr>
            </table>
        <table style="width: 100%; vertical-align:top;" class='tb1'>
                <tr class="tbLabel">
                    <td>
                        <span id="parametro_tit"></span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="parametro_val"></span>
                    </td>
                </tr>
            </table>

        <table class="tb1">
            <tbody id="tableEdit"></tbody>
        </table>
        <table class="tb1" style="position:absolute; bottom:0">
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
    </form>
</body>
</html>