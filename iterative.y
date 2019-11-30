﻿﻿%{
    
%}

%start Program //starting token rule is 'Program', strict declaration
%visibility internal //parser class is visible only inside assembly

%output = iterative.cs //generate parser in that file

%union { 
  public double dVal; 
  public char cVal; 
  public int iVal;
  public string identifier_string;
}

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
%token NOT
%token EQUAL
%token NOT_EQUAL
%token LESS
%token GREATER
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
    Parser() : base(null) {}

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

    class Lexer: QUT.Gppg.AbstractScanner<ValueType,LexLocation>
    {
         private System.IO.TextReader reader;
    
         public Lexer(System.IO.TextReader reader)
         {
             this.reader = reader;
         }

         public bool is_keyword(string str)
         {
          switch (str) {
            case "type": return true;
            case "is": return true;
            case "var": return true;
            case "routine": return true;
            case "integer": return true;
            case "real": return true;
            case "boolean": return true;
            case "record": return true;
            case "array": return true;
            case "while": return true;
            case "for": return true;
            case "loop": return true;
            case "foreach": return true;
            case "if": return true;
            case "then": return true;
            case "else": return true;
            case "end": return true;
            case "and": return true;
            case "or": return true;
            case "xor": return true;
            case "not": return true;
            case "true": return true;
            case "false": return true;

            default: return false;
          }
         }

         public int get_keyword(string str)
         {
          switch (str) {
            case "type": return (int) Tokens.TYPE;
            case "is": return (int) Tokens.IS;
            case "var": return (int) Tokens.VAR;

            case "routine": return (int) Tokens.ROUTINE;
            case "integer": return (int) Tokens.INTEGER;
            case "real": return (int) Tokens.REAL;
            case "boolean": return (int) Tokens.BOOLEAN;
            case "record": return (int) Tokens.RECORD;
            case "array": return (int) Tokens.ARRAY;
            case "while": return (int) Tokens.WHILE;
            case "for": return (int) Tokens.FOR;
            case "loop": return (int) Tokens.LOOP;
            case "foreach": return (int) Tokens.FOR_EACH;
            case "if": return (int) Tokens.IF;
            case "then": return (int) Tokens.THEN;
            case "else": return (int) Tokens.ELSE;
            case "end": return (int) Tokens.END;
            case "and": return (int) Tokens.AND;
            case "or": return (int) Tokens.OR;
            case "xor": return (int) Tokens.XOR;
            case "not": return (int) Tokens.NOT;
            case "true": return (int) Tokens.TRUE;
            case "false": return (int) Tokens.FALSE;
            default: return -1;
          }
         }

         public bool is_op_symbol(char ch) {
          switch (ch) {
            case '+': return true;
            case '-': return true;
            case '*': return true;
            case '/': return true;
            case '%': return true;
            case '=': return true;
            case '>': return true;
            case '<': return true;
            case ':': return true;
            default: return false;
          }
         }

         public int is_operation(string str) {
          switch (str) {
            case "+": return (int) Tokens.ADD;
            case "-": return (int) Tokens.SUB;
            case "*": return (int) Tokens.MUL;
            case "/": return (int) Tokens.DIV;
            case "%": return (int) Tokens.MODULE;
            case "=": return (int) Tokens.EQUAL;
            case ">": return (int) Tokens.GREATER;
            case "<": return (int) Tokens.LESS;
            case ":": return (int) Tokens.ASSIGN;

            case ":=": return (int) Tokens.OP_ASSIGN;
            case ">=": return (int) Tokens.GREATER_OR_EQUAL;
            case "<=": return (int) Tokens.LESS_OR_EQUAL;
            case "/=": return (int) Tokens.NOT_EQUAL;
            default: return -1;
          }
         }
    
         public override int yylex()
         {
            char ch;
            int ord = reader.Read();
            
            if (ord == -1)
              return (int)Tokens.EOF;
            else
              ch = (char) ord;

            if (char.IsWhiteSpace(ch)) {
              return yylex();
            }

            // INTS, FLOATS
            if (char.IsDigit(ch)) {

              StringBuilder sb = new StringBuilder();
              sb.Append(ch);
              char next = (char) reader.Peek();

              if (ch == '0') {
                if (next == '.') {
                  next = (char) reader.Peek();
                  while (char.IsDigit(next)) {
                    sb.Append((char) reader.Read());
                    next = (char) reader.Peek();
                  }
                }
              }
            }
                
            if (char.IsLetter(ch) || ch == '_') {
              StringBuilder sb = new StringBuilder();
              sb.Append(ch);
              char next = (char) reader.Peek();
              while (char.IsLetter(next) || next == '_' || char.IsDigit(next)) {
                sb.Append((char) reader.Read());
                next = (char) reader.Peek();
              }
              string str = sb.ToString();
              if (is_keyword(str)) {
                Console.WriteLine("KEYWORD: {0}", str);
                return get_keyword(str);
              }
                  
              Console.WriteLine("IDENTIFIER: {0}", str);
              yylval.identifier_string = str;
              return (int) Tokens.Identifier;
            }

            // ---- OPERATIONS ----
            if (is_op_symbol(ch)) {
              StringBuilder sb = new StringBuilder();
              sb.Append(ch);
              char next = (char) reader.Peek();
              if (is_op_symbol(next)) {
                next = (char) reader.Read();
                sb.Append(next);
              }
              string str = sb.ToString();
              Console.WriteLine("OPERATION: {0}", str);
              return is_operation(str);
            }

            
            Console.WriteLine("{0}", ch);
            return (int) Tokens.Identifier;
        }
    
        public override void yyerror(string format, params object[] args)
        {
             Console.Error.WriteLine(format, args);
        }
      }