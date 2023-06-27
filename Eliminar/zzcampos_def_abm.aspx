<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim campo_def As String = nvFW.nvUtiles.obtenerValor("campo_def", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    If (strXML <> "") Then
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("campo_def_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ,, strXML)
        Dim rs As ADODB.Recordset = cmd.Execute()
        Dim er As New nvFW.tError(rs)
        er.response()
    End If

    Me.contents("campo_def") = campo_def

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Campos def</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/tMenu.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <!--<script type="text/javascript" language="javascript" src="/FW/script/tMenu.js"></script>-->
    
    <% = Me.getHeadInit()%>
    <script type="text/javascript">
        var default_accion = ""
        function window_onload()
           {

           var campo_def =  nvFW.pageContents.campo_def
           default_accion = campo_def == "" ? "A" : "M"
           var rs = new tRS()
           rs.asyc = true
           rs.onComplete = function(rs) 
                               {
                               nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload")
                               //if (rs.eof()) 
                               //    {
                               //    alert("No se encuentra el campo_def para editar")
                               //    }
                               
                               campos_defs.set_value("campo_def",rs.getdata("campo_def"))
                               campos_defs.set_value('descripcion', rs.getdata("descripcion"))
                               campos_defs.set_value('nro_campo_tipo', rs.getdata("nro_campo_tipo"))
                               
                               $("depende_de").checked = rs.getdata("depende_de") != null  
                               if ($("depende_de").checked)
                                    campos_defs.set_value('depende_de_campo', rs.getdata("depende_de_campo"))
                                
                               $("permite_codigo").checked = rs.getdata("permite_codigo") == "True"

                               if (rs.getdata("json") == "True")
                                    document.querySelector('[value=json]').checked = true
                               else
                                    document.querySelector('[value=XML]').checked = true 
                               
                               $("filtroXML").value = rs.getdata("filtroXML")
                               $("filtroWhere").value = rs.getdata("filtroWhere")

                               } 
           
           var filtroWhere = "<criterio><select><filtro><campo_def type='igual'>'" + campo_def + "'</campo_def></filtro></select></criterio>"                    
           nvFW.bloqueo_activar($$("BODY")[0], "rsOnload")
           rs.open({filtroXML: "<criterio><select vista='campos_def'><campos>*</campos><orden>campo_def</orden><filtro></filtro></select></criterio>", filtroWhere: filtroWhere})

           }

        function campo_def_guardar()
          {
          //Permisos
         
          //Validaciones
          if (campos_defs.value("campo_def") == "")  
              {
              alert("No ha ingresado e valor para 'campo_def'")
              return
              } 

          if (campos_defs.value("descripcion") == "")  
              {
              alert("No ha ingresado e valor para 'Descripción'")
              return
              } 
          if (campos_defs.value("nro_campo_tipo") == "")  
              {
              alert("No ha ingresado e valor para 'Tipo'")
              return
              } 
          
          //Si es nuevo validar que el codigo no exista ...
          var strXML = "<campos_defs><campo_def accion='" + default_accion + "' campo_def='" + campos_defs.value("campo_def") + "' descripcion='" + campos_defs.value("descripcion") + "' nro_campo_tipo='" + campos_defs.value("nro_campo_tipo") + "' " 
          if ($("depende_de").checked)
            strXML += "depende_de='true' depende_de_campo='" + campos_defs.value("depende_de_campo") + "'"
          else 
            strXML += "depende_de='false' depende_de_campo=''"   
         
          if ($("permite_codigo").checked)
            strXML += " permite_codigo='true' "
          else 
            strXML += " permite_codigo='false' "   
          
          if (document.querySelector('[value=json]').checked)
              strXML += "json='true' "
          else 
            strXML += "json='false' "   
           
          strXML += ">"
          strXML += "<filtroXML><![CDATA[" + $("filtroXML").value + "]]></filtroXML><filtroWhere><![CDATA[" + $("filtroWhere").value + "]]></filtroWhere></campo_def></campos_defs>"
          
          var er = nvFW.error_ajax_request("campos_def_abm.aspx", {parameters: {strXML: strXML}
                                                  ,onSuccess: function()
                                                                 {
                                                                  var win = nvFW.getMyWindow()
                                                                  win.close()
                                                                 } 
                                                  ,error_alert: true  
                                                  })

          //debugger
          //var er = new tError()
          //er.Ajax_request("campos_def_abm.aspx", {parameters: {strXML: strXML}
          //                                        //bloq_contenedor_on: true,
          //                                        //bloq_contenedor: $$("BODY")[0],
          //                                        //error_alert: true  
          //                                        //,onSuccess: function()
          //                                        //               {
          //                                        //                //debugger 
          //                                        //                var win = nvFW.getMyWindow()
          //                                        //                win.close()
          //                                        //               }
          //                                        })
          
          

        
          
          //debugger 
          //var oXML = new tXML()
          //oXML.method = "POST" 
          //oXML.asyc = false
          //if (oXML.load("campos_def_abm.aspx",{strXML: strXML}))
          //    {
          //    if (oXML.selectSingleNode("error_mensajes/error_mensaje/@numError").nodeValue != 0)
          //      {
          //      var  er = new tError()
          //      er.error_from_xml(oXML)
          //      er.alert() 
          //      //alert(er.titulo + "  " + er.mensaje)
          //      }
          //    } 

          }

         
    </script>

</head>
<body  style="overflow:hidden" onload="window_onload()">


    <table class="tb1" style="width:100%">
        <tr><td ><div id="DIV_Menu" style="WIDTH: 100%"></div></td></tr>
    </table>
        <script type="text/javascript" language="javascript">
    
    
    var vMenu = new tMenu('DIV_Menu','vMenu');
    vMenu.alineacion = 'centro';
    vMenu.estilo = 'A'
   
    vMenu.loadImage("guardar",'/FW/image/icons/guardar.png')
    vMenu.loadImage('eliminar','/FW/image/icons/eliminar.png')
    vMenu.loadImage('nuevo','/FW/image/icons/nueva.png')
    //vMenu.imagenes = Imagenes //Imagenes se declara en pvUtiles
 
    //Importante: Nombre de la ventana que contendrá los documentos 
    var TargetDocumentos = 'lado';
    var e;
    
    //var oXML = new tXML();
    //oXML.loadXML("<Menu><Menu>")
    //vMenu.CargarXML(oXML);
    vMenu.CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenu.CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Campo defs</Desc></MenuItem>")
    vMenu.CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenu.CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_nuevo</Codigo></Ejecutar></Acciones></MenuItem>")

    vMenu.MostrarMenu();

    </script>
    <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 40px" >id:</td>
            <td colspan="2"><% = nvFW.nvCampo_def.get_html_input("campo_def", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td  class="Tit1">Descripción:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("descripcion", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td  class="Tit1">Tipo:</td>
            <td><% = nvFW.nvCampo_def.get_html_input("nro_campo_tipo", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='campos_def_tipo'><campos> distinct nro_campo_tipo as id, campo_tipo as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>")  %></td>
        </tr>
        <tr>
            <td  class="Tit1">Dependiente:</td>
            <td><input name="depende_de" id="depende_de" type="checkbox" /></td>
            <td><% = nvFW.nvCampo_def.get_html_input("depende_de_campo", enDB:=False, nro_campo_tipo:=104)  %></td>
            <td class="Tit1">Permite código</td>
            <td><input name="depende_de" id="permite_codigo" type="checkbox" /></td>
            <td class="Tit1">transporte</td>
            <td><input name="transporte" type="radio" value="json"  /> JSON <input name="transporte" type="radio" value="XML"  />XML</td>
        </tr>
    </table>
    <table class="tb1">
        <tr class="tbLabel">
            <td>FiltroXML</td>
        </tr>
        <tr>
            <td><textarea name="filtroXML" id="filtroXML" style="width:100%" rows="5" ></textarea></td>
        </tr>
        <tr class="tbLabel">
            <td>FiltroWhere</td>
        </tr>
        <tr>
            <td><textarea name="filtroWhere" id="filtroWhere" style="width:100%" rows="5" ></textarea></td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width:40%"></td>
            <td><div  id="divGuardar" name="divGuardar"></div></td>
            <td style="width:40%"></td>
        </tr>
    </table>

    <table style="width: 100%">
        <tr>
            <td style="width:40%"></td>
            <td><div  id="divGuardar2" name="divGuardar2"></div></td>
            <td style="width:40%"></td>
        </tr>
    </table>
    

    <script type="text/javascript">
        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "alert('hola')";
        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Guardar2";
        vButtonItems[1]["etiqueta"] = "Guardar2";
        vButtonItems[1]["imagen"] = "guardar";
        vButtonItems[1]["onclick"] = "alert('hola')";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("guardar",'/FW/image/icons/guardar.png')
        vListButton.MostrarListButton()
    </script>
</body>
</html>        