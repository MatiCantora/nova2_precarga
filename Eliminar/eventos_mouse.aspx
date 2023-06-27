<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>

<html>
<head>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0">
    <link href="/fw/css/base.css" type='text/css' rel='stylesheet' />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <title></title>
    <script type="text/javascript">
        function window_onload()
        {
        //nvFW.window_contextMenu = false  
        //nvFW.window_click_left = function () {nvFW.alert("LEFT")}
        //nvFW.window_click_left = function () {nvFW.alert("LEFT")}
        //nvFW.window_click_left = function () {nvFW.alert("LEFT")}  
        }

        function evento_en_ctrlA(e)
          {
          nvFW.window_key_disable['CTRL+65'] = true
          nvFW.window_key_action['CTRL+65'] = function (e)
                                                  {
                                                  nvFW.alert("Presionó CRTL+A")                                                   
                                                  }   
          }

        
    </script>
</head>
<body onload="window_onload()">
    Tabla class tb1 - Tabla simple sin ajustes
    <table class="tb1">
        <tr>
            <td><input type="button" value="Disable Context Menu" onclick="nvFW.window_contextMenu = false" /></td>
            <td><input type="button" value="Enable Context Menu" onclick="nvFW.window_contextMenu = true" /></td>
            <td><input type="button" value="Click right" onclick="nvFW.window_contextMenu = false; nvFW.window_click_right = function() {nvFW.alert('RIGHT')}" /></td>
            <td><input type="button" value="Click Middle" onclick="nvFW.window_click_middle = function() {nvFW.alert('MIDDLE')}" /></td>
            <td><input type="button" value="Click left" onclick="nvFW.window_click_left = function() {nvFW.alert('LEFT')}" /></td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
        </tr>
        <tr>
            <td><input type="button" value="Habilitar F5" onclick="nvFW.window_key_disable['116'] = false" /></td>
            <td><input type="button" value="Evento en CTRL+A" onclick="evento_en_ctrlA(event)" /></td>
            <td><input type="button" value="Quitar seleccion" onclick="nvFW.selection_clear()" /></td>
            <td><input type="text" id="txt1"></td>
            <td><input type="text" id="txt2"></td>
            <td><input type="checkbox"   id="chk1"></td>
            <td><input type="date"   id="date1"></td>
            <td><input type="number"   id="number1"></td>
            <td><input type="password"   id="password"></td>
            <td><input type="radio"   id="radio"></td>
            

        </tr>
     </table>
</body>
</html>
