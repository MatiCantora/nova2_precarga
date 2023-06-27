
function target_parse(target) {
    var i
    var destinos = new Array();
    if (target == '') {
        return destinos
    }
    //Los targets vienen separados por ;
    //Utiliza el split si sencuentra el ; o simplemente asigna el valor al primer elemento

    if (target.indexOf(';') == -1) {
        destinos[0] = target
    }
    else
        destinos = target.split(';')

    //Elimina los espacio al principio
    for (var i = 0; i < destinos.length; i++) {
        var r = new RegExp("^\\s*") //Espacios en blanco al principio
        destinos[i] = destinos[i].replace(r, '')
        //Elimina los destinos en blanco
        if (destinos[i] == '') {
            destinos.splice(i, 1)
            i--
        }
    }

    var arrTarget = new Array();
    for (var i = 0; i < destinos.length; i++) {
        var target = destinos[i]
        var protocolo = target.substr(0, target.indexOf('://')).toUpperCase()
        switch (protocolo) {
            case "FILE": //Copia el archivo resultado al destino
                var file = target_get_file(target)
                arrTarget[i] = file
                break

            case "MAILTO":
                var mailto = target_get_mailto(target)
                arrTarget[i] = mailto
                break

            case "NAME": //Copia el archivo resultado al destino
                arrTarget[i] = {}
                arrTarget[i]['protocolo'] = protocolo
                arrTarget[i]['filename'] = target.substr(target.indexOf('://') + 3, target.length)
                arrTarget[i]['target'] = target
                break
            default:
                arrTarget[i] = new Array();
                arrTarget[i]['protocolo'] = protocolo
                arrTarget[i]['target'] = target
                break
        }
    }
    return arrTarget
}

function target_get_file(strfile)
{
    var file = new Array();
    file['protocolo'] = 'file'

    //var raiz = ''
    ////path_destino = strfile.substr(strfile.indexOf('://') + 3, strfile.length)

    //path_destino = strfile.substr(strfile.indexOf('://') + 3, strfile.length).split("?xls_save_as=")[0]

    //if (path_destino.split("?xls_save_as=").length > 0)
    //    path_destino = path_destino.split("?xls_save_as=")[0]

    //file['path'] = path_destino
    //file['folder'] = fso_GetParentFolder(path_destino)
    //file['filename'] = fso_GetFileName(path_destino)
    //file['extencion'] = fso_GetExtencion(path_destino)
    //file['xls_save_as'] = strfile.split("?xls_save_as=")[1]

    var raiz = ''
    path_destino = strfile.substr(strfile.indexOf('://') + 3, strfile.length).split("||")[0]
    file['uri'] = strfile
    file['path'] = path_destino
    file['folder'] = fso_GetParentFolder(path_destino)
    file['filename'] = fso_GetFileName(path_destino)
    file['extension'] = fso_GetExtencion(path_destino)

    file['xls_save_as'] = ""
    file['comp_metodo'] = ""
    file['comp_algoritmo'] = ""
    file['comp_pwd'] = ""
    file['target'] = strfile
    file['target_comp'] = ""
    file['comp_extension'] = ""
    file['comp_filename'] = ""
    file['target_agregar'] = ""

    var strExp = '(\\|\\|<(.*?)>\\|\\|)'
    var reg = new RegExp(strExp, "ig")
    var res = []
    res = strfile.match(reg)
    res = res ? res : [] 
    if (res.length > 0) {

        file['target'] = strfile.replace(reg, "")

        strExp = '[|]'
        reg = new RegExp(strExp, "ig")
        res = res[0].replace(reg, "")
        var objxml = new tXML();
        if (objxml.loadXML(res)) {
            file['xls_save_as'] = selectSingleNode("opcional/@xls_save_as", objxml.xml).value
            file['target_agregar'] = selectSingleNode("opcional/@target_agregar", objxml.xml).value
            file['comp_metodo'] = selectSingleNode("opcional/@comp_metodo", objxml.xml).value
            file['comp_algoritmo'] = selectSingleNode("opcional/@comp_algoritmo", objxml.xml).value
            file['comp_pwd'] = selectSingleNode("opcional/@comp_pwd", objxml.xml).value
            if (file['comp_metodo'] != "")
            {
                file['target_comp'] = file['target'].replace(file['extension'], file['comp_metodo'])
                file['comp_extension'] = file['comp_metodo']
                file['comp_filename'] = fso_GetFileName(file['target_comp'])
            }
        }
    }


    return file
}

function getExtSave_as(save_as)
{
    var ext = ""

    if (!save_as)
        return ext

    switch(save_as.toString())
    {
        case "20":
            ext = "Delimitado por tab (*.csv)"
        break;
        case "36":
            ext = "Delimitado por espacio (*.csv)"
        break;
        case "6":
            ext = "Delimitado por coma (*.csv)"
        break;
        case "54":
            ext = "XML Excel (*.xml)"
            break;
        case "51":
            ext = "Libro Excel (*.xlsx)"
        break;
        case "56":
            ext = "Libro Excel 97-2003 (*.xls)"
        break;
        case "56":
            ext = "Libro Excel 97-2003 (*.xls)"
        break;
		 case "57":
            ext = "PDF (*.pdf)"
        break;
    }
  return ext
}

