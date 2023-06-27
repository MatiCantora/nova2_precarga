<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")
    Dim valor As String = nvFW.nvUtiles.obtenerValor("valor")
    Dim parametro As String = nvFW.nvUtiles.obtenerValor("parametro", "")
    Dim strvalor_ant As String = nvFW.nvUtiles.obtenerValor("strvalor_ant", "")
    Dim strvalor As String = nvFW.nvUtiles.obtenerValor("strvalor", "")


    If modo = "M" Then

        Dim err As New nvFW.tError
        Try
            Dim strxml As String = nvFW.nvUtiles.obtenerValor("strxml", "")
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_credito_parametro_cambiar", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@strxml", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strxml.Length, strxml)

            Dim rs As ADODB.Recordset = cmd.Execute()
            nro_credito = rs.Fields("nro_credito").Value
            Dim numError As Integer = rs.Fields("numError").Value
            Dim mensaje As String = rs.Fields("mensaje").Value

            err.numError = numError
            If (err.numError) Then
                err.titulo = "Error Proceso"
            End If
            err.mensaje = mensaje


        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If


    Me.contents.Add("parametros", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_Parametros_mostrar_2'><campos>tipo_dato,parametro,parametro_valor,etiqueta,campo_def</campos><orden></orden><filtro><nro_credito type='igual'>%nro_credito%</nro_credito><parametro type='igual'>'id_gestion_firma_documental'</parametro></filtro></select></criterio>"))



%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html  xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="viewport" content="width=device-width, minimum-scale=1, initial-scale=1, shrink-to-fit=no">
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico" />
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language='javascript' src="script/precarga.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript" language="javascript" class="table_window">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

var vButtonItems = new Array()

vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Actualizar";
vButtonItems[0]["etiqueta"] = "Actualizar Parámetro";
vButtonItems[0]["imagen"] = "";
vButtonItems[0]["onclick"] = "return Actualizar()";

var vListButtons = new tListButton(vButtonItems, 'vListButtons')
//vListButtons.imagenes = Imagenes

var win = nvFW.getMyWindow()

var fecha_hoy
var valor
var nro_credito = ''
var parametro = ''
var huboCambio=false;
      
var tipo_dato
var valorparam
var strvalor
var escampo_def
var strvalor_ant
var strparametro

function window_onload() 
{
// mostramos los botones creados
vListButtons.MostrarListButton()
var param = new Array()
param = win.options.userData.param
nro_credito = param['nro_credito']
parametro = param['parametro']
$('nro_credito').value = nro_credito
$('parametro').value = parametro
Cargar_Parametro(nro_credito, parametro)


}

var valor_ant = ''

function Cargar_Parametro(nro_credito, parametro)
{
var tipo_dato=''
var ValorParam=''
$('divParametros').innerHTML = '' 
    var defs = new Array()
    var rs = new tRS();
    
   //rs.open("<criterio><select vista='verCredito_Parametros_mostrar_2'><campos>tipo_dato,parametro,parametro_valor,etiqueta,campo_def</campos><orden></orden><grupo></grupo><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito><parametro type='igual'>'" + parametro + "'</parametro></filtro></select></criterio>")  
    //rs.open({ filtroXML: nvFW.pageContents["parametros"], params: "<criterio><params nro_credito='" + nro_credito + "' parametro='" + parametro + "' /></criterio>" })
    rs.open({ filtroXML: nvFW.pageContents["parametros"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
    {
    if (!rs.eof())
        {
        $('tipo_dato').value = rs.getdata('tipo_dato')
        var str = ""
        str = "<table class='tb1'><tr class='tbLabel'><td style='width:40%'>Parámetro</td><td style='width:60%'>Valor</td></tr>"   
        valor = rs.getdata('parametro_valor')
        valor_ant = rs.getdata('parametro_valor')
        $('strparametro').value = rs.getdata('etiqueta')        
        $('escampo_def').value = rs.getdata('campo_def')      
        str += "<tr><td style='vertical-align: left'>" + rs.getdata('etiqueta') + "</td><td id='def_param_" + parametro + "'>"
        if (rs.getdata('campo_def') == null) 
            {tipo_dato=rs.getdata('tipo_dato').toLowerCase()
                switch(tipo_dato)
                {
                case 'int':
                    str += "<input type='text' style='width:100%;text-align:right' onkeypress='return valDigito(event)' id='" + parametro + "' name='" + parametro + "' value='" + valor + "'/>"
                    $('strvalor_ant').value=valor
                break
                case 'money':
                    if (valor == '')
                        valor = 0
                    str += "<input type='text' style='width:100%;text-align:right' onkeypress='return valDigito(event,\".\")' id='" + parametro + "' name='" + parametro + "' value='" + parseFloat(valor).toFixed(2) + "'/>"
                    $('strvalor_ant').value=valor                    
                break                            
                case 'datetime':
                if (valor != '')
                    {
                     
                        ValorParam=valor
                    }
                     $('strvalor_ant').value=valor
                    str+="<div id='divFecha'></div>"
                    // str += "<input type='text' style='width:100%' onchange='valFechaVBS()' onkeypress='return valDigito(event,\"/\")' id='" + parametro + "' name='" + parametro + "' value='" + valor + "'/>"
                break
                case 'bit':
                    Checked = ''
                    if (valor == 'true')
                        {Checked = 'checked'   
                        $('strvalor_ant').value='Si'
                        }else
                        {
                        $('strvalor_ant').value='No'
                        }
                    str += "<input type='checkbox' style='width:100%' id='" + parametro + "' name='" + parametro + "' " + Checked + "/>"               
                break                                 
                default:
                    str += "<input type='text' style='width:100%' id='" + parametro + "' name='" + parametro + "' value='" + valor + "' />"
                    $('strvalor_ant').value = valor                                                 
                break     
                
                
            }                              
        }              
        
        str += "</td></tr></table>"
        
        $('divParametros').insertAdjacentHTML("afterbegin", str)  

        if (rs.getdata('campo_def') != null)
            {
            defs[defs.length] = new Array()
            defs[defs.length-1]['campo_def']= rs.getdata('campo_def')
            defs[defs.length-1]['parametro']= rs.getdata('parametro')
            defs[defs.length-1]['valor']= valor
            }  

        for (i=0;i< defs.length;i++)        
          {
          var txt_id="def_param_" + defs[i]['parametro'];                    
           campos_defs.add(defs[i]['campo_def'], {target: txt_id})
          //get_html_input(defs[i]['campo_def'], target)
          nombre = defs[i]['parametro']
          if (defs[i]['valor'] != '')
            campos_defs.set_value(nombre,defs[i]['valor'])
            $('strvalor_ant').value = campos_defs.desc(nombre)               
          }
                               
        }

    } 
 
   if(($('escampo_def').value=='null' || $('escampo_def').value=='') && tipo_dato=='datetime' )    
   {
   armarCampoFecha(parametro,ValorParam)
   }
}




function armarCampoFecha(nombre,valor)
{
campos_defs.add(nombre, {enDB: false,target: 'divFecha',nro_campo_tipo: 103})
campos_defs.set_value(nombre,valor)
}


function Actualizar(){ 

var mensaje = ''

objeto=$(parametro)
if(objeto.value == valor_ant)
{
    mensaje = 'Debe cambiar el Valor del Parametro'
}

if (objeto.value == '') {
    mensaje = 'Debe ingresar una opcion válida'
}


if (mensaje != '')
    {
    alert(mensaje)
    return
    }  

$('strvalor').value = campos_defs.desc(parametro)
valor=objeto.value



 var strxml=""
 strxml += "<detalle parametro = '" + parametro + "' nro_credito='"+nro_credito+"' valor='" + valor + "' strvalor='" + $('strvalor').value + "' strvalor_ant='" + $('strvalor_ant').value + "' ></detalle>";


    
nvFW.error_ajax_request('Credito_Parametro_cambiar.aspx', {
    encoding: 'ISO-8859-1',
    parameters: { modo: 'M', strxml: strxml },
               onSuccess: function (err, transport) {
                   
                   if (err.numError == 0) {
                        
                           res = true                                                   
                           var win = nvFW.getMyWindow()
                           win.options.userData = { res: res }
                           win.close()                              
                       }
                  else alert('No se pudo guardar el parametro')  
               }
           }); 


}




</script>
</head>
<body onload="return window_onload()">
<xml name="mnuXML" id="mnuXML"></xml>
<xml name="XML1" id="XML1"></xml>

<input type="hidden" id="modo" name="modo" value="<%= modo %>"/>
<input type="hidden" id="nro_credito" name="nro_credito" value="<%= nro_credito %>" />
<input type="hidden" id="parametro" name="parametro" />
<input type="hidden" id="tipo_dato" name="tipo_dato" />
<input type="hidden" id="strparametro" name="strparametro" />
<input type="hidden" id="strvalor_ant" name="strvalor_ant" />
<input type="hidden" id="strvalor" name="strvalor" />
<input type="hidden" id="escampo_def" name="escampo_def" value="" />

<div id="divMenuParametros"></div>
<script type="text/javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuParametros = new tMenu('divMenuParametros','vMenuParametros',mnuXML);
     Menus["vMenuParametros"] = vMenuParametros
     Menus["vMenuParametros"].alineacion = 'centro';
     Menus["vMenuParametros"].estilo = 'A';
     vMenuParametros.loadImage("menos", "/FW/image/icons/menos.gif");
     Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 14px'><Lib TipoLib='offLine'>DocMNG</Lib><icono>menos</icono><Desc></Desc></MenuItem>")
     Menus["vMenuParametros"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")  
     vMenuParametros.MostrarMenu()
</script>
<table class="tbFondo" cellspacing="0" cellpadding="0" style="width:100%">
   <tr>
        <td style="width: 15px">&nbsp;</td>
        <td>
                <div id="divParametros"></div>
                <table style="width:100%"><tr><td><div id="divActualizar"></div></td></tr></table>
        </td>
    </tr>
</table>
<table class="tb1" style="width:100%" cellspacing="0" cellpadding="0"><tr><td style='text-align:center'><b>Debe Asignar un valor al parametro para continuar.</b></td></tr></table>

<iframe name="frmEnviar" style="DISPLAY: none" src="enBlanco.htm"></iframe>    

</body>
</html>
