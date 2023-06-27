<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "A" Then

        Dim err As New nvFW.tError
        Try
            Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")
            Dim nro_plan_sel As Integer = nvFW.nvUtiles.obtenerValor("nro_plan_sel", "0")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_cr_cambiar_plan", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
            cmd.addParameter("@nro_plan", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_plan_sel)
            Dim rs As ADODB.Recordset = cmd.Execute()

            err.numError = 0
            err.titulo = ""
            err.mensaje = ""
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If

    Me.contents.Add("creditos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>nro_docu,tipo_docu,sexo,nro_banco,nro_mutual,nro_sistema,nro_lote,convert(varchar,fe_naci,103) as fe_naci,dbo.an_cuota_maxima_credito(nro_credito) as cuota_maxima,nro_plan,saldo_cancelado,cod_prov,nro_banco_cta,dbo.rm_an_valor_etiqueta(nro_credito,93) as sit_bcra,nro_tipo_cobro</campos><orden></orden><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))
    Me.contents.Add("planes_lotes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes_v4' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos><![CDATA[distinct datediff(year, convert(datetime,'%fe_naci%',103), dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) as edad_fin, nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,nro_tipo_cobro,gastoscomerc,mes_vencimiento]]></campos><orden>nro_plan</orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("planes_grupos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='planes'><campos>nro_grupo</campos><filtro><nro_plan type='igual'>%nro_plan%</nro_plan></filtro><orden></orden></select></criterio>"))

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Me.contents("permisos_precarga") = op.permisos("permisos_precarga")
    Me.addPermisoGrupo("permisos_precarga")
    Me.contents("operador") = nvApp.operador.operador
    Dim filtro_cuenta As Boolean
    Dim filtro_bcra As Boolean
    filtro_cuenta = op.tienePermiso("permisos_precarga", 64)
    filtro_bcra = op.tienePermiso("permisos_precarga", 128)
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>Precarga - Seleccionar Plan</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>

    <% = Me.getHeadInit()%>
    <script type="text/javascript" language="javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    
    var win = nvFW.getMyWindow()
    var nro_credito = 0
    var nro_banco = 0
    var nro_mutual = 0
    var nro_sistema = 0
    var nro_lote = 0
    var cuota_maxima = 0
    var fe_naci = ''
    var TotalCancelaciones = 0
    var nro_plan = 0
    var sexo = ''
    var nro_banco_debito = 0
    var cod_prov = 0
    var nro_plan = 0
    var nro_grupo = 0
    var sit_bcra = 0
    var nro_tipo_cobro = 0

    var vButtonItems = {}
    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "PlanBuscar";
    vButtonItems[0]["etiqueta"] = "";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return btnBuscarPLanes_onclick()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons');
    vListButtons.loadImage("buscar", "/precarga/image/search_16.png");

    var permisos_precarga = nvFW.pageContents["permisos_precarga"]

    var filtro_cuenta = nvFW.tienePermiso("permisos_precarga", 6)
    var filtro_bcra = tienePermiso("permisos_precarga", 7)

    function window_onload() {
        window_onresize() 
        vListButtons.MostrarListButton()
              
        nro_credito = win.options.userData.param['nro_credito']
        var rs = new tRS();
        rs.async = true
        rs.onComplete = function (rs)
            {
            if (!rs.eof()) {
                nro_mutual = rs.getdata('nro_mutual')
                nro_banco = rs.getdata('nro_banco')            
                nro_sistema = rs.getdata('nro_sistema')
                nro_lote = rs.getdata('nro_lote')
                fe_naci = rs.getdata('fe_naci')
                importe_max_cuota = (rs.getdata('cuota_maxima') <= 0) ? 99999 : rs.getdata('cuota_maxima')
                TotalCancelaciones = rs.getdata('saldo_cancelado')
                nro_plan = rs.getdata('nro_plan')
                sexo = rs.getdata('sexo')
                cod_prov = rs.getdata('cod_prov')
                sit_bcra = rs.getdata('sit_bcra')
                nro_tipo_cobro = rs.getdata('nro_tipo_cobro')
                if (rs.getdata('nro_banco_cta'))
                    nro_banco_debito = rs.getdata('nro_banco_cta')
                }
            if ((nro_sistema == 0) && (nro_lote == 0)) {
            var rsp = new tRS();
            rsp.open({ filtroXML: nvFW.pageContents["planes_grupos"], params: "<criterio><params nro_plan='" + nro_plan + "' /></criterio>" })
            if (!rsp.eof())
                nro_grupo = rsp.getdata('nro_grupo')
            }

            $('strcuota_maxima').insert({ bottom: (importe_max_cuota == 99999) ? 'No disponible' : '$ ' + parseFloat(importe_max_cuota).toFixed(2) })
            campos_defs.set_value('nro_tipo_cobro_precarga',nro_tipo_cobro)
            }
        rs.open({ filtroXML: nvFW.pageContents["creditos"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
        
        if ((permisos_precarga & 64) == 0)
            $('chkFiltroCuenta').style.visibility = 'hidden';

        if ((permisos_precarga & 128) == 0)
            $('chkFiltroBCRA').style.visibility = 'hidden';
        
        if (filtro_cuenta)
            $('chkFiltroCuenta').innerText = 'Banco Cobro'
        if (filtro_bcra)
            $('chkFiltroBCRA').innerText = 'sit. BCRA'
    }    

    function window_onresize() {
        try {
              var body_height = $$('body')[0].getHeight()
              var filtro_height = $('divFiltros_selplan').getHeight()      
              var buttons_height = $('tbButtons').getHeight() 
              $('ifrplanes').setStyle({ 'height': body_height - filtro_height - buttons_height })
          }
          catch (e) { }
    }

    function btnBuscarPLanes_onclick(nro_plan) {
        if ((!$('chkmax_disp').checked) && (($('retirado_desde').value == '') && ($('retirado_hasta').value == '') && ($('importe_cuota_desde').value == '') && ($('importe_cuota_hasta').value == '') && ($('cuota_desde').value == '') && ($('cuota_hasta').value == '')))
            {
            nvFW.alert('Ingrese algún filtro para realizar la búsqueda.')
            return
            }


        var strWhere = ''
        strWhere += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
        strWhere += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"

        if (((nro_sistema == 0) && (nro_lote == 0)) && (nro_grupo != 0))
            strWhere += "<nro_grupo type='igual'>" + nro_grupo + "</nro_grupo>"
        else {
            strWhere += "<nro_sistema type='igual'>" + nro_sistema + "</nro_sistema>"
            strWhere += "<nro_lote type='igual'>" + nro_lote + "</nro_lote>"
        }
        strWhere += "<marca type='igual'>'S'</marca>"
        strWhere += "<falta type='menos'>getdate()</falta>"
        strWhere += "<fbaja type='sql'>(fbaja > getdate() or fbaja is null)</fbaja>"
        strWhere += "<vigente type='igual'>1</vigente>"
        strWhere += "<nro_tabla_tipo type='igual'>1</nro_tabla_tipo>"

        if (nro_plan)
            strWhere += "<nro_plan type='igual'>" + nro_plan + "</nro_plan>"
        
        
        if (!$('chkFiltroCuenta').checked) {
            if (nro_banco_debito != undefined)
                strWhere += "<sql type='sql'><![CDATA[((nro_tipo_cobro = 4 and nro_banco_debito = " + nro_banco_debito + ") or (nro_tipo_cobro <> 4))]]></sql>"
        }
        if (!$('chkFiltroBCRA').checked) {
            if (sit_bcra != undefined)
                strWhere += "<sql type='sql'><![CDATA[((sitbcra_max is null) or (" + sit_bcra + " between sitbcra_min and sitbcra_max))]]></sql>"
            }

        if (cod_prov != undefined)
            strWhere += "<sql type='sql'><![CDATA[((nro_tipo_cobro in (1,4) and (cod_prov = " + cod_prov + " or cod_prov is null)) or (nro_tipo_cobro not in (1,4)) )]]></sql>"

        var campo_max
        var campo_min
        if (sexo == 'M') {
            campo_max = 'edad_max_masc'
            campo_min = 'edad_min_masc'
        }
        else {
            campo_max = 'edad_max_fem'
            campo_min = 'edad_min_fem'
        }

        strWhere += "<sql type='sql'><![CDATA[datediff(year," + ajustarFecha(fe_naci) + ", getdate()) >= " + campo_min + "]]></sql>"

        strWhere += "<sql type='sql'><![CDATA[datediff(year, " + ajustarFecha(fe_naci) + ", dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) <= " + campo_max + "]]></sql>"

        var maxImporte = TotalCancelaciones

        if ($('chkmax_disp').checked) {
            var strIn = '(Select max(importe_cuota) from planes where planes.nroTabla = verPlanes_lotes_v4.nroTabla and planes.importe_cuota <= ' + importe_max_cuota + ')'
            strWhere += "<importe_cuota type='igual'><![CDATA[" + strIn + "]]></importe_cuota>"
            strWhere += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
            }
        else {
            strWhere += "<importe_cuota type='menos'>" + importe_max_cuota + "</importe_cuota>"
            if ($('retirado_desde').value != "")
                if (parseFloat($('retirado_desde').value) > parseFloat(TotalCancelaciones))
                    maxImporte = $('retirado_desde').value
            strWhere += "<importe_neto type='mas'>" + maxImporte + "</importe_neto>"
            if ($('retirado_hasta').value != '')
                strWhere += "<importe_neto type='menos'>" + $('retirado_hasta').value + "</importe_neto>"
            if ($('importe_cuota_desde').value != '')
                strWhere += "<importe_cuota type='mas'>" + $('importe_cuota_desde').value + "</importe_cuota>"
            if ($('importe_cuota_hasta').value != '')
                strWhere += "<importe_cuota type='menos'>" + $('importe_cuota_hasta').value + "</importe_cuota>"
            if ($('cuota_desde').value != '')
                strWhere += "<cuotas type='mas'>" + $('cuota_desde').value + "</cuotas>"
            if ($('cuota_hasta').value != '')
                strWhere += "<cuotas type='menos'>" + $('cuota_hasta').value + "</cuotas>"
        }

        var nro_tipo_cobro = campos_defs.get_value('nro_tipo_cobro_precarga')
        if (nro_tipo_cobro != "")
            strWhere += "<nro_tipo_cobro type='in'>" + nro_tipo_cobro + "</nro_tipo_cobro>"

            //var heightWin = $$('body')[0].getHeight()
            //var widthWin = $('contenedor').getWidth() - 50
            //var BodyWidth = $$('body')[0].getWidth()
        var operador = nvFW.pageContents["operador"]
        strWhere += "<nroTabla type='sql'>dbo.rm_tabla_permiso_estructura (" + operador + ",nroTabla) = 1</nroTabla>"
            WinTipo = 'C'

            var filtroXML = nvFW.pageContents.planes_lotes
            nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: "<criterio><select><filtro>" + strWhere + "</filtro></select></criterio>",
                params: "<criterio><params fe_naci='" + fe_naci + "' /></criterio>",
                path_xsl: 'report/verPlanes_lotes/lst_planes_precarga_HTML.xsl',
                formTarget: 'ifrplanes',
                async: true,
                bloq_contenedor: $(document.documentElement),
                bloq_msg: 'Buscando planes...',
                nvFW_mantener_origen: true
            })
        }


    var nro_plan_sel = 0
    function Guardar(){
        nro_plan_sel = 0
        var iframe = $('ifrplanes');
        var radioGrp = iframe.contentDocument.forms.frmplanes.rdplan
        if (radioGrp.length == undefined)
            if (iframe.contentDocument.forms.frmplanes.rdplan.checked)
                nro_plan_sel = iframe.contentDocument.forms.frmplanes.rdplan.value
        for (i = 0; i < radioGrp.length; i++) {
            if (radioGrp[i].checked == true)
                nro_plan_sel = radioGrp[i].value
        }
        if (nro_plan_sel != 0)
            {
            nvFW.error_ajax_request('precarga_plan_seleccionar.aspx', {
                parameters: { modo: "A", nro_credito: nro_credito, nro_plan_sel : nro_plan_sel },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        var retorno = {}
                        retorno["actualizar"] = true
                        var win = nvFW.getMyWindow()
                        win.options.userData = { res: retorno }
                        win.close()
                    }
                }
            });
            }
        else
            alert('Seleccione un plan para Guardar.')
    }

</script>
</head>
<body onload="return window_onload()"  onresize="return window_onresize()" style="overflow:auto" >
<div id="divFiltros_selplan">
        <table class="tb1">
            <tr class="tbLabel">
                <td style="text-align:left !important">Filtros - Cuota máxima: <span id="strcuota_maxima"></span></td>
            </tr>
        </table>         
        <table class='tb1' style="border-collapse:collapse; border:none;">
            <tr>
                <td>
                <div id="divFiltrosLeft">
                    <table class='tb1'>
                        <tr>
                            <td class='Tit1' style="width:50%"></td>
                            <td class='Tit1' style="width:25%">Desde</td>
                            <td class='Tit1' style="width:25%">Hasta</td>
                        </tr>
                        <tr>
                            <td>Importe Retirado</td>
                            <td><script type="text/javascript">campos_defs.add('retirado_desde', { enDB: false, nro_campo_tipo: 102 })</script></td>
                            <td><script type="text/javascript">campos_defs.add('retirado_hasta', { enDB: false, nro_campo_tipo: 102 })</script></td>
                        </tr>
                    </table>
                </div>
                <div id="divFiltrosRight">
                    <table class='tb1'>
                        <tr>
                            <td class='Tit1' style="width:50%"></td>
                            <td class='Tit1' style="width:25%">Desde</td>
                            <td class='Tit1' style="width:25%">Hasta</td>
                        </tr>
                        <tr>
                            <td>Importe Cuota</td>
                            <td><script type="text/javascript">campos_defs.add('importe_cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script></td>
                            <td><script type="text/javascript">campos_defs.add('importe_cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script></td>
                        </tr>
                    </table>
                </div>
                <div id="divFiltros2Left">
                    <table class='tb1'>
                            <tr>
                                <td class='Tit1' style="width:50%"></td>
                                <td class='Tit1' style="width:25%">Desde</td>
                                <td class='Tit1' style="width:25%">Hasta</td>
                            </tr>
                            <tr>
                                <td>Cuotas</td>
                                <td><script type="text/javascript">campos_defs.add('cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script></td>
                                <td><script type="text/javascript">campos_defs.add('cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script></td>
                            </tr>
                    </table>
                </div>  
                <div id="divFiltros2Right">
                    <table class='tb1' style='vertical-align:middle'>
                        <tr>
                            <td class="Tit1" style="width:100%" colspan="2">Ignorar</td>
                        </tr>
                        <tr>
                            <td style="width:50%">
                                <input type="checkbox" style="border:none" id="chkFiltroCuenta"/>Banco Cobro
                            </td>
                            <td style="width:50%">                               
                               <input type="checkbox" style="border:none" id="chkFiltroBCRA"/> Sit.BCRA
                           </td>                            
                        </tr>
                    </table>
                </div> 
                <div id="divFiltros3Left">
                    <table class='tb1'>
                        <tr>
                            <td class="Tit1" style="width:50%"></td>
                            <td class="Tit1" style="width:50%">Cobro</td>
                        </tr>
                        <tr>
                            <td style="width:50%"><input type="checkbox" style="border:none" id="chkmax_disp" /> Importe máx. disp.</td>  
                            <td style="width:50%"><script type="text/javascript">campos_defs.add('nro_tipo_cobro_precarga', { enDB: true })</script></td>
                        </tr>
                    </table>
                </div>         
                <div id="divFiltros3Right">
                    <table class='tb1'>
                        <tr><td></td></tr>
                        <tr>
                            <td style="width:100%"><div id="divPlanBuscar"></div></td>  
                        </tr>
                    </table>
                </div>                        
                </td>
            </tr>
        </table>        
    </div>
    <iframe  style="width: 100%; height: 300px; border:none; overflow:hidden" name="ifrplanes" id="ifrplanes"></iframe>
      <table style="width:100%; position: fixed; bottom: 0px; float: left; background-color: grey; border-radius:140px" id="tbButtons">
        <tr>
            <td>
                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0">
                    <tr>
                        <td class="btnBegin_O"></td>
                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="Guardar()" id="btn1">
                            <img src="image/save.ico" class="img_button" border="0" align="absmiddle" hspace="1" id="img1">&nbsp;Guardar
                        </td>
                       <td class="btnEnd_O"></td>
                    </tr>
                </table>
            </td>
        </tr>
      </table>
</body>
</html>
