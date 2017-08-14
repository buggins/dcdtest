import std.stdio;

import server.autocomplete;
import common.messages;
import dsymbol.modulecache;


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

void createThread() {
    import core.thread;
    auto thread = new Thread(delegate() {
        // do nothing
    });
    thread.start();
    thread.join();
    writeln("New thread created");
}

int main(string[] args) {
    import std.path;
    import std.file;
    import std.string;
    ModuleCache moduleCache = ModuleCache(new ASTAllocator);
    string testDir = absolutePath("test");
    string sourceFile = buildPath(testDir, "main.d");
    string source = readText(sourceFile);
    auto position = source.indexOf(".run") + 2;
    writeln("test dir: ", testDir);
    writeln("source file: ", sourceFile);
    writeln("source: ", source);
    writeln("position: ", position);

    moduleCache.addImportPaths([testDir]);

    // this one works ok
    testFindDeclaration(sourceFile, source, position, [testDir], moduleCache);

    createThread();

    // this one fails ok
    testFindDeclaration(sourceFile, source, position, [testDir], moduleCache);

    return 0;
}
