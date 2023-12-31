
var Menus = {}; //se colocan aca todos los menus de la pagina
//de esta manera se pueden cargar automaticamente en el load del documento
//necesario para CargarMenus()
function CargarMenus()
{
  var i
  for(i in Menus)
    Menus[i].MostrarMenu()
}  

function tMenu(txt_canvas, txt_nombre, param)
{
  Menus[txt_nombre] = this
  this.nombre = txt_nombre; // Nombre de la variable
  this.canvas = txt_canvas; // Area que contendrá el arbol
  this.canvasMobile = (param) ? param.canvasMobile : ""
  this.functionMobile = true//(param === undefined ||param.functionMobile === undefined) ? true : param.functionMobile
  this.clasicMenu = (param === undefined || param.clasicMenu === undefined) ? true : param.clasicMenu
  this.alineacion = 'izquierda'; // o 'derecha'
  this.MenuItems = {};
  this.nvImages = new tImage();
  this.imagenes = {}; // Imagenes comunes
  this.simagenes = {}; // Imagenes cuando seleccionado
  this.estilo = "O";
  this.separador = "|"
  this.CargarXML = tMenu_CargarXML;
  this.CargarMenuItem = tMenu_CargarMenuItem;
  this.CargarMenuItemXML = tMenu_CargarMenuItemXML;
  this.MostrarMenu = tMenu_MostrarMenu;
  this.MostrarSubMenu = tMenu_MostrarSubMenu;
  this.loadImage = tMenu_loadImage;
  this.getURLImage = tMenu_getURLImage;
  this.XML = '';
  this.cargar_sistemas = tMenu_CargarSistemas

  this.mostrarMenuMobile = tMenu_mostrarMenuMobile;
  this.MostrarSubMenuMobile = tMenu_MostrarSubMenuMobile;
  this.strXML
  this.strXMLItem =[]
  this.menuMobile
  this.isMenuMobile = false

  this.resize = tMenu_resize;
  this.resizeSubMenu = tMenu_resizeSubMenu;
  
  //this.resize()
}

function tMenu_resize(isMobile) {
    
    var element = $(this.canvas);
    var element_mobile = $(this.canvasMobile)

    if (isMobile) {
            element.hide()
            element_mobile.show()
    }
    else {
        
        if (this.clasicMenu) {
            element.show()
            element_mobile.hide()

            for (var index in this.MenuItems) {
                this.resizeSubMenu(index)
            }
        }
        else {
            element.hide()
            element_mobile.show()
        }
    }
}

 function tMenu_CargarSistemas() {
  parametros = encodeURIComponent("<criterio><select vista='verMenu_sistemas' forxml='explicit' ><campos>*</campos><filtro><xmlpath path='[MenuItem!1!servidor_alias]' type='igual'>'" + cfg_server_name + "'</xmlpath></filtro><orden>[MenuItem!4!id]</orden></select></criterio>")
  oXML = new tXML()
  oXML.method = 'POST'
  oXML.getXML("GETXML", parametros)
  var strXML = oXML.toString()
  var strReg = '<\\?[^>]*\\?>'
  var re = RegExp(strReg)
  strXML = strXML.replace(re, '')
  this.CargarMenuItemXML(strXML)    
  }

function tMenuItem()
  {
  this.menu = ""; // Arbol al cual pertenece
  this.id = ""; // Identificador del Nodo
  this.accion = new tAccion(this); // accion a ejecutar cuando click
  this.nombre = ""; // Texto el Item
  this.style = ""
  this.innerHTML = ""
  this.TipoMenuItem = "";
  this.icono = "";
  this.parent = null
  this.MenuItems = {};
  this.isOpened = false

  this.count = function () {
      var j = 0
      
      for (var i in this.MenuItems) {
          j++;
      }
      return j
  }
  this.CargarMenuItem = tMenu_CargarMenuItem;
  this.GenerarHTML = tMenuItem_GenerarHTML;
  
}

