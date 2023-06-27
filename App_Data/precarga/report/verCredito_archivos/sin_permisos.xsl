<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				
				<title>Archivos</title>
				<link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
        <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
				</head>
				<body style="width:100%;height:100%; overflow:auto">
						<table id="tbCuerpo" class="tb1" >
							<tr class="tbLabel" >
								<td colspan="3">
									<table class="tb1" cellspacing="0" cellpadding="0">
										<tr>
											<td style="text-align:center">
												<b>Información de archivos no disponible</b>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>					
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>