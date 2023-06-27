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
            <td style='width:3%; padding:0;'>
            </td>
            <td style='width:97%'>
              <script type="text/javascript">
                campos_head.agregar('Definicion de archivo', 'false', 'def_archivo')
              </script>
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
    <xsl:variable name="nro_def_archivo" select="@nro_def_archivo"/>
    <xsl:variable name="pos" select="position()"/>
        <form id='checkEstado' class='checkEstado' style='margin:0'>
    <tr>
      <xsl:attribute name="id">
        tr_ver<xsl:value-of select="$pos"/>
      </xsl:attribute>
      <td style='width:3%; text-align:center;'>
        <xsl:attribute name="onclick">
          mostrar_entidades(this, <xsl:value-of select="@nro_def_archivo"/>)
        </xsl:attribute> 
        <img style="cursor:pointer" id="icono{$nro_def_archivo}" src="/FW/image/icons/mas.gif" />        
      </td>
      <td style='text-align: left; width:97%'>
        <xsl:attribute name='title'>
          <xsl:value-of select="@nro_def_detalle"/>
        </xsl:attribute>
          <xsl:value-of  select="@def_archivo"/>
      </td>
    </tr>
    <tr>
      <td colspan='5' >
        <iframe src="/fw/enBlanco.htm" name="entidades{$nro_def_archivo}" id="entidades{$nro_def_archivo}" scope='row' style='width:100%; height: 300px; display:none' />   
      </td>
    </tr>
  </form>
  </xsl:template>
</xsl:stylesheet>