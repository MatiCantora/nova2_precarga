<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim crparam As Integer = nvFW.nvUtiles.obtenerValor("crparam", "0")
    Dim URI as String=""
    

    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("tyc_alta_key_ABM", ADODB.CommandTypeEnum.adCmdStoredProc)
    Dim pParam = cmd.CreateParameter("@id_tipo", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 0, crparam)
    cmd.Parameters.Append(pParam)
    ''cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, crparam)
    Dim rs As ADODB.Recordset = cmd.Execute()
    If (Not (rs.EOF)) Then
        URI = rs.Fields("URI").Value
    End If

    Me.contents.Add("creditos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>nro_credito,nro_docu,tipo_docu,sexo,strNombreCompleto,estado,descripcion,nro_banco,banco,nro_mutual,mutual,nombre_operador,operador,vendedor,convert(varchar,fe_estado,103) as fe_estado,dbo.conv_fecha_to_str(fe_estado,'dd/mm/yyyy hh:mm:ss') as fe_estado_str,importe_cuota,cuotas,importe_bruto,importe_neto,importe_documentado,gastoscomerc + dbo.rm_PG_suma_importe(nro_credito,18) as gasto_administrativo,saldo_cancelado,dbo.an_cuota_maxima_credito(nro_credito) as cuota_maxima,tipo_cobro,email,car_tel,telefono</campos><orden></orden><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))



%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>Precarga - Enviar terminos y condiciones</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>

    <% = Me.getHeadInit()%>
    <style type="text/css">
        .row {
            -moz-border-radius: 0.33em;
            box-shadow: 0 0 1px #f4f4f4;
            text-align: left;
            height: 21px;
            width:50%;
            margin-bottom: 0.66em;
        }
            .row div{
            border-radius: 0.33em; 
            height: 1.5em;
            display: flex;
            justify-content: center;
            align-content: center;
            flex-direction: column;
            padding: 0px 0.35em 0px 0.35em;
        }

        @media screen and (max-width: 580px) {
            .row {
                width:100%
            }
        }
        .row1{
           -moz-border-radius: 0.33em;
            box-shadow: 0 0 1px #f4f4f4;
            text-align: left;
            height: 21px;
            width:100%;
            margin-bottom: 0.66em; 
        }


        
    </style>
    <script type="text/javascript" language="javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    
    var win = nvFW.getMyWindow()
  

    var vButtonItems = {}
    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "copiar";
    vButtonItems[0]["etiqueta"] = "Copiar link";
    vButtonItems[0]["imagen"] = "copiar";
    vButtonItems[0]["onclick"] = "return btnCopiar_onclick()";

    vButtonItems[1] = {}
    vButtonItems[1]["nombre"] = "whatsapp";
    vButtonItems[1]["etiqueta"] = "Enviar por whatsapp";
    vButtonItems[1]["imagen"] = "whatsapp";
    vButtonItems[1]["onclick"] = "return btnEnviarwp_onclick()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons');
    vListButtons.loadImage("copiar", "/precarga/image/send-16.png");
    vListButtons.loadImage("whatsapp", "/precarga/image/whatsapp16.png");
    

    var permisos_precarga = nvFW.pageContents["permisos_precarga"]

    
    function window_onload() {
        
        vListButtons.MostrarListButton()
       cargarDatos()
       window_onresize() 
       
    }    

var car_tel
var telefono
var strNombreCompleto
    function cargarDatos(){
        nro_credito = win.options.userData.param['nro_credito']
        var rs = new tRS();
        rs.async = true;     
           
        rs.onComplete = function (rs){
            
            if (!rs.eof()) {
                car_tel = rs.getdata('car_tel')
                telefono = rs.getdata('telefono')
                strNombreCompleto = rs.getdata('strNombreCompleto')         
            }
        }
      rs.open({filtroXML: nvFW.pageContents["creditos"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" });
      
       

    }//cargar datos

      function window_onresize() {
        try {
              var dif = Prototype.Browser.IE ? 5 : 2
              body_height = $$('body')[0].getHeight()
              cab_height = $('tbCampos').getHeight()              
                            
              
          }
          catch (e) { }
    }

    function btnCopiar_onclick() {
        var soportaComando=document.queryCommandSupported('copy');
        if(soportaComando){
        var copyText = $('uri');
        copyText.select();
        if(document.execCommand('copy')){
        alert('copiado al portapapeles');
        }else{
        alert('no se copio');
        }
        
        }else{
        alert('no soporta copiado porta papeles');
        }

    }

    function btnEnviarwp_onclick() {
        
         var url=$F('uri');
            if(car_tel.trim()=="")
                {alert("el numero de telefono no es correcto");
                return;}
            if(telefono.trim()==""){
                alert("el numero de telefono no es correcto");
                return;
            }

         if(car_tel.substr(0,1)=="0")
            car_tel=car_tel.replace("0","") //elimino el 0 del comienzo

         if(telefono.substr(0,2)=="15")
            telefono=telefono.replace("15","") //elimino el 15 del comienzo
        

         var phone="54"+car_tel+telefono
           
            mensaje="Hola "+strNombreCompleto+", te envio este link para que aceptes los terminos y condiciones del credito: "+url+"  - Saludos cordiales."
         //window.location.href="https://wa.me/"+phone+"?text="+encodeURI(mensaje)
           window.open("https://wa.me/"+phone+"?text="+encodeURI(mensaje), '_blank');
    }



</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    

    <table id="tbCampos" class="tb1" style="width: 100%">
        <tr>
            <td>
                <div>                   
                    <div class="row" style="float: left;">
                        <div style="width: 100%; text-align: center">
                             <div  id="divcopiar" ></div>
                        </div>                       
                    </div>                  
                    <div class="row" style="float: left;">
                        <div style="width: 100%; text-align: center">
                             <div  id="divwhatsapp" ></div>
                        </div>                       
                    </div>
                     <div class="row1" style="float: left;">
                        <div class='Tit2' style="width: 35%; float: left;">LINK:</div>
                        <div style="width: 65%; float: left">
                            <input type="text"  id="uri" value="<%=URI%>" style="width:100%" readonly/>
                        </div>
                    </div> 
                </div>
            </td>
        </tr>
    </table>

</body>
</html>
