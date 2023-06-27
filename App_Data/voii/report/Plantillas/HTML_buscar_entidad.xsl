<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:fn="http://www.w3.org/2005/xpath-functions"
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl" />


  <xsl:template match="/">
    <html>
      <xsl:choose>

        <xsl:when test="count(xml/rs:data/z:row) = 1">
          <head>
            <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
            <script type="text/javascript" language="javascript">
              <xsl:comment>
                var tiporel  = '<xsl:value-of select="xml/rs:data/z:row/@tiporel"/>'
                var nro_entidad  = '<xsl:value-of select="xml/rs:data/z:row/@nro_entidad"/>'
                var tipocli      = '<xsl:value-of select="xml/rs:data/z:row/@tipocli"/>'
                var nrodoc       = '<xsl:value-of select="xml/rs:data/z:row/@nrodoc"/>'
                var tipdoc       = '<xsl:value-of select="xml/rs:data/z:row/@tipdoc"/>'
                <![CDATA[
                        function cargarDatosClienteUnico()
                        {
                            if(parent.name == 'frame_ref')
                              $frame = ObtenerVentana('frame_buscar')
                            else
                              $frame = parent
                            
                            if($frame.cargarDatosCliente)
                              $frame.cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, tiporel)
                        }
                    ]]>
              </xsl:comment>
            </script>
          </head>
          <body onload="return cargarDatosClienteUnico()">
          </body>
        </xsl:when>
        <xsl:otherwise>
          <head>
            <title>Buscar Entidad</title>
            <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
            <style type="text/css">

              .tiporel-1, /*Prospecto*/
              .tiporel1,  /*Cliente Potencial (CCL)*/
              .tiporel2,  /*Cliente en Tramite*/
              .tiporel6,  /*Cliente de Alta Reducida*/
              .tiporel7,  /*Cliente Normal*/
              .tiporel8,  /*Cliente Pend. de Autorización*/
              .tiporel10, /*Vuelco Sin Cuentas*/
              .tiporel11, /*Alta Masiva*/
              .tiporel12, /*Vuelco Con Cuenta*/
              .tiporel13  /*Firmantes Cust Val*/
              {
              /*Amarillo*/
              color: #a3a21b;background-color: #ffff9e !important;
              }

              .tiporel3 /*Cliente Activo (CCL)*/
              {
              /*Verde*/
              color: #270;background-color: #DFF2BF !important;
              }

              .tiporel4,  /*Cliente Inactivo*/
              .tiporel5,  /*Cliente Suspendido*/
              .tiporel9 /*Cliente Rechazado*/
              {
              /*Rojo*/
              color: #D8000C;background-color: #FFBABA !important;
              }

            </style>
            <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
            <script type="text/javascript" language="javascript" src="/fw/script/nvFW_BasicControls.js"></script>
            <script type="text/javascript" language="javascript" src="/fw/script/nvFW_windows.js"></script>
            <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>

            <script type="text/javascript" language="javascript">
              <xsl:comment>
                var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'

                campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID"/>'
                campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl"/>'
                campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
                campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount"/>
                campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize"/>
                campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage"/>

                if (mantener_origen == '0')
                campos_head.nvFW = window.parent.nvFW

                <![CDATA[
                        var dif = Prototype.Browser.IE ? 5 : 0
                        var $body
                        var $tb_titulos
                        var $div_detalles
                        var $tb_detalles
                        var $tdScroll
                        var $frame
                        
                        
                        function window_onload()
                        {
                            // cachear los elementos en variables
                            $body         = $$('body')[0]
                            $tb_titulos   = $('tb_titulos')
                            $div_detalles = $('div_detalles')
                            $tb_detalles  = $('tb_detalles')
                            $tdScroll     = $('tdScroll')
                            if(parent.name == 'frame_ref')
                              $frame = ObtenerVentana('frame_buscar')
                            else
                              $frame = parent
                            
                            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
                            Menus["pMenu"] = pMenu
                            Menus["pMenu"].alineacion = 'centro';
                            Menus["pMenu"].estilo = 'A';

                            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Entidades</Desc></MenuItem>")
                            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_entidad()</Codigo></Ejecutar></Acciones></MenuItem>")
                            pMenu.loadImage("nuevo", "/FW/image/icons/persona_alta.png");
                            pMenu.MostrarMenu()

                            window_onresize()
                        }


                        function window_onresize()
                        {
			                      try {
				                        var body_h        = $body.getHeight()
				                        var tb_titulos_h  = $tb_titulos.getHeight()
				                        var tb_detalles_h = $tb_detalles.getHeight()
				                        var contenedor_h  = body_h - tb_titulos_h - dif
                                
                                        $div_detalles.style.height = contenedor_h + 'px'
                                
                                        tdScroll_hide_show(tb_detalles_h > contenedor_h)
                          
                                campos_head.resize('tb_titulos','tb_detalles');
                                  
				                    }
			                        catch(e) {}
			                  }


			                  function tdScroll_hide_show(show)
                        {
                            show ? $tdScroll.show() : $tdScroll.hide()
                        }
                        
                        function nueva_entidad()
                        {
                            if($frame.nueva_entidad){
                              return $frame.nueva_entidad();
                            }
                            else{
                                win_abm_entidad = window.top.nvFW.createWindow({
                                    url:         '/FW/entidades/entidad_abm.aspx?nro_rol=0&nro_entidad=',
                                    title:       '<b>ABM Entidad</b>',
                                    minimizable: false,
                                    maximizable: false,
                                    draggable:   false,
                                    width:       900,
                                    height:      420,
                                    resizable:   false
                                })

                                win_abm_entidad.showCenter(true)
                            }
                        }
                    
                        function cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, tiporel)
                        {
                            if($frame.cargarDatosCliente)
                              $frame.cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, tiporel)
                            else
                              alert("No definido.")
                        }
                    ]]>
              </xsl:comment>
            </script>
          </head>
          <body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden; background: #FFF;">
            <div id="divMenuPrincipal"></div>
            <table class="tb1" id="tb_titulos">
              <tr class="tbLabel">
                <td style="width: 25px; text-align: center;">-</td>
                <td style="width: 120px; text-align: center; white-space: nowrap;">
                  <script>campos_head.agregar('Tipo Doc.', true,'tipdoc')</script>
                </td>
                <td style="width: 120px; text-align: center; white-space: nowrap;">
                  <script>campos_head.agregar('Nro. Doc.', true,'nrodoc')</script>
                </td>
                <td style="width: 120px; text-align: center; white-space: nowrap;">
                  <script>campos_head.agregar('CUIT / CUIL', true,'CUIT_CUIL')</script>
                </td>
                <td style="text-align: center;">
                  <script>campos_head.agregar('Nombre', true,'razon_social')</script>
                </td>
                <td style="width: 200px; text-align: center;">
                  <script>campos_head.agregar('Estado', true,'tipreldesc')</script>
                </td>
                <!--<td id="tdScroll" style="width: 14px !important; display: none; text-align: center;">&#160;</td>-->
              </tr>
            </table>

            <div id="div_detalles" style="width: 100%; overflow: auto;">
              <table class="tb1 highlightOdd highlightTROver" id="tb_detalles">
                <xsl:apply-templates select="xml/rs:data/z:row" />
              </table>
            </div>

            <!-- DIV DE PAGINACION -->
            <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; height: 16px;">
              <script type="text/javascript">
                if (campos_head.PageCount > 1)
                document.write(campos_head.paginas_getHTML())
              </script>
            </div>
          </body>
        </xsl:otherwise>
      </xsl:choose>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()" />

    <tr id="tr_ver{$pos}">
      <td style="width: 25px; text-align: center;">
        <img alt="Seleccionar" src="/FW/image/icons/ver.png" style="cursor: pointer;" title="Entidad [{@tipdoc_desc}: {@nrodoc}]"
             onclick="return cargarDatosCliente('{@nro_entidad}', {@tipocli}, {@nrodoc}, {@tipdoc}, {@tiporel})" />
      </td>
      <td style="width: 120px; text-align: left;">
        <xsl:value-of select="@tipdoc_desc" />
      </td>
      <td style="width: 120px; text-align: right;">
        <xsl:value-of select="@nrodoc" />
      </td>
      <td style="width: 120px; text-align: right;">
        <xsl:value-of select="@CUIT_CUIL" />
      </td>
      <td>
        <xsl:value-of select="@razon_social" />
      </td>
      <td style="width: 200px;" class="tiporel{@tiporel}">
        <xsl:value-of select="@tipreldesc" />
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>