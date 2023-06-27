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
				
				var dif = valor - nro_entero
				if (dif > 0)
					return String(Math.floor((valor * 100)))
				else
				return String(nro_entero)
			}
			
		
    ]]>
  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>Envio;NroAut;NroTitular;TipoTitular;TipoDocumento;NroDocumento;ApellidoyNombres;DomicilioCalle;DomicilioNumero;DomicilioPiso;DomicilioDpto;CaracteristicaTelefono;NumeroTelefono;CodigoPostal;Sexo;EstadoCivil;CodIVA;CodigoCUIT;NumeroCUIT;FechadeNacimiento;Ingresos;Localidad;CodDes-RepPub</xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:apply-templates select="xml/rs:data/z:row" />
		<xsl:value-of select="foo:rellenar_izq(string(/xml/rs:data/z:row/@nro_envio),11,'0')"/><xsl:text>;</xsl:text><xsl:value-of select="foo:rellenar_izq('9',9,'9')"/><xsl:text>;</xsl:text><xsl:value-of select="foo:rellenar_izq(foo:valor_control((sum(/xml/rs:data/z:row[@nro_docu > 0]/@nro_docu) div count(/xml/rs:data/z:row[@nro_aut > 0]))*7),8,'0')"/>;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0</xsl:template>
	
	<xsl:template match="z:row">
		<xsl:value-of select="foo:rellenar_izq(string(@nro_envio),11,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_aut),9,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_titular),3,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@tipo_titular),1,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_docu),2,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_docu),11,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@apellido_nombres),40,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@calle),30,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@numero),5,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@dompiso),4,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@domdepto),5,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@cartel),5,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@numtel),9,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@codigo_postal),5,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@sexo),1,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@estado_civil),1,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@cod_iva),2,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_cuit),2,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@CUIT),11,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(foo:formatoDDMMYYYY(string(@fecha_nacimiento)),8,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="format-number(@ingresos * 100, '00000000000')" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_der(string(@localidad),30,' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(0),15,'0')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>