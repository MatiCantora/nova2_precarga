<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Me.contents("FiltroXML_desde") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='transf_conf'><campos>id_transf_conf as id, transf_conf as [campo]</campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroTransf_diccionario") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_diccionario'><campos>distinct transf_dic_var,transf_dic_var_desc</campos><filtro></filtro><orden>transf_dic_var_desc</orden></select></criterio>")
    Me.contents("filtro_pizarra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='(select vp.nro_calc_pizarra,calc_pizarra,calc_pizarra_dato from calc_pizarra_def def inner join verpizarras vp on vp.nro_calc_pizarra = def.nro_calc_pizarra) p'><campos>*</campos></select></criterio>")

    Dim modo = nvUtiles.obtenerValor("modo", "")
    If (modo = "getRs") Then

        Try

            Dim criterio As String = "" 'HttpUtility.UrlDecode(nvUtiles.obtenerValor("criterio", ""))
            Dim vista As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("vista", ""))
            Dim cn As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("cn", ""))
            Dim type As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("type", ""))

            If type.ToLower = "view" Then
                criterio = "<criterio><select vista='" & vista & "' cn='" & cn & "'><campos>*</campos><filtro><SQL type='sql'>1=2</SQL></filtro></select></criterio>"
            End If

            If type.ToLower = "sp" Then

                criterio = "<criterio><select vista='sys.parameters' cn='" & cn & "'><campos>replace(name,'@','') as name</campos><filtro><object_id type='igual'>object_id('" & vista & "')</object_id></filtro></select></criterio>"
                If nvApp.app_cns(cn).cn_tipo.ToLower = "sybase" Then
                    criterio = "<criterio><select vista=' sysobjects o inner join syscolumns c on o.id = c.id ' cn='" & cn & "'><campos>substring(c.name,2,len(c.name)) as name</campos><filtro><SQL type='sql'> o.name = '" & vista & "'</SQL></filtro></select></criterio>"
                End If

            End If

            Dim arParam As trsParam = New trsParam
            arParam("SQL") = ""
            arParam("timeout") = 0
            arParam("objError") = Nothing
            arParam("logTrack") = Nothing

            'ejecutamos consulta
            Dim rs As ADODB.Recordset = nvXMLSQL.XMLtoRecordset(criterio, "", arParam)

            'Convertir el RS a XML
            Dim objXML = New System.Xml.XmlDocument
            objXML = nvFW.nvXMLSQL.RecordsetToXML(rs, arParam)

            nvFW.nvXMLUtiles.responseXML(Response, objXML.OuterXml)

        Catch ex As Exception
        End Try

        Response.End()

    End If

    If (modo = "Exportar") Then

        Dim filtroXML As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("filtroXML", ""))
        Dim paramExport As tnvExportarParam = nvFW.reportViewer.getParamExportFromRequest()
        paramExport.filtroXML = nvXMLSQL.encXMLSQL(filtroXML)
        paramExport.salida_tipo = nvenumSalidaTipo.adjunto
        paramExport.path_xsl = "\\report\\html_base.xsl"

        Dim er As nvFW.tError = reportViewer.exportarReporte(paramExport)

        If er.numError <> 0 Then
            er.salida_tipo = "adjunto"
            er.mostrar_error()
        Else
            Response.End()
        End If

    End If
%>

<html>
<head>
<title>Transferencia Detalle Exp</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/script/CodeMirror/lib/codemirror.css" rel="stylesheet" >  
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/doc/docs.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/lib/codemirror.css" />
    <link rel="stylesheet" href="/FW/Transferencia/script/CodeMirror/addon/button/buttons.css" />

    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript" src="/FW/script/tScript.js"></script>     
            
    <script type="text/javascript" src="/FW/transferencia/script/transf_utiles.js"></script>
    <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>

    <script src="/FW/Transferencia/script/CodeMirror/lib/codemirror.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/lib/util/loadmode.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/meta.js" type="text/javascript"></script>

    <script src="/FW/Transferencia/script/CodeMirror/mode/javascript/javascript.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/vb/vb.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/clike/clike.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/xml/xml.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/mode/sql/sql.js" type="text/javascript"></script>

    <script src="/FW/Transferencia/script/CodeMirror/addon/button/buttons.js" type="text/javascript"></script>
    <script src="/FW/Transferencia/script/CodeMirror/addon/display/panel.js" type="text/javascript"></script>
    <style type="text/css">
           /**** menu ****/
            .mnuTB_B td.mnuCELL_Normal_B{
               padding: 0px;
               background: #A2A2A2;
               border-bottom: 1px solid black;
               border-right: 1px solid black;
               border-radius: 0.33em;
               z-index:100;

            }
            .mnuTB_B td.mnuCELL_OnOver_B{
                background: #C0C0C0;
                color: #FFFFFF;
                border-bottom: 1px solid black;
                border-right: 1px solid black;
                cursor: pointer;
                cursor: hand;
                 z-index:100;
            }
            tr.submnuTR_B td {
                cursor: pointer;
                padding: 0 0px;
                min-width: 100px;
                background: #A2A2A2;
                border-bottom: 1px solid black;
                border-right: 1px solid black;
                -moz-border-radius: 0.33em;
                -webkit-border-radius: 0.33em;
                border-radius: 0.33em;
                 z-index:100;
            }
            tr.submnuTR_B td:hover {
                background: #C0C0C0;
                cursor: hand;
                cursor: pointer;
                border-bottom: 1px solid black;
                border-right: 1px solid black;
                 z-index:100;
            }

        .CodeMirror {
            border: 2px solid #eee;
            height: auto;
            vertical-align: top;            
        }

    </style>
    <% = Me.getHeadInit()%>
    <script type="text/javascript" >

var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 120, okLabel: "cerrar",zIndex:100000 }); } 

var objScriptEditar = new tScript();

var win = nvFW.getMyWindow()

//var editor
//function setContent(extension, obj, value) {
    
//    var modo = ''
//    if (extension == 'xml')
//        modo = 'application/xml'
//   if (extension == 'txt')
//       modo ='text/x-mariadb'

//   //CodeMirror.xmlHints['<'] = [
//   //   'criterio'
//   //  ,'select'
//   //];


//    editor = CodeMirror.fromTextArea($(obj), {
//        mode: 'application/xml',
//        readOnly: false,
//        lineNumbers: true,
//        selectionPointer: true,
//        autofocus: true,
//        extraKeys: { "Ctrl-Space": "autocomplete" }
//        //extraKeys: {
//        //    "'>'": function (cm) { cm.closeTag(cm, '>'); },
//        //    "'/'": function (cm) { cm.closeTag(cm, '/'); },
//        //    "' '": function (cm) { CodeMirror.xmlHint(cm, ' '); },
//        //    "'<'": function (cm) { CodeMirror.xmlHint(cm, '<'); },
//        //    "Ctrl-Space": function (cm) { CodeMirror.xmlHint(cm, ''); }
//        //}

//    });

//    /*editor.on("dblclick", function (event) {
//        script_editar(editor.getTextArea().id);
//    }),*/

//    $(obj).value = value
//    editor.setValue(value);
//}

