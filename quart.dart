$(selector, [context]){
    if (context !== null) {
        return $(context).find(selector);
    } else if (selector is Quart) {
        return selector;
    } else {
        List dom;
        if (selector is Element) {
            dom = [selector];
            selector = null;
        } else {
            dom =  new List.from(document.queryAll(selector));
        }
        return new Quart(dom, selector);
    }
}

class Quart {
    final String selector;
    final List   dom;

    Quart(this.dom, this.selector);

    Quart each(callback) {
        dom.forEach(callback);
        return this;
    }

    List map(callback) {
        return dom.map(callback);
    }

    int size() => dom.length;

    Element get(idx) => dom[idx];

    Quart remove() => each((elem){ elem.remove(); });

    Quart first() => $(dom[0]);

    Quart last()  => $(dom.last());

    Quart prev()  => $(dom[0].previousElementSibling);

    Quart next()  => $(dom[0].nextElementSibling);

    bool hasClass(className) => dom.first.classes.contains(className);

    Quart addClass(className) => each((elem){ elem.classes.add(className); });

    Quart removeClass(className) => each((elem){ elem.classes.remove(className); });

    Quart toggleClass(className) => each((elem){ elem.classes.toggle(className); });

    Quart show() => each((elem){ elem.hidden = false; });

    Quart hide() => each((elem){ elem.hidden = true; });

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

    Quart _insert(where, html) {
        return each((elem){
            if (html is Quart) {
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

    Quart append(html)  => _insert('beforeEnd', html);

    Quart prepend(html) => _insert('afterBegin', html);

    Quart before(html)  => _insert('beforeBegin', html);

    Quart after(html)   => _insert('afterEnd', html);

    Quart bind(evt, callback) => each((elem){ QuartEvent.add(elem, evt, callback); });

    Quart unbind(evt, [callback]) => each((elem){ QuartEvent.remove(elem, evt, callback); });
}

class QuartEvent {
    static List handlers;

    static Dynamic _find(Element elem, String evt, fn) {
        return handlers.filter((handler){
            return handler !== null
                && handler['elem'] === elem
                && handler['evt'] == evt
                && (fn === null || handler['fn'] === fn);
        });
    }

    static void add(Element elem, String evts, fn) {
        if (handlers === null) {
            handlers = [];
        }
        evts.split(" ").forEach((evt){
            handlers.add({
                'evt' : evt.trim(),
                'elem': elem,
                'fn'  : fn,
                'idx' : handlers.length });
            elem.on[evt].add(fn);
        });
    }

    static void remove(Element elem, String evts, fn) {
        if (handlers === null) {
            handlers = [];
        }
        evts.split(" ").forEach((evt){
            _find(elem, evt, fn).forEach((handler){
                handlers[handler['idx']] = null;
                elem.on[evt].remove(handler['fn']);
            });
        });
    }
}
