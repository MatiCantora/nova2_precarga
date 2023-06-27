<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
		
		var nro_ref_doc_tipo = -1
		var nro_ref_doc = -1

		var ref_ant = 0
		function get_ref_nueva(nro_ref)
		{
        if (ref_ant == nro_ref)
		      return false
		    else {
		      ref_ant = nro_ref
		      return true
		    }
		}
      
    var primera_vez = true;
		function get_primera_vez()
    {
		    if(primera_vez){
		      primera_vez = false;
		      return true;
		    }
		  return false;
		  }
		var tiene_resumibles = false;
		function setResumibles(){
		    tiene_resumibles = true;
		    return true;
		}
		function getResumibles(){
		    return tiene_resumibles;
		}
		]]>
  </msxsl:script>

  <xsl:template match="/">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
      <title>Referencia</title>
      <!--<link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>-->
      <link href="/wiki/css/base.css" type="text/css" rel="stylesheet"/>

      <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
      <script type="text/javascript" language="javascript" src="/FW/script/nvFW_BasicControls.js"></script>
      <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>

      <script type="text/javascript" language="javascript">
        <xsl:comment>
          var nro_ref = '<xsl:value-of select="xml/rs:data/z:row/@nro_ref"></xsl:value-of >'

          <![CDATA[
						
			function window_onresize()
            {
              if(nro_ref != '')
              {
                body_heigth = $$('body')[0].getHeight();
                //titulo_heigth = $('tb_titulo').getHeight() + $$('.ref_titulo.first')[0].getHeight();
                //var a = $('tb_body')
                //a.setStyle({'height': body_heigth - titulo_heigth})
						  }
            }
            
            function window_onload()
						{ 
              window_onresize()
						}
						  
						function imprimir()
						{
						  window.print()
 						}
		
						]]>
        </xsl:comment>
      </script>
      <style>
        @media print
        {
        .noprint
        {
        display: none
        }
        }

      </style>
    </head>
    <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto">
      <xsl:apply-templates select="xml/rs:data/z:row" mode="tipo" />
      <xsl:variable name="tiene_resumibles" select="foo:getResumibles()"></xsl:variable>
      <xsl:if test="$tiene_resumibles">
        <hr></hr>
        <table class="resumen_tb" >
          <tr class="resumen_titulo">
            <td style="width:25%">
              Tema
            </td>
            <td>
              Descripci&#243;n
            </td>
          </tr>
          <xsl:apply-templates select="xml/rs:data/z:row" mode="resumen" />
        </table>
      </xsl:if>
    </body>
  </html>
  </xsl:template>
  
  <xsl:template match="z:row" mode="tipo">
    <xsl:variable name="ref_nueva" select="foo:get_ref_nueva(number(@nro_ref))"></xsl:variable>
    <xsl:variable name="nro_ref_doc_tipo" select="@nro_ref_doc_tipo"/>
    <xsl:variable name="primer_vez" select="foo:get_primera_vez()"></xsl:variable>
    <xsl:variable name="nro_ref_doc" select="@nro_ref"></xsl:variable>
    <xsl:variable name="nro_ref_raiz" select="number(/xml/rs:data/z:row/@nro_ref)"></xsl:variable>

    <xsl:if test="$nro_ref_doc = $nro_ref_raiz">
      <xsl:if test="$ref_nueva">
        <table id="tb_titulo"  style="width: 100%; border: 0px;"  cellspacing="0" >
          <tr class="ref_titulo">
            <xsl:if test="$primer_vez">
              <td nowrap="true">
                <a class="noprint" style="font-family:Verdana; font-size:13px; font-weight:bold; color:#404040" >
                  <xsl:attribute name="href">javascript:imprimir()</xsl:attribute>
                  <img alt='Imprimir'  border='0' align='absmiddle' hspace='2' src="/fw/image/icons/imprimir.png"></img >
                  Imprimir
                </a>
              </td>
            </xsl:if>
            <td  style="width: 100%">
              <xsl:value-of select="@referencia"/>. <span class="ref_titulo_sub">Ref <xsl:value-of select="@nro_ref"/></span>
            </td>
            <xsl:if test="$primer_vez">
              <!--<td nowrap="true">
                  <a class="noprint" style="font-family:Verdana; font-size:8pt; font-weight:bold; color: white" >
                      <xsl:attribute name="href">/wiki/ref_export.asp?nro_ref=<xsl:value-of select='@nro_ref'/>&amp;file_type=pdf&amp;tipo_salida=resumen</xsl:attribute>
                      <xsl:attribute name="target">_blank</xsl:attribute>
                      <img alt='Imprimir'  border='0' align='absmiddle' hspace='2' src="../../meridiano/image/icons/file_pdf.png"></img>
                      Exportar a pdf
                  </a>
              </td>-->
            </xsl:if>
          </tr>
        </table>
      </xsl:if>
      <table class="tbDoc_cab" >
        <tr nowrap="true">
          <td style="text-align:left vertical-align:middle" rowspan="2">
            <h9>
              <span class="ref_doc_titulo">
                <xsl:value-of select="@ref_doc_titulo"/>
              </span>
            </h9>
          </td>
        </tr>
      </table>
      <table style="width:100%">
        <tr nowrap="true">
          <xsl:attribute name="id">trDocu<xsl:value-of select="@nro_ref_doc"/></xsl:attribute>
          <td style='width:17px'></td>
          <td style='vertical-align:top; margin:auto'>
            <div>
              <xsl:attribute name='id'>divDOC<xsl:value-of select='@id_ref_doc'/></xsl:attribute>
            </div>
            <script type="text/javascript" language="javascript">
                <xsl:comment>
                  var id_ref_doc = '<xsl:value-of select='@id_ref_doc'/>'
                  var divID = 'divDOC' + id_ref_doc;
                  nvFW.insertFileInto(id_ref_doc, divID)
                </xsl:comment>
            </script>
          </td>
        </tr>
      </table>
    </xsl:if>
    <xsl:if test="$nro_ref_doc != $nro_ref_raiz">
      <xsl:variable name="tiene_resumibles" select="foo:setResumibles()"></xsl:variable>
    </xsl:if>
  </xsl:template>

  <xsl:template match="z:row" mode="resumen">
    <xsl:variable name="ref_nueva" select="foo:get_ref_nueva(number(@nro_ref))"></xsl:variable>
    <xsl:variable name="nro_ref_doc_tipo" select="@nro_ref_doc_tipo"/>
    <xsl:variable name="primer_vez" select="foo:get_primera_vez()"></xsl:variable>
    <xsl:variable name="nro_ref_doc" select="@nro_ref"></xsl:variable>
    <xsl:variable name="nro_ref_raiz" select="number(/xml/rs:data/z:row/@nro_ref)"></xsl:variable>

    <xsl:if test="$nro_ref_doc != $nro_ref_raiz">
      <xsl:if test="@nro_ref_doc_tipo = 1 and @nro_ref_padre = $nro_ref_raiz">
        <tr>
          <td style="width: 25%">
            <a>
              <xsl:attribute name="href">javascript:ref_mostrar(<xsl:value-of select="@nro_ref"/>)</xsl:attribute>
              <xsl:value-of select="@referencia"/>
            </a>
          </td>
          <td>
            <div>
              <xsl:attribute name='id'>divDOC<xsl:value-of select='@id_ref_doc'/></xsl:attribute>
            </div>
            <script type="text/javascript" language="javascript">
              <xsl:comment>
                var id_ref_doc = '<xsl:value-of select='@id_ref_doc'/>'
                var divID = 'divDOC' + id_ref_doc;
                nvFW.insertFileInto(id_ref_doc, divID)
              </xsl:comment>
            </script>
          </td>
        </tr>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>


