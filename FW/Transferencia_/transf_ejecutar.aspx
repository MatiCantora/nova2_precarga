<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvTransferencia" %>

<%
    '/*****************************************************************************************/
    '/******************************************************************************************/
    Dim salida_tipo As String = IIf(nvUtiles.obtenerValor("salida_tipo", "html").ToLower() = "html" Or nvUtiles.obtenerValor("salida_tipo", "").ToLower() = "", "html", "estado") 'Cargar el valor correcto
    Dim objError As tError = New tError()
    objError.debug_src = "transf_ejecutar.aspx"
    objError.salida_tipo = salida_tipo

    Dim Transf As New tTransfererncia

    '/*********************************************************/
    '/*********************************************************/
    '// Parametros de entrada 
    '/*********************************************************/
    '/*********************************************************/
    ' //id_transferencia = idem
    ' //xml_param = valores de los parametros
    ' //pasada = indica el nro de pasada que está ejecutando
    ' /***************************************************/

    Dim ej_mostrar As Boolean = nvUtiles.obtenerValor("ej_mostrar", "").ToLower = "true"
    Dim async As Boolean = nvUtiles.obtenerValor("async", "").ToLower = "true"

    Dim id_transferencia As Integer = nvUtiles.obtenerValor("id_transferencia", 0, nvConvertUtiles.DataTypes.int)
    Dim xml_param As String = nvUtiles.obtenerValor("xml_param", "")
    Dim xml_det_opcional As String = nvUtiles.obtenerValor("xml_det_opcional", "")
    Dim xml_comentario As String = nvUtiles.obtenerValor("xml_comentario", "")
    Dim pasada As Integer = nvUtiles.obtenerValor("pasada", 0, nvConvertUtiles.DataTypes.int)
    'Dim trans_salida_tipo As String = salida_tipo 'IIf(nvUtiles.obtenerValor("salida_tipo", "adjunto").ToLower = "estado", "estado", "adjunto") '//adjunto o estado
    Dim id_transf_log As Integer = nvUtiles.obtenerValor("id_transf_log", 0, nvConvertUtiles.DataTypes.int)
    Dim id_transf_det As Integer = nvUtiles.obtenerValor("id_transf_det", "0")
    'Dim tiene_requeridos_pendientes As Boolean = False


    ' // controlo si el id_transf_log esta termiando
    If (id_transf_log > 0) Then
        Dim rsTransfEstado As ADODB.Recordset = nvDBUtiles.DBExecute("Select * from transf_log_cab where estado = 'finalizado' and  id_transf_log = " & id_transf_log)
        If Not rsTransfEstado.EOF Then
            objError.numError = 12010 '     objError.cargar_msj_error(12010)
            objError.titulo = "Error al intentar ejecutar la transferencia"
            objError.mensaje = "La transferencia ya se encuentra finalizada"
            Transf.error_limpiar_archivos()
            nvDBUtiles.DBCloseRecordset(rsTransfEstado)
            objError.mostrar_error()
        End If
        nvDBUtiles.DBCloseRecordset(rsTransfEstado)
    End If

    ' /***********************************************/
    ' //Crear objeto transferencia
    ' /***********************************************/
    Transf.id_transf_log = id_transf_log
    Transf.id_transf_det = id_transf_det

    'Cargar transferencia
    objError = Transf.cargar(id_transferencia, xml_param, xml_det_opcional)
    If objError.numError <> 0 Then
        Transf.error_limpiar_archivos()
        objError.mostrar_error()
    End If

    ' /****************************************************************************/
    ' //Controla el tiempo maximo de ejecución de la transferencia
    ' /****************************************************************************/
    Server.ScriptTimeout = Transf.timeout


    ' /********************************************/
    ' //Controlar que si es una ejecución pendiente
    ' /********************************************/
    Dim tiene_requeridos_pendientes As Boolean

    ' /*********************************************************************************************/
    ' // Si alguna de las tareas de la transferencia es opcional y es la primera pasada
    ' // la propone para confirmar su ejecución
    ' /*********************************************************************************************/
    '//si tiene pendientes y el salida_tipo es estado entonces mandar error
    '//Si la ejecucion es desatendida no puede tener requeridos pendientes


    If Transf.tiene_requeridos_pendientes And salida_tipo = "estado" Then
        objError.numError = 12002
        objError.titulo = "Error al intentar ejecutar la transferencia"
        '  objError.mensaje = "La transferencia tiene requisitos que no fueron suministrados"
        Transf.error_limpiar_archivos()
        objError.mostrar_error()
    End If

    tiene_requeridos_pendientes = Transf.tiene_requeridos_pendientes Or (Transf.tiene_editables And pasada = 0 And Not async And salida_tipo <> "estado") Or (Transf.tiene_opcionales = True And pasada = 0)

    If Not (tiene_requeridos_pendientes Or ej_mostrar) Then

        '/*******************************************/
        '//  Si no tiene pendientes hay que ejecutar
        '/*******************************************/
        'async = False
        ' Dim nvApp As tnvApp = nvFW.nvApp.getInstance()
        If Transf.id_transf_log = 0 Then
            Dim rsTransf_log As ADODB.Recordset = nvDBUtiles.DBExecute("exec transf_log_add " & Transf.id_transferencia)
            Transf.id_transf_log = rsTransf_log.Fields("id_transf_log").Value
            nvDBUtiles.DBCloseRecordset(rsTransf_log)
        End If

        Dim err As New tError()
        Dim objXML_comentario As New System.Xml.XmlDocument
        If xml_comentario <> "" Then
            Try
                objXML_comentario.LoadXml(xml_comentario)
            Catch ex As Exception
                objError.parse_error_xml(ex)
                objError.numError = 12002
                objError.titulo = "Error al intentar ejecutar la transferencia"
                objError.mensaje = "Error al cargar el comentario"
                Transf.error_limpiar_archivos()
                objError.mostrar_error()
            End Try
        End If

        Dim comentario As String
        Dim nro_com_tipo As Integer
        Dim nro_com_id_tipo_ As Integer

        Try
            If Not nvXMLUtiles.getNodeText(objXML_comentario, "comentario") Is Nothing Then
                comentario = nvXMLUtiles.getNodeText(objXML_comentario,"comentario", "")

                Dim rsIdcomTipo_ As ADODB.Recordset = nvDBUtiles.DBExecute("select top 1 nro_com_id_tipo from com_id_tipo where com_id_tipo like '%BPM%'")
                nro_com_id_tipo_ = rsIdcomTipo_.Fields("nro_com_id_tipo").Value
                nvDBUtiles.DBCloseRecordset(rsIdcomTipo_)
                'nro_com_id_tipo_ = 3 '//getParametroValor("nro_com_id_tipo")

                nro_com_tipo = nvXMLUtiles.getAttribute_path(objXML_comentario, "/comentario/@nro_com_tipo", nro_com_id_tipo_)
                If nro_com_tipo > 0 And comentario <> "" Then
                    Dim strSQL = "INSERT INTO [com_registro]"
                    strSQL += " ([nro_entidad],[nro_com_tipo],[comentario],[operador],[fecha],[nro_com_estado],[nro_com_id_tipo],[id_tipo]) "
                    strSQL += " VALUES (0," & nro_com_tipo & "," & nvConvertUtiles.objectToSQLScript(comentario) & ",dbo.rm_nro_operador(),getdate(),1," & nro_com_id_tipo_ & "," & Transf.id_transf_log & ")"
                    nvDBUtiles.DBExecute(strSQL)
                End If
            End If
        Catch ex As Exception
            objError.parse_error_xml(ex)
            objError.numError = 12002
            objError.titulo = "Error al intentar ejecutar la transferencia"
            objError.mensaje = "Error al cargar el comentario"
            Transf.error_limpiar_archivos()
            objError.mostrar_error()
        End Try

        If Transf.transf_version = "2.0" Then
            If async Then

                Dim async_thread As System.Threading.Thread = New System.Threading.Thread(Sub(psp As Object)

                                                                                              nvFW.nvApp._nvApp_ThreadStatic = psp("nvApp")
                                                                                              psp("Transf").ejecutar()

                                                                                              psp("Transf").error_limpiar_archivos()

                                                                                              Try
                                                                                                  nvTransfUtiles.transfRunThread.Remove(psp("Transf").id_transf_log)
                                                                                              Catch ex As Exception
                                                                                              End Try

                                                                                          End Sub)

                nvFW.nvTransferencia.nvTransfUtiles.transfRunThread.Add(Transf.id_transf_log, async_thread)

                Dim ps As New Dictionary(Of String, Object)
                ps.Add("Transf", Transf)
                ps.Add("nvApp", nvApp)

                async_thread.Start(ps)
                err.params("id_transf_log") = Transf.id_transf_log

            Else
                err = Transf.ejecutar()
                err.params("id_transf_log") = Transf.id_transf_log
                Transf.error_limpiar_archivos()
            End If

        Else

            '//obtener puerto
            Dim ports As nvServer.tParPorts = nvServer.getPortsTransf(nvApp.server_name)
            Dim protocolo As String = nvApp.server_protocol
            Dim port As Integer
            If nvApp.server_protocol = "https" Then
                port = ports.https
            Else
                port = ports.http
            End If


            Dim nvSessionNET As String = ""
            Dim hash As String = ""
            err = nvLogin.execute(nvApp, "get_hash", nvApp.operador.login, "", "", "", "", "")
            hash = err.params("hash")

            Dim IDSessionNet As String = ""
            '//crear sesion en .NET 
            Try

                Dim oHTTP As New nvHTTPRequest
                oHTTP.param_add("id_transf_log", Transf.id_transf_log)
                If Not Transf.transf_det_pendiente Is Nothing Then
                    oHTTP.param_add("id_transf_det", Transf.transf_det_pendiente.id_transf_det)
                Else
                    oHTTP.param_add("id_transf_det", "")
                End If

                oHTTP.param_add("pasada", pasada)
                oHTTP.param_add("xml_param", xml_param)
                oHTTP.param_add("xml_det_opcional", xml_det_opcional)
                oHTTP.param_add("xml_comentario", xml_comentario)
                oHTTP.param_add("id_transferencia", id_transferencia)
                oHTTP.param_add("app_cod_sistema", nvApp.cod_sistema)
                oHTTP.param_add("app_path_rel", nvApp.path_rel)
                oHTTP.param_add("nv_hash", hash)
                oHTTP.param_add("hash", hash)
                oHTTP.param_add("salida_tipo", objError.salida_tipo)
                oHTTP.param_add("ej_mostrar", ej_mostrar)
                oHTTP.param_add("end", "")
                oHTTP.multi_part = True

                For Each campo In Transf.Archivos.Keys
                    If Transf.Archivos(campo)("path") <> "" Then oHTTP.param_add(campo, Transf.Archivos(campo)("path"), 1)
                Next

                Dim URL As String = protocolo & "://" & nvApp.server_name & ":" & port
                oHTTP.url = URL & "/FW/Transferencia/transf_ejecutar.asp" & IIf(Transf.transf_version = "2.0", "x", "")

                If async Then
                    Try
                        err = New tError()
                        oHTTP.sendRequest()
                    Catch ex As Exception
                        err.parse_error_script(ex)

                    End Try
                    err.params("id_transf_log") = Transf.id_transf_log
                Else
                    Try
                        err.loadXML(oHTTP.getResponse())
                    Catch ex As Exception
                        err.parse_error_script(ex)
                    End Try
                End If
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
            Transf.error_limpiar_archivos()
        End If

        err.salida_tipo = salida_tipo
        err.mostrar_error()
    End If


    Response.Buffer = False
    Response.ContentType = "text/html"

    ' permisos
    Me.addPermisoGrupo("permisos_transferencia")
    Me.addPermisoGrupo("permisos_transferencia_seguimiento")

    'vistas
    Me.contents("filtroBucleEjecucion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_det'><campos>id_transf_log_subproc,fe_fin_det,nombre_operador,dbo.transf_USR_permiso_pendiente(id_transf_log,id_transf_det) as permiso_pendiente" _
        & ", id_transf_log, nombre, estado, estado_det, fe_inicio, fe_fin, id_transf_log_det, id_transf_det,id_transferencia, transferencia,transf_tipo,numError, mensaje, " _
        & "comentario, debug_desc, debug_src, link, script,salida_tipo,parametros_extra_xml,'' as obs</campos><filtro></filtro><orden>fe_fin_det</orden></select></criterio>")

    Me.contents("filtroXML_verTransf_log_det") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_det'><campos>comentario,mensaje,debug_src,debug_desc</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroTransferencia_det") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_det'><campos>parametros_extra_xml</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroCom_grupos") = nvXMLSQL.encXMLSQL("<criterio><select vista='com_grupos'><campos>nro_com_grupo</campos><filtro><com_grupo type='igual'>'BPM'</com_grupo></filtro></select></criterio>")
    Me.contents("filtroVerTransf_log_det") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_log_det'><campos>fe_fin_det,nombre_operador,dbo.transf_USR_permiso_pendiente(id_transf_log,id_transf_det) as permiso_pendiente, id_transf_log, nombre, estado, estado_det, fe_inicio, fe_fin, id_transf_log_det, id_transf_det,id_transferencia, transferencia,transf_tipo,numError, mensaje, comentario, debug_desc, debug_src, link, script,salida_tipo,parametros_extra_xml,'' as obs</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroRm_DTSRun_res") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_DTSRun_res' CommantTimeOut='1500' vista='verDTSRun_res'><parametros></parametros></procedure></criterio>")
    Me.contents("filtroVertransf_log_param") = nvXMLSQL.encXMLSQL("<criterio><select vista='vertransf_log_param'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")


