using System.Collections.Generic;
using System;
using System.Text;
using System.Linq;

namespace Compiler
{
    public class SymbolTable
    {
        public Dictionary<string, SymbolEntry> entries;

        public SymbolTable parent;

        public Guid id;

        public SymbolTable(SymbolTable parent)
        {
            this.entries = new Dictionary<string, SymbolEntry>();
            this.parent = parent;
            this.id = Guid.NewGuid();
        }

        // member function or method
        public void insert(SymbolEntry entry)
        {
            this.entries[entry.name] = entry;
        }

        public SymbolEntry lookup_inside(string var_name)
        {
            try
            {
                return this.entries[var_name];
            }
            catch (KeyNotFoundException)
            {
                return null;
            }
        }

        public SymbolEntry lookup_above(string var_name)
        {
            try
            {
                return this.entries[var_name];
            }
            catch (KeyNotFoundException)
            {
                if (this.parent != null)
                    return this.parent.lookup_above(var_name);
                else
                {
                    return null;
                }
            }
        }
    public static string[] NodesWhichCreateNewScope = new string[]{
        "Body",
        "ParameterDeclaration",
        "ElseBody",
        "WhileLoop",
        "ForLoop"
    };
    public static string[] NodesWhichAddToScope = new string[]{
        "VariableDeclaration",
        "RoutineDeclaration"
    };

    public static string[] NodesWhichCannotBeRedeclaredInCurrentScope = new string[]{
        "ParameterDeclaration",
        "VariableDeclaration",
        "RoutineDeclaration"
    };

        public static string[] NodesWhichMustBeDeclared = new string[]{
            "Identifier",
            "RoutineCall",
        };
        public static void handleNodeIn(AST_Node node)
        {
            if (SymbolTable.NodesWhichMustBeDeclared.Contains(node.name))
            {
                // if already declared above
                string spaces_string = string.Concat(Enumerable.Repeat(" ", AST_Node.currentDepth));
                Console.Write("{0}", spaces_string);
                Console.Write("MUST DECLARED CHECK: [{0},{1}] ", node.identifier_string, node.name);
                Console.WriteLine("<" + AST_Node.currentScope[0].id + ">  ");

                if (AST_Node.currentScope[0].lookup_above(node.identifier_string) == null) {
                    throw new InvalidProgramException("Need to declare identifier " + node.identifier_string);
                }
            }
            if (SymbolTable.NodesWhichCannotBeRedeclaredInCurrentScope.Contains(node.name)) {
                // redeclaration in one scope
                if (AST_Node.currentScope[0].lookup_inside(node.identifier_string) != null) {
                    throw new InvalidProgramException("redeclaration in one scope " + node.identifier_string + "|" + node.return_type);
                }
            }
            if (SymbolTable.NodesWhichAddToScope.Contains(node.name))
            {
                //Routine Return Type
                SymbolEntry entry = new SymbolEntry(node.identifier_string, node.name, node.return_type);
                string spaces_string = string.Concat(Enumerable.Repeat(" ", AST_Node.currentDepth));
                Console.Write("{0}", spaces_string);
                Console.Write("ADD SELF TO SCOPE   :");
                Console.Write(" <" + AST_Node.currentScope[0].id + "> ");
                entry.print();
                AST_Node.currentScope[0].insert(entry);
            }

            if (SymbolTable.NodesWhichCreateNewScope.Contains(node.name))
            {
                SymbolTable new_table = new SymbolTable(AST_Node.currentScope[0]);
                SymbolEntry entry = new SymbolEntry(node.identifier_string, node.name, node.return_type); 
                entry.pointer = new_table;
                string spaces_string = string.Concat(Enumerable.Repeat(" ", AST_Node.currentDepth));
                Console.Write("{0}", spaces_string);
                Console.Write("ADD NEW SCOPE IN    :");
                Console.Write(" <" + AST_Node.currentScope[0].id + "> ");
                entry.print();
                AST_Node.currentScope[0] = new_table;
                AST_Node.currentDepth++;
                spaces_string = string.Concat(Enumerable.Repeat(" ", AST_Node.currentDepth));
                Console.Write("{0}", spaces_string);
                Console.Write("CREATED NEW SCOPE   :");
                Console.ForegroundColor = ConsoleColor.DarkGreen;
                Console.WriteLine(" <" + AST_Node.currentScope[0].id + "> ");
                Console.ResetColor();
            }
        }
        public static void handleNodeOut(AST_Node node) {
            if (SymbolTable.NodesWhichCreateNewScope.Contains(node.name)) {
                if (AST_Node.currentScope[0].parent != null) {
                    string spaces_string = string.Concat(Enumerable.Repeat(" ", AST_Node.currentDepth));
                    Console.Write("{0}", spaces_string);
                    Console.Write("EXIT  FROM  SCOPE   :");
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine(" <" + AST_Node.currentScope[0].id + "> ");
                    Console.ResetColor();
                    AST_Node.currentScope[0] = AST_Node.currentScope[0].parent;
                    AST_Node.currentDepth--;
                }
            }
        }
        public static string RandomString()
        {
            Random random = new Random();
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, 8)
            .Select(s => s[random.Next(s.Length)]).ToArray());
        }
    }

    public class SymbolEntry
    {
        public string name;
        public string declaration_type;
        public SymbolTable pointer = null;
        public string value_type;
        public SymbolEntry(String name, string declaration_type, string value_type)
        {
            this.name = name;
            this.declaration_type = declaration_type;
            this.value_type = value_type;
        }
        public void print() {
            Console.WriteLine(" [{0},{1},{2}]", this.name, this.declaration_type, this.value_type);
        }

        public static string[] EntryTypesTransitive = new string[]{
        "ROUTINE",
        "RECORD",
        "IF",
        "ELSE",
        "WHILE_LOOP",
        "FOR_LOOP"
    };
    }
}