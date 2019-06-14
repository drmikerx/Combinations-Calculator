TITLE Combinations Calculator     (Project5B.asm)

; Author: Michael Childress
; Last Modified: 8/10/2018
; Description: This program introduces itself and then generates and displays two randomly generated
;              numbers. One is n, which will be in the range 3 to 12, and the other is r, which will
;			   be in the range 1 to n. It then asks the user for their input on the number of combinations
;			   that can be chosen based on the numbers generated for n and r. User input is received as a
;			   string and converted into an int. If the string contains non-numeric characters an error
;			   message will display and user will be re-prompted. The program then calculates the correct
;			   answer to the question via a recursive algorithm. The user's input is compared to the
;			   correct answer and the user is told whether they were right or not. Lastly, the user is asked
;			   whether they would like another problem. Input is validated to be either y or n. If y, the
;			   program presents another problem. If n, the program ends with a goodbye message.

INCLUDE Irvine32.inc

;WriteString macro adapted from class lecture # 26 notes

mWriteStr MACRO text
	push	edx
	mov		edx, OFFSET text
	call	WriteString
	pop		edx
ENDM

.data

welcome_1			BYTE		"Welcome to the Combinations Calculator",0
welcome_2			BYTE		"	Implemented by Michael Childress",0
instructions_1		BYTE		"I'll give you a combinations problem. You enter your answer,",0
instructions_2		BYTE		"and I'll let you know if you're right.",0
problemHeader		BYTE		"Problem:",0
displayN			BYTE		"Number of elements in the set:	   ",0
displayR			BYTE		"Number of elements to choose from the set: ",0
userPrompt			BYTE		"How many ways can you choose? ",0
invalidNumber		BYTE		"Invalid input.  Your response here must be an integer.",0
result_1			BYTE		"There are ",0
result_2			BYTE		" combinations of ",0
result_3			BYTE		" items from a set of ",0
periodCharacter		BYTE		".",0
correctAnswer		BYTE		"You are correct!",0
wrongAnswer			BYTE		"You need more practice.",0
playAgain			BYTE		"Another problem? (y/n): ",0
invalidPlayAgain	BYTE		"Invalid response.  Another problem? (y/n): ",0
goodbye				BYTE		"OK ... goodbye.",0
n					DWORD		? ;will be assigned a random number in range 3 to 12
r					DWORD		? ;will be assigned a random number in range 1 to n
stringInput			BYTE		5 DUP(?) ;user will input number as string
inputStringSize		DWORD		? ;will be equal to sizeof stringInput
answer				DWORD		? ;will be assigned by user after conversion from string input
result				DWORD		? ;will be computed in combinations function
playAgainResponse	BYTE		2 DUP(?) ;user inputs y to play again and n to quit

.code
main PROC
	call	Randomize	;setup for random number generation

	;Display the title, programmer name, and instructions
	call	introduction
	jmp		noRegisterRestoreNeeded

anotherGo:
	pop		eax
	pop		esi
	pop		ecx
	pop		edx

noRegisterRestoreNeeded:
	;Generate random numbers for n and r and display the problem
	push	OFFSET n
	push	OFFSET r
	call	showProblem


	;Get and validate user input for answer
	push	OFFSET answer
	push	OFFSET stringInput
	push	OFFSET inputStringSize
	call	getData

	;Calculate correct answer
	push	n
	push	r
	push	OFFSET result
	call	combinations


	;Display the student's answer, calculated result, and whether student got correct answer
	push	n
	push	r
	push	answer
	push	result
	call	showResults

	;Ask if user wants to play again
	push	edx
	push	ecx
	push	esi
	push	eax
	mWriteStr playAgain
	
tryInputAgain:	
	mov		edx,OFFSET playAgainResponse
	mov		ecx,SIZEOF playAgainResponse
	call	ReadString
	mov		esi,OFFSET playAgainResponse
	mov		eax,[esi]
	cmp		eax,89	;ASCII of 'Y'
	je		anotherGo
	cmp		eax,121	;ASCII of 'y'
	je		anotherGo
	cmp		eax,78	;ASCII of 'N'
	je		gameIsDone
	cmp		eax,110	;ASCII of 'n'
	jne		inputNoGood
	jmp		gameIsDone
