/*******************************************************/
// Objeto que permite agregar campos de ordenamiento 
//y filtrado dentro de las paginas
/*******************************************************/
function tCampo_head()
  {
  this.items = new Array();
  this.agregar = head_agregar; //Inserta el campo head
  this.orden =  '' //Mantiene el �ltimo orden aplicado
  this.divHead_filtro = null //div con las opciones de filtro
  this.divHead_vidrio = null //Vidrio para capturar el click divHead_vidrio
  
  this.reordenar = head_reordenar //Rreordena el resultado
  this.pagina_cambiar = head_pagina_cambiar //cambia la pagina 
  this.paginas_getHTML = head_paginas_getHTML
  this.paginas_precarga_getHTML = head_paginas_precarga_getHTML
  this.id_exp_origen = 0 //Variable de control, identifica la extracci�n
  this.cacheID = '' //Propiedad que indica que el resultado esta asociado a una cache
  
  this.filtrar_personalizar = head_filtrar_personalizar; //Filtro personalizado
  this.filtro_click = head_filtro_click; //Click  inicial en el icono
  this.filtro_option_click = head_filtro_option_click; //Seleccion del option
  this.filtro_click_out = head_filtro_click_out;// Click fuera del div
  
  this.filtrar_add = head_filtrar_add; //Agregar/Quitar filtro
  
  this.resize = head_resize;
  
  
  this.nvFW = null
  }



//Genera el HTML para mostrar y agrega el elemento a la colecci�n items
function head_agregar(etiqueta, btn_orden, campo, btn_filtro, campo_def)
  {
  if (btn_filtro == undefined)
    btn_filtro = false
  if (!campo_def)  
    campo_def = ''
  this.items[etiqueta] = new Array()
  this.items[etiqueta]['btn_orden'] = btn_orden
  this.items[etiqueta]['campo'] = campo
  this.items[etiqueta]['btn_filtro'] = btn_filtro
  this.items[etiqueta]['campo_def'] = campo_def

  var strHTML = ''
  if (btn_orden)
    strHTML += '<img src="/FW/image/icons/down_a.png"  onclick="campos_head.reordenar(\'DESC\',\'' + etiqueta + '\')"  style="cursor: hand"/><img src="/FW/image/icons/up_a.png" onclick="campos_head.reordenar(\'\', \'' + etiqueta + '\')" style="cursor: hand"/> '
  strHTML += etiqueta
  if (btn_filtro)
    strHTML += '&nbsp;<img src="/FW/image/icons/filtro10.png"  onclick="campos_head.filtro_click(\'' + etiqueta + '\')"  style="cursor: hand"/>'
  strHTML = '<span id="spnHead_' + etiqueta + '">' +  strHTML + '</span>'
  document.write(strHTML)
  this.items[etiqueta]['strHTML'] = strHTML
  return strHTML
  }


