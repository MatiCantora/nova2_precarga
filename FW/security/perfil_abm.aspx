<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err As New nvFW.tError()
    
    'debe tener el permiso correspondiente
    If Not op.tienePermiso("permisos_seguridad", 3) Then
        err.numError = -1
        err.titulo = "No se pudo completar la operaci�n. "
        err.mensaje = "No tiene permisos para ver la p�gina."
        err.response()
    End If

    Dim filtroOperador As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>rtrim(tipo_operador_desc) as tipo_operador_desc</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroBuscar As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo' PageSize='17' AbsolutePage='1' cacheControl='Session'><campos>*</campos><orden>tipo_operador_desc</orden><filtro></filtro></select></criterio>")
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim  get_tipo_operador As String = nvFW.nvUtiles.obtenerValor("get_tipo_operador", "0")
    Dim get_operador_desc As String = nvFW.nvUtiles.obtenerValor("get_operador_desc", "")
   
    
    If modo <> "" Then
        
        Dim tipo_operador As Integer = nvFW.nvUtiles.obtenerValor("tipo_operador", "")
        Dim tipo_operador_txt As String = nvFW.nvUtiles.obtenerValor("tipo_operador_txt", "")
        Dim tipo_operador_hereda As Integer
        If modo = "H" Then
            tipo_operador_hereda = tipo_operador
            tipo_operador = 0
        End If
       
        Try
             
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_perfil_ABM", ADODB.CommandTypeEnum.adCmdStoredProc)

            cmd.addParameter("@tipo_operador", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , tipo_operador)
            cmd.addParameter("@tipo_operador_desc", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, tipo_operador_txt.Length, tipo_operador_txt)
            cmd.addParameter("@tipo_operador_hereda", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , tipo_operador_hereda)

            Dim rs As ADODB.Recordset = cmd.Execute()
            
        Catch ex As Exception
            
            err.numError = -1
            err.mensaje = "Error inesperado"
            err.titulo = "Error al tratar de realizar la operaci�n"
            err.debug_desc = ex.Message
            err.debug_src = "FW_perfil_ABM"
            
        End Try
        
        err.response()
    End If

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Perfil ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript"  src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript"  src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript"  src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript"  src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>

    <script  type="text/javascript" >


    var alert = function(msg) { parent.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

    var vButtonItems = new Array();
    vButtonItems[0] = new Array();
    vButtonItems[0]["nombre"] = "Aceptar";
    vButtonItems[0]["etiqueta"] = "";
    vButtonItems[0]["imagen"] = "buscar";
    vButtonItems[0]["onclick"] = "return Buscar()";

    var filtroBuscar = '<%= filtroBuscar %>'
    var filtroOperador = '<%= filtroOperador %>'

    var vListButtons = new tListButton(vButtonItems, 'vListButtons')
    vListButtons.loadImage("buscar","/fw/image/icons/buscar.png")

    var win = nvFW.getMyWindow()

    function window_onload() {

        vListButtons.MostrarListButton()
        window_onresize()
        $('modo').value = 'M'
        $('tipo_operador_id').disabled = true

        campos_defs.items['tipo_operadores']['onchange'] = tipo_operador_onchange

        $('tipo_operador_id').value = '<% = get_tipo_operador%>'
        $('tipo_operador_desc').value = '<% = get_operador_desc%>'

        if ($('tipo_operador_id').value == 0)
            nuevo()
    }


    function Buscar() {
        if ($('modo').value == 'H')
            return
    
        var filtro = ""

        if ($('tipo_operador_desc').value != '')
            filtro += "<tipo_operador_desc type='like'>%" + $('tipo_operador_desc').value + "%</tipo_operador_desc>"

        nvFW.exportarReporte({
            filtroXML: filtroBuscar,
            path_xsl: 'report\\security\\verPerfiles\\HTML_perfil_seleccionar.xsl',
            filtroWhere: "<criterio><select /><filtro>" + filtro + "</filtro></criterio>", 
            formTarget: 'iframe_perfiles',
            nvFW_mantener_origen: true,
            bloq_contenedor: $('iframe_perfiles'),
            cls_contenedor: 'iframe_perfiles',
            id_exp_origen: 0
        });

    }


    function perfil_seleccionar(tipo_operador, tipo_operador_desc) {
    
        $('tipo_operador_id').value = tipo_operador
        $('tipo_operador_desc').value = tipo_operador_desc
        $('modo').value = 'M'

    }


    function tipo_operador_onchange() {
    
        $('observacion').innerHTML = ''
        $('tipo_operador_id').value = campos_defs.value('tipo_operadores')
        var rs = new tRS();
        var filtroW = campos_defs.filtroWhere('tipo_operadores')
        rs.open(filtroOperador, '', filtroW, '', '')
        {
           $('observacion').insert({ top: '<br/>* El nuevo perfil va tener los permisos heredados del perfil: <b>' + rs.getdata('tipo_operador_desc') + '</b>' })
        }   
    }

    var hereda = false
    function nuevo()  {
        $('tipo_operador_desc').value = ''
        $('modo').value = 'A'
        $('observacion').innerHTML = ''
        hereda = false

        nvFW.confirm("Desea heredar los permisos de otro perfil?",
                                     {
                                         width: 340,
                                         okLabel: "Aceptar",
                                         cancelLabel: "Cancelar",
                                         cancel: function(win)
                                         {
                                             $('tipo_operador_id').value = 0
                                             $('iframe_perfiles').src = ''
                                             win.close()
                                         },
                                         ok: function(win)
                                         {
                                             hereda = true
                                             $('modo').value = 'H'
                                             campos_defs.onclick(null, 'tipo_operadores')
                                             $('iframe_perfiles').src = ''
                                             win.close()
                                         }
                                     });
    }


    function validar(){
     var strError = ''
     if($('tipo_operador_desc').value == '')
         strError = "Ingrese la descripci�n del perfil"
   
     return strError  
    }


    function guardar(){
         strError = validar()
         if (strError != '')
          {
           alert(strError)
           return
          }
              
        nvFW.error_ajax_request('perfil_abm.aspx', {encoding: 'ISO-8859-1',
            parameters: { modo: $('modo').value, tipo_operador: $('tipo_operador_id').value, tipo_operador_txt: $('tipo_operador_desc').value },
                                            onSuccess: function(err, transport){          
                                                                            if (err.numError != 0 ) {
                                                                                alert(err.Mensaje)   }
                                                                            else {
                                                                                alert("Perfil Creado.")
                                                                                win.close() }
                                                                            }
                                           });
        }




    function strPerfil_onkeypress(e) {
        key = Prototype.Browser.IE ? event.keyCode : e.which
        if (key == 13)
            Buscar()
    }


    function perfil_onfocusout() {
        $('tipo_operador_id').value = $('tipo_operador_desc').value == '' ? 0 : $('tipo_operador_id').value

    }


    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            cab_height = $('tbFiltro').getHeight()
            //div_height = $('tbFiltro').getHeight()
        
            $('iframe_perfiles').setStyle({ 'height': body_height - cab_height - dif })
        }
        catch (e) { }
    }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style='width:100%;height:100%;overflow:hidden'>
