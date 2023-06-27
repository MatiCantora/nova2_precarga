<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%
    Dim dependientes As String = ""
    'Dim rsF = nvFW.nvDBUtiles.DBOpenRecordset("select convert(varchar,dbo.finac_inicio_mes(getdate()-2),103) as fe_desde_str")
    'Dim fe_desde_str As String = rsF.Fields("fe_desde_str").Value
    Dim nro_vendedor As Integer = nvFW.nvUtiles.obtenerValor("nro_vendedor", "0")
    Dim rsD = nvFW.nvDBUtiles.DBOpenRecordset("select dbo.rm_vendedor_dependencia(" & nro_vendedor & ") as dependientes")
    if  rsD.EOF = False then
		dependientes = rsD.Fields("dependientes").Value
end if 

    Me.contents("creditos_mostrar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos' PageSize='9' AbsolutePage='1' cacheControl='Session'><campos>nro_credito,nro_docu,strNombreCompleto,banco,mutual,importe_neto,cuotas,importe_cuota,descripcion,estado,fe_estado,dbo.conv_fecha_to_str(fe_estado,'dd/mm/yyyy hh:mm:ss') as fe_estado_str</campos><orden>fe_estado desc</orden><filtro></filtro></select></criterio>")
    Me.contents("estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEstados'><campos>cod_estado as id,estado_desc as [campo]</campos><filtro><estado type='in'>'A','D','E','G','H','L','M','O','P','Q','R','T','U','Z','1','2','4','5'</estado></filtro><orden>estado_desc</orden></select></criterio>")
    Me.contents("creditos_mostrar_exp") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos_exp'><campos>nro_credito,mutual,banco,strNombreCompleto as apellido_y_nombres,nro_docu,grupo as reparticion,importe_neto,cuotas,importe_cuota,descripcion as estado,dbo.conv_fecha_to_str(fe_estado,'dd/mm/yyyy hh:mm:ss') as fe_estado,vendedor,car_tel,telefono,localidad,provincia</campos><orden>fe_estado desc</orden><filtro></filtro></select></criterio>")
    ' Me.contents("dependientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista=''><campos>dbo.rm_vendedor_dependencia(%nro_vendedor%) as dependientes</campos><filtro></filtro></select></criterio>")
    '"<criterio><select vista='verEstados'><campos>cod_estado as id,estado_desc as [campo]</campos><filtro><estado type='in'>'A','D','E','G','H','L','M','O','P','Q','R','T','U','Z'</estado></filtro><orden>estado_desc</orden></select></criterio>"
    Me.contents("dependientes_vendedor") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vendedor' ><campos>top 1 dbo.rm_vendedor_dependencia(%nro_vendedor%) As dependientes </campos></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="FW/image/icons/nv_login.ico"/>
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>
    <script type="text/javascript" src="/precarga/script/tCampo_head.js" ></script>
    <%--<script type="text/javascript" src="/precarga/script/precarga.js" ></script>--%>
    <script type="text/javascript" src="script/precarga.js"></script>

    <% = Me.getHeadInit()%>  

    <script type="text/javascript" language="javascript" class="table_window">

    var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    var win = nvFW.getMyWindow()

    var vButtonItems = {}
    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "Buscar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return verCreditos(modo)";
    vButtonItems[1] = {}
    vButtonItems[1]["nombre"] = "Exportar";
    vButtonItems[1]["etiqueta"] = "Exportar";
    vButtonItems[1]["imagen"] = "excel";
    vButtonItems[1]["onclick"] = "return Exportar()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons');
    vListButtons.loadImage("buscar", "/precarga/image/search_16.png");
    vListButtons.loadImage("excel", "/FW/image/icons/excel.png");

        var nro_vendedor = 0;
        var nro_docu = 0;
        var WinTipo = '';
        var modo = '';
        var ismobile = false;
        var fe_desde = '';
        var dependientes = "";
        var BodyWidth = 0;

    function window_onload() 
    {
        vListButtons.MostrarListButton()
        filtros = win.options.userData.filtros
        modo = filtros['modo']
        nro_vendedor = filtros['nro_vendedor']
        nro_docu = filtros['nro_docu']
        BodyWidth = filtros['BodyWidth']
        window_onresize()
     //   campos_defs.add("estados", { nro_campo_tipo: 2, target: "tdestados", enDB: false, cacheControl:'nvFW', filtroXML: nvFW.pageContents.estados })
        campos_defs.set_value('estados_precarga', "'P','H','M','R'")        
        fe_desde = new Date()
        fe_desde.setDate(1)
        $('fecha_desde').value = FechaToSTR(fe_desde)
        
    }     

    function verCreditos(modo)
    {
        dependientes = 0
        var rs = new tRS()
        rs.open({ filtroXML: nvFW.pageContents.dependientes_vendedor, params: "<criterio><params nro_vendedor='" + nro_vendedor + "' /></criterio>" })
        if (!rs.eof()) {
            dependientes = rs.getdata("dependientes")
        }

        var filtro = "<estado type='in'>'1','2','4','5','A', 'D', 'E', 'G', 'H', 'L', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'Z'</estado>"
       // dependientes = "<nro_vendedor type='sql'><![CDATA[nro_vendedor in (select dbo.rm_vendedor_dependencia(" + nro_vendedor + "))]]></nro_vendedor> "
        var estados = ''       

        estados = $('estados_precarga').value

        if (($('fecha_desde').value == '') && ($('fecha_hasta').value == '') && (estados == '') && ($('nro_credito').value == '') && ($('nro_docu').value == ''))
            {
            nvFW.alert('Ingrese un filtro para realizar la búsqueda')
            return
            }
            
        if ($('fecha_desde').value != '')
            filtro += "<fe_estado type='sql'><![CDATA[fe_estado >= convert(datetime,'" + $('fecha_desde').value + "',103)]]></fe_estado>"

        if ($('fecha_hasta').value != '')
            filtro += "<fe_estado type='sql'><![CDATA[fe_estado < convert(datetime,'" + $('fecha_hasta').value + "',103)+1]]></fe_estado>"            

        if (modo == 'V')
            filtro += "<nro_vendedor type='sql'><![CDATA[nro_vendedor in ("+dependientes+")]]></nro_vendedor> " //"<nro_vendedor type='in'>" + dependientes + "</nro_vendedor>"
        if (modo == 'S')
            $('nro_docu').value = nro_docu
            //filtro += "<nro_docu type='igual'>" + nro_docu + "</nro_docu>"        
        
        if (estados != '')
            filtro += "<estado type='in'>" + estados + "</estado>"

        if ($('nro_credito').value != '')
            filtro += "<nro_credito type='igual'>" + $('nro_credito').value + "</nro_credito>"

        if ($('nro_docu').value != '')
            filtro += "<nro_docu type='igual'>" + $('nro_docu').value + "</nro_docu>"

        var page = 9
        if (isMobile()) {
            page = 3
        }
        nvFW.exportarReporte({
            filtroXML: nvFW.pageContents.creditos_mostrar,
            filtroWhere: "<criterio><select PageSize='" + page + "'><filtro>" + filtro + "</filtro></select></criterio>",
            //params: "<criterio><params  /></criterio>",
            path_xsl: 'report\\verCreditos\\HTML_creditos_precarga.xsl',
            formTarget: 'iframe_cr',
            nvFW_mantener_origen: true,
            bloq_contenedor: $(document.documentElement),
            bloq_msg: 'Realizando búsqueda...'
        })

   //     window.webkit.messageHandlers.nvInterOp.postMessage("Buscar vededores");
        
    }   

    function Exportar()
    {
        var filtro = "<estado type='in'>'1','2','4','5','A', 'D', 'E', 'G', 'H', 'L', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'Z'</estado>"

        var estados = ''       

        estados = $('estados_precarga').value

        if (($('fecha_desde').value == '') && ($('fecha_hasta').value == '') && (estados == '') && ($('nro_credito').value == '') && ($('nro_docu').value == ''))
            {
            nvFW.alert('Ingrese un filtro para realizar la búsqueda')
            return
            }
            
        if ($('fecha_desde').value != '')
            filtro += "<fe_estado type='sql'><![CDATA[fe_estado >= convert(datetime,'" + $('fecha_desde').value + "',103)]]></fe_estado>"

        if ($('fecha_hasta').value != '')
            filtro += "<fe_estado type='sql'><![CDATA[fe_estado < convert(datetime,'" + $('fecha_hasta').value + "',103)+1]]></fe_estado>"            

        if (modo == 'V')
            filtro += "<nro_vendedor type='in'>" + dependientes + "</nro_vendedor>"
        if (modo == 'S')
            $('nro_docu').value = nro_docu
            //filtro += "<nro_docu type='igual'>" + nro_docu + "</nro_docu>"        

        if (estados != '')
            filtro += "<estado type='in'>" + estados + "</estado>"

        if ($('nro_credito').value != '')
            filtro += "<nro_credito type='igual'>" + $('nro_credito').value + "</nro_credito>"

        if ($('nro_docu').value != '')
            filtro += "<nro_docu type='igual'>" + $('nro_docu').value + "</nro_docu>"
        
        nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.creditos_mostrar_exp,
                        filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                        path_xsl: "report\\EXCEL_base.xsl",
                        salida_tipo: "adjunto",
                        ContentType: "application/vnd.ms-excel",
                        formTarget: "_blank",
                        filename: "creditos_" + nro_vendedor + ".xls",
                        export_exeption: "RSXMLtoExcel",
                        content_disposition: "attachment"
                        ,requestMethod: "GET"
                    })
    } 

    var win_estado

    function MostrarCredito(nro_credito)
    {
        var filtros = {}
        filtros['nro_credito'] = nro_credito
        win_estado = window.top.createWindow2({
            url: 'Credito_cambiar_estado.aspx',
            title: '<b>Crédito: ' + nro_credito + ' </b>',
            centerHFromElement: parent.$("contenedor"),
            parentWidthElement: parent.$("contenedor"),
            parentWidthPercent: 0.9,
            parentHeightElement: parent.$("contenedor"),
            parentHeightPercent: 0.9,
            maxHeight: 500,
            minimizable: false,
            maximizable: false,
            draggable: true,
            resizable: true,
            onClose: MostrarCredito_onClose
        });
        win_estado.options.userData = { filtros: filtros }
        win_estado.showCenter(true)
    }

    function MostrarCredito_onClose()
    {
        var retorno = win_estado.options.userData.res
        if (retorno)
            verCreditos(modo)
    }

    function Aceptar(estado)
    {
        var datos_solicitud = {}
        datos_solicitud['estado'] = estado    
        win.options.userData = { datos_solicitud: datos_solicitud }
        win.close()
    }

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            div_filtro = $('divFiltro').getHeight()
            $('containerDiv').setStyle({ height: body_height - dif - 2 + 'px' })
            $('iframe_cr').setStyle({ height: body_height - div_filtro - dif - 10 + 'px' })
        }
        catch (e) { }
    }
        