//Recupera el orden original y lo modifica para cumplir con el nuevo orden					
function head_reordenar(orden, etiqueta)
  {
  var filtroWhere = ""
  if (this.nvFW != null)
    {
    filtroWhere =  this.nvFW.reporte_parametro[this.id_exp_origen].filtroWhere
    }
  else
    {  
    var rs = new tRS();
    //rs.cn = '/meridiano/GetXML.asp?accion=GETXML&criterio='
    var strXML = "<criterio><select vista='exp_origen_log'><campos>*</campos><filtro><id_exp_origen type='igual'>" + this.id_exp_origen + "</id_exp_origen></filtro></select></criterio>"
    rs.open(strXML)
    filtroXML = rs.getdata('filtroWhere')
    }
  
  
  if (filtroWhere == "" || filtroWhere == undefined)
     filtroWhere = "<criterio><select><orden></orden></select></criterio>"
  var objXML = new tXML()
  objXML.async = false
  objXML.loadXML(filtroWhere)
  /*******************************/
  // Controlar si tiene cache
  // Si escape asi colocar el cacheID
  /*******************************/
  //  debugger
  //  if (typeof(this.cache) == 'object')
  //    {
  //    var att_cacheID = objXML.selectSingleNode('criterio/select/@cacheID')
  //    if (att_cacheID == null)
  //      {
  //      nod = objXML.selectSingleNode('criterio/select')
  //      nod.setAttribute('cacheID', this.cache.cacheID)
  //      }
  //    else  
  //      att_cacheID.nodeValue = this.cache.cacheID
  //    }   
  
  
  /***********************************/
  // Ajustar orden /criterio/select/orden
  /***********************************/
  var NOD = objXML.selectSingleNode('/criterio/select')
  if (NOD == null)
    {
    NOD = objXML.xml.createElement("select")
    objXML.selectSingleNode('/criterio').appendChild(NOD)
    }

  NOD = objXML.selectSingleNode('/criterio/select/orden')
  if (NOD == null)
    {
    NOD = objXML.xml.createElement("orden")
    objXML.selectSingleNode('/criterio/select').appendChild(NOD)
    }
  
  //Eliminar el campo si ya existe
  var strreg = '(^|\\s|,)' + this.items[etiqueta]['campo'] + '(\\s|,|$)(DESC)?' 
  var reg = new RegExp(strreg, 'ig')
  this.orden = this.orden.replace(reg, '')

  //Eliminar doble coma ",,"
  strreg = ',\\s*,' 
  reg = new RegExp(strreg, 'ig')
  this.orden = this.orden.replace(reg, ',')

  //Eliminar coma al inicio
  strreg = '^\\s*,' 
  reg = new RegExp(strreg, 'ig')
  this.orden = this.orden.replace(reg, '')

  //Eliminar coma al final
  strreg = ',\\s*$' 
  reg = new RegExp(strreg, 'ig')
  this.orden = this.orden.replace(reg, '')

  if (this.orden =='')
    this.orden += this.items[etiqueta]['campo'] + ' ' + orden 
  else
    this.orden = this.items[etiqueta]['campo'] + ' ' + orden + ', ' + this.orden
  
  if (!!document.all)
    NOD.text = this.orden
  else
    NOD.textContent = this.orden
  
  if (this.nvFW != null)
    {
    this.nvFW.reporte_parametro[this.id_exp_origen].filtroWhere = objXML.toString()
    this.nvFW.exportarReporte({nvFW_mantener_origen: true,
                               id_exp_origen : this.id_exp_origen})
    }
  else  
    nvFW.exportarReporte({filtroXML : rs.getdata('filtroXML'),
                        filtroWhere: objXML.toString(),
                        VistaGuardada: rs.getdata('VistaGuardada'),
                        xsl_name  : rs.getdata('xsl_name'),
                        path_xsl: rs.getdata('path_xsl'),
                        ContentType: rs.getdata('ContentType'),
                        destinos: rs.getdata('target'),
                        salida_tipo: rs.getdata('salida_tipo'),
                        parametros: rs.getdata('parametros'),
                        formTarget : "",
                        mantener_origen: 'true',
                        id_exp_origen : this.id_exp_origen,
                        cls_contenedor: document.body 
                         
                        })
  
    
  }

			
//Dibuja el div con las opciones de filtrado al hacer chlick en el icono de filtro			
function head_filtro_click(etiqueta)
  {
  var div_id = 'divHead_filtro_' + etiqueta
  var select_id = 'divHead_filtro_select_' + etiqueta
  var span_id ='spnHead_' + etiqueta 
  var div_vidrio = $('divHead_vidrio')
  var div = $(div_id)
  var span = $(span_id)
  if (div == null)
    {
    var strHTML = "<div id='" + div_id + "' style='position: absolute; float: left; z-index: 2; width: 150px; display:none; '><select id='" + select_id + "' onclick='campos_head.filtro_option_click(event, \"" + etiqueta + "\")' style='width: 100%' size='5' ><option value='0'>Orden ascendente</option><option value='1'>Orden descendente</option><option value='-1'>-----------------------------</option><option value='2'>Todas</option><option value='3'>Personalizado</option></select>"
    strHTML += '</div>'  
      
    if (div_vidrio == null)
      strHTML += "<div id='divHead_vidrio' onclick='head_filtro_click_out()' style='position: absolute; float: left; z-index: 1; width: 100%; heigth: 100%; background-color: blue;'></div>"
    
    $$('BODY')[0].insert({top: strHTML})
    div = $(div_id)
    div_vidrio = $('divHead_vidrio')
    var campo_def = campos_head.items[etiqueta].campo_def
    if (campo_def != '')
      {
      campos_defs.add(campo_def, {target: div_id}) 
      campos_defs.items[campo_def]["onchange"] = function(e, campo_def)
                                                   {
                                                   head_campo_def_click(e, campo_def, etiqueta)
                                                   } 
      //debugger
      //campo_def_onclick(null,campo_def)                                             
      }
    }
  
  div_vidrio.setOpacity(0.01)
  div_vidrio.clonePosition($$('BODY')[0])
  div_vidrio.show()
  
  div.clonePosition(span, {setHeight: false, setWidth: false, offsetTop: span.getHeight()})  
  div.show()
  
  this.divHead_filtro = div
  this.divHead_vidrio = div_vidrio
  }					  
  

