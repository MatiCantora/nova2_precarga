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


            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_comentario_control_sucursal_cargar", ADODB.CommandTypeEnum.adCmdStoredProc)



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

    Me.contents("filtroParametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_parametros_tipo'><campos>*</campos><filtro><nro_com_tipo type='igual'>" & nro_com_tipo & "</nro_com_tipo></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_Control_Sucursal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud_Control_Sucursal'><campos>ln_ant_negativos,ln_db_terrorista,case when pep_decla = 'SI' and not(ln_pep = 'SI') then pep_decla else ln_pep end as ln_pep,ln_pep_categoria,repet_db_terrorista,case when so_decla = 'SI' and not(uif_so = 'SI') then so_decla else uif_so end as uif_so,uif_so_tipos,fatca,ocde,ocde_dom,fatca_SSN,vinculado_banco</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.Contents("filtrotipo_pep") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_det'><campos>distinct dato1_desde as [id], pizarra_valor_2 as [campo]</campos><orden>[campo]</orden><filtro><nro_calc_pizarra>233</nro_calc_pizarra></filtro></select></criterio>")
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
           
            /*parent.window_onresize()*/
            // mostramos los botones creados
            vListButtons.MostrarListButton()

            $('divParametros').innerHTML = '';
            var strHTML = '<table class="tb1" id="tbParametros" style="width:100%;">';
            var strPAC = '<tr class="tbLabel"><td colspan="2"><b>CONTROL POLITICA DE ACEPTACION DE CLIENTES</b></td></tr>';
            strPAC += '<tr><td><table class="tb1" id="params" style="width: 100%;">'
            strPAC += '<tr class="tbLabel0"><td style="width: 60%">Descripción</td><td style="text-align:center">-</td></tr>';

            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroParametros);
            while (!rs.eof()) {

                strPAC += '<tr>';
                strPAC += '<td style="width:35%">' + rs.getdata('com_etiqueta') + '</td>';

                if (rs.getdata('com_parametro') == 'fatca' || rs.getdata('com_parametro') == 'ocde') {
                    strPAC += '<td style="text-align: left;" ><select name="' + rs.getdata('com_parametro') + '" id="' + rs.getdata('com_parametro') + '" onchange="return onchange_' + rs.getdata('com_parametro') +'()"><option value="NO">NO</option><option value="SI">SI</option></select>';
                }
                else if (rs.getdata('tipo_dato') == 'BOOLEAN')
                    strPAC += '<td style="text-align: left;" ><select name="' + rs.getdata('com_parametro') + '" id="' + rs.getdata('com_parametro') + '" onchange="return onchange_select(event)"><option value="NO">NO</option><option value="SI">SI</option></select>';
                else
                {
                 strPAC += '<td style="text-align: left" id="tdParam_' + rs.getdata('com_parametro') +'">';
                  if ('ln_pep_categoria' != rs.getdata('com_parametro'))
                      strPAC += '<input name="' + rs.getdata('com_parametro') + '" id="' + rs.getdata('com_parametro') + '" value="--"/>'
                }

                strPAC += '</td></tr>';

                rs.movenext();
            }
            strPAC += '</table></td></tr>';
            strHTML += strPAC;
            strHTML += '</table>';

            $('divParametros').insert({ top: strHTML });
            window_onresize()

            campos_defs.add('ln_pep_categoria', { target: "tdParam_ln_pep_categoria", filtroXML: nvFW.pageContents.filtrotipo_pep, nro_campo_tipo: 1, enDB: false })
            campos_defs.items.ln_pep_categoria.onchange = function () {
                if (campos_defs.get_value('ln_pep_categoria') == 'PEP_NO') {

                    $('ln_pep').value = "NO"
                    campos_defs.habilitar('ln_pep_categoria', false)
                  }
                else
                    $('ln_pep').value = "SI"
            }
          
            rs = new tRS();
            rs.open(nvFW.pageContents.filtro_Control_Sucursal, null, "<criterio><select><filtro><nro_sol type='igual'>" + parent.id_tipo +"</nro_sol></filtro></select></criterio>");
            if(!rs.eof()) {
                
              if ($('ln_ant_negativos'))
                $('ln_ant_negativos').value = rs.getdata('ln_ant_negativos')

              if ($('ln_db_terrorista'))
                $('ln_db_terrorista').value = rs.getdata('ln_db_terrorista')

              if ($('ln_pep'))
                $('ln_pep').value = rs.getdata('ln_pep')

              if ($('ln_pep_categoria'))
                    campos_defs.set_value('ln_pep_categoria', (rs.getdata('ln_pep_categoria') == '--' || rs.getdata('ln_pep') == 'NO' ? 'PEP_NO' : rs.getdata('ln_pep_categoria')))

              if ($('vinculado_banco'))
                $('vinculado_banco').value = rs.getdata('vinculado_banco')

              if ($('repet_db_terrorista'))
                $('repet_db_terrorista').value = rs.getdata('repet_db_terrorista')

              if ($('uif_so'))
                $('uif_so').value = rs.getdata('uif_so')

              if ($('uif_so_tipos'))
                $('uif_so_tipos').value = rs.getdata('uif_so_tipos')

              if ($('fatca'))
                $('fatca').value = rs.getdata('fatca')

              if ($('ocde'))
                $('ocde').value = rs.getdata('ocde')

              if ($('ocde_dom'))
                $('ocde_dom').value = rs.getdata('ocde_dom')

              if ($('fatca_SSN'))
                $('fatca_SSN').value = rs.getdata('fatca_SSN')

              if ($('fatca'))
                {
                    if ($('fatca').value == 'NO' || $('fatca').value == '') {
                        $('fatca_SSN').disabled = true
                    }
                    else if ($('fatca').value == 'SI') {
                        $('fatca_SSN').disabled = false
                    }
                }

              if ($('ocde'))
                {
                    if ($('ocde').value == 'NO' || $('ocde').value == '') {
                        $('ocde_dom').disabled = true
                    }
                    else if ($('ocde').value == 'SI') {
                        $('ocde_dom').disabled = false
                    }
                }
            }
        }

        function onchange_fatca() {
            if ($('fatca').value == 'NO') {
                $('fatca_SSN').value = "--"
                $('fatca_SSN').disabled = true
            }
            else if ($('fatca').value == 'SI') {
                $('fatca_SSN').disabled = false
            }

        }

        function onchange_ocde() {
            if ($('ocde').value == 'NO') {
                $('ocde_dom').value = "--"
                $('ocde_dom').disabled = true
            }
            else if ($('ocde').value == 'SI') {
                $('ocde_dom').disabled = false
            }

        }

        function onchange_select(e) {
            
            var obj = Event.element(e)

            if ($('ln_pep').value == 'SI' && campos_defs.get_value('ln_pep_categoria') == 'PEP_NO') {
                campos_defs.habilitar('ln_pep_categoria', true)
                campos_defs.clear('ln_pep_categoria')
            }

            if (obj.id == "ln_pep")
              if (obj.value == "NO") {
                campos_defs.set_value('ln_pep_categoria', 'PEP_NO')
                campos_defs.habilitar('ln_pep_categoria', false)
               }
              else
                campos_defs.habilitar('ln_pep_categoria', true)


        }

        function btnGuardarComentario_onclick() {


            if ($('ln_db_terrorista').value == '') {
                parent.alert("Seleccione si es o no encontrado en lista de terrorista")
                return
            }

            if ($('ln_ant_negativos').value == '') {
                parent.alert("Seleccione si tiene o no antecedentes negativos")
                return
            }

            if ($('uif_so').value == '') {
                parent.alert("Seleccione si es o no sujeto obligado")
                return
            }

            if ($('ln_pep').value == '') {
                parent.alert("Seleccione si es o no PEP")
                return
            }

           if ($('ln_pep').value.toLowerCase() == 'si' && campos_defs.get_value('ln_pep_categoria') == '')
            {
                parent.alert("Seleccione la categoría PEP")
                return
            }

            if ($('fatca'))
              if ($('fatca').value.toLowerCase() == 'si' && ($('fatca_SSN').value == '--' || $('fatca_SSN').value == ''))
                {
                    parent.alert("Ingrese número de seguridad social")
                    return
                }

            if ($('ocde'))
                if ($('ocde').value.toLowerCase() == 'si' && ($('ocde_dom').value == '--' || $('ocde_dom').value == '')) {
                    parent.alert("Ingrese el domicilio de residencia")
                    return
                }

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

            nvFW.error_ajax_request('cargar_com_control_sucursal.aspx', {
                parameters: { modo: 'M', nro_registro: nro_registro, id_tipo: parent.id_tipo, nro_com_id_tipo: parent.nro_com_id_tipo, comentario_value: comentario_value, nro_com_tipo: parent.campos_defs.value('nro_com_tipo'), strXML: strParam, nro_entidad: nro_entidad },
                onSuccess: function (err, transport) {
                    var nro_registro = err.params['nro_registro']
                    res = true
                    //var win = parent.nvFW.getMyWindow()
                    //win.options.userData = { res: res }
                    //win.close()
                    
                    window.top.Windows.getFocusedWindow().returnValue = err.params['nro_entidad']
                    nvFW.ObtenerVentana('frame_comentario').parent.document.location.reload(true)
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

        function window_onresize() {

            try {
                var resta = $$('body')[0].getHeight() - $('coment').getHeight() - $('boton').getHeight() + 'px'
                $('divParametros').setStyle({ 'height': resta })
            }
            catch (e) { }

        }

    </script>

</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="width: 100%; height: 100%; overflow: hidden">
    <div id="divParametros" style="width: 100%; overflow: auto"></div>
    <table class="tb1" id="coment" cellspacing="0" cellpadding="0" style="width: 100%">
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
                <textarea name="comentario" id="comentario" style="width: 100%; resize: none" onkeyup="return maximaLongitud(this,8000)" rows="3" placeholder="Ingrese aquí su comentario"></textarea></td>
        </tr>
        <tr>
            <td colspan="3" style="width: 100%"></td>
        </tr>
    </table>
  
        <table class="tb1" id="boton">
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
<!--    <div id="div_HTML" style="display: none"></div>

    <iframe name="iframe1" height="1" width="1" frameborder="0" src="/fw/enBlanco.htm"></iframe>
    <iframe name="iframe2" height="1" width="1" frameborder="0" src="/fw/enBlanco.htm"></iframe>

    <iframe name="iframe_oculto_coment" height="1" width="1" frameborder="0" src="/fw/enBlanco.htm"></iframe> -->
</body>
</html>
