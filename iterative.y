﻿%{
    
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
%token OPEN_SQUARE_BRACKET
%token CLOSE_SQUARE_BRACKET

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
    | IS Expression 
	|
    ;

 
TypeDeclaration: 
  TYPE Identifier IS Type
 ;

RoutineDeclaration: 
  ROUTINE Identifier OPEN_PAREN RoutineParameters CLOSE_PAREN RoutineReturnType IS Body END
;
 
RoutineParameters:
  Parameters
|
;

RoutineReturnType: 
    | ASSIGN Type 
	|
    ;

Parameters: 
  Parameters COMMA ParameterDeclaration
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
  VariableDeclaration RecordType1
|
;


ArrayType: 
  ARRAY Type
| ARRAY OPEN_SQUARE_BRACKET Expression CLOSE_SQUARE_BRACKET Type
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
  Relation
| Expression logic_operation Relation
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

compare_sign:
    LESS 
    | LESS_OR_EQUAL 
    | GREATER 
    | GREATER_OR_EQUAL 
    | EQUAL
    | NOT_EQUAL
    ;


Simple: 
  Simple mult_sign Factor
| Factor 
;

mult_sign
    : MUL
    | DIV
    | MODULE
    ;

Factor: 
  Factor sum_sign Summand
| Summand 
;

sum_sign: 
	ADD
|	SUB
;

Summand: 
  Primary
| OPEN_PAREN Expression CLOSE_PAREN
;


Primary: 
  IntegralLiteral
| RealLiteral
| TRUE 
| FALSE
| ModifiablePrimary
;

ModifiablePrimary: 
  Identifier 
| ModifiablePrimary OPEN_SQUARE_BRACKET Expression CLOSE_SQUARE_BRACKET
| ModifiablePrimary DOT Identifier
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
            //case "return": return (int) Tokens.RETURN; //wtf
            default: return -1;
          }
         }

         public bool is_first_op_symbol(char ch) {
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
            case '(': return true;
            case ')': return true;
            case '[': return true;
            case ']': return true;
            default: return false;
          }
         }
 
         public bool is_second_op_symbol(char ch) {
          switch (ch) {
            case '=': return true;
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
            case "(": return (int) Tokens.OPEN_PAREN;
            case ")": return (int) Tokens.CLOSE_PAREN;
            case "[": return (int) Tokens.OPEN_SQUARE_BRACKET;
            case "]": return (int) Tokens.CLOSE_SQUARE_BRACKET;

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
                  string str = sb.ToString();
                  yylval.dVal = Convert.ToDouble(str);
                  return (int) Tokens.REAL;
                } else {
                  yylval.iVal = 0;
                  return (int) Tokens.INTEGER;
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
              int keyword_token = get_keyword(str);
              if (! (keyword_token == -1)) {
                Console.WriteLine("KEYWORD: {0}", str);
                return keyword_token;
              }
                  
              Console.WriteLine("IDENTIFIER: {0}", str);
              yylval.identifier_string = str;
              return (int) Tokens.Identifier;
            }

            // ---- OPERATIONS, BRACKETS ----
            if (is_first_op_symbol(ch)) {
              StringBuilder sb = new StringBuilder();
              sb.Append(ch);
              char next = (char) reader.Peek();
              if (is_second_op_symbol(next)) {
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
