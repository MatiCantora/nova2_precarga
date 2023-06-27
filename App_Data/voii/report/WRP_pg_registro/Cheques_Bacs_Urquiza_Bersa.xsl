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
				<Created>2007-11-14T17:56:14Z</Created>
				<Version>11.5606</Version>
			</DocumentProperties>
			<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
				<WindowHeight>8835</WindowHeight>
				<WindowWidth>15180</WindowWidth>
				<WindowTopX>120</WindowTopX>
				<WindowTopY>105</WindowTopY>
				<ProtectStructure>False</ProtectStructure>
				<ProtectWindows>False</ProtectWindows>
			</ExcelWorkbook>
			<Styles>
				<Style ss:ID="Default" ss:Name="Normal">
					<Alignment ss:Vertical="Bottom"/>
					<Borders/>
					<Font/>
					<Interior/>
					<NumberFormat/>
					<Protection/>
				</Style>
				<Style ss:ID="s24">
					<NumberFormat ss:Format="Short Date"/>
				</Style>				
			</Styles>
			<Worksheet ss:Name="Cheques_bacs_ch9_FI13112007_FF1">
				<Table ss:ExpandedColumnCount="10" ss:ExpandedRowCount="36" x:FullColumns="1"
				 x:FullRows="1" ss:DefaultColumnWidth="60">
					<Column ss:AutoFitWidth="0" ss:Width="21"/>
					<Column ss:AutoFitWidth="0" ss:Width="157.5"/>
					<Column ss:AutoFitWidth="0" ss:Width="21"/>
					<Column ss:AutoFitWidth="0" ss:Width="157.5"/>
					<Column ss:AutoFitWidth="0" ss:Width="63"/>
					<Column ss:AutoFitWidth="0" ss:Width="52.5" ss:Span="1"/>
					<Column ss:Index="8" ss:AutoFitWidth="0" ss:Width="42"/>
					<Column ss:AutoFitWidth="0" ss:Width="262.5"/>
					<Column ss:AutoFitWidth="0" ss:Width="73.5"/>
					<Row>
						<Cell>
							<Data ss:Type="String">ch_lcredito</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">descripcion_linea</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">ch_chequera</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">descripcion_chequera</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">ch_envio</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">nrocred</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">ch_numero</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">ch_fechav</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">ch_orden</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">ch_importe</Data>
						</Cell>
					</Row>
					<xsl:apply-templates select="xml/rs:data/z:row">
						<xsl:sort order="ascending" select="@nro_credito" data-type="number"/>
					</xsl:apply-templates>
				</Table>
				<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
					<PageSetup>
						<Header x:Margin="0"/>
						<Footer x:Margin="0"/>
						<PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"
						 x:Right="0.78740157499999996" x:Top="0.984251969"/>
					</PageSetup>
					<Selected/>
					<ProtectObjects>False</ProtectObjects>
					<ProtectScenarios>False</ProtectScenarios>
				</WorksheetOptions>
			</Worksheet>
		</Workbook>
	</xsl:template>
	<xsl:template match="z:row">
		<Row>
			<Cell>
				<Data ss:Type="Number">1</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">AYUDA ECONOMICA AMUS</Data>
			</Cell>
			<Cell>
				<Data ss:Type="Number">9</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="@cuenta"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="@nro_envio"/> / <xsl:value-of select="@nro_envio_gral"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_credito"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_cheque"/>
				</Data>
			</Cell>
			<Cell ss:StyleID="s24">
				<Data ss:Type="DateTime">
					<xsl:value-of select="@fe_impresion_datetime"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="String">
					<xsl:value-of select="@razon_social"/>
				</Data>
			</Cell>
			<Cell>
				<Data ss:Type="Number">
					<xsl:value-of select="@importe_param"/>
				</Data>
			</Cell>
		</Row>
	</xsl:template>
</xsl:stylesheet>