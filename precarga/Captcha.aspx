<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<%

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>Ingresar Captcha</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>
    
    <% = Me.getHeadInit()%>
    
    <script type="text/javascript" language="javascript">


        function window_onload() {
            var e
            var win = nvFW.getMyWindow()
        }

</script>
</head>
<body onload="window_onload()"  style="width:100%;height:100%; overflow:auto">
  <table class="tb1" style="border-collapse:collapse; border:none; width:100%">
      <tr>
          <td><img src="C:/cuad_captcha/captcha250717090705214.jpg" class="img_button" border="0" align="absmiddle" hspace="1" id="imgCaptcha"></td>
          <td><input type="number" name="txtCaptcha" id="txtCaptcha" style="width: 9em; text-align: right" maxlength="6" /></td>
      </tr>
  </table>


</body>
</html>
