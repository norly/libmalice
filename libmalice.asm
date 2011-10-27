; libmalice

; Code for Linux on IA-32.

extern lmMain

section .text ; start of code
global _lmStart ; export the entry point function



_lmStart:
mov [__start_esp], esp
call lmMain
_start_end:
mov esp, [__start_esp]
	; Cleanup can be done here if necessary
mov ebx, eax
mov eax, 1
int 0x80





; lmExit - Terminate safely from any position in the program

global lmExit
lmExit:	; void lmExit(int exitstatus)
mov eax, [esp+4]	; pass the exit status through as eax
jmp _start_end	; poor man's exception handling
	; ret is not necessary





; lmPrintChar - Print one character to stdout (8-bit in 32-bit, LSB)

global lmPrintChar
lmPrintChar:	; void lmPrintChar(int chr)
push eax	; will be: syscall number
push ebx 	; will be: stdout fd
push ecx 	; will be: character start address
push edx	; will be: character counter

mov  edx, 1	; print one char
lea  ecx, [esp+20]	; address of the char
mov  ebx, 1	; stdout fd
mov  eax, 4	; write()
int 0x80

pop edx
pop ecx
pop ebx
pop eax
ret





; lmPrintString - Print a null-terminated string to stdout

global lmPrintString
lmPrintString:	; void lmPrintString(char *string)
push eax	; will be: syscall number
push ebx 	; will be: stdout fd
push ecx 	; will be: character start address
push edx	; will be: character counter

mov  eax, 0		; prepare for holding a char
mov  ecx, [esp+20]	; string start address
mov  edx, -1		; init char counter to 0

_print_string_loop:
	inc  edx		; char_counter++
	mov  al, [ecx+edx]	; check next char
cmp al, 0			; if != '\0' continue
jne _print_string_loop

mov  ebx, 1	; stdout fd
mov  eax, 4	; write()
int 0x80

pop edx
pop ecx
pop ebx
pop eax
ret





; lmPrintInt32s - Print an integer to stdout (signed, 32-bit)

global lmPrintInt32s
lmPrintInt32s:	; void lmPrintInt(int num)
push eax	; will be: dividend
push ebx	; will be: divisor
push ecx 	; will be: character start address
push edx	; will be: character counter
mov eax, [esp+20]	; load num
sub esp, 12		; make space for converted integer
lea ecx, [esp+11]	; string offset counter, start at lastchar+1
			; so writing ends at 10 and char 11 is reserved

mov ebx, 10		; always divide by 10

cmp eax, dword 0	; if the number is negative, negate
jge _print_int_loop
neg eax			; great fun at -2147483648. Overflow ftw!

_print_int_loop:
	mov edx, 0
	idiv ebx
	add edx, 0x30
	dec ecx		; write next char
	mov [ecx], dl
test eax, eax
jne _print_int_loop

cmp [esp+32], dword 0	; check for negative number
jge _print_int_end	; skip for positive
dec ecx
mov [ecx], byte '-'	; add - sign

_print_int_end:
lea edx, [esp+11]
sub edx, ecx	; number of chars
mov  ebx, 1	; stdout fd
mov  eax, 4	; write()
int 0x80	; let the number speak

add esp, 12
pop edx
pop ecx
pop ebx
pop eax
ret





; lmReadChar - Read a character from stdin (8-bit in 32-bit, LSB)

global lmReadChar
lmReadChar:	; int lmReadChar(void)
push ebx
push ecx
push edx

sub esp, 4	; make room for character to be read

mov edx, 1	; number of chars
mov ecx, esp	; character buffer
mov ebx, 0	; stdin fd
mov eax, 3	; read()
int 0x80

cmp eax, 0
jne _read_char_ok	; No end of input -> return char

mov eax, 0		; End of Input -> return 0
jmp _read_char_end

_read_char_ok:
mov eax, 0
mov al, [esp]

_read_char_end:
add esp, 4
pop edx
pop ecx
pop ebx
ret





; lmReadInt32s - Read an integer from stdin (signed, 32-bit)
;                       Terminated by EOF or LF

global lmReadInt32s
lmReadInt32s:	; int lmReadInt(void)
push ebx
push ecx
push edx
push esi	; negative number info
push edi	; actual number

sub esp, 4	; make room for character to be read

mov esi, 0	; 0 = positive
mov edi, 0	; start with 0


_read_int_next:
mov edx, 1	; number of chars
mov ecx, esp	; character buffer
mov ebx, 0	; stdin fd
mov eax, 3	; read()
int 0x80

cmp eax, 0
je _read_int_neg	; End of input

mov eax, 0
mov al, [esp]

cmp al, '-'
jne _read_int_process_digit
mov esi, 1
jmp _read_int_next

_read_int_process_digit:
cmp al, 0x30
jb _read_int_neg	; char < '0'
cmp al, 0x39
ja _read_int_neg	; char > '9'

sub eax, 0x30
imul edi, 10	; shift old digits
add edi, eax	; add new digit

jmp _read_int_next


_read_int_neg:
test esi, esi
jz _read_int_skip_loop
neg edi


_read_int_skip_loop:	; read and skip until newline is encountered
cmp byte [esp], 0x0a
je _read_int_end	; if newline found -> end reading

mov edx, 1	; number of chars
mov ecx, esp	; character buffer
mov ebx, 0	; stdin fd
mov eax, 3	; read()
int 0x80

cmp eax, 0
je _read_int_end	; End of input -> end reading

jmp _read_int_skip_loop


_read_int_end:
mov eax, edi	; Return value: The number read

add esp, 4
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret







section .data

__start_esp: dd 0