%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Ejecutar transferencia</title>
  
    <link type="text/css" href="/fw/css/base.css" rel="stylesheet" />
      
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" src="/FW/transferencia/script/transf_seg_utiles.js"></script>
    <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>
    <script type="text/javascript" src="/fw/transferencia/script/transf_utiles.js"></script>
    <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>

    <style type="text/css">
         
          /*.tr_cel TD
          {
          background-color: white !Important
          }
        
          .tr_cel_click TD
          {
          background-color: #BDD3EF !Important;
          color : #0000A0 !Important
          }
          
          .dialog TABLE.table_window TD
          {
          padding-right : 1px;
          }*/
          
          .tdSubTitulo
          {
           border: 1px solid #749BC4 !Important;
           text-align:center !Important;
          }
          
    </style>
    <script type="text/javascript">
    var permisos_transferencia = nvFW.pageContents.permisos_transferencia
   // window.alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:600, height:200, okLabel: "cerrar"}); }
 
 //var vButtonItems = new Array()
 //var vListButtons = new tListButton(vButtonItems, 'vListButtons')
 //vListButtons.imagenes = Imagenes
 //vListButtons.MostrarListButton()
    /********************************************/
    // Todos los script de browser
    /********************************************/
 var id_transferencia = '<%= Transf.id_transferencia.ToString %>'
 var id_transf_log = '<%= id_transf_log.ToString  %>'
 <%
        Dim id_transf_det_pendiente As Integer = 0
        Try
            id_transf_det_pendiente = nvUtiles.isNUll(Transf.transf_det_pendiente.id_transf_det.ToString, 0)
        Catch ex As Exception
        End Try
 %>
var id_transf_det = '<%= id_transf_det_pendiente.ToString  %>'

 var fe_fin = '<%= "" %>'  //Transf.transf_det_pendiente == undefined ? '' : Transf.transf_det_pendiente.fe_fin
 var tiene_requeridos_pendientes = '<%= tiene_requeridos_pendientes %>'.toLowerCase() == 'true' 
 var ej_mostrar = '<%= ej_mostrar %>'.toLowerCase() == 'true'
      
 var id_interval = null
