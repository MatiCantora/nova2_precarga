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
      function formatFecha(fechaHora as string, format as string) as string
      
         Dim cultureinfo As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("en-US")
         Dim fechaHoraDate As DateTime = DateTime.Parse(fechaHora, cultureinfo)
        
        return fechaHoraDate.ToString(format)
      
      end function
      
      function fechaHasta(fechaHora as string) as string
      
         Dim cultureinfo As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("en-US")
         Dim fechaHoraDate As DateTime = DateTime.Parse(fechaHora, cultureinfo)
        
        return fechaHoraDate.AddMonths(1).AddDays(-1).ToString("yyyy/MM/ddTHH:mm:ss")
      
      end function
      
    ]]>
  </msxsl:script>
    
  <xsl:template match="/">
    
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<META http-equiv="Pragma" content="no-cache" />
<META http-equiv="Expires" content="-1" />
<META http-equiv="Cache-Control" content="no-cache" />
<META http-equiv="Cache-Control" content="must-revalidate" />
<META http-equiv="Cache-Control" content="proxy-revalidate" />

  <link REL="stylesheet" TYPE="text/css" HREF="/fw/servicios/afip/css/estilo.css" />
<link REL="stylesheet" TYPE="text/css" HREF="/fw/servicios/afip/css/estilo_base.css" />
<link REL="stylesheet" TYPE="text/css" HREF="/fw/servicios/afip/css/internet.css" />
<link rel="stylesheet" type="text/css" href="/fw/servicios/afip/css/estilosGenericosParaConstancias.css"/>

  <style type="text/css">
td {
	border-width: 0px;
}


</style>
<TITLE>Formulario de Impresi&#243;n de Constancia de
	Inscripción</TITLE>
</HEAD>

<BODY>
	<FORM>
		<INPUT type="hidden" name="response" value="constancia-sin-error" />
	</FORM>
	
	<style type="text/css">
