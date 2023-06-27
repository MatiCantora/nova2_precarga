<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%


%>
<html>
<head>
<title>Veraz</title>
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
    vButtonItems[0]["etiqueta"] ="Obtener preguntas";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return obtenerPreguntas()";

    vButtonItems[1] = {}
    vButtonItems[1]["nombre"]  = "Validar";
    vButtonItems[1]["etiqueta"]= "Validar persona";
    vButtonItems[1]["imagen"] = "guardar";
    vButtonItems[1]["onclick"] = "return Validar()";
    
  
    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')
    vListButtons.loadImage("guardar", '/FW/image/icons/guardar.png')


function window_onload() {

        vListButtons.MostrarListButton()   
        window_onresize()
}


function window_onresize()
{

var dif = Prototype.Browser.IE ? 5 : 2
var body_h = $$('body')[0].getHeight()
var tblcab = $('tblcab').getHeight()
var tblpie = $('tblpie').getHeight()
var tblPreguntas = $('tblPreguntas').getHeight()
var tblResultado = $('tblResultado').getHeight()


      $('tblPreguntas').setStyle({ 'height': body_h - tblcab - tblpie - tblResultado - dif + 'px' });

}


function dni_onkeypress(e) 
{
 var key = Prototype.Browser.IE ? e.keyCode : e.which; 
 
  return valDigito(e)
}


function obtenerPreguntas()
{


$('score').innerHTML = ""
$('resultado').innerHTML = ""
$('valor').innerHTML = ""
var nro_docu=$("nro_docu").value
var sexo=$("sexo").value
var apellido=$("apellido").value
var nombres=$("nombres").value
$("tblBtnrespuestas").show()
$("tblPreguntas").show()
$("tblResultado").hide()

$$("#tblPreguntas tbody > tr").each(function(e){
    e.remove()
})

    if(nro_docu=='' || sexo=='' || apellido=='' || nombres=='')
    {
        alert("falta completar un dato")
        return
    }

     nvFW.bloqueo_activar($$("BODY")[0], "bloq")

     var oXML = new tXML();
     oXML.async = true

     var existe
     oXML.load('/fw/servicios/veraz/GetXML.aspx', 'accion=obtener_preguntas&criterio=<criterio><apellido>' + apellido + '</apellido><nombres>'+ nombres +'</nombres><nro_docu>' + nro_docu + '</nro_docu><sexo>' + sexo + '</sexo></criterio>', function ()
     {
         
             nvFW.bloqueo_desactivar($$("BODY")[0], "bloq")

              var err = new tError()
              err.error_from_xml(oXML)

         
              if (err.numError == 0) {

                  var htmlrow = ""

                  var parser = new DOMParser();

                  var xmlpreguntas = parser.parseFromString(err.params['xmlpreguntas'], "text/xml");
                  $("lote").value = err.params["lote"]
                  var x = xmlpreguntas.getElementsByTagName("pregunta")

                  for (i = 0; i < x.length; i++) {

                      var questionID = x.item(i).attributes.getNamedItem("questionID").value
                      var orden = x.item(i).attributes.getNamedItem("orden").value
                      var texto = x.item(i).getElementsByTagName("text")[0].innerHTML
                      htmlrow += "<tr><td><input type='hidden' id='question-" + questionID + "' value='" + questionID + "'> " + texto + "</td>"
                      htmlrow += "<td><table class='tb1'>"
                      var opciones = x.item(i).getElementsByTagName("opcion")
                      for (o = 0; o < opciones.length; o++) {

                          var optionId = opciones.item(o).attributes.getNamedItem("optionId").value
                          var optiontext = opciones.item(o).innerHTML
                          htmlrow += "<tr><td><label for='opt-" + questionID + "-" + optionId + "'>" + optiontext + " </label><input type='radio' id='opt-" + questionID + "-" + optionId + "'  name='options-" + questionID + "' value='" + optionId + "' /></td></tr>"
                      }

                      htmlrow += "</table></td></tr>"

                  }

                  $("tblPreguntas").down("tbody").insert(htmlrow)
                  window_onresize()

              } else {
                  alert("error al consultar en el servicio: " + err.mensaje)
                  console.log("error al consultar en el servicio: " + err.mensaje)
              }
               
      });


 }

 function Validar()
 {
  
        $('score').innerHTML = ""
        $('resultado').innerHTML = ""
        $('valor').innerHTML = ""
        $('autorizacion').innerHTML=""
        $('estado').innerHTML =""
        $("tblResultado").show()
        var xmlrespuestas="<respuesta>"
        var respondioTodos=true;
        $$("input[id*=question-]").each(function(e)
        {
            try {
            var questionID=(e.id).replace("question-","")
            var answerID=$$('input:checked[type=radio][name=options-'+questionID+']')[0].value;
            }
            catch(error) {
              console.error(error);     
              respondioTodos=false;
                return
            }    
    
            xmlrespuestas+="<opcion questionID='"+questionID+"' answerID='"+answerID+"'></opcion>"
        })

        if(!respondioTodos)
        {
            alert("Debe responder todas las preguntas")
            return
        }

        xmlrespuestas += "</respuesta>"

       nvFW.bloqueo_activar($$("BODY")[0], "bloq")

        var oXML = new tXML();
        oXML.async = true

        var existe
        oXML.load('/fw/servicios/veraz/GetXML.aspx', 'accion=validar&criterio=<criterio><lote>' + $("lote").value + '</lote><xmlrespuestas>' + xmlrespuestas + '</xmlrespuestas></criterio>', function () {

                nvFW.bloqueo_desactivar($$("BODY")[0], "bloq")

                var err = new tError()
                err.error_from_xml(oXML)
                var htmlrow = ""

                if (err.numError == 0) {

                    var htmlrow = ""
                    if (err.numError == 0) {

                        $('autorizacion').innerHTML = (err.params['autorizacion'] == 'True') ? "Consulta Autorizada" : "Consulta no autorizada"
                        $('score').innerHTML = err.params['score'];
                        $('resultado').innerHTML = err.params['resultado'];
                        $('valor').innerHTML = err.params['valor'];
                        $('estado').innerHTML = (err.params['estado'] == 1) ? "VALIDADO" : "NO VALIDADO" //este dato indica si la validacion de la persona es correcta o no

                        $("tblBtnrespuestas").hide()
                        $("tblPreguntas").hide()
                        $("tblResultado").show()
                        $$("#tblPreguntas tbody > tr").each(function (e) {
                            e.remove()
                        })
                    }
                    else {
                        alert("error al consultar en el servicio")
                        console.log("error al consultar en el servicio: " + err.descError)
                    }
                }
            });
  

 } //validar

   

    </script>

