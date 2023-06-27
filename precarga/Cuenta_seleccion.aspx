<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%

    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", 0)
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("select nro_entidad,cuit,tipo_docu,nro_docu,sexo,isnull(id_cuenta,0) as id_cuenta,estado from vercreditos where nro_credito=" & CStr(nro_credito))
    Dim nro_entidad = rs.Fields("nro_entidad").Value
    Dim cuit = rs.Fields("cuit").Value
    Dim tipo_docu = rs.Fields("tipo_docu").Value
    Dim nro_docu = rs.Fields("nro_docu").Value
    Dim sexo = rs.Fields("sexo").Value
    Dim id_cuenta = rs.Fields("id_cuenta").Value
    Dim estado = rs.Fields("estado").Value


    ''Alta de CBU
    If modo = "C" Then
        Dim err = New tError
        Dim StrSQL As String = ""
        Dim mensajeError As String = ""
        ''estados que se permite cambiar cuenta bancaria
        Dim arr(4) As String
        arr(0) = "H"
        arr(1) = "P"
        arr(2) = "R"
        arr(3) = "X"
        arr(4) = "M"


        Dim index1 As Integer = Array.IndexOf(arr, estado)
        id_cuenta = nvFW.nvUtiles.obtenerValor("id_cuenta", "")
        If (index1 >= 0) Then
            Try
                StrSQL = "delete from Credito_cobro where nro_credito=" & CStr(nro_credito) & vbCrLf
                StrSQL &="insert into Credito_cobro(nro_docu,tipo_docu,sexo,nro_banco_cliente,nro_sucursal_cliente,tipo_cuenta,nro_cuenta,nro_credito,ID_cuenta)" & vbCrLf
                StrSQL &= "select p.nro_docu,p.tipo_docu,p.sexo,e.nro_banco,e.id_banco_sucursal,e.tipo_cuenta,e.nro_cuenta," & CStr(nro_credito) & " as nro_credito,e.id_cuenta_old from verEntidad_bco_ctas e join verpersonas p on e.nro_entidad=p.nro_entidad where id_cuenta=" & CStr(id_cuenta) & vbCrLf
                StrSQL &= "update credito set cobro = 2 where nro_credito = " & CStr(nro_credito) & vbCrLf
                StrSQL &= "update pago_registro_detalle set nro_pago_tipo = 1,dep_id_cuenta = " & CStr(id_cuenta) & " where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5)" & vbCrLf
                StrSQL &= "delete pago_parametros where nro_pago_detalle in (select nro_pago_detalle from pago_registro_detalle where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5))" & vbCrLf
                StrSQL &= "INSERT INTO [lausana].[dbo].[pago_parametros] ([nro_pago_detalle],[nro_pago_tipo],[pago_parametro],[pago_parametro_valor])" & vbCrLf
                StrSQL &= "select nro_pago_detalle,prd.nro_pago_tipo,'id_cuenta',cast(prd.dep_id_cuenta as varchar(50)) from pago_registro_detalle prd join entidad_ctas ec on prd.dep_id_cuenta = ec.id_cuenta where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5)" & vbCrLf
                StrSQL &= "INSERT INTO [lausana].[dbo].[pago_parametros] ([nro_pago_detalle],[nro_pago_tipo],[pago_parametro],[pago_parametro_valor])" & vbCrLf
                StrSQL &= "select nro_pago_detalle,prd.nro_pago_tipo,'nro_banco',cast(ec.nro_banco as varchar(50)) from pago_registro_detalle prd join entidad_ctas ec on prd.dep_id_cuenta = ec.id_cuenta where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5)" & vbCrLf
                StrSQL &= "INSERT INTO [lausana].[dbo].[pago_parametros] ([nro_pago_detalle],[nro_pago_tipo],[pago_parametro],[pago_parametro_valor])" & vbCrLf
                StrSQL &= "select nro_pago_detalle,prd.nro_pago_tipo,'nro_banco_sucursal',cast(ec.id_banco_sucursal as varchar(50)) from pago_registro_detalle prd join entidad_ctas ec on prd.dep_id_cuenta = ec.id_cuenta where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5)" & vbCrLf
                StrSQL &= "INSERT INTO [lausana].[dbo].[pago_parametros] ([nro_pago_detalle],[nro_pago_tipo],[pago_parametro],[pago_parametro_valor])" & vbCrLf
                StrSQL &= "select nro_pago_detalle,prd.nro_pago_tipo,'nro_cuenta',cast(ec.CBU as varchar(50)) from pago_registro_detalle prd join entidad_ctas ec on prd.dep_id_cuenta = ec.id_cuenta where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5)" & vbCrLf
                StrSQL &= "INSERT INTO [lausana].[dbo].[pago_parametros] ([nro_pago_detalle],[nro_pago_tipo],[pago_parametro],[pago_parametro_valor])" & vbCrLf
                StrSQL &= "select nro_pago_detalle,prd.nro_pago_tipo,'tipo_cuenta','2' from pago_registro_detalle prd join entidad_ctas ec on prd.dep_id_cuenta = ec.id_cuenta where nro_pago_registro in (select nro_pago_registro from pago_registro where nro_credito = " & CStr(nro_credito) & " and nro_pago_concepto = 5)"
                
                nvFW.nvDBUtiles.DBExecute(StrSQL)
            Catch ex As Exception
                err.parse_error_script(ex)
            End Try
        Else
            err.numError = 2
            err.titulo = "No se permite cambiar la cuenta"
            err.mensaje = "No se puede cambiar la cbu en el estado en que se encuentra el credito"
        End If

        err.response()
    End If

    Me.contents.Add("cuentas", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("creditos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>*,convert(varchar,fe_naci,103) as fecha_nacimiento</campos><filtro></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("bancos_cta", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banco'><campos>distinct nro_banco as id, banco as  [campo] </campos><filtro><esBanco_cliente type='igual'>1</esBanco_cliente></filtro><orden>[campo]</orden></select></criterio>"))



