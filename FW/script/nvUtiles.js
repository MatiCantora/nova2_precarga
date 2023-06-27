
function replace(cad, buscar, remplazar)
  {
  cad = cad.toString()
  var re = new RegExp('(\\\\|\\?|\\*|\\[|\\]|\\(|\\)|\\^|\\$|\\|)',"ig")
  buscar = buscar.replace(re, '\\$1')
  var re = new RegExp(buscar,"ig")
  res = cad.replace(re, remplazar);
  return res
  }

  function ObtenerVentana(Target) 
    {
      var ventana;
      switch (Target.toUpperCase()) {
          case "_TOP":
              ventana = window.top;
              break
          case "_PARENT":
              ventana = window.parent;
              break
          case "_BLANK":
              ventana = CrearVentana("");
              break
          case "_SELF":
              ventana = window;
              break
          default:
              ventana = window.open('', Target);
      }
      return ventana
    } 
  
function copy_array(o) 
   {
   if (typeof(o) != "object" || o == null)
     return o; 
     
   var r = new Array();
   
   for (var i in o)
     {
     r[i] = copy_array(o[i]);
     }
   return r;
   }  

function MMDDYYYY(strFecha)  
  {
  return strFecha.split('/')[1] + '/' + strFecha.split('/')[0] + '/' + strFecha.split('/')[2]
  }

function ajustarFecha(objInput)
  {
  var Cfecha = new Date(Date.parse(MMDDYYYY(objInput)))
  return "convert(datetime, '" + FechaToSTR(Cfecha,2) + "', 101)"
  }


function valDigito(e,strCaracteres)
 {
 var key 
 if(window.event) // IE
   key = e.keyCode;
 else 
   key = e.which;
     
  if (key == 13 || key == 9 || key == 8 || key == 27 || key == 0)
      return true
    
  if(!strCaracteres) strCaracteres = ''
  
  var strkey = String.fromCharCode(key)
  var encontrado = strCaracteres.indexOf(strkey) != -1
  
  if (((strkey < "0") || (strkey > "9")) && !encontrado)
    return false
    
  }


function valDigitoVBS(e,strCaracteres)
  {
  valDigito(e,'/')
  }

function valDigitoCero(numero) 
{
  var numero = numero
  if (numero.substr(0, 1) == '0') 
   {
      numero = parseInt(numero.substr(1, 1))
   }
  return numero
}

function valAnio(anio) 
{
  if (anio.length <= 2)
      anio = 2000 + parseInt(anio, 10)

  if (anio.length == 3)
      anio = 2000 + parseInt(anio, 10)

  if (anio.length >= 4)
      anio = parseInt(anio, 10)


  return anio
}

function valFecha(e) 
{
      
      var oE = Event.element(e)
      var strFecha = oE.value
      if (strFecha == '')
          return

      var aFecha = strFecha.split('/')
      var hoy = new Date()
      strFecha = ''

      var fecha = null
      try {
          if (aFecha.length == 3) {
              var dia = valDigitoCero(aFecha[0])
              var mes_n = valDigitoCero(aFecha[1])
              var mes = parseInt(mes_n) - 1

              var anio_n = valAnio(aFecha[2])
              var anio = parseInt(anio_n)
          }

          if (aFecha.length == 2) {
              var dia = valDigitoCero(aFecha[0])
              var mes_n = valDigitoCero(aFecha[1])
              var mes = parseInt(mes_n) - 1
              var anio = hoy.getFullYear()
          }

          fecha = new Date(anio, mes, dia)

          if (fecha.getMonth() != parseInt(mes) || fecha.getDate() != parseInt(dia))
              fecha = null

      }
      catch (a) {
          fecha = null
      }


      if (fecha == null) {
          //alert('La fecha ingresado no es válida')
          oE.value = ''
          oE.focus()
      }
      else {
          oE.value = FechaToSTR(fecha, 1)
      }

  }

function formatoDecimal(num, dec)
  {
  if (isNaN(dec))
    dec = 2;
  if (isNaN(num))
    num = 0;
  return parseFloat(num).toFixed(dec)  
  }
  
