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
	                            xmlns:foo="http://www.broadbase.com/foo"
                              extension-element-prefixes="msxsl"
                              exclude-result-prefixes="foo"
				                      xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" 
				                      xmlns:user="urn:vb-scripts">

  <xsl:output encoding="UTF-16" omit-xml-declaration="no" method="xml" version="1.0" standalone="yes" />
  <msxsl:script language="vb" implements-prefix="user">
	  <msxsl:assembly name="System.Web" />
		<msxsl:using namespace="System.Web" />
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


        var numHoja = 0;


		    function getHoja()
        {
            numHoja++;
            return "Hoja" + numHoja;
        }


        var fila_tag    = '';
        var filas       = [];
        var columna_tag = '';
        var columnas    = [];


        function cargarValoresMatriz(xml_matriz)
        {
            xml_matriz = OuterXML(xml_matriz);

            // Creacion Objeto XMLDOM
            var oXML     = new ActiveXObject("Microsoft.XMLDOM");
            oXML.async   = false;

            if (oXML.loadXML(xml_matriz))
            {
                // Filas
                fila_tag = oXML.selectSingleNode('matriz/filas').getAttribute('etiqueta');
                var _filas = oXML.selectNodes('matriz/filas/fila');

                for (var i = 0; i < _filas.length; i++)
                {
                    filas[i] = _filas[i].text;
                }

                // Columnas
                columna_tag = oXML.selectSingleNode('matriz/columnas').getAttribute('etiqueta');
                var _columnas = oXML.selectNodes('matriz/columnas/columna');

                for (var i = 0; i < _columnas.length; i++)
                {
                    columnas[i] = _columnas[i].text;
                }
            }

            return getCeldasFila(1);
        }
        
  
        function getCeldasFila(numero_fila)
        {
            var html_celdas = '';
        
            switch (numero_fila)
            {
                case 1:
                    // FILA 1: tiene al combinación de las 2 primeras filas y las 2 primeras columnas en una sola (4 celdas) más la Etiqueta de las Columnas
                    html_celdas += '<Cell ss:MergeAcross="1" ss:MergeDown="1" ss:StyleID="s65"/>';
                    html_celdas += '<Cell ss:MergeAcross="' + (columnas.length - 1) + '" ss:StyleID="s65"><Data ss:Type="String">' + columna_tag + '</Data></Cell>';

                    break;
                    
                case 2:
                    // FILA 2: solo contiene todas las etiquetas de columnas, iniciando desde la columna 3
                    for (var col = 0; col < columnas.length; col++)
                    {
                        html_celdas += '<Cell ' + (col == 0 ? 'ss:Index="3"' : '') + ' ss:StyleID="s64"><Data ss:Type="String">' + columnas[col] + '</Data></Cell>';
                    }

                    break;

                default:
                    // FILA 3 EN ADELANTE: si la 3 ponemos la Etiqueta de las Filas y la primer valor de la fila
                    if (numero_fila == 3)
                    {
                        html_celdas += '<Cell ss:MergeDown="' + (filas.length - 1) + '" ss:StyleID="s65"><Data ss:Type="String">' + fila_tag + '</Data></Cell>';
                        html_celdas += '<Cell ss:StyleID="s64"><Data ss:Type="String">' + filas[numero_fila - 3] + '</Data></Cell>';
                    }
                    else
                    {
                        html_celdas += '<Cell ss:Index="2" ss:StyleID="s64"><Data ss:Type="String">' + filas[numero_fila - 3] + '</Data></Cell>';
                    }

                    break;
            }
            
            return html_celdas.toString();
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
        <Title>Pizarra</Title>
				<Author>Impronta Solutions S.A.</Author>
        <Keywords>Matriz</Keywords>
				<LastAuthor>Impronta Solutions S.A.</LastAuthor>
				<Created></Created>
				<Company>Impronta Solutions S.A.</Company>
				<Version>14.00</Version>
			</DocumentProperties>
			<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
				<DownloadComponents/>
				<LocationOfComponents HRef="file:///\\"/>
			</OfficeDocumentSettings>
			<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
				<WindowHeight>8205</WindowHeight>
				<WindowWidth>12480</WindowWidth>
				<WindowTopX>510</WindowTopX>
				<WindowTopY>585</WindowTopY>
				<ProtectStructure>False</ProtectStructure>
				<ProtectWindows>False</ProtectWindows>
			</ExcelWorkbook>

			<Styles>
			  <Style ss:ID="Default" ss:Name="Normal">
					<Alignment ss:Vertical="Bottom"/>
					<Font ss:FontName="Arial" x:Family="Swiss" ss:Size="10"/>
				</Style>
        <Style ss:ID="s18" ss:Name="Moneda">
					<NumberFormat ss:Format="_ &quot;$&quot;\ * #,##0.00_ ;_ &quot;$&quot;\ * \-#,##0.00_ ;_ &quot;$&quot;\ * &quot;-&quot;??_ ;_ @_ " />
				</Style>
        <Style ss:ID="s20" ss:Name="Porcentual">
					<NumberFormat ss:Format="0%"/>
				</Style>
        <Style ss:ID="s24">
					<NumberFormat ss:Format="Short Date"/>
				</Style>
        <Style ss:ID="s29" ss:Parent="s20">
					<NumberFormat ss:Format="0.000000"/>
				</Style>
        <Style ss:ID="s64">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#A6A6A6"/>
            <Border ss:Position="Left"   ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#A6A6A6"/>
            <Border ss:Position="Right"  ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#A6A6A6"/>
            <Border ss:Position="Top"    ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#A6A6A6"/>
          </Borders>
          <Font ss:Color="#3d3d3d"/>
          <Interior ss:Color="#e9e9e4" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="s65">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:Color="#000000" ss:Bold="1"/>
          <Interior ss:Color="#d0d0d0" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="s66">
          <Font ss:Color="#000000"/>
        </Style>
			</Styles>

      <Worksheet>
        <xsl:attribute name="ss:Name"><xsl:value-of select="foo:getHoja()" /></xsl:attribute>

        <Table x:FullColumns="1" x:FullRows="1">
          <xsl:attribute name="ss:DefaultColumnWidth">80</xsl:attribute>
          <xsl:attribute name="ss:DefaultRowHeight">16</xsl:attribute>
          <xsl:attribute name="ss:ExpandedRowCount"><xsl:value-of select="/xml/Params/@ExpandedRowCount" /></xsl:attribute>
          <xsl:attribute name="ss:ExpandedColumnCount"><xsl:value-of select="/xml/Params/@ExpandedColumnCount" /></xsl:attribute>

          <xsl:choose>
            <!-- La entidad &#62; representa a ">" en HTML -->
            <xsl:when test="count(/xml/parametros/matriz) &#62; 0">
              <!--*****************************************************************************
                    Para el armado de éste tipo de tabla, tanto la Fila 1 como la Fila 2
                    mantienen siempre una estructura similar; sólo a partir de la 3er Fila
                    es cuando comienza a cambiar la forma en cómo se dibuja.
                  *****************************************************************************-->

              <!-- Fila 1 -->
                <!-- Al ejecutar cargarValoresMatriz() llenamos los vectores de datos y sus etiquetas; luego devuelve las celdas de la Fila 1 -->
              <Row><xsl:value-of select="foo:cargarValoresMatriz(/xml/parametros/matriz)" disable-output-escaping="yes" /></Row>

              <!-- Fila 2: todas las etiquetas de columnas -->
              <Row><xsl:value-of select="foo:getCeldasFila(2)" disable-output-escaping="yes" /></Row>

              <!-- Fila 3 en adelante, las dibujamos desde los z:row -->
              <xsl:apply-templates select="xml/rs:data/z:row" />
            </xsl:when>
          
            <xsl:otherwise>
              <!--*****************************************************************************
                    Si llegó acá es porque no se pasó la estructura XML para el armado de las 
                    cabeceras y sus datos, o bien está mal formado.
                    Dejamos una celda con un mensaje alusivo para que se realice un chequeo.
                  *****************************************************************************-->
              <Row>
                <Cell>
                  <Data ss:Type="String">No se proporcionaron datos. Revise que la estructura "xml/parametros/matriz" existe y no contiene errores.</Data>
                </Cell>
              </Row>
            </xsl:otherwise>
          </xsl:choose>

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

	<xsl:template match="z:row">
		<xsl:variable name="pos" select="position()" />

    <Row>
      <!-- A) Pedimos a la función que nos retorne la/las celdas iniciales -->
      <!-- Aquí "$pos" inicia en 1, pero nuestra función arma las celdas para cada z:row desde la Fila 3 
           en el fichero Excel final, por lo tanto le sumamos "2" a la posición actual, ya que la Fila 1
           y la Fila 2 se arman por fuera de éste bucle de "z:row's".-->

      <xsl:value-of select="foo:getCeldasFila(number($pos) + 2)" disable-output-escaping="yes" />

      <!-- B) Dibujamos el resto de los valores para cada "Celda" -->
			<xsl:variable name="fila" select="." />

      <xsl:for-each select="/xml/s:Schema/s:ElementType/s:AttributeType">

				<xsl:variable name="attr"      select="@name" />
				<xsl:variable name="valor"     select="string($fila/@*[name() = $attr])" />
				<xsl:variable name="tipo_dato" select="./s:datatype/@dt:type" />

				<xsl:choose>

          <xsl:when test="$tipo_dato = 'dateTime'">
						<Cell ss:StyleID="s24">
							<!--<Data ss:Type="DateTime">2005-10-21T00:00:00.000</Data>-->
							<xsl:if test="$valor != ''">
								<Data ss:Type="DateTime"><xsl:value-of select="substring($valor, 1, 19)" />.000</Data>
							</xsl:if>
						</Cell>
					</xsl:when>

          <xsl:when test="$tipo_dato = 'int' or $tipo_dato = 'i2' or $tipo_dato = 'ui1'">
						<Cell>
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number"><xsl:value-of select="$valor" /></Data>
							</xsl:if>
						</Cell>
					</xsl:when>

					<xsl:when test="$tipo_dato = 'number'">
						<Cell ss:StyleID="s18">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number"><xsl:value-of select="$valor" /></Data>
							</xsl:if>
						</Cell>
					</xsl:when>

					<xsl:when test="$tipo_dato = 'float'">
						<Cell ss:StyleID="s29">
							<xsl:if test="$valor != ''">
								<Data ss:Type="Number"><xsl:value-of select="$valor" /></Data>
							</xsl:if>
						</Cell>
					</xsl:when>

					<xsl:otherwise>
						<Cell >
							<Data ss:Type="String"><xsl:value-of select="$valor" /></Data>
						</Cell>
					</xsl:otherwise>

				</xsl:choose>
			</xsl:for-each>
		</Row>
	</xsl:template>

</xsl:stylesheet>