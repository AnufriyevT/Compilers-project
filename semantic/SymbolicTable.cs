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
        "RoutineDeclaration",
        "IfStatement",
        "ElseBody",
        "WhileLoop",
        "ForLoop"
    };
    public static string[] NodesWhichAddToScope = new string[]{
        "RoutineDeclaration",
        "ParameterDeclaration",
        "VariableDeclaration"
    };

    public static string[] NodesWhichCannotBeRedeclaredInCurrentScope = new string[]{
        "RoutineDeclaration",
        "ParameterDeclaration",
        "VariableDeclaration"
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
                if (AST_Node.currentScope.lookup_above(node.identifier_string) == null) {
                    throw new InvalidProgramException("Need to declare identifier " + node.identifier_string);
                }
            }
            if (SymbolTable.NodesWhichCannotBeRedeclaredInCurrentScope.Contains(node.name)) {
                // redeclaration in one scope
                if (AST_Node.currentScope.lookup_inside(node.identifier_string) != null) {
                    throw new InvalidProgramException("redeclaration in one scope " + node.identifier_string);
                }
            }
            if (SymbolTable.NodesWhichAddToScope.Contains(node.name))
            {
                //Routine Return Type
                SymbolEntry entry = new SymbolEntry(node.identifier_string, node.name, node.return_type); 
                Console.Write("<" + AST_Node.currentScope.id + ">  ");
                entry.print("ADD SELF TO SCOPE: ");
                AST_Node.currentScope.insert(entry);
            }

            if (SymbolTable.NodesWhichCreateNewScope.Contains(node.name))
            {
                SymbolTable new_table = new SymbolTable(AST_Node.currentScope);
                SymbolEntry entry = new SymbolEntry(node.identifier_string, node.name, node.return_type); 
                entry.pointer = new_table;
                Console.Write("<" + AST_Node.currentScope.id + ">  ");
                entry.print("ADD NEW SCOPE:     ");
                AST_Node.currentScope = new_table;
            }
        }
        public static void handleNodeOut(AST_Node node) {
            if (AST_Node.currentScope.parent != null) {
                AST_Node.currentScope = AST_Node.currentScope.parent;
            }
        }
        public static string RandomString()
        {
            Random random = new Random();
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, 16)
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
        public void print(string kek) {
            Console.Write(kek);
            Console.WriteLine("  [{0},{1},{2}]", this.name, this.declaration_type, this.value_type);
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