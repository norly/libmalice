; libmalice

; Code for Linux on IA-32.

extern lmMain

section .text ; start of code


global _lmStart ; export the entry point function
_lmStart:	; void lmStart(void)
mov [__start_esp], esp
call lmMain
.end:
mov esp, [__start_esp]
	; Cleanup can be done here if necessary
mov ebx, eax
mov eax, 1
int 0x80





; lmExit - Terminate safely from any position in the program

global lmExit
lmExit:	; void lmExit(int exitstatus)
mov eax, [esp+4]	; pass the exit status through as eax
jmp _lmStart.end	; poor man's exception handling
	; ret is not necessary





; lmPrintChar - Print one character to stdout (8-bit in 32-bit, LSB)

global lmPrintChar
lmPrintChar:	; void lmPrintChar(int chr)
   ; eax	; will be: syscall number
push ebx 	; will be: stdout fd
   ; ecx 	; will be: character start address
   ; edx	; will be: character counter

mov  edx, 1	; print one char
lea  ecx, [esp+8]	; address of the char
mov  ebx, 1	; stdout fd
mov  eax, 4	; write()
int 0x80

pop ebx
ret





; lmPrintString - Print a null-terminated string to stdout

global lmPrintString
lmPrintString:	; void lmPrintString(char *string)
   ; eax	; will be: syscall number
push ebx 	; will be: stdout fd
   ; ecx 	; will be: character start address
   ; edx	; will be: character counter

mov  eax, 0		; prepare for holding a char
mov  ecx, [esp+8]	; string start address
mov  edx, -1		; init char counter to 0

.loop:
	inc  edx		; char_counter++
	mov  al, [ecx+edx]	; check next char
cmp al, 0			; if != '\0' continue
jne .loop

mov  ebx, 1	; stdout fd
mov  eax, 4	; write()
int 0x80

pop ebx
ret





; lmPrintInt32s - Print an integer to stdout (signed, 32-bit)

global lmPrintInt32s
lmPrintInt32s:	; void lmPrintInt(int num)
   ; eax	; will be: dividend
push ebx	; will be: divisor
   ; ecx 	; will be: character start address
   ; edx	; will be: character counter
mov eax, [esp+8]	; load num
sub esp, 12		; make space for converted integer
lea ecx, [esp+11]	; string offset counter, start at lastchar+1
			; so writing ends at 10 and char 11 is reserved

mov ebx, 10		; always divide by 10

cmp eax, dword 0	; if the number is negative, negate
jge .loop
neg eax			; great fun at -2147483648. Overflow ftw!

.loop:
	mov edx, 0
	idiv ebx
	add edx, 0x30
	dec ecx		; write next char
	mov [ecx], dl
test eax, eax
jne .loop

cmp [esp+20], dword 0	; check for negative number
jge .end		; skip for positive
dec ecx
mov [ecx], byte '-'	; add - sign

.end:
lea edx, [esp+11]
sub edx, ecx	; number of chars
mov  ebx, 1	; stdout fd
mov  eax, 4	; write()
int 0x80	; let the number speak

add esp, 12
pop ebx
ret





; lmReadChar - Read a character from stdin (8-bit in 32-bit, LSB)

global lmReadChar
lmReadChar:	; int lmReadChar(void)
push ebx

sub esp, 4	; make room for character to be read

mov edx, 1	; number of chars
mov ecx, esp	; character buffer
mov ebx, 0	; stdin fd
mov eax, 3	; read()
int 0x80

cmp eax, 0
jne .ok		; No end of input -> return char

mov eax, 0	; End of Input -> return 0
jmp .end

.ok:
mov eax, 0
mov al, [esp]

.end:
add esp, 4
pop ebx
ret





; lmReadInt32s - Read an integer from stdin (signed, 32-bit)
;                       Terminated by EOF or LF

global lmReadInt32s
lmReadInt32s:	; int lmReadInt(void)
push ebx
push esi	; negative number info
push edi	; actual number

sub esp, 4	; make room for character to be read

mov esi, 0	; 0 = positive
mov edi, 0	; start with 0


.next:
mov edx, 1	; number of chars
mov ecx, esp	; character buffer
mov ebx, 0	; stdin fd
mov eax, 3	; read()
int 0x80

cmp eax, 0
je .neg		; End of input

mov eax, 0
mov al, [esp]

cmp al, '-'
jne .process_digit
mov esi, 1
jmp .next

.process_digit:
cmp al, 0x30
jb .neg		; char < '0'
cmp al, 0x39
ja .neg		; char > '9'

sub eax, 0x30
imul edi, 10	; shift old digits
add edi, eax	; add new digit

jmp .next


.neg:
test esi, esi
jz .skip_loop
neg edi


.skip_loop:	; read and skip until newline is encountered
cmp byte [esp], 0x0a
je .end		; if newline found -> end reading

mov edx, 1	; number of chars
mov ecx, esp	; character buffer
mov ebx, 0	; stdin fd
mov eax, 3	; read()
int 0x80

cmp eax, 0
je .end		; End of input -> end reading

jmp .skip_loop


.end:
mov eax, edi	; Return value: The number read

add esp, 4
pop edi
pop esi
pop ebx
ret







section .data

__start_esp: dd 0