function head_filtro_option_click(e, etiqueta)
  {
  var select_id = 'divHead_filtro_select_' + etiqueta
  var div_id = 'divHead_filtro_' + etiqueta
  var select = $(select_id)
  var div = $(div_id)
  //var div = Event.element(e)
  //while (div.tagName != 'DIV') 
    //div = div.parentNode
  if (div != null)
    {
    var value = parseInt(select.options[select.selectedIndex].value)
    head_filtro_click_out()
    switch (value)
      {
      case 0:
        this.reordenar('', etiqueta)
        break
      case 1:
        this.reordenar('DESC', etiqueta)
        break
      case 2:
        //Todas
        this.filtrar_add(etiqueta, '')
        break
      case 3:
        this.filtrar_personalizar(etiqueta)
              
      }
    }
  }

//Oculta el div de opciones de filtrado
function head_filtro_click_out()
  {
  try
    {
    campos_head.divHead_filtro.hide()
    campos_head.divHead_vidrio.hide()
    }
  catch(e){}  
  } 
  
   
  
//Genera un nuevo filtro sobre la consulta actual
function head_filtrar_add(etiqueta, strAdd)
  {
  
  if (this.nvFW != null)
    {
    var oParametros = this.nvFW.reporte_parametro[this.id_exp_origen]
    var filtroXML =  oParametros.filtroXML 
    var strParametros = oParametros.parametros
    }
  else
    {
    var rs = new tRS();
    //rs.cn = '/meridiano/GetXML.asp?accion=GETXML&criterio='
    var strXML = "<criterio><select vista='exp_origen_log'><campos>*</campos><filtro><id_exp_origen type='igual'>" + this.id_exp_origen + "</id_exp_origen></filtro></select></criterio>"
    rs.open(strXML)
    var filtroXML = rs.getdata('filtroXML')  
    var strParametros =  rs.getdata('parametros')
    }
    
  if (strParametros == null || strParametros == '' || strParametros == undefined) //Si No existe
      strParametros = '<parametros></parametros>'  
    
    var oXML = new tXML()
    if (oXML.loadXML(strParametros))  
      {
      //busca los parametros del filtrado, si no existen los inicializa
      var head_filtro = oXML.selectSingleNode("/parametros/head_filtro")
      if (head_filtro == null)
        {
        oXML = head_crear_parametros(oXML)
        head_filtro = oXML.selectSingleNode("/parametros/head_filtro")
        }
      //Se guarda en prametros el filtrado original
      
      //var filtroXML = head_filtro.getAttribute('filtroXML') //oXML.selectSingleNode("/parametros/head_filtro/@filtroXML")
      if (head_filtro.getAttribute('filtroXML') == '')
        head_filtro.setAttribute('filtroXML', filtroXML)
        
      //Porci�n de filtro agregado  
      //var filtroAdd = head_filtro.getAttribute(filtroAdd) //oXML.selectSingleNode("/parametros/head_filtro/@filtroAdd")
      var filtroAdd_anterior = head_filtro.getAttribute('filtroAdd') 
      
      //Filtro de la etiqueta seleccionada
      //var filtroEtiqueta = oXML.selectSingleNode("/parametros/head_filtro/etiquetas/@" +  etiqueta)
      var etiquetas = oXML.selectSingleNode("/parametros/head_filtro/etiquetas")
      if (oXML.selectSingleNode("/parametros/head_filtro/etiquetas/@" +  etiqueta) == null)
        {
        etiquetas.setAttribute(etiqueta, '')
        //var filtroEtiqueta = oXML.selectSingleNode("/parametros/head_filtro/etiquetas/@" +  etiqueta)
        }
      
        
      //Elimiar filtro agregado de filtroXML
      if (head_filtro.getAttribute('filtroAdd') != '')
        filtroXML = replace(filtroXML,'<AND>' + head_filtro.getAttribute('filtroAdd') + '</AND>', '')
      
      
      /**************  Editar filtroAdd  ******************/
      //Eliminar filtro de la etiqueta del filtroAdd
      if (etiquetas.getAttribute(etiqueta) != '')
        head_filtro.setAttribute('filtroAdd', replace(head_filtro.getAttribute('filtroAdd'), etiquetas.getAttribute(etiqueta), ''))
        
      //Insertar filtro nuevo en filtroAdd
      etiquetas.setAttribute(etiqueta, strAdd)
      head_filtro.setAttribute('filtroAdd', head_filtro.getAttribute('filtroAdd') + strAdd)
      
      //Si hubo cambio de filtro
      if (filtroAdd_anterior == head_filtro.getAttribute('filtroAdd'))
        head_filtro_click_out()
      else  
        {
        if (head_filtro.getAttribute('filtroAdd') != '')
          {
          var strReg = "</filtro>"
          var reg = new RegExp(strReg, 'ig') 
          var res = filtroXML.match(reg)
          if (res == null)
            filtroXML = filtroXML.replace('</select>', '<filtro><AND>' + head_filtro.getAttribute('filtroAdd') + '</AND></filtro></select>')
          else
            filtroXML = filtroXML.replace('</filtro>', '<AND>' + head_filtro.getAttribute('filtroAdd') + '</AND>' + '</filtro>')
          }
        //guardar el fitltroXML modificado
        head_filtro.setAttribute('filtroXML', filtroXML)
        strParametros = oXML.toString()
        if (this.nvFW != null)
          {
          oParametros.parametros = strParametros
          oParametros.filtroXML = filtroXML
          this.nvFW.exportarReporte({nvFW_mantener_origen: true,
                               id_exp_origen : this.id_exp_origen})
          }
        else
          nvFW.exportarReporte({filtroXML : filtroXML,
                        filtroWhere: rs.getdata('filtroWhere'),
                        VistaGuardada: rs.getdata('VistaGuardada'),
                        xsl_name  : rs.getdata('xsl_name'),
                        path_xsl: rs.getdata('path_xsl'),
                        ContentType: rs.getdata('ContentType'),
                        destinos: rs.getdata('target'),
                        salida_tipo: rs.getdata('salida_tipo'),
                        parametros: strParametros   ,
                        formTarget : "",
                        mantener_origen: 'true',
                        id_exp_origen : this.id_exp_origen,
                        cls_contenedor: document.body
                        })                       
        }
      
                                 
      
      }
    }
  

  
  function head_campo_def_click(e, campo_def, etiqueta)
    {
    var strAdd = eval("'" + campos_defs.filtroWhere(campo_def) + "'")
    campos_head.filtrar_add(etiqueta, strAdd)
    
    }
    
  function head_filtrar_personalizar()
    {}  
    
  function head_crear_parametros(oXML)  
    {
    var raiz = oXML.selectSingleNode("/parametros")
    var nod = oXML.xml.createElement('head_filtro')
    var head_filtro = raiz.appendChild(nod)
    head_filtro.setAttribute('filtroXML', '')
    head_filtro.setAttribute('filtroAdd', '')
    nod = oXML.xml.createElement('etiquetas')
    var etiquetas = head_filtro.appendChild(nod)
    
    return oXML
    }

