TITLE Composite Numberama

; Author: Alex Muñoz
; Last Modified: 02/16/2020
; Date:  02/16/2020
; Description: Asks the user for number n in the range of 1 to 400, the program
;			  verifies and then efficiently calculates and colorfully displays
;			  all of the composite numbers up to the nth composite (inclusive).

; #############################################################################

; /////////////////////////////////////////////////////////////////////////////
;	LIBRARIES
; /////////////////////////////////////////////////////////////////////////////

INCLUDE Irvine32.inc


; /////////////////////////////////////////////////////////////////////////////
;	CONSTANTS
; /////////////////////////////////////////////////////////////////////////////

; The limits for the user input
		LOWER_LIMIT = 1
		UPPER_LIMIT = 400

; Spacer Character
	; ASCII code for TAB character
		SPACER = 9		

; Number of composite numbers per output line
		LINE_MAX = 10

; Cascade Constants (for EC)
	; time to wait before displaying a composite number
		DELAY_TIME = 10	

	; The range for random number generation for the text color
	; set to 14 as to exclude black
		COLOR_VALS = 14

; /////////////////////////////////////////////////////////////////////////////
	.DATA
; /////////////////////////////////////////////////////////////////////////////

; Program Messages
	; Introduction Strings
		programTitle		BYTE	"Composite Numberama",0
		programSubtitle		BYTE	"A program by Alex Munoz",0
		feature_1			BYTE	"*Composite numbers are aligned",0
		feature_2			BYTE	"*Efficient algorithm finds composite numbers by dividing by primes",0
		feature_3			BYTE	"*Composite Numberama has a special, colorful surprise!",0

	; Instruction Strings
		instruction_1		BYTE	"How many composite numbers would you like to see displayed?",0
		instruction_2		BYTE	"Please enter a positive integer between 1 and 400:",0

	; Entry prompt / Validation String
		inputPrompt			BYTE	">>",0
		outOfRangeMsg		BYTE	"Out of range. ",0

	; Post-calculation Strings
		thankYouMsg			BYTE	"Thank you for using Composite Numberama! Goodbye.", 0

; Program Variables
	; User input
		userInput			DWORD	?
		validInput			BYTE	?

	; Calculation
		numberComposite		BYTE	?
		lineCount			BYTE	0
		; Only need the first 8 prime numbers to calc the first 400 composites
		primeArray			DWORD	2, 3, 5, 7, 11, 13, 17, 19
		primeArrayLength	DWORD	($ - primeArray)
	

; /////////////////////////////////////////////////////////////////////////////
	.CODE
; /////////////////////////////////////////////////////////////////////////////

; ==[ MAIN ]===================================================================

main PROC

; Main procedure of the Composite Numberama program

		CALL		introduction
		CALL		getUserData
		CALL		showComposites
		CALL		farewell
		EXIT

main ENDP


; ==[ INTRODUCTION ]===========================================================

introduction PROC

; Display the introductory message to the user, and give them the instructions.
	; Clear the console and write title
		CALL		ClrScr
		MOV			EDX, OFFSET programTitle
		CALL		WriteString
		CALL		CrLf

	; Write subtitle
		MOV			EDX, OFFSET programSubtitle
		CALL		WriteString
		CALL		CrLF
		CALL		CrlF

	; Write extra-credit lines
		MOV			EDX, OFFSET feature_1
		CALL		WriteString
		CALL		CrLf
		MOV			EDX, OFFSET feature_2
		CALL		WriteString
		CALL		CrLf
		MOV			EDX, OFFSET feature_3
		CALL		WriteString
		CALL		CrLf
		CALL		CrLf

	; Write program instructions
		MOV			EDX, OFFSET instruction_1
		CALL		WriteString
		CALL		CrLf
		MOV			EDX, OFFSET instruction_2
		CALL		WriteString
		CALL		CrLf

	; Return
		RET

introduction ENDP


; ==[ GET USER DATA ]==========================================================

getUserData PROC

; Get the input from the user
	; Write input prompt and read user input, which is stored to EAX register
		getUserInput:
		CALL		CrLf
		MOV			EDX, OFFSET inputPrompt
		CALL		WriteString
		CALL		ReadInt
		MOV			userInput, EAX

	; Pass the userInput to the validate subroutine for validation
		PUSH		userInput
		CALL		validate

	; Repeat if invalid input
		CMP			validInput, FALSE
		JE			getUserInput

	; Return
		RET

getUserData ENDP


; ==[ VALIDATE INPUT ]=========================================================

validate PROC

