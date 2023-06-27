<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim detalle As String = ""
    Try

        Dim camposIBS As String = "tipocli, tiporel, tipdoc, tipdoc_desc, nrodoc, CUIT_CUIL, DNI, cliape, clinom, clideno, " +
"convert(varchar(20),fecnac_insc,103) as fecnac_insc, clisexo, cartel, numtel, razon_social, tipreldesc, domnom, domnro, dompiso, domdepto, codpos, loccoddesc, codprovdesc, " +
"email, clconddgi, descestciv, tipsocdesc, tipoempdesc, policaexpuesto, sectorfindesc, profdesc, impgandesc, perconnom, clasidesc, desctipcar "
        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select " + camposIBS + " from VOII_entidades where nrodoc in (819,20076085936,20108252236,20233723496,30650254755,568,20114598730,23236691349,27180395038,186,20265927719,23075210299,27941008343,20234049837,585,20148480622,23243038979,23249920339,30660281386,30707594140,30710410077,437,20123516150,20131873213,30715054619,20076653594,27244597195,20258054807,23825554819,27293189671,20149777920,781,20224569581,23041964529,636,11111111111,20129753235,20175761927,30708594802,664,770,20218517316,23076751579,30688992008,20173320974,20220992900,653,20173591196,33711915759,681,787,20221103018,20228476928,20253765322,123,20204062146,27203120171,27301433927,27317828662,670,20131695714,20134179407,20141563506,20161461017,20285088489,27263436240,832,20127088935,20164903436,23312586649,687,27138553138,715,20261341515,20308341721,23135264539,598,20175351931,27937094383,20059889479,20258036280,30707247408,30712137793,20286941029,615,20145851530,20224198478,20242325622,20244967672,20276883527,23117031489,27309979864,20169485799,20172866272,27118747726,27231751721,27281584524,30699998008,20084144380,20272881554,20283620531,23204203644,738,20169101540,20279496761,20161315657,20232767007,515,1006,20044370825,20925832872,27118379123,27200279196,30678706228,20107436600,20311448642,469,20166731535,20235677122,20284904584,23228571474,27148098730,20045444865,20137612411,20214916712,23335105109,244,20134959372,27307115668,27206205569,27226200016,27251274512,20184366755,20224706805,20244487816,20250961902,20291903720,700,20049835753,20235108195,27173645924,30709979686,834,1029,20127728594,23162468979,27127298713,583,20111201197,27160178693,422,717,20045368816,20168916400,20171430586,20178096940,27185153822,20116525764,20358624228,20298342538,23127203059,27188463512,734,20113339714,20133050222,20147042877,20215884822,20344364134,20297800166,23227810394,319,20262010075,27238195654,20206105659,20257453708,20270321705,20061512102,20254314561,20294587749,27302779312,20045940803,20204104876,20287119292,23180187154,27307083626,30593174057,768,20177076199,20221262108,20232737817,27263537500,517,20119866996,20170033532,20294492535,27222509152,20242545029,20270268251,27163622691,27249219504,106,27123657360,27163226753,23165434919,562,668,20043058461,20202981314,20217557322,23166262089,62,20101237673,20129986388,20218329951,20377337744,23131801114,685,2017084487,27119858300,27183040184,23083878819,20140201554,20145295190,20160620340,20249096114,20950458950,23304773804,27284010103,20145877742,20177268497,20183623487,20184146089,20239872019,20285075580,20316603417,27167933667,27176866190,27321877120,27340567612,30701280802,24332957496,20060353930,20112042890,20118992602,1028,775,20136579933,23181786019,27116924434,524,20063008770,20184146968,27140332432,20260962184,23224105134,23238332419,2724047007,20118367066,20219193158,23106629064,30685227440,20055302651,20168294884,20308626971,27219053555,809,20213576659,20043134656,20114598888,20240174635,30707969659,586,20121241111,23204785139,23307435624,27941243954,27173252590,10000,20173637188,20252887653,27128406528,27188554941,27234730784,20133668242,20216132506,20121376769,20261205751,20124532117,20179469007,20214399343,20233089096,20295912376,27179105166,20109299686,20236263666,20314388926,27131735664,20284634188,20287302151,637,743,20110767626,20125301453,20167117504,30710859376,20076054305,23236700909,20229556879,20233550206,654,27132772008,20043992407,27185293268,671,20132960144,20308154190,30679921912,466,20174756970,20223023186,20280307077,20359924748,27129529364,20228261182,20250151994,20254330990,27178334447,688,794,20237314914,20284213794,20304357976,23079617989,23357298814,20225889695,27258633372,571,20082363530,20255461185,20257881475,20289194038,20295204681,30657515503,20261653959,27947195110,30715403435,588,20161441881,20179998433,30576721710,20118204043,20209461170,20254311279,27251089707,30704978878,711,27254661150,845,20239914986,20041951606,20255180860,20126046805,27342867486,30500017704,756,20181604825,27122774010,20340981155,20355514898,745,20147437626,23244967672,27149518474,20044152348,20140264920,20219472472,20235722535,628,20103998116,20233173283,20282339251,20110223375,20112667602,20172331883,30710384564,20084623246,20234681126,20249247538,20272021059,23297760114,20202507973,27172544520,27294800986,673,779,20045328589,20207348954,20218514252,20323576808,27315307118,27322188523,30581096743,20149128795,20177822907,20241710050,20289907360,20312271126,690,796,20119870502,23247026959,27180700507,824,25670202,20103299633,20133052861,27165501190,707,20119878986,20127130796,20220332048,23344349339,20231267531,20253177609,23281671499,30678158506,158,590,20250395087,27166481851,724,27064107769,27268739845,23202885209,20211520087,20302557781,23182628379,27063741294,30545819089,20137542634,23928504964,27134167608,27135308892,769,1111,20076817597,25271811390,518,20147618132,27202347938,20073772401,20177617211,20219305711,20243780269,20320513961,20348278216,680,15287582,20167651764,20129461080,23146189644,27037356781,27267350901,27304957609,20085081013,20122856128,20223831053,27921868990,20174243811,27259968416,220128820893,20238800286,686,20304261006,23165879619,23231144854,27180432944,30714094226,20060464171,20164922392,27124852205,20217102260,20165159145,20171086575,429,27062784372,27236853395,11112,20122769438,20124916373,27205429803,27341500821,720,20045384749,20118758324,20214751136,20225506419,20244966226,24346303790,27274642322,200840690363,20178670183,20239656731,631,737,20255672933,20313935818,30714202789,20140562700,20149980548,20172876553,514,20223669124,27163351868,754,20122483593,20187807795,27054651134,20182721140,20244981357,30677240047,1022,20145268746,20181740478,20180234862,27224934713,121,20143915302,30649280726,20122856357,20140150623,27143397675,682,20164304680,20315769311,20077963392,20137594250,20249571211,20284677359,27228353677,27299867698,20116246156,20229752937,20326382524,20140125416,27264356054,27343744949,20137476410,20220229484,20174364150,20178811666,20084411664,20114476227,20133991345,20166261369,20248231891,27232507727,30714629316,20105578106,27238651854,616,20954222781,23214235854,20137822629,20168345311,20176486865,20227504537,20242706731,20248735377,20386858676,1018,20164960448,20217102198,232430334779,20149074652,20258037732,27233729693,1007,20127285943,23239870414,27211419453,27348136076,20224325437,784,667,20163351464,20164283691,20209762472,27210936276,108,907,111111111,20112107933,20136239466,20284712952,23084102059,27304489672,2016948579,20182677966,20280579131,578,23051201914,567,20172362282,20113627434,20169751154,23184909189,23260444999,27168800385,20226214012,23235336529,27223294982,20307436192,23325554819,27247281113,612,20043089952,852,20208423321,20252968041,27292319180,601,2005206141,20128820893,23238042194,23242560299,27289626374,30714972630,629,20322618213,27127271998,1099,72854,20240617693,20246623733,27174115015,27284967653,20140989623,20148202282,20283141232,20379964037,23147605439,20232283573,20288948977,20298341523,23242149114,808,20110617381,20302190586,20041604000,20184020905,20238877114,30538006404,111,20102491867,20138393748,20142227275,27132305299,27228474970,33708285809,154,1106,23121050099,1,20118151047,20129320665,20147010487,20306122164,27044733752,20062429764,20165212712,27169768620,373,20275447707,20162079345,20217234965,20164876072,20179329353,20354004004,27046681318,27242713880,27255980012,20129453282,20138011756,20174235776,23161052779,23271197934,982,20102786182,20165697430,23206918489,270,20353227182,27128523818,20171727554,20341461910,27254802323,20252489410,30710911580,52,642,776,20109669440,20149980173,20173678186,20201962243,20235722861,23202263844,20049540503,20256700221,659,20119855153,20132112259,20141262603,20149271148,20226062972,20233723186,20293873659,23229908499,107,20119874263,27276221618,20146180877,23082656669,23235703459,20262814042,20258956088,20276741102,20221515979,23326412589,27385338207,30716046555,693,30646367790,20078695464,20226751182,20117847587,20132455512,20244295917,27205372348,27181421067,20170844875,23122381099,20116777003,20204859044,23177372889,23186402359,508,11111,20062644436,20105087897,23120838539,27039590013,27241559683,1061,20148731072,20228656470,30605659981,27264736345,20133805614,20228260194,20345361538,27051345873,27065532331,27237804630,30500781293,655,20205737368,20601908574,23250208014,27136158231,20119117756,20251579335,27277701230,145,10115,20239682961,27064393869,672,20100853125,20203553286,20214384974,20101106536,27293138333,30500005625,795,20222519838,27229627665,33693710559,20049628391,20105253460,30678562846,572,20228246973,27100286179,27223632632,27138076658,695,20101389244,27245994651,723,20115941667,20233766357,20245032189,23243652219,20042981339,20043045394,20147182075,20173825839,20219228903,20265363602,23085284649,162,712,20077849204,20078385589,20119961158,740,846,20050692451,20118894856,30711425728,30715832816,20115065700,20083899876,20237383452,27296556985,20175416081,23279407809,30672418735,640,20271135255,774,27238781839,20234731204,20254000737,20271876840,23178999494,23222296064,27252843952,120,20044231590,20126761377,20165595875,20062509156,20145101000) ", cod_cn:="BD_IBS_ANEXA")
        Dim rsGuardar As ADODB.Recordset
        While rs.EOF = False

            Dim razon_social As String = ""
            detalle = ""

            'consultar que no exista en la tabla de compatibilidad
            Dim rsComp As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select nro_entidad,tipdoc,nrodoc from verEntidades_compatibilidad_ibs where tipdoc = " & rs.Fields("tipdoc").Value & " and nrodoc = " & rs.Fields("nrodoc").Value)
            If rsComp.EOF = True Then

                detalle = "(" & rs.Fields("CUIT_CUIL").Value.ToString & ") " & rs.Fields("razon_social").Value.ToString

                Dim rsNomenclado As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select cod_interno, cod_externo from nv_codigos_externos where sistema_externo='ibs' and elemento='documento' and cod_externo='" & rs.Fields("tipdoc").Value & "'")
                If rsNomenclado.EOF = True Then

                End If

                Dim tipdoc As String = rsNomenclado.Fields("cod_interno").Value.ToString
                nvFW.nvDBUtiles.DBCloseRecordset(rsNomenclado)

                razon_social = "<![CDATA[" & rs.Fields("razon_social").Value.ToString & "]]>"
                Dim abreviacion As String = "<![CDATA[" & rs.Fields("razon_social").Value.ToString & "]]>"
                Dim apellido As String = "<![CDATA[" & rs.Fields("cliape").Value.ToString & "]]>"
                Dim nombres As String = "<![CDATA[" & rs.Fields("clinom").Value.ToString & "]]>"


                Dim _alias As String = IIf(IsDBNull(rs.Fields("clideno").Value) = False, "<![CDATA[" & rs.Fields("clideno").Value.ToString & "]]>", "")
                Dim calle As String = "<![CDATA[" & rs.Fields("domnom").Value.ToString & "]]>"
                Dim email As String = "<![CDATA[" & rs.Fields("email").Value.ToString & "]]>"
                Dim esPersona_fisica As Boolean = IIf(rs.Fields("tipocli").Value = "1", True, False)

                Dim xmldato As String = "<?xml version=""1.0"" encoding=""ISO-8859-1""?>"
                xmldato += "<pago_entidad modo='AC' nro_entidad='' "
                If rs.Fields("cartel").Value.ToString <> "" Then
                    xmldato += "postal_telefono='" & IIf(IsDBNull(rs.Fields("cartel").Value) = True, rs.Fields("cartel").Value.ToString, "") & "' "
                End If

                If IsDBNull(rs.Fields("numtel").Value) = False Then
                    xmldato += "telefono='" & IIf(IsDBNull(rs.Fields("numtel").Value) = True, rs.Fields("numtel").Value.ToString, "") & "' "
                End If

                xmldato += "cuit='" & rs.Fields("CUIT_CUIL").Value.ToString & "' "
                xmldato += "cuitcuil='" & IIf(IsDBNull(esPersona_fisica) = True, "CUIL", "CUIT") & "' "
                xmldato += "numero='" & rs.Fields("domnro").Value.ToString & "' nro_contacto_tipo='1' resto='' "
                If IsDBNull(rs.Fields("dompiso").Value) = False Then
                    xmldato += "piso='" & rs.Fields("dompiso").Value.ToString & "' "
                    If IsDBNull(rs.Fields("domdepto").Value) = False Then
                        xmldato += "depto='" & rs.Fields("domdepto").Value.ToString & "' "
                    End If

                End If

                If (rs.Fields("policaexpuesto").Value = 1) Then
                    xmldato += "pep='1' "
                Else
                    xmldato += "pep='0' "
                End If

                Dim fecnac_insc As String = IIf(IsDBNull(rs.Fields("fecnac_insc").Value) = True, "", rs.Fields("fecnac_insc").Value)

                If esPersona_fisica Then
                    xmldato += "nro_docu='" & rs.Fields("nrodoc").Value.ToString & "' tipo_docu='" & tipdoc & "' sexo='" & rs.Fields("clisexo").Value.ToString & "' persona_fisica='1' "
                    xmldato += "dni='" & rs.Fields("DNI").Value.ToString & "' nro_emp_tipo='' nro_soc_tipo='' "
                    xmldato += "fecha_nacimiento='" & fecnac_insc.ToString & "' fecha_inscripcion='' "
                Else
                    xmldato += "nro_docu='" & rs.Fields("nrodoc").Value.ToString & "' tipo_docu='" & tipdoc.ToString & "' sexo='' persona_fisica='0' "
                    xmldato += "dni='' nro_emp_tipo='' nro_soc_tipo='' "
                    xmldato += "fecha_nacimiento='' fecha_inscripcion='" & fecnac_insc.ToString & "' estado_civil='' nro_nacion='' "
                End If

                xmldato += ">"

                If esPersona_fisica = True Then
                    xmldato += "<apellido>" & apellido & "</apellido>"
                    xmldato += "<nombres>" & nombres & "</nombres>"
                Else
                    xmldato += "<apellido></apellido>"
                    xmldato += "<nombres></nombres>"
                End If

                xmldato += "<razon_social>" & razon_social & "</razon_social>"
                xmldato += "<abreviacion>" & abreviacion & "</abreviacion>"
                xmldato += "<alias>" & _alias & "</alias>"
                xmldato += "<calle>" & calle & "</calle>"
                xmldato += "<email>" & email & "</email>"
                xmldato += "</pago_entidad>"

                'nvServer.Events.RaiseEvent("entidad_onSave", "", xmldato)

                ' Dim Err As New nvFW.tError()

                Try
                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nv_entidad_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
                    cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmldato.Length, xmldato)

                    rsGuardar = cmd.Execute()
                    Response.Write("<p>" & detalle & ". Mensaje: " & If(rsGuardar.Fields("mensaje").Value = "", "OK", rsGuardar.Fields("mensaje").Value) & "</p></br>" & vbCrLf)
                    Response.Flush()

                    '**** INSERT en DBANEXA ****
                    If (rsGuardar.Fields("numError").Value = 0) Then
                        nvServer.Events.RaiseEvent("entidad_onSave", rsGuardar.Fields("nro_entidad").Value, xmldato)
                    End If

                    nvFW.nvDBUtiles.DBCloseRecordset(rsGuardar)
                    '  Dim nro_entidad As String = rs.Fields("nro_entidad").Value
                    'Err.numError = rs.Fields("numError").Value
                    'Err.titulo = rs.Fields("titulo").Value
                    'Err.mensaje = rs.Fields("mensaje").Value
                    'Err.params.Add("nro_entidad", nro_entidad)

                    ' If rs.Fields("numError").Value <> 0 Then
                    '  Dim msgEvent As String = "Error de inserción en Nova - Mensaje: " & rs.Fields("mensaje").Value

                    ' nvFW.nvLog.addEvent("IBS_entidad_save_error", msgEvent)
                    'Else
                    '  Dim msgEvent As String = "Inserción correcta en Nova - Nro. Entidad: " & rs.Fields("nro_entidad").Value

                    ' nvFW.nvLog.addEvent("IBS_entidad_save", msgEvent)
                    ' End If

                Catch ex As Exception
                    Response.Write("<p style='color:red'>Error: " & detalle & " Mensaje por caso: " & ex.Message.ToString & "</p></br>" & vbCrLf)
                    Response.Flush()
                    ' Dim msgEvent As String = "Error de inserción en Nova"
                    '  nvFW.nvLog.addEvent("IBS_entidad_save_error", msgEvent)
                End Try

            End If

            rs.MoveNext()
        End While

        Dim strSQL As String = "select e.nro_entidad,leg.nro_archivo_id_tipo,d.nro_def_detalle,[fecha presentacion] as fe_alta from tmp_ar_legajos l" & vbCrLf
        strSQL += "join [tmp_ar_cab] tc on tc.codigo = l.codigo" & vbCrLf
        strSQL += "join tmp_ar_det td on td.codigo = l.documento " & vbCrLf
        strSQL += "join archivos_def_cab c on c.def_archivo = tc.descripcion " & vbCrLf
        strSQL += "join verEntidades_compatibilidad_ibs e on e.nrodoc = l.cuit  " & vbCrLf
        strSQL += "join archivo_leg_cab leg on leg.id_tipo = e.nro_entidad and leg.nro_archivo_id_tipo = 2" & vbCrLf
        strSQL += "join archivos_def_detalle d on d.archivo_descripcion = td.documento and c.nro_def_archivo = d.nro_def_archivo " & vbCrLf
        strSQL += "left outer join archivos a on a.nro_def_detalle = d.nro_def_detalle and leg.id_tipo = a.id_tipo and a.nro_archivo_id_tipo = leg.nro_archivo_id_tipo and nro_archivo_estado in (1,3)" & vbCrLf
        strSQL += "where not [fecha presentacion] is null and a.nro_archivo is null"

        Dim rsA As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
        While rsA.EOF = False

            Dim archivo As tnvArchivo
            archivo = New tnvArchivo(id_tipo:=rsA.Fields("nro_entidad").Value, nro_archivo_id_tipo:=rsA.Fields("nro_archivo_id_tipo").Value, nro_def_detalle:=rsA.Fields("nro_def_detalle").Value, isFisical:=True)
            archivo.save()

            rsA.MoveNext()
        End While


    Catch ex As Exception
        Response.Write("<p style='color:red'>Mensaje: " & ex.Message.ToString & "</p></br>" & vbCrLf)
        Response.Flush()
    End Try

%>