function head_pagina_cambiar(AbsolutePage)
  {
  if (AbsolutePage > this.PageCount)
      AbsolutePage = this.PageCount
  if (AbsolutePage == '')
      AbsolutePage = 1
  if (AbsolutePage == 0)  
      AbsolutePage = 1
  if (this.nvFW != null) {
          var filtroWhere = this.nvFW.reporte_parametro[this.id_exp_origen].filtroWhere
  }
  else {
          var rs = new tRS();
          //rs.cn = '/meridiano/GetXML.asp?accion=GETXML&criterio='
          var strXML = "<criterio><select vista='exp_origen_log'><campos>*</campos><filtro><id_exp_origen type='igual'>" + this.id_exp_origen + "</id_exp_origen></filtro></select></criterio>"
          rs.open(strXML)
          var filtroWhere = rs.getdata('filtroWhere')
  }
 

  if (filtroWhere == "" || filtroWhere == undefined)
     filtroWhere = "<criterio><select></select></criterio>"

  var objXML = new tXML()
  objXML.async = false
  objXML.loadXML(filtroWhere)

  /***********************************/
  // Ajustar orden /criterio/select/orden
  /***********************************/
  var NOD = objXML.selectSingleNode('/criterio/select')
  var NOD2 = objXML.selectSingleNode('/criterio/procedure')
  if (NOD == null && NOD2 == null)
    {
    NOD = objXML.xml.createElement("select")
    objXML.selectSingleNode('/criterio').appendChild(NOD)
    }

  /*******************************/
  // Controlar si tiene cache
  // Si escape asi colocar el cacheID
  /*******************************/
  var tipo = objXML.selectNodes("criterio/select").length == 0 ? 'procedure' : 'select'
  
  if (this.cacheID != '') {
      var att_cacheID = objXML.selectSingleNode('criterio/' + tipo + '/@cacheID')
      if (att_cacheID == null) {
          nod = objXML.selectSingleNode('criterio/' + tipo)
          nod.setAttribute('cacheID', this.cacheID)
      }
      else
          att_cacheID.nodeValue = this.cacheID
  }

  var att_AbsolutePage = objXML.selectSingleNode('criterio/' + tipo + '/@AbsolutePage')
  if (att_AbsolutePage == null)
    {
    nod = objXML.selectSingleNode('criterio/' + tipo)
    nod.setAttribute('AbsolutePage', AbsolutePage)
    }
  else
    att_AbsolutePage.nodeValue =  AbsolutePage

  
  if (this.nvFW != null)
    {
    this.nvFW.reporte_parametro[this.id_exp_origen].filtroWhere = objXML.toString()
    this.nvFW.exportarReporte({nvFW_mantener_origen: true,
                             id_exp_origen : this.id_exp_origen})
    }
  else  
    nvFW.exportarReporte({filtroXML : rs.getdata('filtroXML'),
                      filtroWhere: objXML.toString(),
                      VistaGuardada: rs.getdata('VistaGuardada'),
                      xsl_name  : rs.getdata('xsl_name'),
                      path_xsl: rs.getdata('path_xsl'),
                      ContentType: rs.getdata('ContentType'),
                      destinos: rs.getdata('target'),
                      salida_tipo: rs.getdata('salida_tipo'),
                      parametros: rs.getdata('parametros'),
                      formTarget : "",
                      mantener_origen: 'true',
                      id_exp_origen : this.id_exp_origen,
                      cls_contenedor: document.body 
                      })
  

  }      

