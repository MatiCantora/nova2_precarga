<script runat="server" language="javascript" src="/fw/Transferencia/script/transf_destino_utiles.js"></script>

<%
function exportarDestino()
{
/*********************************************************************/
//DEVOLVER EL RESULTADO
//Parametros
//  salida_tipo = ['estado'|'adjunto'] = identifica que info se escribe en el flujo de salida.
//  target = definición de destinos separados por ";" 
//Los datos pueden estar en tres contenedores.
//   1) variable BinaryData
//   2) Archivo que se encuentra en el "path_temp"
//   3) variable string "a"
/*********************************************************************/
try      
  {
  
  rptError = new tError();
  rptError.salida_tipo = salida_tipo
  var path_destino = ''
  var xls_save_as 
  
  /*********************************************************/
  //Analizar salida
  /*********************************************************/
  //target = "file://directorio_archivos/prueba1.pdf; file://directorio_archivos/prueba2.pdf"
  //target = target + ';mailto://jmolivera@redmutual.com.ar?to=jmolivera@redmutual.com.ar&cc=hbosch@redmutual.com.ar&subject=prueba attach&body=No se que escribir&attch=c:\\Informe_AMUS.xls'
  try
    {
    var fso = Server.CreateObject("Scripting.FileSystemObject")
    var destinos = target_parse(target)
    for (i in destinos)
      {
      var protocolo = destinos[i]['protocolo']
      switch (protocolo.toUpperCase()) 
        {
        case "FILE": //Copia el archivo resultado al destino
        
           path_destino =  get_file_path(destinos[i]['target'])
           xls_save_as = destinos[i]['xls_save_as']
           fso_create_folder(path_destino)
             
          if ( ((destinos[i].extencion == 'xls' || destinos[i].extencion == 'xlsx') || (xls_save_as && destinos[i].extencion != 'xls' && destinos[i].extencion != 'xlsx')) && (!fso.FileExists(path_temp) && path_temp == undefined) ) 
           {
             
            if(path_temp == undefined)
              {
                 var path_tmp_i = 0

                 fso_create_folder(Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\transferencia\\reportViewer\\tmp\\tmp_exp" + Session.SessionID + "_" +  path_tmp_i + ".xls")

                 path_temp  = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\transferencia\\reportViewer\\tmp\\tmp_exp" + Session.SessionID + "_" +  path_tmp_i + ".xls"
                 while (fso.FileExists(path_temp))
                  {
                   path_tmp_i++
                   path_temp = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\transferencia\\reportViewer\\tmp\\tmp_exp" + Session.SessionID + "_" + path_tmp_i + ".xls"
                  }
              }

            if (BinaryData != undefined)
              {
              //Pasar BinaryData a path_temp
              var mStream = Server.CreateObject("ADODB.Stream")
              mStream.Mode = 3 //adModeReadWrite
              mStream.Type = 1
              mStream.Open()
              mStream.Write(BinaryData)
              mStream.SaveToFile(path_temp, 2)
              mStream.Close()
              BinaryData = undefinned
              }
            else
              {
              //Pasar TextData a path_temp
              var arch = fso.CreateTextFile(path_temp, true)
              arch.write(TextData)
              arch.close()
              TextData = undefined
              }

          }

           //Datos binarios 
          if (BinaryData != undefined)
             {
              var mStream = Server.CreateObject("ADODB.Stream")
              mStream.Mode = 3 //adModeReadWrite
              mStream.Type = 1
              mStream.Open()
              mStream.Write(BinaryData)
              mStream.SaveToFile(path_destino, 2)
              mStream.Close()
             }
          
          if (TextData != undefined)
             {  
             var arch = fso.CreateTextFile(path_destino, true)
             arch.write(TextData)
             arch.close()
             }
           

          if (fso.FileExists(path_temp))
            {
             res = null
             if(xls_save_as)     
               res = convertir_a(xls_save_as,path_temp)
              
             if(res)
               throw res
      
             if(fso.FileExists(path_destino) && (destinos[i].extencion == 'xls' || destinos[i].extencion == 'xlsx') && destinos[i].target_agregar == 'true')
              res = exReemplazarHojas(path_temp,path_destino)
             else
               fso.CopyFile(path_temp, path_destino, true)
             
             if(res)
               throw res
            }

           break
        case "MAILTO" :
        
           var mailto = destinos[i]
           
           if (path_destino == '' || destinos[i]['attch'] != '' )
             {
             
              if(destinos[i]['attch'])         
                path_destino = get_file_path(destinos[i]['attch'])
    
             if(path_destino == '')
              path_destino = path_temp
             
             if (!fso.FileExists(path_destino))
               {  
               if (BinaryData != undefined)
                 {
                 var mStream = Server.CreateObject("ADODB.Stream")
                 mStream.Mode = 3 //adModeReadWrite
                 mStream.Type = 1
                 mStream.Open()
                 mStream.Write(BinaryData)
                 mStream.SaveToFile(path_destino, 2)
                 mStream.Close()
                 }
               if (TextData != undefined)
                 {  
                 var arch = fso.CreateTextFile(path_destino, true)
                 arch.write(TextData)
                 arch.close()
                 }   
               }
             } 
            
           mailto["attch"] = path_destino //replace(path_destino,set_file_raiz(), '\\\\' + Request.ServerVariables("LOCAL_ADDR").Item + '\\')
           
           sql_mail_send(mailto["to"], mailto["cc"], mailto["bcc"], mailto["subject"], mailto["body"],  mailto["attch"],mailto["from"])
           
           break
        default :
           break
        } 
      }
    }
  catch(e)  
    {
    rptError.cargar_msj_error(12007)
    rptError.error_script(e)
    return rptError.mostrar_error()
    }

  if (salida_tipo.toLowerCase() == "adjunto")
    { 
     Response.ContentType = ContentType  
 
     try { if(filename == undefined) filename = ''} catch(e){filename = ''}  
     try { if(content_disposition == undefined) content_disposition = 'attachment'} catch(e){content_disposition = 'attachment'}  

     if (path_destino != '' || filename != '')
     {
      if(filename != '')
        path_destino = filename
        
      Response.AddHeader("Content-Disposition", content_disposition + "; filename=" + path_destino)
     } 
    
    if (BinaryData == undefined && fso.FileExists(path_temp))
      {
      var mStream = Server.CreateObject("ADODB.Stream")
      mStream.Mode = 3 //adModeReadWrite
      mStream.Type = 1
      mStream.Open()
      mStream.LoadFromFile(path_temp)
      BinaryData = mStream.Read()
      mStream.Close()
      }
    if (BinaryData != undefined) 
     {
      Response.BinaryWrite(BinaryData)
      Response.Flush()
      BinaryData = null
     } 
    else
      { 
      Response.CharSet = "ISO-8859-1"
      Response.Write(TextData)
      Response.Flush()
      TextData = null
      }
    }

  
  //Eliminar archivo temporal
  try{
      if (fso.FileExists(path_temp))
         fso.DeleteFile(path_temp, true)
     }
  catch(e){}
  
  if (salida_tipo.toLowerCase() == "estado")
    {
    rptError.numError = 0
    return rptError.response() 
    }
  
  if (salida_tipo.toLowerCase() == "return")
    {
    rptError.numError = 0
    return rptError
    }  
  
  }
catch(e)
  {
  rptError.cargar_msj_error(11004)
  rptError.error_script(e)
  return rptError.mostrar_error() 
  }  
}
%>