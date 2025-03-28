%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

int yylex(void);
void yyerror(const char* s, ...);

#define MK_SPOS_S(T) (createSourcePos((T).first_line, (T).first_column, (T).last_line, (T).last_column))
#define MK_SPOS_R(S, E) (createSourcePos((S).first_line, (S).first_column, (E).last_line, (E).last_column))

struct BSQON_TYPE_AST_Node* yybsqonval_type;
struct BSQON_AST_Node* yybsqonval;
char* filename = "<stdin>";

#define MAX_PARSER_ERRORS 128
#define MAX_ERROR_LENGTH 1024

char errorbuf[MAX_ERROR_LENGTH];
char* errors[MAX_PARSER_ERRORS];
int errorcount = 0;

#define YYDEBUG 1
%}

%code requires {
#include "../../../src/fbparser/bsqon_ast.h"
}

%union {
   char* str;
   struct ByteString* bstr;

   struct BSQON_AST_Node* bsqon_type_node;
   struct BSQON_AST_Node* bsqon_value_node;

   struct BSQON_AST_Node* bsqon_decl;

   struct BSQON_AST_LIST_OF_TYPES* bsqon_type_list;

   struct BSQON_AST_NLIST_OF_TYPES_ENTRY bsqon_named_type_list_entry;
   struct BSQON_AST_NLIST_OF_TYPES* bsqon_named_type_list;

   struct BSQON_AST_LIST_OF_VALUES* bsqon_value_list;

   struct BSQON_AST_NLIST_OF_VALUES_ENTRY bsqon_named_value_list_entry;
   struct BSQON_AST_NLIST_OF_VALUES* bsqon_named_value_list;
}

%define parse.error verbose
%locations

/* declare tokens */

%token KW_TRUE "true"
%token KW_FALSE "false"

%token KW_NONE "none"
%token KW_SOME "some"
%token KW_OK "ok"
%token KW_ERR "err"

%token KW_NPOS "$npos"
%token KW_INDEX "$i"
%token KW_KEY "$key"
%token KW_SRC "$src"

%token KW_LET "let"
%token KW_IN "in"
%token KW_ENV "env"

%token SYM_DOUBLE_COLON "::"
%token SYM_HASH "#"
%token SYM_ENTRY "=>"
%token SYM_COLON ":"
%token SYM_COMMA ","
%token SYM_EQUALS "="
%token SYM_DOT "."

%token SYM_ELIST_LEFT "(|"
%token SYM_ELIST_RIGHT "|)"
%token SYM_LBRACK_BAR "[|"
%token SYM_RBRACK_BAR "|]"

%token <str> TOKEN_NAT "nat literal"
%token <str> TOKEN_INT "int literal"
%token <str> TOKEN_BIG_NAT "big nat literal" 
%token <str> TOKEN_BIG_INT "big int literal"

%token <str> TOKEN_RATIONAL "rational literal"
%token <str> TOKEN_FLOAT "float literal"
%token <str> TOKEN_DECIMAL "decimal literal"
%token <str> TOKEN_DECIMAL_DEGREE "decimal degree literal"
%token <str> TOKEN_COMPLEX "complex literal"
%token <str> TOKEN_LAT_LONG "geo coordinate literal"

%token <str> TOKEN_NUMBERINO "numberino"

%token <str> TOKEN_BYTE_BUFFER "byte buffer"
%token <str> TOKEN_UUID_V4 "uuid (v4)"
%token <str> TOKEN_UUID_V7 "uuid (v7)"
%token <str> TOKEN_SHA_HASH "sha3 hashcode (512 bits)"

%token <bstr> TOKEN_STRING "string"
%token <bstr> TOKEN_CSTRING "cstring"
%token <bstr> TOKEN_REGEX "regular expression"
%token <bstr> TOKEN_PATH_ITEM "path item"

%token <str> TOKEN_TZ_DATE_TIME "date & time with timezone"
%token <str> TOKEN_TIA_TIME "date & time in TIA"
%token <str> TOKEN_PLAIN_DATE "plain date"
%token <str> TOKEN_PLAIN_TIME "plain time"
%token <str> TOKEN_LOGICAL_TIME "logical time"
%token <str> TOKEN_TIMESTAMP "ISO timestamp"

