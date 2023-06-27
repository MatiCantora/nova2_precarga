<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<%
    Dim cn1 As New ADODB.Connection
    Dim cn2 As New ADODB.Connection
    Dim rs As ADODB.Recordset
    Dim msg As String

    Try
        Stop
        Dim txtCN1 As String = "Provider=SQLNCLI11;Server=mova1.redmutual.com.ar;Database=nvadmin;Failover Partner=mova2.redmutual.com.ar;Integrated Security=SSPI;"
        Dim txtCN2 As String = "Provider=ASEOLEDB;Data Source=172.16.5.80:2048;Initial Catalog=DBAnexa;User Id=sa;Password=Impronta15;Charset=ClientDefault;CodePageType=other;clientCharset=cp850;"
        Dim txtSQL As String = "select * from API_nodes"
        Dim txtCreateTable As String = "CREATE TABLE #API_nodes(  " &
    "[api_cfg_id] [varchar](50) NOT NULL," &
    "[node_name] [varchar](500) Not NULL," &
    "[node_type] [int] Not NULL," &
    "[node_parent] [varchar](500) NULL," &
    "[permiso_grupo] [varchar](50) Not NULL," &
    "[nro_permiso] [int] NOT NULL," &
    "[proxy_url] [varchar](500) Not NULL," &
    "[proxy_client_cert] [varbinary](4000) NULL," &
    "[proxy_http_session] [bit] Not NULL," &
    "[proxy_timeout] [int] NULL," &
    "[proxy_add_headers] [varchar](255) Not NULL," &
    "[folder_host] [varchar](500) NOT NULL," &
    "[folder_host_failover] [varchar](500) Not NULL," &
    "[srv_path] [varchar](500) NOT NULL," &
    "[proxy_client_cert_name] [varchar](500) NULL," &
    "[proxy_client_cert_pwd] [varchar](50) NULL," &
    "[orden] [int] Not NULL," &
    "[ident_cert] [bit] NOT NULL," &
    "[ident_token] [bit] Not NULL," &
    "[proxy_server_cert] [varbinary](4000) NULL," &
    "[input_buffer_size] [int] NULL," &
    "[output_buffer_size] [int] NULL)"

        cn1.Open(txtCN1)
        cn2.Open(txtCN2)

        'Cargar el recordsert
        rs = New ADODB.Recordset
        rs.CursorLocation = ADODB.CursorLocationEnum.adUseClient
        rs.CursorType = ADODB.CursorTypeEnum.adOpenStatic
        rs.Open(txtSQL, cn1)
        Dim RecordCount As Integer = rs.RecordCount
        Dim strNames As String = ""
        While Not rs.EOF
            strNames += ", " & rs.Fields("node_name").Value
            rs.MoveNext()
        End While


        'Crear la tabla temporal
        cn2.Execute(txtCreateTable)

        'Abrir la tabla temporal en modo dinámico
        Dim rs2 As New ADODB.Recordset
        rs2.CursorType = ADODB.CursorTypeEnum.adOpenKeyset
        rs2.LockType = ADODB.LockTypeEnum.adLockOptimistic
        rs2.Open("select * from #API_nodes", cn2)
        rs2.AddNew()
        For i = 0 To rs.Fields.Count - 1
            If Not rs.Fields(rs.Fields(i).Name).Value Is Nothing Then
                rs2.Fields(rs.Fields(i).Name).Value = rs.Fields(rs.Fields(i).Name).Value
            End If
        Next
        rs2.UpdateBatch()


        rs2.Close()
        'Eliminar la tabla temporal
        cn2.Execute("Drop table #API_nodes")

        rs.Close()
        cn1.Close()
        cn2.Close()
        msg = "Cantidad de registros " & RecordCount
    Catch ex As Exception
        msg = ex.Message
    End Try
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
        

    <% = Me.getHeadInit()%>

    <style type="text/css">
        input
        {
            width: 100px;
        }
    </style>

    <script type="text/javascript" language="javascript">
         
        function window_onload()
          {
         
           
            
//          var el = $("input_txt")
//          el.addEventListener('change', handler, false)
//          //el.addEventListener('domattrmodified', handler, false)
//          //el.onchange = handler

//          el = $("input_hidden")
//          el.addEventListener('change', handler, false)
//          //el.addEventListener('domattrmodified', handler, false)
//          //el.onchange = handler

          }

 
    </script>

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >
    <%=msg %>
</body>
</html>