var editor
function setContent(obj, value, options) {


    if (!options) {
        options = {}      
        options.extension = 'jscript'
        options.lineNumbers = true
    }

            // los objetos de texto que soporta
            if (options.extension == 'jscript' ||
                options.extension == 'asp' ||
                options.extension == 'aspx' ||
                options.extension == 'vb' ||
                options.extension == 'js' ||
                options.extension == 'cs' ||
                options.extension == 'xml' ||
                options.extension == 'sql'
            ) {

                var modeInput
                switch (options.extension) {
                    case "vb":
                        modeInput = "text/x-vb"
                        break;
                    case "cs":
                        modeInput = "text/x-csharp"
                        break;
                    case "js":
                        modeInput = "javascript"
                        break;
                    case "asp":
                        modeInput = "application/x-ejs"
                        break;
                    case "aspx":
                        modeInput = "application/x-ejs"
                        break;
                    case "xml":
                        modeInput = "application/xml"
                        break;
                    case "sql":
                        modeInput = 'text/x-mssql'
                        break;
                }


                if (editor) {
                    var val = modeInput, m, mode, spec;
                    if (m = /.+\.([^.]+)$/.exec(val)) {
                        var info = CodeMirror.findModeByExtension(m[1]);
                        if (info) {
                            mode = info.mode;
                            spec = info.mime;
                        }
                    } else if (/\//.test(val)) {
                        var info = CodeMirror.findModeByMIME(val);
                        if (info) {
                            mode = info.mode;
                            spec = val;
                        }
                    } else {
                        mode = spec = val;
                    }
                    if (mode) {
                        editor.setOption("mode", spec);
                        CodeMirror.autoLoadMode(editor, mode);
                    } else {
                        alert("No encuentra el modo correspondiente a " + val);
                    }
                    //editor.setOption("mode", mode);
                    //CodeMirror.autoLoadMode(editor, mode);
                }
                else {
                    
                    editor = CodeMirror.fromTextArea($(obj), {
                        scrollbarStyle: "native",
                        //scrollbarStyle: "simple",
                        mode: modeInput,
                        readOnly: false,
                        lineNumbers: options.lineNumbers,
                        autofocus: true,
                        selectionPointer: false,
                        dragDrop: true

                        //buttons: [
                        //    {
                        //        hotkey: 'Ctrl-B',
                        //        class: 'bold',
                        //        label: '<b>Pizarra</b>',
                        //        callback: function (data) {

                        //            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                        //            winEditor = w.createWindow({
                        //                className: 'alphacube',
                        //                title: '<b>Editor</b>',
                        //                url: '/fw/pizarra/calculos_pizarra_buscar.aspx',
                        //                minimizable: false,
                        //                maximizable: true,
                        //                draggable: true,
                        //                width: 900,
                        //                height: 450,
                        //                resizable: true,
                        //                destroyOnClose: true,
                        //                onClose: return_listar_pizarra
                        //            })

                        //            winEditor.showCenter(true)

                        //         /*   var selection = data.getSelection();
                        //            data.replaceSelection('nvEvaluator.Pizarra.value("Pre-calificaci�n ""Tipo de empleo"" v1.0",3, "Empleado P�blico Nacional", 1001)' + selection);
                        //            if (!selection) {
                        //                var cursorPos = data.getCursor();
                        //                data.setCursor(cursorPos.line, cursorPos.ch - 2);
                        //            }*/
                        //        }
                        //    }],
                    });
                  
                    editor.on('drop', function (data, e) {
                        
                        e.preventDefault();
                        e.stopPropagation();

                        var file;
                        var files;
                        // Check if files were dropped
                        files = e.dataTransfer.files;
                        if (files.length > 0) {

                            file = files[0];
                            alert('File: ' + file.name);
                            return false;
                        }

                        var datos = {};
                        if(event.dataTransfer.getData("Data"))
                            eval(event.dataTransfer.getData("Data"));

                        if (event.dataTransfer.getData("Text"))
                            datos.parametro  = event.dataTransfer.getData("Text")

                        if (!datos.parametro)
                            return false;

                        var selection = data.getSelection();
                        data.replaceSelection(datos.parametro + selection);
                        if (!selection) {
                            var cursorPos = data.getCursor();
                            data.setCursor(cursorPos.line, cursorPos.ch - 2);
                        }
                        return false;

                      /*var x = e.pageX;
                        var y = e.pageY;
                        var coords = { left: x, top: y };

                        data.coordsChar(coords);

                        var doc = data.getDoc();
                        doc.replaceSelection(datos.parametro, data.focus());
                        return false;*/

                        //var x = e.pageX;
                        //var y = e.pageY;
                        //var coords = { left: x, top: y };
                        //var loc = editor.coordsChar(coords);
                    });
                 

                    $(obj).value = value
                    editor.setValue(value);
                    setTimeout("window_onresize()",100)
                }

            }

            //window_onresize()
        }

function window_onresize() {
    try {
        var alto = 0
        var dif = Prototype.Browser.IE ? 5 : 2
        var body_heigth = $$('body')[0].getHeight()
        var tbPie_height = $('tbPie').getHeight()
        
        alto = body_heigth - tbPie_height

        if (getComputedStyle($('divRight')).display == 'none')
            $('divLeft').setStyle({ width: '100%' })

        $('divLeft').setStyle({ height: (alto) + 'px'})
        $('divRight').setStyle({ height: (alto) + 'px'})

        var altoRight = 20
        contenedores = $('divRight').querySelectorAll(".contenedor")
        for (var i = 0; i < contenedores.length; i++) {
            if (getComputedStyle(contenedores[i]).display != 'none') {
                altoRight = altoRight + contenedores[i].getHeight()
            }
        }

        $('ifrSelectorParametros').setStyle({ height: (alto - altoRight) + 'px' })

        var altoLeft = 20
        contenedores = $('divLeft').querySelectorAll(".contenedor")
        for (var i = 0; i < contenedores.length; i++) {
            if (getComputedStyle(contenedores[i]).display != 'none') {
                altoLeft = altoLeft + contenedores[i].getHeight()
            }
        }

        var width = $('divLeft').getWidth() + 'px'
        var height = (alto - altoLeft) + 'px'

        if ($('cb_protocolo').value.toUpperCase() == 'FILE') {
          width = "100%"
          height = "auto"
        }

        editor.setSize(width, height)
        editor.refresh()
    //    console.warn("OK," + altoLeft + ',' + alto)
    }
    catch (e) { console.log(e.message)  }

}

function cargarSelectorParametros() {
    $('ifrSelectorParametros').src = '/FW/Transferencia/editor_parametros_listar.aspx'
}

