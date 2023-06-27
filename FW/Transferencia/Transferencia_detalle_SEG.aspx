<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Me.contents("filtroTransf_diccionario") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_diccionario'><campos>distinct transf_dic_var,transf_dic_var_desc</campos><filtro></filtro><orden>transf_dic_var_desc</orden></select></criterio>")
    Me.contents("filtroTransf_campos_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='campos_def'><campos>distinct campo_def,filtroXML</campos><filtro></filtro><orden></orden></select></criterio>")


%>
<html>
<head>
<title>Transferencia Detalle SEG</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tTree.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tTree.js"></script>     
    <script type="text/javascript" src="/FW/transferencia/script/tUndo.js"></script>                 

    <script type="text/javascript" src="/FW/transferencia/script/transf_utiles.js"></script>

    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/doc/docs.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/lib/codemirror.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/fold/foldgutter.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/scroll/simplescrollbars.css" />
    
    <script src="/FW/Transferencia/script/CodeMirror/lib/codemirror.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/fold/markdown-fold.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/sql/sql.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/search/searchcursor.js"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/search/search.js"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/scroll/annotatescrollbar.js"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/search/matchesonscrollbar.js"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/search/jump-to-line.js"></script>
    <style type="text/css">
      .CodeMirror {
        border: 1px solid #eee;
        height: auto;
      }
    </style>

<%
    Dim indice = nvUtiles.obtenerValor("indice", "")
%>
<%= Me.getHeadInit()   %>
<script type="text/javascript">

var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 

var indice
var Transferencia
var vTree


var vButtonItems = new Array();
vButtonItems[0] = new Array();
vButtonItems[0]["nombre"] = "Boton_Deshacer"
vButtonItems[0]["etiqueta"] = ""
vButtonItems[0]["imagen"] = "deshacer"
vButtonItems[0]["onclick"] = "return u()";

vButtonItems[1] = new Array();
vButtonItems[1]["nombre"] = "Boton_Rehacer"
vButtonItems[1]["etiqueta"] = ""
vButtonItems[1]["imagen"] = "rehacer"
vButtonItems[1]["onclick"] = "return r()";

vButtonItems[2] = new Array();
vButtonItems[2]["nombre"] = "Boton_Eliminar"
vButtonItems[2]["etiqueta"] = "Eliminar"
vButtonItems[2]["imagen"] = "eliminar"
vButtonItems[2]["onclick"] = "return btnEliminar_nodo()";

vButtonItems[3] = new Array();
vButtonItems[3]["nombre"] = "Boton_Borrar"
vButtonItems[3]["etiqueta"] = "Limpiar"
vButtonItems[3]["imagen"] = "nueva"
vButtonItems[3]["onclick"] = "return btnSegmento_borrar()";

vButtonItems[4] = new Array();
vButtonItems[4]["nombre"] = "Boton_wUndo"
vButtonItems[4]["etiqueta"] = ""
vButtonItems[4]["imagen"] = "undo_abrir"
vButtonItems[4]["onclick"] = "return wu()";


var vListButtons = new tListButton(vButtonItems, 'vListButtons')
vListButtons.loadImage("rehacer", '/fw/image/transferencia/redo.png')
vListButtons.loadImage("deshacer", '/fw/image/transferencia/undo.png')
vListButtons.loadImage("nueva", '/fw/image/transferencia/nueva.png')
vListButtons.loadImage("eliminar", '/fw/image/transferencia/eliminar.png')
vListButtons.loadImage("undo_abrir", '/fw/image/transferencia/undo_abrir.png')

document.ondragover = null;
document.ondrop = null;

function crear_tree() {
        
            vTree=new tTree('Div_vTree_0',"vTree");
            vTree.loadImage("carpeta",'/fw/image/transferencia/modulo.png')
            vTree.loadImage("variable", '/fw/image/transferencia/variable.png')
            vTree.loadImage("hoja", '/fw/image/transferencia/variable.png')
            vTree.loadImage("undefined", '/fw/image/transferencia/variable.png')
            vTree.bloq_contenedor=$$("BODY")[0]
            vTree.getNodo_xml = tree_getNodo;

            var Nodo = new tNodo(vTree, 'raiz', null);
            vTree.nodos['raiz'] = {}
            vTree.nodos['raiz'] = Nodo
            vTree.nodos['raiz'].nodo_id = 'raiz'
            vTree.id = 'raiz'
            vTree.ChargeNodeOnchek=false
            vTree.nodos['raiz'].count = function () {
                                                        var j = 0
                                                        for (i in this.hijos)
                                                            j++
                                                        return j
                                                    }
            //vTree.async=true;
            //vTree.ChargeNodeOnchek=true
            //vTree.onNodeCharge = function (nodo_id) {
            //        debugger
            //        if(nodo_id.toLowerCase()=='raiz')
            //            this.MostrarArbol();
            //        }
            
        }

function tree_getNodo(nodoId, oXML) {
            //if (nodoId == 'raiz')
            //    oXML.load("transferencia_detalle_sp.aspx", "accion=raiz")
            //else
            //    oXML.load("transferencia_detalle_sp.aspx","accion=nodo&nodoId="+nodoId)
}

