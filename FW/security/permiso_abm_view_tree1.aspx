<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err As New nvFW.tError()
    
    'debe tener el permiso para editar el modulo
    If Not op.tienePermiso("permisos_seguridad", 3) Then
        err.numError = -1
        err.titulo = "No se pudo completar la operación. "
        err.mensaje = "No tiene permisos para ver la página."
        err.response()
    End If

    Dim filtroOperadorTipo =  nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct tipo_operador,ltrim(rtrim(tipo_operador_desc)) as tipo_operador_desc</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nodo_get As String = nvFW.nvUtiles.obtenerValor("nodo_get", "")
    Dim tipo_operador_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_get", "")
    Dim tipo_operador_comp_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_comp_get", "")
    Dim operador_get As String = nvFW.nvUtiles.obtenerValor("operador_get", "")
    Dim operador_comp_get As String = nvFW.nvUtiles.obtenerValor("operador_comp_get", "")
    Dim nro_per_nodo_get As String = nvFW.nvUtiles.obtenerValor("nro_per_nodo_get", "")
    Dim vista As String = nvFW.nvUtiles.obtenerValor("vista", "")


    If modo.ToUpper = "GUARDAR" Then
  
        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
        Dim rs As ADODB.Recordset
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_permiso_nodos_perfiles_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim pStrXML As ADODB.Parameter
        pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        cmd.Parameters.Append(pStrXML)
        rs = cmd.Execute()
        Dim numError As Integer = rs.Fields.Item("numError").Value
        If numError <> 0 Then
            err.numError = numError
            err.titulo = rs.Fields.Item("titulo").Value
            err.mensaje = rs.Fields.Item("mensaje").Value
            err.debug_desc = rs.Fields.Item("debug_desc").Value
            err.debug_src = rs.Fields.Item("debug_src").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
        err.response()
    End If

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
        <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <style type="text/css">
   
      BODY 
        {
         font: 11px Trebuchet, Tahoma, Arial, Helvetica;
         border:0px;
         color:Black
        }
   
      .titulo
       {
        background-color: gray !Important;
        font-family: Tahoma !Important;
        font-size: 11px !Important;
        font-weight: bolder;
        text-align:center;
        color: white
       } 
   
      .tabla
       {
        font: 11px Trebuchet, Tahoma, Arial, Helvetica;
        color: black
       }  
    </style>
    
    <script type="text/javascript" language="javascript">

    var vButtonItems = new Array();
    var filtroOperadorTipo = '<%= filtroOperadorTipo %>'

    vButtonItems[0] = new Array();
    vButtonItems[0]["nombre"] = "Boton_Buscar"
    vButtonItems[0]["etiqueta"] = "Buscar"
    vButtonItems[0]["imagen"] = "buscar"
    vButtonItems[0]["onclick"] = "vista_lineal(event)";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar", "/fw/image/icons/buscar.png")


    window.alert = function(msg) { window.top.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

    var vista = '<%= vista %>'

    var vTree = new tTree('Div_vTree_0', "vTree");
    vTree.loadImage("r", '/fw/image/sistemas/sistema.png')
    vTree.loadImage("m", '/fw/image/sistemas/modulo.png')
    vTree.loadImage("p", '/fw/image/icons/clave.png')
    var Imagenes = vTree.imagenes
    vTree = new Array()

    var tipo_operador_desc_comp = ''
    var operador_desc_comp = ''

    function window_onload()  {
      vListButtons.MostrarListButton()
  
      if($('tipo_operador_comp_get').value > 0)
       {
        campos_defs.set_value('operador_tipo',$('tipo_operador_comp_get').value)
        tipo_operador_desc_comp = campos_defs.desc('operador_tipo')
        campos_defs.clear('operador_tipo')
       }

      campos_defs.items['nro_operador']['onchange'] = habilitar_tree
     // campos_defs.items['operador_tipo']['onchange'] = habilitar_tree
      campos_defs.items['operador_tipo3']['onchange'] = habilitar_tree

      if($('tipo_operador_get').value > 0)
        campos_defs.set_value('operador_tipo',$('tipo_operador_get').value)

      if ($('operador_comp_get').value > 0) {
          campos_defs.set_value('nro_operador', $('nro_operador').value)
          operador_desc_comp = campos_defs.desc('operador_tipo')
          campos_defs.clear('nro_operador')
      }

      if ($('operador_get').value > 0) 
       {
        campos_defs.set_value('nro_operador', $('operador_get').value)
       // cargar_tipo_operador()
       }

       switch (vista)
       {
        case 'lineal':
             $('filtro').value = cargar_filtro_path('<%= nro_per_nodo_get %>')
             vista_lineal()
             break;
        case 'comparar':
              $('filtro').value = cargar_filtro_path('<%= nro_per_nodo_get %>')
              vista_lineal()
              break;
        default:
          vista_tree()
       }
  
        window_onresize()

     }

     function vista_tree() {
    
         vTree.length = 0 // resetea la estructura

         $('filtro').value = ''
         $('Div_vTree_0_Cab').hide()
         $('tbBuscar').hide()
         vista = ''

         try {
              $(vTree[0].canvas).innerHTML = '' //resetea el div
              $(vTree[0].canvas).id = 'Div_vTree_0' // lo vuelve a su nombre original
             }
         catch (e) { }
   
       cargar_tree()
       habilitar_tree()
       window_onresize()
     }

     function vista_lineal(e)  {
       $('Div_vTree_0').innerHTML = ""
       vista = vista == '' ? 'lineal' : vista
   
       try {
           vTree = new Array()
          }
       catch (e1) { }

        $('tbBuscar').show()

        nvFW_bloqueo_activar($$('BODY')[0])
 
        cargar_vPath()
        dibujar_vPath()
    
        if(vista == 'comparar')
          comparar()
 
        habilitar_tree()

        nvFW_bloqueo_desactivar($$('BODY')[0])

        window_onresize()
    }


    function cargar_filtro_path(nro_per_nodo)  {
        var criterio = "<criterio><select vista=''><campos>dbo.FW_Permiso_Nodos_Path("+ nro_per_nodo + ",'') as path</campos><filtro></filtro><orden></orden></select></criterio>"
        var rs = new tRS();
        rs.open(criterio)
        if (!rs.eof())
            return rs.getdata('path')
        else 
            return ''
    }


    var Operador_Tipo = {}
    function cargar_tipo_operador()  {
        Operador_Tipo = {}
        var filtro = "<operador type='igual'>" + $('operador_get').value + "</operador><estado type='igual'>'ACTIVO'</estado>";
        var criterio = filtroOperadorTipo
        var rs = new tRS();
        rs.open(criterio,'',filtro,'','')
        while (!rs.eof()) 
         {
            Operador_Tipo[rs.getdata('tipo_operador')] = {}
            Operador_Tipo[rs.getdata('tipo_operador')] = rs.getdata('tipo_operador_desc')
            rs.movenext()
         }
    }

    function cargar_vPath() {
        var view = ""
    
        var indice = vTree.length
        vTree[indice] = {}
        vTree[indice].nodos = {}
    
        var filtro_path = ''
        if ($('filtro').value != '')
            filtro_path = '<path type="like">%' + $('filtro').value + '%</path>'
    
        var filtro_tipo_operador = ''
        if ($('tipo_operador_get').value != '') {
            view = "FW_Permisos_verPerfiles_accesos"
            filtro_tipo_operador = "<tipo_operador type='igual'>" + $('tipo_operador_get').value + "</tipo_operador>"
        }

        var filtro_operador = ''
        if ($('operador_get').value != '') {
            view = "FW_Permisos_verOperadores_accesos"
            filtro_operador = "<operador type='igual'>" + $('operador_get').value + "</operador>"
        }

        var criterio = "<criterio><select vista='" + view + "'><campos>distinct dbo.[rellenar_izquierda_str](cast(nro_per_nodo as varchar),'0000') as nro_per_nodo,path,nro_permiso,permitir,nro_permiso_grupo,permiso_grupo</campos><filtro><NOT><nro_per_nodo type='isnull'/></NOT>"+ filtro_path + filtro_tipo_operador + filtro_operador + "</filtro><orden>path</orden></select></criterio>"
        var rs = new tRS();
        rs.open(criterio)
        while(!rs.eof())
            {
                 vTree[indice].nodos[rs.getdata('nro_per_nodo')] = {}
                 vTree[indice].nodos[rs.getdata('nro_per_nodo')].id = rs.getdata('nro_per_nodo')
                 vTree[indice].nodos[rs.getdata('nro_per_nodo')].uid = rs.getdata('nro_per_nodo')
                 vTree[indice].nodos[rs.getdata('nro_per_nodo')].path = rs.getdata('path')
                 vTree[indice].nodos[rs.getdata('nro_per_nodo')].title = '['+ rs.getdata('nro_permiso') + '] ' + rs.getdata('permitir') + ' -> ['+  rs.getdata('nro_permiso_grupo') + '] ' + rs.getdata('permiso_grupo')
                 vTree[indice].nodos[rs.getdata('nro_per_nodo')].checked = false
                 rs.movenext()
            }
    }

    function sel_todos_checkbox(chkbox) {
      var elementos = ''
      var x = 0
      for(var i in vTree[0].nodos)
       {
         ele = $('chck_' + i)
         if ((ele.type == 'checkbox' && ele.id != 'check_all'))
         {
	       ele.checked = chkbox.checked
	       id = ele.id.split('chck_')[1]
	       vTree[0].nodos[id].checked = chkbox.checked
	     }
       }	   
    }

    function dibujar_vPath() {
       $('Div_vTree_0').innerHTML = ""
   
       $('Div_vTree_0_Cab').show()
       $('Div_vTree_0_Cab').innerHTML = ""

       var strHTMLCab = "<table class='tabla' style='width: 100%'><tr class='titulo'><td style='width:4%;text-align:center'><input type='checkbox' id='check_all' onclick='return sel_todos_checkbox(this)' style='width:100%'/></td><td>Descripción</td>"
       if (vista != 'lineal') {
       
           var title_sel = ''
           var title_comp = ''
           if (operador_desc_comp != '')
               {
                 title_sel = campos_defs.desc('nro_operador')
                 title_comp = operador_desc_comp
               }

           if (tipo_operador_desc_comp != '')
               {
                 title_sel = campos_defs.desc('operador_tipo')
                 title_comp = tipo_operador_desc_comp
               }

             strHTMLCab += "<td style='width:10%;cursor:hand;cursor:pointer' title='" + title_sel + "' id='cabPerfil'>Perfil Sel.</td>"
             strHTMLCab += "<td style='width:10%;cursor:hand;cursor:pointer' title='" + title_comp + "' id='cabPerfilComp'>Perfil Com.</td>"
       }
       strHTMLCab += "</tr></table>"

       $('Div_vTree_0_Cab').insert({ top: strHTMLCab })

       var strHTML = "<table class='tabla' style='width: 100%'>"
       strHTML += "</tr>"  
       var checkear
       for(var i in vTree[0].nodos)
        {
          Arr = vTree[0].nodos[i]
      
          checkear = ""
          if(Arr.checked)
            checkear = "checked='checked'"
      
          strHTML += "<tr id='tr_permiso"+ Arr.uid +"'><td class='titulo' style='width: 3%; vertical-align:middle; text-align:center'><input type='checkbox' "+ checkear +" id='chck_"+ Arr.uid +"' ></td>" 
          strHTML += "<td style='text-align: left; vertical-align:middle' title='"+ Arr.title +"'>" + Arr.path + "</td>"
          if (vista != 'lineal') {
              strHTML += "<td style='width: 10%; text-align: center; vertical-align:middle'><img src='/FW/image/security/tilde.png' style='cursor:hand;cursor:pointer;display:none' id='img_" + Arr.uid + "'/></td>"
              strHTML += "<td style='width: 10%; text-align: center; vertical-align:middle'><img src='/FW/image/security/tilde.png' style='cursor:hand;cursor:pointer;display:none' id='img_comp_" + Arr.uid + "'/></td>"
          }
      
          strHTML += "</tr>"
         } 
 
       strHTML += "</table>"
       $('Div_vTree_0').insert({ top: strHTML })

    }

    function cargar_tree() {
      indice = vTree.length
      //Crear el div de contenido para el arbol
      vTree[indice] = new tTree('Div_vTree_' + indice, "vTree["+ indice + "]");
     vTree[indice].imagenes = Imagenes


      vTree[indice].getNodo_xml = tree_getNodo
  
      vTree[indice].cargar_nodo('0000');
      vTree[indice].MostrarArbol();
  
    }

    function comparar() {
 
        if ($('tipo_operador_comp_get').value != '' || $('operador_comp_get').value != '')
         {
             var habilitado = 0
             if ($('operador_comp_get').value != '')
               habilitado = "dbo.FW_getHabilitado_Permiso_Nodos_Operador(nro_per_nodo, " + $('operador_comp_get').value + ")" 

             if ($('tipo_operador_comp_get').value != '')
               habilitado = "dbo.FW_getHabilitado_Permiso_Nodos(nro_per_nodo, " + $('tipo_operador_comp_get').value + ")"

             if (habilitado != '') {
                 var criterio = "<criterio><select vista='Permiso_Nodos'><campos>distinct dbo.[rellenar_izquierda_str](cast(nro_per_nodo as varchar),'0000') as nro_per_nodo, " + habilitado + " as habilitado</campos><filtro><per_nodo_tipo type='igual'>'P'</per_nodo_tipo></filtro><orden></orden></select></criterio>"
                 var rs = new tRS();
                 rs.async = true
                 rs.open(criterio)
                 rs.onComplete = function (rs) {
                     while (!rs.eof()) {
                         nodo = vTree[0].nodos[rs.getdata('nro_per_nodo')]
                         habilitado = rs.getdata('habilitado') == 'true' ? true : false
                         if (nodo) {

                             if ((habilitado && $('chck_' + nodo.uid).checked) || (!habilitado && !$('chck_' + nodo.uid).checked)) {
                                 $('tr_permiso' + nodo.uid).setStyle({ color: 'green' })
                                 $('img_' + nodo.uid).src = $('chck_' + nodo.uid).checked ? '/FW/image/security/tilde.png' : '/FW/image/security/eliminar.png'
                                 $('img_comp_' + nodo.uid).src = habilitado ? '/FW/image/security/tilde.png' : '/FW/image/security/eliminar.png'
                             }

                             if (habilitado && !$('chck_' + nodo.uid).checked) {
                                 $('tr_permiso' + nodo.uid).setStyle({ color: '#800040' })
                                 $('img_' + nodo.uid).src = '/FW/image/security/eliminar.png'
                                 $('img_comp_' + nodo.uid).src = '/FW/image/security/tilde.png'
                             }

                             if (!habilitado && $('chck_' + nodo.uid).checked) {
                                 $('tr_permiso' + nodo.uid).setStyle({ color: '#749BC4' })
                                 $('img_' + nodo.uid).src = '/FW/image/security/tilde.png'
                                 $('img_comp_' + nodo.uid).src = '/FW/image/security/eliminar.png'
                             }

                             $('img_' + nodo.uid).show()
                             $('img_comp_' + nodo.uid).show()

                         }
                         rs.movenext()
                     }
                 }
             }
         }       
    }

    var Arrpnp
    function Arr_cargar_permiso_nodos() {
   
        Arrpnp = {}
        var criterio = ""
        if (campos_defs.value('operador_tipo') != '')
         {
          var nro_perfil = !hereda ? campos_defs.value('operador_tipo') : campos_defs.value('operador_tipo3')  
          criterio = "<criterio><select vista='Permiso_Nodos'><campos>distinct dbo.[rellenar_izquierda_str](cast(nro_per_nodo as varchar),'0000') as nro_per_nodo, dbo.FW_getHabilitado_Permiso_Nodos(nro_per_nodo," + nro_perfil + ") as habilitado</campos><filtro><per_nodo_tipo type='igual'>'P'</per_nodo_tipo></filtro><orden></orden></select></criterio>"
         }

        if (campos_defs.value('nro_operador') != '')
          criterio = "<criterio><select vista='Permiso_Nodos'><campos>distinct dbo.[rellenar_izquierda_str](cast(nro_per_nodo as varchar),'0000') as nro_per_nodo, dbo.FW_getHabilitado_Permiso_Nodos_operador(nro_per_nodo," + campos_defs.value('nro_operador') + ") as habilitado</campos><filtro><per_nodo_tipo type='igual'>'P'</per_nodo_tipo></filtro><orden></orden></select></criterio>"

        var rs = new tRS();
        rs.open(criterio)
        while(!rs.eof())
            {
             Arrpnp[rs.getdata('nro_per_nodo')] = {}
             Arrpnp[rs.getdata('nro_per_nodo')].habilitado = rs.getdata('habilitado') == 'true' ? true : false
             hereda = false    
             rs.movenext()
            }
    }

    function habilitar_tree() {
  
      if(vTree[0] == undefined)
        return
    
      Arr_cargar_permiso_nodos()
  
      for(i in vTree[0].nodos)
       {
        nodo = vTree[0].nodos[i]
        $('chck_' + nodo.uid).checked = false
        vTree[0].nodos[i].checked = false
    
        for(j in Arrpnp)
         {
           if (i == j)
            {
             $('chck_' + nodo.uid).checked = Arrpnp[j].habilitado
             nodo.checked = Arrpnp[j].habilitado
             try {
                   if(vista == 'lineal')
                    {
                      $('tr_permiso' + nodo.uid).setStyle({ color: 'black' })
                      $('img_' + nodo.uid).src = nodo.checked ? '/FW/image/security/tilde.png' : '/FW/image/icons/eliminar.png'
                      $('img_' + nodo.uid).show()
                    }
                }
             catch (e) { }

             if (vista == '')
               nodo.checking()
            } 
         }
       }
  
    }
 
    function tree_getNodo(nodo_id) {

      var criterio = ''
  
      if (campos_defs.value('operador_tipo') != '')
          criterio = "<criterio><select vista='(select 1 as field)foo'><campos>dbo.FW_Permiso_Nodos_Perfiles_Tree('" + nodo_id + "'," + campos_defs.value('operador_tipo') + ") as xml_data</campos></select></criterio>"
  
      if (campos_defs.value('nro_operador') != '')
          criterio = "<criterio><select vista='(select 1  as field)foo'><campos>cast(dbo.FW_Permiso_Nodos_Perfiles_Tree_Operador('" + nodo_id + "'," + campos_defs.value('nro_operador') + " as varbinary(max)) as forxml_data</campos></select></criterio>"

      var rs = new tRS()
      //rs.xml_format = 'rs_xml_json'
      rs.open(criterio)
      var xml = ""
      if (!rs.eof()) {
          var xml = rs.getdata("xml_data").toString()
      }
      return xml;
    }

    function nodo_permiso_onclick() {}

    function guardar()  {
  
        if(campos_defs.value("operador_tipo") == '')
          {
           alert("Seleccione el perfil.")
           return
          }

        var xmldato = ""
        xmldato = "<?xml version='1.0' encoding='ISO-8859-1'?>"
        xmldato += "<permiso_nodos_perfiles tipo_operador ='" + campos_defs.value("operador_tipo") + "'>"
        xmldato += "<permiso_nodos>"
        for(i in vTree[0].nodos)
          {
           nodo = vTree[0].nodos[i]
           if (vista != '') 
             nodo.checked =  $('chck_' + nodo.uid).checked 
           xmldato +="<relacion nro_per_nodo='" + nodo.id + "' habilitado ='" + nodo.checked + "'/>"
          }    
        xmldato +="</permiso_nodos>"
        xmldato += "</permiso_nodos_perfiles>"
        nvFW.error_ajax_request('permiso_abm_view_tree.asp', {
                                 parameters: { modo: 'GUARDAR', strXML: escape(xmldato) },
                                 onSuccess: function(err, transport){
                                             if (err.numError != 0)
                                               {
                                                 alert(err.mensaje)
                                                 return
                                               }

                                             try { parent.win.options.userData.accion = 'refresh' } catch (e) { }
                                        
                                            }

                                        });  
 
    }

    function permiso_nodos_abm() { 
            var path = "/fw/security/permiso_nodos_tree.aspx";
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
            winP = w.createWindow({
                                    className: 'alphacube',
                                    url: path,
                                    title: '<b>Estructura ABM</b>',
                                    minimizable: false,
                                    maximizable: false,
                                    draggable: true,
                                    width: 700,
                                    height: 400,
                                    resizable: false,
                                    destroyOnClose: true,
                                    onClose: permiso_nodos_abm_return
                                 });
           winP.showCenter(true);
        }
    
      function permiso_nodos_abm_return() {
        if(winP.options.userData == 'refresh')
         {
          $(vTree[0].canvas).innerHTML = '' //resetea el div
          $(vTree[0].canvas).id = 'Div_vTree_0' // lo vuelve a su nombre original
          vTree.length = 0 // resetea la estructura
          cargar_tree() // vuelve a cargar
          habilitar_tree()
         }
      }  

     var hereda = false
     function permiso_heredar() {
         hereda = false
 
         Dialog.confirm("¿Desea heredar los permisos de otro perfil?",
                                         {    
                                               width:400, 
                                           className: "alphacube",
                                             okLabel: "Aceptar", 
                                         cancelLabel: "Cancelar",  
                                              cancel:function(win){
                                                                    win.close()}, 
                                                  ok:function(win){
                                                                   hereda = true
                                                                   campos_defs.onclick(null,'operador_tipo3')
                                                                   win.close()
                                                                  } 
                                         });  

     }

    function window_onresize() {
          try {
        
             var dif = Prototype.Browser.IE ? 5 : 2
             var body_height = $$('BODY')[0].getHeight()
             var divMenuABM_height = $('divMenuABM').getHeight()
      
             var tbBuscar_height = 0
             if($('tbBuscar').style.display != "none" )
                 tbBuscar_height = $('tbBuscar').getHeight()

             var Div_vTree_0_Cab_height = 0
             if ($('Div_vTree_0_Cab').style.display != "none")
                 Div_vTree_0_Cab_height = $('Div_vTree_0_Cab').getHeight()

             sumar = body_height - divMenuABM_height - Div_vTree_0_Cab_height - tbBuscar_height - dif -20
             $('Div_vTree_0').setStyle({ 'height': sumar })

         }
         catch (e) { }  
    }



    function onkeypress_filtro(e) {
        var key = Prototype.Browser.IE ? e.keyCode : e.which
        if (key == 13)
            vista_lineal();
    }

//-->
    </script>
    


</head>
<body onload="window_onload()" onresize="return window_onresize()" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
<input type="hidden" id="tipo_operador_get" value="<%= tipo_operador_get%>"/>
<input type="hidden" id="tipo_operador_comp_get" value="<%= tipo_operador_comp_get%>"/>
<input type="hidden" id="operador_get" value="<%= operador_get%>"/>
<input type="hidden" id="operador_comp_get" value="<%= operador_comp_get%>"/>
    <div id="divMenuABM"></div>
     <script type="text/javascript" language="javascript">

         var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
         vMenuABM.loadImage("guardar", "/fw/image/icons/guardar.png")
         vMenuABM.loadImage("persona_sel", "/fw/image/icons/personas.png")
         vMenuABM.loadImage("arbol", "/fw/image/icons/arbol.png")
         Menus["vMenuABM"] = vMenuABM
         Menus["vMenuABM"].alineacion = 'centro';
         Menus["vMenuABM"].estilo = 'A';

         if ($('tipo_operador_get').value > 0)
           Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")  
     
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Visualización Tipo Árbol</Desc></MenuItem>")
    
         if ($('tipo_operador_get').value > 0)
           Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>persona_sel</icono><Desc>Heredar Permisos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>permiso_heredar()</Codigo></Ejecutar></Acciones></MenuItem>")

         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='3' style='width:10%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>arbol</icono><Desc>Vista Arbol</Desc><Acciones><Ejecutar Tipo='script'><Codigo>vista_tree()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='4' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>arbol</icono><Desc>Vista Arbol Lineal</Desc><Acciones><Ejecutar Tipo='script'><Codigo>vista_lineal(event)</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenuABM.MostrarMenu()

    </script>  
   <div id="divCab" style='width:100%'>
   <table class="tabla" style="width:100%;display:none">
    <tr id="trOperadorTipo">
      <td class="titulo" style="width:10%;">Perfil:</td>
      <td style="display:none"><%= nvFW.nvCampo_def.get_html_input("operador_tipo3")%></td>
      <td style="display:none"><%= nvFW.nvCampo_def.get_html_input("operador_tipo")%></td>
      <td style="display:none"><%= nvFW.nvCampo_def.get_html_input("nro_operador")%></td>
      <td class="titulo" style="width:10%">&nbsp;</td>
     </tr>
   </table> 
   </div>
   <div id="Div_vTree_0_Cab" style="width:100%;overflow:auto;display:none"></div>

   <div id="Div_vTree_0" style="width:100%;height:100%;overflow:auto"></div>

   <table class="tabla" id="tbBuscar" style="width:100%;display:none">
    <tr>
      <td class="titulo" style="width:10%" nowrap="nowrap">Filtro Path:</td>
      <td><input type="text" style="width:100%;font:10pt" id="filtro" name="filtro" onkeypress="return onkeypress_filtro(event)" value=''/></td>
      <td class="titulo" style="width:20%"><div id="divBoton_Buscar" style="width:100%"></div></td>
     </tr>
   </table> 
   
</body>
</html>
