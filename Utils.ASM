GetFirstPixelPositionFromSysFrame: ;TODO Nombrar GetPositionOffsetFromSysFrame
; devuelve la posicion del primer byte del pixel
; x,y dentro del SYSFRAME

; parametros
; x	    +4
; y	    +8
; resultado = (y*XRES+x)*4

		mov ecx,[esp+8] ;y

		imul ecx,XRES
		add ecx,[esp+4]
		shl ecx,2 ;ecx*4

		mov [esp+4],ecx

		ret

;***********************************************************************************************************

KeyboardEventHandler:
; recibe un evento de teclado y decide que accion ejecutar


		  cmp [SYSKEY],K_BACKSPACE
		  je KeyboardEventHandler.backspace

		  cmp [SYSKEY],K_ENTER
		  je KeyboardEventHandler.enter

		  cmp [SYSKEY],K_SPACE
		  je KeyboardEventHandler.espacio

		  cmp [SYSKEY],2
		  jl KeyboardEventHandler.exit

		  cmp [SYSKEY],14
		  jl KeyboardEventHandler.doInput

		  cmp [SYSKEY],15
		  jle KeyboardEventHandler.exit

		  cmp [SYSKEY],29
		  jl KeyboardEventHandler.doInput

		  cmp [SYSKEY],29
		  jle KeyboardEventHandler.exit

		  cmp [SYSKEY],41
		  jl KeyboardEventHandler.doInput

		  cmp [SYSKEY],43
		  jle KeyboardEventHandler.exit

		  cmp [SYSKEY],52
		  jl  KeyboardEventHandler.doInput
		  jmp KeyboardEventHandler.exit


KeyboardEventHandler.doInput:
		  mov eax,[SYSKEY]
		  mov ebx,[cinput]
		  mov [input_storage+ebx],eax
		  add ebx,1
		  mov [cinput],ebx

		  call	GraphicDrawCharacter

		  ret

KeyboardEventHandler.backspace:
		  cmp [nComandos],POSITION_MESSAGES_X
		  je KeyboardEventHandler.exit

		  mov [SYSKEY],0
		  ;TODO Hacer otra funcion aparte que dibuje caracter en blanco y no aumente nComandos. Asi no seria necesario hacer el sub despues
		  call	GraphicDrawCharacter ;Dibuja blanco en posicion del blink cursor

		  mov eax,[nComandos]
		  sub eax,22
		  mov [nComandos],eax

		  mov [SYSKEY],0
		  call	GraphicDrawCharacter ;Dibuja blanco en el ultimo caracter

		  mov eax,[nComandos]
		  sub eax,11
		  mov [nComandos],eax

		  mov ebx,[cinput]
		  sub ebx,1
		  mov [input_storage+ebx],0
		  mov [cinput],ebx

		  ret

KeyboardEventHandler.espacio:
		  mov ebx,[cinput]

		  mov eax,[input_storage+ebx-1]
		  cmp eax,K_SPACE
		  je KeyboardEventHandler.exit

		  mov [input_storage+ebx],K_SPACE
		  add ebx,1
		  mov [cinput],ebx
		  mov [SYSKEY],0
		  call	GraphicDrawCharacter
		  ret

KeyboardEventHandler.enter:
		  call InputHandler
		  ret


KeyboardEventHandler.exit:
		 ret


;***********************************************************************************************************

InputHandler:
; analiza lo almacenado en el input storage y ejecuta la accion correspondiente
; TODO Usar calls en vez de jumps
		  mov edx,0

