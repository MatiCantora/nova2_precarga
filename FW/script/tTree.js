  //***************************************************************
//  Definición del tipo tTre. Obejto base que controla el arbol
//  Parametros: txt_canvas: (string) ID del objeto contenedor del árbol
//              txt_nombre: (string) nombre de la variable tTree
//              XML: (XML) XML asociado por el cual recibe los datos.
//  Salida: Un objeto tTree que controla el arbol.
//****************************************************************

function tTree(canvas, txt_nombre)
{
  this.nombre = txt_nombre; // Nombre de la variable
  this.async = false
  this.bloq_contenedor = null
  this.bloq_cont_id = ''

  this.onExpand = null
  this.onNodeCharge = null
  this.ChargeNodeOnchek = true

  this.MostrarArbol = tTree_MostrarArbol;
  //this.AgregarNodo = tTree_AgregarNodo;
  this.cargar_nodo = tTree_cargar_nodo;
  //this.CargarXML = tTree_CargarXML;
  this.crear_nodo = tTree_crear_nodo;
  this.select_node = tTree_selectNode;
  this.recargar_nodo = tTree_recargar_nodo;
  this.recargar_node = tTree_recargar_node;
  this.eliminar_nodo = tTree_eliminar_nodo;
  this.id_to_uid = tTree_id_to_uid;
  
  this.nodos = {};//new Array();
  this.nvImages = new tImage();
  this.imagenes = {}; //new Array(); // Imagenes comunes
  this.loadImage = tTree_loadImage;
  this.getURLImage = tTree_getURLImage;
  this.uid = IdentificadorUnico();
  this.canvas = canvas //+ '_' + this.uid // Area que contendrá el arbol
  //$(canvas).id = this.canvas
  this.getNodo_xml = null
  
  /*************************/
  // DRAG AND DROP
  /*************************/
  this.dad_opacity = 0.3 //Opacidad del elemento arrastrado
  this.dad_drop_eval = "element.hasClassName('hqTR_Arbol')" //Por defecto toma otros nodos como destino del drop
  this.nodo_mousedown = tTree_nodo_mousedown; //Comienza el proceso de drag and drop
  this.dad_drag_over = null
  this.dad_drag_over_out = null
  this.dad_drop = null

  var nombreXML;
  
  this.loadImage('mas', '/FW/image/tTree/mas.jpg')
  this.loadImage('menos', '/FW/image/tTree/menos.jpg')
  this.loadImage('punto', '/FW/image/tTree/punto.jpg')
  
}

function tTree_id_to_uid(uid)
  {
  for (var id in this.nodos)
    if (this.nodos[id].uid == uid)
      return id
  }

function tTree_recargar_nodo(id)
  {
  var padre = this.nodos[id] != undefined ? this.nodos[id] : undefined
  //si el padre NO es nulo o el id es el raiz
  if (padre != undefined || this.id == id)
    this.cargar_nodo(id, padre)
  } 

//seleccionar un nodo del arbol
function tTree_selectNode(id)
  {
  for (var i in this.nodos)
    this.nodos[i].select(this.nodos[i].id == id)

  }
  
function tTree_recargar_node(id)  
  {
  //buscar el nodo

  for (var i in this.nodos)
    if (this.nodos[i].id == id)
      {
      //borrar contenedor
      if (this.nodos[i].parent)
        var Contenedor = $('hijos' + this.nodos[i].parent.uid) //var Contenedor = eval('document.all.hijos' + this.parent.uid)
      else  
        var Contenedor = $(this.canvas)
      
      Contenedor.innerHTML = ''
      
      //identificar si es primer nodo      
      if (this.nodos[i].parent != undefined)
        {
        this.cargar_nodo(this.nodos[i].parent.id, this.nodos[i].parent)
        var j    
        for (j in this.nodos[i].parent.hijos)
          this.nodos[i].parent.hijos[j].MostrarNodo();
        //expandir  

        this.nodos[i].parent.estadoCarpeta = 'cerrado'
        this.nodos[i].parent.expand()  
        this.nodos[i].estadoCarpeta = 'cerrado'
        this.nodos[i].expand()  
        }
      else 
        {
        this.cargar_nodo(this.id)
        this.MostrarArbol()
        }
      }
  
    
      
  }
  
