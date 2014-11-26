
library prompt.example.barista.serve;

import 'dart:math';

import 'coffee_order.dart';

String serve(CoffeeOrder order) => indent('''
${_topContent(order)}
${_rowContent(order)}
''', _indent);

_topContent(CoffeeOrder order) {
  var topSize = _rowWidth(_rows.length);
  if (order.iced && !order.straw) return '_' * topSize;
  var topRows = order.straw ?
  [
    '<_>',
    '| |',
    '|_|'
  ] :
  [
    '    )      ',
    '(  (    )  ',
    '_)__)__(__('
  ];

  var _steamRows = [
    center(topRows[0], topSize, ' '),
    center(topRows[1], topSize, ' '),
    center(topRows[2], topSize, '_')
  ];
  return _steamRows.join('\n');
}

final int _indent = 2;

String _rowContent(order) {
  var rowMap = _rows.asMap();
  var cupRows = [];
  rowMap.forEach((row, formatter) {
    cupRows.add(_cupRow(formatter(order), row));
  });

  return cupRows.join('\n');
}

String _cupRow(String content, int row) {
  var prefix = ' ' * row;
  var rowWidth = _rowWidth((_rows.length - 1) - row);
  var cupContent = content.substring(0, min(content.length, rowWidth))
      .padRight(rowWidth);
  var handleRow = _handleRows[row];
  return '$prefix\\$cupContent/$handleRow';
}

_rowWidth(int row) => row * 2 + _bottomWidth;

List _rows = [
  (order) => order.iced ? ('-^' * (_rowWidth(_rows.length - 1) ~/ 2)) : '',
  (order) => '   ' + order.name,
  (order) =>  '  ' + order.item + (order.double ? ' X 2' : ''),
  (order) =>   ' ' + (order.iced ? '☑' : '☐') + ' Iced',
  (order) => '',
  (order) => _bottom,
];

var x = '^-^-^-^-^-^';

var _handleRows = [
       '',
      '--.',
     '--. |',
    '___/ /',
   '_____/',
  ''
];

final String _bottom = '${'_' * _bottomWidth}';
final int _bottomWidth = 8;

indent(String s, int count, [String indenter = ' ']) =>
    s.split('\n').map((line) => (indenter * count) + line).join('\n');

String center(String input, int width, String fill) {
  if (fill == null || fill.length == 0) {
    throw new ArgumentError('fill cannot be null or empty');
  }
  if (input == null) input = '';
  var leftWidth = input.length + (width - input.length) ~/ 2;
  return input.padLeft(leftWidth, fill).padRight(width, fill);
}