InputHandler.repeat1:

		  mov eax,[input_storage+edx]
		  and eax,$00ffff

		  cmp eax,CMDBYE
		  je SYSEND

		  cmp eax,CMDNUMERO
		  je InputHandler.exec_num

		  cmp eax,CMDDUP
		  je InputHandler.exec_duplicate

		  cmp eax,CMDDROP
		  je InputHandler.exec_drop

		  cmp eax,CMDSWAP
		  je InputHandler.exec_swap

		  cmp eax,CMDADVANCE
		  je InputHandler.exec_advance

		  cmp eax,CMDLEFT
		  je InputHandler.exec_left

		  cmp eax,CMDRIGTH
		  je InputHandler.exec_right

		  cmp eax,CMDPOSITION
		  je InputHandler.exec_position

		  cmp eax,CMDUP
		  je InputHandler.exec_up

		  cmp eax,CMDDOWN
		  je InputHandler.exec_down

		  cmp eax,CMDCOLOR
		  je InputHandler.exec_color

		  cmp eax,CMDBACKGROUND
		  je InputHandler.exec_background

		  cmp eax,CMDHOME
		  je InputHandler.exec_home

		  cmp eax,CMDCLEAR
		  je InputHandler.exec_clear

		  cmp eax,CMDLOAD
		  je InputHandler.exec_load

		  cmp eax,CMDSAVE
		  je InputHandler.exec_save

		  cmp eax,CMDRUN
		  je InputHandler.exec_run

		  cmp eax,CMDRPTI
		  je InputHandler.exec_bucle

		  ; me fijo si es un nro, un add ,un sub, un rpt
		  and eax,$00000ff

		  cmp eax,CMDADD
		  je InputHandler.exec_add

		  cmp eax,CMDSUB
		  je InputHandler.exec_sub

		  cmp eax,CMDMUL
		  je InputHandler.exec_mult

		  cmp eax,CMDDIV
		  je InputHandler.exec_div

		  cmp eax,CMDRPTF
		  je InputHandler.bcl_closer

		  cmp eax,CMDLNUMBER
		  jl InputHandler.errorComando
		  cmp eax,CMDHNUMBER
		  jle InputHandler.ejecNumDecimal

		  cmp eax,CMDHEXANUMBER
		  je InputHandler.ejec_NumHexadecimal

InputHandler.errorComando:
		  push msg_notrecognizedcmd
		  call	GraphicPrintMessage
		  add esp,4
		  jmp InputHandler.salir


		  ;busca el proximo comando a reconocer en la linea
InputHandler.repeat2:
		  add edx,1
		  cmp edx,[cinput]
		  jg InputHandler.salir

		  mov eax,[input_storage+edx]
		  and eax,$0000ff
		  cmp eax,K_SPACE
		  jne InputHandler.repeat2

		  add edx,1
		  jmp InputHandler.repeat1

InputHandler.salir:
		  mov [SYSKEY],K_BACKSPACE
		  call KeyboardEventHandler
		  mov eax,[cinput]
		  cmp eax,0
		  jg InputHandler.salir

		  ret

InputHandler.ejecNumDecimal:

		  push edx

		  push eax
		  call GetNumberFromKeyCode
		  pop ebx


		  ; fixme.........
		  push ebx
		  add ebx,48
		  push ebx
		  call HistoryBufferCommand
		  add esp,4
		  pop ebx
		  ; ..............


		  pop edx



 InputHandler.loop1:
		  add edx,1

		  cmp edx,[cinput]
		  jge  InputHandler.edn_FinInputHandler

		  mov eax,[input_storage+edx]
		  and eax,$0000ff

		  cmp eax,K_SUB
		  je InputHandler.edn_negativizar

		  cmp eax,K_SPACE
		  je InputHandler.edn_FinInputHandler

		  cmp eax,CMDLNUMBER
		  jl InputHandler.errorComando

		  cmp eax,CMDHNUMBER
		  jg InputHandler.errorComando

		  ; hago la conversion a numero decimal
		  push edx
		  push ebx
		  push eax
		  call GetNumberFromKeyCode
		  pop ecx


		  ; fixme.........
		  push ecx
		  add ecx,48
		  push ecx
		  call HistoryBufferCommand
		  add esp,4
		  pop ecx
		  ; ..............


		  pop ebx
		  mov eax,10
		  mul ebx
		  mov ebx,eax
		  add ebx,ecx
		  pop edx

		  jmp InputHandler.loop1


InputHandler.edn_negativizar:
		  ; si se encontro el signo "-" al final, paso el nro a negativo
		  push edx
		  mov eax,0
		  sub eax,ebx
		  mov ebx,eax


		  push dword [msg_neg]
		  call SaveHistory
		  add esp,4


		  pop edx
		  add edx,1

InputHandler.edn_FinInputHandler:

		  ; se apila el nro decimal en la pila de numeros
		  push ebx
		  call StackDecimalNumber
		  add esp,4

		  push edx

		  Call	GraphicDrawStack


		  push dword [msg_space]
		  call SaveHistory
		  add esp,4

		  push msg_decnumbercmd
		  call	GraphicPrintMessage
		  add esp,4
		  pop edx

		  cmp edx,[cinput]
		  je InputHandler.salir

		  add edx,1
		  jmp InputHandler.repeat1

; .....................................................
InputHandler.ejec_NumHexadecimal:
		  mov ebx,0

		  pusha
		  push dword [msg_pesos]
		  call HistoryBufferCommand
		  add esp,4
		  popa

