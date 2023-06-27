<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    
    Dim op = nvFW.nvApp.getInstance.operador

    Dim ErrPermiso As New nvFW.tError()
    If Not op.tienePermiso("permisos_solicitudes", 3) Then
        Response.Redirect("/FW/error/httpError_401.aspx")
    End If

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "C")         '//Modos --->    'C': Consulta - M: Modif.Parámetros

    If modo.ToUpper() = "M" Then
        Dim pErr As New tError()

        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sol_param_def_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()


            pErr.numError = rs.Fields("numError").Value
            pErr.titulo = rs.Fields("titulo").Value
            pErr.mensaje = rs.Fields("mensaje").Value
            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception

            pErr.numError = -1
            pErr.mensaje = "Error inesperado"
            pErr.titulo = "Error al tratar de realizar la operación"
            pErr.debug_desc = ex.Message.ToString
            pErr.debug_src = "sol_param_def_abm"

        End Try

        pErr.response()

    End If

    Me.contents("filtroTablasSimples") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_tablas_simples'><campos>nro_tabla_simple AS codigoID</campos><filtro><descripcion type='igual'>'Tipo Solicitud'</descripcion></filtro><orden></orden></select></criterio>")

    Me.contents("filtro_sol_parametros_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='sol_param_def'><campos>*</campos><orden>orden</orden><filtro></filtro></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Parametros Solicitud</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <% = Me.getHeadInit()%>
    
    <script type="text/javascript">

        function window_onload()
        {
            mostrarParams()
        }

        function window_onresize() {
            try {

                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var menu_h = $('divMenuParametros').getHeight()
                var menuTipo_h = $('divMenuTipoParametros').getHeight()
                var tbParametros_h = $('solParams').getHeight()

                var calculo = body_h - menu_h - menuTipo_h - dif

                if (tbParametros_h > calculo)
                    $('divParametros').setStyle({ 'height': (body_h - menu_h - menuTipo_h - dif) + 'px' })
                else {
                    $('divParametros').setStyle({ 'height': (tbParametros_h) + 'px' })
                    //$('divPie').setStyle({ 'height': (body_h - menu_h - tbParametros_h - dif) + 'px' })
                }

            }
            catch (e) { console.log(e.message) }
        }


        function mostrarParams() {

            var paramsRs = new tRS();            
            var filtro = "<nro_sol_tipo type='igual'>'" + campos_defs.get_value('nro_sol_tipo') + "'</nro_sol_tipo>"
            
            paramsRs.open(nvFW.pageContents.filtro_sol_parametros_def, "", filtro);
            var paramsTbody = $('solParams')
            tBodyHTML = '<tr class="tbLabel0"><td style="width:39%">Parámetro</td><td style="width:60%">Etiqueta</td></tr>'

            while (!paramsRs.eof()) {
                    
                tBodyHTML += '<tr><td style="width:39%">' + paramsRs.getdata("param") + '</td><td style="width:60%">' + paramsRs.getdata("etiqueta") + '</td></tr>';

                paramsRs.movenext()
            }

            paramsTbody.innerHTML = tBodyHTML;

            window_onresize();
        }

        var winParam_def
        function param_def_abm() {

            var filtro = "<nro_sol_tipo type='igual'>'" + campos_defs.get_value('nro_sol_tipo') + "'</nro_sol_tipo>"
            var param = []

            var strCriterio = nvFW.pageContents.filtro_sol_parametros_def
            var rs = new tRS();
            rs.open(strCriterio, "", filtro)
            while (!rs.eof()) {
                parametro = {}
                parametro = new tParam_def({
                    nro_sol_tipo: rs.getdata('nro_sol_tipo'),
                    parametro: rs.getdata('param'),
                    tipo_dato: rs.getdata('tipo_dato'),
                    etiqueta: rs.getdata('etiqueta'),
                    //requerido: rs.getdata('requerido').toLowerCase() == 'true',
                    editable: rs.getdata('editable').toLowerCase() == 'true',
                    visible: rs.getdata('visible').toLowerCase() == 'true',
                    campo_def: rs.getdata('campo_def'),
                    valor_defecto: rs.getdata('valor_defecto'),
                    id_mask: rs.getdata('id_mask')
                })

                param.push(parametro);
                rs.movenext()
            }


            var options = {
                title: '<b>Parámetros Def Solicitud</b>',
                maximizable: true,
                minimizable: false,
                /*  centerHFromElement: $$("BODY")[0],
                  parentWidthElement:$$("BODY")[0],
                  parentWidthPercent: 0.9,
                  parentHeightElement: $$("BODY")[0],
                  parentHeightPercent: 0.9,*/
                height: 400,
                width: 1080,
                resizable: true,
                destroyOnClose: true,
                modal: true,
                drawButtonSave: true
            }

            winParam_def = nvFW.param_def_edit(param, function () { onSave(); }, options)

        }

        function onSave() {
            params = winParam_def.options.userData.params
            
            //validacion personalizada
            //guardar
            strXML = "<param_def>"
            params.each(function (arr, i) {
                strXML += "<param nro_sol_tipo = '" + campos_defs.get_value('nro_sol_tipo') + "' param = '" + arr.parametro + "' visible = '" + arr.visible + "' orden= '" + arr.orden + "' tipo_dato= '" + arr.tipo_dato + "' requerido= '" + arr.requerido + "' editable = '" + arr.editable + "' campo_def = '" + arr.campo_def + "' eliminar = '" + (arr.eliminar == true ? 'true' : 'false') + "'>"
                strXML += "<valor_defecto><![CDATA[" + arr.valor_defecto + "]]></valor_defecto>"
                strXML += "<etiqueta><![CDATA[" + arr.etiqueta + "]]></etiqueta></param>"
            });
            strXML += "</param_def>"

            nvFW.error_ajax_request('sol_param_listar.aspx', {
                parameters: { strXML: strXML, modo: "M" },
                onFailure: function (err) {
                    //debugger
                },
                onSuccess: function (err, transport) {

                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    mostrarParams()
                    winParam_def.close()
                },
                error_alert: true
            });

            //winParam_def.close()
            return params
        }


        var win_tipo_solicitud_abm
        function abm_sol_tipo() {

            //obtengo el codigoID
            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroTablasSimples)

            if (!rs.eof()) {
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_tipo_solicitud_abm = w.createWindow({
                    className: 'alphacube',
                    url: '/fw/funciones/abmcodigos_seleccion.aspx?codigoID=' + rs.getdata('codigoID'),
                    title: '<b>ABM Tipo Solicitud</b>',
                    minimizable: true,
                    maximizable: false,
                    draggable: true,
                    resizable: false,
                    modal: true,
                    width: 800,
                    height: 400,
                    onClose: function () { campos_defs.clear_list('nro_sol_tipo'); }
                });
                win_tipo_solicitud_abm.showCenter(true);
            }
        }


    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style='width: 100%; height: 100%; overflow: hidden;'>
    <form name="frmFiltro_tablas" method="post" target="frmEnviar" style='width: 100%; height: 100%; overflow: hidden; margin: 0;'>
        <div id="divMenuTipoParametros"></div>
        <script type="text/javascript">
            var vMenuTipoParametros = new tMenu('divMenuTipoParametros', 'vMenuTipoParametros');
            Menus["vMenuTipoParametros"] = vMenuTipoParametros;
            Menus["vMenuTipoParametros"].alineacion = 'centro';
            Menus["vMenuTipoParametros"].estilo = 'A';
            Menus["vMenuTipoParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuTipoParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_sol_tipo()</Codigo></Ejecutar></Acciones></MenuItem>")

            Menus["vMenuTipoParametros"].loadImage('hoja', '/FW/image/icons/nueva.png')
            vMenuTipoParametros.MostrarMenu()
        </script>
        <table class="tb1">
            <tr>
                <td class="Tit1" nowrap>Tipo Parametro:</td>
                <td style="width: 20%">
                    <script>
                        campos_defs.add('nro_sol_tipo', {
                            mostrar_codigo: false
                        });
                        campos_defs.items['nro_sol_tipo']['onchange'] = function () {
                            mostrarParams();
                        };
                    </script>
                </td>
                <td style="width: 100%"></td>
            </tr>
        </table>
        <div id="divMenuParametros"></div>
        <script type="text/javascript">
            var vMenuParametros = new tMenu('divMenuParametros', 'vMenuParametros');
            Menus["vMenuParametros"] = vMenuParametros;
            Menus["vMenuParametros"].alineacion = 'centro';
            Menus["vMenuParametros"].estilo = 'A';
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>param_def_abm()</Codigo></Ejecutar></Acciones></MenuItem>")

            //Menus["vMenuParametros"].loadImage('guardar', '/FW/image/icons/guardar.png')
            //Menus["vMenuParametros"].loadImage('hoja', '/FW/image/icons/nueva.png')
            vMenuParametros.MostrarMenu()
        </script>
        <div id="divParametros" style="width:100%;overflow:auto;">
            <table class="tb1 highlightOdd highlightTROver layout_fixe">   
                <tbody id="solParams"></tbody>
            </table>
        </div>
        
    </form>
</body>
</html>
