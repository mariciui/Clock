.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib kernel32.lib 
extern GetLocalTime@4: proc
includelib canvas.lib
extern BeginDrawing: proc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

csec DD 0 ;numara 12*secunde 

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20



h dd 0
s dd 0
m dd 0
state dd 0
symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

mytimeStruct STRUCT 
wYear word ?
wMonth word ?
wDayOfWeek word ?
wDay word ?
wHour word ?
wMinute word ?
wSecond word ?
wMilliseconds word ?
mytimeStruct ends
mytime mytimeStruct <> 

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

patrat MACRO dim1,dim2,culoare,x

LOCAL dreaptasec,jossec,stangasec,sussec   ;desenare patrat cifre ceas 
   
   mov eax,dim1
   mov ebx, area_width
   mul ebx
   add eax,dim2
   mov ebx,4
   mul ebx 
   add eax,area 
   
   mov ecx,0 
   
   dreaptasec: 
   mov dword ptr[eax],culoare
   add eax,4
   inc ecx
   cmp ecx,x
   jne dreaptasec
   
   mov ecx,0 
   
   jossec : 
   mov dword ptr[eax],culoare
   add eax, area_width *4
   inc ecx
   cmp ecx,x
   jne jossec 
   
   mov ecx,0 
   stangasec:
   mov dword ptr[eax],culoare
   sub eax,4
   inc ecx
   cmp ecx,x
   jne stangasec
   
   mov ecx,0 
   
   sussec: 
   
   mov dword ptr[eax],culoare
   sub eax,area_width*4
   inc ecx
   cmp ecx,x
   jne sussec
   ENDM
   
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	   mov eax,30
   mov ebx, area_width
   mul ebx
   add eax,30
   mov ebx,4
   mul ebx 
   add eax,area 
   
   mov ecx,0 
   
   dreapta: 
   mov dword ptr[eax],0CD5C5Ch
   add eax,4
   inc ecx
   cmp ecx,400
   jne dreapta
   
   mov ecx,0 
   
   jos : 
   mov dword ptr[eax],0CD5C5Ch
   add eax, area_width *4
   inc ecx
   cmp ecx,400
   jne jos 
   
   mov ecx,0 
   stanga:
   mov dword ptr[eax],0CD5C5Ch
   sub eax,4
   inc ecx
   cmp ecx,400
   jne stanga 
   
   mov ecx,0 
   
   sus: 
   
   mov dword ptr[eax],0CD5C5Ch
   sub eax,area_width*4
   inc ecx
   cmp ecx,400
   jne sus
   jmp afisare_litere
	
	
	
