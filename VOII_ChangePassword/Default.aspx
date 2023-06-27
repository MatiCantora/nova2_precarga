<%@ Page Language="vb" AutoEventWireup="false"  %>


<% 
    Stop
    'Dim eval As Boolean = False

    'If Not Request.QueryString("eval") Is Nothing Then
    '    eval = Request.QueryString("eval").ToUpper() = "TRUE"
    'End If
    'Dim m = eval
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />-->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Cambiar contraseña</title>
    <script type="text/javascript">
      function input_val()
        {
        document.getElementById("frmRes").style.display = "none" 
        if (document.getElementById("UID").value == '' || document.getElementById("PWD").value == '')
          {
          alert("No ha ingresado sus credeciales correctamente")
          return false
          }
          
        if (document.getElementById("pwd_new01").value == '' || document.getElementById("pwd_new02").value == '')
          {
          alert("Debe ingresar la nueva contraseña")
          return false
          }
          
        if (document.getElementById("pwd_new01").value != document.getElementById("pwd_new02").value)
          {
          alert("Las nuevas contraseñas ingresadas no son iguales")
          return false
          }  
            
        
        
        return true  
        }
      function frmRes_omload()
        {
        document.getElementById("frmRes").style.display = "inline"
        //document.getElementById("UID").value = "" 
        document.getElementById("PWD").value = "" 
        document.getElementById("pwd_new01").value = ""
        document.getElementById("pwd_new02").value = ""
        }
        
     function window_onload()
       {
       document.getElementById("UID").focus()  
       }
       
       
    </script>
</head>
<body onload="window_onload()">
 <p style="text-align:center">
    <font color='#606060' face='Trebuchet MS, Arial' size='4'> <b>Cambiar contraseña Banco VOII SA</b></font>
    </p>
    <div style= "border: solid blue 1px; text-align:center; width:600px; margin:auto">
    <font face='Trebuchet MS, Arial' size='2'>Servicio de cambio de contraseña </font>
    <br />
    <font face='Trebuchet MS, Arial' size='2'>Si tiene alguna duda respecto de sus credenciales consulte a Seguridad Informática. </font>
    </div>
    
   
    <br />
    
    <form name="frmLogin" action="frmChangePassword.aspx" onsubmit="return input_val()" method="post" target="frmRes" >
    <div style="width:100%; margin:auto">
         <table style="width:300px; margin:auto">
          
           <tr><td style="width:150px">Usuario:</td><td><input name="UID" id="UID" style="width:100%" /></td></tr>
           <tr><td style="width:150px">Contraseña actual:</td><td><input type="password" name="PWD" id="PWD" style="width:100%" /></td></tr>
           <tr ><td style="width:150px; border-top:solid gray 1px">Contraseña nueva:</td><td  style="border-top:solid gray 1px"><input type="password" name="pwd_new01" id="pwd_new01" style="width:100%" /></td></tr>
           <tr><td style="width:150px">Contraseña nueva:</td><td><input type="password" name="pwd_new02" id="pwd_new02" style="width:100%" /></td></tr>
           <tr><td style="width:150px">&nbsp;</td><td><input type="submit" value="Cambiar contraseña"  style="width:100%" /></td></tr>
           
        </table>
        </div>
      
    </form>
    
    <iframe name="frmRes" id="frmRes" style="width:100%; height: 200px; border: 0px; border-top: solid blue 1px; display:none" onload="frmRes_omload()">
    </iframe>
       
</body>
</html>
