<%
/*
'This file contains the HTML code to instantiate the Smart Viewer ActiveX.      
'                                                                     
'You will notice that the Report Name parameter references the RDCrptserver10.asp file.
'This is because the report pages are actually created by RDCrptserver10.asp.
'RDCrptserver10.asp accesses session("oApp"), session("oRpt") and session("oPageEngine")
'to create the report pages that will be rendered by the ActiveX Smart Viewer.
'*/
%>
<html>
<head>
    <title>Crystal Reports ActiveX Viewer</title>
    <script type="text/javascript" language="javascript" src="../../meridiano/script/tXML.js"></script>
</head>
<body bgcolor="C6C6C6" onload="return window_onload()" onunload="window_onunload();" leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0">
    <object id="CRViewer" classid="CLSID:460324E8-CFB4-4357-85EF-CE3EBFE23A62" width="100%"
        height="99%" codebase="/crystalreportviewers11/ActiveXControls/ActiveXViewer.cab#Version=11,0,0,893"
        viewastext>
        <param name="EnableRefreshButton" value="1">
        <param name="EnableGroupTree" value="1">
        <param name="DisplayGroupTree" value="1">
        <param name="EnablePrintButton" value="1">
        <param name="EnableExportButton" value="1">
        <param name="EnableDrillDown" value="1">
        <param name="EnableSearchControl" value="1">
        <param name="EnableAnimationControl" value="1">
        <param name="EnableZoomControl" value="1">
    </object>

    <script type="text/javascript" language="javascript">

function window_onload() {
  
	try
	  {
	  var webBroker = new ActiveXObject("CrystalReports11.WebReportBroker.1")
	  var webSource = new ActiveXObject("CrystalReports11.WebReportSource.1")
		webSource.ReportSource = webBroker
		webSource.URL = "RDCrptserver11.asp"
		webSource.PromptOnRefresh = true
		CRViewer.ReportSource = webSource
		
  	CRViewer.ViewReport()
  	}
  catch(e) {
    alert('No se puede mostrar el reporte')
    }
  }

  function window_onunload() 
    {
    //Quitar variables del servidor
    var oXMLHttp = XMLHttpObject()
    oXMLHttp.onreadystatechange = function(e) {
                                              if (this.readyState == 4) 
                                                {
                                                var parseError = XMLParseError(this.responseXML)
                                                }
                                              }
    oXMLHttp.open('GET', 'mostrarReporte_cerrar.asp', false);
    oXMLHttp.send(null)
    }
</script>

</body>
</html>
