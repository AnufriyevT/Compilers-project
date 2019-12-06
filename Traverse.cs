using System.Collections.Generic;
using System.IO;
using System;
using System.Linq;
using System.Text;

using Compiler.AST_Node;

public class Traverse
    {
        AST_Node myRoot = root;
        public void prt(){
            Console.Write(" ",myRoot);
        }
        
        public static void Main(){
            prt();
            return 0;
        }
        
    }
    