%token <str> TOKEN_DELTA_DATE_TIME "date & time delta"
%token <str> TOKEN_DELTA_SECONDS "delta in seconds"
%token <str> TOKEN_DELTA_LOGICAL "logical time delta"
%token <str> TOKEN_DELTA_ISOTIMESTAMP "timestamp delta"

%token <str> TOKEN_IDENTIFIER "identifier"
%token <str> TOKEN_TYPE_COMPONENT "type name"
%token <str> TOKEN_UNSPEC_IDENTIFIER "unspec identifier"

%token <str> TOKEN_SHEBANG_LINE "shebang line"
 
%type <bsqon_type_node> bsqontypel_entry bsqonnominaltype bsqonelisttype bsqontype
%type <bsqon_type_list> bsqontypel bsqontermslist

%type <bsqon_named_type_list_entry> bsqonnametypel_entry
%type <bsqon_named_type_list> bsqonnametypel bsqonenvlist

%type <bsqon_value_node> bsqonl_entry bsqon_braceval bsqonliteral bsqonunspecvar bsqonidentifier bsqonscopedidentifier bsqonref bsqontypeliteral bsqonterminal bsqonenvaccess bsqon_mapentry
%type <bsqon_value_node> bsqonbracketvalue bsqonbracevalue bsqonbracketbracevalue bsqontypedvalue bsqonstructvalue bsqonspecialcons bsqonletexp bsqonaccess bsqonval
%type <bsqon_value_list> bsqonvall

%type <bsqon_decl> bsqoncomponent bsqonroot

%type <bsqon_named_value_list_entry> bsqonnameval_entry
%type <bsqon_named_value_list> bsqonnamevall

%start bsqonroot

%%

bsqontypel:
   bsqontypel bsqontypel_entry { $$ = BSQON_AST_LIST_OF_TYPES_Push($2, $1); }
   | bsqontypel_entry { $$ = BSQON_AST_LIST_OF_TYPES_Singleton($1); }
;

bsqontypel_entry:
   bsqontype SYM_COMMA { $$ = $1; }
   | error SYM_COMMA { $$ = BSQON_AST_ERROR(MK_SPOS_S(@1)); yyerrok; }
;

bsqonnametypel:
   bsqonnametypel bsqonnametypel_entry { $$ = BSQON_AST_NLIST_OF_TYPES_Push($2, $1); }
   | bsqonnametypel_entry { $$ = BSQON_AST_NLIST_OF_TYPES_Singleton($1); }
;

bsqonnametypel_entry:
   TOKEN_IDENTIFIER SYM_COLON bsqontype SYM_COMMA { $$ = BSQON_AST_NLIST_OF_TYPES_ENTRY_Create($1, $3); }
   | TOKEN_IDENTIFIER SYM_COLON error SYM_COMMA { $$ = BSQON_AST_NLIST_OF_TYPES_ENTRY_Create($1, BSQON_AST_ERROR(MK_SPOS_S(@3))); yyerrok; }
;

bsqonnominaltype:
   TOKEN_TYPE_COMPONENT { $$ = BSQON_AST_NODE_CONS(NominalType, BSQON_AST_TAG_NominalType, MK_SPOS_S(@1), $1, NULL); }
   | TOKEN_TYPE_COMPONENT bsqontermslist { $$ = BSQON_AST_NODE_CONS(NominalType, BSQON_AST_TAG_NominalType, MK_SPOS_S(@1), $1, $2); }
   | bsqonnominaltype SYM_DOUBLE_COLON TOKEN_TYPE_COMPONENT { $$ = BSQON_AST_NODE_CONS(NominalScopedType, BSQON_AST_TAG_NominalScopedType, MK_SPOS_R(@1, @3), $1, $3); }
;

bsqontermslist:
   '<' bsqontype '>' { $$ = BSQON_AST_LIST_OF_TYPES_Singleton($2); }
   | '<' bsqontypel bsqontype '>' { $$ = BSQON_AST_LIST_OF_TYPES_Reverse(BSQON_AST_LIST_OF_TYPES_Push($3, $2)); }
   | '<' error '>' { $$ = BSQON_AST_LIST_OF_TYPES_Singleton(BSQON_AST_ERROR(MK_SPOS_S(@2))); yyerrok; }
   | '<' bsqontypel error '>' { $$ = BSQON_AST_LIST_OF_TYPES_Reverse(BSQON_AST_LIST_OF_TYPES_Push(BSQON_AST_ERROR(MK_SPOS_S(@3)), $2)); yyerrok; }