var _parent
function window_onload() 
{

 //nvFW.bloqueo_activar($$("BODY")[0], "bloq")

 nvFW.enterToTab = false
 $('txt_target').setStyle({width:'100%'})

var objEntrante = new tScript();
if (!win) {
    _parent = parent.win
    objEntrante = parent.win.options.objScriptEditar
    
}
else {
    _parent = win
    objEntrante = win.options.objScriptEditar
}

objScriptEditar.cargar_parametros(objEntrante.parametros)
objScriptEditar.cargar_param_add(objEntrante.param_add)
objScriptEditar.protocolo = objEntrante.protocolo
objScriptEditar.lenguaje = objEntrante.lenguaje
objScriptEditar.cod_cn = objEntrante.cod_cn
objScriptEditar.lenguajeReadOnly = objEntrante.lenguajeReadOnly
objScriptEditar.vista = objEntrante.vista
objScriptEditar.script_txt = objEntrante.script_txt == undefined ? '' : objEntrante.script_txt
objScriptEditar.parametros_extra = objEntrante.parametros_extra
objScriptEditar.callbackCancel = ('callbackCancel' in objEntrante) ? objEntrante.callbackCancel : null;
objScriptEditar.callbackAccept = ('callbackAccept' in objEntrante) ? objEntrante.callbackAccept : null;
objScriptEditar.readOnly = !('readOnly' in objEntrante) ? false : objEntrante.readOnly  

var string = objScriptEditar.script_txt 

$('tbFiltro').hide()

  switch (objScriptEditar.protocolo.toUpperCase())
  {

      case 'SCRIPT':

          $('divRight').style.display = 'inline-block'

          $('cb_protocolo').selectedIndex = 4
          $('cb_protocolo').disabled = true

          $('cmb_lenguaje').value = objScriptEditar.lenguaje.toLowerCase() == '' ? 'js' : objScriptEditar.lenguaje.toLowerCase()
          $('cmb_cn').value = objScriptEditar.cod_cn ? objScriptEditar.cod_cn : $('cmb_cn').options[0].value

          if (objScriptEditar.parametros_extra.tipo_aisla) {
              if (objScriptEditar.parametros_extra.tipo_aisla.toLowerCase() == 'noaislar') {
                  $('cmb_tipo_aisla').hide()
                  $('tit_tp_aisla').hide()
              }
              else
                  $('cmb_tipo_aisla').value = objScriptEditar.parametros_extra.tipo_aisla
          }
          else
              $('cmb_tipo_aisla').options[0].value

          $('tbFiltro').show()
          $('trFiltroPie').hide()
          $('tbPFILE').hide()
          $('tbPMAILTO').hide()

          objScriptEditar.set_string(string)
          $('txt_script').value = objScriptEditar.string

          var contenedores = $('divRight').querySelectorAll(".contenedor")
          for (var i = 0; i < contenedores.length; i++)
              contenedores[i].hide()

          var contenedores = $('divRight').querySelectorAll(".diccionario")
          for (var i = 0; i < contenedores.length; i++)
              contenedores[i].show()

          if (!objScriptEditar.parametros_extra.tipo_aisla) {
              var contenedores = $('divRight').querySelectorAll(".tipo_aisla")
              for (var i = 0; i < contenedores.length; i++)
                  contenedores[i].hide()
          }

          if ($('cmb_lenguaje').value.toLowerCase() != 'sql') {
              $('divMenu').show()
              crearMenu()
              $('tbConexiones').hide()
              $('cmb_lenguaje').remove(3);
          }
          else {
              $('divMenu').hide()
              $('bt_agregar_cn').hide()
              $('bt_quitar_cn').hide()
              $('tbConexiones').show()
              $('cmb_cn').setStyle({ width: '100%' })
              $('cmb_lenguaje').remove(0);
              $('cmb_lenguaje').remove(0);
              $('cmb_lenguaje').remove(0);
          }

          $('cb_type').hide()
          $('cb_campos').hide()

          //   $('txt_script').value = dar_formato()

          setContent('txt_script', $('txt_script').value,{ extension: $('cmb_lenguaje').value, lineNumbers: true })
          
          cargarSelectorParametros()       

      break

    case 'XSL':

        $('divRight').style.display= 'inline-block'
        $('divMenu').hide()

        $('cb_protocolo').selectedIndex = 3
        $('tbFiltro').show()
        $('tbPFILE').hide()
        $('tbPMAILTO').hide()
        $('txt_script').value = string
        $('cb_protocolo').disabled = true
        $('btn_dar_formato').disabled = true
        $('btn_plantillas').disabled = true
        $('btn_exportar_reporte').disabled = true
        $('cb_parametros').disabled = true
        $('cb_param_add').disabled = true
        $('cb_type').disabled = true
        $('cb_campos').disabled = true
        setContent( 'txt_script', $('txt_script').value,{ extension: 'xml', lineNumbers: true })

       if (objScriptEditar.vista.toLowerCase() == "xml_xsl") {

            contenedores = $('divRight').querySelectorAll(".ocultar")
            for (var i = 0; i < contenedores.length; i++)
                contenedores[i].hide()

            contenedores = $('divRight').querySelectorAll(".class_paramstros")
            for (var i = 0; i < contenedores.length; i++)
                contenedores[i].setStyle({ width: '100%' })
        }

        var contenedores = $('divRight').querySelectorAll(".lenguaje")
        for (var i = 0; i < contenedores.length; i++)
            contenedores[i].hide()

        var contenedores = $('divRight').querySelectorAll(".param_old")
        for (var i = 0; i < contenedores.length; i++)
            contenedores[i].hide()

             cargarSelectorParametros()  
        break

    case 'XML':

        $('divRight').style.display= 'inline-block'
        $('divMenu').hide()

        $('cb_protocolo').selectedIndex = 0
        $('tbFiltro').show()
        $('tbPFILE').hide()
        $('tbPMAILTO').hide()
        objScriptEditar.set_string(string)
        $('txt_script').value = objScriptEditar.string
       
        $('cb_protocolo').disabled = true
          
        $('txt_script').value = dar_formato()
        setContent('txt_script', $('txt_script').value,{ extension: 'xml', lineNumbers: true })

        if (objScriptEditar.vista.toLowerCase() == "parametros") {

            contenedores = $('divRight').querySelectorAll(".ocultar")
            for (var i = 0; i < contenedores.length; i++)
                contenedores[i].hide()

            contenedores = $('divRight').querySelectorAll(".class_paramstros")
            for (var i = 0; i < contenedores.length; i++)
                contenedores[i].setStyle({ width: '100%' })
        }

        var contenedores = $('divRight').querySelectorAll(".lenguaje")
        for (var i = 0; i < contenedores.length; i++)
            contenedores[i].hide()

        var contenedores = $('divRight').querySelectorAll(".tipo_aisla")
        for (var i = 0; i < contenedores.length; i++)
              contenedores[i].hide()

        var contenedores = $('divRight').querySelectorAll(".param_old")
        for (var i = 0; i < contenedores.length; i++)
            contenedores[i].hide()

        cargarSelectorParametros()

        break 

    case 'FILE':

      var arTarget = objScriptEditar.target_parse(objScriptEditar.script_txt)

          if (!arTarget[0]) {
            arTarget = new Array()
            arTarget[0] = new Array()
      }

      if (((objScriptEditar['protocolo'] != '' && arTarget[0]['protocolo'] == '') || !arTarget[0]['protocolo']) || objScriptEditar['protocolo'] == 'XSL')
          arTarget[0]['protocolo'] = objScriptEditar['protocolo']


      // $('divRight').hide()
       $('divMenu').hide()
       $('modXML').hide()
       $('divRight').style.display = 'inline-block'

       var contenedores = $('divRight').querySelectorAll(".contenedor")
       for (var i = 0; i < contenedores.length; i++)
           contenedores[i].hide()

       var contenedores = $('divRight').querySelectorAll(".diccionario")
       for (var i = 0; i < contenedores.length; i++)
          contenedores[i].show()

       var contenedores = $('divRight').querySelectorAll(".lenguaje")
       for (var i = 0; i < contenedores.length; i++)
           contenedores[i].hide()

       var contenedores = $('divRight').querySelectorAll(".tipo_aisla")
       for (var i = 0; i < contenedores.length; i++)
          contenedores[i].hide()

       cargarSelectorParametros()

        if ($('cb_protocolo')[0].value == "XML")
            $('cb_protocolo').remove(0);
        if ($('cb_protocolo')[2].value == "XSL")
            $('cb_protocolo').remove(2);

        $('cb_protocolo').selectedIndex = 0
        $('tbFiltro').hide()
        $('tbPFILE').show()
          $('tbPMAILTO').hide()


        $('txt_target').value = arTarget[0]['path'] == undefined ? 'directorio_archivos/' : arTarget[0]['path']

        if ($('txt_target').value.indexOf('[%local%]') > -1) {
          $('seluri').value = 'local'
          $('txt_target').value  =  $('txt_target').value.replace('[%local%]','') 
          }

        setContent('txt_target', $('txt_target').value,{ extension: $('cmb_lenguaje').value, lineNumbers: false })


        $('xls_save_as').value = arTarget[0]['xls_save_as'] == undefined ? '' : arTarget[0]['xls_save_as']
        $('codificacion').value = arTarget[0]['codificacion'] == '' ? 'iso88591' : arTarget[0]['codificacion']
       
        $('comp_metodo').value = arTarget[0]['comp_metodo'] == undefined ? '' : arTarget[0]['comp_metodo']
        $('comp_algoritmo').value = arTarget[0]['comp_algoritmo'] == undefined ? '' : arTarget[0]['comp_algoritmo']
        $('comp_filename').value = arTarget[0]['comp_filename'] == undefined ? '' : arTarget[0]['comp_filename']
        $('comp_pwd').value = arTarget[0]['xls_save_as'] == undefined ? '' : arTarget[0]['comp_pwd']
        $('target_agregar').checked = arTarget[0]['target_agregar'] == undefined ? false : (arTarget[0]['target_agregar'].toLowerCase() == 'false' ? false : true)
        
        $('comp_check').checked = $('comp_metodo').value != "" ? true : false
        onclick_comp_check()

        valTxt_target()
        valXls_save_as()
        valTarget_agregar()

        setContent('txt_script', $('txt_script').value,{ extension: $('cmb_lenguaje').value, lineNumbers: true })

        break
    case 'MAILTO':

        var arTarget = objScriptEditar.target_parse(objScriptEditar.script_txt)

        if (!arTarget[0]) {
              arTarget = new Array()
              arTarget[0] = new Array()
          }

        if (((objScriptEditar['protocolo'] != '' && arTarget[0]['protocolo'] == '') || !arTarget[0]['protocolo']) || objScriptEditar['protocolo'] == 'XSL')
              arTarget[0]['protocolo'] = objScriptEditar['protocolo']

        $('divRight').hide()
        $('divMenu').hide()

        if($('cb_protocolo')[0].value == "XML")          
           $('cb_protocolo').remove(0);
        if ($('cb_protocolo')[2].value == "XSL")
           $('cb_protocolo').remove(2);

        $('cb_protocolo').selectedIndex = 1
        $('cb_campos').options.length = 2
        $('cb_campos').options[0].text = 'user@mail.com.ar'
        $('tbFiltro').hide()
        $('tbPFILE').hide()
        $('tbPMAILTO').show()
        campos_defs.set_value("from",arTarget[0]['from'])
        $('txt_to').value = arTarget[0]['to']
        $('txt_cc').value = arTarget[0]['cc']
        $('txt_co').value = arTarget[0]['co']
        $('txt_subject').value = arTarget[0]['subject']
        $('txt_body').value = arTarget[0]['body']

        setContent('txt_body', $('txt_body').value,{ extension: 'txt', lineNumbers: true })

    break
      
  }
 
//parametro_cargar()
campo_cargar()
type_cargar()
    
$('cmb_lenguaje').disabled = objScriptEditar.lenguajeReadOnly

if (objScriptEditar['tipo'] == 'RPT')
    $('cb_protocolo').disabled = true


//nvFW.bloqueo_desactivar($$("BODY")[0], 'bloq')

window_onresize()


}



function type_cargar()
{
    
  var isSelect = false
  var obj = new tXML();
  if (obj.loadXML($('txt_script').value))
      isSelect = selectSingleNode('criterio/select', obj.xml) ? true : false

  $('cb_type').length = 0
  for (var i in objScriptEditar.type)
  {
    if (!isSelect && objScriptEditar.type[i]['tipo'] == 'select')
       continue;

    if (isSelect && objScriptEditar.type[i]['tipo'] == 'procedure')
       continue;

    $('cb_type').options.length++
    $('cb_type').options[$('cb_type').options.length - 1].value = objScriptEditar.type[i]['filtroWhere']
    $('cb_type').options[$('cb_type').options.length - 1].text = objScriptEditar.type[i]['desc']

   }
 }  