var transf_log_dets = {}

 function hoy()
    {
    var fecha = new Date();
    return FechaToSTR(fecha)
    }   

 function transf_ejecutar()
  {
  
   var strError = ''
   for (var i in Transf.param)
   {
    valor = ''
    if(Transf.param[i]['requerido'] && Transf.param[i]['editable'])
     {
      if (Transf.param[i]['campo_def'] == '') 
        if (Transf.param[i]['tipo_dato'].toUpperCase() == 'BIT')
           valor = $(Transf.param[i]['parametro']).checked ? 'True' : 'False'
        else   
           valor = $(Transf.param[i]['parametro']).value
      else
        valor = campos_defs.value(Transf.param[i]['parametro'])  
    
      if(valor == '')    
        strError += "Ingrese valor al parámetro <b>" + Transf.param[i]['etiqueta'] + "</b>.</br>"
     }
     
     if (Transf.param[i]['tipo_dato'].toUpperCase() == 'FILE') 
       {
        if($(Transf.param[i]['parametro']) != null)
         if($(Transf.param[i]['parametro']).value != '')
          {
           // Reemplazar "*" por ".*" , luego "?" por ".?" y el "." por "\."     
           var streg = Transf.param[i]['file_filtro']
           var reg = new RegExp("\\.", 'ig')
           streg = streg.replace(reg, "\\.")
           reg = new RegExp("\\*", 'ig')
           streg = streg.replace(reg, ".*")
           reg = new RegExp("\\?", 'ig')
           streg = streg.replace(reg, ".?")
       
           var reg = new RegExp(streg,'ig')
           var resultado = $(Transf.param[i]['parametro']).value.match(reg)
       
           if (resultado == null)
            {
             strError += "La denominación del archivo adjunto del parámetro <b>" + Transf.param[i]['etiqueta'] + "</b> es incorrecta.</br>"
             continue
            }
          }    
       }
   }   
  
   var comentario = ''
   try
      {
       //var FCK = FCKeditorAPI.GetInstance('fckeditor');
       comentario = CKEDITOR.instances.comentario.getData(); //FCK.GetData()
       comentario = comentario == null ? '' : comentario
       
       if(campos_defs.value("nro_com_tipo") == '' && comentario != '' )
         strError += "<b>Comentario</b>: falta definir el tipo de comentario.</br>"
      }
   catch(e){comentario = ''}
  
  
   if(strError != '')
    {
     Dialog.alert(strError, {className: "alphacube", width:400, height:150, okLabel: "cerrar"})
     return
    }
  
   var strXML = '<parametros>'
   var valor
   
   for (var i in Transf.param)
      {

      if (Transf.param[i]['editable'])
        {
        switch(Transf.param[i]['tipo_dato'].toUpperCase())
          {
          case 'BIT':
              valor = $(Transf.param[i]['parametro']).checked
              break;
          case 'DATETIME':
              valor = campos_defs.value(Transf.param[i]['parametro']) 
               if (valor == "") valor = null
              break;
          default:  //varchar, int, money
              if (Transf.param[i]['campo_def'] == '') 
                valor = $(Transf.param[i]['parametro']).value
              else
                valor = campos_defs.value(Transf.param[i]['parametro'])
              if ((Transf.param[i]['tipo_dato'].toUpperCase() == 'INT' || Transf.param[i]['tipo_dato'].toUpperCase() == 'MONEY') && valor == '')
                  valor = null
          }
        }
      else
        valor = Transf.param[i]['valor']
   
      if (valor != null)
          {
          strXML += '\n<' + Transf.param[i]['parametro'] + '>'

          if (Transf.param[i]['tipo_dato'].toUpperCase() == 'DATETIME' && valor == '')
              valor = null

          strXML += USER_get_valor(Transf.param[i]['tipo_dato'], valor)
          strXML += '</' + Transf.param[i]['parametro'] + '>'
          }
      }
      
    strXML += '</parametros>'

    var strXML_det = "\n<det_opcional>"
    for (var id_tranf_det in Transf.dets)
      {
      det = Transf.dets[id_tranf_det]
      if (det.opcional && det.habilitado) //habilitado
        {
        strXML_det += "<det id_transf_det='" + id_tranf_det + "' check='" + $("det_opcional" + id_tranf_det).checked + "' />"
        }
      }
    strXML_det += "</det_opcional>"
    //Event.observe($(hiddenIframe), 'onload', hiddenIframe_event)

    cookieDivCuerpo = $("divCuerpo").innerHTML.toString()
    cookieDivBotones = $("divBotones").innerHTML.toString()
    cookieXml_param = strXML.toString()
    cookieXml_det_opcional = strXML_det.toString()
     
    glogalEjecutar = true
    formTransfe.id_transferencia.value = id_transferencia
    formTransfe.xml_param.value = strXML
    formTransfe.xml_det_opcional.value = strXML_det
    formTransfe.id_transf_log.value = id_transf_log
    formTransfe.id_transf_det.value = id_transf_det
    formTransfe.xml_comentario.value = "<comentario nro_com_tipo='"+ campos_defs.value("nro_com_tipo") + "'><![CDATA[" + comentario + "]]></comentario>"
    formTransfe.pasada.value++
    formTransfe.async.value = true
    nvFW.bloqueo_activar($$('body')[0], "divTransfVidrio") 
    formTransfe.submit()
 
    //if($('divbtnEjecutar') != null)
    //  {
    //    try{ $("divbtnEjecutar").getElementsByClassName("btnOnOver_O")[0].onclick = function(){}} catch(e){}
    //  }

  }


 var cookieDivCuerpo = ""
 var cookieDivBotones = ""
 var cookieXml_param = ""
 var cookieXml_det_opcional = ""
        

function transf_control()
 {
  if(!tiene_requeridos_pendientes && ej_mostrar)
     {
        transf_ejecutar()
        $("divCuerpo").innerHTML = ""
        $("divBotones").innerHTML = ""
     }
  else
    {
      // verifica si tiene transf en iniciando
      //openWin_transf_en_iniciando_consultar(id_transferencia,id_transf_log)
  
      if($('divParams') != null)
         $('divParams').show()
       
      if($('divOpcions') != null)
         $('divOpcions').show()
       
      if($('divbtnEjecutar') != null)
         $('divbtnEjecutar').show()
       
      if($('divbtnComentario') != null)
         $('divbtnComentario').show()
         
      if($('divbtnSalir') != null)
         $('divbtnSalir').show()
       
      if($('divComentario') != null)
        {
          if(id_transf_log > 0)
           {
            $('tbComentarioTitulo').hide()
            $('divCkeditor').hide()
            //$('fckeditor___Frame').hide()
            $('trComTipo').hide()
            comentario_cargar(id_transf_log) 
            
            if(id_transf_det != "")
              if(getVercomentario() === true)
                 comentario_colapsar()
           }
       }
   }     
   
}

function getVercomentario()
{
 var rs = new tRS()
 rs.open(nvFW.pageContents.filtroTransferencia_det, "", "<criterio><select><campos></campos><filtro><id_transf_det type='igual'>" + id_transf_det + "</id_transf_det></filtro></select></criterio>", "", "")
 if(!rs.eof())
  {
   var oXML = new tXML();
   if(oXML.loadXML(rs.getdata('parametros_extra_xml')))
   {
    objXML = oXML.xml
    if(selectNodes('parametros_extra/parametro',objXML).length > 0)
     {
      var nombre = selectSingleNode('parametros_extra/parametro/@nombre', objXML).value
      var valor = selectSingleNode('parametros_extra/parametro', objXML).text
      if(nombre == 'verComentarios' && valor == '0')
        return false
      else
        return true
     } 
   } 
 }  
 return true
}

function comentario_colapsar() 
{
    
 if(id_interval != null)
  return
  
 var div = $('divComentario')
 if (div.style.display == 'none')
   {	
	div.show()
	if(id_transf_log > 0)
	 {
	   $('tbComentarioTitulo').hide();
	   $('frame_comentario').show();
	 }
	else
	 {
	   $('tbComentarioTitulo').show()
	   $('frame_comentario').hide();
     }	   
   }	
 else
  {
    div.hide()
  	$('tbComentarioTitulo').hide()
  }
    
 window_onresize()
}

var nro_com_grupo = 0
function obtener_nro_com_grupo()
{
 if(nro_com_grupo > 0)
  return
  
 var rs = new tRS()
 rs.open(nvFW.pageContents.filtroCom_grupos, "", "", "", "")
 if(!rs.eof())
   nro_com_grupo = rs.getdata("nro_com_grupo")
  
 if(nro_com_grupo == 0)
  alert("Falta definir grupo comentario") 
}

function comentario_cargar(id_transf_log) 
  {
    obtener_nro_com_grupo()
    ObtenerVentana('frame_comentario').location.href = '/fw/comentario/verCom_registro.aspx?nro_com_id_tipo='+ $('nro_com_id_tipo').value +'&nro_com_grupo='+ nro_com_grupo +'&collapsed_fck=1&id_tipo='+ id_transf_log +'&do_zoom=0'
  }
 
function window_onresize()
{
    try
   {
    var dif = Prototype.Browser.IE ? 5 : 2
    var body_h = $$('BODY')[0].getHeight()
    var divMenu_h = $('vMenu').getHeight()  
	var alto_botonera = $('divBotones').getHeight()

	var calculo = body_h - divMenu_h - alto_botonera - dif

    var alto_cuerpo = 0
    var contenedores = $('divCuerpo').querySelectorAll(".contenedor")
    for (var i = 0; i < contenedores.length; i++) {
        alto_cuerpo = alto_cuerpo + contenedores[i].getHeight()
    }

     //   console.log(calculo + " alto cuerpo:" + alto_cuerpo + 'botones:' + alto_botonera) 

    var alto_comentario = 0
    if ($('divComentario').style.display != 'none') {
         if (alto_cuerpo > calculo)
             alto_comentario = 200
         else
             alto_comentario = calculo - alto_cuerpo

         $('divComentario').setStyle({ height: (alto_comentario) + 'px' })
        // $('divCuerpo').setStyle({ height: calculo - alto_comentario + 'px' })

         contenedores = $('divComentario').querySelectorAll(".contenedor")
         for (var i = 0; i < contenedores.length; i++) {
             if (contenedores[i].style.display != 'none')
              alto_comentario = alto_comentario - contenedores[i].getHeight()
         }

         $('divCuerpoComentario').setStyle({ height: (alto_comentario) + 'px' })
         try {
             CKEDITOR.instances.comentario.resize('100%', (alto_comentario) + 'px')
         }
         catch (e1) { }
         try {
             $('frame_comentario').setStyle({ height: (alto_comentario) + 'px' })
         }
         catch (e2) { }
    }

    if(alto_comentario > 0 || alto_cuerpo > 0)
        $('divCuCO').setStyle({ height: calculo + 'px' })
    else
        $('divCuCO').setStyle({ height: '0px' })

   }
    catch (e) {
        //console.log(e.message)
    }
} 

