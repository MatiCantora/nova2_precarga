<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim nrodoc As String = nvFW.nvUtiles.obtenerValor("nrodoc", "")
    Dim tipdoc As String = nvFW.nvUtiles.obtenerValor("tipdoc", "")

    Me.contents("nrodoc") = nrodoc
    Me.contents("tipdoc") = tipdoc
    Me.contents("ver_cuentas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cuentas' cn='BD_IBS_ANEXA'><campos>prodnom, convert(varchar, fecultmov, 103) as fecultmov, cuecod, sistcod, sistema, moneda, cueestdesc, nombrecta</campos><filtro> <nrodoc type='igual'> " + nrodoc + " </nrodoc><tipdoc type='igual'> " + tipdoc + " </tipdoc></filtro></select ></criterio > ")
    Me.contents("ver_pf") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_PF' cn='BD_IBS_ANEXA'><campos>openro,sistcod, mondesc, cuecod, nombrecta, estoperdesc, prodnom, capital, interes, sdocuo, plazoop, capital_indbase, indbase, convert(varchar, fecori, 103) as fecori, convert(varchar, fecven, 103) as fecven</campos><orden/><filtro><cuecod type='igual'>%cuecod%</cuecod><nrodoc type='igual'> " + nrodoc + " </nrodoc><tipdoc type='igual'> " + tipdoc + " </tipdoc></filtro></select></criterio>")
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <meta name="viewport" content="width=device-width, user-scalable=no">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Contables</title>

    <style type="text/css">
        .grid-container {
            display: grid;
            grid-template-columns: auto auto;
            grid-row-gap: 10px;
        }

        .grid-item1 {
            padding-top: 10px;
            grid-row-start: 1;
            grid-row-end: 2;
            grid-column-start: 1;
            grid-column-end: 2;
        }

        .grid-item2 {
            padding-top: 10px;
            grid-row-start: 1;
            grid-row-end: 2;
            grid-column-start: 2;
            grid-column-end: 3;
        }

        .grid-item3 {
            padding-top: 10px;
            grid-row-start: 2;
            grid-row-end: 3;
            grid-column-start: 1;
            grid-column-end: 2;
        }

        .dialog {
            position: unset !important;
        }
    </style>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">

        var nrodoc = nvFW.pageContents.nrodoc;
        var tipdoc = nvFW.pageContents.tipdoc;
        var mywin = nvFW.getMyWindow();
        var winC, winTrans, winParam, winCampo;
        var cuecod = ''

        function window_onload() {
            
            cargar_cuentas(nrodoc, tipdoc)
            vListButton.MostrarListButton()
        }
        
        function window_onresize() {            
            var resta = $$('body')[0].getHeight() - $('cabecera').getHeight() + 'px'
            $('iframe_op').setStyle({ height: resta })           
        }

        function cuentas_resize() {
            var resta2 = $('divCuentas').getHeight() - $('cuentas_cab').getHeight() + 'px'
            $('cuentas_det').setStyle({ height: resta2 })
            campos_head.resize('tbCuentas', 'tbDetalle')
        }
                      

        var cant_cuentas = 0;
        function cargar_cuentas(nrodoc, tipdoc) {
            
            nvFW.bloqueo_activar($$('body')[0], 'bloq_cuentas', 'Cargando cuentas...');
           
            var strWhere = "<criterio><select><filtro>" + campos_defs.filtroWhere() + "</filtro></select></criterio>"
            var rs_cuentas = new tRS();

            rs_cuentas.async = true;
                
            rs_cuentas.onError = function () {                

                nvFW.bloqueo_desactivar(null, 'bloq_cuentas');

                alert('Error al cargar cuentas.');

            }

            rs_cuentas.onComplete = function () {
                
                var strHTML = '';
                cant_cuentas = 0;
                if (!rs_cuentas.eof()) {
                    strHTML += '<div id="cuentas_cab">';
                    strHTML += '<table class="tb1" id="tbCuentas">';
                    strHTML += '<tr class="tbLabel" style="overflow: hidden">';
                    strHTML += '<td style="text-align: center; width: 2%"></td>';
                    strHTML += '<td style="text-align: center; width: 15%">Sistema</td>';
                    strHTML += '<td style="text-align: center; width: 53%">Producto</td>';
                    strHTML += '<td style="text-align: center; width: 10%">Moneda</td>';
                    strHTML += '<td style="text-align: center; width: 5%">Nro.</td>';
                    strHTML += '<td style="text-align: center; width: 5%">Estado</td>';
                    //strHTML += '<td style="text-align: center; width: 28%">Nombre Cuenta</td>';
                    strHTML += '<td style="text-align: center; width: 10%">Último Mov.</td>';
                    strHTML += '</tr>';
                    strHTML += '</table >';
                    strHTML += '</div >';
                    strHTML += '<div id="cuentas_det" style="width: 100%;overflow-y:auto; overflow-x: hidden">';
                    strHTML += '<table id="tbDetalle" class="tb1 highlightOdd highlightTROver layout_fixed">';
                    strHTML += '<tr>';

                            var rdchecked = 'checked';
                            var prodnom = '';
                            var fecultmov = '';                    
                            var nombrecta = '';
                             

                    while (!rs_cuentas.eof()) {
                        
                        if (rs_cuentas.getdata('prodnom') != undefined) {
                            prodnom = rs_cuentas.getdata('prodnom')
                        }

                        if (rs_cuentas.getdata('fecultmov') != undefined) {
                            fecultmov = rs_cuentas.getdata('fecultmov')
                        }

                        if (rs_cuentas.getdata('nombrecta') != undefined) {
                            nombrecta = rs_cuentas.getdata('nombrecta')
                        }

                        
                        cuecod = rs_cuentas.getdata('cuecod')
                        

                        
                        strHTML += '<td style="text-align: center; width:2%"><input type="radio" name="rd_checked" id="' + rs_cuentas.getdata('cuecod') + '" ' + rdchecked + ' onchange="cargar_op(' + rs_cuentas.getdata('sistcod') + ', ' + rs_cuentas.getdata('cuecod') + ')"></input></td>';
                        strHTML += '<td style="width:10%" id="rd_tipo_' + cant_cuentas + '">' + rs_cuentas.getdata('sistema') + '</td>';
                        strHTML += '<td style="width:53%" id="rd_tipo_' + cant_cuentas + '">' + prodnom + '</td>';
                        strHTML += '<td style="width:10%" id="rd_moneda_' + cant_cuentas + '">' + rs_cuentas.getdata('moneda') + '</td>';
                        strHTML += '<td style="width:5%; text-align:right;" id="rd_nro_' + cant_cuentas + '">' + cuecod + '</td>';
                        strHTML += '<td style="width:5%" id="rd_estado_' + cant_cuentas + '">' + rs_cuentas.getdata('cueestdesc') + '</td>';
                        //strHTML += '<td style="width:28%" id="rd_nombre_' + cant_cuentas + '">' + nombrecta + '</td>';
                        strHTML += '<td style="width:10%; text-align:right;" id="rd_ultimo_mov_' + cant_cuentas + '">' + fecultmov + '</td>';
                        strHTML += '</tr>'
                    
                        rdchecked = '';
                        cant_cuentas++;

                        rs_cuentas.movenext();
                    }

                    strHTML += '</table></div>';
                    
                    $('divCuentas').setStyle({ display: 'block' })
                   

                } else {                    
                    $('divCuentas').setStyle({ display: 'flex', justifyContents: 'center', alignItems: 'center' });
                    strHTML += '<div><b>No se encontraron cuentas para el usuario.<b></div>';
                    nvFW.bloqueo_desactivar(null, 'bloq_cuentas');
                }

                $('divCuentas').innerHTML = strHTML;
                cuentas_resize();
                document.getElementsByName('rd_checked')[0].onchange();

                nvFW.bloqueo_desactivar(null, 'bloq_cuentas');
                
                

                for (var i = 0; i < document.getElementsByName('rd_cuenta').length; i++)
                    if (document.getElementsByName('rd_cuenta')[i].checked)
                        document.getElementsByName('rd_cuenta')[i].onchange();
                
            }
            
            rs_cuentas.open(nvFW.pageContents.ver_cuentas, '', strWhere, '', '');            
            
        }

        function cargar_op(id, cuecod) {

            
            var id = id
            cuecod = cuecod                     
            
            if (id == '4') {
                $('iframe_op').src = 'PF_listar.aspx?nrodoc=' + nrodoc + '&tipdoc=' + tipdoc + '&cuecod=' + cuecod + '';
            } else {
                $('iframe_op').src = 'CA_listar.aspx?nrodoc=' + nrodoc + '&tipdoc=' + tipdoc + '&cuecod=' + cuecod + '';
            }

            window_onresize()
        }

        function exportar() {
            debugger            
            var strXSL = campos_defs.filtroWhere()
            strXSL += nvFW.ObtenerVentana('iframe_op').campos_defs.filtroWhere()
            
            var params = ''
            for (var i = 0; i < document.getElementsByName('rd_checked').length; i++) {
                if (document.getElementsByName('rd_checked')[i].checked)                    
                    params = '<criterio><params cuecod="' + document.getElementsByName('rd_checked')[i].id + '" /></criterio>'
            }            

            nvFW.exportarReporte({                
                filtroXML: nvFW.pageContents.ver_pf
                , filtroWhere: strXSL
                , path_xsl: "report\\excel_base.xsl"
                , salida_tipo: "adjunto"
                , ContentType: "application/vnd.ms-excel"
                , formTarget: "iframe1"
                , params: params
                , filename: "cuenta_movimiento.xls"
            })
        }
    </script>