function parametro_cargar()
 {
 $('cb_parametros').length = 0
//for (var i in objScriptEditar.parametros)
for (var i = 0; i < objScriptEditar.parametros.size(); i++) 
   {
   $('cb_parametros').options.length++
   $('cb_parametros').options[$('cb_parametros').options.length-1].value = objScriptEditar.parametros[i]['parametro']
   $('cb_parametros').options[$('cb_parametros').options.length-1].text = objScriptEditar.parametros[i]['parametro']
   }

   $('cb_param_add').length = 0

//for (i in objScriptEditar.param_add)
for (var i = 0; i < objScriptEditar.param_add.size(); i++) 
   {
   $('cb_param_add').options.length++
   $('cb_param_add').options[$('cb_param_add').options.length-1].value = objScriptEditar.param_add[i].parametro
   $('cb_param_add').options[$('cb_param_add').options.length-1].text = objScriptEditar.param_add[i].etiqueta
   }  

 }
 
 function campo_cargar()
 {

     
   try { editor.save() } catch (e) { }

   objScriptEditar.string = $('txt_script').value

   var campos = objScriptEditar.get_campos()
   $('cb_campos').options.length = 0
   for (i in campos)
     {
     $('cb_campos').options.length++
     $('cb_campos').options[$('cb_campos').options.length-1].text = campos[i]
     }
   }
   
 function add_parametro(e)
   {
     cb = !Prototype.Browser.IE ? Event.element(e).parentElement : Event.element(e)
     
     var parametro = ""
     if (objScriptEditar['vista'] == 'parametros')
       parametro = "<" + cb.options[cb.selectedIndex].text + ">{" + cb.options[cb.selectedIndex].text + "}</" + cb.options[cb.selectedIndex].text + ">"
     else
        if (objScriptEditar['lenguaje'].toUpperCase() == 'SQL')
            parametro = "{" + cb.options[cb.selectedIndex].text + "}"
        else
            parametro = cb.options[cb.selectedIndex].text

   
   $('txt_sel').value = parametro
   if(Prototype.Browser.IE)
     window.clipboardData.setData("Text", parametro)
   
   }

 function add_param_add(e)
   {
   cb = !Prototype.Browser.IE ? Event.element(e).parentElement : Event.element(e)
   var parametro = "{%" + cb.options[cb.selectedIndex].text + "%}"
   $('txt_sel').value = parametro
   if(Prototype.Browser.IE)
     window.clipboardData.setData("Text", parametro)

   }
   
 function add_type(e)
   {

   cb = !Prototype.Browser.IE ? Event.element(e).parentElement : Event.element(e)
   var str = cb.options[cb.selectedIndex].value
   if ($('cb_campos').selectedIndex >= 0)
     {
     var campo = $('cb_campos').options[$('cb_campos').selectedIndex].text
     var r = RegExp("\\?", "ig")
     str = str.replace(r, campo)
     }
   $('txt_sel').value = str 
   if(Prototype.Browser.IE)
     window.clipboardData.setData("Text", str)

   $('txt_sel').select()
   }  
   
 function add_campo(e)
   {
   cb = !Prototype.Browser.IE ? Event.element(e).parentElement : Event.element(e)
   var campo = cb.options[cb.selectedIndex].text
   $('txt_sel').value = campo
   if(Prototype.Browser.IE)
       window.clipboardData.setData("Text", campo)

   $('txt_sel').select()
   }    

function Aceptar() 
  { 
    
  try { editor.save() } catch (e) { }

  var msj = ''
  //si es filtro o Target
  switch ($('cb_protocolo')[$('cb_protocolo').selectedIndex].value)
    {
    case 'XSL':
        string = $('txt_script').value
    break
    case 'SCRIPT':
       string = $('txt_script').value
       var script = objScriptEditar.string_to_script($('txt_script').value,false)
    break
    case 'XML': 
       string = $('txt_script').value
       var script = objScriptEditar.string_to_script($('txt_script').value,false)
      break
    case 'MAILTO':
      var to = $('txt_to').value
      if (to == '')
        {
        alert('Para no est� definido')
        return
        }
      if (to.indexOf(';') != -1)  
        mailto = to.substring(0, to.indexOf(';')-1)
      else
        mailto = to  
    
      var string = 'MAILTO://' + mailto + '?from=' + campos_defs.value("from") + '&to=' + to + '&cc=' + $('txt_cc').value + '&co=' + $('txt_co').value + '&subject=' + $('txt_subject').value + '&body=' + $('txt_body').value
      var script =  objScriptEditar.string_to_script(string,false)
    break
    case 'FILE':
        
        var string = 'FILE://' + ($('seluri').value != 'default' ? '[%local%]': '') + $('txt_target').value  
        
        if(!$('comp_check').checked)
        {
            $('comp_metodo').value = ""
            $('comp_algoritmo').value = ""
            $('comp_pwd').value = ""
            $('comp_filename').value = ""
        }
        
        string += "||<opcional "
        string += " xls_save_as='" + ($('xls_save_as').value > 0 ? $('xls_save_as').value : '') + "'"
        string += " comp_metodo='" + ($('comp_metodo').value != "" ? $('comp_metodo').value : '') + "'"
        string += " comp_algoritmo='" + ($('comp_algoritmo').value != "" ? $('comp_algoritmo').value : '') + "'"
        string += " comp_filename='" + ($('comp_filename').value != "" ? $('comp_filename').value : '') + "'"
        string += " comp_pwd='" + ($('comp_pwd').value != "" ? $('comp_pwd').value : '') + "'"
        string += " target_agregar ='" + ($('target_agregar').checked ? 'true' : 'false') + "'"
        string += " codificacion='" + $('codificacion').value + "'"
        string += " ></opcional>||"
        
        var script = objScriptEditar.string_to_script(string,false)
       
        break
  
    }
  

  var res = null
  if ($('cb_protocolo')[$('cb_protocolo').selectedIndex].value != 'XSL')// && $('cb_protocolo')[$('cb_protocolo').selectedIndex].value != 'SCRIPT')
   {
      //validar que no existan parametros sin conversion
      var str = "\\{%([^\\}]*)%\\}"
      var r = new RegExp(str)
      res = script.match(r)
      if (res != null)
       {
          msj = 'Hay una variable no encontrada\n' + res[0] + '\n�Desea continuar?' 
          
          Dialog.confirm(msj, {
                                      width: 300,
                                      className: "alphacube",
                                      okLabel: "Si",
                                      cancelLabel: "No",
                                      zIndex: 10,
                                      onOk: function(win_local) {
                                                           guardar(script, string)
                                                           if (objScriptEditar.callbackAccept)
                                                              objScriptEditar.callbackAccept()
                                                           else
                                                              close()

                                                           win_local.close(); return
                                      },
                                      onCancel: function(win_local) { win_local.close(); return }
                             });
        }//end if

        //validar que no existan parametros sin conversion
        var str = "\\{([^\\}]*)\\}"
        var r = new RegExp(str,"ig")
        res = script.match(r)
        if (res != null) {
            msj = 'Hay una variable no encontrada\n' + res[0] + '\n�Desea continuar?'
            Dialog.confirm(msj, {
                width: 300,
                className: "alphacube",
                okLabel: "Si",
                cancelLabel: "No",
                zIndex:10,
                onOk: function (win_local) {
                    guardar(script, string)
                    if (objScriptEditar.callbackAccept)
                      objScriptEditar.callbackAccept()
                    else
                     close()
                    win_local.close(); return
                },
                onCancel: function(win_local) { win_local.close(); return }
            });
        } //en if
   }
 
 if(res == null)
  {

     guardar(script, string)

     if (objScriptEditar.callbackAccept)
         objScriptEditar.callbackAccept()
     else
         close()

  } 
 
 }

function close() {

    if (objScriptEditar.callbackCancel)
       objScriptEditar.callbackCancel()
    else
       _parent.close()

}

function guardar(script,string)
{
    if (_parent.options.Transferencia)
     {
        var indice = _parent.options.indice
        if (_parent.options.indice == -1) {
            _parent.options.Transferencia["detalle"].length++
            indice = Transferencia["detalle"].length - 1
            _parent.options.Transferencia["detalle"][indice] = new Array();
        }      

        if (parent.transferencia.value == "") {
            parent.transferencia.value = "Tarea " + parent.cb_transf_tipo.value + "(" + indice + ")"
        }

        _parent.options.Transferencia["detalle"][indice]["orden"] = indice
        _parent.options.Transferencia["detalle"][indice]["transf_tipo"] = parent.cb_transf_tipo.value
        _parent.options.Transferencia["detalle"][indice]["transferencia"] = parent.transferencia.value
        _parent.options.Transferencia["detalle"][indice]["opcional"] = parent.opcional.checked
        _parent.options.Transferencia["detalle"][indice]["transf_estado"] = parent.estado.value
        _parent.options.Transferencia["detalle"][indice]["TSQL"] = string
        _parent.options.Transferencia["detalle"][indice]['cod_cn'] = $('cmb_cn').value;
        _parent.options.Transferencia["detalle"][indice]['lenguaje'] = $('cmb_lenguaje').value;
        _parent.options.Transferencia["detalle"][indice].parametros_extra.title_hide = parent.$('title_hide').checked;
        
     }

    _parent.options.objScriptEditar.script_txt = string  
    _parent.options.objScriptEditar.string = string
    _parent.options.objScriptEditar.script = script
    _parent.options.objScriptEditar.lenguaje = $("cmb_lenguaje").value

    try {
        if (_parent.options.objScriptEditar.parametros_extra.tipo_aisla)
            _parent.options.objScriptEditar.parametros_extra.tipo_aisla = $('cmb_tipo_aisla').value
    }
    catch (e) { }

//    _parent.options.objScriptEditar.cod_cn = $("cmb_cn").value
    _parent.returnValue = 'OK'

}

function Cancelar()  
  {
    close()
  }

function btn_validar_xml() 
{
 try { editor.save() } catch (e) { }

 var strError = validar_xml()
 if (strError != '')
   Dialog.alert(strError, { className: "alphacube", width: 300, height: 200, okLabel: "cerrar",zIndex:100000 });
 else
   alert('Validaci�n OK')
}

function validar_xml()
{
 var strXML = $('txt_script').value
 var strError = ''

 var objXML = new tXML();
 if (!objXML.loadXML(strXML)) 
 {
    strError = 'C�digo: ' + objXML.parseError.numError + '</br>Descripci�n: ' + objXML.parseError.description
  }
  
  if (strError != '')  
   return 'Validaci�n Erronea.</br>' + strError
 else 
   return ''

}

function dar_formato_onclick()
{
    try { editor.save() } catch (e) { }
      var strError = validar_xml()
      if (strError != '') 
      {
          alert(strError)
          return
      }
  
      $('txt_script').value = dar_formato()
      editor.setValue($('txt_script').value);

  }


