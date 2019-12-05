using System.Collections.Generic;
using System;
using System.Text;

namespace Compiler
{
    public class TypeTable
    {
        public Dictionary<string, TypeTableEntry> entries;

        // member function or method
        public void display()
        {
            Console.WriteLine("Class & Objects in C#");
        }
    }

    public class TypeTableEntry
    {
        public string name;
        public string declaration_type;
        public string value_type;
        public TypeTable pointer;
        public TypeTableEntry(String name, String declaration_type, string value_type)
        {
            this.name = name;
            this.declaration_type = declaration_type;
            this.value_type = value_type;
            this.pointer = null;
        }
    }
}