<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="../../xsl_includes/js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
        
    
    ]]>
  </msxsl:script>

  <xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Historial Comentarios</title>
        <link href="css/base.css" type="text/css" rel="stylesheet"/>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script language="javascript" type="text/javascript">
          <xsl:comment>
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
            if (mantener_origen == '0')
            campos_head.nvFW = window.top.nvFW

            var permitirABM = '<xsl:value-of select="xml/parametros/permitirABM"/>';
            if(permitirABM == ''){
                permitirABM = true;
            } else {
                permitirABM = eval(permitirABM)
            }
          </xsl:comment>
        </script>		
				<style>
					.MO
					{
					CURSOR: hand
					}
					.MU
					{
					CURSOR: default
					}
				</style>
				<script>
					<xsl:comment>
						<xsl:if test="count(xml/rs:data/z:row) > 0" >
						   var nro_entidad = '<xsl:value-of select="xml/rs:data/z:row/@nro_entidad"/>'
						</xsl:if>	
						<![CDATA[
						
						function Mostrar_Registro_grupo(nro_com_grupo)
							{
							var e
							try
								{
								frmExportarC_html.VistaGuardada.value = ""
								frmExportarC_html.path_xsl.value = ""
								frmExportarC_html.xsl_name.value = ""
								frmExportarC_html.filtroWhere.value = ""
								frmExportarC_html.filtroXML.value = ""
								frmExportarC_html.target.value = ""
								var strFiltro = ''
								if(nro_credito != '' )
									strFiltro = "<nro_credito type='igual'>" + nro_credito + "</nro_credito>"
								else
								  strFiltro = "<nro_credito type='isnull'/>"
								  
							  
								if(nro_docu != '' )
									strFiltro += "<nro_docu type='igual'>" + nro_docu + "</nro_docu><tipo_docu type='igual'>" + tipo_docu + "</tipo_docu><sexo type='igual'>'" + sexo + "'</sexo>"
							  
								frmExportarC_html.xsl_name.value = "verRegistro_base.xsl"
								frmExportarC_html.filtroXML.value = "<criterio><select vista='verRegistro'><campos>*</campos><orden>com_prioridad desc, fecha</orden><filtro>" + strFiltro + "<nro_com_grupo type='igual'>" + nro_com_grupo + "</nro_com_grupo></filtro></select></criterio>"
								frmExportarC_html.submit()
								}
							catch(e){}	
							}
							
						function Mostrar_Registro_estado(nro_com_estado)
							{
							var e
							try
								{
								frmExportarC_html.VistaGuardada.value = ""
								frmExportarC_html.path_xsl.value = ""
								frmExportarC_html.xsl_name.value = ""
								frmExportarC_html.filtroWhere.value = ""
								frmExportarC_html.filtroXML.value = ""
								frmExportarC_html.target.value = ""
								var strFiltro = ''
								if(nro_credito != '' )
									strFiltro = "<nro_credito type='igual'>" + nro_credito + "</nro_credito>"
							  
								if(nro_docu != '' )
									strFiltro += "<nro_docu type='igual'>" + nro_docu + "</nro_docu><tipo_docu type='igual'>" + tipo_docu + "</tipo_docu><sexo type='igual'>'" + sexo + "'</sexo>"
							  
								frmExportarC_html.xsl_name.value = "verRegistro_base.xsl"
								frmExportarC_html.filtroXML.value = "<criterio><select vista='verRegistro'><campos>*</campos><orden>com_prioridad desc, fecha</orden><filtro>" + strFiltro + "<nro_com_estado type='igual'>" + nro_com_estado + "</nro_com_estado></filtro></select></criterio>"
								frmExportarC_html.submit()
								}
							catch(e){}
							}	
							
						function Mostrar_Registro()
							{
							frmExportarC_html.VistaGuardada.value = ""
							frmExportarC_html.path_xsl.value = ""
							frmExportarC_html.xsl_name.value = ""
							frmExportarC_html.filtroWhere.value = ""
							frmExportarC_html.filtroXML.value = ""
							frmExportarC_html.target.value = ""
						    frmExportarC_html.xsl_name.value = "verRegistro_base.xsl"
							frmExportarC_html.filtroXML.value = "<criterio><select vista='verRegistro'><campos>*</campos><orden>com_prioridad desc, fecha</orden><filtro><nro_docu type='in'>" + nro_docu + "</nro_docu><nro_com_grupo type='igual'>5</nro_com_grupo></filtro></select></criterio>"
						    frmExportarC_html.submit()
							}	

					 function nodo_onclick(nro_registro)
             {
					   var tb = eval('document.all.tbH' + nro_registro)
					   var imgG = eval('document.all.imgG' + nro_registro)
					   if (tb.style.display == 'none')
					      {
						    imgG.src = '../../FW/image/comentario/menos.jpg'
					      tb.style.display = 'inline'
						    }
					   else 
					     {
						   imgG.src = '../../FW/image/comentario/mas.jpg'
						   tb.style.display = 'none'
						   }
             }
             
					 function MO(e)
						{
						if (!e)
							var e=window.event;
						var S=e.srcElement;
						while (S.tagName!="TD")
							{S=S.parentElement;}
						S.className="MO";
						}
            
					function MU(e)
						{
						if (!e)
							var e=window.event;
						var S=e.srcElement;
						while (S.tagName!="TD")
							{S=S.parentElement;}
						S.className="MU";
						}  
					function ABMRegistro(nro_entidad,nro_registro)
						{						  
						if(permitirABM){
                          var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW

                          window.top.win = w.createWindow({ className: 'alphacube',
                                      url: '/fw/comentario/ABMRegistro.asp?nro_entidad=' + nro_entidad + '&nro_registro=' + nro_registro,
                                      title: '<b>Alta de Comentario</b>',
                                      minimizable: false,
                                      maximizable: false,
                                      draggable: false,
                                      width: 650,
                                      height: 400,
                                      resizable: true/*,
                                      onClose: editarEntidad_return*/
                          });
                          window.top.win.showCenter(true)
						}
						}
					
						function window_onload()
						{						
							window_onResize();
						}
						
						function window_onResize()
						{							
							try{
							   var dif = Prototype.Browser.IE ? 5 : 5
								 body_height = $$('body')[0].getHeight()
								 trTitulo_height = $('trTitulo').getHeight()
								 alto = body_height - trTitulo_height - dif
								 $('div_registro').setStyle({height : alto-30})
								}
								catch(e){}
						}
					   ]]>
					</xsl:comment>
				</script>
			</head>
			<body onload="return window_onload()" onresize="return window_onResize()" style="width:100%;overflow:auto; height:100%">
				<xsl:variable name="nro_com_grupo" select="xml/rs:data/z:row/@nro_com_grupo" />
				<xsl:variable name="nro_entidad" select="xml/rs:data/z:row/@nro_entidad" />
				<table class="tb1">
					<tr>
						<td style="width:100%">
							<div id="div_registro" style="width:100%; overflow-y:auto;">		
								<xsl:apply-templates select="xml/rs:data/z:row[@depende = 0]"/>
							</div>
						</td>						
					</tr>
				</table>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
		<xsl:variable name="nro_registro" select="@nro_registro"/>
		<table cellspacing="0" cellpadding="0">
			<tr>
				<td style='text-align: left; FONT-SIZE: 10px; !Important'>
					<xsl:if test="@Hijos > 0">
            <xsl:attribute name="onmouseover">MO()</xsl:attribute>
            <xsl:attribute name="onmouseout">MU()</xsl:attribute>
            <img src='/FW/image/comentario/menos.jpg' border='0' align='absmiddle' hspace='1'>
              <xsl:attribute name="id">imgG<xsl:value-of select="@nro_registro"/></xsl:attribute>
              <xsl:attribute name='onclick'>return nodo_onclick(<xsl:value-of select='@nro_registro'/>)</xsl:attribute>
            </img>
					</xsl:if>
					<xsl:if test="@Hijos = 0">
						<img src='/FW/image/comentario/punto.jpg' border='0' align='absmiddle' hspace='1'/>
					</xsl:if>
				</td>
				<td nowrap='true' style='text-align: left; FONT-SIZE: 10px; !Important; width: 200px'>
          <xsl:attribute name='onmouseover'>this.title="<xsl:value-of select="foo:HoraToSTR(string(@fecha))"/>"; return</xsl:attribute>
          <b>
            <span>
              <xsl:attribute name="style"><xsl:value-of select="@style"/></xsl:attribute>
              <img src='/FW/image/comentario/comentario.png' style='cursor:pointer' border='0' align='absmiddle' hspace='1'>
                <xsl:attribute name='onclick'>
                  return ABMRegistro(<xsl:value-of select='@nro_entidad'/>, <xsl:value-of select='@nro_registro'/>)
                </xsl:attribute>
              </img>
              <u>
                <xsl:value-of select="@com_tipo"/> (<xsl:value-of select="@com_estado"/>)
              </u>
            </span>
            <br/>
            <xsl:value-of select="foo:FechaToSTR(string(@fecha))"/>
            <img src='/FW/image/comentario/user.png' border='0' align='absmiddle' hspace='1'/>
            <xsl:value-of select="@nombre_operador"/>
          </b>
				</td>
				<td style="FONT-SIZE: 11px; !Important; text-indent: 5px; width: 100%; ">
					<xsl:value-of select="@comentario" disable-output-escaping = "yes" />
				</td>
			</tr>
		</table>
		<xsl:if test="@Hijos > 0">
      <table style="width: 100%" cellspacing="0" cellpadding="0">
        <xsl:attribute name="id">tbH<xsl:value-of select="@nro_registro"/></xsl:attribute>
        <tr>
          <td style="width: 15px">
            <xsl:text disable-output-escaping="yes">&#x26;nbsp;</xsl:text>
          </td>
          <td>
            <xsl:apply-templates select="/xml/rs:data/z:row[@nro_registro_depende = $nro_registro]" />
          </td>
        </tr>
      </table>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>