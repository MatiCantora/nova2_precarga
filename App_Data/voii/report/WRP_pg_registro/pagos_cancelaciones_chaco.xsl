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
		//modo 1 = dd/mm/yyyy
        //modo 2 = mm/dd/yyyy
        //function FechaToSTR(objFecha, modo)
		function FechaToSTR(cadena)
          {
		  var objFecha = parseFecha(cadena)
		  var dia
		  var mes
		  var anio
		  if (objFecha.getDate() < 10)
		     dia = '0' + objFecha.getDate().toString()
		  else
		     dia = objFecha.getDate().toString() 
		  
		  if ((objFecha.getMonth() +1) < 10)
		     mes = '0' + (objFecha.getMonth()+1).toString()
		  else
		     mes = (objFecha.getMonth()+1).toString() 	 
		  anio = objFecha.getFullYear()  
          var modo = 1
          if (modo == 1) 
            return dia + '/' + mes + '/' + anio
          else
            return  mes + '/' + dia + '/' + anio
          }		
					
			function CuentaEntidad(nro_entidad)
			{
			var cta_deposito = 'Efectivo'

			switch (nro_entidad)
			{
			   case '650': 
						cta_deposito="C.A. 26060/06";
			   break				
			   case '1006':
						cta_deposito="C.A. 94350-8";
			   break				
			   case '1007':
						cta_deposito="C.C. 1046/04";
			   break
			   case '1053':
						cta_deposito="C.A. 169791/0";
			   break
			   case '1043':
						cta_deposito="C.A. 613/00";
			   break
			   case '1009':
						cta_deposito="C.A. 23303/10";
			   break
			   case '1010': 
						cta_deposito="C.C. 1698/05";
			   break
			   case '1013': 
						cta_deposito="C.A. 30/142150/8";
			   break
			   case '1014': 
						cta_deposito="C.A. 16857/02";
			   break
			   case '1062': 
						cta_deposito="C.C. 15110/3";
			   break
			   case '589': 
						cta_deposito="C.A. 161650/9";
			   break
			   case '1051': 
						cta_deposito="C.A. 11664/05";
			   break
			   case '1048': 
						cta_deposito="C.C. 1397/08";
			   break
			   case '1016': 
						cta_deposito="C.A. 27223/10";
			   break
			   case '1020': 
						cta_deposito="C.C. 001667/05";
			   break
			   case '1015': 
						cta_deposito="C.A. 28748/02";
			   case '558': 
						cta_deposito="C.C. 29834/04"
			   break
			   case '1028': 
						cta_deposito="C.A. 1645108";
			   break
			   case '1042': 
						cta_deposito="C.A. 168160/5";
			   break
			   case '1029': 
						cta_deposito="C.A. 30/3079908";
			   break
			   case '1030': 
						cta_deposito="C.C. 1606/03";
			   break
			   case '1036'
						: cta_deposito="C.A. 3215302"
			   break
			   case '1156': 
						cta_deposito="C.A. 31821/03";
			   break
			   case '1080': 
						cta_deposito="C.A. 315140/1";
			   break
			   case '425':
						cta_deposito="C.C. 19/2524-00";
			   break
			   case '558':
						cta_deposito="C.A. 298340/4";
			   break
			   default:
						cta_deposito="Efectivo";
			   break;
			}
			return cta_deposito			   
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
 </Styles>
 <Names>
  <NamedRange ss:Name="Datos_cancelaciones"
   ss:RefersTo="=Datos_cancelaciones!R1C1:R22C4"/>
 </Names>
 <Worksheet ss:Name="Datos_cancelaciones">
  <Table ss:ExpandedColumnCount="256" x:FullColumns="1"
   x:FullRows="1" ss:DefaultColumnWidth="60">
   <Row>
    <Cell ss:StyleID="s23"><Data ss:Type="String" x:Ticked="1">Entidad</Data><NamedCell
      ss:Name="Datos_cancelaciones"/></Cell>
	<Cell ss:StyleID="s23"><Data ss:Type="String" x:Ticked="1">Cuenta</Data><NamedCell
      ss:Name="Datos_cancelaciones"/></Cell>	   
   </Row>
	  <xsl:apply-templates select="xml/rs:data/z:row">
		  <xsl:sort order="ascending" select="@razon_social" data-type="text"/>
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
		<xsl:variable name="nro_entidad" select="@nro_entidad"/>
		<xsl:variable name="pos" select="position()"/>
		<xsl:variable name="nro_entidad_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@nro_entidad"/>
		<xsl:choose>
			<xsl:when test="$nro_entidad != $nro_entidad_ant">
				<Row>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String">
							<xsl:value-of select="@razon_social"/>
						</Data>
						<NamedCell
			  ss:Name="Datos_cancelaciones"/>
					</Cell>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String">
							<xsl:value-of select="foo:CuentaEntidad(string(@nro_entidad))"/>
						</Data>
						<NamedCell
			  ss:Name="Datos_cancelaciones"/>
					</Cell>
				</Row>					
			</xsl:when>
			<xsl:otherwise>
				<Row>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String" x:Ticked="1">Nro. Credito</Data>
						<NamedCell
		  ss:Name="Datos_cancelaciones"/>
					</Cell>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String" x:Ticked="1">Apellido y Nombres</Data>
						<NamedCell
		  ss:Name="Datos_cancelaciones"/>
					</Cell>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String" x:Ticked="1">Credito Cancela</Data>
						<NamedCell
				   ss:Name="Datos_cancelaciones"/>
					</Cell>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String" x:Ticked="1">Cuota</Data>
						<NamedCell
				   ss:Name="Datos_cancelaciones"/>
					</Cell>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String" x:Ticked="1">Vence</Data>
						<NamedCell
				   ss:Name="Datos_cancelaciones"/>
					</Cell>
					<Cell ss:StyleID="s23">
						<Data ss:Type="String" x:Ticked="1">Importe</Data>
						<NamedCell
		  ss:Name="Datos_cancelaciones"/>
					</Cell>
				</Row>
				<xsl:apply-templates select="/xml/rs:data/z:row[@nro_entidad = $nro_entida]" mode="registros"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="registros" match="z:row">
		<Row>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@nro_credito"/>
				</Data>
				<NamedCell
	  ss:Name="Datos_cancelaciones"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String" x:Ticked="1">
					<xsl:value-of select="@strNombreCompleto"/>
				</Data>
				<NamedCell
	  ss:Name="Datos_cancelaciones"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@cancela_nro_credito"/>
				</Data>
				<NamedCell
	  ss:Name="Datos_cancelaciones"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@cancela_cuota"/>
				</Data>
				<NamedCell
	  ss:Name="Datos_cancelaciones"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="String" x:Ticked="1">
					<xsl:value-of select="foo:FechaToSTR(string(@cancela_vence))"/>
				</Data>
				<NamedCell
	  ss:Name="Datos_cancelaciones"/>
			</Cell>
			<Cell ss:StyleID="s23">
				<Data ss:Type="Number">
					<xsl:value-of select="@importe_param"/>
				</Data>
				<NamedCell
	  ss:Name="Datos_cancelaciones"/>
			</Cell>
		</Row>		
	</xsl:template>
</xsl:stylesheet>