function validarNumero(e,valorDefecto)
  { 
  var obj = Event.element(e)
  if (!valorDefecto) valorDefecto = '0.00'
  if (obj.value == "") 
     {
     obj.value = valorDefecto
     return
     }
  try
    {
    obj.value = formatoDecimal(eval(obj.value),2)
    }
  catch(e)
    {
    alert("El valor ingresado no es válido");
    obj.value = formatoDecimal(valorDefecto, 2)  
    }  
     
  }

function rellenar_izq(numero, largo, relleno)
			{
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(1, largo)
			while(strNumero.length < largo)
			  strNumero = relleno + strNumero.toString() 
			return strNumero
			}

//modo 1 = dd/mm/yyyy
//modo 2 = mm/dd/yyyy
//modo 3 = yyyy-mm-dd
function FechaToSTR(objFecha, modo)
  {
  if(!modo)
    modo = 1
  
  var dia = rellenar_izq(objFecha.getDate(),2, "0")
	var mes = rellenar_izq(objFecha.getMonth()+1,2, "0")
	var anio = objFecha.getFullYear()

  switch (modo)
    {
    case 1:
      return dia + '/' + mes + '/' + anio
      break;
    case 2:
      return  mes + '/' + dia + '/' + anio
      break;
    case 3:
      return  anio + '-' + mes + '-' + dia
      break;
    }
  }

function HoraToSTR(objFecha, modo)
{
    switch (modo) {
        case 'hh:mm':
            return String(objFecha.getHours()).padStart(2, '0') + ':' + String(objFecha.getMinutes()).padStart(2, '0');
            break;
        default:
            return objFecha.getHours() + ':' + objFecha.getMinutes() + ':' + objFecha.getSeconds();
            break;
    }
}

function parseFecha(strFecha, modo)
{
if (!modo)
  modo = 'UTC'
if (strFecha == null || strFecha == '')
  return null
//var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
//a = a.substr(0, a.indexOf('.'))
//var fe = new Date(Date.parse(a))
//return fe
var fe = null
switch (modo)
  {
  case 'UTC':
    var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
    a = a.substr(0, a.indexOf('.'))
    fe = new Date(Date.parse(a))
    break
    
  case 'dd/mm/yyyy':
    var items2 = new Array()
    items2[0] = 1
    items2[1] = (new Date()).getMonth()+1
    items2[2] = (new Date()).getFullYear()
    var items = strFecha.split("/")
    for (var i=0;i<items.length;i++)
      items2[i] = items[i]
    fe = new Date(items2[2], items2[1]-1, items2[0])
    break     
  
  case 'mm/dd/yyyy':
    var items = strFecha.split("/")
    fe = new Date(items[2], items[0]-1, items[1])
    break     

  case 'yyyy-mm-dd':
    var items = strFecha.split("-")
    fe = new Date(items[0], items[1]-1, items[2])
    break 
  case 'yyyy-mm-ddThh:mm':
    var arregloFechaHora = strFecha.split('T')
    var itemsFecha = arregloFechaHora[0].split("-")
    var itemsHora = arregloFechaHora[1].split(":")
    fe = new Date(itemsFecha[0], itemsFecha[1]-1, itemsFecha[2], itemsHora[0], itemsHora[1])
    break
  }

return fe
}

//function MO(e)
//{
//if (!e)
//  var e=window.event;
//var S=e.srcElement;
//while (S.tagName!="TD")
//  {S=S.parentElement;}
//S.className="MO";
//}

//function MU(e)
//{
//if (!e)
// var e=window.event;
//var S=e.srcElement;
//while (S.tagName!="TD")
// {S=S.parentElement;}
//S.className="MU";
//}

//function MENU_MO(e)
//{
//if (!e)
//  var e=window.event;
//var S=e.srcElement;
//while (S.tagName!="TD")
//  {S=S.parentElement;}
//S.className="MENU_MO";
//}
//function MENU_MU(e)
//{
//if (!e)
// var e=window.event;
//var S=e.srcElement;
//while (S.tagName!="TD")
// {S=S.parentElement;}
//S.className="MENU_MU";
//}
  
  
//function  link_mostrar(URL_relativa,  URL)
//  {
//  if (!URL)
//    URL = URL_relativa
//    //URL = URL_BASE + URL_relativa
//  var a = window.open(URL)
//  }
//  
 

