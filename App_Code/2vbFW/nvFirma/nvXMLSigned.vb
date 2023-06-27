Imports Microsoft.VisualBasic
Imports System.Xml
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Public Class nvXMLSigned
    Inherits System.Security.Cryptography.Xml.SignedXml


    Private doc As XmlDocument = Nothing
    Private signaturePropertiesRoot As XmlElement = Nothing



    Public Sub New(doc As XmlDocument, signatureId As String, propertiesId As String)

        MyBase.New(doc)

        If String.IsNullOrEmpty(signatureId) Then
            Throw New ArgumentException("signatureId no puede ser vacio", "signatureId")
        End If
        If String.IsNullOrEmpty(propertiesId) Then
            Throw New ArgumentException("propertiesId no puede ser vacio", "propertiesId")
        End If

        Me.doc = doc
        Me.Signature.Id = signatureId

        ' crear elemento root para guardar las properties
        Me.signaturePropertiesRoot = doc.CreateElement("SignatureProperties", XmlDsigNamespaceUrl)
        Me.signaturePropertiesRoot.SetAttribute("Id", propertiesId)


        ' crear objeto para guardar las properties
        Dim signatureProperties As System.Security.Cryptography.Xml.DataObject = New System.Security.Cryptography.Xml.DataObject()
        signatureProperties.Data = signaturePropertiesRoot.SelectNodes(".")
        Me.AddObject(signatureProperties)

        ' añadir una referencia oara el data object
        Dim propertiesRef As System.Security.Cryptography.Xml.Reference = New System.Security.Cryptography.Xml.Reference("#" + propertiesId)
        propertiesRef.Type = "http://www.w3.org/2000/02/xmldsig#SignatureProperty"
        Me.AddReference(propertiesRef)

        Return

    End Sub




    Public Sub AddProperty(content As XmlElement)
        If content Is Nothing Then
            Throw New ArgumentNullException("content")
        End If

        If String.Compare(content.NamespaceURI, XmlDsigNamespaceUrl) = 0 Then
            Throw New InvalidOperationException("Las propiedades de la firma no deben estar en el namespace de firma digital de XML")
        End If

        ' elemento SignatureProperty
        Dim prop As XmlElement = doc.CreateElement("SignatureProperty", XmlDsigNamespaceUrl)
        prop.SetAttribute("Target", "#" + Signature.Id)
        prop.AppendChild(content)

        signaturePropertiesRoot.AppendChild(prop)
        Return
    End Sub



    Public Overrides Function GetIdElement(doc As XmlDocument, id As String) As XmlElement

        If id = Nothing Then
            Return Nothing
        End If
        If String.Compare(id, signaturePropertiesRoot.GetAttribute("Id"), StringComparison.OrdinalIgnoreCase) = 0 Then
            Return signaturePropertiesRoot
        Else
            Return MyBase.GetIdElement(doc, id)
        End If
    End Function





End Class



