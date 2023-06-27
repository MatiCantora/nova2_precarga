<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%

    Dim numError = ""

    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    If (modo Is Nothing) Then
        modo = "C"
    End If

    Dim getpadre = nvFW.nvUtiles.obtenerValor("getpadre", "")
    Dim nro_ref_padre = nvFW.nvUtiles.obtenerValor("nro_ref_padre_txt", "")
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")

    If (modo.ToUpper() = "M") Then

        Dim err = New nvFW.tError()

        Try

            Dim strSQL = ""
            strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
            strSQL = "Delete from ref_dependencias where nro_ref_padre = " + nro_ref_padre + "\n"

            Dim objXML = Server.CreateObject("Microsoft.XMLDOM")
            objXML.loadXML(strXML)
            For i As Integer = 0 To objXML.selectNodes("referencia_dependencia/ref_dependencias").length - 1

                Dim nod = objXML.selectNodes("/referencia_dependencia/ref_dependencias")(i)
                nod.selectSingleNode("@nro_ref").nodeValue
                nod.selectSingleNode("@ref_dep_orden").nodeValue
                strSQL += "insert into ref_dependencias(nro_ref, nro_ref_padre, ref_dep_orden) values (" + nod.attributes(0).nodeValue + ", " + nro_ref_padre + ", " + nod.attributes(1).nodeValue + ")\n"
            Next
            nvFW.nvDBUtiles.DBExecute(strSQL)
            err.numError = 0
            err.mensaje = ""

        Catch e As Exception

            err.parse_error_script(e)
        End Try

        err.response()
    End If

 %>