<input type="hidden" id='modo' name="modo" />

  <div id="divMenu" style="margin: 0px;padding: 0px;"></div>
    <script type="text/javascript" language="javascript">

        var vMenu = new tMenu('divMenu', 'vMenu');
        vMenu.loadImage("guardar", "/fw/image/icons/guardar.png")
        vMenu.loadImage("nueva", "/fw/image/icons/nueva.png")
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.MostrarMenu()

    </script>        
    <table id="tbFiltro" class='tb1'>
        <tr class='tbLabel'>
           <td style='width:10%'>Nro</td>
           <td style='width:75%'>Perfil</td>
           <td  style="width: 20%; text-align:center" id='botton'></td>
        </tr>
        <tr>
            <td style='width:80px'><input type="text" id="tipo_operador_id" style="width:100%"/></td>
            <td><input style="width: 100%" name="tipo_operador_desc" id="tipo_operador_desc" onkeypress="return strPerfil_onkeypress(event)" onfocusout="return perfil_onfocusout()"/></td> 
            <td  style="width: 20%; text-align:center" id='boton'><div id="divAceptar"></div></td>
        </tr>
        <tr>
           <td style='width:100%' colspan='3' id="observacion"></td>
        </tr>
    </table>
    <div style="display:none">
        <%= nvFW.nvCampo_def.get_html_input(campo_def:="tipo_operadores")%>

    </div>
    <iframe name="iframe_perfiles" id="iframe_perfiles" style="width: 100%; height: 100%; overflow: auto;" frameborder="0" src=""></iframe>
</body>
</html>