function hiddenIframe_event()
{ 
    
    if (glogalEjecutar == false) return
    try
        {
        var strHTML = $('hiddenIframe').contentWindow.document.body.innerHTML
        var strXML = $('hiddenIframe').contentWindow.error_xml.value
        var oXML = new tXML()
        oXML.loadXML(strXML)
        var err = new tError()
        err.error_from_xml(oXML)
        if (err.numError == 0)
          {
          id_transf_log = err.params["id_transf_log"]

          if(id_transf_log > 0)
            {
            $('divMenu').innerHTML = ""
            
            var index = 0 
            for(var i in Menus.vMenu.MenuItems){index = i}
            Menus.vMenu.MenuItems[index].innerHTML = '<td nowrap style="WIDTH: 10%; text-align:center; vertical-align:middle;border:1px white solid !Important;background-color:#739AC6 !Important" ><span><img src="/fw/image/transferencia/spinner24x24_azul.gif"/></span></td>'
            vMenu.MostrarMenu()
                              
            $("divCuerpo").innerHTML = ""
            $('divBotones').innerHTML = ""
            
            $('divBotones').hide()
            $('divComentario').hide()
            $('divCkeditor').hide()
            $('trComTipo').hide()
            $('tbComentarioTitulo').hide()
            //window_onresize()
            pool_control_ejecucion()
            id_interval = 1 //window.setTimeout('pool_control_ejecucion()',1000)
          //  console.warn("Intervalo 1")
            } 
        
          }
        else
          {
          try{nvFW.bloqueo_desactivar($$('body')[0], "divTransfVidrio")}catch(e2){}
          err.alert()

          }
        }
      catch(e)  
        {
        var err = new tError()
        err.numError = 1045
        err.titulo = "Error al intentar iniciar la transferencia."
        err.comentario = "Error desconocido"  
        try{nvFW.bloqueo_desactivar($$('body')[0], "divTransfVidrio")}catch(e2){} 
        err.alert()
        }
  }
    
 function ver_pool_avanzado()
  {
   
   if (!nvFW.tienePermiso("permisos_transferencia_seguimiento", 2))
    {
     alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
     return
    }
   
   if($('tb' + id_transf_log + "_A") == null && $('tb' + id_transf_log) == null)
    return
   
   var buttom = ""
   if($('tb' + id_transf_log + "_A").style.display == 'none')
     {
      if($('tb' + id_transf_log) != null)
       $('tb' + id_transf_log).hide()
      
      $('tb' + id_transf_log + "_A").show()

      try{
          $('SpanDescVA').innerHTML = ""
          $('SpanDescVA').insert({top: "Vista Normal"})
         }
      catch(e){}
     } 
   else  
   {
       try {
              $('tb' + id_transf_log + "_A").hide()
      
              if($('tb' + id_transf_log) != null)
                $('tb' + id_transf_log).show()
        
              if(tbVacia == 0)  
                $('tb' + id_transf_log + 'Titulo').hide()
    
                  $('SpanDescVA').innerHTML = ""
                  $('SpanDescVA').insert({top: "Vista Avanzada"})
          }
       catch(e){}
     } 
    
    window_onresize()
   
  }


 var win_seg
function mostrar_transf(id_transf_log) {

    win_seg = window.top.nvFW.createWindow({
                                          url: '/fw/transferencia/transf_seguimiento_pool_control_exec.aspx?id_transf_log=' + id_transf_log,
                                          minimizable: false,
                                          maximizable: true,
                                          draggable: true,
                                          width: 800,
                                          height: 350,
                                          resizable: true,
                                          destroyOnClose: true
                                       })

    win_seg.showCenter()
}

