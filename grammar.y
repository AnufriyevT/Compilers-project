%{
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
int yyerror(char *msg);
int yylineno;
char *yytext;
FILE *yyin;
int yylex();

typedef struct nodeType {
    int value;
    char* oper_type;
    int nops;
    struct nodeType** children;
} nodeType;

nodeType *add_node(char* oper_type, int nops, ...);
void print_tree(nodeType* root);
void print_node(nodeType* node);
%}

%token NUM

%%
input:
  %empty
| input line
;

line:
  '\n'
| exp '\n'      { printf ("%d\n", $1); }
;

exp:
  NUM
| exp exp '+'   { $$ = $1 + $2;      }
| exp exp '-'   { $$ = $1 - $2;      }
| exp exp '*'   { $$ = $1 * $2;      }
| exp exp '/'   { $$ = $1 / $2;      }
| exp 'n'       { $$ = -$1;          }  /* Unary minus   */
;

%%

int yylex (void)
{
  int c = getchar ();
  /* Skip white space. */
  while (c == ' ' || c == '\t')
    c = getchar ();

  /* Process numbers. */
  if (c == '.' || isdigit (c))
    {
      ungetc (c, stdin);
      scanf ("%d", &yylval);
      return NUM;
    }

  /* Return end-of-input. */
  else if (c == EOF)
    return 0;
  /* Return a single char. */
  else
    return c;
}
int yyerror(char *msg)
{
	printf("\n%s at line %d with [%s]\n",msg, yylineno, yytext);
}

int main(int argc, char *argv[])
{   
	if (argc == 2) 
    {
        printf("Parsed external file: \'%s\'\n", argv[1]);
        stdin = fopen(argv[1], "r");
    }
	int res = yyparse();
	if (res == 0)
	  	printf("Successful parse\n");
	else
	  	printf("Encountered errors\n");	
	exit(res);
}