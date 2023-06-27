<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    Dim operador As String = nvUtiles.obtenerValor("operador", "")
    Dim cuenta_cambiar_pwd As String = nvUtiles.obtenerValor("cuenta_cambiar_pwd", "false")
    Dim operadorXML As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("operadorXML", ""))

    Select Case accion.ToLower
        Case "get_operador"

            Dim err As New tError
            Try

                Dim cuenta_set_password As Boolean = False
                Dim cuenta_observacion As String = ""

                Dim op As New nvFW.nvSecurity.tnvOperador
                op.load(operador)
                Dim enebleApplication As Boolean = op.enebleApplication(nvApp.cod_sistema)
                Dim oXML As New System.Xml.XmlDocument
                oXML.LoadXml(op.loginXML)
                cuenta_cambiar_pwd = nvXMLUtiles.getNodeText(oXML, "criterio/cuenta_cambiar_pwd", "false") = "true"
                cuenta_observacion = nvXMLUtiles.getNodeText(oXML, "criterio/observacion", "") 'cargamos las observaciones de la cuenta
                cuenta_set_password = nvXMLUtiles.getNodeText(oXML, "criterio/login", "") = "" 'en el caso que el login no exista le decimos que setee la password

                op.loginXML = ""
                operadorXML = op.toXML()
                oXML.LoadXml(operadorXML)
                If (oXML.SelectSingleNode("operador/datos").ChildNodes.Count = 0) Then
                    Dim xml_datos As String = oXML.SelectSingleNode("operador/datos").OuterXml.ToString
                    oXML.LoadXml(nvApp.operador.toXML())
                    operadorXML = operadorXML.Replace(xml_datos, oXML.SelectSingleNode("operador/datos").OuterXml.ToString)
                End If

                err.params("operadorXML") = operadorXML
                err.params("enebleApplication") = enebleApplication
                err.params("cuenta_cambiar_pwd") = cuenta_cambiar_pwd
                err.params("cuenta_observacion") = cuenta_observacion
                err.params("cuenta_set_password") = cuenta_set_password

            Catch ex As Exception
                err.numError = 12
                err.parse_error_script(ex)
                err.titulo = "Error en ABM operador"
                err.mensaje = "No se pudo realizar la acci�n solicitada"
            End Try

            err.response()

        Case "abm_operador"

            Dim err As New tError
            Try
                Dim bajacuenta As String = nvUtiles.obtenerValor("bajacuenta", "")
                Dim enebleApplication As Boolean = nvUtiles.obtenerValor("enebleApplication", "false") = "true"

                ' en el caso que el login no exista
                Dim pass As String = nvUtiles.obtenerValor("pass", "")
                Dim nombres As String = nvUtiles.obtenerValor("nombres", "")
                Dim apellido As String = nvUtiles.obtenerValor("apellido", "")

                Dim op2 As New nvFW.nvSecurity.tnvOperador
                op2.loadFromXML(operadorXML)

                Dim errLogin As tError = op2.loadLogin()
                Dim oXml As New System.Xml.XmlDocument
                oXml.LoadXml(errLogin.params("loginXML"))

                op2.loginXML = oXml.OuterXml

                If enebleApplication <> op2.enebleApplication(nvApp.cod_sistema) Then
                    If enebleApplication Then
                        oXml.SelectSingleNode("criterio/cuenta_habilitada").InnerText = "true"
                        oXml.SelectSingleNode("criterio/nv_operadores/nv_operador[@cod_sistema='" & nvApp.cod_sistema & "']/@acceso_sistema").Value = "true"
                    Else
                        oXml.SelectSingleNode("criterio/nv_operadores/nv_operador[@cod_sistema='" & nvApp.cod_sistema & "']/@acceso_sistema").Value = "false"
                        If bajacuenta Then oXml.SelectSingleNode("criterio/cuenta_habilitada").InnerText = "false"
                    End If
                End If

                If oXml.SelectSingleNode("criterio/login").InnerText = "" Then
                    oXml.SelectSingleNode("criterio/login").InnerText = op2.login
                    oXml.SelectSingleNode("criterio/apellido").InnerText = apellido
                    oXml.SelectSingleNode("criterio/nombres").InnerText = nombres
                    oXml.SelectSingleNode("criterio/fullname").InnerText = nombres & " " & apellido
                    oXml.SelectSingleNode("criterio/pass").InnerText = pass.ToString
                End If

                oXml.SelectSingleNode("criterio/cuenta_cambiar_pwd").InnerText = cuenta_cambiar_pwd.ToString.ToLower
                op2.loginXML = "<?xml version='1.0' encoding='ISO-8859-1'?>" & oXml.OuterXml
                err = op2.save()
            Catch ex As Exception
                err.numError = 12
                err.parse_error_script(ex)
                err.titulo = "Error en ABM operador"
                err.mensaje = "No se pudo realizar la acci�n solicitada"
            End Try
            err.response()
    End Select

    Dim StrSQL = ""
    Dim strError = ""

    Me.contents("tEntidades_filtroXML") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("tOperador_tipo_filtroXML") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>tipo_operador as [id],tipo_operador_desc as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")


    Dim verificacion As String = "La cuenta se valida contra <b>" & IIf(nvApp.ads_dc = "", "", nvApp.ads_dc)
    If Not (IsNothing(nvApp.ads_dominio)) And nvApp.ads_dominio <> "" Then
        verificacion += "." & nvApp.ads_dominio
    End If
    verificacion += "</b> mediante el protocolo " & nvApp.ads_access

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Operador ABM</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/fw/script/ttable.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_head.js"></script>

      <% = Me.getHeadInit()%>
    <script type="text/javascript" >
    
