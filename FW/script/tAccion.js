function tAccion(Nodo)
  {
  this.parametros = {};
  this.TipoLib = "";
  this.estado = ""; //["activo";"no-activo"]
  this.parent = Nodo;
  this.Ejecutar = tAccion_Ejecutar;
  this.offLineEjecutar = tAccion_offLineEjecutar;
  }  

function tAccion_Ejecutar(event)
  {
  //window.event.returnValue = false;
  switch (this.parent.accion.TipoLib)
    {
    case "offLine":
      this.offLineEjecutar(event);
    }  
  }

function tAccion_offLineEjecutar(event) {
  var TipoEjecutar;
  var codigo
  var Lib = this.parametros["Lib"];
  var oXML = new tXML();
  oXML.loadXML(this.parametros["xml"])
  var XML1 = oXML.xml
  if (XML1 == null) return
  var NODAcciones = selectSingleNode('Acciones', XML1)
  for (var i=0; i < NODAcciones.childNodes.length; i++)
    if (NODAcciones.childNodes[i].nodeType == 1)    
      {
      nvFW.selection_clear()
      TipoEjecutar = NODAcciones.childNodes[i].getAttribute('Tipo');
      switch (TipoEjecutar)
        {
        case 'script':
          codigo = XMLText(selectSingleNode('Codigo|codigo', NODAcciones.childNodes[i]))
          if(NODAcciones.childNodes[i].attributes[1] > 0)
            {
            var retardo = NODAcciones.childNodes[i].attributes[0].nodeValue;
            window.setTimeout(codigo,retardo);
            }
          else
			eval(codigo);
          break
      case 'link':
          var Target = XMLText(selectSingleNode('Target', NODAcciones.childNodes[i]));
		  var URL = XMLText(selectSingleNode('URL', NODAcciones.childNodes[i]));
		  var ventana = ObtenerVentana(Target);
		  ventana.location.href = URL;
          break	  
        } 
      }
}

 
function CrearVentana(URL,Propiedades)
  {
  if (URL == undefined) 
    URL = 'about:blank';
  if (Propiedades == undefined)
    Propiedades = '' //'maximized=yes,menubar=yes,toolbar=yes,scrollbars=yes,resizable=yes';//toolbar=no,width=600,height=600,directories=no,status=no,scrollbars=yes,resize=no,menubar=no
           
      var newWindow = window.open(URL,null,Propiedades)
      return newWindow;
    }


