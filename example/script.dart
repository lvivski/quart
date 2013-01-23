import 'dart:html';
import 'package:quart/quart.dart';
void main() {
    $('.test').hide().data('path', 'asda').html('<i></i>').addClass('newClass').removeClass('test').prev().addClass('test').show();
    var button = () => new Element.html('<button>Button</button>');
    var button2 = () => new Element.html('<button class="big">Button</button>');
    var input = () => new Element.html('<input type="text" />');
    $('.test').append(button());
    $('div').addClass('test');
    $('.test').removeClass('newClass').before(button2()).prepend(input()).show();
    $('.test').html();

    $('button').bind('click', (e){
        print(e);
    });

    $('button').first().unbind('click');

    $.ajax({
        'url': 'ajax.json',
        'success': (data, [type, xhr]){
            print(data);
        }
    });

    print($('button').parent().dom);
    print($('button').matches('.big'));

    print($('ul.children').find('li').size());

    print($('ul.children').children().size());
}