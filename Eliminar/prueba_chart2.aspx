<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>

<%@ Register assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" namespace="System.Web.UI.DataVisualization.Charting" tagprefix="asp" %>
<script runat="server">

    Protected Sub Chart1_Load(sender As Object, e As EventArgs)

    End Sub

    Protected Sub Chart1_Click(sender As Object, e As ImageMapEventArgs)
        Response.Redirect("http://www.google.com")
    End Sub
</script>




<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
        

   

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >
      

    
    <form id="form1" runat="server">
&nbsp;<asp:Chart ID="Chart1" runat="server" DataSourceID="zzDataSouce" Height="800px" Width="1200px" OnLoad="Chart1_Load" OnClick="Chart1_Click">
            <series>
                <asp:Series Name="Series1" XValueMember="banco" YValueMembers="suma_importe_bruto" ChartType="Pie" LabelUrl="http://www.google.com" ToolTip="Algo del toolTip" Url="http://www.google.com">
                </asp:Series>
            </series>
            <chartareas>
                <asp:ChartArea Name="ChartArea1">
                </asp:ChartArea>
            </chartareas>
        </asp:Chart>
        <asp:SqlDataSource ID="zzDataSouce" runat="server" ConnectionString="Data Source=morfeo1;Initial Catalog=nvAdmin;Integrated Security=True" ProviderName="System.Data.SqlClient" SelectCommand="select  nro_banco, banco, count(*) as cantidad, SUM(importe_bruto)/1000000 as suma_importe_bruto From lausana..wrp_infocredito_base  where estado = 'T' and fe_credito &gt;= CONVERT(datetime, '5/1/2017', 101) and fe_credito &lt; CONVERT(datetime, '6/1/2017', 101)  Group by  nro_banco, banco "></asp:SqlDataSource>
    </form>
</body>
</html>