</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; overflow: hidden; background-color:white">
    <div style="overflow:auto;-webkit-overflow-scrolling:touch;" id="containerDiv">
        <div id="divFiltro">
            <div id="divCrFiltroFecha">
            <table class='tb1' id="tbFiltro03">
                <tr>
                    <td class='Tit1' style="width:50%">Fecha</td>
                </tr>
                <tr>
                    <td><table style="width:100%"><tr><td style="width:50%"><script type="text/javascript">campos_defs.add('fecha_desde', { enDB: false, nro_campo_tipo: 103 })</script></td><td>-</td><td><script type="text/javascript">campos_defs.add('fecha_hasta', { enDB: false, nro_campo_tipo: 103 })</script></td></tr></table></td>
                </tr>
            </table>
            </div>
            <div id="divCrFiltroLeft">
            <table class='tb1' id="tbFiltro01">
                <tr>
                    <td class='Tit1' style="width:25%">Crédito</td>
                    <td class='Tit1' style="width:25%">Documento</td>                
                </tr>
                <tr>
                    <td><input type="number" name="nro_credito" id="nro_credito" style="width: 100%; text-align: right" maxlength="10" /></td>
                    <td><input type="number" name="nro_docu" id="nro_docu" style="width: 100%; text-align: right" maxlength="10" /></td>
                </tr>
            </table>
            </div>

            <div id="divCrFiltroRight">
                <table class='tb1' id="tbFiltro02">
                    <tr>
                        <td class='Tit1' style="width:50%">Estado</td>
                        <td style="vertical-align:middle;width:25%"><div id="divExportar"></div></td>
                    </tr>
                    <tr>
                        <td id="tdestados">
                            <!--<span id="spestados"></span>-->
                            <!--<select multiple="multiple" size="1" style="width:100%" id="estados"></select>-->
                            <%= nvFW.nvCampo_def.get_html_input("estados_precarga") %>
                        </td>
                        <td style="vertical-align:middle;width:25%"><div id="divBuscar"></div></td>
                    </tr>
                </table>
            </div>
        </div>
        <!--onkeypress="return btnBuscar_trabajo_onclick(event)"-->
    
        <iframe name="iframe_cr" id="iframe_cr" style='width: 100%;' frameborder="0" src="/fw/enBlanco.htm"></iframe>
    </div>      
</body>
</html>