function cargarNodoRaizCD(datos,padre){
    
    var campo_def = datos.campo_def
    var etiqueta = datos.etiqueta
    var parametro = datos.parametro
    
    var NodoCampo_def = new tNodo(vTree, campo_def, padre);
    NodoCampo_def.uid = id_nodo++//IdentificadorUnico() + "%" + padre.id + "%" + campo_def
    vTree.nodos[NodoCampo_def.uid] = {}
    vTree.nodos[NodoCampo_def.uid] = NodoCampo_def
    vTree.nodos[NodoCampo_def.uid].xpath = padre.parametro + " = '" + padre.valor + "' "
    vTree.nodos[NodoCampo_def.uid].id = NodoCampo_def.uid
    vTree.nodos[NodoCampo_def.uid].nodo_id = id_nodo++// NodoCampo_def.uid
    vTree.nodos[NodoCampo_def.uid].title = etiqueta 
    vTree.nodos[NodoCampo_def.uid].nombre = etiqueta
    vTree.nodos[NodoCampo_def.uid].imagen = "hoja"
    vTree.nodos[NodoCampo_def.uid].tipo = "carpeta"
    vTree.nodos[NodoCampo_def.uid].checkbox = 'habilitado'
    vTree.nodos[NodoCampo_def.uid].parametro = parametro
    vTree.nodos[NodoCampo_def.uid].campo_def = campo_def
    //vTree.nodos[NodoCampo_def.uid].valor = ''
    vTree.nodos[NodoCampo_def.uid].count = function () {
                                                        var j = 0
                                                        for (i in this.hijos)
                                                            j++
                                                        return j
                                                       }

    if (padre.id != "raiz") {

        padre.imagen = "carpeta"
        if (padre.tipo == "hoja")
            padre.imagen = "variable"
        padre.tipo = "carpeta"
        padre.estadoCarpeta = "abierto"
        padre.EstadoHijos = "cargado"
        padre.nhijos = padre.count()
        if (padre.nhijos > 0)
            padre.tipo = "carpeta"
        padre.accion.estado = "activo"
        //   vTree.recargar_node(padre.id)
        //   padre.expand(true)
    }
    else {
        padre.nhijos = vTree.nodos['raiz'].count()
        vTree.MostrarArbol();
    }

    return vTree.nodos[NodoCampo_def.uid]
  }

var id_nodo = 0
function cargarNodoHijoCD(rs, padre)
{
    
    var i = 0
    while (!rs.eof()) {

        var Nodo = new tNodo(vTree, rs.getdata("id"), padre);
        Nodo.uid = id_nodo++// IdentificadorUnico() + "%" + padre.id +  "%" + rs.getdata("id")
        vTree.nodos[Nodo.uid] = {}
        vTree.nodos[Nodo.uid] = Nodo
        vTree.nodos[Nodo.uid].xpath = padre.parametro + " = '" + rs.getdata("id") + "' "
        vTree.nodos[Nodo.uid].id = Nodo.uid
        vTree.nodos[Nodo.uid].nodo_id = id_nodo++// Nodo.uid
        vTree.nodos[Nodo.uid].title = rs.getdata("campo") + "(" + rs.getdata("id") + ") -> " + padre.title
        vTree.nodos[Nodo.uid].nombre = rs.getdata("campo") + "(" + rs.getdata("id") + ")"
        vTree.nodos[Nodo.uid].accion.estado = ""
        vTree.nodos[Nodo.uid].imagen = vTree.nodos[Nodo.uid].tipo = "hoja"
        vTree.nodos[Nodo.uid].checkbox = 'habilitado'
       // vTree.nodos[Nodo.uid].setEditor = setContent
        vTree.nodos[Nodo.uid].editor = null
        vTree.nodos[Nodo.uid].parametro = padre.parametro
        vTree.nodos[Nodo.uid].campo_def = padre.campo_def
        vTree.nodos[Nodo.uid].valor = rs.getdata("id")
        vTree.nodos[Nodo.uid].code = ''
        vTree.nodos[Nodo.uid].count = function () {
                                                   var j = 0
                                                   for (i in this.hijos)
                                                     j++
                                                   return j
                                                  }
        i++
        rs.movenext()
    }

    rs.position = 0

    if (i > 0)
    {
        padre.imagen = "carpeta"
        if (padre.tipo == "hoja")
            padre.imagen = "variable"

        padre.tipo = "carpeta"
        padre.estadoCarpeta = "abierto"
        padre.EstadoHijos = "cargado"
        padre.nhijos = padre.count()
        padre.accion.estado = "activo"
     //   vTree.recargar_node(padre.parent.id)
     //   padre.expand(true)
    }

}