</head>
<body onload="return window_onload()" style="width:100%;height:100%; overflow:auto" onresize="window_onresize()">
  
  <input type="hidden" id="lote" value="">
  <table class="tb1" style="width:100%" id="tblcab">
    <tr class="tbLabel">      
      <td style="width:20%">Documento*</td>
      <td style="width:10%">Sexo*</td>
      <td style="width:20%">Apellido*</td>
      <td style="width:30%">Nombres*</td>
      <td style="width:10%">&nbsp;</td>
    </tr>
    <tr>            
       <td><input type="text" name="nro_docu" id="nro_docu" style="WIDTH: 100%" value="" maxlength="8"  onkeypress="return dni_onkeypress(event)"/></td>
      <td><select name="sexo" id="sexo" style="WIDTH: 100%">
            <option value="M" >MASC</option>
            <option value="F" >FEM</option>            
          </select>
      </td>
      <td><input type="text" name="apellido" id="apellido" style="WIDTH: 100%" value="" /></td>
      <td><input type="text" name="nombres" id="nombres" style="WIDTH: 100%" value="" /></td>
      <td><div id="divObtener"></div></td>

    </tr>
  </table>
<div id="tblPreguntas" style="width:100%;display: none;overflow: auto" id="tblPreguntas" >
  <table class="tb1" style="width:100%" >
    <thead>
    <tr class="tbLabel">      
      <th style="width:50%">Preguntas</th>
      <th style="width:50%">Seleccione su respuesta</th>            
    </tr>    
    </thead>
    <tbody>        
    </tbody>
  </table>
</div>
<table class="tb1" style="width:100%;display: none;" id="tblBtnrespuestas">
    <tr>
        <td style="width:80%"><div id="divValidar"></div></td>
    </tr>
</table>
<table class="tb1" style="width:100%;display: none;" id="tblResultado">
<tr class="tbLabel">      
  <td style="width:20%">Consulta</td>
  <td style="width:20%">Score</td>
  <td style="width:20%">Puntaje a superar</td>      
  <td style="width:20%">Servicio</td>      
  <td style="width:20%">Validación</td>      
</tr>
<tr>            
   <td><span id="resultado"></span></td>
   <td><span id="score"></span></td>
   <td><span id="valor"></span></td>
   <td><span id="autorizacion"></span></td>
   <td><span id="estado"></span></td>
  <td>
  </td>
</tr>
</table>

<table class="tb1" id="tblpie" cellspacing="0" cellpadding="0">
<tr class="tbLabel_O"><td style="TEXT-ALIGN: left !Important">(*) Campos obligatorios</td></tr>
</table>
</body>
</html>
