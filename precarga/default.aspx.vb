Imports nvFW
Imports nvFW.nvDBUtiles
Imports nvFW.nvUtiles
Partial Class default_precarga
    Inherits nvFW.nvPages.nvPageMutualPrecarga
    Public modo As String
    Public nro_credito As Integer
    Private Sub default_precarga_Load(sender As Object, e As EventArgs) Handles Me.Load

        modo = nvFW.nvUtiles.obtenerValor("modo", "")
        nro_credito = nvFW.nvUtiles.obtenerValor("nro_credito", 0)

        Me.contents("nro_credito") = nro_credito
        'Me.contents("nro_vendedor") = Me.operador.nro_vendedor
        'Me.contents("strVendedor") = Me.operador.vendedor



        Me.addPermisoGrupo("permisos_precarga")
        'Me.addPermisoGrupo("permisos_web2")

        'Dim a As String = Me.operador.sucursal
        'Me.contents("sucursal") = Me.operador.sucursal  ''nvFW.pageContents.nro_sucursal nvFW.opredaor.

        Me.contents.Add("operador", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='veroperadores'><campos>sucursal_cod_prov, nro_docu, sucursal_provincia, sucursal_postal_real</campos><orden></orden><filtro><operador type='igual'>" & Me.operador.operador & "</operador></filtro></select></criterio>"))
        Me.contents.Add("vendedor", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vervendedores'><campos>nro_vendedor, strNombreCompleto</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
        'Me.contents.Add("trabajo", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBTrabajo_cuad_anexa_v3'><campos>dbo.rm_lote_first_grupo(nro_sistema,nro_lote) as nro_grupo,dbo.rm_lote_first_nombre_grupo(nro_sistema,nro_lote) as grupo, tipo,nro_sistema,sistema,nro_lote,lote,clave_sueldo,nro_docu,nombre,disponible,dbo.conv_fecha_to_str(fecha_actualizacion,'dd/mm') as fecha_actualizacion,id_origen</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
        Me.contents.Add("trabajo", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBTrabajo_cuad_anexa_v4'><campos>dbo.rm_lote_first_grupo(nro_sistema,nro_lote) as nro_grupo,dbo.rm_lote_first_nombre_grupo(nro_sistema,nro_lote) as grupo, tipo,tipo_lote,nro_sistema,sistema,nro_lote,lote,clave_sueldo,nro_docu,nombre,id_origen,Scu_id,Sce_Id</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
        Me.contents.Add("persona", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,sexo,nro_docu,tipo_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad,cod_prov</campos><orden></orden><filtro><cuit type='like'>%cuit%</cuit></filtro></select></criterio>"))
        Me.contents.Add("saldos", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_calc_credito_precarga' CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><nro_calc_tipos>%nro_calc_tipos%</nro_calc_tipos><sexo>%sexo%</sexo></parametros></procedure></criterio>"))
        Me.contents.Add("creditos_cs", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio_v2'  CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo><cuit>%cuit%</cuit><nro_grupo DataType='int'>%nro_grupo%</nro_grupo></parametros></procedure></criterio>"))
        'Me.contents.Add("creditos_cs", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio'  CommantTimeOut='1500' vista='verCreditos'><parametros><cuit>%cuit%</cuit></parametros></procedure></criterio>"))

        Me.contents.Add("creditos_cs_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_socio'  CommantTimeOut='1500' vista='verCreditos'><parametros><nro_docu DataType='int'>%nro_docu%</nro_docu><tipo_docu DataType='int'>%tipo_docu%</tipo_docu><sexo>%sexo%</sexo></parametros></procedure></criterio>"))
        'Me.contents.Add("operatorias", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_auxbanco_mutual_linea_grupo_analisis_v2'  CommantTimeOut='1500' vista='verCreditos'><parametros><cuit>%cuit%</cuit><nro_sistema DataType='int'>%nro_sistema%</nro_sistema><nro_lote DataType='int'>%nro_lote%</nro_lote><nro_grupo DataType='int'>%nro_grupo%</nro_grupo><sitbcra DataType='int'>%sit_bcra%</sitbcra><nro_banco DataType='int'>%nro_banco%</nro_banco><nro_mutual DataType='int'>%nro_mutual%</nro_mutual><salida>%salida%</salida></parametros></procedure></criterio>"))
        Me.contents.Add("operatoria_bancos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAuxBanco_grupo_mutual_cobro_debito'><campos>nro_banco as id, banco as campo,  dbo.rm_banco_sitBCRA_orden(nro_banco, %sit_bcra%) as orden</campos><orden>orden</orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_tipo_cobro type='igual'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco_debito type='igual'>%nro_banco_cobro%</nro_banco_debito><aplica_precarga type='igual'>1</aplica_precarga></filtro><grupo>nro_banco, banco, dbo.rm_banco_sitBCRA_orden(nro_banco, %sit_bcra%)</grupo></select></criterio>"))


        Me.contents.Add("operatoria_bancos_manual", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='banco'><campos>nro_banco as id, banco as campo,  dbo.rm_banco_sitBCRA_orden(nro_banco, %sit_bcra%) as orden</campos><orden>orden</orden><filtro><opera_lausana type='igual'>'S'</opera_lausana><nro_banco type='in'>%nro_bancos%</nro_banco></filtro><grupo></grupo></select></criterio>"))

        Me.contents.Add("operatoria_mutuales", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAuxBanco_grupo_mutual_cobro_debito'><campos>nro_mutual as id, mutual as campo</campos><orden></orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_tipo_cobro type='igual'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco_debito type='igual'>%nro_banco_cobro%</nro_banco_debito><nro_banco type='igual'>%nro_banco%</nro_banco><aplica_precarga type='igual'>1</aplica_precarga></filtro><grupo>nro_mutual,mutual</grupo></select></criterio>"))
        Me.contents.Add("operatoria_mutuales_manual", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='MUTUAL'><campos>nro_mutual as id, mutual as campo</campos><orden>mutual</orden><filtro><opera_lausana type='igual'>'S'</opera_lausana><nro_mutual type='in'>%nro_mutuales%</nro_mutual></filtro><grupo></grupo></select></criterio>"))

        Me.contents.Add("sit_bcra", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='lausana_anexa..nosis_consulta'><campos>dbo.rm_sit_bcra_nosis_v2(id_consulta,0) as situacion</campos><orden></orden><filtro><id_consulta type='igual'>%id_consulta%</id_consulta></filtro></select></criterio>"))
        Me.contents.Add("persona_docu", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,sexo,nro_docu,tipo_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
        Me.contents.Add("grupos_lotes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verGrupos_lotes'><campos>top 1 nro_grupo</campos><orden></orden><filtro><nro_sistema type='igual'>%nro_sistema%</nro_sistema><nro_lote type='igual'>%nro_lote%</nro_lote><nro_grupo type='in'>401,501,127,1,402,502,125,2000,116,53,2,117,8,51,10,18</nro_grupo></filtro></select></criterio>"))
        Me.contents.Add("nosis_cda_def", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNosis_cda_def_v5'><campos>distinct nro_tipo_cobro, tipo_cobro, nro_banco, banco, abreviacion</campos><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo></filtro><orden></orden></select></criterio>"))
        Me.contents.Add("precarga_cda", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_precarga_cda_v12'  CommantTimeOut='1500'><parametros><nro_vendedor DataType='int'>%nro_vendedor%</nro_vendedor><nro_grupo DataType='int'>%nro_grupo%</nro_grupo><nro_tipo_cobro DataType='int'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco DataType='int'>%nro_banco%</nro_banco><cuil>%cuit%</cuil></parametros></procedure></criterio>"))
        Me.contents.Add("mutual_cuota", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='auxMutual_cuota'><campos>top 1 importe_cuota as importe_cuota_social</campos><filtro><nro_mutual type='igual'>%nro_mutual%</nro_mutual><aplica type='igual'>1</aplica><nro_grupo type='sql'>nro_grupo = case when nro_grupo = 0 then 0 else %nro_grupo% end</nro_grupo></filtro><orden></orden></select></criterio>"))
        'Me.contents.Add("planes_lotes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes_v4' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos>datediff(year, convert(datetime,'%fe_naci%',103), dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) as edad_fin, nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,nro_tipo_cobro,gastoscomerc,mes_vencimiento,case when %tiene_seguro%=1 then dbo.piz4D_money('monto_seguro',nro_banco,nro_mutual,nro_grupo,importe_bruto) else 0 end as monto_seguro</campos><orden>nro_plan desc</orden><filtro></filtro><grupo>nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,nro_tipo_cobro,gastoscomerc,mes_vencimiento,nro_banco,nro_mutual,nro_grupo</grupo></select></criterio>"))

        'Me.contents.Add("planes_lotes2", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes'><campos>top 1 nro_plan</campos><orden></orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_mutual type='igual'>%nro_mutual%</nro_mutual><nro_banco type='igual'>%nro_banco%</nro_banco><marca type='igual'>'S'</marca><falta type='menos'>getdate()</falta><fbaja type='sql'>(fbaja > getdate() or fbaja is null)</fbaja><vigente type='igual'>1</vigente><nro_tabla_tipo type='igual'>1</nro_tabla_tipo><importe_neto type='igual'>0</importe_neto><importe_cuota type='igual'>0</importe_cuota><cuotas type='igual'>0</cuotas></filtro></select></criterio>"))
        Me.contents.Add("planes_parametros", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_Parametros'><campos>*</campos><orden></orden><filtro><nro_plan type='igual'>%nro_plan%</nro_plan></filtro></select></criterio>"))
        Me.contents.Add("DBCuit", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBCuit_precarga'><campos>cuit,nombre,fe_naci_str,edad,sexo,nro_docu</campos><orden></orden><filtro><nro_docu type='igual'>%nro_docu%</nro_docu></filtro></select></criterio>"))
        Me.contents.Add("DBCuit2", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBCuit_precarga'><campos>cuit,nombre,fe_naci_str,edad,sexo,nro_docu</campos><orden></orden><filtro><cuit type='igual'>'%cuit%'</cuit></filtro></select></criterio>"))

        Me.contents.Add("DBCuitJMO", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBCuit_precarga'><campos>cuit,nombre,fe_naci_str,edad,sexo,nro_docu</campos><orden></orden><filtro>[<cuit type='igual'>'%cuit%?'</cuit>][<nro_docu type='igual'>%nro_docu?%</nro_docu>]</filtro></select></criterio>"))


        Me.contents.Add("evaluar_persona", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Personas'><campos>dbo.rm_cr_mes(cuit,%nro_vendedor%) as cr_mes,dbo.rm_tiene_cs(cuit) as tiene_cs,dbo.rm_tiene_cr(cuit) as tiene_cr,nro_docu</campos><orden></orden><filtro><cuit type='igual'>'%cuit%'</cuit></filtro></select></criterio>"))
        'Me.contents.Add("BCRA_deudores", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verBCRA_deudores1'><campos>*,convert(varchar,fe_periodo,103) as fecha_periodo</campos><orden></orden><filtro><fe_periodo type='igual'>convert(datetime,'%fecha_periodo%',103)</fe_periodo><nro_identificacion type='igual'>'%nro_identificacion%'</nro_identificacion></filtro></select></criterio>"))
        Me.contents.Add("BCRA_deudores", nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_BCRA_deudores'  CommantTimeOut='1500'><parametros><cuil>%cuil%</cuil><nro_grupo DataType='int'>%nro_grupo%</nro_grupo><nro_tipo_cobro DataType='int'>%nro_tipo_cobro%</nro_tipo_cobro><nro_banco DataType='int'>%nro_banco%</nro_banco></parametros></procedure></criterio>"))
        Me.contents.Add("tipos_rechazos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_grupo_tipos'><campos>nro_com_tipo, com_tipo</campos><orden></orden><filtro><nro_com_grupo type='igual'>17</nro_com_grupo><nro_permiso type='sql'>dbo.rm_tiene_permiso('permisos_com_tipo',nro_permiso) = 1</nro_permiso></filtro></select></criterio>"))
        Me.contents.Add("nosis_cp", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='provincia'><campos>top 1 dbo.rm_nosis_obtener_cp('%cuit%') as cp</campos><orden></orden><filtro></filtro></select></criterio>"))
        Me.contents.Add("provincia", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='provincia'><campos>cod_prov as id , provincia as campo</campos><orden></orden><filtro><nro_nacion type='igual'>1</nro_nacion><estaborrado type='igual'>0</estaborrado></filtro></select></criterio>"))
        Me.contents.Add("grupo_provincia", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='grupo_provincia'><campos>nro_grupo, cod_prov</campos><orden></orden><filtro><nro_grupo type='igual'>%nro_grupo%</nro_grupo><cod_prov type='igual'>%cod_prov%</cod_prov></filtro></select></criterio>"))
        Me.contents.Add("analisis_cargar", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAux_Banco_Mutual_Grupo_Analisis_tabla_v2'><campos>distinct nro_analisis as id, analisis as campo, orden</campos><orden>orden</orden><filtro></filtro></select></criterio>"))
        Me.contents.Add("etiqueta_analisis", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEtiqueta_analisis'><campos>Orden,Nro_Etiqueta,etiqueta,Visible,Calculado,Color,Nro_Analisis,analisis,ultimo,HD,Comentario,css_style,tipo_dato,css_style_input,Calculo,editable,dbo.rm_an_calculobanco(nro_analisis, nro_etiqueta, orden, %nro_banco%) as CalculoBanco</campos><filtro><nro_analisis type='igual'>%nro_analisis%</nro_analisis></filtro><orden>orden</orden></select></criterio>"))
        Me.contents.Add("analisis_valor", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='analisis'><campos>%fun% as value</campos><filtro><nro_analisis type='igual'>%nro_analisis%</nro_analisis></filtro></select></criterio>"))
        Me.contents.Add("cuad_consumos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCUAD_consumos_terceros'><campos>clave,clave_sueldo,documento,cuotas,importe_cuota,saldo_consumo,nro_entidad,Razon_social</campos><orden></orden><filtro><documento type='igual'>%nro_docu%</documento><clave_sueldo type='like'>%clave_sueldo%</clave_sueldo></filtro></select></criterio>"))
        Me.contents.Add("planes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='planes'><campos>*</campos><filtro></filtro></select></criterio>"))
        Me.contents.Add("planes2", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='planes'><campos>dbo.piz5D_money('cuota_credito2',importe_bruto,cuotas,nro_banco,nro_mutual,nro_grupo) as prevision_coseguro</campos><filtro><nro_plan type='igual'>%nro_plan%</nro_plan></filtro></select></criterio>"))
        Me.contents.Add("inaes_black_list", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='lausana_anexa..inaes_black_list'><campos>*</campos><filtro><CUIT type='igual'>%CUIT%</CUIT></filtro></select></criterio>"))

        Me.contents.Add("postergaciones_originante", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos_postergaciones'><campos>distinct nro_credito,estado,importe_cuota,credito_origen</campos><filtro><credito_origen type='igual'>%credito_origen%</credito_origen></filtro></select></criterio>"))
        Me.contents.Add("postergaciones", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos_postergaciones'><campos>distinct nro_credito,estado,importe_cuota,credito_origen</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))
        Me.contents.Add("credito_originante", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>distinct  nro_credito,estado,importe_cuota</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))

        '##################################################
        '----------------------PLANES----------------------
        '##################################################

        Dim filtro_planes_agrupado As String = ""
        filtro_planes_agrupado &= "<importe_neto type='igual'><![CDATA[("
        filtro_planes_agrupado &= "select max(importe_neto) from verPlanes verPlanes2 "
        filtro_planes_agrupado &= "where verPlanes2.nro_tabla = verPlanes1.nro_tabla "
        filtro_planes_agrupado &= "and verPlanes2.nro_grupo = verPlanes1.nro_grupo "
        filtro_planes_agrupado &= "and verPlanes2.cuotas = verPlanes1.cuotas "
        filtro_planes_agrupado &= "and case when '%sexo%' = 'M' and (datediff(year, %fe_naci%, dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) >= edad_min_masc) then  1 "
        filtro_planes_agrupado &= "when '%sexo%' = 'F' and (datediff(year, %fe_naci%, dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) >= edad_min_fem)  then 1 "
        filtro_planes_agrupado &= "else 0 end = 1 "
        filtro_planes_agrupado &= "and case when '%sexo%' = 'M' and (datediff(year, %fe_naci%, dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) <= edad_max_masc) then 1 "
        filtro_planes_agrupado &= "when '%sexo%' = 'F' and (datediff(year, %fe_naci%, dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) <= edad_max_fem) then 1 "
        filtro_planes_agrupado &= "else 0 end = 1 "
        filtro_planes_agrupado &= "[ and importe_neto <= %neto_maximo?%] "
        filtro_planes_agrupado &= "and marca = 'S' "
        filtro_planes_agrupado &= "and importe_cuota <= %importe_cuota_hasta% "
        filtro_planes_agrupado &= "and importe_neto >= %neto_minimo% "
        filtro_planes_agrupado &= "and importe_cuota >= %importe_cuota_desde% "
        filtro_planes_agrupado &= ")]]></importe_neto></filtro></select></criterio>"

        Dim filtro_planes As String = "<criterio><select vista='verPlanes as verPlanes1' PageSize='5' AbsolutePage='1' cacheControl='Session'>"
        filtro_planes &= "<campos>datediff(year, %fe_naci%, dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) as edad_fin,"
        filtro_planes &= " nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,%nro_tipo_cobro%  as nro_tipo_cobro,gastoscomerc,mes_vencimiento"
        filtro_planes &= ",case when %tiene_seguro%=1 then dbo.piz4D_money('monto_seguro',nro_banco,nro_mutual,nro_grupo,importe_bruto) else 0 end as monto_seguro"
        filtro_planes &= "</campos><orden>nro_plan desc</orden>"
        filtro_planes &= "<filtro>"
        filtro_planes &= "<nro_grupo type='igual'>%nro_grupo%</nro_grupo><nro_tabla type='in'>%nro_tablas%</nro_tabla><marca type='igual'>'%marca%'</marca>"
        filtro_planes &= "<%campo_min% type='menos'><![CDATA[datepart(YYYY,getdate()) - datepart(YYYY, %fe_naci%) - case when datepart(dy, getdate()) < datepart(dy, %fe_naci%) then 1 else 0 end]]></%campo_min%>"
        filtro_planes &= "<%campo_max% type='mas'><![CDATA[datediff(year, %fe_naci%, dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan)))]]></%campo_max%>"
        filtro_planes &= "<importe_neto type='mas'>%neto_minimo%</importe_neto>"
        filtro_planes &= "[<importe_neto type='menos'>%neto_maximo?%</importe_neto>]"
        filtro_planes &= "[<nro_plan type='igual'>%nro_plan?%</nro_plan>]"
        filtro_planes &= "<importe_cuota type='mas'>%importe_cuota_desde%</importe_cuota>"
        filtro_planes &= "<importe_cuota type='menos'>%importe_cuota_hasta%</importe_cuota>"

        filtro_planes_agrupado = filtro_planes & filtro_planes_agrupado
        filtro_planes &= "</filtro></select></criterio>"

        Me.contents.Add("planes_lotes", nvFW.nvXMLSQL.encXMLSQL(filtro_planes))
        Me.contents.Add("planes_lotes_agrupado", nvFW.nvXMLSQL.encXMLSQL(filtro_planes_agrupado))
        Me.contents("filtro_piz_dictamen") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_det'><campos>dato1_desde, pizarra_valor</campos><filtro><nro_calc_pizarra type='igual'>371</nro_calc_pizarra></filtro></select></criterio>")

        Me.contents.Add("verStatsPrecarga", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verStatsPrecarga'><campos>aprobados, manual, rechazados, total, cred_liq, cred_gestion</campos><orden></orden><filtro><nro_operador type='igual'>%nro_operador%</nro_operador></filtro></select></criterio>"))


        'Campos defs
        'Me.contents.Add("grupos_cda", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verGrupos_cda'><campos>nro_grupo as id,grupo as campo</campos><orden></orden><filtro></filtro></select></criterio>"))
        Me.contents.Add("grupos_cda", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNosis_cda_def_v5'><campos>distinct nro_grupo as id, grupo as campo</campos><orden></orden><filtro></filtro></select></criterio>"))

        Me.contents.Add("precarga_cuota_social", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='auxMutual_cuota'><campos> *</campos><filtro><nro_mutual type='igual'>%nro_mutual%</nro_mutual><SQL type='sql'>(%nro_grupo%=0) or (%nro_grupo%=nro_grupo)  or (nro_grupo=0)</SQL></filtro></select></criterio>"))
        ''Me.contents.Add("max_cuota_plan", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes_v4' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos>isnull(max(importe_cuota),0) as importe_cuota</campos><orden></orden><filtro></filtro></select></criterio>"))
        Me.contents.Add("max_cuota_plan", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes_lotes_v4' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos>isnull(max(importe_cuota),0) as importe_cuota</campos><orden></orden><filtro></filtro><grupo>cuotas</grupo></select></criterio>"))

        'modo = nvFW.nvUtiles.obtenerValor("modo", "")
        'nro_credito = nvFW.nvUtiles.obtenerValor("nro_credito", "0")

        Select Case modo.ToUpper
            Case "L"
                Dim err As New nvFW.tError
                Try
                    Dim xmlLog As String = nvFW.nvUtiles.obtenerValor("xmlLog", "")
                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_precarga_log", ADODB.CommandTypeEnum.adCmdStoredProc)
                    cmd.addParameter("@xmlLog", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlLog.Length, xmlLog)
                    Dim rs As ADODB.Recordset = cmd.Execute()
                    Dim numError As Integer = rs.Fields("numError").Value
                    Dim mensaje As String = rs.Fields("mensaje").Value
                    err.mensaje = mensaje
                    err.numError = numError
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error al registrar la consulta."
                    err.comentario = ""
                End Try
                err.response()

                'Case "F"    'Actualizar Fuentes de Nosis

                '    Dim err As New nvFW.tError
                '    Try

                '        Dim documento As String = nvFW.nvUtiles.obtenerValor("cuit", "")
                '        Dim url As String = nvFW.nvUtiles.obtenerValor("url", "")

                '        Dim nvNosisFuentes As New nvFW.servicios.tnvNosisFuentes
                '        nvNosisFuentes.URL = url
                '        nvNosisFuentes.timeOut = 20
                '        Dim respuesta = nvNosisFuentes.ActualizarFuentesNosis(documento)
                '        err.numError = 0
                '        err.titulo = ""
                '        err.mensaje = ""
                '        If (respuesta <> 1) Then
                '            err.numError = 99
                '            err.titulo = "Generar informe comercial."
                '            err.mensaje = "Error al actualizar las fuentes externas. Intente Nuevamente."
                '        End If
                '        err.params("respuesta") = respuesta
                '    Catch ex As Exception
                '        err.parse_error_script(ex)
                '        err.titulo = "Error al actualizar las fuentes externas"
                '        err.comentario = ""
                '    End Try
                '    err.response()

                'Case "E"
                '    Dim err As New nvFW.tError
                '    Try
                '        Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
                '        Dim nro_vendedor As Integer = nvFW.nvUtiles.obtenerValor("nro_vendedor", "")

                '        err.params("cr_mes") = 0
                '        err.params("tiene_cs") = 0
                '        err.params("tiene_cr") = 0
                '        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select nro_credito from vercreditos where cuit = '" & cuit & "' and nro_vendedor = " & nro_vendedor & " and estado in ('H','M','P') and fe_estado >= dbo.finac_inicio_mes(getdate())")
                '        If (rs.EOF = False) Then
                '            err.params("cr_mes") = 1
                '        End If
                '        nvDBUtiles.DBCloseRecordset(rs)
                '        rs = nvDBUtiles.DBOpenRecordset("select nro_credito from vercreditos where cuit = '" & cuit & "' and nro_banco = 200 and estado = 'T'")
                '        If (rs.EOF = False) Then
                '            err.params("tiene_cs") = 1
                '        End If
                '        nvDBUtiles.DBCloseRecordset(rs)
                '        rs = nvDBUtiles.DBOpenRecordset("select nro_credito from vercreditos where cuit = '" & cuit & "' and nro_banco <> 200 and estado = 'T'")
                '        If (rs.EOF = False) Then
                '            err.params("tiene_cr") = 1
                '        End If
                '        nvDBUtiles.DBCloseRecordset(rs)
                '        err.numError = 0

                '    Catch ex As Exception
                '        err.parse_error_script(ex)
                '        err.titulo = "Error al evaluar socio"
                '        err.comentario = ""
                '    End Try
                '    err.response()

                'Case "S"    'Generar Solicitud
                '    Dim err As New nvFW.tError
                '    Try
                '        Dim persona_existe As Boolean
                '        If nvFW.nvUtiles.obtenerValor("persona_existe", "") = "true" Then
                '            persona_existe = True
                '        End If
                '        Dim noti_prov As Boolean
                '        If nvFW.nvUtiles.obtenerValor("noti_prov", "") = "true" Then
                '            noti_prov = True
                '        End If
                '        Dim nro_archivo_noti_prov As Integer = nvFW.nvUtiles.obtenerValor("nro_archivo_noti_prov", "0")
                '        Dim xmlpersona As String = nvFW.nvUtiles.obtenerValor("xmlpersona", "")
                '        Dim xmltrabajo As String = nvFW.nvUtiles.obtenerValor("xmltrabajo", "")
                '        Dim xmlcredito As String = nvFW.nvUtiles.obtenerValor("xmlcredito", "")
                '        Dim xmlanalisis As String = nvFW.nvUtiles.obtenerValor("xmlanalisis", "")
                '        Dim xmlcancelaciones As String = nvFW.nvUtiles.obtenerValor("xmlcancelaciones", "")
                '        Dim xmlparametros As String = nvFW.nvUtiles.obtenerValor("xmlparametros")
                '        Dim estado As String = nvFW.nvUtiles.obtenerValor("estado")
                '        Dim paramMotor As Dictionary(Of String, String) = New Dictionary(Of String, String)
                '        Dim evalua_motor As Integer = nvFW.nvUtiles.obtenerValor("evalua_motor", 0)
                '        Dim xmlmotorparametros As String = nvFW.nvUtiles.obtenerValor("xmlmotorparametros", "")
                '        Dim mensaje_usuario As String = nvFW.nvUtiles.obtenerValor("mensaje_usuario", "")
                '        ''If (evalua_motor = 1) Then
                '        If (xmlmotorparametros <> "") Then
                '            Dim motorXML As System.Xml.XmlDocument
                '            motorXML = New System.Xml.XmlDocument
                '            motorXML.LoadXml(xmlmotorparametros)
                '            Dim XmlMotorNodeList As System.Xml.XmlNodeList
                '            Dim nodemotor As System.Xml.XmlNode
                '            XmlMotorNodeList = motorXML.SelectNodes("/motor/parametro")
                '            If XmlMotorNodeList IsNot Nothing Then
                '                For Each nodemotor In XmlMotorNodeList
                '                    Dim parametro = nodemotor.Attributes.GetNamedItem("nombre").Value
                '                    Dim valor = nodemotor.Attributes.GetNamedItem("valor").Value
                '                    paramMotor.Add(parametro, valor)
                '                Next
                '            End If
                '        End If ''evalua_motor


                '        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_cr_solicitud_v10", ADODB.CommandTypeEnum.adCmdStoredProc)
                '        cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                '        cmd.addParameter("@persona_existe", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, persona_existe)
                '        cmd.addParameter("@noti_prov", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, noti_prov)
                '        cmd.addParameter("@nro_archivo_noti_prov", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_archivo_noti_prov)
                '        cmd.addParameter("@XMLpersona", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlpersona.Length, xmlpersona)
                '        cmd.addParameter("@XMLtrabajo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmltrabajo.Length, xmltrabajo)
                '        cmd.addParameter("@XMLcredito", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcredito.Length, xmlcredito)
                '        cmd.addParameter("@XMLanalisis", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlanalisis.Length, xmlanalisis)
                '        cmd.addParameter("@XMLcancelaciones", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcancelaciones.Length, xmlcancelaciones)
                '        cmd.addParameter("@XMLparametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlparametros.Length, xmlparametros)
                '        Dim rs As ADODB.Recordset = cmd.Execute()
                '        nro_credito = rs.Fields("nro_credito").Value
                '        Dim modo1 As String = rs.Fields("modo").Value
                '        Dim numError As Integer = rs.Fields("numError").Value
                '        Dim mensaje As String = rs.Fields("mensaje").Value
                '        err.params("nro_credito") = nro_credito
                '        err.params("estado") = estado
                '        err.mensaje = mensaje
                '        err.numError = numError

                '        ''indica que es un alta de credito (sino es una modificacion)
                '        If numError = 0 And modo1 = "A" Then
                '            Try
                '                'Incorporar archivo Nosis al credito
                '                Dim NosisXML As String = nvFW.nvUtiles.obtenerValor("NosisXML")

                '                If NosisXML <> "" Then
                '                    Dim objXML As System.Xml.XmlDocument
                '                    objXML = New System.Xml.XmlDocument
                '                    objXML.LoadXml(NosisXML)
                '                    Dim strHTML As String = objXML.SelectSingleNode("Respuesta/ParteHTML").InnerText
                '                    Dim rsDef = nvFW.nvDBUtiles.DBOpenRecordset("select nro_def_detalle,archivo_descripcion from verArchivos_def where nro_credito = " & nro_credito & " and  archivo_descripcion like 'NOSIS%'")
                '                    Dim nro_def_detalle As Integer = rsDef.Fields("nro_def_detalle").Value
                '                    Dim archivo_descripcion As String = rsDef.Fields("archivo_descripcion").Value
                '                    Dim cmdnosis As New nvFW.nvDBUtiles.tnvDBCommand("get_nro_archivo", ADODB.CommandTypeEnum.adCmdStoredProc)
                '                    cmdnosis.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                '                    cmdnosis.addParameter("@nro_def_detalle", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_def_detalle)
                '                    cmdnosis.addParameter("@descripcion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, archivo_descripcion.Length, archivo_descripcion)
                '                    Dim rsnosis As ADODB.Recordset = cmdnosis.Execute()
                '                    Dim nro_archivo As Integer = rsnosis.Fields("nro_archivo").Value
                '                    'Dim rsA = nvFW.nvDBUtiles.DBOpenRecordset("Select isnull(max(nro_archivo), 0) + 1 As maxArchivo from archivos")
                '                    'Dim nro_archivo As Integer = rsA.Fields("maxArchivo").Value
                '                    'nvFW.nvDBUtiles.DBCloseRecordset(rsA)
                '                    'nvFW.nvDBUtiles.DBExecute("Insert Into archivos (nro_archivo, path, operador,nro_img_origen,nro_archivo_estado) values(" & nro_archivo & ", '" & nro_archivo & "','" & nvApp.operador.operador & "',1,1)")
                '                    Dim carpeta As String = DateTime.Now.ToString("yyyyMM")
                '                    Dim filename As String = CStr(nro_archivo) & ".html"

                '                    'Guardado en Nova
                '                    'Dim path_carpeta As String
                '                    'path_carpeta = "\\\\" & server_name & "\\d$\\MeridianoWeb\\Meridiano\\archivos\\" & carpeta
                '                    'If System.IO.Directory.Exists(path_carpeta) = False Then
                '                    '    System.IO.Directory.CreateDirectory(path_carpeta)
                '                    'End If
                '                    'Dim path As String = path_carpeta & "\\" & filename
                '                    'Dim fs2 As New System.IO.FileStream(path, IO.FileMode.Create)
                '                    'Dim buffer() As Byte = nvFW.nvConvertUtiles.StringToBytes(strHTML)
                '                    'fs2.Write(buffer, 0, buffer.Length)
                '                    'fs2.Close()


                '                    'JMO: Esto no VA!!!! Hay que cambiar el guardado de archivo por los metodos del nvFile
                '                    'Guardado en Rova
                '                    Dim path_rova As String
                '                    Dim rsRova = nvFW.nvDBUtiles.DBOpenRecordset("select path from helpdesk.dbo.nv_servidor_sistema_dir where cod_ss_dir in (select cod_dir from helpdesk.dbo.nv_sistema_dir where cod_directorio_tipo = 2 ) and cod_sistema = 'nv_mutual' and cod_servidor = '" & nvApp.cod_servidor & "' and cod_ss_dir = 'nvArchivosDefault'")
                '                    path_rova = rsRova.Fields("path").Value.Replace("\", "\\") & carpeta
                '                    If System.IO.Directory.Exists(path_rova) = False Then
                '                        System.IO.Directory.CreateDirectory(path_rova)
                '                    End If
                '                    Dim pathR As String = path_rova & "\\" & filename
                '                    'System.IO.File.Copy(path, pathR, True)

                '                    Dim fs3 As New System.IO.FileStream(pathR, IO.FileMode.Create)
                '                    Dim buffer1() As Byte = nvFW.nvConvertUtiles.StringToBytes(strHTML)
                '                    fs3.Write(buffer1, 0, buffer1.Length)
                '                    fs3.Close()

                '                    nvFW.nvDBUtiles.DBExecute("update archivos set nro_archivo_estado = 2 where nro_def_detalle = " & nro_def_detalle & " and nro_credito = " & nro_credito & " and nro_archivo <> " & nro_archivo)
                '                    nvFW.nvDBUtiles.DBExecute("update archivos set path = '" & carpeta & "\" & filename & "', nro_credito = " & nro_credito & ", descripcion = '" & archivo_descripcion & "',nro_def_detalle=" & nro_def_detalle & " where nro_archivo = " & nro_archivo)
                '                    'Incorporar parametros del CDA al archivo de Nosis
                '                    Dim strParteXML As String = "<?xml version=""1.0"" encoding=""ISO-8859-1""?>" & objXML.SelectSingleNode("Respuesta/ParteXML").OuterXml
                '                    Dim ParteXML As System.Xml.XmlDocument
                '                    ParteXML = New System.Xml.XmlDocument
                '                    ParteXML.LoadXml(strParteXML)

                '                    Dim XmlNodeList As System.Xml.XmlNodeList
                '                    Dim node As System.Xml.XmlNode

                '                    XmlNodeList = ParteXML.SelectNodes("/ParteXML/Dato/CalculoCDA")

                '                    Dim strSQL As String = ""

                '                    For Each node In XmlNodeList
                '                        Dim Titulo = node.Attributes.GetNamedItem("Titulo").Value
                '                        strSQL = "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'EMPRESA' , '" & Titulo & "', getdate(),dbo.rm_nro_operador()) "
                '                        Dim NroCDA = node.Attributes.GetNamedItem("NroCDA").Value
                '                        strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CDA' , '" & NroCDA & "', getdate(),dbo.rm_nro_operador()) "
                '                        Dim Version = node.Attributes.GetNamedItem("Version").Value
                '                        strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CDA_VERSION' , '" & Version & "', getdate(),dbo.rm_nro_operador()) "
                '                        Dim Fecha = node.Attributes.GetNamedItem("Fecha").Value
                '                        strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'FECHA' , '" & Fecha & "', getdate(),dbo.rm_nro_operador()) "
                '                        Dim Documento = node.SelectSingleNode("Documento").InnerText
                '                        strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'CUIL' , '" & Documento & "', getdate(),dbo.rm_nro_operador()) "
                '                        Dim RazonSocial = node.SelectSingleNode("RazonSocial").InnerText
                '                        strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'RAZON_SOCIAL' , '" & RazonSocial & "', getdate(),dbo.rm_nro_operador()) "
                '                        Dim ItemList As System.Xml.XmlNodeList
                '                        Dim ItemNode As System.Xml.XmlNode
                '                        ItemList = node.SelectNodes("Item")
                '                        For Each ItemNode In ItemList
                '                            Dim parametro = ItemNode.Attributes.GetNamedItem("Clave").Value
                '                            Dim valor = ItemNode.SelectSingleNode("Valor").InnerText
                '                            strSQL += "INSERT INTO archivos_parametros(nro_archivo, parametro, parametro_valor,fe_actualizacion,nro_operador) values (" & nro_archivo & ",'" & parametro & "' , '" & valor & "', getdate(),dbo.rm_nro_operador()) "
                '                        Next
                '                        nvFW.nvDBUtiles.DBExecute(strSQL)
                '                    Next
                '                End If

                '            Catch ex As Exception
                '            End Try

                '            Try
                '                Dim strSql As String = ""
                '                ''si evalua motor de cuad (va a generar consumo), y es una alta
                '                If (evalua_motor = 1 And modo1 = "A" And numError = 0) Then
                '                    ''dentro del motor, el que decide es el motor 1538 cuad santa fe
                '                    If (paramMotor.ContainsKey("nro_motor_decision")) Then
                '                        If (paramMotor("nro_motor_decision") = "1538") Then
                '                            Dim respondiocuad As Boolean = True
                '                            Dim comprobante_filiacion_64 As String = ""
                '                            Dim comprobante_consumo_64 As String = ""
                '                            Dim comprobante_screen_64 As String = ""
                '                            Dim errr As New nvFW.tError
                '                            Dim robot As New nvFW.servicios.Robots.wsCuad
                '                            Dim credencial As New nvFW.servicios.Robots.wsCuad.wsCredencial
                '                            Dim Usuario As String = nvUtiles.getParametroValor("CUAD_ROBOT_USERNAME", "WS_Nova01")
                '                            Dim Password As String = nvUtiles.getParametroValor("CUAD_ROBOT_PASSWORD", "WS_N0v41F")
                '                            credencial.usuario = Usuario
                '                            credencial.pwd = Password
                '                            robot.callback = nvFW.nvApp.getInstance.server_host_https & "/FW/servicios/ROBOTS/cuad_callback.aspx"
                '                            robot.timeoutconsumo = 1000 * 60 * 15 ''15 minutos
                '                            Dim socio_nuevo As String = IIf(paramMotor("socio_nuevo") = "1", "1", "0")

                '                            Dim nro_docu As String = ""
                '                            Dim importe_cuota As String = ""
                '                            Dim cuotas As String = ""
                '                            Dim primer_venc As String = ""
                '                            Dim cat As String = ""
                '                            Dim tipo_lote As String = ""
                '                            Dim nro_mutual As String = ""


                '                            Dim rs2 As ADODB.Recordset = Nothing
                '                            ''rs2 = nvDBUtiles.DBOpenRecordset("select nro_mutual,nro_docu,importe_cuota,cuotas,dbo.conv_fecha_to_str(primer_vencimiento,'yyyymm') as primer_venc,tipo_lote from vercreditos where nro_credito=" & CStr(nro_credito))
                '                            rs2 = nvDBUtiles.DBOpenRecordset("select nro_mutual,nro_docu,importe_cuota,cuotas,dbo.conv_fecha_to_str(dbo.rm_cuad_robot_primer_vencimiento(nro_credito," & paramMotor("scu_id") & "),'yyyymm') as primer_venc,tipo_lote from vercreditos where nro_credito=" & CStr(nro_credito) & " and estado<>'X'")
                '                            If (rs2.EOF = False) Then
                '                                nro_docu = rs2.Fields("nro_docu").Value
                '                                importe_cuota = rs2.Fields("importe_cuota").Value
                '                                cuotas = rs2.Fields("cuotas").Value
                '                                primer_venc = rs2.Fields("primer_venc").Value
                '                                tipo_lote = rs2.Fields("tipo_lote").Value
                '                                nro_mutual = rs2.Fields("nro_mutual").Value
                '                            End If
                '                            Dim scu_id As String = paramMotor("scu_id") ''identificativo de sistema cuad
                '                            Dim sce_id As String = "" ''tipo de lote (activo o pasivo)
                '                            Dim scm_id As String = "" '' mutual de referencia en cuad
                '                            Dim ses_id As String = "" '' identificativo de tipo de servicio segun categoria de socio, mutual y tipo de lote
                '                            strSql = "select categoria_socio,scm_id,sce_id,ses_id from verPiz_cuad_mutual_categorias_serv where nro_mutual=" & nro_mutual & " and tipo_lote='" & tipo_lote & "' and socio_nuevo= " & socio_nuevo
                '                            rs2 = nvDBUtiles.DBOpenRecordset(strSql)
                '                            If (rs2.EOF = False And nro_docu <> "") Then
                '                                cat = rs2.Fields("categoria_socio").Value
                '                                scm_id = rs2.Fields("scm_id").Value
                '                                sce_id = rs2.Fields("sce_id").Value
                '                                ses_id = rs2.Fields("ses_id").Value
                '                                'Scu_Id: sistema cuad
                '                                'Sce_Id:id del liquidador
                '                                'Scm_id:id de la mutual al cual se consulta el cupo
                '                                'ses_id: id del servicio a consumir (por lo general- prestamo personal) segun mutual - sistema cuad - lote
                '                                'cat: categoria del socio segun mutual, lote y si es socio nuevo o no
                '                                Dim consumo_log_id As String = ""
                '                                ''AltaConsumoCredito(ByVal credencial As wsCredencial, ByVal parametrosrobot As Dictionary(Of String, String), ByVal parametroscredito As Dictionary(Of String, String))
                '                                Dim parametrosrobot As New Dictionary(Of String, String)
                '                                parametrosrobot("Scu_Id") = scu_id
                '                                parametrosrobot("Sce_Id") = sce_id
                '                                parametrosrobot("Scm_Id") = scm_id
                '                                parametrosrobot("Clave_Sueldo") = paramMotor("clave_sueldo")
                '                                parametrosrobot("Nro_Documento") = nro_docu
                '                                parametrosrobot("Prioridad") = 1
                '                                parametrosrobot("Ses_Id") = ses_id
                '                                parametrosrobot("Cuotas") = cuotas
                '                                parametrosrobot("Importe") = importe_cuota
                '                                parametrosrobot("Primer_Venc") = primer_venc
                '                                parametrosrobot("Categoria_Socio") = cat
                '                                parametrosrobot("Clave_Servicio") = ""
                '                                parametrosrobot("Comentario") = ""
                '                                Dim parametroscredito As New Dictionary(Of String, String)
                '                                parametroscredito("nro_credito") = CStr(nro_credito)
                '                                parametroscredito("id_transf_log") = paramMotor("id_transf_log")
                '                                parametroscredito("estado") = paramMotor("estado")
                '                                parametroscredito("xmlmotorparametros") = xmlmotorparametros
                '                                '' referencia 1
                '                                ''si desde el front, trae mensaje de usuario, lo guardo como comentario observador motivo, ya que luego de pedir el consumo, nose si cuad va a responder y nose si va a guardar comentario
                '                                If (mensaje_usuario <> "") Then
                '                                    strSql = "INSERT INTO com_registro ([tipo_docu], [nro_docu], [sexo], [nro_credito], [nro_com_tipo], [comentario], [operador], [fecha], [nro_com_estado], [operador_destino], [nro_registro_depende], [nro_com_id_tipo], [id_tipo])" & vbCrLf
                '                                    strSql &= "Select tipo_docu,nro_docu,sexo,nro_credito,164 As nro_com_tipo,?,dbo.rm_nro_operador() as operador,getdate() as fecha,1,null,null,2 as nro_com_id_tipo, nro_credito as id_tipo from vercreditos where nro_credito=" & CStr(nro_credito)
                '                                    Dim cmd3 As New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                '                                    mensaje_usuario = mensaje_usuario.Replace("|", "<br/>")
                '                                    mensaje_usuario = mensaje_usuario.Replace("&lt;", "<").Replace("&gt;", ">") ''esta transformacion de caracteres html viene desde el front
                '                                    Dim parametersSql1 = cmd3.CreateParameter("@comentario", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, mensaje_usuario)
                '                                    cmd3.Parameters.Append(parametersSql1)
                '                                    cmd3.Execute()
                '                                    mensaje_usuario = "" ''seteo en vacio el mensaje para q siga el circuito pero recabando nuevos mensajes
                '                                End If

                '                                errr = robot.AltaConsumoCredito(credencial:=credencial, parametrosrobot:=parametrosrobot, parametroscredito:=parametroscredito)
                '                                If (errr.numError = 1000) Then
                '                                    mensaje_usuario &= "Carga en proceso. <br/>"
                '                                    respondiocuad = False
                '                                Else
                '                                    respondiocuad = True
                '                                End If
                '                                If (errr.params.ContainsKey("log_id")) Then
                '                                    consumo_log_id = errr.params("log_id")
                '                                End If

                '                                ''si el consumo se hizo, paso el credito a estado presupuesto
                '                                If (errr.numError = 0 And respondiocuad) Then
                '                                    Dim logfiles As String = "p1;"
                '                                    Dim cmd4 As New nvFW.nvDBUtiles.tnvDBCommand("rm_credito_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc)
                '                                    cmd4.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                '                                    cmd4.addParameter("@estado", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 1, IIf(paramMotor("estado") = "A", "M", paramMotor("estado")))
                '                                    cmd4.addParameter("@GenerarCC", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, 0)
                '                                    cmd4.Execute()
                '                                    Dim codigo_consumo As String = errr.params("codigo_consumo")
                '                                    comprobante_filiacion_64 = IIf(errr.params.ContainsKey("comprobante_filiacion_64"), errr.params("comprobante_filiacion_64"), "")
                '                                    comprobante_consumo_64 = IIf(errr.params.ContainsKey("comprobante_consumo_64"), errr.params("comprobante_consumo_64"), "")  ''errr.params("comprobante_consumo_64")
                '                                    comprobante_screen_64 = IIf(errr.params.ContainsKey("comprobante_screen"), errr.params("comprobante_screen"), "") ''errr.params("comprobante_screen")
                '                                    ''actualizo los valores de los analisis
                '                                    strSql = "update Detalle_Sueldo set valor='" & importe_cuota & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta=493" & vbCrLf ''actualizo cuota afectada
                '                                    strSql &= "update Detalle_Sueldo set valor='" & codigo_consumo & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta=356" & vbCrLf ''actualizo codigo cuad de consumo

                '                                    If (errr.params.ContainsKey("bruto")) Then
                '                                        If (errr.params("bruto") <> "") Then
                '                                            strSql &= "update Detalle_Sueldo set  monto='" & errr.params("bruto") & "', valor='" & errr.params("bruto") & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta in(0,526) " & vbCrLf ''actualizo importe bruto en analisis
                '                                        End If
                '                                    End If
                '                                    If (errr.params.ContainsKey("neto")) Then
                '                                        If (errr.params("neto") <> "") Then
                '                                            strSql &= "update Detalle_Sueldo set  monto='" & errr.params("neto") & "', valor='" & errr.params("neto") & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta=385" & vbCrLf ''actualizo neto
                '                                        End If
                '                                    End If
                '                                    If (errr.params.ContainsKey("afectable")) Then
                '                                        If (errr.params("afectable") <> "") Then
                '                                            strSql &= "update Detalle_Sueldo set monto='" & errr.params("afectable") & "', valor='" & errr.params("afectable") & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta=167" & vbCrLf ''actualizo afectable
                '                                        End If
                '                                    End If
                '                                    ''cupo antes de realizar el consumo
                '                                    If (errr.params.ContainsKey("cupo")) Then
                '                                        If (errr.params("cupo") <> "") Then
                '                                            strSql &= "update Detalle_Sueldo set  monto='" & errr.params("cupo") & "', valor='" & errr.params("cupo") & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta=523" & vbCrLf ''actualizo cupo total
                '                                        End If
                '                                    End If
                '                                    ''afectado antes de realizar el consumo
                '                                    If (errr.params.ContainsKey("afectado")) Then
                '                                        If (errr.params("afectado") <> "") Then
                '                                            strSql &= "update Detalle_Sueldo set monto='" & errr.params("afectado") & "', valor='" & errr.params("afectado") & "' where nro_credito=" & CStr(nro_credito) & " and nro_etiqueta=524" & vbCrLf ''Afectado Teorico
                '                                        End If
                '                                    End If
                '                                    nvFW.nvDBUtiles.DBExecute(strSql)
                '                                    Try
                '                                        nvFW.nvDBUtiles.DBExecute("exec dbo.rm_ajustar_analisis_calculados2 " & CStr(nro_credito))
                '                                    Catch ex As Exception
                '                                        err.debug_desc = "Error al actualizar analisis " & ex.Message
                '                                    End Try

                '                                End If
                '                                ''si el mensaje o error, no es de time out del cuad, y es otro mensajes del cuad, como ser CUPO INSUFICIENTE, lo muestro a pantalla y lo paso a consumo rechazado
                '                                If (errr.numError <> 1000 And errr.numError <> 0) Then
                '                                    err.numError = 0 'errr.numError
                '                                    err.mensaje = errr.mensaje
                '                                    mensaje_usuario &= " consumo rechazado " & err.mensaje
                '                                    err.debug_desc = "id log consumo :" & consumo_log_id & " detalle terror: " & CStr(errr.numError) & " - " & errr.mensaje & " - " & errr.debug_desc
                '                                    Dim cmd4 As New nvFW.nvDBUtiles.tnvDBCommand("rm_credito_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc)
                '                                    cmd4.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                '                                    cmd4.addParameter("@estado", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 1, "7")
                '                                    cmd4.addParameter("@GenerarCC", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, 0)
                '                                    cmd4.Execute()
                '                                End If

                '                            Else
                '                                err.numError = 0  '100
                '                                err.mensaje = "No se puedo generar el consumo. No se encontraron configuraciones necesarias para el alta del consumo. Notifiquelo"
                '                                err.debug_desc = "No se encontraron asociaciones fundamentales en las pizzarras para con el socio"
                '                            End If
                '                            nvDBUtiles.DBCloseRecordset(rs2)
                '                            ''ejecuto la transferencia para que siga generando los archivos faltantes (asincrono) y tmb los demas archivos
                '                            Dim async_thread As System.Threading.Thread = New System.Threading.Thread(Sub(psp As Object)

                '                                                                                                          Dim nvFile As New nvFW.servicios.nvProcesamiento
                '                                                                                                          nvFW.nvApp._nvApp_ThreadStatic = psp("nvApp")
                '                                                                                                          Dim _pdf As New nvFW.nvPDF
                '                                                                                                          Dim robot2 As New nvFW.servicios.Robots.wsCuad
                '                                                                                                          Dim comprobante_filiacion_642 As String = psp("comprobante_filiacion_64")
                '                                                                                                          Dim comprobante_consumo_642 As String = psp("comprobante_consumo_64")
                '                                                                                                          Dim comprobante_screen_642 As String = psp("comprobante_screen_64")
                '                                                                                                          Dim bytes As Byte() = Nothing
                '                                                                                                          ''comprobante de filiacion
                '                                                                                                          If (comprobante_filiacion_642 <> "") Then
                '                                                                                                              bytes = robot2.getPdf(comprobante_filiacion_642)
                '                                                                                                              nvFile.addfilelegajo(binary:=bytes, nro_credito:=nro_credito, nro_archivo_def_tipo:=46, cod_sistema:="nv_mutual") '' adjunto cad de cuota social (alta como socio)
                '                                                                                                          End If
                '                                                                                                          ''cad de consumo
                '                                                                                                          If (comprobante_consumo_642 <> "") Then
                '                                                                                                              bytes = robot2.getPdf(comprobante_consumo_642)
                '                                                                                                              nvFile.addfilelegajo(binary:=bytes, nro_credito:=nro_credito, nro_archivo_def_tipo:=2, cod_sistema:="nv_mutual") '' adjunto cad de prestacion al legajo
                '                                                                                                          End If

                '                                                                                                          ''captura (png)
                '                                                                                                          If (comprobante_screen_642 <> "") Then
                '                                                                                                              bytes = robot2.parseBytes(comprobante_screen_642)
                '                                                                                                              Try
                '                                                                                                                  ''si es imagen, esto va a reventar, sino, es pdf
                '                                                                                                                  Dim ms As New IO.MemoryStream(bytes) 'This is correct...
                '                                                                                                                  Dim returnImage As System.Drawing.Image = System.Drawing.Image.FromStream(ms)
                '                                                                                                                  bytes = _pdf.ImageToPDF(returnImage)
                '                                                                                                              Catch ex As Exception
                '                                                                                                              End Try
                '                                                                                                              nvFile.addfilelegajo(binary:=bytes, nro_credito:=nro_credito, nro_archivo_def_tipo:=118, cod_sistema:="nv_mutual") '' adjunto captura del cuad
                '                                                                                                          End If
                '                                                                                                          ''adjunta NOSIS
                '                                                                                                          Dim tTransferencia As New nvTransferencia.tTransfererncia
                '                                                                                                          Try
                '                                                                                                              tTransferencia.cargar(1567)
                '                                                                                                              tTransferencia.param("nro_credito")("valor") = psp("nro_credito")
                '                                                                                                              tTransferencia.param("id_consulta")("valor") = psp("id_consulta")
                '                                                                                                              tTransferencia.ejecutar()
                '                                                                                                          Catch ex As Exception
                '                                                                                                          End Try
                '                                                                                                      End Sub)

                '                            Dim ps As New Dictionary(Of String, Object)
                '                            ps.Add("nvApp", nvApp)
                '                            ps.Add("nro_credito", nro_credito)
                '                            ps.Add("id_consulta", paramMotor("nosis_id_consulta"))
                '                            ps.Add("comprobante_filiacion_64", comprobante_filiacion_64)
                '                            ps.Add("comprobante_consumo_64", comprobante_consumo_64)
                '                            ps.Add("comprobante_screen_64", comprobante_screen_64)
                '                            async_thread.Start(ps)


                '                        End If ''motor cuad santa fe

                '                    End If '' si existe el diccionario de ContainsKey nro_motor_decision
                '                    If (err.mensaje <> "") Then
                '                        mensaje_usuario &= (IIf(mensaje_usuario <> "", "<br/>" & err.mensaje, err.mensaje))
                '                    End If
                '                Else
                '                    ''para casos que no vayan al motor
                '                    If (paramMotor.ContainsKey("id_transf_log") And paramMotor.ContainsKey("estado")) Then
                '                        strSql = "INSERT INTO [dbo].[CUAD_motor_calificacion]([id_transf_log],[nro_credito],[estado],[fecha],[nro_operador],[xml]) VALUES (" & paramMotor("id_transf_log") & "," & CStr(nro_credito) & ",'" & paramMotor("estado") & "',getdate(),dbo.rm_nro_operador(),?)" & vbCrLf
                '                        strSql = strSql & "select @@identity as id "
                '                        cmd = New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                '                        Dim parametersSql = cmd.CreateParameter("@xml", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, xmlmotorparametros)
                '                        cmd.Parameters.Append(parametersSql)
                '                        cmd.Execute()
                '                    End If

                '                End If


                '                ''si desde el front, trae mensaje de usuario (que no se guardo antes de realizar consumo cuad - ver referencia 1), lo guardo como comentario observador motivo, como asi tambien si el motor de cuad, trajo algo
                '                If (mensaje_usuario <> "") Then
                '                    strSql = "INSERT INTO com_registro ([tipo_docu], [nro_docu], [sexo], [nro_credito], [nro_com_tipo], [comentario], [operador], [fecha], [nro_com_estado], [operador_destino], [nro_registro_depende], [nro_com_id_tipo], [id_tipo])" & vbCrLf
                '                    strSql &= "Select tipo_docu,nro_docu,sexo,nro_credito,164 As nro_com_tipo,?,dbo.rm_nro_operador() as operador,getdate() as fecha,1,null,null,2 as nro_com_id_tipo, nro_credito as id_tipo from vercreditos where nro_credito=" & nro_credito
                '                    Dim cmd3 As New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                '                    mensaje_usuario = mensaje_usuario.Replace("|", "<br/>")
                '                    mensaje_usuario = mensaje_usuario.Replace("&lt;", "<").Replace("&gt;", ">") ''esta transformacion de caracteres html viene desde el front
                '                    Dim parametersSql1 = cmd3.CreateParameter("@comentario", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, mensaje_usuario)
                '                    cmd3.Parameters.Append(parametersSql1)
                '                    cmd3.Execute()
                '                End If
                '            Catch ex As Exception
                '                err.parse_error_script(ex)
                '            End Try
                '        End If

                '    Catch ex As Exception
                '        err.parse_error_script(ex)
                '    End Try
                '    err.response()

        End Select

    End Sub
End Class