;

bsqonelisttype:
   SYM_ELIST_LEFT SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(EListType, BSQON_AST_TAG_EListType, MK_SPOS_R(@1, @2), NULL); }
   | SYM_ELIST_LEFT bsqontype SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(EListType, BSQON_AST_TAG_EListType, MK_SPOS_R(@1, @3), BSQON_AST_LIST_OF_TYPES_Singleton($2)); }
   | SYM_ELIST_LEFT bsqontypel bsqontype SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(EListType, BSQON_AST_TAG_EListType, MK_SPOS_R(@1, @4), BSQON_AST_LIST_OF_TYPES_Reverse(BSQON_AST_LIST_OF_TYPES_Push($3, $2))); }
   | SYM_ELIST_LEFT error SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(EListType, BSQON_AST_TAG_EListType, MK_SPOS_R(@1, @3), BSQON_AST_LIST_OF_TYPES_Singleton(BSQON_AST_ERROR(MK_SPOS_S(@1)))); yyerrok; }
   | SYM_ELIST_LEFT bsqontypel error SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(EListType, BSQON_AST_TAG_EListType, MK_SPOS_R(@1, @4), BSQON_AST_LIST_OF_TYPES_Reverse(BSQON_AST_LIST_OF_TYPES_Push(BSQON_AST_ERROR(MK_SPOS_S(@3)), $2))); yyerrok; }
;

bsqontype:
   bsqonnominaltype { $$ = $1; }
   | bsqonelisttype { $$ = $1; }
   | '(' bsqontype ')' { $$ = $2; }
   | '(' error ')' { $$ = BSQON_AST_ERROR(MK_SPOS_S(@2)); yyerrok; }
;

bsqonliteral: 
   KW_NONE                    { $$ = BSQON_AST_NODE_CONS(SingletonValue, BSQON_AST_TAG_NoneValue, MK_SPOS_S(@1)); }
   | KW_TRUE                  { $$ = BSQON_AST_NODE_CONS(SingletonValue, BSQON_AST_TAG_TrueValue, MK_SPOS_S(@1)); }
   | KW_FALSE                 { $$ = BSQON_AST_NODE_CONS(SingletonValue, BSQON_AST_TAG_FalseValue, MK_SPOS_S(@1)); }
   | TOKEN_NAT                { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_NatValue, MK_SPOS_S(@1), $1); }
   | TOKEN_INT                { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_IntValue, MK_SPOS_S(@1), $1); }
   | TOKEN_BIG_NAT            { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_BigNatValue, MK_SPOS_S(@1), $1); }
   | TOKEN_BIG_INT            { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_BigIntValue, MK_SPOS_S(@1), $1); }
   | TOKEN_RATIONAL           { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_RationalValue, MK_SPOS_S(@1), $1); }
   | TOKEN_FLOAT              { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_FloatValue, MK_SPOS_S(@1), $1); }
   | TOKEN_DECIMAL            { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_DecimalValue, MK_SPOS_S(@1), $1); }
   | TOKEN_DECIMAL_DEGREE     { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_DecimalDegreeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_COMPLEX            { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_ComplexValue, MK_SPOS_S(@1), $1); }
   | TOKEN_LAT_LONG           { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_LatLongValue, MK_SPOS_S(@1), $1); }
   | TOKEN_BYTE_BUFFER        { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_ByteBufferValue, MK_SPOS_S(@1), $1); }
   | TOKEN_UUID_V4            { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_UUIDv4Value, MK_SPOS_S(@1), $1); }
   | TOKEN_UUID_V7            { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_UUIDv7Value, MK_SPOS_S(@1), $1); }
   | TOKEN_SHA_HASH           { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_SHAHashcodeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_STRING             { $$ = BSQON_AST_NODE_CONS(LiteralStringValue, BSQON_AST_TAG_StringValue, MK_SPOS_S(@1), $1); }
   | TOKEN_CSTRING            { $$ = BSQON_AST_NODE_CONS(LiteralStringValue, BSQON_AST_TAG_CStringValue, MK_SPOS_S(@1), $1); }
   | TOKEN_REGEX              { $$ = BSQON_AST_NODE_CONS(LiteralStringValue, BSQON_AST_TAG_RegexValue, MK_SPOS_S(@1), $1); }
   | TOKEN_PATH_ITEM          { $$ = BSQON_AST_NODE_CONS(LiteralPathValue, BSQON_AST_TAG_PathValue, MK_SPOS_S(@1), $1); }
   | TOKEN_TZ_DATE_TIME       { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_TZDateTimeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_TIA_TIME           { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_TIATimeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_PLAIN_DATE         { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_PlainDateValue, MK_SPOS_S(@1), $1); }
   | TOKEN_PLAIN_TIME         { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_PlainTimeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_LOGICAL_TIME       { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_LogicalTimeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_TIMESTAMP          { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_TimestampValue, MK_SPOS_S(@1), $1); }
   | TOKEN_DELTA_DATE_TIME    { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_DeltaDateTimeValue, MK_SPOS_S(@1), $1); }
   | TOKEN_DELTA_SECONDS      { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_DeltaSecondsValue, MK_SPOS_S(@1), $1); }
   | TOKEN_DELTA_ISOTIMESTAMP { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_DeltaISOTimeStampValue, MK_SPOS_S(@1), $1); }
   | TOKEN_DELTA_LOGICAL      { $$ = BSQON_AST_NODE_CONS(LiteralStandardValue, BSQON_AST_TAG_DeltaLogicalValue, MK_SPOS_S(@1), $1); }
