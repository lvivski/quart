part of quart;

class QuartEvents {
  static List handlers = [];
  static List<StreamSubscription> subscriptions = [];

  static _find(Element elem, String evt, fn) {
    return handlers.where((handler){
      return handler != null
        && handler['elem'] == elem
        && (evt == null || handler['evt'] == evt)
        && (fn == null || handler['fn'] == fn);
    }).toList();
  }

  static void add(Element elem, String evts, fn) {
    evts.split(" ").forEach((evt){
      handlers.add({
        'evt' : evt.trim(),
        'elem': elem,
        'fn' : fn,
        'idx' : handlers.length });
      subscriptions.add(elem.on[evt].listen(fn));
    });
  }

  static void remove(Element elem, String evts, fn) {
    evts.split(" ").forEach((evt){
      _find(elem, evt, fn).forEach((handler){
        handlers[handler['idx']] = null;
        subscriptions[handler['idx']].cancel();
      });
    });
  }
}