<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%@  language="JScript" %>
<%
    Response.Expires = 0
%>
<html>
<head>
<title>Filtro Parámetros de comentarios</title>

    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    
    <script type="text/javascript" language="javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var vButtonItems = new Array()

vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Aceptar";
vButtonItems[0]["etiqueta"] = "Aceptar";
vButtonItems[0]["imagen"] = "guardar";
vButtonItems[0]["onclick"] = "return Aceptar()";


var vListButtons = new tListButton(vButtonItems, 'vListButtons')
vListButtons.imagenes = Imagenes                                                // "Imagenes" está definida en "pvUtiles.asp"

var nro_com_tipos = ''

var Filtros = new Array()

function window_onload() 
{
    // mostramos los botones creados
    vListButtons.MostrarListButton()
    var win = nvFW.getMyWindow()
    Filtros = win.options.userData.Filtros
    nro_com_tipos = Filtros['nro_com_tipos']
    Cargar_Filtros(nro_com_tipos)
}

function Cargar_Filtros(nro_com_tipos)
{
    var com_tipo = ''
    var valor_input_0 = ''
    var valor_input_1 = ''
    var valor_input_2 = ''    
    $('divFiltros').innerHTML = ""
    var strHTML = "<table class='tb1'>" 
    var filtroWhere = "<nro_com_tipo type='in'>" + nro_com_tipos + "</nro_com_tipo><esfiltro type='igual'>1</esfiltro>"
    var rs = new tRS(); 
    rs.open("<criterio><select vista='com_parametro_tipo'><campos>nro_com_parametro, nro_com_tipo, com_tipo, com_etiqueta, com_parametro, tipo_dato, por_rango</campos><filtro>" + filtroWhere + "</filtro><orden>com_tipo</orden></select></criterio>")
    while (!rs.eof()){         
           if (rs.getdata('com_tipo') != com_tipo)
                strHTML = strHTML + "<tr class='tbLabel0' style='width:100%'><td colspan='2' style='width:100%' nowrap='true' class='Tit1'>" + rs.getdata('com_tipo') + "</td></tr>"             
           
           var valor_input_0 = ''
           var valor_input_1 = ''
           var valor_input_2 = ''
                
           for (i in Filtros){
                if (Filtros[i]["nro_com_tipo"] == rs.getdata('nro_com_tipo') && Filtros[i]["com_etiqueta"] == rs.getdata('com_etiqueta') && Filtros[i]["tipo_dato"] == rs.getdata('tipo_dato') && Filtros[i]["por_rango"] == rs.getdata('por_rango')){ 
                     switch(Filtros[i]["orden"]){
                        case '0':
                            valor_input_0 = Filtros[i]["com_valor"]
                        break    
                        case '1':
                            valor_input_1 = Filtros[i]["com_valor"]
                        break                            
                        case '2':
                            valor_input_2 = Filtros[i]["com_valor"]                            
                        break                            
                        }
                }
           }               
                                    
           strHTML = strHTML + "<tr><td style='width:30%' nowrap='true' class='Tit1'>" + rs.getdata('com_etiqueta') + "</td>"        
           switch(rs.getdata('tipo_dato')){
            case 'int':
                strHTML = strHTML + "<td align='center'>"
                if (rs.getdata('por_rango'))
                    strHTML = strHTML + "desde <input type='text' onkeypress='return valDigito(event)' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",1," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_1 + "'  style='width: 40%'/>  hasta  <input type='text' onkeypress='return valDigito(event)' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",2," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_2 + "'  style='width: 40%'/>"
                else
                    strHTML = strHTML + "<input type='text' onkeypress='return valDigito(event)' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",0," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_0 + "'  style='width: 100%'/>"
                strHTML = strHTML + "</td></tr>"                  
            break
            case 'money':
                strHTML = strHTML + "<td align='center'>"
                if (rs.getdata('por_rango'))
                    strHTML = strHTML + "desde <input type='text' onkeypress='return valDigito(event)' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",1," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_1 + "'  style='width: 40%'/>  hasta  <input type='text' onkeypress='return valDigito(event)' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",2," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_2 + "'  style='width: 40%'/>"
                else
                    strHTML = strHTML + "<input type='text' onkeypress='return valDigito(event)' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",0," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_0 + "'  style='width: 100%'/>"                    
                strHTML = strHTML + "</td></tr>"                  
            break
            case 'datetime':
                strHTML = strHTML + "<td align='center'>"
                if (rs.getdata('por_rango'))
                    strHTML = strHTML + 'desde <input type="text" onkeypress="return valDigito(event, \'/\')" onchange="valFecha(event)" name="' + rs.getdata('com_etiqueta') + ',' + rs.getdata('tipo_dato') + ',' + rs.getdata('por_rango') + ',1,' + rs.getdata('nro_com_tipo') + '" value="' + valor_input_1 + '"  style="width: 40%"/> hasta <input type="text"  onkeypress="return valDigito(event, \'/\')" onchange="valFecha(event)" name="' + rs.getdata('com_etiqueta') + ',' + rs.getdata('tipo_dato') + ',' + rs.getdata('por_rango') + ',2,' + rs.getdata('nro_com_tipo') + '" value="' + valor_input_2 + '"  style="width: 40%"/>'
                else
                    strHTML = strHTML + '<input type="text"  onkeypress="return valDigito(event, \'/\')" onchange="valFecha(event)" name="' + rs.getdata('com_etiqueta') + ',' + rs.getdata('tipo_dato') + ',' + rs.getdata('por_rango') + ',0,' + rs.getdata('nro_com_tipo') + '" value="' + valor_input_0 + '"  style="width: 100%"/>'
                strHTML = strHTML + "</td></tr>"                  
            break
            case 'varchar':
                strHTML = strHTML + "<td align='center'><input type='text' name='" + rs.getdata('com_etiqueta') +"," + rs.getdata('tipo_dato') +"," + rs.getdata('por_rango') +",0," + rs.getdata('nro_com_tipo') +"' value='" + valor_input_0 + "'  style='width: 100%'/></td></tr>"                  
            break      
           }                
            com_tipo = rs.getdata('com_tipo')                   
            rs.movenext()
    }
    strHTML = strHTML + "</table>"          
    $('divFiltros').insert({top: strHTML })
    rs.close        
}

function Aceptar(){
    x = 1
    Filtros.length = 0
    Filtros['nro_com_tipos'] = nro_com_tipos
    for(i=0; ele=$('frmFiltros').elements[i]; i++){
	    if (ele.type == 'text')
	            if (ele.value != '')
	                {  
	                Filtros[x] = new Array();
	                datos = ele.name.split(',')  
	                Filtros[x]['com_etiqueta'] = datos[0]
	                Filtros[x]['tipo_dato'] = datos[1]
	                Filtros[x]['por_rango'] = datos[2]
	                Filtros[x]['orden'] = datos[3]
	                Filtros[x]['com_valor'] = ele.value
	                Filtros[x]['nro_com_tipo'] = datos[4]	                
	                x++
                }
    }
    var win = nvFW.getMyWindow()
    win.options.userData = { res: Filtros }
    win.close()	    
}

function window_onunload() {
    var win = nvFW.getMyWindow()
    win.close()
}

</script>
</head>
<body onload="return window_onload()" onunload="return window_onunload()">
<form name="frmFiltros" action="com_seleccion_parametros.asp">
<table width="100%">
    <tr>
        <td><div id="divFiltros" style="width:100%"></div></td>
    </tr>
    <tr>
        <td><div id="divAceptar" style="width:100%"/></td>
    </tr>
</table>
</form>
</body>
</html>