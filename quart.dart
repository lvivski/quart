#library('quart');

#import('dart:html');
#import('dart:json');

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
    } else if(selector is List) {
      dom = selector;
      selector = null;
    } else {
      dom = new List.from(document.queryAll(selector));
    }
    return new Quart(dom, selector);
  }
}

class Quart {
  String selector;
  List  dom;

  Quart(this.dom, this.selector);

  Quart each(callback) {
    dom.forEach(callback);
    return this;
  }

  List map(callback) => dom.map(callback);

  Quart filter(callback) => $(dom.filter(callback));

  int size() => dom.length;

  Element get(idx) => dom[idx];

  Quart remove() => each((elem){ elem.remove(); });

  Quart first() => $(dom[0]);

  Quart last() => $(dom.last());

  Quart prev() => $(dom[0].previousElementSibling);

  Quart next() => $(dom[0].nextElementSibling);

  Quart parent() => $(map((elem) => elem.parent));

  Quart children() {
    List childList = [];
    each((elem){ childList.addAll(elem.elements); });
    return $(childList);
  }

  Quart find(sel) {
    List childList = [];
    each((elem){ childList.addAll(elem.queryAll(sel)); });
    return $(childList);
  }

  bool match(sel) => filter((elem) => elem.matchesSelector(sel)).size() > 0;

  Quart not(sel) => filter((elem) => elem.matchesSelector(sel) === false);

  bool hasClass(className) => dom[0].classes.contains(className);

  Quart addClass(className) => each((elem){ elem.classes.add(className); });

  Quart removeClass(className) => each((elem){ elem.classes.remove(className); });

  Quart toggleClass(className) => each((elem){ elem.classes.toggle(className); });

  Quart show() => each((elem){ elem.hidden = false; });

  Quart hide() => each((elem){ elem.hidden = true; });

  Dynamic html([htmlData]) {
    if (htmlData !== null) {
      return each((elem){ elem.innerHTML = htmlData; });
    }
    return dom[0].innerHTML;
  }

  /* Not yet implemented in VM */
  Dynamic text([textData]) {
    if (text !== null) {
      return each((elem){ elem.innerText = textData; });
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

  Quart _insert(where, htmlData) {
    return each((elem){
      if (htmlData is Quart) {
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

  Quart append(htmlData) => _insert('beforeEnd', htmlData);

  Quart prepend(htmlData) => _insert('afterBegin', htmlData);

  Quart before(htmlData) => _insert('beforeBegin', htmlData);

  Quart after(htmlData)  => _insert('afterEnd', htmlData);

  Quart bind(evt, callback) => each((elem){ QuartEvent.add(elem, evt, callback); });

  Quart unbind([evt, callback]) => each((elem){ QuartEvent.remove(elem, evt, callback); });
}

class QuartEvent {
  static List handlers;

  static Dynamic _find(Element elem, String evt, fn) {
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

class $_ {
  /*static List extensions;

  static noSuchMethod(String name, List args) {
    if (extensions === null) {
      extensions = [];
    }
    if (name.length > 4) {
      String prefix = name.substring(0, 4);
      String key   = name.substring(4);

      if (prefix == "get:") {
        return extensions[key];
      } else if (prefix == "set:") {
        extensions[key] = args[0];
      }
    }
  }*/

  static void ajax([Map options]) {
    if(options === null) {
      return;
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

    XMLHttpRequest xhr = new XMLHttpRequest();

    xhr.on.readyStateChange.add((evt){
      if (xhr.readyState == 4) {
        if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 0) {
          if (! (new RegExp(@"/^\s*$/")).hasMatch(xhr.responseText)) {
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
  }

  static void get(String url, [success]) {
    ajax({
      'url': url,
      'success': success });
  }

  static void post(String url, data, [success]) {
    ajax({
      'type': 'POST',
      'url' : url,
      'data': data,
      'success': success });
  }
}