function dar_formato(strXML, orden) 
{ 
  if(!orden)
    orden = 1
    
  if (!strXML)
    strXML = $('txt_script').value  
  
  var espacios = '\n'
  var espacios_fin = '\n'
  for(var n = 1; n<=orden; n++)
    espacios += '    '
  espacios_fin = espacios.substring(0, espacios.length-4)

  //Eliminar saltos de linea
  exp = "\\s*" + String.fromCharCode(13) + String.fromCharCode(10) + "\\s*" 
  r = new RegExp(exp, "ig")
  strXML = strXML.replace(r, "")
  
  exp = "\\s*\n\\s*" 
  r = new RegExp(exp, "ig")
  strXML = strXML.replace(r, "")
  
  res = ''
  //Busca el patron <*></*>
  r = /<([\w]+)([^>]*)>(.*)<\/\1>/
  //r.lastIndex = 2
  res_match = strXML.match(r)

  while (res_match != null) 
   {
    var lastIndex = 0

    try { lastIndex = res_match[0].length } catch (e) { }//res_match.lastIndex

   var uno = strXML.substring(0, lastIndex)
   var dos = strXML.substring(lastIndex) 
   var tres = res_match[3]

    try {
        if (res_match[0].split("</" + res_match[1] + ">").length > 2) {
            uno = "<AND></AND>"
            dos = strXML.substring(0, res_match[0].indexOf("</" + res_match[1] + ">")) + ("</" + res_match[1] + ">")
            tres = strXML.substring((strXML.substring(0, res_match[0].indexOf("</" + res_match[1] + ">")) + ("</" + res_match[1] + ">")).length, strXML.length)
          }
      }
    catch (e) {
        uno = strXML.substring(0, lastIndex)
        dos = strXML.substring(lastIndex) 
        tres = res_match[3]
    }

    //var uno = strXML.substring(0, lastIndex)
    //var dos = strXML.substring(lastIndex) 
    //var tres = res_match[3]
    
    var res_match2 = tres.match(r)
    if (res_match2 != null)
      res += uno.replace(r, "<$1$2>" + espacios + dar_formato(tres, orden+1) + espacios_fin + "</$1>")
    else
      res += uno
    
    if (dos != '')  
      res += espacios_fin
    strXML = dos
    res_match = strXML.match(r) 
    }
  return res
  }

function btn_cancelar_onclick ()
{
 close()
}

  
function protocolo_cambiar() 
  {
   var protocolo = $('cb_protocolo').options[$('cb_protocolo').selectedIndex].value

   try { editor.save() } catch (e) { }

  $('cb_campos').length = 0

  $('cb_parametros').disabled = false
  $('cb_param_add').disabled = false
  $('cb_type').disabled = false
  $('cb_campos').disabled = false
  $('btn_dar_formato').disabled = false
  $('btn_exportar_reporte').disabled = false
  
  switch (protocolo)
    {
    case 'XSL':
       $('cb_campos').options.length = 0
       $('tbFiltro').show()
       $('tbPFILE').hide()
       $('tbPMAILTO').hide()
       $('txt_target').value = ''
       $('cb_parametros').disabled = true
       $('cb_param_add').disabled = true
       $('cb_type').disabled = true
       $('cb_campos').disabled = true
       $('btn_dar_formato').disabled = true
       $('btn_exportar_reporte').disabled = true
    break
    case 'XML':
        $('cb_campos').options.length = 0
        $('tbFiltro').show()
        $('tbPFILE').hide()
        $('tbPMAILTO').hide()
        $('txt_target').value = ''
        campo_cargar()
    break
    case 'FILE':
        $('cb_campos').options.length = 1
        $('tbFiltro').hide()
        $('tbPFILE').show()
        $('tbPMAILTO').hide()
        $('txt_target').value = ''
        $('modXML').hide()
    break
    case 'MAILTO':
        $('cb_campos').options.length = 2
        $('tbFiltro').hide()
        $('cb_campos').options[0].text = 'user@mail.com.ar'
        $('tbPFILE').hide()
        $('tbPMAILTO').show()
        campos_defs.clear("from")
        $('txt_to').value = ''
        $('txt_cc').value = ''
        $('txt_co').value = ''
        $('txt_subject').value = ''
        $('txt_body').value = ''

      if(!editor)
        setContent('txt_body', $('txt_body').value,{ extension: 'text', lineNumbers: true })

      break
    }
    
  }
  
  function path_file_onchange()
 {
  var ruta = ""
  ruta = $('file_target').value 
  var strXML = ruta.split(":\\")[1]; 
  var exp = "\\\\.*\\\\" 
  var r = new RegExp(exp,"ig")
  strXML = strXML.replace(r, "/")
  if (strXML != '')
  {
   path = 'directorio_archivos/' + strXML
   $('txt_target').value = path
  }
}

var winEjecutar_consulta
var consulta
var parametros_ec = {}
function salida_base() 
{
    
   try { editor.save() } catch (e) { }
   var strError = validar_xml()
   if (strError != '') 
     {
      alert(strError)
      return
     }
        
    var filtroXML
    try {
        filtroXML = $('txt_script').value //eval(replace(objScriptEditar.string_to_script($('txt_script').value), "\\n", ""))
        }
    catch (e) {alert(e.description); return;}
    
    var objXML = new tXML();
    if (objXML.loadXML(filtroXML)) {
        if (objXML.selectSingleNode("criterio/procedure") != null) {
            alert("Imposible verificar resultado.</br>Es un procedimiento almacenado.")
            return
        }

        if (objXML.selectSingleNode("criterio/select/filtro") != null) {
            var NOD = objXML.selectNodes('criterio/select/filtro')[0].childNodes
            for (i = 0; i < NOD.length; i++) {

                parametro = XMLText(selectSingleNode('.', NOD[i]))
                parametro = replace(parametro, "{", "")
                parametro = replace(parametro, "}", "")

                parametros_ec[i] = {}
                parametros_ec[i].parametro = parametro;
            }
        }

        $('divParametros').innerHTML = ""

        var strHTML = ""
        strHTML += "<table class='tb1' style='width:100%'>"
        strHTML += "<tr>"
        strHTML += "<td style='text-align:left;width:30%'>&nbsp;</td>"
        strHTML += "</tr>"
        strHTML += "<tr>"
        strHTML += "<td colspan='3' class='Tit4' style='text-align:left;width:30%'>Debe ingresar valores a los par�metros definidos en la consulta.</td>"
        strHTML += "</tr>"
        strHTML += "<tr>"
        strHTML += "<td class='Tit4' style='text-align:left;width:40%'>Cantidad de registros de salida:</td>"
        strHTML += "<td style='text-align:left;width:10%'>"
        strHTML += "<input style='width:100%;' type='text' name='cantidad_registro' id='cantidad_registro' value='10'/>"
        strHTML += "</td>"
        strHTML += "<td style='text-align:center'>&nbsp;</td>"
        strHTML += "</tr>"
        strHTML += "</table>"
        strHTML += "<table class='tb1' style='width:100%'>"
        strHTML += "<tr class='tbLabel contenedor'>"
        strHTML += "<td style='width:30%; text-align:center; vertical-align:middle'>Par�metro</td>"
        strHTML += "<td style='text-align:center; vertical-align:middle'>Valor</td>"
        strHTML += "</tr>"
        strHTML += "</table>"

        strHTML += "<div style='width:100%;height:60%;overflow:auto' id='divBodyParametros'>"
        strHTML += "<table class='tb1' style='width:100%' id='tbParametros'>"
        var i = 0
        for (var i in parametros_ec)
        {
            strHTML += "<tr>"
            strHTML += "<td class='Tit4' style='width:30%;text-align:left; vertical-align:middle' name='parametro" + i + "' id='parametro" + i + "'>" + parametros_ec[i].parametro + "</td>"
            strHTML += "<td style='text-align:left; vertical-align:middle'><input style='width:100%;' type='text' name='parametro_valor" + i + "' id='parametro_valor" + i + "' value=''/></td>"
            strHTML += "</tr>"
            i++
        }
        strHTML += "</table>"
        strHTML += "</div>"

        strHTML += "<table class='tb1' style='width:100%'>"
        strHTML += "<tr>"
        strHTML += "<td style='text-align:center;width:10%'>&nbsp;</td>"
        strHTML += "<td style='text-align:center;width:35%'><input type='button' style='width:100%' value='Aceptar' onclick='btn_aceptar_ec_onclick()' /></td>"
        strHTML += "<td style='text-align:center;width:10%'>&nbsp;</td>"
        strHTML += "<td style='text-align:center;width:35%'><input type='button' style='width:100%' value='Cancelar' onclick='btn_cancelar_ec_onclick()' /></td>"
        strHTML += "<td style='text-align:center;width:10%'>&nbsp;</td>"
        strHTML += "</tr>"
        strHTML += "</table>"
        strHTML += "</table>"

        $('divParametros').insert({ top: strHTML })

        winEjecutar_consulta = nvFW.createWindow({
            width: 800, height: 350, zIndex: 100,
            draggable: true,
            resizable: true,
            closable: true,
            minimizable: false,
            maximizable: false,
            title: "<b>Ejecutar Consulta</b>",
            onShow: function (win) {
            }
        })

        winEjecutar_consulta.getContent().innerHTML = $('divParametros').innerHTML
        winEjecutar_consulta.showCenter(true);

    }

}