var list_parametros = []
function TreeAgregarNodo(e) {

    event.preventDefault();
    
    var datos = {};
    eval(event.dataTransfer.getData("Data"));

    if (!datos.campo_def && !datos.parametro)
        return

    var el = Event.element(e)

    if (!datos.campo_def && datos.parametro) {
        if (el.type == "text")
          el.value = datos.parametro
        return
    }

    nvFW.bloqueo_activar($("Div_vTree_0"), "bloq")
    
    var strError = ""
    var padre
    try {
        
        padre = vTree.nodos[el.id.split("mm_")[1]]

        if(padre === undefined)
            if (el.parentElement.parentElement.querySelector("img"))
                  padre = vTree.nodos[el.parentElement.parentElement.querySelector("img").id.split("mm_")[1]]

        if (padre === undefined && vTree.nodos['raiz'].nhijos > 0) 
            strError = "No es posible segmentar el elemento."
        else
          if (padre && padre !== undefined) 
            if (padre.imagen == 'variable') 
              strError = "No es posible segmentar el elemento."

        if (strError != "") {
          alert(strError)
          nvFW.bloqueo_desactivar($("Div_vTree_0"), 'bloq')
          return
        }

        if (padre === undefined && vTree.nodos['raiz'].nhijos == 0) {
            padre = vTree.nodos['raiz']
        }

      
        }
    catch (e) {
                alert("Error desconocido." + e.message)
                nvFW.bloqueo_desactivar($("Div_vTree_0"), 'bloq')
                return
              }


    var i = list_parametros.length
    list_parametros[i] = []
    list_parametros[i] = datos.parametro

    var filtroXML = ""
    var rs = new tRS();
    rs.open(nvFW.pageContents.filtroTransf_campos_def, "", "<campo_def type='igual'>'" + datos.campo_def + "'</campo_def>", "", "")
    if (!rs.eof()) {
        if (!campos_defs.items[datos.campo_def])
            campos_defs.add(datos.campo_def, { enDB: true, target: "campos_defs_hide" })

        filtroXML = campos_defs.items[datos.campo_def].filtroXML
    }

    var rs = new tRS();
    rs.open(filtroXML);
    
    if (padre.nhijos == 0) 
        cargarNodoHijoCD(rs, cargarNodoRaizCD(datos, padre))
    else
       for (i in padre.hijos) {
           cargarNodoHijoCD(rs, cargarNodoRaizCD(datos, padre.hijos[i]))
        }
   
     vTree.recargar_node("raiz")
     vTree.nodos['raiz'].expand(true)

     controlCheckNodo()
     tTreeCrearInput(vTree.nodos['raiz'])
     tTreeResizeAllInput()

     nvFW.bloqueo_desactivar($("Div_vTree_0"), 'bloq')
     Undo.add("Insertar parametró " + datos.parametro)
 }


function tTreeResizeAllInput() {

        var left_fixed = getInputLeft()

        for (i in vTree.nodos) {
            nodo = vTree.nodos[i]
            if (nodo.tipo == 'hoja')
                tTreeResizeInput(nodo.id, left_fixed)
        }
}

function getInputLeft() {

       var inputLeft = 0

        for (i in vTree.nodos) {
            nodo = vTree.nodos[i]
            if (nodo.tipo == 'hoja')
                if (inputLeft < $("hqCELLInput" + nodo.id).cumulativeOffset().left)
                    inputLeft = $("hqCELLInput" + nodo.id).cumulativeOffset().left
        }

        return inputLeft 

}

function tTreeResizeInput(id, left_fixed) {


       $("hqCELL" + id).setStyle({ width: $('Div_vTree_0').getWidth() })

       var x = $("hqCELLInput" + id).cumulativeOffset().left

       var left = left_fixed - x

       var width = $("hqCELL" + id).getWidth() - left_fixed //+ $("hqCELL" + id).cumulativeOffset().left

       //console.log("left:" + left + ", left_fixed:" + left_fixed + ", width:" + width + "," + $("hqCELL" + id).getWidth() )

       $("hqCELLInput" + id).setStyle({ left: left + "px", width: width + "px" })
       $("hqCELLButton" + id).setStyle({ left: (left + 10) + "px", width: "50px" })
       
}

function abm_editor(id)
{

   var valor = $("hqCELLInput" + id).value

   var exp = "\\s*\\\\n\\s*" 
   var r = new RegExp(exp, "ig")
   valor = valor.replace(r, "\n")
        
   objScriptEditar.script_txt = valor
   objScriptEditar.lenguaje = $("cmb_lenguaje").value
   objScriptEditar.lenguajeReadOnly = true;
   objScriptEditar.protocolo = "SCRIPT"

    var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
    winEditor = w.createWindow({
        title: '<b>Editor</b>',
        url: '/fw/transferencia/editor_script.aspx',
        minimizable: false,
        maximizable: true,
        draggable: true,
        width: 900,
        height: 450,
        resizable: true,
        destroyOnClose: true,
        onClose: return_abm_editor
    })

    winEditor.options.userData = {}
    winEditor.options.userData.id = id
    winEditor.options.objScriptEditar = objScriptEditar
    
    winEditor.showCenter(true)
}