//Botones
var vButtonItems = new Array();


vButtonItems[0] = {};
vButtonItems[0]["nombre"] = "btnAceptar_pwd";
vButtonItems[0]["etiqueta"] = "Aceptar";
vButtonItems[0]["imagen"] = "";
vButtonItems[0]["onclick"] = "return btnAceptar_pwd_set_onclick(false)";

vButtonItems[1] = {};
vButtonItems[1]["nombre"] = "btnCancelar_pwd";
vButtonItems[1]["etiqueta"] = "Cancelar";
vButtonItems[1]["imagen"] = "";
vButtonItems[1]["onclick"] = "return btnCancelar_pwd_onclick()";

vButtonItems[2] = {};
vButtonItems[2]["nombre"] = "btnAceptar_pwd_set";
vButtonItems[2]["etiqueta"] = "Aceptar";
vButtonItems[2]["imagen"] = "";
vButtonItems[2]["onclick"] = "return btnAceptar_pwd_set_onclick(true)";

vButtonItems[3] = {};
vButtonItems[3]["nombre"] = "btnCancelar_pwd_set";
vButtonItems[3]["etiqueta"] = "Cancelar";
vButtonItems[3]["imagen"] = "";
vButtonItems[3]["onclick"] = "return btnCancelar_pwd_onclick()";

vButtonItems[4] = {};
vButtonItems[4]["nombre"] = "btnAceptar_hcha";
vButtonItems[4]["etiqueta"] = "Dehabilitar Cuenta";
vButtonItems[4]["imagen"] = "";
vButtonItems[4]["onclick"] = "return btnAceptar_hcha_onclick()";

vButtonItems[5] = {};
vButtonItems[5]["nombre"] = "btnAceptar_ha";
vButtonItems[5]["etiqueta"] = "Dehabilitar Acceso a la Aplicaci�n";
vButtonItems[5]["imagen"] = "";
vButtonItems[5]["onclick"] = "return btnAceptar_ha_onclick()";

vButtonItems[6] = {};
vButtonItems[6]["nombre"] = "btnCancelar_hcha";
vButtonItems[6]["etiqueta"] = "Cancelar";
vButtonItems[6]["imagen"] = "";
vButtonItems[6]["onclick"] = "return btnCancelar_hcha_onclick()";

var vListButton = new tListButton(vButtonItems, 'vListButton');
vListButton.loadImage("buscar", '/fw/image/security/buscar.png')
vListButton.imagenes = {}//Imagenes //Imagenes se declara en pvUtiles

var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:120, okLabel: "cerrar"}); }

var modo = '';
var L = new Array();
var checkeador;
var criterio = ''

var win = nvFW.getMyWindow()


