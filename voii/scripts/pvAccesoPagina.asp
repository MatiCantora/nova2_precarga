<!--#include virtual="FW/scripts/nvSession.asp"-->
<% 
/***************************************************************************************/
//Controlar que ingrese por el protocolo seguro https si esta configurado de esa manera
//En caso contrario mandarlo a la misma URL pero en HTTPS
/***************************************************************************************/
debugger
var	HTTPS = Request.ServerVariables("HTTPS").Item
var URL = Request.ServerVariables('URL').item + '?' + Request.QueryString

if (Application.Contents("nv_onlyHTTPS") == true &&  HTTPS != "on")
  Response.Redirect( "https://" +  Request.ServerVariables("SERVER_NAME").Item + ":" + nvSession.getContents("cfg_server_port_https") + '/' + URL);

var PORT = Request.ServerVariables("SERVER_PORT").Item
var strPort = ":" + PORT
if (PORT == 443 && HTTPS == 'on') strPort = ""
if (PORT == 80 && HTTPS == 'off') strPort = ""

var protocol
if (HTTPS == 'on')
  protocol = "https://"
else
  protocol = "http://"
var SERVER_NAME = protocol + Request.ServerVariables("SERVER_NAME").Item + strPort

/****************************************************/
//Controlar esté logueado al sistema
/****************************************************/
var nv_hash = ''
if (Request.QueryString + "" != '')
  {
  nv_hash = obtenerValor('nv_hash', '')
  if (nv_hash != '')
    nv_hash = "&nv_hash=" + nv_hash
  }
if (nvSession.getContents("login") == '')
  {
  
  if (nv_hash == '')
    {
    var paramURL
    paramURL = URL == "" ? "" : "?URL=" + escape(URL)
    var URL = SERVER_NAME + "/FW/nvlogin.aspx" + paramURL
    Response.Redirect(URL)
    }
    
  }

/****************************************************/
//Controlar que este configurada la aplicacion actual
//Si "app_cod_sistema" es undefined nunca fue cargada por ende la carga
//Si "app_cod_sistema" es <> de la aplicación entonces estaba definida para otra aplicacion
//debe llamar de nuevo al nv_login para crear una nueva sesión
/****************************************************/
if (nvSession.getContents("app_cod_sistema") == undefined)
  Server.Execute('scripts/app_config.asp')

//Si no coincide la aplicacion activa con de la aplicación 
if (nvSession.getContents("app_cod_sistema") != 'nv_voii')
  {
  var URL = SERVER_NAME + "/FW/nvlogin.aspx?URL=" + escape(URL) + '&app_cod_sistema=nv_voii' + nv_hash
  Response.Redirect(URL)
  }


/****************************************************/
//Controlar que sea un operador de sistema
/****************************************************/
var AutLevel = nvSession.getContents("AutLevel");
if (AutLevel == -1)
  Response.Redirect("../../errores_personalizados/error_401_1.html")

//Response.cookies("cfg_session_id") = nvSession.SessionID


%>