<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:fn="http://www.w3.org/2005/xpath-functions"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">

    <xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"  />
    
    <msxsl:script language="vb" implements-prefix="user">
		<msxsl:assembly name="System.Web"/>
		<msxsl:using namespace="System.Web"/>
		<![CDATA[
		
		Public function getfiltrosXML() as String 
          
            Page.contents("filtroupdateRefOp") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText = 'dbo.rm_ref_op_suscripcion' CommantTimeOut = '1500'><parametros><nro_ref DataType = 'int'>%nro_ref%</nro_ref></parametros></procedure></criterio>")
		
		End Function
        
        Dim a as String = getfiltrosXML()
		]]>
	</msxsl:script>
    
    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[

		]]>
    </msxsl:script>
    
    <xsl:template match="/">
        <html>
            <head>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
                <script type="text/javascript" src="/FW/script/nvFW.js"></script>
                <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
                <script type="text/javascript">
                    <![CDATA[
                    var t_layout;
                    var inicio_referencias;
                        
                    function suscripcion_referencia(nro_ref)
                    {
                        var dejar_de = "";
                        
                        if (nro_ref < 0)
                        {
                            dejar_de = 'dejar de ';
                        }
                        
                        window.top.nvFW.confirm('¿Desea ' + dejar_de + 'recibir las actualizaciones de la referencia?', {
                            width: 300,
                            onOk: function(win) {
                                updateRefOp(nro_ref);
                                win.close();
                                t_layout.refresh(inicio_referencias);
                            },
                            onCancel: function(win) {
                                win.close();
                            }
                        });
                    }

                    function updateRefOp(nro_ref)
                    {
                        var alert_1 = 'Se subscribió a la referencia';
                        var alert_2 = 'No se puedo realizar la operación';
                        
                        if (nro_ref < 0)
                        {
                            alert_1 = alert_2;
                            alert_2 = 'Se elimino subscripción a la referencia';
                        }
                        
                        var rs = new tRS();
                        
                        rs.open({
                            filtroXML: nvFW.pageContents.filtroupdateRefOp,
                            params: "<criterio><params nro_ref='" + nro_ref + "'></params></criterio>"
                        });
                        
                        if (!rs.eof())
                        {
                            alert(alert_1);
                            close();
                        }
                        else
                        {
                            alert(alert_2);
                            close();
                        }
                    }

                    function verRef(nro_ref, event)
                    { 
                        window.top.showRef = nro_ref;
                        window.top.event = event;
                        window.top.$$('iframe[name="menu_left"]')[0].contentWindow.referencia();
                    }
                    
                    function close()
                    {
                        if (parent.winSusc)
                        {
                            //parent.document.getElementById('suscripciones_sub_window').remove();
                            parent.winSusc.close();
                        }
                    }
                    ]]>
                </script>
            </head>
            <body style="background-color: #FFFFFF; width:100%;height:100%;overflow: hidden">
                <table class="tb1 highlightTROver">
                    <xsl:apply-templates select="xml/rs:data/z:row" mode="tipo" />
                </table>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="z:row" mode="tipo">
        <tr style="cursor: pointer;">
        <xsl:attribute name="onclick">javascript:verRef('<xsl:value-of select="@nro_ref"/>',event)</xsl:attribute>
            <td>
                <xsl:value-of select="@nro_ref"/>
            </td>
            <td style="width: 80%;color: blue;">
                &#160;<xsl:value-of select="@referencia"/>
            </td>
            <td>
                <xsl:value-of select="@fecha"/>
            </td>
            <td>
                <xsl:value-of select="@hora"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>