@media print {
    #printpagetoolbar {
        display :  none;
    }
}
</style>

	

	<TABLE border="0" cellPadding="0" cellSpacing="0" rules="groups" width="100%">

		<TR>
			<TD width="40px" rowspan="8" ALIGN="CENTER" valign="middle">

				<table>
					<tr>
						<td valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/l_afip.png"
							style="margin-left: 1px; margin-right: 5px;" /></td>
					</tr>
					<tr>
						<td valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/l_afip.png"
							style="margin-left: 1px; margin-right: 5px;" /></td>
					</tr>
					<tr>
						<td valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/l_afip.png"
							style="margin-left: 1px; margin-right: 5px;" /></td>
					</tr>
					<tr>
						<td valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/l_afip.png"
							style="margin-left: 1px; margin-right: 5px;" /></td>
					</tr>
					<tr>
						<td valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/l_afip.png"
							style="margin-left: 1px; margin-right: 5px;" /></td>
					</tr>
					<tr>
						<td valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/l_afip.png"
							style="margin-left: 1px; margin-right: 5px;" /></td>
					</tr>
				</table>
			</TD>

            <TD width="100%">
				<TABLE width="85%" ALIGN="LEFT">
					<TR>
						<TD><BR /> <IMG src="/fw/servicios/afip/images/afipsolo.png" />
						</TD>
						<TD ALIGN="CENTER"><BR /> <FONT face="Arial" SIZE="1">ADMINISTRACION
								FEDERAL DE INGRESOS PUBLICOS</FONT> <BR /> <FONT face="Arial Black"
							size="4"><B>CONSTANCIA DE INSCRIPCION</B></FONT></TD>
					</TR>
				</TABLE>
			</TD>
			
			<TD width="40px" rowspan="8" ALIGN="CENTER" valign="middle">
				<table>
					<tr>
						<td align="right" valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/r_afip.png"
							style="margin-left: 5px; margin-right: 1px;" /></td>
					</tr>
					<tr>
						<td align="right" valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/r_afip.png"
							style="margin-left: 5px; margin-right: 1px;" /></td>
					</tr>
					<tr>
						<td align="right" valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/r_afip.png"
							style="margin-left: 5px; margin-right: 1px;" /></td>
					</tr>
					<tr>
						<td align="right" valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/r_afip.png"
							style="margin-left: 5px; margin-right: 1px;" /></td>
					</tr>
					<tr>
						<td align="right" valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/r_afip.png"
							style="margin-left: 5px; margin-right: 1px;" /></td>
					</tr>
					<tr>
						<td align="right" valign="middle" height="116px"><IMG
							src="/fw/servicios/afip/images/r_afip.png"
							style="margin-left: 5px; margin-right: 1px;" /></td>
					</tr>
				</table>
			</TD>
		</TR>

		<TR>
			<TD><BR />
        <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosGenerales" mode="datosGenerales"/>
		   </TD>
		</TR>
		<TR >
        			<TD ALIGN="CENTER"><BR /> <B> <FONT face="Arial" SIZE="2">IMPUESTOS/REGIMENES NACIONALES REGISTRADOS Y FECHA DE ALTA</FONT>
        			</B>
        				<TABLE border="1" cellPadding="0" cellSpacing="0" rules="groups"
        					width="100%" ALIGN="CENTER">
        					<TR VALIGN="TOP">
        						<TD HEIGHT="400">
        							<TABLE ALIGN="CENTER" width="100%">
                        
                        <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/regimen" mode="regimen"/>
                        <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/impuesto" mode="impuesto"/>

                        <xsl:variable name ="tieneRI" select ="count(soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/impuesto)" />        							
        							  <xsl:if test="$tieneRI = 0">
                          <TR>
        									  <TD><FONT face="Arial" SIZE="1">No registra impuestos activos</FONT></TD>
        									  <TD ALIGN="RIGHT"><FONT face="Arial" SIZE="1">&#160;</FONT></TD>
        								  </TR>
                        </xsl:if>
                          
                          <TR>
        									<TD><FONT face="Arial" SIZE="1">****************************************************</FONT></TD>
        									<TD ALIGN="RIGHT"><FONT face="Arial" SIZE="1"></FONT></TD>
        								</TR>

        								
        								<TR>
        									<TD colspan="2"><FONT face="Arial" SIZE="1">Contribuyente no amparado en los beneficios promocionales INDUSTRIALES establecidos por Ley 22021 y sus modificatorias 22702 y 22973, a la fecha de emision de la presente constancia.</FONT></TD>
        								</TR>
        								
        								<TR>
        									<TD colspan="2"><FONT face="Arial" SIZE="1"> </FONT></TD>
        								</TR>
        								

        							</TABLE>
        						</TD>
        					</TR>
        				</TABLE></TD>
        		</TR>
		<TR >
			<TD>
				<TABLE ALIGN="CENTER" width="100%">
					<TR>
						<TD>
							 
							<B style="font-size: 10;">
							 Esta constancia no da cuenta de la inscripci&#243;n en:
							<BR/> 
							- Impuesto Bienes Personales y Exteriorizaci&#243;n - Ley 26476: de corresponder,
							deber&#243;n solicitarse en la dependencia donde se encuentra inscripto.
							<BR/>
							- Impuesto a las Ganancias: la condici&#243;n de exenta, para las entidades enunciadas
							en los incisos b), d), e), f), g), m) y r) del Art. 20 de la ley, se acredita mediante 
							el "Certificado de exenci&#243;n en el Impuesto a las Ganancias" - Resoluci&#243;n 
							General 2681.
							 </B>

						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>

    <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/actividad" mode="actividad">
       <xsl:sort select="orden" />
    </xsl:apply-templates>
		
    <TR>
			<TD ALIGN="CENTER"><BR /> <B> <FONT face="Arial" SIZE="1">DOMICILIO FISCAL - AFIP</FONT>
			</B>
        <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosGenerales/domicilioFiscal" mode="domicilioFiscal"/>
			</TD>			
		</TR>

    <xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/datosGenerales/dependencia" mode="dependencia"/>
    
		<xsl:apply-templates select="soap:Envelope/soap:Body/ns2:getPersonaResponse/personaReturn/metadata" mode="metadata"/>
    
		<TR>
			<TD colspan="3" ALIGN="CENTER"><BR />

				<table width="100%">
					<tr>
						<td>&#160;</td>
						<td width="592px">
							<table width="100%">
								<tr>
									<td width="20%" align="center"><IMG
										src="/fw/servicios/afip/images/h_afip.png" /></td>
									<td width="20%" align="center"><IMG
										src="/fw/servicios/afip/images/h_afip.png" /></td>
									<td width="20%" align="center"><IMG
										src="/fw/servicios/afip/images/h_afip.png" /></td>
									<td width="20%" align="center"><IMG
										src="/fw/servicios/afip/images/h_afip.png" /></td>
									<td width="20%" align="center"><IMG
										src="/fw/servicios/afip/images/h_afip.png" /></td>
								</tr>
							</table>
						</td>
						<td>&#160;</td>
					</tr>
				</table></TD>
		</TR>
	</TABLE>
  <br/>
	<TABLE width="100%">
		<TR>
			<TD><FONT face="Arial" SIZE="1">Los datos contenidos en la presente constancia deberán ser validados por el receptor de la misma en la página institucional de AFIP 
        <a href="http://www.afip.gob.ar" target="_blank" rel="noopener noreferrer"><u>http://www.afip.gob.ar</u></a>.
			</FONT></TD>
		</TR>
	</TABLE>
