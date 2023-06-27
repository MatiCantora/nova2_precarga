<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim fecha = nvFW.nvUtiles.obtenerValor("fecha", "10/26/2010")
    Dim hora_fraccion = nvFW.nvUtiles.obtenerValor("hora_fraccion", "")
    Dim esquema_h = nvFW.nvUtiles.obtenerValor("esquema_h", "")
    Dim privacidad = nvFW.nvUtiles.obtenerValor("privacidad", "")
    Dim nro_period = nvFW.nvUtiles.obtenerValor("nro_period", "")
    Dim tiene_autorun = nvFW.nvUtiles.obtenerValor("tiene_autorun", "")
    
    Me.contents("filtroTareasConsultar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>%strFe_desde%</fe_desde><fe_hasta DataType='datetime'>%strFe_hasta%</fe_hasta><strWhere>%strWhere%</strWhere><strOrder>%strOrder%</strOrder></parametros></procedure></criterio>")
    
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Calendario Dia</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit() %>

    <style type="text/css">
        .tbHoy, .tdTarea, .divTarea, .tbTarea, .tbTarea tr td {
	        font: 12px Arial, Helvetica, sans-serif;
        }
        .tbHoy {
	        width: 100%;
	        background-color: #BDD2EC;
	        border: 0px;
	        padding: 0px;
        }
        .tdTarea {
	        vertical-align: middle;
	        border-bottom: solid 1px #FFEFC7;
	        padding: 0px;
	        background: #FFFFD5;
	        height: 20px;
        }
        .tdHoraH, .tdHoraM {
            width: 75px;
            vertical-align: middle;
            background: #D4D0C8;
            border-top: solid 1px #808080;
            border-bottom: solid 1px #808080;
            text-align: center;
        }
        .tdHoraH {
	        font-size: 15px;
	        font-weight: bolder;
        }
        .tdHoraM {
	        font-size: 12px;
	        height: 20px;
        }
        .spanTarea {
	        width: 150px;
	        height: 18px;
	        border: solid 1px gray;
        }
        .divTarea {
	        position: absolute;
	        float: left;
	        z-index: 1;
	        width: 200px;
	        vertical-align: middle;
	        padding: 0px;
	        border: solid 1px silver;
	        background-color: #FFFFFF
        }
        div.divTarea:hover {
	        border: solid 1px #749BC4; 
	        background-color: #F0FFFF;
        }	
        .tbTarea {
	        width: 100%;
            height: 100%;
	        border: 0px;
	        padding: 0px;
        } 
        .tbTarea tr td {
	        vertical-align: top
        }
        .tdTarea_sep {
	        background-color: blue;
	        width: 5px;
        }
    </style>
    <script type="text/javascript">
        
        var param_nro_period = '<% = nro_period  %>',
            param_tiene_autorun = '<% = tiene_autorun %>',
            param_privacidad = '<% = privacidad  %>',
            param_fecha = '<%= fecha %>',
            param_hora_fraccion = '<%= hora_fraccion %>',
            param_esquema_h = '<%= esquema_h %>'

        var fe_hoy = new Date()
        
        if (param_fecha != '')
            fe_hoy = new Date(param_fecha)
        
        var fe_manana = new Date(fe_hoy.valueOf() + 86400000),
            fe_vista = param_fecha == '' ? new Date() : new Date(Date.parse(param_fecha)),
            hora_fraccion = param_hora_fraccion == '' ? 2 : param_hora_fraccion,
            //esquema_h = param_esquema_h == '' ? 1 : eval(param_esquema_h),
            esquema_h = param_esquema_h == '' ? 1 : +param_esquema_h, // + adelante de un String numerico lo conviente al tipo Number: +"5" => 5
            horario_esquema = {}
        
        switch (esquema_h) {
            case 1:
                horario_esquema[0] = {}
                horario_esquema[0]['min'] = 0
                horario_esquema[0]['max'] = 24
                break
            case 2:
                horario_esquema[0] = {}
                horario_esquema[0]['min'] = 8
                horario_esquema[0]['max'] = 19
                break
        }
        
        function control_esquema(fecha, esquema) {
            var valor = fecha.getHours(),
                fraccion = fecha.getMinutes() == 0 ? 0 : (fecha.getMinutes() * 100 / 60),
                bandera = false

            fraccion /= 100
            valor += fraccion

            for (var i in esquema)
                if (valor >= esquema[i]['min'] && valor < esquema[i]['max'])
                    bandera = true

            return bandera
        }

        var hoy_fraciones = {},
            tareas = {},
            dias = new Array(),
            meses = new Array()

        dias[0] = "Domingo"
        dias[1] = "Lunes"
        dias[2] = "Martes"
        dias[3] = "Miercoles"
        dias[4] = "Jueves"
        dias[5] = "Viernes"
        dias[6] = "Sabado"

        meses[0] = "enero"
        meses[1] = "febrero"
        meses[2] = "marzo"
        meses[3] = "abril"
        meses[4] = "mayo"
        meses[5] = "junio"
        meses[6] = "julio"
        meses[7] = "agosto"
        meses[8] = "septiembre"
        meses[9] = "octubre"
        meses[10] = "noviembre"
        meses[11] = "diciembre"

        function TiempoToSTR(objFecha) {
            horas = parseInt(objFecha.getHours(), 10) 
            minutos = parseInt(objFecha.getMinutes(), 10) 
          
            horas = horas < 10 ? '0' + horas : horas
            minutos = minutos < 10 ? '0' + minutos : minutos

            return horas + ':' + minutos
        }

        function date_to_str(fecha) {
            var str = dias[fecha.getDay()] + ', '
            str += fecha.getDate() + ' de ' + meses[fecha.getMonth()] + ' de ' + fecha.getFullYear()
            
            return str
        }

        function int_to_str(num, largo, relleno) {
            if (!relleno)
                relleno = '0'
            
            var str = num.toString()
            
            while (str.length < largo)
                str = relleno + str
            
            return str
        }

        function hoy_dibujar() {
            hoy_fraciones = {}
            $("tdFecha_actual").innerHTML = ''
            $("tdFecha_actual").innerHTML = date_to_str(fe_vista)

            var tbHoyTitulo = $("tbHoyTitulo"),
                style_fin_fraccion = '',
                style_inicio_fraccion = '',
                fe_fraccion ,
                id_fraccion = 0,
                strHTML = '<table border="0" cellspacing="0" cellpadding="0" class="tbHoy">'

            for (var hora = 0; hora < 24; hora++)
                for (var fraccion = 0; fraccion < hora_fraccion; fraccion++) {
                    id_fraccion++
                    fe_fraccion = new Date(fe_vista.getFullYear(), fe_vista.getMonth(), fe_vista.getDate(), hora, (60 / hora_fraccion) * fraccion)
                    //controlar que el horario este dentro del esquema
                    if (!control_esquema(fe_fraccion, horario_esquema))
                        continue

                    hoy_fraciones[id_fraccion] = {}
                    hoy_fraciones[id_fraccion].tdID = "tdHoyFrac_" + id_fraccion
                    hoy_fraciones[id_fraccion].fe_fraccion = fe_fraccion
                    hoy_fraciones[id_fraccion].fe_hasta = new Date(fe_fraccion.valueOf() + (60 / hora_fraccion) * 60000)
                  
                    strHTML += '<tr>'
                  
                    if (fraccion == 0) {
                        style_inicio_fraccion = "border-top: solid 1px #EAD098"
                        strHTML += '<td class="tdHoraH" style="width: 30px" rowspan="' + hora_fraccion + '">' + int_to_str(hora, 2) + '</td>'
                    }
                    else {
                        style_inicio_fraccion = ""
                    }

                    strHTML += '<td class="tdHoraM" style="width: 25px">:' + int_to_str((60 / hora_fraccion) * fraccion, 2) + '</td><td id="tdHoyFrac_' + id_fraccion + '" class="tdTarea" style="' + style_inicio_fraccion + '" ondblclick="return tarea_abm(\'0\',\''+ param_fecha + ' ' + int_to_str(hora, 2) + ':' + int_to_str((60 / hora_fraccion) * fraccion, 2) + '\')">&nbsp;</td></tr>' //<span class="spanTarea">tarea</span>
                }
            
            strHTML += '</table>'

            $("divHoy").insert({ bottom: strHTML })
            hoy_linea_hora()
        }

        function hoy_linea_hora() {
            var strHTML = "<H1 id='divLinea_hora' style='position:absolute; float:left; z-index:0; width: 100%; border-top:dashed 2px gray; height: 0px; margin: 0px; padding:0px' />"
            $("divHoy").insert({top:strHTML})
            var linea = $('divLinea_hora')

            linea.hide()

            var ahora = new Date()

            for (var id_fraccion in hoy_fraciones) {
                var td = $('tdHoyFrac_' + id_fraccion),
                    frac_ms = (60 / hora_fraccion) * 30000,
                    mod
                
                if (ahora >= hoy_fraciones[id_fraccion].fe_fraccion && ahora < hoy_fraciones[id_fraccion].fe_hasta) {
                    x = ahora.getMinutes() % (60 / hora_fraccion) / ((60 / hora_fraccion))
                    var top = td.positionedOffset().top + (td.getHeight() * x)
                    linea.setStyle({top: top + 'px'})
                    linea.show()
                    
                    return
                }
            }  
        }

        function tareas_consultar() {
            var rs = new tRS()
            rs.async = true
            rs.onComplete = tareas_dibujar

            var strWhere = param_privacidad == '' ? '' : ' privacidad in (' + param_privacidad + ') '

            if (param_nro_period == '0')
                strWhere += strWhere == '' ? ' (nro_period = 1 or nro_period is null) ' : ' and (nro_period = 1 or nro_period is null) '
            
            if (param_nro_period == '1')
                strWhere += strWhere == '' ? ' nro_period > 1 ' : ' and nro_period > 1 '

            if (param_tiene_autorun == '0')
                strWhere += strWhere == '' ? ' tiene_autorun = 0 ' : ' and tiene_autorun = 0 '
            
            if (param_tiene_autorun == '1')
                strWhere += strWhere == '' ? ' tiene_autorun = 1 ' : ' and tiene_autorun = 1 '   

            var strOrder = 'fe_inicio',
                strFe_desde = FechaToSTR(fe_hoy, 2),
                strFe_hasta = FechaToSTR(fe_manana, 2),
                filtroXML = nvFW.pageContents.filtroTareasConsultar,
                params = "<criterio><params strFe_desde='" + strFe_desde + "' strFe_hasta='" + strFe_hasta + "' strWhere='" + strWhere + "' strOrder='" + strOrder + "'/></criterio>"

            rs.open({
                filtroXML: filtroXML,
                params: params
            })
        }
          
        function tareas_dibujar(rs) {
            if (rs != undefined) {
                tareas = {}
                while (!rs.eof()) {
                    tareas[rs.position] = new tTarea(rs)
                    rs.movenext()
                }
            }  
            
            for (var id in tareas) {
                if (tareas[id].div == null) {
                    var body = $$("BODY")[0]
                    $("divHoy").insert({top: tareas[id].getHTML()})
                    tareas[id].div = $("divTarea_" + id)
                    tareas[id].setPosition()
                }
            }
        }

        function tTarea(rs) {
            this.id = rs.position
            this.nro_tarea = rs.getdata("nro_tarea")
            this.nro_rep = rs.getdata("nro_rep")
            this.fe_inicio = parseFecha(rs.getdata("fe_inicio"))
            this.fe_inicio_sinformato = rs.getdata("fe_inicio")
            this.fe_fin = parseFecha(rs.getdata("fe_fin"))
            this.asunto = rs.getdata("asunto")
            this.nro_tipo_period = rs.getdata("nro_tipo_period")
            this.nro_tarea_pri = rs.getdata("nro_tarea_pri")
            this.tiene_autorun = rs.getdata("tiene_autorun")
            this.nro_tarea_estado = rs.getdata("nro_tarea_estado")
            this.fe_vencimiento = rs.getdata("fe_vencimiento")
            this.id_noti = rs.getdata("id_noti")
            this.fe_dif_tarea_noti = rs.getdata("fe_dif_tarea_noti")
            this.operador = rs.getdata("operador")
            this.login = rs.getdata("Login")
            this.tarea_vencida = rs.getdata("tarea_vencida")
            this.div = null
            this.getHTML = tTarea_getHTML
            this.strHTML = null
            this.setPosition = tTarea_setPosition

            return this
        }
         
        function tTarea_setPosition() {
            var new_def = {}
            new_def.top = null
            new_def.left = null
            new_def.bottom  = null
            new_def.right = null

            //Calcular top y bottom
            for (var id_fraccion in hoy_fraciones) {
                var td = $('tdHoyFrac_' + id_fraccion),
                    frac_ms = (60 / hora_fraccion) * 30000,
                    mod

                if (new_def.left == null) {
                    new_def.left = td.positionedOffset().left + 5
                    new_def.right = new_def.left + 200
                }

                if (new_def.top == null && this.fe_inicio <= hoy_fraciones[id_fraccion].fe_fraccion) {
                    new_def.top = td.positionedOffset().top
                }
              
                if (new_def.top == null && this.fe_inicio <  hoy_fraciones[id_fraccion].fe_hasta) {
                    x = this.fe_inicio.getMinutes() % (60 / hora_fraccion) / ((60 / hora_fraccion))
                    new_def.top = td.positionedOffset().top + (td.getHeight() * x)
                }

                if (this.fe_fin < hoy_fraciones[id_fraccion].fe_hasta && this.fe_fin >= hoy_fraciones[id_fraccion].fe_fraccion) {
                    x = this.fe_fin.getMinutes() % (60 / hora_fraccion) / ((60 / hora_fraccion))
                    new_def.bottom = td.positionedOffset().top + (td.getHeight() * x)
                }  

                if (this.fe_fin > hoy_fraciones[id_fraccion].fe_hasta) {
                    new_def.bottom = td.positionedOffset().top + td.getHeight()
                }      
            }
          
            // Ajustar si fe_fin es nulo
            if (this.fe_fin == null)  
                new_def.bottom = new_def.top + 20 
          
            // Controlar si no hay que mostrar
            if (new_def.top == null || new_def.bottom == null)
                this.div.hide()
            else {
                // Calcular left
                for (var i = 0; i < this.id; i++)
                    if (tareas[i].div.visible() && ((this.fe_inicio >= tareas[i].fe_inicio && this.fe_inicio <= tareas[i].fe_fin) || (this.fe_fin >= tareas[i].fe_inicio && this.fe_fin <= tareas[i].fe_fin) || (tareas[i].fe_inicio >= this.fe_inicio && tareas[i].fe_inicio <= this.fe_fin))) {
                        new_def.left = tareas[i].div.positionedOffset().left + 210
                        new_def.right = new_def.left + 200
                    }
                this.div.setStyle({top: new_def.top+'px', left:new_def.left+'px', width:(new_def.right - new_def.left)+'px', height:(new_def.bottom - new_def.top)+'px'})
            }
        }

        function tTarea_getHTML() {
            if (this.strHTML == null) {
                var strHTML = "<div class='divTarea' id='divTarea_" + this.id + "'"

                if (this.fe_fin == null)
                    strHTML += " style='border: solid 2px green' "
                else
                    strHTML += " style='border-left: solid 5px blue' "  

                strHTML += ">"
                strHTML += "<table class='tbTarea' border='0' cellpadding='0' cellspacing='0'>"
                strHTML += "<tr>"

                var font = ''
            
                if (this.nro_tarea_estado == 1 || this.nro_tarea_estado == 2)
                    font = "font-weight:bold !Important;color:blue !Important"
            
                var titleHTML = "+ Tarea: " + this.nro_tarea + " - " + this.asunto.substring(0,15) + " \n",
                    eti_img_est = ""
            
                if (this.nro_tarea_estado == 3) {
                    font = "text-decoration:line-through !Important;font-weight:bold !Important;color:black !Important"
                    titleHTML += "+ Estado: Completa \n"
                    eti_img_est = "<img src='/wiki/image/icons/completado.png' style='vertical-align:middle !Important'/>"
                } 

                if(this.tarea_vencida == 1) {
                    font = "font-weight:bold !Important;color:red !Important" 
                    titleHTML += "+ Vencida: Si \n"  
                } 

                titleHTML += "+ Prioridad:"  // prioridad 
            
                var eti_img_pri = ""

                switch (parseInt(this.nro_tarea_pri)) {
                    case 1:
                        titleHTML += " Alta \n"
                        eti_img_pri = "<img src='/wiki/image/icons/pri_alta.png' style='vertical-align:middle !Important'/>"
                        break
                    case 2:
                        titleHTML += " Normal \n"
                        eti_img_pri = "<img src='/wiki/image/icons/pri_normal.png' style='vertical-align:middle !Important' />"
                        break
                    case 3:
                        titleHTML += " Baja \n"
                        eti_img_pri = "<img src='/wiki/image/icons/pri_baja.png' style='vertical-align:middle !Important'/>"
                        break
                }

                var eti_img_perio = ''
            
                if (this.nro_rep > 1) {
                    titleHTML += "+ Periodica: Si \n" 
                    eti_img_perio = "<img src='/wiki/image/icons/periodicidad.png' style='vertical-align:middle !Important' />"
                } 
            
                if (this.nro_rep == 1 && this.nro_tipo_period != null) {
                    titleHTML += "+ Periodicidad: Origen \n" 
                    eti_img_perio = "<img src='/wiki/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />"
                }
           
                var eti_img_autorun = ''

                if (this.tiene_autorun == 'True') {
                    titleHTML += "+ Ejecución Automática: Si \n"
                    eti_img_autorun = "<img src='/wiki/image/icons/auto_run.png' style='vertical-align:middle !Important' />"
                }

                var eti_img_noti = ''

                if (this.id_noti > 0) {
                    titleHTML += "+ Noti: " + FechaToSTR(parseFecha(this.fe_dif_tarea_noti)) + " " + TiempoToSTR(parseFecha(this.fe_dif_tarea_noti)) + " \n" 
                    eti_img_noti += "&nbsp;<img src='/wiki/image/icons/aviso.png' style='vertical-align:middle !Important'/>"
                }

                var nro_rep = (this.nro_rep == 1 && this.nro_tipo_period == null) ? 0 : this.nro_rep  // en el caso que no tenga periodicidad

                strHTML += "<td title='" + titleHTML + "' style='cursor: default; vertical-align: middle;" + font + "' ondblclick='return tarea_ondblclick(" + this.nro_tarea + ", \"" + this.fe_inicio_sinformato + "\", " + nro_rep + "," + this.id + ")'>" 
                strHTML += "&nbsp;" + TiempoToSTR(this.fe_inicio) + "&nbsp;"
                strHTML += eti_img_pri
                strHTML += eti_img_perio
                strHTML += eti_img_autorun
                strHTML += ' ' + this.asunto.substring(0,15)
                strHTML += eti_img_est
                strHTML += eti_img_noti
                strHTML += "</td></tr></table>"
                strHTML += "</div>"

                this.strHTML = strHTML
            }
            
            return this.strHTML  
        }     

        function window_onload() {
            hoy_dibujar()
            tareas_consultar()
            tareas_dibujar()
        }  
        
        var id

        function tarea_ondblclick(nro_tarea, fe_inicio, nro_rep, id_click) {
            id = id_click
            tarea_abm(nro_tarea, fe_inicio, nro_rep)
        }
          
        function tarea_abm(nro_tarea, fe_inicio, nro_rep) {
            fe_inicio = fe_inicio == undefined ? '' : fe_inicio
            nro_rep = nro_rep == undefined ? 0 : nro_rep
            
            window.top.win = window.top.nvFW.createWindow({
                url: '/wiki/tarea_abm.aspx?nro_tarea_get=' + nro_tarea + '&fe_inicio_get=' + fe_inicio + '&nro_rep_get=' + nro_rep,
                title: '<b>Tarea</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 1024,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                onClose: tarea_abm_return
            });

            window.top.win.showCenter(true)
        }

        function tarea_abm_return() {
            for (var id in tareas) {
                $('divTarea_'+id).innerHTML = ''
                $('divTarea_'+id).hide()
            }

            if ((window.top.win.returnValue != undefined) || (id != undefined))  
                tareas_consultar()
        }

        function set_hoy(dias) {
            //var hora_fraccion
            //var esquema_h = cb.options(cb.options.selectedIndex).value
            var fecha = new Date(fe_vista.valueOf() + (86400000 * dias))
            //window.parent.set_fecha(fecha)

            win = ObtenerVentana("FrameResultado")
            win.location.href = "calendario_dia.aspx?fecha=" + FechaToSTR(fecha, 2) + '&hora_fraccion=' + hora_fraccion + "&esquema_h=" + esquema_h
        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto">
    <table class="tb1">
        <tr>
            <td>
                <table style="width:100%;height:20px !Important" id="tbHoyTitulo" >
                    <tr>
                        <td style="width: 25%">&nbsp;</td>
                        <td style="text-align: center; cursor: hand; cursor: pointer;" onclick="return set_hoy(-1)">
                            <img alt="Anterior" title='Anterior' src='/wiki/image/icons/anterior.png' style='vertical-align:middle !Important'/>
                        </td>
                        <td id="tdFecha_actual" style="text-align: center;font: 13px Arial, Helvetica, sans-serif;font-weight:bold !Important;"></td>
                        <td style="text-align: center; cursor: hand; cursor: pointer;" onclick="return set_hoy(1)">
                            <img alt="Siguiente" title='Siguiente' src='/wiki/image/icons/siguiente.png' style='vertical-align:middle !Important'/>
                        </td>
                        <td style="width: 25%">
                            &nbsp;
                        </td>
                    </tr>
                </table>
           </td>
        </tr>
    </table>        
            
    <div id="divHoy" style="width: 100%; overflow: auto"></div>
</body>
</html>