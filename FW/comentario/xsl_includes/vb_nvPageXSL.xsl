<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				xmlns:user="urn:vb-scripts">

	<msxsl:script language="vb" implements-prefix="user">
		<msxsl:assembly name="System.Web"/>
		<msxsl:using namespace="System.Web"/>
		<![CDATA[
		
		Dim nvFW as object = HttpContext.current.application.contents("_nvFW_interOp")
		
		public class tnvXSLPage
		   public contents as Object 
		   
		   Public Sub new()
		     
		     Dim nvFW_interOp as object = HttpContext.current.application.contents("_nvFW_interOp")
			 nvFW_interOp = HttpContext.current.application.contents("_nvFW_interOp")
		     contents = nvFW_interOp.new_class("trsParam")
			 
		   End Sub
		end class
		
		Dim Page as tnvXSLPage = new tnvXSLPage()
		
		Public function head_init()
		  Dim retScript As String = "<script type='text/javascript' language='javascript' id='nvPageXSL_HeadInit' name='nvPageXSL_HeadInit'>" & vbCrLf
          retScript += "var obj = window" & vbCrLf
          retScript += "if (nvFW != undefined)" & vbCrLf
          retScript += "  obj = nvFW" & vbCrLf
          If Page.contents.count > 0 Then
            retScript += "  obj.pageContents = " & Page.contents.toJSON() & vbCrLf & vbCrLf
          End If
          retScript += "</script>" & vbCrLf
          Return retScript
        End Function
		
		]]>
	</msxsl:script>
</xsl:stylesheet>