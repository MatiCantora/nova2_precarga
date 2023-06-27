<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
              xmlns ="http://www.somedomainename.com"
              xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
              xmlns:ns2="http://a5.soap.ws.server.puc.sr/"
			       	xmlns:foo="http://www.broadbase.com/foo" exclude-result-prefixes="soap ns2"
              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
              xmlns:Extension="urn:Extension">
	
	<xsl:output method="text" />

  <msxsl:script implements-prefix="Extension" language="vb">
    <![CDATA[
    
      
    ]]>
  </msxsl:script>
    
  <xsl:template match="/">

      <HTML>
        <HEAD>
          <META http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
          <META http-equiv="Pragma" content="no-cache" />
          <META http-equiv="Expires" content="-1" />

          <META http-equiv="Cache-Control" content="no-cache" />
          <META http-equiv="Cache-Control" content="must-revalidate" />
          <META http-equiv="Cache-Control" content="proxy-revalidate" />

          <link REL="stylesheet" TYPE="text/css" HREF="/fw/servicios/afip/css/estilo.css" />
          <link REL="stylesheet" TYPE="text/css" HREF="/fw/servicios/afip/css/estilo_base.css" />
          <link REL="stylesheet" TYPE="text/css" HREF="/fw/servicios/afip/css/internet.css" />
          <link rel="stylesheet" type="text/css" href="/fw/servicios/afip/css/estilosGenericosParaConstancias.css" />

          <style type="text/css">
            .alert-danger {
            color: #d2322d;
            }
            .alert p, .alert {
            font-size: 18px !important;
            line-height: 20px;
            }
            .alert-danger {
            background: #ffebee;
            border-color: #c62828;
            }
            .alert-warning, .alert-success, .alert-info, .alert-danger {
            color: #444444;
            }
            .alert {
            font-weight: 300;
            }
            .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
            }
            .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
            }
            .alert-info {
            color: #214c62;
            }
            .alert-info {
            background: #EBF7FF;
            border-color: #0072bb;
            }
            .alert-info {
            color: #31708f;
            background-color: #d9edf7;
            border-color: #bce8f1;
            }
          </style>
        </HEAD>
        <BODY>
            <br/>
            <TABLE  width="100%" ALIGN="CENTER">
              <tr>
                <TD>&#160;</TD>
              </tr>
              <TR>
                <TD ALIGN="LEFT" STYLE="margin-left:100px">
                  <BR/>
                  <IMG src="/fw/servicios/afip/images/afipsolo.png"/>
                </TD>
              </TR>
              <TR>
                <TD ALIGN="CENTER">
                  <BR/>
                  <b>
                    <FONT face="Arial" SIZE="6">CONSTANCIA DE INCRIPCIÓN</FONT>
                  </b>
                  <BR/>
                </TD>
              </TR>
              <tr>
                <TD>&#160;</TD>
              </tr>
              <tr>
                <TD>&#160;</TD>
              </tr>
              <tr>
                <TD>&#160;</TD>
              </tr>
            </TABLE>
            <table width="80%" border="0" cellpadding="0" cellspacing="4" align="center">

              <TR>
                <TD align="center">

                  <BODY>

                    <TABLE>

                      <tr>
                        <td align="center" class="columna">
                          <div class="alert alert-danger" role="alert">
                            ATENCIÓN: Se ha producido un error
                          </div>
                        </td>
                      </tr>
                      <tr class="tableRow">
                        <td align="left" class="columna">
                          Ha ocurrido un error durante la ejecución de la registración. Por favor tenga en cuenta las siguientes consideraciones:
                        </td>
                      </tr>
                      <tr>
                        <td colspan="2">&#160;</td>
                      </tr>
                      <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/errorConstancia/error" mode="errorConstancia"/>
                      <tr class="tableRow">
                        <TD class="columna">
                          <div class="alert" role="alert">
                            Verifique que haya ingresado los datos correctamente. Si continúa recibiendo este mensaje de error a pesar de que los datos estén correctos, comuníquese telefénicamente al 0810-999-2347 o bien ingresando una consulta web en <a href="https://serviciosweb.afip.gob.ar/consultas/" style="color:blue; font-weight:bolder;" target="_blank" rel="noopener noreferrer">https://serviciosweb.afip.gob.ar/consultas/</a>.
                          </div>
                        </TD>
                      </tr>

                    </TABLE>

                  </BODY>

                </TD>
              </TR>

              <tr class="tableRow">
                <TD align="center" class="columna">
                  <div class="alert alert-danger" role="alert">
                    <b></b>
                  </div>
                </TD>
              </tr>

              </table>

            </BODY>
    </HTML>
</xsl:template>
  
<xsl:template match="ns2:getPersonaResponse/personaReturn/errorConstancia/error" mode="errorConstancia">
  <tr>
    <td class="columna">
      <div class="alert" role="alert">
        <img src="/fw/servicios/afip/images/select.gif"/>
        <xsl:value-of select="." />
      </div>
    </td>
  </tr>
</xsl:template>

</xsl:stylesheet>