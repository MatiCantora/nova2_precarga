Imports Microsoft.VisualBasic
Imports System.Xml
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class nvXMLUtiles

        Public Shared Function escapeXMLAttribute(str As String) As String
            If str <> "" Then
                str = str.Replace("&", "&amp;")
                str = str.Replace("""", "&quot;")
                str = str.Replace("'", "&apos;")
                str = str.Replace("<", "&lt;")
                str = str.Replace(">", "&gt;")
            End If
            Return str
        End Function


        Public Shared Function getXmlNamespaceManager(node As XmlNode) As XmlNamespaceManager
            If node.OuterXml = "" Then Return Nothing
            
            Dim oXML As XmlDocument
            If node.OwnerDocument Is Nothing Then
                oXML = node
            Else
                oXML = node.OwnerDocument
            End If

            Dim nsMgr As XmlNamespaceManager = New XmlNamespaceManager(oXML.NameTable)
            Dim atts As XmlAttributeCollection = oXML.DocumentElement.Attributes

            For i = 0 To atts.Count - 1
                If atts(i).Prefix = "xmlns" Then
                    nsMgr.AddNamespace(atts(i).LocalName, atts(i).Value)
                End If
            Next

            Return nsMgr
        End Function


        Public Shared Function selectNodes(node As XmlNode, path As String) As XmlNodeList
            Return node.SelectNodes(path, getXmlNamespaceManager(node))
        End Function

        Public Shared Function selectSingleNode(node As XmlNode, path As String) As XmlNode
            Return node.SelectSingleNode(path, getXmlNamespaceManager(node))
        End Function

        Public Shared Function getAttribute_path(ByVal objXML As XmlNode, ByVal path As String, Optional ByVal valor_defecto As String = "") As String
            Dim res As String = valor_defecto
            Try
                Dim NOD = objXML.SelectSingleNode(path, getXmlNamespaceManager(objXML))
                If Not NOD Is Nothing Then
                    res = NOD.Value
                End If
            Catch ex As Exception
            End Try
            Return Res
        End Function

        Public Shared Function getNodeText(ByVal objXML As XmlNode, ByVal path As String, Optional ByVal valor_defecto As String = "") As String
            Dim res As String = valor_defecto
            Try
                Dim nod = objXML.SelectSingleNode(path, getXmlNamespaceManager(objXML))
                If Not nod Is Nothing Then
                    res = nod.InnerText
                End If
            Catch ex As Exception
            End Try
            Return res
        End Function


        Public Shared Sub responseXML(ByRef response As HttpResponse, ByVal oXML As System.Xml.XmlDocument, Optional charset As String = "")
            Dim strXML As String
            strXML = oXML.OuterXml
            responseXML(response, strXML, charset)
        End Sub

        Public Shared Sub responseXML(ByRef response As HttpResponse, ByVal strXML As String, Optional charset As String = "")

            If charset = "" Then
                charset = nvConvertUtiles.currentEncoding.BodyName.ToUpper
            End If

            'Quitar la declaración XML en caso que venga
            Dim reg As New Text.RegularExpressions.Regex("^\s*<\?[^>]*\?>")
            strXML = reg.Replace(strXML, "")

            response.Expires = -1
            response.ContentType = "text/xml"
            Try
                response.Charset = charset    '"ISO-8859-1" '"UTF-8"
            Catch ex As Exception

            End Try

            strXML = "<?xml version='1.0' encoding='" & charset & "'?>" + strXML
            Dim buffer() As Byte = System.Text.Encoding.GetEncoding(charset).GetBytes(strXML)
            'Response.Write(strXML)
            response.BinaryWrite(buffer)
            'response.End()
        End Sub

        Public Shared Function GetXPathToNode(ByVal node As XmlNode) As String
            If node.NodeType = XmlNodeType.Attribute Then
                '// attributes have an OwnerElement, not a ParentNode; also they have
                '// to be matched by name, not found by position
                Return GetXPathToNode(DirectCast(node, XmlAttribute).OwnerElement) & "/@" & node.Name
            End If
            If node.ParentNode Is Nothing Then
                '// the only node with no parent is the root node, which has no path
                Return ""
            End If


            Dim nodes As XmlNodeList
            If node.NodeType = System.Xml.XmlNodeType.Element Then
                nodes = node.ParentNode.SelectNodes(node.Name)
                If nodes.Count > 1 Then
                    Dim iIndex As Integer = 1
                    While Not nodes(iIndex - 1).Equals(node)
                        iIndex += 1
                    End While
                    Return GetXPathToNode(node.ParentNode) & "/" & node.Name & "[" & iIndex & "]"
                End If
                Return GetXPathToNode(node.ParentNode) & "/" & node.Name
            Else
                Return GetXPathToNode(node.ParentNode)
            End If


            'Dim iIndex As Integer = 1
            'Dim xnIndex As XmlNode = node
            'While Not xnIndex.PreviousSibling Is Nothing
            '    iIndex += 1
            '    xnIndex = xnIndex.PreviousSibling
            'End While
            'If iIndex > 1 Then
            '    Return GetXPathToNode(node.ParentNode) & "/node()[" & iIndex & "]"
            'Else
            '    Return GetXPathToNode(node.ParentNode) & "/" & node.Name
            'End If

        End Function


        Public Shared Function XMLAddNode(ByRef oXML As XmlDocument, ByRef oNode As XmlNode, Optional ByVal rewrite As Boolean = True) As XmlNode

            Dim findNode As XmlNode = oXML.SelectSingleNode(GetXPathToNode(oNode))
            If findNode Is Nothing Or Not rewrite Then
                findNode = oXML.CreateNode(oNode.NodeType, oNode.Name, oNode.NamespaceURI)
                Dim findparent As XmlNode
                If oNode.NodeType = XmlNodeType.Attribute Then
                    findparent = oXML.SelectSingleNode(GetXPathToNode(DirectCast(oNode, XmlAttribute).OwnerElement))
                    findparent.Attributes.Append(findNode)
                Else
                    findparent = oXML.SelectSingleNode(GetXPathToNode(oNode.ParentNode))
                    findparent.AppendChild(findNode)
                End If


            End If
            If oNode.NodeType = XmlNodeType.Attribute Then
                findNode.Value = oNode.Value
            End If
            If oNode.NodeType = XmlNodeType.Text Then
                findNode.InnerText = oNode.InnerText
                
            End If
           
            Return findNode
        End Function

        Public Shared Function MergeXML(ByVal filtroXML As String, ByVal filtroXML2 As String, Optional ByVal exclusions As List(Of String) = Nothing) As String
            If exclusions Is Nothing Then
                exclusions = New List(Of String)
            End If
            If filtroXML = "" Then
                Return filtroXML2
            End If

            If filtroXML2 = "" Then
                Return filtroXML
            End If


            Dim resXML As New System.Xml.XmlDocument
            Dim oXMLADD As New System.Xml.XmlDocument

            Try
                resXML.LoadXml(filtroXML)
            Catch ex As Exception
                Return filtroXML2
            End Try

            Try
                oXMLADD.LoadXml(filtroXML2)
            Catch ex As Exception
                Return filtroXML
            End Try

            Dim node As System.Xml.XmlNode
            Dim cola As New Queue(Of System.Xml.XmlNode)
            Dim path As String
            Dim findelement As XmlNode
            node = oXMLADD.FirstChild
            While Not node Is Nothing
                path = GetXPathToNode(node)
                System.Diagnostics.Debug.Print(path)
                If Not exclusions.Contains(path) Then
                    'si bien esta función une dos XML, tiene una excepción. Si son dependientes de la etiqueta filtro se deben agregar, no reemplazar
                    If GetXPathToNode(node.ParentNode) = "/criterio/select/filtro" Then
                        findelement = XMLAddNode(resXML, node, False)
                    Else
                        findelement = XMLAddNode(resXML, node)
                    End If

                    Try
                        For i = 0 To node.Attributes.Count - 1
                            If Not exclusions.Contains(GetXPathToNode(node.Attributes(i))) Then
                                System.Diagnostics.Debug.Print(GetXPathToNode(node.Attributes(i)) & "=" & node.Attributes(i).Value)
                                XMLAddNode(resXML, node.Attributes(i))
                            End If
                        Next
                    Catch ex As Exception

                    End Try
                    For i = 0 To node.ChildNodes.Count - 1
                        Select Case node.ChildNodes(i).NodeType
                            Case XmlNodeType.CDATA
                                Dim CDATA As System.Xml.XmlNode = resXML.CreateCDataSection(node.ChildNodes(i).InnerText)
                                findelement.AppendChild(CDATA)
                            Case XmlNodeType.Text
                                System.Diagnostics.Debug.Print(GetXPathToNode(node) & "/text:" & node.ChildNodes(i).InnerText)
                                findelement.InnerText = node.InnerText
                            Case Else
                                cola.Enqueue(node.ChildNodes(i))
                        End Select
                       
                    Next
                End If
                If cola.Count > 0 Then
                    node = cola.Dequeue
                Else
                    node = Nothing
                End If
            End While
            Return resXML.OuterXml
        End Function


    End Class

    Public Class nvXmlHtmlWriter
        Inherits XmlTextWriter

        Private openingElement As String = ""
        Private openingAttribute As String = ""
        Private selfClosingElements As New List(Of String)

        Public Sub New(ByRef stream As System.IO.Stream, ByVal en As Encoding)
            MyBase.New(stream, en)
            '//// Put all the elements for which you want self closing tags in this list.
            '//// Rest of the tags would be explicitely closed
            selfClosingElements.AddRange({"area", "base", "basefont", "br", "hr", "input", "img", "link", "meta"})
        End Sub

        Public Overrides Sub WriteEndElement()
            If (Not selfClosingElements.Contains(openingElement)) Then
                WriteFullEndElement()
            Else
                MyBase.WriteEndElement()

            End If
        End Sub

        Public Overrides Sub WriteStartElement(ByVal prefix As String, ByVal localName As String, ByVal ns As String)
            MyBase.WriteStartElement(prefix, localName, ns)
            openingElement = localName
        End Sub

        Public Overrides Sub WriteStartAttribute(ByVal prefix As String, ByVal localName As String, ByVal ns As String)
            MyBase.WriteStartAttribute(prefix, localName, ns)
            openingAttribute = localName
        End Sub

        Public Overrides Sub WriteEndAttribute()
            MyBase.WriteEndAttribute()
            openingAttribute = ""
        End Sub



        Public Overrides Sub WriteString(ByVal valor As String)
            If openingAttribute = "" And openingElement = "script" Then
                MyBase.WriteRaw(valor)
            Else
                MyBase.WriteString(valor)
            End If
        End Sub

    End Class


End Namespace
