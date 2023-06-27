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
  
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Consulta Comentarios</title>
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

        <script language="javascript" type="text/javascript">
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
        <script type="text/javascript" language="javascript">
          <![CDATA[
					var win_comentario

                    //function verUser_contact(e, nro_registro, nro_com_tipo, com_tipo, nro_com_estado, com_estado, fecha, operador, id_tipo, nro_entidad, nro_com_id_tipo, nro_com_grupo) {
        //    var filtro = '';

        //    var url_destino = '';
        //    if (nro_com_id_tipo == 5)
        //        url_destino = '/yacare/comentarios_backoffice/comentario_seleccion_backoffice.aspx?nro_entidad=' + id_tipo + '&nro_com_id_tipo=' + nro_com_id_tipo;
        //    else
        //        url_destino = '/yacare/comentarios_backoffice/comentario_seleccion_backoffice.aspx?contact_id=' + id_tipo + '&nro_com_id_tipo=' + nro_com_id_tipo;

        //    if (e.ctrlKey == true) {
        //        var win = window.open(url_destino)
        //    } else if (e.shiftKey) {
        //        // Nueva ventana de browser
        //        var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
        //        newWin.moveTo(0, 0)
        //        newWin.resizeTo(screen.availWidth, screen.availHeight)
        //    } else {

        //        var win = window.top.nvFW.createWindow({
        //            className: 'alphacube',
        //            title: '<b></b>',
        //            minimizable: true,
        //            maximizable: true,
        //            draggable: true,
        //            //width: 600,
        //            //height: 520,
        //            width: 1400,
        //            height: 700,
        //            resizable: true
        //        });

        //        if (nro_com_id_tipo == 5)
        //            win.setURL(url_destino)
        //        else
        //            win.setURL(url_destino)
        //        win.showCenter()
        //    }
        //}		
            
            
            var Parametros = []
            function Alta_Comentario(nro_registro, nro_com_tipo, com_tipo, nro_com_estado, com_estado, fecha, operador, id_tipo, nro_entidad, nro_com_id_tipo, nro_com_grupo, bloq_operador, bloqueado, e) {
                var filtro = ""
                
                var url_destino = '/FW/comentario/ABMRegistro.aspx' +
                        '?nro_entidad=' + nro_entidad +
                        '&id_tipo=' + id_tipo +
                        '&nro_com_id_tipo=' + nro_com_id_tipo +
                        '&nro_registro_origen=' + nro_registro +
                        '&nro_com_tipo_origen=' + nro_com_tipo +
                        '&nro_com_estado_origen=' + nro_com_estado +
                       // '&nro_circuito=' + 1 +
                        '&nro_com_grupo=' + nro_com_grupo +
                        '&collapsed_fck=' + 1 +
                        '&bloq_menu=' + 1 +
                        '&bloqueado=' + bloqueado +
                        '&bloq_operador=' + bloq_operador
                        
                Parametros["nro_entidad"] = nro_entidad
                Parametros["id_tipo"] = id_tipo
                Parametros["nro_com_id_tipo"] = nro_com_id_tipo
                Parametros["nro_registro_origen"] = nro_registro
                Parametros["nro_com_tipo_origen"] = nro_com_tipo
                Parametros["nro_com_estado_origen"] = nro_com_estado
                Parametros["collapsed_fck"] = 1
                Parametros["nro_circuito"] = 2
                Parametros["nro_com_grupo"] = nro_com_grupo
                Parametros["bloq_operador"] = bloq_operador
                Parametros["bloqueado"] = bloqueado
                
                if (e.ctrlKey == true) {
                  var win = window.open(url_destino)
                  console.log(win)
                  console.log(win.getId())
                } else if (e.shiftKey) {
                  // Nueva ventana de browser
                  var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                  newWin.moveTo(0, 0)
                  newWin.resizeTo(screen.availWidth, screen.availHeight)
                  } else {

                    window.top.win = window.top.nvFW.createWindow({
                        url: url_destino,
                        title: '<b>Alta de Comentario</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        width: 800,
                        //height: 624,
                        height: 600,
                        resizable: true,
                        destroyOnClose: true,
                        onClose: Alta_Comentario_return
                    });

                    window.top.win.options.userData = Parametros
                    window.top.win.showCenter()
                
                }

            }		


          function Alta_Comentario_return() {}


          function Persona_mostrar(e, nro_docu, tipo_docu, sexo, documento, apellido, nombres) {
              window.parent.Persona_mostrar(e, nro_docu, tipo_docu, sexo, documento, apellido, nombres);
          }

          function window_onload() {
              window_onresize()
          }

          function window_onresize() {
              try {
              
                  var dif = Prototype.Browser.IE ? 5 : 2
                  var body_height = $$('body')[0].getHeight()
                  var tbCabe_height = $('tbCabe').getHeight()
                  var div_pag_height = $('div_pag').getHeight()

                  $('divDetalle').setStyle({
                      height: body_height - tbCabe_height - div_pag_height - dif + 'px'
                  })
              
                  campos_head.resize("tbCabe", "tbDetalle")
              } catch (e) {}
              
          }


          function onmove_sel(indice) {
              $('tr_ver' + indice).addClassName('tr_cel')
          }

          function onout_sel(indice) {
              $('tr_ver' + indice).removeClassName('tr_cel')
          }
					
          
					
					]]>
        </script>
        <style type="text/css">
          .tr_cel TD
          {
          background-color: white !Important
          }
          .tr_cel_click TD
          {
          background-color: #BDD3EF !Important,
          color : #0000A0 !Important
          }
        </style>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
        <table class="tb1" id="tbCabe">
          <tr class="tbLabel">
            <td style='width:5%; text-align:center'>-</td>
            <td style='width:20%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Motivo', true, 'com_tipo')
              </script>
            </td>
            <td style='text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Comentario', true, 'comentario')
              </script>
            </td>
            <td style='width:10%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Estado', true, 'com_estado')
              </script>
            </td>
            <td style='width:10%; text-align:center'>
              <script type="text/javascript">
                campos_head.agregar('Fecha', true, 'fecha')
              </script>
            </td>
          </tr>
        </table>

        <div id="divDetalle" style="width:100%;overflow:auto">
          <table id="tbDetalle" class='tb1 highlightOdd highlightTROver layout_fixed'>
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>

        <div id="div_pag" class="divPages">
          <script type="text/javascript">
            if (campos_head.PageCount > 1)
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <tr style="max-height:18px !important'">
      <xsl:attribute name="id">
        tr_ver<xsl:value-of select="$pos"/>
      </xsl:attribute>
      <td  style='text-align: center;'>
        <a style='cursor:pointer'>
          <xsl:attribute name='onclick'>
            return Alta_Comentario(<xsl:value-of select='@nro_registro'/>, <xsl:value-of select='@nro_com_tipo'/>, '<xsl:value-of select='@com_tipo'/>', <xsl:value-of select='@nro_com_estado'/>, '<xsl:value-of select='@com_estado'/>', '<xsl:value-of  select="foo:FechaToSTR(string(@fecha))" />', <xsl:value-of select='@operador'/>, <xsl:value-of select='@id_tipo'/>, '<xsl:value-of select="@nro_entidad"/>', <xsl:value-of select='@nro_com_id_tipo'/>, <xsl:value-of select='@nro_com_grupo'/>, "<xsl:value-of select='@bloq_operador'/>", "<xsl:value-of select='@bloqueado'/>", event)
          </xsl:attribute>
          <img src='../image/comentario/comentario.png' border='0' align='absmiddle' hspace='1'/>
        </a>&#160;
        <!--<a style='cursor:pointer'>
          <xsl:attribute name='onclick'>
            return verUser_contact(event, <xsl:value-of select='@nro_registro'/>, <xsl:value-of select='@nro_com_tipo'/>, '<xsl:value-of select='@com_tipo'/>', <xsl:value-of select='@nro_com_estado'/>, '<xsl:value-of select='@com_estado'/>', '<xsl:value-of  select="foo:FechaToSTR(string(@fecha))" />', <xsl:value-of select='@operador'/>, <xsl:value-of select='@id_tipo'/>, '<xsl:value-of select="@nro_entidad"/>', <xsl:value-of select='@nro_com_id_tipo'/>, <xsl:value-of select='@nro_com_grupo'/>)
          </xsl:attribute>
          <img src='../image/comentario/user.png' border='0' align='absmiddle' hspace='1'/>
        </a>-->
      </td>
      <td>
        <xsl:attribute name='style'>
          <xsl:value-of select="@style"/> text-align: left;
        </xsl:attribute>
        <xsl:value-of select="@com_tipo"/>
      </td>
      <td  style='text-align: left;'>
        <xsl:value-of select="@comentario" disable-output-escaping="yes"/>
      </td>
      <td  style='text-align: left;'>
        <xsl:value-of select="@com_estado"/>
      </td>
      <td  style='text-align: right;'>
        <xsl:value-of select="foo:FechaToSTR(string(@fecha))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fecha))"/> 
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