</BODY>
</HTML>
</xsl:template>
  
<xsl:template match="ns2:getPersonaResponse/personaReturn/datosGenerales" mode="datosGenerales">
  
    <TABLE border="1" cellPadding="0" cellSpacing="0" rules="groups"
					ALIGN="LEFT" width="100%">
					<TR>
						<TD>
						    <xsl:if test="string(razonSocial) = ''">  
                <B><i><FONT face="Arial" SIZE="1">&#160;<xsl:value-of select="apellido" />&#160;<xsl:value-of select="nombre" /></FONT></i></B>
                </xsl:if>
                <xsl:if test="string(razonSocial) != ''">  
                <B><i><FONT face="Arial" SIZE="1">&#160;<xsl:value-of select="razonSocial" /></FONT></i></B>
                </xsl:if>
						    <FONT face="Arial" SIZE="1">&#160;<xsl:value-of select="tipoClave" />:&#160;</FONT><B> <i><FONT face="Arial" SIZE="1"><xsl:value-of select="idPersona" /></FONT></i> </B>
						</TD>
					</TR>
					<TR>
						<TD><FONT face="Arial" SIZE="1">&#160;Persona:&#160;</FONT> <B> <i><FONT face="Arial" SIZE="1"><xsl:value-of select="tipoPersona" /></FONT></i></B></TD>
					</TR>
          <xsl:if test="string(fechaContratoSocial) != ''">
           <TR>
						 <TD><FONT face="Arial" SIZE="1">&#160;Fecha ContratoSocial:&#160;</FONT> <B> <i><FONT face="Arial" SIZE="1"><xsl:value-of select="fechaContratoSocial" /></FONT></i></B></TD>
					 </TR>
          </xsl:if>
				</TABLE>

</xsl:template>

<xsl:template match="ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/regimen" mode="regimen">
         <TR>
             <TD><FONT face="Arial" SIZE="1"><xsl:value-of select="descripcionRegimen" /> - <xsl:value-of select="idRegimen" /></FONT></TD>
        		 <TD ALIGN="RIGHT"><FONT face="Arial" SIZE="1"><xsl:value-of select="periodo" /></FONT></TD>
        </TR>
</xsl:template>

<xsl:template match="ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/impuesto" mode="impuesto">
        <TR>
         <TD><FONT face="Arial" SIZE="1"><xsl:value-of select="descripcionImpuesto" />&#160;-&#160;<xsl:value-of select="idImpuesto" /></FONT></TD>
         <TD ALIGN="RIGHT"><FONT face="Arial" SIZE="1"><xsl:value-of select="periodo" /></FONT></TD>
        </TR>
</xsl:template>

<xsl:template match="ns2:getPersonaResponse/personaReturn/datosRegimenGeneral/actividad" mode="actividad">
      <TR>
			<TD ALIGN="CENTER"><BR /><B><FONT face="Arial" SIZE="2">ACTIVIDADES NACIONALES REGISTRADAS Y FECHA DE ALTA</FONT></B>
				<TABLE border="1" cellPadding="0" cellSpacing="0" rules="groups"
					ALIGN="CENTER" width="100%">
          <xsl:if test="orden = 1">
            <TR>
						  <TD valign="top" nowrap="nowrap" width="1%" class="tact"><FONT face="Arial" SIZE="1">Actividad principal:&#160;</FONT></TD>
						  <TD valign="top" nowrap="nowrap" width="1%" align="right" class="cact"><i><FONT face="Arial" SIZE="1"> <xsl:value-of select="idActividad" /> (F-<xsl:value-of select="nomenclador" />)&#160;</FONT> </i></TD>
						  <TD valign="top" width="97%"><i> <FONT face="Arial" SIZE="1"> <xsl:value-of select="descripcionActividad" /> </FONT></i></TD>
						  <TD ALIGN="RIGHT" valign="top" nowrap="nowrap" width="1%" class="pact"><FONT face="Arial" SIZE="1">Mes de	inicio: <i><xsl:value-of select="periodo" /> </i></FONT></TD>
					 </TR>
          </xsl:if>
          <xsl:if test="orden != 1">
            <TR>
						 <TD valign="TOP" nowrap="nowrap"><FONT face="Arial" SIZE="1">Secundaria(s):</FONT></TD>
						 <TD valign="top" nowrap="nowrap" align="right"><i><FONT face="Arial" SIZE="1"> <xsl:value-of select="idActividad" /> (F-<xsl:value-of select="nomenclador" />)</FONT> </i></TD>
             <TD valign="top" width="97%"><i> <FONT face="Arial" SIZE="1"> <xsl:value-of select="descripcionActividad" /> </FONT></i></TD>
						 <TD valign="top"> <FONT face="Arial" SIZE="1">Mes de	inicio: <i><xsl:value-of select="periodo" /></i></FONT></TD>
					 </TR>
          </xsl:if>

          <TR>
						<TD colspan="4"><FONT face="Arial" SIZE="1">Mes de	cierre ejercicio comercial:&#243;</FONT> <B> <i><FONT
									face="Arial" SIZE="1"><xsl:value-of select="//mesCierre" /></FONT></i>
						</B> <BR /></TD>
					</TR>
				</TABLE>
     </TD>
		</TR>