function window_onload() 
  {
    
    vListButton.MostrarListButton();
    vOperador.MostrarMenu()
    
    //campos_defs.items['nro_operador']['onchange'] = operador_cargar
    if (typeof (win) == 'object') 
     {
        if (typeof (win.returnValue) == 'object') {
            $('login').value = win.returnValue['login']
        }
        else
            if (win.options.userData != undefined)
                if (win.options.userData.login)
                  $('login').value  = win.options.userData.login
     }

    if ($('login').value == '')
      operador_nuevo()
    else
      operador_cargar()

    $('login').focus()
    window_onresize()
  }

 function operador_abrir() 
  {
     campos_defs.items['nro_operador']['onchange'] = operador_cargar
     campos_defs.clear('nro_operador')
     campos_defs.onclick(null, 'nro_operador');
  }

  var cuenta_set_password
  var Nodesdatos
  function operador_cargar(forzar) 
   {

    if (!forzar)
          forzar = true

    cuenta_set_password = false

    nvFW.error_ajax_request('operador_abm.aspx', {
        parameters: { accion: 'get_operador', operador: $('login').value },
        onSuccess: function (err, transport) {

            var objXML = new tXML();
            if (objXML.loadXML(err.params.operadorXML)) 
            {
            $('validador').innerHTML = ""
            $('validador').insert({ top: err.params.cuenta_observacion })
            $('operador').value = XMLText(objXML.selectSingleNode("operador/operador"))
            $('nombre_operador').value = XMLText(objXML.selectSingleNode("operador/nombre_operador"))
            $('nro_entidad').value = XMLText(objXML.selectSingleNode("operador/nro_entidad"))
            
            entidad_cargar()

            $('login').value = XMLText(objXML.selectSingleNode("operador/login"))
            $('login').disabled = true

            $('cuenta_habilitada').checked = err.params.enebleApplication == 'True'
            $('cuenta_cambiar_pwd').checked = err.params.cuenta_cambiar_pwd == 'True'
            cuenta_set_password = err.params.cuenta_set_password == 'True'

            if (forzar)
              perfil_cargar(objXML.selectNodes("operador/perfiles"))

            datos_cargar(objXML.selectNodes("operador/datos"))

            if ($('login').disabled)
                btn_modificar_login(true)
            }
        }
    });
 }

  var tabla_perfil
  function perfil_cargar(Node, forzar) {
      
          tabla_perfil = new tTable();
          tabla_perfil.cn = '';
          tabla_perfil.filtroXML = ''

          tabla_perfil.nombreTabla = "tabla_perfil";
          tabla_perfil.editable = true;
          tabla_perfil.eliminable = true;
          tabla_perfil.mostrarAgregar = true;
          tabla_perfil.cabeceras = ["Perfil", "Fecha Alta","Fecha Baja","Comentario"];
          tabla_perfil.campos = [
              {
                  nombreCampo: "tipo_operador_desc",
                           id: "tipo_operador",
                    get_campo: function (nombreTabla, id) {
                                                           campos_defs.add(nombreTabla + "_campos_defs" + id, { 
                                                           nro_campo_tipo: 1,
                                                           enDB: false,
                                                           filtroXML: nvFW.pageContents.tOperador_tipo_filtroXML,
                                                           target: 'campos_tb_' + nombreTabla + id
                                                           });
                                                           
                                                           campos_defs.items[nombreTabla + "_campos_defs" + id]["onchange"] = tipo_operador_existe
                                                          }
              , width: "25%", editable: true
              },
              {
                  nombreCampo: "fe_alta", width: "14%", align: "center", editable: true, nro_campo_tipo: 103, enDB: false
              },
              {
                  nombreCampo: "fe_baja", width: "14%", align: "center", editable: true, nro_campo_tipo: 103, enDB: false
              },
              {
                  nombreCampo: "comentario", width: "35%", editable: true, nro_campo_tipo: 104, enDB: false
              }
          ]
      
          tabla_perfil.data = [];
      
          NOD = Node[0].childNodes
          for (i = 0; i < NOD.length; i++) {
                  var fila = {};
                  //Para cada campo recuperamos su valor y su id correspondiente en caso de contar con uno.
                  for (var index_campos = 0; index_campos < tabla_perfil.campos.length; index_campos++) {
                      var valor_campo = selectSingleNode('@' + tabla_perfil.campos[index_campos].nombreCampo, NOD[i]).value;
                      fila[tabla_perfil.campos[index_campos].nombreCampo] = valor_campo ? valor_campo : "";
                      if (tabla_perfil.campos[index_campos].id) {
                          var valor_id = selectSingleNode('@' + tabla_perfil.campos[index_campos].id, NOD[i]).value;
                          fila[tabla_perfil.campos[index_campos].id] = valor_id ? valor_id : "";
                      }
                  }

                  //Para cada campo hide recuperamos el valor y lo almacenamos en los datos de la fila.
                  for (var index_campos = 0; index_campos < tabla_perfil.camposHide.length; index_campos++)
                      fila[tabla_perfil.camposHide[index_campos].nombreCampo] = selectSingleNode('@' + tabla_perfil.camposHide[index_campos].nombreCampo, NOD[i]).value;

                  fila.tabla_control = {};
                  tabla_perfil.data.push(fila);
              }

          tabla_perfil.mostrar_tabla(tabla_perfil);

          tabla_perfil.resize();
  }

  function tipo_operador_existe(e, id)
  {
      var contar_encontrados = 0
      for (var i = 0; i < tabla_perfil.cantFilas-1 ; i++)
       {
        if (tabla_perfil.getValor("tipo_operador", i) == campos_defs.value(id))
                 contar_encontrados++
       }

      if (contar_encontrados > 1)
      {
          campos_defs.set_value(id, "") 
          parent.alert("El perfil ya fue seleccionado.")
          return
      }

  }

  function datos_cargar(Node)
  {
      Nodesdatos = Node[0].childNodes
      for (var i = 0; i < Nodesdatos.length; i++) {
          if (selectSingleNode('@campo_def', Nodesdatos[i]).value != "")
          {
              campos_defs.set_value(selectSingleNode('@campo_def', Nodesdatos[i]).value, selectSingleNode('@value', Nodesdatos[i]).value)
              campos_defs.items[selectSingleNode('@campo_def', Nodesdatos[i]).value].despliega = "arriba"
          }
      }
  }

function seleccionar_combo(cmb, valor) {
     for (var i = 0; i < $(cmb).length; i++) {
         if ($(cmb).options[i].value == valor)
             $(cmb).options[i].selected = true
     }
 }

function entidad_cargar()
 {
  $('apellido').value = ''
  $('nombres').value = ''
  $('tipo_docu').value = ''
  $('nro_docu').value = ''
  $('sexo').value = ''
  $('cuit').value = ''

  if($('nro_entidad').value > 0)
   {
     var criterio = "<nro_entidad type='igual'>" + $('nro_entidad').value + "</nro_entidad>"
     var rs = new tRS();
     rs.open(nvFW.pageContents.tEntidades_filtroXML, "", criterio, "", "")
     if (!rs.eof())
      { 
       $('apellido').value = rs.getdata('apellido')
       $('nombres').value = rs.getdata('nombres')
       $('nro_docu').value = rs.getdata('nro_docu')
       $('cuit').value = rs.getdata('cuit') == null ? '' : rs.getdata('cuit')
       seleccionar_combo('tipo_docu', rs.getdata('tipo_docu'))
       seleccionar_combo('sexo', rs.getdata('sexo'))
     }

       $('apellido').disabled = true
       $('nombres').disabled = true
       $('tipo_docu').disabled = true
       $('nro_docu').disabled = true
       $('sexo').disabled = true
       $('cuit').disabled = true
    }   
 }


