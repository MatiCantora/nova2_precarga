<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
				xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			    xmlns:o="urn:schemas-microsoft-com:office:office"
			    xmlns:x="urn:schemas-microsoft-com:office:excel"
			    xmlns:html="http://www.w3.org/TR/REC-html40"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<msxsl:script language="javascript" implements-prefix="foo">
	</msxsl:script>
	<xsl:output encoding="UTF-16"/>
	<xsl:template match="/">
		<xsl:processing-instruction name="mso-application">progid="Excel.Sheet"</xsl:processing-instruction>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
  <Author>Usuario</Author>
  <LastAuthor>juan pablo ozan</LastAuthor>
  <Created>2014-06-06T17:10:59Z</Created>
  <LastSaved>2014-07-16T12:07:52Z</LastSaved>
  <Version>14.00</Version>
 </DocumentProperties>
 <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
  <AllowPNG/>
 </OfficeDocumentSettings>
 <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>11640</WindowHeight>
  <WindowWidth>20520</WindowWidth>
  <WindowTopX>480</WindowTopX>
  <WindowTopY>240</WindowTopY>
  <ProtectStructure>False</ProtectStructure>
  <ProtectWindows>False</ProtectWindows>
 </ExcelWorkbook>
 <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
   <Borders/>
   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>
  <Style ss:ID="s16">
   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"
    ss:Bold="1"/>
   <Interior ss:Color="#538DD5" ss:Pattern="Solid"/>
  </Style>
  <Style ss:ID="s17">
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
  </Style>
  <Style ss:ID="s18">
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
   <NumberFormat ss:Format="Standard"/>
  </Style>
  <Style ss:ID="s19">
   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
   <NumberFormat ss:Format="Short Date"/>
  </Style>
  <Style ss:ID="s20">
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
   <NumberFormat ss:Format="Short Date"/>
  </Style>
  <Style ss:ID="s21">
   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
  </Style>
  <Style ss:ID="s22">
   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
   <NumberFormat ss:Format="#,##0"/>
  </Style>
  <Style ss:ID="s23">
   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
  </Style>
 </Styles>
 <Worksheet ss:Name="Polizas SMG">
  <Table ss:ExpandedColumnCount="11"  x:FullColumns="1"
   x:FullRows="1" ss:StyleID="s17" ss:DefaultRowHeight="15">
   <Column ss:Index="2" ss:StyleID="s17" ss:AutoFitWidth="0" ss:Width="159"
    ss:Span="8"/>
   <Row ss:Index="3">
    <Cell ss:StyleID="s16"><Data ss:Type="String">Póliza</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Apellido</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Nombre</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Tipo de Documento</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Número de Documento</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Fecha de Nacimiento</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Saldo de Deuda</Data></Cell>
    <Cell ss:StyleID="s16"><Data ss:Type="String">Fecha de originación</Data></Cell>
	<Cell ss:StyleID="s16"><Data ss:Type="String">Numero de crédito</Data></Cell>
	<Cell ss:StyleID="s16"><Data ss:Type="String">Provincia</Data></Cell>
    <Cell ss:StyleID="s16"/>    
   </Row>

 
	  <xsl:apply-templates select="xml/rs:data/z:row">
	  </xsl:apply-templates>
  </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Header x:Margin="0.3"/>
    <Footer x:Margin="0.3"/>
    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
   </PageSetup>
   <Print>
    <ValidPrinterInfo/>
    <HorizontalResolution>600</HorizontalResolution>
    <VerticalResolution>598</VerticalResolution>
   </Print>
   <Selected/>
   <ProtectObjects>False</ProtectObjects>
   <ProtectScenarios>False</ProtectScenarios>
  </WorksheetOptions>
 </Worksheet>
</Workbook>
	</xsl:template>
	<xsl:template match="z:row">
		   <Row>
    <Cell><Data ss:Type="String">
		<xsl:value-of select="@poliza"/>
	</Data></Cell>
    <Cell><Data ss:Type="String">
		<xsl:value-of select="@apellido"/>
	</Data></Cell>
    <Cell><Data ss:Type="String">
		<xsl:value-of select="@nombres"/>
	</Data></Cell>
    <Cell ss:StyleID="s21"><Data ss:Type="String">
		<xsl:value-of select="@tipo_docu"/>
	</Data></Cell>
    <Cell ss:StyleID="s22"><Data ss:Type="Number">
		<xsl:value-of select="@nro_docu"/>
	</Data></Cell>
    <Cell ss:StyleID="s19"><Data ss:Type="string">
		<xsl:value-of select="@fecha_nacimiento" />
	</Data></Cell>
    <Cell ss:StyleID="s18"><Data ss:Type="Number">
		<xsl:value-of select="@saldo_deuda"/>
	</Data></Cell>
    <Cell ss:StyleID="s19"><Data ss:Type="DateTime">
		<xsl:value-of select="@fecha_envio"/>
	</Data></Cell>
    <Cell ss:StyleID="s18">
    <Data ss:Type="String">
		   <xsl:value-of select="@nro_credito"/>
	</Data>
	</Cell>
	<Cell>
		<Data ss:Type="String">
			<xsl:value-of select="@provincia"/>
		</Data>
	</Cell>
    
    <Cell ss:StyleID="s18"/>
   </Row>
		
	</xsl:template>
</xsl:stylesheet>