function mostrar_transf_return() {

}

        function pollLoad(rs) {

    //  console.log("---------------Cargar RS-----------------")

      while (!rs.eof()) {

          var id_transf_log_det = rs.getdata('id_transf_log_det')
          if (id_transf_log_det == undefined) {
              rs.movenext()
              continue;
          }

          obs = rs.getdata("obs") == null ? '' : rs.getdata("obs")

          var tranf_log_det = transf_log_dets[id_transf_log_det] = {}
          tranf_log_det['id_transf_log'] = rs.getdata('id_transf_log')
          tranf_log_det['id_transf_log_subproc'] = rs.getdata('id_transf_log_subproc')

          tranf_log_det['nombre'] = rs.getdata('nombre') == null ? '' : rs.getdata('nombre') //
          tranf_log_det['estado'] = rs.getdata('estado') == null ? '' : rs.getdata('estado') //
          tranf_log_det['estado_det'] = rs.getdata('estado_det') == null ? '' : rs.getdata('estado_det')
          tranf_log_det['fe_inicio'] = rs.getdata('fe_inicio')
          tranf_log_det['fe_fin'] = rs.getdata('fe_fin')
          tranf_log_det['id_transferencia'] = rs.getdata('id_transferencia') == null ? '' : rs.getdata('id_transferencia') //
          tranf_log_det['id_transf_log_det'] = rs.getdata('id_transf_log_det') == null ? '' : rs.getdata('id_transf_log_det') // 
          tranf_log_det['id_transf_det'] = rs.getdata('id_transf_det') == null ? '' : rs.getdata('id_transf_det')
          tranf_log_det['permiso_pendiente'] = rs.getdata('permiso_pendiente') == null ? '' : rs.getdata('permiso_pendiente')
          tranf_log_det['transferencia'] = rs.getdata('transferencia') == null ? '' : rs.getdata('transferencia')
          tranf_log_det['transf_tipo'] = rs.getdata('transf_tipo') == null ? '' : rs.getdata('transf_tipo') // 
          tranf_log_det['salida_tipo'] = rs.getdata('salida_tipo') == null ? '' : rs.getdata('salida_tipo') // 
          tranf_log_det['link'] = rs.getdata('link') == null ? '' : rs.getdata('link') // 
          tranf_log_det['script'] = rs.getdata('script') == null ? '' : rs.getdata('script') // 
          tranf_log_det['nombre_operador'] = rs.getdata('nombre_operador') == null ? '' : rs.getdata("nombre_operador")
          tranf_log_det['parametros_extra_xml'] = rs.getdata('parametros_extra_xml') == null ? '' : rs.getdata("parametros_extra_xml")

          tranf_log_det['error'] = new tError()
          tranf_log_det['error'].numError = rs.getdata('numError')
          tranf_log_det['error'].mensaje = rs.getdata('mensaje') == null ? '' : rs.getdata('mensaje') // 
          tranf_log_det['error'].comentario = rs.getdata('comentario') == null ? '' : rs.getdata('comentario') // 
          tranf_log_det['error'].debug_desc = rs.getdata('debug_desc') == null ? '' : rs.getdata('debug_desc') // 
          tranf_log_det['error'].debug_src = rs.getdata('debug_src') == null ? '' : rs.getdata('debug_src') // 

          tranf_log_det['fe_fin_det'] = rs.getdata('fe_fin_det')

          tranf_log_det['fe_fin_det_ant'] = transf_log_dets[id_transf_log_det - 1] != undefined ? transf_log_dets[id_transf_log_det - 1].fe_fin_det : null

          tranf_log_det['fe_comienzo'] = tranf_log_det['fe_fin_det']
          if (transf_log_dets[id_transf_log_det - 1] != undefined)
              tranf_log_det['fe_comienzo'] = transf_log_dets[id_transf_log_det - 1]['fe_comienzo']

          rs.movenext()
      }

  }

  function pollDrawBody() {

    $("divCuerpo").innerHTML = ''

   // console.log("---------------Ejecutar Body-----------------")


    var strHTML_cabe_A = '<div class="contenedor" style="width:100%" id="div' + id_transf_log + '_A">'
    var   strHTML_cabe = '<div class="contenedor" style="width:100%" id="div' + id_transf_log + '">'

    strHTML_cabe_A += '<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tb' + id_transf_log + '_A" style="display:none"><tr class="tbLabel" id="tb' + id_transf_log + '_ATitulo"><td style="width:30%" >Tarea</td><td style="width:10%">Estado</td><td>Link</td><td style="width:15%">Duración</td><td style="width:10%">LOG</td><td style="width:6%">Param</td></tr>'
    strHTML_cabe   += '<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tb' + id_transf_log + '" ><tr class="tbLabel" id="tb' + id_transf_log + 'Titulo"><td style="width:30%" >Tarea</td><td style="width:15%">Estado</td><td>Link</td></tr>'

    var registros = {}
    registros.htmlA = ""
    registros.html = ""

        for (var tranf_log_det in transf_log_dets) {

                var det_log = transf_log_dets[tranf_log_det]

                var img_estado = ''
                var class_name = 'color:green;'
                var txtEstado = ''
                var link = ''
                var log = ''

              //  console.log("Nº id_intervalo:" + id_interval + " id_det_log: " + det_log.id_transf_log_det + '-' + det_log.transferencia + ' Estado ' + det_log.estado_det.toLowerCase())

                if (det_log.estado_det.toLowerCase() == 'pendiente') {
                    txtEstado = "Pendiente"
                    class_name = 'color:blue;'
                }

                if (det_log.estado_det.toLowerCase() == 'ejecutando') {
                    txtEstado = "Ejecutando - " + '<img style="text-align:center" src="/FW/image/icons/spinner24x24_azul.gif"></img>'
                    class_name = 'color:blue;'
                }

                if (det_log.estado_det.toLowerCase() == 'pendiente_ejecutado')
                    txtEstado = "Pendiente - Ejecutado "

                if (det_log.estado_det.toLowerCase() == 'terminado' && det_log.error.numError == 0)
                    txtEstado = "Terminado"

                if (det_log.error.numError != 0) {
                    href = "javascript:fn_mostrar_error(" + det_log.id_transf_log_det + ",\"" + nvFW.pageContents.filtroXML_verTransf_log_det + "\")"

                    if (det_log.transf_tipo == 'DTS' && det_log.error.numError != 0 && parseInt(det_log.error.debug_src) > 0)
                       href = "javascript:fn_DTS_log(\"" + det_log.error.debug_src + "\",\"" + nvFW.pageContents.filtroRm_DTSRun_res + "\")"

                    txtEstado = "<a style='color:red !Important' href='" + href + "'>Error</a>"
                    class_name = 'color:red !Important; '
                }

                if (det_log.estado_det.toLowerCase() == 'ejecucion_async') {
                    
                    href = "javascript:mostrar_transf(" + det_log.id_transf_log_subproc + ")"
                    txtEstado = "<a style='color:#D28757 !Important' href='" + href + "'>Ejecución Asincrona</a>"
                    class_name = 'color:#D28757;'

                }

                if (det_log.script != '' && det_log.script != null && script_run[det_log.id_transf_log_det] != true) {
                  
                   if (det_log.salida_tipo.toLowerCase() == "'adjunto'")
                    {
                        det_log.script = replace(det_log.script, "{getFile}", "/fw/files/file_get.aspx")
                        var script_browser = " window.open('" + det_log.script + ",'win_" + det_log.id_transf_log_det + "','')"
                       // console.log(script_browser)
                        det_log.script = script_browser
                    } 

                    script_run[det_log.id_transf_log_det] = true
                    eval(det_log.script)

                }

                if (det_log.link != '' && det_log.estado_det.toLowerCase() == "terminado") {
                    
                    var arDestinos = target_parse(det_log.link)
                    var ext
                    //var target
                    var content_disposition = 'attachment'
                    var path
                    
                    for (d = 0; d < arDestinos.length; d++)
                        if (arDestinos[d].protocolo.toLowerCase() == 'file' && det_log.error.numError == 0) {
                            
                            ext = arDestinos[d].comp_extension != "" ? arDestinos[d].comp_extension : arDestinos[d].extension
                            //target = ext.toUpperCase() == 'HTML' || ext.toUpperCase() == 'HTM' || ext.toUpperCase() == 'PDF' ? "target ='_blank'" : ""
                            path = arDestinos[d].target_comp != "" ? arDestinos[d].target_comp : "FILE://" + arDestinos[d].path
                            filename = arDestinos[d].comp_filename != "" ? arDestinos[d].comp_filename : arDestinos[d].filename

                            link += "<a title='" + filename + "' href='/fw/files/file_get.aspx?content_disposition=" + content_disposition + "&path=" + path + "'><img src='/FW/image/docs/" + ext + ".png' border='0' align='bottom'></img>&nbsp;" + filename + "</a>&nbsp;"
                        }


                }

                if (det_log.transf_tipo == 'DTS' && det_log.estado_det.toLowerCase() == "terminado" && det_log.error.numError == 0)
                    log = "&nbsp;<a href='javascript:fn_DTS_log(\"" + det_log.error.debug_src + "\",\"" + nvFW.pageContents.filtroRm_DTSRun_res + "\")'>log DTS</a>"


                if ((det_log.transf_tipo == 'INF' || det_log.transf_tipo == 'EXP') && det_log.salida_tipo == "'adjunto'")
                    link = 'Reporte Adjunto.'

                img_parametro = '&nbsp;'
                if ((registros.html == "" || det_log.transf_tipo != 'DTS' && det_log.transf_tipo != 'INF' && det_log.transf_tipo != 'EXP') && det_log.estado_det.toLowerCase() != 'ejecutando' && det_log.id_transf_log_det > 0)
                    img_parametro = "<img title='Parámetros' onclick='mostrar_transf_parametros(" + det_log.id_transf_log_det + ", \"" + "Valores de los Parámetros sobre la Tarea: " + det_log.transferencia + "\", " + nvFW.tienePermiso('permisos_transferencia_seguimiento', 3)  + ",\"" + nvFW.pageContents.filtroVertransf_log_param + "\")' style='cursor:pointer;cursor:hand' src='/FW/image/transferencia/variable.png'/>"

                //detalle tabla avanzada
                          <% 
        if nvApp.operador.tienePermiso("permisos_transferencia_seguimiento", 2) Then
            Response.Write("registros.htmlA += ""<tr id=\'trResA""+ det_log.id_transf_log_det +""\'><td style=\'width:30%;font-weight\'>"" + det_log.transferencia + ""</td><td style=\'width:10%;"" + class_name + ""\'>"" + txtEstado + ""</td><td>"" + link + ""</td><td style=\'width:15%;text-align:right\'>"" + getDuracion(det_log.fe_fin_det_ant, det_log.fe_fin_det) + ""</td><td style=\'width:10%\'>"" + log + ""</td><td style=\'width:6%;text-align:center\'>"" + img_parametro + ""</td></tr>""")
        End If
                          %>

                //if (det_log.transf_tipo.toUpperCase() != 'DTS' && det_log.transf_tipo.toUpperCase() != 'INF' && det_log.transf_tipo.toUpperCase() != 'EXP' && det_log.estado.toLowerCase() == 'ejecutando') {
                  //  registros.html = "<tr id='trRes" + det_log.id_transf_log_det + "'><td style='width:30%;font-weight:bold'>" + det_log.transferencia + "</td><td style='width:15%;" + class_name + "'>" + txtEstado + "</td><td></td></tr>"
                //}
                

            //detalle tablas usuario
            if (((det_log.transf_tipo.toUpperCase() == 'DTS' || det_log.transf_tipo.toUpperCase() == 'INF' || det_log.transf_tipo.toUpperCase() == 'EXP') && link != '') || (det_log.error.numError != 0) || (det_log.estado_det.toLowerCase() == 'ejecutando') || (det_log.transf_tipo.toUpperCase() == 'TRA' && det_log.id_transf_log_subproc > 0)) {// && det_log.transf_tipo.toUpperCase().indexOf("EXPINFDTS") >= 0 )) {
                    registros.html += "<tr id='trRes" + det_log.id_transf_log_det + "'><td style='width:30%;font-weight:bold'>" + det_log.transferencia + "</td><td style='width:15%;" + class_name + "'>" + txtEstado + "</td><td>" + link + "</td></tr>"
                    tbVacia = tbVacia + 1
                }
        }
      
        if (det_log == undefined)
            registros.html = "<div class='contenedor' style='width:100%' id='div" + id_transf_log + "'><table class='tb1' style='width:100%'><tr><td id='tdEspResp' style='width:100%' colspan='3'>Esperando respuesta&nbsp;&nbsp;<img style='text-align:center' src='/FW/image/transferencia/spinner24x24_azul.gif'></img></td></tr></table></div>"
        else {

              if (registros.html == "" && (det_log.estado.toLowerCase() == 'ejecutando' || det_log.estado.toLowerCase() == 'iniciando')) 
                registros.html += "<tr><td id='tdEspResp' style='width:100%' colspan='3'>Esperando respuesta&nbsp;&nbsp;<img style='text-align:center' src='/FW/image/transferencia/spinner24x24_azul.gif'></img></td></tr>"

              if (registros.html != "") {
                  registros.html = strHTML_cabe + registros.html + "</table></div>"
              }
              registros.htmlA = strHTML_cabe_A + registros.htmlA + "</table></div>"
            }

    $("divCuerpo").insert({ top: registros.html + registros.htmlA })
    $("divCuerpo").show()

 }