;

bsqonunspecvar: 
   TOKEN_UNSPEC_IDENTIFIER { $$ = BSQON_AST_NODE_CONS(NameValue, BSQON_AST_TAG_UnspecIdentifierValue, MK_SPOS_S(@1), $1); }
;

bsqonidentifier: 
   KW_SRC             { $$ = BSQON_AST_NODE_CONS(NameValue, BSQON_AST_TAG_IdentifierValue, MK_SPOS_S(@1), "$src"); }
   | KW_NPOS          { $$ = BSQON_AST_NODE_CONS(NameValue, BSQON_AST_TAG_IdentifierValue, MK_SPOS_S(@1), "$npos"); }
   | KW_INDEX         { $$ = BSQON_AST_NODE_CONS(NameValue, BSQON_AST_TAG_IdentifierValue, MK_SPOS_S(@1), "$i"); }
   | KW_KEY           { $$ = BSQON_AST_NODE_CONS(NameValue, BSQON_AST_TAG_IdentifierValue, MK_SPOS_S(@1), "$key"); }
   | TOKEN_IDENTIFIER { $$ = BSQON_AST_NODE_CONS(NameValue, BSQON_AST_TAG_IdentifierValue, MK_SPOS_S(@1), $1); }
;

bsqonscopedidentifier:
   bsqonnominaltype SYM_DOUBLE_COLON TOKEN_IDENTIFIER { $$ = BSQON_AST_NODE_CONS(ScopedNameValue, BSQON_AST_TAG_ScopedNameValue, MK_SPOS_R(@1, @3), $1, $3); }
   | bsqonnominaltype SYM_HASH TOKEN_IDENTIFIER { $$ = BSQON_AST_NODE_CONS(EnumAccessValue, BSQON_AST_TAG_EnumAccessValue, MK_SPOS_R(@1, @3), $1, $3); }
   | bsqonnominaltype SYM_HASH TOKEN_TYPE_COMPONENT { $$ = BSQON_AST_NODE_CONS(EnumAccessValue, BSQON_AST_TAG_EnumAccessValue, MK_SPOS_R(@1, @3), $1, $3); }
;

bsqontypeliteral:
   bsqonliteral '<' bsqonnominaltype '>' { $$ = BSQON_AST_NODE_CONS(TypedLiteralValue, BSQON_AST_TAG_TypedLiteralValue, MK_SPOS_R(@1, @3), $1, $3); }
;

