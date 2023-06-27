<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[
    
            function rellenar_izq(numero, largo, relleno)
			{
			if (typeof(numero) == 'object')
			  numero = String(numero)
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(0, largo)
			while(strNumero.length < largo)
			  strNumero = relleno + strNumero.toString() 
			return strNumero.toString() 
			}
			
            function rellenar_der(numero, largo, relleno)
			{
			if (typeof(numero) == 'object')
			  numero = String(numero)
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(0, largo)
			  
			while(strNumero.length < largo)
			  strNumero = strNumero.toString() + relleno
			return strNumero.toString() 
			}
			
            function veraz_saldo_acreedor(numero, largo, relleno)
			{
			    numero = parseInt(numero)
			    if (numero < 0)
			        numero = 0
			    return rellenar_der(numero, largo, relleno).toString()
			}
			
            function veraz_validar_apeynom(cadena, largo, relleno)
            {
                cadena = cadena.toUpperCase()
                cadena = cadena.replace('Ñ', 'N')
                cadena = cadena.replace('Á', 'A')
                cadena = cadena.replace('À', 'A')
                cadena = cadena.replace('É', 'E')
                cadena = cadena.replace('È', 'E')
                cadena = cadena.replace('Í', 'I')
                cadena = cadena.replace('Ì', 'I')
                cadena = cadena.replace('Ó', 'O')
                cadena = cadena.replace('Ò', 'O')
                cadena = cadena.replace('Ú', 'U')
                cadena = cadena.replace('Ù', 'U')
                cadena = cadena.replace('Ü', 'U')
                var patron = new RegExp("^([A-Z\\s\'\,])*$")
                var resultado = ''
 
 
                if (patron.test(cadena))
                    return rellenar_der(cadena, largo, relleno).toString()
                else
                {
                    for(var i=0; i<cadena.length; i++)
                    {
                        if (patron.test(cadena.charAt(i)) == true) 
                            resultado += cadena.charAt(i)
                    }
                    return rellenar_der(resultado, largo, relleno).toString()
                }
            }
            
            function veraz_validar_cadena_gral(cadena, largo, relleno)
            {
                cadena = cadena.toUpperCase()
                cadena = cadena.replace('.', ' ')
                cadena = cadena.replace('Ñ', 'N')
                cadena = cadena.replace('Á', 'A')
                cadena = cadena.replace('À', 'A')
                cadena = cadena.replace('É', 'E')
                cadena = cadena.replace('È', 'E')
                cadena = cadena.replace('Í', 'I')
                cadena = cadena.replace('Ì', 'I')
                cadena = cadena.replace('Ó', 'O')
                cadena = cadena.replace('Ò', 'O')
                cadena = cadena.replace('Ú', 'U')
                cadena = cadena.replace('Ù', 'U')
                cadena = cadena.replace('Ü', 'U')
                var patron = new RegExp("^([A-Z0-9\\s\-\/])*$")
                var resultado = '' 
 
                if (patron.test(cadena))
                    return rellenar_der(cadena, largo, relleno).toString()
                else
                {
                    for(var i=0; i<cadena.length; i++)
                    {
                        if (patron.test(cadena.charAt(i)) == true) 
                            resultado += cadena.charAt(i)
                    }
                    return rellenar_der(resultado, largo, relleno).toString()
                }
            }
            
            function veraz_validar_telefono(cadena, largo, relleno)
            {
                var patron = new RegExp("^([0-9])*$") 
                var resultado = ''
 
                if (patron.test(cadena))
                    return rellenar_der(cadena, largo, relleno)
                else
                {
                    for(var i=0; i<cadena.length; i++)
                    {
                        if (patron.test(cadena.charAt(i)) == true) 
                            resultado += cadena.charAt(i)
                    }
                    return rellenar_der(resultado, largo, relleno).toString()
                }
            }
		
        ]]>
    </msxsl:script>
    
	<xsl:output method="text" />
	<xsl:template match="/">
        <xsl:value-of  select="xml/rs:data/z:row/@nro_matriz" /><!-- BUN-HDR-MATRIZ (6): Identificación del adherente, proporcionada por Veraz -->
        <xsl:text>HHHHHH</xsl:text><!-- BUN-HDR-TIPO-REG (6): es una constante-->
        <xsl:text>1P</xsl:text><!-- BUN-HDR-TIPO (2): Tipo de información que se envia = Préstamos en Cuotas -->
        <xsl:text>ALTAS</xsl:text><!-- BUN-HDR-ARCHIVO (5): es una constante -->
        <xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@fecha_grabacion), 8, ' ')"/><!-- BUN-HDR-FECHA-GRABACION (8): Fecha de grabación del archivo en formato AAAAMMDD -->
        <xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@hora_grabacion), 6, ' ')"/><!-- BUN-HDR-HORA-GRABACION (6): Hora de grabación del archivo en formato HHMMSS-->
        <xsl:text>TR</xsl:text><!-- BUN-HDR-MEDIO (2): Soporte de la información = TR (transferencia FTP) -->
        <xsl:text>000000</xsl:text><!-- BUN-HDR-BLOQUEO (6): Si el soporte es CD (CD-ROM) o FT (File Transfer) informar el campo en ceros -->
        <xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@periodo_informacion), 6, ' ')"/><!-- BUN-HDR-PERIODO (6): Período al que pertenece la información en formato AAAAMM -->
        <xsl:text>A</xsl:text><!-- BUN-HDR-CODIFICACION-ORIGEN (1): A (ASCII) o E (EBCDIC) -->
        <xsl:value-of select="foo:rellenar_der('', 2, ' ')"/><!-- BUN-HDR-MARCA (2): Si el tipo de información es "3T (Tarjeta de Crédito)", se indica la marca de la tarjeta (tabulado) -->
        <xsl:value-of select="foo:rellenar_der('', 247, ' ')"/><!-- SIN USO (247) -->
        <xsl:text>Y2K</xsl:text><!-- BUN-HDR-Y2K (3): es una constante -->
        <xsl:text>&#xD;&#xA;</xsl:text>

      
        <xsl:if test="xml/rs:data/z:row/@vacio = '0'">
            <xsl:apply-templates select="xml/rs:data/z:row"/>
        </xsl:if>
  

        <xsl:variable name="cant_reg" select="count(xml/rs:data/z:row)"/>

        <xsl:value-of  select="xml/rs:data/z:row/@nro_matriz" /><!-- BUN-TRL-ADHMATRIZ (6)Identificación del adherente, proporcionada por Veraz -->
        <xsl:text>TTTTTT</xsl:text><!-- BUN-TRL-TIPO-REG (6): es una constante -->
        <xsl:text>1P</xsl:text><!-- BUN-TRL-TIPO (2): Tipo de información que se envia = Préstamos en Cuotas -->
        <xsl:choose>
            <xsl:when test="xml/rs:data/z:row/@vacio = '0'">
                <xsl:value-of select="foo:rellenar_izq(string($cant_reg), 8, '0')"/><!-- BUN-TRL-CANT-REG (8): Cantidad de registros de altas (excluídos header y trailer) -->
            </xsl:when>
            <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
        </xsl:choose>     
        <xsl:value-of select="foo:rellenar_der('', 278, ' ')"/> <!-- SIN USO (278) -->
        <xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template match="z:row">
        <xsl:variable name="bun_adherent_str" select="concat(string(@nro_matriz),string(@nro_sucursal),string(@nro_sector))"/>

        <xsl:value-of select="$bun_adherent_str"/><!-- BUN-ADHERENT (12) -->
        <xsl:text>1P</xsl:text><!-- BUN-TIPO (2): Tipo de información que se envia = Préstamos en Cuotas -->
        <xsl:value-of select="foo:rellenar_der(string(@openro), 20, ' ')"/><!-- BUN-NRO-OPERACION (20): Código identificatorio de cada persona/producto. Unico e invariante en el tiempo. Veraz la usará para actualizar información. -->
        <xsl:text>T</xsl:text><!-- BUN-VINCULACION (1): Relación de la persona con la operación. Titular = T -->
        <xsl:value-of select="foo:rellenar_der(string(@nro_entidad), 20, ' ')"/><!-- BUN-NRO-CLIENTE (20): Facilitar identificación posterior -->
        <xsl:value-of select="foo:rellenar_der('', 1, ' ')"/><!-- SIN USO (1) -->
        <xsl:value-of select="foo:veraz_validar_apeynom(string(@apellido_nombres), 72, ' ')"/><!-- BUN-APELLIDO-Y-NOMBRE (72) -->
        <xsl:value-of select="foo:rellenar_der('', 25, ' ')"/><!-- SIN USO (25) -->
        <xsl:value-of select="foo:rellenar_der(string(@fe_nacimiento), 8, ' ')"/><!-- BUN-FECHA-DE-NACIMIENTO (8): Fecha de nacimiento en formato AAAAMMDD -->
        <xsl:value-of select="foo:rellenar_izq(string(@nro_docu), 11, '0')"/><!-- BUN-NRO-DOCUMENTO-1 (11): Número de documento (DNI) -->
        <xsl:text>00000000000</xsl:text><!-- BUN-NRO-DOCUMENTO-2 (11): Para personas físicas. Puede ser número de cédula o pasaporte. Si no se informa, enviarlos en ceros. -->
        <xsl:text>0</xsl:text><!-- BUN-PCIA-CEDULA (1): Provincia emisora de la cédula -->
        <xsl:value-of select="foo:rellenar_der('', 3, ' ')"/><!-- SIN USO (3) -->
        <xsl:value-of select="@sexo"/><!-- BUN-TIPO-SOCIEDAD (1): Sexo -->
        <xsl:value-of select="@estado_civil"/><!-- BUN-EST-CIVIL (1): Estado Civil -->
        <xsl:value-of select="foo:rellenar_der('', 8, ' ')"/><!-- SIN USO (8) -->
        <xsl:text>S</xsl:text><!-- BUN-MARCA-DIRECCION (1): Se informa la dirección separada en campos -->
        <xsl:value-of select="foo:veraz_validar_cadena_gral(string(@calle), 23, ' ')"/><!-- BUN-CALLE (23) -->
        <xsl:value-of select="foo:veraz_validar_cadena_gral(string(@numero), 10, ' ')"/><!-- BUN-NRO (10) -->
        <xsl:value-of select="foo:veraz_validar_cadena_gral(string(@piso), 6, ' ')"/><!-- BUN-PISO (6): Piso y departamento separado por un guión -->
        <xsl:value-of select="foo:veraz_validar_cadena_gral(string(@localidad), 20, ' ')"/><!-- BUN-LOCALIDAD (20): Nombre de la Localidad. Si la provincia es "C" (Capital Federal), colocar espacios vacíos.  -->
        <xsl:value-of select="foo:rellenar_der(string(@provincia), 1, ' ')"/><!-- BUN-PROVINCIA (1): Código de la Provincia (tabulado) -->
        <xsl:value-of select="foo:rellenar_der(string(@codigo_postal), 8, ' ')"/><!-- BUN-COD-POST (8): Código Postal -->
        <xsl:value-of select="foo:rellenar_der(string(@fe_ingreso), 8, ' ')"/><!-- BUN-FECHA-SERVICIO (8): Fecha en que la persona comenzó relación con la entidad AAAAMMDD -->
        <xsl:value-of select="foo:rellenar_der('', 2, ' ')"/><!-- BUN-CARGO (2): Cargo que ocupa dentro de la sociedad o dejar en blanco -->
        <xsl:value-of select="foo:rellenar_der('', 6, ' ')"/><!-- SIN USO (6) -->
        <xsl:value-of select="foo:rellenar_der('', 2, ' ')"/><!-- BUN-RETORNO (2): Deben ir los espacios -->
        <xsl:value-of select="foo:veraz_validar_telefono(string(@telefono), 14, ' ')"/><!-- BUN-TELEFONO (14): Número de teléfono con DDN, sin guiones, caracteres extraños ni alfabéticos -->
        <xsl:value-of select="foo:rellenar_der(string(@nacionalidad), 1, ' ')"/><!-- BUN-NACIONALIDAD (1): A = Argentina | E = Extranjero | '' = Desconocida -->
        <xsl:value-of select="foo:rellenar_der('', 1, ' ')"/><!-- SIN USO (1) -->
        <xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>