InputHandler.ehn_loop1:
		  add edx,1

		  cmp edx,[cinput]
		  jge  InputHandler.ehn_EndInputHandler

		  mov eax,[input_storage+edx]
		  and eax,$0000ff

		  cmp eax,K_SUB
		  je InputHandler.ehn_negativizar

		  cmp eax,K_SPACE
		  je InputHandler.ehn_EndInputHandler

		  cmp eax,CMDLNUMBER
		  jl InputHandler.errorComando

		  ;..............
		  pusha
		  push eax
		  call GetKeyCodeInASCII
		  pop ecx
		  push ecx
		  call HistoryBufferCommand
		  add esp,4
		  popa
		  ; ..............


		  cmp eax,K_A
		  je InputHandler.ehn_Convercion

		  cmp eax,K_B
		  je InputHandler.ehn_Convercion

		  cmp eax,K_C
		  je InputHandler.ehn_Convercion

		  cmp eax,K_D
		  je InputHandler.ehn_Convercion

		  cmp eax,K_E
		  je InputHandler.ehn_Convercion

		  cmp eax,K_F
		  je InputHandler.ehn_Convercion

		  cmp eax,CMDHNUMBER
		  jg InputHandler.errorComando


		  ; hago la conversion a numero decimal
InputHandler.ehn_Convercion:

		  push edx
		  push ebx
		  push eax
		  call GetNumberFromKeyCode
		  pop ecx
		  pop ebx
		  mov eax,16

		  mul ebx
		  mov ebx,eax
		  add ebx,ecx
		  pop edx
		  jmp InputHandler.loop1


InputHandler.ehn_negativizar:
		  ; si se encontro el signo "-" al final, paso el nro a negativo
		  push edx
		  mov eax,0
		  sub eax,ebx
		  mov ebx,eax

		  push dword [msg_neg]
		  call SaveHistory
		  add esp,4


		  pop edx
		  add edx,1

InputHandler.ehn_EndInputHandler:

		  ; se apila el nro decimal en la pila de numeros
		  push ebx
		  call StackDecimalNumber
		  add esp,4

		  push edx

		  Call	GraphicDrawStack

		  push dword [msg_space]
		  call SaveHistory
		  add esp,4

		  push msg_hexnumbercmd
		  call	GraphicPrintMessage
		  add esp,4
		  pop edx

		  cmp edx,[cinput]
		  je InputHandler.salir
		  add edx,1
		  jmp InputHandler.repeat1

;______________________________________________________

