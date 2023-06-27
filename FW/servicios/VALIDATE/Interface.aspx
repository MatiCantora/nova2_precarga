<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%


%>
<html>
<head>
<title>Validar</title>
<link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
<script type="text/javascript" src="/fw/script/nvFW.js"></script>
<script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
<script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
<script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>


<script type="text/javascript">
    
    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 290, height: 90, okLabel: "cerrar" }); }

var vButtonItems = {}

    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] =  "Obtener";
    vButtonItems[0]["etiqueta"] ="obtener Codigo por SMS";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return enviarSms()";

    vButtonItems[1] = {}
    vButtonItems[1]["nombre"]  = "Validar";
    vButtonItems[1]["etiqueta"]= "Validar codigo";
    vButtonItems[1]["imagen"] = "guardar";
    vButtonItems[1]["onclick"] = "return Validar()";
    

    vButtonItems[2] = {}
    vButtonItems[2]["nombre"]  = "Mail";
    vButtonItems[2]["etiqueta"]= "Enviar Mail";
    vButtonItems[2]["imagen"] = "buscar";
    vButtonItems[2]["onclick"] = "return EnviarMail()";
  
    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')
    vListButtons.loadImage("guardar", '/FW/image/icons/guardar.png')

var mode=''  //produccion
function window_onload() {

        vListButtons.MostrarListButton()   
        window_onresize()
}


function window_onresize()
{

/*var dif = Prototype.Browser.IE ? 5 : 2
var body_h = $$('body')[0].getHeight()
var tblcab = $('tblcab').getHeight()
var tblpie = $('tblpie').getHeight()
var tblPreguntas = $('tblPreguntas').getHeight()
var tblResultado = $('tblResultado').getHeight()


      $('tblPreguntas').setStyle({ 'height': body_h - tblcab - tblpie - tblResultado - dif + 'px' });*/

}


function dni_onkeypress(e) 
{
 var key = Prototype.Browser.IE ? e.keyCode : e.which; 
 
  return valDigito(e)
}


function enviarSms()
{



var texto=$("texto").value
var telefono=$("telefono").value
var cuit=$("cuit").value
var xmlvalidar="<validate mode='" + mode + "'>"
    
xmlvalidar+="<item type='sms' identificador='"+telefono+"' cuit='" + cuit + "' ><texto> <![CDATA[" + texto + "]]></texto></item>"
        

        xmlvalidar += "</validate>"

        if(texto.length > 160)
        {
          alert("El texto no puede superar los 160 caracteres")
          return
        }

    if(telefono=='' || cuit=='')
    {
        alert("falta completar un dato")
        return
    }

     nvFW.bloqueo_activar($$("BODY")[0], "bloq")

     var oXML = new tXML();
     oXML.async = true

     var existe
     oXML.load('/fw/servicios/VALIDATE/SEND.aspx', 'criterio=<criterio>' + xmlvalidar + '</criterio>', function ()
     {
         
             nvFW.bloqueo_desactivar($$("BODY")[0], "bloq")

              var err = new tError()
              err.error_from_xml(oXML)

         
              if (err.numError == 0) {

                  

                  var parser = new DOMParser();
                  var xmlresponse = parser.parseFromString(err.params['xmlresponse'], "text/xml");                  
                  var x = xmlresponse.getElementsByTagName("item")
                  var huboErroneos = false
        
                  for (i = 0; i < x.length; i++) {

                      var token = x.item(i).attributes.getNamedItem("token").value
                      var estado = x.item(i).attributes.getNamedItem("estado").value
                      var detalle = x.item(i).getElementsByTagName("detalle")[0].childNodes[0].nodeValue
                      
                      $("token").value=token  

                      if(estado!="enviado")
                      {
                        alert("No se ha podido enviar el sms: " + detalle)
                        huboErroneos=true
                      }
                  }
                  if(!huboErroneos)
                  {
                    alert("Ingrese el codigo que enviamos al telefono")
                  }

                  
                  

              } else {
                  alert("error al consultar en el servicio: " + err.mensaje)
                  console.log("error al consultar en el servicio: " + err.mensaje)
              }
               
      });


 }



