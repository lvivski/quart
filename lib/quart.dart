library quart;

import 'dart:html';
import 'dart:json';

part 'src/events.dart';
part 'src/dom.dart';

class Quart {
  Map extensions;

  noSuchMethod(InvocationMirror mirror) {
    if (extensions == null) {
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

  call(Object selector, [Object context]) {
    if (context != null) {
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
    if(options == null) {
      throw new Exception();
    }
    var empty  = ([data, state, xhr]){};
    var callback = options.containsKey('success') ? options['success'] : empty;
    var errback = options.containsKey('error') ? options['error'] : empty;
    String type = options.containsKey('type') ? options['type'] : 'GET';
    String url  = options.containsKey('url') ? options['url'] : window.location.toString();
    String data;
    if (options.containsKey('data') && options['data'] is Map) {
      data = stringify(data);
    }

    HttpRequest xhr = new HttpRequest();

    xhr.on.readyStateChange.add((evt){
      if (xhr.readyState == 4) {
        if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 0) {
          if (! (new RegExp(r"/^\s*$/")).hasMatch(xhr.responseText)) {
            callback(parse(xhr.responseText), 'success', xhr);
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

  HttpRequest get(String url, [Function success]) {
    return ajax({
      'url': url,
      'success': success });
  }

  HttpRequest post(String url, data, [Function success]) {
    return ajax({
      'type': 'POST',
      'url' : url,
      'data': data,
      'success': success });
  }
}

var $ = new Quart();