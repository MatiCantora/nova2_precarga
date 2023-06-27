<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />

  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>


  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

        <title>Buscar Documentos</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/FW/script/swfobject.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
        <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>

        <script  type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW
        </script>
        <script type="text/javascript" >
          <xsl:comment>
            <![CDATA[ 

                            function window_onresize() {
                                try {
                                    var dif = Prototype.Browser.IE ? 5 : 2
                                    var body_height = $$('body')[0].getHeight()
                                    var tbCabe1_height = $('tbCabe1').getHeight()
                                    var div_pag1_height = $('div_pag1').getHeight()

                                    $('divDetalle1').setStyle({
                                        height: body_height - div_pag1_height - tbCabe1_height - dif + 'px'
                                    })

                                    $('tbDetalle1').getHeight() - $('divDetalle1').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
                                } 
                                catch (e) {}
                            }

                            function tdScroll_hide_show(show) {
                                var i = 1
                                while (i <= campos_head.recordcount) {
                                    if (show && $('tdScroll' + i) != undefined)
                                        $('tdScroll' + i).show()

                                    if (!show && $('tdScroll' + i) != undefined)
                                        $('tdScroll' + i).hide()

                                    i++
                                }
                            }

                            function window_onload() {
                                window_onresize()
                            }

                            function mostrarDependencias(id_cierre_def, nro_cierre_periodo) {
                                window.parent.mostrarDependencias(id_cierre_def, nro_cierre_periodo)
                            }


                            function ejecutarCierre(id_cierre_def, nro_cierre_periodo, id_transferencia, cierre_periodo, cierre_def) {
                                window.parent.ejecutarCierre(id_cierre_def, nro_cierre_periodo, id_transferencia, cierre_periodo, cierre_def)
                            }

                            function controlarCierre(id_cierre_def, nro_cierre_periodo, str_cierre) {
                                window.parent.controlarCierre(id_cierre_def, nro_cierre_periodo, str_cierre)
                            }

                            function mostrarArchivos(id_cierre_def, nro_cierre_periodo, str_cierre) {
                                window.parent.mostrarArchivos(id_cierre_def, nro_cierre_periodo, str_cierre)
                            }

                            function mostrarHistorial(id_cierre_def, nro_cierre_periodo, str_cierre) {
                                window.parent.mostrarHistorial(id_cierre_def, nro_cierre_periodo, str_cierre)
                            }

                            function anularCierre(id_cierre_def, nro_cierre_periodo, str_cierre) {
                                window.parent.anularCierre(id_cierre_def, nro_cierre_periodo, str_cierre)
                            }

                            function abrir_transferencia(id_transferencia) {
                                if ((window.top.permisos_cierres & 2) > 0) {
                                    var url = "/FW/transferencia/transferencia_ABM.aspx?id_transferencia=" + id_transferencia
                                    window.parent.open(url, '_blank')
                                }
                            }
                          ]]>
          </xsl:comment>
        </script>

      </head>
      <body onload="window_onload()"  style="width:100%;height:100%;overflow:hidden">
       
        
        <table class="tb1" id="tbCabecera">
          <tr class="tbLabel">

            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Periodo', true,'cierre_periodo')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Fecha desde', true,'fe_desde')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Fecha hasta', true,'fe_hasta')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Cierre', true,'fe_hasta')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Tipo de cierre', true,'fe_hasta')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Estado', true,'fe_hasta')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Acciones', true,'fe_hasta')</script>
            </td>
            <td style='width: 2%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('', true,' ')</script>
            </td>
          </tr>
        </table>
          
        <div id="divDetalle1" style="width:100%;overflow:auto">
          <table class="tb1 highlightEven highlightTROver" id="tbDetalle1">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag1" class="divPages">
          <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <tr name="dataRow">
      <xsl:attribute name="id">
        tr_ver<xsl:value-of select="$pos"/>
      </xsl:attribute> 
      <td style='text-align: left; width:10%'>
        <xsl:value-of select="@cierre_periodo"/>
      </td>
      <td style='text-align: center; width:10%'>
        <xsl:value-of select="@fe_desde"/>
      </td>
      <td style='text-align: center; width:10%'>
        <xsl:value-of select="@fe_hasta"/>
      </td>
      <td style='text-align: center; width:29%'>
        <xsl:attribute name="onclick">
          abrir_transferencia(<xsl:value-of select="@id_transferencia"/>)
        </xsl:attribute>
        <xsl:attribute name="style">
          <xsl:choose>
            <xsl:when test="@det_estado = 'Esperando Dependencia'">color:#AAA60F !Important;text-align: left; width:27%;cursor:pointer</xsl:when>
            <xsl:when test="@det_estado = 'Pendiente' or @det_estado='Anulado'">color:#ED8714 !Important;text-align: left; width:27%;cursor:pointer</xsl:when>
            <xsl:when test="@det_estado ='Iniciado'">color:green !Important;text-align: left; width:27%;cursor:pointer</xsl:when>
            <xsl:when test="@det_estado ='Controlado' ">color:blue !Important;text-align: left; width:27%; cursor:pointer</xsl:when>
            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="@cierre_def"/>
      </td>
      <td style='text-align: left; width:7%'>
        <xsl:value-of select="@cierre_tipo"/>
      </td>
      <td style='text-align: left; width:15%'>
        <xsl:choose>
          <xsl:when test="@det_estado='Anulado'">Pendiente</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@det_estado"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style="text-align:center; width:3%">
        <xsl:if test="(@det_estado='Pendiente' and @ejecuta=1) or (@det_estado='Anulado' and @ejecuta=1)">
          <img title="Ejecutar cierre" style="cursor:hand; cursor:pointer" src='../../fw/image/icons/procesar.png'>
            <xsl:attribute name='onclick'>
              return ejecutarCierre(<xsl:value-of select="@id_cierre_def"/>,<xsl:value-of select="@nro_cierre_periodo"/>,<xsl:value-of select="@id_transferencia"/>,'<xsl:value-of select="@cierre_periodo"/>','<xsl:value-of select="@cierre_def"/>')
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
      <td style="text-align:center; width:3%">
        <xsl:if test="@det_estado ='Iniciado' and @controla=1">
          <img title="Controlar cierre" style="cursor:hand; cursor:pointer" src='../../fw/image/icons/editar.png'>
            <xsl:attribute name='onclick'>
              return controlarCierre(<xsl:value-of select="@id_cierre_def"/>,<xsl:value-of select="@nro_cierre_periodo"/>,'<xsl:value-of select="@cierre_def"/>')
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
      <td style="text-align:center; width:3%">
        <xsl:if test="@dependencias != ''">
          <img title="Dependencias del cierre" style="cursor:hand; cursor:pointer" src='../../fw/image/icons/modulo.png'>
            <xsl:attribute name='onclick'>
              return mostrarDependencias(<xsl:value-of select="@id_cierre_def"/>,<xsl:value-of select="@nro_cierre_periodo"/>)
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
      <td style="text-align:center; width:3%">
        <xsl:if test="@det_estado ='Iniciado' or @det_estado='Controlado'">
          <img title="Ver archivos del cierre" style="cursor:hand; cursor:pointer" src='../../fw/image/icons/file.png'>
            <xsl:attribute name='onclick'>
              return mostrarArchivos(<xsl:value-of select="@id_cierre_def"/>,<xsl:value-of select="@nro_cierre_periodo"/>,'<xsl:value-of select="@cierre_def"/>')
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
      <td style="text-align:center; width:3%">
        <xsl:if test="@det_estado ='Iniciado' or @det_estado='Controlado' or @det_estado ='Anulado'">
          <img title="Ver historial de acciones" style="cursor:hand; cursor:pointer" src='../../fw/image/icons/sector.png'>
            <xsl:attribute name='onclick'>
              return mostrarHistorial(<xsl:value-of select="@id_cierre_def"/>,<xsl:value-of select="@nro_cierre_periodo"/>,'<xsl:value-of select="@cierre_def"/>')
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
      <td style="text-align:center; width:3%">
        <xsl:if test="@det_estado ='Iniciado' and @anula=1">
          <img title="Anular cierre" style="cursor:hand; cursor:pointer" src='../../fw/image/icons/CloseSearch.gif'>
            <xsl:attribute name='onclick'>
              return anularCierre(<xsl:value-of select="@id_cierre_def"/>,<xsl:value-of select="@nro_cierre_periodo"/>,'<xsl:value-of select="@cierre_def"/>')
            </xsl:attribute>
          </img>
        </xsl:if>
      </td>
      <td style='width:1% !Important'>
        <xsl:attribute name='id'>
          tdScroll<xsl:value-of select="$pos"/>
        </xsl:attribute>&#160;&#160;
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