bsqonenvaccess: 
   KW_ENV SYM_LBRACK_BAR TOKEN_CSTRING SYM_RBRACK_BAR { $$ = BSQON_AST_NODE_CONS(EnvAccessValue, BSQON_AST_TAG_EnvAccessValue, MK_SPOS_R(@1, @4), $3, NULL); }
   | KW_ENV '<' bsqontype '>' SYM_LBRACK_BAR TOKEN_CSTRING SYM_LBRACK_BAR { $$ = BSQON_AST_NODE_CONS(EnvAccessValue, BSQON_AST_TAG_EnvAccessValue, MK_SPOS_R(@1, @7), $6, $3); }
;

bsqonterminal: 
   bsqonliteral | bsqonunspecvar | bsqonidentifier | bsqonscopedidentifier | bsqontypeliteral | bsqonenvaccess { $$ = $1; }
;

bsqon_mapentry:
   bsqonval SYM_ENTRY bsqonval { $$ = BSQON_AST_NODE_CONS(MapEntryValue, BSQON_AST_TAG_MapEntryValue, MK_SPOS_R(@1, @3), $1, $3); }
   | error SYM_ENTRY bsqonval { $$ = BSQON_AST_NODE_CONS(MapEntryValue, BSQON_AST_TAG_MapEntryValue, MK_SPOS_R(@1, @3), BSQON_AST_ERROR(MK_SPOS_S(@1)), $3); yyerrok; }
   | bsqonval SYM_ENTRY error { $$ = BSQON_AST_NODE_CONS(MapEntryValue, BSQON_AST_TAG_MapEntryValue, MK_SPOS_R(@1, @3), $1, BSQON_AST_ERROR(MK_SPOS_S(@3))); yyerrok; }
   | error SYM_ENTRY error { $$ = BSQON_AST_NODE_CONS(MapEntryValue, BSQON_AST_TAG_MapEntryValue, MK_SPOS_R(@1, @3), BSQON_AST_ERROR(MK_SPOS_S(@1)), BSQON_AST_ERROR(MK_SPOS_S(@3))); yyerrok; }
;

bsqonvall:
   bsqonvall bsqonl_entry { $$ = BSQON_AST_LIST_OF_VALUES_Push($2, $1); }
   | bsqonl_entry { $$ = BSQON_AST_LIST_OF_VALUES_Singleton($1); }
;

bsqonl_entry:
   bsqon_braceval SYM_COMMA { $$ = $1; }
   | error SYM_COMMA { $$ = BSQON_AST_ERROR(MK_SPOS_S(@1)); yyerrok; }
;

bsqonbracketvalue:
   SYM_ELIST_LEFT SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(BracketValue, BSQON_AST_TAG_BracketValue, MK_SPOS_R(@1, @2), NULL); }
   | SYM_ELIST_LEFT bsqonval SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(BracketValue, BSQON_AST_TAG_BracketValue, MK_SPOS_R(@1, @3), BSQON_AST_LIST_OF_VALUES_Singleton($2)); }
   | SYM_ELIST_LEFT bsqonvall bsqonval SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(BracketValue, BSQON_AST_TAG_BracketValue, MK_SPOS_R(@1, @4), BSQON_AST_LIST_OF_VALUES_Reverse(BSQON_AST_LIST_OF_VALUES_Push($3, $2))); }
   | SYM_ELIST_LEFT error SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(BracketValue, BSQON_AST_TAG_BracketValue, MK_SPOS_R(@1, @3), BSQON_AST_LIST_OF_VALUES_Singleton(BSQON_AST_ERROR(MK_SPOS_S(@2)))); yyerrok; }
   | SYM_ELIST_LEFT bsqonvall error SYM_ELIST_RIGHT { $$ = BSQON_AST_NODE_CONS(BracketValue, BSQON_AST_TAG_BracketValue, MK_SPOS_R(@1, @4), BSQON_AST_LIST_OF_VALUES_Reverse(BSQON_AST_LIST_OF_VALUES_Push(BSQON_AST_ERROR(MK_SPOS_S(@3)), $2))); yyerrok; }
;

bsqonnamevall:
   bsqonnamevall bsqonnameval_entry { $$ = BSQON_AST_NLIST_OF_VALUES_Push($2, $1); }
   | bsqonnameval_entry { $$ = BSQON_AST_NLIST_OF_VALUES_Singleton($1); }