function tMenu_MostrarSubMenuMobile(id) {
    var objDIV
    var renderItem = true
    var imgOpen = $(this.nombre + '_img' + id + "_open")

    for (var index in this.MenuItems) {
        objDIV = $("divSubMnu_" + this.canvas + "_" + index)

        if (objDIV != null) {
            if (id == index)
                renderItem = false

            if (id == index && objDIV.style.display === "none") {
                objDIV.show()
                
            }
            else {
                if (id == index) {
                    
                    objDIV.hide()
                    $(this.nombre + '_img' + index + "_open").src = "/fw/image/tmenu/menos.gif"
                }
            }
        }
    }

    if (imgOpen.src.indexOf("/fw/image/tmenu/menos.gif") != -1) {
        imgOpen.src = "/fw/image/tmenu/mas.gif"
    }
    else
        imgOpen.src = "/fw/image/tmenu/menos.gif"

    if (!renderItem)
        return
    

    var estilo = this.estilo
    objMenuItem = this.MenuItems[id]
    var strHTML = '<table>'
    var cont = 0;

    for (var i in objMenuItem.MenuItems) {
        cont++
        strHTML = strHTML + '<tr>' + this.MenuItems[i].GenerarHTML(true) + '</tr>';
    }
    this.estilo = estilo
    strHTML = strHTML + '</table>'

    var objDIV = $("divSubMnu_" + this.canvas + "_" + id)

    if (!objDIV) {
        var objTD = $(this.nombre + "_img" + id)
        while (objTD.tagName != 'TD') {
            objTD = objTD.up()
        }

        var coorsTOP_LEFT = findPos(objTD)

        $("menuItem_" + this.canvas + '_' + id).innerHTML = $("menuItem_" + this.canvas + '_' + id).innerHTML + "<div id='divSubMnu_" + this.canvas + "_" + id + "' style='padding-left: 13px;display: none' ></div>"
        var objDIV = $("divSubMnu_" + this.canvas + "_" + id)
        objDIV.insert({ top: strHTML })

        objDIV.show()

    }
    else
        objDIV.show()
}
  
var openedObjDIV
function tMenu_MostrarSubMenu(id)
  {
  var objDIV 
  var idDIVParent
  for (var index in this.MenuItems)
    {
      objDIV = $("divSubMnu_" + this.canvas + "_" + index)
      if (objDIV) {
          if (this.MenuItems[id].parent)
            idDIVParent = this.MenuItems[id].parent.id
      }
      if (objDIV != null && idDIVParent != index) {
          objDIV.hide()//objDIV.style.display = 'none'
          this.MenuItems[id].isOpened = false;
      }
    }
 
  this.MenuItems[id].isOpened = true;

  var estilo = this.estilo
  objMenuItem = this.MenuItems[id]
  var strHTML = '<table class="submnuTB_' + estilo + '" cellspacing="0" cellpadding="0" > ' //style="border-bottom: solid black 2px; border-left: solid black 1px"
  var cont = 0;
  
  //this.estilo = 'A'
  for(var i in objMenuItem.MenuItems)
    {
    cont++
    strHTML = strHTML + '<tr class="submnuTR_' + estilo + '">' + this.MenuItems[i].GenerarHTML() + '</tr>'; 
    }
  this.estilo = estilo
  strHTML = strHTML + '</table>'  
  
  var objDIV = $("divSubMnu_" + this.canvas + "_" + id)
  
  if (!objDIV) {
      //var objTD = Event.element(e)
      var objTD = $(this.nombre + "_img" + id)
      while (objTD.tagName != 'TD') {
          objTD = objTD.up()
      }

      var coorsTOP_LEFT = findPos(objTD)
      
      //$$('BODY')[0].insert({ top: "<div tabindex='1' id='divSubMnu_" + this.canvas + "_" + id + "' style='position: absolute; z-index: 2; float: left; display: none' onmouseout='return submnu_mouseout(\"" + this.canvas + "_" + id + "\")' onmousemove='return submnu_mousemove(\"" + this.canvas + "_" + id + "\")' ></div>" })
      $$('BODY')[0].insert({ top: "<div  id='divSubMnu_" + this.canvas + "_" + id + "' style='position: absolute; z-index: 2; float: left; display: none' onmouseout='return submnu_mouseout(\"" + id + "\"," + this.nombre + ")'  onmousemove='return submnu_mousemove(\"" + id + "\"," + this.nombre + ")' ></div>" })
      //document.body.insertAdjacentHTML('beforeEnd', "<div id='divSubMnu_" + id + "' style='position: absolute; z-index: 2; float: left; display: none' onmouseout='return submnu_mouseout(" + id + ")' onmousemove='return submnu_mousemove(" + id + ")' ></div>")
      var objDIV = $("divSubMnu_" + this.canvas + "_" + id)
      objDIV.insert({ top: strHTML })

      objDIV.show()

      //objDIV.style.top = (coorsTOP_LEFT[1]) + objTD.offsetHeight  + 'px'  //document.all.btnSel_nro_sistema.offsetTop + document.all.btnSel_nro_sistema.offsetHeight + 30 + "px"
      //objDIV.style.left = (coorsTOP_LEFT[0]) + 'px'    
      //Width

      this.resizeSubMenu(id)
  }
  else {
      objDIV.show()//objDIV.style.display = 'inline'

      this.resizeSubMenu(id)
  }
  
  openedObjDIV = objDIV.id
  //objDIV.focus();
  
  }

