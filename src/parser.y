%{

#include <cstdio>

extern FILE *yyin;
extern FILE *yyout;
extern int yylex(void);
extern int yylineno;

#include "AST/StatementList.hpp"
int yyerror(ast::StatementList& ast, const char* message);

extern int yywrap(void);

%}

/***************
 * Preferences *
 ***************/

%code requires {
    #include "AST/AST.hpp"

    #include "AST/AST.hpp"
    #include "AST/StatementList.hpp"
    #include "AST/Types.hpp"
}

%defines "parser.hpp"
%output="parser.cpp"

%parse-param {ast::StatementList& statements}

%union {
    ast::BaseNode* node; 
    ast::CommandNode* commandNode;
    //ast::NodePtr<ast::BinaryOperatorNode> binaryOp;
    //ast::NodePtr<ast::UnaryOperatorNode> unaryOperator;
    //ast::NodePtr<ast::CommandNode> command;
    //ast::NodePtr<ast::IdentifierNode> identifier;
    //ast::NodePtr<ast::ConstantValueNode> constant;
    //ast::NodePtr<ast::VariableDeclNode> varDecl;

    double number;
    char* string;

    // to store the actual token
    // e.g. for an operator we will store the token
    // thus when converting we will just:
    // if token == TOKEN_PLUS
    // etc. etc.
    int token;
}

/********************
* Token Definitions *
*********************/

%token TOKEN_BEGIN_PROGRAM;
%token TOKEN_END_PROGRAM;
%token TOKEN_END_OF_STATEMENT

/* Commands */
%token TOKEN_PRINT
%token TOKEN_INPUT

/* Variable Types */
%token TOKEN_STRING_TYPE
%token TOKEN_NUMBER_TYPE

/* Identifiers/constant expressions */
%token <string> TOKEN_STRING_LITERAL
%token <number> TOKEN_NUMBER_CONSTANT

/* Operators */
%token <token> TOKEN_LEFT_PARAN
%token <token> TOKEN_RIGHT_PARAN

%token <token> TOKEN_ASSIGNMENT 
%token <token> TOKEN_MULTIPLY
%token <token> TOKEN_DIVIDE
%token <token> TOKEN_PLUS
%token <token> TOKEN_MINUS

%token <string> TOKEN_IDENTIFIER

%type <node> expression value constant
%type <commandNode> command
%type <node> statement

/*%type <token> binary_op*/

/* Operator precedence for mathematical operators */
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_MULTIPLY TOKEN_DIVIDE
/*%right TOKEN_ASSIGNMENT;*/

%start program

%%

program : TOKEN_BEGIN_PROGRAM statements TOKEN_END_PROGRAM;

statements : statement TOKEN_END_OF_STATEMENT { statements.emplace_back(ast::node($1)); } |
             TOKEN_END_OF_STATEMENT
statement : /*variable_declaration | command |*/ expression;

/* TODO: Throw errors */
/*
variable_declaration : TOKEN_STRING_TYPE identifier { $$ = ast::node<>(); } |
                       TOKEN_NUMBER_TYPE identifier { };
*/
/*identifier : TOKEN_IDENTIFIER { $$ = ast::node<ast::IdentifierNode>($1); }*/

/* expression */
expression : /*expression binary_op expression { } |*/
             value
             |
             command;


value : /*var | */constant;
/*var : identifier;*/
constant: TOKEN_NUMBER_CONSTANT { std::cout << "hit constant node\n"; $$ = new ast::ConstantValueNode{$1}; } | 
          TOKEN_STRING_LITERAL  { $$ = new ast::ConstantValueNode{$1}; } ;

/*binary_op : TOKEN_ASSIGNMENT | TOKEN_PLUS | TOKEN_MINUS | TOKEN_DIVIDE | TOKEN_MULTIPLY;*/

command : TOKEN_PRINT expression { $$ = new ast::CommandNode(ast::Command::PRINT, ast::node($2)); }; /*| 
          TOKEN_INPUT var { $$ = ast::node<ast::CommandNode>(ast::CommandNode::Command::INPUT, ast::node<IdentifierNode>($2)); };
          */

%%

/*
expression : unary_op expression { } |
expression:
             expression binary_op expression { } |
unary_op : TOKEN_ASSIGNMENT | TOKEN_PLUS | TOKEN_MINUS;
*/

int yyerror(ast::StatementList& ast, const char* message)
{
    std::cerr << "[ERROR]: " << message << "(" << yylineno << ")\n";
    return 0;
}
