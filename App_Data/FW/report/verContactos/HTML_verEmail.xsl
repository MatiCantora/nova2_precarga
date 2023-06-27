<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
    ]]>
  </msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Listado contacto email</title>
        <link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>

        <style>
          .footer-pie {
          position: fixed;
          left: 0;
          bottom: 0;
          width: 100%;
          }
        </style>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          if (mantener_origen == '0')
          campos_head.nvFW = parent.nvFW
          var modo = '<xsl:value-of select="xml/rs:data/z:row/@modo"/>'
        </script>

        <script language="javascript" type="text/javascript">
          <xsl:comment>
            <![CDATA[
          
          function window_onload()
		      {
          
            if ((modo == "VER") || (parent.nro_entidad == ""))
                $('div_boton_agregar').hide();
            
		 	      window_onresize()
		      }
                              
          function window_onresize()
          {
              try
			        {
			          var dif = Prototype.Browser.IE ? 5 : 2
			          var body_height = $$('body')[0].getHeight()
			          var tbCabe_height = $('tbCabe').getHeight()
		            var div_pag_height = $('div_pag').getHeight()
                var div_boton_agregar_height = $('div_boton_agregar').gerHeight();
			      
                $('divRow').setStyle({height: body_height - tbCabe_height - div_pag_height - div_boton_agregar_height - dif + 'px'})
			     
			        }
			      catch(e){}
        
             try
              {
               campos_head.resize("tbCabe","tbRow")                  
              }
             catch(e){}
          }
      ]]>
          </xsl:comment>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <!--<p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold;">No se encontraron domicilios</p>-->
            </div>
            <div id="div_boton_agregar" style="margin-top: 0.5em;">
              <center>
                <img onclick="parent.Email_Actualizar(-1)" src="/FW/image/icons/agregar.png" style="cursor:pointer" title="Agregar Email" />
              </center>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <table class="tb1" id="tbCabe">
              <tr class="tbLabel">
                <td style='width: 5%; text-align: center;'>-</td>
                <td style='width: 25%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Email', true, 'email')</script>
                </td>
                <td style='text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Observación', true, 'observacion')</script>
                </td>
                <td style='width: 15%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Tipo', true, 'desc_contacto_tipo')</script>
                </td>
                <td style='width:15%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Fe. Estado', true, 'fecha_estado')</script>
                </td>
                <td style='width: 5%; text-align: center;'>-</td>
                <td style='width: 5%; text-align: center;'>-</td>
              </tr>
            </table>

            <div style="width: 100%; overflow: auto;" id="divRow">
              <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                <xsl:apply-templates select="xml/rs:data/z:row" />
              </table>
            </div>

            <div id="div_boton_agregar" style="margin-top: 0.5em;">
              <center>
                <img onclick="parent.Email_Actualizar(-1)" src="/FW/image/icons/agregar.png" style="cursor:pointer" title="Agregar Email" />
              </center>
            </div>

            <div id="div_pag" class="divPages footer-pie">
              <script type="text/javascript">
                if (campos_head.PageCount > 1)
                document.write(campos_head.paginas_getHTML())
              </script>
            </div>
            <!--<script type="text/javascript">
              campos_head.resize("tbCabe", "tbRow")
            </script>-->
          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position() - 1"/>

    <tr>
      <td style='width: 5%; text-align: center;'>
        <script>

          if (typeof parent.Contactos["email"] == "undefined")
          parent.Contactos["email"] = new Array();

          parent.Contactos["email"]['<xsl:value-of select="$pos"/>'] = new Array();
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["id_email"] = '<xsl:value-of select="@id_email"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["email"] = '<xsl:value-of select="@email"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["nro_operador"] = '<xsl:value-of select="@nro_operador"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["nombre_operador"] = '<xsl:value-of select="@nombre_operador"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["fecha_estado"] = FechaToSTR(parseFecha('<xsl:value-of select="@fecha_estado"/>'))
          if ('<xsl:value-of select="@observacion"/>')
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["observacion"] = '<xsl:value-of select="@observacion"/>'
          else
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["observacion"] = ''

          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["nro_contacto_tipo"] = '<xsl:value-of select="@nro_contacto_tipo"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["desc_contacto_tipo"] = '<xsl:value-of select="@desc_contacto_tipo"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["predeterminado"] = '<xsl:value-of select="@predeterminado"/>' == null ? "False" : '<xsl:value-of select="@predeterminado"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["orden"] = '<xsl:value-of select="@orden"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["estado"] = 'GUARDADO'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["vigente"] = '<xsl:value-of select="@vigente"/>' == null ? "False" : '<xsl:value-of select="@vigente"/>'
          parent.Contactos["email"]['<xsl:value-of select="$pos"/>']["incorrecto"] = '<xsl:value-of select="@incorrecto"/>' == null ? "False" : '<xsl:value-of select="@incorrecto"/>'

        </script>
        <xsl:if test="@modo = 'C'">
          <xsl:if test="@predeterminado = 'True'">
            <script>
              parent.indiceEmailPredeterminado ='<xsl:value-of select="$pos"/>'
            </script>
            <input type='radio' style='cursor: pointer; border:0' name='rd_email' id='rd_email_{$pos}'  value="{$pos}" checked="true" disabled="true" onclick='parent.rd_email_onclick({$pos})' >
            </input>
          </xsl:if>
          <xsl:if test="@predeterminado = 'False'">
            <input type='radio' style='cursor: pointer; border:0' name='rd_email' id='rd_email_{$pos}' value="{$pos}" disabled="true" onclick='parent.rd_email_onclick({$pos})' >
            </input>
          </xsl:if>
        </xsl:if>
        <xsl:if test="@modo != 'C'">
          <xsl:if test="@predeterminado = 'True'">
            <script>
              parent.indiceEmailPredeterminado ='<xsl:value-of select="$pos"/>'
            </script>
            <input type='radio' style='cursor: pointer; border:0' name='rd_email' id='rd_email_{$pos}' value="{$pos}" checked="true" onclick='parent.rd_email_onclick({$pos})' >
            </input>
          </xsl:if>
          <xsl:if test="@predeterminado = 'False'">
            <xsl:if test="@vigente = 'True'">
              <input type='radio' style='cursor: pointer; border:0' name='rd_email' id='rd_email_{$pos}' value="{$pos}" onclick='parent.rd_email_onclick({$pos})' >
              </input>
            </xsl:if>
            <xsl:if test="@vigente = 'False'">
              <input type='radio' style='cursor: pointer; border:0' name='rd_email' id='rd_email_{$pos}' value="{$pos}" disabled="true" onclick='parent.rd_email_onclick({$pos})' >
              </input>
            </xsl:if>
          </xsl:if>
        </xsl:if>
      </td>
      <td style='width: 25%; text-align: left;'>
        <xsl:value-of select="@email" />&#160;
      </td>
      <td style='text-align: left;'>
        <xsl:value-of select="@observacion" />&#160;
      </td>
      <td style="width: 15%; text-align: left;">
        &#160;<xsl:value-of select="@desc_contacto_tipo" />
      </td>
      <td style='width: 10%; text-align: right;'>
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@fecha_estado))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fecha_estado))"/>
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@fecha_estado))" />&#160;
      </td>
      <td style='width: 5%; cursor: pointer; text-align: center;'>
        <xsl:if test="@modo != 'VER'">
          <img src='/fw/image/icons/editar.png' border='0' align='absmiddle' hspace='1' onclick='parent.Email_Actualizar("{$pos}","{@id_email}")' title='Editar' >
          </img>
        </xsl:if>
      </td>
      <td style='width: 5%; cursor: pointer; text-align: center;'>
        <xsl:if test="@modo != 'VER'">
          <img src='/fw/image/icons/eliminar.png' border='0' align='absmiddle' hspace='1' title='Eliminar' >
            <xsl:attribute name="onclick">
              parent.Email_Eliminar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_email" />')
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>