%token ASSIGN
%token OP_ASSIGN
%token IS
%token INTEGER
%token TYPE
%token REAL
%token BOOLEAN
%token BEGIN
%token END
%token RECORD
%token ARRAY
%token LOOP
%token IN
%token REVERSE
%token ELLIPSIS
%token FOR_EACH
%token IF
%token THEN
%token ELSE
%token WHILE
%token ADD
%token SUB
%token MUL
%token DIV
%token ROUTINE
%token OPEN_PAREN
%token CLOSE_PAREN
%token DOT
%token AND
%token OR
%token XOR
%token EQUAL
%token NOT_EQUAL
%token LESS
%token GREATER
%token LESS_OR_GREATER
%token GREATER_OR_EQUAL
%token MODULE
%token COMMA
%token VAR
%token FROM
%token TRUE
%token FALSE
%token LINE_BREAK

Program: 
  %empty
| SimpleDeclaration Program
| RoutineDeclaration Program
;


SimpleDeclaration:
  VariableDeclaration
| TypeDeclaration
;


VariableDeclaration: 
  VAR Identifier ASSIGN Type IS Expression
| VAR Identifier ASSIGN Type
| var Identifier IS Expression
; 
 
 
TypeDeclaration: 
  TYPE Identifier IS Type
 ;


RoutineDeclaration: 
  ROUTINE Identifier OPEN_PAREN Parameters CLOSE_PAREN ASSIGN Type IS LINE_BREAK Body LINE_BREAK END
| ROUTINE Identifier OPEN_PAREN Parameters CLOSE_PAREN IS LINE_BREAK Body LINE_BREAK END
;
 
 
Parameters: 
  OPEN_PAREN ParameterDeclaration ParameterDeclaration1 CLOSE_PAREN
;


ParameterDeclaration1:
  %empty
| COMMA ParameterDeclaration1
| ParameterDeclaration
;


ParameterDeclaration: 
  Identifier ASSIGN Identifier
; 
 
 
Type: 
  PrimitiveType
| ArrayType
| RecordType
| Identifier
;


PrimitiveType: 
  INTEGER 
| REAL
| BOOLEAN
;


RecordType: 
  RECORD RecordType1 END
;


RecordType1: 
  %empty
| VariableDeclaration RecordType1
;


ArrayType: 
  ARRAY Type
| ARRAY Expression Type
;


Body:
  %empty
| SimpleDeclaration Body
| Statement Body
;


Statement: 
  Assignment 
| RoutineCall
| WhileLoop 
| ForLoop 
| ForeachLoop
| IfStatement
;


Assignment:
  ModifiablePrimary OP_ASSIGN Expression
;

RoutineCall: 
  Identifier 
| Identifier OPEN_PAREN Expression RoutineCall1 CLOSE_PAREN
;


RoutineCall1:
  %empty
| COMMA Expression
|  RoutineCall1
;


WhileLoop: 
  WHILE Expression LOOP Body END
;


ForLoop:
  FOR Identifier Range LOOP Body END
;


Range: 
   IN REVERSE Expression ELLIPSIS Expression
|  IN Expression ELLIPSIS Expression
;


ForeachLoop:
    FOR_EACH Identifier FROM ModifiablePrimary LOOP Body END
;


IfStatement: 
  IF Expression THEN Body ELSE Body END
| IF Expression THEN Body END
; 


Expression: 
  Relation 
| Relation OPEN_PAREN AND CLOSE_PAREN Expression
| Relation OPEN_PAREN OR CLOSE_PAREN Expression
| Relation OPEN_PAREN XOR CLOSE_PAREN Expression
;


Relation: 
  Simple
| Simple LESS Simple 
| Simple LESS_OR_EQUAL Simple
| Simple GREATER Simple
| Simple GREATER_OR_EQUAL Simple
| Simple EQUAL Simple
| Simple NOT_EQUAL Simple
;


Simple: 
  Factor
| Factor MUL Simple
| Factor DIV Simple
| Factor MODULE Simple
;


Factor: 
  Summand 
| Summand ADD Factor
| Summand SUB Factor
;


Summand: 
  Primary
| OPEN_PAREN Expression CLOSE_PAREN
;


Primary : 
  IntegralLiteral
| RealLiteral
| TRUE 
| FALSE
| ModifiablePrimary


ModifiablePrimary: 
  Identifier ModifiablePrimary1
;
  
ModifiablePrimary1:
  DOT Identifier ModifiablePrimary1
| DOT Expression ModifiablePrimary1
| %empty                                   
;


