library quart;

import 'dart:html';
import 'dart:json';

class Quart {
  Map extensions;

  noSuchMethod(mirror) {
    if (extensions === null) {
      extensions = {};
    }
    if (mirror.memberName.length > 4) {
      String name = mirror.memberName;
      List args = mirror.positionalArguments;
      String prefix = name.substring(0, 4);
      String key = name.substring(4);
      if (prefix == "get:") {
        return extensions[key];
      } else if (prefix == "set:") {
        extensions[key] = args[0];
      }
    }
  }
  
  call(selector, [context]) {
    if (context !== null) {
      return call(context).find(selector);
    } else if (selector is QuartDom) {
      return selector;
    } else {
      List dom;
      if (selector is Element) {
        dom = [selector];
        selector = null;
      } else if(selector is List) {
        dom = selector;
        selector = null;
      } else {
        dom = new List.from(document.queryAll(selector));
      }
      return new QuartDom(dom, selector);
    }
  }

  HttpRequest ajax([Map options]) {
    if(options === null) {
      throw new Exception();
    }
    var empty  = ([data, state, xhr]){};
    var callback = options.containsKey('success') ? options['success'] : empty;
    var errback = options.containsKey('error') ? options['error'] : empty;
    String type = options.containsKey('type') ? options['type'] : 'GET';
    String url  = options.containsKey('url') ? options['url'] : window.location.toString();
    String data;
    if (options.containsKey('data') && options['data'] is Map) {
      data = JSON.stringify(data);
    }

    HttpRequest xhr = new HttpRequest();

    xhr.on.readyStateChange.add((evt){
      if (xhr.readyState == 4) {
        if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 0) {
          if (! (new RegExp(r"/^\s*$/")).hasMatch(xhr.responseText)) {
            callback(JSON.parse(xhr.responseText), 'success', xhr);
          } else {
            callback(xhr.responseText, 'success', xhr);
          }
        } else {
          errback(xhr, 'error');
        }
      }
    });

    xhr.open(type, url, true);
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.send(data);
    return xhr;
  }

  HttpRequest get(String url, [success]) {
    return ajax({
      'url': url,
      'success': success });
  }

  HttpRequest post(String url, data, [success]) {
    return ajax({
      'type': 'POST',
      'url' : url,
      'data': data,
      'success': success });
  }
}

class QuartDom {
  String selector;
  List  dom;
  Quart Q;

  QuartDom(this.dom, this.selector): Q = new Quart();

  QuartDom each(callback) {
    dom.forEach(callback);
    return this;
  }

  List map(callback) => dom.map(callback);

  QuartDom filter(callback) => Q(dom.filter(callback));

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
    each((elem){ childList.addAll(elem.elements); });
    return Q(childList);
  }

  QuartDom find(sel) {
    List childList = [];
    each((elem){ childList.addAll(elem.queryAll(sel)); });
    return Q(childList);
  }

  bool match(sel) => filter((elem) => elem.matchesSelector(sel)).size() > 0;

  QuartDom not(sel) => filter((elem) => elem.matchesSelector(sel) === false);

  bool hasClass(className) => dom[0].classes.contains(className);

  QuartDom addClass(className) => each((elem){ elem.classes.add(className); });

  QuartDom removeClass(className) => each((elem){ elem.classes.remove(className); });

  QuartDom toggleClass(className) => each((elem){ elem.classes.toggle(className); });

  QuartDom show() => each((elem){ elem.hidden = false; });

  QuartDom hide() => each((elem){ elem.hidden = true; });

  html([htmlData]) {
    if (htmlData !== null) {
      return each((elem){ elem.innerHTML = htmlData; });
    }
    return dom[0].innerHTML;
  }

  /* Not yet implemented in VM */
  text([textData]) {
    if (text !== null) {
      return each((elem){ elem.innerText = textData; });
    }
    return dom[0].innerText;
  }

  attr(name, [value]) {
    if (value !== null) {
      return each((elem){ elem.attributes[name] = value; });
    }
    return dom[0].attributes[name];
  }

  data(name, [value]) {
    if (value !== null) {
      return each((elem){ elem.dataAttributes[name] = value; });
    }
    return dom[0].dataAttributes[name];
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
          elem.insertAdjacentHTML(where, htmlData);
        }
      }
    });
  }

  QuartDom append(htmlData) => _insert('beforeEnd', htmlData);

  QuartDom prepend(htmlData) => _insert('afterBegin', htmlData);

  QuartDom before(htmlData) => _insert('beforeBegin', htmlData);

  QuartDom after(htmlData)  => _insert('afterEnd', htmlData);

  QuartDom bind(evt, callback) => each((elem){ QuartEvent.add(elem, evt, callback); });

  QuartDom unbind([evt, callback]) => each((elem){ QuartEvent.remove(elem, evt, callback); });
}

class QuartEvent {
  static List handlers;

  static _find(Element elem, String evt, fn) {
    return handlers.filter((handler){
      return handler !== null
        && handler['elem'] === elem
        && (evt === null || handler['evt'] == evt)
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
        'fn' : fn,
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