;

bsqon_braceval:
   bsqonval | bsqon_mapentry { $$ = $1; }
;

bsqonnameval_entry:
   TOKEN_IDENTIFIER SYM_EQUALS bsqonval SYM_COMMA { $$ = BSQON_AST_NLIST_OF_VALUES_ENTRY_Create($1, $3); }
   | TOKEN_IDENTIFIER SYM_EQUALS error SYM_COMMA { $$ = BSQON_AST_NLIST_OF_VALUES_ENTRY_Create($1, BSQON_AST_ERROR(MK_SPOS_S(@3))); yyerrok; }
   | bsqon_braceval SYM_COMMA { $$ = BSQON_AST_NLIST_OF_VALUES_ENTRY_Create(NULL, $1); }
   | error SYM_COMMA { $$ = BSQON_AST_NLIST_OF_VALUES_ENTRY_Create(NULL, BSQON_AST_ERROR(MK_SPOS_S(@1))); yyerrok; }
;

bsqonbracevalue:
   '{' '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @2), NULL); }
   | '{' TOKEN_IDENTIFIER SYM_EQUALS bsqonval '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @5), BSQON_AST_NLIST_OF_VALUES_Singleton(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create($2, $4))); }
   | '{' bsqonnamevall TOKEN_IDENTIFIER SYM_EQUALS bsqonval '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @6), BSQON_AST_NLIST_OF_VALUES_Reverse(BSQON_AST_NLIST_OF_VALUES_Push(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create($3, $5), $2))); }
   | '{' TOKEN_IDENTIFIER SYM_EQUALS error '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @5), BSQON_AST_NLIST_OF_VALUES_Singleton(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create($2, BSQON_AST_ERROR(MK_SPOS_S(@4))))); yyerrok; }
   | '{' bsqonnamevall TOKEN_IDENTIFIER SYM_EQUALS error '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @6), BSQON_AST_NLIST_OF_VALUES_Reverse(BSQON_AST_NLIST_OF_VALUES_Push(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create($3, BSQON_AST_ERROR(MK_SPOS_S(@5))), $2))); yyerrok; }
   | '{' bsqon_braceval '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @3), BSQON_AST_NLIST_OF_VALUES_Singleton(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create(NULL, $2))); }
   | '{' bsqonnamevall bsqon_braceval '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @4), BSQON_AST_NLIST_OF_VALUES_Reverse(BSQON_AST_NLIST_OF_VALUES_Push(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create(NULL, $3), $2))); }
   | '{' error '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @3), BSQON_AST_NLIST_OF_VALUES_Singleton(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create(NULL, BSQON_AST_ERROR(MK_SPOS_S(@2))))); yyerrok; }
   | '{' bsqonnamevall error '}' { $$ = BSQON_AST_NODE_CONS(BraceValue, BSQON_AST_TAG_BraceValue, MK_SPOS_R(@1, @4), BSQON_AST_NLIST_OF_VALUES_Reverse(BSQON_AST_NLIST_OF_VALUES_Push(BSQON_AST_NLIST_OF_VALUES_ENTRY_Create(NULL, BSQON_AST_ERROR(MK_SPOS_S(@3))), $2))); yyerrok; }
;

bsqonbracketbracevalue:
   bsqonbracketvalue | bsqonbracevalue { $$ = $1; }
;

bsqontypedvalue:
   '<' bsqontype '>' '(' bsqonbracketbracevalue ')'  { $$ = BSQON_AST_NODE_CONS(TypedValue, BSQON_AST_TAG_TypedValue, MK_SPOS_R(@1, @4), $5, $2, true); }
   | bsqonnominaltype bsqonbracketbracevalue { $$ = BSQON_AST_NODE_CONS(TypedValue, BSQON_AST_TAG_TypedValue, MK_SPOS_R(@1, @2), $2, $1, false); }
   | error '(' bsqonbracketbracevalue ')'    { $$ = BSQON_AST_NODE_CONS(TypedValue, BSQON_AST_TAG_TypedValue, MK_SPOS_R(@1, @4), $3, BSQON_AST_ERROR(MK_SPOS_S(@2)), true); }
   | error bsqonbracketbracevalue            { $$ = BSQON_AST_NODE_CONS(TypedValue, BSQON_AST_TAG_TypedValue, MK_SPOS_R(@1, @2), $2, BSQON_AST_ERROR(MK_SPOS_S(@1)), false); }
