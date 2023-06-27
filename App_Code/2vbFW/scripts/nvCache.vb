Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Public Class nvCache

        Public Shared Sub init()
            Dim oCacheStore As nvCacheStore = New nvCacheStore
            nvSession.Contents("nvCacheStore") = oCacheStore
        End Sub

        Public Shared Function add(ByVal cacheID As String, ByVal oCache As nvCacheElement) As nvCacheElement
            Dim caches As nvCacheStore = nvSession.Contents("nvCacheStore")
            Return caches.add(cacheID, oCache)
        End Function

        Public Shared Function add(ByVal cacheID As String, ByRef params As Dictionary(Of String, Object), ByRef valores As Dictionary(Of String, Object), ByVal expireAbsolute As Date) As nvCacheElement
            Dim caches As nvCacheStore = nvSession.Contents("nvCacheStore")
            Return caches.add(cacheID, params, valores, expireAbsolute)
        End Function

        Public Shared Function add(ByVal cacheID As String, ByRef params As Dictionary(Of String, Object), ByRef valores As Dictionary(Of String, Object), ByVal expire_minutes As Integer) As nvCacheElement
            Dim caches As nvCacheStore = nvSession.Contents("nvCacheStore")
            Return caches.add(cacheID, params, valores, expire_minutes)
        End Function

        Public Shared Function getCache(ByVal cacheID As String, ByRef params As Dictionary(Of String, Object)) As nvCacheElement
            Dim caches As nvCacheStore = nvSession.Contents("nvCacheStore")
            Return caches.getCache(cacheID, params)
        End Function


        Public Shared Function IDGen() As String
            Dim id As String = ""
            Dim code As Integer
            Randomize()
            For i = 0 To 10
                code = CInt(Rnd() * 25) + 65
                id = id & Chr(code)
            Next
            Return id
        End Function

        Public Shared Sub clear(Optional Session As HttpSessionState = Nothing)
            Try
                Dim pvSession = nvSession.GetContents(Session)
                If pvSession IsNot Nothing AndAlso pvSession("nvCacheStore") IsNot Nothing Then
                    Dim caches As nvCacheStore = pvSession("nvCacheStore")
                    caches.clear()
                    nvSession.GetContents(Session)("nvCacheStore") = Nothing
                End If
            Catch ex As Exception

            End Try
        End Sub


    End Class



    Public Class nvCacheStore
        Private _caches As Dictionary(Of String, List(Of nvCacheElement))

        Public Sub New()
            _caches = New Dictionary(Of String, List(Of nvCacheElement))
        End Sub

        Public Function add(ByVal name As String, ByVal oCache As nvCacheElement) As nvCacheElement
            If Not _caches.ContainsKey(name) Then
                _caches.Add(name, New List(Of nvCacheElement))
            End If
            Dim index As String = findIndex(name, oCache.params)
            If Not index Is Nothing Then
                _caches(name).RemoveAt(index)
            End If
            _caches(name).Add(oCache)
            Return oCache
        End Function

        Public Function add(ByVal name As String, ByRef params As Dictionary(Of String, Object), ByRef valores As Dictionary(Of String, Object), Optional ByVal expire_minutes As Integer = 0) As nvCacheElement
            Dim oCache As nvCacheElement = New nvCacheElement(name, params, valores, expire_minutes, Nothing)
            Return Me.add(name, oCache)
        End Function

        Public Function add(ByVal name As String, ByRef params As Dictionary(Of String, Object), ByRef valores As Dictionary(Of String, Object), ByVal expireAbsolute As Date) As nvCacheElement
            Dim oCache As nvCacheElement = New nvCacheElement(name, params, valores, 0, expireAbsolute)
            Return Me.add(name, oCache)
        End Function

        Public Function getCache(ByVal name As String, ByRef params As Dictionary(Of String, Object)) As nvCacheElement
            Dim oCache As nvCacheElement = Nothing
            Dim index As String = findIndex(name, params)
            If Not index Is Nothing Then
                oCache = _caches(name)(index)
                If Not oCache Is Nothing Then
                    oCache.actualiceExpire()
                End If
            End If
            Return oCache
        End Function

        Public Function removeCache(ByVal name As String, ByRef params As Dictionary(Of String, Object)) As nvCacheElement
            Dim oCache As nvCacheElement = Nothing
            Dim index As String = findIndex(name, params)
            If Not index Is Nothing Then
                'oCache = _caches(name)(index)
                _caches(name).RemoveAt(index)
            End If
            Return oCache

        End Function

        Public Sub clear()
            Dim name As String
            Dim index As Integer
            'En caso de que exostan caches de RS los cierra
            If _caches.Keys.Contains("rs") Then
                For Each cacheElement As nvCacheElement In _caches("rs")
                    Try
                        nvDBUtiles.DBCloseRecordset(cacheElement.Valores("rs"))
                    Catch ex As Exception
                    End Try
                Next
            End If
            For Each name In _caches.Keys
                For Each cacheElement As nvCacheElement In _caches(name)
                    cacheElement.clear()
                Next
            Next
            For Each name In _caches.Keys
                _caches(name).Clear()
            Next
            _caches.Clear()

        End Sub

        Private Function findIndex(ByVal name As String, ByRef params As Dictionary(Of String, Object)) As String
            'Eliminar elementos expirados
            Me.deleteExpired()

            If Not _caches.ContainsKey(name) Then
                Return Nothing
            End If

            Dim cacheElementsCollection As List(Of nvCacheElement) = _caches(name)
            Dim encontrado As Boolean
            Dim i As String = 0
            Dim param_name As String
            'Recorrer todos los elementos del cache
            For Each cacheElement As nvCacheElement In cacheElementsCollection
                encontrado = False
                Try
                    'Dim value As String = DirectCast(cacheElement.params(1), KeyValuePair(Of String, String)).Key
                    If cacheElement.params.Keys.Count <> params.Keys.Count Then
                        Continue For
                    End If
                    For Each param_name In cacheElement.params.Keys
                        If cacheElement.params(param_name) <> params(param_name) Then
                            GoTo salto1
                        End If
                    Next
                    encontrado = True
                Catch ex As Exception
                End Try
