<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<% 

    Response.Expires = 0

    Dim control_vigente As String = ""

    'Obtenemos valores del submit()
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")      '//M:'Modo Actualización'  
    If (modo = "") Then
        modo = "C"
    End If

    Dim nro_transf_pt_ref As String = nvUtiles.obtenerValor("nro_transf_pt_ref", "")
    Dim descripcion As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("descripcion", ""))
    Dim vigente As String = nvUtiles.obtenerValor("vigente", "")
    Dim id_transferencia As String = nvUtiles.obtenerValor("id_transferencia", "")
    Dim nro_permiso As String = nvUtiles.obtenerValor("nro_permiso", "")
    Dim nro_permiso_grupo As String = nvUtiles.obtenerValor("nro_permiso_grupo", "")

    'debe tener el permiso para editar el modulo
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If Not op.tienePermiso("permisos_procesos_tareas", 2) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.response()
    End If


    Dim campos_defs As Dictionary(Of String, String)
    Dim arrParam As New Dictionary(Of String, Dictionary(Of String, String))
    Dim StrSQL As String = "Select distinct id_transf_pt_param, campo_def,campo_etiqueta from transf_pt_params"
    Dim rsTpram = nvDBUtiles.DBOpenRecordset(StrSQL)
    While (rsTpram.EOF = False)

        campos_defs = New Dictionary(Of String, String)
        campos_defs.Add(rsTpram.Fields("campo_def").Value, rsTpram.Fields("campo_etiqueta").Value)

        arrParam.Add(rsTpram.Fields("id_transf_pt_param").Value, campos_defs)

        rsTpram.MoveNext()

    End While

    nvDBUtiles.DBCloseRecordset(rsTpram)

    StrSQL = ""
    If (modo <> "C") Then
        Dim err As New tError()
        Try

            If (nro_transf_pt_ref = 0) Then

                StrSQL = "INSERT INTO transf_pt_ref(descripcion,id_transferencia,vigente,nro_permiso_grupo,nro_permiso"
                For Each i As String In arrParam.Keys
                    StrSQL += ", id_transf_pt_param" & i
                Next
                StrSQL = StrSQL & ") " & vbCrLf & " VALUES ('" & descripcion & "', " & id_transferencia & ", " & vigente & "," & IIf(nro_permiso_grupo = "", "NULL", nro_permiso_grupo) & ", " & IIf(nro_permiso = "", "NULL", nro_permiso) & " "

                For Each i As String In arrParam.Keys
                    StrSQL += ",'" & nvUtiles.obtenerValor(i, "") & "'"
                Next
                StrSQL = StrSQL & ") " & vbCrLf

            End If

            If (nro_transf_pt_ref > 0) Then

                StrSQL = "UPDATE transf_pt_ref SET"
                StrSQL += " descripcion = '" & descripcion & "',nro_permiso_grupo = " + IIf(nro_permiso_grupo = "", "NULL", nro_permiso_grupo) + " ,nro_permiso = " + IIf(nro_permiso = "", "NULL", nro_permiso) + " , id_transferencia = " & id_transferencia & " "
                StrSQL += ", vigente = " & vigente
                For Each i As String In arrParam.Keys
                    StrSQL += ", id_transf_pt_param" & i & " = '" & nvUtiles.obtenerValor(i, "") & "'"
                Next

                StrSQL += " WHERE nro_transf_pt_ref = " & nro_transf_pt_ref & " " & vbCrLf

            End If
            If (nro_transf_pt_ref < 0) Then
                StrSQL = "DELETE FROM transf_pt_ref WHERE nro_transf_pt_ref = " & (nro_transf_pt_ref * -1) & " " & vbCrLf
            End If

            nvDBUtiles.DBExecute(StrSQL)
            err.numError = 0
            err.mensaje = ""
            err.params.Add("res", "OK")

        Catch ex As Exception
            err.parse_error_script(ex)
            err.mensaje = ex.Message.ToString & "Sql:" & StrSQL
        End Try

        err.response()

    End If

    '******* vistas encriptadas 
    Me.contents("filtroverTransf_procesos_tareas_ref") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_procesos_tareas_ref'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

    '*********** permisos
    Me.addPermisoGrupo("permisos_transferencia")

 %>
<html>

<head>
     <title></title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <%= Me.getHeadInit()   %>
    <script type="text/javascript" >


var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); } 

