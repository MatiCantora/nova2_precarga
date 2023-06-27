<%@  language="JScript" %>
<!--#include virtual="fw/scripts/pvUtilesASP.asp"-->

<%
Response.Buffer = true

/****************************************************************/
//Informa el resultado de una operación
//Puede tener tres formas de ingreso
//1) Titulo <> '' = el error viene informado en los campos titulo, descripcion, comentario, numError
//2) error_xml = un xml con la información del error
//3) numError = el id del error dentro del tabla "error_mensajes"
/****************************************************************/
var titulo = obtenerValor('titulo', '')
var mensaje = obtenerValor('mensage', '')
var comentario = obtenerValor('comentario', '')
var debug_src = ''
var debug_desc = ''

var numError = obtenerValor('numError', '-1')
var formato = obtenerValor('formato', 'HTML')
//Se mantiene por compatibilidad "formato" el campo a utilizar es salida_tipo
var salida_tipo = obtenerValor('salida_tipo', 'HTML')
if (salida_tipo == null)
  salida_tipo = formato
var error_xml = obtenerValor('error_xml', '')


var objXML = Server.CreateObject("Microsoft.XMLDOM")
if (objXML.loadXML(error_xml))
  {
  debug_src = objXML.selectSingleNode('error_mensajes/error_mensaje/debug_src').text
  debug_desc = objXML.selectSingleNode('error_mensajes/error_mensaje/debug_desc').text
  }

if (numError != -1 && numError != null)
  {
   var nv_cn_string = Application.Contents('nv_cn_string')   
   nv_config = Server.CreateObject("ADODB.Connection"); 
   try{nv_config.Open(nv_cn_string)}catch(e){}

   error_xml = "<?xml version='1.0' encoding='iso-8859-1'?><error_mensajes><error_mensaje numError='-1'><titulo>Error de Conexión</titulo><mensaje></mensaje><comentario></comentario></error_mensaje></error_mensajes>"
   try{
       var rs = Server.CreateObject("ADODB.Recordset") 
       var strSQL = 'Select * from error_mensajes where numError = ' + numError
       rs.Open(strSQL,nv_config)
       if (!rs.eof)
        {
        titulo = rs.Fields('titulo').value
        mensaje = rs.Fields('mensaje').value
        comentario = rs.Fields('comentario').value 
        error_xml = "<?xml version='1.0' encoding='iso-8859-1'?><error_mensajes><error_mensaje numError='" + numError + "'><titulo>" + titulo + "</titulo><mensaje>" + mensaje + "</mensaje><comentario>" + comentario + "</comentario></error_mensaje></error_mensajes>"
        }
       rs.close()
       nv_config.Close()
       delete nv_config
      }
   catch(e){} 
  }
else
  { 
  if(numError == '-1' && titulo == '' && mensaje == '')
    error_xml = "<?xml version='1.0' encoding='iso-8859-1'?><error_mensajes><error_mensaje numError='-1'><titulo>Error de desconocido</titulo><mensaje></mensaje><comentario>Consulte al administrador de Sistema</comentario></error_mensaje></error_mensajes>"
  if (titulo != '' && error_xml == '')
    error_xml = "<?xml version='1.0' encoding='iso-8859-1'?><error_mensajes><error_mensaje numError='" + numError + "'><titulo>" + titulo + "</titulo><mensaje>" + mensaje + "</mensaje><comentario>" + comentario + "</comentario></error_mensaje></error_mensajes>" 
  else
    if (objXML.loadXML(error_xml)) //Si error_xml es un xml valido, toma esa info.
      {
       numError = objXML.selectSingleNode('error_mensajes/error_mensaje/@numError').nodeValue
       titulo = objXML.selectSingleNode('error_mensajes/error_mensaje/titulo').text
       mensaje = objXML.selectSingleNode('error_mensajes/error_mensaje/mensaje').text
       comentario = objXML.selectSingleNode('error_mensajes/error_mensaje/comentario').text
      }
  }  


switch (salida_tipo.toUpperCase())
  {
  case 'XML':
     Response.Write(error_xml) 
     break
     
  default:
%>
<html>
<head>
      <title>Error Login</title>
 <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
 <link href="../errores_personalizados/css/base.css" type="text/css" rel="stylesheet"/>
 
</head>
<body>
   </br></br>
    <table style="height:140px;width:100%">       <tr>           <td nowrap='nowrap' style="text-align:center; FONT: 15pt/15pt verdana;height:30px">&nbsp;<%= numError + ': ' + titulo%>           <div style="text-align:center; FONT: 8pt/8pt verdana;height:30px" nowrap='nowrap'>&nbsp;<%= mensaje%></div></td>
       </tr>    </table>    <br/>    <table style="width:100%;height:150px">      <tr>       <td style="text-align:center">
          <a>
             <img alt="" src='../errores_personalizados/image/rm_logo_280.jpg'/>
          </a>
       </td>      </tr>    </table>    <br/> <br/>    <table width="100%" style="text-align:center; color:black; font:12pt/12pt tahoma">
         <tr>
              <td style="text-align:center; color:black; font:12pt/12pt tahoma"><%= comentario%></td>
         </tr>
         <tr >
              <td>&nbsp;Email:
                   <a href="http://webmail.redmutual.com.ar/" style="color:blue; font:12pt/12pt tahoma" title="Email: Departamento de Sistemas">sistemas@redmutual.com.ar</a>
              </td>
         </tr>
    </table>
</body>
</html>
<%    
  }
%>
