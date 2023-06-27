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
			    return rellenar_izq(numero, largo, relleno)
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
                    return rellenar_der(cadena, largo, relleno)
                else
                {
                    for(var i=0; i<cadena.length; i++)
                    {
                        if (patron.test(cadena.charAt(i)) == true) 
                            resultado += cadena.charAt(i)
                    }
                    return rellenar_der(resultado, largo, relleno)
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
                    return rellenar_der(cadena, largo, relleno)
                else
                {
                    for(var i=0; i<cadena.length; i++)
                    {
                        if (patron.test(cadena.charAt(i)) == true) 
                            resultado += cadena.charAt(i)
                    }
                    return rellenar_der(resultado, largo, relleno)
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
                    return rellenar_der(resultado, largo, relleno)
                }
            }
		]]>
        </msxsl:script>
    
	<xsl:output method="text" />
	<xsl:template match="/">
        <xsl:value-of  select="xml/rs:data/z:row/@nro_matriz" /><!-- BUA-HDR-MATRIZ (6): Identificación del adherente, proporcionada por Veraz -->
        <xsl:text>HHHHHH</xsl:text><!-- BUA-HDR-TIPO-REG (6): es una constante-->
        <xsl:text>1P</xsl:text><!-- BUA-HDR-TIPO (2): Tipo de información que se envia = Préstamos en Cuotas -->
        <xsl:text>DATOS</xsl:text><!-- BUA-HDR-ARCHIVO (5): es una constante -->
        <xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@fecha_grabacion), 8, ' ')"/><!-- BUA-HDR-FECHA-GRABACION (8): Fecha de grabación del archivo en formato AAAAMMDD -->
        <xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@hora_grabacion), 6, ' ')"/><!-- BUA-HDR-HORA-GRABACION (6): Hora de grabación del archivo en formato HHMMSS-->
        <xsl:text>TR</xsl:text><!-- BUA-HDR-MEDIO (2): Soporte de la información = TR (transferencia FTP) -->
        <xsl:text>000000</xsl:text><!-- BUA-HDR-BLOQUEO (6): Si el soporte es CD (CD-ROM) o FT (File Transfer) informar el campo en ceros -->
        <xsl:value-of select="foo:rellenar_der(string(xml/rs:data/z:row/@periodo_informacion), 6, ' ')"/><!-- BUA-HDR-PERIODO (6): Período al que pertenece la información en formato AAAAMM -->
        <xsl:text>A</xsl:text><!-- BUA-HDR-CODIFICACION-ORIGEN (1): A (ASCII) o E (EBCDIC) -->
        <xsl:value-of select="foo:rellenar_der('', 2, ' ')"/><!-- BUA-HDR-MARCA (2): Si el tipo de información es "3T (Tarjeta de Crédito)", se indica la marca de la tarjeta (tabulado) -->
        <xsl:value-of select="foo:rellenar_der('', 87, ' ')"/><!-- SIN USO (87) -->
        <xsl:text>Y2K</xsl:text><!-- BUA-HDR-Y2K (3): es una constante -->
        <xsl:text>&#xD;&#xA;</xsl:text>

        <xsl:if test="xml/rs:data/z:row/@vacio = '0'">
            <xsl:apply-templates select="xml/rs:data/z:row"/>
        </xsl:if>

        <xsl:variable name="cant_reg" select="count(xml/rs:data/z:row)"/>

        <xsl:value-of  select="xml/rs:data/z:row/@nro_matriz" /><!-- BUA-TRL-ADHCOD (6) -->
        <xsl:text>TTTTTT</xsl:text><!-- BUA-TRL-TIPO-REG (6): es una constante -->
        <xsl:text>1P</xsl:text><!-- BUA-TRL-TIPO (2): Tipo de información que se envia = Préstamos en Cuotas -->
        <xsl:choose>
            <xsl:when test="xml/rs:data/z:row/@vacio = '0'">
                <xsl:value-of select="foo:rellenar_izq(string($cant_reg), 8, '0')"/><!-- BUA-TRL-CANT-REG (8): Cantidad de registros de altas (excluídos header y trailer) -->
                <xsl:value-of select="foo:veraz_saldo_acreedor(string(sum(xml/rs:data/z:row/@saldo_total)), 18, ' ')"/><!-- BUA-TRL-SUMATORIA-CAMPO-4 (18): Suma de los saldos totales -->
            </xsl:when>
            <xsl:otherwise>
				<xsl:value-of select="foo:rellenar_der(string(0), 26, ' ')"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- <xsl:value-of select="foo:rellenar_der(sum(xml/rs:data/z:row/@saldo_total), 18, ' ')"/>BUA-TRL-SUMATORIA-CAMPO-4 (18): Suma de los saldos totales -->
        <xsl:value-of select="foo:rellenar_der('', 100, ' ')"/> <!-- SIN USO (100) -->
        <xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template match="z:row">
        <xsl:variable name="bun_adherent_str" select="concat(string(@nro_matriz),string(@nro_sucursal),string(@nro_sector))"/>
        <!--<xsl:variable name="atraso" select="@ultima_cuota_vencida - @ultima_cuota_paga"/>-->
        <!--<xsl:variable name="cuotas_pendientes" select="@cuotas - @ultima_cuota_paga"/>-->
        <xsl:variable name="cuotas" select="concat(foo:rellenar_izq(string(@cuotas),3,' '),'M /',foo:rellenar_izq(string(@cuotas_pendientes),3,' '))"/>

        <xsl:value-of select="$bun_adherent_str"/><!-- BUA-ADHERENT (12): Identificación del adherente y sus sucursales, proporcionada por Veraz -->
        <xsl:text>1P</xsl:text><!-- BUA-TIPO (2): Tipo de información que se envia = Préstamos en Cuotas -->
        <xsl:value-of select="foo:rellenar_der(string(@openro), 20, ' ')"/><!-- BUA-NRO-OPERACION (20): Código identificatorio de cada persona/producto. Unico e invariante en el tiempo. Veraz la usará para actualizar información. -->
        <xsl:value-of select="foo:rellenar_der(string(@nro_entidad), 20, ' ')"/><!-- BUA-NRO-CLIENTE (20): Facilitar identificación posterior -->
        <xsl:value-of select="foo:rellenar_der('', 6, ' ')"/><!-- BUA-FECHA-ULT-COMPRA (6): Fecha de la última compra realizada solo para Tarjetas de Crédito -->

        <!-- ARREGLAR CAMPO 4.BUA-CAMPO-4 -->
        <!-- BUA-STATUS (1): Tiempo de atraso en el que se encuentra la información (tabulado) -->
        <xsl:value-of select="foo:rellenar_der(string(@estado_cuentas), 1, ' ')"/>
        
        <!--<xsl:choose>
            <xsl:when test="@estado = 'S'"><xsl:text>C</xsl:text></xsl:when>--><!-- Saldado - Operación Cerrada --><!--
            <xsl:when test="@estado = 'T' and @saldo_total = 0"><xsl:text>C</xsl:text></xsl:when>--><!-- Terminado y saldo total igual a 0 - Operación Cerrada --><!--
            <xsl:when test="@estado = 'I'"><xsl:text>I</xsl:text></xsl:when>--><!-- Quiebra - Incobrable o Irrecuperable--><!--
            <xsl:when test="@estado = 'W'"><xsl:text>G</xsl:text></xsl:when>--><!-- Legales - Cuenta en gestión de cobranza extrajudicial--><!--
            <xsl:when test="@estado = 'T' and @saldo_vencido = 0"><xsl:text>0</xsl:text></xsl:when>--><!-- Terminado y saldo vencido igual a 0 - No hizo uso del préstamo. Demasiado nuevo para opinar --><!--
            <xsl:when test="@atraso &lt;= 30"><xsl:text>1</xsl:text></xsl:when>--><!-- Pago Normal. Atraso de hasta 30 días --><!--
            <xsl:when test="@atraso &gt;= 31 and @atraso &lt;= 60"><xsl:text>2</xsl:text></xsl:when>--><!-- Atraso entre 31 y 60 días --><!--
            <xsl:when test="@atraso &gt;= 61 and @atraso &lt;= 90"><xsl:text>3</xsl:text></xsl:when>--><!-- Atraso entre 61 y 90 días --><!--
            <xsl:when test="@atraso &gt;= 91 and @atraso &lt;= 120"><xsl:text>4</xsl:text></xsl:when>--><!-- Atraso entre 91 y 120 días --><!--
            <xsl:when test="@atraso &gt;= 121 and @atraso &lt;= 180"><xsl:text>6</xsl:text></xsl:when>--><!-- Atraso entre 121 y 180 días --><!--
            <xsl:when test="@atraso &gt;= 181"><xsl:text>9</xsl:text></xsl:when>--><!-- Atraso entre 181 y 360 días --><!--
            <xsl:otherwise><xsl:value-of select="foo:rellenar_der('', 1, ' ')"/></xsl:otherwise>
        </xsl:choose>-->

        <xsl:value-of select="foo:rellenar_izq(string(@clase_moneda), 9, ' ')"/><!-- BUA-CAMPO-1 (9): XX/XXBXXX - Clase que describe el préstamo (tabulado) + un espacio en blanco + Tipo de moneda en la cual se concretó al operación (tabulado). Ejemplo: PP/SG ARS (Préstamo Personal/Sin Garantía Pesos Argentinos)  -->

        <xsl:value-of select="foo:veraz_saldo_acreedor(string(@compromiso_mes), 9, '0')"/><!-- BUA-CAMPO-2 (9): Compromiso del mes: indica el monto a pagar ese mes. Importe cuota del mes que genera la información.  -->
        <xsl:value-of select="foo:veraz_saldo_acreedor(string(@capital_solicitado), 9, '0')"/><!-- BUA-CAMPO-3 (9): Capital original del préstamo. Capital solicitado  -->
        <xsl:value-of select="foo:veraz_saldo_acreedor(string(@saldo_total), 9, '0')"/><!-- BUA-CAMPO-4 (9): Saldo total = Saldo total - Saldo Pagado. Es el saldo total de deuda a la fecha de la información. Deberá incluir el saldo vencido e intereses  -->

        <!-- ARREGLAR CAMPO 5.BUA-CAMPO-5 -->
        <xsl:choose>
            <xsl:when test="@estado_cuentas = 'C'">
                <xsl:value-of select="foo:rellenar_izq(string(concat(string(@cuotas),'M /  0')), 9, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="foo:rellenar_izq(string($cuotas), 9, ' ')"/><!-- BUA-CAMPO-5 (9): Total de cuotas (cuotas período refuerzo / cuotas pendientes)  -->
            </xsl:otherwise>
        </xsl:choose>
          
        <xsl:value-of select="foo:veraz_saldo_acreedor(string(@cuota_mes), 9, '0')"/><!-- BUA-CAMPO-6 (9): Cuota/mes. Cuota Mensualizada  -->       
        
        
        <!--<xsl:value-of select="foo:veraz_saldo_acreedor(string(@saldo_vencido), 9, '0')"/>--><!-- BUA-CAMPO-7 (9): Saldo Vencido  -->
        <!--<xsl:choose>
            <xsl:when test="@estado = '5' or (@estado = '1' and @saldo_total = 0)">
                <xsl:value-of select="foo:veraz_saldo_acreedor('0', 9, '0')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="foo:veraz_saldo_acreedor(string(@saldo_vencido), 9, '0')"/>--><!-- BUA-CAMPO-7 (9): Saldo Vencido  --><!--
            </xsl:otherwise>
        </xsl:choose>-->

        <xsl:value-of select="foo:veraz_saldo_acreedor(string(@saldo_vencido), 9, '0')"/><!-- BUA-CAMPO-7 (9): Saldo Vencido  -->
                
        <xsl:value-of select="foo:rellenar_der('', 2, ' ')"/><!-- BUA-RETORNO (2): Es el código de retorno en caso de que el registro sea rechazado. Deben ir los espacios -->
        <xsl:value-of select="foo:rellenar_der('', 1, ' ')"/><!-- BUA-ACTUALIZADO (1): Es para uso interno de OSVA -->
        <xsl:value-of select="foo:rellenar_izq(string(@fecha_informacion), 8, '0')"/><!-- BUN-FECHA-INFORMACION (8): Es el período al que está asociada la información. Debe ser el último día del mes al que pertenece la información AAAAMMDD -->
        <xsl:value-of select="foo:rellenar_der('', 5, ' ')"/><!-- BUA-CAMPO-9 (5):   -->
        <xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>