function head_resize(idHead, idBody)
  {
  var oHead = $(idHead)
  var oBody = $(idBody)

  if (oHead == undefined || oBody == undefined)
    return 

  var colHead = oHead
  while (colHead.nodeName.toUpperCase() != "TR" && $(colHead).childElements().length>0 )
    colHead = $(colHead).childElements()[0]
  
  var colBody = oBody
  while (colBody.nodeName.toUpperCase() != "TR" && $(colBody).childElements().length>0 )
    colBody = $(colBody).childElements()[0]
  
  if ((colBody.nodeName.toUpperCase() != "TR") || (colHead.nodeName.toUpperCase() != "TR"))
    return 

  var divBody = $(oBody.parentNode)
  

  var colWidth
  var tbBodyWidth = oBody.getWidth()
  var scrollWidth = divBody.getWidth() - tbBodyWidth
  //for (var i=0; i<colHead.childElements().length;i++)
  //  {
  //  colWidth = $(colBody.childElements()[i]).getWidth() 
  //  if (i == colBody.childElements().length-1) 
  //    colWidth += scrollWidth
  //  $(colHead.childElements()[i]).setStyle({width: colWidth+"px"})
  //  colWidth = $(colHead.childElements()[i]).getWidth()
  //  }

    //var strHTML = "<thead>" + colHead.outerHTML + "</thead>"
    //Eliminar la tabla de cabecera
    //oHead.parentNode.removeChild(oHead)
    //Insertar la cabecera en la tabla
    //oBody.insertAdjacentHTML('afterbegin', strHTML)
    //oBody.setStyle({height: divBody.getHeight() + "px"})
    //$(oBody).setStyle({display: "block"})
    //$(oBody.getElementsByTagName("thead")[0]).setStyle({display: "block", width: "100%", border:"solid blue 1px"})
    //$(oBody.getElementsByTagName("tbody")[0]).setStyle({display: "block", width: "100%", overflow: "auto", border:"solid blue 1px"})




    //var colBody = oBody.childElements()[0]
    //while (colBody.nodeName.toUpperCase() != "TR")
    //  colBody = $(colBody).childElements()[0]


    for (var i=0; i<colHead.childElements().length-1;i++)
    {
    $(colBody.childElements()[i]).setStyle({width:$(colHead.childElements()[i]).getWidth() + "px"})
    //$(colBody.childElements()[i]).clonePosition($(colHead.childElements()[i]), {setLeft:false, setTop:false, setHeight:false})
    //colWidth = $(colBody.childElements()[i]).getWidth() 
    //if (i == colBody.childElements().length-1) 
    //  colWidth += scrollWidth
    //$(colHead.childElements()[i]).setStyle({width: colWidth+"px"})
    //colWidth = $(colHead.childElements()[i]).getWidth()
    }
  return ""

  }   


