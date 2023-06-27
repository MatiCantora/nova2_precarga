<%@ Page Language="VB" %>
<%

    Dim strJson As String = <![CDATA[
  {
    "vendedor": {
        "cuit": "30546741636",
        "cbu": "3120001901000110001992",
        "banco": "312",
        "sucursal": "001"
    },
    "comprador": {
        "cuit": "27122305495",
        "cuenta": {
            "cbu": "3120001902000000000224"
        }
    },
    "detalle": {
        "concepto": "PLF",
        "idUsuario": "99",
        "idComprobante": "99",
        "moneda": "32",
        "importe": "9.99",
        "tiempoExpiracion": "48",
        "descripcion": "prueba001",
        "mismoTitular": "0"
    },
    "datosGenerador": {
        "ipCliente": "127.0.0.1",
        "tipoDispositivo": "04",
        "plataforma": "01",
        "imsi": [],
        "imei": [],
        "lat": "0",
        "lng": "0",
        "precision": []
    },
    "respuesta": {
        "codigo": "99",
        "descripcion": "NO ADHERIDO COMO VENDEDOR"
    },
    "debin": {
        "id": "WORD6LEN8QGGKG09M1Y30V",
        "estado": {
            "codigo": "ERROR DATOS",
            "descripcion": "99"
        },
        "addDt": "2020-09-04T14:02:55.534985-03:00",
        "fechaExpiracion": "2020-09-04T14:50:55.5329811-03:00"
    },
    "evaluacion": {
        "puntaje": "0"
    }
}
]]>.ToString


    Response.Expires = -1
    Response.ContentType = "application/json"
    Response.Charset = "ISO-8859-1"
    Dim buffer() As Byte = nvConvertUtiles.currentEncoding.GetBytes(Replace(Replace(strJson, "<![CDATA[", ""), "]]>", ""))
    Response.BinaryWrite(buffer)
    Response.End()
    %>