salto1:
                If encontrado Then
                    Return i
                End If
                i += 1
            Next
            Return Nothing
        End Function


        Private Sub deleteExpired()
            Dim name As String
            Dim eliminar As New Dictionary(Of String, List(Of nvCacheElement))
            For Each name In _caches.Keys
                For Each cacheElement As nvCacheElement In _caches(name)
                    If cacheElement.expireAbsolute < Now() Then
                        If Not eliminar.ContainsKey(name) Then eliminar.Add(name, New List(Of nvCacheElement))
                        eliminar(name).Add(cacheElement)
                    End If
                Next
            Next

            For Each name In eliminar.Keys
                For Each cacheElement As nvCacheElement In eliminar(name)
                    _caches(name).Remove(cacheElement)
                Next
            Next
        End Sub

        Protected Overrides Sub Finalize()
            _caches = Nothing
            MyBase.Finalize()
        End Sub
    End Class



    Public Class nvCacheElement
        Private _name As String
        Private _expireAbsolute As Date
        Private _expire_minutes As Integer = 0
        Private _params As Dictionary(Of String, Object)
        Private _valores As Dictionary(Of String, Object)

        Public Sub New(ByVal cacheID As String, ByVal params As Dictionary(Of String, Object), ByVal valores As Dictionary(Of String, Object), Optional ByVal expire_minutes As Integer = 0, Optional ByVal expireAbsolute As Date = Nothing)
            _name = cacheID
            _params = params
            _valores = valores
            _expire_minutes = expire_minutes
            If expire_minutes > 0 Then
                _expireAbsolute = DateAdd(DateInterval.Minute, expire_minutes, Now())
            Else
                If expireAbsolute = (New Date(0)) Then
                    expireAbsolute = Now()
                End If
                _expireAbsolute = expireAbsolute
            End If
        End Sub

#Region "Propiedades"

        Public ReadOnly Property name As String
            Get
                Return _name
            End Get
        End Property

        Public ReadOnly Property expire_minutes As Integer
            Get
                Return _expire_minutes
            End Get
        End Property

        Public ReadOnly Property expireAbsolute As Date
            Get
                Return _expireAbsolute
            End Get
        End Property

        Public ReadOnly Property params As Dictionary(Of String, Object)
            Get
                Return _params
            End Get
        End Property

        Public ReadOnly Property Valores As Dictionary(Of String, Object)
            Get
                Return _valores
            End Get
        End Property

#End Region 'Propiedades

#Region "Metodos"
        Public Sub clear()
            _params.Clear()
            _valores.Clear()
        End Sub

        Public Sub actualiceExpire()
            If _expire_minutes > 0 Then
                _expireAbsolute = DateAdd(DateInterval.Minute, _expire_minutes, Now())
            End If
        End Sub

        Protected Overrides Sub Finalize()
            _params = Nothing
            _valores = Nothing
            MyBase.Finalize()
        End Sub

#End Region
    End Class


    Public Class nvCacheID_index
        Public cacheID As String
        Public index As Integer
        Public Sub New(ByVal pCacheID As String, ByVal pIndex As Integer)
            cacheID = pCacheID
            index = pIndex
        End Sub
    End Class


End Namespace