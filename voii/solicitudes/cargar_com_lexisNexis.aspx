<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    'Response.Expires = 0

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim nro_entidad As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad", 0)
    Dim nro_registro As Integer = nvFW.nvUtiles.obtenerValor("nro_registro", 0)


    Dim id_tipo As Integer = nvFW.nvUtiles.obtenerValor("id_tipo", 0)
    Dim nro_com_id_tipo As Integer = nvFW.nvUtiles.obtenerValor("nro_com_id_tipo", 0)
    Dim comentario_value As String = nvFW.nvUtiles.obtenerValor("comentario_value", "")
    'Dim operador As Integer = nvFW.nvUtiles.obtenerValor("operador", 0)
    Dim operador As Integer = nvFW.nvApp.getInstance.operador.operador
    Dim nro_com_tipo As Integer = nvFW.nvUtiles.obtenerValor("nro_com_tipo", 0)
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")


    If modo = "M" Then
        Dim Err As nvFW.tError = New nvFW.tError()

        Try


            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_comentario_lexis_nexis_cargar", ADODB.CommandTypeEnum.adCmdStoredProc)



            cmd.addParameter("@nro_registro", ADODB.DataTypeEnum.adInteger, , , nro_registro)
            cmd.addParameter("@id_tipo", ADODB.DataTypeEnum.adInteger, , , id_tipo)
            cmd.addParameter("@nro_com_id_tipo", , , , nro_com_id_tipo)
            cmd.addParameter("@comentario_value", ADODB.DataTypeEnum.adLongVarChar, , , comentario_value)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, , , strXML)
            cmd.addParameter("@operador", ADODB.DataTypeEnum.adInteger, , , operador)
            cmd.addParameter("@nro_entidad", ADODB.DataTypeEnum.adInteger, , , nro_entidad)
            cmd.addParameter("@nro_com_tipo", ADODB.DataTypeEnum.adInteger, , , nro_com_tipo)

            Dim rs As ADODB.Recordset = cmd.Execute()

            Err.numError = rs.Fields("numError").Value


            If rs.Fields("numError").Value > 0 Then
                id_tipo = rs.Fields("id_tipo").Value
                Err.params.Add("id_tipo", id_tipo)

                Err.titulo = "ERROR"
                Err.mensaje = rs.Fields("mensaje").Value

            Else
                id_tipo = rs.Fields("nro_registro").Value

                Err.params.Add("id_tipo", id_tipo)
                Err.params.Add("nro_entidad", operador)

                Err.titulo = ""
                Err.mensaje = ""

            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

        Catch e As Exception

            Err.parse_error_script(e)
            Err.titulo = "Error al procesar el comando"
            Err.mensaje = "No se pudo realizar la acción solicitada"

        End Try

        Err.response()

    End If

    Me.contents("filtroParametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_parametros_tipo'><campos>*</campos><filtro><nro_com_tipo type='igual'>3</nro_com_tipo></filtro><orden></orden></select></criterio>")
