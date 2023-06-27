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
                                     
					          $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - dif + 'px'})            					     
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
          
          function bajaLogica(nro, pos, bl) {
            var td = $('td_' + pos)
            parent.bajaLogica(nro, td, bl)
          }
                      
					]]>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;overflow:auto" hover="background :rgba(grey, 0.5);">
        <table class="tb1" id="tbCabe" >
          <tr class="tbLabel">
            <td style='width:65px'>
              <script type="text/javascript">
                campos_head.agregar('Tipo', 'false', 'dc_mov_tipo')
              </script>
            </td>
            <td style=''>
              <script type="text/javascript">
                campos_head.agregar('Descripción', 'false', 'mov_dc_def_desc')
              </script>
            </td>
            <td style='width:40px'>
            </td>
            <td style='width:40px'>
            </td>
          </tr>
        </table>
        <div style="width:100% ;overflow-y:auto;" id="div_lst_creditos">
          <table class="tb1 highlightEven highlightTROver layout_fixed" id="tbDetalle">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
    <!--<div id="div_pag" class="divPages">
          <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>-->
        </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="nro_entidad" select="@nro_entidad"/>
    <xsl:variable name="pos" select="position()"/>
        <form id='checkEstado' class='checkEstado' style='margin:0'>
    <tr>
        <xsl:choose>
          <xsl:when test='@activo = 0'>
            <xsl:attribute name="style">color: #D8000C;background-color: #FFBABA</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      <td>
        <xsl:attribute name="style">text-align: center; width:65px</xsl:attribute>
        <img>

          <xsl:choose>
          <xsl:when test='@dc_mov_tipo = "C"'>
            <xsl:attribute name='src'>/voii/image/icons/credin.png</xsl:attribute>
            <xsl:attribute name='title'>Credin</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name='src'>/voii/image/icons/debin.png</xsl:attribute>
            <xsl:attribute name='title'>Debin</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        </img>

      </td>
      <td>
        <xsl:attribute name='title'>
          CBU:<xsl:value-of select="@cbu"/>
        </xsl:attribute>
          <xsl:value-of  select="@mov_dc_def_desc"/>
      </td>
      <td style='width:40px; text-align: center'>
        <a style='text-align:center'>
          <xsl:attribute name="onclick">parent.editar_def('<xsl:value-of select="@nro_dc_mov_def"/>', '<xsl:value-of select="@mov_dc_def_desc"/>', '<xsl:value-of select="@dc_mov_tipo"/>', '<xsl:value-of select="@nro_banco_bcra"/>', '<xsl:value-of select="@nro_sucursal"/>', '<xsl:value-of select="@cuitcuil"/>', '<xsl:value-of select="@cbu"/>', '<xsl:value-of select="@moneda"/>', '<xsl:value-of select="@tiempoExpiracion"/>', '<xsl:value-of select="@razon_social"/>', '<xsl:value-of select="@id_dc_concepto"/>', '<xsl:value-of select="@nro_dc_tipo_cta"/>', '<xsl:value-of select="@activo"/>',)</xsl:attribute>
          <img title="Editar Definición" src="/fw/image/icons/editar.png" style="cursor:pointer" border="0"/>
        </a>
      </td>
      <td style='width:40px; text-align: center'>
        <xsl:attribute name="id">
          td_<xsl:value-of select="$pos"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test='@activo = 1'>
            <a style='text-align:center'>
              <xsl:attribute name='title'>Desactivar</xsl:attribute>
              <xsl:attribute name="onclick">bajaLogica('<xsl:value-of select="@nro_dc_mov_def"/>', '<xsl:value-of select="$pos"/>', 0)</xsl:attribute>
              <img src="/fw/image/icons/eliminar.png" style="cursor:pointer" border="0"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </form>
  </xsl:template>
</xsl:stylesheet>