function EnviarMail()
{


var texto= ($("textomail").value).trim()
var mail=$("email").value
var cuit=$("cuit1").value
var xmlvalidar="<validate  mode='" + mode + "'>"
    
xmlvalidar+="<item type='mail' identificador='"+mail+"' cuit='" + cuit + "' ><texto> <![CDATA[" + texto + "]]></texto></item>"
        

        xmlvalidar += "</validate>"

       

    if(cuit=='' || mail=='')
    {
        alert("falta completar un dato")
        return
    }

     nvFW.bloqueo_activar($$("BODY")[0], "bloq")

     var oXML = new tXML();
     oXML.async = true

     var existe
     oXML.load('/fw/servicios/VALIDATE/SEND.aspx', 'criterio=<criterio>' + xmlvalidar + '</criterio>', function ()
     {
         
             nvFW.bloqueo_desactivar($$("BODY")[0], "bloq")

              var err = new tError()
              err.error_from_xml(oXML)

         
              if (err.numError == 0) {

                  

                  var parser = new DOMParser();
                  var xmlresponse = parser.parseFromString(err.params['xmlresponse'], "text/xml");                  
                  var x = xmlresponse.getElementsByTagName("item")
                  var huboErroneos=false
                  for (i = 0; i < x.length; i++) {

                      var token = x.item(i).attributes.getNamedItem("token").value
                      var estado = x.item(i).attributes.getNamedItem("estado").value
                      var detalle = x.item(i).getElementsByTagName("detalle")[0].childNodes[0].nodeValue
                      
                      $("token").value=token  

                      if(estado!="enviado")
                      {
                        alert("No se ha podido enviar el mail: " + detalle)
                        huboErroneos=true
                      }
                  }
                  if(!huboErroneos)
                  {
                    alert("Ingrese el codigo que enviamos a su mail")
                  }

                  
                  

              } else {
                  alert("error al consultar en el servicio: " + err.mensaje)
                  console.log("error al consultar en el servicio: " + err.mensaje)
              }
               
      });

}

 function Validar()
 {
  
        
        var xmlvalidar="<validate>"
        
        
            var codigo=$("codigo").value
            var token=$("token").value
            xmlvalidar+="<item validador='"+codigo+"' token ='" + token + "'></item>"
        

        xmlvalidar += "</validate>"

       nvFW.bloqueo_activar($$("BODY")[0], "bloq")

        var oXML = new tXML();
        oXML.async = true

        
        oXML.load('/fw/servicios/VALIDATE/VALIDATE.aspx', 'criterio=<criterio>' + xmlvalidar + '</criterio>', function () {

                nvFW.bloqueo_desactivar($$("BODY")[0], "bloq")
                
                var err = new tError()
                    err.error_from_xml(oXML)
                    if (err.numError == 0) {

                          var parser = new DOMParser();
                          var xmlreponse = parser.parseFromString(err.params['xmlresponse'], "text/xml");
                          $("resultado").value = err.params['xmlresponse']
                          var x = xmlreponse.getElementsByTagName("item")

                          for (i = 0; i < x.length; i++) {
                            var token = x.item(i).attributes.getNamedItem("token").value
                            var validacion =x.item(i).attributes.getNamedItem("validacion").value
                            alert("VALIDACION  :" + validacion)
                          }
                    }
                    else {
                        alert("error al consultar en el servicio")
                        console.log("error al consultar en el servicio: " + err.descError)
                    }
                
            });
  

 } //validar

   

    </script>