function tMenu_resizeSubMenu(id) {
    
    var objDIV = $("divSubMnu_" + this.canvas + "_" + id)

    if (objDIV === null) return

    var objTD = $(this.nombre + "_img" + id)
    
    var coorsTOP_LEFT = findPos(objTD)
     //falta ver porque un submenu de un submenu se posiciona mal

    if (this.MenuItems[id].parent) {
        
        var objDIVParent = $("divSubMnu_" + this.canvas + "_" + this.MenuItems[id].parent.id)

        objDIV.style.left = parseInt(objDIVParent.style.left) + objDIVParent.getWidth() + 'px'
        objDIV.style.width = parseInt(objDIVParent.style.width) + 'px'
        objDIV.style.top = parseInt(objDIVParent.style.top) +  "px"
        objDIV.style.zIndex = parseInt(objDIV.style.zIndex) + 1
    }
    else {
        if (objDIV.offsetWidth < objTD.offsetWidth) {
            objDIV.style.width = objTD.offsetWidth + 'px'
        }

        //LEFT
        if (coorsTOP_LEFT[0] + objDIV.offsetWidth < document.body.offsetWidth)
            objDIV.style.left = (coorsTOP_LEFT[0]) - 5 + 'px'
        else
            objDIV.style.left = coorsTOP_LEFT[0] + objTD.offsetWidth - 5 - objDIV.offsetWidth + 'px'
    }
    objDIV.style.top = (coorsTOP_LEFT[1]) + objTD.offsetHeight + 'px'

}

function tMenu_CargarXML(strXML, Tipo)// tipo = ['URL', 'XML']
{
    this.strXML = strXML;
  var NOD;
  if (Tipo == undefined)
    Tipo = 'XML';
  if (Tipo == 'XML')
    {
    oXML = new tXML()
    oXML.loadXML(strXML)
    this.XML = oXML.xml
    }
  else
    {
    oXML = new tXML()
    oXML.load(strXML)
    this.XML = oXML.xml
    }

  if (this.XML != null)
    {
    NOD = selectNodes('/resultado/MenuItems', this.XML);
    //this.MenuItems = {};
    if (NOD.length > 0)
      {
      NOD = NOD[0];
      for(var i=0;i < NOD.childNodes.length;i++)
        if (NOD.childNodes[i].nodeType == 1)
	      this.CargarMenuItem(NOD.childNodes[i])  
	  }
    }
  }
function tMenu_CargarMenuItemXML(xmlMenuItem)
{
    this.strXMLItem[this.strXMLItem.length] = xmlMenuItem
    
  oXML = new tXML()
  oXML.loadXML("<?xml version='1.0' encoding='ISO-8859-1'?><resultado><MenuItems>" + xmlMenuItem + "</MenuItems></resultado>")
  var NODS = oXML.selectNodes('/resultado/MenuItems/MenuItem')
  for (i=0; i < NODS.length; i++)
    if (NODS[i].nodeType == 1)
      this.CargarMenuItem(NODS[i])
}  

