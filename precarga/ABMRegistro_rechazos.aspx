<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    if modo = "" then
        modo = "VA"
    end if
    if modo.toUpper = "M" Then
        'Stop
        Dim err As New nvFW.tError
        Try
            Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_comentario_rechazo_cargar", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            Dim rs As ADODB.Recordset = cmd.Execute()

            'Dim numError As Integer = rs.Fields("numError").Value
            'Dim mensaje As String = rs.Fields("mensaje").Value
            Dim nro_credito As Integer = rs.Fields("nro_credito").Value
            err.params("nro_credito") = nro_credito
            err.mensaje = ""
            err.numError = 0

        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al cargar el comentario"
            err.comentario = ""
        End Try
        err.response()
    end if

    'if (modo.toUpperCase() == 'M') {

    '        var err = new tError()
    '       try {
    '          var strXML = ''
    '        var strXML = unescape(obtenerValor('strXML', ''))
    '
    '       var objXML = Server.CreateObject("Microsoft.XMLDOM");
    '        objXML.loadXML(strXML)
    '
    '       var Cmd = Server.CreateObject("ADODB.Command")
    '
    '       Cmd.ActiveConnection = conectar()
    '      Cmd.CommandType = 4
    '     Cmd.CommandTimeout = 1500
    '    Cmd.CommandText = 'rm_comentario_rechazo_cargar'

    '   var pstrXML = Cmd.CreateParameter('strXML', 201, 1, strXML.length, strXML)
    '  Cmd.Parameters.Append(pstrXML)

    '  var rs = Cmd.Execute()
    '  //err.numError = rs.Fields('numError').Value
    '  //err.titulo = rs.Fields('titulo').Value
    '  //err.mensaje = rs.Fields('mensaje').Value
    '  //err.comentario = rs.Fields('comentario').Value
    '  rs.close()

    '}
    ' catch (e) {
    '     err.error_script(e)
    ' }
    ' err.response()
    '}        

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="FW/image/icons/nv_login.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>

    <% = Me.getHeadInit()%>  
    
    <script type="text/javascript" language="javascript" class="table_window">
    
    var nro_docu
	var tipo_docu
	var sexo
    var nro_credito
    var fecha
	var operador
	var nro_operador
	
    var win = nvFW.getMyWindow()
    
    function window_onresize()
    {
     try
      {
       var dif = Prototype.Browser.IE ? 5 : 2
       var body_height = $$('body')[0].getHeight()
       var tbCabecera_height = $('tbCabecera').getHeight() 
       var divMenuComentarios_height = $('divMenuComentarios').getHeight() 
       
       $('frame_comentarios').setStyle({height: body_height - tbCabecera_height - divMenuComentarios_height - dif - 10 + 'px'})   
      }
     catch(e){}
    }

    function window_onload()
    {
       try{  
            var Parametros = win.options.userData.Parametros
            if (Parametros["nro_docu"])
            {
                nro_docu = Parametros["nro_docu"]
                tipo_docu = Parametros["tipo_docu"]
                sexo = Parametros["sexo"]
                nro_credito = Parametros["nro_credito"]
                fecha = Parametros["fecha"]
                operador = Parametros["operador"]
                nro_operador = Parametros["nro_operador"]
            }
        }
        catch (e){
                nro_credito = 0
        }
        /* establecemos la fecha, operador y nro_credito */
        hoy = new Date()
        $('fecha_comentario').innerHTML = FechaToSTR(hoy,1)
        $('nro_credito_comentario').innerHTML = nro_credito == 0 ? '-' : nro_credito
        $('operador_comentario').innerHTML = operador
    
        comentarios_rechazos_cargar()
        
        window_onresize();   
    }
    
    function comentarios_rechazos_cargar()
    {
        //Se muestran sólo los comentarios de rechazo
        var filtro = "<nro_com_grupo type='igual'>17</nro_com_grupo>"
        
        //Se muestran sólo los comentarios para los cuales el operador tiene permiso
        filtro += "<SQL type='sql'>dbo.rm_tiene_permiso('permisos_com_tipo',nro_permiso) = 1</SQL>"
        
        nvFW.exportarReporte({
        filtroXML: "<criterio><select vista='verCom_grupo_tipos'><campos>nro_com_tipo,com_tipo,nro_com_grupo,com_grupo,nro_permiso</campos><orden>nro_com_tipo</orden><filtro>" + filtro + "</filtro></select></criterio>",
                    path_xsl: 'report\\verRegistro\\verRegistro_comentarios_rechazos.xsl',
                    formTarget: 'frame_comentarios',
                    nvFW_mantener_origen: true,
                    bloq_contenedor: $('frame_comentarios'),
                    cls_contenedor: 'frame_comentarios',
                    parametros: "<parametros><nro_docu>"+nro_docu+"</nro_docu><tipo_docu>" + tipo_docu + "</tipo_docu><sexo>" + sexo + "</sexo><nro_credito>" + nro_credito + "</nro_credito><fecha>" + fecha + "</fecha><operador>" + operador + "</operador><nro_operador>" + nro_operador + "</nro_operador></parametros>"
         })      
    }
    
    

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <table class="tb1" id="tbCabecera">
       <tr class="tbLabel">
           <td style="width: 15%;">Fecha</td>
           <td style="width: 70%;">Operador</td>
           <td style="width: 15%;">Crédito</td>
       </tr>
       <tr>
            <td style="text-align:center"><span id="fecha_comentario"></span></td>
            <td><span id="operador_comentario"></span></td>
            <td style="text-align:center"><span id="nro_credito_comentario"></span></td>
       </tr>
   </table>
    <iframe name="frame_comentarios" id="frame_comentarios" src="/fw/enBlanco.htm" style="width: 100%; height: 100%; overflow: auto" frameborder="0"></iframe>
</body>


</html>