function return_abm_editor(){
    
    if (winEditor.returnValue == 'OK') {

        //$("cmb_lenguaje").value = winEditor.options.objScriptEditar.lenguaje
        
        if (winEditor.options.userData.id) {

            var valor = winEditor.options.objScriptEditar.string

            var exp = "\\s*\n\\s*" 
            var r = new RegExp(exp, "ig")
            valor = valor.replace(r, "\\n")

            var id = $("hqCELLInput" + winEditor.options.userData.id)
            id.value = valor

            vTree.nodos[winEditor.options.userData.id].code = id.value

            Undo.add("Retorno edición de " + id.value)
        }
    }

  }

function onBlurInput(id) {
    vTree.nodos[id].code = $('hqCELLInput' + id).value
    Undo.add("Edición " + $('hqCELLInput' + id).value)
}

function tTreeCrearInput(nodo) {

   crearInput(nodo)
   if (nodo.nhijos > 0) {
    for (h in nodo.hijos) {
      hijo = nodo.hijos[h]
      tTreeCrearInput(hijo)
     }
    }

}   

function crearInput(nodo) {

        var id = nodo.id
        if (nodo.tipo == 'hoja') {

            //if ($("divText" + id))
            //    return
            //strHTML = "<div id='divText" + id + "' style='position:relative;float:left;width:100%'><table class='tb1 layout_fixed'><tr><td style='width:15%'></td><td><input type='text' id='text" + id + "' style='width:100%' resize='none'></input></td></tr></table></div>"
            //$("Div_vTree_valores").insert({ bottom: strHTML })

            if (!$("hqCELLInput" + id)) {
                try {
                    $("hqCELL" + id).setStyle({ borderBottom: "solid #A2A2A2 1px" })
                    $("hqCELL" + id).insertAdjacentHTML("BeforeEnd", "<input type='text' id='hqCELLInput" + id + "' onblur='return onBlurInput(\"" + id + "\")' style='width:100%;position:relative; display:inline-block; margin-bottom: 3px'><input type='button' id='hqCELLButton" + id + "' style='cursor:pointer;width:50px;position:relative; display:inline-block;' onclick='return abm_editor(\"" + id + "\")' value='...' />")
                }
                catch (e){ }
            }

            $("hqCELLInput" + id).value = nodo.code

            //var y = $("hqCELL" + id).cumulativeOffset().top
            //var x = $("hqCELLInput" + id).cumulativeOffset().left

            //var left = ($("Div_vTree_0").getWidth() * 0.40)  - x
            //var width = $("Div_vTree_0").getWidth() - ($("Div_vTree_0").getWidth() * 0.40)
            //$("hqCELLInput" + id).setStyle({ left: left + "px", width: width + "px"})

            //$("divText" + id).setStyle({ border: "solid blue 1px" })
            //var dif = y - $("divText" + id).cumulativeOffset().top
            //$("divText" + id).setStyle({ top: dif + 'px', height: $("hqCELL" + id).getHeight()})
            //$("divText" + id).clonePosition($(id), { setWidth: false, setHeight: false, offsetLeft: x, offsetTop: y });
            //$("divText" + id).show()
            //nodo.setEditor()
        }
    
}

function dragInicio(e, campo, parametro) {
    
    var el = Event.element(e)
    event.dataTransfer.setData("Data", " datos = { campo_def : '" + campo + "', etiqueta: '" + el.innerText + "', parametro: '" + parametro +"'}");

}
 
var objScriptEditar = new tScript();
function window_onload() {
    
    // mostramos los botones creados
    vListButtons.MostrarListButton()

    nvFW.bloqueo_activar($$("BODY")[0], "bloq")
    
    nvFW.enterToTab = false
    Transferencia = parent.return_Transferencia()
    objScriptEditar.cargar_parametros(Transferencia.parametros)
    //objScriptEditar..parametros = Transferencia.parametros

    indice = $('indice').value
    crearUndo()
    cargarSelectorParametros()
    cargar_parametros()
    crear_tree()
    onchange_lenguje()

    window_onresize()

    var str =' var strXML = !Transferencia.detalle[indice].parametros_extra.xml ? "" : Transferencia.detalle[indice].parametros_extra.xml;'
    str +=' var objXML = new tXML();'
    str +=' if(objXML.loadXML(\'<?xml version="1.0" encoding="iso-8859-1"?>\' + strXML)){'
    str +=' setListParametros(objXML);'
    str +=' tTree_recontruir(objXML, vTree.nodos["raiz"]);'
    str +=' vTree.nodos["raiz"].nhijos = vTree.nodos["raiz"].count();'
    str +=' vTree.MostrarArbol();'
    str +=' vTree.recargar_node("raiz");'
    str += ' vTree.nodos["raiz"].expand(true);'
    str += ' controlCheckNodo();'
    str += 'tTreeCrearInput(vTree.nodos["raiz"]);'
    str += 'tTreeResizeAllInput();'
    str += 'Undo.add("Inicializar Segmento");'
    str += '};'
    str += 'nvFW.bloqueo_desactivar($$("BODY")[0], "bloq")'

//    console.log(str)
    setTimeout(str, 500)
 }