function head_paginas_getHTML()
  {
    var strHTML = "<table class='tbPages' style='bottom: 1px; position: absolute;'><tr>"
  if (this.AbsolutePage > 1)
    strHTML += "<td><a href='javascript:campos_head.pagina_cambiar(1)'>&lt;&lt;</a></td>"
  else
    strHTML += "<td>&lt;&lt;</td>"
                      
  if (this.AbsolutePage > 1)
    strHTML += "<td><a href='javascript:campos_head.pagina_cambiar(" + (this.AbsolutePage-1) + ")'>&lt;</a></td>"
  else
    strHTML += "<td>&lt;</td>"
  for (var i=1; i<=this.PageCount;i++)
    {
    if (this.AbsolutePage == i)
      strHTML += "<td class='tdPageSelected'> " + i + "</td>"
    else  
      strHTML += "<td><a href='javascript:campos_head.pagina_cambiar(" + i + ")'>" + i + "</a></td>"
    }
  if (this.AbsolutePage < this.PageCount)  
    strHTML += "<td><a href='javascript:campos_head.pagina_cambiar(" + (this.AbsolutePage+1) + ")'>&gt;</td>"
  else  
    strHTML += "<td>&gt;</td>"
  if (this.AbsolutePage < this.PageCount)  
    strHTML += "<td><a href='javascript:campos_head.pagina_cambiar(" + this.PageCount + ")'>&gt;&gt;</td>"
  else  
    strHTML += "<td>&gt;&gt;</td>"
  strHTML += "</tr></table>"

  return strHTML
}

