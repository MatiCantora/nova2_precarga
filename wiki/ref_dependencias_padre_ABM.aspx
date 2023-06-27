<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%

    Dim modo = ""
    Dim numError = ""

    'Obtenemos valores del submit()
    modo = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "C"
    End If

    Dim gethijo As String = nvFW.nvUtiles.obtenerValor("gethijo", "")
    Dim nro_ref_hijo As String = nvFW.nvUtiles.obtenerValor("nro_ref_hijo_txt", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim filtro_ref_padre_permiso = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReferencia'><campos>ref_editar</campos><filtro></filtro><orden></orden></select></criterio>")

    If modo.ToUpper() = "M" Then
        Dim Err = New nvFW.tError()
        Try
            Dim strSQL As String
            strSQL = "Delete from ref_dependencias where nro_ref_padre = " + nro_ref_hijo + "\n"
            Dim objXML As New System.Xml.XmlDocument
            objXML.LoadXml(strXML)
            Dim nodes As System.Xml.XmlNodeList = objXML.SelectNodes("referencia_dependencia/ref_dependencias")
            For Each nod As System.Xml.XmlNode In nodes
                strSQL += "insert into ref_dependencias(nro_ref, nro_ref_padre, ref_dep_orden) values (" + nro_ref_hijo + ", " + nod.Attributes("nro_ref_padre").Value + ", " + nod.Attributes("ref_dep_orden").Value + ")\n"
            Next
            nvFW.nvDBUtiles.DBExecute(strSQL)
        Catch ex As Exception
            Err.parse_error_script(ex)
        End Try
        Err.response()
    End If
    
    Me.contents("filtro_ref_padre_permiso") = filtro_ref_padre_permiso
 %>
<html>
<head>
    <title>Dependencia ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit() %>
    <script type="text/javascript">

        var vButtonItems = {},
            filtro_ref_padre_permiso = nvFW.pageContents.filtro_ref_padre_permiso

        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return guardar()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Salir";
        vButtonItems[1]["etiqueta"] = "Salir";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return salir()";

        Imagenes = new Array();
        Imagenes["guardar"] = new Image();
        Imagenes["guardar"].src = '/FW/image/icons/guardar.png';

        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        vListButtons.imagenes = Imagenes    

        var  indice = 0,
            Referencia = window.parent.referencia       
  
        function window_onload() {
            vListButtons.MostrarListButton()
            campos_defs.items['nro_ref_leer']['onchange'] = referencia_add
            referencias_cargar()
        }
   
        function referencias_cargar() { 
            $('nro_ref_hijo_txt').value = Referencia['nro_ref']
            $('referencia').value = Referencia['referencia']
            var cb = $('cb_ref_padres')
            cb.options.length = 0
            Referencia['dependencia_padre'].each(function(arreglo_i,index_i) {
                                                                                cb.length++
                                                                                cb.options[cb.options.length-1].value = arreglo_i['nro_ref_padre']
                                                                                cb.options[cb.options.length-1].text =  arreglo_i['referencia_padre'] 
                                                                                });
        }

        function Existe(referencia)
         {
          var StrError = ''
          cb = $('cb_ref_padres')
  
          if (cb.options.length > 0)
           { 
            for (i=0; i<cb.options.length; i++)
             {
              if (cb.options[i].value == referencia)
                StrError = 'La dependencia ya existe'
              if (StrError != '')
                break 
             }
           } 
    
           if ( referencia == $('nro_ref_hijo_txt').value)
                StrError ='No puede depender de si misma'
     
            if (StrError != '') 
             {   
              alert(StrError)
                return true
             }
            else
                return false
         }


        function ref_padre_permiso_edicion() {
     
             var res = true
             var fitroWhere = "<nro_ref type='igual'>" + campos_defs.value('nro_ref_leer') + "</nro_ref>"
             var rs = new tRS();
             rs.open(filtro_ref_padre_permiso, '', fitroWhere,'','')
             if (!rs.eof()) 
                {
                 if (rs.getdata('ref_editar') == 0) 
                   res = false
                }
        
             return res
         }
 
 
        function referencia_add()
          {
           var encontrado = false
           var cb = $('cb_ref_padres')
           if (campos_defs.value('nro_ref_leer') != '') {
               if (ref_padre_permiso_edicion()) {
                   if (!Existe(campos_defs.value('nro_ref_leer')) && !es_hijo(campos_defs.value('nro_ref_leer'))) {
                       cb.length++
                       cb.options[cb.options.length - 1].value = campos_defs.value('nro_ref_leer')
                       cb.options[cb.options.length - 1].text = campos_defs.desc('nro_ref_leer')
                       cb.options[cb.options.length - 1].selected = true
                   }
               }
               else 
                   {
                      alert("La referencia " + campos_defs.desc('nro_ref_leer') + "</br>no posee permiso de edición.")
                      campos_defs.clear('nro_ref_leer')
                    }
            }    
          }
  
        function es_hijo(nro_referencia)
         {
             var retorno = false
             Referencia['dependencia_padre'].each(function(arreglo_i,index_i)
                 {
                  if(arreglo_i['nro_ref_padre'] == $('nro_ref_hijo_txt').value)
                    {
                     alert('No puede depender de si mismo, imposible asociar...ya es hijo')
                     retorno = true
                    } 
                 });
     
                Referencia['dependencia_hijo'].each(function(arreglo_j,index_j)
                      {
                       if(arreglo_j['nro_ref'] == nro_referencia)
                        {
                         alert('Hay recursividad, imposible asociar...ya es hijo')
                         retorno = true
                        } 
                      });   
            return retorno
         }
 
        function referencia_delete()
          {
           var cb = $('cb_ref_padres')
           if (cb.options.length > 0 && cb.options.selectedIndex != -1)
            {
             cb.remove(cb.selectedIndex)
            } 
          }
  
        function isNULL(valor, sinulo)
         {
          valor = valor == null ? sinulo: valor
          return valor
         }
 
        function guardar()
          {
            //validar    
            strError=''
            if($('nro_ref_hijo_txt').value == '')
             strError="Por favor ingrese la referencia"
   
            if (strError == '')
             {  
              var cb = document.all.cb_ref_padres
              Referencia['dependencia_padre'].clear()
              for (var i=0; i < cb.length; i++)
                 {
                  Referencia['dependencia_padre'][i]= new Array();
                  Referencia['dependencia_padre'][i]['nro_ref_padre']= cb.options[i].value 
                  Referencia['dependencia_padre'][i]['referencia_padre'] = cb.options[i].text
                  Referencia['dependencia_padre'][i]['ref_dep_orden']= i
                 }
              window.parent.referencia['dependencia_padre'].returnValue = Referencia['dependencia_padre']
              window.parent.win_dependencia.options.userData.retorno["success"] = true
              window.parent.win_dependencia.close();
             }
            else
             {
              alert(strError)
              return 
             }    
          }

        function salir()
        {
            parent.win_dependencia.close()
        }
    </script>
</head>
<body onload="return window_onload()" style="height: 100%; vertical-align: middle; overflow: auto;">
    <form name="frmRefDep" action="Ref_dependencias_padre_ABM.aspx" method="post" target="frameEnviar" style="width:100%">
      
        <table class="tb1">
         <tr class="tbLabel">
            <td style="width:10%">Nro.</td>
            <td style="width:80%">Referencia seleccionada</td>
         </tr>
        <tr>    
            <td><input type="text" name="nro_ref_hijo_txt" id="nro_ref_hijo_txt" style="width:100%; text-align:center" disabled/></td>
            <td><input type="text" name="referencia" id="referencia" style="width:100%" readonly/></td>
        </tr>
        </table>    
        <table class="tb1">
            <tr class="tbLabel">
                 <td colspan="3">Asociar a referencias padres</td>
            </tr>
        </table>
        <table class='tb1' >
            <tr>
                <td style="width: 100%; text-align: left; vertical-align:middle">
                    <select style="width: 100%; height:200px" size="12" id='cb_ref_padres' ondblclick="referencia_delete()">
                    </select>
                </td>
            </tr>
            <tr>
                <td style="width: 60%" colspan="3"><%= nvFW.nvCampo_def.get_html_input("nro_ref_leer") %></td> 
            </tr>
        </table>
        <table > 
            <tr>
              <td style="width:33%"><div id="divGuardar" style="width:100%"/></td>
              <td style="width:33%"><div id="divSalir" style="width:100%"/></td>
            </tr> 
        </table> 
    </form>
 <iframe style="DISPLAY:none" src="enBlanco.htm" name="frameEnviar" id="frameEnviar"/>
</body>
</html>
