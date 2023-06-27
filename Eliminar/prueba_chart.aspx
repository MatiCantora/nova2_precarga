<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>
<%@ Import Namespace="system.drawing,System.Web.UI.DataVisualization.Charting" %>


<%
    Stop
    Dim chart As System.Web.UI.DataVisualization.Charting.Chart = nvFW.nvChart.CreateChart("Venta mensual desde 1/2016 hasta 5/2017")
    chart.Width = 1200
    chart.Height = 600
    chart.Legends(0).Docking = Docking.Bottom
    chart.Legends(0).LegendStyle = LegendStyle.Table

    Dim strSQL As String = "select  lausana.dbo.finac_fin_mes(fe_credito) as fe_credito0, cast(day(lausana.dbo.finac_fin_mes(fe_credito)) as varchar(4)) + '/' + CAST(MONTH(fe_credito) as varchar(2)) as strfe_credito, nro_banco, banco, count(*) as cantidad, SUM(importe_bruto)/1000000 as suma_importe_bruto " &
"From lausana..wrp_infocredito_base  " &
"where estado = 'T' and fe_credito >= CONVERT(datetime, '1/1/2016', 101) and fe_credito < CONVERT(datetime, '6/1/2017', 101)  " &
"Group by lausana.dbo.finac_fin_mes(fe_credito), cast(day(lausana.dbo.finac_fin_mes(fe_credito)) as varchar(4)) + '/' + CAST(MONTH(fe_credito) as varchar(2)), nro_banco, banco " &
"order by fe_credito0"
    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
    nvFW.nvChart.CreateSeriesDB(chart, rs, "banco", "fe_credito0", "suma_importe_bruto", SeriesChartType.Spline)
    nvDBUtiles.DBCloseRecordset(rs)

    Dim ms As New System.IO.MemoryStream
    chart.SaveImage(ms, ChartImageFormat.Jpeg)


    chart = nvFW.nvChart.CreateChart("Venta 5/2017")
    chart.Width = 600
    chart.Height = 600
    chart.Legends(0).Docking = Docking.Bottom
    chart.Legends(0).LegendStyle = LegendStyle.Table

    strSQL = "select 'total' as serie, nro_banco, banco, count(*) as cantidad, SUM(importe_bruto)/1000000 as suma_importe_bruto " &
"From lausana..wrp_infocredito_base  " &
"where estado = 'T' and fe_credito >= CONVERT(datetime, '5/1/2017', 101) and fe_credito < CONVERT(datetime, '6/1/2017', 101)  " &
"Group by  nro_banco, banco "

    rs = nvDBUtiles.DBOpenRecordset(strSQL)
    nvFW.nvChart.CreateSeriesDB(chart, rs, "serie", "banco", "suma_importe_bruto", SeriesChartType.Pie, xValue:=ChartValueType.String)
    nvDBUtiles.DBCloseRecordset(rs)

    Dim ms2 As New System.IO.MemoryStream
    chart.SaveImage(ms2, ChartImageFormat.Jpeg)




    'serie = nvFW.nvChart.CreateSerie(chart, "AMUS", DataVisualization.Charting.SeriesChartType.Spline, Color.Green)
    'strSQL = "select  lausana.dbo.finac_fin_mes(fe_credito) as fe_credito0, cast(day(lausana.dbo.finac_fin_mes(fe_credito)) as varchar(4)) + '/' + CAST(MONTH(fe_credito) as varchar(2)) as strfe_credito, nro_banco, banco, count(*) as cantidad, SUM(importe_bruto)/1000000 as suma_importe_bruto " &
    '    "From lausana..wrp_infocredito_base  " &
    '    "where estado = 'T' and fe_credito >= CONVERT(datetime, '1/1/2016', 101) and fe_credito < CONVERT(datetime, '6/1/2017', 101) and nro_banco in (170) " &
    '    "Group by lausana.dbo.finac_fin_mes(fe_credito), cast(day(lausana.dbo.finac_fin_mes(fe_credito)) as varchar(4)) + '/' + CAST(MONTH(fe_credito) as varchar(2)), nro_banco, banco " &
    '    "order by fe_credito0"
    'rs = nvDBUtiles.DBOpenRecordset(strSQL)
    'While Not rs.EOF
    '    serie.Points.Add(New DataPoint() With {.XValue = rs.Fields("fe_credito0").Value.ToOADate(), .YValues = New Double() {rs.Fields("suma_importe_bruto").Value}})
    '    '.LegendText = "AMUS", .AxisLabel = rs.Fields("strfe_credito").Value,
    '    Dim d = DirectCast(rs.Fields("fe_credito0").Value, Date)
    '    rs.MoveNext()
    'End While
    'nvDBUtiles.DBCloseRecordset(rs)

    'serie = nvFW.nvChart.CreateSerie(chart, "VOII", DataVisualization.Charting.SeriesChartType.Spline, Color.Gray)
    'strSQL = "select  lausana.dbo.finac_fin_mes(fe_credito) as fe_credito0, cast(day(lausana.dbo.finac_fin_mes(fe_credito)) as varchar(4)) + '/' + CAST(MONTH(fe_credito) as varchar(2)) as strfe_credito, nro_banco, banco, count(*) as cantidad, SUM(importe_bruto)/1000000 as suma_importe_bruto " &
    '                                    "From lausana..wrp_infocredito_base  " &
    '                                    "where estado = 'T' and fe_credito >= CONVERT(datetime, '1/1/2016', 101) and fe_credito < CONVERT(datetime, '6/1/2017', 101) and nro_banco in (800) " &
    '                                    "Group by lausana.dbo.finac_fin_mes(fe_credito), cast(day(lausana.dbo.finac_fin_mes(fe_credito)) as varchar(4)) + '/' + CAST(MONTH(fe_credito) as varchar(2)), nro_banco, banco " &
    '                                    "order by fe_credito0"
    'rs = nvDBUtiles.DBOpenRecordset(strSQL)
    'While Not rs.EOF
    '    serie.Points.Add(New DataPoint() With {.XValue = rs.Fields("fe_credito0").Value.ToOADate(), .YValues = New Double() {rs.Fields("suma_importe_bruto").Value}})
    '    '.LegendText = "VOII", .AxisLabel = rs.Fields("strfe_credito").Value,
    '    Dim d = DirectCast(rs.Fields("fe_credito0").Value, Date)
    '    rs.MoveNext()
    'End While
    'nvDBUtiles.DBCloseRecordset(rs)




    'Me.contents("chartBytes") = ms.GetBuffer()


 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
        

    <% = Me.getHeadInit()%>

  

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >

         <%
             Response.Write("<img src='data:image/jpg;base64," & Convert.ToBase64String(ms.GetBuffer) & "' /></br>")
             Response.Write("<img src='data:image/jpg;base64," & Convert.ToBase64String(ms2.GetBuffer) & "' /></br>")
             'Response.Write(nvFW.nvChart.getHtmlImageAllTypes(chart))

         %>
    

    
    Prueba chart
</body>
</html>
