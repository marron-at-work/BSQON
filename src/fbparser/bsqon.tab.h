/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_HOME_MARK_CODE_BOSQUECORE_SRC_BSQON_PARSER_LB_BSQON_TAB_H_INCLUDED
# define YY_YY_HOME_MARK_CODE_BOSQUECORE_SRC_BSQON_PARSER_LB_BSQON_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 29 "/home/mark/Code/BosqueCore/src/bsqon/parser/lb/bsqon.y"

#include "bsqon_ast.h"

#line 53 "/home/mark/Code/BosqueCore/src/bsqon/parser/lb/bsqon.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    SYM_BAR = 258,                 /* SYM_BAR  */
    SYM_AMP = 260,                 /* SYM_AMP  */
    KW_NONE = 262,                 /* "none"  */
    KW_NOTHING = 263,              /* "nothing"  */
    KW_TRUE = 264,                 /* "true"  */
    KW_FALSE = 265,                /* "false"  */
    KW_SOMETHING = 266,            /* "something"  */
    KW_OK = 267,                   /* "ok"  */
    KW_ERR = 268,                  /* "err"  */
    KW_SRC = 269,                  /* "$src"  */
    KW_LET = 270,                  /* "let"  */
    KW_IN = 271,                   /* "in"  */
    SYM_DOUBLE_COLON = 272,        /* "::"  */
    SYM_ENTRY = 273,               /* "=>"  */
    SYM_COLON = 274,               /* ":"  */
    SYM_COMMA = 275,               /* ","  */
    SYM_EQUALS = 276,              /* "="  */
    SYM_UNDERSCORE = 277,          /* "_"  */
    TOKEN_NAT = 278,               /* "nat literal"  */
    TOKEN_INT = 279,               /* "int literal"  */
    TOKEN_BIG_NAT = 280,           /* "big nat literal"  */
    TOKEN_BIG_INT = 281,           /* "big int literal"  */
    TOKEN_RATIONAL = 282,          /* "rational literal"  */
    TOKEN_FLOAT = 283,             /* "float literal"  */
    TOKEN_DECIMAL = 284,           /* "decimal literal"  */
    TOKEN_DECIMAL_DEGREE = 285,    /* "decimal degree literal"  */
    TOKEN_COMPLEX = 286,           /* "complex literal"  */
    TOKEN_LAT_LONG = 287,          /* "geo coordinate literal"  */
    TOKEN_NUMBERINO = 288,         /* "numberino"  */
    TOKEN_BYTE_BUFFER = 289,       /* "byte buffer"  */
    TOKEN_UUID_V4 = 290,           /* "uuid (v4)"  */
    TOKEN_UUID_V7 = 291,           /* "uuid (v7)"  */
    TOKEN_SHA_HASH = 292,          /* "sha3 hashcode (512 bits)"  */
    TOKEN_STRING = 293,            /* "string"  */
    TOKEN_ASCII_STRING = 294,      /* "ascii string"  */
    TOKEN_REGEX = 295,             /* "regular expression"  */
    TOKEN_PATH_ITEM = 296,         /* "path item"  */
    TOKEN_DATE_TIME = 297,         /* "date & time with timezone"  */
    TOKEN_UTC_DATE_TIME = 298,     /* "date & time in UTC"  */
    TOKEN_PLAIN_DATE = 299,        /* "plain date"  */
    TOKEN_PLAIN_TIME = 300,        /* "plain time"  */
    TOKEN_LOGICAL_TIME = 301,      /* "logical time"  */
    TOKEN_TICK_TIME = 302,         /* "tick time"  */
    TOKEN_TIMESTAMP = 303,         /* "ISO timestamp"  */
    TOKEN_IDENTIFIER = 304,        /* "identifier"  */
    TOKEN_TYPE_COMPONENT = 305,    /* "type name"  */
    TOKEN_UNSPEC_IDENTIFIER = 306, /* "unspec identifier"  */
    SYM_BANG = 307,                /* SYM_BANG  */
    SYM_DOT = 308,                 /* SYM_DOT  */
    SYM_AT = 309,                  /* SYM_AT  */
    KW_SOME = 310                  /* KW_SOME  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 33 "/home/mark/Code/BosqueCore/src/bsqon/parser/lb/bsqon.y"

   char* str;
   struct ByteString* bstr;

   struct BSQON_AST_Node* bsqon_type_node;
   struct BSQON_AST_Node* bsqon_value_node;

   struct BSQON_AST_LIST_OF_TYPES* bsqon_type_list;

   struct BSQON_AST_NLIST_OF_TYPES_ENTRY bsqon_named_type_list_entry;
   struct BSQON_AST_NLIST_OF_TYPES* bsqon_named_type_list;

   struct BSQON_AST_LIST_OF_VALUES* bsqon_value_list;

   struct BSQON_AST_NLIST_OF_VALUES_ENTRY bsqon_named_value_list_entry;
   struct BSQON_AST_NLIST_OF_VALUES* bsqon_named_value_list;

#line 141 "/home/mark/Code/BosqueCore/src/bsqon/parser/lb/bsqon.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;

int yyparse (void);


#endif /* !YY_YY_HOME_MARK_CODE_BOSQUECORE_SRC_BSQON_PARSER_LB_BSQON_TAB_H_INCLUDED  */
