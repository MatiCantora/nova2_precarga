Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvBasicControls
        Public Class tTreeNode
            Public id As String
            Public name As String
            Public tipo As String
            Public icono As String
            Public jscode As String = ""
            Public URL As String = ""
            Public URL_target As String = ""
            Public enableCheckBox As Boolean = False
            Public checked As Boolean = False
            Public count_hijos As Integer = 0
            Public hijos As List(Of tTreeNode)

            Public Sub New(Optional ByVal id As String = "",
                            Optional ByVal name As String = "",
                            Optional ByVal tipo As String = "",
                            Optional ByVal icono As String = "",
                            Optional ByVal jscode As String = "",
                            Optional ByVal URL As String = "",
                            Optional ByVal URL_target As String = "",
                            Optional ByVal enableCheckBox As Boolean = False,
                            Optional ByVal checked As Boolean = False,
                            Optional ByVal count_hijos As Integer = 0)

                Me.id = id
                Me.name = name
                Me.tipo = tipo
                Me.icono = icono
                Me.jscode = jscode
                Me.URL = URL
                Me.URL_target = URL_target
                Me.enableCheckBox = enableCheckBox
                Me.checked = checked
                Me.count_hijos = count_hijos
                Me.hijos = New List(Of tTreeNode)
            End Sub

            Public Sub addChildrenNode(Optional ByVal id As String = "",
                            Optional ByVal name As String = "",
                            Optional ByVal tipo As String = "",
                            Optional ByVal icono As String = "",
                            Optional ByVal jscode As String = "",
                            Optional ByVal URL As String = "",
                            Optional ByVal URL_target As String = "",
                            Optional ByVal enableCheckBox As Boolean = False,
                            Optional ByVal checked As Boolean = False,
                            Optional ByVal count_hijos As Integer = 0)
                Dim node As New tTreeNode(id, name, tipo, icono, jscode, URL, URL_target, enableCheckBox, checked, count_hijos)
                Me.hijos.Add(node)
            End Sub

            Public Sub reponseXML()
                Dim strXML As String = "<?xml version='1.0' encoding='ISO-8859-1'?><resultado><nodo id='" & Me.id & "' desc='" & nvXMLUtiles.escapeXMLAttribute(Me.name) & "' tipo='" & Me.tipo & "' hijos='" & Me.count_hijos & "'  icono='" & Me.icono & "' checkbox='" & IIf(Me.enableCheckBox, "habilitado", "no-habilitado") & "' checked='" & Me.checked.ToString().ToLower() & "' >"
                For i = 0 To Me.hijos.Count - 1
                    strXML += "<nodo id='" & Me.hijos(i).id & "' desc='" & nvXMLUtiles.escapeXMLAttribute(Me.hijos(i).name) & "' tipo='" & Me.hijos(i).tipo & "' hijos='" & Me.hijos(i).count_hijos & "'  icono='" & Me.hijos(i).icono & "' checkbox='" & IIf(Me.hijos(i).enableCheckBox, "habilitado", "no-habilitado") & "' checked='" & Me.hijos(i).checked.ToString().ToLower() & "' >"
                    If Me.hijos(i).jscode <> "" Then
                        strXML += "<Acciones tipo='script'>"
                        strXML += "<Ejecutar Tipo='script'>"
                        strXML += "<Codigo><![CDATA[" & Me.hijos(i).jscode & "]]></Codigo>"
                        strXML += "</Ejecutar>"
                        strXML += "</Acciones></nodo>"
                    Else
                        strXML += "<Acciones>"
                        strXML += "<Ejecutar Tipo='link'>"
                        strXML += "<URL><![CDATA[" & Me.hijos(i).URL & "]]></URL>"
                        strXML += "<Target>" & Me.hijos(i).URL_target & "</Target>"
                        strXML += "</Ejecutar>"
                        strXML += "</Acciones></nodo>"
                    End If
                Next

                strXML += "</nodo></resultado>"
                HttpContext.Current.Response.ContentType = "text/xml"
                HttpContext.Current.Response.Write(strXML)
                HttpContext.Current.Response.End()
            End Sub

            Public Sub loadFromDB(ByVal vista As String, ByVal nodo_id As String, Optional ByVal orden As String = "", Optional ByVal filtro As String = "")
                Dim strSQL As String
                Dim rs As ADODB.Recordset = Nothing
                Try
                    If nodo_id.ToLower = "raiz" Then
                        strSQL = "select * from " & vista & " where depende_de is null " & IIf(filtro = "", "", " and " & filtro) & IIf(orden = "", "", "Order by " & orden)
                        rs = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
                        Me.id = "raiz"
                        Me.name = "raiz"
                        Me.tipo = "raiz"
                        Me.count_hijos = rs.RecordCount
                        While Not rs.EOF
                            Me.addChildrenNode(rs.Fields("nodo_id").Value, rs.Fields("nombre").Value, rs.Fields("tipo").Value,
                                               rs.Fields("icono").Value, rs.Fields("jscode").Value, rs.Fields("url").Value, rs.Fields("url_target").Value,
                            rs.Fields("enableCheckBox").Value = "habilitado", rs.Fields("checked").Value = "true", rs.Fields("count_hijos").Value)
                            rs.MoveNext()
                        End While
                    Else
                        strSQL = "select case when nodo_id = '" & nodo_id & "' then 0 else 1 end as orden,  * " &
                                "from " & vista & " where nodo_id = '" & nodo_id & "' or depende_de = '" & nodo_id & "'" &
                                IIf(filtro = "", "", " and " & filtro) &
                                " order by orden " & IIf(orden = "", "", ", " & orden)
                        rs = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
                        While Not rs.EOF
                            If rs.Fields("nodo_id").Value = nodo_id Then
                                Me.id = rs.Fields("nodo_id").Value
                                Me.name = rs.Fields("nombre").Value
                                Me.tipo = rs.Fields("tipo").Value
                                Me.icono = rs.Fields("icono").Value
                                Me.jscode = rs.Fields("jscode").Value
                                Me.URL = rs.Fields("url").Value
                                Me.URL_target = rs.Fields("url_target").Value
                                Me.enableCheckBox = rs.Fields("enableCheckBox").Value = "habilitado"
                                Me.checked = rs.Fields("checked").Value = "true"
                                Me.count_hijos = rs.Fields("count_hijos").Value
                            Else
                                Me.addChildrenNode(rs.Fields("nodo_id").Value, rs.Fields("nombre").Value, rs.Fields("tipo").Value,
                                               rs.Fields("icono").Value, rs.Fields("jscode").Value, rs.Fields("url").Value, rs.Fields("url_target").Value,
                                               rs.Fields("enableCheckBox").Value = "habilitado", rs.Fields("checked").Value = "true", rs.Fields("count_hijos").Value)
                            End If

                            rs.MoveNext()
                        End While
                    End If
                Catch e As Exception
                    nvDBUtiles.DBCloseRecordset(rs)
                    Throw e
                Finally
                End Try
            End Sub
        End Class

        Public Class tMenu
            Public MenuItems As Dictionary(Of String, tMenuItem)
            Public Sub New()
                MenuItems = New Dictionary(Of String, tMenuItem)()
            End Sub
            Public Sub addChildItem(Optional ByVal id As String = "",
                          Optional ByVal desc As String = "",
                          Optional ByVal icono As String = "",
                          Optional ByVal jscode As String = "",
                          Optional ByVal URL As String = "",
                          Optional ByVal URL_target As String = "",
                          Optional ByVal lib_tipo As String = "offLine",
                          Optional ByVal lib_value As String = "DocMNG")

                Dim mi As New tMenuItem(id, desc, icono, jscode, URL, URL_target, lib_tipo, lib_value)
                Me.MenuItems.Add(id, mi)
            End Sub
            Public Function getXML() As String
                Dim strXML As String = "<?xml version='1.0' encoding='ISO-8859-1'?><resultado><MenuItems>"
                Dim id As String
                For Each id In Me.MenuItems.Keys
                    strXML += Me.MenuItems(id).getXML()
                Next
                strXML += "</MenuItems></resultado>"
                Return strXML
            End Function
            Public Sub responseXML()
                Dim strXML As String = Me.getXML()
                HttpContext.Current.Response.ContentType = "text/xml"
                HttpContext.Current.Response.Write(strXML)
                HttpContext.Current.Response.End()
            End Sub
        End Class

        Public Class tMenuItem
            Public id As String
            Public lib_tipo As String
            Public lib_value As String
            Public icono As String
            Public desc As String
            Public jscode As String = ""
            Public URL As String = ""
            Public URL_target As String = ""
            Public MenuItems As Dictionary(Of String, tMenuItem)

            Public Sub New(Optional ByVal id As String = "",
                           Optional ByVal desc As String = "",
                           Optional ByVal icono As String = "",
                           Optional ByVal jscode As String = "",
                           Optional ByVal URL As String = "",
                           Optional ByVal URL_target As String = "",
                           Optional ByVal lib_tipo As String = "offLine",
                           Optional ByVal lib_value As String = "DocMNG")

                Me.id = id
                Me.desc = desc
                Me.lib_tipo = lib_tipo
                Me.lib_value = lib_value
                Me.icono = icono
                Me.jscode = jscode
                Me.URL = URL
                Me.URL_target = URL_target
                Me.MenuItems = New Dictionary(Of String, tMenuItem)
            End Sub


            Public Sub addChildItem(Optional ByVal id As String = "",
                          Optional ByVal desc As String = "",
                          Optional ByVal icono As String = "",
                          Optional ByVal jscode As String = "",
                          Optional ByVal URL As String = "",
                          Optional ByVal URL_target As String = "",
                          Optional ByVal lib_tipo As String = "offLine",
                          Optional ByVal lib_value As String = "DocMNG")

                Dim mi As New tMenuItem(id, desc, icono, jscode, URL, URL_target, lib_tipo, lib_value)
                Me.MenuItems.Add(id, mi)
            End Sub

            Public Function getXML() As String
                Dim strXML As String = "" '"<?xml version='1.0' encoding='ISO-8859-1'?><resultado><MenuItems>"
                Dim id As String
                strXML += "<MenuItem id='" & Me.id & "'><Lib TipoLib='" & lib_tipo & "'>" & lib_value & "</Lib><icono>" & icono & "</icono><Desc><![CDATA[" & desc & "]]></Desc>"
                If Me.MenuItems.Count > 0 Then
                    strXML += "<MenuItems>"
                    For Each id In Me.MenuItems.Keys
                        strXML += Me.MenuItems(id).getXML()
                    Next
                    strXML += "</MenuItems>"
                Else
                    If Me.jscode <> "" Then
                        strXML += "<Acciones tipo='script'>"
                        strXML += "<Ejecutar Tipo='script'>"
                        strXML += "<Codigo><![CDATA[" & Me.jscode & "]]></Codigo>"
                        strXML += "</Ejecutar>"
                        strXML += "</Acciones>"
                    Else
                        strXML += "<Acciones>"
                        strXML += "<Ejecutar Tipo='link'>"
                        strXML += "<URL><![CDATA[" & Me.URL & "]]></URL>"
                        strXML += "<Target>" & Me.URL_target & "</Target>"
                        strXML += "</Ejecutar>"
                        strXML += "</Acciones>"
                    End If
                End If
                strXML += "</MenuItem>"
                Return strXML
            End Function
        End Class

    End Namespace
End Namespace
