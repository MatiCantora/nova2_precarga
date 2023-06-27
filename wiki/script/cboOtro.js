var HrvToolkit = {  Version: '1.0', Autor: '' }

HrvToolkit.Utilidades = Class.create();
HrvToolkit.Utilidades.ComboEditable = Class.create();
HrvToolkit.Utilidades.ComboEditable.prototype =
{
    //////////////////////////////////////////////////////////////////////////////////
    // Contructor
    //////////////////////////////////////////////////////////////////////////////////	
    initialize: function(id) {
        this.otro = "Otro...";
        this.optOtroValue = "-2";

        cbo = $(id);

        //Agrego la opcion "otro..."
        this.SetOther(cbo);

        //Agrego el evento que verifica si cambia a modo editable
        cbo.handler = this;
        cbo.onchange = function() { this.handler.CboChange(this); }
    },

    //////////////////////////////////////////////////////////////////////////////////
    // Evento que se dispara cuando cambia el valor del combo
    //////////////////////////////////////////////////////////////////////////////////
    CboChange: function(cbo) {
        if (cbo.value != this.optOtroValue) {
            onchange_cmb(cbo)
            return;
        }

        //Creo el text box para el ingreso de datos, utilizo el id del cbo + "_txt"
        var txtElem = document.createElement("input");
        txtElem.type = "text";
        txtElem.id = cbo.id + "_txt";
        txtElem.name = cbo.id + "_txt";
        txtElem.style.verticalAlign = "middle";
        txtElem.handler = this;
        txtElem.onkeypress = function() { return valDigito(event, ':') }
        txtElem.onchange = function() { return valTiempo(event) }
        txtElem.onblur = function() { this.handler.Refresh(cbo); onchange_cmb(cbo) }
        cbo.parentNode.appendChild(txtElem);

        //Crea La imagen, utilizo el id del cbo + "_img"
        var imgElem = document.createElement("img");
        imgElem.id = cbo.id + "_img";
        imgElem.src = "../../meridiano/image/icons/play.png";
        imgElem.style.width = "14";
        imgElem.style.height = "14";
        imgElem.style.textAlign = "center";
        imgElem.style.verticalAlign = "middle";
        imgElem.border = "0";
        imgElem.handler = this;
        imgElem.onclick = function() { this.handler.Refresh(cbo); }
        imgElem.style.cursor = "hand";
        txtElem.parentNode.appendChild(imgElem);
        cbo.style.display = "none";
        txtElem.focus();

        this.SetSameWidth(cbo, txtElem, imgElem);
    },

    //////////////////////////////////////////////////////////////////////////////////
    // Evento que se dispara cuando se ingresa un nuevo valor o se pierde el foco
    //////////////////////////////////////////////////////////////////////////////////		
    Refresh: function(cbo) {
        var txt = $(cbo.id + "_txt");
        var img = $(cbo.id + "_img");

        newitem = txt.value;

        //Elimino el texbox y la img
        cbo.parentNode.removeChild(txt);
        cbo.parentNode.removeChild(img);

        //Guardo el valor ingresado en el cbo
        if (newitem != "") {
            this.AddItem(cbo, newitem);
        }
        else {
            cbo.selectedIndex = 0;
        }
        cbo.style.display = "inline";
    },

    /////////////////////////////////////////////////////////////////////////////
    // Agrega un nuevo item al combobox
    ////////////////////////////////////////////////////////////////////////////
    AddItem: function(cbo, value) {

        if (!this.Exist(cbo, value)) {
            //Si no lo encuentra lo agrega
            cbo.options[cbo.options.length] = new Option(value, value, "", true);
            //acciones adicionales para que "otro..." quede siempre al final
            this.SetOther(cbo);
        }
    },

    /////////////////////////////////////////////////////////////////////////////
    // Verifica si un item existe. si existe lo deja "selected"
    ////////////////////////////////////////////////////////////////////////////
    Exist: function(cbo, value) {
        var indice = 0;
        var encontrado = false;

        for (var i = 0; !(encontrado) && i < cbo.options.length; i++) {
            if (cbo.options[i].text == value) { indice = i; encontrado = true; }
        }

        if (encontrado) { cbo.selectedIndex = indice; }
        return encontrado;
    },

    //////////////////////////////////////////////////////////////////////////////////
    // Agrega la opcion "otro..." al combo. Si existe la elimina y la pone al final
    //////////////////////////////////////////////////////////////////////////////////
    SetOther: function(cbo) {

        encontrado = false;
        for (var i = 0; !(encontrado) && i < cbo.options.length; i++) {
            if (cbo.options[i].text == this.otro) { cbo.remove(i); encontrado = true; }
        }
        cbo.options[cbo.options.length] = new Option(this.otro, -2, "", false);
    },

    SetSameWidth: function(cbo, txtElem, imgElem) {
        if (cbo.style.width && imgElem.width)
            txtElem.style.width = (parseInt(cbo.style.width) - parseInt(imgElem.width) - 5) + 25;
    }
}