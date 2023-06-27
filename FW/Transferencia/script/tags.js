Element.addMethods(['div'], {
    taggify: function(element, options) {
        if (!(element = $(element))) {
            return;
        }
        if (options == undefined) {
            options = {};
        }
        element.uniqueTags = true;//no permitir repetidos
        element.editable = true;
        element.escape = 59; //semicolon 
        element.beforeAdd = function() {
            return true;
        };
        element.beforeRemove = function() {
            return true;
        };
        element.afterAdd = function() {
            return true;
        };
        element.afterRemove = function() {
            return true;
        };
        element.addTag = function(tag) {
            var result = false;
            element.input.hide();
            if (typeof tag == 'string') {
                tag = {
                    name: tag,
                    extras: {}
                };
            }
            var doAdd = true;
            doAdd = doAdd && !!tag.name;
            if (element.uniqueTags) {
                element.getValue().each(function(eTag) {
                    if (eTag.name == tag.name) {
                        doAdd = false;
                        throw $break;
                    }
                });
            }
            doAdd = doAdd && element.beforeAdd(tag);
            if (doAdd) {
                var tagElement = $(document.createElement('div'));
                tagElement.addClassName('tag');

                var tagName = $(document.createElement('span'));
                tagName.addClassName('name');
                tagName.update(tag.name);
                tagElement.insert({bottom: tagName});

                var tagRemove = $(document.createElement('span'));
                tagRemove.addClassName('remove');
                tagRemove.update('&nbsp;');
                tagElement.insert({bottom: tagRemove});

                tagRemove.observe('click', function() {
                    if (element.beforeRemove(tag)) {
                        tagElement.remove();
                        element.afterRemove(tag);
                        return tag;
                    }
                    return false;
                });
                var lastTag = element.select('.tag:last-of-type');
                if (lastTag.length) {
                    lastTag[0].insert({after: tagElement});
                } else {
                    element.insert({top: tagElement});
                }
//                            tag.element = tagElement;
                tagElement.tag = tag;
                element.afterAdd(tag);
                result = tagElement;
            }
            element.input.show();
            return result;
        };
        element.controlAddTag = function() {
//            var regEx = new RegExp(element.escapeChar + "+", "g");
            var str = element.input.value.replace(element.regEx, '');
            str = element.trim(str);
            if (element.addTag(str)) {
                element.input.value = '';
                element.eraseInput = true;
            }
            element.input.focus();
        };
        element.getValue = function() {
            var tags = [];
            element.select('.tag').each(function(tag) {
                tags.push({
                    name: tag.tag.name,
                    extras: tag.tag.extras
                });
            });
            return tags;
        };
        element.getStringValue = function(joinner) {
            if (joinner === undefined) {
                joinner = element.escapeChar;
            }
            var string = [];
            element.select('.tag').each(function(tag) {
                string.push(tag.tag.name);
            });
            return string.join(joinner);
        };
        element.setValue = function(tags) {
            var count = 0;
            if (tags.name !== undefined || typeof tags == 'string') {
                tags = [tags];
            }
            tags.each(function(tag) {
                if (element.addTag(tag)) {
                    count++;
                }
            });
            return count;
        };
        element.setStringValue = function(tags, joinner) {
            if (joinner === undefined) {
                joinner = element.escapeChar;
            }
            var count = 0;
            tags.split(joinner).each(function(tag) {
                count += element.setValue(tag);
            });
        };
        /***********************/
        for (var key in options) {
            element[key] = options[key];
        }
        element.escapeChar = String.fromCharCode(element.escape);
        element.eraseInput = false;

        element.addClassName('tagger');
        element.update('');
        element.trim = function(str) {
            return str.replace(/^ +/, '').replace(/ +$/, '');
        };
        if (element.editable) {
            element.input = $(document.createElement('input'));
            element.observe('click', function() {
                element.input.focus();
            });
            element.input.observe('blur', function() {
                //element.controlAddTag();
            });
            element.input.addClassName('edit');
            element.insert({bottom: element.input});
            element.tmpSpan = $(document.createElement('span'));
            element.tmpSpan.setStyle({
                display: 'none'
            });
            element.insert({bottom: element.tmpSpan});
            element.input.observe('keypress', function(event) {
                var key = !event.which ? event.keyCode : event.which;
                if (key == element.escape) {
                    element.controlAddTag();
                }
                /* redimenciono */
                element.tmpSpan.update(element.input.value);
                element.input.setStyle({
                    //le sumo 10px porque todavia no se escribió la última letra
                    width: (element.tmpSpan.getWidth() + 10) + 'px'
                });
            });
            element.doRemove = false;
            element.regEx = new RegExp(element.escapeChar + "+", "g");
            element.input.observe('keyup', function(event) {
                var key = !event.which ? event.keyCode : event.which;
                if (element.eraseInput) {
                    element.eraseInput = false;
                    element.input.value = '';
                }
                if (key == 8 && element.doRemove) {//backspace
                    var lastTag = element.select('.tag:last-of-type');
                    if (lastTag.length) {
                        lastTag[0].remove();
                    }
                }
                element.doRemove = element.input.value === '';
                if(element.input.value.match(element.regEx)) {
                    element.input.value = element.input.value.replace(element.regEx, '');
                }
            });
        }
        return element;
    }
});