function tTree_cargar_nodo(nodo_id, padre, onComplete)
  {
  var XML = new tXML();
  var arbol = this
  XML.onComplete = function(oXML)
                       {
                       var NOD;
                      var objXML;
                      objXML = XML //this.CargaXMLTerminada(strXML)
//                      if (typeof(XML) == 'object')
//                        objXML = XML //this.CargaXMLTerminada(strXML)
//                      else
//                        {  
//                        var oXML = new tXML()
//                        oXML.async = false;
//                        oXML.loadXML(XML)
//                        objXML = oXML.xml
//                        }  
//  
  
                      NOD = selectSingleNode('resultado/nodo', objXML.xml);
  
                      if (NOD != null)
                        {
                        //copiar los nodos antes de la carga
    
                        if (arbol.nodos_copia == undefined)
                          arbol.nodos_copia = {}
                        for (var i in arbol.nodos)
                          arbol.nodos_copia[i] = arbol.nodos[i]
                        var id = selectSingleNode('@id', NOD).nodeValue
                        var uid = arbol.uid + id

		                if (padre != undefined)
                          padre.EstadoHijos = "cargado"
                        else
                          {
                          arbol.id = id
                          padre = arbol.crear_nodo(NOD, padre)
                          }

                        //Si con hijos del raiz
                        if (padre.id == arbol.id)
                          arbol.nodos = {}
    
                        if (arbol.nodos[id] != undefined)
                           arbol.nodos[id].hijos = {}
  
                        var hijos = selectNodes('nodo', NOD)
	                      for(var i=0;i < hijos.length;i++)
	                        arbol.crear_nodo(hijos[i], padre)
	                      }

                       if (arbol.onNodeCharge != null)
                         arbol.onNodeCharge(padre.id)
                                   
                       if (onComplete != null)
                         onComplete()
                       }
  if (this.async)
    {
    XML.async = true
    this.getNodo_xml(nodo_id, XML)
    }
  else
    {
    XML.async = false
    var strXML = this.getNodo_xml(nodo_id)
    XML.loadXML(strXML)
    }

  }

function tTree_eliminar_nodo(nodo,padre)
{
    if (!padre)
        padre = null

    for (i in nodo.hijos)
        if (nodo.hijos[i])
            this.eliminar_nodo(nodo.hijos[i], nodo)

    this.nodos[nodo.uid].eliminar()
}

//***************************************************************
//  Definición del tipo tNodo. Obejto que controla cada nodo del árbol
//  Parametros: arbol   = (objeto) objeto tTree de cual depende
//              id      = (integer) Identificador del nodo
//              padre   = (objeto) Nodo del cual depende
//  Salida: Un objeto tNodo que controla el nodo.
//****************************************************************
function tNodo(arbol, id, padre)
{
  
  this.arbol = arbol; // Arbol al cual pertenece
  this.id = id; // Identificador del Nodo
  this.uid = arbol.uid + id;
  this.tipo = ""; // ["carpeta", "hoja"]
  this.accion = new tAccion(this); // accion a ejecutar cuando click
  this.nombre = ""; // Texto el Item
  this.estadoCarpeta = "cerrado"; // ["cerrado", "abierto"]
  this.hijos = {} //new Array(); // Nodos hijos del Item 
  this.nhijos = 0; // Cantidad de hijos del Item
  this.selected = false; // True cuando está seleccionado
  this.checkbox = "no-habilitado";
  this.checked = false;
  this.indeterminate = false
  this.title = "";
  this.EstadoHijos = "no-cargados"; // ["cargados", "no-cargados" ]
  this.ultimoHijoCargado = 0; // Se utiliza para agregar los hijos
  this.TipoItem = "";
  this.MostrarNodo = tNodo_MostrarNodo;
  this.GenerarHTML = tNodo_GenerarHTML;
  this.CargarXML = tNodo_cargar_nodo;
  this.select = tNodo_select;
  this.recargar = tNodo_recargar;
  this.eliminar = tNodo_eliminar;
  this.expand = tNodo_expand;
  this.checking = tNodo_checking;
  this.parent = padre; // Nodo padre
  if (padre)
    {
    padre.hijos[this.uid] = this;
    padre.ultimoHijoCargado++;
    }
  this.strXML = '' 
 
  
}

