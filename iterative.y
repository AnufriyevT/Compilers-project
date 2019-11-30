
    
%{
    
%}

%start Program //starting token rule is 'Program', strict declaration
%visibility internal //parser class is visible only inside assembly


%output = iterative.cs //generate parser in that file

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
%token FOR
%token LESS_OR_EQUAL
%token IntegralLiteral
%token RealLiteral
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
%token Identifier


%%
Program: 
  SimpleDeclaration Program
| RoutineDeclaration Program
|
;


SimpleDeclaration:
  VariableDeclaration
| TypeDeclaration
;


VariableDeclaration: 
  VAR Identifier ASSIGN Type VariableExpression
| VAR Identifier IS Expression
; 
 
VariableExpression: 
    | IS expression 
	|
    ;

 
TypeDeclaration: 
  TYPE Identifier IS Type
 ;


RoutineDeclaration: 
  ROUTINE Identifier OPEN_PAREN Parameters CLOSE_PAREN RoutineReturnType IS LINE_BREAK Body LINE_BREAK END
;
 

RoutineReturnType: 
    | ASSIGN type 
	|
    ;
 


Parameters: 
  ParameterDeclaration ParameterDeclaration1
;


ParameterDeclaration1:
  COMMA ParameterDeclaration
| ParameterDeclaration1
|
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
  VariableDeclaration RecordType1
|
;


ArrayType: 
  ARRAY Type
| ARRAY Expression Type
;


Body:
  SimpleDeclaration Body
| Statement Body
|
;


Statement: 
  Assignment 
| RoutineCall
| WhileLoop 
| ForLoop 
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
   COMMA Expression RoutineCall1
|
;


WhileLoop: 
  WHILE Expression LOOP Body END
;


ForLoop:
  FOR Identifier Range LOOP Body END
;


Range: 
   IN Reverse Expression ELLIPSIS Expression
;

Reverse:
	REVERSE
|	
;



IfStatement: 
  IF Expression THEN Body ElseBody END
; 


ElseBody:
	ELSE Body
|
;

Expression: 
  Relation Relation1
;

Relation1:
	logic_operation Relation Relation1
|	
;

logic_operation
    : AND 
    | OR 
    | XOR 
    ;

Relation: 
  Simple
| Simple compare_sign Simple 
;


compare_sign
    : LESS 
    | LESS_OR_EQUAL 
    | GREATER 
    | GREATER_OR_EQUAL 
    | EQUAL
    | NOT_EQUAL
    ;


Simple: 
	Factor  Factor1
;

Factor1:
	mult_sign Factor Factor1
| 
;

mult_sign
    : MUL
    | DIV
    | MODULE
    ;

Factor: 
  Summand Summand1
;

Summand1:
	sum_sign Summand Summand1
|	
;


sum_sign: 
	ADD
|	SUB
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
;


ModifiablePrimary: 
  Identifier ModifiablePrimary1
;
  

ModifiablePrimary1:
  DOT Identifier ModifiablePrimary1
| DOT Expression ModifiablePrimary1
|                                 
;

%%

    Parser() : base(null) { }

    static void Main(string[] args)
    {
        Parser parser = new Parser();
        
        System.IO.TextReader reader;
        if (args.Length > 0)
            reader = new System.IO.StreamReader(args[0]);
        else
            reader = System.Console.In;
            
        parser.Scanner = new Lexer(reader);
        //parser.Trace = true;
        
        parser.Parse();
    }


    /*
     * Copied from GPPG documentation.
     */
    class Lexer: QUT.Gppg.AbstractScanner<int,LexLocation>
    {
         private System.IO.TextReader reader;
    
         //
         // Version 1.2.0 needed the following code.
         // In V1.2.1 the base class provides this empty default.
         //
         // public override LexLocation yylloc { 
         //     get { return null; } 
         //     set { /* skip */; }
         // }
         //
    
         public Lexer(System.IO.TextReader reader)
         {
             this.reader = reader;
         }
    
         public override int yylex()
         {
             char ch;
             int ord = reader.Read();
             //
             // Must check for EOF
             //
             if (ord == -1)
                 return (int)Tokens.EOF;
             else
                 ch = (char)ord;
    
             if (ch == '\n')
                return ch;
             else if (char.IsWhiteSpace(ch))
                 return yylex();
             else if (char.IsDigit(ch))
             {
                 yylval = ch - '0';
                 return (int)Tokens.Identifier;
             }
             // Don't use IsLetter here!
             else if ((ch >= 'a' && ch <= 'z') ||
                      (ch >= 'A' && ch <= 'Z'))
             {
                yylval = char.ToLower(ch) - 'a';
                return (int)Tokens.RealLiteral;
             }
             else
                 switch (ch)
                 {
                     case '+':
                     case '-':
                     case '*':
                     case '/':
                     case '(':
                     case ')':
                     case '%':
                     case '=':
                         return ch;
                     default:
                         Console.Error.WriteLine("Illegal character '{0}'", ch);
                         return yylex();
                 }
         }
    
         public override void yyerror(string format, params object[] args)
         {
             Console.Error.WriteLine(format, args);
         }
    }
