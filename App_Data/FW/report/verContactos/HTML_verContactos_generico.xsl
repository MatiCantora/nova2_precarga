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
        <title>Listado contacto teléfonos</title>
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
            parent.busquedaGenerica = true;
            //controlar si es repetido
            var strHTML = '';
            console.log(parent.checkContacto_grupos)
            for (var i = 0; i < parent.contactosExternos.length; i++) {
            
                if (parent.checkContacto_grupos.length == 0 || parent.checkContacto_grupos.indexOf(parent.contactosExternos[i].nro_contacto_grupo) > -1) {
                    strHTML += '<tr>';
                    //strHTML += '<td style='width: 8%; text-align: left;'>' + parent.contactosExternos[i].nro_contacto_grupo '</td>';
                    //strHTML += '<td style='width: 8%; text-align: left;'>' + parent.contactosExternos[i].modo + '</td>';
                    strHTML += '<td>' + parent.contactosExternos[i].contacto_grupo + '</td>';
                    strHTML += '<td>' + parent.contactosExternos[i].contacto + '</td>';
                    //parent.contactosExternos[i].postal_real;
                    strHTML += '<td title="' + parent.contactosExternos[i].localidad + '">' + parent.contactosExternos[i].localidad + '</td>';
                    strHTML += '<td></td>';
                    strHTML += '<td>' + parent.contactosExternos[i].desc_contacto_tipo + '</td>';
                    //parent.contactosExternos[i].provincia;
                    //parent.contactosExternos[i].cpa;
                    strHTML += '<td>' + parent.contactosExternos[i].fecha_estado + '</td>';
                    //strHTML += '<td>' + parent.contactosExternos[i].predeterminado + '</td>';
                    strHTML += '<td></td>';
                    strHTML += '<td colspan="2" style="color: #270; background-color: #DFF2BF !important">Contacto ' + parent.contactosExternos[i].sistema + '</td>';
                    strHTML += '</tr>';
                }
            }
            
            if (campos_head.recordcount != 0)
              $('tbRow').getElementsByTagName('tbody')[0].innerHTML += strHTML;
            else $('tbRow').innerHTML = strHTML;
            
            //if ((modo == "VER") || (parent.id_tipo == ""))
              //$('div_boton_agregar').hide();
            
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
          <xsl:when test="count(xml/rs:data/z:row) = 0 and xml/parametros/contactos_ABM/@cantContactosExternos = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <!--<p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold;">No se encontraron teléfonos</p>-->
            </div>
            <div id="div_boton_agregar" style="margin-top: 0.5em;">
              <center>
                <img onclick="parent.Contacto_Actualizar(-1)" src="/FW/image/icons/agregar.png" style="cursor:pointer" title="Agregar Contacto" />
              </center>
            </div>
          </xsl:when>
          <xsl:otherwise>

            <!--Cabecera-->
            <table class="tb1" id="tbCabe">
              <tr class="tbLabel">
                <td style='width: 10%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Tipo Contacto', true, 'contacto_grupo')</script>
                </td>
                <td style='width: 20%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Contacto', true, 'contacto')</script>
                </td>
                <td style='width: 10%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Localidad', true, 'localidad')</script>
                </td>
                <td style='text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Observación', true, 'observacion')</script>
                </td>
                <td style='width: 10%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Tipo', true, 'desc_contacto_tipo')</script>
                </td>
                <td style='width: 9%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Fe. Estado', true, 'fecha_estado')</script>
                </td>
                <td style='width: 10%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Predeterminado', true, 'predeterminado')</script>
                </td>
                <td style='width: 5.5%; text-align: center;'>-</td>
                <td style='width: 5.5%; text-align: center;'>-</td>
              </tr>
            </table>

            <!--Detalle-->
            <div style="width: 100%; overflow: auto;" id="divRow">
              <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                <xsl:apply-templates select="xml/rs:data/z:row" />
              </table>
            </div>

            <!--Paginacion-->
            <div id="div_boton_agregar" style="margin-top: 0.5em;">
              <center>
                <img onclick="parent.Contacto_Actualizar(-1)" src="/FW/image/icons/agregar.png" style="cursor:pointer" title="Agregar Contacto" />
              </center>
            </div>

            <!--Alta contacto-->
            <div id="div_pag" class="divPages footer-pie">
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

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position() - 1"/>

    <tr>
      <td style='width: 8%; text-align: left;'>
        <xsl:if test="@vigente = 'False'">
          <xsl:attribute name="style">
            color:gray;
          </xsl:attribute>
        </xsl:if>
        <script>

          var contacto_grupo = '<xsl:value-of select="@contacto_grupo"/>'
          var acentos = {'á':'a','é':'e','í':'i','ó':'o','ú':'u','Á':'A','É':'E','Í':'I','Ó':'O','Ú':'U'};
          contacto_grupo = contacto_grupo.split('').map( letra => acentos[letra] || letra).join('').toString();
          contacto_grupo = contacto_grupo.toLowerCase()

          if (typeof parent.Contactos[contacto_grupo] == "undefined")
          parent.Contactos[contacto_grupo] = {};

          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>'] = new Array();
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["id_contact"] = '<xsl:value-of select="@id_contact"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["nro_contacto_grupo"] = '<xsl:value-of select="@nro_contacto_grupo"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["email"] = '<xsl:value-of select="@email"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["telefono"] = '<xsl:value-of select="@telefono"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["postal"] = '<xsl:value-of select="@postal"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["car_tel"] = '<xsl:value-of select="@car_tel"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["desc_localidad"] = "CP:" + '<xsl:value-of select="@postal_real"/>' + " - " + '<xsl:value-of select="@localidad"/>' + " - " + '<xsl:value-of select="@provincia"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["nro_operador"] = '<xsl:value-of select="@nro_operador"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["nombre_operador"] = '<xsl:value-of select="@nombre_operador"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["fecha_estado"] = FechaToSTR(parseFecha('<xsl:value-of select="@fecha_estado"/>'))

          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["calle"] = '<xsl:value-of select="@calle"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["numero"] = '<xsl:value-of select="@numero"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["piso"] = '<xsl:value-of select="@piso"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["depto"] = '<xsl:value-of select="@depto"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["resto"] = '<xsl:value-of select="@resto"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["postal"] = '<xsl:value-of select="@postal"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["desc_localidad"] = "CP:" + '<xsl:value-of select="@postal_real"/>' + " - " + '<xsl:value-of select="@localidad"/>' + " - " + '<xsl:value-of select="@provincia"/>'

          if ('<xsl:value-of select="@observacion"/>')
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["observacion"] = '<xsl:value-of select="@observacion"/>'
          else
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["observacion"] = ''

          if ('<xsl:value-of select="@observacion_referencia"/>')
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["observacion_referencia"] = '<xsl:value-of select="@observacion_referencia"/>'
          else
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["observacion_referencia"] = ''

          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["nro_contacto_tipo"] = '<xsl:value-of select="@nro_contacto_tipo"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["desc_contacto_tipo"] = '<xsl:value-of select="@desc_contacto_tipo"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["predeterminado"] = '<xsl:value-of select="@predeterminado"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["orden"] = '<xsl:value-of select="@orden"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["estado"] = 'GUARDADO'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["vigente"] = '<xsl:value-of select="@vigente"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["incorrecto"] = '<xsl:value-of select="@incorrecto"/>' == null ? "False" : '<xsl:value-of select="@incorrecto"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["id_ro_telefono"] = '<xsl:value-of select="@id_ro_telefono"/>' == null ? 0 : '<xsl:value-of select="@id_ro_telefono"/>'

          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["cpa"] = '<xsl:value-of select="@cpa"/>' != null ? '<xsl:value-of select="@cpa"/>' : ''
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["cod_veraz_prov"] = '<xsl:value-of select="@cod_veraz_prov"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["localidad_CPA"] = '<xsl:value-of select="@localidad"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["cod_prov"] = '<xsl:value-of select="@cod_prov"/>'
          parent.Contactos[contacto_grupo]['<xsl:value-of select="$pos"/>']["id_ro_domicilio"] = '<xsl:value-of select="@id" />'


        </script>
        <xsl:value-of select="@contacto_grupo" />&#160;
      </td>
      <td style='width: 8%; text-align: left;'>
        <xsl:if test="@vigente = 'False'">
          <xsl:attribute name="style">
            color:gray;
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@contacto" />&#160;
      </td>
      <td style='width: 10%; text-align: left;'>
        <xsl:if test="@vigente = 'False'">
          <xsl:attribute name="style">
            color:gray;
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@localidad" />&#160;
      </td>
      <td style='text-align: left;'>
        <xsl:if test="@vigente = 'False'">
          <xsl:attribute name="style">
            color:gray;
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@observacion" />&#160;
      </td>
      <td style='width: 10%; text-align: left;'>
        <xsl:if test="@vigente = 'False'">
          <xsl:attribute name="style">
            color:gray;
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@desc_contacto_tipo" />&#160;
      </td>
      <td style='width: 9%; text-align: right;'>
        <xsl:if test="@vigente = 'False'">
          <xsl:attribute name="style">
            color:gray; text-align: right;
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@fecha_estado))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fecha_estado))"/>
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@fecha_estado))" />&#160;
      </td>
      <td style='width: 5.5%; text-align: center;'>
        <xsl:if test="@predeterminado = 'True'">
          <img src='/fw/image/icons/tilde.png' border='0' align='absmiddle' hspace='1' title='Eliminar' ></img>
        </xsl:if>
      </td>
      <td style='width: 5.5%; cursor: pointer; text-align: center;'>
        <xsl:if test="@modo != 'VER' and @permiso_editar = 'True'">
          <img src='/fw/image/icons/editar.png' border='0' align='absmiddle' hspace='1' title='Editar' >
            <xsl:choose>
              <xsl:when test='@contacto_grupo = "Teléfono"'>
                <xsl:attribute name="onclick">
                  parent.Telefono_Actualizar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
                </xsl:attribute>
              </xsl:when>
              <xsl:when test='@contacto_grupo = "Email"'>
                <xsl:attribute name="onclick">
                  parent.Email_Actualizar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
                </xsl:attribute>
              </xsl:when>
              <xsl:when test='@contacto_grupo = "Domicilio"'>
                <xsl:attribute name="onclick">
                  parent.Domicilio_Actualizar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                parent.Contacto_Actualizar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />','<xsl:value-of select="@nro_contacto_grupo" />')
              </xsl:otherwise>
            </xsl:choose>
          </img>
        </xsl:if>
      </td>
      <td style='width: 5.5%; cursor: pointer; text-align: center;'>
        <xsl:if test="@modo != 'VER' and @permiso_editar = 'True'">
          <img src='/fw/image/icons/eliminar.png' border='0' align='absmiddle' hspace='1' title='Eliminar' >
            <xsl:choose>
              <xsl:when test='@contacto_grupo = "Teléfono"'>
                <xsl:attribute name="onclick">
                  parent.Telefono_Eliminar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
                </xsl:attribute>
              </xsl:when>
              <xsl:when test='@contacto_grupo = "Email"'>
                <xsl:attribute name="onclick">
                  parent.Email_Eliminar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
                </xsl:attribute>
              </xsl:when>
              <xsl:when test='@contacto_grupo = "Domicilio"'>
                <xsl:attribute name="onclick">
                  parent.Domicilio_Eliminar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                parent.Contacto_Eliminar('<xsl:value-of select="$pos" />','<xsl:value-of select="@id_contact" />')
              </xsl:otherwise>
            </xsl:choose>
          </img>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>