function tNodo_eliminar(nodo,padre)
{
    if (padre) {
        delete padre.hijos[nodo.uid]
        padre.nhijos--
    }

   delete this.arbol.nodos[nodo.uid]
}

function tNodo_recargar(id)
  {
  
  }

function tNodo_select(selected)
  {
  this.selected = selected
  var rec = $('hqCELL' + this.uid)
  if (rec != null)
    if (selected)
      rec.addClassName('hqRec_sel')
    else 
      rec.removeClassName('hqRec_sel')
    
  }



//***************************************************************
// tNodo.Expand(): Se ejecuta cuando se hace click sobre una carpeta
//  Parametros: expand define si se fuerza una apertura o cierre de la carpeta
//  Salida: 
//****************************************************************

function tNodo_expand(expand)
  {
  var i;
  var Nodo = this
  if (this.tipo == 'carpeta')
    {
    if (this.arbol.bloq_contenedor != null && this.arbol.async && this.arbol.bloq_cont_id == '')
      {
      nvFW.bloqueo_activar(this.arbol.bloq_contenedor, "bt_" + Nodo.uid)
      this.arbol.bloq_cont_id = "bt_" + Nodo.uid
      }
    var funcExpand = function()
                        {
                        var divHijos = $('hijos' + Nodo.uid).up().up()
                        //si no viene el expand lo hace en función del estadoCarpeta
                        expand = expand == undefined ? Nodo.estadoCarpeta == 'cerrado' : expand
                        if (expand)
                            {
                            if ($('hijos' + Nodo.uid).innerHTML == '')
                            {
                            for (i in Nodo.hijos)
                                Nodo.hijos[i].MostrarNodo();
                            }  
        
                            divHijos.show()
                            Nodo.estadoCarpeta = 'abierto';
                            $('mm_' + Nodo.uid).src = Nodo.arbol.getURLImage("menos") //this.arbol.imagenes["menos"].src  
                            }
                        else
                            {
                            Nodo.estadoCarpeta = 'cerrado';
                            $('mm_' + Nodo.uid).src = Nodo.arbol.getURLImage("mas") //this.arbol.imagenes["mas"].src
                            divHijos.hide()
                            }
                        if (Nodo.arbol.bloq_contenedor != null && Nodo.arbol.async && Nodo.arbol.bloq_cont_id == "bt_" + Nodo.uid)
                          {
                          nvFW.bloqueo_desactivar(Nodo.arbol.bloq_contenedor, "bt_" + Nodo.uid)
                          Nodo.arbol.bloq_cont_id = ''
                          }

                        if (Nodo.arbol.onExpand != null)
                            Nodo.arbol.onExpand(Nodo)
                        }
    if (this.EstadoHijos != "cargado") 
       this.arbol.cargar_nodo(this.id, this,  funcExpand)
    else
      funcExpand()
    
    }
  }

//***************************************************************
// tNodo.Checking(): Se ejecuta cuando se hace click sobre una carpeta
//  Parametros: checking define si selecciona el nodo
//  Salida: 
//****************************************************************
//function tNodo_checking_hijos(nodo,valor)
//   {
//   debugger
//   var funComplete = function()
//                        {
//                        $('chck_' + nodo.uid).checked = valor
//                        nodo.checked = valor

//                        
//                        if ($('hijos' + nodo.uid).innerHTML == '')
//                          for (i in nodo.hijos)
//                            nodo.hijos[i].MostrarNodo();

