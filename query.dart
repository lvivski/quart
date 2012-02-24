$(selector, [context]){
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
    final List   dom;

    Query(this.dom, this.selector);

    Query each(callback) {
        dom.forEach(callback);
        return this;
    }

    List map(callback) {
        return dom.map(callback);
    }

    int size() => dom.length;

    Element get(idx) => dom.getRange(idx, 1);

    Query remove() => each((elem){ elem.remove(); });

    Query first() => $(dom.getRange(0, 1));

    Query last()  => $(dom.last());

    Query prev()  => $(dom[0].previousElementSibling);

    Query next()  => $(dom[0].nextElementSibling);

    bool hasClass(className) => dom.first.classes.contains(className);

    Query addClass(className) => each((elem){ elem.classes.add(className); });

    Query removeClass(className) => each((elem){ elem.classes.remove(className); });

    Query toggleClass(className) => each((elem){ elem.classes.toggle(className); });

    Query show() => each((elem){ elem.hidden = false; });

    Query hide() => each((elem){ elem.hidden = true; });

    Dynamic html([html]) {
        if (html !== null) {
            return each((elem){ elem.innerHTML = html; });
        }
        return dom[0].innerHTML;
    }

    Dynamic text([text]) {
        if (text !== null) {
            return each((elem){ elem.innerText = text; });
        }
        return dom[0].innerText;
    }

    Dynamic attr(name, [value]) {
        if (value !== null) {
            return each((elem){ elem.attributes[name] = value; });
        }
        return dom[0].attributes[name];
    }

    Dynamic data(name, [value]) {
        if (value !== null) {
            return each((elem){ elem.dataAttributes[name] = value; });
        }
        return dom[0].dataAttributes[name];
    }

    Query _insert(where, html) {
        return each((elem){
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

    Query append(html)  => _insert('beforeEnd', html);

    Query prepend(html) => _insert('afterBegin', html);

    Query before(html)  => _insert('beforeBegin', html);

    Query after(html)   => _insert('afterEnd', html);
}
