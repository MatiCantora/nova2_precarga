//############################################
//#######-----MOTOR COMPATIBILIDAD-----#######
//############################################

const motor = {
    get: function (etiqueta) {
        var retorno = ''
        switch (etiqueta) {
            case 'sueldo_bruto':
                retorno = (consulta.oferta.sueldo_bruto) ? this.datos.sueldo_bruto : "0"
                break;
            case 'sueldo_neto':
                retorno = (consulta.oferta.sueldo_neto) ? this.datos.sueldo_neto : "0"
                break;
            case 'disponible':
                //var tiene_oferta = this.tiene_ofertas()
                let importe_disponible = 0;
                //var nro_banco = $F("banco")
                //var nro_mutual = $F("mutual")
                //var nro_analisis = $F('cbAnalisis')
                //importe_disponible=parseFloat((this.datos.trabajo)?this.datos.trabajo.disponible:"0")
                importe_disponible = parseFloat((consulta.oferta.disponible) ? consulta.oferta.disponible : "0")
                //if (tiene_oferta) {
                //    var aOferta = motor.ofertas.filter(oferta => oferta.nro_banco == nro_banco && oferta.nro_mutual == nro_mutual && oferta.nro_analisis == nro_analisis)
                //    if (aOferta.length > 0) {
                //        importe_disponible = aOferta[0].disponible
                //    }
                //}

                ///*if(this.tiene_ofertas() && aOferta.length>0){
                //  importe_disponible=aOferta[0].disponible
                //}else{
                //  importe_disponible=parseFloat((this.datos.cupo_disponible)?this.datos.cupo_disponible:"0")  
                //} */
                retorno = importe_disponible
                break;
            case 'desc_ley':
                retorno = (consulta.oferta.desc_ley) ? consulta.oferta.desc_ley : "0"
                break;
            case 'cuota_maxima':
                //if (!this.tiene_ofertas()) return "";
                //var nro_banco = $F("banco")
                //var nro_mutual = $F("mutual")
                //var nro_analisis = $F('cbAnalisis')
                //var aOferta = motor.ofertas.filter(oferta => oferta.nro_banco == nro_banco && oferta.nro_mutual == nro_mutual && oferta.nro_analisis == nro_analisis)
                //if (aOferta.length > 0) {
                //    var cuota_maxima = aOferta[0].cuota_maxima
                //    var importe_cuota_social = +this.get('importe_cs')
                //    if (importe_cuota_social > 0) {
                //        cuota_maxima = cuota_maxima - importe_cuota_social
                //    }
                //    retorno = cuota_maxima
                //}
                
                retorno = parseFloat((consulta.oferta.cuota_maxima) ? consulta.oferta.cuota_maxima : "0")
                retorno += parseFloat(consulta.cancelacion.LiberaCuota) //le sumo las cuotas liberadas (si es q hay)
                break;
            case 'neto_maximo':
                //if (!this.tiene_ofertas()) return "";
                //var nro_banco = $F("banco")
                //var nro_mutual = $F("mutual")
                //var nro_analisis = $F('cbAnalisis')
                //var aOferta = motor.ofertas.filter(oferta => oferta.nro_banco == nro_banco && oferta.nro_mutual == nro_mutual && oferta.nro_analisis == nro_analisis)
                //if (aOferta.length > 0) {
                //    retorno = aOferta[0].neto_maximo
                //}
                retorno = parseFloat((consulta.oferta.neto_maximo) ? consulta.oferta.neto_maximo : "0")

                break;
            case 'max_cuotas':
                //gjmo -> ver de donde sale
                if (!this.tiene_ofertas()) return "";
                var nro_banco = $F("banco")
                var nro_mutual = $F("mutual")
                var nro_analisis = $F('cbAnalisis')
                var aOferta = consulta.ofertas.filter(oferta => oferta.nro_banco == nro_banco && oferta.nro_mutual == nro_mutual && oferta.nro_analisis == nro_analisis)
                if (aOferta.length > 0) {
                    retorno = aOferta[0].max_cuotas
                }
                break;
            case 'bcra_calificacion_cendeu':
                retorno = consulta.oferta.bcra_calificacion_cendeu
                break;
            case 'estado':
                //gjmo -> ver de donde sale
                if (!this.tiene_ofertas()) return "";
                var nro_banco = $F("banco")
                var nro_mutual = $F("mutual")
                var nro_analisis = $F('cbAnalisis')
                var aOferta = consulta.ofertas.filter(oferta => oferta.nro_banco == nro_banco && oferta.nro_mutual == nro_mutual && oferta.nro_analisis == nro_analisis)
                if (aOferta.length > 0) {
                    retorno = aOferta[0].estado
                }
                break;
            case 'importe_cs':
                var importe_cs = 0
                var nro_grupo = consulta.resultado.nro_grupo;
                var nro_mutual = $F("mutual")
                var socio_nuevo = (consulta.oferta.socio_nuevo) ? consulta.oferta.socio_nuevo : "0"
                if (socio_nuevo == "1") {
                    var rsN = new tRS()
                    rsN.async = false
                    rsN.open({
                        filtroXML: nvFW.pageContents["precarga_cuota_social"],
                        params: "<criterio><params nro_grupo='" + nro_grupo + "' nro_mutual='" + nro_mutual + "' /></criterio>"
                    })
                    if (!rsN.eof()) {
                        importe_cs = rsN.getdata('importe_cuota');
                    }
                }//if socio_nuevo
                retorno = importe_cs
                break;
            default:
                alert('Error al evaluar ' + etiqueta)
                return;

                //if (this.datos[etiqueta]) {
                //    retorno = (isNaN(this.datos[etiqueta].replace(",", ".")) ? this.datos[etiqueta] : (+(this.datos[etiqueta].replace(",", "."))))
                //}
                //console.log(etiqueta + " valor " + retorno)
        }//switch   
        return retorno;
    }
}