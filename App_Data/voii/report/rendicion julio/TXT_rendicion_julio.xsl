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




	<!--HEADER-->

	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>1</xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades))"/>
		<xsl:value-of select="substring(foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades)), 1, 6)"/>
		<!--<xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades))"/>-->
		<xsl:value-of select="foo:rellenar_izq(string(/xml/rs:data/z:row/@cuil_bco),11,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(/xml/rs:data/z:row/@nro_convenio),5,'0')"/>
		<xsl:value-of select="foo:rellenar_izq('',119,' ')"/>		
		<xsl:text>&#xD;&#xA;</xsl:text>		
		<xsl:apply-templates select="xml/rs:data/z:row" />
		<xsl:text>9</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(count(/xml/rs:data/z:row/@nro_credito),8,'0')"/>
		<xsl:value-of select="foo:rellenar_con_decimales(sum(/xml/rs:data/z:row/@total),2, 'izq','0', 17)"/>
		<xsl:value-of select="foo:rellenar_izq('',124,' ')"/>
		<!--<xsl:value-of select="foo:entero(count(/xml/rs:data/z:row/@nro_credito))"/>
		<xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital))"/>,<xsl:value-of select="substring(substring-after(sum(/xml/rs:data/z:row/@capital), '.'), 1, 2)"/>
		--><!--<xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital))"/>,<xsl:value-of select="substring(substring-after(sum(/xml/rs:data/z:row/@capital), '.'), 1, 2)"/>--><!--
		<xsl:value-of select="@cuil_bco" />
		<xsl:value-of select="@nro_convenio" />
		<xsl:text>Filler</xsl:text>-->		
		
	</xsl:template>

	<!--REGISTRO COBRANZA-->


	<xsl:template match="z:row">
		<xsl:text>2</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_credito),10,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_cuota),3,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_doc),2,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@cuil),11,' ')"/>
		<xsl:value-of select="foo:rellenar_con_decimales(string(@total),2, 'izq','0', 17)"/>
		<xsl:value-of select="foo:rellenar_con_decimales(string(@capital),2, 'izq','0', 17)"/>
		<xsl:value-of select="foo:rellenar_con_decimales(string(@interes_tot),2, 'izq','0', 17)"/>
		<xsl:value-of select="foo:rellenar_con_decimales(string(@compensatorios),2, 'izq','0', 17)"/>
		<xsl:value-of select="foo:rellenar_con_decimales(string(@punitorios),2, 'izq','0', 17)"/>
		<!--<xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@vencimcuo))"/>-->
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@vencimcuo))"/>
		<!--<xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fe_pago))"/>-->
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@fe_pago))"/>
		<xsl:value-of select="foo:rellenar_izq('',22,' ')"/>	
		<!--<xsl:value-of select="string(@nro_credito)"/>
		<xsl:value-of select="string(@nro_cuota)"/>
		<xsl:value-of select="@tipo_doc" />
		<xsl:value-of select="@cuil" />
		<xsl:value-of select="@capital" />
		<xsl:value-of select="@interes_tot" />
		<xsl:value-of select="@compensatorios" />
		<xsl:value-of select="@punitorios" />
		<xsl:text>Fecha de vecnimiento</xsl:text>
		<xsl:text>Fecha de Pago</xsl:text>
		<xsl:text>Filler</xsl:text>-->
		<!--<xsl:value-of select="foo:entero(sum(@capital))" />,<xsl:value-of select="foo:decimal(sum(@capital))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@interes))" />,<xsl:value-of select="foo:decimal(sum(@interes))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@compensatorios))" />,<xsl:value-of select="foo:decimal(sum(@compensatorios))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@punitorios))" />,<xsl:value-of select="foo:decimal(sum(@punitorios))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@gastos))" />,<xsl:value-of select="foo:decimal(sum(@gastos))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@iva))" />,<xsl:value-of select="foo:decimal(sum(@iva))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@otros_servicios))" />,<xsl:value-of select="foo:decimal(sum(@otros_servicios))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@otros_tributos))" />,<xsl:value-of select="foo:decimal(sum(@otros_tributos))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@total))" />,<xsl:value-of select="foo:decimal(sum(@total))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@tipo_pago)" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_operacion)" />-->
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>

	<!--TRAILER-->

	<xsl:template match="eof">
		
	</xsl:template>

</xsl:stylesheet>