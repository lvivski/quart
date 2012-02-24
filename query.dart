$(selector, [context = null]){
    if (context !== null) {
        return $(context).find(selector);
    } else if (selector is Query) {
        return selector;
    } else {
        var dom;
        if (selector is Element) {
            dom = [selector];
            selector = null;
        } else {
            dom =  new List.from(document.queryAll(selector));
        }
        return new Query(dom, selector);
    }
}

class Query {
    final String selector;
    final ElementList dom;

    Query(this.dom, this.selector);

    Query each(callback) {
        this.dom.forEach(callback);
        return this;
    }

    int size() => this.dom.length;

    Element get(idx) => this.dom.getRange(idx, 1);

    Query remove() => this.each((elem){ elem.remove(); });

    Query first() => $(this.dom.getRange(0, 1));

    Query last()  => $(this.dom.last());

    Query prev()  => $(this.dom[0].previousElementSibling);

    Query next()  => $(this.dom[0].nextElementSibling);

    bool hasClass(className) => this.dom.first.classes.contains(className);

    Query addClass(className) => this.each((elem){ elem.classes.add(className); });

    Query removeClass(className) => this.each((elem){ elem.classes.remove(className); });

    Query toggleClass(className) => this.each((elem){ elem.classes.toggle(className); });

    Query show() => this.each((elem){ elem.hidden = false; });

    Query hide() => this.each((elem){ elem.hidden = true; });

    Dynamic html([html = null]) {
        if (html !== null) {
            return this.each((elem){ elem.innerHTML = html; });
        }
        return this.dom[0].innerHTML;
    }

    Dynamic text([text = null]) {
        if (text !== null) {
            return this.each((elem){ elem.innerText = text; });
        }
        return this.dom[0].innerText;
    }

    Dynamic attr(name, [value = null]) {
        if (value !== null) {
            return this.each((elem){ elem.attributes[name] = value; });
        }
        return this.dom[0].attributes[name];
    }

    Dynamic data(name, [value = null]) {
        if (value !== null) {
            return this.each((elem){ elem.dataAttributes[name] = value; });
        }
        return this.dom[0].dataAttributes[name];
    }

    Query insert(where, html) {
        return this.each((elem){
            if (html is Query) {
                var dom = html;
                    length = dom.length;
                if (where == 'afterBegin' || where == 'afterEnd') {
                    dom.each((elem, idx){ elem.insertAdjacentElement(where, dom[length-idx-1]); });
                } else {
                    dom.each((elem, idx){ elem.insertAdjacentElement(where, dom[idx]); });
                }
            } else {
                if(html is Element) {
                    elem.insertAdjacentElement(where, html);
                } else {
                    elem.insertAdjacentHTML(where, html);
                }
            }
        });
    }

    Query append(html)  => insert('beforeEnd', html);

    Query prepend(html) => insert('afterBegin', html);

    Query before(html)  => insert('beforeBegin', html);

    Query after(html)   => insert('afterEnd', html);
}