var BuscarEnPadron = false;

 var vButtonItems = {};
 vButtonItems[0] = {};
 vButtonItems[0]["nombre"] = "guardar";
 vButtonItems[0]["etiqueta"] = "Guardar cambios";
 vButtonItems[0]["imagen"] = "guardar";
 vButtonItems[0]["onclick"] = "return guardar()";
 
 vButtonItems[1] = {};
 vButtonItems[1]["nombre"] = "guardar_como";
 vButtonItems[1]["etiqueta"] = "Guardar como";
 vButtonItems[1]["imagen"] = "guardar";
 vButtonItems[1]["onclick"] = "return guardar(true)";
 
 vButtonItems[2] = {};
 vButtonItems[2]["nombre"] = "eliminar";
 vButtonItems[2]["etiqueta"] = "Eliminar";
 vButtonItems[2]["imagen"] = "cerrar";
 vButtonItems[2]["onclick"] = "return eliminar()";

 vButtonItems[3] = {};
 vButtonItems[3]["nombre"] = "salir";
 vButtonItems[3]["etiqueta"] = "Salir";
 vButtonItems[3]["imagen"] = "";
 vButtonItems[3]["onclick"] = "return parent.Windows.getFocusedWindow().close()";
 
 
var vListButton = new tListButton(vButtonItems,'vListButton');
vListButton.loadImage("cerrar", '/fw/image/icons/eliminar.png')
vListButton.loadImage("guardar", '/fw/image/icons/guardar.png')

var modo = ''

var win = nvFW.getMyWindow()

function window_onload() 
  { 
   vListButton.MostrarListButton()
    
   if ('<%=id_transferencia %>' != '')
       campos_defs.set_value('id_transferencia', '<%=id_transferencia %>')

   campos_defs.set_value('nro_permiso_grupo', '10')

   proceso_ref_cargar()

}

function Validar()
{ 
//validar
 strError=''

 if ($('descripcion').value == '')
  strError="\nPor favor ingrese la Descripción"

 if (campos_defs.value('id_transferencia') == '')
  strError="\nPor favor ingrese la Transferencia"

 if (strError != '')
    return strError
}

function guardar(guardar_como)
{
    var strErr = Validar()
    if(strErr != undefined)
      {
       alert(strErr)
       return
      }
      
    if (guardar_como)
       $('nro_transf_pt_ref').value = 0

    var str = "nvFW.error_ajax_request('procesos_tareas_ref_abm.aspx', { parameters: { modo: 'M'\n"
       str += "                                                             , nro_transf_pt_ref: $('nro_transf_pt_ref').value\n"
       str += "                                                             , descripcion: encodeURIComponent($('descripcion').value)\n"
       str += "                                                             , vigente: $('control_vigente').value\n"
                                                                           for (i in arrtparam) 
       str += "                                                             ," + i + " : campos_defs.value('" + arrtparam[i] + "')\n"
       str += "                                                             , id_transferencia: campos_defs.value('id_transferencia')\n"
       str += "                                                             , nro_permiso_grupo: campos_defs.value('nro_permiso_grupo')\n"
       str += "                                                             , nro_permiso: campos_defs.value('nro_permiso_dep')\n"
       str += "                                                             },\n"
       str += "onSuccess: function(err, transport) {\n"
       str += "    if (err.params['res'] = 'OK') {\n"
       str += "        parent.Windows.getFocusedWindow().returnValue = 'OK'\n"
       str += "        parent.Windows.getFocusedWindow().close()\n"
       str += "    }\n"
       str += "}\n"
       str += "});\n;"
   
   eval(str)
}

function proceso_ref_cargar() {
  
  Control_Vigente()
  
  if( $('nro_transf_pt_ref').value == 0)
   return

  var rs = new tRS();
  
  var filtroWhere = $('nro_transf_pt_ref').value
  rs.open(nvFW.pageContents.filtroverTransf_procesos_tareas_ref, "", "<criterio><select><campos></campos><filtro><nro_transf_pt_ref type='igual'>" + filtroWhere + "</nro_transf_pt_ref></filtro><orden></orden></select></criterio>","","")
  if (!rs.eof())
     {
        $('descripcion').value = rs.getdata('descripcion')
        $('chk_vigente').checked = rs.getdata('vigente') == 'True' ? true : false 
        
        Control_Vigente()// Le paso el valor al control si es vigente o  no.-

        for (i in arrtparam) 
         {
            streval = ''
            streval += "if(rs.getdata('id_transf_pt_param"+ i +"') != null)\n"
            streval += " campos_defs.set_value('" + arrtparam[i] + "',rs.getdata('id_transf_pt_param" + i + "')) \n"
            eval(streval)
         }
        
        if (rs.getdata('id_transferencia') != null)
          campos_defs.set_value('id_transferencia', rs.getdata('id_transferencia'))

      
       if (rs.getdata('nro_permiso_grupo') != null)
          campos_defs.set_value('nro_permiso_grupo', rs.getdata('nro_permiso_grupo'))

       if (rs.getdata('nro_permiso') != null)
            campos_defs.set_value('nro_permiso_dep', rs.getdata('nro_permiso'))
         
   } 
 }
function eliminar()
 {
   Dialog.confirm("Desea eliminar este Procesos ",{    width:350, 
                                                   className: "alphacube",
                                                     okLabel: "Aceptar", 
                                                 cancelLabel: "Cancelar",  
                                                      cancel:function(win){win.close(); return}, 
                                                          ok:function(win){ 
                                                                           $('nro_transf_pt_ref').value = $('nro_transf_pt_ref').value * -1
                                                                            guardar(false)
                                                                            win.close() 
                                                                          } 
                                                 });   
 }

