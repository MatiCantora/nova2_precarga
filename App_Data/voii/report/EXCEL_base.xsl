<?xml version="1.0" encoding="ISO-8859-1"?>
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
				xmlns:user="urn:vb-scripts">

    <xsl:output encoding="UTF-16" omit-xml-declaration="no" method="xml" version="1.0" standalone="yes" />
    <msxsl:script language="vb" implements-prefix="user" >
	    <msxsl:assembly name="System.Web"/>
		<msxsl:using namespace="System.Web"/>
		<![CDATA[
        Public function prueba(xmlColumnheaders) as String
            
            xmlColumnheaders.MoveNext()
            dim a = xmlColumnheaders.Current
            dim trs = xmlColumnheaders.Current.Select("table/tr")
            trs.MoveNext()
           
            return "Algo" & a.outerXML
        end function
		]]>
	</msxsl:script>
    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[
        function OuterXML(xmlColumnheaders)
            {
            xmlColumnheaders.MoveNext()
            var nod = xmlColumnheaders.Current
            var strXML = nod.OuterXml
            return strXML.toString()
            }

        var numHoja = 0
		function getHoja() {
            numHoja++
            return "Hoja" + numHoja
        }
		
        function test_ultima_fila(pos, max) {
            return (pos % max == 0)
        }

        function existe(ar, x, y)
            {
            var res = false
            try
                {
                res = ar[x][y]
                }
            catch(e) {}        
            return res
            }

        function setValue(ar, x, y, valor)
            {
            if (!ar[y]) 
                ar[y] = {}

            ar[y][x] = valor
            return ar
            }

        function setValueDesdeHasta(ar, x_desde, y_desde, x_hasta, y_hasta, valor)
            {
            for (var y = y_desde; y <= y_hasta; y++)
                for (var x = x_desde; x <= x_hasta; x++)
                    ar = setValue(ar, x, y, valor)
            return ar
            }

        function getXindex(ar, fila, tdIndex)
            {
            var x
            for (x = 1; x < 100; x++)
                if (!existe(ar, fila, x))
                    break
            return x
            }

        function arToSTR(ar)
            {
            var strHTML = "<!--"
            for (var y in ar)
                {
                for (var x in ar[y])
                    strHTML += "{" + y + "," + x + "}"
                }
            strHTML += "-->"  
            return strHTML
            }

        function getHTMLHeaders(xmlColumnheaders)
            {
            xmlColumnheaders = OuterXML(xmlColumnheaders)
            var strHTML = ""
            var arValor = {}

            // Creacion Objeto XMLDOM
            var oXML = new ActiveXObject("Microsoft.XMLDOM")
            oXML.async = false
            var fila = 0
            var tdIndex = 0
            var tr_count = 0

            if (oXML.loadXML(xmlColumnheaders))
                {
                var trs = oXML.selectNodes("columnHeaders/table/tr")

                for (var i = 0, maxFilas = trs.length; i < maxFilas; ++i)
                    {
                    var tds = trs[i].selectNodes("td")
                    fila++
                    tdIndex = 0
                    strHTML += "<Row>"
                    
                    tr_count++
                    
                    for (var j = 0, maxCols = tds.length; j < maxCols; ++j)
                        {
                        tdIndex++
                        var first = getXindex(arValor, fila, tdIndex)
                        var rowspan = 1
                        var colspan = 1
                        
                        if (tds[j].getAttribute("rowspan") != null)
                            rowspan = parseInt(tds[j].getAttribute("rowspan"))
                        
                        if (tds[j].getAttribute("colspan") != null)
                            colspan = parseInt(tds[j].getAttribute("colspan"))
                        
                        arValor = setValueDesdeHasta(arValor, first, fila, first + (colspan - 1), fila + (rowspan - 1), "ok") 
                        strHTML += '<Cell ss:StyleID="cell_cab" ss:Index="' + first + '" '
                        
                        if (rowspan > 1)
                            strHTML += "ss:MergeDown='" + (rowspan - 1) + "' "

                        if (colspan > 1)
                            strHTML += "ss:MergeAcross='" + (colspan - 1) + "' "

                        strHTML += "><Data ss:Type='String'>" + tds[j].text + "</Data>" + "</Cell>"
                        }
                    strHTML += "</Row>"   
                    }
                }
                return strHTML.toString()
            }
		]]>
    </msxsl:script>
	
    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes" >&lt;?xml version="1.0" encoding="iso-8859-1"?></xsl:text>
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
					<NumberFormat ss:Format="Short Date"/>
				</Style>
				<Style ss:ID="s29" ss:Parent="s20">
					<NumberFormat ss:Format="0.000000"/>
        </Style>
        <Style ss:ID="s30" >
          <NumberFormat ss:Format="0"/>
        </Style>
        <Style ss:ID="cell_cab">
                    <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
                    <Borders>
                        <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
                        <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
                        <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
                        <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
                    </Borders>
                    <Font ss:FontName="Arial" x:Family="Swiss" ss:Bold="1"/>
                    <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
        </Style>
			</Styles>
		    <Worksheet>
            <xsl:attribute name="ss:Name">
                <xsl:value-of select="foo:getHoja()"/>
            </xsl:attribute> 
				<Table  x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="60">
                    <xsl:choose>
                        <!-- Cabecera normal formada a partir de atributos pasados -->
                        <xsl:when test="count(/xml/parametros/columnHeaders) = 0">
                            <!--<Row ss:StyleID="s22">-->
                            <Row ss:StyleID="cell_cab">
						        <xsl:apply-templates select="//xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
					        </Row>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Cabecera opcional formada con los valores obtenidos desde la etiqueta "parametros" con el sub-tag "columnHeaders" -->
                            <xsl:value-of select="foo:getHTMLHeaders(/xml/parametros/columnHeaders)" disable-output-escaping="yes"/>
                        </xsl:otherwise>
                    </xsl:choose>
					
					<xsl:apply-templates select="xml/rs:data/z:row" />
					<!--
						<Cell ss:StyleID="s18">
							<Data ss:Type="Number">12.25</Data>
						</Cell>
						<Cell ss:StyleID="s24">
							<Data ss:Type="DateTime">2008-04-02T00:00:00.000</Data>
						</Cell>
						<Cell ss:StyleID="s29">
							<Data ss:Type="Number">0.14249999999999999</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">Nombre</Data>
						</Cell>
						<Cell>
							<Data ss:Type="Number">10.5</Data>
						</Cell>
						-->
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
	<xsl:template match="s:AttributeType" mode="titulo">
		<Cell ss:StyleID="cell_cab">
			<Data ss:Type="String">
        <!--<xsl:value-of select="s:datatype/@dt:type" /> - <xsl:value-of select="s:datatype/@rs:precision" /> - <xsl:value-of select="s:datatype/@dt:maxLength" />-->
				<xsl:choose>
					<xsl:when test="@name = 'strNombreCompleto'">
						Apellido y nombre
					</xsl:when>
					<xsl:when test="@name = 'strDomicilioCompleto'">
						Domicilio
					</xsl:when>
					<xsl:when test="@name = 'nro_credito'">
						N� cr�dito
					</xsl:when>
					<xsl:when test="@name = 'importe_neto'">
						$ Neto
					</xsl:when>
					<xsl:when test="@name = 'importe_documentado'">
						$ Documentado
					</xsl:when>
					<xsl:when test="@name = 'importe_bruto'">
						$ Bruto
					</xsl:when>
					<xsl:when test="@name = 'importe_cuota'">
						$ Cuota
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@name"/>
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
          <xsl:when test=" $attr = 'cuecod' or $attr = 'tipopercod' or $attr = 'nrodoc' or $attr = 'nrolote' or $attr = 'valor' ">
            <Cell ss:StyleID="s30">
              <xsl:if test="$valor != ''">
                <Data ss:Type="Number">
                  <xsl:value-of  select="$valor" />
                </Data>
              </xsl:if>
            </Cell>
          </xsl:when>
					<xsl:when test="$tipo_dato = 'dateTime'">
						<Cell ss:StyleID="s24">
							<!--<Data ss:Type="DateTime">2005-10-21T00:00:00.000</Data>-->
							<xsl:if test="$valor != ''">
								<Data ss:Type="DateTime"><xsl:value-of  select="substring($valor, 1, 19)" />.000</Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:when test="$tipo_dato = 'int' or $tipo_dato = 'i2' or $tipo_dato = 'ui1'">
						<Cell>
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number"><xsl:value-of  select="$valor" /></Data>
							</xsl:if>
						</Cell>
					</xsl:when>
          <xsl:when test="($tipo_dato = 'number') and not(($tipo_dato = 'number' and $precision=19 and $maxLength=8) or ($tipo_dato = 'number' and $precision=10 and $maxLength=8))">
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
					<xsl:when test="$tipo_dato = 'float'">
						<Cell ss:StyleID="s29">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number"><xsl:value-of  select="$valor" /></Data>
							</xsl:if>
						</Cell>
					</xsl:when>
					<xsl:otherwise>
						<Cell >
							<Data  ss:Type="String"><xsl:value-of  select="$valor" /></Data>
						</Cell>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</Row>
	</xsl:template>

</xsl:stylesheet>