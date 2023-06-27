		
		
		function tWikiPermisoRef() {
		

			var permiso_referencia = 0

			var cargarPermisoReferencia =  function(nro_ref)
			{
				if (nro_ref == undefined || nro_ref == "") {
					permiso_referencia = 0
					return
				}

				nvFW.error_ajax_request("/wiki/default.aspx", {
					asynchronous: true, // sincrono para que se cargue antes de accion de usuario
					parameters: {
						modo:    'get_permiso_referencia',
						nro_ref: nro_ref
					},
					onSuccess: function(err) {
						permiso_referencia = parseInt(err.params["permiso_referencia"], 10)
					},
					onFailure: function(err) {
						permiso_referencia = 0
					},
					bloq_contenedor_on: false,  // no bloquear, solo se usa de llamada
					error_alert: false
				})
			}


			/*----------------------------------------------------------------
			|   tipo_permiso: valores posibles
			|-----------------------------------------------------------------
			| #     | Valor | Descripción
			|-----------------------------------------------------------------
			| [1]   | 1     | subir archivo
			| [2]   | 2     | borrar
			| [3]   | 4     | modificar
			| [4]   | 8     | leer (por defecto)
			| [5]   | 16    | administrar permisos
			| [6]   | 31    | TODOS los permisos (suma todos los anteriores)
			|---------------------------------------------------------------*/
			var tienePermisoReferencia =  function(tipo_permiso, nro_ref)
			{
				if (nro_ref) {
					cargarPermisoReferencia(nro_ref)
				}
				tipo_permiso = parseInt(tipo_permiso || 2, 10)  // tipo_permiso default = 2 -> leer
				var valor    = tipo_permiso == 6 ? 31 : Math.pow(2, tipo_permiso - 1)
				return (valor & permiso_referencia) > 0
			}
			
			
			return {cargarPermisoReferencia: cargarPermisoReferencia,  tienePermisoReferencia: tienePermisoReferencia}
		}
		
		