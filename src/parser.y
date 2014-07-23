%{
#include <iostream>
#include <string>

#include "AST/AST.hpp"

#include "ErrorCodes.hpp"
#include "Interpreter.hpp"

// extern functions/vars (yuck, I know)
extern "C" {
	FILE *yyin;
	FILE *yyout;
	int yyparse(void);
}

StatementList statements;
int parse(const std::string& filepath);

%}

%parse-param {StatementList& statements}

/***************
 * Preferences *
 ***************/
%defines "parser.hpp"
%output "parser.cpp"

%union {
    double numberValue;
    char* stringValue;
}

/********************
* Token Definitions *
*********************/

%token TOKEN_BEGIN_PROGRAM;
%token TOKEN_END_PROGRAM;

/* Variable Types */
%token TOKEN_STRING_VAR
%token TOKEN_NUMBER_VAR

/* Identifiers/constant expressions */
%token TOKEN_IDENTIFIER
%token <stringValue> TOKEN_STRING_LITERAL
%token <numberValue> TOKEN_NUMBER_CONSTANT
%token TOKEN_END_OF_STATEMENT

/* Commands */
%token TOKEN_PRINT
%token TOKEN_INPUT

/* Operators */
%token TOKEN_LEFT_PARAN
%token TOKEN_RIGHT_PARAN
%token TOKEN_ASSIGNMENT 
%token TOKEN_MULTIPLY
%token TOKEN_DIVIDE
%token TOKEN_PLUS
%token TOKEN_MINUS

/* Operator precedence for mathematical operators */
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_MULTIPLY TOKEN_DIVIDE

%start program

%%

program : TOKEN_BEGIN_PROGRAM statements TOKEN_END_PROGRAM;

statements : statement TOKEN_END_OF_STATEMENT | TOKEN_END_OF_STATEMENT;

statement : variable_declaration | command | expression;

var : TOKEN_IDENTIFIER;

variable_declaration : TOKEN_STRING_VAR TOKEN_IDENTIFIER { statements.emplace_back(new VariableNode(Value($2)));} |
                       TOKEN_NUMBER_VAR TOKEN_IDENTIFIER { statemnets.emplace_back(new VariableNode(Value(util::from_string($2)))); };

command : TOKEN_PRINT expression { } | 
          TOKEN_INPUT var { statements.emplace_back(new PrintCommandNode($2)); };

%%

/*
expression : var TOKEN_ASSIGNMENT expression { } |
             var TOKEN_PLUS var { } |
             var TOKEN_MINUS var { } |
             var TOKEN_MULTIPLY var { } |
             var TOKEN_DIVIDE var { };
             */

int parse(const std::string& filepath)
{
	// Open the file we wish to interpet
	FILE* file = fopen(filepath.c_str(), "r"); // have to use FILE for bison/flex
	
    // if we failed to open the file
    if(!file)
	{
		std::cerr << "[ERROR]: Failed to open file: \"" << filepath << "\"\n";
		std::cerr << "Perhaps there is no persmission or file does not exist?\n";

		if(errorCode)
        {
            return errorCode;
        }
	}
	
	// set flex to read from the file instead of stdin
	yyin = file;

	// parse through the file
	while(!feof(yyin))
	{
		// get yacc (bison in this case) to parse the file
		yyparse();
	}
}
