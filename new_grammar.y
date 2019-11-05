%token DOT
%token ASSING
%token DOT_DOT
%token LESS
%token LESS_EQ
%token GREATER
%token GR_EQ
%token EQ
%token NOT_EQ
%token MULL
%token DIV
%token PROC
%token ADD
%token SUB



Program: 
  %empty
| SimpleDeclaration
| RoutineDeclaration
| Program
;


SimpleDeclaration:
  VariableDeclaration
| TypeDeclaration
;


VariableDeclaration
 : var Identifier : Type [ is Expression ]
 | var Identifier is Expression
 
 
TypeDeclaration: 
  type Identifier is Type
 ;

RoutineDeclaration: routine Identifier ( Parameters ) [ : Type ] is
 Body
 end
 
 
Parameters: ParameterDeclaration { , ParameterDeclaration }


ParameterDeclaration : Identifier : Identifier
 
 
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
| SimpleDeclaration
| Statement
| Body
;














Statement: 
  Assignment 
| RoutineCall
| WhileLoop 
| ForLoop 
| /* ForeachLoop */
| IfStatement
;


Assignment:
  ModifiablePrimary ASSING Expression
;


RoutineCall : Identifier [ ( Expression { , Expression } ) ]

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

Summand : Primary | ( Expression )


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
| %empty
;

