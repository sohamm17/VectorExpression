grammar vectorGrammar;

options {
  language = Java;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens{
	PROGRAM;
	IF;
	LOOP;
	PRINT;
	VAR_DECL;
	EXPR;
	PAREN;
}

@parser::members {
  @Override
  protected Object recoverFromMismatchedToken(IntStream input, int ttype, BitSet follow) throws RecognitionException {
    throw new MismatchedTokenException(ttype, input);
  }

  @Override
  public Object recoverFromMismatchedSet(IntStream input, RecognitionException e, BitSet follow) throws RecognitionException {
    throw e;
  }

}

@rulecatch {
    catch (RecognitionException e) {
        throw e;
    }
}

@lexer::members {
    @Override
    public void reportError(RecognitionException e) {
        throw new RuntimeException(e);
    }
}

@header {
}

@lexer::header {
}

program:
		var_decl* statement* EOF -> ^(PROGRAM var_decl* statement*)
	;

var_decl
	: type VARIABLE '=' expression Semicolon -> ^(VAR_DECL type VARIABLE expression)
	;
	
type: 'int';

statement
	:	(assignment
	|	ifStatement
	|	loopStatement
	|	printStatement) Semicolon!
	;
	
assignment:
		VARIABLE '=' expression -> ^('=' VARIABLE ^(EXPR expression)) 
	;

term:
		INT_NUM
	|	VARIABLE
	|	'('! expression ')'!
	;
	
	
mult:
		term (('/'^ | '*'^) term)*
	;

add:
		mult (('+'^ | '-'^) mult)*
	;

expression:
		add (('<'^ | '>'^ | '=='^ | '!='^ ) add)*
	;
	
ifStatement
	:	If '(' expression ')' statement* Fi -> ^(IF ^(PAREN expression) statement*)
	;

loopStatement
	:	Loop '(' expression ')' statement* Pool -> ^(LOOP ^(PAREN expression) statement*)
	;
	
printStatement
	:	Print '(' expression ')' -> ^(PRINT ^(PAREN expression))
	;

//Comparator: ('<' | '==' | '!=' | '>'); For some weird reasons this doesn't work
Semicolon: ';';
If: 'if' ;
Fi: 'fi';
Loop: 'loop';
Pool: 'pool';
Print: 'print';
fragment LETTER: ('a'..'z' | 'A'..'Z');
fragment DIGIT: '0'..'9';
VARIABLE: LETTER (LETTER | DIGIT)* 
		{
			setText(getText() + "_data");
		};
INT_NUM: DIGIT+;
WS: (' ' | '\n' | '\r' | '\t' | '\b')+ {$channel = HIDDEN;};