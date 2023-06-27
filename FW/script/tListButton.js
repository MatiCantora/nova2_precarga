function tListButton(vButtonItems, txt_nombre) {
    this.nombre = txt_nombre; // Nombre de la variable
    this.ButtonItems = {};
    this.nvImages = new tImage();
    this.imagenes = {}; // Imagenes comunes
    this.loadImage = tListButton_loadImage;
    this.getURLImage = tListButton_getURLImage;
    this.MostrarListButton = tListButton_MostrarListButton;
    this.XML = null;
    this.estilo = 'O';

    var buttonItemsArray = Array.isArray(vButtonItems) ? vButtonItems : Object.values(vButtonItems);
    for (var i = 0; i < buttonItemsArray.length; i++) {
        this.ButtonItems[i] = new tButtonItem();
        this.ButtonItems[i].parent = this;
        this.ButtonItems[i].nombre = buttonItemsArray[i]["nombre"];
        this.ButtonItems[i].imagen = buttonItemsArray[i]["imagen"];
        this.ButtonItems[i].etiqueta = buttonItemsArray[i]["etiqueta"];
        this.ButtonItems[i].onclick = buttonItemsArray[i]["onclick"];
        this.ButtonItems[i].estilo = buttonItemsArray[i]["estilo"] || this.estilo;
    }

}

function tButtonItem() {
    this.ListButton = ""; // Arbol al cual pertenece
    this.parent = "";
    this.nombre = ""; // Texto el Item
    this.imagen = "";
    this.etiqueta = "";
    this.onclick = "";
    this.estilo = 'O';
    this.GenerarHTML = tButtonItem_GenerarHTML;
}


function tListButton_getURLImage(icono) {
    if (this.nvImages.Exists(icono))
        return this.nvImages.items[icono].src;
    else
        if (this.imagenes[icono] != undefined) {
            this.nvImages.load(icono, this.imagenes[icono].src);
            return this.nvImages.items[icono].src;
        }
    return "";
}


function tButtonItem_GenerarHTML() {
    var strHTML;
    strHTML = '<table class="btnTB_' + this.estilo + '" cellspacing="0" border="0" cellpadding="0"><tr>' +
        '<td class="btnBegin_' + this.estilo + '"></td>' +
        '<td class="btnNormal_' + this.estilo + '" ' +
        'onClick="' + this.onclick + '">';
    if (this.imagen !== '') {
        var src = this.parent.getURLImage(this.imagen);
        if (src === "")
            alert("Error. No se encuentra la imagen '" + this.imagen + "'");
        else
            strHTML += '<img name="img_1" src="' + src + '" border="0" align="absmiddle" hspace="1">';
    }
    strHTML += '&nbsp;' + this.etiqueta + '</td>' +
        '<td class="btnEnd_' + this.estilo + '"></td></tr></table>';

    this.innerHTML = strHTML;
    return strHTML;
}


function tListButton_MostrarListButton() {
    var divButton;
    for (var i in this.ButtonItems) {
        divButton = $("div" + this.ButtonItems[i].nombre);
        divButton.innerHTML = this.ButtonItems[i].GenerarHTML();
    }
}


function tListButton_loadImage(name, url, preLoad) {
    if (!this.imagenes)
        this.imagenes = {};

    this.imagenes[name] = {
        src: url
    }
} 