; 

bsqonstructvalue:
   bsqonbracketbracevalue | bsqontypedvalue { $$ = $1; }
;

bsqonspecialcons:
   KW_SOME '(' bsqonval ')'  { $$ = BSQON_AST_NODE_CONS(SpecialConsValue, BSQON_AST_TAG_SomeConsValue, MK_SPOS_R(@1, @4), $3, "some"); }
   | KW_SOME '(' error ')'   { $$ = BSQON_AST_NODE_CONS(SpecialConsValue, BSQON_AST_TAG_SomeConsValue, MK_SPOS_R(@1, @4), BSQON_AST_ERROR(MK_SPOS_S(@3)), "some"); yyerrok; }
   | KW_OK '(' bsqonval ')'  { $$ = BSQON_AST_NODE_CONS(SpecialConsValue, BSQON_AST_TAG_OkConsValue, MK_SPOS_R(@1, @4), $3, "ok"); }
   | KW_OK '(' error ')'     { $$ = BSQON_AST_NODE_CONS(SpecialConsValue, BSQON_AST_TAG_OkConsValue, MK_SPOS_R(@1, @4), BSQON_AST_ERROR(MK_SPOS_S(@3)), "ok"); yyerrok; }
   | KW_ERR '(' bsqonval ')' { $$ = BSQON_AST_NODE_CONS(SpecialConsValue, BSQON_AST_TAG_ErrConsValue, MK_SPOS_R(@1, @4), $3, "err"); }
   | KW_ERR '(' error ')'    { $$ = BSQON_AST_NODE_CONS(SpecialConsValue, BSQON_AST_TAG_ErrConsValue, MK_SPOS_R(@1, @4), BSQON_AST_ERROR(MK_SPOS_S(@3)), "err"); yyerrok; }
;

bsqonval: 
  bsqonterminal | bsqonspecialcons | bsqonstructvalue | bsqonletexp | bsqonaccess { $$ = $1; }
;

bsqonletexp:
  '(' KW_LET TOKEN_IDENTIFIER SYM_COLON bsqontype SYM_EQUALS bsqonval KW_IN bsqonval ')' { $$ = BSQON_AST_NODE_CONS(LetInValue, BSQON_AST_TAG_LetInValue, MK_SPOS_R(@1, @10), $3, $5, $7, $9); }
;

bsqonref: 
   bsqonidentifier | bsqonscopedidentifier | bsqonaccess { $$ = $1; }
;

bsqonaccess:
   bsqonref SYM_DOT TOKEN_IDENTIFIER                        { $$ = BSQON_AST_NODE_CONS(AccessNameValue, BSQON_AST_TAG_AccessNameValue, MK_SPOS_R(@1, @3), $1, $3); }
   | bsqonref SYM_LBRACK_BAR TOKEN_NUMBERINO SYM_RBRACK_BAR { $$ = BSQON_AST_NODE_CONS(AccessIndexValue, BSQON_AST_TAG_AccessIndexValue, MK_SPOS_R(@1, @3), $1, $3); }
   | bsqonref SYM_LBRACK_BAR bsqonterminal SYM_RBRACK_BAR   { $$ = BSQON_AST_NODE_CONS(AccessKeyValue, BSQON_AST_TAG_AccessKeyValue, MK_SPOS_R(@1, @4), $1, $3); }
;

