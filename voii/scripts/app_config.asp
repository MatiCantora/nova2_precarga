<!--#include virtual="FW/scripts/nvSession.asp"-->
<!--#include virtual="FW/scripts/pvUtilesASP.asp"-->
<% 
try
    {
   
    var login = nvSession.getContents("login")
   
    //recuperar conexion de la aplicacion
    var rsCN = adminDBExecute("select * from verSistemas_servidores where cod_sistema = 'nv_voii' and servidor_alias = '" + nvSession.getContents("cfg_server_name") + "'")
    nvSession.setContents('app_cod_servidor', rsCN.fields('cod_servidor').value)
    //nvSession.setContents('connection_string', rsCN.fields('cn_string').value)
    //nvSession.setContents('directorio_archivos', rsCN.fields('directorio_archivos').value)
    //nvSession.setContents('ads_abm_credencial', rsCN.fields('ads_abm_credencial').value)
    DBCloseRecordset(rsCN)
    
    //Cargar conexiones y directorios del sistema
    nvApp_cargar_db_dir("nv_voii")
    
    var strSQL = "select * from verLogin_servidores where login like '" + login + "' and acceso_sistema = 1 and cod_sistema = 'nv_voii' order by acceso_orden"
    var rsAcceso = adminDBExecute(strSQL)
    var tiene_acceso = !rsAcceso.eof
    DBCloseRecordset(rsAcceso)
    
    if (tiene_acceso) 
      {
      /***********************************/
      // Comprobar fucnionamiento de la base default
      try
        {
        var ex = {}
        var cn = DBConectar("", ex)
        if (cn == null) 
          {
          var err = new tError()
          err.numError = 10
          err.titulo = "Error al iniciar la Aplicacion"
          err.comentario = "No se pudo acceder a la base por defecto"
          err.mensaje = ex.message
          err.response()
          }
        cn.Execute("Select 1")
        }
      catch(e2)
        {
        var err = new tError()
        err.numError = 10
        err.titulo = "Error al iniciar la Aplicacion"
        err.comentario = "No se pudo acceder a la base por defecto"
        err.mensaje = e2.message
        err.response()
        }
      /***********************************/

      /***********************************************************************/
      // Cargar información de operador
      /***********************************************************************/
      var rs = DBExecute("select * from verOperadores where login like '" + login + "'")
      
      if (rs.eof)
        {
        var err = new tError()
        err.numError = 12
        err.titulo = "Error al iniciar la Aplicacion"
        err.comentario = "El usuario no existe en la aplicación"
        err.mensaje = ""
        err.response()
        }

      var operador = new Array();
      operador['operador'] = rs.Fields('operador').value
      operador['nombre_operador'] = rs.Fields('nombre_operador').value
      operador['tipo_operador'] = rs.Fields('tipo_operador').value
      operador['tipo_operador_desc'] = rs.Fields('tipo_operador_desc').value
      operador['nro_entidad'] = rs.Fields('nro_entidad').value
      operador['sucursal'] = rs.Fields('sucursal').value
      DBCloseRecordset(rs);
    
      /***********************************************************************/
      // Cargar información de permisos
      // Estos permisos se utilizan para la gestion del front-end
      // Para el control ASP utilizar la funciones
      /***********************************************************************/
      operador['operador_permisos'] = new Array()
      strSQL = 'select * from verOperador_permiso_grupo'
      rs = DBExecute(strSQL)
      while (!rs.eof)
        {
        operador['operador_permisos'][rs.Fields('permiso_grupo').value] = rs.Fields('permiso').value
        rs.movenext
        }
      DBCloseRecordset(rs);
    
      //nvSession.setContents("AutLevel", 1) //Controla el acceso al sistema
      nvSession.setContents("operador", operador)  
      nvSession.setContents("app_cod_sistema", 'nv_voii');
      nvSession.setContents("app_sistema", 'Nova VOII');
      nvSession.setContents("app_path_rel", 'voii');
      
      app_config_return_error = obtenerValor('app_config_return_error', 'false')
      if (app_config_return_error == 'true')
        {
        var err = new tError()
        err.response()
        }
      }
    }
  catch(e)
    {
    app_config_return_error = obtenerValor('app_config_return_error', 'false')
    if (app_config_return_error == 'true')
      {
      var err = new tError()
      err.error_script(e)
      err.response()
      }
    else 
      Response.Redirect("../../errores_personalizados/error_gral.asp?titulo=Error de acceso&mensaje=" + escape(e.description)) 
    }
    
%>