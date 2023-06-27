


function mostrarObjetoImplementacion(cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo, extension) {
    
    if (!cod_servidor) {
        cod_servidor = ""
    }
    if (!cod_sistema) {
        cod_sistema = ""
    }

    if (!extension) {
        var arr = objeto.split(".")
        if(arr.length>1){
            extension = arr[arr.length-1]
        } 
    }

    if(cod_obj_tipo==1||cod_obj_tipo==2||cod_obj_tipo==3||cod_obj_tipo==6 || cod_obj_tipo==8) {
        mostrarObjScript('', true, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
    }


    if (!extension)
        return;

    if (cod_obj_tipo == 5) {
        mostrarObjArchivo('', extension, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
    }
    


}


// cod_objeto + cod_obj_tipo + extension

function mostrarObjetoDefinicion(cod_objeto, cod_obj_tipo, extension) {
    
    if(cod_obj_tipo==1||cod_obj_tipo==2||cod_obj_tipo==3||cod_obj_tipo==6 || cod_obj_tipo==8) {
        mostrarObjScript(cod_objeto, true)
    }

    if(cod_obj_tipo==5) {
        mostrarObjArchivo(cod_objeto, extension);
    }
}


// para mostrar los scripts de los objetos db
function mostrarObjScript(cod_objeto, esDBObj, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo) {
    
    
    var params = ""

    if (cod_objeto) {
        params = 'cod_objeto='+cod_objeto
    } else {
        params = "cod_servidor=" + cod_servidor + "&cod_sistema=" + cod_sistema + "&port=" + port +
            "&objeto=" + encodeURIComponent(objeto) + "&path=" + encodeURIComponent(path) + "&cod_obj_tipo=" + cod_obj_tipo
    }
    params += "&esDBObj="+esDBObj

    var win=
            window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/sica/sica_script_viewer.aspx?' + params,
                title: 'Detalle del Objeto',
                minimizable: false,
                maximizable: true,
                draggable: true,
                width: 900,
                height: 500,
                destroyOnClose: true
            });
    win.showCenter();
}


// para mostrar archivos simples y complejos: asp, aspx, js, pdf, imagenes etc
function mostrarObjArchivo(cod_objeto, extension, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo) {

    // quitar el prefijo de punto de la extension
    var parts = extension.split(".")
    if (parts.length>0){
        extension = parts[parts.length-1];
    } 

    var fileExtensions = {
        pdf: true, 
        doc: true, 
        docx: true, 
        xls: true, 
        xlsx: true, 
        gif: true, 
        jpg: true, 
        jpe: true, 
        jpeg: true, 
        tif: true, 
        tiff: true, 
        ico: true, 
        png: true, 
        bmp: true,
        svg: true,
        swf: true
    }

    var scriptExtensions = {
        vb: true,
        vbs: true,
        asp: true,
        asa: true,
        aspx: true,
        asax: true,
        js: true,
        css: true,
        xsl: true,
        cs: true,
        html: true,
        htm: true,
        xhtml: true,
        txt: true,
        cfg: true,
        xml: true,
    }



    var params = ""
    if (cod_objeto) {
        params = 'modo=GET_DEF&cod_objeto=' + cod_objeto
    } else {
        params = "modo=GET_IMP&cod_servidor=" + cod_servidor + "&cod_sistema=" + cod_sistema + "&port=" + port +
        "&objeto=" + encodeURIComponent(objeto) + "&path=" + encodeURIComponent(path) + "&cod_obj_tipo=" + cod_obj_tipo
    }



    if (fileExtensions[extension.toLowerCase()]) {
  
        if (extension == 'xml' && Prototype.Browser.IE) {
            window.open('/fw/sica/get_objeto_response.aspx?' + params)
            return
        }

        var win =
            window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/sica/get_objeto_response.aspx?' +  params,
                title: 'Detalle del Objeto',
                minimizable: false,
                maximizable: true,
                resizable: true,
                draggable: true,
                width: 900,
                height: 500,
                destroyOnClose: true
            });
        win.showCenter();
        return
    }


    if (scriptExtensions[extension.toLowerCase()]) {
        if (cod_objeto) {
            mostrarObjScript(cod_objeto)
        } else {
            mostrarObjScript(null, false, cod_servidor, cod_sistema, port, objeto, path, cod_obj_tipo)
        }
    }
   
}








