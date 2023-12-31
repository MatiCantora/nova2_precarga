<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
        xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
		function rellenar0(numero, largo)
			{
			var strNumero
			//debugger
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
        <title>HTML base</title>
        <link href="../css/base.css" type="text/css" rel="stylesheet"/>

        <style>
          .tableFixHead          { overflow-y: auto; height: 100px; }
          .tableFixHead thead th { position: sticky; top: 2px; }

          /* Just common table stuff. Really. */
          /*table  { border-collapse: collapse; width: 100%; }*/
          /*th, td { padding: 8px 16px; }*/
          /*th     { background:#eee; }*/
        </style>

        <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" language="javascript" src="/FW/script/tCampo_head.js"></script>
        <script type="text/javascript" >

          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'

          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>

          var parentName = '<xsl:value-of select="xml/parametros/ABMReportes/@window_parentName"/>'

          <![CDATA[
          if (mantener_origen == '0' && parentName != '')
          campos_head.nvFW = ObtenerVentana(parentName).nvFW
          ]]>

          <!--if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW-->
        </script>

      </head>
      <script>
        <xsl:comment>
          <![CDATA[
						function window_onload() {
              window_onresize();
						}
            
            
            function window_onresize() {
              
              var body = $$('body')[0];
              var divDetalle = $('divDetalle');
              
              //Verificar si hay scroll horizontal
              var scroll_h = 0;
              if (body.getWidth() < divDetalle.getWidth())
                scroll_h = 16;
              
              //Setear alto del div de datos
              divDetalle.setStyle({ height: (body.getHeight() - $('tbPaginacion').getHeight() - $('tbTotales').getHeight() - scroll_h) + 'px'});
            
            }          
            
           
						]]>
        </xsl:comment>
      </script>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
        <div id="divDetalle" class="tableFixHead" style="overflow-x: auto">
          <table class="tb1 highlightOdd highlightTROver" id="tbCabecera">
            <thead>
              <tr class="tbLabel">
                <th style='text-align: center;'>Fila</th>
                <xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
              </tr>
            </thead>
            <tbody>
              <xsl:apply-templates select="xml/rs:data/z:row" />
              <tr class="tbLabel0">
                <td  style="text-align: center">
                  <!--<xsl:value-of select="//xml/params/@recordcount"/>-->-
                </td>
                <xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="totales"/>
              </tr>
            </tbody>
          </table>
        </div>
        <table class="tbPages" id="tbPaginacion" style="height: 21px">
          <tr>
            <td style="width: 100%; height: 21px">
              <div id="div_pag" class="divPages">
                <script type="text/javascript">
                  if (campos_head.PageCount > 1)
                  document.write(campos_head.paginas_getHTML())
                </script>
              </div>
            </td>
            <td nowrap="true" style="height: 21px">
              <xsl:choose>
                <xsl:when test="//xml/params/@PageCount > 1">
                  <xsl:choose>
                    <xsl:when test="//xml/params/@PageCount > //xml/params/@AbsolutePage">
                      Cant. Registros: <xsl:value-of select="//xml/params/@PageSize*//xml/params/@AbsolutePage"/> de <xsl:value-of select="//xml/params/@recordcount"/>
                    </xsl:when>
                    <xsl:otherwise>
                      Cant. Registros: <xsl:value-of select="//xml/params/@recordcount"/> de <xsl:value-of select="//xml/params/@recordcount"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  Cant. Registros: <xsl:value-of select="//xml/params/@recordcount"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </table>

        <table class="tb1" id="tbTotales">
          <xsl:variable name="importe_neto" select="sum(xml/rs:data/z:row/@importe_neto)"/>
          <xsl:variable name="importe_bruto" select="sum(xml/rs:data/z:row/@importe_bruto)"/>
          <xsl:variable name="importe_documentado" select="sum(xml/rs:data/z:row/@importe_documentado)"/>
          <xsl:variable name="importe_cuota" select="sum(xml/rs:data/z:row/@importe_cuota)"/>
          <xsl:if test="$importe_neto > 0">
            <tr>
              <td class="Tit1">Suma importe neto:</td>
              <td style="text-align: right">
                <xsl:value-of select="format-number($importe_neto,'0.00')"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="$importe_bruto > 0">
            <tr>
              <td class="Tit1">Suma importe bruto:</td>
              <td style="text-align: right">
                <xsl:value-of select="format-number($importe_bruto,'0.00')"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="$importe_documentado > 0">
            <tr>
              <td class="Tit1">Suma importe documentado:</td>
              <td style="text-align: right">
                <xsl:value-of select="format-number($importe_documentado,'0.00')"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="$importe_cuota > 0">
            <tr>
              <td class="Tit1">Suma importe cuota:</td>
              <td style="text-align: right">
                <xsl:value-of select="format-number($importe_cuota,'0.00')"/>
              </td>
            </tr>
          </xsl:if>
          <!--<tr >
						<td class="Tit1">Cantidad de registros:</td>
						<td style="text-align: right"	>
							<xsl:value-of select="count(xml/rs:data/z:row)"/>
						</td>
					</tr>-->
        </table>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="s:AttributeType" mode="titulo">
    <th style="white-space: nowrap; text-align: center;">
      <xsl:choose >
        <xsl:when test="@name = 'strNombreCompleto'">
          Apellido y nombre
        </xsl:when>
        <xsl:when test="@name = 'strDomicilioCompleto'">
          Domicilio
        </xsl:when>
        <xsl:when test="@name = 'nro_credito'">
          N� cr�dito
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
        <xsl:otherwise>
          <script type="text/javascript">
            campos_head.agregar('<xsl:value-of select="@name"/>', true, '<xsl:value-of select="@name"/>')
          </script>
          <!--<xsl:value-of select="@name"/>-->
        </xsl:otherwise>
      </xsl:choose>
    </th>
  </xsl:template>

  <xsl:template match="s:AttributeType" mode="totales">
    <xsl:choose >
      <xsl:when test="@name = 'importe_neto'">
        <td style="text-align: right">
          <xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_neto),'#.00')"/>
        </td>
      </xsl:when>
      <xsl:when test="@name = 'importe_bruto'">
        <td style="text-align: right">
          <xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_bruto),'#.00')"/>
        </td>
      </xsl:when>
      <xsl:when test="@name = 'importe_cuota'">
        <td style="text-align: right">
          <xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_cuota),'#.00')"/>
        </td>
      </xsl:when>
      <xsl:when test="@name = 'importe_documentado'">
        <td style="text-align: right">
          <xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_documentado),'#.00')"/>
        </td>
      </xsl:when>
      <xsl:otherwise>
        <td>-</td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- datos/detalle -->
  <xsl:variable name="cantRegistros" select="(//xml/params/@PageSize)*((//xml/params/@AbsolutePage)-1)"/>
  <xsl:template match="z:row">
    <tr>
      <td  style='text-align: center;'>
        <!--numero de fila-->
        <xsl:value-of select="format-number(position() + ($cantRegistros), '00000')"/>
      </td>
      <!--<xsl:apply-templates  select="@*"/>-->
      <xsl:variable name="fila" select="."/>
      <xsl:for-each select="/xml/s:Schema/s:ElementType/s:AttributeType"  >
        <td nowrap="true">
          <xsl:variable name="attr" select="@name" />
          <xsl:variable name="valor" select="string($fila/@*[name() = $attr])"/>
          <xsl:variable name="existe" select="count($fila/@*[name() = $attr])"/>

          <xsl:variable name="tipo_dato" select="./s:datatype/@dt:type" />

          <xsl:choose>
            <xsl:when test="$existe=0">NULL</xsl:when>
            <xsl:otherwise>

              <xsl:choose>
                <xsl:when test="$tipo_dato = 'dateTime'">
                  <xsl:attribute name="style">
                    text-align: right;
                  </xsl:attribute>
                  <xsl:value-of select="concat(foo:FechaToSTR(string($valor)),' ',foo:HoraToSTR(string($valor)))" />
                </xsl:when>
                <xsl:when test="$tipo_dato = 'int'">
                  <xsl:attribute name="style">
                    text-align: right;
                  </xsl:attribute>
                  <xsl:value-of select="$valor"/>
                </xsl:when>
                <xsl:when test="$tipo_dato = 'i2'">
                  <xsl:attribute name="style">
                    text-align: right;
                  </xsl:attribute>
                  <xsl:value-of select="$valor"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$valor"/>
                </xsl:otherwise>
              </xsl:choose>

              <!--<xsl:value-of select="$valor"/>-->

            </xsl:otherwise>
          </xsl:choose>

        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>


  <xsl:template match="@nro_credito">
    <xsl:variable name="nro_credito" select='.'/>
    <td style='text-align: center'>
      <a target="_blank">
        <xsl:attribute name="href">
          ../MostrarCredito.asp?nro_credito=<xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:value-of  select="format-number(.,'0000000')" />
      </a>
    </td>
  </xsl:template>
  <xsl:template match="@nro_docu">
    <td>
      <xsl:variable name="tipo_docu" select="../@tipo_docu"/>
      <a  target="_blank">
        <xsl:attribute name="href">
          ../MostrarDatosPersona.asp?tipo_docu=<xsl:value-of select="../@tipo_docu"/>&amp;nro_docu=<xsl:value-of select="../@nro_docu"/>&amp;sexo=<xsl:value-of select="../@sexo"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="$tipo_docu = 3">
            DNI
          </xsl:when>
          <xsl:when test="$tipo_docu = 2">
            LC
          </xsl:when>
          <xsl:when test="$tipo_docu = 1">
            LE
          </xsl:when>
          <xsl:when test="$tipo_docu = 4">
            CI
          </xsl:when>
          <xsl:when test="$tipo_docu = 5">
            PASS
          </xsl:when>
          <xsl:otherwise>
            Desconocido
          </xsl:otherwise>
        </xsl:choose>
        - <xsl:value-of  select="." />
      </a>
    </td>
  </xsl:template>
  <xsl:template match="@strNombreCompleto">
    <td style="white-space: nowrap">
      <a  target="_blank">
        <xsl:attribute name="href">
          ../MostrarDatosPersona.asp?tipo_docu=<xsl:value-of select="../@tipo_docu"/>&amp;nro_docu=<xsl:value-of select="../@nro_docu"/>&amp;sexo=<xsl:value-of select="../@sexo"/>
        </xsl:attribute>
        <xsl:value-of  select="." />
      </a>
    </td>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:variable name="tipo_dato" select="." />
    <td style="text-align: right">
      <xsl:value-of  select="." />
    </td>
  </xsl:template>
</xsl:stylesheet>