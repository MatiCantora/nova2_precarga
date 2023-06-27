<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				xmlns:user="urn:vb-scripts">

	<msxsl:script language="vb" implements-prefix="user">
		<msxsl:assembly name="System.Web"/>
		<msxsl:using namespace="System.Web"/>
		<![CDATA[
		
		Public Class nvCampo_def
			Public Shared Function get_html_input(ByVal campo_def As String, Optional ByVal filtroXML As String = "" _
																		  , Optional ByVal filtroWhere As String = "" _
																		  , Optional ByVal vistaGuardada As String = "" _
																		  , Optional ByVal depende_de As String = "" _
																		  , Optional ByVal depende_de_campo As String = "" _
																		  , Optional ByVal nro_campo_tipo As integer = 1 _
																		  , Optional ByVal permite_codigo As Boolean = False _
																		  , Optional ByVal json As Boolean = True _
																		  , Optional ByVal cacheControl As String = "" _
																		  , Optional ByVal enDB As Boolean = True _
																		  , Optional ByRef parametros As Generic.Dictionary(Of String, Object) = Nothing) As String
                
				Dim nvFW_interOp as Object = HttpContext.current.application.contents("_nvFW_interOp")
                Return nvFW_interOp.nvCampo_def.get_html_input(campo_def, filtroXML, filtroWhere, vistaGuardada, depende_de, depende_de_campo, nro_campo_tipo, permite_codigo, json, cacheControl, enDB, parametros)
            End Function
		End Class
		
		
		Public Function get_html_input(ByVal campo_def As String) As String
                Return nvCampo_def.get_html_input(campo_def)
        End Function
		
		Public Function get_html_input(ByVal campo_def As String, ByVal filtroXML As String _
                                                                      , Optional ByVal filtroWhere As String = "" _
                                                                      , Optional ByVal vistaGuardada As String = "" _
                                                                      , Optional ByVal depende_de As String = "" _
                                                                      , Optional ByVal depende_de_campo As String = "" _
                                                                      , Optional ByVal nro_campo_tipo As Integer = 1 _
                                                                      , Optional ByVal permite_codigo As Boolean = False _
                                                                      , Optional ByVal json As Boolean = True _
                                                                      , Optional ByVal cacheControl As String = "" _
                                                                      , Optional ByVal enDB As Boolean = True _
                                                                      , Optional ByRef parametros As Generic.Dictionary(Of String, Object) = Nothing) As String
            Return nvCampo_def.get_html_input(campo_def, filtroXML, filtroWhere, vistaGuardada, depende_de, depende_de_campo, nro_campo_tipo, permite_codigo, json, cacheControl, enDB, parametros)
        End Function
		
		
		]]>
	</msxsl:script>
</xsl:stylesheet>