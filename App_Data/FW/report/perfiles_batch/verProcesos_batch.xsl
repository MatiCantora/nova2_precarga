<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:vbuser="urn:vb-scripts">
  
  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\report\xsl_includes\js_formato.xsl"  />

    <xsl:template match="/">
    <html>
      <head>
        <title>Resultado procesos batch</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        
        <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
        <script language="javascript" type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

            if (mantener_origen == '0')
            campos_head.nvFW = window.parent.nvFW

            function window_onresize() {
            var body = $$("BODY")[0]
            var altoDiv = body.clientHeight - 70
            //var export = $("export").getHeight()
            $("divBody").setStyle({height: altoDiv  + "px" })

            campos_head.resize("tbCabe", "tbDetalle")
            }

            function window_onload(){
            window_onresize()
            }

            function verXMLResultado(id_transf_log){
            $('formXML').XML_id_transf_log.value = id_transf_log
            $('formXML').submit()
            }

            <![CDATA[
            function exportarResultados(id_transf, nro_proceso, id_bpm){
                var res = top.nvFW.createWindow({
                title: "<b>Exportar Parámetros</b>",
                url: "/fw/perfiles_batch/perfiles_param_exportar.aspx?id_transferencia=" + id_transf + "&id_bpm=" + id_bpm + "&nro_proceso=" + nro_proceso,
                width: "500",
                height: "350",
                top: "50",
                setWidthMaxWindow: true,
                destroyOnClose: true,
                onClose: function(win) { }
                })
                res.showCenter()
            }
            ]]>
        </script>
      </head>
      <body style="width: 100%; height: 100%; overflow: hidden; background-color: white;" onresize="window_onresize()" onload="window_onload()">
          <form id="formXML" name="formXML" target="_blank"  action="/FW/transferencia/XML_resultado.aspx" style="display:none" method="post">
              <input name="XML_id_transf_log" id="XML_id_transf_log"/>
          </form>
          <xsl:choose>
              <xsl:when test="count(xml/rs:data/z:row) = 0">
                  <div style="margin: 0 auto; text-align: center;" id="divBody">
                      <h2 style="margin-top: 100px;">Sin resultados</h2>
                      <p style="">No se ejecutaron procesos para el batch.</p>
                  </div>
              </xsl:when>
              <xsl:otherwise>
        <table class="tb1 " id="tbCabe">
            <tr class="tbLabel">
                <td style="width:160px ; text-align: center;">
                    <script>campos_head.agregar('Nro Proceso', true, 'nro_proceso')</script>
                </td>
                <td style="width: 140px; text-align: center;">
                    <script>campos_head.agregar('Fecha' , true, 'fecha_proceso')</script>
                </td>
                <td style="width: 140px; text-align: center;">Tiempo ejecucion</td>
                <td style='width: ; text-align:center' nowrap='nowrap'>
                    <script>campos_head.agregar('Estado', true, 'pr_estado')</script>
                </td>
                <td style='width:140px; text-align:center'  nowrap='nowrap'>Registros totales</td>
                <td style='width:140px; text-align:center'  nowrap='nowrap'>Registros procesados</td>
                <td style="width: 30px; text-align: center;">Detalle</td>
            </tr>
        </table>
        <div style="width: 100%; height: 300px; overflow-y: auto;overflow-x: hidden;" id="divBody">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
                <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
            </table>
        </div>
        <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
        </script>

        <script type="text/javascript">
        campos_head.resize("tbCabe", "tbDetalle")
        </script>
              </xsl:otherwise>
          </xsl:choose>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row" mode="row1">
    <tr>
        
        <td style="width:160px ;text-align:center">
            <xsl:value-of select="@nro_proceso" />
        </td>
        <td style="width: 140px;align: center; text-align: center;">
            <xsl:value-of select="string(@fecha_proceso)"/>
        </td>
        <td style="width: 140px;align: center; text-align: center;">
           <xsl:value-of select='@tiempo' /> Seg.
        </td>
        <td style="width: ; align: center; text-align: center;">
            <xsl:choose>
                <xsl:when test='@pr_estado = 1'>
                    <xsl:attribute name='style'>text-align:center;color:green;width:5%</xsl:attribute>
                    <img border='0' align='absmiddle' hspace='1'>
                        <xsl:attribute name='src'>/fw/image/transferencia/seg_fin.png</xsl:attribute>
                    </img>Finalizado
                </xsl:when>
                <xsl:when test='@pr_estado = "2"'>
                    <xsl:attribute name='style'>text-align:center;width:5%</xsl:attribute>
                    <img border='0' align='absmiddle' hspace='1'>
                        <xsl:attribute name='src'>/fw/image/transferencia/spinner24x24_azul.gif</xsl:attribute>
                    </img>Ejecutando
                </xsl:when>
                <xsl:when test='@pr_estado = "3"'>
                    <xsl:attribute name='style'>text-align:center;width:5%</xsl:attribute>
                    <img border='0' align='absmiddle' hspace='1'>
                        <xsl:attribute name='src'>/fw/image/transferencia/seg_err.png</xsl:attribute>
                    </img>Anulado
                </xsl:when>
                <xsl:when test='@pr_estado = "4"'>
                    <xsl:attribute name='style'>text-align:center;width:5%</xsl:attribute>
                    <img border='0' align='absmiddle' hspace='1'>
                        <xsl:attribute name='src'>/fw/image/transferencia/seg_err.png</xsl:attribute>
                    </img>Error
                </xsl:when>
            </xsl:choose>
        </td>
        <td style='width:140px; text-align:right'>
            <xsl:value-of select="@cantidad_registros"/> </td>
        <td style='width:140px; text-align:right'>
            <xsl:value-of select="@reg_procesados"/>
        </td>
      <td  style="width: 40px; align: center; text-align: center;">
       <img src="/fw/image/icons/editar.png" style="cursor: pointer;" onclick="parent.verResultados({@nro_proceso})" />
     </td>
      <!-- <td style="width: 40px; align: center; text-align: center;">
        <img src="/fw/image/file_dialog/file_xml.png" style="cursor: pointer;" onclick="verXMLResultado({@id_transferencia_log})" />
      </td>
    <td  style="width: 40px; align: center; text-align: center;">
        <img src="/fw/image/icons/procesar.png" style="cursor: pointer;" onclick="parent.ejecutarTransferencia({@id_transferencia_log})" />
    </td>-->
    </tr>
  </xsl:template>

</xsl:stylesheet>