evt_click:
 inc h
 jmp afisare_litere
 

   
  
   d1 : 
   patrat 45,215,0h,30
   jmp dd12
   
   d2: 
   patrat 65,290,0h,30
   jmp dd1

   
   d3: 
   patrat 125,350,0h,30
   jmp dd2
   
   d4: 
   patrat 207,375,0h,30
   jmp dd3
   
   d5: 
   patrat 290,351,0h,30
   jmp dd4 
   
   d6: 
   patrat 348,291,0h,30
   jmp dd5
   
   d7: 
   patrat 365,208,0h,30
   jmp dd6
   
   d8:
   patrat 350,124,0h,30
   jmp dd7 
   
   d9: 
   patrat 288,63,0h,30
   jmp dd8
   
   d10: 
   patrat 210,42,0h,30
   jmp dd9 
   
   d11:
   patrat 126,65,0h,30
   jmp dd10 
   
   d12:
   patrat 67,130,0h,30
   jmp dd11
   d13 : 
   patrat 45,215,0h,30
   jmp dd12
 
   dd1 :
   patrat 45,215,0FFFFFFh,30
   jmp evt_timer
   
   dd2: 
   patrat 65,290,0FFFFFFh,30
   jmp evt_timer
   
   dd3: 
   patrat 125,350,0FFFFFFh,30
   jmp evt_timer
   
   dd4: 
   patrat 207,375,0FFFFFFh,30
   jmp evt_timer
   
   dd5: 
   patrat 290,351,0FFFFFFh,30
   jmp evt_timer 
   
   dd6: 
   patrat 348,291 ,0FFFFFFh,30
   jmp evt_timer
   
   dd7: 
   patrat 365,208,0FFFFFFh,30
   jmp evt_timer
   
   dd8:
   patrat 350,124 ,0FFFFFFh,30
  jmp evt_timer 
   
   dd9: 
   patrat 288,63,0FFFFFFh,30
   jmp evt_timer 
   
   dd10: 
   patrat 210,42,0FFFFFFh,30
   jmp evt_timer 
   
   dd11:
   patrat 126,65,0FFFFFFh,30
   jmp evt_timer 
   
   dd12:
   patrat 67,130,0FFFFFFh,30
  jmp evt_timer
    
  
   
   patratmin1: 
   patrat 55,280,0ff0000h,45
   jmp dm12

   
   patratmin2: 
   patrat 115,340,0ff0000h,45
   jmp dm1
   
   patratmin3: 
   patrat 197,365,0ff0000h,45
   jmp dm2
   
   patratmin4: 
   patrat 280,341,0ff0000h,45
   jmp dm3
 
   
   patratmin5: 
   patrat 338,281,0ff0000h ,45
   jmp dm4
   
   patratmin6: 
   patrat 355,198,0ff0000h,45
   jmp dm5
   
   patratmin7:
   patrat 340,114,0ff0000h,45
   jmp dm6 
   
   patratmin8: 
   patrat 278,53,0ff0000h,45
   jmp dm7
   
   patratmin9: 
   patrat 200,32,0ff0000h,45
   jmp dm8 
   
   patratmin10:
   patrat 116,55,0ff0000h,45
   jmp dm9 
   
   patratmin11:
   patrat 57,120,0ff0000h,45
   jmp dm10
   patratmin12 : 
   patrat 35,205,0ff0000h,45
   jmp dm11
  
  ora1: 
   patrat 50,270,000ff00h,60
   jmp do12

   
   ora2: 
   patrat 110,330,000ff00h,60
   jmp do1
   
   ora3: 
   patrat 192,355,000ff00h,60
   jmp do2
   
   ora4: 
   patrat 275,331,000ff00h,60
   jmp do3
 
   
   ora5: 
   patrat 333,271,000ff00h,60
   jmp do4
   
  ora6: 
   patrat 350,188,000ff00h,60
   jmp do5
   
   ora7:
   patrat 335,104,000ff00h,60
   jmp do6
   
   ora8: 
   patrat 273,43,000ff00h,60
   jmp do7
   
   ora9: 
   patrat 195,22,000ff00h,60
   jmp do8 
   
   ora10:
   patrat 111,45,000ff00h,60
   jmp do9 
   
   ora11:
   patrat 52,110,000ff00h,60
   jmp do10
   ora12 : 
   patrat 30,195,000ff00h,60
   jmp do11
  
  dm1 :
   patrat 55,280,0FFFFFFh,45
   jmp evt_timer
   
   dm2: 
   patrat 115,340,0FFFFFFh,45
   jmp evt_timer
   
   dm3: 
   patrat 197,365,0FFFFFFh,45
   jmp evt_timer
   
   dm4: 
   patrat 280,341,0FFFFFFh,45
   jmp evt_timer
   
   dm5: 
   patrat 338,281,0FFFFFFh,45
   jmp evt_timer 
   
   dm6: 
   patrat 355,198 ,0FFFFFFh,45
   jmp evt_timer
   
   dm7: 
   patrat 340,114,0FFFFFFh,45
   jmp evt_timer
   
   dm8:
   patrat 278,53 ,0FFFFFFh,45
  jmp evt_timer 
   
   dm9: 
   patrat 200,32,0FFFFFFh,45
   jmp evt_timer 
   
   dm10: 
   patrat 116,55,0FFFFFFh,45
   jmp evt_timer 
   
   dm11:
   patrat 57,120,0FFFFFFh,45
   jmp evt_timer 
   
   dm12:
   patrat 35,205,0FFFFFFh,45
  jmp evt_timer
; mov ecx,6 
   do1 :
   patrat 50,270,0FFFFFFh,60
   jmp evt_timer
   
   do2: 
   patrat 110,330,0FFFFFFh,60
   jmp evt_timer
   
   do3: 
   patrat 192,355,0FFFFFFh,60
   jmp evt_timer
   
   do4: 
   patrat 275,331,0FFFFFFh,60
   jmp evt_timer
   
   do5: 
   patrat 333,271,0FFFFFFh,60
   jmp evt_timer 
   
   do6: 
   patrat 350,188 ,0FFFFFFh,60
   jmp evt_timer
   
   do7: 
   patrat 335,104,0FFFFFFh,60
   jmp evt_timer
   
   do8:
   patrat 273,43 ,0FFFFFFh,60
  jmp evt_timer 
   
   do9: 
   patrat 195,22,0FFFFFFh,60
   jmp evt_timer 
   
   do10: 
   patrat 111,45,0FFFFFFh,60
   jmp evt_timer 
   
   do11:
   patrat 52,110,0FFFFFFh,60
   jmp evt_timer 
   
   do12:
   patrat 30,195,0FFFFFFh,60
  jmp evt_timer
