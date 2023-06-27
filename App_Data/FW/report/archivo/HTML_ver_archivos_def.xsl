<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">
  
  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
	<xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />


  <msxsl:script language="vb" implements-prefix="user">
    <msxsl:assembly name="System.Web"/>
    <msxsl:using namespace="System.Web"/>
    <![CDATA[

      Public function getfiltrosXML() as String
        
          Page.contents("filtro_archivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos'><campos>*</campos><filtro></filtro></select></criterio>")
          Page.contents("filtro_archivos_grupos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_grupos'><campos>distinct nro_archivo_def_grupo, archivo_def_grupo</campos><filtro></filtro></select></criterio>")
          Page.contents("filtro_verArchivos_idtipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[nro_def_archivo],[def_archivo],[orden],[archivo_descripcion],[readonly],[file_filtro],[file_max_size],[f_path],[perfil],[repetido],[requerido],[reutilizable],[nro_def_detalle],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[f_id],[momento],[operador],[nro_archivo_estado],[nro_registro],[nro_archivo_def_tipo],[permiso],[cantidad],[fe_venc],fe_venc_obs,dbo.fn_ar_dias_a_vencer(fe_venc) as dias_a_vencer,dbo.rm_tiene_permiso('permisos_archivos', permiso) as permiso_tiene</campos><filtro></filtro><orden>orden</orden></select></criterio>")
          Page.contents("filtro_verArchivos_parametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_parametros'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
          
          return ""
          
      End Function
		
		  Dim a as String = getfiltrosXML()   

  ]]>
  </msxsl:script>

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		
		]]>
	</msxsl:script>
  
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				
				<title></title>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
        <script type="text/javascript" src="/fw/script/utiles.js"></script>
        <script type="text/javascript" src="/fw/script/nosis.js"></script>
        
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
          
        <script language="javascript" >
				
        <xsl:comment>
          
        campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
				var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
				campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
				campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
				campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
				campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
				campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
				campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
				if (mantener_origen == '0')
				 campos_head.nvFW = parent.nvFW  
          
        var nro_def_archivo_actual = '<xsl:value-of select="xml/parametros/nro_def_archivo_actual"/>'
         
        <xsl:variable name="id_tipo" select="xml/parametros/id_tipo"/>
        <xsl:variable name="nro_archivo_id_tipo" select="xml/parametros/nro_archivo_id_tipo"/>

        var id_tipo = ''
        var nro_archivo_id_tipo = ''
				id_tipo = '<xsl:value-of select="$id_tipo"/>'
        nro_archivo_id_tipo = '<xsl:value-of select="$nro_archivo_id_tipo"/>'
				
        var habilitar_nosis = '<xsl:value-of select="xml/parametros/habilitar_nosis"/>' == 'true' ? true : false
				
        var nro_archivo
				<xsl:variable name="nro_archivo" select="xml/rs:data/z:row/@nro_archivo"/>
				<xsl:if test="$nro_archivo">
					nro_archivo = '<xsl:value-of select="$nro_archivo"/>'
				</xsl:if>
				var permiso_nosis = '<xsl:value-of select="xml/rs:data/z:row/@permiso_nosis"/>'