function cargarSelectorParametros() {
    //$('ifrSelectorParametros').src = '/FW/Transferencia/editor_parametros_listar.aspx'
}


function tTree_addNodo(nodo,padre)
{
    var nodo_id = selectSingleNode('@nodo_id', nodo).value

    id_nodo++
    for (var uid in vTree.nodos) {
        if (vTree.nodos[uid].nodo_id == nodo_id)
            return vTree.nodos[uid]
    }

    var imagen = selectSingleNode('@imagen', nodo).value
    var tipo = selectSingleNode('@tipo', nodo).value
    var depende_de = selectSingleNode('@depende_de', nodo).value
    var parametro = !selectSingleNode('@parametro', nodo) ? '' : selectSingleNode('@parametro', nodo).value
    var campo_def = !selectSingleNode('@campo_def', nodo) ? '' : selectSingleNode('@campo_def', nodo).value

    var nombre = XMLText(selectSingleNode('nombre', nodo))
    var title = XMLText(selectSingleNode('title', nodo))
    var valor = !selectSingleNode('valor', nodo) ? '' : XMLText(selectSingleNode('valor', nodo))
    var code = !selectSingleNode('code', nodo) ? '' : XMLText(selectSingleNode('code', nodo))
    var xpath = ""

    valor = !selectSingleNode('@' + parametro, nodo) ? '' : selectSingleNode('@' + parametro, nodo).value
    if (valor != '' && valor != 'undefined')
       xpath += parametro + " = '" + valor + "'"

    //valor = !selectSingleNode('@' + padre.parametro, nodo) ? '' : selectSingleNode('@' + padre.parametro, nodo).value
    //if (valor != '' && valor != 'undefined')
    //        xpath = padre.xpath + " " + xpath
    
    var objNodo = new tNodo(vTree, nodo_id, padre);
    vTree.nodos[objNodo.uid] = {}
    vTree.nodos[objNodo.uid] = objNodo
    vTree.nodos[objNodo.uid].id = objNodo.uid
    vTree.nodos[objNodo.uid].xpath = xpath
    vTree.nodos[objNodo.uid].nodo_id = nodo_id
    vTree.nodos[objNodo.uid].title = title
    vTree.nodos[objNodo.uid].nombre = nombre
    vTree.nodos[objNodo.uid].imagen = imagen
    vTree.nodos[objNodo.uid].tipo = tipo
    vTree.nodos[objNodo.uid].checkbox = 'habilitado'
    vTree.nodos[objNodo.uid].parametro = parametro
    vTree.nodos[objNodo.uid].campo_def = campo_def
    vTree.nodos[objNodo.uid].valor = valor
    vTree.nodos[objNodo.uid].code = code
    vTree.nodos[objNodo.uid].count = function () {
        var j = 0
        for (i in this.hijos)
            j++
        return j
    }

    vTree.nodos[objNodo.uid].estadoCarpeta = "abierto"
    vTree.nodos[objNodo.uid].EstadoHijos = "cargado"
    vTree.nodos[objNodo.uid].accion.estado = "activo"

    return objNodo
}

function tTree_recontruir(objXML,padre) {
    
    for (var i = 0; i < selectNodes('/segmentos/nodo [@nodo_id!="raiz"]', objXML.xml).length; i++) {

       var nodo = selectNodes('/segmentos/nodo [@nodo_id!="raiz"]', objXML.xml)[i]
       tnodo = tTree_addNodo(nodo, padre)

       var hijos = 0
       if (selectNodes('/segmentos/nodo [@depende_de="' + tnodo.nodo_id + '"]', objXML.xml).length > 0) {
           hijos = selectNodes('/segmentos/nodo [@depende_de="' + tnodo.nodo_id + '"]', objXML.xml).length
         if (hijos > 0) {
           vTree.nodos[tnodo.id].nhijos = hijos
           for (var h = 0; h < selectNodes('/segmentos/nodo [@depende_de="' + tnodo.nodo_id + '"]', objXML.xml).length; h++) {

            var hNodo = selectNodes('/segmentos/nodo [@depende_de="' + tnodo.nodo_id + '"]', objXML.xml)[h]
            var tnodoh = tTree_addNodo(hNodo,tnodo)

           } 
         }
       }
     }
  }


function cargar_parametros() {
var strHTML = ''
    $("divParametros").innerHTML = '' 
    strHTML = "<table class='tb1 highlightOdd highlightTROver layout_fixed'>"
    strHTML += "<tr class='tbLabel'>"
    strHTML += "<td>Parámetros</td>"
    strHTML += "</tr>"
    Transferencia.parametros.each(function (arreglo, j) {
        if (arreglo.campo_def != '') {
            strHTML += "<tr>"
            strHTML += "<td style='cursor:pointer;cursor:hand' title='" + (arreglo.etiqueta == '' ? '(' : arreglo.etiqueta + " (") + arreglo.parametro + ")' draggable= 'true' ondrop='drop(event)' ondragstart='dragInicio(event,\"" + arreglo.campo_def + "\",\"" + arreglo.parametro + "\")'>" + (arreglo.etiqueta == '' ? '(' : arreglo.etiqueta + ' (') + arreglo.parametro + ")</td>"
            strHTML += "</tr>"
         }
        });
    strHTML += "</table>"
    $("divParametros").insert({ top: strHTML })
}