function isNULL(valor, sinulo)
{
  valor = valor == null ? sinulo: valor
  return valor
}

function Control_Vigente()
{ 
  $('control_vigente').value = $('chk_vigente').checked == true ? 1 : 0
}

function window_onunload()
{
    win.close()
}


function transferencia_abm() {

    if (nvFW.tienePermiso("permisos_transferencia", 1)) {
        win = window.top.nvFW.createWindow({
            className: 'alphacube',
            url: '/fw/transferencia/transferencia_abm.aspx?id_transferencia=' + campos_defs.value("id_transferencia"),
            title: '<b>Transferencia - ABM</b>',
            minimizable: true,
            maximizable: true,
            draggable: true,
            width: 1000,
            height: 500
        });

        win.showCenter()

    }
    else {
        alert('No posee los permisos necesarios para realizar esta acción')
        return
    }
}

//-->
</script>
</head>
<body onload="return window_onload()" onunload ="return window_onunload()" style="width:100%;height:100%;overflow:hidden">
    <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
       <script type="text/javascript">
         var DocumentMNG = new tDMOffLine;
         var vMenu = new tMenu('divMenu', 'vMenu');
         Menus["vMenu"] = vMenu
         Menus["vMenu"].alineacion = 'centro';
         Menus["vMenu"].estilo = 'A';
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Transferencia ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>transferencia_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenu.loadImage("editar", '/fw/image/transferencia/editar.png')
         vMenu.MostrarMenu()
        </script> 
    <input type="hidden" name="modo" value="<%= modo%>" />
    <input type="hidden" name="control_vigente" id="control_vigente" value="<%= control_vigente%> " />
                  <table class="tb1">                      
                     <tr class="tbLabel0">
                          <td style="width:25%;text-align:center" colspan="2">Descripción</td>
                          <td style="width:20%;text-align:center">Transferencia</td>
                     </tr>
                     <tr>
                          <td colspan="2"><input type="hidden" name="nro_transf_pt_ref" id="nro_transf_pt_ref" value="<% = nro_transf_pt_ref %>" style="width:100%" disabled/><input type="text" name="descripcion" id="descripcion" style="width:100%" value=""/></td>
                          <td><%= nvCampo_def.get_html_input("id_transferencia") %></td> 
                     </tr>
                     <tr class="tbLabel0">
                          <td style="width:20%;text-align:center">Grupo Permiso</td>
                          <td style="width:20%;text-align:center">Permiso</td>
                          <td style="width:20%;text-align:center">Vigente</td>
                     </tr>
                     <tr>
                          <td><%= nvCampo_def.get_html_input("nro_permiso_grupo") %></td> 
                          <td><%= nvCampo_def.get_html_input("nro_permiso_dep", depende_de:="nro_permiso_grupo") %></td> 
                          <td style="text-align:center"><input type="checkbox" name="chk_vigente" id="chk_vigente" checked="checked" onchange="return Control_Vigente()"/></td>
                     </tr>
                  </table>                  
                     <table class="tb1">     
                     
                        <%

                            Dim strarrtparam As String = ""
                            Dim stretiqueta As String = ""
                            Dim strecuerpo As String = ""

                            For Each i As String In arrParam.Keys
                                stretiqueta += "<td class='Tit4' style='width:22%;text-align:center'>" & arrParam(i).Values(0).ToString & "</td>"
                                strecuerpo += "<td>" & nvCampo_def.get_html_input(arrParam(i).Keys(0).ToString,nro_campo_tipo:= 1) & "</td>"
                                strarrtparam += " arrtparam['" & i & "'] = '" & arrParam(i).Keys(0).ToString & "'"
                                strarrtparam += vbCrLf
                            Next

                            Response.Write("<tr class='tbLabel'>")
                            Response.Write(stretiqueta)
                            Response.Write("</tr>")

                            Response.Write("<tr>")
                            Response.Write(strecuerpo)
                            Response.Write("</tr>")

                            Response.Write(vbCrLf)
                            Response.Write("<script type='text/javascript'>")
                            Response.Write(vbCrLf)
                            Response.Write("var arrtparam = {}")
                            Response.Write(vbCrLf)
                            Response.Write(strarrtparam)
                            Response.Write(vbCrLf)
                            Response.Write("</script>")
                            Response.Write(vbCrLf)

                        %>
                  </table>                     
                  <br/>
             
                  <table style="width:100%">
                        <tr>
                            <td style="width: 25%">
                                <div id="divguardar"></div>
                            </td>
                            <td style="width: 25%">
                                <div id="divguardar_como"></div>
                            </td>                                                      
                            <td style="width: 25%">
                                <div id="diveliminar" style="display:inline"></div>
                            </td>   
                            <td style="width: 25%">
                                <div id="divsalir" style="display:inline"></div>
                            </td>                                                             
                        </tr>
                    </table>
</body>
</html>