function pollfooter() {

    //console.log("---------------Ejecutar Pie-----------------")
    var det_log_ultimo = {}
    var existe_error = ""
    var existe_det_ejecutando = false

     for (tranf_log_det in transf_log_dets) { 
        det_log_ultimo = transf_log_dets[tranf_log_det]

        if (existe_error != 'error')
            existe_error = det_log_ultimo.estado.toLowerCase() 

        if (det_log_ultimo.estado_det.toLowerCase() == 'terminado' && det_log_ultimo.error.numError != 0)
             existe_error = 'error'

        if (det_log_ultimo.estado_det.toLowerCase() == 'ejecutando') {
                 existe_det_ejecutando = true
         }

     }

    if (det_log_ultimo.estado != undefined) {

         if (det_log_ultimo.estado.toLowerCase() == 'finalizado' || det_log_ultimo.estado.toLowerCase() == 'pendiente' || det_log_ultimo.estado.toLowerCase() == 'error') {
            // console.log(det_log_ultimo.estado.toLowerCase())

             
             if (existe_det_ejecutando ) {

               //  console.error("Finalizo con tarea ejecuntando, nº intervalo (" + id_interval + ")")

                 if (!id_interval)
                     pool_control_ejecucion()

                 return
             }
             
             id_interval = null

           //  var existe_error = det_log_ultimo.estado.toLowerCase()

             /* for(i in transf_log_dets)
                {
                 if(i != 'window')
                  if(transf_log_dets[i]['estado_det'].toLowerCase() == 'terminado' && transf_log_dets[i]['error'].numError != 0)
                    existe_error = 'error'
                }*/

             var strHTMLRes = getHTMLResultado({
                 id_transf_log: id_transf_log,
                 estado: det_log_ultimo.estado,
                 existe_error: existe_error,
                 permiso_pendiente: det_log_ultimo.permiso_pendiente,
                 duracion: getDuracion(det_log_ultimo.fe_comienzo, det_log_ultimo.fe_fin_det),
                 obs: obs
             })

             $('divBotones').innerHTML = ""
             $('divBotones').insert({ top: strHTMLRes })

             // $('divBotones').setStyle({height:'120px'})

             //Redibujar Menu
             redraw_menu(existe_error)

             if (tbVacia == 0)
                 try { $('tb' + id_transf_log + 'Titulo').hide() } catch (i) { }

             vButtonItems = new Array()
             if (det_log_ultimo.estado.toLowerCase() == 'pendiente' && det_log_ultimo.permiso_pendiente == 1) {
                 vButtonItems[0] = new Array();
                 vButtonItems[0]["nombre"] = "btnSiguiente";
                 vButtonItems[0]["etiqueta"] = "Continuar";
                 vButtonItems[0]["imagen"] = "procesar";
                 vButtonItems[0]["onclick"] = "ObtenerVentana('_SELF').location.href = '/fw/transferencia/transf_ejecutar.aspx?ej_mostrar=true&id_transferencia=" + id_transferencia + "&id_transf_log=" + id_transf_log + "&id_transf_det=" + det_log_ultimo.id_transf_det + "'";
             }

             var indexButton = vButtonItems.length
             vButtonItems[indexButton] = new Array()
             vButtonItems[indexButton]["nombre"] = "btnSalir";
             vButtonItems[indexButton]["etiqueta"] = "Salir";
             vButtonItems[indexButton]["imagen"] = "cerrar";
             vButtonItems[indexButton]["onclick"] = "window_cerrar()";

             var vListButtons = new tListButton(vButtonItems, 'vListButtons')
             //vListButtons.imagenes = Imagenes
             vListButtons.loadImage("procesar", '/fw/image/transferencia/procesar.png')
             vListButtons.loadImage("cerrar", '/fw/image/transferencia/salir.png')
             vListButtons.MostrarListButton()

             $('divBotones').show()

             comentario_cargar(id_transf_log)
             window_onresize()
             //comentario_colapsar()

             var oXML = new tXML();
             if (oXML.loadXML(tranf_log_det['parametros_extra_xml'])) {
                 objXML = oXML.xml
                 if (selectNodes('parametros_extra/parametro', objXML).length > 0) {
                     var nombre = selectSingleNode('parametros_extra/parametro/@nombre', objXML).value
                     var valor = selectSingleNode('parametros_extra/parametro', objXML).text
                     if (nombre == 'verComentarios' && valor == '1')
                         comentario_colapsar()
                 }
             }
         }
     }


 }


var cont       = 0 
var script_run = {}
var tbVacia    = 0
 function pool_control_ejecucion()
  {
     
     cont++
     try 
       {
        var rs = new tRS()
        rs.async = true
        rs.xml_format = 'rs_xml_json'
        rs.onError = function(rs)
                        { 
                         window.clearInterval(id_interval)
                         id_interval = null
                         setTimeout("DialogSuspend()", 6000)
                        }
        rs.onComplete = function(rs)
                       {
                       try
                       {
                           
                       try { nvFW.bloqueo_desactivar($$('body')[0], "divTransfVidrio") } catch (e2) { }

                           try { pollLoad(rs) } catch (e3) {
                       //       console.log("Error pollLoad:" + e3.message)
                           }
                           try { pollDrawBody() } catch (e4) {
                       //        console.log("Error pollDrawBody:" + e4.message)
                           }
                           try { pollfooter() } catch (e5) {
                       //        console.log("Error pollfooter:" + e5.message)
                           }

                           if (cont == 1)
                              window_onresize()

                           if (id_interval > 0) {
                               try { window.clearInterval(id_interval) } catch (a1) { }
                               id_interval = window.setTimeout('pool_control_ejecucion()', 1000) 
                             //  console.warn("Nuevo Intervalo: " + id_interval)
                           }

                       }
                       catch(e)   
                         {
                         //  console.log("Error:" + e.message)
                         }
                       }

         var filtroWhere = "<id_transf_log type='igual'>" + id_transf_log + "</id_transf_log>"
         filtroWhere += id_transf_det != '0' ? "<fe_fin_det type='mayor'>dbo.transf_get_fe_fin_det_log_ant(id_transf_log,"+ id_transf_det +")</fe_fin_det><estado_det type='distinto'>'pendiente_ejecutado'</estado_det>" : ""
         filtroWhere =  "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>" 
        rs.open(nvFW.pageContents.filtroBucleEjecucion, null, filtroWhere)
     }
     catch(e)
       {
         window.clearInterval(id_interval)
         id_interval = null
         setTimeout("DialogSuspend()",6000)
       }

}


function DialogSuspend() {

           Dialog.confirm("La ejecución fue suspendida.<br>¿Desea continuar?", {  width: 300,
                                                                             className: "alphacube",
                                                                             okLabel: "Si",
                                                                             cancelLabel: "No",
                                                                             onOk: function(w){
                                                                                                 id_interval = window.setTimeout('pool_control_ejecucion()', 1000) 
                                                                                                  w.close(); return
                                                                                               },
                                                                             onCancel: function(w) { window_cerrar(); return }
                                                              });


 }

  function redraw_menu(estado)
  {
   
      if(Menus["vMenu"])
        Menus["vMenu"] = null
      
      var items = 0
      DocumentMNG = new tDMOffLine;
      vMenu = new tMenu('divMenu', 'vMenu');
      Menus["vMenu"] = vMenu
      Menus["vMenu"].alineacion = 'centro';
      Menus["vMenu"].estilo = "A";
      //Menus["vMenu"].imagenes = Imagenes 
      Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='background-color: " + backgroundColorEstados(estado) + ";WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>comentario</icono><Desc>Comentario</Desc><Acciones><Ejecutar Tipo='script'><Codigo>comentario_colapsar()</Codigo></Ejecutar></Acciones></MenuItem>")
      items = 1

        if (estado != "") {
      <% 

        If (nvApp.operador.tienePermiso("permisos_transferencia", 1)) Then

            Response.Write("Menus[""vMenu""].CargarMenuItemXML(""<MenuItem id='1' style='background-color: "" + backgroundColorEstados(estado) + "" ;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" & Transf.id_transferencia.ToString & " - " & Transf.nombre & "</Desc><Acciones><Ejecutar Tipo='script'><Codigo>transf_editar(" & Transf.id_transferencia & ")</Codigo></Ejecutar></Acciones></MenuItem>"")" & vbCrLf)
            Response.Write("Menus[""vMenu""].CargarMenuItemXML(""<MenuItem id='2' style='background-color: "" + backgroundColorEstados(estado) + "" ;WIDTH:10%; text-align:center; vertical-align:middle '><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Vista Avanzada</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ver_pool_avanzado()</Codigo></Ejecutar></Acciones></MenuItem>"")" & vbCrLf)
            Response.Write("items = 3" & vbCrLf)

        Else
            Response.Write("Menus[""vMenu""].CargarMenuItemXML(""<MenuItem id='1' style='background-color: ""+ backgroundColorEstados(estado) + "";text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + Transf.id_transferencia.ToString & " - " & Transf.nombre & "</Desc></MenuItem>"")" & vbCrLf)
            Response.Write("items = 2" & vbCrLf)
        End If
      %>      
        }
        else {
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='" + items + "' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + Transf.id_transferencia.ToString + " - " + Transf.nombre + "</Desc></MenuItem>")
            items = items + 1
        }

      Menus["vMenu"].CargarMenuItemXML("<MenuItem id='" + items + "' style='background-color: " + backgroundColorEstados(estado) + ";WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + estado.toUpperCase() + "</Desc></MenuItem>")
      $('divMenu').innerHTML = ""
      vMenu.loadImage("nueva", "/fw/image/transferencia/nueva.png")
      vMenu.loadImage("buscar", "/fw/image/transferencia/buscar.png")
      vMenu.loadImage("comentario", "/fw/image/transferencia/comentario.png")
      vMenu.MostrarMenu()
        
      var contenedores = $('divMenu').querySelectorAll("span")
        for (var i = 0; i < contenedores.length; i++) {
            if (contenedores[i].innerHTML.indexOf("Vista Avanzada") >= 0)
               contenedores[i].id = "SpanDescVA"
        }
      
  }

  var glogalEjecutar  = false
  function window_onload()
   {
      //controla si no esta ejecutando la misma transferencia por el operador
       // en caso que los campos sean editable y requeridos y vengan asignados ya por metodo get
       // y el parametros ej_mostrar sea true es decir, que muestre el resultado por pantalla 
       // se ejecuta directamente 
       transf_control()
       window_onresize()
       
   }
       
 function transf_editar(id_transferencia)
 {
    if (!nvFW.tienePermiso("permisos_transferencia", 1))
    {
     alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
     return
    }

    window.open("/FW/transferencia/transferencia_ABM.aspx?id_transferencia=" + id_transferencia)
  }      
    
 function window_cerrar()
  {
   try
     {
     var win = nvFW.getMyWindow()
         win.close()
     }
   catch(e)  
     {
     if (window == window.top)
        window.close(true)
     }
     
     try
     { $$('BODY')[0].innerHTML = '' }
     catch (e) { }
  } 