function login_onblur()
{

    if ($('login').value == '') {
       
        alert("Ingrese el login para continuar.")
        return
    }

    operador_cargar()
    
}
 
 function validar_perfil() 
    {
        var strError = ''
        var strError2 = ''
        var strError3 = ''
        var titulo = ''
        var titulo2 = ''
        var titulo3 = ''
      
        if ((tabla_perfil.indexReal(tabla_perfil.cantFilas - 1)) == 0)
            strError += 'Debe seleccionar al menos un perfil.'

        if (strError != '')
         return strError

        titulo = 'La fecha de baja es menor a la fecha de alta en los siguientes perfiles:</br>'
        titulo2 = 'La fecha de alta no fue ingresada en los siguientes perfiles:</br>'
        titulo3 = 'Indique el motivo por el cual seleccion� el perfil/es:</br>'
        
        for (var i = 1; i < tabla_perfil.cantFilas; i++)
        {
            if (!tabla_perfil.getFila(i).eliminado)
            {
                fe_alta = YYYYMMDD(tabla_perfil.getFila(i).fe_alta)
                fe_baja = YYYYMMDD(tabla_perfil.getFila(i).fe_baja)
                comentario = tabla_perfil.getFila(i).comentario 
                tipo_operador_desc = tabla_perfil.getFila(i).tipo_operador_desc

                if (campos_defs.items["tabla_perfil_campos_defs_fila_" + (i) + "_columna_0"])
                    tipo_operador_desc = campos_defs.desc("tabla_perfil_campos_defs_fila_" + (i) + "_columna_0")

                if (tipo_operador_desc == ""){
                    strError += 'Unos de los perfiles esta vacio. Verifique</br>'
                    break;
                }

                if (fe_alta != '' && fe_baja != '') {
                    if (fe_baja < fe_alta)
                        strError += ' - <b>' + tipo_operador_desc + '</b>.</br>'
                }

                if (fe_alta == '') {
                    strError2 += ' - <b>' + tipo_operador_desc + '</b>.</br>'
                }

                if (fe_alta != '' && fe_baja != '') {
                    if ((fe_baja > fe_alta) && comentario == '')
                        strError3 += ' - <b>"' + tipo_operador_desc + '"</b>.</br>'
                }

            }

            if (strError != '')
                return (titulo + strError)

            if (strError2 != '')
                return (titulo2 + strError2)

            if (strError3 != '')
                return (titulo3 + strError3)

            }
     
        return strError
    }

   
   function operador_nuevo()
    {

     tabla_perfil = new tTable()

    $('tabla_perfil').innerHTML = "";

    campos_defs.items['nro_operador']['onchange'] = operador_cargar
    campos_defs.clear()


    $('operador').value = 0
    $('login').value = ''
    $('nombre_operador').value = ''
    $('nro_entidad').value = 0
    $('apellido').value = ''
    $('nombres').value = ''
    $('nro_docu').value = ''

    $('apellido').disabled = false
    $('nombres').disabled = false
    $('tipo_docu').disabled = false
    $('nro_docu').disabled = false
    $('sexo').disabled = false
    $('validador').innerHTML = ""

    btn_modificar_login(false)

    $('login').focus()

   }

    function guardar_onclick() 
    {
        if ($('login').value == '') {
            alert("Debe ingrese el login para continuar.")
            return
        }

        if ($('nro_entidad').value == 0)
        {
            alert('Debe seleccionar una entidad.')
            return
        }
        
        var strError = ""
        for (var i = 0; i < Nodesdatos.length; i++) {
            if (selectSingleNode('@campo_def', Nodesdatos[i]).value != "") {
                if (campos_defs.value(selectSingleNode('@campo_def', Nodesdatos[i]).value) == "")
                    strError += 'Debe seleccionar un valor al atributo ' + selectSingleNode('@campo_def', Nodesdatos[i]).value + '.'
            }
        }

        if (strError != '') {
            alert(strError)
            return
        }

        tabla_perfil.actualizarData();

        strError = validar_perfil()
        if (strError != '') {
            alert(strError)
            return
        }

        guardar()
    }

    var pasadas = 1
    var bajacuenta = "false"
    function guardar()
     {
        if (cuenta_set_password && $('pass').value == '' && $('pass_conf').value == '')
        {
          login_setear_pwd(false)
          return
        }
        
        if (!$('cuenta_habilitada').checked && pasadas == 1) {
            ComoGuardarEstadoCuenta()
            return
        }

        ajax_request()
    }

    function ajax_request() {
        
        //Cargar XML 
        var xmldato = ""
        xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
        xmldato += "<operador>"
        xmldato += "<operador>" + $('operador').value + "</operador>"
        xmldato += "<nombre_operador>" + $('nombre_operador').value + "</nombre_operador>"
        xmldato += "<nro_entidad>" + $('nro_entidad').value + "</nro_entidad>"
        xmldato += "<login>" + $('login').value + "</login>"
        xmldato += "<apellido>" + $('apellido').value + "</apellido>"
        xmldato += "<nombres>" + $('nombres').value + "</nombres>"
        xmldato += "<loginXML/>"

        xmldato += "<perfiles>"
        for (var index_fila = 1; index_fila < tabla_perfil.cantFilas; index_fila++) {
            if (!tabla_perfil.getFila(index_fila).eliminado)
                xmldato += "<perfil tipo_operador='" + tabla_perfil.getFila(index_fila).tipo_operador + "' tipo_operador_desc='' fe_alta='" + tabla_perfil.getFila(index_fila).fe_alta + "' fe_baja='" + tabla_perfil.getFila(index_fila).fe_baja + "' comentario ='" + tabla_perfil.getFila(index_fila).comentario + "'/>"
        }
        xmldato += "</perfiles>"

        xmldato += "<datos>"
        for (var i = 0; i < Nodesdatos.length; i++) {
            if (selectSingleNode('@campo_def', Nodesdatos[i]).value != "") {
                xmldato += "<dato name='" + selectSingleNode('@name', Nodesdatos[i]).value + "' campo_def='" + selectSingleNode('@campo_def', Nodesdatos[i]).value + "' label='" + selectSingleNode('@label', Nodesdatos[i]).value + "' value='" + campos_defs.value(selectSingleNode('@campo_def', Nodesdatos[i]).value) + "' />"
            }
        }
        xmldato += "</datos>"
        xmldato += "</operador>"

        nvFW.error_ajax_request('operador_abm.aspx', {
            parameters: {  accion: 'abm_operador'
                         , operadorXML: escape(xmldato)
                         , enebleApplication: $('cuenta_habilitada').checked.toString()
                         , bajacuenta: bajacuenta
                         , cuenta_cambiar_pwd: $('cuenta_cambiar_pwd').checked.toString()
                         , pass: $('pass').value
                         , apellido: $('apellido').value
                         , nombres: $('nombres').value
                        },
            onSuccess: function (err, transport) {
                    pasadas = 1
                    $('pass').value = ''
                    $('pass_conf').value = ''
                    bajacuenta = "false"

                    if (err.numError == 0) {
                        operador_cargar(false)
                    }
                }
            });

    }

    function window_onunload()
    {
    window.close()
    }
 
    function window_onresize()
    {
    try
     {
        var divCab_h = $('divCab').getHeight();
        var tbtabla_perfil = $('tbtabla_perfil');
        
        var body_h = $$('BODY')[0].getHeight();
        var tamanio = (body_h - divCab_h)

        tbtabla_perfil.style.height = tamanio + "px" 

        if (tabla_perfil)
            tabla_perfil.resize();

     }
        catch (e) { console.log(tbtabla_perfil.style.height) }
    }
    
    function btn_modificar_login(disabled) 
    {
        if (disabled)
        {
            $('login').disabled = true
            $('apellido').disabled = true
            $('nombres').disabled = true
        }
        else
        {
            $('login').disabled = false
            $('apellido').disabled = false
            $('nombres').disabled = false
        }
   }

   function YYYYMMDD(strFecha) 
    {
              
       if (strFecha == '' || strFecha == undefined)
            return ''
              
        anio = strFecha.split('/')[2]
        mes = parseInt(strFecha.split('/')[1]) < 10 ? '0' + parseInt(strFecha.split('/')[1]).toString() : parseInt(strFecha.split('/')[1]).toString()
        dia = parseInt(strFecha.split('/')[0]) < 10 ? '0' + parseInt(strFecha.split('/')[0]).toString() : parseInt(strFecha.split('/')[0]).toString()

        return anio + mes + dia
    }

            
    var win_history
    function historico_ver() 
    {
        if ($('operador').value > 0) {
            win_history = new Window({
                className: "alphacube",
                url: '/fw/security/operador_tipo_historial.aspx?operador_get=' + $('operador').value,
                width: 800,
                height: 200,
                draggable: true,
                resizable: true,
                closable: true,
                minimizable: false,
                maximizable: false,
                title: "<b>Historial</b>"
            })
            win_history.showCenter(true);
        }
        else
            alert("Debe seleccionar un operador.")
    }

    function permiso_ver() 
    {

        if ($('operador').value > 0) {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
            win = w.createWindow({
                className: "alphacube",
                url: '/fw/security/permiso_abm.aspx?vista=lineal&operador_get=' + $('operador').value,
                width: 900,
                height: 500,
                draggable: true,
                resizable: true,
                closable: true,
                minimizable: false,
                maximizable: false,
                title: "<b>Permiso</b>"
            })
            win.showCenter();
        }
        else
        alert("Seleccione el operador.")

    }

     
    function ComoGuardarEstadoCuenta() {
            try { win_pass.close() } catch (e) { }
            win_pass = new Window({
                className: "alphacube",
                width: 700,
                height: 150,
                draggable: false,
                resizable: false,
                closable: false,
                minimizable: false,
                maximizable: false,
                onShow: function (win) {
                }
            })

            win_pass.getContent().innerHTML = $('divComoguardarEstadoCuenta').innerHTML
            win_pass.showCenter(true);
          
    }

    function btnAceptar_hcha_onclick() {
        pasadas++
        bajacuenta = "true"
        guardar()
        win_pass.close()
    }

    function btnAceptar_ha_onclick() {
        pasadas++
        bajacuenta = "false"
        guardar()
        win_pass.close()
    }

    function btnCancelar_hcha_onclick() {
        win_pass.close()
    }

    function pwd_onkeypress(e, setea)
        {
            key = Prototype.Browser.IE ? event.keyCode : e.which
            var pwd_new = setea ? $('pass_set') : $('pass')
            var pwd_new_conf = setea ? $('pass_conf_set') : $('pass_conf')
                
            if (key == 13) {
                     
                if (pwd_new.value == '')
                    pwd_new.focus()
                else
                    if (pwd_new_conf.value == '')
                        pwd_new_conf.focus()
                    else
                        btnAceptar_pwd_set_onclick(setea)
            }
        }

        function btnCancelar_pwd_onclick()
        {
        $('pass').value = ''
        $('pass_conf').value = ''
        $('pass_set').value = ''
        $('pass_conf_set').value = ''
        win_pass.close()
        }

    function btnAceptar_pwd_set_onclick(setea)
    {
        var pwd_new = setea ? $('pass_set').value : $('pass').value
        var pwd_new_conf = setea ? $('pass_conf_set').value : $('pass_conf').value

        if (pwd_new_conf != pwd_new && !(pwd_new_conf == "" || pwd_new == "")) {
            alert('La contrase�a o la confirmaci�n no coinciden. Verifique')
            return
        }

        if (setea) {
            nvFW.error_ajax_request('/fw/nvLogin.aspx', {
                parameters: {
                            UID: $('login').value,
                            PWD: $('pass_set').value,
                            accion: "pwd_setear"},
                onSuccess: function (err, transport) {
                    $('pass_set').value = ''
                    $('pass_conf_set').value = ''
                    if (err.numError == 0) {
                        alert("La contrase�a se seteo correctamente.")
                        win_pass.close()
                    }
                }
            });
        }
        else {

            guardar()
            win_pass.close()
        }
    }

    function login_setear_pwd(setear) {

        if ((($("login").value != "" && !cuenta_set_password) && setear) || !setear) {
            var strHTML = ""
            win_pass = new Window({
                className: "alphacube",
                width: 350,
                height: 170,
                draggable: false,
                resizable: false,
                closable: false,
                minimizable: false,
                maximizable: false,
                title: "<b>Establecer contrase�a para " + $('login').value + "</b>",
                onShow: function (win) {
                    $('pass_set').focus();
                }
            })

            win_pass.getContent().innerHTML = setear ? $('divSetear_pwd').innerHTML : $('divCuenta_pwd').innerHTML
            win_pass.showCenter(true);
        }
        else
        {
            alert("El usuario debe estar dado de alta.")
            return
        }

    }

          
    function entidades_abm() 
    {
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
        win = w.createWindow({
            className: "alphacube",
            url: '/fw/funciones/entidad_consultar.aspx?nro_entidad_get=' + $('nro_entidad').value,
            width: 700,
            height: 400,
            draggable: true,
            resizable: true,
            closable: true,
            minimizable: false,
            maximizable: false,
            title: "<b>Entidad Consultar</b>",
            onClose: entidad_abm_return
        })
        win.options.userData = {}
        win.options.userData.entidad = {}
        win.showCenter(true);
          
    }

    function entidad_abm_return()
    {
        if (win.options.userData.entidad.nro_entidad)
        {
            var arr = win.options.userData.entidad
            //if (validar_entidad({ nro_docu: arr.nro_docu, tipo_docu: arr.tipo_docu, sexo: arr.sexo })) {
            //    alert("La entidad ya se encuentra asociada la aplicacion")
            //    return
            //}
      
            $('nro_entidad').value = arr.nro_entidad
            $('apellido').value = arr.apellido
            $('nombres').value = arr.nombres
            $('nro_docu').value = arr.nro_docu
            seleccionar_combo('tipo_docu', arr.tipo_docu)
            seleccionar_combo('sexo', arr.sexo)
            $('cuit').value = arr.cuit
        }
    }

