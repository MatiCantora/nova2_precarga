function tGadget(options) {

    this.resetLayout = tGadget_resetLayout;
    this.draw = tGadget_draw;
    this.add = tGadget_add;
    this.getExportarReporte = tGadget_getExportarReporte;
    this.createBlock = tGadget_createBlock;
    this.createElement = tGadget_createElement;
    this.refresh = tGadget_refresh;

    var __construct = function(t_gadget, options) {
        t_gadget.blocks = [];
        t_gadget.container = options.container;
        t_gadget.gap = options.gap;
        t_gadget.container.addClassName('gadget');
        t_gadget.container.setStyle({'paddingBottom': t_gadget.gap + 'px'});
        t_gadget.selected = false;
        Event.observe($($(document)), 'mouseup', function() {
            t_gadget.resetLayout();
        });
        Event.observe($($(window)), 'resize', function() {
            t_gadget.draw();
        });
    }(this, options);
}

function tGadget_resetLayout() {
    this.selected = false;
    this.container.removeClassName('block-selected');
    this.container.select('.moving').each(function(moving) {
        moving.remove();
    });
}

function tGadget_draw() {
    var t_gadget = this;
    if (Prototype.Browser.IE) {
        this.resetLayout();
    }
    var line_blocks = [];
    var cont_width = this.container.getWidth() - t_gadget.gap;
    var current_list_pos = -1;
    this.blocks.each(function(block) {
        if (line_blocks[current_list_pos] == undefined || line_blocks[current_list_pos].width + block.block.min_width + t_gadget.gap > cont_width) {
            current_list_pos++;
            line_blocks[current_list_pos] = {
                content: [],
                width: 0
            };
        }
        line_blocks[current_list_pos].content.push(block);
        line_blocks[current_list_pos].width += block.block.min_width + t_gadget.gap;
    });
    this.container.select('div.block, div.clear').each(function(element) {
        element.remove();
    });
    var width_add;
    var dv;
    line_blocks.each(function(line) {
        width_add = Math.floor((cont_width - line.width) / (line.content.length));
        line.content.each(function(block) {
            block.block.setStyle({width: (block.block.min_width + width_add) + 'px'});
            this.container.insert({bottom: block.block});
        });
        dv = $($(document.createElement('div'))).addClassName('clear');
        this.container.insert({bottom: dv});
    });
}

function tGadget_add(options) {
    var export_parameters = false;
    var orig_content = options.content;
    if (typeof options.content === 'object') {
        export_parameters = options.content;
        options.content = '';
    }

    var block = this.createBlock(options);
    block.element = this.createElement(options);
    block.block.update(block.element);
    this.blocks.push(block);
    this.draw();

    if (export_parameters) {
        this.getExportarReporte(export_parameters, block.element);
    }
    block.element.content = orig_content;
    return block.element;
}

function tGadget_refresh(element) {
    if (typeof element.content === 'object') {
        this.getExportarReporte(element.content, element);
    } else {
        element.update(element.content);
    }
}

function tGadget_getExportarReporte(export_parameters, element) {
    var name = 'gadget_temp_iframe_' + (Math.random() + '').substr(2);
    var iframe = $($(document.createElement('iframe')));
    iframe.setAttribute('name', name);
    iframe.setAttribute('id', name);
    iframe.setStyle({display: 'none'});
    this.container.insert({bottom: iframe});

    export_parameters.formTarget = name;
    export_parameters.salida_tipo = "adjunto";

    export_parameters.funComplete = function() {
        var content = iframe.contentWindow.document.body.innerHTML;
        iframe.remove();
        $($(element.select('.content:first')[0])).update(content);
    };
    nvFW.exportarReporte(export_parameters);
}

function tGadget_createBlock(options) {
    var t_gadget = this;
    var block = $($(document.createElement('div'))).addClassName('block unselectable');
    block.setStyle({
        padding: this.gap + 'px 0 0 ' + this.gap + 'px'
    });
    block.min_width = options.min_width;
    block.height = options.height;
    Event.observe(block, 'mousedown', function() {
        t_gadget.selected = block;
    });
    Event.observe(block, 'mouseup', function() {
        if (t_gadget.selected && t_gadget.selected != block) {
            var cur_index = t_gadget.blocks.indexOf(block);
            var sel_index = t_gadget.blocks.indexOf(t_gadget.selected);
            t_gadget.blocks.splice(sel_index, 1);
            t_gadget.blocks.splice(cur_index, 0, t_gadget.selected);

            t_gadget.draw();
        }
    });
    block = {
        block: block,
        title: options.title,
//        width: options.width,
        height: options.height
    };
    return block;
}

function tGadget_createElement(options) {
    var t_gadget = this;
    var element = $($(document.createElement('div'))).addClassName('element unselectable');
    element.setStyle({
        'height': options.height + 'px',
        'minWidth': options.min_width + 'px'
    });

    var title = $($(document.createElement('div'))).addClassName('title unselectable alphacube_title');
    title.update(options.title);
    Event.observe($($(title)), 'mousedown', function(event) {
        t_gadget.container.addClassName('block-selected');
        var x_ini = event.clientX - element.viewportOffset()[0] + t_gadget.container.viewportOffset()[0];
        var y_ini = t_gadget.container.viewportOffset()[1] - 3;

        var x_max = t_gadget.container.getWidth() - options.width - 1;
        var y_max = t_gadget.container.getHeight();// - options.height - 1;
        var x_min = 0;
        var y_min = 0;
        element.addClassName('selected');

        var moving = $($(document.createElement('div'))).addClassName('moving');
        var delta_x = (event.clientX - x_ini);
        var delta_y = (event.clientY - y_ini);
        moving.setStyle({
            width: element.getWidth() - 2 + 'px',
            height: options.height - 1 + 'px',
            left: delta_x + 'px',
            top: delta_y + 'px'
        });
        if (Prototype.Browser.IE) {
            moving.setOpacity(0.3);
        }
        t_gadget.container.insert({bottom: moving});

        Event.observe($($(document)), "mousemove", function(event) {
            var delta_x = (event.clientX - x_ini);
            var delta_y = (event.clientY - y_ini);
            if (delta_x < x_min) {
                delta_x = x_min;
            }
            if (delta_x > x_max) {
                delta_x = x_max;
            }
            if (delta_y < y_min) {
                delta_y = y_min;
            }
            if (delta_y > y_max) {
                delta_y = y_max;
            }
            moving.setStyle({
                left: delta_x + 'px',
                top: delta_y + 'px'
            });
            if (window.getSelection) {
                if (window.getSelection().empty) {  // Chrome
                    window.getSelection().empty();
                } else if (window.getSelection().removeAllRanges) {  // Firefox
                    window.getSelection().removeAllRanges();
                }
            } else if (document.selection) {  // IE?
                document.selection.empty();
            }
        });
    });
    Event.observe($($(document)), 'mouseup', function(event) {
        Event.stopObserving($($(document)), "mousemove");
        element.removeClassName('selected');
    });
    element.insert({'bottom': title});

    var content = $($(document.createElement('div'))).addClassName('content unselectable');
    content.update(options.content);

    var body = $($(document.createElement('div'))).addClassName('body unselectable');
    body.update(content);

    element.insert({'bottom': body});

    return element;
}