inputNoGood:
	mWriteStr invalidPlayAgain
	jmp		tryInputAgain

gameIsDone:
	mWriteStr goodbye
	call	CrLf
	pop		eax
	pop		esi
	pop		ecx
	pop		edx

	exit	; exit to operating system
main ENDP


;Procedure to introduce the progam and present instructions
;receives: none
;returns: none
;preconditions: none
;registers changed: none
introduction PROC

	mWriteStr welcome_1
	call	CrLf
	mWriteStr welcome_2
	call	CrLf
	call	CrLf
	mWriteStr instructions_1
	call	CrLf
	mWriteStr instructions_2
	call	CrLf

	ret
introduction ENDP


;Procedure to generate and display random numbers for n and r
;receives: n and r by reference
;returns: random values stored in n and r variables
;preconditions: none
;registers changed: none
showProblem PROC
	push	ebp
	mov		ebp,esp
	push	eax
	push	edi

	;Display problem header
	call	CrLf
	mWriteStr problemHeader
	call	CrLf

	;Generate random number for n (adapted from Lecture # 20 notes)
	mov		eax, 12
	sub		eax, 3
	inc		eax
	call	RandomRange
	add		eax, 3
	mov		edi, [ebp+12]
	mov		[edi], eax	;store random number within the n variable

	;Display this number to the user
	mWriteStr displayN
	call	WriteDec	;value of n is still in eax
	call	CrLf

	;Generate random number for r (n is high value here)
	mov		eax, [edi]	;store hi in eax
	sub		eax, 1
	inc		eax
	call	RandomRange
	add		eax, 1
	mov		edi, [ebp+8]
	mov		[edi], eax	;store random number within the r variable

	;Display this number to the user
	mWriteStr displayR
	call	WriteDec
	call	CrLf

	pop		edi
	pop		eax
	pop		ebp

	ret 8
showProblem ENDP



;Procedure to get and validate user input for their answer
;receives: answer variable by reference
;returns: validated user input stored in answer variable
;preconditions: none
;registers changed: none
getData PROC
	push	ebp
	mov		ebp,esp
	push	ebx
	push	edi
	push	edx
	push	ecx
	push	eax
	push	esi

	mov		ebx,0			;will accumulate to final answer

tryAgain:
	mWriteStr userPrompt
	mov		edi,[ebp+8]		;inputStringSize
	mov		edx,[ebp+12]	;OFFSET of array
	mov		ecx,5			;User can enter 4 digits + a space for null terminator
	call	ReadString
	mov		[edi],eax		;number of characters entered
	
	;string now stored in array and number of characters entered is in [edi]

	mov		ecx,[edi]		;do this once for each character entered
	mov		esi,[ebp+12]	;point to beginning of array

convertNext:
	push	ecx				;save the loop counter
	
	mov		ecx,0
	mov		cl,[esi]		;character as ASCII
	cmp		ecx,48
	jl		invalidInput
	cmp		ecx,57
	jg		invalidInput

	mov		eax,ebx			;previous value of answer
	mov		edx,10
	mul		edx				;10 * previous value of answer
	mov		edx,ecx			;character ASCII
	sub		edx,48			;(str[k] - 48)
	add		eax,edx
	mov		ebx,eax		;answer now updated

	jmp		readyForNext

invalidInput:
	mWriteStr invalidNumber
	call	CrLf
	call	CrLf
	pop		ecx
	jmp		tryAgain

readyForNext:
	add		esi,1			;advance to next character
	pop		ecx				;restore loop counter
	loop	convertNext

	mov		esi,[ebp+16]
	mov		[esi],ebx		;answer now stored in variable


	pop		esi
	pop		eax
	pop		ecx
	pop		edx
	pop		edi
	pop		ebx
	pop		ebp

	ret 12
getData ENDP



;Procedure to calculate the correct number of combinations based on given values of n and r
;receives: n and r variables by value, and result variable by reference
;returns: calculated value stored in result variable
;preconditions: n is in range 3 to 12, r is in range 1 to n
;registers changed: none
combinations PROC
	push	ebp
	mov		ebp,esp
	push	ebx
	push	eax
	push	ecx
	push	edi

	mov		ebx,[ebp+16]
	mov		ecx,[ebp+12]
	mov		eax,1		;if n = r, result will be 1
	cmp		ebx,ecx
	je		noRecursionNeeded


	mov		ebx,[ebp+16]	;move n into ebx
	mov		eax,1			;will accumulate value as n decrements throughout factorial function
	push	ebx				;n will be only value sent to factorial
	push	eax				;accumulator
	call	factorial
	;result of factorial will be stored in EAX
	mov		ecx,eax			;store result temporarily in ECX (n!)

	mov		ebx,[ebp+12]	;move r into ebx
	mov		eax,1
	push	ebx
	push	eax
	call	factorial
	;result of factorial will be stored in EAX
	mov		ebx,eax			;store result in EBX (r!)
	mov		eax,ecx			;EAX = n!
	cdq
	div		ebx
	mov		ecx,eax			;ECX = (n! / r!)


	mov		ebx,[ebp+16]	;n
	mov		eax,[ebp+12]	;r
	sub		ebx,eax			;n-r
	mov		eax,1
	push	ebx
	push	eax
	call	factorial
	;result of factorial will be stored in EAX
	mov		ebx,eax			;(n-r)!
	mov		eax,ecx			;(n! / r!)
	cdq
	div		ebx
	;EAX = (n! / (r!(n-r)!)
	
noRecursionNeeded:	
	mov		edi,[ebp+8]		;@result
	mov		[edi],eax


	pop		edi
	pop		ecx
	pop		eax
	pop		ebx
	pop		ebp

	ret 12
combinations ENDP



;Procedure to recursively calculate the factorial of a number
;Implementation note: This procedure implements the following recursive algorithm:
;	if (x == 1)
;		return 1
;	else
;		return x * factorial(x-1)
;receives: value to be recursed in EBX, and accumulator in EAX
;returns: result of calculation stored in EAX
;preconditions: EBX contains value of n, r, or n-r, and EAX contains 1
;registers changed: EAX (will be restored by combinations fxn before returning to main)
factorial PROC
	push	ebp
	mov		ebp,esp
	push	edx
	push	ebx

	mov		eax,[ebp+8]		;accumulator
	mov		ebx,[ebp+12]	;not technially a loop counter, but value of n will determine base case

	mul		ebx				;n * previous accumulation
	mov		edx,1			;base case reached when n = 1
	cmp		ebx,edx
	je		quit			;base case n = 1 reached
recurse:
	dec		ebx				;n - 1
	push	ebx
	push	eax
	call	factorial

quit:
	pop		ebx
	pop		edx
	pop		ebp

	ret 8
factorial ENDP



;Procedure to display correct answer and compare user input to this value. User is told if response was correct.
;receives: values of n, r, answer, and result all by value
;returns: none
;preconditions: all received variables contain values
;registers changed: none
showResults PROC
	push	ebp
	mov		ebp,esp
	push	eax
	push	ebx

	call	CrLf

	mWriteStr result_1
	mov		eax,[ebp+8]		;result
	call	WriteDec
	mWriteStr result_2
	mov		eax,[ebp+16]	;r
	call	WriteDec
	mWriteStr result_3
	mov		eax,[ebp+20]	;n
	call	WriteDec
	mWriteStr periodCharacter
	call	CrLf

	
	mov		eax,[ebp+12]	;answer
	mov		ebx,[ebp+8]		;result
	
	cmp		eax,ebx
	je		answerIsGood
	;answer was incorrect
	mWriteStr wrongAnswer
	call	CrLf
	call	CrLf
	jmp		theEnd

answerIsGood:
	mWriteStr correctAnswer
	call	CrLf
	call	CrLf

theEnd:
	pop		ebx
	pop		eax
	pop		ebp

	ret 16
showResults ENDP

END main
