<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
      
		
		
		]]>
	</msxsl:script>
	<xsl:output method="text" encoding="iso-8859-1"/>
	<xsl:template match="/">
		<xsl:if test="count(xml/rs:data/z:row/@or_tipo_cuenta) > 0">
			<xsl:text>*U*</xsl:text>
			<!--Registros únicos ‘*U*’ para lotes de TEF-->
			<xsl:value-of select="foo:rellenar_izq(string(xml/rs:data/z:row/@or_nro_banco_bcra), 3, '0')"/>
			<!--Codigo banco-->
			<xsl:choose>
				<xsl:when test="xml/rs:data/z:row/@or_tipo_cuenta = '0'">
					<xsl:text>02</xsl:text>
				</xsl:when>
				<xsl:when test="xml/rs:data/z:row/@or_tipo_cuenta = '1'">
					<xsl:text>01</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>--***ERROR***--</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="foo:rellenar_izq(string(xml/rs:data/z:row/@or_nro_cuenta), 17, ' ')"/>
			<!--nro_cuenta-->
			<xsl:text>D</xsl:text>
			<!--Indicador de ‘D’ o ‘C’-->
			<xsl:value-of select="foo:formatoYYYYMMDD(string(xml/rs:data/z:row/@fe_solicitud))"/>
			<!--Fecha de solicitud-->
			<xsl:text>S</xsl:text>
			<!--Marca de consolidado “S” o “N”-->
			<xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@tef_obs), 61, ' ')"/>
			<!--Observación del lote-->
			<xsl:text>000</xsl:text>
			<!--triple 0-->
			<xsl:text>00</xsl:text>
			<!--Nro de Cuenta Corto según formato Datanet - Si no conoce el número ingrese 00-->
			<xsl:value-of select="foo:formatoMM_DD_YY(string(xml/rs:data/z:row/@fe_solicitud))"/>
			<!--Fecha archivo-->
			<xsl:value-of select="foo:rellenar_izq(string(xml/rs:data/z:row/@nro_secuencia), 8, '0')"/>
			<!--nro secuencia archivo-->
			<xsl:value-of select="foo:rellenar_izq('', 123, ' ')"/>
			<!--relleno-->
			<xsl:text>&#xD;&#xA;</xsl:text>
			<xsl:apply-templates select="xml/rs:data/z:row"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:text>*M*</xsl:text><!--Registros ‘*M*’ para TEF de Proveedores-->
		<xsl:value-of select="foo:rellenar_izq(string(@des_nro_banco_bcra), 3, '0')"/><!--Codigo banco-->
		<!--<xsl:value-of select="foo:rellenar_izq(string(), 2, '0')"/>tipo_cuenta-->
		<xsl:choose>
			<xsl:when test="@des_tipo_cuenta = '0'"><xsl:text>02</xsl:text></xsl:when>
			<xsl:when test="@des_tipo_cuenta = '1'"><xsl:text>01</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>--***ERROR***--</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="foo:rellenar_izq(string(@des_nro_cuenta), 17, ' ')"/><!--nro_cuenta-->
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@importe_pago)), '15', '0')"/><!--importe Tef int-->
		<!--<xsl:text>,</xsl:text>importe Tef coma decimal-->
		<xsl:value-of select="foo:rellenar_izq(foo:decimal(string(@importe_pago)), '2', '0')"/><!--importe Tef decimales-->
		<!--<xsl:value-of select="foo:rellenar_der(concat(string(@tef_obs),' ',string(@nro_credito)), 60, ' ')"/>--><!--Observación del lote-->
		<xsl:value-of select="foo:rellenar_der(string(@nro_credito),60,' ')"/><!-- Observación de la Transferencia (importante para el upload de comprobantes)-->
		<xsl:value-of select="foo:rellenar_der(string(@tef_doc_a_canc), 2, ' ')"/><!--Documento a Cancelar CC= Cancelacion / CR= Importe en mano credito-->
		<xsl:value-of select="foo:rellenar_der(string(@nro_credito), 12, ' ')"/><!--nro documento a cancelar-->
		<xsl:value-of select="foo:rellenar_der('', 2, ' ')"/><!--Tipo orden de pago-->
		<xsl:value-of select="foo:rellenar_der('', 12, ' ')"/><!--nro orden de pago-->
		<xsl:value-of select="foo:rellenar_der('', 12, ' ')"/><!--codigo cliente-->
		<xsl:value-of select="foo:rellenar_izq('', 2, ' ')"/><!--Tipo de retención (Ej.: 01= IVA / 02=Ganancias /03=Ingresos Brutos / 04= SUSS -->
		<xsl:value-of select="foo:rellenar_izq('', 10, '0')"/><!--Total retenciones-->
		<!--<xsl:text>,</xsl:text>Total retenciones-->
		<xsl:value-of select="foo:rellenar_izq('', 2, '0')"/><!--Total retenciones-->
		<xsl:value-of select="foo:rellenar_der('', 12, ' ')"/><!--nro nota de credito-->
		<xsl:value-of select="foo:rellenar_izq('', 8, '0')"/><!--Importe de la Nota de Crédito-->
		<!--<xsl:text>,</xsl:text>Importe de la Nota de Crédito-->
		<xsl:value-of select="foo:rellenar_izq('', 2, '0')"/><!--Importe de la Nota de Crédito-->
		<xsl:value-of select="foo:rellenar_izq(string(@des_cuit), 11, '0')"/><!--CUIT-->
		<xsl:value-of select="foo:rellenar_izq(string(@des_cbu), 22, '0')"/><!--CBU-->
		<xsl:value-of select="foo:rellenar_izq('', 29, ' ')"/><!--relleno-->
		<xsl:text>&#xD;&#xA;</xsl:text>
		
	</xsl:template>
</xsl:stylesheet>