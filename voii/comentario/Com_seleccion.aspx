<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Me.contents("verRegistro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro' PageSize='100' AbsolutePage='1' cacheControl='Session'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("expRegistro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("defTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_id_tipo'><campos>nro_com_id_tipo as id, com_id_tipo as campo</campos><filtro></filtro><orden></orden></select></criterio>")

    Response.Expires = 0
%>
<html>
<head>
<title>Búsqueda de Comentarios</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var vButtonItems = new Array()

vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Buscar";
vButtonItems[0]["etiqueta"] = "Buscar";
vButtonItems[0]["imagen"] = "buscar";
vButtonItems[0]["onclick"] = "return Aceptar()";

//vButtonItems[1] = new Array();
//vButtonItems[1]["nombre"] = "Imprimir";
//vButtonItems[1]["etiqueta"] = "Imprimir";
//vButtonItems[1]["imagen"] = "imprimir";
//vButtonItems[1]["onclick"] = "return Imprimir()";

vButtonItems[1] = new Array();
vButtonItems[1]["nombre"] = "Exportar";
vButtonItems[1]["etiqueta"] = "Exportar";
vButtonItems[1]["imagen"] = "excel";
vButtonItems[1]["onclick"] = "return Exportar()";

var vListButtons = new tListButton(vButtonItems, 'vListButtons')
vListButtons.loadImage("buscar", "/fw/image/icons/buscar.png")
//vListButtons.loadImage("imprimir", "/fw/image/icons/imprimir.png")
vListButtons.loadImage("excel", "/fw/image/icons/excel.png")

var tipo_docu_desc
var tipo_docu
var nro_docu = 0
var sexo
var nombre
var criterio = ""
var nro_com_tipos_ant = ""
var Filtros = new Array()

function window_onload() 
{
    vListButtons.MostrarListButton()
    //campos_defs.items['nro_com_tipo']['onchange'] = Filtro_Parametros
    campos_defs.items['nro_com_tipo'].onchange = function (campo_def) {
        Filtro_Parametros()
    }
    campos_defs.add('fecha_desde', { target: 'tdfecha_desde', enDB: false, nro_campo_tipo: 103 })
    campos_defs.add('fecha_hasta', { target: 'tdfecha_hasta', enDB: false, nro_campo_tipo: 103 })
    window_onresize()           
}

function window_onresize() {
    try {
        var dif = Prototype.Browser.IE ? 5 : 2
        var body_height = $$('body')[0].getHeight()
        var divFiltro01_height = $('divFiltro01').getHeight()
        var divFiltro02_height = $('divFiltro02').getHeight()
        var divVistas_height = $('divVistas').getHeight()

        $('iframe1').setStyle({ height: body_height - divFiltro01_height - divFiltro02_height - divVistas_height - dif + 'px' })
       
    }
    catch (e) { }
} 

function Filtro_Parametros(){
    var filtro = ''
    nro_com_tipos = $('nro_com_tipo').value
    if (nro_com_tipos != '')
        filtro = "<nro_com_tipo type='in'>" + nro_com_tipos + "</nro_com_tipo>"  
    if (filtro != '')
        {
        var rs = new tRS();
        rs.open("<criterio><select vista='com_parametros_tipo'><campos>com_parametro</campos><filtro>" + filtro + "</filtro></select></criterio>")
        if (!rs.eof())
            $('btn_parametros').disabled = false
        else
            $('btn_parametros').disabled = true
        rs.close                 
        }
    else
        $('btn_parametros').disabled = true
}

var win_parametros

function Ventana_Parametros() {
    if (nro_com_tipos_ant != campos_defs.items['nro_com_tipo']["input_hidden"].value)
        Filtros['nro_com_tipos'] = campos_defs.items['nro_com_tipo']["input_hidden"].value
    else
        Filtros['nro_com_tipos'] = campos_defs.items['nro_com_tipo']["input_hidden"].value    
    nro_com_tipos = campos_defs.items['nro_com_tipo']["input_hidden"].value
    nro_com_tipos_ant = nro_com_tipos

    win_parametros = nvFW.createWindow({ className: 'alphacube',
        title: '<b>Filtro Parámetros de Comentarios</b>',
        minimizable: true,
        maximizable: true,
        draggable: false,
        closable: true,
        width: 625,
        height: 400,
        resizable: false,
        onClose: Ventana_Parametros_return
    });
    win_parametros.options.userData = { Filtros: Filtros }
    win_parametros.setURL('Com_seleccion_parametros.aspx')
    win_parametros.showCenter(true) 

}

function Ventana_Parametros_return(){
    if (win_parametros.options.userData.res) {
        Filtros = win_parametros.options.userData.res
        Armar_Filtro(Filtros)
    }        
}

var Filtro_parametros = ''
var Campos_parametros = ''

function Armar_Filtro(Filtros) { 
    debugger
    Filtro_parametros = ''
    campo_filtrar = ''

    for (i = 1; i < Filtros.length; i++) {  
        debugger
         x = parseInt(i) + 1  
          switch (Filtros[i]["tipo_dato"]) {                       
                case 'BOOLEAN':
                     Filtro_parametros = Filtro_parametros + "<nro_registro type='sql'>dbo.rm_com_parametro_valor (nro_registro,'" + Filtros[i]["com_etiqueta"] + "') like '%" + Filtros[i]["com_valor"] + "%'</nro_registro>"        
                break                    
                case 'VARCHAR':        
                     Filtro_parametros = Filtro_parametros + "<nro_registro type='sql'>dbo.rm_com_parametro_valor (nro_registro,'" + Filtros[i]["com_etiqueta"] + "') like '%" + Filtros[i]["com_valor"] + "%'</nro_registro>"        
                break                          
          }
    }
}

function Aceptar() { 
    if ($('nro_com_grupo').value == "") {
        alert('Debe seleccionar un grupo de comentarios para realizar la búsqueda.')
        return
    }
     
    if ($('btn_parametros').disabled)    
        Filtro_parametros = ''
           
    criterio = '' 

    if ($('id_tipo').value != '')
        criterio += "<id_tipo type='in'>" + $('id_tipo').value + "</id_tipo>"

    if ($('nro_com_id_tipo').value != '')
        criterio += "<nro_com_id_tipo type='in'>" + $('nro_com_id_tipo').value + "</nro_com_id_tipo>"

    if ($('nro_com_grupo').value != '')       
        criterio += "<nro_com_grupo type='in'>" + $('nro_com_grupo').value + "</nro_com_grupo>"
        
    if ($('nro_com_tipo').value != '')     
        criterio += "<nro_com_tipo type='in'>" + $('nro_com_tipo').value + "</nro_com_tipo>"
        
    if ($('nro_com_estados').value != '')
        criterio += "<nro_com_estado type='in'>" + $('nro_com_estados').value + "</nro_com_estado>"
        
    if ($('comentario').value != '')
        criterio += "<comentario type='like'>%" + $('comentario').value + "%</comentario>"
        
    if ($('fecha_desde').value != '')
        criterio += "<fecha type='mas'>'" + $('fecha_desde').value + "'</fecha>"
    else {
        alert('Debe ingresar una fecha desde.')
        return
    }
        
    if ($('fecha_hasta').value != '')
        criterio += "<fecha type='menos'>dateadd(day,1,'" + $('fecha_hasta').value + "')</fecha>"

    if ($('nro_operador').value != "") {
        if (campos_defs.value("nro_com_tipo") == 63 || campos_defs.value("nro_com_tipo") == 62 || campos_defs.value("nro_com_tipo") == "63, 62") {
            criterio += "<operador_comentario type='igual'>" + $('nro_operador').value + "</operador_comentario>"
        }
        else
            criterio += "<operador type='igual'>" + $('nro_operador').value + "</operador>"
    }        
    

    if (criterio == "")
        alert('Ingrese algún filtro para realizar la búsqueda...')    
    else {    
        var filtroXML = nvFW.pageContents.verRegistro
        var report = "report\\comentario\\HTML_verRegistro_lineal.xsl"

        nvFW.exportarReporte({
            filtroXML: filtroXML, 
            filtroWhere: "<criterio><select><orden>fecha</orden><filtro>" + criterio + Filtro_parametros + "</filtro></select></criterio>",
            path_xsl: report,
            formTarget: 'iframe1',
            nvFW_mantener_origen: true,
            bloq_contenedor: $('iframe1'),
            cls_contenedor: 'iframe1',
        })
    }
}

//function VerFiltros(){
//    if ($('div_menu').style.display == 'none') {
//        $('div_menu').show()
//        $('img_filtro').src = 'image/mnuSvr/menos.gif'    
//        }
//    else {
//        $('div_menu').hide()
//        $('img_filtro').src = 'image/mnuSvr/mas.gif'
//    }
//    window_onresize()    
//}


var win_persona
function Persona_mostrar(e, nro_docu, tipo_docu, sexo, documento, apellido, nombres) {
    if (e.ctrlKey == false) {
        var title = documento + ' ' + nro_docu + ' - ' + apellido + ', ' + nombres;
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_persona = w.createWindow({
            className: 'alphacube',
            url: 'persona_mostrar.asp?nro_docu=' + nro_docu + '&tipo_docu=' + tipo_docu + '&sexo=' + sexo + '&modal=1',
            title: '<b>' + title + '</b>',
            minimizable: true,
            maximizable: true,
            draggable: true,
            resizable: false,
            width: 1000,
            height: 500,
            onClose: function() { }
        });

        win_persona.showCenter()
    }
    else {
        $('link_mostrar_persona').href = 'persona_mostrar.asp?nro_docu=' + nro_docu + '&tipo_docu=' + tipo_docu + '&sexo=' + sexo;
    }
}

function Exportar() { 
    if ($('nro_com_grupo').value == "") {
        alert('Debe seleccionar un grupo de comentarios para realizar la búsqueda.')
        return
    }

    if ($('btn_parametros').disabled)
        Filtro_parametros = ''

    criterio = ''

    if ($('id_tipo').value != '')
        criterio += "<id_tipo type='in'>" + $('id_tipo').value + "</id_tipo>"

    if ($('id_tipo').value != '')
        criterio += "<nro_com_id_tipo type='in'>" + $('nro_com_id_tipo').value + "</nro_com_id_tipo>"

    if ($('nro_com_grupo').value != '')
        criterio += "<nro_com_grupo type='in'>" + $('nro_com_grupo').value + "</nro_com_grupo>"

    if ($('nro_com_tipo').value != '')
        criterio += "<nro_com_tipo type='in'>" + $('nro_com_tipo').value + "</nro_com_tipo>"

    if ($('nro_com_estados').value != '')
        criterio += "<nro_com_estado type='in'>" + $('nro_com_estados').value + "</nro_com_estado>"

    if ($('comentario').value != '')
        criterio += "<comentario type='like'>%" + $('comentario').value + "%</comentario>"

    if ($('fecha_desde').value != '')
        criterio += "<fecha type='mas'>'" + $('fecha_desde').value + "'</fecha>"
    else {
        alert('Debe ingresar una fecha desde.')
        return
    }

    if ($('fecha_hasta').value != '') 
        criterio += "<fecha type='menos'>dateadd(day,1,'" + $('fecha_hasta').value + "')</fecha>"
        
    if ($('nro_operador').value != "") {
        criterio += "<operador type='igual'>" + $('nro_operador').value + "</operador>"
    }
    if (nro_docu != 0)
        criterio += "<nro_docu type='igual'>" + nro_docu + "</nro_docu><tipo_docu type='igual'>" + tipo_docu + "</tipo_docu><sexo type='like'>" + sexo + "</sexo>"

    if (criterio == "")
        alert('Ingrese algún filtro para realizar la búsqueda...')    
    else {   
        var filtroXML = nvFW.pageContents.expRegistro

        nvFW.exportarReporte({
            filtroXML: filtroXML,
            filtroWhere: "<criterio><select><orden>fecha</orden><filtro>" + criterio + Filtro_parametros + "</filtro></select></criterio>",
            path_xsl: "report\\EXCEL_base.xsl", 
            salida_tipo: "adjunto", 
            ContentType: "application/vnd.ms-excel", 
            formTarget: "_blank",
            filename: "rpt_comentarios.xls"
        })
    }
}

function show_comentario(nro_reg /*coment*/) {

    var w = nvFW.createWindow({
        url: 'Com_win.aspx?nro_reg=' + nro_reg,
        title: '<b>Comentario</b>',
        minimizable: false,
        maximizable: false,
        draggable: false,
        width: 600,
        height: 325,
        resizable: false
    });
    //w.options.userData = {coment:coment}
    w.showCenter(true)
}

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
<input type="hidden" id="nro_vendedor" name="nro_vendedor" value="" />

<table class="tb1" style="width:100%">
<tr>
<td>

<div id='divFiltro01'>
    <table class="tb1" style="width:100%">
        <tr class="tbLabel">
            <td style="width:15%">Grupo</td>
            <td style="width:30%" colspan="2">Tipo</td>
            <td style="width:15%">Estados</td>
            <td style="width:20%">Fecha Desde</td>
            <td style="width:20%">Fecha Hasta</td>
        </tr>
        <tr>    
            <td style="width:15%">
                <script type="text/javascript">
                    campos_defs.add('nro_com_grupo', { enDB: true, nro_campo_tipo: 2 })
                </script>
            </td>
            <td style="width:20%">
                        <script type="text/javascript">
                            campos_defs.add('nro_com_tipo', { enDB: true, nro_campo_tipo: 2 })
                        </script>
            </td>
            <td style="width: 10%">
                <input style="width: 100%" type="button" id="btn_parametros" name="btn_parametros" value="Parámetros" disabled="disabled" onclick="Ventana_Parametros()" />
            </td>
            <td style="width:15%">
                        <script type="text/javascript">
                            campos_defs.add('nro_com_estados', { enDB: true, nro_campo_tipo: 2 })
                        </script>
            </td>
            <td style="width:20%" id="tdfecha_desde"></td>
            <td style="width:20%" id="tdfecha_hasta"></td>
        </tr>            
    </table>
    <table class="tb1" style="width:100%">
        <tr class="tbLabel">
            <td style="width:20%">Tipo </td>
            <td style="width:40%">Comentario</td>        
            <td style="width:20%">Operador</td>
            <td style="width:20%">Nro Tipo</td>
        </tr>
        <tr>
            <td style="width:20%">
                <script type="text/javascript">
                    campos_defs.add('nro_com_id_tipo', {
                        enDB: false,
                        nro_campo_tipo: 2,
                        filtroXML: nvFW.pageContents.defTipo
                    })
                </script>             
            </td>
            <td style="width:40%"><input type="text" name="comentario" id="comentario" style="width:100%" /></td>
            <td style="width:20%">
                <script type="text/javascript">
                    campos_defs.add('nro_operador', { enDB: true, nro_campo_tipo: 2 })
                </script>             
            </td> 
            <td>
                <input style="width:100%" id="id_tipo" type="text" placeholder="100, 101, 102..."/>
            </td>
        </tr>
    </table>
    </div>
    <div id='divVistas' style="display:none">
    <table style="width:100%">
        <tr>
            <td style="width:46%">
                <table class="tb1">
                    <tr class="tbLabel">
                        <td></td>
                        <td></td>            
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>                
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </div>

</td>
<td>
    <table class="tb1" style="width:100%; height:100%">
        <tr>
            <td style="width:12%"><div id="divBuscar" style="width:100%"/></td>
        </tr>
        <tr>
            <td style="width:12%"><div id="divExportar" style="width:100%"/></td>
        </tr>
    </table>
</td>
</tr>
</table>
<iframe name="iframe1" id="iframe1" style="height:100%;width:100%; max-height:645px; overflow:auto; border:none" src="../enBlanco.htm"></iframe>
</body>
</html>