%>
<html>
<head>
    <title>Cargar Comentario Lexis Nexis</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% =Me.getHeadInit() %>

    <script type="text/javascript" language="javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }


        //Botones
        var vButtonItems = new Array();

        vButtonItems[0] = new Array()
        vButtonItems[0]["nombre"] = "Boton_guardar_comentario"
        vButtonItems[0]["etiqueta"] = "Guardar"
        vButtonItems[0]["imagen"] = "guardar"
        vButtonItems[0]["onclick"] = "return btnGuardarComentario_onclick()"

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage('guardar', '/fw/image/icons/guardar.png');

        var nro_registro = '<%= nro_registro%>'

        function window_onload() {

            // mostramos los botones creados
            vListButtons.MostrarListButton()

            $('divParametros').innerHTML = '';
            var strHTML = '<table class="tb1" id="tbParametros" style="width:100%;">';
            var strPAC = '<tr class="tbLabel"><td colspan="2"><b>CONTROL POLITICA DE ACEPTACION DE CLIENTES</b></td></tr>';
            strPAC += '<tr><td><table class="tb1" style="width: 60%">'
            strPAC += '<tr class="tbLabel0"><td style="width: 90%">Descripcion</td><td style="text-align:center; width: 5%">SI/NO</td></tr>';

            //var strPEP = '<tr class="tbLabel"><td colspan="2"><b>CONTROL PERSONAS EXPUESTAS POLITICAMENTE</b></td></tr>';
            //strPEP += '<tr><td><table class="tb1" style="width: 60%">'
            //strPEP += '<tr class="tbLabel0"><td style="width: 90%">Descripcion</td><td style="text-align:center; width: 5%">SI/NO</td></tr>';

            //var strSO = '<tr class="tbLabel"><td colspan="2"><b>CONTROL SUJETO OBLIGADO</b></td></tr>';
            //strSO += '<tr><td><table class="tb1" style="width: 60%">'
            //strSO += '<tr class="tbLabel0"><td style="width: 90%">Descripcion</td><td style="text-align:center; width: 5%">SI/NO</td></tr>';

            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroParametros);
            //var cant = 0;
            while (!rs.eof()) {

                //if (rs.getdata('com_parametro') == "PAC") {
                //if (cant < 2) {
                    strPAC += '<tr>';
                    strPAC += '<td nowrap>' + rs.getdata('com_etiqueta') + '</td>';

                strPAC += '<td style="text-align: left"><select name="' + rs.getdata('com_parametro') + '" id="' + rs.getdata('com_parametro') + '"><option value="NO">NO</option><option value="SI">SI</option></select>';

                    strPAC += '</tr>';

                //}

                //if (rs.getdata('com_parametro') == "PEP") {
                //if (cant == 2) {
                //strPEP += '<tr>';
                //strPEP += '<td nowrap>' + rs.getdata('com_etiqueta') + '</td>';

                //strPEP += '<td style="text-align: left"><select name="' + rs.getdata('com_parametro') + '" id="' + rs.getdata('com_parametro') + '"><option value="SI">SI</option><option value="NO">NO</option></select>';

                //strPEP += '</tr>';

                //}

                //if (cant == 3) {
                //strSO += '<tr>';
                //strSO += '<td nowrap>' + rs.getdata('com_etiqueta') + '</td>';

                //strSO += '<td style="text-align: left"><select name="' + rs.getdata('com_parametro') + '" id="' + rs.getdata('com_parametro') + '"><option value="SI">SI</option><option value="NO">NO</option></select>';

                //strSO += '</tr>';

                //}

                //cant++;

                rs.movenext();
            }
            strPAC += '</table></td></tr>';
            //strPEP += '</table></td></tr>';
            //strSO += '</table></td></tr>';
            strHTML += strPAC;
            //strHTML += strPEP;
            //strHTML += strSO;
            strHTML += '</table>';

            $('divParametros').insert({ top: strHTML });
        }


        function btnGuardarComentario_onclick() {


            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroParametros);
            var strParam = '<parametros>';

            while (!rs.eof()) {

                strParam += "<" + rs.getdata('com_parametro');
                strParam += " nro_com_parametro='" + rs.getdata('nro_com_parametro') + "' com_parametro_valor='" + $(rs.getdata('com_parametro')).value;
                strParam += "'></" + rs.getdata('com_parametro') + ">"

                rs.movenext();
            }

            var comentario_value = '';
            if ($('comentario').value != '(Ingrese aquí su comentario)')
                comentario_value = $('comentario').value;

            var nro_entidad = 0;
            if (parent.nro_entidad != '' && parent.nro_entidad != undefined)
                nro_entidad = parent.nro_entidad;


            strParam += '</parametros>';

            nvFW.error_ajax_request('cargar_com_lexisNexis.aspx', {
                parameters: { modo: 'M', nro_registro: nro_registro, id_tipo: parent.id_tipo, nro_com_id_tipo: parent.nro_com_id_tipo, comentario_value: comentario_value, nro_com_tipo: parent.campos_defs.value('nro_com_tipo'), strXML: strParam, nro_entidad: nro_entidad },
                onSuccess: function (err, transport) {
                    var nro_registro = err.params['nro_registro']
                    res = true
                    //var win = parent.nvFW.getMyWindow()
                    //win.options.userData = { res: res }
                    //win.close()

                    window.top.Windows.getFocusedWindow().returnValue = err.params['nro_entidad']
                    parent.Cerrar_Ventanas()
                },
                onFailure: function (err, b) {
                    id_tipo = err.params['id_tipo']
                    //alert('No se pudo confirmar el comprobante.Verifique.')
                    return
                }

            });


        }


        function maximaLongitud(texto, maxlong) {

            var tecla, int_value, out_value;

            if (texto.value.length > maxlong) {
                /*con estas 3 sentencias se consigue que el texto se reduzca
                al tamaño maximo permitido, sustituyendo lo que se haya
                introducido, por los primeros caracteres hasta dicho limite*/
                in_value = texto.value;
                out_value = in_value.substring(0, maxlong);
                texto.value = out_value;
                alert("La longitud máxima es de " + maxlong + " caractéres");
                return false;
            }
            return true;

        }

    </script>

</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto">
    <div id="divParametros" style="width: 100%; overflow: auto;"></div>
    <table class="tb1" cellspacing="0" cellpadding="0" style="width: 100%">
        <%--<tr>--%>
        <%--<td style="width: 5%">&nbsp;</td>
            <td style="width: 90%">
                <form name="frm_comentario" action=''>
                    <table style="width: 100%">
        --%>

        <tr class="tbLabel">
            <td style="width: 100%">Comentario:</td>
            <%--<td colspan="2" style="width: 100%"><b>*&nbsp;<u>Comentario:</u></b></td>--%>
        </tr>
        <tr>
            <td style="width: 100%">
                <textarea name="comentario" id="comentario" style="width: 100%; resize: none" onkeyup="return maximaLongitud(this,8000)" rows="6" onfocus="if(this.value == '(Ingrese aquí su comentario)') this.value=''">(Ingrese aquí su comentario)</textarea></td>
        </tr>
        <tr>
            <td colspan="3" style="width: 100%"></td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td colspan="3">&nbsp;</td>
        </tr>
        <tr>
            <td style="width: 30%">&nbsp;</td>
            <td>
                <div id="divBoton_guardar_comentario"></div>
            </td>
            <td style="width: 30%">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="3">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="3">&nbsp;</td>
        </tr>
    </table>
    <%-- </form>
            </td>
            <td style="width: 5%">&nbsp;</td>
    </tr>
    </table>--%>

    <!-- 'div' oculto -->
    <div id="div_HTML" style="display: none"></div>

    <iframe name="iframe1" height="1" width="1" frameborder="0" src="/fw/enBlanco.htm"></iframe>
    <iframe name="iframe2" height="1" width="1" frameborder="0" src="/fw/enBlanco.htm"></iframe>

    <iframe name="iframe_oculto_coment" height="1" width="1" frameborder="0" src="/fw/enBlanco.htm"></iframe>
</body>
</html>
