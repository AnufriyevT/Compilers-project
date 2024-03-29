﻿﻿%{
    AST_Node root = null;
%}
%namespace Compiler
%start Program //starting token rule is 'Program', strict declaration
%visibility internal //parser class is visible only inside assembly
%YYSTYPE Compiler.AST_Node
%output = iterative.cs //generate parser in that file

%token ASSIGN
%token OP_ASSIGN
%token IS
%token INTEGER
%token TYPE
%token TYPE_INT
%token TYPE_REAL
%token TYPE_BOOL
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
%token IN
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
%token RETURN

%%
Program: 
 {
   $$ = new AST_Node("Program", false);
  root = $$;
  }
| Program SimpleDeclaration  {$1.add_child($2);}
| Program RoutineDeclaration   {$1.add_child($2);}
;



SimpleDeclaration:
  VariableDeclaration {$$ = $1;}
| TypeDeclaration {$$ = $1;}
;

// SymbolTAble push
VariableDeclaration: 
  VAR Identifier ASSIGN Type IS Expression {$$ = new AST_Node("VariableDeclaration", false, $1, $2, $3, $4, $5, $6); $$.identifier_string = $2.identifier_string; $$.return_type = $4.return_type;}
| VAR Identifier ASSIGN Type {$$ = new AST_Node("VariableDeclaration", false, $1, $2, $3, $4, null, null); $$.identifier_string = $2.identifier_string; $$.return_type = $4.return_type;}
| VAR Identifier ASSIGN Type IS RoutineCall {$$ = new AST_Node("VariableDeclaration", false, $1, $2, $3, $4, $5, $6); $$.identifier_string = $2.identifier_string; $$.return_type = $4.return_type;}
| VAR Identifier IS RoutineCall {$$ = new AST_Node("VariableDeclaration", false, $1, $2, $3, $4); $$.identifier_string = $2.identifier_string; $$.return_type = "generic";}
| VAR Identifier IS Expression {$$ = new AST_Node("VariableDeclaration", false, $1, $2, $3, $4); $$.identifier_string = $2.identifier_string; $$.return_type = "generic";}
; 

// TypeTable push
TypeDeclaration: 
  TYPE Identifier IS Type {$$ = new AST_Node("TypeDeclaration", false, $1, $2, $3, $4);}
 ;

// NEW SCOPE SymbolTAble push
RoutineDeclaration: 
  ROUTINE Identifier OPEN_PAREN RoutineParameters CLOSE_PAREN RoutineReturnType IS Body END
  {
    $$ = new AST_Node("RoutineDeclaration", $4.children);
    $$.identifier_string = "Routine_"+ $2.identifier_string;
    $$.return_type = $6.return_type;
    $$.add_child($8);
  }
;
 
RoutineParameters:
  Parameters {$$ = $1;}
| {$$ = new AST_Node("Parameters", false);}
;

// TypeTable check
RoutineReturnType: 
    ASSIGN Type {$$ = new AST_Node("RoutineReturnType", false, $1, $2); $$.return_type = $2.return_type;}
	| {$$ = new AST_Node("RoutineReturnType", false); $$.return_type = "void";}
  ;

// POSSIBLE CONFLICT
Parameters: 
  ParameterDeclaration COMMA Parameters {
    $3.add_child($1);
  }
| ParameterDeclaration {$$ = new AST_Node("Parameters", false, $1);}
;

// NEW SCOPE SymbolTAble push
ParameterDeclaration: 
  Type ASSIGN Identifier {$$ = new AST_Node("ParameterDeclaration", false, $1, $2, $3); $$.identifier_string = $1.identifier_string; $$.return_type = $3.identifier_string;}
; 
 
Type: 
  PrimitiveType {$$ = $1; $$.return_type = $1.return_type;}
| ArrayType {$$ = $1; $$.return_type = $1.return_type;}
| RecordType {$$ = $1; $$.return_type = $1.return_type;}
| Identifier {$$ = $1; $$.return_type = $1.identifier_string;}
;

