<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")      'M:'Modo Actualización'  
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("xml", "")
    
    If modo.ToUpper() <> "" Then
        Dim Err As tError = New tError()
        Try
            Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand("localidad_ABM", ADODB.CommandTypeEnum.adCmdStoredProc, nvFW.nvDBUtiles.emunDBType.db_app, , , , , )
            Cmd.addParameter("@strXML", 201, 1, , strXML)
            
            Dim rs = Cmd.Execute()

            Err.numError = 0
            Err.mensaje = ""
            
        Catch ex As Exception
            Err.parse_error_script(ex)
        End Try
        Err.response()
    End If
    
    Me.contents("filtro_cargarLocalidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='localidad'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    
 %>
<html>
<head>
    <title>Localidad ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>    
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    
     <% = Me.getHeadInit()%>
    <script type="text/javascript">
        
        function window_onload()
        {
            campos_defs.items['postal_real']['onchange']=localidad_cargar
            localidad_cargar()
        }

        function localidad_cargar()
        {
            var filtroXML=nvFW.pageContents.filtro_cargarLocalidad
            var filtroWhere=campos_defs.filtroWhere('postal_real')
            if(filtroWhere!='') {
                var rs=new tRS();
                rs.open(filtroXML,'',filtroWhere)
                if(!rs.eof()) {
                    $('postal').value=rs.getdata('postal')
                     campos_defs.set_value('postal_real_txt',rs.getdata('postal_real'))
                     campos_defs.set_value('localidad',rs.getdata('localidad'))
                     campos_defs.set_value('car_tel',rs.getdata('car_tel'))
                    campos_defs.set_value('cod_prov',rs.getdata('cod_prov'))
                    campos_defs.set_value('cod_depar',rs.getdata('cod_depar'))
                }
                rs.close
            }
        }


        function Guardar()
        {
            //validar
            var strError=''
            if($('postal').value=='')
                $('postal').value=0

            if(campos_defs.get_value('postal_real_txt') =='')
                strError+="Ingrese el código postal.<br>"

            if(campos_defs.get_value('localidad') =='')
                strError+="Ingrese El nombre de la localidad.<br>"

            if(campos_defs.get_value('car_tel') =='')
                strError+="Ingrese el prefijo telefonico.<br>"

            if(campos_defs.get_value('cod_prov') =='')
                strError+="Ingrese la provincia. "

            if(campos_defs.get_value('cod_depar') =='')
                strError+="Ingrese el departamento."

            if(strError=='') {
                var xmldato="<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato+="<localidad postal='"+$('postal').value+"' postal_real='"+campos_defs.get_value('postal_real_txt')+"' localidad='"+campos_defs.get_value('localidad')+"' caract='"+campos_defs.get_value('car_tel')+"' cod_prov='"+campos_defs.value('cod_prov')+"' cod_depar='"+campos_defs.value('cod_depar')+"'></localidad>"
                
                nvFW_error_ajax_request('/FW/funciones/localidad_abm.aspx',{ parameters: { modo: 'M',xml: xmldato },
                    onSuccess: function(err,transport)
                    {
                        var postal_real=err.params['postal_real']
                        var localidad=err.params['localidad']
                        var params=new Array()
                        params['postal_real']=postal_real
                        params['localidad']=localidad
                        var win=nvFW.getMyWindow()
                        win.options.userData={ params: params }
                        win.close()
                    }
                });
            }
            else {
                alert(strError)
                return
            } // error en algun campo
        }

        function Limpiar()
        {
            campos_defs.clear()
        }

        function localidad_nueva()
        {
            Limpiar()
            $('postal').value=0
        }


    </script>
</head>
<body onload="window_onload()" style="overflow:hidden">
      <input type="hidden" name="postal" id="postal" />
      
      <div id="divMenuLoca" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
         var vMenuLoca = new tMenu('divMenuLoca','vMenuLoca');
         vMenuLoca.loadImage('nueva', '/FW/image/icons/nueva.png');
         vMenuLoca.loadImage('guardar', '/FW/image/icons/guardar.png');
         Menus["vMenuLoca"] = vMenuLoca
         Menus["vMenuLoca"].alineacion = 'centro';
         Menus["vMenuLoca"].estilo = 'A'; 
         Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Guardar()</Codigo></Ejecutar></Acciones></MenuItem>")           
         Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%; text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")  
         Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>localidad_nueva()</Codigo></Ejecutar></Acciones></MenuItem>")
        
         vMenuLoca.MostrarMenu()

        </script>
    <table class="tb1" width="100%">
         <tr>
            <td class="Tit1" style="width:120px">Buscar Localidad:</td>      
            <td colspan ="2"><%= nvFW.nvCampo_def.get_html_input("postal_real")%></td> 
         </tr> 
    </table>
    <table class="tb1" width="100%">
         <tr class="tbLabel">  
            <td style="width:20%">Cod. Postal</td> 
            <td style="width:60%">Localidad</td> 
            <td style="width:20%">Prefijo Tel.</td> 
         </tr>
         <tr>
            <td style="width:20%"><%= nvFW.nvCampo_def.get_html_input("postal_real_txt", enDB:=False, nro_campo_tipo:=100)%></td>            
            <td style="width:60%"><%= nvFW.nvCampo_def.get_html_input("localidad", enDB:=False, nro_campo_tipo:=104)%></td>
            <td style="width:20%"><%= nvFW.nvCampo_def.get_html_input("car_tel", enDB:= False , nro_campo_tipo:= 100)%></td>
         </tr>
    </table>
    <table class="tb1" width="100%">
        <tr class="tbLabel">
            <td style="width: 50%">Provincia</td>
            <td>Departamento</td>
        </tr>
        <tr>
            <td style="width: 50%"> <%= nvFW.nvCampo_def.get_html_input("cod_prov")%></td>
            <td><%= nvFW.nvCampo_def.get_html_input("cod_depar")%></td>
        </tr>
    </table>
</body>
</html>
