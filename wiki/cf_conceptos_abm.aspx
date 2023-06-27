<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim cf_id = nvFW.nvUtiles.obtenerValor("cf_id", "")
    Dim accion = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    
    Dim Err = New nvFW.tError()
    Try
        If (strXML <> "") Then
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("cf_conceptos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, , , strXML)
            cmd.addParameter("@accion", ADODB.DataTypeEnum.adLongVarChar, , , accion)
            Dim rs As ADODB.Recordset = cmd.Execute()
            Dim er As New nvFW.tError(rs)
            er.response()
        End If
    Catch e As Exception
    End Try
    
    
    Me.contents("cf_id") = cf_id
    Me.contents("filtroConcepto") = nvXMLSQL.encXMLSQL("<criterio><select vista='verCf_conceptos'><campos>*</campos><orden></orden></select></criterio>")

 %>
<html>
<head>
    <title>Conceptos financieros ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <%=Me.getHeadInit()%>
    <script type="text/javascript">    
        
        var cf_id, cf_tipo_id
        function window_onload() {
           cf_id =  nvFW.pageContents.cf_id
           if(cf_id != ""){
                cargar_concepto()
            }
        }

       function cargar_concepto(){
            var rs = new tRS()
            var filtroXML = nvFW.pageContents.filtroConcepto
            var filtroWhere = "<criterio><select><filtro><cf_id type='igual'>'" + cf_id + "'</cf_id></filtro></select></criterio>"
            rs.onComplete = function (rs){
                                $('id').value = rs.getdata("cf_id")
                                campos_defs.set_value("cf_concepto",rs.getdata("cf_concepto"))
                                campos_defs.set_value("cf_concepto_abrev", rs.getdata("cf_abrev"))
                                cf_tipo_id = rs.getdata("cf_tipo_id") 
                                $("cf_tipo").value = rs.getdata("cf_tipo") + " (" + rs.getdata("cf_tipo_id") + ")"
                            }   
            rs.open({filtroXML:filtroXML, filtroWhere:filtroWhere})
        }
   
       //METODO BOTON GUARDAR
        function guardar(){
            if(campos_defs.get_value("cf_concepto") == ''){
                nvFW.alert("Debe completar el concepto financiero.", {title: "Datos incompletos", okLabel: "Aceptar"})
                return
            }
            if(campos_defs.get_value("cf_concepto_abrev") == ''){
                nvFW.alert("Debe completar la abreviación del concepto financiero.", {title: "Datos incompletos", okLabel: "Aceptar"})
                return
            }
            if(cf_tipo_id == ""){
                nvFW.alert("Debe seleccionar un tipo de concepto financiero.", {title: "Datos incompletos", okLabel: "Aceptar"})
                return
            }
          
          var accion = cf_id == "" ? "A" : "M"  
          var strXML = "<cf_conceptos cf_id='"+ cf_id +"' cf_concepto='"+ campos_defs.get_value("cf_concepto") +"' cf_abrev='"+ campos_defs.get_value("cf_concepto_abrev") +"' cf_tipo_id='"+ cf_tipo_id +"'></cf_conceptos>"
           //guardarDatos y cerrar
           var er = nvFW.error_ajax_request("cf_conceptos_abm.aspx", 
                                                {parameters:{strXML:strXML, accion:accion }
                                                ,onSuccess: function(){
                                                                window.parent.buscar()
                                                                nvFW.getMyWindow().close()
                                                                } 
                                                ,error_alert: true  
                                             })
        }

        //METODO BOTON ELIMINAR
        function eliminar(){
            if(cf_id == ""){
                nvFW.alert("No existe ningun concepto financiero para eliminar.", {title: "Error", okLabel: "Aceptar"})
                return
            }

            nvFW.confirm("¿Está seguro que desea eliminar el concepto financiero: " + campos_defs.get_value("cf_concepto") + "?", 
                {
                    title: "Eliminar concepto financiero",
                    onOk: function ()
                    {   //eliminar
                    var strXML = "<cf_conceptos cf_id='"+ cf_id +"' cf_concepto='"+ campos_defs.get_value("cf_concepto") +"' cf_abrev='"+ campos_defs.get_value("cf_concepto_abrev") +"' cf_tipo_id='"+ cf_tipo_id +"'></cf_conceptos>"
                        var er = nvFW.error_ajax_request("cf_conceptos_abm.aspx", 
                                                {parameters:{strXML:strXML, accion:"B" }
                                                ,onSuccess: function(){
                                                                window.parent.buscar()
                                                                nvFW.getMyWindow().close()
                                                                } 
                                                ,error_alert: true  
                                              })
                    },
                    onCancel: function(){ return }
                })
        }

        
        //Abre el arbol de tipos de CF
        parent.winTipo = {}
        function abrir_arbol_tipo(){
            parent.winTipo = parent.nvFW.createWindow({
                url: "/wiki/cf_tipos_listar.aspx",
                title: "<b>Tipos de Conceptos Financieros</b>",
                width: 500,
                height: 400,
                destroyOnClose: true,
                minimizable: true,
                maximizable: true,
                onClose: function () {
                    cf_tipo_id = parent.tipo_id
                    if (parent.tipo_desc != null && parent.tipo_id != null)
                        $("cf_tipo").value = "" + parent.tipo_desc + " (" + parent.tipo_id + ")"
                }
            })

            parent.winTipo.showCenter(true)
        }

    </script>

</head>
<body onload="return window_onload()" style="height: 100%; vertical-align: middle; overflow: auto; background:#FFFFFF">
    <div id="divMenu" style="width:100%"></div>
     <script type="text/javascript">
        var vMenu = new tMenu('divMenu','vMenu');
        vMenu.loadImage("guardar","/FW/image/icons/guardar.png");
        vMenu.loadImage("eliminar","/FW/image/icons/eliminar.png");
        Menus["vMenu"]=vMenu
        Menus["vMenu"].alineacion='centro';
        Menus["vMenu"].estilo='A';
        
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>");
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>");
        vMenu.MostrarMenu();
    </script>
    <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 30%">ID:</td>
            <td><input id="id" disabled="disabled" /></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 30%">Concepto financiero:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("cf_concepto", enDB:=False, nro_campo_tipo:=104)%></td>
        </tr>
        <tr>
            <td class="Tit1">Concepto financiero abreviado:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("cf_concepto_abrev", enDB:=False, nro_campo_tipo:=104)%></td>
        </tr>
        <tr>
            <td class="tit1" style="width: 30%;">Tipo de concepto financiero:</td>
            <td style="width: 30%;">
                <input id="cf_tipo" type="text" value="" readonly="readonly" ondblclick="abrir_arbol_tipo()"/><img style="vertical-align:middle" src="../FW/image/icons/buscar.png" alt="" onclick="abrir_arbol_tipo()" title="Buscar tipo de concepto"/>
            </td>
        </tr>
    </table>
</body>
</html>
