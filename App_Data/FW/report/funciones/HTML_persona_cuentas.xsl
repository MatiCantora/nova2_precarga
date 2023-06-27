<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				                      xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				                      xmlns:rs='urn:schemas-microsoft-com:rowset' 
				                      xmlns:z='#RowsetSchema'
				                      xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	                            xmlns:foo="http://www.broadbase.com/foo"
                              extension-element-prefixes="msxsl"
                              exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl" />
  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<html>
			<head>
				<title>Cuentas de Persona</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        
        <style type="text/css">
          img { align: center; border: 0; cursor: pointer; }
          .tr_cel TD { background-color: white !Important; }
          .tr_cel_click TD { background-color: #BDD3EF !Important; color: #0000A0 !Important; }
        </style>
        
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <script language="javascript" type="text/javascript">
          var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
        </script>

        <script type='text/javascript' language="javascript" >
          <![CDATA[
          function obtener_id_cuenta()
          {
            var id_cuenta = window.parent.$('id_cuenta').value
            var modo      = window.parent.$('modo').value

            if (id_cuenta != -1 && id_cuenta != undefined && id_cuenta != '' && id_cuenta != 0) {
              $('RCuenta' + id_cuenta).checked = true;
            }
          }


          function window_onresize()
          {
            try {
              var h_body                 = $$("body")[0].getHeight()
              var h_divMenuABMDescuentos = $("divMenuABMDescuentos").getHeight()
              var h_tbCabecera           = $("tbCabecera").getHeight()
              var nueva_h                = h_body - h_divMenuABMDescuentos - h_tbCabecera
                            
              $("contenido").setStyle({ height: nueva_h + "px" })
                            
              $("tbContenido").getHeight() > nueva_h ? $("tdScroll").show() : $("tdScroll").hide();
            }
            catch(e) {}
          }


          function window_onload()
          {
            obtener_id_cuenta()
            window_onresize()
          }
          ]]>
        </script>
      </head>
			<body style="width: 100%; height: 100%; overflow: auto; background-color: white;" onload="return window_onload()">
        <div id="divMenuABMDescuentos"></div>

				<table class="tb1" id="tbCabecera">
          <tr class="tbLabel">
					  <td style='text-align: center; width: 45px'>-</td>
					  <td style='text-align: center;'>Banco - Sucursal</td>					
            <td style='text-align: center; width: 90px'>Tipo Cta</td>                  
            <td style='text-align: center; width: 220px'>Nro. Cuenta</td>
				    <td style='text-align: center; width: 45px'>Hab.</td>
						<td style='text-align: center; width: 45px'>-</td>
            <td style='width: 14px; display: none;' id='tdScroll'>&#160;</td>
					</tr>
				</table>

				<div style="width: 100%; height: 170px; overflow-y: auto;" id="contenido">
				  <table class="tb1 highlightOdd highlightTROver" id="tbContenido">
					  <xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>

			</body>
		</html>
	</xsl:template>
  
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()" />

		<tr id="tr_ver{$pos}">
      <td style='text-align: center; width: 45px' >
			  <input type="hidden" value="{$pos}" id="cuenta_{@id_cuenta}" />
				<input type="hidden" value="{@id_cuenta_old}" id="cuenta_old_{$pos}" />
				<input type="hidden" value="{@nro_banco}" id="nro_banco_{$pos}" />
				<input type="hidden" value="{@id_banco_sucursal}"  id="id_banco_sucursal_{$pos}"/>
			  <input type='radio' name='RCuenta' style='border: none; cursor: pointer;' onclick='window.parent.RCuenta_onclick({$pos}, {@id_cuenta}, "{@id_cuenta_old}", {@nro_banco}, {@id_banco_sucursal})' value='{$pos}' id='RCuenta{@id_cuenta}' title='Seleccionar {@banco}' />
      </td>
      <td style='text-align: left;'>
        &#160;<xsl:value-of select="@banco" /> - <xsl:value-of select="@banco_sucursal" />
      </td>            			
			<td style='text-align: center; width: 90px;'>
        <xsl:value-of select="@tipo_cuenta_desc" />
      </td>
			<td style='text-align: right; width: 220px;'>
        <xsl:value-of select="@nro_cuenta" />&#160;
      </td>
			<td style='text-align: center; width: 45px;' >							
			  <xsl:choose>
				  <xsl:when test='string(@habilitada) ="True"'>Si</xsl:when>
					<xsl:otherwise>No</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='text-align: center; width: 45px;'>
			  <img src="/FW/image/icons/interbanking.ico" title="Estado en interbanking" width="16" height="16" onclick="window.parent.mostrar_rel_interbanking({@id_cuenta})" />
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>