; Validate that the user's entry is a positive integer within the specified 
; range. If the entry is valid, inputValid is set to TRUE, otherwise set to 
; FALSE
	; Push return address to top of stack, and set to ESP in order to use EBP 
	; as base pointer in subroutine's stack frame
		PUSH		EBP
		MOV			EBP, ESP

	; Store the value of the passed user input to the EBX register
		MOV			EBX,[EBP + 8]

	; Compare entry to upper and lower limits
		
		; if user input (EBX) less than lower limit
		CMP			EBX, LOWER_LIMIT		
		JB			invalid

		; elif user input (EBX) greater than upper limit
		CMP			EBX, UPPER_LIMIT
		JA			invalid

		; else user input is valid
		JMP			valid

	; User's entry is out of range
		invalid:
		; Write out of range message and repeat instructions
		MOV			EDX, OFFSET outOfRangeMsg
		CALL		WriteString
		MOV			EDX, OFFSET instruction_2
		CALL		WriteString

		; set valid input to false and return
		MOV			validInput, FALSE
		JMP			returnValidate

	; User's entry is in the specified range
		valid:
		MOV			validInput, TRUE
		
	; Clean up the stack and return
		returnValidate:
		POP			EBP
		RET			4

validate ENDP


; ==[ SHOW COMPOSITES ]========================================================

showComposites PROC

	; Set loop counter equal to userInput
		; Start writing composites on next line
		CALL		CrLf

		; EAX will keep track of current number. Starts at 4, which is the 
		; first composite number
		MOV			EAX, 4

		; ECX will be the loop counter
		MOV			ECX, userInput

		; Create random seed so same 'random' colors aren't used every time
		CALL		Randomize

	; Write Composite Numbers
		writeComposites:
		; Pass current number to the isComposite subroutine to determine 
		; whether it is composite or not
		PUSH		EAX
		CALL		isComposite
		POP			EAX

		; If composite then write number, else continue
		CMP			numberComposite, TRUE
		JE			writeLineCheck

		; only decrement loop counter if a composite has been found
		INC			ECX		
		JMP			continue
				
		; First, see if 10 numbers per line limit reached, if not skip to write
		; value, else carriage return and write value
		writeLineCheck:
		CMP			lineCount, LINE_MAX
		JB			WriteValue
		CALL		CrLf
		MOV			lineCount, 0

		WriteValue:
		; Random Color Generation
		; Temporarily store EAX in EBX for randomization
		MOV			EBX, EAX	
		MOV			EAX, COLOR_VALS
		CALL		RandomRange
		; By incrementing, black text on black background is avoided
		INC			EAX			
		CALL		SetTextColor

		; Delay a short period to create cascade effect
		MOV			EAX, DELAY_TIME
		CALL		DELAY
		MOV			EAX, EBX	; Restore value of EAX

		; Write the value
		CALL		WriteDec
		; Temporarily store EAX in EBX in order to write spacer character
		MOV			EBX, EAX	
		MOV			AX, SPACER
		CALL		WriteChar
		; Restore value of EAX
		MOV			EAX, EBX	
		INC			lineCount
		JMP			continue

		continue:	
		INC			EAX
		LOOP		writeComposites
	
	; Return
		RET

showComposites ENDP

; ==[ IS COMPOSITE ]===========================================================

isComposite PROC

; Determines whether a passed number argument is composite or not. 
; Sets numberComposite to TRUE if it is, otherwise FALSE
	; Push return address to top of stack, and set to ESP in order to use EBP 
	; as base pointer in subroutine's stack frame
		PUSH		EBP
		MOV			EBP, ESP

	; Store the value of the passed in number to the EBX register
		MOV			EBX,[EBP + 8]
	
	; Calculate if number is composite
		; Initialize the index register
		MOV			ESI, 0

		; Divide the number by each prime in the prime list to determine 
		; whether it is composite (for EC)
		divideByPrimes:
		MOV			EAX, EBX
		CMP			EAX, primeArray[ESI]
		JE			continuePrimeLoop
		CDQ	
		DIV			primeArray[ESI]
		CMP			EDX, 0
		JE			composite

	; Check if the number is prime
		CMP			ESI, primeArrayLength
		JE			prime

		continuePrimeLoop:
		ADD			ESI, 4
		JMP			divideByPrimes	
		
	; Number has been divided by all prime numbers in prime list but none 
	; yielded a zero remainder, i.e. the number is prime (and therefore not 
	; composite)
		prime:
		MOV			numberComposite, FALSE
		JMP			returnIsComposite

	; The number is composite
		composite:
		MOV			numberComposite, TRUE
		JMP			returnIsComposite

	; Clean up the stack and return
		returnIsComposite:
		POP			EBP
		RET			

isComposite ENDP


; ==[ FAREWELL ]===============================================================

farewell PROC

; Write farewell message to user
	; Change black color text back
		MOV			EAX, 15
		CALL		SetTextColor

	; write message
		CALL		CrLf
		CALL		CrLf
		MOV			EDX, OFFSET thankYouMsg
		CALL		WriteString
		CALL		CrLf

	; return
		RET


farewell ENDP


; #############################################################################

END main