function btn_aceptar_ec_onclick()
{
    
    var filtroXML = $('txt_script').value
    var objXML = new tXML();
    if (!objXML.loadXML(filtroXML)) {
        alert("Error al generar su consulta. Verifique")
        return
    }

    //cargar atributos
    if (selectSingleNode("criterio/select", objXML.xml))
    {
        if (!selectSingleNode("criterio/select/@top", objXML.xml))
            selectSingleNode("criterio/select", objXML.xml).setAttribute("top", $('cantidad_registro').value)
        else
            selectSingleNode("criterio/select/@top", objXML.xml).nodeValue = $('cantidad_registro').value

        filtroXML = XMLtoString(objXML.xml)

        selectSingleNode("criterio/select", objXML.xml).setAttribute("AbsolutePage", "1")
        selectSingleNode("criterio/select", objXML.xml).setAttribute("PageSize", $('cantidad_registro').value)
        selectSingleNode("criterio/select", objXML.xml).setAttribute("CacheControl", "none")
    }
    
    //reemplazar por valor
    for (var i in parametros_ec) {
        strExp = "\\{(" + parametros_ec[i].parametro + ")\\}"
        reg = new RegExp(strExp, "ig")
        filtroXML = filtroXML.replace(reg, "'" + $('parametro_valor' + i).value + "'")
        i++
    }

    ////encriptar
    //nvFW.error_ajax_request('/fw/transferencia/editor_script.aspx', {
    //    parameters: {
    //        accion: 'getEncFiltro'
    //      , strXML: escape(filtroXML)
    //    },
    //    asynchronous: false,
    //    onSuccess: function (err, transport) {
    //        filtroXML = err.params.strXML
    //    }
    //});

    $('formExportar').action = 'editor_script.aspx?modo=Exportar&filtroXML='+ escape(filtroXML)
    $('formExportar').submit()

    //consultar
    //nvFW.exportarReporte({
    //    filtroXML: filtroXML
    //    , path_xsl: "\\report\\html_base.xsl"
    //    , salida_tipo: "adjunto"
    //    , formTarget: "_blank"
    //    , onError: function () { debugger }
    //})

}

function btn_cancelar_ec_onclick() {
    winEjecutar_consulta.close()
}

function editar_conexion(modo)
{
    try { editor.save() } catch (e) { }

    var consulta = $('txt_script').value
    var objXML = new tXML();
    if (objXML.loadXML(consulta)) {
        if (selectSingleNode("criterio/procedure", objXML.xml))
            if (!selectSingleNode("criterio/procedure/@cn", objXML.xml) && modo != "eliminar")
                selectSingleNode("criterio/procedure", objXML.xml).setAttribute("cn", $('cmb_cn').value)
            else {
                if (modo == "eliminar")
                    selectSingleNode("criterio/procedure", objXML.xml).removeAttribute("cn")
                else
                    selectSingleNode("criterio/procedure/@cn", objXML.xml).nodeValue = $('cmb_cn').value
            }


        if (selectSingleNode("criterio/select", objXML.xml))
            if (!selectSingleNode("criterio/select/@cn", objXML.xml) && modo != "eliminar")
                selectSingleNode("criterio/select", objXML.xml).setAttribute("cn", $('cmb_cn').value)
            else {
                if (modo == "eliminar")
                    selectSingleNode("criterio/select", objXML.xml).removeAttribute("cn")
                else
                    selectSingleNode("criterio/select/@cn", objXML.xml).nodeValue = $('cmb_cn').value
            }


        $('txt_script').value = XMLtoString(objXML.xml)
        editor.setValue($('txt_script').value);
    }
    else {
        alert("Consulta mal generada. Verifique")
    }
}

var winPlantilla
function seleccionar_plantillas()
{
         winPlantilla = nvFW.createWindow({
            name: "sasara", width: 800, height: 270, zIndex: 100,
            draggable: false,
            resizable: false,
            closable: true,
            minimizable: false,
            maximizable: false,
            title: "<b>Seleccione una plantilla para dise�ar</b>",
            onShow: function (win) {
                $('pSelect').innerText = "<criterio><select cn='' top='' vista=''><campos>*</campos><filtro></filtro><grupo></grupo><orden></orden></select></criterio>"
                $('pProcedure').innerText = "<criterio><procedure cn='' CommandText='' CommantTimeOut='' vista=''><parametros></parametros></procedure></criterio>"
                $('pParams').innerText = "<params></params>"
            }
        })

        winPlantilla.getContent().innerHTML = $('divPlantillas').innerHTML
        winPlantilla.showCenter(true);
}

function btn_aceptar_plantilla_onclick()
{
    if ($('Rplantilla0').checked)
        $('txt_script').value = $('pSelect').innerText 

    if ($('Rplantilla1').checked)
        $('txt_script').value = $('pProcedure').innerText

    if ($('Rplantilla2').checked)
        $('txt_script').value = $('pParams').innerText

    $('txt_script').value = dar_formato()
    editor.setValue($('txt_script').value);

    //campo_cargar()
    type_cargar()

    try { editor.save() } catch (e) { }
    winPlantilla.close()
}

function btn_cancelar_plantilla_onclick() {
    winPlantilla.close()
}

function onclick_comp_check()
{
    if (!$('comp_check').checked)
        $('trCompri').hide()
    else
    {
        if ($('comp_metodo').value == "")
           $('comp_metodo').value = 'zip'

        $('trCompri').show()
    }
}

function valTxt_target_ondrop(event)
{
    event.preventDefault();

    var datos = {};
    eval(event.dataTransfer.getData("Data"));

    if (!datos.parametro)
        return false;

    var el = Event.element(event)
    el.value = el.value + datos.parametro
    //$('txt_target').value = $('txt_target').value + datos.parametro

}

function valTxt_target() {
    
        var eval = false
        if ($('txt_target').value.split(".")[1]) {
          var valor = $('txt_target').value.split(".")[1]
          if (valor == 'xls' || valor == 'xlsx' || valor == 'pdf')
               eval = true
        }

        if (!eval) {
            $('xls_save_as').value = 0
            $('xls_save_as').disabled = true
            $('target_agregar').checked = false
            $('target_agregar').disabled = true
        }
        else {
            $('xls_save_as').disabled = false
            $('target_agregar').disabled = false
        }

}

function valXls_save_as() {

            var eval = false
            if ($('txt_target').value.split(".")[1]) {
                var valor = $('txt_target').value.split(".")[1]
                if (valor == 'xls' || valor == 'xlsx' || valor == 'pdf') {
                    if ($('xls_save_as').value == 0) 
                        eval = true
                }
            }

            if (!eval) {
                $('target_agregar').checked = false
                $('target_agregar').disabled = true
            }
            else
                $('target_agregar').disabled = false

}

function valTarget_agregar() {
    
        var eval = false
        if ($('target_agregar').checked) {
            if ($('txt_target').value.split(".")[1]) {
                var valor = $('txt_target').value.split(".")[1]
                if (valor == 'xls' || valor == 'xlsx') {
                    eval = false
                }
            }
        }
        else
            eval = true

        if (!eval) {
                $('xls_save_as').value = 0
                $('xls_save_as').disabled = true
        }
        else {
                $('xls_save_as').disabled = false
        }

}

