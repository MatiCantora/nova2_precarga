class tBox {
    constructor(canvas, id, options) {
        this.id = id
        this.canvas = $(canvas)
        this.style = options.style == undefined ? "base" : options.style
        this.title = options.title == undefined ? "" : options.title
        this.footer = options.footer == undefined ? "" : options.footer
        this.insert_position = options.insert_position == undefined ? "bottom" : options.insert_position
        this.collapsible = options.collapsible == undefined ? "false" : options.collapsible
        this.collapsed = options.collapsed == undefined ? "false" : options.collapsed
        this.content = options.content == undefined ? "" : options.content

        this.create()
        if (this.collapsible) {
            if (!this.collapsed)
                this.div_canvas.style.display = "none"
            else
                this.div_canvas.style.display = "inline"
            tBox.expand_collapse(this.div_btnExpand.id)
        }
        
    }

    create() {
        if (this.canvas == null) {
            throw new Error('Error al cargar el objeto. El canvas no existe');
        }

        var strHTML = "<div id='div_tBox_" + this.id + "' class='div_tBox_container " + this.style + "_div_tBox_container'>"
        if (this.collapsible) {
            strHTML += "<div id='div_tBox_btnExpand_" + this.id + "' class='div_tBox_btnExpand " + this.style + "_div_tBox_btnExpand' onclick='debugger; tBox.expand_collapse(\"div_tBox_btnExpand_" + this.id + "\")'></div>"
        }
        strHTML += "<div id='div_tBox_tile_" + this.id + "' class='div_tBox_title " + this.style + "_div_tBox_title'><span class='span_tBox_title " + this.style + "_span_tBox_title'>" + this.title + "</span></div>"
        strHTML += "<div id='div_tBox_canvas_" + this.id + "' class='div_tBox_canvas " + this.style + "_div_tBox_canvas'>" + this.content + "</div>"
        strHTML += "<div id='div_tBox_footer_" + this.id + "' class='div_tBox_footer " + this.style + "_div_tBox_footer' > " + this.footer + "</div >"
        strHTML += "</div >"

        let op = {}
        op[this.insert_position] = strHTML
        this.canvas.insert(op)

        this.div_title = $("div_tBox_tile_" + this.id)
        this.div_canvas = $("div_tBox_canvas_" + this.id)
        this.div_footer = $("div_tBox_footer_" + this.id)
        this.div_btnExpand = $("div_tBox_btnExpand_" + this.id)
        if (!!this.div_btnExpand)
            this.div_btnExpand._tBox = this
        
    }

    static expand_collapse(id) {
        let btn = $(id).tBox
        if ($(id)._tBox.div_canvas.style.display == "none") {
            $(id)._tBox.div_canvas.style.display = "inline"
            $(id).addClassName("div_tBox_btnExpand_collapse")
        }
        else {
            $(id)._tBox.div_canvas.style.display = "none"
            $(id).removeClassName("div_tBox_btnExpand_collapse")
        }
        this.collapsed = $(id)._tBox.div_canvas.style.display == "none"

    }
}

