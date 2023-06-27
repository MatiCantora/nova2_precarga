<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageBase" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim StrSQL = ""
    Dim strError = ""

    Dim getparamxml = nvUtiles.obtenerValor("getparamxml", "")
    Dim login = nvUtiles.obtenerValor("login", "")
    Dim criterio = nvUtiles.obtenerValor("criterio", "")
    Dim modo = nvUtiles.obtenerValor("modo", "")

    'Obtenemos valores del submit()

    'if (!op_get_permiso('permisos_seguridad', 1))
    '    Response.Redirect("/errores_personalizados/error_gral.asp?numerror=10000")

    Dim Err As New tError()

    If modo.ToLower = "get_complementos" Or modo.ToLower = "abm" Then

        Err = nvLogin.execute(nvApp, modo, "", "", "", "", "", criterio)

        nvXMLUtiles.responseXML(Response, Err.mensaje)

        If (modo.ToLower = "abm") Then
            Err.response()
        End If

        Response.End()

    End If

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Datos Complementarios</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript" >
    
    var alert =  function(msg){window.top.Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }

    var win = nvFW.getMyWindow()
    function window_onload()
      {
        window_onresize()
        getInfoComplementaria()

      }

    function parametros_obtenervalor(param)
    {
        var retorno = ''
        var objxml = new tXML();
        paramxml = "<%= getparamxml%>"

        if (objxml.loadXML(paramxml))
          if(objxml.selectSingleNode('/parametros/' + param))
              retorno = objxml.selectSingleNode('/parametros/' + param).text 
     
        return retorno
    }

    function seleccionar_combo(cmb, valor) {
         for (var i = 0; i < $(cmb).length; i++) {
             if ($(cmb).options[i].value == valor)
                 $(cmb).options[i].selected = true
         }
     }

    function window_onunload()
    {
    window.close()
    }
 
    function window_onresize()
    {
    try
    {
    var dif = Prototype.Browser.IE ? 5 : 2
    var body_h = $$('body')[0].getHeight()
    var divCab_i = $('div_Iframe').getHeight()
    $('divDatosComplementarios').setStyle({ 'height': body_h - divCab_i - dif })
    }
    catch(e){}
    }
 
    function div_Actualizar_show()
    {
    var div = $("div_Actualizar")
    div.show()
    div.setOpacity(0.5)
    var div_i = $("div_Iframe")
    div.clonePosition(div_i)
    } 

    function div_Actualizar_hide()
    {
        try { $('div_Actualizar').hide() } catch (e) { }
    }

          var windc
          function complementos_editar()
          {

              var strHTML = ""
              windc = parent.nvFW.createWindow({
                  className: "alphacube", resizable: false,
                  closable: true,
                  minimizable: false,
                  maximizable: false,
                  draggable: true,
                  resizable:true,
                  recenterAuto: true,
                  title: "Editar Complemeto de: <b><%= login %></b>",
                  onShow: function () {
                                          var vButtonItems = new Array()
                                          vButtonItems[0] = new Array();
                                          vButtonItems[0]["nombre"] = "ComplementoGuardar";
                                          vButtonItems[0]["etiqueta"] = "Guardar";
                                          vButtonItems[0]["imagen"] = "guardar";
                                          vButtonItems[0]["onclick"] = "ObtenerVentana('"+ window.name+ "').complementos_abm()";

                                          vButtonItems[1] = new Array();
                                          vButtonItems[1]["nombre"] = "ComplementoCancelar";
                                          vButtonItems[1]["etiqueta"] = "salir";
                                          vButtonItems[1]["imagen"] = "salir";
                                          vButtonItems[1]["onclick"] = "ObtenerVentana('" + window.name + "').windc.close()";

                                          var vListButtons = new tListButton(vButtonItems, 'vListButtons')
                                          vListButtons.loadImage("guardar", '/fw/image/transferencia/guardar.png')
                                          vListButtons.loadImage("salir", '/fw/image/transferencia/salir.png')
                                          //  vListButtons.MostrarListButton()
                      
                                          var divButton = parent.$("divComplementoGuardar")
                                          divButton.innerHTML = vListButtons.ButtonItems[0].GenerarHTML()

                                          var divButton = parent.$("divComplementoCancelar")
                                          divButton.innerHTML = vListButtons.ButtonItems[1].GenerarHTML()
                                      }

              })
              
              windc.setHTMLContent(getInfoComplementaria_html(false))
              
              windc.setSize(550, 380)
              windc.showCenter(true);
              windc.toFront()
          }


        function complementos_abm() {
            
              try {
                  var xmldato = ""
                  xmldato += "<?xml version='1.0' encoding='iso-8859-1'?>"
                  xmldato += "<criterio><login><%= login %></login>" + getInfoorigen()
                  for (i in DatosComplemetarios)
                   {
                      var id = parent.$(i)

                      if (id == 'numError' || id == 'separador' || id == null)
                          continue

                      if (id.disabled)
                          continue

                      valor = id.value
                      if ($(id).type == 'checkbox')
                          valor = id.checked

                      if (DatosComplemetarios[i].obligatorio && DatosComplemetarios[i].editable && valor === '')
                       {
                          alert("Ingrese el valor de: " + DatosComplemetarios[i].etiqueta + ".")
                          return
                       }

                      xmldato += "<" + i + ">" + valor + "</" + i + ">"

                  }
                 xmldato += "</criterio>"

                 nvFW.error_ajax_request('datos_complementarios_abm.aspx', { parameters: { modo: 'abm', criterio: xmldato },
                          onError: function (err, transport) { alert(err.mensaje) },
                          onSuccess: function (err, transport) 
                           {
                              getInfoComplementaria()
                              windc.close()
                           }
                      });
              }

              catch (e) { alert(e.mensaje)}


          }

          function getInfoorigen()
          {
              var adsarr = {}
              adsarr = $('origen').value.split("|")
              var ads_access = "<ads_access></ads_access>"
              var ads_dc = "<ads_dc></ads_dc>"
              var ads_dominio = "<ads_dominio></ads_dominio>"
              var delegate_login = "<delegate_login></delegate_login>"

              if (adsarr.length > 0) {
                  ads_access = "<ads_access>" + adsarr[0] + "</ads_access>"
                  ads_dc = "<ads_dc>" + adsarr[1] + "</ads_dc>"
                  ads_dominio = "<ads_dominio>" + adsarr[2] + "</ads_dominio>"
              }
              else
                  delegate_login = "<delegate_login>" + $('origen').value + "</delegate_login>"

              return "<ads_login>" + ($('tipo_login').value == 'ads' ? 'true' : 'false') + "</ads_login>" + ads_access + ads_dc + ads_dominio + delegate_login

          }

          var DatosComplemetarios = {}
          function getInfoComplementaria()
          {
                  if ("<%= login %>" == "")
                   return

                  var adsarr = {}
                      adsarr = $('origen').value.split("|")
                  var ads_access = "<ads_access></ads_access>"
                  var ads_dc = "<ads_dc></ads_dc>"
                  var ads_dominio = "<ads_dominio></ads_dominio>"
                  var delegate_login = "<delegate_login></delegate_login>"

                  if (adsarr.length > 0)
                    {
                        ads_access = "<ads_access>" + adsarr[0] + "</ads_access>"
                        ads_dc = "<ads_dc>" + adsarr[1] + "</ads_dc>"
                        ads_dominio = "<ads_dominio>" + adsarr[2] + "</ads_dominio>"
                    }
                  else
                    delegate_login = "<delegate_login>" + $('origen').value + "</delegate_login>"

                  DatosComplemetarios.length = 0
                  DatosComplemetarios = {}
                  nvFW.bloqueo_activar($('divDatosComplementarios'), 'Ajax_bloqueo')
              
                  var rs = new tRS()
                  rs.async = true 
                  rs.cn = '/fw/security/datos_complementarios_abm.aspx?modo=get_complementos&criterio='
                  var criterio = '<criterio><login><%= login %></login>' + getInfoorigen() + '</criterio>'
                  rs.onComplete = function (rs)
                   {
                      DatosComplemetarios = {}
                      
                      while (!rs.eof())
                       {
                          DatosComplemetarios[rs.getdata("id")] = {}
                          DatosComplemetarios[rs.getdata("id")].id = rs.getdata("id")
                          DatosComplemetarios[rs.getdata("id")].etiqueta = rs.getdata("etiqueta")
                          DatosComplemetarios[rs.getdata("id")].valor = rs.getdata("valor")
                          DatosComplemetarios[rs.getdata("id")].editable = rs.getdata("editable") == 'true' ? true : false
                          DatosComplemetarios[rs.getdata("id")].visible = rs.getdata("visible") == 'true' ? true : false
                          DatosComplemetarios[rs.getdata("id")].tipo_dato = rs.getdata("tipo_dato")
                          DatosComplemetarios[rs.getdata("id")].onchange = rs.getdata("onchange")
                          DatosComplemetarios[rs.getdata("id")].toma_valor_de = rs.getdata("toma_valor_de")
                          DatosComplemetarios[rs.getdata("id")].obligatorio = rs.getdata("obligatorio") == 'true' ? true : false

                          rs.movenext()
                       }
                      
                      $('divDatosComplementarios').innerHTML = ""
                      $('divDatosComplementarios').insert({ top: getInfoComplementaria_html(true) })
                      nvFW.bloqueo_desactivar($('divDatosComplementarios'), 'Ajax_bloqueo')

                 }
                rs.open(criterio)
          }

          function getInfoComplementaria_html(solo_lectura) {
            
              var html = "<div id='divDC_scroll' style='width:100%'>"
              if (!solo_lectura)
                html = "<div id='divDC_scroll' style='width:100%;height:320px;overflow:auto'>"

              html += "<table class='tb2' style='width:100%'>"
              for (i in DatosComplemetarios) 
              {
                  var dato = DatosComplemetarios[i]
                  var id = i
                  var etiqueta = dato.etiqueta
                  var valor = dato.valor
                  var editable = dato.editable
                  var visible = dato.visible
                  var tipo_dato = dato.tipo_dato
                  var onchange = dato.onchange
                  var toma_valor_de = dato.toma_valor_de
                  var obligatorio = dato.obligatorio

                  if (id == 'numError' && valor != '0') {
                      alert(valor)
                      //continue
                  }

                  display = 'display: block-level'
                  if (!visible)
                      display = 'display: none'

                  if(solo_lectura)
                      editable = false

                  if (id.indexOf('separador') > -1)
                  {
                      html += "<tr><td class='Tit2' colspan='2'><b>" + etiqueta + "</b></td></tr>"
                      html += "<tr><td class='Tit1' style='width:35%;text-align:center'><b>Descripción</b></td><td class='Tit1' style='text-align:center'><b>Valor</b></td></tr>"
                      continue
                  }

                  html += "<tr style='" + display + "'>"
                  html += "<td class='Tit4' style='width:35%' id='eti_" + id + "' nowrap='nowrap'>" + (obligatorio ? "(*) " : " ") + etiqueta + ":</td>"
                  html += "<td id='valor_" + id + "'>" + complemento_dibujar_tipo_dato(id, tipo_dato, valor, editable, visible, onchange, toma_valor_de) + "</td>"
                  html += "</tr>"
              }

              html += "</table>"
              html += "</div>"

              if (!solo_lectura)
               {
                  html += "</br>"
                  html += "<table style='width:100%'>"
                  html += "<tr>"
                  html += "<td>&nbsp;</td>"
                  html += "<td style='width:30%'><div id='divComplementoGuardar'/></td>"
                  html += "<td style='width:30%'><div id='divComplementoCancelar'/></td>"
                  html += "<td>&nbsp;</td>"
                  html += "</tr>"
                  html += "</table>"
               }
              
              return html
          }

          function complemento_dibujar_tipo_dato(id, tipo_dato, valor_defecto, editable, visible, onchange, toma_valor_de)
          {
              if (!valor_defecto)
                  valor_defecto = ''

              if (toma_valor_de)
                  valor_defecto = parametros_obtenervalor(toma_valor_de) 

              if (!tipo_dato)
                  tipo_dato = 'varchar'

              if (!editable)
                  editable = "disabled='disabled'"

              var input = ''
              switch (tipo_dato.toLowerCase()) 
                 {
                      case 'int':
                          input = "type = 'text'  onkeypress='return valDigito(event)' style='width: 40%; text-align: right'"
                          break
                      case 'datetime':
                          input = "type = 'text' onchange='return valFecha(event)' onkeypress='return valDigitoFecha(event)' style='width: 15%; text-align: right'"
                          break
                      case 'bit':
                          input = "type = 'checkbox' style='border:0px' "
                          valor_defecto = valor_defecto.toLowerCase() == 'false' || valor_defecto.toLowerCase() == '' ? "0' " : "1'  checked='checked' "
                          break
                      case 'varchar':
                          input = "type = 'text' style='width: 80%; text-align: left' onchange='" + onchange + "'"
                          break
                      case 'pass':
                          input = "type = 'password' style='width: 40%; text-align: left' onchange='" + onchange + "'"
                          break
                 }

              var strHTML = ''
              if (input == '')
               {
                  if (tipo_dato.toLowerCase() == 'tipo_docu')
                      strHTML = "<select id='" + id + "'  " + editable + " style='width:50%'><option value='3' selected='selected'>DNI</option><option value='1'>LE</option><option value='2'>LC</option></select>"
                  if (tipo_dato.toLowerCase() == 'sexo')
                      strHTML = "<select id='" + id + "'  " + editable + " style='width:50%'><option value='M' selected='selected'>Masculino</option><option value='F'>Femenino</option></select>"
               }
              else
                  strHTML = "<input " + input + " name='" + id + "' id='" + id + "' value='" + valor_defecto + "' " + editable + "/>"

              return strHTML
          }


          function validar_clave(obj1, obj2)
          {
              var pwd_new = $(obj1).value
              var pwd_new_conf = $(obj2).value

              if (pwd_new == "" || pwd_new_conf == "")
                  return

              if (pwd_new_conf != pwd_new)
               {
                  $(obj1).value = ""
                  $(obj1).focus()
                  alert('Las contraseñas no coinciden.')
                  return
               }

          }

          function tipo_login_onchange()
          {
              if ($('tipo_login').value == 'ads')
              {
                  $('origen').show()
                  $('tdorigen').show()
              }
              else
              {
                  $('origen').hide()
                  $('tdorigen').hide()
              }

          }
