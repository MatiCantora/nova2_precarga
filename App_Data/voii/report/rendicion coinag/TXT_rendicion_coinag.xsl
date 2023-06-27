<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:decimal-format name="peso" decimal-separator="," grouping-separator="." />

	<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
			function parte_entera(valor)
				{
				var suma=parseInt(valor)
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
        
                function decimales(cadena, decimales) { //convierte a string un entero o nro floate con "decimales" cantidad de decimlaes luego de la coma
         
            var cad = String(cadena);
            var partes = new Array();
            var resultado = cadena;

            if (cad != "") {
                partes = cad.split('.');
                if (partes.length > 1) {
                    var p1 = String(partes[1])
                    if (p1.length > decimales) {
                        resultado = String(partes[0]) +  p1.substr(0, decimales)
                    }
                    else {
                        var part1 = ""

                        for (i = 0; i < decimales - p1.length ; i++) {
                            part1 += "0"
                        }
                        partes[1] = p1 + part1
                        resultado = partes[0] +  partes[1]
                    }
					
					
                }else
				{
				 var part1 = ""

                        for (var i = 0; i < decimales ; i++) {
                            part1 += "0"
                        }
                        
                        resultado = cad+part1
				}
            }

            return resultado;

        } //fin de la funcion decimales
        
        function rellenar_con_decimales(cadena, cant_dec, lado, caracter, cant)//dada la cadena rellena con cant_dec, hacia lado, con el caracter 'caracter', cant=cantidad de caracteres a completar 
        {

            if (cadena == null || cadena == '' || cadena == 0 || cadena == '0') {
                cadena = "0.00"
            }

            var res1 = decimales(cadena, cant_dec)
            var resultado = ''
            if (lado == "izq") {
                resultado = rellenar_izq(res1, cant, caracter)
            }
            if (lado == "der") {
                resultado = rellenar_der(res1, cant, caracter)
            }
            return resultado;
        }
		
		 

    ]]>
	</msxsl:script>



	<xsl:template match="/">
    <xsl:text>1</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>30546741636</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text></xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>Banco VOII SA</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:value-of select="count(/xml/rs:data/z:row/@nro_prestamo)"/>
		<xsl:text>;</xsl:text>
    <!--<xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@capital))"/>-->
		<xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital))"/>,<xsl:value-of select="substring(substring-after(sum(/xml/rs:data/z:row/@capital), '.'), 1, 2)"/>
    <xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@interes))"/>,<xsl:value-of select="substring(substring-after(sum(/xml/rs:data/z:row/@interes), '.'), 1, 2)"/>
    <!--<xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@interes))"/>,<xsl:value-of select="substring(substring-after(sum(/xml/rs:data/z:row/@interes), '.'), 1, 2)"/>-->
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades))"/>
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
    <xsl:apply-templates select="/xml/rs:data/z:row" />
  </xsl:template> 
    
	<xsl:template match="z:row">
    <xsl:text>2</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@cuil)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_prestamo),12,'0')"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(@vencimcuo))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_cuota)" />
    <xsl:text>;</xsl:text>
    <!--<xsl:value-of select="foo:entero(sum(@capital))" />,<xsl:value-of select="foo:decimal(sum(@capital))" />-->
		<xsl:value-of select="foo:entero(sum(@capital))"/><xsl:choose><xsl:when test="substring(substring-after(sum(@capital), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@capital), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>

		<!--<xsl:value-of select="substring(substring-after(sum(@capital), '.'), 1, 2)"/>-->
    <xsl:text>;</xsl:text>
    <!--<xsl:value-of select="foo:entero(sum(@interes))" />,<xsl:value-of select="substring(substring-after(sum(@interes), '.'), 1, 2)" />-->
		<xsl:value-of select="foo:entero(sum(@interes_tot))"/><xsl:choose><xsl:when test="substring(substring-after(sum(@interes_tot), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@interes_tot), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@compensatorios))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@compensatorios), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@compensatorios), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
        <!--<xsl:value-of select="substring(substring-after(sum(@compensatorios), '.'), 1, 2)" />-->
		<!--<xsl:value-of select="foo:entero(sum(@compensatorios))" />,<xsl:value-of select="foo:decimal(sum(@compensatorios))" />-->
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@punitorios))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@punitorios), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@punitorios), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<!--<xsl:value-of select="foo:entero(sum(@punitorios))" />,<xsl:value-of select="substring(substring-after(sum(@punitorios), '.'), 1, 2)" />-->
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@gastos))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@gastos), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@gastos), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<!--<xsl:value-of select="foo:entero(sum(@gastos))" />,<xsl:value-of select="substring(substring-after(sum(@gastos), '.'), 1, 2)" />-->
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@iva))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@iva), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@iva), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<!--<xsl:value-of select="foo:entero(sum(@iva))" />,<xsl:value-of select="substring(substring-after(sum(@iva), '.'), 1, 2)" />-->
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@otros_servicios))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@otros_servicios), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@otros_servicios), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<!--<xsl:value-of select="foo:entero(sum(@otros_servicios))" />,<xsl:value-of select="substring(substring-after(sum(@otros_servicios), '.'), 1, 2)" />-->
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@otros_tributos))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@otros_tributos), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@otros_tributos), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<!--<xsl:value-of select="foo:entero(sum(@otros_tributos))" />,<xsl:value-of select="substring(substring-after(sum(@otros_tributos), '.'), 1, 2)" />-->
		<xsl:text>;</xsl:text><xsl:value-of select="foo:entero(sum(@total))" /><xsl:choose><xsl:when test="substring(substring-after(sum(@total), '.'), 1, 2) = ''">,00</xsl:when><xsl:otherwise>,<xsl:value-of select="substring(substring-after(sum(@total), '.'), 1, 2)"/></xsl:otherwise></xsl:choose>
		<!--<xsl:value-of select="foo:entero(sum(@total))" />,<xsl:value-of select="substring(substring-after(sum(@total), '.'), 1, 2)" />-->
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@tipo_pago)" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_operacion)" />
    <xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>