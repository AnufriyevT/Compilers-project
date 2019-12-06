using System.Globalization;
using System.Runtime.CompilerServices;
using System.Collections.Generic;
using System.IO;
using System;
using System.Linq;
using System.Text;

namespace Compiler
{
    public class AST_Node
    {
        public string name;
        public AST_Node[] children;
        public bool is_token;
        public string return_type = null;
        public string type = null;
        public int ival = 0;
        public double dval = 0.0;
        public string identifier_string;
        private static string filepath = "llvm_input.llvm";
        
        public static SymbolTable[] currentScope = {new SymbolTable(null)};
        public static int currentDepth = 0;
        public AST_Node(string name, bool is_token, params AST_Node[] children)
        {
            this.name = name;
            this.children = children;
            this.is_token = is_token;
            this.return_type = null;
            this.identifier_string = null;
        }
        public AST_Node(string name, AST_Node[] children)
        {
            this.name = name;
            this.children = children;
            this.is_token = false;
            this.return_type = null;
            this.identifier_string = null;
        }
        public void add_child(AST_Node node) {
            Array.Resize(ref this.children, this.children.Length + 1);
            this.children[this.children.Length - 1] = node;
        }
        public static string llvm_bitcode_string = null;
        public void to_LLVM()
        {
            try
            {
                llvm_bitcode_string = LLVM_Translator.callbacks[this.name](this);
            }
            catch (KeyNotFoundException)
            {
                foreach (AST_Node child in this.children) {
                    if (child != null) {
                        child.to_LLVM();
                        break;
                    }
                }
            }
            
            // byte[] llvm_bitcode_to_file = Encoding.UTF8.GetBytes(llvm_bitcode_string);
            Console.Write(llvm_bitcode_string);
            // FileStream llvm_input_fd = File.Create(AST_Node.filepath);
            // llvm_input_fd.Write(llvm_bitcode_to_file, 0, llvm_bitcode_to_file.Length);
            // llvm_input_fd.Close();
        }
        public void BuildSymbolTable() {
            SymbolTable.handleNodeIn(this);
            foreach (AST_Node child in this.children) {
                    if (child != null) {
                        child.BuildSymbolTable();
                    }
                }
            SymbolTable.handleNodeOut(this);
        }

        public void print_llvm() {
            if (this.name.Equals("Operation")) {
                        Console.WriteLine(LLVM_Translator.translate_operation(this));
            } else {
                foreach (AST_Node child in this.children) {
                if (child != null) {
                    child.print_llvm();
                }        
            }
            }
            
        }

        public string translate_tree() {
            if (this.name.Equals("Operation")) {
                return LLVM_Translator.translate_operation(this);  
            } else {
                Console.WriteLine("--- [{0}]", this.name);
                foreach (AST_Node child in this.children) {
                    if (child != null) {
                        Console.WriteLine(child.name);
                        return child.translate_tree();
                    }
                }
                return "";
            }
        }
        public void print_self(int spaces)
        {
            string spaces_string = string.Concat(Enumerable.Repeat(" ", spaces));
            Console.Write("{0}", spaces_string);
            if (this.is_token) {

                Console.ForegroundColor = ConsoleColor.DarkGreen;
                if (this.name == "INTEGER") {
                    Console.Write("<{0}:{1}> ", this.return_type, this.ival);
                }
                if (this.name == "REAL") {
                    Console.Write("<{0}:{1}> ", this.return_type, this.dval);
                }
                if (this.name == "KEYWORD") {
                    Console.Write("{0}", this.identifier_string);
                }
                if (this.name == "IDENTIFIER") {
                    Console.Write("{0}", this.identifier_string);
                }
                if (this.name == "OPERATION") {
                    Console.Write("{0}", this.identifier_string);
                }
                Console.ResetColor();
                Console.WriteLine(" [{0}] ", this.name);
            }
            else {
                Console.WriteLine("NODE: [{0}]", this.name);
                // Console.WriteLine("|");
                foreach (AST_Node child in this.children)
                {
                    if (child != null) {
                        child.print_self(spaces + 1);
                    }
                }
            }
        }
    }