PrimitiveType: 
  TYPE_INT  {$$ = $1; $$.return_type = $1.return_type;}
| TYPE_REAL {$$ = $1; $$.return_type = $1.return_type;}
| TYPE_BOOL {$$ = $1; $$.return_type = $1.return_type;}
;

RecordType: 
  RECORD RecordBody END {$$ = new AST_Node("RecordType", false, $1, $2, $3); $$.return_type = "record";}
;

RecordBody: 
  VariableDeclaration RecordBody {$$ = new AST_Node("RecordBody", false, $1, $2);}
| {$$ = null;}
;

ArrayType: 
  ARRAY Type {$$ = new AST_Node("ArrayType", false, $1, $2); $$.return_type = "[" + $2.return_type + "]";}
| ARRAY OPEN_SQUARE_BRACKET Expression CLOSE_SQUARE_BRACKET Type  {$$ = new AST_Node("ArrayType", false, $1, $2, $3, $4, $5); $$.return_type = "[" + $5.return_type + "]";}
;

Body:
  {$$ = new AST_Node("Body", false);}
| Body SimpleDeclaration  {$1.add_child($2);}
| Body Statement {$1.add_child($2);} 
;

Statement: 
  Assignment {$$ = $1;}
| RoutineCall {$$ = $1;}
| WhileLoop {$$ = $1;}
| ForLoop {$$ = $1;}
| IfStatement {$$ = $1;}
| ReturnStatement {$$ = $1;}
;

ReturnStatement:
  RETURN Return_value {$$ = new AST_Node("ReturnStatement", false, $1, $2);}
;

Assignment:
  ModifiablePrimary OP_ASSIGN Expression {$$ = new AST_Node("Assignment", false, $1, $2, $3);}
  | ModifiablePrimary OP_ASSIGN RoutineCall {$$ = new AST_Node("Assignment", false, $1, $2, $3);}
;

RoutineCall: 
  // WTF this is not call
  // Identifier {$$ = new AST_Node("RoutineCall", false, $1);}
  Identifier OPEN_PAREN Expression ArgsList CLOSE_PAREN {$$ = new AST_Node("RoutineCall", false, $1, $2, $3, $4, $5); $$.identifier_string = $1.identifier_string; $$.return_type = "-";}
;

ArgsList:
   COMMA Expression ArgsList {$$ = new AST_Node("ArgsList", false, $1, $2, $3);}
| {$$ = null;}
;

WhileLoop: 
  WHILE Expression LOOP Body END {$$ = new AST_Node("WhileLoop", false, $1, $2, $3, $4, $5); $$.return_type = "-"; $$.identifier_string = SymbolTable.RandomString();}
;

ForLoop:
  FOR Identifier Range LOOP Body END {$$ = new AST_Node("ForLoop", false, $1, $2, $3, $4, $5, $6); $$.return_type = "-"; $$.identifier_string = SymbolTable.RandomString();}
;

Return_value:
  Expression {$$ = $1;}
| {$$ = null;}
;

Range: 
   IN Reverse Expression ELLIPSIS Expression {$$ = new AST_Node("Range", false, $1, $2, $3, $4, $5);}
;

Reverse:
	REVERSE {$$ = $1;}
|	{$$ = null;}
;

IfStatement: 
  IF Expression THEN Body ElseBody END {
    $$ = new AST_Node("IfStatement", $5.children);
    $4.return_type = "-"; $4.identifier_string = "IF_STATEMENT_" + SymbolTable.RandomString();
    $$.add_child($4);
  }
; 

ElseBody:
	ELSE Body ElseBody {$3.add_child($2);}
| {$$ = new AST_Node("ElseBody", false); $$.return_type = "-"; $$.identifier_string = SymbolTable.RandomString();}
;

Expression: 
  Relation {$$ = new AST_Node("Expression", false, $1);}
