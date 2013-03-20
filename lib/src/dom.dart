part of quart;

typedef void DomIteratorCallback(HtmlElement element);

class QuartDom {
  String selector;
  List<HtmlElement>  dom;
  Quart Q;

  QuartDom(this.dom, this.selector): Q = new Quart();

  QuartDom each(DomIteratorCallback callback) {
    dom.forEach(callback);
    return this;
  }

  List map(callback) => dom.map(callback).toList();

  QuartDom filter(callback) => Q(dom.where(callback).toList());

  int size() => dom.length;

  Element get(idx) => dom[idx];

  QuartDom remove() => each((elem){ elem.remove(); });

  QuartDom first() => Q(dom[0]);

  QuartDom last() => Q(dom.last);

  QuartDom prev() => Q(dom[0].previousElementSibling);

  QuartDom next() => Q(dom[0].nextElementSibling);

  QuartDom parent() => Q(map((elem) => elem.parent));

  QuartDom children() {
    List childList = [];
    each((elem){ childList.addAll(elem.children); });
    return Q(childList);
  }

  QuartDom find(sel) {
    List childList = [];
    each((elem){ childList.addAll(elem.queryAll(sel)); });
    return Q(childList);
  }

  bool matches(sel) => filter((elem) => elem.matches(sel)).size() > 0;

  QuartDom not(sel) => filter((elem) => elem.matches(sel) == false);

  bool hasClass(className) => dom[0].classes.contains(className);

  QuartDom addClass(className) => each((elem){ elem.classes.add(className); });

  QuartDom removeClass(className) => each((elem){ elem.classes.remove(className); });

  QuartDom toggleClass(className) => each((elem){ elem.classes.toggle(className); });

  QuartDom show() => each((elem){ elem.hidden = false; });

  QuartDom hide() => each((elem){ elem.hidden = true; });

  html([htmlData]) {
    if (htmlData != null) {
      return each((elem){ elem.innerHtml = htmlData; });
    }
    return dom[0].innerHtml;
  }

  /* Not yet implemented in VM */
  text([textData]) {
    if (text != null) {
      return each((elem){ elem.text = textData; });
    }
    return dom[0].text;
  }

  attr(name, [value]) {
    if (value != null) {
      return each((elem){ elem.attributes[name] = value; });
    }
    return dom[0].attributes[name];
  }

  data(name, [value]) {
    if (value != null) {
      return each((elem){ elem.dataset[name] = value; });
    }
    return dom[0].dataset[name];
  }

  QuartDom _insert(where, htmlData) {
    return each((elem){
      if (htmlData is QuartDom) {
        dom = htmlData.dom;
        if (where == 'afterBegin' || where == 'afterEnd') {
         for (var i=0; i < dom.length; i++) {
          elem.insertAdjacentElement(where, dom[dom.length-i-1]);
         }
        } else {
         for (var i=0; i < dom.length; i++) {
          elem.insertAdjacentElement(where, dom[i]);
         }
        }
      } else {
        if(htmlData is Element) {
          elem.insertAdjacentElement(where, htmlData);
        } else {
          elem.insertAdjacentHtml(where, htmlData);
        }
      }
    });
  }

  QuartDom append(htmlData) => _insert('beforeEnd', htmlData);

  QuartDom prepend(htmlData) => _insert('afterBegin', htmlData);

  QuartDom before(htmlData) => _insert('beforeBegin', htmlData);

  QuartDom after(htmlData)  => _insert('afterEnd', htmlData);

  QuartDom bind(evt, callback) => each((elem){ QuartEvents.add(elem, evt, callback); });

  QuartDom unbind([evt, callback]) => each((elem){ QuartEvents.remove(elem, evt, callback); });
}