function tMenu_CargarMenuItem(NOD, NOD_parent)
{
  //NOD = <MenuItem>
  var pvMenuItem = new tMenuItem;
  pvMenuItem.menu = this;
  a = XMLtoString(NOD)
  pvMenuItem.id = selectSingleNode("@id", NOD).nodeValue;
  if (selectSingleNode("@style", NOD) != null)
     pvMenuItem.style = selectSingleNode("@style", NOD).nodeValue;
     
     
  //Identificar el padre
  if (typeof(NOD_parent) == 'object')
    {
    NOD_parent.MenuItems[pvMenuItem.id] = pvMenuItem;
    pvMenuItem.parent = NOD_parent
    }
    
  //Agregarlo a la coleccion
  this.MenuItems[pvMenuItem.id] = pvMenuItem;
    
  pvMenuItem.accion.TipoLib = selectSingleNode("Lib/@TipoLib", NOD).nodeValue
  pvMenuItem.accion.parametros["Lib"] = XMLText(selectSingleNode("Lib", NOD));
  pvMenuItem.icono = XMLText(selectSingleNode("icono", NOD));

  pvMenuItem.nombre = XMLText(selectSingleNode("Desc", NOD));
  var MenuItems = selectNodes("MenuItems/MenuItem", NOD)
  
  if (MenuItems.length == 0)
    {
    if (selectNodes('Acciones', NOD).length == 0)
      pvMenuItem.accion.estado = "no-activo"
    else  
      {
        pvMenuItem.accion.estado = "activo"; 
      pvMenuItem.accion.parametros["xml"] = XMLtoString(selectSingleNode("Acciones", NOD));
      }
    }  
  else
    {
      pvMenuItem.accion.estado = "activo";
      
      if (this.isMenuMobile) {
          
          pvMenuItem.accion.parametros["xml"] = "<Acciones><Ejecutar Tipo='script'><Codigo>" + pvMenuItem.menu.nombre + ".MostrarSubMenuMobile('" + pvMenuItem.id + "')</Codigo></Ejecutar></Acciones>";
      }
      else {
          pvMenuItem.accion.parametros["xml"] = "<Acciones><Ejecutar Tipo='script'><Codigo>" + pvMenuItem.menu.nombre + ".MostrarSubMenu('" + pvMenuItem.id + "')</Codigo></Ejecutar></Acciones>";
      }
    for (var i=0; i < MenuItems.length; i++)
      this.CargarMenuItem(MenuItems[i], pvMenuItem)
    }  
  //pvMenuItem.GenerarHTML();
  
}

function tMenu_getURLImage(icono)
  {
  if (this.nvImages.Exists(icono))
    return this.nvImages.items[icono].src
  else 
    if (this.imagenes[icono] != undefined)
      {
      this.nvImages.load(icono, this.imagenes[icono].src)
      return this.nvImages.items[icono].src
      }
  return "" 
  }

function tMenuItem_GenerarHTML(mobile)
  {
  if (this.innerHTML != "")
    return this.innerHTML

  var strHTML;
  var estilo = 'class="mnuCELL_Normal_' + this.menu.estilo + '"'

  //if (mobile) {
  //    estilo = "style='padding-top:10px;'" 
  //}
    
  strHTML = '<td id="menuItem_' + this.menu.canvas + '_' + this.id.toString() + '"' + estilo + ' nowrap style="cursor:pointer;' + this.style + '" '
  
  if (this.accion.estado == 'activo') {
      if (mobile) {
          strHTML += ' onkeydown="return document.selection.empty()" '
      }
      else {
          strHTML += ' onkeydown="return document.selection.empty()" onmouseover="mnuMO(event, \'' + this.menu.estilo + '\')" onmouseout="mnuMU(event, \'' + this.menu.estilo + '\')" '
      }
  }
  strHTML += '>'
  
  if(this.icono != '')
    {
    var src = this.menu.getURLImage(this.icono)
    var alt // = this.icono
    if (src == "")
        alert("Error. No se encuentra la imagen '" + this.icono + "'")

      strHTML += '<span onClick="Menus[\'' + this.menu.nombre + '\'].MenuItems[' + this.id + '].accion.Ejecutar(event);">' + ((mobile && this.count(this.MenuItems) > 1) ? '<img id="' + this.menu.nombre + '_img' + this.id.toString() + '_open" style="position: relative;top: 4px" src="/fw/image/tmenu/mas.gif" >' : '') + '<img id="' + this.menu.nombre + '_img' + this.id.toString() + '" src="' + src + '" alt="' + alt + '" border=0 align=absmiddle hspace=1></span>'
    }
  
  if(this.nombre != '')
      strHTML += '<span onClick="Menus[\'' + this.menu.nombre + '\'].MenuItems[' + this.id + '].accion.Ejecutar(event);">' + this.nombre + '</span>';
  strHTML += '</td>'
  
  this.innerHTML = strHTML;
  return strHTML;  
}

