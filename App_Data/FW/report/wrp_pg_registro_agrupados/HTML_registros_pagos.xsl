<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\FW\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl" />

  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

  <msxsl:script language="vb" implements-prefix="user">
    <msxsl:assembly name="System.Web"/>
    <msxsl:using namespace="System.Web"/>
    <![CDATA[

      Dim nvFW_interOp as object = HttpContext.current.application.contents("_nvFW_interOp")
      
      Public function getfiltrosXML() as String
        

          Page.contents("filtro_pago_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPG_Registro_detalle'>" + 
              "<campos>nombre_operador, pago_tipo, pago_tipo_orig, pago_estados, importe_pago, fe_estado, detalle_cobro, origen, login</campos><filtro><nro_pago_registro type='igual'>%nro_pago_registro%</nro_pago_registro></filtro></select></criterio>")

		  return ""
      End Function
		
		  Dim a as String = getfiltrosXML()     
      

		]]>
  </msxsl:script>

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
		function rellenar0(numero, largo)
        {
		    var strNumero = numero.toString()
            var count     = strNumero.length

            while (count < largo) {
			    strNumero = '0' + strNumero
                count++
            }

			return strNumero
		}
		]]>
  </msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <title>Ver Pagos</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <script language="javascript" type="text/javascript">
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
        </script>

        <script type="text/javascript" language="javascript">
          <![CDATA[
                var $body
                var $tbCabe
                var $divDetalle
                var $tbDetalle
                var $tdScroll
                var detalleCargado = []
                    
                    
                function seleccionar_pago(nro_tipo_pago)
                {
                    window.parent.editarPago(nro_tipo_pago)
                }


                function  window_onload()
                {
                    // cache
                    $body       = $$('body')[0]
                    $tbCabe     = $('tbCabe')
                    $divDetalle = $('divDetalle')
                    $tbDetalle  = $('tbDetalle')
                    $tdScroll   = $('tdScroll')
                    
                    window_onresize()
                }


                function window_onresize()
                {
                    try {
                        var body_h   = $body.getHeight()
                        var tbCabe_h = $tbCabe.getHeight()
                        var altura   = body_h - tbCabe_h

                        $divDetalle.style.height = altura + 'px'

                        $tbDetalle.getHeight() > altura ? $tdScroll.show() : $tdScroll.hide()

                            //? tdScroll_hide_show(false)
                            //: tdScroll_hide_show(true)
                    }
                    catch(e) {}
                    
                    campos_head.resize('tbCabe', 'tbDetalle')
                }


                /*
                function tdScroll_hide_show(show)
                {
                    var i = 1
                    var tdElement

                    while (i <= campos_head.recordcount) {
                        tdElement = $('tdScroll' + i)
                            
                        if (tdElement != undefined)
                            show ? tdElement.show() : tdElement.hide()

                        i++
                    }
                }
                */
                
                
                function showHideDetalles(pos, nro_pago_registro) {
                
                        var alturaDiv = $(divDetalle).getHeight();
                        
                        var scrollVisible = $('tbDetalle').getHeight() > alturaDiv ? true : false;

                        var rowInfo = document.getElementById("tr_" + pos);
                        var rowImg =  document.getElementById("img_" + pos);
                        var iframe = 'iframe_' + pos;

                        if (rowInfo.style.display == "none") {
                            rowInfo.style.display = "";
                            rowImg.src = "/fw/image/tmenu/menos.gif";
                            
                            if (!detalleCargado[pos]) { // si no fue cargado anteriormente
                        
                              detalleCargado[pos] = true
                              var filtro = '';
                            
                              nvFW.exportarReporte({
                                  async: true,
                                  filtroXML: nvFW.pageContents.filtro_pago_detalle,
                                  filtroWhere: filtro,
                                  path_xsl: "report\\wrp_pg_registro_agrupados\\HTML_pagos_detalle.xsl",
                                  formTarget: iframe,
                                  nvFW_mantener_origen: true,
                                  bloq_contenedor: iframe,
                                  cls_contenedor: iframe,
                                  params: '<criterio><params nro_pago_registro="' + nro_pago_registro + '" /></criterio>',
                                  funComplete: function () {
                                  }
                              });
                            
                            }
                            
                        } else {
                            rowInfo.style.display = "none";
                            rowImg.src = "/fw/image/tmenu/mas.gif";
                        }
                        //Resize de ultima columna en caso de aparecer o desaparecer scroll
                        if (($('tbDetalle').getHeight() > alturaDiv && !scrollVisible) || ($('tbDetalle').getHeight() < alturaDiv && scrollVisible))
                          campos_head.resize('tbCabe', 'tbDetalle');
                         
                    }
                
                
                
                ]]>
        </script>
        <style type="text/css">
          .tr_cel TD { background-color: #F0FFFF !Important; }
          tr.centrado td { text-align: center; }
        </style>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
        <form name="frmPagos" id="frmPagos" style="width: 100%; height: 100%; overflow: hidden;">
          <table class="tb1" id="tbCabe">
            <tr class="tbLabel centrado">
              <td style="width: 3%"></td>
              <td style='width: 10%'>
                <script type="text/javascript">campos_head.agregar('Envio', 'true', 'nro_envio_gral')</script>
              </td>
              <td nowrap='true' style='width: 22%'>
                <script type="text/javascript">campos_head.agregar('Razón Social', 'true', 'razon_social')</script>
              </td>
              <td style='width: 10%;'>
                <script type="text/javascript">campos_head.agregar('Fecha', 'true', 'fecha')</script>
              </td>
              <td style='width: 10%'>
                <script type="text/javascript">campos_head.agregar('Crédito', 'true', 'nro_credito')</script>
              </td>
              <td style='width: 15%'>
                <script type="text/javascript">campos_head.agregar('Importe Pago', 'true', 'importe_pago')</script>
              </td>
              <td style='width: 15%'>
                <script type="text/javascript">campos_head.agregar('Concepto', 'true', 'pago_concepto')</script>
              </td>
              <td style='width: 5%' title='Detalles'>D</td>
              <td style='width: 5%' title='Pendientes'>P</td>
              <td style='width: 5%'> - </td>
              <!--<td style="width: 5%; display: none;" id="tdScroll">&#160;</td>-->
            </tr>
          </table>

          <div id="divDetalle" style="width: 100%; overflow: auto;">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
              <xsl:apply-templates select="xml/rs:data/z:row" />
            </table>
          </div>
        </form>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()" />
    <xsl:variable name="cantidad_pendientes" select="@pagos_pendientes" />
    <xsl:variable name="cantidad_suspendidos" select="@pagos_suspendidos" />

    <tr id="tr_ver{$pos}">
      <xsl:choose>
        <xsl:when test="$cantidad_pendientes > 0">
          <xsl:attribute name='style'>color: blue;</xsl:attribute>
        </xsl:when>
        <xsl:when test="$cantidad_suspendidos > 0">
          <xsl:attribute name='style'>color: orange;</xsl:attribute>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>

      <td style="text-align: center; width: 3%">
        <img id="img_{$pos}" alt="Ver detalle" src="/FW/image/tmenu/mas.gif" style="cursor: pointer;" title="Mostrar detalle Instrucción de Pago" onclick="showHideDetalles({$pos}, {@nro_pago_registro})" />
        <script>
          detalleCargado['<xsl:value-of select="$pos"/>'] = false
        </script>
      </td>
      <td style='text-align: right; width: 10%'>
        <xsl:value-of select="@nro_envio_gral" />&#160;
      </td>
      <td style='text-align: left; width: 22%' nowrap='true'>
        <xsl:attribute name="title">
          <xsl:value-of select="@razon_social" />
        </xsl:attribute>
        &#160;<xsl:value-of select="@razon_social" />
      </td>
      <td style='text-align: right; width: 10%;'>
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@fecha), 1)" />&#160;&#13;<xsl:value-of select="foo:HoraToSTR(string(@fecha))" />
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@fecha), 1)" />&#160;
      </td>
      <td style='text-align: right; width: 10%'>
        <xsl:choose>
          <xsl:when test='@nro_credito'>
            <a target="_blank" href="/meridiano/credito_mostrar.aspx?nro_credito={@nro_credito}">
              <xsl:if test="$cantidad_pendientes = 0">
                <xsl:attribute name="style">color: black;</xsl:attribute>
              </xsl:if>
              <xsl:if test="$cantidad_pendientes > 0">
                <xsl:attribute name='style'>color: blue;</xsl:attribute>
              </xsl:if>
              <xsl:value-of select="format-number(@nro_credito, '0000000')" />
            </a>&#160;
          </xsl:when>
        </xsl:choose>
      </td>
      <td style='text-align: right; width: 15%'>
        <span style='float: left'>
          <xsl:value-of  select="@ISO_cod" />&#160;
        </span>
        <xsl:value-of  select="format-number(@importe_pago, '#0.00')" />&#160;
      </td>
      <td style='text-align: left; width: 15%'>
        &#160;<xsl:value-of  select="@pago_concepto" />
      </td>
      <td style='text-align: center; width: 5%'>
        <xsl:value-of  select="@detalle" />
      </td>
      <td style='text-align: center; width: 5%'>
        <xsl:value-of  select="$cantidad_pendientes" />
      </td>
      <td style='text-align: center; width: 5%;'>
        <img style='border: none; cursor: pointer;' alt='Editar Pago' src='/FW/image/icons/editar.png' onclick='return seleccionar_pago({@nro_pago_registro})' title='Editar Pago' />
        <input type='hidden' name='{$pos}' value='{@nro_credito}' />
      </td>
      <!--<td style='width: 5% !Important;' id='tdScroll{$pos}'>
        &#160;&#160;
      </td>-->
      <input type="hidden" id="nro_pago_registro_{$pos}" value="{@nro_pago_registro}" name="nro_pago_registro_{$pos}" />
    </tr>


    <!-- subtemplate para mostrar la tabla de objetos dependientes-->
    <tr style="display:none !important">
      <xsl:attribute name="id">tr_<xsl:value-of  select="$pos" /></xsl:attribute>
      <!--<td style="width: 3%"></td>-->
      <td colspan="10" style="text-align: left">
        <iframe style="width: 90%; height: 95%;margin-top: 0px;" frameborder="0" marginheight="0" marginwidth="0">
          <xsl:attribute name="id">iframe_<xsl:value-of  select="$pos" /></xsl:attribute>
          <xsl:attribute name="name">iframe_<xsl:value-of  select="$pos"/></xsl:attribute>
        </iframe>
      </td>
    </tr>
    <tr style="display:none !important"></tr>

  </xsl:template>

</xsl:stylesheet>