    public static class LLVM_Translator
    {
        public static int counter = 0;
        public static readonly Dictionary<string, Func<AST_Node, string>> callbacks = new Dictionary<string, Func<AST_Node, string>>
    {
        // { "KEYWORD", translate_expression }, // +TRUE, FALSE
        // { "INTEGER", translate_integer }, //100, 120
        // { "REAL", translate_real }, //110.01023
        // { "OPERATION", translate_operation }, // all op + brackets
        { "Operation", translate_operation},
    };
        public static string translate_operation(AST_Node node) {
            if (node.children.Length == 3) {
                string operstring = node.children[1].identifier_string;
                
                string r_type = "";
                if (node.children[0].return_type != node.children[2].return_type) {
                    throw new InvalidProgramException("Types mismatch");
                }
                if (node.children[0].return_type == "integer") {
                    r_type = "int32";
                }
                if (node.children[0].return_type == "real") {
                    r_type = "double";
                }
                if (node.children[0].return_type == "bool") {
                    r_type = "i1";
                }
                
                string r1 = null;
                string v1 = null;
                string r2 = null;
                string v2 = null;
                Console.WriteLine(node.name);
                if (!node.children[0].is_token && !node.children[2].is_token) {
                    r1 = "%" + counter.ToString();
                    v1 = "%" + counter.ToString()  + " = " + LLVM_Translator.translate_operation(node.children[0]);
                    counter++;
                    r2 = "%" + counter.ToString();
                    v2 = "%" + counter.ToString()  + " = " + LLVM_Translator.translate_operation(node.children[2]);
                    counter++;
                }
                if (node.children[0].is_token && !node.children[2].is_token) {
                    r1 = "%" + counter.ToString();
                    v1 = null;
                    if (node.children[0].return_type.Equals("integer")) v1 = "%" + counter.ToString() + " = add int32 " + node.children[0].ival + " 0\n";
                    if (node.children[0].return_type.Equals("integer")) v1 = "%" + counter.ToString() + " = add double " + node.children[0].dval + " 0\n";
                    if (node.children[0].identifier_string == "true") v1 = "%" + counter.ToString() + " = i1 true\n";
                    if (node.children[0].identifier_string == "false") v1 = "%" + counter.ToString() + " = i1 false\n";

                    counter++;
                    r2 = "%" + counter.ToString();
                    v2 = "%" + counter.ToString() + LLVM_Translator.translate_operation(node.children[2]);
                    counter++;
                }
            
                if (node.children[0].is_token && !node.children[2].is_token) {
                    r1 = "%" + counter.ToString();
                    v1 = "%" + counter.ToString() + LLVM_Translator.translate_operation(node.children[0]);
                    counter++;

                    r2 = "%" + counter.ToString();
                    v2 = null;
                    if (node.children[2].return_type == "integer") v2 = "%" + counter.ToString() + " = add int32 " + node.children[2].ival + " 0\n";
                    if (node.children[2].return_type == "real") v2 = "%" + counter.ToString() + " = add double " + node.children[2].dval + " 0\n";
                    if (node.children[2].identifier_string == "true") v2 = "%" + counter.ToString() + " = i1 true\n";
                    if (node.children[2].identifier_string == "false") v2 = "%" + counter.ToString() + " = i1 false\n";
                }
                if (node.children[0].is_token && !node.children[2].is_token) {
                    r1 = "%" + counter.ToString();
                    v1 = null;
                    if (node.children[0].return_type == "integer") v1 = "%" + counter.ToString() + " = add int32 " + node.children[0].ival + " 0\n";
                    if (node.children[0].return_type == "real") v1 = "%" + counter.ToString() + " = add double " + node.children[0].dval + " 0\n";
                    if (node.children[0].identifier_string == "true") v1 = "%" + counter.ToString() + " = i1 true\n";
                    if (node.children[0].identifier_string == "false") v1 = "%" + counter.ToString() + " = i1 false\n";

                    r2 = "%" + counter.ToString();
                    v2 = null;
                    if (node.children[2].return_type == "integer") v2 = "%" + counter.ToString() + " = add int32 " + node.children[2].ival + " 0\n";
                    if (node.children[2].return_type == "real") v2 = "%" + counter.ToString() + " = add double " + node.children[2].dval + " 0\n";
                    if (node.children[2].identifier_string == "true") v2 = "%" + counter.ToString() + " = i1 true\n";
                    if (node.children[2].identifier_string == "false") v2 = "%" + counter.ToString() + " = i1 false\n";
                }
                
                switch (operstring) {
                    case "+": {
                        operstring = "add";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = add "+r_type+" " + r1 + ", " + r2 + "\n";
                    }
                    case "-": {
                        operstring = "sub";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = add "+r_type+" " + r1 + ", " + r2 + "\n";
                    }
                    case "*": {
                        operstring = "mult";
                        r_type = "i1"; 
                        return v1 + v2 + "%" + counter.ToString() + " = add "+r_type+" " + r1 + ", " + r2 + "\n";
                    }
                    case "%": {
                        operstring = "mod";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = add "+r_type+" " + r1 + ", " + r2 + "\n";               
                    };
                    case "=": {
                        operstring = "eq";
                        r_type = "i1";
                        return v1 + v2 + "\n%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                    case ">": {
                        operstring = "ugt";
                        r_type = "i1";
                        return v1 + v2 + "\n%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                    case "<":
                    {
                        operstring = "ult";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                    case ">=": {
                        operstring = "ule";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                    case "<=": {
                        operstring = "uge";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                    case "/=": {
                        operstring = "ne";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                    default: {
                        operstring = "ERROR";
                        r_type = "i1";
                        return v1 + v2 + "%" + counter.ToString() + " = icmp " + operstring +" "+r_type+" "+ r1 +"," + r2 + "\n";
                    }
                }
                
            } else {
                return "";
            }
        }
    }
}
