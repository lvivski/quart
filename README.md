# Quart

Quart is a minimalist Dart library with a jQuery-compatible API and chaining syntax.

# Element functions:

``` js
get(0)              // return first element found
size()              // the number of elements in collection
each(callback)      // iterate over collection, calling callback for every element
first()             // new collection containing only the first matched element
last()              // new collection containing only the last matched element
next()              // next siblings
prev()              // previous siblings
remove()            // remove element

html()              // get first element's .innerHTML
html('<br />')      // set the contents to the element(s)
text()              // get first element's .innerText
text('text')        // set the text contents to the element(s)
attr('name')        // get element attribute
attr('name', 'val') // set element attribute
data('name')        // gets the value of the "data-name" attribute
data('name', 'val') // sets the value of the "data-name" attribute
addClass('name')    // adds a CSS class name
removeClass('name') // removes a CSS class name
hasClass('name')    // returns true of first element has a classname set
toggleClass('name') // adds/removes class
append(), prepend() // like html(), but add html (or a DOM Element or a Quart object) to element contents
before(), after()   // add html (or a DOM Element or a Quart object) before/after the element

show()              // forces elements to be displayed
hide()              // hides elements

bind('event', function)      // add an event listener
unbind(['event', function]) // remove event listeners
```

# Ajax

Simple GET and POST:

``` js
$_.get(url, [callback])
$_.post(url, data, [callback])
```

If you need more control (all keys are optional):

``` js
$_.ajax({
  'type': 'POST',                      // defaults to 'GET'
  'url': '/foo',                       // defaults to window.location
  'data': {'hello': 'Hello World!'},   // can be a String or Map
  'success': (body, [type, xhr]]) {}, // body is a string or JSON
  'error': (xhr, [type]) {}            // type is a string ('error')
})
```

## License

Copyright (c) 2012 Yehor Lvivski

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
