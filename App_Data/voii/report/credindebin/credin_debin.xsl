<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:decimal-format name="euro" decimal-separator="," grouping-separator="."/>
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
            function actualizarMasivo() {
              var list = []
              var c = 0
              var tope = document.querySelectorAll('input').length 

              while (c < tope) {
                  if (document.querySelectorAll('input')[c].checked == true) {
                            list.push(document.querySelectorAll('input')[c].id)
                  }
                  c = c + 1
              }
              
              c = 0
              debugger
              var xml = '<debines>'
              while ( c < list.length) {
                  xml += '<id>' + list[c] + '</id>'
                  c = c + 1
              }
              xml += '</debines>'
              
              parent.actualizarMasivo(xml)
  
            } 
            
            function window_onload() {
              window_onresize()  
            }
            
            function window_onresize() {
            
              var gralWidth = $('gral_1').offsetWidth + $('gral_2').offsetWidth + $('gral_3').offsetWidth + $('gral_4').offsetWidth
              var debWidth = $('deb_1').offsetWidth + $('deb_2').offsetWidth
              var credWidth = $('cred_1').offsetWidth + $('cred_2').offsetWidth 
              
              $('gral').style.width = gralWidth + 4 + 'px'
              $('debin').style.width = debWidth + 4 + 'px'
              $('credin').style.width = credWidth + 4 + 'px'
              
              
			         var dif = Prototype.Browser.IE ? 5 : 2
			         var body_height = $$('body')[0].getHeight()
               var divCabe_height = $('divCabe').getHeight()
		           var div_pag_height = $('div_pag').getHeight()
			         $('divRow').setStyle({height: body_height - divCabe_height - div_pag_height - dif + 'px'})
           
			     
			        
                campos_head.resize("tbCabe", "tbRow")
                
                $('gral').setStyle({ width: $('gral_2').getWidth() + $('gral_1').getWidth() + $('gral_4').getWidth() + $('gral_3').getWidth() + 6 + 'px' })
                
                $('debin').setStyle({ width: $('deb_1').getWidth() + $('deb_2').getWidth() + 2 + 'px' })
                
                $('credin').setStyle({ width: $('cred_1').getWidth() + $('cred_2').getWidth() + 2 + 'px' })
                
            }
            
            function consultarEstado(id_deb, estado, internalcode,dc_mov_tipo){
             // var td = $('estado_' + id_deb)
              parent.consultarEstado(id_deb, estado, internalcode,dc_mov_tipo)
            }
            
					]]>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;overflow:auto;margin-bottom:0px;padding-bottom:0px" hover="background :rgba(grey, 0.5);">
        <div id="divCabe" syle="width:100%">
          <table class="tb1 layout_fixed" id="tbTit">
            <tr class="tbLabel">
              <td id="gral" style='width:25%;text-align:center'></td>
              <td id="debin" style='width:25%;text-align:center'>DÉBITO</td>
              <td id="credin" style='width:25%;text-align:center'>CRÉDITO</td>
              <td></td>
            </tr>
          </table>
          <table class="tb1 layout_fixed" id="tbCabe">
            <tr class="tbLabel">
              <!--<td style='width:3%; text-align:center' nowrap='true' >
              <a style='text-align:center'>
                <xsl:attribute name="onclick">
                  actualizarMasivo()
                </xsl:attribute>
                <img title="Editar Movimiento" src="/fw/image/icons/periodicidad.png" style="cursor:pointer" border="0"/>
              </a>
            </td>-->
              <td id="gral_2" style='width:3% !important; text-align:center' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('', 'false', 'dc_mov_tipo')
                </script>
              </td>
              <td id="gral_1" style='width:8%; text-align:center' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('Fecha Alta', 'false', 'dc_addDt')
                </script>
              </td>
              <td id="gral_4" style='width:12%;text-align:center'>
                <script type="text/javascript">
                  campos_head.agregar('Comprobante/Cod. Interno', 'false', 'internalcode')
                </script>
              </td>
              <td id="gral_3" style='width:12%;text-align:center'>
                <script type="text/javascript">
                  campos_head.agregar('Estado', 'false', 'dc_id_estado')
                </script>
              </td>
              <td id="deb_1" style='width:18%;text-align:center' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('Cuenta Titular', 'false', 'debito_Razon_social')
                </script>
              </td>
              <td id="deb_2" style='width:8%; text-align:center' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('CUIT/CUIL', 'false', 'debito_cuit')
                </script>
              </td>

              <td id="cred_1" style='width:18%; text-align:center' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('Cuenta Titular', 'false', 'credito_Razon_social')
                </script>
              </td>
              <td id="cred_2" style='width:8%; text-align:center' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('CUIT/CUIL', 'false', 'credito_cuit')
                </script>
              </td>

				<td id="operador" style='width:8%; text-align:center' nowrap='true' >
					<script type="text/javascript">
						campos_head.agregar('Operador', 'false', 'Login')
					</script>
				</td>  
				
              <td style='width:8%; text-align:center;' nowrap='true' >
                <script type="text/javascript">
                  campos_head.agregar('Importe', 'false', 'importe')
                </script>
              </td>
              <td style='width:4%; text-align:center'>
                -
              </td>
              <td style='width:4%; text-align:center'>
                -
              </td>
              <td style='width:4%; text-align:center'>
                -
              </td>
            </tr>
          </table>
        </div>
        <div style="width:100% ;overflow-y:auto; text-align:center" id="divRow">
          <table class="tb1 highlightEven highlightTROver layout_fixed" id="tbRow">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag" class="divPages" >
          <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>
        <!--        <div id="div_pag" style="text-align:center !Important; font-size:15px; margin-bottom:0px; height:20px">
          <script type="text/javascript">
            setTimeout(function(){
            $("div_pag").innerHTML = 'Cantidad de registros: ' + (document.querySelectorAll('tr').length - 1);
            },1000,"JavaScript");
          </script>
        </div>-->
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <!--<form class='checkEstado' style='margin:0'>-->
    <tr id="tr_ver{$pos}">
      <!--<xsl:attribute name="id">
        tr_ver<xsl:value-of select="$pos"/>
      </xsl:attribute>-->
      <!--<td style='width:3%; text-align:center'>
        <input type='checkbox'>
          <xsl:attribute name="id">
            <xsl:value-of select="@dc_id"/>
          </xsl:attribute>
        </input> 
      </td>-->
      <td>
        <xsl:attribute name="style">text-align: center; width:3%</xsl:attribute>
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
      <td style='text-align: center; width:8%'>
        <xsl:attribute name='title'>
          Fecha Alta: <xsl:value-of select="concat(foo:FechaToSTR(string(@dc_addDt)),' - ',foo:HoraToSTR(string(@dc_addDt)))" />
          Fecha Expiración: <xsl:value-of select="foo:FechaToSTR(string(@dc_fecha_expiracion))" />
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@dc_addDt))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@dc_addDt))" />
      </td>

      <td style='text-align: left width:12%'>
        <div style="font-size:0.9em">
          Comp: <xsl:value-of select="@internalcode"/>
        </div>
        <div style="font-size:0.9em">
          Cod: <xsl:value-of select="@idComprobante"/>
        </div>
      </td>

      <td style='width:18%'>
        <xsl:attribute name="style">
          text-align: center;<xsl:value-of select="@css_style_estado"/>
        </xsl:attribute>
        <xsl:attribute name="id">
          estado_<xsl:value-of select="@dc_id"/>
        </xsl:attribute>
        <xsl:value-of select="@dc_id_estado"/>
      </td>

      <td style='text-align: left; width:8%'>

        <xsl:attribute name='title'>
          <xsl:value-of select="@debito_Razon_social"/>
          CBU: <xsl:value-of select="@debito_cbu"/>
          ALIAS: <xsl:value-of select="@debito_alias"/>
        </xsl:attribute>

        <div style="width:60%">
          <xsl:value-of select="@debito_Razon_social"/>
        </div>
        <div style="font-size:0.8em">
          <xsl:if test="@debito_cbu != ''">
            CBU: <xsl:value-of select="@debito_cbu"/>
          </xsl:if>
          <xsl:if test="@debito_alias != ''">
            ALIAS: <xsl:value-of select="@debito_alias"/>
          </xsl:if>
        </div>

      </td>
      <td style='text-align: right; width:18%'>
        <xsl:value-of select="@debito_cuit"/>
      </td>

      <td style='text-align: left; width:8%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@credito_Razon_social"/>
          CBU: <xsl:value-of select="@credito_cbu"/>
          ALIAS: <xsl:value-of select="@credito_alias"/>
        </xsl:attribute>

        <div style="width:60%">
          <xsl:value-of select="@credito_Razon_social"/>
        </div>
        <div style="font-size:0.8em">
          <xsl:if test="@credito_cbu != ''">
            CBU: <xsl:value-of select="@credito_cbu"/>
          </xsl:if>
          <xsl:if test="@credito_alias != ''">
            ALIAS: <xsl:value-of select="@credito_alias"/>
          </xsl:if>
        </div>
      </td>
      <td style='text-align: right; width:8%'>
        <xsl:value-of select="@credito_cuit"/>
      </td>
		
		 <td style='text-align: left; width:8%'>
        <xsl:value-of select="@Login"/>
      </td>
		
      <td style='text-align: right; width:8%'>
        <xsl:choose>
          <xsl:when test='@importe != ""'>
            $ <xsl:value-of select="format-number(@importe, '###.###,00', 'euro')"/>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style='width:4%; text-align:center'>
        <a style='text-align:center'>
          <xsl:attribute name="onclick">
            parent.editar_mov('<xsl:value-of select="@credito_cuit"/>', '<xsl:value-of select="@credito_cbu"/>', '<xsl:value-of select="@debito_cuit"/>', '<xsl:value-of select="@debito_cbu"/>', '<xsl:value-of select="@dc_fecha_alta"/>', '<xsl:value-of select="@dc_fecha_estado"/>', '<xsl:value-of select="@dc_id_estado"/>', '<xsl:value-of select="@dc_mov_tipo"/>', <xsl:value-of select="@nro_dc_mov"/>, '<xsl:value-of select="@id_dc_concepto"/>', '<xsl:value-of select="@descripcion"/>', <xsl:value-of select="@moneda"/>, '<xsl:value-of select="@idUsuario"/>', '<xsl:value-of select="@idComprobante"/>', '<xsl:value-of select="@importe"/>', '<xsl:value-of select="@dg_lat"/>', '<xsl:value-of select="@dg_lng"/>', '<xsl:value-of select="@dg_precision"/>', '<xsl:value-of select="@dg_ipCliente"/>', '<xsl:value-of select="@dg_tipoDispositivo"/>', '<xsl:value-of select="@dg_plataforma"/>', '<xsl:value-of select="@credito_nro_sucursal"/>', '<xsl:value-of select="@credito_id_cuenta"/>', '<xsl:value-of select="@debito_id_cuenta"/>', '<xsl:value-of select="@dc_id"/>', '<xsl:value-of select="@dc_id_estado"/>', '<xsl:value-of select="@dc_estado"/>', '<xsl:value-of select="@dc_addDt"/>', '<xsl:value-of select="@dc_fecha_expiracion"/>', '<xsl:value-of select="@res_puntaje"/>', '<xsl:value-of select="@debito_bcra_desc"/>', '<xsl:value-of select="@internalcode"/>', '<xsl:value-of select="@debito_Razon_social"/>', '<xsl:value-of select="@credito_tipo_cta"/>', '<xsl:value-of select="@debito_tipo_cta"/>', '<xsl:value-of select="@credito_bcra_desc"/>', '<xsl:value-of select="@res_reglas"/>', '<xsl:value-of select="@credito_Razon_social"/>', '<xsl:value-of select="@Login"/>', '<xsl:value-of select="@res_descripcion"/>', '<xsl:value-of select="@res_codigo"/>')
		  </xsl:attribute>
          <img title="Editar Movimiento" src="/fw/image/icons/buscar.png" style="cursor:pointer" border="0"/>
        </a>
      </td>
      <td style='width:4%; text-align:center'>
		  <xsl:choose>
			  <xsl:when test='@dc_id != ""'>
            <a style='text-align:center'>
              <xsl:attribute name="onclick">
                consultarEstado('<xsl:value-of select="@dc_id"/>', '<xsl:value-of select="@dc_id_estado"/>', '<xsl:value-of select="@internalcode"/>', '<xsl:value-of select="@dc_mov_tipo"/>')
              </xsl:attribute>
              <img title="Actualizar Movimiento" src="/fw/image/icons/periodicidad.png" style="cursor:pointer" border="0"/>
            </a>
			</xsl:when>
		  <xsl:otherwise>
		 </xsl:otherwise>
		</xsl:choose>
      </td>
      <td style='width:4%; text-align:center'>
        <xsl:choose>
        <xsl:when test='@dc_id_estado = "ACREDITADO"'>
          <a style='text-align:center'>
            <xsl:attribute name="onclick">
              parent.mostrarReporteDebinCredin('<xsl:value-of select="@nro_dc_mov"/>')
            </xsl:attribute>
            <img title="Descargar" src="/fw/image/icons/file_pdf.png" style="cursor:pointer" border="0"/>
          </a>
        </xsl:when>
			<xsl:when test='@dc_id_estado = "ACREDITADO IB"'>
				<a style='text-align:center'>
					<xsl:attribute name="onclick">
						parent.mostrarReporteDebinCredin('<xsl:value-of select="@nro_dc_mov"/>')
					</xsl:attribute>
					<img title="Descargar" src="/fw/image/icons/file_pdf.png" style="cursor:pointer" border="0"/>
				</a>
			</xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
    <!--</form>-->
  </xsl:template>
</xsl:stylesheet>