function head_paginas_precarga_getHTML() {
    var strHTML = "<table class='tbPages' style='bottom: 1px;'><tr>"
    if (this.AbsolutePage > 1)
        //strHTML += "<td onclick='campos_head.pagina_cambiar(1)' style='cursor:pointer' class='tbPagesArrow'><b>&nbsp;&lt;&lt;&nbsp;</b></td>"
        strHTML += "<td onclick='campos_head.pagina_cambiar(1)' style='cursor:pointer'><img class='img_buttonArrow' src='/precarga/image/left-arrow-doble.png' border='0' align='absmiddle' hspace='0'/></td>"
    else
        //strHTML += "<td class='tbPagesArrow'>&nbsp;&lt;&lt;&nbsp;</td>"
        strHTML += "<td><img class='img_buttonArrow' src='/precarga/image/left-arrow-doble.png' border='0' align='absmiddle' hspace='0'/></td>"
    if (this.AbsolutePage > 1)
        //strHTML += "<td onclick='campos_head.pagina_cambiar(" + (this.AbsolutePage - 1) + ")' style='cursor:pointer' class='tbPagesArrow'><b>&lt;</b></td>"
        strHTML += "<td onclick='campos_head.pagina_cambiar(" + (this.AbsolutePage - 1) + ")' style='cursor:pointer'><img class='img_buttonArrow' src='/precarga/image/left-arrow.png' border='0' align='absmiddle' hspace='1'/></td>"
    else
        //strHTML += "<td class='tbPagesArrow'>&nbsp;&lt;&nbsp;</td>"
        strHTML += "<td><img class='img_buttonArrow' src='/precarga/image/left-arrow.png' border='0' align='absmiddle' hspace='1'/></td>"
/*    strHTML += "<td>P�gina: <select id='cbPage' name='cbPage' onchange=campos_head.pagina_cambiar(this.selectedIndex+1)>"
    for (var i = 1; i <= this.PageCount; i++)
        {
        var strSelected = ''
        if (this.AbsolutePage == i)
            strSelected = 'selected'
        strHTML += "<option " + strSelected + " value=" + i + ">" + i + "</option>"
        }
    strHTML += "</select> de " + this.PageCount + " </td>"*/
    strHTML += "<td>&nbsp;P�gina:&nbsp;<input type='number' id='txtPage' name='txtPage' style='width: 3em; text-align: right' maxlength='4' value=" + this.AbsolutePage + " onkeypress='return valDigito(event)' />  <input type='button' value='Ir' style='cursor:pointer' onclick=campos_head.pagina_cambiar($('txtPage').value) /> de " + this.PageCount + " </td>"
    //onblur=campos_head.pagina_cambiar(this.value)
    //onchange=campos_head.pagina_cambiar(this.value)
    if (this.AbsolutePage < this.PageCount)
        //strHTML += "<td onclick='javascript:campos_head.pagina_cambiar(" + (this.AbsolutePage + 1) + ")' style='cursor:pointer' class='tbPagesArrow'><b>&nbsp;&gt;&nbsp;</b></td>"
        strHTML += "<td onclick='javascript:campos_head.pagina_cambiar(" + (this.AbsolutePage + 1) + ")' style='cursor:pointer'><img class='img_buttonArrow' src='/precarga/image/right-arrow.png' border='0' align='absmiddle' hspace='1'/></td>"

    else
        //strHTML += "<td class='tbPagesArrow'>&nbsp;&gt;&nbsp;</td>"
        strHTML += "<td><img class='img_buttonArrow' src='/precarga/image/right-arrow.png' border='0' align='absmiddle' hspace='1'/></td>"
    if (this.AbsolutePage < this.PageCount)
        //strHTML += "<td onclick='javascript:campos_head.pagina_cambiar(" + this.PageCount + ")' style='cursor:pointer' class='tbPagesArrow'><b>&nbsp;&gt;&gt;&nbsp;</b></td>"
        strHTML += "<td onclick='javascript:campos_head.pagina_cambiar(" + this.PageCount + ")' style='cursor:pointer'><img class='img_buttonArrow' src='/precarga/image/right-double-doble.png' border='0' align='absmiddle' hspace='1'/></td>"
    else
        //strHTML += "<td class='tbPagesArrow'>&nbsp;&gt;&gt;&nbsp;</td>"
        strHTML += "<td><img class='img_buttonArrow' src='/precarga/image/right-double-doble.png' border='0' align='absmiddle' hspace='1'/></td>"
    strHTML += "</tr></table>"
    return strHTML
}

                          
//Objeto global de administraci�n
var campos_head = new tCampo_head();