function tMenu_MostrarMenu(mobile)
{
    var strHTML = '<table id="' + this.nombre + '" class="mnuTB_' + this.estilo + '" cellspacing="0" cellpadding="0" style="color: black; padding: 0px"><tr>'

    if (this.alineacion == 'izquierda')
        strHTML = strHTML + '<td class="mnuCELL_Normal_' + this.estilo + '">&nbsp;</td>';
    var cont = 0;
    for (var i in this.MenuItems) {
        
        if (this.MenuItems[i].nombre == "Volver")
            continue

        if (this.MenuItems[i].parent != null)
            continue
        
        cont++
        if ((cont > 1) && (this.MenuItems.length > 0)) {
            strHTML = strHTML + '<td class="mnuCELL_Sep_' + this.estilo + '">' + this.separador + '</td>'
        }
        strHTML = strHTML + this.MenuItems[i].GenerarHTML();
    }

    if (this.alineacion == 'derecha')
        strHTML = strHTML + '<td width="100%" height="100%" class="mnuCELL_Normal_' + this.estilo + '" >&nbsp;</td>';

    strHTML = strHTML + '</tr></table>'
    $(this.canvas).insert({ top: strHTML })
   // $(this.canvas).style = "background-color: white;border-bottom: 3px solid #E3E0E3"

    //var objDIV = document.createElement("div");

    //objDIV.style = "background-color: white;"

    //if (!this.canvasMobile)
    //    this.canvasMobile = this.canvas + "_mobile";

    //objDIV.id = this.canvasMobile
    if (mobile) {
        objDIV = $(this.canvasMobile)
        //$(this.canvas).parentElement.insertBefore(objDIV, $(this.canvas));
        //$$("BODY")[0].insert(objDIV);
        this.menuMobile = new tMenu(this.canvasMobile, this.nombre + ".menuMobile")
        this.menuMobile.isMenuMobile = true
        this.menuMobile.clasicMenu = this.clasicMenu
        this.menuMobile.estilo = this.estilo

        if (this.strXML) {
            this.menuMobile.CargarXML(this.strXML)
        }
        else {
            for (var i = 0; i < this.strXMLItem.length; i++) {
                this.menuMobile.CargarMenuItemXML(this.strXMLItem[i])
            }
        }

        this.menuMobile.imagenes = this.imagenes
        //menuMobile.MenuItems = changeMenuItemsId(this.MenuItems);

        this.menuMobile.mostrarMenuMobile();
        this.resize(mobile)
    }
    
    
    
    //this.mostrarMenuMobile(mobile)
}  


function tMenu_mostrarMenuMobile() {
    //var estiloMobile = ""
    //estiloMobile = "style = 'width: 100%;border: 0px solid white; padding-left: 10px;border-spacing: 4px 9px;font-size:14px;color: black; text-align: left';"
    
    var strHTML = '<table id="' + this.nombre + '" class="mnuTB_' + this.estilo + '" cellspacing="0" cellpadding="0" style="padding: 0px;">'
    var cont = 0;
    for (var i in this.MenuItems) {
       

        if (this.MenuItems[i].parent != null)
            continue
        cont++
        if ((cont > 1) && (this.MenuItems.length > 0)) {
            strHTML = strHTML + "<tr>"
            strHTML = strHTML + '<td width="100%" class="mnuCELL_Normal_' + this.estilo + '">&nbsp;</td>'
            strHTML = strHTML + "</tr>"
        }
        strHTML = strHTML + "<tr>"
        strHTML = strHTML + this.MenuItems[i].GenerarHTML(true);
        strHTML = strHTML + "</tr>"
    }

    strHTML = strHTML + '</table>'

    //var objDIV = document.createElement("div");

    $(this.canvas).style = "background-color: white;opacity: 1;"
    //objDIV.id = this.canvasMobile

    $(this.canvas).insert({ top: strHTML })

    //$(this.canvas).parentElement.insertBefore(objDIV, $(this.canvas));
}

function tMenu_loadImage(name, url, preLoad)
  {
  if (!this.imagenes)
    this.imagenes = {}
  
  this.imagenes[name] = {}
  this.imagenes[name].src = url
  }