</script>
    
    <%
        '/*******************************************************/
        '//Escribir los valores de los parametros a script
        '/*******************************************************/
        Dim strScript As String = Transf.toJSON()
        'strScript = strScript & vbCrLf & "debugger" & vbCrLf

        Response.Write("<script type='text/javascript'>" & strScript & ";</script>")
        Response.Write("<script type='text/javascript'> " + Transf.paramSCRIPT() + "</script>")

    %>

</head>

<body onload="window_onload()" onresize="window_onresize()" style="background-color:white; overflow:hidden; width:100%; height:100%"> 
  <form name="formTransfe" enctype="multipart/form-data" action="transf_ejecutar.aspx" method="post" style="overflow:hidden; width:100%; height:100%" target="hiddenIframe">
  
      <iframe name="hiddenIframe" id="hiddenIframe" onload="return hiddenIframe_event()" style='display: none'></iframe> 

        <input type="hidden" id="id_transferencia" name="id_transferencia" />
        <input type="hidden" id="xml_det_opcional" name="xml_det_opcional" />
        <input type="hidden" id="xml_comentario" name="xml_comentario" />
        <input type="hidden" id="xml_param" name="xml_param" ondblclick="return xml_param_ondblclick()" />
        <input type="hidden" id="pasada" name="pasada" />
        <input type="hidden" id="async" name="async"  value='false'/>
        <input type="hidden" id="id_transf_log" name="id_transf_log" />
        <input type="hidden" id="id_transf_det" name="id_transf_det" />
        <input type="hidden" id="ej_mostrar" name="ej_mostrar" />
   <div id="divMenu" style="width:100%;display:inline;overflow:hidden"></div>
   <script type="text/javascript"> 
      DocumentMNG = new tDMOffLine;
      vMenu = new tMenu('divMenu', 'vMenu');
      Menus["vMenu"] = vMenu
      Menus["vMenu"].alineacion = 'centro';
      Menus["vMenu"].estilo = 'A';
      //Menus["vMenu"].imagenes = Imagenes //Imagenes se declara en pvUtiles  
      Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>comentario</icono><Desc>Comentario</Desc><Acciones><Ejecutar Tipo='script'><Codigo>comentario_colapsar()</Codigo></Ejecutar></Acciones></MenuItem>")
      Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc><%= Transf.id_transferencia.ToString  %> - <%= Transf.nombre %></Desc><Acciones><Ejecutar Tipo='script'><Codigo>transf_editar('<%= Transf.id_transferencia.ToString  %>')</Codigo></Ejecutar></Acciones></MenuItem>")
      Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
      vMenu.loadImage("comentario", '/fw/image/transferencia/comentario.png')
      vMenu.MostrarMenu()
    </script>
<%
'/****************************************************************************************/
'//tiene_requeridos_pendientes indica que requiere intervencion de usuario
'//Sino se ejecuta la transferencia
'/****************************************************************************************/

%>
   <div id="divCuCO" style="width:100%;overflow:auto">
   <div id="divCuerpo" style="width:100%;vertical-align:top;overflow:hidden">
   <div class="contenedor" style="width: 100%;height:auto;display:none;overflow:hidden" id="divParams">
   <table class='tb1' style="width: 100%">
        <tr class='tblabel0'>
            <td colspan="2"><b>Parámetros</b></td>                
        </tr>