//                        for (i in nodo.hijos)
//                          {
//                          if(nodo.hijos[i])
//                             tNodo_checking_hijos(nodo.hijos[i],valor)
//                          }
//    
////                        if (nodo.arbol.bloq_contenedor != null && nodo.arbol.async && nodo.arbol.bloq_cont_id == "bt_" + nodo.uid)
////                          {
////                          nvFW.bloqueo_desactivar(nodo.arbol.bloq_contenedor, "bt_" + nodo.uid)
////                          nodo.arbol.bloq_cont_id = ''
////                          }
//                        }
//   
////   if (nodo.arbol.bloq_contenedor != null && nodo.arbol.async && nodo.arbol.bloq_cont_id == '')
////     {
////     nvFW.bloqueo_activar(nodo.arbol.bloq_contenedor, "bt_" + nodo.uid)
////     nodo.arbol.bloq_cont_id= "bt_" + nodo.uid
////     }
//       
//   if (nodo.EstadoHijos != "cargado" && nodo.tipo == 'carpeta' && nodo.arbol.ChargeNodeOnchek)
//     nodo.arbol.cargar_nodo(nodo.id, nodo, funComplete)
//   else
//    funComplete()
//         
//    
//}

var valor_hijos = true
function tNodo_checking_return_valor_hijo(nodo,uid)
{
   for (i in nodo.hijos)
     if(nodo.hijos[i])
       tNodo_checking_return_valor_hijo(nodo.hijos[i],uid)

   if($('chck_' + nodo.uid) != null)
    if(!$('chck_' + nodo.uid).checked && nodo.uid != uid)
      valor_hijos = false
}

function tNodo_count_hijos_check(nodo)
  {
  var res = 0
  for (i in nodo.hijos)
    {
    if (nodo.hijos[i].checked)
      res++
    if (nodo.hijos[i].tipo == 'carpeta')
      res += tNodo_count_hijos_check(nodo.hijos[i])
    }
  return res
  }

 function tNodo_count_hijos(nodo)
  {
  var res = 0
  for (i in nodo.hijos)
    {
    res++
    if (nodo.hijos[i].tipo == 'carpeta')
      res += tNodo_count_hijos(nodo.hijos[i])
    }
  return res
  } 

function tNodo_checking_parent(nodo)
{
   //valor_hijos = true
   //tNodo_checking_return_valor_hijo(nodo,nodo.uid)
   if (nodo.tipo == 'carpeta')
     {
     var count_hijos_check = tNodo_count_hijos_check(nodo)
     var count_hijos = tNodo_count_hijos(nodo)

     var checked = count_hijos_check == count_hijos
     var indeterminate = count_hijos_check != count_hijos
   
     if($('chck_' + nodo.uid) != null)
       {
       $('chck_' + nodo.uid).checked = checked
       $('chck_' + nodo.uid).indeterminate = indeterminate
       nodo.checked = checked  
       nodo.indeterminate = indeterminate  
       }

     if(nodo.parent)
       tNodo_checking_parent(nodo.parent)
     }
}

function tNodo_checking(valor, noparent)
  {
  if (noparent == undefined)
    noparent = false
  var checking
  if (valor == undefined)
    {
    checking =  this.indeterminate || $('chck_' + this.uid).checked
    }
  else
    checking = valor
  this.indeterminate = false
  this.checked = checking 
  if ($("chck_" + this.uid) != null)
    $("chck_" + this.uid).checked = checking
  var nodo = this
  var funComplete = function()
                        {
                        for (i in nodo.hijos)
                          nodo.hijos[i].checking(checking, true)
                        } 
  
  if (this.EstadoHijos != "cargado" && this.tipo == 'carpeta' && this.arbol.ChargeNodeOnchek)
     this.arbol.cargar_nodo(this.id, this, funComplete)
  else
    funComplete()
//  if (this.tipo == "carpeta")
//    {
//    tNodo_checking_hijos(this,checking)
//    }
  
  //if(this.id == '0000')
  //  return
 
if (noparent == false)
    tNodo_checking_parent(this.parent)
}


