<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_stock_tarjetas", 1)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        
        Dim Err As New nvFW.tError()
        Dim strSQL As String = ""
        Dim vigente As Boolean = nvFW.nvUtiles.obtenerValor("vigente", False)
        Dim cod_tran As String = nvFW.nvUtiles.obtenerValor("cod_tran", "")
        Dim tran_desc As String = nvFW.nvUtiles.obtenerValor("tran_desc", "")

        Try

            If modo = "A" Then
                strSQL = "IF (SELECT COUNT(*) FROM LINK_SOAT_cod_trans WHERE cod_tran=" & cod_tran & ") = 0 BEGIN "
                strSQL &= "INSERT INTO LINK_SOAT_cod_trans (cod_tran, tran_desc, habilitado) VALUES ('" & cod_tran & "', '" & tran_desc & "', " & IIf(vigente, 1, 0) & ") "
                strSQL &= "SELECT 0 AS numError, '' AS mensaje, '' AS debug_desc "
                strSQL &= "END ELSE BEGIN "
                strSQL &= "SELECT -1 AS numError, 'Ya existe un registro con el codigo de transacción " & cod_tran & "' AS mensaje, 'Error de primary key' AS debug_desc "
                strSQL &= "END"

                Dim rs As ADODB.Recordset = DBExecute(strSQL)
                If Not rs.EOF Then
                    Err.numError = rs.Fields("numError").Value
                    Err.mensaje = rs.Fields("mensaje").Value
                    Err.debug_desc = rs.Fields("debug_desc").Value
                End If
            ElseIf modo = "M" Then
                strSQL = "UPDATE LINK_SOAT_cod_trans SET tran_desc = '" & tran_desc & "', habilitado = " & IIf(vigente, 1, 0) & " WHERE cod_tran = '" & cod_tran & "'"
                'ElseIf modo = "B" Then
                '    strSQL = "DELETE FROM LINK_SOAT_cod_trans WHERE cod_tran = '" & cod_tran & "'"
                DBExecute(strSQL)
            End If


        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error"
            Err.mensaje = "No se pudo relizar la acción."
            Err.debug_desc = Err.mensaje
            Err.debug_src = "cod_trans_abm.aspx"
        End Try
        Err.response()
    End If

    Me.contents("filtroCod_trans") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='LINK_SOAT_cod_trans'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM CODIGO TRANSACCION</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />


    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscarCod_tran()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

        function window_onload() {

            vListButton.MostrarListButton()

            window_onresize();

        }

        function window_onresize() {

            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var contenedor_cab_h = $('tbcontenedor_cab').getHeight()
                var FiltroDatos_h = $('divFiltroDatos').getHeight()
                $('contenedor').setStyle({ height: body_h - FiltroDatos_h - contenedor_cab_h - dif });

                if ((cantdatos) * 18 > $('contenedor').getHeight()) {
                    $('contenedor').setStyle({ overflowY: 'scroll' });
                } else $('contenedor').setStyle({ overflowY: 'auto' });

                campos_head.resize('tbcontenedor_cab', 'tbcontenedor_detalle');

            }
            catch (e) { }

            //$('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('divFiltroDatos').getHeight() })
        }


        var cantdatos;
        function buscarCod_tran() {
            $('contenedor').update('');
            nvFW.bloqueo_activar($(document.body), 'Buscando...')
            var rsCod_trans = new tRS();

            var filtro = campos_defs.filtroWhere();

            rsCod_trans.open({ filtroXML: nvFW.pageContents.filtroCod_trans, filtroWhere: filtro });

            var strHTML = '';

            cantdatos = 0;
            var strHTML = '<table class="tb1 highlightOdd highlightTROver" id="tbcontenedor_detalle">'
            while (!rsCod_trans.eof()) {

                var estado = 'Deshabilitado';
                var vigente = false;
                if (rsCod_trans.getdata('habilitado') == 'True') {
                    estado = 'Habilitado';
                    vigente = true;
                }

                strHTML += '<tr><td style="text-align: right;">' + rsCod_trans.getdata('cod_tran') + '</td><td>' + rsCod_trans.getdata('tran_desc') + '</td><td>' + estado + '</td>'
                strHTML += '<td style="text-align: center;"><img src="/fw/image/icons/editar.png"  onclick="abm_cod_tran(\'M\', \'' + rsCod_trans.getdata("cod_tran") + '\',\'' + rsCod_trans.getdata("tran_desc") + '\',' + vigente + ')"   style="cursor:pointer" /></td>';
                //strHTML += '<td style="text-align: center;"><img src="/fw/image/icons/eliminar.png"  onclick="abm_cod_tran(\'B\', \'' + rsCod_trans.getdata("cod_tran") + '\',\'' + rsCod_trans.getdata("tran_desc") + '\')"   style="cursor:pointer" /> </td></tr>'
                cantdatos += 1;
                rsCod_trans.movenext();
            }
            strHTML += '</table>'
            nvFW.bloqueo_desactivar($(document.body), 'Buscando...')
            $('contenedor').update(strHTML);

            if (cantdatos != 0) {
                $('tbcontenedor_cab').show()
                window_onresize();
            }

        }


        function abm_cod_tran(modo, codigoID, descripcion, vigente) {

            if (modo != 'B') {
                var strhtml = '';
                
                strhtml += '<table class="tb1" style="width: 100%"><tr class="tbLabel"><td style="text-align: center; width: 10%;">ID</td><td style="text-align: center; width: 75%;" nowrap>Descripción</td><td style="text-align: center;  width: 10%;">Vigente</tr>'
                strhtml += '<tr><td style="width: 30%"><input type="number" name="cod_tran" id="cod_tran" value="" style="width: 100%" /></td><td style="width: 75%"><input style="width: 100%" type="text" id="tran_desc" name="tran_desc"/></td><td style="width: 15%; text-align:center;"><input type="checkbox" id="vigente" value="vigente"/></td></tr></table>'

                Dialog.confirm(strhtml, {
                    width: 700,
                    height: 100,
                    className: "alphacube",
                    draggable: true,
                    closable: true,
                    okLabel: "Guardar",
                    onShow: function (win) {
                        if (modo == 'M') {
                            $('cod_tran').value = codigoID;
                            $('cod_tran').disabled = true;
                            $('tran_desc').value = descripcion;
                            $('vigente').checked = vigente;
                        } else if (modo == 'A') $('vigente').checked = true;

                    },
                    cancelLabel: "Cancelar",
                    cancel: function (win) { win.close(); return },
                    ok: function (win) {

                        var strError = '';

                        if ($('cod_tran').value == '')
                            strError += "<b>ID</b><br>"

                        if ($('tran_desc').value == '')
                            strError += "<b>Descripción</b><br>"

                        if (strError != '') {
                            nvFW.alert("Debe Ingresar<br>" + strError)
                            return
                        }

                        nvFW.error_ajax_request('cod_trans_abm.aspx', {
                            parameters: { modo: modo, cod_tran: $('cod_tran').value.toUpperCase(), tran_desc: $('tran_desc').value, vigente: $('vigente').checked },
                            onSuccess: function (err, transport) {

                                if (err.numError != 0) {
                                    alert(err.mensaje)
                                    return
                                }

                                win.close();

                                buscarCod_tran();

                            },
                            error_alert: true
                        })

                    }
                });
            } //else {
            //    Dialog.confirm('¿Desea eliminar el codigo de transacción <b>' + descripcion + '</b>?',{
            //        width: 400,
            //        height: 100,
            //        className: "alphacube",
            //        draggable: true,
            //        closable: true,
            //        okLabel: "Aceptar",                    
            //        cancelLabel: "Cancelar",
            //        cancel: function (win) { win.close(); return },
            //        ok: function (win) {

            //            nvFW.error_ajax_request('cod_trans_abm.aspx', {
            //                parameters: { modo: modo, cod_tran: codigoID },
            //                onSuccess: function (err, transport) {

            //                    if (err.numError != 0) {
            //                        alert('Error, puede que el codigo transacción este asociado')
            //                        return
            //                    }

            //                    win.close();

            //                    buscarCod_tran();

            //                },
            //                error_alert: true
            //            })

            //        }
            //    });
            //}
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divFiltroDatos">
        <div id="divMenuABMSimples">
        </div>

        <script type="text/javascript" language="javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuABMSimples = new tMenu('divMenuABMSimples', 'vMenuABMSimples');
            Menus["vMenuABMSimples"] = vMenuABMSimples
            Menus["vMenuABMSimples"].alineacion = 'centro';
            Menus["vMenuABMSimples"].estilo = 'A';
            vMenuABMSimples.loadImage("hoja", "/FW/image/icons/nueva.png");

            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 95%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuABMSimples"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_cod_tran('A')</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuABMSimples.MostrarMenu()
        </script>

        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align: center; width: 20%">ID</td>
                <td style="text-align: center; width: 80%">Descripción</td>               
            </tr>
            <tr>
                <td>
                    <script>
                        campos_defs.add('ID', {
                            enDB: false,
                            nro_campo_tipo: 101,
                            filtroWhere: '<cod_tran type="in">%campo_value%</cod_tran>'
                        });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('ct_desc', {
                            enDB: false,
                            nro_campo_tipo: 104,
                            filtroWhere: '<tran_desc type="like">%%campo_value%%</tran_desc>'
                        });
                    </script>
                </td>
                 <td>
                    <div id="divBuscar" />
                </td>
            </tr>
        </table>
    </div>
    <table class="tb1" id="tbcontenedor_cab" style="display: none">
        <tr class="tbLabel">
            <td style="width: 7%; text-align: center">ID</td>
            <td style="width: 60%; text-align: center">Descripción</td>
            <td style="width: 19%; text-align: center">Estado</td>
            <td style="width: 14%; text-align: center">-</td>
            <%--<td style="width: 7%; text-align: center">-</td>--%>
        </tr>
    </table>
    <div id="contenedor" style="width: 100%; overflow-y: auto">
    </div>
    <%--<iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>--%>
</body>
</html>