<html>
<head>
    <title>Dependencia ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <script type="text/javascript" >

        var s_getpadre = '<%= getpadre %>'

        var vButtonItems = {};

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

        var indice = 0,
            Referencia = window.parent.Referencia  

        function window_onload() {
            $('nro_ref_padre_txt').value = s_getpadre
            vListButtons.MostrarListButton()
            campos_defs.items['nro_ref_leer']['onchange'] = referencia_add
            referencia_cargar()
        }
   
        function referencia_cargar() {
           $('nro_ref_padre_txt').value = Referencia['nro_ref']
           $('referencia').value = Referencia['referencia']
           var cb = $('cb_ref_hijos')
           cb.options.length = 0
           Referencia['dependencia_hijo'].each(function(arreglo_i,index_i) {
                                                                            cb.length++
                                                                            cb.options[cb.options.length-1].value = arreglo_i['nro_ref']
                                                                            cb.options[cb.options.length-1].text =  arreglo_i['referencia'] 
                                                                            });
        }

        function Existe(referencia)
         {
          var StrError = ''
          cb = $('cb_ref_hijos')
  
          if (cb.options.length > 0)
           { 
            for (i=0; i<cb.options.length; i++)
             {
              if (cb.options[i].value == referencia)
                StrError = 'La Dependencia Ya Existe'
              if (StrError !='')
                break 
             }
           } 
    
           if ( referencia == frmRefDep.nro_ref_padre_txt.value)
                StrError ='No puede Depender de si misma'
     
            if (StrError != '') 
             {   
              alert(StrError)
                return true
             }
            else
                return false
         }
 
        function referencia_add()
          {
           var encontrado = false
           var cb = $('cb_ref_hijos')
           if (campos_defs.value('nro_ref_leer') != '')
            { 
               if (!Existe(campos_defs.value('nro_ref_leer')) && !es_padre(campos_defs.value('nro_ref_leer')))
                { 
                 cb.length++
                 cb.options[cb.options.length-1].value = campos_defs.value('nro_ref_leer')
                 cb.options[cb.options.length-1].text = campos_defs.desc('nro_ref_leer')
                 campos_defs.items['nro_ref']['input_hidden'].value = ''
                 campos_defs.items['nro_ref']['input_text'].value = ''
                 cb.options[cb.options.length-1].selected = true
                }
            }    
          }
  
        function es_padre(nro_referencia)
         {
             var retorno = false
             Referencia['dependencia_hijo'].each(function(arreglo_i,index_i)
                 {
                  if(arreglo_i['nro_ref'] == $('nro_ref_padre_txt').value)
                    {
                     alert('No puede depender de si mismo, imposible asociar...ya es hijo')
                     retorno = true
                    } 
                 });
     
                Referencia['dependencia_padre'].each(function(arreglo_j,index_j)
                      {
                       if(arreglo_j['nro_ref_padre'] == nro_referencia)
                        {
                         alert('Hay recursividad, imposible asociar...ya es hijo')
                         retorno = true
                        } 
                      });   
            return retorno
         }
 
        function referencia_delete()
          {
           var cb = $('cb_ref_hijos')
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
            if($('nro_ref_padre_txt').value == '')
             strError="Por favor ingrese la referencia"
   
            if (strError == '')
             {  
              var cb = $('cb_ref_hijos')
              Referencia['dependencia_hijo'].clear()
              for (var i=0; i < cb.length; i++)
                 {
                  Referencia['dependencia_hijo'][i]= new Array();
                  Referencia['dependencia_hijo'][i]['nro_ref']= cb.options[i].value 
                  Referencia['dependencia_hijo'][i]['referencia'] = cb.options[i].text
                  Referencia['dependencia_hijo'][i]['ref_dep_orden']= i
              }
              window.parent.Referencia['dependencia_hijo'].returnValue = Referencia['dependencia_hijo']
              window.parent.win_dependencia.options.userData.retorno["success"] = true
              window.parent.win_dependencia.close();
             }
            else
             {
              alert(strError)
              return 
             }    
          }

        function subir()
          {
           var cb_as = $('cb_ref_hijos')
           var subir_value
           var subir_text
   
           if (cb_as.selectedIndex > 0)
            {
             subir_value =cb_as.options[cb_as.options.selectedIndex].value     
             subir_text = cb_as.options[cb_as.options.selectedIndex].text
             cb_as.options[cb_as.options.selectedIndex].value = cb_as.options[cb_as.options.selectedIndex-1].value
             cb_as.options[cb_as.options.selectedIndex].text = cb_as.options[cb_as.options.selectedIndex-1].text
             cb_as.options[cb_as.options.selectedIndex-1].value = subir_value
             cb_as.options[cb_as.options.selectedIndex-1].text = subir_text
             cb_as.options[cb_as.options.selectedIndex-1].selected = true
            }
          }

        function bajar()
          {
           var cb_as = $('cb_ref_hijos')
           var bajar_value
           var bajar_text
           if (cb_as.selectedIndex < cb_as.length-1 && cb_as.selectedIndex > -1)
            {
             bajar_value =cb_as.options[cb_as.options.selectedIndex].value
             bajar_text = cb_as.options[cb_as.options.selectedIndex].text
             cb_as.options[cb_as.options.selectedIndex].value = cb_as.options[cb_as.options.selectedIndex+1].value
             cb_as.options[cb_as.options.selectedIndex].text = cb_as.options[cb_as.options.selectedIndex+1].text
             cb_as.options[cb_as.options.selectedIndex+1].value = bajar_value
             cb_as.options[cb_as.options.selectedIndex+1].text = bajar_text
             cb_as.options[cb_as.options.selectedIndex+1].selected = true
            }
          }
  
        function salir()
        {
            parent.win_dependencia.close()
        }  

    </script>
</head>
<body onload="return window_onload()" style="height: 100%; vertical-align: middle; overflow: auto;">

    <form name="frmRefDep" action="Ref_dependencias_hijo_ABM.aspx" method="post" target="frameEnviar" style="width: 100%">
      
        <table class="tb1" >
         <tr class="tbLabel">
            <td style="width:10%">Nro.</td>
            <td style="width:80%">Referencia seleccionada</td>
         </tr>
        <tr>    
            <td><input type="text" name="nro_ref_padre_txt" id="nro_ref_padre_txt" style="width:100%; text-align:center" disabled/></td>
            <td><input type="text" name="referencia" id="referencia" style="width:100%" /></td>
        </tr>
        </table>    
        <table class="tb1" >
            <tr class="tbLabel">
                 <td colspan="3">Asociar a referencias hijas</td>
            </tr>     
        </table>
        <table class='tb1' style="width:100%">
            <tr>
                <td style="width: 90%; text-align: left; vertical-align:middle">
                    <select style="width: 100%; height:200px" size="12" id='cb_ref_hijos' ondblclick="referencia_delete()">
                    </select>
                </td>
                <td style="width: 4%; text-align: center; vertical-align:middle">
                  <input type="button" name="btn_subir" id="btn_subir" value="^" style="width:100%; height:50px" onclick ="subir()"/>
                  <input type="button" name="btn_bajar" id="btn_bajar" value="v" style="width:100%; height:50px" onclick ="bajar()"/>
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
