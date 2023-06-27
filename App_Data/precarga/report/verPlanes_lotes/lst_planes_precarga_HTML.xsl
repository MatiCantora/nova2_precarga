<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>
  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl" />
  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_campo_def.xsl" />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title></title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
        <script type="text/javascript" src="/precarga/script/tCampo_head.js" language="JavaScript"></script>

        <script type="text/javascript" language="javascript">
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
        </script>
                
			</head>
            <script type="text/javascript"  language="javascript">
                <xsl:comment>
					var ultimo_nro_plan = '<xsl:value-of select="xml/rs:data/z:row[count(/xml/rs:data/z:row)]/@nro_plan"/>'
					<![CDATA[						
					function btnSelPlan_onclick(nro_plan, importe_neto, importe_bruto, cuotas, importe_cuota, plan_banco, nro_tipo_cobro, gastoscomerc)
						{
            var filas = $('tbDetalle').rows.length
            for (var i = 0; i < filas; i++)
            { 
            if ($('tbDetalle').rows[i].className == 'tr_cel2')
              $('tbDetalle').rows[i].removeClassName('tr_cel2')
            }
            var radioGrp = document['forms']['frmplanes']['rdplan'];
            if (radioGrp.length == undefined)
              $('rdplan').checked = true
            else
            {
              for(i=0; i < radioGrp.length; i++){
              if (radioGrp[i].value == nro_plan) 
                radioGrp[i].checked = true
              else
                radioGrp[i].checked = false
              }
            }            
            
            var tr = $('tr_ver' + nro_plan)
            if (tr.className == 'tr_cel2')
              tr.removeClassName('tr_cel2')
            else
              tr.addClassName('tr_cel2')
              
            parent.btnSelPlan_onclick(nro_plan, importe_neto, importe_bruto, cuotas, importe_cuota, plan_banco, nro_tipo_cobro,gastoscomerc)
						}
						
						function window_onresize()
			            {
			                try
			                {
    					    
			                 var dif = Prototype.Browser.IE ? 5 : 15
			                 var body_height = $$('body')[0].getHeight()
                       var tbCabe_height = $('tbCabe').getHeight() 
			                 var div_pag_height = $('div_pag').getHeight()
			                 
                       $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - div_pag_height - dif - 15 + 'px'})
    					     
                       $('tbDetalle').getHeight() - $('div_lst_creditos').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
                                              
			                }
			                 catch(e){}
			            }         
        					    
			            function tdScroll_hide_show(show)
                        {
                          var i = 1
                          while(i <=  campos_head.recordcount)
                            {
                              if(show &&  $('tdScroll'+ i) != undefined)
                               $('tdScroll'+ i).show() 
                              
                              if(!show &&  $('tdScroll'+ i) != undefined)
                               $('tdScroll'+ i).hide() 
                              
                              i++
                            }
                        }
						
						function  window_onload()
                        {
                            window_onresize()
                        }
                        
                        function seleccionar(indice)
                        {
                            $('tr_ver'+indice).addClassName('tr_cel')
                        }
                                 
                        function no_seleccionar(indice)
                        {
                            $('tr_ver'+indice).removeClassName('tr_cel')
                        }
                        
                function pag_seleccionar(id)
					       {
					         $(id).addClassName('tr_cel')
					       }
                 
                 function pag_no_seleccionar(id)
                 {
                   $(id).removeClassName('tr_cel')
                 }
	
					]]>
			</xsl:comment>
			</script>
      <style type="text/css">
      @media screen and (max-width: 1023px)
        {  
        #tbCabe{
        font-size: 0.9em !important
        }
        #tbDetalle{
        font-size: 0.9em !important
        }
        }
        
        input[type=number]::-webkit-inner-spin-button, 
        input[type=number]::-webkit-outer-spin-button { 
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            margin: 0; 
        }

        input[type=number] {
        -moz-appearance: textfield;
        }
      </style>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto" tabindex="-1">
              <form id="frmplanes" style="clear: none; float: none; border-style: none; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px">
              <div id="contenedor" style="height:100%">
                    <table class="tb1" id="tbCabe">
                      <tr class="tbLabel">
                        <td style="width: 10%">
                                  -
                        </td>
                        <td  style="width: 20%">
                          <script>campos_head.agregar('Ret.', true, 'importe_neto')</script>
                        </td>
                        <td  style="width: 20%">
                          <script>campos_head.agregar('Sol.', true, 'importe_bruto')</script>
                        </td>
                        <td  style="width: 15%">Ctas
                        </td>
                        <td nowrap="true">
                          <script>campos_head.agregar('Cuota', true, 'importe_cuota')</script>
                        </td>
                      <td style="width: 15%">
                          <script>campos_head.agregar('Seg.', true, 'monto_seguro')</script>
                        </td>
                      </tr>
                    </table>
                    <div id="div_lst_creditos" style="width:100%;overflow:auto">
                      <table class="tb1 highlightEven highlightTROver" id="tbDetalle">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                      </table>
                    </div>
                    <div id="div_pag" class="divPages">
                      <script type="text/javascript">
                        document.write(campos_head.paginas_precarga_getHTML())
                      </script>
                    </div>
              </div>                  
                </form>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="WinTipo" select="@WinTipo"/>
		  <tr style='cursor:pointer;text-align:center' >
              <xsl:attribute name="id">tr_ver<xsl:value-of select="@nro_plan"/></xsl:attribute>
              <xsl:attribute name="onclick">btnSelPlan_onclick(<xsl:value-of  select="@nro_plan" />,<xsl:value-of  select="format-number(@importe_neto,'#0.00')" />,<xsl:value-of  select="format-number(@importe_bruto,'#0.00')" />,<xsl:value-of  select="@cuotas" />,<xsl:value-of  select="format-number(@importe_cuota,'#0.00')" />,'<xsl:value-of  select="@plan_banco" />',<xsl:value-of  select="@nro_tipo_cobro" />,<xsl:value-of select ="@gastoscomerc"/>)</xsl:attribute>
              <xsl:variable name="tabindex_str" select="17"/>
       
                <td style="text-align: left; width: 10%">
                  <xsl:attribute name="id">tdrdplan<xsl:value-of select="$pos"/></xsl:attribute>
                  <input type="radio" name="rdplan">
                    <xsl:attribute name="id">rdplan<xsl:value-of select="$pos"/></xsl:attribute>
                    <xsl:attribute name="value"><xsl:value-of  select="@nro_plan" /></xsl:attribute>
                  </input>
			          </td>
			          <td style="text-align: right; width: 20%" nowrap="true">
				          $ <xsl:value-of  select="format-number(@importe_neto,'#0.00')" />
			          </td>
			          <td style="text-align: right;  width: 20%" nowrap="true">
				          $ <xsl:value-of  select="format-number(@importe_bruto,'#0.00')" />
			          </td>
			          <td style="text-align: right;  width: 15%" nowrap="true">
				          <xsl:value-of  select="@cuotas" />
			          </td>
			          <td style="text-align: right" nowrap="true">
				          $ <xsl:value-of  select="format-number(@importe_cuota,'#0.00')" />
			          </td>
                <td style="text-align: right; width: 15%" nowrap="true">
				          $ <xsl:value-of  select="format-number(@monto_seguro,'#0.00')" />
			          </td>
          </tr>	  
	</xsl:template>
</xsl:stylesheet>