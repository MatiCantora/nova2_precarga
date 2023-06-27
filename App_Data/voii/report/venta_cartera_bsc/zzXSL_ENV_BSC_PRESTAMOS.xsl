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
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
				>
	<xsl:output encoding="UTF-16"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
    var numHoja = 0
		function getHoja()
      {
      numHoja++
      return "Hoja" + numHoja
      }
		function test_ultima_fila(pos, max)
      {
      return (pos % max == 0)
      }
	  
	 function getfecha(strfecha)
	 {
	 //CAPITAL20140201
	  var strretorno=""
		 if(strfecha.length == 15)
		 {
			 
			 var aaaa=strfecha.substring(7, 11)
			 var mm=strfecha.substring(11,13 )
			 var dd=strfecha.substring(13,15)
			 strretorno=dd + "/"+ mm + "/" + aaaa
			 
		 }	
		 return strretorno
	 }
	 
	 var numcuota = 0
	 function formatfila1(cadena)
	 {
		var retorno=""
				var str=cadena.substring(0, 7)
			 if(str == "CAPITAL")
			 {
			 numcuota++
			 retorno="Cuota "+numcuota
			 }
			 
			 
	 return retorno
	 }
	 
	function formatfila2(cadena)
	 {
		 var retorno=cadena
			var str=cadena.substring(0, 7)
	
			 if(str == "CAPITAL")
			 {
			 retorno=getfecha(cadena)
			 }
			 
			 if(str == "INTERES")
			 {
			 retorno=""
			 }
	 return retorno
	 }
	 function formatfila3(cadena)
	 {
		var retorno=""
			var str=cadena.substring(0, 7)
	
			 if(str == "CAPITAL")
			 {
			 retorno="Capital"
			 }
			 
			 if(str == "INTERES")
			 {
			 retorno="Interes"
			 }
		return retorno
	 }
	 
		]]>
	</msxsl:script>
	<xsl:template match="/">
		<xsl:processing-instruction name="mso-application">progid="Excel.Sheet"</xsl:processing-instruction>
		<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
		 xmlns:o="urn:schemas-microsoft-com:office:office"
		 xmlns:x="urn:schemas-microsoft-com:office:excel"
		 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
		 xmlns:html="http://www.w3.org/TR/REC-html40">
			<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
				<Author></Author>
				<LastAuthor></LastAuthor>
				<Created></Created>
				<Company>.</Company>
				<Version>10.6839</Version>
			</DocumentProperties>
			<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
				<DownloadComponents/>
				<LocationOfComponents HRef="file:///\\"/>
			</OfficeDocumentSettings>
			<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
				<WindowHeight>8835</WindowHeight>
				<WindowWidth>12780</WindowWidth>
				<WindowTopX>360</WindowTopX>
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
				<Style ss:ID="s18" ss:Name="Moneda">
					<NumberFormat
					 ss:Format="_ &quot;$&quot;\ * #,##0.00_ ;_ &quot;$&quot;\ * \-#,##0.00_ ;_ &quot;$&quot;\ * &quot;-&quot;??_ ;_ @_ "/>
				</Style>
				<Style ss:ID="s20" ss:Name="Porcentual">
					<NumberFormat ss:Format="0%"/>
				</Style>
				<Style ss:ID="s22">
					<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
					<Font x:Family="Swiss" ss:Bold="1"/>
				</Style>
				<Style ss:ID="s24">
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
					<Font ss:FontName="MS Sans Serif" x:Family="Swiss" ss:Size="8.5"/>
					<NumberFormat ss:Format="Short Date"/>
				</Style>
				<Style ss:ID="s29" ss:Parent="s20">
					<NumberFormat ss:Format="0.000000"/>
				</Style>
				<Style ss:ID="s62">
					<Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>
				</Style>
				<Style ss:ID="s63">
					<Alignment ss:Vertical="Bottom"/>
					<Borders/>
					<Font x:Family="Swiss" ss:Bold="1"/>
					<Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>
					<Protection/>
				</Style>
				<Style ss:ID="s77">
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
					<Font ss:FontName="MS Sans Serif" x:Family="Swiss" ss:Size="8.5"/>
					<NumberFormat ss:Format="&quot;$&quot;\ #,##0.00"/>
				</Style>
				<Style ss:ID="s75">
					<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
					<Borders>
						<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
						<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
					</Borders>
					<Font ss:FontName="MS Sans Serif" x:Family="Swiss" ss:Size="8.5"/>
					<NumberFormat/>
				</Style>
			</Styles>
			<Worksheet>
				<xsl:attribute name="ss:Name">
					<xsl:value-of select="foo:getHoja()"/>
				</xsl:attribute>
				<Table  x:FullColumns="1"
				 x:FullRows="1" ss:DefaultColumnWidth="70">
					<Row ss:StyleID="s22">
						<xsl:apply-templates select="//xml/s:Schema/s:ElementType/s:AttributeType" mode="cabecera1"/>
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
						<HorizontalResolution>600</HorizontalResolution>
						<VerticalResolution>600</VerticalResolution>
					</Print>
					<Selected/>
					<Panes>
						<Pane>
							<Number>3</Number>
							<ActiveRow>1</ActiveRow>
						</Pane>
					</Panes>
					<ProtectObjects>False</ProtectObjects>
					<ProtectScenarios>False</ProtectScenarios>
				</WorksheetOptions>
			</Worksheet>

		</Workbook>
	</xsl:template>


	<xsl:template match="s:AttributeType" mode="cabecera1">
		<Cell>

			<Data ss:Type="String">
				<xsl:choose >
					<xsl:when test="@name = 'nro_prestamo'">
						Nº operación
					</xsl:when>
					<xsl:when test="@name = 'fecha_nacimiento'">
						Fecha de nacimiento
					</xsl:when>
					<xsl:when test="@name = 'apellido_nombres'">
						Cliente
					</xsl:when>
					<xsl:when test="@name = 'CUIT'">
						CUIL
					</xsl:when>
					<xsl:when test="@name = 'fe_liquidacion'">
						Fch. liq.
					</xsl:when>
					<xsl:when test="@name = 'cuotas_orig'">
						Cuotas orig.
					</xsl:when>
					<xsl:when test="@name = 'monto_origen'">
						Monto orig.
					</xsl:when>
					<xsl:when test="@name = 'venc_primer_cuota'">
						Vto. 1 cuota
					</xsl:when>
					<xsl:when test="@name = 'venc_ultima_cuota'">
						Vto. ult. cuota
					</xsl:when>
					<xsl:when test="@name = 'cuotas_vig'">
						Cuotas vig.
					</xsl:when>
					<xsl:when test="@name = 'deuda'">
						Deuda
					</xsl:when>
					<xsl:when test="@name = 'deuda_sin_iva'">
						Deuda Sin Iva
					</xsl:when>
					<xsl:when test="@name = 'saldo_capital'">
						saldo de capital
					</xsl:when>
					<xsl:when test="@name = 'monto_cuota'">
						Monto Cuota
					</xsl:when>
					<xsl:when test="@name = 'ingresos'">
						Sueldo
					</xsl:when>
					<xsl:when test="@name = 'organismo'">
						Organismo
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="string(@name)"/>
					</xsl:otherwise>
				</xsl:choose>
			</Data>
		</Cell>
	</xsl:template>

	<xsl:template match="z:row">
		<xsl:variable name="pos" select="position()"/>
		<xsl:if test="foo:test_ultima_fila(position(),  65536)">
			<xsl:text disable-output-escaping="yes">&lt;/Table&gt;</xsl:text>
			<xsl:text disable-output-escaping="yes">&lt;/Worksheet&gt;</xsl:text>
			<xsl:text disable-output-escaping="yes">&lt;Worksheet ss:Name="</xsl:text>
			<xsl:value-of select="foo:getHoja()"/>
			<xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
			<xsl:text disable-output-escaping="yes">&lt;Table  x:FullColumns="1"
           x:FullRows="1" ss:DefaultColumnWidth="60"&gt;
            &lt;Row ss:StyleID="s22"&gt;</xsl:text>
			<xsl:apply-templates select="/xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
			<xsl:text disable-output-escaping="yes">&lt;/Row&gt;</xsl:text>

		</xsl:if>
		<Row>
			<xsl:variable name="fila" select="."/>
			<xsl:for-each select="/xml/s:Schema/s:ElementType/s:AttributeType"> 
				<xsl:variable name="attr" select="@name" />
				<xsl:variable name="valor" select="string($fila/@*[name() = $attr])"/>
				<xsl:variable name="tipo_dato" select="./s:datatype/@dt:type" />
				<xsl:variable name="precision" select="./s:datatype/@rs:precision" />
				<xsl:variable name="maxLength" select="./s:datatype/@dt:maxLength" />
				<xsl:choose>
					<xsl:when test="$tipo_dato = 'dateTime'">
						<Cell ss:StyleID="s24">
							<!--<Data ss:Type="DateTime">2005-10-21T00:00:00.000</Data>-->
							<xsl:if test="$valor != ''">
								<Data ss:Type="DateTime">
									<xsl:value-of  select="substring($valor, 1, 19)" />.000
								</Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:when test="$tipo_dato = 'int' or $tipo_dato = 'i2' or $tipo_dato = 'ui1'">
						<Cell  ss:StyleID="s75">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number">
									<xsl:value-of  select="$valor" />
								</Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:when test="$tipo_dato = 'number'">
						<Cell ss:StyleID="s18">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number">
									<xsl:value-of  select="$valor" />
								</Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:when test="($tipo_dato = 'number' and $precision=19 and $maxLength=8) or ($tipo_dato = 'number' and $precision=10 and $maxLength=8)">
						<!--En Sybase los tipos money se pasan como number(19,8) y los smallmoney como number(10,8) -->
						<Cell ss:StyleID="s18">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number">
									<xsl:value-of  select="$valor" />
								</Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:when test="$tipo_dato = 'float' ">
						<Cell ss:StyleID="s29">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number">
									<xsl:value-of  select="$valor" />
								</Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:otherwise>
						<Cell  ss:StyleID="s77">
							<Data  ss:Type="String">
								<xsl:value-of  select="$valor" />
							</Data>
						</Cell>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</Row>




	</xsl:template>

</xsl:stylesheet>