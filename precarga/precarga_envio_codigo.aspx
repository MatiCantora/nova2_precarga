<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 

    
    Dim codigoyacare As Integer = nvFW.nvUtiles.obtenerValor("codigoyacare", "0")
    

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
    vButtonItems[0]["etiqueta"] = "Copiar codigo";
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
var car_tel
var telefono
var strNombreCompleto
var codigo    
    function window_onload() {
        
        vListButtons.MostrarListButton()
       strNombreCompleto = win.options.userData.param['strNombreCompleto']        
       codigo = win.options.userData.param['codigo']     
       $("codigoyacare").value=codigo
       window_onresize() 
       
    }    


  

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
        var copyText = $('codigoyacare');
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
        
         var codigo=$F('codigoyacare');
         var telefono=$F('telefono');
         
            if(telefono.trim()=="")
                {alert("el numero de telefono no es correcto");
                return;}
            
        

         var phone="54"+telefono
           
            mensaje="Hola "+strNombreCompleto+", te envio codigo link para que lo ingrese en la app de yacare: "+codigo+"  - Saludos cordiales."
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
                   <!-- <div class="row1" style="float: left;">
                        <div class='Tit2' style="width: 35%; float: left;">INGRESE TELEFONO:</div>
                        <div style="width: 65%; float: left">
                            
                        </div>
                    </div>
                     <div class="row1" style="float: left;">
                        <div class='Tit2' style="width: 35%; float: left;">CODIGO:</div>
                        <div style="width: 65%; float: left">
                          
                        </div>
                    </div> -->
                </div>
                 <div  style="float: left;width: 100%" >
                    
                        <table class="tb1" style="border: none;width: 100%">
                            <tr class="tbLabel" style="padding-left: 3px">
                                <td >INGRESE TELEFONO</td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text"  id="telefono" value="" style="width:100%" onkeypress="return valDigito(event)" maxlength="11" placeholder="carateristica sin cero + numero tel. sin 15"/>
                                </td>
                            </tr>
                            <tr class="tbLabel" style="padding-left: 3px">
                                <td >CODIGO</td>
                            </tr>
                            <tr>
                                <td>
                                      <input type="text"  id="codigoyacare" value="" style="width:100%" readonly/>
                                </td>
                            </tr>
                        </table>
                    
                </div>
                
            </td>
        </tr>
        <tr>
        <td>OBS: El c&oacute;digo generado tendr&aacute; una valid&eacute;z de 5 dias</td>
        </tr>
    </table>

</body>
</html>
