<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				xmlns:vbuser="urn:vb-scripts">
  
  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>Listado perfiles bpm batch</title>
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
                var altoDiv = body.clientHeight - 50
                $("divBody").setStyle({height: altoDiv + "px" })

                campos_head.resize("tbCabe", "tbDetalle")
            }

            function window_onload(){
                window_onresize()
            }

            

        </script>
      </head>
      <body style="width: 100%; height: 100%; overflow: hidden; background-color: white;" onresize="window_onresize()" onload="window_onload()">
        <table class="tb1 " id="tbCabe">
            <tr class="tbLabel">
                <td style="width: 40px; cursor: pointer; text-align: center;"></td>
                <td style="width: 50px;">ID</td>
                <td  style="width: 20%">
                    <script>campos_head.agregar('Descripción', 'true', 'bpm_batch')</script>
                </td>
                <td style="width: 50px;">ID</td>
                <td style="width: 25%">
                    <script>campos_head.agregar('Transferencia', 'true', 'nombre_transf')</script>
                </td>
                <td style="width: 25%">Nombre excel</td>
                <td style="width: 40px; cursor: pointer; text-align: center;">
                    <img src="/fw/image/icons/bajar.png" style="cursor: pointer;" />
                </td>
                <td style="width: 40px; cursor: pointer; text-align: center;"></td>
            </tr>
        </table>
        <div style="width: 100%; height: 300px; overflow-y: auto;" id="divBody">
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
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row" mode="row1">
    <tr>
         <td style="align: center; text-align: center;">
        <img src="/fw/image/icons/editar.png" style="cursor: pointer;" title="Editar" onclick="parent.bpm_batch_editar({@id_bpm_batch})" />
      </td>
        <td style="text-align:right">
        <xsl:value-of select="@id_bpm_batch" />
      </td>
      <td >
        <xsl:value-of select="@bpm_batch" />
      </td>
      <td style="text-align:right">
        <xsl:value-of select="@id_transferencia" />
      </td>
      <td>
         <xsl:value-of select="@nombre_transf" /> 
      </td>
      <td>
          <xsl:value-of select="@nombre_excel" />
      </td>
        <td style="align: center; text-align: center;">
            <img src="/fw/image/filetype/excel.png" style="cursor: pointer;" title="Descargar" onclick="parent.batch_descargar_excel({@id_bpm_batch},'{@nombre_excel }' )" />
        </td>
     
    <td style="align: center; text-align: center;">
        <img src="/fw/image/icons/procesar.png" style="cursor: pointer;" title="Procesar" onclick="parent.bpm_batch_procesar({@id_bpm_batch})" />
    </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>