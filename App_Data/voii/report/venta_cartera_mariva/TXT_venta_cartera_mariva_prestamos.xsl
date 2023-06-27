<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
			
			function parte_entera(valor)
			{
			var suma=parseInt(valor)
			return suma
			}

			function valor_control_old(valor)
			{
			 var suma=String(entero(valor)) + String(decimal(valor))
			 return suma
			}
			
			function valor_control(valor) 
			{
				valor = parseFloat(valor)
				var nro_entero = Math.floor(valor)
				
				dif = valor - nro_entero
				if (dif > 0)
					return String(Math.floor((valor * 100)))
				esle
				return String(nro_entero)
			}


    ]]>
  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:apply-templates select="xml/rs:data/z:row" />
    </xsl:template>
	
	<xsl:template match="z:row">
		<xsl:value-of select="foo:rellenar_izq(string(@cuit_cedente),11,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@nro_prestamo),30,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@tasa),7,'0')"/>
		<xsl:value-of select="format-number(@monto_origen * 100, '000000000000000')"/>
		<xsl:value-of select="format-number(@saldo_capital * 100, '000000000000000')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@cuotas_orig),4,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@fe_liquidacion),8,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@tipo_docu),2,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_docu),11,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@CUIL),11,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@apellido_nombres),80,' ')"/>
		<xsl:value-of select="foo:rellenar_der(string(@calle),20,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@numero),5,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@piso),2,' ')"/>
		<xsl:value-of select="foo:rellenar_der(string(@depto),4,' ')"/>
		<xsl:value-of select="foo:rellenar_der(string(@codigo_postal),8,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@tel_codpais),3,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@tel_cartel),4,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@tel_nro),12,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@cod_act),3,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@caracter_juri),3,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@fecha_nacimiento),8,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@fecha_ingreso_lab),8,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@nacionalidad),1,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@sexo),1,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@estado_civil	),1,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@pep),1,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@pep_fecha_decl),8,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@uif_sujeto_obligado),1,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@uif_sujeto_obligado_fecha),8,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@impuesto_ganancia),1,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@impuesto_val_agre),1,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@mail),60,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@ctf),7,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@base_calculo),3,'0')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>