<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Eventos</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
        <style type="text/css">
          tr {
          white-space: nowrap !important;
          }
          td.Error{
          color: #D8000C;
          background-color: #FFBABA;
          }
          td.FailureAudit{
          color: #D8000C;
          background-color: #FFBABA;
          }
          td.Information{
          color: #059;
          background-color: #BEF;
          }
          td.SuccessAudit{
          color: #270;
          background-color: #DFF2BF;
          }
          td.Warning{
          color: #9F6000;
          background-color: #FEEFB3;
          }
        </style>
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
          
              var descripciones = {};
              function onload() {
                  onresize();
              }


              function onresize() {
                  
                  try {
                      var body_h = $$('BODY')[0].getHeight();
                      var divHeader_h = $('divCabeceras').getHeight();
                      var div_pag1_h = $('div_pag1').getHeight();

                      var h = body_h - divHeader_h - div_pag1_h;
                      if (h > 0) {
                          $('tabla_contenido').setStyle({ height: h + 'px', overflow: "auto" });
                      }
                  }                  
                  catch (e) {}
                  
                  campos_head.resize('header_tbl', 'tbDetalle')
                  
              }
  
              function getDescripcionBoton(idlog, fe_log, instancia, name, msg, machine, log, logType){
                
                  var descripcion={};
                  descripcion["idlog"] = idlog;
                  descripcion["fe_log"] = fe_log;
                  descripcion["instancia"] = instancia;
                  descripcion["name"] = name;
                  descripcion["msg"] = (new RegExp(msg)).source;
                  descripcion["machine"] = machine;
                  descripcion["log"] = log;
                  descripcion["logType"] = logType;
              
                  parent.descripciones[idlog] = descripcion;
                  
                  return "<img border='0'  onclick='verDescripcion("+idlog+")' "+
                                                "src='/FW/image/icons/ver.png' title='ver' />"; 
              
              }
                
                
              function verDescripcion(idlog){
                parent.verDescripcion(idlog)
              }

          ]]>
        </script>

      </head>
      <body style="width:100%; height:100%;overflow:hidden; background-color: white;" onload="return onload()" onresize="return onresize()">
        <xsl:variable name="countLogs" select="count(xml/rs:data/z:row/@idlog)"/>

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="margin: 0 auto; text-align: center;" id="divBody">
              <h2 style="margin-top: 100px;">Sin resultados</h2>
              <p style="color: #999;">No existe ningún evento con los filtros suministrados</p>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div style="width:100%;" id="divCabeceras">
              <table class="tb1" id="header_tbl" name="header_tbl">
                <tr class='tbLabel'>
                  <td style='width: 10%'>
                    <script>campos_head.agregar('Fecha', true, 'fe_log')</script>
                  </td>
                  <td style='width: 14%'>
                    <script>campos_head.agregar('Instancia', true, 'instancia')</script>
                  </td>
                  <td style='width: 14%'>
                     <script>campos_head.agregar('Watcher', true, 'name')</script>
                  </td>
                  <td style='width: 48%'>
                     <script>campos_head.agregar('Descripción', true, 'msg')</script>
                  </td>
                  <td style='width: 10%'>
                     <script>campos_head.agregar('Tipo Evento', true, 'nro_logType')</script>
                  </td>
              
                  <td style="width: 30px; cursor: pointer; text-align: center;" width="30px">
                      <img alt="Exportar Excel" src="/fw/image/filetype/xlsx.png" onclick="parent.exportar()" title="Exportar a Excel" />
                  </td>
                </tr>
              </table>
            </div>
       
            <div id="tabla_contenido">
              <table class="tb1 highlightEven highlightTROver layout_fixed" id="tbDetalle" name="tbDetalle" >
                <xsl:apply-templates select="xml/rs:data/z:row" />
              </table>
            </div>
          
       
            <div style="float:left" id="div_pag1" class="divPages">
              <script type="text/javascript">
                document.write(campos_head.paginas_getHTML())
              </script>
            </div>
          
          <!--<div style="float:left" id="div_pag2">
            <script type="text/javascript">
              document.write('Total ' + '<xsl:value-of select="count(xml/rs:data/z:row)"></xsl:value-of>' + '/' + '<xsl:value-of select="xml/params/@recordcount"/>')
            </script>
          </div>-->
            <script type="text/javascript">
              campos_head.resize("header_tbl", "tbDetalle")
            </script>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>
    
    
  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="idlog" select="@idlog "/>

    <tr>
      <td>
          <xsl:attribute name="title">
              <xsl:value-of  select="foo:FechaToSTR(string(@fe_log))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_log))"></xsl:value-of>
          </xsl:attribute>
        <xsl:value-of  select="foo:FechaToSTR(string(@fe_log))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_log))"></xsl:value-of>
      </td>
      
      <td>
          <xsl:attribute name="title">
              <xsl:value-of  select="@instancia" />
          </xsl:attribute>
        <xsl:value-of  select="@instancia" />
      </td>
      <td>
          <xsl:attribute name="title">
              <xsl:value-of  select="@name" />
          </xsl:attribute>
        <xsl:value-of  select="@name" />
      </td>
      <td >
          <xsl:attribute name="title">
            <xsl:value-of select='@msg'/>
          
          </xsl:attribute>
        <xsl:value-of  select="@msg" />
      </td>
      <td >
          <xsl:attribute name="title">
              <xsl:value-of  select="@logType" />
          </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:value-of  select="@logType" />
        </xsl:attribute>
        <xsl:value-of  select="@logType" />
      </td>
      <td  style='width: 30px; align: center; text-align: center;' width="30px">
        <script>  
          try{
            document.write(getDescripcionBoton('<xsl:value-of select="@idlog" />', '<xsl:value-of select="foo:FechaToSTR(string(@fe_log))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_log))"></xsl:value-of>', '<xsl:value-of select="@instancia" />', '<xsl:value-of select="@name" />', 
              /<xsl:value-of select='normalize-space(@msg)'/>/, '<xsl:value-of select="@machine" />', '<xsl:value-of select="@log" />', '<xsl:value-of select="@logType" />' ) ) 
          }catch(e){}
        </script>
      </td>
    </tr>

  </xsl:template>
</xsl:stylesheet>


