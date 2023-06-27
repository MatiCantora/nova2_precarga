<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 
    'Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    'Dim nro_docu As Integer = 0
    'Dim nro_vendedor As Integer = 0
    'Dim dependientes As String = ""
    'Try
    '    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from veroperadores where operador = " & nvApp.operador.operador)
    '    nro_docu = rs.Fields("nro_docu").Value '4292472
    '    nvDBUtiles.DBCloseRecordset(rs)
    'Catch ex As Exception
    'End Try
    'If nro_docu <> 0 Then
    '    Try
    '        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from vervendedores where nro_docu = " & nro_docu)
    '        nro_vendedor = rs.Fields("nro_vendedor").Value
    '        nvDBUtiles.DBCloseRecordset(rs)
    '        If nro_vendedor <> 0 Then
    '            Dim rsD = nvFW.nvDBUtiles.DBOpenRecordset("select dbo.rm_vendedor_dependencia(" & nro_vendedor & ") as dependientes")
    '            dependientes = rsD.Fields("dependientes").Value
    '        End If
    '    Catch ex As Exception
    '    End Try
    'End If
    'Me.contents.Add("filtroXML_vendedores", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEstructuraVenta'  PageSize='7' AbsolutePage='1' cacheControl='Session' orden='0'><campos>nro_vendedor,vendedor,estructura,cod_prov,provincia,postal_real,nro_estructura</campos><orden></orden><filtro></filtro></select></criterio>"))
    Dim accion As String = nvUtiles.obtenerValor("accion")
    'permisos_precarga 1 
    If accion = "set_vendedor" And Me.operador.tienePermiso("permisos_precarga", 1) Then
        Me.operador.setVendedor(nvUtiles.obtenerValor("nro_vendedor"))
        'Dim rs As New ADODB.Recordset
        'Try
        '    rs = nvDBUtiles.DBOpenRecordset("select *, dbo.rm_vendedor_dependencia(nro_vendedor) as dependientes from vervendedores where nro_vendedor = " & nvUtiles.obtenerValor("nro_vendedor"))
        '    If Not rs.EOF Then
        '        Me.operador.nro_vendedor = rs.Fields("nro_vendedor").Value
        '        Me.operador.vendedor = rs.Fields("strNombreCompleto").Value < a href="../Bin/">../Bin/</a>
        '        Me.operador.nro_estructura = rs.Fields("nro_estructura").Value
        '        Me.operador.estructura = rs.Fields("estructura").Value
        '        Me.operador.dependientes = rs.Fields("dependientes").Value
        '    End If

        'Catch ex4 As Exception

        'Finally
        '    nvDBUtiles.DBCloseRecordset(rs)
        'End Try

        'Me.operador.nro_vendedor = nvUtiles.obtenerValor("nro_vendedor")
        'Me.operador.vendedor = nvUtiles.obtenerValor("vendedor")
        Dim err As New tError()
        err.params("nro_vendedor") = Me.operador.nro_vendedor
        err.response()
    End If

    Dim filtro_dependientesA As String = ""
    If Me.operador.dependientes <> "" Then filtro_dependientesA = "<nro_vendedor type='in'>" & Me.operador.dependientes & "</nro_vendedor>"


    'Dim filtroDependinetes As String = ""
    'If operador.tienePermiso("permisos_precarga", 9) AndAlso dependientes <> "" Then filtroDependinetes = "<nro_vendedor type='in'>%nvSession['vendedor_dependientes']%</nro_vendedor>"

    Me.contents.Add("filtroXML_vendedores", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEstructuraVenta1'  PageSize='7' AbsolutePage='1' cacheControl='Session'><campos>nro_vendedor,vendedor,estructura,cod_prov,provincia,postal_real,nro_estructura</campos><orden></orden><filtro>" & filtro_dependientesA & "</filtro></select></criterio>"))
    'Me.contents.Add("estructura", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vend_estructura'><campos>nro_estructura,estructura</campos><filtro><fe_baja type='isnull'/></filtro><orden></orden></select></criterio>"))

    'Me.contents("permisos_precarga") = op.permisos("permisos_precarga")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="initial-scale=1">
    <title>Precarga - Seleccionar Vendedor</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <!--<link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />-->
    <!--<link href="css/precarga.css" type="text/css" rel="stylesheet" />-->
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>

    <% = Me.getHeadInit()%>
    <style type="text/css">
        .filtro {
            -moz-border-radius: 0.33em;
            box-shadow: 0 0 1px #f4f4f4;
            text-align: left;
            height: 21px;
            width:50%;
            margin-bottom: 0.66em;
        }
            .filtro div{
            border-radius: 0.33em; 
            height: 1.5em;
            display: flex;
            justify-content: center;
            align-content: center;
            flex-direction: column;
            padding: 0px 0.35em 0px 0.35em;
        }

        @media screen and (max-width: 580px) {
            .filtro {
                width:100%
            }
        }
        
    </style>
    <script type="text/javascript" language="javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

    var vButtonItems = {}
    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "Aceptar";
    vButtonItems[0]["etiqueta"] = "Buscar";
    vButtonItems[0]["imagen"] = "";
    vButtonItems[0]["onclick"] = "return Buscar()";

    var vListButtons = new tListButton(vButtonItems, 'vListButtons');

    var win = nvFW.getMyWindow()
    var res = {}
    var BodyWidth = 0

    function window_onload() {
        vListButtons.MostrarListButton()
        //CargarEstructuras()
        document.getElementById('strVendedor').focus()
        window_onresize() 
    }

    function Buscar() {
        var filtroWhere = ''

        if ($('strVendedor').value != '')
            filtroWhere += "<vendedor type='like'>%" + $('strVendedor').value + "%</vendedor>"

        if ($('nro_docu_vend').value != '')
            filtroWhere += "<nro_docu type='igual'>" + $('nro_docu_vend').value + "</nro_docu>"

        if ($('nro_estructura').value != '')
            filtroWhere += "<nro_estructura type='igual'>" + $('nro_estructura').value + "</nro_estructura>"        
        
        //if (((permisos_precarga & 256) > 0) && (dependientes != ''))
        //    filtroWhere += "<nro_vendedor type='in'>" + dependientes + "</nro_vendedor>"

        if (filtroWhere != "") {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroXML_vendedores,
                filtroWhere: "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl: '/report/verSelVendedor/HTML_sel_vendedor.xsl',
                formTarget: 'iframe_vendedores',
                async: true,
                bloq_contenedor: $(document.documentElement),
                bloq_msg: 'Realizando búsqueda...',
                nvFW_mantener_origen: true
            })
        }
        else {
            alert('Por favor, seleccione un criterio de búsqueda.')
            return
        }  

        
    }

    //function CargarEstructuras() {
    //    $('cbEstructura').insert(new Element('option', { value: '' }).update(''))
    //    var rs = new tRS();
    //    //rs.open("<criterio><select vista='vend_estructura'><campos>nro_estructura,estructura</campos><filtro><fe_baja type='isnull'/></filtro><orden></orden></select></criterio>")
    //    rs.open({filtroXML: nvFW.pageContents["estructura"]})
    //    while (!rs.eof())
    //    {
    //        $('cbEstructura').insert(new Element('option', { value: rs.getdata('nro_estructura') }).update(rs.getdata('estructura')))
    //        rs.movenext()
    //    }
    //}

        function selVendedor(nro_vendedor, vendedor, cod_prov, provincia, postal_real, nro_estructura) {
            var res = new Array()
            res["nro_vendedor"] = nro_vendedor
            res["vendedor"] = vendedor
            res["cod_prov"] = cod_prov
            res["provincia"] = provincia
            res["postal_real"] = postal_real
            res["nro_estructura"] = nro_estructura
            //alert(nro_estructura)


            nvFW.error_ajax_request("selVendedor.aspx", {
                async: false,
                //onSuccess: function (err) { alert(err.params['nro_vendedor']) },
                //onFailure: function () { alert("Error") }
                 parameters: {
                    accion: "set_vendedor",
                    nro_vendedor: nro_vendedor,
                    vendedor: vendedor
                }
        })

      win.options.userData = {res: res}
      win.close()
    }

    function window_onresize() {
        try {
              var dif = Prototype.Browser.IE ? 5 : 2
              body_height = $$('body')[0].getHeight()
              cab_height = $('tbFiltro').getHeight()              
              $('iframe_vendedores').setStyle({ height: body_height - cab_height - dif + 'px' })              
              
          }
          catch (e) { }
    }

    function strVendedor_onkeypress(e) 
    {
        key = Prototype.Browser.IE ? event.keyCode : e.which
        if (key == 13)
                Buscar()
    }


    function enter_onkeypress(e) {
        key = Prototype.Browser.IE ? e.keyCode : e.which
        if (key == 13)
            Buscar()
    }


    function documVendedor_onIntro(){
        if (event.keyCode == 13) {
             Buscar()
        }
    }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <%--    <table id="tbFiltro" class="tb1">
  <tr>
     <td class='Tit2' style="width: 35%">Vendedor:</td>
      <td><input style="width: 100%" name="strVendedor" id="strVendedor" onkeypress="return strVendedor_onkeypress(event)" /></td>
  </tr>
  <tr>
     <td class='Tit2' style="width: 35%; white-space:nowrap;" >Nº documento:</td>
    <td><input style="width: 100%" type="text" name="nro_docu_vend" id="nro_docu_vend" onkeypress="return documVendedor_onIntro(event) || valDigito(event)" maxlength="10" /></td>
  </tr>
  <tr>
     <td class='Tit2' style="width: 35%">Estructura:</td>
    <td><script type="text/javascript">campos_defs.add('nro_estructura', { enDB: true })</script></td>
  </tr>
  <tr>
      <td></td>
      <td rowspan='2' style="width: 70%; text-align:center"><div id="divAceptar"></div></td>
      <!--<select id="cbEstructura" style="width:100%"></select>-->
      <!--<td><script type="text/javascript">campos_defs.add('nro_estructura', { permite_codigo: false, cacheControl: nvFW, despliega: 'abajo' })</script></td>-->
  </tr>