| Expression logic_operation Relation {$$ = new AST_Node("Expression", false, $1, $2, $3);}
;

logic_operation:
      AND {$$ = $1;}
    | OR {$$ = $1;}
    | XOR {$$ = $1;}
    ;

Relation: 
  Simple {$$ = $1;}
| Simple compare_sign Simple {$$ = new AST_Node("Operation", false, $1, $2, $3);}
;

// NOT AN AST_Node, JUST GROUP OF SYMBOLS 
compare_sign:
      LESS {$$ = $1;}
    | LESS_OR_EQUAL {$$ = $1;}
    | GREATER {$$ = $1;}
    | GREATER_OR_EQUAL {$$ = $1;}
    | EQUAL {$$ = $1;}
    | NOT_EQUAL {$$ = $1;}
    ;


Simple: 
  Factor mult_sign Simple {$$ = new AST_Node("Operation", false, $1, $2, $3);}
| Factor {$$ = $1;}
;

mult_sign:
    MUL {$$ = $1;}
  | DIV {$$ = $1;}
  | MODULE {$$ = $1;}
;

Factor: 
  Summand sum_sign Factor {$$ = new AST_Node("Operation", false, $1, $2, $3);}
| Summand {$$ = $1;}
;

sum_sign: 
	ADD {$$ = $1;}
|	SUB {$$ = $1;}
;

Summand: 
  Primary {$$ = new AST_Node("Operation", false, $1);}
| OPEN_PAREN Expression CLOSE_PAREN {$$ = new AST_Node("Operation", false, $1, $2, $3);}
;

// Primary is just a grouping
Primary: 
  INTEGER {$$ = $1;}
| REAL {$$ = $1;}
| TRUE {$$ = $1;}
| FALSE {$$ = $1;}
| ModifiablePrimary {$$ = $1;}
;

ModifiablePrimary: 
  Identifier {$$ = new AST_Node("ModifiablePrimary", false, $1);}
