<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%

    Dim nro_entidad As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad", 0)
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("select cuit,tipo_docu,nro_docu,sexo from verpersonas where nro_entidad=" & CStr(nro_entidad))

    Dim cuit = rs.Fields("cuit").Value
    Dim tipo_docu = rs.Fields("tipo_docu").Value
    Dim nro_docu = rs.Fields("nro_docu").Value
    Dim sexo = rs.Fields("sexo").Value


    ''Alta de CBU
    If modo = "AC" Then
        Dim err = New tError
        Dim StrSQL As String = ""
        Dim mensajeError As String = ""
        
        Try
            Dim nro_banco_cta As String = nvFW.nvUtiles.obtenerValor("nro_banco_cta", "")
            Dim cbu As String = nvFW.nvUtiles.obtenerValor("cbu", 0)
            rs = nvFW.nvDBUtiles.DBOpenRecordset("select isnull(s.id_banco_sucursal,0) as id_banco_sucursal from Banco_sucursal s where  s.cod_sucursal='999-99' and s.nro_banco=" & CStr(nro_banco_cta))
            Dim id_banco_sucursal As String = rs.Fields("id_banco_sucursal").Value
            If (rs.RecordCount = 0) Then
                mensajeError = "No se encuentra la sucursal para el banco seleccionado\n"
            End If
            rs = nvFW.nvDBUtiles.DBOpenRecordset("select * from verEntidad_bco_ctas where nro_entidad=" & CStr(nro_entidad) & " and CBU='" & cbu & "'")
            If (rs.RecordCount = 0 And mensajeError = "") Then
                StrSQL = "declare @ret int" & vbCrLf
                StrSQL &= " EXEC dbo.rm_cuenta_banco_ABM_precarga '" & cuit & "'," & tipo_docu & "," & nro_docu & "," & nro_banco_cta & "," & id_banco_sucursal & ",2,'" & cbu & "',NULL,NULL,'" & sexo & "'," & nro_entidad & ",'A'" & vbCrLf

                rs = nvFW.nvDBUtiles.DBOpenRecordset(StrSQL)
                Dim ret As Integer = rs.Fields("numerror").Value
                Dim mensaje As String = rs.Fields("mensaje").Value
                If (ret <> 0) Then
                    mensajeError &= mensaje
                End If
            Else
                mensajeError &= "La cbu " & cbu & " que intenta ingresar, ya existe para la persona\n"
            End If

            If (mensajeError <> "") Then
                err.numError = 1
                err.titulo = "Error al dar de alta. Consulte con sistemas"
                err.mensaje = mensajeError
            End If

        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If
    Me.contents.Add("bancos_cta", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banco'><campos>distinct nro_banco as id, banco as  [campo] </campos><filtro><esBanco_cliente type='igual'>1</esBanco_cliente></filtro><orden>[campo]</orden></select></criterio>"))


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <meta http-equiv="X-UA-Compatible" content="IE=edge">
     <meta name="viewport" content="initial-scale=1 " lang="es" >
     <meta name="viewport" content="width=device-width, user-scalable=no" lang="es" >
    
    <title>ABM cuentas bancarias</title>
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
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js?v=1"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript" class="table_window">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var ismobile
        var vButtonItems = {}
        var mywin=nvFW.getMyWindow()
        var params={add:0}        
        mywin.options.userData=params
         vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Agregar";
        vButtonItems[0]["etiqueta"] = "Agregar";
        vButtonItems[0]["imagen"] = "agregar";
        vButtonItems[0]["onclick"] = "return agregar()";
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "cancelar";
        vButtonItems[1]["onclick"] = "return cancelar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons');        
        vListButtons.loadImage("cancelar", "/FW/image/icons/cancelar.png");        
        vListButtons.loadImage("agregar", "/FW/image/icons/agregar.png");


        
        
        
        function window_onload() { 

            ismobile = (parent.isMobile()) ? true : false
            vListButtons.MostrarListButton()
            window_onresize()            
            //cargar_bancos()
        }

                
      

       
        function window_onresize() {
            try {
                
                if (ismobile) {
                    $('idDatos1').style.width = '100%'
                    $('idDatos2').style.width = '100%'
                    
                }
                else {
                    $('idDatos1').style.width = '50%'
                    $('idDatos2').style.width = '50%'
                    
                }
             var hbody=$$("body")[0].getHeight()
             var hresultado=$("tbResultado").getHeight()
             var hbotonera=$("botonera").getHeight()
            }
            catch (e) { }
        }

        function cancelar(){            
            mywin.close()
        }

        function agregar(){
            
            var cbu=$("cbu").value
            cbu=cbu.trim()
            var nro_banco_cta=$F("bancos_cta")  //$("nro_banco_cta").value
            if(cbu.length!=22){
                alert("la cbu no es valida")
                return
            }
            if(nro_banco_cta==""){
             alert("Debe seleccionar un banco para la CBU")
                return   
            }
            if(validarCBU1(cbu) == false){
             alert("La cbu ingresada no es valida. Verifique por favor")
                return      
            }

             Dialog.confirm("�Desea agregar esta cbu a la persona?",
                                       {
                                           width: 300,
                                           className: "alphacube",
                                           okLabel: "Si",
                                           cancelLabel: "No",
                                           onOk: function (w) {
                                               addcbu(cbu,nro_banco_cta)
                                               w.close();
                                               return
                                           },

                                           onCancel: function (w) {                                               
                                               w.close();
                                           }
                                       });//dialog
            
        }//agregar

function addcbu(cbu,nro_banco_cta){
nvFW.error_ajax_request('Cuenta_ABM.aspx', {parameters: { modo: 'AC', cbu: cbu, nro_banco_cta: nro_banco_cta,nro_entidad:$F('nro_entidad') },
                                             bloq_msg: 'agregando cbu...',
                                             onSuccess: function (err, transport) {
                                                                    
                                                                        if (err.numError == 0) {                     
                                                                            params['add']=1
                                                                            console.log("cbu agregada")
                                                                            mywin.close()
                                                                        }
                                                                        else
                                                                        {
                                                                        params['add']=0
                                                                        nvFW.alert(err.mensaje)
                                                                        }
                                                                        mywin.options.userData=params
                                                                    }
                                                                    
                                                                });     


}
function validarCBU1(cbu) {
    var ponderador;
    ponderador = '97139713971397139713971397139713'

    var i;
    var nDigito;
    var nPond;
    var bloque1;
    var bloque2;

    var nTotal;
    nTotal = 0;

    bloque1 = '0' + cbu.substring(0, 7)

    for (i = 0; i <= 7; i++) {
        nDigito = bloque1.charAt(i)
        nPond = ponderador.charAt(i)
        nTotal = nTotal + (nPond * nDigito) - ((Math.floor(nPond * nDigito / 10)) * 10)
    }

    i = 0;

    while (((Math.floor((nTotal + i) / 10)) * 10) != (nTotal + i)) {
        i = i + 1;
    }

    // i = digito verificador

    if (cbu.substring(7, 8) != i) {
        return false;
    }

    nTotal = 0;

    bloque2 = '000' + cbu.substring(8, 21)

    for (i = 0; i <= 15; i++) {
        nDigito = bloque2.charAt(i)
        nPond = ponderador.charAt(i)
        nTotal = nTotal + (nPond * nDigito) - ((Math.floor(nPond * nDigito / 10)) * 10)
    }

    i = 0;

    while (((Math.floor((nTotal + i) / 10)) * 10) != (nTotal + i)) {
        i = i + 1;
    }

    // i = digito verificador
    if (cbu.substring(21, 22) != i) {
        return false;
    }
}

function cargar_bancos(){

    var options=""
    var rs = new tRS()
    rs.async = true
    rs.onComplete = function (rs) {
        options="<option value=''>SELECCIONE UN BANCO</option>"
    while(!rs.eof()){
        var id=rs.getdata("id")
        var campo=rs.getdata("campo")
        options+="<option value="+id+">"+campo+"</option>"
        rs.movenext()
    }    
    $("nro_banco_cta").update(options)    
    }
    rs.open(nvFW.pageContents.bancos_cta)
    
}


    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; background-color: white; -webkit-text-size-adjust: none; overflow: auto;">
    <input type="hidden" value="<%=nro_entidad %>" id="nro_entidad" />    
    <div style="overflow: auto; -webkit-overflow-scrolling: touch" id="containerDiv">
        <table class="tb1" id="tbResultado" style="width: 100%; white-space: nowrap;">
         
            <tr>
                <td>
                    <table id="idDatos1" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="width: 70px" class="Tit1">Banco</td>
                            <td>

                               <!-- <select id="nro_banco_cta" style="width: 100%;" maxlength="10">
                                </select>-->
                                <script type="text/javascript">
                                    //campos_defs.add('bancos_cta', { nro_campo_tipo: 4, enDB: false, filtroXML: nvFW.pageContents.bancos_cta })
                                    campos_defs.add('bancos_cta', { enDB: false, nro_campo_tipo: 1, filtroXML: nvFW.pageContents["bancos_cta"] })
                                </script>
                            </td>
                        </tr>
                    </table>
                    <table id="idDatos2" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="width:50px" class="Tit1">CBU</td>
                            <td id="tdcbu"><input type="number" name="cbu" id="cbu" style="width: 100%; text-align: right" maxlength="22" onkeypress="return this.value.length < 23;" /></td>
                            
                        </tr>
                    </table>
                    </td>
            </tr>           
        </table>
       </div>
        <table class="tb1" id="botonera">
            <tr>            
                <td style="text-align: center;width: 50%">                
                <div style="width:100%; margin: auto" id="divCancelar" />
                </td>
                <td style="text-align: center;width: 50%">                
                    <div style="width:100%; margin: auto" id="divAgregar" />
                </td>
            </tr>
        </table>
    </div>
</body>
</html>

