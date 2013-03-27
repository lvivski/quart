part of quart;

class QuartDom {
  String selector;
  List<HtmlElement>  dom;
  Quart Q;

  QuartDom(this.dom, this.selector): Q = new Quart();

  QuartDom each(void callback(HtmlElement el)) {
    dom.forEach(callback);
    return this;
  }

  List map(callback(HtmlElement el)) => dom.map(callback).toList();

  QuartDom filter(bool callback(HtmlElement el)) => Q(dom.where(callback).toList());

  int size() => dom.length;

  Element get(num idx) => dom[idx];

  QuartDom remove() => each((elem){ elem.remove(); });

  QuartDom first() => Q(dom[0]);

  QuartDom last() => Q(dom.last);

  QuartDom prev() => Q(dom[0].previousElementSibling);

  QuartDom next() => Q(dom[0].nextElementSibling);

  QuartDom parent() => Q(map((elem) => elem.parent));

  QuartDom children() {
    var childList = [];
    each((elem){ childList.addAll(elem.children); });
    return Q(childList);
  }

  QuartDom find(String sel) {
    var childList = [];
    each((elem){ childList.addAll(elem.queryAll(sel)); });
    return Q(childList);
  }

  bool matches(String sel) => filter((elem) => elem.matches(sel)).size() > 0;

  QuartDom not(String sel) => filter((elem) => elem.matches(sel) == false);

  bool hasClass(String className) => dom[0].classes.contains(className);

  QuartDom addClass(String className) => each((elem){ elem.classes.add(className); });

  QuartDom removeClass(String className) => each((elem){ elem.classes.remove(className); });

  QuartDom toggleClass(String className) => each((elem){ elem.classes.toggle(className); });

  QuartDom show() => each((elem){ elem.hidden = false; });

  QuartDom hide() => each((elem){ elem.hidden = true; });

  html([String htmlData]) {
    if (?htmlData) {
      return each((elem){ elem.innerHtml = htmlData; });
    }
    return dom[0].innerHtml;
  }

  /* Not yet implemented in VM */
  text([String textData]) {
    if (?textData) {
      return each((elem){ elem.text = textData; });
    }
    return dom[0].text;
  }

  attr(String name, [String value]) {
    if (?value) {
      return each((elem){ elem.attributes[name] = value; });
    }
    return dom[0].attributes[name];
  }

  data(String name, [String value]) {
    if (?value) {
      return each((elem){ elem.dataset[name] = value; });
    }
    return dom[0].dataset[name];
  }

  QuartDom _insert(String where, htmlData) {
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

  QuartDom bind(String evt, void callback(Event e)) => each((elem){ QuartEvents.add(elem, evt, callback); });

  QuartDom unbind([String evt, void callback(Event e)]) => each((elem){ QuartEvents.remove(elem, evt, callback); });
}