</script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="height: 100%;width:100%; vertical-align: top; overflow: hidden;">
       <div id="divCab" style="width:100%">
        <div id="divOperador" style="margin: 0px; padding: 0px;"></div>
        <script  type="text/javascript">
         var DocumentMNG = new tDMOffLine;
         var vOperador = new tMenu('divOperador','vOperador');
         Menus["vOperador"] = vOperador
         Menus["vOperador"].alineacion = 'centro';
         Menus["vOperador"].estilo = 'A';
         Menus["vOperador"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")                         
         Menus["vOperador"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")  
         Menus["vOperador"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>clave</icono><Desc>Setear contrase�a</Desc><Acciones><Ejecutar Tipo='script'><Codigo>login_setear_pwd(true)</Codigo></Ejecutar></Acciones></MenuItem>")
       //  Menus["vOperador"].CargarMenuItemXML("<MenuItem id='3' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>socio</icono><Desc>Impostar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>impostar_usuario()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vOperador"].CargarMenuItemXML("<MenuItem id='4' style='WIDTH: 10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>operador_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")

         vOperador.loadImage("guardar", '/fw/image/security/guardar.png')
         vOperador.loadImage("operador", '/fw/image/security/operador.png')
         vOperador.loadImage("socio", '/fw/image/security/socio.png')
         vOperador.loadImage("nueva", '/fw/image/security/nueva.png')
         vOperador.loadImage("clave", '/fw/image/security/clave.png')
        </script>
        <table class="tb1">
         <tr>
            <td>
               <table style="width:100%;display:none">
                    <tr>
                     <td style="width: 20%; vertical-align: middle; text-align: center" nowrap='nowrap'><input type="text" style="width:100%" id='nombre_operador'/></td>
                     <td style="display:none;width: 30px; vertical-align: middle; text-align: center" nowrap='nowrap'><%= nvCampo_def.get_html_input("nro_operador")%></td>
                     <td>&nbsp;</td>
                    </tr>
               </table>
                <table style="width:100%">
                    <tr>
                       <td class="Tit1" style="width: 100%; text-align: center;font:14px arial !important " colspan="7"><%= verificacion %></td>
                    </tr>
               </table>
               <table style="width:100%">
                    <tr> 
                     <td style="width: 30%; vertical-align: middle; text-align: right"><b>Operador:</b></td>
                     <td style="width: 5%; vertical-align: middle; text-align: center"><input type="text" style="width:100%;text-align: center" id='operador' disabled="disabled" /></td>
                     <td style="width: 10%; vertical-align: middle; text-align: right"><b>Login:</b></td>
                     <td style="width: 15%; vertical-align: middle; text-align: left"><input type="text" style="width:100%;text-align: left" id='login' onblur="return login_onblur()" /></td>
                     <td>&nbsp;</td>
                    </tr>
               </table>
               <div id="divCuenta">
                    <table class="tb1">
                        <tr class="tbLabel">
                             <td style='width: 100%;text-align: left' colspan="2"><b>Estado de la Cuenta:</b>&nbsp;<div id='validador' style="display:inline-block "></div></td>
                         </tr>
                        <tr>
                            <td style="width:60%">
                               <table class="tb1">
                                   <tr>
                                        <td style='width: 50%;text-align: left'><input type="checkbox" name="cuenta_habilitada" id="cuenta_habilitada" style='width: 5%; text-align: center; border:0' />Cuenta habilitada.</td>
                                    </tr>
                                    <tr>
                                        <td style='width: 50%;text-align: left'><input type="checkbox" name="cuenta_cambiar_pwd" id="cuenta_cambiar_pwd" style='width: 5%; text-align: center; border:0' />El usuario debe cambiar la contrase�a en el siguiente inicio de sesi�n.</td>
                                    </tr>
                               </table>
                           </td>
                       </tr>
                   </table>
               </div>
            </td>
             </tr>
            </table>
            <div id="divEntidad" style="margin: 0px; padding: 0px;"></div>
                    <script  type="text/javascript">
                        var DocumentMNG = new tDMOffLine;
                        var vEntidad = new tMenu('divEntidad', 'vEntidad');
                        Menus["vEntidad"] = vEntidad
                        Menus["vEntidad"].alineacion = 'centro';
                        Menus["vEntidad"].estilo = 'A';
                        Menus["vEntidad"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;font-weight:bold'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos Personales:</Desc></MenuItem>")
                        Menus["vEntidad"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%;font-weight:bold'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Entidades</Desc><Acciones><Ejecutar Tipo='script'><Codigo>entidades_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
                        vEntidad.loadImage("editar", '/fw/image/icons/editar.png')
                        vEntidad.loadImage("buscar", '/fw/image/icons/buscar.png')
                        vEntidad.MostrarMenu()
                    </script>  
               <table style="width:100%">
                      <tr>
                         <td class="Tit4" style="width: 15%;vertical-align: middle; text-align: center;display:none" nowrap="nowrap"><b>N� Entidad</b></td>
                         <td class="Tit4" style="width: 10%;vertical-align: middle; text-align: center" colspan="2" ><b>Documento</b></td>
                         <td class="Tit4" style="width: 5%;vertical-align: middle; text-align: center"><b>Sexo</b></td>
                         <td class="Tit4" style="width: 15%;vertical-align: middle; text-align: center"><b>CUIT/CUIL</b></td>
                         <td class="Tit4" style="width: 8%; vertical-align: middle; text-align: center" nowrap="nowrap"><b>Apellido</b></td>
                         <td class="Tit4" style="vertical-align: middle; text-align: center" nowrap="nowrap"><b>Nombre</b></td>
                      </tr>
                      <tr>
                         <td style="width: 10%;vertical-align: middle;display:none"><input type="text" name="nro_entidad" id="nro_entidad" style='width: 100%; text-align: center' disabled="disabled" /></td>
                         <td style="width: 8%;vertical-align: middle; text-align: left" disabled="disabled"><select id="tipo_docu" style="width:100%"><option value="3" selected="selected">DNI</option><option value="1">LE</option><option value="2">LC</option></select></td>
                         <td style="width: 10%;vertical-align: middle; text-align: left" disabled="disabled"><input type="text" name="nro_docu" id="nro_docu" style='width: 100%; text-align: right' onkeypress='return valDigito(event)' /></td>
                         <td style="width: 10%; vertical-align: middle" disabled="disabled"><select id="sexo" style="width:100%" disabled="disabled" ><option value="M" selected="selected">Masculino</option><option value="F">Femenino</option></select></td>
                         <td style="width: 15%;vertical-align: middle; text-align: left" disabled="disabled"><input type="text" name="cuit" id="cuit" style='width: 100%; text-align: right' onkeypress='return valDigito(event)' /></td>
                         <td style="width: 25%; vertical-align: middle" disabled="disabled"><input type="text" name="apellido" id="apellido" style='width: 100%; text-align: left' disabled="disabled" /></td>
                         <td style="vertical-align: middle" disabled="disabled"><input type="text" name="nombres" id="nombres" style='width: 100%; text-align: left' /></td>
                      </tr>
                </table> 
      
       
       <table style="width:100%">
                        <%
                            For Each dato As Object In nvFW.nvApp.getInstance().operador.datos.values
                                Response.Write("<tr><td class='Tit2' style='width: 100%; vertical-align: middle; text-align: left' nowrap='nowrap'><b>" & dato.label & "</b></td></tr>")
                                Response.Write("<tr><td style='width: 100%;vertical-align: middle; text-align: center' nowrap='nowrap'>")
                                Response.Write(nvCampo_def.get_html_input(campo_def:=dato.campo_def.ToString, enDB:=True))
                                Response.Write("</td></tr>")
                            Next
                        %> 
                    
            </table> 
         <div id="divMemuPerfil" style="margin: 0px; padding: 0px;"></div>
                    <script  type="text/javascript">
                        var DocumentMNG = new tDMOffLine;
                        var vMemuPerfil = new tMenu('divMemuPerfil', 'vMemuPerfil');
                        Menus["vMemuPerfil"] = vMemuPerfil
                        Menus["vMemuPerfil"].alineacion = 'centro';
                        Menus["vMemuPerfil"].estilo = 'A';
                        Menus["vMemuPerfil"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;font-weight:bold'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Perfiles:</Desc></MenuItem>")
                        vMemuPerfil.MostrarMenu()
                    </script>  
       </div>
       <div id="tbtabla_perfil" style="width: 100%;min-height:100px">
            <div id="tabla_perfil" style="width: 100%;"></div>
       </div>

      <div  id="divCuenta_pwd" style="width: 100%;display: none">
                  <table class="tb1" style="width:100%;background-color:#FFFBFF !Important">
                    <tr>
                     <td style="width:100%">
                       <table class="tb1" style="width:100%">
                          <tr>
                             <td colspan="2" id="tdNwpwd_t"></td>
                        </tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        <tr>
                        <tr style="padding-bottom:10px">
                            <td style="width: 30%;white-space: nowrap;padding-top:5px">Contrase�a nueva:&nbsp;&nbsp;</td>
                            <td><input type="password" id="pass" tabindex="1" style="width: 90%;margin-top:5px" onkeypress="pwd_onkeypress(event,false)" /></td>
                        </tr>
                        <tr>
                           <td style="width: 30%;white-space: nowrap;padding-top:5px">Confirmar contrase�a:&nbsp;&nbsp;</td>
                            <td><input type="password" id="pass_conf" tabindex="2" style="width: 90%;margin-top:5px" onkeypress="pwd_onkeypress(event,false)" /></td>
                        </tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        </tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        </tr>
                        <tr>
                            <td style="width:100%; text-align:center; vertical-align:middle" colspan="2">
                                <table style="width:100%">
                                    <tr>
                                        <td style="width: 50%; text-align: center">
                                            <div id="divbtnAceptar_pwd" style="width:100%"></div>
                                        </td>
                                        <td style="text-align: center">
                                            <div id="divbtnCancelar_pwd" style="width:100%"></div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                       </table>
                     </td>
                   </tr>
                 </table>   
                </div>
     <div  id="divSetear_pwd" style="width: 100%;display: none">
                  <table class="tb1" style="width:100%;">
                    <tr>
                     <td style="width:100%">
                       <table class="tb1" style="width:100%">
                        <tr>
                             <td colspan="2" class="tdTitulosetearpwd"></td>
                        </tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        <tr>
                        <tr>
                            <td style="width: 30%;white-space: nowrap;padding-top:5px">Contrase�a nueva:&nbsp;&nbsp;</td>
                            <td><input type="password" id="pass_set" autocapitalize="off" tabindex="1" style="width: 90%;margin-top:5px" onkeypress="pwd_onkeypress(event,true)" /></td>
                        </tr>
                        <tr>
                           <td style="width: 30%;white-space: nowrap;padding-top:5px">Confirmar contrase�a:&nbsp;&nbsp;</td>
                            <td><input type="password" id="pass_conf_set" autocapitalize="off" tabindex="2" style="width: 90%;margin-top:5px" onkeypress="pwd_onkeypress(event,true)" /></td>
                        </tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        <tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        </tr>
                        <tr>
                            <td style="width:100%; text-align:center; vertical-align:middle" colspan="2">
                                <table style="width:100%">
                                    <tr>
                                        <td style="width: 50%; text-align: center">
                                            <div id="divbtnAceptar_pwd_set" style="width:100%"></div>
                                        </td>
                                        <td style="text-align: center">
                                            <div id="divbtnCancelar_pwd_set" style="width:100%"></div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                       </table>
                     </td>
                   </tr>
                 </table>   
                </div>
     <div  id="divComoguardarEstadoCuenta" style="width: 100%;display: none">
                  <table class="tb1" style="width:100%">
                    <tr>
                     <td style="width:100%">
                       <table style="width:100%" class="tb1">
                           <tr>
                               <td colspan="5"><b>Usted no habilit� la cuenta</b>.&nbsp;Seleccione que desici�n desea tomar:</td>
                           </tr>
                            <tr>
                               <td colspan="5">&nbsp;</td>
                           </tr>
                           <tr>
                               <td colspan="5">- Dehabilitar cuenta: el usuario no podra ingresar a ningun servicio de la empresa.</td>
                           </tr>
                           <tr>
                               <td colspan="5">- Deshabilitar acceso a la aplicaci�n: el operador no tendra acceso a la aplicaci�n <b><%= nvApp.sistema  %></b>.</td>
                           </tr>
                           <tr>
                               <td colspan="5">&nbsp;</td>
                           </tr>
                           <tr>
                            <td style="width:100%; text-align:center; vertical-align:middle" colspan="2">
                                <table style="width:100%">
                                    <tr>
                                        <td style="width: 33%; text-align: center">
                                            <div id="divbtnAceptar_hcha" style="width:100%"></div>
                                        </td>
                                        <td style="width: 2%; text-align: center">&nbsp;</td>
                                        <td style="width: 33%; text-align: center">
                                            <div id="divbtnAceptar_ha" style="width:100%"></div>
                                        </td>
                                        <td style="width: 5%; text-align: center">&nbsp;</td>
                                        <td style="text-align: center">
                                            <div id="divbtnCancelar_hcha" style="width:100%"></div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                       </table>
                     </td>
                   </tr>
                 </table>   
      </div>
</body>
</html>
