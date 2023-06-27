<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>
  <msxsl:script language="vb" implements-prefix="user">
    <msxsl:assembly name="System.Web"/>
    <msxsl:using namespace="System.Web"/>
    <![CDATA[

      Public function getfiltrosXML() as String
        
          'Page.contents("filtro_verArchivos_idtipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>*,dbo.rm_tiene_permiso('permisos_archivos', permiso) as permiso_tiene</campos><filtro></filtro><orden>orden</orden></select></criterio>")
          Page.contents("filtro_verArchivos_idtipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[nro_def_archivo],[def_archivo],[orden],[archivo_descripcion],[readonly],[file_filtro],[file_max_size],[f_path],[perfil],[repetido],[requerido],[reutilizable],[nro_def_detalle],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[f_id],[momento],[operador],[nro_archivo_estado],[nro_registro],[nro_archivo_def_tipo],[permiso],[cantidad],[fe_venc],fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento,dbo.rm_tiene_permiso('permisos_archivos', permiso) as permiso_tiene</campos><filtro></filtro><orden>orden</orden></select></criterio>")

          return ""
          
      End Function
		
		  Dim a as String = getfiltrosXML()   

  ]]>
  </msxsl:script>
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
		]]>
  </msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Créditos Control Digital</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
        <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
        <script type="text/javascript" src="/FW/script/utiles.js"></script>
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
        <script language="javascript" type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          var fecha_hasta = '<xsl:value-of select="xml/parametros/fecha_hasta"/>'
          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW
        </script>
        <script type="text/javascript">
          <![CDATA[ 				
					function  window_onload()
                          {
                            window_onresize()
                            var win = $$("#tbDetalle tbody tr td")
                            parent.cantReg(win)
                          }
                          
						function window_onresize()
					      {
					       try
					          {
            			      var dif = Prototype.Browser.IE ? 5 : 2
					          var body_height = $$('body')[0].getHeight()
					          var tbCabe_height = $('tbCabe').getHeight()
					          var div_pag_height = $('div_pag').getHeight()
                                     
					          $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})            					     
      		          }
					       catch(e){}
					     }
			
          var post = 0
          function mostrar_entidades(pos, nro) {
            if ($('entidades'+ nro).style.display == 'none' || pos == 0) {
              post = nro
              $('icono'+ nro).src = '/FW/image/icons/menos.gif'
              $('entidades'+ nro).style.display = 'block'
              parent.filtro_fn()
              parent.mostrar_entidades($('entidades'+ nro), nro)
            } else {
            
              $('icono'+ nro).src = '/FW/image/icons/mas.gif'
              $('entidades'+ nro).style.display = 'none'
            }
          }
          
          function getPos() {
            return post
          }
                      
					]]>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;overflow:auto" hover="background :rgba(grey, 0.5);">
        <table class="tb1" id="tbCabe" >
          <tr class="tbLabel">
            <td style='width:20%'>
              <script type="text/javascript">
                campos_head.agregar('Razon Social', 'false', 'Razon_social')
              </script>
            </td>
            <td style='width:10%'>
              <script type="text/javascript">
                campos_head.agregar('CBU', 'false', 'CBU')
              </script>
            </td>
            <td style='width:20%'>
              <script type="text/javascript">
                campos_head.agregar('Banco', 'false', 'banco')
              </script>
            </td>
            <td style='width:15%'>
              <script type="text/javascript">
                campos_head.agregar('Nro. Cuenta', 'false', 'nro_cuenta')
              </script>
            </td>
            <td style='width:10%'>
              <script type="text/javascript">
                campos_head.agregar('Tipo Cuenta', 'false', 'r_tipo_cuenta_desc')
              </script>
            </td>
            <td style='width:3%'>

            </td>
          </tr>
        </table>
        <div style="width:100% ;overflow-y:auto;" id="div_lst_creditos">
          <table class="tb1 highlightEven highlightTROver layout_fixed" id="tbDetalle">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag" class="divPages">
          <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="nro_entidad" select="@nro_entidad"/>
    <xsl:variable name="pos" select="position()"/>
        <form id='checkEstado' class='checkEstado' style='margin:0'>
    <tr>
      <td style='text-align: left; width:20%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@Razon_social"/>
        </xsl:attribute>
          <xsl:value-of  select="@Razon_social"/>
      </td>
      <td style='text-align: left; width:10%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@CBU"/>
        </xsl:attribute>
          <xsl:value-of  select="@cuit"/>
      </td>
      <td style='text-align: left; width:20%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@banco"/>
        </xsl:attribute>
          <xsl:value-of select="@banco"/>
      </td>
      <td style='text-align: left; width:15%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@nro_cuenta"/>
        </xsl:attribute>
          <xsl:value-of  select="@nro_cuenta"/>
      </td>
      <td style='text-align: left; width:10%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@r_tipo_cuenta_desc"/>
        </xsl:attribute>
          <xsl:value-of  select="@r_tipo_cuenta_desc"/>
      </td>
      <td style='text-align: center; width:3%'>
        <xsl:attribute name="onclick">
          parent.definirDebito('<xsl:value-of select="@cuit"/>', '<xsl:value-of select="@CBU"/>', '<xsl:value-of select="@Razon_social"/>')
        </xsl:attribute>
        <img title="Seleccionar esta cuenta" src="/fw/image/icons/activo.png" style="cursor:pointer" border="0"/>
      </td>
    </tr>
    <tr>
      <td colspan='5' style='display:none'>
        <iframe src="/fw/enBlanco.htm" name="entidades{$nro_entidad}" id="entidades{$nro_entidad}" scope='row' style='width:100%; height: 300px; display:none' />   
      </td>
    </tr>
  </form>
  </xsl:template>
</xsl:stylesheet>