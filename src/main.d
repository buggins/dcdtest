import std.stdio;

import server.autocomplete;
import common.messages;
import dsymbol.modulecache;
import dsymbol.string_interning : internString;
import dsymbol.symbol;
import containers.ttree;
import core.thread;

void testFindDeclaration(string sourceFile, string source, size_t position, string[] importPaths, ref ModuleCache moduleCache) {
    writeln("Calling findDeclaration()");
    AutocompleteRequest request;
    request.sourceCode = cast(ubyte[])source;
    request.fileName = sourceFile;
    request.cursorPosition = position;
    request.importPaths = importPaths;
    AutocompleteResponse response = findDeclaration(request, moduleCache);
    string resultFile = response.symbolFilePath.dup;
    auto resultOffset = response.symbolLocation;
    writeln("    result file: ", response.symbolFilePath, " location: ", response.symbolLocation);
}

void dumpInternStrings() {
    import std.string;
    import dsymbol.builtin.names;
    writeln("Interned strings ptr=", builtinTypeNames.ptr);
    
    foreach(name; builtinTypeNames[0..5]) {
        writeln("name=", name, " ptr=", name.ptr, " interned.ptr=", internString(name).data.ptr);
    }
}

void createThread() {
    import core.thread;
    auto thread = new Thread(delegate() {
        // do nothing
        writeln("inside thread");
        dumpInternStrings();
        writeln("exiting thread");
    });
    thread.start();
    thread.join();
    writeln("New thread created");
}

int main(string[] args) {
    import std.path;
    import std.file;
    import std.string;
    //ModuleCache moduleCache = ModuleCache(new ASTAllocator);
    //string testDir = absolutePath("test");
    //string sourceFile = buildPath(testDir, "main.d");
    //string source = readText(sourceFile);
    //auto position = source.indexOf(".run") + 2;
    //writeln("test dir: ", testDir);
    //writeln("source file: ", sourceFile);
    //writeln("source: ", source);
    //writeln("position: ", position);

    writeln("Dumping interned strings before thread start");
    dumpInternStrings();

    //moduleCache.addImportPaths([testDir]);


    // this one works ok
    //testFindDeclaration(sourceFile, source, position, [testDir], moduleCache);

    //writeln("Dumping interned strings before thread start - second time");
    //dumpInternStrings(["long", "string", "main", "testField", "int", "void", "X", "Test", "run"]);

    createThread();

    writeln("Dumping interned strings after thread exit");
    dumpInternStrings();

    // this one fails
    //testFindDeclaration(sourceFile, source, position, [testDir], moduleCache);


    //writeln("symbol1.opCmp(symbol1)=", symbol1.opCmp(symbol1));
    //writeln("s1.ptr=", s1.ptr, " s2.ptr=", s2.ptr, " symbol1.opCmp(symbol2)=", symbol1.opCmp(symbol2));
    //writeln("own1.opCmp(own2)=", own1.opCmp(own2));

    //writeln("Dumping interned strings after thread start - second time");
    //dumpInternStrings(["long", "string", "main", "testField", "int", "void", "X", "Test", "run"]);

    return 0;
}