//function mostrarVentanaModal(sURL, vArguments, sFeatures)
//  {
//  sFeatures =  sFeatures + 'edge: sunken; center: Yes; help: No; resizable: No; status: No; dialogHide: yes; unadorned: yes;'
//  var res = window.showModalDialog(sURL, vArguments, sFeatures)
//  }

/* Cookies *********************************** */
/* Cookies *********************************** */
/* Cookies *********************************** */

function GetCookie (name, defecto) 
{  
  if(defecto == undefined)
    defecto = null
  var arg = name + "=";  
  var alen = arg.length;  
  var clen = document.cookie.length;  
  var i = 0;  
  while (i < clen) 
    {    
    var j = i + alen;    
    if (document.cookie.substring(i, j) == arg)      
      return getCookieVal (j);    
    i = document.cookie.indexOf(" ", i) + 1;    
    if (i == 0) break;   
    }  
  return defecto;
}

function SetCookie (name, value, expires, path, domain, secure) 
{  

  var hoy = new Date();
  var argv = SetCookie.arguments;  
  var argc = SetCookie.arguments.length; 
  if (argc > 2)
    { 
    var today = new Date();
    today.setTime(today.getTime());
    expires = expires * 1000 * 60 * 60 * 24;
    var expires = new Date( today.getTime() + (expires) );
    }
  else
    var expires = null 
  
  var path = (argc > 3) ? argv[3] : null;  
  var domain = (argc > 4) ? argv[4] : null;  
  var secure = (argc > 5) ? argv[5] : false;  
  document.cookie = name + "=" + escape (value) + 
  ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) + 
  ((path == null) ? "" : ("; path=" + path)) +  
  ((domain == null) ? "" : ("; domain=" + domain)) +    
  ((secure == true) ? "; secure" : "");
}

function DeleteCookie (name) 
{  
  var exp = new Date();  
  exp.setTime (exp.getTime() - 1);  
  var cval = GetCookie (name);  
  document.cookie = name + "=" + cval + "; expires=" + exp.toGMTString();
}


function getCookieVal(offset) 
{
  var endstr = document.cookie.indexOf (";", offset);
  if (endstr == -1)
  endstr = document.cookie.length;
  return unescape(document.cookie.substring(offset, endstr));
}

//function cod_reemplazar(cade)
//  {
//  var cars = new Array()
//  cars[0] = {}
//  cars[0]['original'] = 'á'
//  cars[0]['reemplazo'] = 'a'
//  cars[1] = {}
//  cars[1]['original'] = 'é'
//  cars[1]['reemplazo'] = 'e'
//  cars[2] = {}
//  cars[2]['original'] = 'í'
//  cars[2]['reemplazo'] = 'i'
//  cars[3] = {}
//  cars[3]['original'] = 'ó'
//  cars[3]['reemplazo'] = 'o'
//  cars[4] = {}
//  cars[4]['original'] = 'ú'
//  cars[4]['reemplazo'] = 'u'
//  cars[5] = {}
//  cars[5]['original'] = 'ñ'
//  cars[5]['reemplazo'] = 'n'
//  cars[6] = {}
//  cars[6]['original'] = 'º'
//  cars[6]['reemplazo'] = ''
//  cars[7] = {}
//  cars[7]['original'] = 'Á'
//  cars[7]['reemplazo'] = 'A'
//  cars[8] = {}
//  cars[8]['original'] = 'É'
//  cars[8]['reemplazo'] = 'E'
//  cars[9] = {}
//  cars[9]['original'] = 'Í'
//  cars[9]['reemplazo'] = 'I'
//  cars[10] = {}
//  cars[10]['original'] = 'Ó'
//  cars[10]['reemplazo'] = 'O'
//  cars[11] = {}
//  cars[11]['original'] = 'Ú'
//  cars[11]['reemplazo'] = 'U'
//  cars[12] = {}
//  cars[12]['original'] = 'Ñ'
//  cars[12]['reemplazo'] = 'N'
//  
//  var strreg = ""
//  var reg
//  for (var i = 0; i < 13; i++)
//    {
//    reg = new RegExp(cars[i]['original'], 'ig')
//    cade = cade.replace(reg, cars[i]['reemplazo'])
//    }
//  
//  return cade
//}