//***************************************************************
//  tTree.AgregarNodo(): Agrega un nodo al arbol
//  Parametros: id      = (integer) Identificador del nodo
//              padre   = (objeto) Nodo del cual depende
//  Salida: Un objeto tNodo que controla el nodo.
//****************************************************************
/*
function tTree_AgregarNodo(id, padre)
{ 
  var nodo = new tNodo(this, id, padre);
  this.nodos[nodo.uid] = nodo;
  return nodo;
}
*/
//***************************************************************
//  tNodo.GenerarHTML(): Genera el codigo HTML que controla la visualización
//                del nodo
//  Parametros: 
//  Salida: (string) el codigo HTML correspondiente a al nodo.
//****************************************************************
function tNodo_GenerarHTML()
  {
  var strHTML
    
    strHTML =  '<table class="hqTB" cellspacing="0" cellpadding="0" ID="rec' + this.uid + '" noWrap>';
  
    
    //Imagenes que debe utilizar
    var IconoItem;
    var IconoArbol;

    if (this.imagen == "")
      this.imagen = "default"
   
    var src = this.arbol.getURLImage(this.imagen)
    if (src == "")
      {
      src = this.arbol.getURLImage("default")
      }

    if (src == "")
      alert("Error. No se encuentra la imagen '" + this.imagen + "'");
    else 
      IconoItem = src;
    
    if (this.tipo == 'carpeta')
    {  
      if (this.estadoCarpeta == 'cerrado')
        IconoArbol = this.arbol.getURLImage("mas") //this.arbol.imagenes["mas"].src
      else
        IconoArbol = this.arbol.getURLImage("menos") //this.arbol.imagenes["menos"].src;
    }
    else
    {
      IconoArbol = this.arbol.getURLImage("punto") //this.arbol.imagenes["punto"].src;
    }
    
    strHTML = strHTML + '<tr class="hqTR_Arbol"  id="hqTR' + this.uid + '" ><td nowrap="nowrap" class="hqCELL_Arbol" ';
	strHTML = strHTML + '><img border="0" style="vertical-align:middle" hspace="1" id="mm_' + this.uid + '"  name="mm_' + this.uid + '" src="' + IconoArbol + '" '
	if (this.tipo == "carpeta")
	  strHTML = strHTML + ' onClick="' + this.arbol.nombre + '.nodos[\'' + replace(this.id, "\\", "\\\\")  + '\'].expand();" ';
	strHTML = strHTML + '/>';
	if (this.checkbox == "habilitado")
	     {
          var checkear = this.checked == true ? 'checked' : ''
          strHTML = strHTML + '<input class="hqInputCheck" type="checkbox" id="chck_' + this.uid + '" onClick="' + this.arbol.nombre + '.nodos[\'' + replace(this.id, "\\", "\\\\")  + '\'].checking();" '+ checkear + '/>'
         } 
    strHTML = strHTML + '</td>';
    
    strHTML = strHTML + '<td style="white-space: nowrap" id="hqCELL' + this.uid + '" title="'+ this.title +'" class="hqCELL_TXT_MU" onmouseover="hqMO(event)" onmouseout="hqMU(event)" ';
    strHTML = strHTML + " nowrap>"
    strHTML = strHTML + "<span class='hqSpanImg' style=\"background-image:url('" + IconoItem + "') \" " + ' onmousedown="' + this.arbol.nombre + '.nodo_mousedown(event, \'' + replace(this.id, "\\", "\\\\") + '\', \'' + replace(this.uid, "\\", "\\\\") + '\' )"' + "></span><span class='hqSpanTxt' onmousemove='return quitar_seleccion()'" //<img border="0" align="absmiddle" hspace="1" src="' + IconoItem + '" alt="' + this.nombre + '" />
    if (this.accion.estado == "activo")
       strHTML = strHTML + ' onClick="' + this.arbol.nombre + '.nodos[\'' + replace(this.id, "\\", "\\\\") + '\'].accion.Ejecutar();" '; 
    strHTML += "/>" + this.nombre + "</span>";
    if (this.tipo=="carpeta")
      strHTML = strHTML + ' <span class="hqSPAN_Hijos">[' + this.nhijos + ']</span>';
    strHTML = strHTML + '</td></tr>';
    //hijos
    strHTML = strHTML + '<tr style="DISPLAY: none"><td style="WIDTH: 40px;"></td><td class="hqCELL_Hijos" colspan="2"><div id="hijos' + this.uid + '"></div></td></tr></table>'
    
    return strHTML;
  }

