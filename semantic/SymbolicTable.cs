public class SymbolTable
{
    public Dictionary<string, SymbolEntry> entries;

      // member function or method
      public void display()
      {
          Console.WriteLine("Class & Objects in C#");
      }
}

public class SymbolEntry
{
    public string name;
    public string declaration_type;
    public string value_type;
    public SymbolTable pointer;
    public SymbolEntry(String name, String declaration_type, 
                  int age, String color) 
    { 
        this.name = name; 
        this.declaration_type = declaration_type; 
        this.value_type = value_type; 
        this.pointer = null; 
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