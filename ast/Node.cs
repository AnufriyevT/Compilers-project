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
        public int ival = 0;
        public double dval = 0.0;
        public string identifier_string;

        private static string filepath = "llvm_input.llvm";

        public AST_Node(string name, bool is_token, params AST_Node[] children)
        {
            this.name = name;
            this.children = children;
            this.is_token = is_token;
            this.return_type = null;
            this.identifier_string = null;
        }
        public void to_LLVM()
        {
            string llvm_bitcode_string = LLVM_Translator.callbacks[this.name](this);
            byte[] llvm_bitcode_to_file = Encoding.UTF8.GetBytes(llvm_bitcode_string);
            FileStream llvm_input_fd = File.Create(AST_Node.filepath);
            llvm_input_fd.Write(llvm_bitcode_to_file, 0, llvm_bitcode_to_file.Length);
            llvm_input_fd.Close();
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
        public static readonly Dictionary<string, Func<AST_Node, string>> callbacks = new Dictionary<string, Func<AST_Node, string>>
    {
        { "KEYWORD", translate_expression }, // +TRUE, FALSE
        { "INTEGER", translate_integer }, //100, 120
        { "REAL", translate_real }, //110.01023
        { "OPERATION", translate_operation }, // all op + brackets
    };

        private static string translate_expression(AST_Node node)
        {
            if (node.is_token) {
                return "kek";
            } else {
                AST_Node node_child_1 = node.children[0];
                return "kek-before" + translate_expression(node_child_1) + "kek-after";
            }
        }

        private static string translate_integer(AST_Node node)
        {
            if (node.is_token) {
                return "kek";
            } else {
                AST_Node node_child_1 = node.children[0];
                return "kek-before" + translate_expression(node_child_1) + "kek-after";
            }
        }

        private static string translate_real(AST_Node node)
        {
            if (node.is_token) {
                return "kek";
            } else {
                AST_Node node_child_1 = node.children[0];
                return "kek-before" + translate_expression(node_child_1) + "kek-after";
            }
        }

        private static string translate_operation(AST_Node node)
        {
            if (node.is_token) {
                return "kek";
            } else {
                AST_Node node_child_1 = node.children[0];
                return "kek-before" + translate_expression(node_child_1) + "kek-after";
            }
        }
    }
}