//***************************************************************
//  tNodo.MostrarNodo(): Hace visible el nodo
//  Parametros: 
//  Salida: 
//****************************************************************
function tNodo_MostrarNodo()
{
  //Escribe en el objeto contenedor el codigo HTML
  //correspondiente al nodo
  var arbol = this.arbol;
  if (this.parent.id != arbol.id)
    var Contenedor = $('hijos' + this.parent.uid) //var Contenedor = eval('document.all.hijos' + this.parent.uid)
  else  
    var Contenedor = $(arbol.canvas);
  Contenedor.insert({bottom: this.GenerarHTML()})

  //Si el nodo es una carpeta y ademas esta abierta, mostrar
  //los hijos del nodo
  var i;
  if (this.estadoCarpeta == 'abierto')
     this.expand(true)

  if (this.estadoCarpeta == 'cerrada' && this.checkbox == "habilitado" && this.checked)
     this.checking()

  /*if ((this.tipo == "carpeta") && (this.estado == "abierto"))
      for (i in this.hijos)
        this.hijos[i].MostrarNodo()  
  */
}  

//***************************************************************
//  tTree.MostrarArbol(): Hace visible el arbol por primera vez
//  Parametros:
//  Salida: 
//****************************************************************
function tTree_MostrarArbol()
{
  $(this.canvas).innerHTML = ''
  for (i in this.nodos)
    if (this.nodos[i].parent != undefined)
      if (this.nodos[i].parent.id == this.id)
        this.nodos[i].MostrarNodo();
}


//***************************************************************
//  CargarXML(): Carga todos los items del XML como
//          hijos del padre dado
//
//  Salida: 
//****************************************************************
function tNodo_cargar_nodo(XML)
  {
  this.arbol.cargar_nodo(XML, this)
  }

/*
function tTree_CargarXML(XML, padre)
{
  var NOD;
  var objXML;
  if (typeof(strXML) == 'object')
    objXML = XML //this.CargaXMLTerminada(strXML)
  else
    {  
    var oXML = new tXML()
    oXML.async = false;
    oXML.loadXML(XML)
    objXML = oXML.xml
    }  
 
    
  NOD = selectSingleNode('resultado/nodo', objXML);
  if (NOD != null)
    {
	//padre = this.CargarItem(NOD, padre)
	
	if (padre != undefined)
      padre.EstadoHijos = "cargado"  
    
    var hijos = selectNodes('nodo', NOD)
	  for(var i=0;i < hijos.length;i++)
	    this.CargarItem(hijos[i], padre)
	    
	
	}      
      
}
*/

//***************************************************************
//  CargarItem(): Carga el Nodo XML como hijos del padre dado   
//  Parametros:
//             NOD:  (objeto) Nodo XML
//             padre: (objeto tNodo) Objeto tNodo
//  Salida: 
//****************************************************************
function tTree_crear_nodo(NOD, padre)
  {
  var id = selectSingleNode('@id', NOD).nodeValue;
  //Crea el nodo y lo agrega a la coleccion nodos
  var Nodo = new tNodo(this, id, padre);
  this.nodos[Nodo.id] = Nodo;
  
   Nodo.strXML = XMLtoString(NOD)
  
  Nodo.accion.TipoLib = 'offLine'//NOD.selectSingleNode(@origen);
  //Nodo.accion.parametros['Lib'] = NOD.childNodes[0].text;
  Nodo.TipoItem = selectSingleNode('@tipo', NOD).value;
  Nodo.imagen = selectSingleNode('@tipo', NOD).value.toLowerCase();
  if (selectSingleNode('@icono', NOD) != null)
    if (selectSingleNode('@icono', NOD).value != "")
      Nodo.imagen = selectSingleNode('@icono', NOD).value.toLowerCase();
  Nodo.nombre = selectSingleNode('@desc', NOD).value;
  Nodo.nhijos = selectSingleNode('@hijos', NOD).value;
  Nodo.checkbox = selectSingleNode('@checkbox', NOD) == null ? "no-habilitado" : selectSingleNode('@checkbox', NOD).value;
  Nodo.checked = selectSingleNode('@checked', NOD) == null ? false : eval(selectSingleNode('@checked', NOD).value)
  if (padre != undefined)
    if (padre.checked == true)
      Nodo.checked = true
  Nodo.title = selectSingleNode('@title', NOD) == null ? "" : selectSingleNode('@title', NOD).value
  
  if (selectNodes('Acciones/Ejecutar', NOD).length == 0)
    Nodo.accion.estado = "no-activo"
  else  
    {
    Nodo.accion.estado = "activo";
    Nodo.accion.parametros['xml'] = XMLtoString(selectSingleNode('Acciones', NOD));
    }
  
  var estadoCarpeta = "cerrado"
  //Si existe el nodo en la tabla de copia conservar el estado 
  //Esto es para el caso de las recargas
  if (this.nodos_copia[Nodo.id] != undefined)
    estadoCarpeta = this.nodos_copia[Nodo.id].estadoCarpeta

    
  Nodo.estadoCarpeta  = estadoCarpeta;
  if (Nodo.nhijos > 0) 
    Nodo.tipo    = "carpeta"
  else
    Nodo.tipo    = "hoja";       
  return Nodo
  }