</head>
<body onload="return window_onload()" style="width:100%;height:100%; overflow:auto" onresize="window_onresize()">
  
  

  <div id="divMenuSMS"></div>
    <script type="text/javascript">
        var vMenuSMS = new tMenu('divMenuSMS', 'vMenuSMS');
        Menus["vMenuSMS"] = vMenuSMS
        Menus["vMenuSMS"].alineacion = 'centro';
        Menus["vMenuSMS"].estilo = 'A';

        vMenuSMS.loadImage("filtro", "/FW/image/transferencia/filtro.png");

        Menus["vMenuSMS"].CargarMenuItemXML('<MenuItem id="0" style="width: 100%"><Lib TipoLib="offLine">DocMNG</Lib><icono></icono><Desc>Validacion por SMS</Desc></MenuItem>')
        
        vMenuSMS.MostrarMenu()
    </script>
  <table class="tb1" style="width:100%" id="tblcab">
    <tr class="tbLabel">      
      <td style="width:20%">cuit*</td>      
      <td style="width:20%">Numero Telefono*</td>      
      <td style="width:50%">Texto Sms</td>      
      <td style="width:10%">&nbsp;</td>
    </tr>
    <tr>            
      <td><input type="text" name="cuit" id="cuit" style="WIDTH: 100%" value="" maxlength="11"  onkeypress="return dni_onkeypress(event)"/></td>
       <td><input type="text" name="telefono" id="telefono" style="WIDTH: 100%" value="" maxlength="10"  onkeypress="return dni_onkeypress(event)"/></td>
      <td><input type="text" name="texto" id="texto" style="WIDTH: 100%" value="" maxlength="160" />            
      <td><div id="divObtener"></div></td>

    </tr>
  </table>

<table class="tb1" id="tblpie" cellspacing="0" cellpadding="0">
<tr class="tbLabel_O"><td style="TEXT-ALIGN: left !Important">(*) Campos obligatorios</td></tr>
</table>

<div id="divMenuMail"></div>
    <script type="text/javascript">
        var vMenuMail = new tMenu('divMenuMail', 'vMenuMail');
        Menus["vMenuMail"] = vMenuMail
        Menus["vMenuMail"].alineacion = 'centro';
        Menus["vMenuMail"].estilo = 'A';

        vMenuMail.loadImage("filtro", "/FW/image/transferencia/filtro.png");

        Menus["vMenuMail"].CargarMenuItemXML('<MenuItem id="0" style="width: 100%"><Lib TipoLib="offLine">DocMNG</Lib><icono></icono><Desc>Validacion por mail</Desc></MenuItem>')        
        vMenuMail.MostrarMenu()
    </script>

<table class="tb1" style="width:100%" id="tblcab">
    <tr class="tbLabel">      
      <td style="width:20%">cuit*</td>      
      <td style="width:20%">Mail*</td>      
      <td style="width:50%">Texto Mail</td>      
      <td style="width:10%">&nbsp;</td>
    </tr>
    <tr>            
      <td><input type="text" name="cuit1" id="cuit1" style="WIDTH: 100%" value="" maxlength="11"  onkeypress="return dni_onkeypress(event)"/></td>
       <td><input type="text" name="email" id="email" style="WIDTH: 100%" value="" /></td>
      <td><textarea  name="textomail" id="textomail" style="WIDTH: 100%" >            
          </textarea>
      <td><div id="divMail"></div></td>

    </tr>
  </table>


<div id="divMenuValidacion"></div>
    <script type="text/javascript">
        var vMenuValidacion = new tMenu('divMenuValidacion', 'vMenuValidacion');
        Menus["vMenuValidacion"] = vMenuValidacion
        Menus["vMenuValidacion"].alineacion = 'centro';
        Menus["vMenuValidacion"].estilo = 'A';

        vMenuValidacion.loadImage("filtro", "/FW/image/transferencia/filtro.png");

        Menus["vMenuValidacion"].CargarMenuItemXML('<MenuItem id="0" style="width: 100%"><Lib TipoLib="offLine">DocMNG</Lib><icono></icono><Desc>Validacion </Desc></MenuItem>')        
        vMenuValidacion.MostrarMenu()
    </script>
  <div style="width:100%;overflow: auto"  >
  <table class="tb1" style="width:100%" >
    <thead>
    <tr class="tbLabel">      
      <th style="width:50%">Ingrese codigo</th>
      <th style="width:50%">Resultado</th>            
    </tr>    
    </thead>
    <tbody> 
      <td  style="text-align:center">
        <input type="hidden" name="token" id="token" value=""  />       
        <input type="text" name="codigo" id="codigo"  onkeypress="return dni_onkeypress(event)" value="" />       
      </td>
      <td style="text-align:center"> <textarea id="resultado" style="width:100%"> </textarea></td>    
    </tbody>
  </table>
</div>
<table class="tb1" style="width:100%;" id="tblBtnrespuestas">
    <tr>
        <td style="width:80%"><div id="divValidar"></div></td>
    </tr>
</table>

</body>
</html>
