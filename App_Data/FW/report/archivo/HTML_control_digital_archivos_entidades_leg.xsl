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
          var pos = 0
					function  window_onload()
                          {
                            window_onresize()
                            var win = $$("#tbDetalle1 tbody tr td")
                            var n_des = 3
                            var n_id = 0
                            var aum = 8
                            parent.parent.getWin(win, aum, n_des, n_id)
                            pos = parent.getPos()
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
                        parent.parent.abrir_entidad_win(event, nro_archivo_id_tipo, id_tipo)
                      }
                      
                      function def_archivo(nro_def_archivo, nro_def_detalle)
                      {
                        parent.parent.def_archivo(nro_def_archivo, nro_def_detalle)
                      }
            
                      var wineditar
                      function editarDocumentosWin(nro_archivo, nro_registro, id_tipo, nro_archivo_id_tipo, nro_def_detalle, nro_archivo_estado) {
						    
                          var Parametros = new Array();
	                        Parametros["id_tipo"] = id_tipo
                          Parametros["nro_archivo_id_tipo"] = nro_archivo_id_tipo
                          Parametros["nro_def_detalle"] = nro_def_detalle
                          //Parametros["titulo"] = titulo + " - " + nro_archivo
	                        Parametros["nro_archivo"] = nro_archivo
                          Parametros["nro_registro"] = nro_registro
                          Parametros["nro_archivo_estado"] = nro_archivo_estado
                    
	                        wineditar = window.top.nvFW.createWindow({
	                          url: '\\fw\\archivo\\archivo_editar.aspx',
                              title: 'Propiedades Archivo ',
                              minimizable: false,
                              maximizable: false,
		                          draggable: true,
	                            width: 800,
		                          height: 400
	                        });
	                        wineditar.options.userData = {
		                      retorno: Parametros
	                        }
	                        wineditar.showCenter(false)
                      }
                      
            function fisicoMasivo() {
                var cont = 0
                var doc = $$("#tbDetalle1 tbody tr td")[cont]
                var desc = ""
                var id = ""
                var tope = document.querySelectorAll('input').length * 7
                
                var a = []
                while (cont < tope) {
                    doc = $$("#tbDetalle1 tbody tr td")[cont]
                    desc = $$("#tbDetalle1 tbody tr td")[cont + 3]
                    id = $$("#tbDetalle1 tbody tr td")[cont + 1]
                    
                    if (doc == 'undefined'){
                    return
                    }else if (doc.getElementsBySelector("input")[0].checked == true) {
                        var obj ={
                          id_tipo: parseInt(id.getElementsBySelector("a")[0].innerText.replace(/\D/g,''), 10),
                          descripcion: desc.innerText,
                          
                        }
                        a.push(obj)
                        //a.push(parseInt(num.getElementsBySelector("a")[0].innerText, 10))
                    }

                    cont = cont + 8
                }
                parent.parent.cambioEstadoMasivo(a)
            }

        function fisicoMasivo() {
          var child = parent
          parent.parent.fisicoMasivo(pos, child, 0)
        }

        function todosFisisco() {
            var c = 0
            var doc = $$("#tbDetalle1 tbody tr td")[c]
            var tope = document.querySelectorAll('input').length * 8 - 8


            while (c < tope) {
                var doc = $$("#tbDetalle1 tbody tr td")[c]

                if ($('todos').checked == true) {
                    if (doc.getElementsBySelector("input")[0].value != 'off') {
                      if(doc.getElementsBySelector("input")[0].id == 'checkAll' )
                          doc.getElementsBySelector("input")[0].checked = true
                    }
                } else {
                    doc.getElementsBySelector("input")[0].checked = false
                }
                c = c + 8
            }
        } 
                   
                      
					]]>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;overflow:auto" hover="background :rgba(grey, 0.5);">
        <table class="tb1" id="tbCabe" >
          <tr class="tbLabel">
            <td style='width:3%; padding:0;; text-align:center'>
              <input id='todos' type="checkbox" onclick="todosFisisco()" style="cursor:pointer; margin:auto 40%;"/>              
            </td>
            <td style='width:3%; padding:0;; text-align:center'>           
            </td>
            <td style='width:3%; padding:0;; text-align:center'>           
            </td>
            <td style='width:55%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Definición', 'false', 'def_archivo')
              </script>
            </td>
            <!--<td style='width:32%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Documento', 'false', 'archivo_descripcion')
              </script>
            </td>-->
            <td style='width:12%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Fecha de alta', 'false', 'momento')
              </script>
            </td>
            <td style='width:12%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Vencimiento', 'false', 'fe_venc')
              </script>
            </td>
            <td style='width:6%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Requerido', 'false', 'requerido')
              </script>
            </td>
            <td style='width:5%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Operador', 'false', 'operador')
              </script>
            </td>
            <td style='width:1%; text-align:center;cursor:pointer !Important' title='Marcar como no digital'>             
              <xsl:attribute name="onclick">
                fisicoMasivo()
              </xsl:attribute>
              <img src='/fw/image/icons/tilde.png'/>
            </td>
          </tr>
        </table>
        <div style="width:100% ;overflow-y:auto;" id="div_lst_creditos">
          <table class="tb1 highlightEven highlightTROver layout_fixed" id="tbDetalle1">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag" style="text-align:center !Important; font-size:15px; margin-bottom:0px; height:20px">
          <script type="text/javascript">
            setTimeout(function(){
            $("div_pag").innerHTML = 'Cantidad de registros: ' + (document.querySelectorAll('tr').length - 1);
            },1000,"JavaScript");
          </script>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
        <!--<form id='checkEstado' class='checkEstado' style='margin:0'>-->
          <tr>
            <xsl:choose>
              <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))&gt;number(translate(substring(@todayDate,1,10),'-',''))">
                <xsl:attribute name="style">color:blue !Important; </xsl:attribute>
              </xsl:when>
              <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))&lt;number(translate(substring(@todayDate,1,10),'-',''))">
                <xsl:attribute name="style">color:red !Important; </xsl:attribute>
                <xsl:attribute name="title">Vencido</xsl:attribute>
              </xsl:when>
              <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))=number(translate(substring(@todayDate,1,10),'-',''))">
                <xsl:attribute name="style">color:yellow !Important; </xsl:attribute>
              </xsl:when>
              <xsl:when test="number(translate(substring(@fe_venc,1,10),'-',''))=number(translate(substring(@todayDate,1,10),'-',''))+1">
                <xsl:attribute name="style">color:yellow !Important; </xsl:attribute>
              </xsl:when>
              <xsl:when test="@requerido = 'False'">
                <xsl:choose>
                  <xsl:when test="@nro_archivo != ''">
                    <xsl:attribute name="style">color:blue !Important; </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="style">color:green !Important; </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="@requerido = 'True'">
                <xsl:choose>
                  <xsl:when test="@nro_archivo != ''">
                    <xsl:attribute name="style">color:blue !Important; </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="style">color:red !Important; </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
            <xsl:attribute name="id">
              tr_ver<xsl:value-of select="$pos"/>
            </xsl:attribute>
            <td style='width:3%; text-align:center;'>
              <xsl:choose>
                <xsl:when test="@f_nro_ubi != '' ">
                  <input type="checkbox" value="off" style="display:none" />
                </xsl:when>
                <xsl:when test="@nro_archivo != '' ">
                  <input type="checkbox" value="off" style="display:none" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="@archivo_descripcion = ''">
                      <input type="checkbox" style="cursor:pointer;" />
                    </xsl:when>
                    <xsl:otherwise>
                      <input type="checkbox" id="checkAll" style="cursor:pointer;" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td style='text-align: center;width:3%'>
              <xsl:choose>
                <xsl:when test='@f_nro_ubi != "" '>
                  <xsl:attribute name="style">cursor:pointer !Important; text-align: center;width:3%</xsl:attribute>
                  <xsl:attribute name="onclick">
                    abrir_archivo(event,'/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/>', cargar_titulo('<xsl:value-of select="@nro_archivo"/>'))
                  </xsl:attribute>
                  <xsl:attribute name='title'>
                    Descarga
                  </xsl:attribute>
                  <img src='..\..\..\FW\image\icons\download.png'></img>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test='@nro_archivo != ""'>
                      <xsl:attribute name='title'>
                        ARCHIVO NO DIGITAL
                      </xsl:attribute>
                      <img src='..\..\..\FW\image\icons\alerta.png'></img>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td style='text-align: center;width:3%'>
                <xsl:choose>
                  <xsl:when test="@f_nro_ubi != '' ">
                    <a>
                      <xsl:attribute name="onclick">
                        editarDocumentosWin(<xsl:value-of select="@nro_archivo"/>,'<xsl:value-of select="@nro_registro"/>','<xsl:value-of select="@id_tipo"/>','<xsl:value-of select="@nro_archivo_id_tipo"/>','<xsl:value-of select="@nro_def_detalle"/>','<xsl:value-of select="@nro_archivo_estado"/>')
                      </xsl:attribute>
                      <img title="Asignar definicion" src="/fw/image/icons/editar.png" style="cursor:pointer" border="0"/>
                    </a>
                  </xsl:when>
                  <xsl:when test="@nro_archivo != '' ">
                    <a>
                      <xsl:attribute name="onclick">
                        editarDocumentosWin(<xsl:value-of select="@nro_archivo"/>,'<xsl:value-of select="@nro_registro"/>','<xsl:value-of select="@id_tipo"/>','<xsl:value-of select="@nro_archivo_id_tipo"/>','<xsl:value-of select="@nro_def_detalle"/>','<xsl:value-of select="@nro_archivo_estado"/>')
                      </xsl:attribute>
                      <img title="Asignar definicion" src="/fw/image/icons/editar.png" style="cursor:pointer" border="0"/>
                    </a>
                  </xsl:when>
                </xsl:choose>
            </td>            
            <td style='width:54%'>
              <xsl:attribute name='title'>
                <xsl:value-of select="@nro_def_detalle"/>
              </xsl:attribute>
              <!-- <xsl:attribute name="style">cursor:pointer !Important; text-decoration: underline;</xsl:attribute>
              <xsl:attribute name="onclick">
                def_archivo('<xsl:value-of select="@nro_def_archivo"/>','<xsl:value-of select="@archivo_descripcion"/>')
              </xsl:attribute> -->
              <xsl:value-of select="@archivo_descripcion"/>
            </td>
            <!--<td style='width:32%'>
              <xsl:value-of select="@archivo_descripcion"/>
            </td>-->
            <td style='text-align: center; width:12%'>
              <xsl:attribute name='title'>
                <xsl:value-of select="@nro_archivo_id_tipo"/>
              </xsl:attribute>
              <xsl:value-of select="foo:FechaToSTR(string(@momento))" />
            </td>
            <td style='text-align: center; width:12%'>
              <xsl:choose>
                <xsl:when test='@fe_venc != ""'>
                  <xsl:value-of select="foo:FechaToSTR(string(@fe_venc))" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="@nro_archivo != ''">
                      Falta definición
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td style='width:6%'>
              <xsl:choose>
                <xsl:when test='@requerido = "True"'>
                  SI
                </xsl:when>
                <xsl:otherwise>
                  NO
                </xsl:otherwise>
              </xsl:choose>
            </td>
            <td style='width:6%'>
              <xsl:attribute name='id'>
                tdScroll<xsl:value-of select="$pos"/>
              </xsl:attribute>&#160;&#160;
              <xsl:value-of select="@operador"/>
            </td>
          </tr>
        <!--</form>-->
  </xsl:template>
</xsl:stylesheet>