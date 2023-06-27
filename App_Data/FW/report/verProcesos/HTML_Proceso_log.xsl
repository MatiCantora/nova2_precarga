<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />

	<xsl:template match="/">

		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Ver Log del Proceso</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
                <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>

                <script type="text/javascript"  language="javascript" >
                    <![CDATA[
                    function mostrar_creditos(e,nro_credito,link)
                    {
                        var path = "../../meridiano/credito_mostrar.aspx?nro_credito=" + nro_credito
                        var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'

                        $(link).style.color = '#848484'
                        $(link).style.textDecoration = 'underline'
                        $(link).style.cursor = 'pointer'

                        if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                          $(link).href = path;
                        else if (e.shiftKey)//con la tecla "Shift", abre una nueva ventana _blank
                              { 
                                $(link).target = '_blank'
                                $(link).href = path;
                              }else{
                                window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)
                              }
                    }
                    
                    function mostrar_personas(e,nro_docu,nro_credito,link)
                    {
                        if ((nro_docu != '') && (nro_credito != ''))
                        {
                            var rs = new tRS();
                            rs.open(parent.filtro_infocredito, "", "<nro_docu type='igual'>'" + nro_docu + "'</nro_docu><nro_credito type='igual'>'" + nro_credito + "'</nro_credito>")
                            if (!rs.eof()) 
                            {
                                var tipo_docu = rs.getdata('tipo_docu')
                                var documento = rs.getdata('documento')
                                var sexo = rs.getdata('sexo')
                                var nombre_str = rs.getdata('strNombreCompleto')
                                
                                var descripcion = '<b>' + documento + ' ' + nro_docu + ' - ' + nombre_str + '</b>' 
                                var path = "../../meridiano/persona_mostrar.aspx?nro_docu=" + nro_docu + "&tipo_docu=" + tipo_docu + "&sexo=" + sexo + "&modal=1"
                  
                                $(link).style.color = '#848484'
                                $(link).style.textDecoration = 'underline'
                                $(link).style.cursor = 'pointer'
                					        
                                 if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                                     $(link).href = path;
                                 else if (e.shiftKey)//con la tecla "Shift", abre una nueva ventana _blank
                                      { 
                                        $(link).target = '_blank'
                                        $(link).href = path;
                                       }else{
                                            window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)
                                       }
                            }
                        }
                    }
                    
                    ]]>
                </script>

                <script>
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

                    if (mantener_origen == '0')
                        campos_head.nvFW = window.parent.nvFW

                    function window_onresize() {
                        var body = $$("BODY")[0]
                        var altoDiv = body.clientHeight - 50
                        $("divBody").setStyle({height: altoDiv + "px" })

                    campos_head.resize("tbCabe", "tbDetalle")
                    }

                    function window_onload(){
                        window_onresize()
                    }
                </script>
			</head>
			<body onload="window_onload" onresize="window_onresize">
                <table class="tb1  highlightOdd highlightTROver" id="tbCabe">
                    <tr class="tbLabel">
                        <td style='text-align: center; width:55px'>Fila</td>
                        <xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
                    </tr>
                </table>
                <div style="width:100%; " id="divBody">
                    <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
                       <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table>
                </div>
                <script type="text/javascript">
                    document.write(campos_head.paginas_getHTML())
                </script>
                <script type="text/javascript">
                    campos_head.resize("tbCabe", "tbDetalle")
                </script>
            </body>
		</html>
	</xsl:template>

	<xsl:template match="s:AttributeType" mode="titulo">
		<td style="white-space: nowrap; width: 150px">
			<xsl:choose>
				<xsl:when test="@name = 'strNombreCompleto'">
					Apellido y nombre
				</xsl:when>
				<xsl:when test="@name = 'strDomicilioCompleto'">
					Domicilio
				</xsl:when>
				<xsl:when test="@name = 'nro_docu'">
					Documento
				</xsl:when>
				<xsl:when test="@name = 'nro_credito'">
					Nº crédito
				</xsl:when>
				<xsl:when test="@name = 'importe_neto'">
					$ Neto
				</xsl:when>
				<xsl:when test="@name = 'importe_documentado'">
					$ Documentado
				</xsl:when>
				<xsl:when test="@name = 'importe_bruto'">
					$ Bruto
				</xsl:when>
				<xsl:when test="@name = 'importe_cuota'">
					$ Cuota
				</xsl:when>
				<xsl:when test="@name = 'tipo_pago'">
					Tipo Pago
				</xsl:when>
				<xsl:when test="@name = 'serviciosp'">
					Imputado
				</xsl:when>
				<xsl:when test="@name = 'cuotas'">
					Cuotas
				</xsl:when>
				<xsl:when test="@name = 'importe_cuota'">
					Importe Cuota
				</xsl:when>
                <xsl:when test="@name = 'suma_importe'">
                    Suma Importe
                </xsl:when>
                <xsl:otherwise>
					<xsl:value-of select="@name"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	
    <xsl:template match="s:AttributeType" mode="totales">
			<xsl:choose >
				<xsl:when test="@name = 'serviciosp'">
					<td style="text-align: ">
						<xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@serviciosp),'#.00')"/>
					</td>
				</xsl:when>				
				<xsl:when test="@name = 'importe_neto'">
					<td style="text-align: ">
						<xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_neto),'#.00')"/></td>
					</xsl:when>
				<xsl:when test="@name = 'importe_bruto'">
					<td style="text-align: "><xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_bruto),'#.00')"/>
				</td>
				</xsl:when>
				<xsl:when test="@name = 'importe_cuota'">
					<td style="text-align: ">
						<xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_cuota),'#.00')"/>
				</td>
					</xsl:when>
				<xsl:when test="@name = 'suma_importe'">
					<td style="text-align: ">
						<xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@suma_importe),'#.00')"/>
					</td>
				</xsl:when>				
				<xsl:when test="@name = 'importe_documentado'">
					<td style="text-align: "><xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_documentado),'#.00')"/>
				</td>
				</xsl:when>
				<xsl:otherwise>
					<td>-</td>
				</xsl:otherwise>
			</xsl:choose>		
	</xsl:template>
	
    <xsl:template match="z:row">
	  <tr>
		  <td  style='text-align: center;width:55px '>
			  <xsl:value-of select="format-number(position(), '00000')"/>
		  </td>
		  <xsl:apply-templates  select="@*"/>
	  </tr>	  
	
    </xsl:template>
	
    <xsl:template match="@nro_credito">
		<xsl:variable name="nro_credito" select='.'/>
		<td style='text-align: center'>
			<!--<a target="_blank">
				<xsl:attribute name="href">../MostrarCredito.asp?nro_credito=<xsl:value-of select="."/></xsl:attribute>
				<xsl:value-of  select="format-number(.,'0000000')" />
			</a>-->
            <a>
                <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;color: #0000CC !important</xsl:attribute>
                <xsl:attribute name="id">link_mostrar_credito_<xsl:value-of select="."/></xsl:attribute>
                <xsl:attribute name='onclick'>javascript:mostrar_creditos(event,'<xsl:value-of select="."/>','link_mostrar_credito_<xsl:value-of select="."/>')</xsl:attribute>
                <xsl:value-of  select="format-number(.,'0000000')" />
            </a>
		</td>
	</xsl:template>
	
    <xsl:template match="@nro_docu">
		<td>
			<xsl:variable name="tipo_docu" select="../@tipo_docu"/>
            <a  target="_blank">
				<!--<xsl:attribute name="href">../MostrarDatosPersona.asp?tipo_docu=<xsl:value-of select="../@tipo_docu"/>&amp;nro_docu=<xsl:value-of select="../@nro_docu"/>&amp;sexo=<xsl:value-of select="../@sexo"/></xsl:attribute>-->
                <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;color: #0000CC !important</xsl:attribute>
                <xsl:attribute name="id">link_mostrar_persona_<xsl:value-of  select="../@nro_docu" />_<xsl:value-of select="../@nro_credito"/></xsl:attribute>
                <xsl:attribute name='onclick'>javascript:mostrar_personas(event,'<xsl:value-of select="../@nro_docu"/>','<xsl:value-of select="../@nro_credito"/>','link_mostrar_persona_<xsl:value-of  select="../@nro_docu" />_<xsl:value-of select="../@nro_credito"/>')</xsl:attribute>
			    <xsl:choose>
				<xsl:when test="$tipo_docu = 3">DNI</xsl:when>
				<xsl:when test="$tipo_docu = 2">LC</xsl:when>	
				<xsl:when test="$tipo_docu = 1">LE</xsl:when>	
				<xsl:when test="$tipo_docu = 4">CI</xsl:when>
				<xsl:when test="$tipo_docu = 5">PASS</xsl:when>
				<xsl:otherwise>Desconocido</xsl:otherwise>
			    </xsl:choose>
			    - <xsl:value-of  select="." />
			</a>	
		</td>
	</xsl:template>
	
    <xsl:template match="@strNombreCompleto">
		<td style="white-space: nowrap;width:150px">
            <xsl:value-of  select="." />
		</td>
	
    </xsl:template>
	
    <xsl:template match="@*">
		<xsl:variable name="tipo_dato" select="." />
		<td style="text-align: ">
            <xsl:value-of  select="." />
		</td>
	</xsl:template>

</xsl:stylesheet>