#include "../info/type_info.h"
#include "../info/bsqon.h"
#include "bsqon_parse.h"

#include <iostream>
#include <fstream>

bool processArgs(int argc, char** argv, std::string& metadata, std::string& type, std::string& data, bool& loadenv)
{
    if(argc < 2) {
        printf("usage: bsqon [metadata.json] [type] data.bsqon\n");
        return false;
    }

    loadenv = false;
    std::vector<std::string> args;
    for(int i = 1; i < argc; ++i) {
        if(strcmp(argv[i], "--loadenv") == 0) {
            loadenv = true;
        }
        else {
            args.push_back(argv[i]);
        }
    }

    size_t apos = 1;
    if(apos < args.size() && args[apos].ends_with(".json")) {
        metadata = args[apos];
        apos++;
    }
    else {
        metadata = "<implicit>";
    }

    if(apos < args.size() && !args[apos].ends_with(".bsqon")) {
        type = args[apos];
        apos++;
    }
    else {
        type = "<implicit>";
    }

    data = "<unset>";
    if(apos < args.size() && args[apos].ends_with(".bsqon")) {
        data = args[apos];
        apos++;
    }
    else {
        printf("usage: bsqon [metadata.json] [type] data.bsqon\n");
        printf("missing bsqon file\n");
        return false;
    }

    if(apos < args.size()) {
        printf("usage: bsqon [metadata.json] [type] data.bsqon\n");
        printf("too many arguments\n");
        return false;
    }

    return true;
}

std::map<std::string, std::string>* loadEnvironment(char** envp)
{
    std::map<std::string, std::string>* envmap = new std::map<std::string, std::string>();
    for (char** env = envp; *env != 0; env++)
    {
        std::string ename(*env);
        std::string evalue(getenv(*env));
        
        envmap->insert(std::make_pair(ename, evalue));
    }

    return envmap;
}

int main(int argc, char** argv, char **envp)
{
    std::string metadata, type, data;
    bool loadenv = false;
    if(!processArgs(argc, argv, metadata, type, data, loadenv)) {
        return 1;
    }

    std::map<std::string, std::string>* env = nullptr;
    if(loadenv) {
        env = loadEnvironment(envp);
    }

    //parse the JSON 
    json jv = nullptr;
    try
    {
        std::ifstream infile(argv[1]);
        infile >> jv;
    }
    catch(const std::exception& e)
    {
        printf("Error parsing JSON: %s\n", e.what());
        exit(1);
    }
    
    //the property assembly is the code so load it
    BSQON::AssemblyInfo assembly;
    BSQON::AssemblyInfo::parse(jv, assembly);

    //the property loadtype is the type so look it up
    const BSQON::Type* loadtype = nullptr;
    loadtype = assembly.resolveType(argv[2]);
    if(loadtype->isUnresolved()) {
        printf("Invalid 'loadtype'\n");
        exit(1);
    }

    //the property value is the BSQON value (as a JSON string) so parse it
    BSQON_AST_Node* node = argc == 3 ? parse_from_stdin() : parse_from_file(argv[3]);
    char** errorInfo = (char**)malloc(sizeof(char*) * 128);
    size_t errorInfoCount = BSQON_AST_getErrorInfo(errorInfo);

    if(node == nullptr) {
        for(size_t i = 0; i < errorInfoCount; ++i) {
            printf("++ %s\n", errorInfo[i]);
        }

        fflush(stdout);
        exit(1);
    }
    else {
        BSQON::Parser parser(&assembly);
        BSQON::Value* res = parser.parseValue(loadtype, node);

        if(parser.errors.empty() && errorInfoCount == 0) {
            std::string rstr = res->toString();
            printf("%s\n", rstr.c_str());

            fflush(stdout);
            exit(0);
        }
        else {
            for(size_t i = 0; i < errorInfoCount; ++i) {
                std::string sstr(errorInfo[i]);
                if(!sstr.starts_with("syntax error")) {
                    printf("%s\n", sstr.c_str());
                }
            }

            for(size_t i = 0; i < parser.errors.size(); ++i) {
                const BSQON::ParseError& pe = parser.errors.at(i);
                printf("%s -- line %u\n", pe.message.c_str(), pe.loc.first_line);
            }

            fflush(stdout);
            exit(1);
        }
    }
}