%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <meta http-equiv="X-UA-Compatible" content="IE=edge">
     <meta name="viewport" content="initial-scale=1 " lang="es" >
     <meta name="viewport" content="width=device-width, user-scalable=no" lang="es" >
    
    <title>Edición de cuentas bancarias</title>
    <meta name="google" content="notranslate" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico" />

   
    <meta name="mobile-web-app-capable" content="yes"lang="es"  >
    <meta http-equiv="Content-Language" content="es"/>
    <link href="/precarga/image/icons/nv_mutual.png"  sizes="193x193" rel="shortcut icon" />
    <title>NOVA Precarga</title>
   

    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript" class="table_window">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var ismobile
        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return guardar()";
        
         vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Agregar";
        vButtonItems[1]["etiqueta"] = "Agregar";
        vButtonItems[1]["imagen"] = "agregar";
        vButtonItems[1]["onclick"] = "return agregar()";
       /*vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "Eliminar";
        vButtonItems[2]["etiqueta"] = "Eliminar";
        vButtonItems[2]["imagen"] = "eliminar";
        vButtonItems[2]["onclick"] = "return eliminar()";*/


        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        vListButtons.loadImage("guardar", "/FW/image/icons/guardar.png");
        vListButtons.loadImage("eliminar", "/FW/image/icons/eliminar.png");
        vListButtons.loadImage("verificar", "/FW/image/icons/confirmar.png");
        vListButtons.loadImage("agregar", "/FW/image/icons/agregar.png");

        var win = nvFW.getMyWindow()
        var nro_credito = '<%= nro_credito%>'
        
        
        function window_onload() { 

            ismobile = (parent.isMobile()) ? true : false
            vListButtons.MostrarListButton()            
            cargar_cuentas_persona()            
            window_onresize()
            
            
        }



        function cargar_cuentas_persona() {
            nvFW.bloqueo_activar($(document.body), 'Cargando cuentas');
            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (rs) {
                $("tblistado").update("")
                var html=""
                while(!rs.eof()){
                    html+="<tr><td><input type='radio' id='cuenta_"+rs.getdata("id_cuenta")+"'  name='cuenta' id_cuenta='"+rs.getdata("id_cuenta")+"' /> </td><td>"+rs.getdata("banco")+"</td><td>"+rs.getdata("CBU")+"</td></tr>"
                    rs.movenext()
                }//while
                if(html!=""){
                     $("tblistado").update(html)
                     selcuenta($F("id_cuenta_selected"))
                }
             nvFW.bloqueo_desactivar($(document.body), 'Cargando cuentas');    
            }
            rs.open(nvFW.pageContents.cuentas, '', "<nro_entidad type='igual'>" + $F("nro_entidad") + "</nro_entidad>")
            
            
        }

        function selcuenta(id_cuenta){
            
            $("id_cuenta_selected").value=id_cuenta
             $$("input[name='cuenta']").each(function(e){
                
                var idcuenta=$(e).readAttribute('id_cuenta');
                if(idcuenta==id_cuenta){
                    $(e).checked=true
                }
             })
        }

        
       
                
      

       
        function window_onresize() {
            
            try {
                
                if (ismobile) {
                    $("tblistado").setStyle({fontSize:"12px"})
                }
                else {
                    $("tblistado").setStyle({fontSize:"13px"})
                }
                
             var hbody=$$("body")[0].getHeight()            
             $("containerDiv").setStyle({height:hbody.toString()+"px"})                
             var hhead=$("tbhead").getHeight()
             var hbotonera=$("botonera").getHeight()
             var htbcab=$("tbcab").getHeight()

             var hlistado=hbody-hhead-hbotonera-htbcab-20
             $("divlistado").setStyle({height:hlistado.toString()+"px"}) 
            }
            catch (e) { }
        }

        function eliminar(){            
            nvFW.getMyWindow().close()
        }
        var win_abm
        var estados="HPRXM" 
        function agregar(){
            if(estados.indexOf($F("estado"))>=0){
             win_abm =  window.top.createWindow2({
                url: 'Cuenta_ABM.aspx?modo=V&nro_entidad='+$F("nro_entidad"),
                title: '<b>ingrese banco y cbu</b>',
                centerHFromElement: window.top.$("contenedor"),
                parentWidthElement: window.top.$("contenedor"),
                parentWidthPercent: 0.9,
                parentHeightElement: window.top.$("contenedor"),
                parentHeightPercent: 0.9,
                maxHeight: 150,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: datos_return
            });
            
            win_abm.options.userData = {}
            win_abm.showCenter(true)   
        }else{
            alert("El estado en que se encuentra el credito, no se pueden agregar cuentas")
        }
             
            
        }//agregar

        function datos_return(){            
            if(win_abm.options.userData['add']==1){
                cargar_cuentas_persona()
            }
        }


        function guardar(){
             if(estados.indexOf($F("estado"))>=0){
            var id_cuenta=0
            $$("input[name='cuenta']").each(function(e){ if(e.checked){
                id_cuenta = $(e).readAttribute("id_cuenta")
            }
            });
            if(id_cuenta==0){
                alert("No ha seleccionado una cuenta")
                return
            }

            Dialog.confirm("¿Desea realizar el cambio de cbu para este credito?",
                                       {
                                           width: 300,
                                           className: "alphacube",
                                           okLabel: "Si",
                                           cancelLabel: "No",
                                           onOk: function (w) {
                                               changecbu(id_cuenta,nro_credito)
                                               w.close();
                                               return
                                           },

                                           onCancel: function (w) {                                               
                                               w.close();
                                           }
                                       });//dialog
        }else{
            alert("No se permite realizar esta acción en el estado en que se encuentra el crédito")
        }
        }

        function changecbu(id_cuenta,nro_credito){
            nvFW.error_ajax_request('Cuenta_seleccion.aspx', {parameters: { modo: 'C', id_cuenta: id_cuenta, nro_credito: nro_credito},
             bloq_msg: 'actualizando crédito...',
             onSuccess: function (err, transport) {                                  
                                        if (err.numError == 0) {                     
                                            console.log("credito actualizado")
                                            $("id_cuenta_selected").value=id_cuenta
                                            selcuenta($F("id_cuenta_selected"))
                                            win.options.userData['cuenta_actualizada']=1
                                            win.close();
                                        }
                                        else
                                        {
                                        nvFW.alert(err.mensaje)
                                        }                         
                                    }
                                });     


}


    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; background-color: white; -webkit-text-size-adjust: none; overflow: auto;">
    <input type="hidden" value="<%=nro_entidad %>" id="nro_entidad" />
    <input type="hidden" value="<%=id_cuenta %>" id="id_cuenta_selected" />
    <input type="hidden" value="<%=estado %>" id="estado" />
    <div style="overflow: auto; -webkit-overflow-scrolling: touch" id="containerDiv">
        <table class="tb1" id="tbhead" style="width: 100%; white-space: nowrap;">
            <tr>
                <td class="Tit3" style="text-align: center;">Cuentas bancarias</td>
                <td style="width: 120px" title="Agregar cuenta bancaria" >
                    <div style="width: 120px" id="divAgregar" />
                </td>
            </tr>
        </table>
        <table class="tb1 highlightEven highlightTROver" id="tbcab" style="width: 100%;">
            <head><tr><th style="width:7%"></th><th style="width:47%;text-align:left">banco</th><th style="width:auto;text-align:left">cbu</th></tr></head>
        </table>
        <div id="divlistado" style="width: 100%; overflow-y: auto">
        <table class="tb1 highlightEven highlightTROver" style="width: 100%;text-align: left" >             
            <tbody id="tblistado">                
            </tbody>
        </table>    
        </div>
        
        <table class="tb1" id="botonera">
            <tr>            
            <td style="text-align: center;width: 100%">                
                <div style="margin: auto" id="divGuardar" />
            </td>
            </tr>
        </table>
    </div>
</body>
</html>