function hqMO(e)
{
  obj = Event.element(e)
  while (obj.className.indexOf("hqCELL_TXT_MU") >= 0)
    {obj = obj.up()}
  obj.addClassName("hqCELL_TXT_MO")  
}

function hqMU(e)
{
  obj = Event.element(e)
  while (obj.className.indexOf("hqCELL_TXT_MU") >= 0)
    {obj = obj.up()}
  obj.removeClassName("hqCELL_TXT_MO")  
}

function IdentificadorUnico()
{
var ui = "";
for (var i=0; i<4;i++)
  ui = ui + String.fromCharCode(Math.round(Math.random()* 25 + 65))
var a = new Date();
ui = ui + a.getMilliseconds();  
return ui
  
}



/************************************************************/
// DRAG AND DROP para el tTree
/************************************************************/
var dad_div = null //Div que sigue el cursor simulando el arrastre
var dad_x //x original del arrastre
var dad_y //y original del arrastre
var dad_drag_over_element = null //elemento sobre el que estamos pasando
var dad_drag_nodo = null //Nodo que arrastramos


//Funcion de comienzo del dad
//Inicializa las variables necesarias para el proceso
function tTree_nodo_mousedown(e, id, uid)
  {
  if (!Event.isLeftClick(e) || this.dad_drop == null) return
    
  if (dad_div == null)
    {
    dad_div = $('dad_div')
    if (dad_div == null)
      {
      var strHTML = "<div id='dad_div' style='display: none; position: absolute; float: left; border: none '>"
      $$('BODY')[0].insert({top: strHTML})
      dad_div = $('dad_div')
      dad_div.setOpacity(this.dad_opacity)
      }
    }
  
  var tr = Event.element(e)  
  while(tr.tagName != 'TR')
    tr = tr.up()
    
  window.status = tr.id
  //remover los id del HTML
  var strreg = "id\\S*=\\S*[^\\S]"  
  var reg = new RegExp(strreg, "ig")
  var strHTML_tr = '<table class="hqTB" cellspacing="0" cellpadding="0" noWrap>' + tr.innerHTML.replace(reg, '') + '<table>'

  //remover los name del HTML
  strreg = "name\\S*=\\S*[^\\S]"  
  reg = new RegExp(strreg, "ig")
  strHTML_tr = strHTML_tr.replace(reg, '')
  
  dad_div.innerHTML = strHTML_tr
  
  //dad_div.clonePosition(tr, {setTop: false, setLeft: false})
  dad_div.setStyle({width: tr.getWidth() + 'px', height: tr.getHeight() + 'px'})
  
  dad_x = Event.pointerX(e)
  dad_y = Event.pointerY(e)
  dad_drag_nodo = this.nodos[id]
  return true
  }
  
