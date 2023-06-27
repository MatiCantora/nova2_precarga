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
			
					 
					function mostrar_creditos(e,nro_credito,link)
						{
                            var path = "../../meridiano/credito_mostrar.aspx?nro_credito=" + nro_credito
                            var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'
                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'
                            
                            if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                            $(link).href = path;
                            else {if (e.altKey){ //con la tecla "Alt", abre una ventana emergente
									window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)                                   
									}
									else{ 
										if (e.shiftKey)
										{ //con la tecla "Shift", abre una nueva ventana _blank
										$(link).target = '_blank'
										$(link).href = path;                                 
										}
										else
										{ 
										parent.mostrar_creditos(nro_credito)
										}                            
									}
								}
					     }
						 
            function cargar_titulo(nro_archivo) {
            
						    var rs = new tRS();
						    rs.open(nvFW.pageContents.filtro_verArchivos_idtipo,"","<nro_archivo type='igual'>" + nro_archivo + "</nro_archivo>","","")
						    var path = ""

						    if (!rs.eof())
						        return rs.getdata('def_archivo') + ': ' + rs.getdata('archivo_descripcion') 
                    
						    return 'Legajo'
						}
            
             function abrir_archivo(e,path,titulo,modal) {
                            
                             if (e.ctrlKey == true || e.shiftKey == true) 
                                window.open(path,"_blank")
                             else
                               abrir_ventana_emergente(path, titulo, undefined, undefined, 580, 1100, true, true, true, true, modal)
                            
                }
          
                      function abrir_entidad(event, nro_archivo_id_tipo, id_tipo)
                      {
                        parent.abrir_entidad_win(event, nro_archivo_id_tipo, id_tipo)
                      }    
                      function date()
                      {
                        return new Date();
                      }                      
                      
					]]>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;overflow:auto">
        <table class="tb1" id="tbCabe" >
          <tr class="tbLabel">
            <td style='width:3%'>Físico</td>
            <td style='width:17%'>
              <script type="text/javascript">
                campos_head.agregar('Tipo', 'false', 'nro_archivo_id_tipo' + '-' + 'id_tipo')
              </script>
            </td>
            <!--<td style='width:7%'>
                <script type="text/javascript">
									campos_head.agregar('Nro. Tipo', 'false', 'id_tipo')
								</script>
							</td>-->
            <td style='width:7%'>
              <script type="text/javascript">
                campos_head.agregar('Nro. Archivo', 'true', 'nro_archivo')
              </script>
            </td>
            <td style='width:20%'>
              <script type="text/javascript">
                campos_head.agregar('Descripción', 'false', 'archivo_descripcion')
              </script>
            </td>
            <td style='width:16%'>
              <script type="text/javascript">
                campos_head.agregar('Definición', 'false', 'def_archivo')
              </script>
            </td>
            <td style='width:9%'>
              <script type="text/javascript">
                campos_head.agregar('Fecha', 'false', 'momento')
              </script>
            </td>
            <td style='width:9%'>
              <script type="text/javascript">
                campos_head.agregar('Vencimiento', 'false', 'fe_venc')
              </script>
            </td>
            <td style='width:5%'>
              <script type="text/javascript">
                campos_head.agregar('Origen', 'false', 'path')
              </script>
            </td>
            <td style='width:9%'>
              <script type="text/javascript">
                campos_head.agregar('Operador', 'false', 'operador')
              </script>
            </td>
            <!--<td style="width:2%;text-align:center" nowrap='true'>-</td>-->
            <td style="width:3%">
              <script type="text/javascript">campos_head.agregar_exportar()</script>
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
    <xsl:variable name="pos" select="position()"/>
    <tr>
      <xsl:choose>
        <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))&gt;number(translate(substring(@todayDate,1,10),'-',''))">
          <xsl:attribute name="style">color:blue !Important; </xsl:attribute>
        </xsl:when>
        <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))&lt;number(translate(substring(@todayDate,1,10),'-',''))">
          <xsl:attribute name="style">color:red !Important; </xsl:attribute>
        </xsl:when>
        <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))=number(translate(substring(@todayDate,1,10),'-',''))">
          <xsl:attribute name="style">color:yellow !Important; </xsl:attribute>
        </xsl:when>
        <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))=number(translate(substring(@todayDate,1,10),'-',''))+1">
          <xsl:attribute name="style">color:yellow !Important; </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:attribute name="id">
        tr_ver<xsl:value-of select="$pos"/>
      </xsl:attribute>
      <td style='width:3%; text-align:center;'>
        <xsl:choose>
          <xsl:when test="@f_nro_ubi != '' ">
            -
          </xsl:when>
          <xsl:otherwise>
            <input id='fisico' type="checkbox" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style='text-align: left; width:17%'>
        <a>
          <xsl:attribute name="onclick">
            abrir_entidad(event,<xsl:value-of select="@nro_archivo_id_tipo"/>,<xsl:value-of select="@id_tipo"/>)
          </xsl:attribute>
          <xsl:attribute name="style">cursor:pointer;color:blue !Important; text-decoration: underline;</xsl:attribute>
          <xsl:value-of  select="concat(@archivo_id_tipo,' - ',format-number(@id_tipo,'0000000'))"/>
        </a>
      </td>
      <!--<td style='text-align: left; width:7%'>
			  <a>
          <xsl:attribute name="onclick">abrir_archivo(event,'/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/>', cargar_titulo('<xsl:value-of select="@nro_archivo"/>'))</xsl:attribute>
          <xsl:value-of  select="format-number(@id_tipo,'0000000')" /> 
			  </a>
		  </td>-->
      <td style='text-align: left; width:7%'>
        <a>
          <xsl:attribute name="onclick">
            abrir_archivo(event,'/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/>', cargar_titulo('<xsl:value-of select="@nro_archivo"/>'))
          </xsl:attribute>
          <xsl:value-of  select="format-number(@nro_archivo,'000000000')" />
        </a>
      </td>
      <td style='width:20%'>
        <xsl:choose>
          <xsl:when test="@f_nro_ubi != '' ">
            <a>
              <xsl:attribute name="onclick">
                abrir_archivo(event,'/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/>', cargar_titulo('<xsl:value-of select="@nro_archivo"/>'))
              </xsl:attribute>
              <xsl:attribute name="style">cursor:pointer !Important; text-decoration: underline;</xsl:attribute>
              <xsl:attribute name='title'>
                <xsl:value-of select="@archivo_descripcion"/>
              </xsl:attribute>
              <xsl:value-of select="@archivo_descripcion"/>
            </a>             
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name='title'>
              <xsl:value-of select="@archivo_descripcion"/>
            </xsl:attribute>
            <xsl:value-of select="@archivo_descripcion"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style='width:16%'>
        <xsl:value-of select="@def_archivo"/>
      </td>
      <td style='text-align: center; width:9%'>
        <xsl:value-of select="foo:FechaToSTR(string(@momento))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@momento))"/>
      </td>
      <td style='text-align: center; width:9%'>
        <xsl:value-of select="foo:FechaToSTR(string(@fe_venc))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_venc))"/>
      </td>
      <td style='width:5%'>
        <xsl:value-of select="@img_origen"/>
      </td>
      <td style='width:9%'>
        <xsl:value-of select="@operador"/>
      </td>

      <!--<td style='text-align: center; width:2%;'>
        <a>
          <xsl:attribute name="onclick">
            abrir_archivo(event,'/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/>', cargar_titulo('<xsl:value-of select="@nro_archivo"/>'))
          </xsl:attribute>
          <xsl:attribute name='target'>verDocumento</xsl:attribute>
          <img border='0' src="../image/icons/download.png" style="vertical-align:middle;cursor: pointer"></img>
        </a>
      </td>-->
      <td style='width:3% !Important'>
        <xsl:attribute name='id'>
          tdScroll<xsl:value-of select="$pos"/>
        </xsl:attribute>&#160;&#160;
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>