| ModifiablePrimary OPEN_SQUARE_BRACKET Expression CLOSE_SQUARE_BRACKET {$$ = new AST_Node("ModifiablePrimary", false, $1, $2, $3, $4);}
| ModifiablePrimary DOT Identifier {$$ = new AST_Node("ModifiablePrimary", false, $1, $2, $3);}
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

        parser.root.print_self(0);
        Console.WriteLine("SEMANTIC ANALYZER STARTS... ");
        parser.root.BuildSymbolTable();
        Console.WriteLine("LLVM BITCODE TEST TRANSLATION");
        parser.root.print_llvm();
    }

    class Lexer: QUT.Gppg.AbstractScanner<Compiler.AST_Node, LexLocation>
    {
         private System.IO.TextReader reader;
    
         public Lexer(System.IO.TextReader reader)
         {
             this.reader = reader;
         }

         public int get_keyword(string str)
         {
          switch (str) {
            case "in": return (int) Tokens.IN;
            case "type": return (int) Tokens.TYPE;
            case "is": return (int) Tokens.IS;
            case "var": return (int) Tokens.VAR;
            case "routine": return (int) Tokens.ROUTINE;
            case "int": return (int) Tokens.TYPE_INT;
            case "real": return (int) Tokens.TYPE_REAL;
            case "boolean": return (int) Tokens.TYPE_BOOL;
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
            case "return": return (int) Tokens.RETURN; //wtf
            case "reverse": return (int) Tokens.REVERSE; //wtf
            //case "func": return (int) Tokens.FUNC
            default: return -1;
          }
         }

         public bool is_first_op_symbol(char ch) {
          switch (ch) {
            case '.': return true;
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
            case '.': return true;
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
            case "..": return (int) Tokens.ELLIPSIS;
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

              if (ch == '0' && next != '.') {
              
                string str = sb.ToString();
                // Console.WriteLine("INTEGER: {0}", str);
                yylval = new AST_Node("INTEGER", true);
                yylval.ival = 0;
                yylval.is_token = true;
                yylval.return_type = "integer";
                return (int) Tokens.INTEGER;
              }
              if (ch == '0' && next == '.') {
                
                  next = (char) reader.Read();
                  sb.Append(next); //read dot
                  next = (char) reader.Peek();
                  if (!char.IsDigit(next)) {
                    this.yyerror( "Illegal number \"{0}\" at least 1 number after \'.\' in float", next );
                  }
                  while (char.IsDigit(next)) {
                    sb.Append((char) reader.Read());
                    next = (char) reader.Peek();
                  }
                  string str = sb.ToString();
                  try {
                    yylval = new AST_Node("REAL", true);
                    yylval.dval = Convert.ToDouble(str.Replace(".", ","));
                    yylval.is_token = true;
                    yylval.return_type = "real";
                  }
                  catch (FormatException) {
                    this.yyerror("Tvoi Real Govno {0}", str);
                    return (int) Tokens.error;
                  }
                  // Console.WriteLine("FLOAT: {0}", str);
                  return (int) Tokens.REAL;
              }
              //ch 1..9
              if (ch != '0') {
                while (char.IsDigit(next)) {
                  sb.Append((char) reader.Read());
                  next = (char) reader.Peek();
                }
                if (next == '.') {
                  next = (char) reader.Read();
                  sb.Append(next);
                  next = (char) reader.Peek();
                  if (!char.IsDigit(next)) {
                    this.yyerror( "Illegal number \"{0}\" at least 1 number after \'.\' in float", next );
                  }
                  while (char.IsDigit(next)) {
                    sb.Append((char) reader.Read());
                    next = (char) reader.Peek();
                  }
                  string str = sb.ToString();
                  try {
                    yylval = new AST_Node("REAL", true);
                    yylval.dval = Convert.ToDouble(str.Replace(".", ","));
                    yylval.is_token = true;
                    yylval.return_type = "real";
                    // Console.WriteLine("FLOAT: {0}", str);
                    return (int) Tokens.REAL;
                  }
                  catch (FormatException) {
                    this.yyerror("Tvoi Float Govno {0}", str);
                    return (int) Tokens.error;
                  }
                } else {
                  // Else it is definitely integer
                  string str = sb.ToString();
                  int i = 0;
                  if (!Int32.TryParse(str, out i)) {
                    this.yyerror( "Illegal int number cant be converted to INTEGER", str );
                    return (int) Tokens.error;
                  }
                  // Console.WriteLine("INTEGER: {0}", i);
                  yylval = new AST_Node("INTEGER", true);
                  yylval.ival = i;
                  yylval.is_token = true;
                  yylval.return_type = "integer";
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
                // Console.WriteLine("KEYWORD: {0}", str);
                yylval = new AST_Node("KEYWORD", true);
                yylval.is_token = true;
                yylval.identifier_string = str;
                if (keyword_token == (int) Tokens.TYPE_INT) {
                  yylval.return_type = "int";
                }
                if (keyword_token == (int) Tokens.TYPE_REAL) {
                  yylval.return_type = "real";
                }
                if (keyword_token == (int) Tokens.TYPE_BOOL) {
                  yylval.return_type = "bool";
                }
                  
                return keyword_token;
              }
                  
              // Console.WriteLine("IDENTIFIER: {0}", str);
              yylval = new AST_Node("IDENTIFIER", true);
              yylval.is_token = true;
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
              // Console.WriteLine("OPERATION: {0}", str);
              yylval = new AST_Node("OPERATION", true);
              yylval.is_token = true;
              yylval.identifier_string = str;
              return is_operation(str);
            }

            
            // Console.WriteLine("NAN: {0}", ch);
            return (int) Tokens.error;
        }
    
        public override void yyerror(string format, params object[] args)
        {
             Console.Error.WriteLine(format, args);
        }
      }
