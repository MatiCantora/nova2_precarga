<?xml version="1.0" encoding="iso-8859-1"?>
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
		<![CDATA[
			
			function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
			
			function formatoDDMMYYYY(fecha_date){	// retorna una fecha a una cadena de formato "dd/mm/yyyy"
				var fecha = parseFecha(fecha_date)
				var fecha_retorno
				
				if (fecha.getDate().toString().length == 1)
					fecha_retorno = '0' + fecha.getDate() + '/'
				else
					fecha_retorno = fecha.getDate().toString() + '/'
					
				if (fecha.getMonth() < 9)
					fecha_retorno += '0' + (fecha.getMonth() + 1) + '/'
				else
					fecha_retorno += (fecha.getMonth() + 1).toString() + '/'
					
				fecha_retorno += fecha.getFullYear().toString()
				
				return fecha_retorno
			}	
			
			function reemplazarCaracterEnCadena(cadena, caracter, carac_reemplazo){		// reemplaza en "cadena" las ocurrencias de "caracter" por "carac_reemplazo"
							
				while (cadena.indexOf(caracter) != -1)
					cadena = cadena.replace(caracter, carac_reemplazo)
					
				return cadena
			}
		]]>
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
  <LastAuthor>HBOSCH</LastAuthor>
  <Created>2007-09-12T13:41:13Z</Created>
  <Version>11.5606</Version>
 </DocumentProperties>
 <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>10830</WindowHeight>
  <WindowWidth>15480</WindowWidth>
  <WindowTopX>360</WindowTopX>
  <WindowTopY>75</WindowTopY>
  <AcceptLabelsInFormulas/>
  <ProtectStructure>False</ProtectStructure>
  <ProtectWindows>False</ProtectWindows>
 </ExcelWorkbook>
 <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
   <Borders/>
   <Font ss:FontName="MS Sans Serif"/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>
  <Style ss:ID="s23">
   <NumberFormat/>
  </Style>
	 <Style ss:ID="s25">
		 <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
		 <Borders>
			 <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
			 <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
			 <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
			 <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
		 </Borders>
		 <Font x:Family="Swiss" ss:Bold="1"/>
		 <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>
		 <NumberFormat
		  ss:Format="_ &quot;$&quot;\ * #,##0.00_ ;_ &quot;$&quot;\ * \-#,##0.00_ ;_ &quot;$&quot;\ * &quot;-&quot;??_ ;_ @_ "/>
	 </Style>	 
 </Styles>
 <Names>
  <NamedRange ss:Name="Control_Cancelaciones_Bacs"
   ss:RefersTo="=Control_Cancelaciones_Bacs!R1C1:R22C4"/>
 </Names>
 <Worksheet ss:Name="Control_Cancelaciones_Bacs">
  <Table ss:ExpandedColumnCount="256" x:FullColumns="1"
   x:FullRows="1" ss:DefaultColumnWidth="60">
   <Column ss:AutoFitWidth="0" ss:Width="60" ss:Span="1"/>
   <Column ss:AutoFitWidth="0" ss:Width="60" ss:Span="252"/>
   <Row>
    <Cell ss:StyleID="s25"><Data ss:Type="String" x:Ticked="1">Nro. Crédito</Data><NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/></Cell>
    <Cell ss:StyleID="s25"><Data ss:Type="String" x:Ticked="1">Apellido y Nombres</Data><NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/></Cell>
    <Cell ss:StyleID="s25"><Data ss:Type="String" x:Ticked="1">Fecha</Data><NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/></Cell>
	<Cell ss:StyleID="s25"><Data ss:Type="String" x:Ticked="1">Importe</Data><NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/></Cell>
	<Cell ss:StyleID="s25"><Data ss:Type="String" x:Ticked="1">Serie</Data><NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/></Cell>
	<Cell ss:StyleID="s25"><Data ss:Type="String" x:Ticked="1">Tasa</Data><NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/></Cell>
   </Row>
	  <xsl:apply-templates select="xml/rs:data/z:row">		 
	  </xsl:apply-templates>   
   </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Header x:Data="&amp;A"/>
    <Footer x:Data="Page &amp;P"/>
    <PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"
     x:Right="0.78740157499999996" x:Top="0.984251969"/>
   </PageSetup>
   <Selected/>
   <Panes>
    <Pane>
     <Number>3</Number>
     <ActiveRow>7</ActiveRow>
     <ActiveCol>2</ActiveCol>
    </Pane>
   </Panes>
   <ProtectObjects>False</ProtectObjects>
   <ProtectScenarios>False</ProtectScenarios>
  </WorksheetOptions>
 </Worksheet>
</Workbook>
	</xsl:template>
	<xsl:template match="z:row">
		<Row>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_credito"/>
				</Data>
				<NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@strNombreCompleto"/>
				</Data>
				<NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="foo:formatoDDMMYYYY(string(@fe_descuento))"/>
				</Data>
				<NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@bacs_saldo_banco"/>
				</Data>
				<NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@nro_serie_romano"/>
				</Data>
				<NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@ptasad"/>
				</Data>
				<NamedCell
      ss:Name="Control_Cancelaciones_Bacs"/>
			</Cell>			
		</Row>
	</xsl:template>
</xsl:stylesheet>
