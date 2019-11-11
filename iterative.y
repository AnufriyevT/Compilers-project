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
  VAR Identifier ASSIGN Type IS Expression
| VAR Identifier ASSIGN Type
| VAR Identifier IS Expression
; 
 
 
TypeDeclaration: 
  TYPE Identifier IS Type
 ;


RoutineDeclaration: 
  ROUTINE Identifier OPEN_PAREN Parameters CLOSE_PAREN ASSIGN Type IS LINE_BREAK Body LINE_BREAK END
| ROUTINE Identifier OPEN_PAREN Parameters CLOSE_PAREN IS LINE_BREAK Body LINE_BREAK END
;
 
 
Parameters: 
  ParameterDeclaration ParameterDeclaration1
;


ParameterDeclaration1:
  COMMA ParameterDeclaration1
| ParameterDeclaration
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
   COMMA Expression
|  RoutineCall1
|
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