</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden">

    <script type="text/javascript">
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Mostrar";
        vButtonItems[0]["imagen"] = "ver";
        vButtonItems[0]["onclick"] = "return cargar_cuentas()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Exportar";
        vButtonItems[1]["etiqueta"] = "Expotar";
        vButtonItems[1]["imagen"] = "excel";
        vButtonItems[1]["onclick"] = "return exportar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')

        vListButton.loadImage("ver", '/FW/image/icons/ver.png')
        vListButton.loadImage("excel", '/FW/image/icons/excel.png')
        
    </script>

        <div id="cabecera">
                <table class="tb1">
                    <tr>
                        <td class="Tit3" style="text-align: center; width: 20%">Sistema</td>
                        <td class="Tit3" style="text-align: center; width: 15%">Moneda</td>
                        <td class="Tit3" style="text-align: center; width: 12%">Nro.</td>
                        <td class="Tit3" style="text-align: center; width: 12%">Estado</td>
                        <td class="Tit3" style="text-align: center; width: 18%" colspan="2">Fecha Alta</td>
                        <td class="Tit3" style="text-align: center; width: 18%" colspan="2">Fecha Estado</td>
                        <td style="vertical-align: middle;">
                            <div id="divExportar"></div>
                       </td>                                             
                    </tr>
                    
                    <tr>
                        <td style="width: 20%">
                            <script type="text/javascript">
                                campos_defs.add('sistcodes')
                            </script>
                        </td>
                        <td style="width: 15%">
                            <script type="text/javascript">
                                campos_defs.add('moncodes')
                            </script>
                        </td>
                        <td style="width: 12%">
                            <script type="text/javascript">
                                campos_defs.add('cuecod', {
                                    enDB: false,
                                    nro_campo_tipo: 100,
                                    filtroXML: nvFW.pageContents.filtro_descripcion,
                                    filtroWhere: "<cuecod type='in'>%campo_value%</cuecod>"
                                })
                            </script>
                        </td>
                        <td style="width: 12%">
                            <script type="text/javascript">
                                campos_defs.add('estctacodes')
                            </script>
                        </td>
                        <td style="width: 9%">
                            <script type="text/javascript">
                                campos_defs.add('fecalta_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecalta type='mas'>convert(datetime, '%campo_value%', 103)</fecalta>"
                                });
                            </script>
                        </td>
                        <td style="width: 9%">
                            <script type="text/javascript">
                                campos_defs.add('fecalta_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecalta type='menos'>convert(datetime, '%campo_value%', 103)</fecalta>"
                                });
                            </script>
                        </td>
                        <td style="width: 9%">
                            <script type="text/javascript">
                                campos_defs.add('fecestado_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecestado type='mas'>convert(datetime, '%campo_value%', 103)</fecestado>"
                                });
                            </script>
                        </td>
                        <td style="width: 9%">
                            <script type="text/javascript">
                                campos_defs.add('fecestado_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: "<fecestado type='menos'>convert(datetime, '%campo_value%', 103)</fecestado>"
                                });
                            </script>
                        </td>
                        <td style="vertical-align: middle;">
                            <div id="divBuscar"></div>
                       </td>
                   </tr>
            </table>
            <div id="divCuentas" style="display: none; max-height:300px; overflow: hidden"></div>       
            </div>
               
          <iframe name="iframe_op" id="iframe_op" style="width: 100%; height: 100%; overflow: auto; border:none;"></iframe>      
</body>
</html>
