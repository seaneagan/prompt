
library stdio;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<String> readLine() => linesIterator.moveNext().then((_) => linesIterator.current);
StreamIterator linesIterator = new StreamIterator(_lines);
final _lines = stdin.transform(UTF8.decoder).transform(const LineSplitter());
