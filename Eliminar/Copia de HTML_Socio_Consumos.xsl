<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[
        function bancoMutualStr(nro_comercio,banco,comercio,mutual,id_srv,srv_desc)
		{
		var cadena = ''
		if (nro_comercio == 0)
		    cadena = cadena+' '+banco
		if (nro_comercio > 0)
		    cadena = cadena+' '+comercio
		cadena = cadena+' - '+mutual
		if (id_srv > 0)	
		    cadena = cadena+' - '+srv_desc
		
		return cadena
	    }
		]]>
    </msxsl:script>
    <xsl:include href="..\..\..\meridiano\report\xsl_includes\js_formato.xsl"  />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

                <title>Créditos</title>
                <!--#include virtual="../scripts/pvAccesoPagina.asp"-->
                <!--#include virtual="../scripts/pvUtiles.asp"-->
                <link href="../css/base.css" type="text/css" rel="stylesheet"/>
                <link href="../css/btnSvr.css" type="text/css" rel="stylesheet" />
                <link href="../css/mnuSvr.css" type="text/css" rel="stylesheet" />
                <link href="../css/window_themes/default.css" rel="stylesheet" type="text/css" />
                <link href="../css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

                <script type="text/javascript" src="../script/prototype.js"></script>
                <script type="text/javascript" src="../script/window.js"></script>
                <script type="text/javascript" src="../script/effects.js"></script>

                <script type="text/javascript" src="../script/acciones.js"></script>
                <script type="text/javascript" src="../script/imagenes_icons.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/mnuSvr.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/DMOffLine.js"></script>
                <script type="text/javascript" src="../script/rsXML.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/tXML.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/nvFW.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/tCampo_head.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/tCampo_def.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/utiles.js" language="JavaScript"></script>
                <script type="text/javascript" src="../script/tSesion.js"></script>

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
                <script type="text/javascript"  language="javascript" >
                    <xsl:comment>
                        <xsl:if test="count(xml/rs:data/z:row) > 0" >
                            var nro_docu = <xsl:value-of select="xml/rs:data/z:row[position() = 1]/@nro_docu"/>
                            var sexo = '<xsl:value-of select="xml/rs:data/z:row[position() = 1]/@sexo"/>'
                            var tipo_docu = <xsl:value-of select="xml/rs:data/z:row[position() = 1]/@tipo_docu"/>
                        </xsl:if>

                        <![CDATA[
					    function  window_onload()
                          {
                            window_onresize()
                          }
                          
						function window_onresize()
					      {
					       try
					          {
            			      var dif = Prototype.Browser.IE ? 5 : 2
					          var body_height = $$('body')[0].getHeight()
					          var tbCabe_height = $('tbCabe').getHeight()
					          var div_pag_height = $('div_pag').getHeight()
                                     
					          $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})            					     
                              
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
                          
                          function seleccionar(indice)
					       {
					         $('tr_ver'+indice).addClassName('tr_cel')
					       }
                                 
					      function no_seleccionar(indice)
					       {
					         $('tr_ver'+indice).removeClassName('tr_cel')
					       }
					       
					      function mostrar_creditos(e,nro_credito,modal,id_win,link)
					      {
                            var path = "../../meridiano/credito_mostrar.asp?nro_credito=" + nro_credito
                            var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'
                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'
                            
                            if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                                $(link).href = path;
                            else if (e.altKey){ //con la tecla "Alt", abre una ventana emergente
                                window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)                                   
                            }else if (e.shiftKey){ //con la tecla "Shift", abre una nueva ventana _blank
                                $(link).target = '_blank'
                                $(link).href = path;                                 
                            }else{ 
                                parent.mostrar_creditos(nro_credito)
                                }                            
					      }
					     
					      function mostrar_comercios(e,nro_comercio,nro_mutual,nro_operatoria,nro_entidad,modal,id_win,link)
					      {
					        var path = "../../meridiano/comercio_mostrar.asp?nro_comercio=" + nro_comercio + "&nro_mutual=" + nro_mutual + "&nro_operatoria=" + nro_operatoria + "&nro_entidad=" + nro_entidad
                            var descripcion = '<b>Comercio Nº ' + nro_comercio + '</b>'
                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'
					        
					        if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                                $(link).href = path;
                            else if (e.altKey){ //con la tecla "Alt", abre una ventana emergente
                                window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)   
                            }else if (e.shiftKey){ //con la tecla "Shift", abre una nueva ventana _blank
                                $(link).target = '_blank'
                                $(link).href = path;                                     
                            }else{
					             parent.mostrar_comercios(nro_comercio,nro_mutual,nro_operatoria,nro_entidad)
                                }  
					      }
					     
					   ]]>
                    </xsl:comment>
                </script>
                <style type="text/css">
                    .tr_cel TD {
                    background-color: #F0FFFF !Important
                    }
                </style>
            </head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
                <table width="100%" class="tb1" id="tbCabe">
                    <tr class="tbLabel">
                        <td style='text-align: center; width: 6%'>
                            <script>campos_head.agregar('Nro', 'true', 'nro_credito')</script>
                        </td>
                        <td style='text-align: center; width: 26%'>
                            <script>campos_head.agregar('Banco', 'true', 'banco')</script> - <script>campos_head.agregar('Mutual', 'true', 'mutual')</script>
                        </td>
                        <td style='text-align: center; width: 18%'>
                            <script>campos_head.agregar('Banco Origen', 'true', 'banco_origen')</script>
                        </td>
                        <!--<td style='text-align: center; width: 6%'>
                            <script>campos_head.agregar('Op.', 'true', 'nro_operatoria')</script>
                        </td>-->
                        <td style='text-align: center; width: 7%'>
                            <script>campos_head.agregar('$ Neto', 'true', 'importe_neto')</script>
                        </td>
                        <td style='text-align: center; width: 6%'>
                            <script>campos_head.agregar('Ctas', 'true', 'cuotas')</script>
                        </td>
                        <td style='text-align: center; width: 7%'>
                            <script>campos_head.agregar('$ Cta', 'true', 'importe_cuota')</script>
                        </td>
                        <td style='text-align: center; width: 10%'>
                            <script>campos_head.agregar('Estado', 'true', 'descripcion')</script>
                        </td>
                        <td style='text-align: center; width: 7%' >
                            <script>campos_head.agregar('Fecha', 'true', 'fe_estado')</script>
                        </td>
                        <td style='text-align: center; width: 6%'>$ Debe</td>
                        <td style='text-align: center; width: 6%'>$ a Cobrar</td>
                        <td style="width:1%">&#160;</td>
                    </tr>
                </table>
                <div id="div_lst_creditos" style="width:100%;overflow:auto">
                    <table class="tb1" id="tbDetalle">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table>
                </div>
                <div id="div_pag" class="divPages">
                    <script type="text/javascript">
                        document.write(campos_head.paginas_getHTML())
                    </script>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <tr>
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
            <xsl:attribute name="onmousemove">seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <xsl:attribute name="onmouseout">no_seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <xsl:variable name="banco_mutual_str" select="foo:bancoMutualStr(count(@nro_comercio),string(@banco),string(@comercio),string(@mutual),count(@id_srv),string(@srv_desc))"/>

            <xsl:if test="count(@nro_comercio) != 0">
                <xsl:attribute name='style'>color: #7347CD !important</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test='count(@nro_comerio) = 0 and @estado = "F" or @estado = "I" or @estado = "W" or @estado = "K" or @estado = "J"'>
                    <xsl:attribute name='style'>color: red !important</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <td style="text-align: center; width: 6%">
                <xsl:choose>
                    <xsl:when test="count(@nro_comercio) = 0">
                        <a>
                            <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;font-weight:bold;color: #000000 !important</xsl:attribute>
                            <xsl:attribute name="id">link_mostrar_credito_<xsl:value-of  select="@nro_credito" />_<xsl:value-of select="$pos"/></xsl:attribute>
                            <xsl:attribute name='onclick'>
                                javascript:mostrar_creditos(event,'<xsl:value-of select="@nro_credito"/>','<xsl:value-of select="@modal"/>','<xsl:value-of select="@id_win"/>','link_mostrar_credito_<xsl:value-of  select="@nro_credito" />_<xsl:value-of select="$pos"/>')
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test='@estado = "F" or @estado = "I" or @estado = "W" or @estado = "K" or @estado = "J"'>
                                    <xsl:attribute name='style'>
                                        text-decoration:underline;cursor:pointer;font-weight:bold;color: red !important
                                    </xsl:attribute>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
                        </a>
                    </xsl:when>
                    <xsl:when test="count(@nro_comercio) != 0">
                        <a>
                            <xsl:attribute name='style'>text-decoration:underline;cursor:pointer;font-weight:bold;color: #7347CD !important</xsl:attribute>
                            <xsl:attribute name="id">link_mostrar_comercio_<xsl:value-of  select="@nro_comercio"/>_<xsl:value-of select="$pos"/></xsl:attribute>
                            <xsl:attribute name='onclick'>
                                javascript:mostrar_comercios(event,'<xsl:value-of select="@nro_comercio"/>','<xsl:value-of select="@nro_mutual"/>','<xsl:value-of select="@nro_operatoria"/>','<xsl:value-of select="@nro_entidad"/>','<xsl:value-of select="@modal"/>','<xsl:value-of select="@id_win"/>','link_mostrar_comercio_<xsl:value-of  select="@nro_comercio"/>_<xsl:value-of select="$pos"/>')
                            </xsl:attribute>
                            <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
                        </a>
                    </xsl:when>
                </xsl:choose>
            </td>
            <td style='text-align: left; width: 26%'>
                <xsl:attribute name='title'><xsl:value-of select="$banco_mutual_str" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length($banco_mutual_str) &#62; 40">
                        <xsl:value-of select="substring($banco_mutual_str,1,40)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$banco_mutual_str"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
           <td style='text-align: left; width: 18%'>
            <xsl:attribute name='title'>
              <xsl:value-of select="@banco_origen" />
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="string-length(@banco_origen) &#62; 25">
                <xsl:value-of select="substring(@banco_origen,1,25)"/>...
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@banco_origen"/>
              </xsl:otherwise>
            </xsl:choose>
          </td>
            <!--<td style='text-align: center; width: 6%'>
                <xsl:attribute name='style'>text-align: right;<xsl:if test='@nro_operatoria = 161'>!Important;FONT-WEIGHT: bolder</xsl:if></xsl:attribute>
                <xsl:value-of  select="@nro_operatoria" />
            </td>-->
            <td style='text-align: right; width: 7%'>
                <xsl:value-of  select="format-number(@importe_neto, '#0.00')" />
            </td>
            <td style='text-align: right; width: 6%'>
                <xsl:value-of  select="@cuotas" />
            </td>
            <td style='text-align: right; width: 7%'>
                <xsl:value-of  select="format-number(@importe_cuota, '#0.00')" />
            </td>
            <td style='text-align: left; width: 10%'>
                <xsl:choose>
                    <xsl:when test='@estado = "F" or @estado = "I" or @estado = "W" or @estado = "K" or @estado = "J"'>
                        <xsl:attribute name='style'>
                            text-align: left; color: red
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of  select="@descripcion"  />
            </td>
            <td style='text-align: right; width: 7%' >
                <xsl:value-of select="foo:FechaToSTR(string(@fe_estado))" />
            </td>
            <xsl:variable name="estado" select="@estado"/>
            <xsl:variable name="debe" select="@saldo_vencido - @saldo_pagado"/>
            
            <td style='text-align: right; width: 6%'>
                <xsl:choose>
                    <xsl:when test='$estado = "T" or $estado = "t"'>
                        <xsl:if test='format-number($debe, "#0.00") > 0'>
                            <xsl:attribute name='style'>
                                color: red ;text-align: right; font: bolder !important
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of  select="format-number($debe, '#0.00')" />
                    </xsl:when>
                    <xsl:when test='$estado = "A"'>
                        <xsl:value-of  select="format-number(0, '#0.00') " />
                    </xsl:when>
                    <xsl:otherwise>-</xsl:otherwise>
                </xsl:choose>
            </td>
            <td style='text-align: right; width: 6%' >
                <xsl:variable name="a_vencer" select="@saldo_total - @saldo_pagado"/>
                <xsl:choose>
                    <xsl:when test='$estado = "T" or $estado = "t"'>
                        <xsl:value-of  select="format-number($a_vencer, '#0.00') " />
                    </xsl:when>
                    <xsl:when test='$estado = "A"'>
                        <xsl:value-of  select="format-number(@importe_documentado, '#0.00') " />
                    </xsl:when>
                    <xsl:otherwise>-</xsl:otherwise>
                </xsl:choose>
            </td>
            <td style='width:1% !Important'>
                <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;&#160;
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>