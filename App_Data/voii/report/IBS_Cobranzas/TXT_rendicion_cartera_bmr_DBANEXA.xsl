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
	<xsl:output method="text" />
  <xsl:template match="/">
    <xsl:variable name="cant_filas" select="count(xml/rs:data/z:row)"/>
    <xsl:value-of  select="foo:rellenar_izq(string($cant_filas),18,0)" />
    <xsl:variable name="suma_importe_retener" select="sum(xml/rs:data/z:row/@importe_retener)"/>
    <xsl:value-of  select="foo:rellenar_con_decimales(string($suma_importe_retener),2,'izq','0',18)" />
    <xsl:variable name="suma_importe_pagado" select="sum(xml/rs:data/z:row/@importe_pagado)"/>
    <xsl:value-of  select="foo:rellenar_con_decimales(string($suma_importe_pagado),2,'izq','0',18)" />
    <xsl:text>000000000000000000000000000000000000000000000000000000</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>

    <xsl:apply-templates select="xml/rs:data/z:row" />

  </xsl:template>
	
	<xsl:template match="z:row">
    <xsl:value-of select="foo:rellenar_izq(string(@grupo_afinidad),6,0)"/>
    <xsl:value-of select="foo:rellenar_izq(string(@tipo_docu),1,0)"/>
    <xsl:value-of select="foo:rellenar_izq(string(@documento),8,0)"/>
    <xsl:value-of select="foo:rellenar_der(string(@nombre),30,' ')"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@importe_retener),2, 'izq','0', 10)"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@capital_otorgado),2, 'izq','0', 10)"/>
    <xsl:value-of select="foo:rellenar_izq(string(@periodo),6,' ')"/>
    <xsl:value-of select="foo:rellenar_izq(string(@cuota_liquidada),3,'0')"/>
    <xsl:value-of select="foo:rellenar_izq(string(@cuotas_totales),3,'0')"/>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_prestamo),10,'0')"/>
    <xsl:value-of select="foo:rellenar_izq(string(@cuil),11,'0')"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@importe_pagado),2, 'izq','0', 10)"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>