function recuperar_hijos(padre,nodo) {

var str  = "<nodo nodo_id='" + nodo.nodo_id + "' imagen='" + nodo.imagen + "' tipo='" + nodo.tipo + "'"
    str += " depende_de='" + (padre.nodo_id == "undefined" ? 'raiz' : padre.nodo_id) + "' "
 //   str += (nodo.tipo == 'hoja' ? "" : nodo.parametro + " = '" + nodo.valor + "'")

    if (nodo.tipo == "hoja")
    {

        if (padre.xpath && nodo.xpath)
           if (padre.xpath.indexOf("undefined") == -1)
               if (nodo.xpath.indexOf(padre.xpath) == -1) {
                   nodo.xpath += " " + padre.xpath
               }
        
       if (nodo.xpath)
            str += " " + nodo.xpath

       strParam = ""
       list_parametros.each(function (param, i) {
           if (nodo.xpath.indexOf(param) == -1)
               strParam += " " + param + " = ''"
       });


       if (strParam != "")
           str += strParam

    }
    else
    {
        if (nodo.parametro) {
            str += "" + nodo.parametro 
            if (nodo.valor && nodo.valor != "undefined" )
                str += " = '" + nodo.valor + "'"
            else
                str += " = ''"
        }

        if (nodo.xpath != undefined && padre.xpath != undefined && padre.xpath.indexOf("undefined") == -1) {
            if (nodo.xpath.indexOf(padre.xpath) == -1)
            {
                var noesta = false
                if (padre.xpath.indexOf(nodo.xpath) > -1)
                    noesta = true

                if (!noesta)
                    nodo.xpath += " " + padre.xpath
                else
                    nodo.xpath = " " + padre.xpath
            }
        }      

    
    }
    
    str += " parametro='" + nodo.parametro + "' campo_def='" + nodo.campo_def + "'>"
    str += "<title><![CDATA[" + nodo.title + "]]></title>"
    str += "<nombre><![CDATA[" + nodo.nombre + "]]></nombre>"
    if (nodo.tipo == "hoja")
        str += "<code><![CDATA[" + nodo.code + "]]></code>"
    str += "</nodo>"

    if (nodo.nhijos > 0) {
        for (h in nodo.hijos) {
            hijo = nodo.hijos[h]
            str += recuperar_hijos(nodo,hijo)
        }
    }

    //console.log(str)
    return str
}
function validar() {
    
    var strError = ''


    // (1) verificar si el campo_def existe como parametro
    //     -en el caso que no exista advertir  y no dibujarlo
    // (2) verificar que el valor del campo exista
    //     -en el caso de no existir advertilo y no dibujarlo
    // (3)  si el campo def tiene un parametro nuevo advertir y agregarlo al segmento

    return strError 

}

function setListParametros(objXML)
{
    list_parametros = []
    var lista = selectNodes('/segmentos/parametros/parametro', objXML.xml) 
    for (var i = 0; i < lista.length; i++)
     {
        list_parametros[i] = []
        list_parametros[i] = XMLText(lista[i])
    }
}

function setXML()
{
    var strXML = "<segmentos>"
    strXML += recuperar_hijos({nodo_id: "", parametro: "", valor: "" }, vTree.nodos['raiz'])
    strXML += "<parametros>"
    list_parametros.each(function (param, i) {
        strXML += "<parametro>" + param + "</parametro>"
    });
    strXML += "</parametros>"
    strXML += "</segmentos>"
   

    return strXML
}

