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

    <xsl:apply-templates select="xml/rs:data/z:row" />

  </xsl:template>
	
	<xsl:template match="xml/rs:data/z:row">
    <xsl:value-of select="foo:rellenar_izq(string(@nro_lote),15,0)"/>
    <xsl:value-of select="foo:rellenar_izq(string(@cuit_cedente),11,0)"/>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_prestamo),30,0)"/>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_cuota),4,0)"/>
    <xsl:text>3</xsl:text>
	<xsl:value-of select="foo:rellenar_izq(string(@nrodoc),8,'0')"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@importe_total),2, 'izq','0', 15)"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@capital),2, 'izq','0', 15)"/>
	<xsl:value-of select="foo:rellenar_con_decimales(string(@interes),2, 'izq','0', 15)"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@importe_otros),2, 'izq','0', 15)"/>
    <xsl:value-of select="foo:rellenar_con_decimales(string(@gestion_cobranza),2, 'izq','0', 15)"/>
	<xsl:value-of select="foo:rellenar_izq(foo:formatoYYYYMMDD(string(@fecha_pago)),8,'0')"/>
	<xsl:text>1</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(' ',47,' ')"/>
	<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>

  