evt_timer:

	;mov counter,0

    inc counter

	
	add s,5
    cmp s,650
	jle afisare_sec
	mov s,0
	inc m
	cmp m,12
	jle afisare_minute
	
	mov m,0
	inc h
	cmp h,12
	jle afisare_ora
	mov counter,0
	
	
	

afisare_minute:

mov eax,m 
	cmp eax,1
	je patratmin1
	
	mov eax,m 
	cmp eax,2
	je patratmin2
	
	mov eax,m 
	cmp eax,3
	je patratmin3
	
	mov eax,m 
	cmp eax,4 
	je patratmin4 
	mov eax,m 
	cmp eax,5
	je patratmin5
	
	mov eax,m 
	cmp eax,6
	je patratmin6
	
	mov eax,m 
	cmp eax,7
	je patratmin7
	
	mov eax,m 
	cmp eax,8 
	je patratmin8 
	mov eax,m 
	cmp eax,9
	je patratmin9
	
	mov eax,m 
	cmp eax,10
	je patratmin10
	
	mov eax,m 
	cmp eax,11
	je patratmin11
	
	mov eax,m 
	cmp eax,12 
	je patratmin12
	
	afisare_sec:
	mov eax,s
	cmp eax,50 ;doua secunde
	je d2 
	mov eax,s 
	cmp eax,100 ;trei secunde 
	je d3
	mov eax,s 
	cmp eax,150
	je d4
	mov eax,s
	cmp eax,200
	je d5
	mov eax,s
	cmp eax,250
	je d6
	mov eax,s
	cmp eax,300
	je d7	
	mov eax,s
	cmp eax,350
	je d8 
	mov eax,s 
	cmp eax,400
	je d9
    mov eax,s
	cmp eax,450
	je d10
	mov eax,s 
	cmp eax,500
	je d11	
	mov eax,s 
	cmp eax,550
	je d12
	mov eax,s
	cmp eax,600
	je d13

afisare_ora:
mov eax,h 
	cmp eax,1
	je ora1
	
	mov eax,h 
	cmp eax,2
	je ora2
	
	mov eax,h
	cmp eax,3
	je ora3
	
	mov eax,h 
	cmp eax,4 
	je ora4 
	mov eax,h 
	cmp eax,5
	je ora5
	
	mov eax,h 
	cmp eax,6
	je ora6
	
	mov eax,h 
	cmp eax,7
	je ora7
	
	mov eax,h 
	cmp eax,8 
	je ora8 
	mov eax,h 
	cmp eax,9
	je ora9
	
	mov eax,h
	cmp eax,10
	je ora10
	
	mov eax,h 
	cmp eax,11
	je ora11
	
	mov eax,h 
	cmp eax,12 
	je ora12
	
	

	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;desenare cifre ceas 
    make_text_macro '1', area, 218, 50
	make_text_macro '2', area, 230, 50
	make_text_macro '1', area, 302, 71
	make_text_macro '2', area, 361, 131
	make_text_macro '3', area, 384, 213
	make_text_macro '4', area, 362, 295
	make_text_macro '5', area, 300, 353
	make_text_macro '6', area, 216, 373	
	make_text_macro '7', area, 132, 354
	make_text_macro '8', area, 74, 291	
	make_text_macro '9', area, 50, 212
	make_text_macro '1', area, 72, 131
	make_text_macro '0', area, 82, 131
	make_text_macro '1', area, 133, 71
	make_text_macro '1', area, 145, 71
	


final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret	
draw endp

get_time proc 
push offset mytime 
call GetLocalTime@4 

mov ebx,0
mov bx, mytime.wHour 
mov h, ebx 
mov ebx, 0
mov bx, mytime.wMinute
mov m, ebx 
mov ebx, 0
mov bx, mytime.wSecond 
mov s,ebx 
ret
 get_time endp 


start:

    ;call get_time

	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