</table>  --%>

    <table id="tbFiltro" class="tb1" style="width: 100%">
        <tr>
            <td >
                <div  >
                    <div class="filtro" style="float: left;">
                        <div class='Tit2' style="width: 35%; float: left;">Vendedor:</div>
                        <div style="width: 65%; float: left">
                            <input style="width: 100%" name="strVendedor" id="strVendedor" onkeypress="return strVendedor_onkeypress(event)" />
                        </div>
                    </div>
                    <div  class="filtro" style="float: left;">
                        <div class='Tit2' style="width: 35%; float: left;white-space: nowrap;">Nº documento:</div>
                        <div style="width: 65%; float: left">
                            <input style="width: 100%" type="text" name="nro_docu_vend" id="nro_docu_vend" onkeypress="return documVendedor_onIntro(event) || valDigito(event)" maxlength="10" />
                        </div>
                    </div>
                    <div  class="filtro" style="float: left; ">
                        <div class='Tit2' style="width: 35%; float: left; ">Estructura:</div>
                        <div style="width: 65%; float: left">
                            <script type="text/javascript">campos_defs.add('nro_estructura', { enDB: true })</script>
                        </div>
                    </div>
                    <div class="filtro" style="float: left;">
                        <div style="width: 100%; text-align: center">
                            <div id="divAceptar"></div>
                        </div>
                        <!--<select id="cbEstructura" style="width:100%"></select>-->
                        <!--<td><script type="text/javascript">campos_defs.add('nro_estructura', { permite_codigo: false, cacheControl: nvFW, despliega: 'abajo' })</script></td>-->
                    </div>
                </div>
            </td>
        </tr>
    </table>
 <iframe name="iframe_vendedores" id="iframe_vendedores" style="width: 100%;   overflow: auto;" frameborder="0" src=""></iframe>
     
</body>
</html>