<![CDATA[
						var archivos = new Array()
            
            var alert = function(msg) {
						    Dialog.alert(msg, {
						        className: "alphacube",
						        width: 300,
						        height: 100,
						        okLabel: "cerrar"
						    });
						}

           var documento
						function ABMDocumentos(nro_def_archivo,nro_def_detalle,filein, readonly, nro_archivo, tipo, permisos_tiene) {
						  
						    if (permisos_tiene == 'False') {
						        alert("No posee permisos para realizar esta acción")
						        return;
						    }

						    var url = '\\fw\\archivo\\abmdocumentos.aspx?id_tipo='+ id_tipo +'&nro_archivo_id_tipo=' + nro_archivo_id_tipo + '&nro_def_archivo='+ nro_def_archivo +'&nro_def_detalle='+ nro_def_detalle;

						    var Parametros = {};

						    Parametros["id_tipo"] = id_tipo
                Parametros["nro_archivo_id_tipo"] = nro_archivo_id_tipo
						    Parametros["orden"] = filein
						    if (readonly == 'False')
						        Parametros["nro_archivo"] = nro_archivo

						    documento = window.top.nvFW.createWindow({
						        className: 'alphacube',
						        url: url,
						        title: 'Adjuntar Archivos',
						        minimizable: false,
						        maximizable: false,
						        draggable: true,
						        width: 700,
						        height: 200,
						        onShow: function() {
						        },
						        onClose: abmdocumentos_return
						    });
                
                documento.options.userData = {}
                documento.options.userData.param = Parametros
						    documento.showCenter(true)
						}

						function abmdocumentos_return(win) {
            
            var retorno = ""
            try{retorno = win.options.userData.success ? "refresh" : ""}catch(e){}
            
            if(retorno == "refresh")
       				cargar_grupo(sel_nro_grupo) 
						}

						var wineditar
						function editarDocumentosWin(titulo,nro_archivo, nro_registro, id_tipo, nro_archivo_id_tipo, nro_def_detalle, nro_archivo_estado) {
            
						 //   if (!_permiso_editar_archivos) {
						 //      alert("No posee permisos para modificar archivos")
						  //      return;
						  //  }
						   // if ((window.top.permisos_web & 16) > 0) {
						    
                    var Parametros = new Array();
						        Parametros["id_tipo"] = id_tipo
                    Parametros["nro_archivo_id_tipo"] = nro_archivo_id_tipo
						        Parametros["nro_def_detalle"] = nro_def_detalle
						        Parametros["titulo"] = titulo + " - " + nro_archivo
						        Parametros["nro_archivo"] = nro_archivo
                    Parametros["nro_registro"] = nro_registro
                    Parametros["nro_archivo_estado"] = nro_archivo_estado
                    
						        wineditar = window.top.nvFW.createWindow({
						            url: '\\fw\\archivo\\archivo_editar.aspx',
						            title: 'Propiedades Archivo ' + titulo,
						            minimizable: false,
						            maximizable: false,
						            draggable: true,
						            width: 800,
						            height: 400,
						            onClose: editarDocumentosWin_return
						        });
						        wineditar.options.userData = {
						            retorno: Parametros
						        }
						        wineditar.showCenter(false)

						   // } else
						  //      alert("No posee permisos para realizar esta operacion. Consulte con el administrador del sistema")

						}


						function editarDocumentosWin_return(win) {
            
						    if(wineditar.options.userData.retorno == "refresh")
       						cargar_grupo(sel_nro_grupo) 
				
                //parent.cargarHistorial() 
						}

						function verParametros(titulo,id_tipo,nro_archivo_id_tipo, nro_def_detalle) {

						    var Parametros = new Array();
						    Parametros["id_tipo"] = id_tipo
                Parametros["nro_archivo_id_tipo"] = nro_archivo_id_tipo
						    Parametros["nro_def_detalle"] = nro_def_detalle

						    wineditar = window.top.nvFW.createWindow({
						        url: '\\fw\\archivo\\archivo_parametro.aspx',
						        title: 'Parámetros '+ titulo,
						        minimizable: false,
						        maximizable: false,
						        draggable: true,
						        width: 400,
						        height: 360

						    });
						    wineditar.options.userData = {
						        retorno: Parametros
						    }
						    wineditar.showCenter(false)

						}

						function Alta_Comentario(nro_docu, tipo_docu, sexo, nro_registro, nro_com_tipo, com_tipo, nro_com_estado, com_estado, fecha, nro_operador, operador, id_tipo) {
						    var filtro = ""
						    var Parametros = new Array();
						    Parametros["nro_docu"] = nro_docu
						    Parametros["tipo_docu"] = tipo_docu
						    Parametros["sexo"] = sexo
						    Parametros["id_tipo"] = id_tipo
						    Parametros["nro_registro"] = nro_registro
						    Parametros["com_tipo"] = com_tipo
						    Parametros["nro_registro"] = nro_registro
						    Parametros["nro_com_estado"] = nro_com_estado
						    Parametros["nro_com_tipo"] = nro_com_tipo
						    Parametros["com_estado"] = com_estado
						    Parametros["fecha"] = fecha
						    Parametros["operador"] = operador
						    Parametros["nro_operador"] = nro_operador
						    if (!id_tipo)
						        Parametros["id_tipo"] = id_tipo

						    window.top.win = window.top.nvFW.createWindow({
						        url: '\\fw\\verComRegistro\\ABMRegistro.aspx',
						        title: '<b>Registro de Comentario</b>',
						        minimizable: true,
						        maximizable: false,
						        draggable: false,
						        width: 600,
						        height: 480,
						        onShow: function() {
						            window.top.win.options.userData = {};
						            window.top.win.options.userData.Parametros = Parametros
						        },
						        onClose: Alta_Comentario_return
						    });
						    window.top.win.showCenter(true)
						}


						function Alta_Comentario_return(win) {
						    if (win.options.userData.res) 
						        parent.btnMostrarRegistros_onclick()
						}


						function obtener_archivo(id_tipo, nro_def) {
						    var strXML = nvFW.pageContents.filtro_archivos
						    var rs = new tRS();
						    rs.open(strXML,"","<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo><nro_def_detalle type='igual'>" + nro_def + "</nro_def_detalle>","","")
						    var path = ""
						    if (!rs.eof())
						        path = rs.getdata("path")
						    return path
						}

						function obtener_grupos(id_tipo,nro_archivo_id_tipo) {
            
						    var strXML = nvFW.pageContents.filtro_archivos_grupos
						    var rs = new tRS();
						    rs.open(strXML,"","<nro_def_archivo type='igual'>" + nro_def_archivo_actual + "</nro_def_archivo>","","")						    
                var htmlgrupos = ""
						    while (!rs.eof()) {
						        htmlgrupos += '<tr><td><a href="javascript:cargar_grupo(' + rs.getdata("nro_archivo_def_grupo") + ')">' + rs.getdata("archivo_def_grupo") + '</a></td><td><a href="javascript:imprimir_grupo(' + rs.getdata("nro_archivo_def_grupo") + ')" style="display:none"><img border="0" src="../../fw/image/icons/descargar.png" title="Descargar Grupo"></a></td></tr>';
						        rs.movenext()
						    }
						    htmlgrupos += '<tr><td><a href="javascript:cargar_grupo(-1)">TODOS</a></td><td><a href="javascript:imprimir_grupo(0)" style="display:none"><img border="0" src="/fw/image/icons/descargar.png" title="Descargar Grupo"></a></td></tr>'
						    $('grupos').update(htmlgrupos)
						    return
						}

            var sel_nro_grupo = -1
						function cargar_grupo(nro_grupo) {
						   
               var filtro = "<SQL type='sql'>dbo.rm_archivo_def_detalle_en_grupo(nro_def_detalle," + nro_grupo + ") = 1 </SQL>"
						    if (nro_grupo == -1)
						        filtro = ""
						   
               nvFW.exportarReporte({
                    parametros: "<parametros><habilitar_nosis>"+ habilitar_nosis +"</habilitar_nosis><id_tipo>" + id_tipo + "</id_tipo><nro_archivo_id_tipo>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo><nro_def_archivo_actual>" + nro_def_archivo_actual + "</nro_def_archivo_actual></parametros>",
						        filtroXML: nvFW.pageContents.filtro_verArchivos_idtipo,
						        path_xsl: "/report/archivo/HTML_ver_archivos_def.xsl",
                    filtroWhere: "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo  type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo>" + filtro,
						        formTarget: 'frame_historial',
						        mantener_origen: false,
						        bloq_contenedor: $('frame_historial'),
						        cls_contenedor: 'frame_historial'
						    })

						}

						function imprimir_grupo(nro_grupo) {
                
                alert("No está disponible")
                return
            
						    var id_transferencia = 684 //542

						    var parametros = '<id_tipo>' + id_tipo + '</id_tipo><nro_archivo_id_tipo type="igual">' + nro_archivo_id_tipo + '</nro_archivo_id_tipo><nro_archivo_def_grupo>' + nro_grupo + '</nro_archivo_def_grupo>'

						    var strXML_parm = '<parametros>' + parametros + '</parametros>'

						    parent.nvFW.transferenciaEjecutar({
						        id_transferencia: id_transferencia,
						        xml_param: strXML_parm,
						        pasada: 0,
						        formTarget: 'winPrototype',
						        ej_mostrar: true,
						        async: false,
						        winPrototype: {
						            modal: true,
						            center: true,
						            bloquear: false,
						            url: 'enBlanco.htm',
						            title: '<b>Generar archivo de grupo</b>',
						            minimizable: false,
						            maximizable: true,
						            draggable: true,
						            width: 800,
						            height: 300,
						            resizable: true,
						            destroyOnClose: true
						        }
						    })

						}

						function cargar_titulo(nro_archivo) {
            
						    var rs = new tRS();
						    rs.open(nvFW.pageContents.filtro_verArchivos_idtipo,"","<nro_archivo type='igual'>" + nro_archivo + "</nro_archivo><id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo type='igual'>"+ nro_archivo_id_tipo +"</nro_archivo_id_tipo>","","")
						    var path = ""

						    if (!rs.eof())
						        return rs.getdata('def_archivo') + ': ' + rs.getdata('archivo_descripcion') 
                    
						    return 'Legajo'
						}

            
        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Visualizador";
        vButtonItems[0]["etiqueta"] = "Visualizador";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return abrir_visualizador(event)";
        
        
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Nuevo";
        vButtonItems[1]["etiqueta"] = "Todos";
        vButtonItems[1]["imagen"] = "nueva";
        vButtonItems[1]["onclick"] = "return ABMDocumentos(" + nro_def_archivo_actual + ",0,null,null,null,null)";


        if(habilitar_nosis == true)
        {
          vButtonItems[2] = {}
          vButtonItems[2]["nombre"] = "Nosis";
          vButtonItems[2]["etiqueta"] = "Nosis";
          vButtonItems[2]["imagen"] = "nosis";
          vButtonItems[2]["onclick"] = "return nvNosis.callback()";
        }

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')
        vListButtons.loadImage("nueva", '/FW/image/icons/upload16.png')
        vListButtons.loadImage("nosis", '/FW/image/icons/nosis.png')
        
                        function window_onresize() {
                            try {

                                var dif = Prototype.Browser.IE ? 5 : 2
                                var body_height = $$('body')[0].getHeight()
                                var tbCabe_height = $('tbCabe').getHeight()
                                var div_pag_height = $('div_pag').getHeight()

                                $('divDetalle').setStyle({
                                    height: body_height - div_pag_height - tbCabe_height - dif + 'px'
                                })
                          
                             campos_head.resize("tbCabe", "tbDetalle")
  
                            } catch (e) {console.log(e.message)}
                        }

                        function window_onload() {
                            vListButtons.MostrarListButton()
                            window_onresize()
                            
                            verDocumentacionOpcional()
                        }

                       function verDocumentacionOpcional()
                       {
                           var contenedores = $('tbDetalle').querySelectorAll(".cont_opt")
                           for (var i = 0; i < contenedores.length; i++) {
                             $('check_opt').checked == true ? contenedores[i].show() : contenedores[i].hide() 
                           }
                       }
                     
                      function abrir_visualizador(e) {

                            var tienePermiso = parent.nvFW.tienePermiso('permisos_def_archivo', 1)
                            if (tienePermiso == false) {
                                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
                                return
                            }
                            
                            var path = '/fw/archivo/archivo_visualizador.aspx?ventana=1&nro_def_archivo='+ nro_def_archivo_actual +'&id_tipo=' + id_tipo +'&nro_archivo_id_tipo=' + nro_archivo_id_tipo;
                            var link = 'link_mostrar_archivos';

                            if (e.ctrlKey == true || e.shiftKey == true) 
                                window.open(path,"_blank")
                             else 
                                window.top.abrir_ventana_emergente(path, cargar_titulo(id_tipo,nro_archivo_id_tipo), 'permisos_def_archivo', 1, 580, 1100, true, true, true, true, false)
                        }
                        
                        function abrir_archivo(e,path,titulo,modal) {
                            
                            
                            var tienePermiso = parent.nvFW.tienePermiso('permisos_def_archivo', 1)
                            if (tienePermiso == false) {
                                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
                                return
                            }
                            
                             if (e.ctrlKey == true || e.shiftKey == true) 
                                window.open(path,"_blank")
                             else
                               window.top.abrir_ventana_emergente(path, titulo, 'permisos_def_archivo', 1, 350, 400, true, true, true, true, false)
                            
                        }
                        
                        
                    ]]>
					</xsl:comment>
				</script>
				
				</head>
				<body onload="return window_onload()" onResize="return window_onresize()" style="width:100%;height:100%; overflow:hidden">
          <xsl:variable name="id_tipo" select="xml/parametros/id_tipo"/>
          <xsl:variable name="nro_def_archivo_actual" select="xml/parametros/nro_def_archivo_actual"/>
						<table id="tbCuerpo" class="tb1" >						
							<tr>
								<td colspan='2' style='width:85%;vertical-align:top'>

												<table class="tb1" id="tbCabe">
													<tr class="tbLabel">
														<td style='text-align: center;vertical-align:middle !Important;' nowrap='true'>
														  <span style='float:left'>
															<input type="checkbox" id="check_opt" checked="checked" onclick="return verDocumentacionOpcional()" style="vertical-align:middle;border:0px" ></input> Ver opcionales
														  </span>
															<script>
																campos_head.agregar('Documentos', true, 'archivo_descripcion')
															</script>
														</td>
														<td style='text-align: center; width:20%;vertical-align:middle;font-weight:bold' nowrap='true'>
															<script>
																campos_head.agregar('Fecha', true, 'momento')
															</script>
														</td>
														<td style='text-align: center;  width:5%;' nowrap='true'>
														</td>
														<td style='text-align: center; width:20%;vertical-align:middle;font-weight:bold' nowrap='true'>
															<script>
																campos_head.agregar('Vencimiento', true, 'fe_venc')
															</script>
														</td>
                            <td style='text-align: center; width:6%'></td>
														
													</tr>
												</table>
									<div id="divDetalle" style="width:100%;overflow:auto">
										<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
											<xsl:apply-templates select="xml/rs:data/z:row" />
										</table>
									</div>
									<div id="div_pag" class="divPages">
										<script type="text/javascript">
											if(campos_head.PageCount > 1)
											 document.write(campos_head.paginas_getHTML())
										</script>
									</div>
								
								</td>
								<td style="vertical-align:top">
									<table class="tb1">
										<tr>
											<td>
												<DIV style="WIDTH: 100%" id="divVisualizador"></DIV>
											</td>
										</tr>
									</table>
								<table class="tb1">
                  <tr class="tbLabel">
										<td style="text-align:center"><b>Adjuntar</b></td>
									</tr>
									<tr>	
										<td>
											<DIV style="WIDTH: 100%" id="divNuevo"></DIV>
										</td>
									</tr>
                  <tr>	
										<td>
											<DIV style="WIDTH: 100%" id="divNosis"></DIV>
										</td>
									</tr>
                  </table>
                 <table class="tb1">
									<tr class="tbLabel">
										<td style="text-align:center"><b>Grupos</b></td>
									</tr>
									</table>
									<div  style="overflow: auto; height: 136px;">
									<table class="tb1" id ="grupos">
									</table>
									</div>
									<script type="text/javascript">obtener_grupos(id_tipo,nro_archivo_id_tipo)</script>
								</td>
							</tr>
						</table>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
    <xsl:variable name="id_tipo" select="xml/parametros/id_tipo"/>
    <xsl:variable name="nro_def_archivo_actual" select="/xml/parametros/nro_def_archivo_actual"/>
		<xsl:variable name="pos" select="position()"/>
    <xsl:variable name="style_vencimiento">
        <xsl:choose>
					<xsl:when test="string(@requerido) = 'True' and string(@nro_archivo) = '' ">color:red !Important</xsl:when>
          <xsl:when test="@dias_a_vencer = 0">color:red !Important</xsl:when>
          <xsl:when test="@dias_a_vencer &#60; 30">color:orange !Important</xsl:when>
          <xsl:when test="@dias_a_vencer = 1">color:#FF7B3C !Important</xsl:when>
          <xsl:when test="@dias_a_vencer = 2">color:#AAA60F !Important</xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    <xsl:variable name="dias_a_vencer_desc">
        <xsl:choose>
					  <xsl:when test="string(@requerido) = 'True' and string(@nro_archivo) = ''">Falta presentar documentación</xsl:when>
					  <xsl:when test="@dias_a_vencer = 0">Documentación venciada</xsl:when>
					  <xsl:when test="@dias_a_vencer &#60; 30">El documento vence en <xsl:value-of select="@dias_a_vencer"/> días</xsl:when>
					  <xsl:when test="@dias_a_vencer = 1">Un día para el vencimiento de la documentación</xsl:when>
					  <xsl:when test="@dias_a_vencer = 2">Dos día para el vencimiento de la documentación</xsl:when>
					  <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
		<tr>
			<xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>			 
			<xsl:attribute name="style"><xsl:value-of select="$style_vencimiento"/></xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="$dias_a_vencer_desc"/></xsl:attribute>
      
  			<xsl:if test='string(@requerido) = "False" and string(@nro_archivo) = ""'>
          	<xsl:attribute name="class">cont_opt</xsl:attribute>
			</xsl:if>

			<td style='text-align: left;'>
			<xsl:attribute name="title"><xsl:value-of select="@archivo_descripcion"/>. <xsl:value-of select="$dias_a_vencer_desc"/></xsl:attribute>	
			<xsl:attribute name="style">text-align: left;<xsl:value-of select="$style_vencimiento"/></xsl:attribute>
			 <xsl:choose>
					<xsl:when test='string(@requerido) = "True" and string(@nro_archivo) != "NULL"'>
						<xsl:attribute name="style">color:Red !Important;text-align: left;<xsl:value-of select="$style_vencimiento"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="style">color:Green !Important;text-align: left;<xsl:value-of select="$style_vencimiento"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			<xsl:choose>
				<xsl:when test='string(@nro_archivo) != "" and @nro_archivo_estado = 1'>
					<xsl:attribute name="style">cursor:pointer;color:blue !Important; font-weight:bold; text-decoration: underline;</xsl:attribute>
					<xsl:attribute name="onclick">abrir_archivo(event,'/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/>', cargar_titulo('<xsl:value-of select="@nro_archivo"/>'))</xsl:attribute>
			<xsl:value-of select="@archivo_descripcion"/>
			</xsl:when>
 				<xsl:when test='string(@nro_archivo) != "" and @nro_archivo_estado = 3'>
					<xsl:attribute name="style">cursor:pointer;color:blue !Important; </xsl:attribute>
					<xsl:attribute name="onclick">alert("El documento '<xsl:value-of select="@archivo_descripcion"/>' no se encuentra digitalizado")</xsl:attribute>
			<xsl:value-of select="@archivo_descripcion"/><img src="/fw/image/icons/alerta12x12.png" style="margin-left: 5px;cursor:pointer;cursor:hand" border="0"/>
			</xsl:when>
			<xsl:otherwise>
				 <xsl:value-of select="@nro_archivo"/>    <xsl:value-of select="@nro_archivo_estado"/> <xsl:value-of select="@archivo_descripcion"/>
			</xsl:otherwise>
      </xsl:choose>

			</td>
			<td style='text-align: center;width:5%'>
				 <xsl:attribute name="title"><xsl:value-of select="foo:FechaToSTR(string(@momento))"/></xsl:attribute>
				<xsl:value-of select="foo:FechaToSTR(string(@momento))"/>
			</td>
			<td style='text-align: center; width:6%' nowrap='true'>
				<xsl:if test='@nro_archivo != ""'>
					<xsl:attribute name="onclick">
						editarDocumentosWin(cargar_titulo('<xsl:value-of select="@nro_archivo"/>'),<xsl:value-of select="@nro_archivo"/>,'<xsl:value-of select="@nro_registro"/>','<xsl:value-of select="@id_tipo"/>','<xsl:value-of select="@nro_archivo_id_tipo"/>','<xsl:value-of select="@nro_def_detalle"/>','<xsl:value-of select="@nro_archivo_estado"/>')
					</xsl:attribute>
					<img src="/fw/image/icons/editar.png" style="cursor:pointer" border="0" >
						<xsl:attribute name="title">Editar estado</xsl:attribute>
					</img>
				</xsl:if>
			</td>
			<td style='text-align: center; width:20%' nowrap='true'>
				  <xsl:choose>
				  <xsl:when test="string(@fe_venc_obs) != ''">
    				  <!--<xsl:attribute name="title"><xsl:value-of select="@fe_venc_obs"/></xsl:attribute>-->
					<xsl:value-of select="string(@fe_venc_obs)"/>
				  </xsl:when>
				  <xsl:otherwise>
    				  <!--<xsl:attribute name="title"><xsl:value-of select="foo:FechaToSTR(string(@fe_venc))"/></xsl:attribute>-->
					<xsl:value-of select="foo:FechaToSTR(string(@fe_venc))"/>
				</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='text-align: center; width:6%' nowrap='true'>
				<xsl:if test='@nro_archivo != ""'>
					<xsl:attribute name="onclick">
						editarDocumentosWin(cargar_titulo('<xsl:value-of select="@nro_archivo"/>'),<xsl:value-of select="@nro_archivo"/>,'<xsl:value-of select="@nro_registro"/>','<xsl:value-of select="@id_tipo"/>','<xsl:value-of select="@nro_archivo_id_tipo"/>','<xsl:value-of select="@nro_def_detalle"/>','<xsl:value-of select="@nro_archivo_estado"/>')
					</xsl:attribute>
					<img src="/fw/image/icons/editar.png" style="cursor:pointer" border="0" >
						<xsl:attribute name="title">Editar estado</xsl:attribute>
					</img>
				</xsl:if>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