function onchange_lenguje() {

            if ($('cmb_lenguaje').value == "vb")
                setContent('txt_script', $('txt_script').value,{ extension: 'vb', lineNumbers: true })

            if ($('cmb_lenguaje').value == "js")
                setContent('txt_script', $('txt_script').value,{ extension: 'js', lineNumbers: true })

            if ($('cmb_lenguaje').value == "cs")
              setContent('txt_script', $('txt_script').value, { extension: 'cs', lineNumbers: true })

            objScriptEditar.lenguaje = $('cmb_lenguaje').value      

        }

        var vMenu
        function crearMenu() {

            vMenu = new tMenu('divMenu', 'vMenu');
            vMenu.alineacion = 'izquierda';
            vMenu.estilo = 'B';
            var ImagenesTransf = {};
            ImagenesTransf['buscar'] = new Image();
            ImagenesTransf['buscar'].src = '/FW/image/transferencia/buscar.png';
            ImagenesTransf['procesar'] = new Image();
            ImagenesTransf['procesar'].src = '/FW/image/transferencia/procesar.png';
            ImagenesTransf['nueva'] = new Image();
            ImagenesTransf['nueva'].src = '/FW/image/transferencia/nueva.png';

            vMenu.imagenes = ImagenesTransf;
            var menuXmlIzq = '<?xml version="1.0" encoding="ISO-8859-1"?>';
            menuXmlIzq += '<resultado>';
            menuXmlIzq += '     <MenuItems>';
            menuXmlIzq += '         <MenuItem id="10">';
            menuXmlIzq += '            <Lib TipoLib="offLine">DocMNG</Lib>';
            menuXmlIzq += '            <icono>nueva</icono>';
            menuXmlIzq += '            <Desc>Pizarra</Desc>';
            menuXmlIzq += '            <MenuItems>';
            menuXmlIzq += '                <MenuItem id="11">';
            menuXmlIzq += '                <Lib TipoLib="offLine">DocMNG</Lib>';
            menuXmlIzq += '                <icono>nueva</icono>';
            menuXmlIzq += '                <Desc>Agregar</Desc>';
            menuXmlIzq += '                <Acciones>';
            menuXmlIzq += '                  <Ejecutar Tipo="script">';
            menuXmlIzq += '                     <Codigo>agregar_pizarra()</Codigo>';
            menuXmlIzq += '                  </Ejecutar>';
            menuXmlIzq += '                </Acciones>';
            menuXmlIzq += '               </MenuItem>';
            menuXmlIzq += '            </MenuItems>';
            menuXmlIzq += '         </MenuItem>';
            menuXmlIzq += '     </MenuItems>';
            menuXmlIzq += '</resultado>';
            vMenu.CargarXML(menuXmlIzq);

            vMenu.MostrarMenu();
        }

        function agregar_pizarra() {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            winEditor = w.createWindow({
                title: '<b>Listar Pizarra</b>',
                url: '/fw/pizarra/calculos_pizarra_buscar.aspx?desplegarPizarra=false',
                minimizable: false,
                maximizable: true,
                draggable: true,
                width: 900,
                height: 450,
                resizable: true,
                destroyOnClose: true,
                onClose: return_listar_pizarra
            });

            winEditor.options.userData = [];
            winEditor.options.userData.nro_calc_pizarra
            winEditor.showCenter(true)

        }


        function return_listar_pizarra() {
            
          var cadena = ""        
          var nro_calc_pizarra = winEditor.options.userData.nro_calc_pizarra
          var rs = new tRS();
          rs.open(nvFW.pageContents.filtro_pizarra, "", "<nro_calc_pizarra type='igual'>" + nro_calc_pizarra + "</nro_calc_pizarra>", "")
          while (!rs.eof()) {

              var calc_pizarra = rs.getdata("calc_pizarra")

              if (cadena == '')
                  cadena = "{" + rs.getdata("calc_pizarra_dato") + "}"
              else
                  cadena += ",{" + rs.getdata("calc_pizarra_dato") + "}"

              rs.movenext()
          }

          var selection = editor.getSelection();
          editor.replaceSelection('Pizarra.value("' + replace(calc_pizarra,'"',"'") +'",'+ cadena +')' + selection);

          if (!selection) {
             var cursorPos = editor.getCursor();
             editor.setCursor(cursorPos.line, cursorPos.ch - 2);
          }

        }

        function validar_script() { }

        function txt_sel_ondrag(e) {
              event.dataTransfer.setData("Text", Event.element(e).value);
        }


        //function txt_sel_ondrop(e)
        //{
        //    debugger
        //    e.preventDefault();
        //    e.stopPropagation();

        //    var file;
        //    var files;

        //    // Check if files were dropped
        //    files = e.dataTransfer.files;
        //    if (files.length > 0) {
        //      file = files[0];
        //      alert('File: ' + file.name);
        //      return false;
        //    }

        //    var datos = {};
        //    eval(event.dataTransfer.getData("Data"));

        //    if (!datos.parametro)
        //      return false;

        //    var selection = data.getSelection();
        //    data.replaceSelection(datos.parametro + selection);
        //    if (!selection) {
        //       var cursorPos = data.getCursor();
        //       data.setCursor(cursorPos.line, cursorPos.ch - 2);
        //    }

        //    return false;

        //}

    </script>
     <style type="text/css">.CodeMirror-scroll { max-width: 100%; max-height: 94% }</style>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style='background-color:white;width:100%;height:100%;overflow:hidden'>
    <form id="formExportar" name="formExportar" method="POST" target="_blank" style="display:none"></form>
                <div id="divLeft" style="overflow:hidden;display:inline-block;vertical-align:top;width:78%">
                    <table class="tb1 contenedor" id='tbTarget' style="display:none">
                                    <tr class="tbLabel contenedor">
                                      <td colspan="3">Salida</td>
                                    </tr>
                                    <tr>
                                        <td class="Tit1">Protocolo:</td>
                                        <td style="width: 85%;">
                                            <select style="width: 100%" id="cb_protocolo" onchange="protocolo_cambiar()">
                                                <option value="XML">XML</option>
                                                <option value="FILE">FILE</option>
                                                <option value="MAILTO">MAILTO</option>
                                                <option value="XSL">XSL</option>
                                                <option value="SCRIPT">SCRIPT</option>
                                            </select>
                                        </td>
                                    </tr>
                                </table>
<div id="modXML">
                               <div id='divMenu' class="contenedor" style='display:block;width:100%'></div>
                               <div id="divScript" style="display:block;"><textarea id='txt_script' onchange="campo_cargar(event)"  style="vertical-align:top"></textarea></div>
                               <div id="divButtons" style="display:inline-block;width:100%" class="contenedor">
                                   <table id='tbFiltro' class="tb1" style="vertical-align:top">
                                    <tr  id="trFiltroPie">
                                       <td style="width: 25%">
                                         <input type="button" style="width: 100%; cursor:pointer" name="btn_dar_formato" id='btn_dar_formato' value="Dar formato" onclick="dar_formato_onclick()" />
                                       </td>
                                        <td style="width: 25%">
                                         <input type="button" style="width: 100%; cursor:pointer" name="btn_validar_xml" id='btn_validar_xml' value="Validar XML" onclick="btn_validar_xml()" />
                                       </td>
                                        <td style="width: 25%">
                                         <input type="button" style="width: 100%; cursor:pointer" name="btn_exportar_reporte" id='btn_exportar_reporte' value="Ejecutar Consulta" onclick="salida_base()" />
                                       </td>
                                        <td style="width: 25%">
                                         <input type="button" style="width: 100%; cursor:pointer" name="btn_plantillas" id='btn_plantillas' value="Plantillas" onclick="seleccionar_plantillas()" />
                                       </td>
                                    </tr>
                               </table>
                               </div>
</div>
<div id="modFILE">
                               <table class="tb1" id="tbPFILE" style="display:none">
                                                <tr>
                                                    <td class="Tit1" style="width: 5%">Destino:</td>
                                                    <td colspan="7"><select id="seluri" style="width:100%"><option value="default" selected="selected">Default</option><option value="local">Local</option></select></td>
                                                </tr>
                                                <tr>
                                                    <td class="Tit1" style="width: 5%">Ruta:</td>
                                                    <td colspan="7"><input type="text" style="width: 100%" id="txt_target" ondragenter="return false" ondragover="return false" onchange="valTxt_target()" onblur="valTxt_target()"  ondrop='valTxt_target_ondrop(event)'/></td>
                                                </tr>
                                                <tr>
                                                    <td class="Tit1" style="width: 5%">Codificaci�n:</td>
                                                    <td style="width: 10%"><select id="codificacion"><option value="Windows-1252">ANSI</option><option value="iso-8859-1" selected="selected" >ISO-8859-1</option><option value="utf-8">UTF-8</option></select></td>
                                                    <td class="Tit1" style="width: 8%;white-space:nowrap">Convertir a:</td>
                                                    <td><select name="xls_save_as" id="xls_save_as" style="width:100%" onchange="valXls_save_as()"><option value="0"></option><option value="20">Texto con formato (delimitado por tabulador)</option><option value="36">Texto con formato (delimitado por espacio)</option><option value="6">CSV (delimitado por coma)</option><option value="54">XML Excel (*.xml)</option><option value="51">Libro Excel (*.xlsx)</option><option value="56">Libro Excel 97-2003 (*.xls)</option><option value="57">PDF (*.pdf)</option></select></td>
                                                    <td class="Tit1" style="width: 5%;white-space:nowrap">Agregar Hoja:</td>
                                                    <td style="width: 3%"><input type="checkbox" id="target_agregar" style="width: 100%;border:0px" onclick="valTarget_agregar()"/></td>
                                                    <td class="Tit1" style="width: 5%">Comprimir:</td>
                                                    <td style="width: 3%"><input type="checkbox" id="comp_check" style="width: 100%;border:0px" onclick="return onclick_comp_check()"/></td>
                                                </tr>
                                                <tr id="trCompri">
                                                   <td  style="width: 100%" colspan="8" > 
                                                    <table class="tb1">
                                                      <tr>
                                                         <td  style="width: 10%;white-space:nowrap"  class="Tit1">Compresi�n:</td>
                                                          <td style="width: 10%;">
                                                              <select style="width: 100%" id="comp_metodo">
                                                                  <option value="zip" selected="selected">ZIP</option>
                                                                  <%--<option value="rar" selected="selected">RAR</option>--%>
                                                              </select>
                                                          </td>
                                                          <td  style="width: 10%;white-space:nowrap"  class="Tit1">Filename:</td>
                                                          <td  style="width: 20%"><input type="text" id="comp_filename" style="width: 100%" ondragenter="return false" ondragover="return false" ondrop='valTxt_target_ondrop(event)'/></td>
                                                          <td  style="width: 10%;white-space:nowrap"  class="Tit1">Protecci�n Contrase�a:</td>
                                                          <td><input type="password" id="comp_pwd" style="width: 100%" ondragenter="return false" ondragover="return false" onchange="valTxt_target()" onblur="valTxt_target()"  ondrop='valTxt_target_ondrop(event)'/><input type="hidden" id="comp_algoritmo" style="width: 100%" value=""/></td>
                                                          <td><img onclick="return alert(comp_pwd.value)" title="Ver contrase�a" src="/fw/image/transferencia/ojo.png" style="cursor:hand;cursor:pointer;width:100%"/></td>

                                                        <%--  <td style="width: 10%;white-space:nowrap"  class="Tit1">Algoritmo:</td>
                                                          <td style="width: 15%"><input type="text" id="comp_algoritmo" style="width: 100%"/></td>--%>
                                                        </tr>
                                                     </table>
                                                   </td>
                                                </tr>
                               </table>
