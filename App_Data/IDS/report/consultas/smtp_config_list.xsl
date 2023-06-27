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
          margin: 0;
          background-repeat: no-repeat;
          cursor: pointer;
        }
        .icon.edit {
          background-image: url('/FW/image/icons/editar.png');
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


        function editServerConfig(mail_server_id)
        {
            parent.editServerConfig(mail_server_id);
        }
        ]]>
      </script>
    </head>
    <body onload="windowOnload()" onresize="windowOnresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF">

      <xsl:choose>
        
        <xsl:when test="count(xml/rs:data/z:row) = 0">
          <div class="sin-datos">
            <span class="titulo">Sin Configuraciones</span>
            <span class="mensaje">Actualmente no hay configuraciones de Servidores de Email.</span>
          </div>
        </xsl:when>
        
        <xsl:otherwise>
      
          <table class="tb1 layout_fixed" id="tbCabecera">
            <tr class="tbLabel">
              <td style="width: 30px; text-align: center">-</td>
              <td style="text-align: center" title="Configuración de Servidor de Email">
                <script>campos_head.agregar('Servidor', 'true', 'mail_server');</script>
              </td>
              <td style="width: 15px; display: none;" id="tdScroll"></td>
            </tr>
          </table>

          <div id='divDetalles' style='width: 100%; height: 150px; overflow: auto;'>
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

      <td style="width: 30px; text-align: center;">
        <span class="icon edit" title="Editar configuración {@mail_server}" onclick="editServerConfig('{@mail_server_id}')"></span>
      </td>
      
      <td>
        &#160;<xsl:value-of select="@mail_server" />
      </td>
      
    </tr>
  </xsl:template>

</xsl:stylesheet>