</xsl:template>


<xsl:template match="ns2:getPersonaResponse/personaReturn/datosGenerales/domicilioFiscal" mode="domicilioFiscal">
   <TABLE border="1" cellPadding="0" cellSpacing="0" rules="groups" ALIGN="LEFT" width="100%">
		 <TR>
			 <TD><FONT face="Arial" SIZE="1"><xsl:value-of select="direccion" /></FONT></TD>
    </TR>
		<TR>
		   <TD><FONT face="Arial" SIZE="1"> <xsl:value-of select="localidad" /></FONT></TD>
		</TR>
    <TR>
		   <TD><FONT face="Arial" SIZE="1"><xsl:value-of select="codPostal" />&#160;-&#160;<xsl:value-of select="descripcionProvincia" /></FONT></TD>
		</TR>
	</TABLE>
</xsl:template>
  
<xsl:template match="ns2:getPersonaResponse/personaReturn/datosGenerales/dependencia" mode="dependencia">
    <TR>
			<TD ALIGN="CENTER"><BR/> <B> <FONT face="Arial" SIZE="1">DEPENDENCIA DONDE SE ENCUENTRA INSCRIPTO</FONT>
			</B>
       <TABLE border="1" cellPadding="0" cellSpacing="0" rules="groups" ALIGN="LEFT" width="100%">
          <TR>
						 <TD><FONT face="Arial" SIZE="1"><xsl:value-of select="descripcionDependencia" /></FONT></TD>
          </TR>
		      <TR>
			     <TD><FONT face="Arial" SIZE="1"><xsl:value-of select="direccion" /></FONT></TD>
         </TR>
		     <TR>
		       <TD><FONT face="Arial" SIZE="1"> <xsl:value-of select="Localidad" /> <xsl:value-of select="descripcionProvincia" /> (<xsl:value-of select="codPostal" />)</FONT></TD>
		    </TR>
	    </TABLE>
			</TD>
		</TR>
</xsl:template>
  
<xsl:template match="ns2:getPersonaResponse/personaReturn/metadata" mode="metadata">
     <xsl:variable name="fecha_hasta" select="Extension:fechaHasta(fechaHora)" />
    	<TR>
			<TD>
				<table width="100%">
					<tr>
						<td><BR /> <FONT face="Arial" SIZE="1">Vigencia de la presente constancia:&#160;</FONT> <B> <i>
            <FONT face="Arial" SIZE="1"><xsl:value-of select="Extension:formatFecha(fechaHora,'dd-MM-yyyy')" /></FONT></i>
						</B><FONT face="Arial" SIZE="1">&#160;a&#160;<xsl:value-of select="Extension:formatFecha($fecha_hasta,'dd-MM-yyyy')"/></FONT> <B> <i><FONT
									face="Arial" SIZE="1"></FONT></i>
						</B></td>
						<td align="right"><BR /> <FONT face="Arial" SIZE="1">Hora&#160;</FONT>
							<B> <FONT face="Arial" SIZE="1"> <xsl:value-of select="Extension:formatFecha(fechaHora,'HH:mm:ss')" />
							</FONT>
						</B>
						<BR/></td>
					</tr>
				</table>
			</TD>
		</TR>
</xsl:template>

</xsl:stylesheet>