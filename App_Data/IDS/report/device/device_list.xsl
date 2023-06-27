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
          display: block;
          width: 16px;
          height: 16px;
          margin: 0 auto;
          background-repeat: no-repeat;
        }
        .icon.ok {
          background-image: url('/IDS/image/icons/ok.png');
        }
        .icon.error {
          background-image: url('/IDS/image/icons/cancelar.png');
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
        ]]>
      </script>
    </head>
    <body onload="windowOnload()" onresize="windowOnresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF">

      <xsl:choose>
        
        <xsl:when test="count(xml/rs:data/z:row) = 0">
          <div class="sin-datos">
            <span class="titulo">Sin Dispositivos</span>
            <span class="mensaje">La consulta realizada no retornó ningún dispositivo con los filtros proporcionados. Intente con una combinación diferente.</span>
          </div>
        </xsl:when>
        
        <xsl:otherwise>
      
          <table class="tb1 layout_fixed" id="tbCabecera">
            <tr class="tbLabel">
              <td style="width: 250px; text-align: center" title="ID del Dispositivo">
                <script>campos_head.agregar('ID Dispositivo', 'true', 'ids_deviceid');</script>
              </td>
              <td style="width: 230px; text-align: center" title="Nombre del Dispositivo">
                <script>campos_head.agregar('Nombre', 'true', 'ids_device');</script>
              </td>
              <td style="text-align: center" title="Descripción del Dispositivo">
                <script>campos_head.agregar('Descripción', 'true', 'ids_device_desc');</script>
              </td>
              <td style="width: 150px; text-align: center" title="Fecha de Alta">
                <script>campos_head.agregar('Fe. Alta', 'true', 'creationdate');</script>
              </td>
              <td style="width: 150px; text-align: center" title="Fecha de Último Accceso">
                <script>campos_head.agregar('Último Acceso', 'true', 'lastaccess');</script>
              </td>
              <td style="width: 100px; text-align: center" title="Habilitado">
                <script>campos_head.agregar('Habilitado', 'true', 'enable');</script>
              </td>
              <td style="width: 200px; text-align: center" title="Usuario asociado al Dispositivo">
                <script>campos_head.agregar('Usuario', 'true', 'uid');</script>
              </td>
              <td style="width: 15px; display: none" id="tdScroll"></td>
            </tr>
          </table>

          <div id='divDetalles' style='width: 100%; height: 400px; overflow: auto;'>
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalles">
              <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
	          </table>
          </div>
          
          <div id="divPaginado" class="divPages">
            <script type="text/javascript">
              if (campos_head.PageCount > 1)
                document.write(campos_head.paginas_getHTML())
            </script>
          </div>
          
        </xsl:otherwise>
      </xsl:choose>
    </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row" mode="row1">
    <tr>

      <td style="width: 250px;" title="{@ids_deviceid}">
        &#160;<xsl:value-of select="@ids_deviceid" />
      </td>
      
      <td style="width: 230px;" title="{@ids_device}">
        &#160;<xsl:value-of select="@ids_device"/>
      </td>
      
      <td title="{@ids_device_desc}">
        &#160;<xsl:value-of select="@ids_device_desc" />
      </td>
      
      <td style="width: 150px; text-align: right">
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@creationdate), 1)" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@creationdate))" />
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@creationdate), 1)" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@creationdate))" />&#160;
      </td>
      
      <td style="width: 150px; text-align: right">
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@lastaccess), 1)" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@lastaccess))" />
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@lastaccess), 1)" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@lastaccess))" />&#160;
      </td>
      
      <td style="width: 100px; text-align: center">
        <xsl:choose>
          <xsl:when test="foo:strToLower(string(@enable)) = 'true'">
            <span class="icon ok" title="Dispositivo {@ids_deviceid} habilitado"></span>
          </xsl:when>
          <xsl:otherwise>
            <span class="icon error" title="Dispositivo {@ids_deviceid} NO habilitado"></span>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      
      <td style="width: 200px;" title="{@uid}">

        <xsl:choose>
          <xsl:when test="string(@uid) = ''">
            <xsl:attribute name="title">No Asociado</xsl:attribute>
            <xsl:text>&#160;No Asociado</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            &#160;<xsl:value-of select="@uid" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
    
    </tr>
  </xsl:template>

</xsl:stylesheet>