bsqonenvlist:
   KW_ENV '{' '}' { $$ = NULL; }
   | KW_ENV '{' TOKEN_IDENTIFIER SYM_COLON bsqontype '}' { $$ = BSQON_AST_NLIST_OF_TYPES_Singleton(BSQON_AST_NLIST_OF_TYPES_ENTRY_Create($3, $5)); }
   | KW_ENV '{' bsqonnametypel TOKEN_IDENTIFIER SYM_COLON bsqontype '}' { $$ = BSQON_AST_NLIST_OF_TYPES_Reverse(BSQON_AST_NLIST_OF_TYPES_Push(BSQON_AST_NLIST_OF_TYPES_ENTRY_Create($4, $6), $3)); }
   | KW_ENV '{' TOKEN_IDENTIFIER SYM_COLON error '}' { $$ = BSQON_AST_NLIST_OF_TYPES_Singleton(BSQON_AST_NLIST_OF_TYPES_ENTRY_Create($3, BSQON_AST_ERROR(MK_SPOS_S(@5)))); yyerrok; }
   | KW_ENV '{' bsqonnametypel TOKEN_IDENTIFIER SYM_COLON error '}' { $$ = BSQON_AST_NLIST_OF_TYPES_Reverse(BSQON_AST_NLIST_OF_TYPES_Push(BSQON_AST_NLIST_OF_TYPES_ENTRY_Create($4, BSQON_AST_ERROR(MK_SPOS_S(@4))), $3)); yyerrok; }
;

bsqoncomponent:
   bsqonval { $$ = BSQON_AST_NODE_CONS(BsqonDeclBody, BSQON_AST_TAG_BsqonDeclBody, MK_SPOS_S(@1), NULL, NULL, $1); }
   | bsqonenvlist bsqonval { $$ = BSQON_AST_NODE_CONS(BsqonDeclBody, BSQON_AST_TAG_BsqonDeclBody, MK_SPOS_R(@1, @2), NULL, $1, $2); }
   | TOKEN_SHEBANG_LINE bsqonval { $$ = BSQON_AST_NODE_CONS(BsqonDeclBody, BSQON_AST_TAG_BsqonDeclBody, MK_SPOS_R(@1, @2), $1, NULL, $2); }
   | TOKEN_SHEBANG_LINE bsqonenvlist bsqonval { $$ = BSQON_AST_NODE_CONS(BsqonDeclBody, BSQON_AST_TAG_BsqonDeclBody, MK_SPOS_R(@1, @3), $1, $2, $3); }
;

bsqonroot: 
   bsqoncomponent { yybsqonval = $1; $$ = $1; }
   | error {yybsqonval = BSQON_AST_ERROR(MK_SPOS_S(@1)); $$ = BSQON_AST_ERROR(MK_SPOS_S(@1)); }
;
%%

extern FILE* yyin;

void yyerror(const char *s, ...)
{
   va_list ap;
   va_start(ap, s);

   if(yylloc.first_line) {
      int ccount = snprintf(errorbuf, MAX_ERROR_LENGTH, "%s @ %d.%d-%d.%d -- %s", s, yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column, filename);

      if(errorcount < MAX_PARSER_ERRORS) {
         errors[errorcount++] = strndup(errorbuf, ccount);
      }
   }
}

#ifndef EXPORT
int main(int argc, char** argv)
{
   if(argc > 1 && !strcmp(argv[1], "-d")) {
      yydebug = 1; argc--; argv++;
   }

    //see page 34 of book

   if(argc == 1) {
      yyin = stdin;
      filename = "<stdin>";
   }
   else {
      if((yyin = fopen(argv[1], "r")) == NULL) {
         perror(argv[1]);
         exit(1);
      }

      filename = argv[1];
   }

   if(!yyparse()) {
      //----------------------------
      BSQON_AST_print(yybsqonval);
      //BSQON_TYPE_AST_print(yybsqonval_type);

      printf("\n");
      fflush(stdout);
   }
      
   for(size_t i = 0; i < errorcount; ++i) {
      printf("%s\n", errors[i]);
      fflush(stdout);
   }
}
#else
const struct BSQON_AST_Node* BSQON_AST_parse_from_stdin()
{
   yyin = stdin;
   filename = "<stdin>";

   if(!yyparse()) {
      return yybsqonval;
   }
   else {
      return NULL;
   }
}

const struct BSQON_AST_Node* BSQON_AST_parse_from_file(const char* file)
{
   if((yyin = fopen(file, "r")) == NULL) {
      perror(file);
      exit(1);
   }
   
   if(!yyparse()) {
      return yybsqonval;
   }
   else {
      return NULL;
   }
}

size_t BSQON_AST_getErrorInfo(char** errorInfo)
{
   for(size_t i = 0; i < errorcount; ++i) {
      errorInfo[i] = errors[i];
   }
   fflush(stdout);
   
   return errorcount;
}
#endif
