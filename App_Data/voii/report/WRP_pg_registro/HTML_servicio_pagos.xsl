<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
			{
			var strNumero
			debugger
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}
		 
		]]>
		 </msxsl:script>

		 <xsl:template match="/">
			 <html>
				 <head>
					 <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
					 <link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet"/>
					 <script type="text/javascript" src="../../meridiano/script/prototype.js"></script>
					 <script language="javascript" type="text/javascript">
					 </script>
				 </head>
				 <body style="width:100%; height:100%; overflow:auto">
						 <table id="tbTitulo" class="tb1" style="height:100%">
							 <xsl:apply-templates select="xml/rs:data/z:row"/>
						 </table>
					 
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:variable name="nro_entidad_origen" select="@nro_entidad_origen"/>
		<xsl:variable name="pos" select="position()"/>
		<xsl:variable name="nro_entidad_origen_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@nro_entidad_origen"/>

		<xsl:choose>
			<xsl:when test="$nro_entidad_origen != $nro_entidad_origen_ant or $pos = 1">
				<tr>
					<td colspan="7">&#160;</td>
				</tr>
				<tr>
					
					<td class="Tit1" colspan="1" style="width: 92px">Entidad Origen:</td>
						<td style="font-weight:bold" colspan="1">
							<xsl:value-of  select="@strNombreCompleto" />
						</td>
					
					<td class="Tit1" colspan="1" style="width: 92px">Servicio:</td>
					
					<td style="font-weight:bold" colspan="2">
						<xsl:value-of  select="@srv_tipo" /> - <xsl:value-of  select="@srv_desc" />
				    </td>
					<td colspan="1">
						F.Acont.:
						<xsl:value-of  select="@parametro_valor" />
				   </td>
				</tr>
					<tr class="tbLabel">
						<td style='text-align: center; width: 92px'>Nro. Auto</td>
						<td style='text-align: center; width: 222px'>Entidad Destino</td>
						<td style='text-align: center; width: 122px'>Concepto</td>
						<td style='text-align: center; width: 180px'>Tipo de Pago</td>
						<td style='text-align: center;'>Descripción</td>
						<td style='text-align: center; width: 102px'>Importe</td>
					</tr>
						<tr>
							<td style='text-align: center; width: 90px'>
								<xsl:value-of select="@nro_credito"/>
							</td>
							<td style='text-align: left; width: 220px'>
								<xsl:value-of  select="@razon_social" />
							</td>
							<td style='text-align: left; width: 120px'>
								<xsl:value-of  select="@pago_concepto" />
							</td>
							<xsl:if test="@nro_pago_estado = 1">
								<td>
									<xsl:attribute name="style">text-align: left; width: 180px; color:blue !Important</xsl:attribute>
  									<xsl:value-of  select="@pago_tipo" />(<xsl:value-of  select="@pago_estados" />)
								</td>
							</xsl:if>
							<xsl:if test="@nro_pago_estado != 1">
								<td>
									<xsl:attribute name="style">text-align: left; width: 180px;</xsl:attribute>
									<xsl:value-of  select="@pago_tipo" />(<xsl:value-of  select="@pago_estados" />)
								</td>
							</xsl:if>
							<td style='text-align: left'>
									<xsl:value-of  select="@detalle_descripcion" />
								</td>
								<td style='text-align: right; width: 100px'>
									<xsl:value-of  select="format-number(@importe_param,'$  #0.00')" />
								</td>
							</tr>
						</xsl:when>
						<xsl:when test="$nro_entidad_origen = $nro_entidad_origen_ant">
							<tr>
								<td style='text-align: center; width: 90px'>
									<xsl:value-of select="@nro_credito"/>
								</td>
								<td style='text-align: left; width: 220px'>
									<xsl:value-of  select="@razon_social" />
								</td>
								<td style='text-align: left; width: 120px'>
									<xsl:value-of  select="@pago_concepto" />
								</td>
								<xsl:if test="@nro_pago_estado = 1">
									<td>
										<xsl:attribute name="style">text-align: left; width: 180px; color:blue !Important</xsl:attribute>
										<xsl:value-of  select="@pago_tipo" />(<xsl:value-of  select="@pago_estados" />)
									</td>
								</xsl:if>
								<xsl:if test="@nro_pago_estado != 1">
									<td>
										<xsl:attribute name="style">text-align: left; width: 180px;</xsl:attribute>
										<xsl:value-of  select="@pago_tipo" />(<xsl:value-of  select="@pago_estados" />)
									</td>
								</xsl:if>
							<td style='text-align: left'>
								<xsl:value-of  select="@detalle_descripcion" />
							</td>
							<td style='text-align: right; width: 100px'>
								<xsl:value-of  select="format-number(@importe_param,'$  #0.00')" />
							</td>
						</tr>
			</xsl:when>	
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>