function guardar()
{ 

 //Valida
 var strError = ''

 //Si es Nuevo
 if (indice == -1)
   {
    Transferencia["detalle"].length++
    indice = Transferencia["detalle"].length -1 
    Transferencia["detalle"][indice] = new Array();
   }

 //Carga Objeto
 Transferencia["detalle"][indice]["orden"] = indice
 Transferencia["detalle"][indice]["transf_tipo"] = 'SEG'       
 Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
 Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
 Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value                
 
 Transferencia.detalle[indice].parametros_extra.xml = setXML()

 return Transferencia 
}

    function window_onresize() {
    try {


        setTimeout("tTreeResizeAllInput()", 100)

        var dif = Prototype.Browser.IE ? 10 : 4
        var body_height = $$('body')[0].getHeight()
        var tdTitulo_height = 0
        var calc = body_height - tdTitulo_height - dif 

        var divBotones_height = $('divBotones').getHeight()
        var divLenguaje_height = $('divLenguaje').getHeight()
        
        $('divParametros').setStyle({ 'height': (calc - divBotones_height - divLenguaje_height) + 'px' })


        $('Div_vTree_0').setStyle({ 'height': calc + 'px' })

      //  $('DivRight').setStyle({ 'height': calc + 'px' })

        //var alto_parametros = 0
        //contenedores = $('tbDic').querySelectorAll(".contenedor")
        //for (var i = 0; i < contenedores.length; i++) {
        //    if (contenedores[i].style.display != 'none')
        //        alto_parametros = alto_parametros + contenedores[i].getHeight()
        //}

      //  $('ifrSelectorParametros').setStyle({ 'height': calc - alto_parametros + 'px' })

    }
    catch (e) { window.status = e.description; alert( 'calc: ' + calc )}

}

    function include(arr, obj) {
        return (arr.indexOf(obj) != -1)
    }


    function actualizar_tree() {
        var nodos_expandir = []
        for (i in vTree.nodos) {
            var nodo = vTree.nodos[i]
            if (nodo.estadoCarpeta == "abierto") {
                nodos_expandir.push(nodo.id)
            }
        }
        vTree.getNodo_xml = tree_getNodo
        vTree.cargar_nodo('raiz')
        vTree.MostrarArbol();
        for (i in vTree.nodos) {
            var nodo = vTree.nodos[i]
            if (include(nodos_expandir, nodo.id))
                nodo.expand(true)
        }
    }

    function controlCheckNodo(nodo, padre) {

        if (!padre)
            padre = null

        if (!nodo)
            nodo = vTree.nodos["raiz"]

        for (i in nodo.hijos)
            if (nodo.hijos[i])
                controlCheckNodo(nodo.hijos[i], nodo)
        
        if (nodo.tipo != "carpeta") {
            if ($('chck_' + nodo.uid) != null){
                $('chck_' + nodo.uid).checked = false
                $('chck_' + nodo.uid).disabled = true
             }
        }
    }

    function btnEliminar_nodo()
    {
        Dialog.confirm("¿Desea eliminar el segmento selecionado?",
                                                   {
                                                       width: 300,
                                                       className: "alphacube",
                                                       okLabel: "Si",
                                                       cancelLabel: "No",
                                                       onOk: function (w) {
                                                               Undo.add("Eliminar nodos")
                                                               eliminar_nodo()
                                                               w.close();
                                                              return
                                                       },

                                                       onCancel: function (w) {
                                                           w.close();
                                                       }
                                                   });
    

    }

    function eliminar_nodo(nodo, padre) {
      
        if (!padre)
            padre = null

        if (!nodo)
            nodo = vTree.nodos["raiz"]

        for (i in nodo.hijos)
            if (nodo.hijos[i]) 
                eliminar_nodo(nodo.hijos[i], nodo)

        if (padre) {
            if (padre.tipo == "carpeta" && padre.id != 'raiz') {
                if ($('chck_' + nodo.uid) != null)
                    if ($('chck_' + nodo.uid).checked) {

                        nodo.eliminar(nodo, padre)

                        if (padre.imagen == "variable" && $('chck_' + padre.parent.uid).checked == false) {
                            if ($('chck_' + padre.uid).checked) {
                                $('chck_' + padre.uid).checked = false
                                $('chck_' + padre.uid).disabled = false
                                padre.checked = false
                                padre.tipo = 'hoja'
                            }
                        }

                        if (padre.parent)
                            if (padre.parent.id == 'raiz') {
                                padre = vTree.nodos["raiz"]
                                segmento_borrar()
                            }

                        vTree.recargar_node(padre.id);
                        vTree.nodos[padre.id].expand(true);

                    }

          }

          if (padre.id != 'raiz') {
                tTreeCrearInput(vTree.nodos["raiz"])
                tTreeResizeAllInput()
            }
        }
}