function target_get_mailto(strmailto) {
    var ma, mb, mc, md
    //Array resultado
    var mailto = new Array()
    //descompone la cadena entre la direccion y los parametros
    ma = strmailto.split('?')
    //descompone la cadena entre protocolo y dirección
    mb = ma[0].split('://')
    mailto[mb[0]] = mb[1]
    mc = ma[1].split('&')
    for (var i = 0; i < mc.length; i++) {
        md = mc[i].split('=')
        mailto[md[0]] = replace(md[1], "~", ";")
    }
    if (!mailto["to"] || mailto["to"] == '')
        mailto["to"] = mailto["MAILTO"]
    //  else
    //    mailto["to"] += ';' + mailto["MAILTO"]          
    mailto["protocolo"] = 'mailto'
    mailto["target"] = strmailto
    mailto["attch"] = ""

    return mailto
}

function fso_GetParentFolder(path) {
    var dir = ''
    path = replace(path, '\\', '/')
    var pos = path.lastIndexOf('/')
    if (pos != -1)
        dir = path.substring(0, pos - 1)

    return dir
}

function fso_GetExtencion(path) {
    var filename = fso_GetFileName(path)
    var pos = filename.lastIndexOf('.')
    var ext = ''
    if (pos != -1)
        ext = filename.substring(pos + 1, filename.length)
    return ext
}

function fso_GetFileName(path) {
    var dir = ''
    path = replace(path, '\\', '/')
    var pos = path.lastIndexOf('/')
    if (pos != -1)
        dir = path.substring(pos + 1, path.length)

    return dir
}

function get_file_path(path) {
    // debugger

    var dirs = nvSession.getContents("app_directorios")
    var raiz = Server.MapPath("/") + "\\App_Data\\localfile\\"
    var r = new RegExp("\(.*\)[\\||/]") //Espacios en blanco al principio
    var cod_ss_dir = ""
    var archivo = ""
    if (path.match(r) != null) {
        cod_ss_dir = path.match(r)[0]
        archivo = path.replace(cod_ss_dir, "")
        cod_ss_dir = cod_ss_dir.substr(cod_ss_dir.indexOf('://') + 3, cod_ss_dir.length)//cod_ss_dir.substring(1, cod_ss_dir.length - 3)

       /* for (var cod_ss_dir in dirs) {
            if (dirs[cod_ss_dir])
                return raiz + "\\" + dirs[cod_ss_dir].path + "\\" + replace(archivo, "/", "\\")
        }*/
    }

    return raiz + "\\" + replace(cod_ss_dir, "/", "\\") + "\\" +  replace(archivo, "/", "\\")

    //  for (var cod_ss_dir in dirs)
    //    {
    //    return dirs[cod_ss_dir].path + "\\" + replace(path, "/", "\\")
    //    }

}

function set_file_raiz() {
    var dirs = nvSession.getContents("app_directorios")
    for (var cod_ss_dir in dirs) {
        return dirs[cod_ss_dir].path
    }
    return ""
}

function fso_create_folder(path, cont) {
    if (cont == undefined)
        cont = 1
    var max_cont = 10
    cont++
    if (cont >= max_cont)
        return
    var fso = Server.CreateObject("Scripting.FileSystemObject")
    if (!fso.FolderExists(fso.GetParentFolderName(path))) {
        try {
            fso_create_folder(fso.GetParentFolderName(path), cont)
            fso.CreateFolder(fso.GetParentFolderName(path))
        }
        catch (e) { }
    }
}


function getNuevaHoja(libro)
{
    var existe = true
    var index = 1
    while (existe)
    {    
     hoja = null

     try {
         hoja = libro.Sheets("Hoja" + index)
         existe = true
         }
        catch (he)
        {
         existe = false;
         break;
        }

     index = index + 1
    }

    return "Hoja" + index

}

function exReemplazarHojas(path_tmp, path_destino) {
    try {
        var exAPP = new ActiveXObject("Excel.Application");

        exAPP.Visible = false
        exAPP.DisplayAlerts = false

        var exLibro_dest = exAPP.Workbooks.Open(path_destino)
        var exLibro_tmp = exAPP.Workbooks.Open(path_tmp)

        var exHoja_dest
        for (n = 1; n <= exLibro_tmp.Worksheets.count; n++) {
            exHoja_tmp = exLibro_tmp.Worksheets(n)
            exHoja_tmp_name = exHoja_tmp.name
            exHoja_dest = null
            try {
                exHoja_dest = exLibro_dest.Sheets(exHoja_tmp_name)
            }
            catch (he) { }

            if (exHoja_dest) {
                //exHoja_tmp.name = '$NEW_' + exHoja_tmp_name
                //exHoja_tmp.Copy(exHoja_dest, null)
                //exHoja_dest.Delete()
                //exLibro_dest.Sheets('$NEW_' + exHoja_tmp_name).name = exHoja_tmp_name
                exHoja_tmp.name = getNuevaHoja(exLibro_dest)
            }

            exHoja_tmp.Copy(exLibro_dest.Worksheets(exLibro_dest.Worksheets.count), null)
        }

        exLibro_dest.Save()

        for (c = 1; c <= exAPP.WorkBooks.count; c++)
            exAPP.WorkBooks(c).close(true)


        exAPP.quit()
        delete exAPP

        return null
    }
    catch (e) {

        for (c = 1; c <= exAPP.WorkBooks.count; c++)
            exAPP.WorkBooks(c).close(true)


        exAPP.quit()
        delete exAPP


        return e

    }

}


function convertir_a(save_as, path) {
    try {

        var exAPP = new ActiveXObject("Excel.Application");

        exAPP.Visible = false
        exAPP.DisplayAlerts = false

        var exLibro = exAPP.Workbooks.Open(path)

        exLibro.SaveAs(path, parseInt(save_as))

        exAPP.quit()
        delete exAPP
        exAPP = null
        // CollectGarbage()


        return null
    }
    catch (e) {

        if (exAPP != undefined) {
            exAPP.quit()
            delete exAPP
            exAPP = null
            //CollectGarbage()
        }

        return e
    }

}
