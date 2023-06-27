
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
<script type="text/javascript" >
function window_onload()
    {
   iframe2.location.href = "prueba_campo_def.aspx"

    campos_defs.add('cod_servidor1', {filtroXML:"<criterio><select vista='nv_servidores'><campos>distinct cod_servidor as id, cod_servidor as [campo] </campos><orden>[campo]</orden></select></criterio>", nro_campo_tipo : 1, enDB: false, json: true, target:'miID'});
    campos_defs.add('tipo100', {nro_campo_tipo : 100, target:'miID2'});
}

</script>
</head>
<body onload="window_onload()">
    <table class="tb1" border="1">
        <tr class="tbLabel"><td colspan="2">Hola Titulo</td></tr>
        <tr><td style="width: 50%">Iframe 1</td><td>Iframe 2</td></tr>
        <tr><td><iframe src="prueba_nvFW.aspx" style="width:100%; height: 250px"></iframe></td><td><iframe name="iframe2"  style="width: 100%; height: 250px"></iframe></td></tr>
        </table>

    <table class="tb1" border="1">
        <tr class="tbLabel"><td colspan="2">Cammpos defs</td></tr>
        <tr><td>Cammpo def tipo 1</td><td id="miID"></td></tr>
        <tr><td>Cammpo def tipo 100</td><td id="miID2"></td></tr>
    </table>
</body>
</html>