InputHandler.exec_num:
		  push edx
		  push msg_numerocmd
		  call	GraphicPrintMessage
		  add esp,4
		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_duplicate:
		  push edx
		  call DupCommand

		  push dword [msg_dupcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_drop:
		  push edx
		  call DropCommand

		  push dword [msg_dropcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_swap:
		  push edx
		  call SwapCommand

		  push dword [msg_swapcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_add:
		  push edx
		  call AddCommand


		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_sub:
		  push edx
		  call SubCommand

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_mult:
		  push edx
		  call MultCommand

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_div:
		  push edx
		  call DivCommand

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________


 ; analisis del "[]" CMD REPEAT
InputHandler.exec_bucle:

		  push edx
		  ; tengo el [ voy a buscar el prox ]

InputHandler.bcl_loop1:
		  add edx,1

		  cmp edx,[cinput]
		  jge InputHandler.bcl_noclosed

		  mov eax,[input_storage+edx]
		  and eax,$0000ff

		  cmp eax,CMDRPTF
		  jne InputHandler.bcl_loop1

		  ;si llego ac�, el bucle esta cerrado correctamente
		  ; me fijo en la pila el tope y en base a eso
		  ; ejecuto
InputHandler.bcl_closer:
		  mov eax,[cnumberstack]
		  cmp eax,0
		  je InputHandler.bcl_finbucle

		  sub eax,1
		  mov ebx,[number_stack+eax*4]
		  cmp ebx,0
		  jle InputHandler.bcl_finbucle

		  sub ebx,1
		  mov [number_stack+eax*4],ebx
		  mov edx,[esp]
		  add edx,2
		  jmp InputHandler.repeat1

 InputHandler.bcl_finbucle:

		  add esp,4
		  push edx

		  Call	GraphicDrawStack
		  push msg_repeatok
		  call	GraphicPrintMessage
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2


 InputHandler.bcl_noclosed:

		  add esp,4
		  jmp InputHandler.errorComando


;______________________________________________________

InputHandler.exec_advance:
		  push edx
		  call AdvanceCommand

		  push dword [msg_advancecmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_left:

		  push edx
		  call LeftCommand

		  push dword [msg_leftcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_right:
		  push edx
		  call RightCommand

		  push dword [msg_rightcmd]
		  call SaveHistory
		  add esp,4


		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_position:

		  push edx
		  call PositionCommand

		  push dword [msg_positioncmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_up:
		  push edx
		  call UpCommand

		  push dword [msg_upcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_down:
		  push edx
		  call DownCommand

		  push dword [msg_downcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_color:
		  push edx
		  call ColorCommand


		  push dword [msg_colorcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_background:

		  push edx
		  call BackgroundCommand


		  push dword [msg_bkgcmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_home:
		  push edx
		  call CenterCommand

		  push dword [msg_homecmd]
		  call SaveHistory
		  add esp,4

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_clear:
		  push edx
		  push msg_clearcmd
		  call	GraphicPrintMessage
		  add esp,4
		  pop edx

		  call CenterCommand
		  call BackgroundCommand

		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_load:
		  push edx

		  call LoadHistory

		  pop edx
		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_save:
		  push edx
		  call SaveHistory2
		  pop edx

		  jmp InputHandler.repeat2

;______________________________________________________

InputHandler.exec_run:
		  push edx
		  push msg_runcmd
		  call	GraphicPrintMessage
		  add esp,4
		  pop edx

		  jmp InputHandler.repeat2

;***********************************************************************************************************

LoadKeycodeToASCIIMapper:
; carga el vector paralelo que mapea los keycodes
; con su correspondiente codigo ascii

		   mov [ascii_vector+2],49
		   mov [ascii_vector+3],50
		   mov [ascii_vector+4],51
		   mov [ascii_vector+5],52
		   mov [ascii_vector+6],53
		   mov [ascii_vector+7],54
		   mov [ascii_vector+8],55
		   mov [ascii_vector+9],56
		   mov [ascii_vector+10],57
		   mov [ascii_vector+11],48
		   mov [ascii_vector+16],113
		   mov [ascii_vector+17],119
		   mov [ascii_vector+18],101
		   mov [ascii_vector+19],114
		   mov [ascii_vector+20],116
		   mov [ascii_vector+21],121
		   mov [ascii_vector+22],117
		   mov [ascii_vector+23],105
		   mov [ascii_vector+24],111
		   mov [ascii_vector+25],112
		   mov [ascii_vector+30],97
		   mov [ascii_vector+31],115
		   mov [ascii_vector+32],100
		   mov [ascii_vector+33],102
		   mov [ascii_vector+34],103
		   mov [ascii_vector+35],104
		   mov [ascii_vector+36],106
		   mov [ascii_vector+37],107
		   mov [ascii_vector+38],108
		   mov [ascii_vector+44],122
		   mov [ascii_vector+45],120
		   mov [ascii_vector+46],99
		   mov [ascii_vector+47],118
		   mov [ascii_vector+48],98
		   mov [ascii_vector+49],110
		   mov [ascii_vector+50],109
		   mov [ascii_vector+K_SPACE],32

		   ret

;***********************************************************************************************************

GetKeyCodeInASCII: ;TODO Nombrar GetAsciiFromKeyCode
; devuelve el codigo ascii correspondiente a un
; key code usuando el vector ascii_vector

; keycode +4

		   mov eax,[esp+4]
		   mov ebx,[ascii_vector+eax]
		   and ebx,$000000ff ;TODO definir ascii_vector en byte en vez de dword
		   mov [esp+4],ebx
		   ret


;***********************************************************************************************************

GetAsciiFromKeyCode: ;TODO Nombrar GetKeyCodeFromAscii
; devuelve el keycode correspondiente a un codigo
; ascii usando el vector ascii_vector

; ascii + 4

		   mov edx,0

GetAsciiFromKeyCode.loop:
		   mov eax,[ascii_vector+edx]
		   and eax,$000000ff
		   add edx,1
		   cmp eax,[esp+4]
		   jne GetAsciiFromKeyCode.loop

		   sub edx,1
		   mov [esp+4],edx
		   ret


;***********************************************************************************************************

GetNumberFromKeyCode:
; convierte un key code a su equivalente numerico

; keycode +4
; resultado en +4

	push dword [esp+4]
	call GetKeyCodeInASCII
	pop eax
	cmp eax,97
	jl p.016_loop
	sub eax,39
p.016_loop:
	sub eax,48
	mov [esp+4],eax
	ret

;***********************************************************************************************************

GetPositionOffsetFromBitmap: ;TODO mover a Graphic Module
; devuelve el offset del primer byte del pixel
; x,y dentro de un bitmap de ancho constante

; parametros
; x	    +4
; y	    +8
; ancho bmp +12
; alto bmp  +16

		mov eax,[esp+16] ;alto

		dec  eax
		sub  eax,[esp+8] ;alto-1-y
		imul eax,[esp+12] ;(alto-1-y)*ancho
		add  eax,[esp+4] ;(alto-1-y)*ancho + x
		imul eax,BPP ;((alto - y) * ancho + x ) * BPP ->  BPP = 3 bytes per pixel = 24 bits
		add  eax,54   ;Saltea los 53 bytes de cabecera.
		mov  [esp+4],eax

		ret

;***********************************************************************************************************

StackDecimalNumber:
; apila un numero decimal en la pila de numero de dibujo

; nro +4

		  mov ebx,[esp+4]
		  mov ecx,[cnumberstack]
		  mov [number_stack+ecx*4],ebx
		  add ecx,1
		  cmp ecx,16
		  jge StackDecimalNumber.pilallena

		  mov [cnumberstack],ecx

		  ret


StackDecimalNumber.pilallena:
		  push msg_full_stack
		  call	GraphicPrintMessage
		  add esp,4

		  ret

;***********************************************************************************************************

LoadCosVector:
; Carga el vector con los valores de cos(x)*1000

	    mov [cos_table+0],1000
	    mov [cos_table+4],999
	    mov [cos_table+8],999
	    mov [cos_table+12],998
	    mov [cos_table+16],997
	    mov [cos_table+20],996
	    mov [cos_table+24],994
	    mov [cos_table+28],992
	    mov [cos_table+32],990
	    mov [cos_table+36],987
	    mov [cos_table+40],984
	    mov [cos_table+44],981
	    mov [cos_table+48],978
	    mov [cos_table+52],974
	    mov [cos_table+56],970
	    mov [cos_table+60],965
	    mov [cos_table+64],961
	    mov [cos_table+68],956
	    mov [cos_table+72],951
	    mov [cos_table+76],945
	    mov [cos_table+80],939
	    mov [cos_table+84],933
	    mov [cos_table+88],927
	    mov [cos_table+92],920
	    mov [cos_table+96],913
	    mov [cos_table+100],906
	    mov [cos_table+104],898
	    mov [cos_table+108],891
	    mov [cos_table+112],882
	    mov [cos_table+116],874
	    mov [cos_table+120],866
	    mov [cos_table+124],857
	    mov [cos_table+128],848
	    mov [cos_table+132],838
	    mov [cos_table+136],829
	    mov [cos_table+140],819
	    mov [cos_table+144],809
	    mov [cos_table+148],798
	    mov [cos_table+152],788
	    mov [cos_table+156],777
	    mov [cos_table+160],766
	    mov [cos_table+164],754
	    mov [cos_table+168],743
	    mov [cos_table+172],731
	    mov [cos_table+176],719
	    mov [cos_table+180],707
	    mov [cos_table+184],694
	    mov [cos_table+188],681
	    mov [cos_table+192],669
	    mov [cos_table+196],656
	    mov [cos_table+200],642
	    mov [cos_table+204],629
	    mov [cos_table+208],615
	    mov [cos_table+212],601
	    mov [cos_table+216],587
	    mov [cos_table+220],573
	    mov [cos_table+224],559
	    mov [cos_table+228],544
	    mov [cos_table+232],529
	    mov [cos_table+236],515
	    mov [cos_table+240],500
	    mov [cos_table+244],484
	    mov [cos_table+248],469
	    mov [cos_table+252],453
	    mov [cos_table+256],438
	    mov [cos_table+260],422
	    mov [cos_table+264],406
	    mov [cos_table+268],390
	    mov [cos_table+272],374
	    mov [cos_table+276],358
	    mov [cos_table+280],342
	    mov [cos_table+284],325
	    mov [cos_table+288],309
	    mov [cos_table+292],292
	    mov [cos_table+296],275
	    mov [cos_table+300],258
	    mov [cos_table+304],241
	    mov [cos_table+308],224
	    mov [cos_table+312],207
	    mov [cos_table+316],190
	    mov [cos_table+320],173
	    mov [cos_table+324],156
	    mov [cos_table+328],139
	    mov [cos_table+332],121
	    mov [cos_table+336],104
	    mov [cos_table+340],87
	    mov [cos_table+344],69
	    mov [cos_table+348],52
	    mov [cos_table+352],34
	    mov [cos_table+356],17
	    mov [cos_table+360],0
	    mov [cos_table+364],-17
	    mov [cos_table+368],-34
	    mov [cos_table+372],-52
	    mov [cos_table+376],-69
	    mov [cos_table+380],-87
	    mov [cos_table+384],-104
	    mov [cos_table+388],-121
	    mov [cos_table+392],-139
	    mov [cos_table+396],-156
	    mov [cos_table+400],-173
	    mov [cos_table+404],-190
	    mov [cos_table+408],-207
	    mov [cos_table+412],-224
	    mov [cos_table+416],-241
	    mov [cos_table+420],-258
	    mov [cos_table+424],-275
	    mov [cos_table+428],-292
	    mov [cos_table+432],-309
	    mov [cos_table+436],-325
	    mov [cos_table+440],-342
	    mov [cos_table+444],-358
	    mov [cos_table+448],-374
	    mov [cos_table+452],-390
	    mov [cos_table+456],-406
	    mov [cos_table+460],-422
	    mov [cos_table+464],-438
	    mov [cos_table+468],-453
	    mov [cos_table+472],-469
	    mov [cos_table+476],-484
	    mov [cos_table+480],-499
	    mov [cos_table+484],-515
	    mov [cos_table+488],-529
	    mov [cos_table+492],-544
	    mov [cos_table+496],-559
	    mov [cos_table+500],-573
	    mov [cos_table+504],-587
	    mov [cos_table+508],-601
	    mov [cos_table+512],-615
	    mov [cos_table+516],-629
	    mov [cos_table+520],-642
	    mov [cos_table+524],-656
	    mov [cos_table+528],-669
	    mov [cos_table+532],-681
	    mov [cos_table+536],-694
	    mov [cos_table+540],-707
	    mov [cos_table+544],-719
	    mov [cos_table+548],-731
	    mov [cos_table+552],-743
	    mov [cos_table+556],-754
	    mov [cos_table+560],-766
	    mov [cos_table+564],-777
	    mov [cos_table+568],-788
	    mov [cos_table+572],-798
	    mov [cos_table+576],-809
	    mov [cos_table+580],-819
	    mov [cos_table+584],-829
	    mov [cos_table+588],-838
	    mov [cos_table+592],-848
	    mov [cos_table+596],-857
	    mov [cos_table+600],-866
	    mov [cos_table+604],-874
	    mov [cos_table+608],-882
	    mov [cos_table+612],-891
	    mov [cos_table+616],-898
	    mov [cos_table+620],-906
	    mov [cos_table+624],-913
	    mov [cos_table+628],-920
	    mov [cos_table+632],-927
	    mov [cos_table+636],-933
	    mov [cos_table+640],-939
	    mov [cos_table+644],-945
	    mov [cos_table+648],-951
	    mov [cos_table+652],-956
	    mov [cos_table+656],-961
	    mov [cos_table+660],-965
	    mov [cos_table+664],-970
	    mov [cos_table+668],-974
	    mov [cos_table+672],-978
	    mov [cos_table+676],-981
	    mov [cos_table+680],-984
	    mov [cos_table+684],-987
	    mov [cos_table+688],-990
	    mov [cos_table+692],-992
	    mov [cos_table+696],-994
	    mov [cos_table+700],-996
	    mov [cos_table+704],-997
	    mov [cos_table+708],-998
	    mov [cos_table+712],-999
	    mov [cos_table+716],-999
	    mov [cos_table+720],-1000
	    mov [cos_table+724],-999
	    mov [cos_table+728],-999
	    mov [cos_table+732],-998
	    mov [cos_table+736],-997
	    mov [cos_table+740],-996
	    mov [cos_table+744],-994
	    mov [cos_table+748],-992
	    mov [cos_table+752],-990
	    mov [cos_table+756],-987
	    mov [cos_table+760],-984
	    mov [cos_table+764],-981
	    mov [cos_table+768],-978
	    mov [cos_table+772],-974
	    mov [cos_table+776],-970
	    mov [cos_table+780],-965
	    mov [cos_table+784],-961
	    mov [cos_table+788],-956
	    mov [cos_table+792],-951
	    mov [cos_table+796],-945
	    mov [cos_table+800],-939
	    mov [cos_table+804],-933
	    mov [cos_table+808],-927
	    mov [cos_table+812],-920
	    mov [cos_table+816],-913
	    mov [cos_table+820],-906
	    mov [cos_table+824],-898
	    mov [cos_table+828],-891
	    mov [cos_table+832],-882
	    mov [cos_table+836],-874
	    mov [cos_table+840],-866
	    mov [cos_table+844],-857
	    mov [cos_table+848],-848
	    mov [cos_table+852],-838
	    mov [cos_table+856],-829
	    mov [cos_table+860],-819
	    mov [cos_table+864],-809
	    mov [cos_table+868],-798
	    mov [cos_table+872],-788
	    mov [cos_table+876],-777
	    mov [cos_table+880],-766
	    mov [cos_table+884],-754
	    mov [cos_table+888],-743
	    mov [cos_table+892],-731
	    mov [cos_table+896],-719
	    mov [cos_table+900],-707
	    mov [cos_table+904],-694
	    mov [cos_table+908],-681
	    mov [cos_table+912],-669
	    mov [cos_table+916],-656
	    mov [cos_table+920],-642
	    mov [cos_table+924],-629
	    mov [cos_table+928],-615
	    mov [cos_table+932],-601
	    mov [cos_table+936],-587
	    mov [cos_table+940],-573
	    mov [cos_table+944],-559
	    mov [cos_table+948],-544
	    mov [cos_table+952],-529
	    mov [cos_table+956],-515
	    mov [cos_table+960],-500
	    mov [cos_table+964],-484
	    mov [cos_table+968],-469
	    mov [cos_table+972],-453
	    mov [cos_table+976],-438
	    mov [cos_table+980],-422
	    mov [cos_table+984],-406
	    mov [cos_table+988],-390
	    mov [cos_table+992],-374
	    mov [cos_table+996],-358
	    mov [cos_table+1000],-342
	    mov [cos_table+1004],-325
	    mov [cos_table+1008],-309
	    mov [cos_table+1012],-292
	    mov [cos_table+1016],-275
	    mov [cos_table+1020],-258
	    mov [cos_table+1024],-241
	    mov [cos_table+1028],-224
	    mov [cos_table+1032],-207
	    mov [cos_table+1036],-190
	    mov [cos_table+1040],-173
	    mov [cos_table+1044],-156
	    mov [cos_table+1048],-139
	    mov [cos_table+1052],-121
	    mov [cos_table+1056],-104
	    mov [cos_table+1060],-87
	    mov [cos_table+1064],-69
	    mov [cos_table+1068],-52
	    mov [cos_table+1072],-34
	    mov [cos_table+1076],-17
	    mov [cos_table+1080],0
	    mov [cos_table+1084],17
	    mov [cos_table+1088],34
	    mov [cos_table+1092],52
	    mov [cos_table+1096],69
	    mov [cos_table+1100],87
	    mov [cos_table+1104],104
	    mov [cos_table+1108],121
	    mov [cos_table+1112],139
	    mov [cos_table+1116],156
	    mov [cos_table+1120],173
	    mov [cos_table+1124],190
	    mov [cos_table+1128],207
	    mov [cos_table+1132],224
	    mov [cos_table+1136],241
	    mov [cos_table+1140],258
	    mov [cos_table+1144],275
	    mov [cos_table+1148],292
	    mov [cos_table+1152],309
	    mov [cos_table+1156],325
	    mov [cos_table+1160],342
	    mov [cos_table+1164],358
	    mov [cos_table+1168],374
	    mov [cos_table+1172],390
	    mov [cos_table+1176],406
	    mov [cos_table+1180],422
	    mov [cos_table+1184],438
	    mov [cos_table+1188],453
	    mov [cos_table+1192],469
	    mov [cos_table+1196],484
	    mov [cos_table+1200],500
	    mov [cos_table+1204],515
	    mov [cos_table+1208],529
	    mov [cos_table+1212],544
	    mov [cos_table+1216],559
	    mov [cos_table+1220],573
	    mov [cos_table+1224],587
	    mov [cos_table+1228],601
	    mov [cos_table+1232],615
	    mov [cos_table+1236],629
	    mov [cos_table+1240],642
	    mov [cos_table+1244],656
	    mov [cos_table+1248],669
	    mov [cos_table+1252],681
	    mov [cos_table+1256],694
	    mov [cos_table+1260],707
	    mov [cos_table+1264],719
	    mov [cos_table+1268],731
	    mov [cos_table+1272],743
	    mov [cos_table+1276],754
	    mov [cos_table+1280],766
	    mov [cos_table+1284],777
	    mov [cos_table+1288],788
	    mov [cos_table+1292],798
	    mov [cos_table+1296],809
	    mov [cos_table+1300],819
	    mov [cos_table+1304],829
	    mov [cos_table+1308],838
	    mov [cos_table+1312],848
	    mov [cos_table+1316],857
	    mov [cos_table+1320],866
	    mov [cos_table+1324],874
	    mov [cos_table+1328],882
	    mov [cos_table+1332],891
	    mov [cos_table+1336],898
	    mov [cos_table+1340],906
	    mov [cos_table+1344],913
	    mov [cos_table+1348],920
	    mov [cos_table+1352],927
	    mov [cos_table+1356],933
	    mov [cos_table+1360],939
	    mov [cos_table+1364],945
	    mov [cos_table+1368],951
	    mov [cos_table+1372],956
	    mov [cos_table+1376],961
	    mov [cos_table+1380],965
	    mov [cos_table+1384],970
	    mov [cos_table+1388],974
	    mov [cos_table+1392],978
	    mov [cos_table+1396],981
	    mov [cos_table+1400],984
	    mov [cos_table+1404],987
	    mov [cos_table+1408],990
	    mov [cos_table+1412],992
	    mov [cos_table+1416],994
	    mov [cos_table+1420],996
	    mov [cos_table+1424],997
	    mov [cos_table+1428],998
	    mov [cos_table+1432],999
	    mov [cos_table+1436],999


	    ret

;***********************************************************************************************************

NormalizeAngle:
; Normaliza un angulo a un valor entre 0 y 359
; angulo +4

	mov ebx,[esp+4]

NormalizeAngle.loop:

	cmp ebx,360
	jl NormalizeAngle.buscaNegativo

	sub ebx,360
	jmp NormalizeAngle.loop


NormalizeAngle.buscaNegativo:
	cmp ebx,0
	jge NormalizeAngle.salir

	add ebx,360
	jmp NormalizeAngle.loop


NormalizeAngle.salir:

	mov [esp+4],ebx
	ret

;***********************************************************************************************************

XDistance:

; distance +4

	   mov eax,[esp+4]
	   mov ecx,[pen_angle]
	   mov ecx,[cos_table+ecx*4]
	   imul ecx

	   mov ecx,1000
	   idiv ecx
	   add eax,[pen_x]

	   mov [esp+4],eax

	   ret

;***********************************************************************************************************

YDistance:
; distance +4



	   mov ecx,[pen_angle]
	   add ecx,90

	   push ecx
	   call NormalizeAngle
	   pop ecx

	   mov eax,[esp+4]
	   mov ecx,[cos_table+ecx*4]
	   imul ecx
	   mov ecx,1000
	   idiv ecx
	   mov ebx,[pen_y]

	   add ebx,eax

	   mov eax,ebx
	   mov [esp+4],eax

	   ret


;***********************************************************************************************************

SaveHistory:
; Guarda en el Historial
; cmd +4

	mov eax,[esp+4]
	mov ecx,[chistorybuffer]

	cmp ecx,100
	jge SaveHistory.salir

	mov [history_buffer+ecx],eax
	add ecx,3
	mov [chistorybuffer],ecx

SaveHistory.salir:

	ret


;***********************************************************************************************************

SaveHistory2:

;	 edx='from ecx=cnt eax="filename" --

	mov edx,history_buffer
	mov ecx,128
	mov eax,historyfile
	call SYSSAVE
	ret

;***********************************************************************************************************

LoadHistory:

		mov eax,0

		mov eax,historyfile
		mov edi,history_buffer
		call SYSLOAD


		mov [SYSKEY],K_SPACE
		call KeyboardEventHandler

		mov eax,0

LoadHistory.loop1:
		mov edx,[history_buffer+eax]
		and edx,$000000ff

		cmp edx,59
		je LoadHistory.salir

		pusha

		push edx
		call GetAsciiFromKeyCode
		pop edx

		mov [SYSKEY],edx
		call KeyboardEventHandler

		popa

		add eax,1
		jmp LoadHistory.loop1


 LoadHistory.salir:

		ret

;***********************************************************************************************************

LoadCharactersFile:
; Lee de disco el archivo de fuente y lo carga en memoria
;TODO Reusar pasando parametros. GraphicDrawInterpreter podria usarlo
		mov eax,img_caracteres
		mov edi,bmp_mem_caracteres
		call SYSLOAD
		ret


;-----------------------------------------------------------------------------------------------------------------------------
