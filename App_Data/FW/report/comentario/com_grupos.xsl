<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Eventos</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
       
        <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>

        <script type="text/javascript" language="javascript">
          <xsl:comment>

            campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"  />'
            var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

            campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
            campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
            campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>

            campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
            campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
            campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>

            if (mantener_origen == '0')
            campos_head.nvFW = window.parent.nvFW

          </xsl:comment>
        </script>


 <script type="text/javascript">
          <![CDATA[
          
              function onload() {
                  window.onresize();
              }

              function onresize() {
                 try{
                   campos_head.resize("header_tbl","tabla_contenido");
                   var contenido = $('tabla_contenido');
                   var body = $(document.body);
                   var tamanio = (body.clientHeight - 30)>40 ?(body.clientHeight - 30) + "px" : "40 px"; 
                    //console.log(tamanio)
                   contenido.style.height = tamanio;
                   }catch(e){
         
                   }
              } 
                    
          ]]>
        </script>

      </head>
      <body style="width:100%; height:100%;overflow:hidden;background-color:white" onload="return onload()" onresize="return onresize()">
        <xsl:variable name="countLogs" select="count(xml/rs:data/z:row/@id_sica_log)"/>

        <div style="width:100%; text-align:center" id="divCabeceras">
          <table class="tb1 highlightEven highlightTROver scroll " id="header_tbl" name="header_tbl" style="width: 100%;">
            <tr class='tbLabel'>
              <td style='width:20%'>Seleccionar</td>
              <td  style='width:30%'>Nro Grupo</td>
              <td  style='width:50%'>Descripcion Grupo</td>
            </tr>
          </table>
        </div>
      <div style="overflow-y:auto;overflow-x:hidden;height:100%;width:100%;background-color:white" id="tabla_contenido">
          <table class="tb1 highlightEven highlightTROver scroll " id="tblog" name="tblog" >
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>         
        </div>
      </body>
    </html>
  

  </xsl:template>
  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="id_nv_log_sistema" select="@id_nv_log_sistema "/>

    <tr>
      <td style='text-align: center;'>
        <center>
          <input type="checkbox"  name='checked_grupo_{@nro_com_grupo}' id='checked_grupo_{@nro_com_grupo}'>
            <xsl:attribute name="onclick">
              parent.addGrupo(this,'<xsl:value-of select="@nro_com_grupo"/>')
            </xsl:attribute>
          </input>
        </center>
      </td>
      <td>
        <xsl:value-of  select="@nro_com_grupo" />
      </td>
      <td>
        <xsl:value-of  select="@com_grupo" />
      </td>
    </tr>

  </xsl:template>
</xsl:stylesheet>