</script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="height: 100%;width:100%; vertical-align: middle; overflow: hidden;">
       <div id="div_Iframe" style='width:100%'>
            <table style="width:100%">
                <tr>
                  <td>
                   <div id="divComplemento" style="margin: 0px; padding: 0px;"></div>
                    <script  type="text/javascript">
                        var DocumentMNG = new tDMOffLine;
                        var vComplemento = new tMenu('divComplemento', 'vComplemento');
                        Menus["vComplemento"] = vComplemento
                        Menus["vComplemento"].alineacion = 'centro';
                        Menus["vComplemento"].estilo = 'A';
                        Menus["vComplemento"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos Complementarios</Desc></MenuItem>")
                        if ("<%= login %>" != "")
                          Menus["vComplemento"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>complementos_editar()</Codigo></Ejecutar></Acciones></MenuItem>")
                        vComplemento.loadImage("editar", '/fw/image/icons/editar.png')
                        vComplemento.MostrarMenu()
                    </script>
                     <div id="divOrigenComplemento" style="width:100%;overflow:auto">
                       <% 
                           if (login <> "") Then

                               Dim selected_ads As String = ""
                               Dim selected_del As String = ""

                               If (nvApp.ads_login) Then
                                   selected_ads = "selected = 'selected'"
                               Else
                                   selected_del = "selected = 'selected'"
                               End If

                               Response.Write("<input type='hidden' id='ads_login_def' value ='" & nvApp.ads_login & "'/>")
                               Response.Write("<input type='hidden' id='ads_dc_def' value ='" & nvApp.ads_dc & "'/>")
                               Response.Write("<input type='hidden' id='ads_dominio_def' value ='" & nvApp.ads_dominio & "'/>")

                               Response.Write("<table class='tb2' style='width:100%'>")
                               Response.Write("<tr>")
                               Response.Write("<td class='Tit1' style='width:10%'>Tipo de Validación:</td>")
                               Response.Write("<td style='width:15%'>")
                               Response.Write("<select id='tipo_login' style='width:100%' onchange='tipo_login_onchange() || getInfoComplementaria()'>")
                               Response.Write("<option " & selected_ads & " value='ads'>Active Directory</option>")
                               Response.Write("<option " & selected_del & " value='delegado'>Delegado</option>")
                               Response.Write("</select>")
                               Response.Write("</td>")
                               Response.Write("<td class='Tit1' style='width:5%' id='tdorigen'>Origen:</td>")
                               Response.Write("<td style='width:25%'>")

                               Response.Write("<select id='origen' style='width:100%;' onchange='getInfoComplementaria()' >")

                               Dim selected As String = ""
                               Dim rs As ADODB.Recordset
                               rs = nvDBUtiles.ADMDBOpenRecordset("select distinct isnull(ads_access,'') as ads_access,isnull(ads_dc,'') as ads_dc, isnull(ads_dominio,'') as ads_dominio, delegate_login from nv_servidor_sistemas where cod_sistema = '" & nvApp.cod_sistema & "'")
                               While (Not (rs.EOF))
                                   If rs.Fields("ads_dc").Value = nvApp.ads_dc And rs.Fields("ads_dominio").Value = nvApp.ads_dominio Then
                                       selected = "selected = 'selected'"
                                   End If

                                   If (nvApp.ads_login) Then
                                       Dim descripcion As String = rs.Fields("ads_access").Value + ": " + IIf(rs.Fields("ads_dc").Value = "", "", rs.Fields("ads_dc").Value)
                                       If Not (IsNothing(rs.Fields("ads_dominio").Value)) And Not (rs.Fields("ads_dominio").Value = "") Then
                                           descripcion += "." + rs.Fields("ads_dominio").Value
                                       End If

                                       Dim origen_value As String = rs.Fields("ads_access").Value + "|" + rs.Fields("ads_dc").Value + "|" + rs.Fields("ads_dominio").Value
                                       Response.Write("<option " & selected & " value='" & origen_value & "'>" & descripcion & "</option>")
                                   Else
                                       Response.Write("<option " & selected & " value='" & rs.Fields("delegate_login").Value & "'>" & rs.Fields("delegate_login").Value & "</option>")
                                   End If
                                   rs.MoveNext()
                               End While

                               Response.Write("</select>")
                               Response.Write("</td>")
                               Response.Write("<td>&nbsp;</td>")
                               'Response.Write("<td style='width:10%'><input type='button' value = 'Buscar' style='width:100%' onclick='return getInfoComplementaria()'/></td>")
                               Response.Write("</tr>")
                               Response.Write("</table>")
                               Response.Write("<script  type='text/javascript'>")
                               Response.Write("</script>")
                           End If

                       %>
                    </div>
                 </td>
               </tr>
           </table>
      </div>
      <div id="divDatosComplementarios" style="width:100%;overflow:auto"></div>

</body>
</html>
