# springrts Unit definition parser

This project implements some Perl parsers for the springrts unit definition files.

These configuration files are written in Lua, but this parser allows you to extract their content
  into an AST (abstract syntax tree) composed of nested hashmaps.

The file anni-parser.pl demonstrates this -- it also prints the maps to the screen in an easily read nested format.
