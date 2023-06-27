<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				        xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				        xmlns:rs='urn:schemas-microsoft-com:rowset'
				        xmlns:z='#RowsetSchema'
				        xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	              xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />


  <!-- Funciones JavaScript que corren en Server -->
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
      // Pasar Strings a minúsculas
			function strToLower(texto)
      {
        return texto.toString().toLowerCase();
      }


      function rellenar_izq(numero, largo, relleno)
			{
			  if (typeof(numero) === 'object') numero = String(numero);
			  
        var strNumero = numero.toString();
        
			  if (strNumero.length > largo) strNumero = strNumero.substr(1, largo);
        
			  while (strNumero.length < largo)
			    strNumero = relleno + strNumero.toString();

			  return strNumero;
			}


      // Parseo de Fecha
      function parseFecha(strFecha)
			{
			  var a  = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.';
				a      = a.substr(0, a.indexOf('.'));
				var fe = new Date(Date.parse(a));

				return fe;
			}


      /*************************************
       *   MODOS DE FECHA
       *************************************
       *
       *   MODO 1: dd/mm/yyyy
       *   MODO 2: mm/dd/yyyy
       *
       ************************************/

      function FechaToSTR(cadena)
      {
        return FechaToSTR(cadena, 1); // Si no se pasa un modo, por defecto toma "1"
      }


		  function FechaToSTR(cadena, modo)
      {
        if (!modo) modo = 1;  // Modo por defecto

		    var objFecha = parseFecha(cadena);

        if (isNaN(objFecha.getDate())) return '';   // Fecha inválida

        var dia  = rellenar_izq(objFecha.getDate(),      2, "0");
	      var mes  = rellenar_izq(objFecha.getMonth() + 1, 2, "0");
	      var anio = objFecha.getFullYear();

        switch (modo)
        {
          case 1:
            return dia + '/' + mes + '/' + anio;
            break;

          case 2:
            return  mes + '/' + dia + '/' + anio;
            break;

          case 3:
            return  anio + '-' + mes + '-' + dia;
            break;
        }
      }


      function HoraToSTR(cadena)
      {
		    var objFecha = parseFecha(cadena);

        if (isNaN(objFecha.getDate())) return '';

        var hora    = rellenar_izq(objFecha.getHours(),   2, "0");
		    var minuto  = rellenar_izq(objFecha.getMinutes(), 2, "0");
		    var segundo = rellenar_izq(objFecha.getSeconds(), 2, "0");

        return hora + ':' + minuto + ':' + segundo;
      }
		]]>
  </msxsl:script>


  <xsl:template match="/">
    <html>
    <head>
      <title>Listado de Dispositivos</title>
      <link type="text/css" rel="stylesheet" href="/FW/css/base.css" />

      <style type="text/css">
        .sin-datos {
          margin: 0 auto;
          max-width: 840px;
          text-align: center;
        }
        .sin-datos span {
          display: block;
          padding: 10px;
        }
        span.titulo {
          font-size: 2.5em;
          font-weight: bold;
          color: #333;
        }
        span.mensaje {
          font-size: 1.3em;
          color: #888;
        }
        .icon {
          display: inline-block;
          width: 16px;
          height: 16px;
          margin: 0 3px 0 0;
          background-repeat: no-repeat;
          cursor: pointer;
        }
        .icon.png {
          background-image: url('/FW/image/icons/file_png.png');
        }
        .icon.txt {
          background-image: url('/FW/image/icons/file_txt.png');
        }
        tr.valida td {
          background-color: #d4ffd49a;
        }
        tr.invalida td {
          background-color: #ffd4d49a;
        }
      </style>
      
      <script type="text/javascript" src="/FW/script/nvFW.js"></script>
      <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
      <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
            
      <script type="text/javascript">
        var mantener_origen       = '<xsl:value-of select="xml/mantener_origen" />';
        campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen" />';
        campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID" />';
        campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl" />';
        campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount" />;
        campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount" />;
        campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize" />;
        campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage" />;
        campos_head.orden         = '<xsl:value-of select="xml/params/@orden" />';

        if (mantener_origen === '0')
          campos_head.nvFW = window.parent.nvFW;
      </script>
        
      <script type="text/javascript">
        <![CDATA[
        var $body
        var $tbCabecera
        var $divDetalles
        var $tbDetalles
        var $tdScroll
        var $divPaginado


        function windowOnresize()
        {
            try
            {
                var altura = $body.getHeight() - $tbCabecera.getHeight() - $divPaginado.getHeight();
                $divDetalles.style.height = altura + 'px';
                
                $tbDetalles.getHeight() > altura ? $tdScroll.show() : $tdScroll.hide();
            }
            catch(e) {}
        }
                
                
        function cacheElementos()
        {
            $body        = $$('body')[0];
            $tbCabecera  = $('tbCabecera');
            $divDetalles = $('divDetalles');
            $tbDetalles  = $('tbDetalles');
            $tdScroll    = $('tdScroll');
            $divPaginado = $('divPaginado');
        }
                
                
        function windowOnload()
        {
            cacheElementos();
            windowOnresize();
        }
        
        
        function showImage(cod_image)
        {
            parent.showImage(cod_image);
        }
        
        
        function showInfo(cod_image)
        {
            parent.showInfo(cod_image);
        }
        ]]>
      </script>
    </head>
    <body onload="windowOnload()" onresize="windowOnresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF">

      <xsl:choose>
        
        <xsl:when test="count(xml/rs:data/z:row) = 0">
          <div class="sin-datos">
            <span class="titulo">Sin Solicitudes</span>
            <span class="mensaje">La consulta realizada no retornó ningúna solicitud con los filtros proporcionados. Intente con una combinación diferente.</span>
          </div>
        </xsl:when>
        
        <xsl:otherwise>
      
          <table class="tb1 layout_fixed" id="tbCabecera">
            <tr class="tbLabel">
              <td style="min-width: 100px; text-align: center" title="ID Dispositivo">
                <script>campos_head.agregar('ID Dispositivo', 'true', 'ids_deviceid');</script>
              </td>
              <td style="width: 200px; text-align: center" title="Código de Imagen">
                <script>campos_head.agregar('Cod. Imagen', 'true', 'cod_image');</script>
              </td>
              <td style="width: 200px; text-align: center" title="Fecha y Hora">
                <script>campos_head.agregar('Fecha', 'true', 'fecha');</script> - <script>campos_head.agregar('Hora', 'true', 'hora');</script>
              </td>
              <td style="width: 100px; text-align: center" title="Tipo de Imagen">
                <script>campos_head.agregar('Tipo Imagen', 'true', 'image_type');</script>
              </td>
              <td style="width: 100px; text-align: center" title="Tamaño (bytes)">
                <script>campos_head.agregar('Tamaño', 'true', 'image_size');</script>
              </td>
              <td style="width: 80px; text-align: center" title="Acciones"> - </td>
              <td style="width: 15px; display: none;" id="tdScroll"></td>
            </tr>
          </table>

          <div id='divDetalles' style='width: 100%; height: 400px; overflow: auto;'>
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalles">
              <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
	          </table>
          </div>
          
          <div id="divPaginado" class="divPages">
            <script type="text/javascript">
              if (campos_head.PageCount)
                document.write(campos_head.paginas_getHTML())
            </script>
          </div>
          
        </xsl:otherwise>
      </xsl:choose>
    </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row" mode="row1">

    <xsl:variable name="is_valid">
      <xsl:choose>
        <xsl:when test="string(@is_valid) = '' or string(@is_valid) = 'False'">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <tr>

      <xsl:attribute name="class">
        <xsl:if test="$is_valid = '0'">invalida</xsl:if>
        <xsl:if test="$is_valid = '1'">valida</xsl:if>
      </xsl:attribute>
      
      <td style="min-width: 100px;" title="{@ids_deviceid}">
        &#160;<xsl:value-of select="@ids_deviceid" />
      </td>
      
      <td style="width: 200px;" title="{@cod_image}">
        &#160;<xsl:value-of select="@cod_image" />
      </td>
      
      <td style="width: 200px; text-align: right;">
        <xsl:attribute name="title">
          <xsl:value-of select="concat(@fecha, ' ', @hora)" />
        </xsl:attribute>
        <xsl:value-of select="@fecha"/>&#160;<xsl:value-of select="@hora"/>&#160;
      </td>
      
      <td style="width: 100px;" title="{@image_type}">
        &#160;<xsl:value-of select="@image_type" />
      </td>
      
      <td style="width: 100px; text-align: right">
        <xsl:attribute name="title">
          <xsl:value-of select="@image_size" />&#160;bytes
        </xsl:attribute>
        <xsl:value-of select="@image_size" />&#160;
      </td>
      
      <td style="width: 80px; text-align: center">
        <xsl:if test="$is_valid = '1'">
          <span class="icon png" title="Ver Imagen" onclick="showImage('{@cod_image}')"></span>  
        </xsl:if>
        <span class="icon txt" title="Ver Información" onclick="showInfo('{@cod_image}')"></span>
      </td>
    
    </tr>
  </xsl:template>

</xsl:stylesheet>