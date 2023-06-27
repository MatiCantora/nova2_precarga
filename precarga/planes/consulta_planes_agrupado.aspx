<%@ Page Language="C#" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%

    Stop

    tError err = new tError();

    string filtroWhere = nvUtiles.obtenerValor("filtroWhere", "");

    string filtro_verPlanes = nvXMLSQL.encXMLSQL("<criterio><select vista='verPlanes' PageSize='5' AbsolutePage='1' cacheControl='Session'><campos>datediff(year, convert(datetime,'%fe_naci%',103), dateadd(month, cuotas, dbo.rm_primervencimiento(getdate(), nro_plan))) as edad_fin, nro_plan,importe_neto,importe_bruto,cuotas,importe_cuota,plan_banco,%nro_tipo_cobro%  as nro_tipo_cobro,gastoscomerc,mes_vencimiento,case when %tiene_seguro%=1 then dbo.piz4D_money('monto_seguro',nro_banco,nro_mutual,nro_grupo,importe_bruto) else 0 end as monto_seguro</campos><orden>nro_plan desc</orden><filtro></filtro></select></criterio>");

    string strSQL = nvXMLSQL.XMLtoSQL(filtro_verPlanes, filtroWhere);

    err.response();

%>