<%
    '/***************************************************************************/
    '//           PARAMETROS EDITABLES
    '/***************************************************************************/

    'function get_html_param(id_param)
    ' {
    '  var rs = DBExecute("select top 1 * from parametros_value where id_param = '" + id_param + "'")
    '  valor = rs.fields('valor').value == null ? '' : rs.fields('valor').value

    '    var strHTML = '<table id="id_param_tb' + id_param + '" class="tb1" cellspacing="0" cellpadding="0" style="width: 100%" border="0"><tr>'
    '      strHTML +=  "<td style='width: 100%'><input type='text' id='" + id_param + "' readonly='true' value='" + valor + "' "
    '      strHTML += "/></td>"
    '    strHTML += "</tr></table>"
    '    Return strHTML
    ' }

    'dim parametro As String
    'Dim valor_defecto_editable As String
    Dim setear_valores As String = ""
    Dim disabled As String = ""
    Dim calendario As String = ""
    Dim oParametro As trsParam
    For Each parametro In Transf.param.Keys
        oParametro = Transf.param(parametro)
        If oParametro("editable") Or oParametro("visible") Then
            disabled = IIf(Not oParametro("editable"), "disabled='disabled'", "")
            Dim asterisco As String = IIf(oParametro("requerido"), "(*)", "")

            Response.Write("<tr><td nowrap='true'><b>" + asterisco + oParametro("etiqueta"))

            If oParametro("tipo_dato").toUpper() = "FILE" Then Response.Write(" (" + oParametro("file_filtro") + ")")

            Response.Write(":</b></td><td style='width: 100%'>")

            Dim Input As String = ""
            Dim attrib As String = ""
            calendario = ""
            Select Case oParametro("tipo_dato").toUpper()
                Case "INT"
                    Input = "type = 'text'  onkeypress='return valDigito(event)' style='width: 100px; text-align: right'"

                Case "MONEY"
                    Input = "  onkeypress='return valDigito(event, ""."")' onchange='return validarNumero(event,""0.00"")' style='width: 100px; text-align: right'"

                Case "DATETIME"

                    calendario = "<div style='width:110px'><script type='text/javascript'> campos_defs.add(" & "'" & parametro & "'" & ", {enDB: false, nro_campo_tipo: 103, width:'100px' }) " & "</script></div>"

                Case "FILE"
                    Input = " type = 'file' "
                    attrib = " style='width:100%' "
                    Try
                        If Not Transf.transf_det_pendiente.param(parametro) Is Nothing Then
                            attrib += " onchange='return _$filename_" & parametro & "_onchange()' "
                        End If
                    Catch ex As Exception
                    End Try
                    Input += attrib

                Case "BIT"
                    Input = "type = 'checkbox'"

                Case Else
                    Input = "type = 'text' style='width: 100%'"
            End Select

            If oParametro("campo_def") = "" And calendario = "" Then
                Response.Write("<input " & Input & " id='" & parametro & "' name='" & parametro & "' " & disabled & " value=''/>")
                If oParametro("tipo_dato").ToUpper() = "FILE" Then

                    Dim link As String = ""
                    Response.Write("<div id='_$filename_" & parametro & "' style='display:inline'></div>")

                    Try
                        If Not Transf.transf_det_pendiente.param(parametro)("valor") Is Nothing Then
                            Response.Write("<script type='text/javascript'>$('" & parametro & "').setStyle({width: 90 + (Prototype.Browser.WebKit ? 44 : (Prototype.Browser.Gecko ? 3 : 0))})</script>")
                            link = IIf(Transf.transf_det_pendiente.param(parametro)("link") <> "", Transf.transf_det_pendiente.param(parametro)("link"), "")
                        End If

                        Response.Write("<script type='text/javascript'>$('_$filename_" & parametro & "').insert({top : ""&nbsp;&nbsp;" & Transf.transf_det_pendiente.param(parametro)("valor") & """ + """ & link & """ })</script>")
                    Catch ex As Exception
                    End Try

                    Dim linkEsvacio As Boolean = False
                    If link = "" Then linkEsvacio = True

                    Response.Write("<script type='text/javascript'>function _$filename_" & parametro & "_onchange(){if(true == " + linkEsvacio.ToString.ToLower + ") return;" & vbCrLf & " $('_$filename_" & parametro & "').innerHTML = '';$('_$filename_" & parametro & "').hide(); " & vbCrLf & " $('" & parametro & "').setStyle({width: '100%'}) }</script>")

                End If

            Else
                If oParametro("campo_def") <> "" Then
                    Response.Write(nvCampo_def.get_html_input(oParametro("campo_def")))
                    If oParametro("campo_def") <> parametro Then
                        Response.Write("<script type='text/javascript'>campos_defs.items['" & parametro & "'] = campos_defs.items['" & oParametro("campo_def") & "']</script>")
                    End If
                Else
                    Response.Write(calendario)
                End If


                If (disabled = "disabled='disabled'") Then
                    Response.Write("<script type='text/javascript'>campos_defs.habilitar('" & parametro & "',false)</script>")
                End If
            End If
            Response.Write("</td></tr>")

            '/*************************************/
            '//Setear Valor
            '/*************************************/

            Dim valor_script As String = "''"
            If pasada = 0 And oParametro("valor_defecto_editable") <> "" And oParametro("valor") Is Nothing Then
                valor_script = nvConvertUtiles.objectToScriptString(oParametro("valor_defecto_editable"), "es-AR")
            Else
                valor_script = nvConvertUtiles.objectToScriptString(oParametro("valor"), "es-AR")
            End If

            If valor_script = "" Then valor_script = "''"


            If Not oParametro("valor") Is Nothing Or valor_script <> "''" Then
                If oParametro("tipo_dato").toUpper() = "BIT" Then
                    setear_valores += "$(""" & parametro & """).checked = " & valor_script & " " & vbCrLf  'oParametro("valor").ToString.ToLower
                Else
                    If oParametro("campo_def") = "" Then
                        setear_valores += "$(""" & parametro & """).value = " & valor_script & " " & vbCrLf
                    Else

                        setear_valores += "campos_defs.set_value('" & oParametro("campo_def") & "', " & valor_script & ")" & vbCrLf
                        If disabled <> "" Then
                            setear_valores += "campos_defs.habilitar('" & oParametro("campo_def") & "', false)" & vbCrLf
                        End If
                    End If
                End If
            End If
        End If
    Next

    Response.Write("<script type='text/javascript'>" & vbCrLf & setear_valores & "</script>")
        %>
    </table>
    </div>
   <%
       '/***************************************************************************/
       '//           EJECUCIÓN OPCIONAL
       '/***************************************************************************/
       if Transf.tiene_opcionales Then

     %>
   <div class="contenedor" style="width: 100%;height:auto;display:none;overflow:hidden" id="divOpcions">
     <table class='tb1' style="width: 100%">
        <tr class='tblabel0'>
            <td colspan="2"><b>Ejecución Opcional</b></td>
        </tr>
     <%
         Dim checked As String
         For Each id_transf_det In Transf.dets.Keys
             If Transf.dets(id_transf_det).opcional And Transf.dets(id_transf_det).habilitado Then
                 checked = IIf(Transf.dets(id_transf_det).opcional_value, "checked='true'", "")
                 Response.Write("<tr id='trOpcion" & id_transf_det & "'><td><input type = 'checkbox' style='border:0px' id='det_opcional" & id_transf_det & "' name='det_opcional" & id_transf_det & "' " + checked + " /></td><td style='width: 100%'><b>" & Transf.dets(id_transf_det).transf_det & "</b></td></tr>")
             End If
         Next
     %>   
     </table>   
     </div>
   <%
    End If

   %>
   </div>
   <div id="divComentario" style="width: 100%;display:none;overflow:hidden;text-align:center">
     <div class="contenedor" style="display:none;" id="div_nro_com_id_tipo"></div>
     <table class='tb1 contenedor' id="tbComentarioTitulo" style="width:100%;display:none"><tr class="tbLabel0"><td colspan="3"><b>Registro de Comentarios</b></td></tr></table>
     <table class='tb1' style="width: 100%">
       <tr class="contenedor" id="trComTipo">
          <td style="width:100%;vertical-align:top">
            <table style="width:100%">
                  <tr>
                      <td style="width:10%;white-space:nowrap" class="Tit1">Tipo Comentario:</td>
                      <td id="td_nro_com_tipo" style="width:90%" >
                      <script type="text/javascript">
                          <%

                          Dim nro_com_id_tipo As String ' = 3 getParametroValor("nro_com_id_tipo")
                          Dim rsIdcomTipo As ADODB.Recordset = nvDBUtiles.DBExecute("select nro_com_id_tipo from com_id_tipo where com_id_tipo like '%BPM%'")
                          nro_com_id_tipo = rsIdcomTipo.Fields("nro_com_id_tipo").Value
                          nvDBUtiles.DBCloseRecordset(rsIdcomTipo)

                          Dim filtroVerCom_id_tipo_tipos As String = "<criterio><select vista='verCom_id_tipo_tipos'><campos>nro_com_tipo as id, com_tipo as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>"
                          Dim filtroComTipo = Replace(filtroVerCom_id_tipo_tipos, "<filtro></filtro>", "<filtro><nro_com_id_tipo type='igual'>" & nro_com_id_tipo & "</nro_com_id_tipo></filtro>")
                          filtroVerCom_id_tipo_tipos = nvXMLSQL.encXMLSQL(filtroVerCom_id_tipo_tipos)
                          filtroComTipo = nvXMLSQL.encXMLSQL(filtroComTipo)

                          Response.Write("var nro_com_id_tipo=" & nro_com_id_tipo & vbCrLf)
                          Response.Write("campos_defs.add('nro_com_id_tipo', { nro_campo_tipo: 101, enDB: false, target: 'div_nro_com_id_tipo' })" & vbCrLf)
                          Response.Write("campos_defs.set_value('nro_com_id_tipo', nro_com_id_tipo)" & vbCrLf)
                          Response.Write("campos_defs.add('nro_com_tipo', { nro_campo_tipo: 1, target: 'td_nro_com_tipo', enDB: false, depende_de: 'nro_com_id_tipo', depende_de_campo: 'nro_com_id_tipo', filtroXML: '" & filtroVerCom_id_tipo_tipos & "', filtroWhere: '<nro_com_tipo type=""igual"">%campo_value%</nro_com_tipo>'})" & vbCrLf)

                          %>
                          var rs = new tRS()
                          rs.open("<%= filtroComTipo %>") //,"","","","")
                          if (!rs.eof())
                              campos_defs.set_value('nro_com_tipo', rs.getdata("id"))
                          else
                           {
                              Dialog.alert("No existe definición al módulo de comentario.</br>Imposible continuar", {className: "alphacube", width:300, height:150, okLabel: "cerrar"
                                                                                                                  ,onClose:function(){
                                                                                                                   window_cerrar()
                                                                                                                  }
                              });
                           } 
                      </script>
                      </td>
                 </tr>
             </table>
          </td>  
       </tr>
       <tr>
          <td colspan="3">
            <div id="divCuerpoComentario">
            <iframe name="frame_comentario" id="frame_comentario" style="width: 100%;height:100%;"></iframe>
            <div id="divCkeditor" style="width:100%;height:100%;">
            <textarea name="comentario" id="comentario" style="width: 100%;height:100%;"></textarea>
            <script type="text/javascript">
                // Nueva implementacion con CKEditor
                CKEDITOR.config.toolbar = 'Comentarios'
                CKEDITOR.config.resize_enabled = false;
                CKEDITOR.config.removePlugins = 'elementspath';
                CKEDITOR.replace('comentario', {height:"100%"});
            </script>
            </div>
            </div>
          </td>
      </tr> 
   </table>
  </div>
   </div>
   <div id="divBotones" style="width: 100%;overflow:hidden;text-align:center;vertical-align:bottom">
   <table style="width: 100%">
     <tr>
        <td style="text-align:center;vertical-align:middle !Important;width:10%" >
              <table style="width:100%">
                <tr> 
                 <td style="width:25%">&nbsp;</td>
                 <td style="width:20%;text-align:center"><div style="width: 150px; margin:auto; display:none" id="divbtnEjecutar"></div></td>
                 <td style="width:10%">&nbsp;</td>
                 <td style="width:20%;text-align:center"><div style="width: 150px; margin:auto; display:none" id="divbtnSalir"></div></td>
                 <td style="width:25%">&nbsp;</td>
                </tr>
              </table>
        
        <script type="text/javascript">

            var vButtonItems = new Array()

            vButtonItems[0] = new Array();
            vButtonItems[0]["nombre"] = "btnEjecutar";
            vButtonItems[0]["etiqueta"] = "Ejecutar";
            vButtonItems[0]["imagen"] = "procesar";
            vButtonItems[0]["onclick"] = "transf_ejecutar()";

            vButtonItems[1] = new Array();
            vButtonItems[1]["nombre"] = "btnSalir";
            vButtonItems[1]["etiqueta"] = "Salir";
            vButtonItems[1]["imagen"] = "cerrar";
            vButtonItems[1]["onclick"] = "window_cerrar()";
            
            var vListButtons = new tListButton(vButtonItems, 'vListButtons')
            //vListButtons.imagenes = Imagenes
            vListButtons.loadImage("procesar", '/fw/image/transferencia/procesar.png')
            vListButtons.loadImage("cerrar", '/fw/image/transferencia/salir.png')
            vListButtons.MostrarListButton()
                
        </script>
      </td>
     </tr>
    </table>
   </div>
   <!--<div id="divTransfVidrio" style="width: 100%;display:none"></div>-->
   </form>
   </body>
</html>




