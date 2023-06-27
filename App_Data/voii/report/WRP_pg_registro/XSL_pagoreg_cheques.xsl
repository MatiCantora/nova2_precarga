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
		<xsl:variable name="nombre_hoja">Hoja 1</xsl:variable>
		<?xml version="1.0" encoding="iso-8859-1"?>
		<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
		 xmlns:o="urn:schemas-microsoft-com:office:office"
		 xmlns:x="urn:schemas-microsoft-com:office:excel"
		 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
		 xmlns:html="http://www.w3.org/TR/REC-html40">
			<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
				<LastAuthor>NO ONE</LastAuthor>
				<Created>2007-05-23T16:53:26Z</Created>
				<Version>11.5606</Version>
			</DocumentProperties>
			<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
				<DownloadComponents/>
			</OfficeDocumentSettings>
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
				<Style ss:ID="s21">
					<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
					<Font x:Family="Swiss" ss:Bold="1"/>
				</Style>
				<Style ss:ID="s22">
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
				</Style>
				<Style ss:ID="s23">
					<Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
					<NumberFormat ss:Format="@"/>
				</Style>
				<Style ss:ID="s27">
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
					<NumberFormat ss:Format="&quot;$&quot;\ #,##0.00"/>
				</Style>
			</Styles>
			<Worksheet>
				<xsl:attribute name="ss:Name">
					<xsl:value-of select="$nombre_hoja"/>
				</xsl:attribute>

				<Table ss:ExpandedColumnCount="13" x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="60">
					<Column ss:AutoFitWidth="0" ss:Width="60"/>
					<Column ss:AutoFitWidth="0" ss:Width="70"/>
					<Column ss:AutoFitWidth="0" ss:Width="90"/>
					<Column ss:AutoFitWidth="0" ss:Width="70"/>
					<Column ss:AutoFitWidth="0" ss:Width="150"/>
					<Column ss:AutoFitWidth="0" ss:Width="70"/>
					<Column ss:AutoFitWidth="0" ss:Width="200"/>
					<Column ss:AutoFitWidth="0" ss:Width="120"/>
					<Column ss:AutoFitWidth="0" ss:Width="120"/>
					<Column ss:AutoFitWidth="0" ss:Width="60"/>
					<Column ss:AutoFitWidth="0" ss:Width="200"/>
					<Column ss:AutoFitWidth="0" ss:Width="80"/>
					<Column ss:AutoFitWidth="0" ss:Width="120"/>
					<Row>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Fecha</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Nro. Envio</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Nro. Envio Gral</Data>
						</Cell>						
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Chequera</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Cta Banco</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Cheque</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Razón Social</Data>
						</Cell>						
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Banco</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Mutual</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Credito</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Apellido y Nombres</Data>
						</Cell>						
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Importe</Data>
						</Cell>
						<Cell ss:StyleID="s21">
							<Data ss:Type="String">Concepto</Data>
						</Cell>
					</Row>
					<xsl:apply-templates select="xml/rs:data/z:row" />
				</Table>
				<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
					<PageSetup>
						<Header x:Margin="0"/>
						<Footer x:Margin="0"/>
						<PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"
						 x:Right="0.78740157499999996" x:Top="0.984251969"/>
					</PageSetup>
					<Print>
						<ValidPrinterInfo/>
						<PaperSizeIndex>9</PaperSizeIndex>
						<HorizontalResolution>600</HorizontalResolution>
						<VerticalResolution>600</VerticalResolution>
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
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="foo:formatoDDMMYYYY(string(@fe_impresion_datetime))"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_envio"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_envio_gral"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@chequera"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@nro_cuenta"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_cheque"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@razon_social"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>			
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@banco"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@mutual"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_credito"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@strNombreCompleto"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s27">
				<Data ss:Type="Number">
					<xsl:value-of select="@importe_pago_detalle"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String">
					<xsl:value-of select="@pago_concepto"/>
				</Data>
				<NamedCell
      ss:Name="Pagos"/>
			</Cell>			
		</Row>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>