function btnSegmento_borrar() {

        Dialog.confirm("¿Desea limpiar la segmentación?",
                                                {
                                                    width: 300,
                                                    className: "alphacube",
                                                    okLabel: "Si",
                                                    cancelLabel: "No",
                                                    onOk: function (w) {
                                                        Undo.add("Borrar Segmentos")
                                                        segmento_borrar()
                                                        w.close();
                                                        return
                                                    },

                                                    onCancel: function (w) {
                                                        w.close();
                                                    }
                                                });
}

 function segmento_borrar() {

    list_parametros = []
    id_nodo = 0
    vTree = null
    $('Div_vTree_0').innerHTML = ""
    crear_tree()
}
    
    function onchange_lenguje() {

        //if ($('cmb_lenguaje').value == "vb")
        //    setContent('vb', 'evaluacion', $('evaluacion').value)

        //if ($('cmb_lenguaje').value == "js")
        //    setContent('js', 'evaluacion', $('evaluacion').value)

        //if ($('cmb_lenguaje').value == "cs")
        //    setContent('cs', 'evaluacion', $('evaluacion').value)
        
       objScriptEditar.param_add = [];
        var i 
        if ($('cmb_lenguaje').value == "js") {
            i =objScriptEditar.param_add.length
           objScriptEditar.param_add[i] = {}
           objScriptEditar.param_add[i].parametro = "det.transf_error.numError"
           objScriptEditar.param_add[i].etiqueta = "Nro. Error de la Tarea"
           objScriptEditar.param_add[i].tipo_dato = ""
           objScriptEditar.param_add[i].lenguaje = "js"
        }

        if ($('cmb_lenguaje').value == "vb") {
            i =objScriptEditar.param_add.length
           objScriptEditar.param_add[i] = {}
           objScriptEditar.param_add[i].parametro = "det.transf_error.numError"
           objScriptEditar.param_add[i].etiqueta = "Nro. Error de la Tarea"
           objScriptEditar.param_add[i].tipo_dato = ""
           objScriptEditar.param_add[i].lenguaje = "vb"
        }

        cargarSelectorParametros()
        //var rs = new tRS();
        //var criterio = nvFW.pageContents.filtroTransf_diccionario
        //rs.open(criterio)
        //var i = 0; 
        //while (!rs.eof()) {
        //    i =objScriptEditar.param_add.length
        //   objScriptEditar.param_add[i] = {}
        //   objScriptEditar.param_add[i].parametro = rs.getdata("transf_dic_var")
        //   objScriptEditar.param_add[i].etiqueta = rs.getdata("transf_dic_var_desc")
        //   objScriptEditar.param_add[i].tipo_dato = ""
        //   objScriptEditar.param_add[i].tipo_dato = ""

        //    i++
        //    rs.movenext()
        //}

    }

    var Undo;
    function crearUndo() {
        
        var options = {};
        options.id = "Undo"
        options.onUndo = options.onRedo = function (list,indice) {

            if (!list)
                return

            var objXML = new tXML();
            if (objXML.loadXML('<?xml version="1.0" encoding="iso-8859-1"?>' + list.obj))
            {
             segmento_borrar()
             setListParametros(objXML)
             tTree_recontruir(objXML, vTree.nodos["raiz"]);
             vTree.nodos["raiz"].nhijos = vTree.nodos["raiz"].count();
             vTree.MostrarArbol();
             vTree.recargar_node("raiz");
             vTree.nodos["raiz"].expand(true);
             controlCheckNodo()
             tTreeCrearInput(vTree.nodos["raiz"]);
             tTreeResizeAllInput();
            }

        };
        Undo = new tUndo(options);
        Undo.tAdd = Undo.add;
        Undo.add = function (desc) {
        //    console.log(setXML())
            Undo.tAdd(setXML(),desc);
        }
    }

    function u()
    {
       Undo.undo()
    }

    function r() {
       Undo.redo()
    }

    function wu() {
       Undo.onOpenWindow()
    }
</script>
</HEAD>
<body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
 <input type="hidden" name="indice" id="indice" value="<%=indice%>" />
 <div id="divUndo"></div>
 <table class='tb1' style="width:100%">
     <tr>
         <td style="width:10%">
             <div id="divLenguaje" style="width:100%">
                   <table class='tb1' style="width:100%">
                          <tr class="tbLabel">
                             <td id="tit_lenguaje">Lenguaje</td>
                          </tr>
                          <tr>
                             <td id="td_cmb_lenguje"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js" selected ="selected">JSCRIT</option><option value="vb">VB .NET</option><option value="cs">CS .NET</option></select></td>
                         </tr>
                  </table>
             </div>
             <div id="divParametros" style="width:100%"></div>
             <div id="divBotones" style="width:100%">
                  <table class='tb1' style="width:100%">
                       <tr>
                         <td style="width:100%;text-align:left"><div id="divBoton_Deshacer" style="width: 30%;display:inline-grid"></div> <div id="divBoton_Rehacer" style="width: 30%;display:inline-grid  "></div> <div id="divBoton_wUndo" style="width: 5%;display:inline-grid"></div></td>
                       </tr>
                       <%--<tr>
                         <td style="width:100%"><input type="button" value="Validar" style="width:100%" onclick="validar()"></td>
                       </tr>--%>
                      <tr>
                         <td style="width:100%"><div id="divBoton_Eliminar" style="width: 100%"></div></td>
                       </tr>
                       <tr>
                         <td style="width:100%"><div id="divBoton_Borrar" style="width: 100%"></div></td>
                       </tr>
                  </table>
             </div>
         </td>
         <td><div id="Div_vTree_0" ondrop='TreeAgregarNodo(event)' draggable="true" ondragenter="return false" ondragover="return false" style="width:100%;height:100%;overflow:auto;border:1px #818181 solid"></div></td>
          <%--<td style="width:15%">
              <div id="DivRight" style="width:100%;height:100%;overflow:hidden;">
                   <table class='tb1' id="tbDic" style="width:100%">  
                    <tr class="tbLabel contenedor">
                      <td id="tit_lenguaje">Lenguaje</td>
                    </tr>
                    <tr class="contenedor">
                      <td id="td_cmb_lenguje"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js" selected ="selected">JSCRIT</option><option value="vb">VB .NET</option><option value="cs">CS .NET</option></select></td>
                    </tr>
                   <tr>
                      <td><iframe id="ifrSelectorParametros" style='width:100%;overflow:hidden;border:0px'></iframe></td>
                    </tr>
                </table>     
             </div>
         </td>--%>
    </tr>
 </table>
<div id="campos_defs_hide" style="display:none"></div>
</body>
</HTML>