//Analiza el mouse move el documento, si hay un arrastre definido lo mueve
//Analiza el elemento sobre el que pasa para ver si cumple con la condición de destino
function dad_win_mousemove(e)
  {
  if (dad_div != null)
    {
    //Mover div
    dad_div.show()
    var difX = dad_x - Event.pointerX(e) - 5
    var difY = dad_y - Event.pointerY(e) + (dad_div.getHeight() /2 ) 
    dad_div.setStyle({top: dad_y - difY + 'px', left: dad_x - difX + 'px'})
    
    quitar_seleccion()
    
    //Controlar drop
    //Evaluar si el elemento o algun antecesor del elemento cumple la condición eval
    //Evaluar hasta que el elemento se haga nulo o se llegue hasta el "document"
    var element = Event.element(e)
    
    while (element != null && !element.body && !eval(dad_drag_nodo.arbol.dad_drop_eval))
      element = element.up()
    if (!!element.body)
      element = null
    
    //Si es distinto al ya tomado
    if (element != dad_drag_over_element)
      {
      //si había uno tomado hacer el over_out
      if (dad_drag_over_element != null)
        dad_drag_over_out(e, dad_drag_over_element)
      //si hay un elemento nuevo hacer el over  
      if (element != null)
        dad_drag_over(e, element)
      }  
    }
  }

//Analiza el mouseup del documento, si hay un arrastre definido y no hay elemento destino lo deshace.
//Sino ejecuta el drop
function dad_win_mouseup(e)
  {
  if (dad_div != null)
    {
    if (!!document.all)
      document.selection.clear()
    else
      window.getSelection().removeAllRanges()  
    if (dad_drag_over_element != null)
      {
      var dad_drop_nodo
      if (dad_drag_over_element.hasClassName('hqTR_Arbol'))
        {
        //recuperar el id del nodo destino
        var uid = dad_drag_over_element.id.substring(4, 100)
        //si el nodo pertenece al mismo arbol
        if (dad_drag_over_element.id.indexOf(dad_drag_nodo.arbol.uid) == 4)
          {
          dad_drop_nodo = dad_drag_nodo.arbol.nodos[dad_drag_nodo.arbol.id_to_uid(uid)]
          } 
        }
      dad_drag_nodo.arbol.dad_drop(e, dad_drag_nodo, dad_drag_over_element, dad_drop_nodo)
      dad_drag_over_out(e, dad_drag_over_element)
      }
    //Limpiar todo  
    dad_div.hide()
    dad_div = null
    dad_drag_nodo = null
    dad_drag_over_element = null
    dad_x = null
    dad_y = null  
    }
  }
 
//Cuando pasa sobre un elemento destino 
function dad_drag_over(e, element)
  {
  dad_drag_over_element = element
  if (dad_drag_nodo.arbol.dad_drag_over != null)
    dad_drag_nodo.arbol.dad_drag_over(e, element)
  //element.addClassName('dad_tr_drag_over')
  }
  
//Cuando sale del elemento destino seleccionado 
var dad_drag_over_out = function(e, element)
  {
  dad_drag_over_element = null
  if (dad_drag_nodo.arbol.dad_drag_over_out != null)
    dad_drag_nodo.arbol.dad_drag_over_out(e, element)
  //element.removeClassName('dad_tr_drag_over')
  }
function quitar_seleccion()
  {
  //Limpiar seleccion
  if (!!document.all)
    document.selection.clear()
  else
    window.getSelection().removeAllRanges()   
  }
/*
function dad_win_keydown(e)
  {
  var body = $$("BODY")[0]
  body.removeClassName('dad_body_move')
  body.removeClassName('dad_body_copy')
  if (dad_div != null)
    {
    
    e = !window.event ? e : window.event
    if (e.ctrlKey == 1)
      body.addClassName('dad_body_copy')
    else  
      body.addClassName('dad_body_move')
    }
  }
  
function dad_win_keyup(e)
  {
  
  }  
  */
function tTree_loadImage(name, url, preLoad)
  {
  if (!this.imagenes)
    this.imagenes = {}
  
  this.imagenes[name] = {}
  this.imagenes[name].src = url
  }

function tTree_getURLImage(icono)
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
  
//Evaluaciones globales del documento  
Event.observe(document, 'mousemove', dad_win_mousemove)
Event.observe(document, 'mouseup', dad_win_mouseup)
//Event.observe(document, 'keydown', dad_win_keydown)
//Event.observe(document, 'keyup', dad_win_keyup)