</div>
<div id="modMAILTO">
                               <table class="tb1" id="tbPMAILTO" style="display:none">
                                <tr>
                                    <td style="width:100%">
                                       <table class="tb1" id="tbPMAILTOCabe">
                                        <tr>
                                            <td class="Tit1">Desde:</td>
                                            <td style="width: 100%">
                                              <script type ="text/javascript">                          
                                                   campos_defs.add('from', {
                                                       nro_campo_tipo: 1,
                                                       enDB: false,
                                                       filtroXML: nvFW.pageContents.FiltroXML_desde,
                                                       filtroWhere: "<id_transf_conf type='igual'>%campo_value%</id_transf_conf>"
                                                   })
                    
                                                   </script>    
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Tit1">Para:</td>
                                            <td style="width: 100%"><input type="text" style="width: 100%" id="txt_to" /></td>
                                        </tr>
                                        <tr>
                                            <td class="Tit1">CC:</td>
                                            <td style="width: 100%"><input type="text" style="width: 100%" id="txt_cc" /></td>
                                        </tr>
                                        <tr>
                                            <td class="Tit1">CCO:</td>
                                            <td style="width: 100%"><input type="text" style="width: 100%" id="txt_co" /></td>
                                        </tr>
                                        <tr>
                                            <td class="Tit1">Asunto:</td>
                                            <td style="width: 100%"><input type="text" style="width: 100%" id="txt_subject" /></td>
                                        </tr>
                                       </table>
                                   </td>
                               </tr>
                               <tr>
                                    <td><textarea id='txt_body'></textarea></td>
                               </tr>
                            </table>
</div>
                           </div>

                <div id="divRight" style="border-top:0px !Important;padding-top:0px !Important;overflow:hidden;display:inline-block;vertical-align:top;width:21%">
                               <table class="tb1 layout_fixed" style="border:0px !Important" >
                                <tr class="diccionario">
                                     <td colspan="2">
                                          <table class='tb1' id="tbDic" style="width:100%;border:0px !Important">  
                                                <%--<tr class="contenedor diccionario">
                                                 <td colspan="2"><input type="button" value="Validar" style="width:100%" onclick="validar_script()"/></td>
                                                </tr>--%>
                                                <tr class="tbLabel contenedor diccionario lenguaje">
                                                  <td id="tit_lenguaje" style="text-align:center" colspan="2"><b>Lenguaje</b></td>
                                                </tr>
                                                <tr  class="contenedor diccionario lenguaje" >
                                                  <td id="td_cmb_lenguje" colspan="2"><select id="cmb_lenguaje" onchange="onchange_lenguje()" style="width:100%"><option value="js">JSCRIPT</option><option value="vb" selected ="selected">VB .NET</option><option value="cs">CS .NET</option><option value="sql">SQL</option></select></td>
                                                </tr>
                                                <tr class="tbLabel contenedor diccionario tipo_aisla">
                                                  <td id="tit_tp_aisla" style="text-align:center" colspan="2"><b>Tipo Aislamiento</b></td>
                                                </tr>
                                                <tr  class="contenedor diccionario tipo_aisla" >
                                                  <td id="td_cmb_tp_aisla" colspan="2"><select id="cmb_tipo_aisla" style="width:100%"><option value="interno" selected ="selected">Interno</option><option value="independiente">Independiente</option></select></td>
                                                </tr>
                                                <tr>
                                                  <td><iframe id="ifrSelectorParametros" style='width:100%;overflow:hidden;border:0px'></iframe></td>
                                                </tr>
                                         </table>     
                                     </td>
                                 </tr>
                                 <tr class="tbLabel contenedor param_old">
                                        <td style="width: 50%" class="class_paramstros">Par�metros</td>
                                        <td  class="ocultar param_old">Adicionales</td>
                                </tr>
                                <tr class="contenedor param_old">
                                    <td style="width:50%"  class="class_paramstros">
                                        <select id="cb_parametros" style="width: 100%" size="6" ondblclick="return add_parametro(event)"></select>
                                    </td>
                                    <td class="ocultar param_old">
                                        <select id="cb_param_add" style="width: 100%" size="6" ondblclick="return add_param_add(event)"></select>
                                    </td>
                                </tr>
                                <tr class="tbLabel contenedor ocultar">
                                    <td style="width:50%">type</td>
                                    <td class="ocultar"><img src="/fw/image/transferencia/agregar.png" alt="" style="cursor:pointer" onclick="campo_cargar()">Campos/Par�metros</td>
                                </tr>
                                <tr class="contenedor ocultar">
                                    <td style="width:50%;vertical-align:top">
                                        <select id="cb_type" style="width: 100%" size="15" ondblclick="return add_type(event)"></select>
                                    </td>
                                    <td style="vertical-align:top">
                                        <select id="cb_campos" style="width: 100%" size="15" ondblclick="return add_campo(event)"></select>
                                    </td>
                                </tr>
                                <tr class="contenedor">
                                    <td colspan="2" '>
                                        <input type="text" id="txt_sel" style="width: 100%" draggable= 'true' ondragstart='txt_sel_ondrag(event)' />
                                    </td>
                                </tr>
                            </table>
                            <table class="tb1 contenedor ocultar" id="tbConexiones">
                                 <tr class="tbLabel">
                                     <td style="text-align:center;font-weight:bold">Conexiones</td>
                                 </tr>
                                 <tr>
                                  <td id="td_cmb_cn">
                                      <select id="cmb_cn" style="width:80%">
                                       <%

                                           Dim key As String
                                           Dim cn_nombre As String = ""

                                           For Each key In nvApp.app_cns.Keys
                                               If (cn_nombre <> nvApp.app_cns(key).cn_nombre And nvApp.app_cns(key).cn_default = True) Then
                                                   Response.Write("<option value='" & key & "' ")
                                                   Response.Write(" selected= 'selected' ")
                                                   Response.Write(">" & key & "</option>")
                                                   cn_nombre = nvApp.app_cns(key).cn_nombre
                                               End If
                                           Next

                                           For Each key In nvApp.app_cns.Keys
                                               If (cn_nombre <> nvApp.app_cns(key).cn_nombre And nvApp.app_cns(key).cn_default = False) Then
                                                   Response.Write("<option value='" & key & "' ")
                                                   Response.Write(">" & key & "</option>")
                                               End If
                                           Next

                                       %>
                                     </select><input type="button" value="+" id="bt_agregar_cn" onclick="editar_conexion('agregar')"><input type="button" id="bt_quitar_cn" value="-" onclick="editar_conexion('eliminar')"></td>
                                </tr>
                            </table>
                            </div>
             
                <table class="tb1" style="width:100%" id="tbPie">
                    <tr>
                        <td style="text-align:center;width:10%"">&nbsp;</td>
                        <td style="text-align:center;width:35%""><input type="button" style="width:100%;cursor:pointer" name="btn_Aceptar" value="Aceptar" onclick="Aceptar()" /></td>
                        <td style="text-align:center;width:10%"">&nbsp;</td>
                        <td style="text-align:center;width:35%""><input type="button" style="width:100%;cursor:pointer" name="btn_Cancelar" value="Cancelar" onclick="btn_cancelar_onclick()" /></td>
                        <td style="text-align:center;width:10%"">&nbsp;</td>
                    </tr>
                </table>
   
     <div id="divPlantillas"  style="display:none">
         <table class="tb1" style="width:100%">
                 <tr>
                     <td class="tit2" colspan="6" style="text-align:left">Consultas:</td>
                 </tr>
                 <tr>
                     <td class="tit1"  style="text-align:center;width:3%"><input type="radio" value="0" name="Rplantilla" id="Rplantilla0" /></td>
                     <td class="tit4" colspan="4" style="text-align:left" id="pSelect"></td>
                 </tr> 
                 <tr>
                     <td colspan="5">&nbsp;</td>
                 </tr>  
                 <tr>
                     <td class="tit2" colspan="6" style="text-align:left">Procedimientos Almacenados:</td>
                 </tr>  
                 <tr style="padding-bottom:10px">
                     <td class="tit1" style="text-align:center;width:3%"><input type="radio" value="1" name="Rplantilla" id="Rplantilla1" /></td>
                     <td class="tit4" colspan="4" style="text-align:left " id="pProcedure"></td>
                 </tr> 
                 <tr>
                     <td colspan="5">&nbsp;</td>
                 </tr>  
                 <tr>
                     <td class="tit2" colspan="6" style="text-align:left">Par�metros:</td>
                 </tr>  
                 <tr style="padding-bottom:10px">
                     <td class="tit1" style="text-align:center;width:3%"><input type="radio" value="1" name="Rplantilla" id="Rplantilla2" /></td>
                     <td class="tit4" colspan="4" style="text-align:left " id="pParams"></td>
                 </tr> 
                 <tr>
                     <td colspan="5">&nbsp;</td>
                 </tr>
                  <tr>
                        <td style="text-align:center;width:10%">&nbsp;</td>
                        <td style="text-align:center;width:35%"><input type="button" style="width:100%;cursor:pointer" value="Aceptar" onclick="btn_aceptar_plantilla_onclick()" /></td>
                        <td style="text-align:center;width:10%">&nbsp;</td>
                        <td style="text-align:center;width:35%"><input type="button" style="width:100%;cursor:pointer" value="Cancelar" onclick="btn_cancelar_plantilla_onclick()" /></td>
                        <td style="text-align:center;width:10%">&nbsp;</td>
                    </tr>
          </table>
    </div>
    <div id="divParametros" style="width:100%;display:none"/>
</body>
</html>
