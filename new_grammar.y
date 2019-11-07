%token ASSING
%token IS
%token TYPE
%token INTEGER
%token REAL
%token BOOLEAN
%token BEGIN
%token END
%token RECORD
%token ARRAY
%token LOOP
%token IN
%token THEN
%token ELSE
%token WHILE
%token ADD
%token SUB
%token MULL
%token DIV
%token ROUTINE
%token COLON
%token OPEN_PAREN
%token CLOSE_PAREN
%token OPEN_BRACKET
%token CLOSE_BRACKET
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
  var Identifier COL Type is Expression
| var Identifier COL Type
| var Identifier is Expression
; 
 
TypeDeclaration: 
  type Identifier is Type
 ;

RoutineDeclaration: 
  routine Identifier ( Parameters ) is Body end        ??????  [Parameters]
| routine Identifier ( Parameters ) COL Type is Body end   ??????
;
 
Parameters: 
  ParameterDeclaration 
| ParameterDeclaration , Parameters   ?? Comma?
;

ParameterDeclaration: 
  Identifier : Identifier
; 
 
Type: 
  PrimitiveType
| ArrayType
| RecordType
| Identifier
;

PrimitiveType: 
  integer 
| real
| boolean
;

RecordType: 
  record RecordType1  end
;

RecordType1: 
  %empty
| VariableDeclaration RecordType1
;

ArrayType: 
  array Type
| array Expression Type
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
| /* ForeachLoop */      ???
| IfStatement
;


Assignment:
  ModifiablePrimary ASSING Expression
;

RoutineCall: 
  Identifier 
| Identifier Expression RoutineCall1
;

RoutineCall1:
  %empty
|  , Expression    ??? Comma?
|  RoutineCall1
;


WhileLoop: 
  while Expression loop Body end
;

ForLoop:
  for Identifier Range loop Body end
;

Range: 
   in reverse Expression DOT_DOT Expression
|  in Expression DOT_DOT Expression
;

ForeachLoop:
    foreach Identifier from ModifiablePrimary loop Body end
;

IfStatement: 
  if Expression then Body else Body end
| if Expression then Body end
; 


Expression: 
  Relation 
| Relation and Expression
| Relation or Expression
| Relation xor Expression
;


Relation: 
  Simple
| Simple LESS Simple 
| Simple LESS_EQ Simple
| Simple GREATER Simple
| Simple GR_EQ Simple
| Simple EQ Simple
| Simple NOT_EQ Simple
;

Simple: 
  Factor
| Factor MULL Simple
| Factor DIV Simple
| Factor PROC Simple
;

Factor: 
  Summand 
| Summand ADD Factor
| Summand SUB Factor
;

Summand: 
  Primary
| ( Expression )
;

Primary : 
  IntegralLiteral
| RealLiteral
| true 
| false
| ModifiablePrimary


ModifiablePrimary: 
  Identifier ModifiablePrimary1
;
  
ModifiablePrimary1:
  DOT Identifier ModifiablePrimary1
| DOT Expression ModifiablePrimary1
| %empty                                     ?????????? Mistake in project description??
;