function mnuMO(e, estilo)
{
  obj = Event.element(e)
  while (obj.tagName != "TD")
  { obj = obj.up() }

  obj.removeClassName("mnuCELL_Normal_" + estilo)  
  obj.addClassName("mnuCELL_OnOver_" + estilo)    
}

function mnuMU(e, estilo)
{
    obj = Event.element(e)
    
  while (obj.tagName != "TD")
    {obj = obj.up()}
  obj.removeClassName("mnuCELL_OnOver_" + estilo)  
  obj.addClassName("mnuCELL_Normal_" + estilo)    
}  

function getXY(Obj) 
{
  //for (var sumTop=0,sumLeft=0;Obj!=document.body;sumTop+=Obj.offsetTop,sumLeft+=Obj.offsetLeft, Obj=Obj.offsetParent);
  var sumTop=0
  var sumLeft=0
  while (Obj!=document.body)
    {
    sumTop+=Obj.offsetTop
    sumLeft+=Obj.offsetLeft
    Obj=Obj.offsetParent
    //Obj=Obj.parentElement
    }
  return {left:sumLeft,top:sumTop}
}
function tPopup(txt_canvas, txt_nombre, objXML)
{
  this.nombre = txt_nombre; // Nombre de la variable
  this.canvas = txt_canvas; // Area que contendrá el arbol
  this.alineacion = 'izquierda'; // o 'derecha'
  this.MenuItems = {};
  this.imagenes = {}; // Imagenes comunes
  this.simagenes = {}; // Imagenes cuando seleccionado
  this.estilo = "P";
  this.separador = "|"
  this.CargarXML = tMenu_CargarXML;
  this.CargarMenuItem = tMenu_CargarMenuItem;
  this.MostrarPopup = tPopup_MostrarPopup;
  this.XML = objXML;
  this.visible = false
}

function tPopup_MostrarPopup()
{
  var e
  e =  event.srcElement
  while (e.tagName != 'TD')
    e = e.parentElement
  var Cordenadas = getXY(e)  
  if (!this.visible)
    {
    $(this.canvas).innerHTML = ''
    var strHTML = '<table id="' + this.nombre + '" class="mnuTB_' + this.estilo + '" cellspacing="0" cellpadding="0"><tr>'
    var cont = 0;
    for(var i in this.MenuItems)
      strHTML = strHTML + '<tr>' + this.MenuItems[i].GenerarHTML() + '</tr>'

    strHTML = strHTML + '</tr></table>'
    canvas = $(this.canvas)
    canvas.insert({top: strHTML})
    canvas.style.top = (Cordenadas.top -2) + 'px';
    canvas.style.left = (Cordenadas.left + 17) + 'px';
    canvas.show()
    this.visible = true
    }
  else
    {
    $(this.canvas).hide()
    this.visible = false
    }
 
}  

var a = 0
var b = 0
//window.status = '0 | 0'

function submnu_mouseout(id,nombreTabla)
  {
    
    objDiv = $('divSubMnu_' + nombreTabla.canvas + "_" + id)
    objDiv.mousemove = false
    
    window.setTimeout( function() { submnu_cerrar( id,nombreTabla ) },1500)
  }
  
function submnu_mousemove(id, nombreTabla)
  {
    
    objDiv = $('divSubMnu_' + nombreTabla.canvas + "_" + id)
    objDiv.mousemove = true
    var pos = window.status.indexOf('|')
  }  
  
function submnu_cerrar(id, nombreTabla)
  {
  try
  {
      for (var i in nombreTabla.MenuItems[id].MenuItems) {
          if (nombreTabla.MenuItems[i].isOpened) {
              return
          }
      }

      nombreTabla.MenuItems[id].isOpened = false;
      objDiv = $('divSubMnu_' + nombreTabla.canvas + "_" + id)
    if (!objDiv.mousemove)
        objDiv.hide()
    }
    catch (e) {

    }
  }
  

function findPos(obj) 
           {
           var curleft = curtop = 0;
           if (obj.offsetParent)
             {
             curleft = obj.offsetLeft
             curtop = obj.offsetTop
             while (obj = obj.offsetParent) 
               {
               curleft += obj.offsetLeft
               curtop += obj.offsetTop
               }
             }
           return [curleft,curtop];
           }
