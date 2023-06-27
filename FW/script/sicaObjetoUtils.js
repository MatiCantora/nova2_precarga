function mostrarObjetoImplementacion(cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo, extension)
{
    if (!cod_servidor)  cod_servidor = "";

    if (!cod_sistema) cod_sistema = "";

    if (!extension)
    {
        var arr = objeto.split(".")

        if (arr.length > 1) extension = arr.last();
    }

    // si es dato, y estamos en chorme/firefox 
    if ((cod_obj_tipo == 8 || extension == '.xml') && !Prototype.Browser.IE)
    {
        mostrarXMLChrome('', '', cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
        return
    }

    if (cod_obj_tipo == 1 || cod_obj_tipo == 2 || cod_obj_tipo == 3 || cod_obj_tipo == 6)
    {
        mostrarObjScript('', true, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
    }

    if (!extension) return;

    if (cod_obj_tipo == 5 || cod_obj_tipo == 8)
    {
        if (cod_obj_tipo == 8) extension = "xml";

        mostrarObjArchivo('', extension, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
    }
}


// cod_objeto + cod_obj_tipo + extension
function mostrarObjetoDefinicion(cod_objeto, cod_obj_tipo, extension)
{
    // si es dato o tabla, y estamos en chorme/firefox 
    if ((cod_obj_tipo == 8 || extension == '.xml') && !Prototype.Browser.IE)
    {
        mostrarXMLChrome(cod_objeto, 'ISO-8859-1')
        return
    }

    if (cod_obj_tipo == 1 || cod_obj_tipo == 2 || cod_obj_tipo == 3 || cod_obj_tipo == 6)
    {
        if (cod_obj_tipo == 1) extension = ".xml"   // Tabla esta embebido en XML
        
        mostrarObjScript(cod_objeto, true)
    }

    if (cod_obj_tipo == 5 || cod_obj_tipo == 8)
    {
        if (cod_obj_tipo == 8) extension = ".xml";

        mostrarObjArchivo(cod_objeto, extension);
    }
}


function mostrarObjScript(cod_objeto, esDBObj, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
{
    var params = {}

    if (cod_objeto)
    {
        params.cod_objeto = cod_objeto;
    }
    else
    {
        params.cod_servidor = cod_servidor;
        params.cod_sistema  = cod_sistema;
        params.port         = port;
        params.objeto       = encodeURIComponent(objeto);
        params.path         = encodeURIComponent(path);
        params.cod_obj_tipo = cod_obj_tipo;
    }

    params.esDBObj = esDBObj;

    var win = window.top.nvFW.createWindow({
        url: '/FW/sica/sica_script_viewer.aspx',
        title: 'Detalle del Objeto',
        minimizable: false,
        maximizable: true,
        draggable: true,
        width: 900,
        height: 500,
        destroyOnClose: true
    });

    win.options.userData = params;
    win.showCenter();
}



// para mostrar archivos simples y complejos: asp, aspx, js, pdf, imagenes etc
function mostrarObjArchivo(cod_objeto, extension, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
{
    // quitar el prefijo de punto de la extension
    var parts = extension.split(".")

    if (parts.length > 0) extension = parts.last();

    var fileExtensions = {
        bmp: true,
        doc: true, 
        docx: true, 
        gif: true, 
        ico: true, 
        jpe: true, 
        jpeg: true, 
        jpg: true, 
        pdf: true, 
        png: true, 
        svg: true,
        swf: true, 
        tif: true, 
        tiff: true, 
        xls: true, 
        xlsx: true, 
        xml: true
    }

    var scriptExtensions = {
        asa: true,
        asax: true,
        asp: true,
        aspx: true,
        cfg: true,
        cs: true,
        css: true,
        htm: true,
        html: true,
        js: true,
        txt: true,
        vb: true,
        vbs: true,
        xhtml: true,
        xsl: true
    }

    var params = ""

    if (cod_objeto)
    {
        params = 'modo=GET_DEF&cod_objeto=' + cod_objeto
    }
    else
    {
        params = "modo=GET_IMP" +
                "&cod_servidor=" + cod_servidor + 
                "&cod_sistema=" + cod_sistema + 
                "&port=" + port +
                "&objeto=" + encodeURIComponent(objeto) + 
                "&path=" + encodeURIComponent(path) + 
                "&cod_obj_tipo=" + cod_obj_tipo
    }

    if (fileExtensions[extension.toLowerCase()])
    {
        if (extension == 'xml' && Prototype.Browser.IE)
        {
            window.open('/FW/sica/get_objeto_response.aspx?' + params)
            return
        }

        var win = window.top.nvFW.createWindow({
                url:            '/FW/sica/get_objeto_response.aspx?' +  params,
                title:          'Detalle del Objeto',
                minimizable:    false,
                maximizable:    true,
                resizable:      true,
                draggable:      true,
                width:          900,
                height:         500,
                destroyOnClose: true
        });

        win.showCenter();
        return;
    }

    if (scriptExtensions[extension.toLowerCase()])
    {
        mostrarObjScript(cod_objeto, false, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo);
        return
    }
}



function mostrarXMLChrome(cod_objeto, encoding, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
{
    var params = {}

    if (cod_objeto)
    {
        params.modo = "GET_DEF"
        params.cod_objeto  = cod_objeto
    }
    else
    {
        params.modo = "GET_IMP"
        params.cod_servidor  = cod_servidor
        params.cod_sistema  = cod_sistema
        params.port  = port
        params.objeto  = objeto
        params.path  = path
        params.cod_obj_tipo  = cod_obj_tipo
    }

    if (!encoding) encoding = 'ISO-8859-1';

    params.encoding = encoding

    nvFW.error_ajax_request('/FW/sica/get_objeto_source.aspx',
    {
        parameters: params,
        onSuccess: function (err)
        {
            var xml = err.params.objetoContent_definition;

            if (xml)
            {
                var blob = new Blob([xml], { type: 'text/xml' });
                var url  = URL.createObjectURL(blob);
                window.open(url, null, "width=800, height=500, top=150, left=150");
                URL.revokeObjectURL(url); // Liberar recursos
            }
        },
        bloq_msg: 'Cargando objeto...'
    });
}