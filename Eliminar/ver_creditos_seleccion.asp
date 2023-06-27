<%@  language="JSCRIPT" %>
<!--#include virtual="meridiano/scripts/pvAccesoPagina.asp"-->
<%
    Response.Expires = 0
    var nro_docu = obtenerValor("nro_docu", '')
    var tipo_docu = obtenerValor("tipo_docu", '')   
    var sexo = obtenerValor("sexo", '')         
    var modal = obtenerValor("modal", '')     
    var id_win = obtenerValor("id_win", '')    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar Créditos</title>
    <!--#include virtual="meridiano/scripts/pvUtiles.asp"-->
    <!--#include virtual="meridiano/scripts/pvCampo_def.asp"-->
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="../meridiano/css/base.css" type="text/css" rel="stylesheet" />
    <link href="../meridiano/css/btnSvr.css" type="text/css" rel="stylesheet" />
    <link href="../meridiano/css/mnuSvr.css" type="text/css" rel="stylesheet" />
    <link href="../meridiano/css/window_themes/default.css" rel="stylesheet" type="text/css" />
    <link href="../meridiano/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />
    <link type="text/css" rel="stylesheet" href="../meridiano/css/calendar/css/jscal2.css" />

    <script type="text/javascript" src="../meridiano/script/mnuSvr.js" language="JavaScript"></script>
    <script type="text/javascript" src="../meridiano/script/acciones.js"></script>
    <script type="text/javascript" src="../meridiano/script/DMOffLine.js"></script>
    <script type="text/javascript" src="../meridiano/script/btnSvr.js"></script>
    <script type="text/javascript" src="../meridiano/script/rsXML.js"></script>
    <script type="text/javascript" src="../meridiano/script/tXML.js"></script>
    <script type="text/javascript" src="../meridiano/script/prototype.js"></script>
    <script type="text/javascript" src="../meridiano/script/window.js"></script>
    <script type="text/javascript" src="../meridiano/script/effects.js"></script>
    <script type="text/javascript" src="../meridiano/script/window_effects.js"></script>
    <script type="text/javascript" src="../meridiano/script/utiles.js"></script>
    <script type="text/javascript" src="../meridiano/script/nvFW.js"></script>
    <script type="text/javascript" src="../meridiano/script/calendar/jscal2.js"></script>
    <script type="text/javascript" src="../meridiano/script/calendar/lang/es.js"></script>
    <script type="text/javascript" src="../meridiano/script/tError.js"></script>
    <script type="text/javascript" src="../meridiano/script/tSesion.js"></script>
    <script type="text/javascript" src="../meridiano/script/imagenes_icons.js"></script>   

    <script type="text/javascript" language="javascript">
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "btn_buscar";
        vButtonItems[0]["etiqueta"] = "";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_creditos()";
        
        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "btn_excel";
        vButtonItems[1]["etiqueta"] = "";
        vButtonItems[1]["imagen"] = "excel";
        vButtonItems[1]["onclick"] = "return exportar_creditos()";


        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.imagenes = Imagenes //Imagenes se declara en pvUtiles

        var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); } 
        
                
        
        function window_onresize() {
            try {
                //debugger
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var FiltroDatos_h = $('divFiltroDatos').getHeight()
                var TablaTotales_h = $('divTablaTotales').getHeight()
                $('frame_listado').setStyle({'height': body_h - FiltroDatos_h - TablaTotales_h - dif + 'px' });
            }
            catch (e) { }
        }
        
        function window_onload() {
            vListButton.MostrarListButton()
            campos_defs.set_value('registros',20)
            window_onresize()
            buscar_creditos()
        }

        function buscar_creditos()
        {
            var nro_docu = $('nro_docu').value
            var tipo_docu = $('tipo_docu').value
            var sexo = $('sexo').value
            var modal = $('modal').value
            var id_win = $('id_win').value
            var filtro = ""
            filtro += "<nro_docu type='igual'>" + nro_docu + "</nro_docu>"
            filtro += "<tipo_docu type='igual'>" + tipo_docu + "</tipo_docu>"
            filtro += "<sexo type='igual'>'" + sexo + "'</sexo>"
            filtro += "<id_srv type='isnull'></id_srv>"
            
            var nro_banco = campos_defs.get_value('nro_banco');
            var nro_mutual = campos_defs.get_value('nro_mutual');
            var estado = campos_defs.get_value('estados');
            var fecha_desde = campos_defs.get_value('fecha_desde') 
            var fecha_hasta = campos_defs.get_value('fecha_hasta') 
            var registros = campos_defs.get_value('registros')
            
            if ((registros == '') || (registros == '0'))
            {
                registros = 20
                campos_defs.set_value('registros',20)                
            }
            
            if (nro_banco != '')
                filtro += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"
                
            if (nro_mutual != '')
                filtro += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
                
            if (estado != '')
                filtro += "<estado type='in'>" + estado + "</estado>"
                
            if (fecha_desde != "")
                filtro += "<fe_estado type='mas'>CONVERT(datetime, '" + fecha_desde + "', 103)</fe_estado>"
                    
            if (fecha_hasta != "")
                filtro += "<fe_estado type='menos'>CONVERT(datetime, '" + fecha_hasta + "', 103)+1</fe_estado>"
                
            if ($('chk_activos').checked)
                filtro += "<estado type='charindex'>TAEW</estado><id_srv type='isnull'></id_srv>"


            var filtroXML = "<criterio><select vista='verSocio_Consumos_nova' PageSize='" + registros + "' AbsolutePage='1' cacheControl='Session'><campos>tipo_docu,nro_docu,sexo,nro_credito,nro_banco,banco,nro_mutual,mutual,nro_comercio,comercio,id_srv,srv_desc,estado,fe_estado,nro_operatoria,nro_entidad,importe_neto,cuotas,importe_cuota,descripcion,saldo_total,saldo_vencido,saldo_pagado," + modal + " as modal,'" + id_win + "' as id_win,importe_documentado,nro_banco_origen,banco_origen</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>" 
            nvFW.exportarReporte({ 
                    filtroXML: filtroXML,
                    path_xsl: 'report\\verSocio_Consumos\\HTML_Socio_Consumos.xsl',
                    formTarget: 'frame_listado',
                    nvFW_mantener_origen: true,
                    bloq_contenedor: $('frame_listado'),
                    cls_contenedor: 'frame_listado'
                })
                
        $('divTablaTotales').innerHTML = ''
        var rs = new tRS();
        rs.async = true
        //rs.open("<criterio><select vista='verSocio_Consumos_nova'><campos>sum(case when estado = 'T' or estado = 't' and (saldo_total - saldo_pagado > 0) then importe_neto else 0 end) as importe_neto, sum(case when estado = 'T' or estado = 't' and (saldo_total - saldo_pagado > 0) then importe_cuota else 0 end) as importe_cuota, sum(case when estado = 'T' or estado = 't' then saldo_vencido-saldo_pagado else 0 end) as debe, sum(case when estado = 'T' or estado = 't' then saldo_total-saldo_pagado else 0 end) as avencer</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>")
        
        rs.open("<criterio><select vista='verSocio_Consumos_nova'><campos>sum(importe_neto) as importe_neto, sum(importe_cuota) as importe_cuota, sum(case when (estado = 'T' or estado = 't') then saldo_vencido-saldo_pagado else 0 end) as debe, sum(case when (estado = 'T' or estado = 't') then saldo_total-saldo_pagado else (case when (estado = 'A') then importe_documentado else 0 end) end) as avencer</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>")
        
        rs.onComplete = function(rs) {
        if (!rs.eof()) {
            var importe_neto = (rs.getdata('importe_neto') == null) ? parseFloat(0) : parseFloat(rs.getdata('importe_neto'))
            var importe_cuota = (rs.getdata('importe_cuota') == null) ? parseFloat(0) : parseFloat(rs.getdata('importe_cuota'))
            var debe = (rs.getdata('debe') == null) ? parseFloat(0) : parseFloat(rs.getdata('debe'))
            var avencer = (rs.getdata('avencer') == null) ? parseFloat(0) : parseFloat(rs.getdata('avencer'))           
            
            $('divTablaTotales').innerHTML = ''
            var strHTML = "<table id='tbTablaTotales' class='tb1' style='width:100%'>"
            strHTML += "<tr>"
            strHTML += "<td class='Tit1' style='width:48%;text-align:center'><b>TOTALES</b></td>"
            strHTML += "<td class='Tit1' style='width:8%;text-align:right'><b>$ " + importe_neto.toFixed(2) + "</b></td>"
            strHTML += "<td class='Tit1' style='width:6%;text-align:center'>-</td>"
            strHTML += "<td class='Tit1' style='width:8%;text-align:right'><b>$ " + importe_cuota.toFixed(2) + "</b></td>"
            strHTML += "<td class='Tit1' style='width:15%;text-align:center'>-</td>"
            strHTML += "<td class='Tit1' style='width:7%;text-align:right'><b>$ " + debe.toFixed(2) + "</b></td>"
            strHTML += "<td class='Tit1' style='width:7%;text-align:right'><b>$ " + avencer.toFixed(2) + "</b></td>"
            strHTML += "<td class='Tit1' style='width:1%; text-align:center'></td>"
            strHTML += "</tr>"
            strHTML += "</table>"
            $('divTablaTotales').insert({ top: strHTML })
            } 
         }    
        }



        function exportar_creditos() {
            var nro_docu = $('nro_docu').value
            var tipo_docu = $('tipo_docu').value
            var sexo = $('sexo').value
            var filtro = ""
            filtro += "<nro_docu type='igual'>" + nro_docu + "</nro_docu>"
            filtro += "<tipo_docu type='igual'>" + tipo_docu + "</tipo_docu>"
            filtro += "<sexo type='igual'>'" + sexo + "'</sexo>"
            
            var nro_banco = campos_defs.get_value('nro_banco');
            var nro_mutual = campos_defs.get_value('nro_mutual');
            var estado = campos_defs.get_value('estados');
            var fecha_desde = campos_defs.get_value('fecha_desde') 
            var fecha_hasta = campos_defs.get_value('fecha_hasta') 
            
            if (nro_banco != '')
                filtro += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"
                
            if (nro_mutual != '')
                filtro += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
                
            if (estado != '')
                filtro += "<estado type='in'>" + estado + "</estado>"
                
            if (fecha_desde != "")
                filtro += "<fe_estado type='mas'>CONVERT(datetime, '" + fecha_desde + "', 103)</fe_estado>"
                    
            if (fecha_hasta != "")
                filtro += "<fe_estado type='menos'>CONVERT(datetime, '" + fecha_hasta + "', 103)+1</fe_estado>"
                
            if ($('chk_activos').checked)
                filtro += "<estado type='charindex'>TAEW</estado><id_srv type='isnull'></id_srv>"

            nvFW.exportarReporte({
                           //Parámetros de consulta
            filtroXML: "<criterio><select vista='verSocio_Consumos_nova'><campos>nro_entidad,sexo,tipo_docu,nro_docu,nro_credito,nro_banco,banco,nro_banco_origen,banco_origen,nro_comercio,comercio,id_srv,srv_desc,nro_mutual,mutual,nro_operatoria,importe_neto,cuotas,importe_cuota,estado,descripcion,fe_estado,saldo_pagado,saldo_vencido,saldo_total</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>"
                         , path_xsl: "report\\EXCEL_base.xsl"
                         , salida_tipo: "adjunto"
                         , ContentType: "application/vnd.ms-excel"
                         , formTarget: "_blank"
                         , filename: 'Listado de créditos DNI' + nro_docu
                })
        }
        
        function mostrar_creditos(nro_credito)
        {
            var modal = $('modal').value
            if (nro_credito != '')
            {
                if (modal == '3')
                    window.location.href = "../../meridiano/credito_mostrar.asp?nro_credito=" + nro_credito   
                else
                    window.parent.location.href = "../../meridiano/credito_mostrar.asp?nro_credito=" + nro_credito   
             }
        }
        
        function mostrar_comercios(nro_comercio,nro_mutual,nro_operatoria,nro_entidad)
        {
            var modal = $('modal').value
            if (nro_comercio != '')
            {
                if (modal == '3')
                    window.location.href = "../../meridiano/comercio_mostrar.asp?nro_comercio=" + nro_comercio + "&nro_mutual=" + nro_mutual + "&nro_operatoria=" + nro_operatoria + "&nro_entidad=" + nro_entidad
                else
                    window.parent.location.href = "../../meridiano/comercio_mostrar.asp?nro_comercio=" + nro_comercio + "&nro_mutual=" + nro_mutual + "&nro_operatoria=" + nro_operatoria + "&nro_entidad=" + nro_entidad
            }
        }


    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto">
    <input type="hidden" name="nro_docu" id="nro_docu" value="<%=nro_docu %>" /> 
    <input type="hidden" name="tipo_docu" id="tipo_docu" value="<%=tipo_docu %>" /> 
    <input type="hidden" name="sexo" id="sexo" value="<%=sexo %>" /> 
    <input type="hidden" name="modal" id="modal" value="<%=modal %>" /> 
    <input type="hidden" name="id_win" id="id_win" value="<%=id_win %>" /> 
    <div id="divFiltroDatos">  
    
        <table class="tb1">
            <tr>
                <td style="width: 85%">
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td style="width: 29%">
                                Banco
                            </td>
                            <td style="width: 24%">
                                Mutual
                            </td>
                            <td style="width: 17%">
                                Estado
                            </td>
                            <td style="width: 9%">
                                Fecha Desde
                            </td>
                            <td style="width: 9%">
                                Fecha Hasta
                            </td>
                            <td style="width: 4%">
                                Activos
                            </td>
                            <td style="width: 5%">
                                Registros
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('nro_banco')
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('nro_mutual')
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('estados')
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('fecha_desde', { enDB: false, nro_campo_tipo: 103 })
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('fecha_hasta', { enDB: false, nro_campo_tipo: 103 })
                                </script>
                            </td>
                            <td style="text-align:center"><input type="checkbox" id='chk_activos' style="border:0" /></td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('registros', { enDB: false, nro_campo_tipo: 100 })
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
                <td style="width: 15%;">
                    <div style="width:48%; display: inline-block; display: -moz-inline-stack; *display:inline" id="divbtn_buscar" ></div>
                    <div style="width:50%; display: inline-block; display: -moz-inline-stack; *display:inline" id="divbtn_excel" ></div>
                </td>
            </tr>
        </table>
    </div>
    <iframe name="frame_listado" id="frame_listado" style='width: 100%; overflow: auto; height: 100%' frameborder="0" src="enBlanco.htm"></iframe>    
    <div id="divTablaTotales" style="width: 100%; height: 30px; overflow: auto"></div>
</body>
</html>
