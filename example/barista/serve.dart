
library prompt.example.barista.serve;

import 'dart:math';

import 'package:ansicolor/ansicolor.dart';

import 'coffee_order.dart';

String serve(CoffeeOrder order) => indent('''
${_topContent(order)}
${_rowContent(order)}
''', _indent);

String _topContent(CoffeeOrder order) {
  var topSize = _rowWidth(_rows.length);
  if (order.iced && !order.straw) return _cupPen('_' * topSize);
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
    colorLid(center(topRows[2], topSize, '_'))
  ].map(colorSteam);
  return _steamRows.join('\n');
}

String colorSteam(String smoky) => smoky.replaceAllMapped(new RegExp(r'[()]'),
    (Match match) => _steamPen(match.group(0)));
var _steamPen = new AnsiPen()..gray(level: 0.5);

String colorLid(String top) => top.replaceAllMapped(new RegExp(r'_+'),
    (Match match) => _cupPen(match.group(0)));
var _cupPen = new AnsiPen()..blue(bold: true);

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
  return '$prefix${_cupPen('\\')}$cupContent${_cupPen('/$handleRow')}';
}

_rowWidth(int row) => row * 2 + _bottomWidth;


List _rows = [
  (order) => order.iced ? (_styledIcePattern *
      (_rowWidth(_rows.length - 1) ~/ _icePattern.length)) : '',
  (order) => '   ' + _textPen(order.name),
  (order) =>  '  ' + _textPen(order.item + (order.double ? ' X 2' : '')),
  (order) =>   ' ' + _textPen('[' + (order.iced ? 'x' : ' ') + '] Iced'),
  (order) => '',
  (order) => _bottom,
];
var _iceCube1 = '[]';
var _iceCube2 = '<>';
var _surface = '-';
var _surfacePen = (x) => x; // new AnsiPen()..yellow();
var _icePattern = _surface + _iceCube1 + _surface + _iceCube2;
var _styledIcePattern = _surfacePen(_surface) + _icePen(_iceCube1) + _surfacePen(_surface) + _icePen(_iceCube2);
var _icePen = (x) => x; // new AnsiPen()..cyan(bold: true);
var _textPen = (x) => x; // new AnsiPen()..white(bold: true);

var _handleRows = [
       '',
      '--.',
     '--. |',
    '___/ /',
   '_____/',
  ''
];

final String _bottom = '_' * _bottomWidth;
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
