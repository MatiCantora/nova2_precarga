<%@ Page Language="vb"   %>


<% 
stop
    Dim eval As Boolean = False
    
    If Not Request.QueryString("eval") Is Nothing Then
        eval = Request.QueryString("eval").ToUpper() = "TRUE"
    End If
    Dim m = eval
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />-->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Firma Institucional</title>
    <script type="text/javascript">
      function input_val()
        {
        if (document.getElementById("UID").value == '' || document.getElementById("PWD").value == '')
          {
          alert("No ha ingresado sus credeciales correctamente")
          return false
          }
        document.getElementById("frmRes").style.display = "inline" 
        
        return true  
        }
      function frmRes_omload()
        {
        document.getElementById("fUID").value = "" 
        document.getElementById("UID").value = "" 
        document.getElementById("PWD").value = "" 
        }
        
     function window_onload()
       {
       if (document.getElementById("eval").value == "true")
         document.getElementById("fUID").focus()
       else
         document.getElementById("UID").focus()  
       }     
    </script>
</head>
<body onload="window_onload()">
 <p style="text-align:center">
    <font color='#606060' face='Trebuchet MS, Arial' size='4'> <b>Firma institucional Banco VOII SA</b></font>
    </p>
    <div style= "border: solid blue 1px; text-align:center; width:600px; margin:auto">
    <font face='Trebuchet MS, Arial' size='2'>Ingrese su usuario y contraseña</font>
    <br />
    <font face='Trebuchet MS, Arial' size='2'>El sistema le devolverá la firma insticucional para que copie y pegue dentro de su mail.</font>
    </div>
    
   
    <br />
    
    <form name="frmLogin" action="frmFirma.aspx" onsubmit="return input_val()" method="post" target="frmRes" >
    <div style="width:100%; margin:auto">
         <table style="width:300px; margin:auto">
           <tr <%= iif(eval, "", "style='display:none'") %>><td style="width:100px">Usuario firma:</td><td><input name="fUID" id="fUID" style="width:100%" /></td></tr>
           <tr><td style="width:150px">Usuario:</td><td><input name="UID" id="UID" style="width:100%" /></td></tr>
           <tr><td style="width:150px">Contraseña:</td><td><input type="password" name="PWD" id="PWD" style="width:100%" /></td></tr>
           <tr><td style="width:150px">&nbsp;</td><td><input type="submit" value="Generar firma"  style="width:100%" /></td></tr>
           
        </table>
        </div>
        <input type="hidden" name="eval" id="eval" value="<%=eval.toString().toLower() %>" />
    </form>
    
    <iframe name="frmRes" id="frmRes" style="width:100%; height: 200px; border: 0px; border-top: solid blue 1px; display:none" onload="frmRes_omload()">
    </iframe>
       
</body>
</html>
