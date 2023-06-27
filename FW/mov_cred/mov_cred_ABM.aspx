<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim xmldato = nvUtiles.obtenerValor("xmldato", "")
    Dim accion = nvUtiles.obtenerValor("accion", 0)
    Dim id_mov = nvUtiles.obtenerValor("id_mov", "")
    Dim parentWin = nvUtiles.obtenerValor("parentWin", "")

    If (xmldato <> "" Or accion = 2) Then
        Dim err As New tError
        Try
            'Stop
            If (accion = 2) Then
                DBExecute("DELETE FROM mov_cab WHERE id_mov =" & id_mov,, "BD_IBS_ANEXA")
                DBExecute("DELETE FROM mov_det WHERE id_mov =" & id_mov,, "BD_IBS_ANEXA")
            Else

                Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
                objXML.LoadXml(xmldato)
                Dim nodosArchivos = objXML.SelectNodes("mov_cab/movs_cab")


                For i As Integer = 0 To nodosArchivos.Count - 1
                    Dim paiscod_origen As Integer = nodosArchivos(i).Attributes("paiscod_origen").Value
                    Dim bcocod_origen As Integer = nodosArchivos(i).Attributes("bcocod_origen").Value
                    Dim tipodoc_origen As Integer = nodosArchivos(i).Attributes("tipodoc_origen").Value
                    Dim nrodoc_origen As Long = nodosArchivos(i).Attributes("nrodoc_origen").Value
                    Dim paiscod_destino As Integer = nodosArchivos(i).Attributes("paiscod_destino").Value
                    Dim bcocod_destino As Integer = nodosArchivos(i).Attributes("bcocod_destino").Value
                    Dim tipodoc_destino As Integer = nodosArchivos(i).Attributes("tipodoc_destino").Value
                    Dim nrodoc_destino As Long = nodosArchivos(i).Attributes("nrodoc_destino").Value
                    Dim monto_mov As String = nodosArchivos(i).Attributes("monto_mov").Value
                    Dim tasa_mov As String = nodosArchivos(i).Attributes("tasa_mov").Value
                    Dim nro_mov As Integer = nodosArchivos(i).Attributes("nro_mov").Value
                    Dim nro_mov_tipo As Integer = nodosArchivos(i).Attributes("nro_mov_tipo").Value
                    Dim nro_mov_recurso_tipo As Integer = nodosArchivos(i).Attributes("nro_mov_recurso_tipo").Value
                    Dim fe_mov As DateTime = nodosArchivos(i).Attributes("fe_mov").Value
                    Dim descripcion As String = nodosArchivos(i).Attributes("descripcion").Value
                    Dim estado_mov As Char = nodosArchivos(i).Attributes("estado_mov").Value
                    'Dim fe_estado_mov As DateTime = nodosArchivos(i).Attributes("fe_estado_mov").Value
                    Dim accionAE As Integer = nodosArchivos(i).Attributes("accion").Value

                    If (accionAE = 0) Then
                        DBExecute("INSERT INTO mov_cab (paiscod_origen,bcocod_origen,tipdoc_origen,nrodoc_origen,paiscod_destino,bcocod_destino,tipdoc_destino,nrodoc_destino,monto_mov,tasa_mov,nro_mov,nro_mov_tipo,nro_mov_recurso_tipo,fe_mov,descripcion,estado_mov,fe_estado_mov) VALUES (" & paiscod_origen & "," & bcocod_origen & "," & tipodoc_origen & "," & nrodoc_origen & "," & paiscod_destino & "," & bcocod_destino & "," & tipodoc_destino & "," & nrodoc_destino & "," & monto_mov & "," & tasa_mov & "," & nro_mov & "," & nro_mov_tipo & "," & nro_mov_recurso_tipo & ",'" & fe_mov & "','" & descripcion & "','" & estado_mov & "')",, "BD_IBS_ANEXA")
                        'DBExecute("INSERT INTO mov_cab (paiscod_origen,bcocod_origen,tipdoc_origen,nrodoc_origen,paiscod_destino,bcocod_destino,tipdoc_destino,nrodoc_destino,monto_mov,tasa_mov,nro_mov,nro_mov_tipo,nro_mov_recurso_tipo,fe_mov,descripcion,estado_mov,fe_estado_mov) VALUES (" & paiscod_origen & "," & bcocod_origen & "," & tipodoc_origen & "," & nrodoc_origen & "," & paiscod_destino & "," & bcocod_destino & "," & tipodoc_destino & "," & nrodoc_destino & "," & monto_mov & "," & tasa_mov & "," & nro_mov & "," & nro_mov_tipo & "," & nro_mov_recurso_tipo & ",'" & fe_mov & "','" & descripcion & "','" & estado_mov & "','" & fe_estado_mov & "')",, "BD_IBS_ANEXA")
                    ElseIf (accionAE = 1) Then
                        id_mov = nodosArchivos(i).Attributes("id_mov").Value
                        DBExecute("UPDATE mov_cab SET paiscod_origen = " & paiscod_origen & ",bcocod_origen = " & bcocod_origen & ",tipdoc_origen = " & tipodoc_origen & ",nrodoc_origen = " & nrodoc_origen & ",paiscod_destino = " & paiscod_destino & ",bcocod_destino = " & bcocod_destino & ",tipdoc_destino = " & tipodoc_destino & ",nrodoc_destino = " & nrodoc_destino & ",monto_mov = " & monto_mov & ",tasa_mov = " & tasa_mov & ",nro_mov = " & nro_mov & ",nro_mov_tipo = " & nro_mov_tipo & ",nro_mov_recurso_tipo = " & nro_mov_recurso_tipo & ",fe_mov = '" & fe_mov & "',descripcion = '" & descripcion & "',estado_mov = '" & estado_mov & "' WHERE id_mov =" & id_mov,, "BD_IBS_ANEXA")
                        'DBExecute("UPDATE mov_cab SET paiscod_origen = " & paiscod_origen & ",bcocod_origen = " & bcocod_origen & ",tipdoc_origen = " & tipodoc_origen & ",nrodoc_origen = " & nrodoc_origen & ",paiscod_destino = " & paiscod_destino & ",bcocod_destino = " & bcocod_destino & ",tipdoc_destino = " & tipodoc_destino & ",nrodoc_destino = " & nrodoc_destino & ",monto_mov = " & monto_mov & ",tasa_mov = " & tasa_mov & ",nro_mov = " & nro_mov & ",nro_mov_tipo = " & nro_mov_tipo & ",nro_mov_recurso_tipo = " & nro_mov_recurso_tipo & ",fe_mov = '" & fe_mov & "',descripcion = '" & descripcion & "',estado_mov = '" & estado_mov & "',fe_estado_mov = '" & fe_estado_mov & "' WHERE id_mov =" & id_mov,, "BD_IBS_ANEXA")
                    End If
                Next
            End If

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del estado"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.contents("entidades_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>nrodoc as id,razon_social as campo</campos><orden></orden><filtro><razon_social type='like'>%BANCO%</razon_social></filtro></select></criterio>")
    Me.contents("mov_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_cab' cn='BD_IBS_ANEXA'><campos>id_mov as id,descripcion as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_cab_all") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_cab' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_tipos' cn='BD_IBS_ANEXA'><campos>nro_mov_tipo as id,mov_tipo as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_estados") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_estados' cn='BD_IBS_ANEXA'><campos>estado_mov as id,estado_desc_mov as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_recursos_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_recursos_tipos' cn='BD_IBS_ANEXA'><campos>nro_mov_recurso_tipo as id,mov_recurso_tipo as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("entidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("dateToDay") = DateTime.Now.ToString("dd/MM/yyyy")
    Me.contents("accion") = nvUtiles.obtenerValor("accion", "")
    Me.contents("id_mov") = nvUtiles.obtenerValor("id_mov", "")
    Me.contents("parentWin") = nvUtiles.obtenerValor("parentWin", "")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Editar Estado</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit() %>


    <script type="text/javascript">

        var accion = 0

        var paiscod
        var bcocod
        var tipodoc
        var nrodoc
        var tipocli

        var paiscodOr
        var bcocodOr
        var tipodocOr
        var nrodocOr
        var tipocliOr

        var paiscodDes
        var bcocodDes
        var tipodocDes
        var nrodocDes
        var tipocliDes

        var id_mov
        var n = 0
        var win = nvFW.getMyWindow()

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return guardarMovCred()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("guardar", "/fw/image/icons/guardar.png")

        var nr

        function window_onload() {
            vListButton.MostrarListButton()
            window_onresize()

            accion = nvFW.pageContents.accion

            if (accion == 1) {
                editar_movimiento(nvFW.pageContents.id_mov)
                id_mov = nvFW.pageContents.id_mov
            }


        }

        function editar_movimiento(id_mov) {

            var rs1 = new tRS();
            rs1.open({
                filtroXML: nvFW.pageContents.mov_cab_all,
                filtroWhere: "<criterio><select><filtro><id_mov type='igual'>" + id_mov +"</id_mov></filtro></select></criterio>"
            })

            paiscodOr = rs1.getdata('paiscod_origen')
            bcocodOr = rs1.getdata('bcocod_origen')
            tipodocOr = rs1.getdata('tipdoc_origen')
            nrodocOr = rs1.getdata('nrodoc_origen')

            paiscodDes = rs1.getdata('paiscod_destino')
            bcocodDes = rs1.getdata('bcocod_destino')
            tipodocDes = rs1.getdata('tipdoc_destino')
            nrodocDes = rs1.getdata('nrodoc_destino')

            var date1 = !rs1.getdata('fe_mov') ? 0 : rs1.getdata('fe_mov').substr(8, 2) + "/" + rs1.getdata('fe_mov').substr(5, 2) + "/" + rs1.getdata('fe_mov').substr(0, 4)
            var date2 = !rs1.getdata('fe_estado_mov') ? 0 : rs1.getdata('fe_estado_mov').substr(8, 2) + "/" + rs1.getdata('fe_estado_mov').substr(5, 2) + "/" + rs1.getdata('fe_estado_mov').substr(0, 4)

            $('desc').value = rs1.getdata('descripcion')
            $('fecha_venta').value = !rs1.getdata('fe_mov') ? '' : date1 //rs1.getdata('fe_mov').substr(0, 10)
            $('fecha_estado').value = !rs1.getdata('fe_estado_mov') ? '' : date2 //rs1.getdata('fe_estado_mov').substr(0, 10)
            $('monto').value = !rs1.getdata('monto_mov') ? 0 : rs1.getdata('monto_mov')
            $('tasa').value = !rs1.getdata('tasa_mov') ? 0 : rs1.getdata('tasa_mov')
            campos_defs.set_value('inOrigen', rs1.getdata('nrodoc_origen'))
            campos_defs.set_value('inDest', rs1.getdata('nrodoc_destino')) 
            campos_defs.set_value('mov_estados', rs1.getdata('estado_mov')) 
            campos_defs.set_value('mov_tipos', rs1.getdata('nro_mov_tipo')) 
            campos_defs.set_value('mov_recursos_tipos', rs1.getdata('nro_mov_recurso_tipo')) 


            //var rs2 = new tRS();
            //rs2.open({
            //    filtroXML: nvFW.pageContents.entidades,
            //    filtroWhere: "<criterio><select><filtro><paiscod type='igual'>" + paiscodOr + "</paiscod><bcocod type='igual'>" + bcocodOr + "</bcocod><tipdoc type='igual'>" + tipodocOr + "</tipdoc><nrodoc type='igual'>" + nrodocOr + "</nrodoc></filtro></select></criterio>"
            //})

            //$('orPlus').setStyle({ display: 'none' })
            //$('inOrigen').setStyle({ display: 'block' })



            //var rs3 = new tRS();
            //rs3.open({
            //    filtroXML: nvFW.pageContents.entidades,
            //    filtroWhere: "<criterio><select><filtro><paiscod type='igual'>" + paiscodDes + "</paiscod><bcocod type='igual'>" + bcocodDes + "</bcocod><tipdoc type='igual'>" + tipodocDes + "</tipdoc><nrodoc type='igual'>" + nrodocDes + "</nrodoc></filtro></select></criterio>"
            //})

            //$('desPlus').setStyle({ display: 'none' })
            //$('inDest').setStyle({ display: 'block' })

        } 

        function window_onresize() {

            var heiVal = document.body.getBoundingClientRect().height - $('destino').getBoundingClientRect().height - $('destino').getBoundingClientRect().top
            var topVal = $('tablaCont').getBoundingClientRect().height - $('destino').getBoundingClientRect().height - $('destino').getBoundingClientRect().top
            var leftVal = $('destino').getBoundingClientRect().left

            var topValOr = $('tablaCont').getBoundingClientRect().height - $('origen').getBoundingClientRect().height - $('origen').getBoundingClientRect().top
            var leftValOr = $('origen').getBoundingClientRect().left

            var widthVal = $('destino').getBoundingClientRect().width
            var widthValOr = $('origen').getBoundingClientRect().width

            $('listaEntDes').setStyle({ top: '-' + topVal + 'px', left: leftVal + 1 + 'px', width: widthVal - 2 + 'px', height: heiVal - 30 + 'px' })
            $('listaEntOr').setStyle({ top: '-' + topValOr + 'px', left: leftValOr - 1 + 'px', width: widthValOr - 2 + 'px', height: heiVal - 30 + 'px' })
        }

        function verEntidades(n) {
            var strCriterio = nvFW.pageContents.entidades
            var rs = new tRS();

            if (n == 1) {
                nr = 1
                rs.open({
                    filtroXML: strCriterio,
                    filtroWhere: "<criterio><select><filtro><nrodoc type='igual'>" + $('inOrigen').value + "</nrodoc></filtro></select></criterio>"
                })
            } else {
                nr = 0
                rs.open({
                    filtroXML: strCriterio,
                    filtroWhere: "<criterio><select><filtro><nrodoc type='igual'>" + $('inDest').value + "</nrodoc></filtro></select></criterio>"
                })
            }

            var paiscod1 = rs.getdata('paiscod')
            var bcocod1 = rs.getdata('bcocod')
            var tipodoc1 = rs.getdata('tipdoc')
            var nrodoc1 = rs.getdata('nrodoc')
            var tipocli1 = rs.getdata('tipcli')

            set_value(paiscod1, bcocod1, tipodoc1, nrodoc1, tipocli1)
            
            //if (n == 1) {
            //    nr = 1
            //    $('inOrigen').setStyle({ display: 'block' })
            //    $('orPlus').setStyle({ display: 'none' })
            //} else {
            //    nr = 0
            //    $('inDest').setStyle({ display: 'block' })
            //    $('desPlus').setStyle({ display: 'none' })
            //}

            //var strCriterio = nvFW.pageContents.entidades
            //var rs = new tRS();
            //rs.open({
            //    filtroXML: strCriterio,
            //    filtroWhere: "<criterio><select><filtro><razon_social type='like'>%BANCO%</razon_social></filtro></select></criterio>"
            //})

            //var strHTML = '<table class="tb1  highlightOdd highlightTROver layout_fixed highlightOdd highlightTROver layout_fixed" style="width:100%; maxi-width:800px;">'
            //while (!rs.eof()) {
            //    var paiscod = rs.getdata('paiscod')
            //    var bcocod = rs.getdata('bcocod')
            //    var tipodoc = rs.getdata('tipodoc')
            //    var nrodoc = rs.getdata('nrodoc')
            //    var tipocli = rs.getdata('tipocli')
            //    var razSocial = rs.getdata('razon_social')
            //    var funcOn = 'set_value("' + n + razSocial + '", ' + paiscod + ', ' + bcocod + ', ' + tipodoc + ', ' + nrodoc + ', ' + tipocli + ')'
            //    strHTML += "<tr><td onclick='" + funcOn + "'>" + razSocial + '(' + nrodoc + ')</td></tr>'
            //    rs.movenext()
            //}
            //strHTML += '</table>'

            //if (n == 1) {
            //    $('listaEntOr').setStyle({ display: 'inline-block' })
            //    $('listaEntDes').setStyle({ display: 'none' })

            //    $('listaEntOr').insert({
            //        top: strHTML
            //    })

            //} else {
            //    $('listaEntDes').setStyle({ display: 'inline-block' })
            //    $('listaEntOr').setStyle({ display: 'none' })

            //    $('listaEntDes').insert({
            //        top: strHTML
            //    })

            //}
        }

        function set_value(paiscod1, bcocod1, tipodoc1, nrodoc1, tipocli1) {

            paiscod = paiscod1
            bcocod = bcocod1
            tipodoc = tipodoc1
            nrodoc = nrodoc1
            tipocli = tipocli1

            if (nr == 1) {
                paiscodOr = paiscod1
                bcocodOr = bcocod1
                tipodocOr = tipodoc1
                nrodocOr = nrodoc1
                tipocliOr = tipocli1

            } else {
                paiscodDes = paiscod1
                bcocodDes = bcocod1
                tipodocDes = tipodoc1
                nrodocDes = nrodoc1
                tipocliDes = tipocli1

            }

            //if (nr == 1) {
            //    $('inOrigen').value = razSocial + '(' + nrodoc + ')'
            //    $('listaEntDes').setStyle({ display: 'none' })
            //} else {
            //    $('inDest').value = razSocial + '(' + nrodoc + ')'
            //    $('listaEntOr').setStyle({ display: 'none' })
            //}

        }

        //function listHid(n) {
        //    if (n == 1) {
        //        $('listaEntDes').setStyle({ display: 'none' })
        //    } else {
        //        $('listaEntOr').setStyle({ display: 'none' })
        //    }
        //}

        function guardarMovCred() {

            validar_mov()

            if (n == 1) {
                return
            } else {
                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><mov_cab>"
                xmldato += "<movs_cab paiscod_origen='" + paiscodOr + "' bcocod_origen='" + bcocodOr + "' tipodoc_origen='" + tipodocOr + "' nrodoc_origen='" + nrodocOr + "'"
                xmldato += " paiscod_destino='" + paiscodDes + "' bcocod_destino='" + bcocodDes + "' tipodoc_destino='" + tipodocDes + "' nrodoc_destino='" + nrodocDes + "'"
                xmldato += " monto_mov='" + $('monto').value.replace(/,/g, '.') + "'"
                xmldato += " tasa_mov='" + $('tasa').value + "'"
                xmldato += " nro_mov='" + $('tasa').value + "'"
                xmldato += " nro_mov_tipo='" + $('mov_tipos').value + "'"
                xmldato += " nro_mov_recurso_tipo='" + $('mov_recursos_tipos').value + "'"
                xmldato += " fe_mov='" + $('fecha_venta').value + "'"
                xmldato += " descripcion='" + $('desc').value + "'"
                xmldato += " accion='" + accion + "'"
                if (accion == 1)
                    xmldato += " id_mov='" + id_mov + "'"
                xmldato += " estado_mov='" + $('mov_estados').value + "'"
                xmldato += " fe_estado_mov='" + $('fecha_estado').value + "' >"
                xmldato += "</movs_cab></mov_cab>"

                nvFW.error_ajax_request('mov_cred_ABM.aspx', {
                    parameters: { xmldato: xmldato },
                    onSuccess: function (err, transport) {
                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                        //parent.listaMovCred()
                        win.close()
                        nvFW.pageContents.parentWin.listaMovCred()
                    },
                })
            }


        }

        function validar_mov() {
            if ($('inOrigen').value == '') {
                alert('<b>Ingrese un origen</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return 
            }

            if ($('inDest').value == '') {
                alert('<b>Ingrese un destino</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return 
            }

            if ($('mov_recursos_tipos').value == '') {
                alert('<b>Ingrese tipo de venta</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return
            }

            if ($('mov_tipos').value == '') {
                alert('<b>Ingrese tipo de movimiento</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return 
            }

            if ($('fecha_venta').value > nvFW.pageContents.dateToDay) {
                alert('<b>La fecha no puede ser superior a la de hoy</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return 
            }

            if ($('fecha_venta').value == '') {
                alert('<b>Ingrese la fecha de venta</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return
            }

            if ($('tasa').value == 0) {
                alert('<b>Ingrese la tasa</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return
            }

            if ($('monto').value == 0) {
                alert('<b>Ingrese el monto</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return
            }

            if ($('desc').value == 0) {
                alert('<b>Ingrese la descripción</b>', {
                    width: 325,
                    className: "alphacube",
                })
                n = 1
                return
            }

        }

        function setTwoNumberDecimalT(event) {
            $('tasa').value = parseFloat($('tasa').value).toFixed(3);
            $('tasa').value.replace(/,/g, '.')
        }

        function setTwoNumberDecimalM(event) {
            $('monto').value = parseFloat($('monto').value).toFixed(2);
            $('monto').value.replace(/,/g, '.')
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
<table style="width:100%" class="tb1">
    <tr class="tbLabel">
        <td style="width: 50%; text-align:center">Origen</td>
        <td style="width: 50%; text-align:center">Destino</td>
    </tr>
    <tr>
                    <td id="origen" style="text-align:center" >
<%--                        <img id="orPlus" src="/fw/image/icons/agregar.png" style="cursor: pointer" onclick="verEntidades(1)" /><input id="inOrigen" onclick="verEntidades(1)" style="width: 100%; display:none" type="text" />--%>
                        <script type="text/javascript">
                            campos_defs.add('inOrigen', {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.entidades_def
                            })
                            campos_defs.items['inOrigen'].onchange = function (campo_def) {
                                verEntidades(1)
                            }
                        </script>
                    </td>
                    <td id="destino" style="text-align:center" >
<%--                        <img id="desPlus" src="/fw/image/icons/agregar.png" style="cursor: pointer" onclick="verEntidades()" /><input id="inDest" onclick="verEntidades(0)" style="width: 100%; display:none" type="text" />--%>
                        <script type="text/javascript">
                            campos_defs.add('inDest', {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.entidades_def
                            })
                            campos_defs.items['inDest'].onchange = function (campo_def) {
                                verEntidades(0)
                            }
                        </script>
    </tr>
</table>
<table id="tablaCont" style="width:100%" class="tb1">
    <tr>
        <td style="width:65%">
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center" >Tipo recurso</td>
                    <td style="text-align:center">Tipo movimiento</td>                    
                    <td style="text-align:center">Fecha movimiento</td>
                </tr>
                <tr>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('mov_recursos_tipos', {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.mov_recursos_tipos
                            })
                        </script>
                    </td>                 
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('mov_tipos', {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.mov_tipos
                            })
                        </script>
                    </td>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('fecha_venta', { enDB: false, nro_campo_tipo: 103 })
                        </script>
                    </td>
                </tr>
                <tr class="tbLabel">
                    <td colspan=3 style="text-align:center">Descripción</td>
                </tr>
                <tr>
                    <td colspan=3 ><input id="desc" style="width: 100%" type="text" /></td>
                </tr>
            </table>
        </td>
        <td style="width:35%">
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="width:50%;text-align:center">Tasa</td>
                    <td style="width:50%;text-align:center">Monto movimiento</td>
                </tr>
                <tr>
                    <td style="width:100%;display:flex">
                        <input style="text-align:right" id="tasa" onchange="setTwoNumberDecimalT()" type="number" />
<%--                        <script type="text/javascript">
                            campos_defs.add('tasa', { enDB: false, nro_campo_tipo: 102 })
                            $('tasa').value = 0
                            $('tasa').setStyle({ width: '97%' })
                            campos_defs.items['tasa'].onchange = function (campo_def) {
                                setTwoNumberDecimalT()
                            }
                        </script>--%>%
                    </td>
                    <td >
                        <input id="monto" style="text-align:right" type="number" onchange="setTwoNumberDecimalM()" />
<%--                        <script type="text/javascript">
                            campos_defs.add('monto', { enDB: false, nro_campo_tipo: 102 })
                            $('monto').value = 0
                            //$('monto').setStyle({ width: '95%', 'float-right' })
                        </script>--%>
                    </td>
                </tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td colspan=3 style="width: 65%; text-align:center">Estado</td>
                    <td colspan=3 style="width: 35%; text-align:center">Fecha estado</td>
                </tr>
                <tr>                
                    <td colspan=3 >
                        <script type="text/javascript">
                            campos_defs.add('mov_estados', {
                                filtroXML: nvFW.pageContents.mov_estados,
                                enDB: false,
                                nro_campo_tipo: 1   
                            })
                        </script>
                    </td>
                    <td >
                        <input id="fecha_estado" onclick="verEntidades(1)" style="width: 100%" type="text" disabled/>
                        <script type="text/javascript">
                            $('fecha_estado').value = nvFW.pageContents.dateToDay
                        </script>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<table style="width:100%" class="tb1">
    <tr>
        <td style="margin:auto" ><div style="width:40%; margin:auto" id="divGuardar"></div></td>
    </tr>
</table>
<div id="listaEntDes" onclick="listHid(1)" style="position: relative; max-height:500px; overflow:auto; top:initial; display:none"></div>
<div id="listaEntOr" onclick="listHid()" style="position: relative; max-height:500px; overflow:auto; top:initial; display:none"></div>
</body>
</html>
