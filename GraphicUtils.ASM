GraphicDrawPixel:
; pinta el pixel x,y del syframe con un color
; x +4
; y +8
; color +12
		   cmp dword [negcolor],1
		   je p.008_neg

		   push dword [esp+8]
		   push dword [esp+8]
		   call GetFirstPixelPositionFromSysFrame
		   pop eax
		   add esp,4

		   mov ebx,[esp+12]
		   mov [SYSFRAME+eax],ebx
		   ret

	p.008_neg:
		   push dword [esp+8]
		   push dword [esp+8]
		   call GraphicDrawNoColorPixel
		   add esp,8
		   ret


;***********************************************************************************************************

GraphicDrawNoColorPixel: ;TODO Nombrar GraphicNegateColorPixel
; Niega el color del pixel dado para la posicion x,y.
; x +4
; y +8

	       push dword [esp+8]
	       push dword [esp+8]
	       call GetFirstPixelPositionFromSysFrame
	       pop eax
	       add esp,4

	       mov ebx,[SYSFRAME+eax]
	       xor ebx,$ffffffff
	       mov [SYSFRAME+eax],ebx
	       ret



;***********************************************************************************************************

GraphicDrawPen:
; Muestra pincel en la pantalla.

	       ;TODO Borrar este metodo y llamar directamente a GraphicsDrawCursorLine
	       call GraphicsDrawCursorLine
	       ret


;***********************************************************************************************************

GraphicsDrawCursorLine:

		mov ebx,1
		mov [negcolor],1


		mov ecx,-195

		push ecx

GraphicsDrawCursorLine.loop1:
		mov eax,30

		push dword [pen_angle]
		mov ebx,[pen_angle]

		add ebx,ecx

		push ebx
		call NormalizeAngle
		pop ebx

		mov [pen_angle],ebx

		push eax

		push eax
		call XDistance
		pop eax

		pop ebx
		push eax

		push ebx
		call YDistance
		pop ebx

		pop eax

		mov ecx,[esp+4]
		cmp ecx,150
		jg GraphicsDrawCursorLine.siguiente

		mov [pen_xl1],eax
		mov [pen_yl1],ebx

GraphicsDrawCursorLine.siguiente:
		mov [pen_xl2],eax
		mov [pen_yl2],ebx


		push -1
		push ebx
		push eax
		push [pen_y]
		push [pen_x]
		call GraphicDrawLine


		pop ebx
		mov [pen_angle],ebx


		pop ecx
		add ecx,30
		cmp ecx,180
		jle GraphicsDrawCursorLine.loop1

		push -1
		push [pen_yl2]
		push [pen_xl2]
		push [pen_yl1]
		push [pen_xl1]
		call GraphicDrawLine


		mov ebx,0
		mov [negcolor],0

		ret

;***********************************************************************************************************

GraphicDrawInterpreter:
; dibuja en la la posicion (0,400) el fondo de la
; seccion de informaci�n

		mov eax,img_background
		mov edi,bmp_mem_ImgBackground
		call SYSLOAD ;load .bmp file into bmp_mem_ImgBackground

		mov eax, YRES;
		sub eax, ALTO_BMP_PIXELS;

		push ALTO_BMP_PIXELS
		push ANCHO_BMP_PIXELS
		push ALTO_BMP_PIXELS
		push ANCHO_BMP_PIXELS
		push eax
		push 0
		push 0
		push 0
		push bmp_mem_ImgBackground
		call GraphicDrawBitmap
		add esp,36

		ret

;***********************************************************************************************************

GraphicDrawBitmap:
; Dibuja un bitmap desde su pixel x,y hasta un
; offeset vertical y otro horizontal
; en la posicion x,y del SYSFRAME

; parametros
; dirbmp	+4
; start xbmp	+8
; start ybmp	+12
; start xfrm	+16
; start yfrm	+20
; offsetx	   +24
; offsety	   +28
; anchobmp	+32 TODO: Leer ancho y alto desde la cabecera del bitmap
; altobmp	+36

	       mov edx,0 ;controla offsety

GraphicDrawBitmap.cicloEx:
	       mov ecx,0 ;controla offsetx

GraphicDrawBitmap.cicloInt:

	       ;BitMap position
	       mov eax,[esp+12] ;ybmp
	       mov ebx,[esp+8] ;xbmp
	       add eax,edx
	       add ebx,ecx


	       push dword [esp+36] ;altobmp
	       push dword [esp+36] ;anchobmp
	       push eax
	       push ebx
	       call GetPositionOffsetFromBitmap
	       pop ebx
	       add esp,12

	       push ebx ;bitmap position

	       ;SysFrame position
	       mov eax,[esp+24] ;yfrm
	       mov ebx,[esp+20] ;xfrm
	       add eax,edx
	       add ebx,ecx

	       push ecx

	       push eax
	       push ebx
	       call GetFirstPixelPositionFromSysFrame
	       pop eax
	       add esp,4

	       pop ecx

	       pop ebx

	       mov edi,[esp+4] ;dirbmp
	       mov ebx,[edi+ebx]

	       mov [SYSFRAME+eax],ebx


	       add ecx,1
	       cmp ecx,[esp+24] ;offsetx

	       jl GraphicDrawBitmap.cicloInt

	       add edx,1
	       cmp edx,[esp+28] ;offsety
	       jl GraphicDrawBitmap.cicloEx

	       ret


;***********************************************************************************************************

GraphicCleanStack:
;Crea un cuadrado negro en pantalla para borrar y "limpiar" el sector de la pila en pantalla. NO afecta la pila en memoria

		mov edx,416

GraphicCleanStack.loop1:
		mov ecx,646

GraphicCleanStack.loop2:
		push $0000000
		push edx
		push ecx
		call GraphicDrawPixel
		pop ecx
		pop edx
		add esp,4

		add ecx,1
		cmp ecx,800  ;Limite Max x a borrar
		jl GraphicCleanStack.loop2

		add edx,1
		cmp edx,(YRES-5)    ; Limite Y a borrar (mantiene la linea del borde)
		jl GraphicCleanStack.loop1

		ret


;***********************************************************************************************************

GraphicDrawStack:
; borra y re-dibuja toda la pila

		   call GraphicCleanStack

		   mov eax,[cnumberstack]
		   cmp eax,0
		   je GraphicDrawStack.exit

		   push dword POSITION_STACK_Y
		   mov ecx,0

GraphicDrawStack.loop1:
		   mov eax,[number_stack+ecx*4]
		   push ecx
		   push eax

		   ; si es negativo lo paso a positivo para imprimirlo.
		   cmp eax,0
		   jge GraphicDrawStack.loop2

		   mov ebx,-1
		   imul ebx


GraphicDrawStack.loop2:
		   mov ebx,10
		   CDQ
		   div ebx

		   push eax

		   add edx,48
		   push edx
		   call GetAsciiFromKeyCode
		   pop edx


		   mov eax,edx
		   mov ebx,10
		   mul ebx
		   mov ebx,[esp+12]
		   push ALTO_PIXELS_BMP_CARACTERES
		   push ANCHO_PIXELS_BMP_CARACTERES
		   push 9
		   push PIXELS_POR_CARACTER
		   push ebx
		   push [nPila]
		   push 0
		   push eax
		   push bmp_mem_caracteres
		   call GraphicDrawBitmap
		   add esp,36

		   mov eax,[nPila]
		   sub eax,11
		   mov [nPila],eax

		   pop eax
		   cmp eax,0
		   jg GraphicDrawStack.loop2

		   pop eax
		   cmp eax,0
		   jge GraphicDrawStack.keepGoing

		   ; si era negativo imprimo el signo "-"
		   mov eax,K_SUB
		   mov ebx,10
		   mul ebx
		   mov ebx,[esp+4]

		   push ALTO_PIXELS_BMP_CARACTERES
		   push ANCHO_PIXELS_BMP_CARACTERES
		   push 9
		   push PIXELS_POR_CARACTER
		   push ebx
		   push [nPila]
		   push 0
		   push eax
		   push bmp_mem_caracteres
		   call GraphicDrawBitmap
		   add esp,36

		   mov eax,[nPila]
		   sub eax,11
		   mov [nPila],eax

GraphicDrawStack.keepGoing:
		   mov ebx,[esp+4]
		   sub ebx,12
		   mov [esp+4],ebx
		   mov [nPila],POSITION_STACK_X

		   pop ecx
		   add ecx,1
		   cmp ecx,[cnumberstack]
		   jl GraphicDrawStack.loop1

		   add esp,4

GraphicDrawStack.exit:
		   ret



;***********************************************************************************************************
GraphicDrawCharacter:
;dado un nro de tecla, imprime en pantalla el caracter correspondiente
;se utiliza para escribir en la linea de comandos

		mov eax,[SYSKEY]
		mov ebx,10
		mul ebx

		push ALTO_PIXELS_BMP_CARACTERES
		push ANCHO_PIXELS_BMP_CARACTERES
		push ALTO_PIXELS_BMP_CARACTERES
		push PIXELS_POR_CARACTER
		push POSITION_COMMANDS_Y
		push [nComandos]
		push 0
		push eax
		push bmp_mem_caracteres
		call GraphicDrawBitmap
		add esp,36

		mov eax,[nComandos]
		add eax,11
		mov [nComandos],eax

		ret


;***********************************************************************************************************

GraphicPrintMessage:
; imprime el mensaje pasado por parametro en la zona de mensajes

; Parametros:
; puntero al mensaje +4

		   call GraphicCleanMessagesArea

		   mov edx,0
		   mov ecx,POSITION_MESSAGES_X

GraphicPrintMessage.loop1:
		   mov ebx,[esp+4]
		   add ebx,edx

		   mov eax,[ebx]
		   and eax,$000000ff ;TODO Usar byte en vez de dword

		   cmp eax,0 ;Fin de cadena
		   je GraphicPrintMessage.salir

		   push edx

		   push eax
		   call GetAsciiFromKeyCode ;TODO No mapear el archivo de caracteres (bmp_mem_caracteres) por Keycode, buscar otra representacion
		   pop eax

		   cmp eax,K_SPACE
		   jne GraphicPrintMessage.imprimir

		   mov eax,0 ;Primera posicion del archivo bmp_mem_caracteres

GraphicPrintMessage.imprimir:
		   mov ebx,10
		   mul ebx

		   push ecx

		   push ALTO_PIXELS_BMP_CARACTERES
		   push ANCHO_PIXELS_BMP_CARACTERES
		   push ALTO_PIXELS_BMP_CARACTERES
		   push PIXELS_POR_CARACTER
		   push POSITION_MESSAGES_Y
		   push ecx
		   push 0
		   push eax
		   push bmp_mem_caracteres
		   call GraphicDrawBitmap
		   add esp,36

		   pop ecx
		   add ecx,PIXELS_POR_CARACTER+1


		   pop edx
		   add edx,1
		   jmp GraphicPrintMessage.loop1

GraphicPrintMessage.salir:
		   ret




;***********************************************************************************************************


GraphicSysFrameAdjust:
; Pasa pixel de canvas a su correspondiente dentro del SYSFRAME.
; x +4
; y +8
; xresu +4
; yresu +8
	      mov eax,CENTER_POSITION_X
	      mov ebx,[esp+4]
	      add eax,ebx
	      mov [esp+4],eax

	      mov eax,CENTER_POSITION_Y
	      mov ebx,[esp+8]
	      sub eax,ebx
	      mov [esp+8],eax

	      ret



;***********************************************************************************************************

GraphicDrawCommandsCursor:
; dibuja el cursor de la linea de comandos

		   mov eax,[tcursor]
		   add eax,1
		   mov [tcursor],eax
		   cmp eax,CURSOR_BLINK_TIME
		   je GraphicDrawCommandsCursor.redibujar

		   ret

GraphicDrawCommandsCursor.redibujar:
		   mov [tcursor],0

		   push CURSOR_POSITION_Y
		   push [nComandos]
		   call GetFirstPixelPositionFromSysFrame
		   pop eax
		   add esp,4

		   mov edx,[SYSFRAME+eax]
		   xor edx,$ffffff

		   mov ecx,[nComandos]

GraphicDrawCommandsCursor.repeat:
		   push ecx

		   push edx
		   push CURSOR_POSITION_Y
		   push ecx
		   call GraphicDrawPixel
		   add esp,12

		   pop ecx

		   add ecx,1
		   mov ebx,[nComandos]
		   add ebx,10
		   cmp ecx,ebx
		   jl GraphicDrawCommandsCursor.repeat

		   ret


;***********************************************************************************************************


GraphicCleanMessagesArea:
; borra los mensajes mostrados actualmente en pantalla

	mov edx,POSITION_MESSAGES_Y

GraphicCleanMessagesArea.repeat1:

	mov ecx,POSITION_MESSAGES_X

GraphicCleanMessagesArea.repeat2:

	push 0
	push edx
	push ecx
	call GraphicDrawPixel
	pop ecx
	pop edx
	add esp,4

	add ecx,1
	cmp ecx,END_POSITION_MESSAGES_X;
	jl GraphicCleanMessagesArea.repeat2

	add edx,1
	cmp edx,END_POSITION_MESSAGES_Y;
	jl GraphicCleanMessagesArea.repeat1

	ret

;***********************************************************************************************************


GraphicDrawLine:
;   Dibuja la linea que une los puntos pasados como parametros.
;   sp+4 - x1
;   sp+8 - y1
;   sp+12- x2
;   sp+16- y2
;   sp+20- 32-bit ARGB color

	pusha
	add esp, 00000020h
	pop ebp ; return point
	pop eax ; x1
	pop ebx ; y1
	pop esi ; x2
	pop edi ; y2


	cmp eax,esi
	jne GraphicDrawLine.guarda

	cmp ebx,edi
	jne GraphicDrawLine.guarda


	; si el destino=origen entonces pinto el pixel nada mas
	pop [color]
	pusha
	push [color] ; color
	push ebx ;y
	push eax ;x
	call GraphicDrawPixel
	add esp,12
	popa
	sub esp, 00000038h
	jmp exit_line

;***********************************************************************************************************

GraphicDrawLine.guarda:

	pop [color] ; color
	sub esp, 00000038h ; 8 registes + 5 function parametres + return point = 8*4+5*4+4=56=38h bytes
	mov [error], 00000000h
	mov ecx, eax
	sub ecx, esi ; ecx = x1-x2
	mov edx, ecx ; save ecx in edx
	neg ecx ; invert number sign
	cmovl ecx, edx ; if ecx<edx then place edx in ecx
	mov [dxx], ecx ; save |x1-x2| in [dxx]
	mov ecx, ebx
	sub ecx, edi ; ecx = y1-y2
	mov edx, ecx ; save ecx in edx
	neg ecx ; invert number sign
	cmovl ecx, edx ; if ecx<edx then place edx in ecx
	mov [dyy], ecx ; save |y1-y2| in [dyy]
	cmp [dxx], ecx ; |x1-x2|?|y1-y2|
	jge h_line ; if |x1-x2|>=|y1-y2|
	jmp v_line ; if |y1-y2|>|x1-x2|
	h_line: ; begin paint
	cmp eax, esi
	jg swap_h; if x1>x2 then interchange  x and y coordinates
	jmp start_paint_h

swap_h: ; x=y y=x
	xchg eax, esi
	xchg ebx, edi

start_paint_h:
	mov ecx, [dxx] ; ecx=|x1-x2|
	mov [y], ebx ; y=y0
	mov [x], eax ; x=x0
    ; start pixel
	pusha
	push [color] ; color
	push [y] ;y
	push [x] ;x
	call GraphicDrawPixel
	add esp,12
	popa

loop_paint_h:
	inc [x]
	pusha
	push [color] ; color
	push [y] ;y
	push [x] ;x
	call GraphicDrawPixel
	add esp,12
	popa
	mov edx, [dyy]
	add edx, [error] ; error=error+dyy
	mov [error], edx
	imul edx, 00000002h ; edx=error*2
	cmp edx, [dxx] ; if [error]*2>=[dxx]
	jge inc_y
	jmp next_step_h

inc_y:
	cmp edi,ebx
	jl dech_y

	inc [y]
	jmp p.037_uSigH

dech_y:
	dec [y]

p.037_uSigH:
	mov edx, [error]
	sub edx, [dxx]
	mov [error], edx ; [error]=[error]-[dxx]
	next_step_h:
	loop loop_paint_h ; print next point
	jmp exit_line

v_line: ; begin paint
	cmp ebx, edi
	jg swap_v; if y1>y2 then interchange  x and y coordinates
	jmp start_paint_v

swap_v: ; x=y y=x
	xchg eax, esi
	xchg ebx, edi

start_paint_v:
	mov ecx, [dyy] ; ecx=|y1-y2|
	mov [y], ebx ; y=y0
	mov [x], eax ; x=x0
    ; start pixel
	pusha
	push [color] ; color
	push [y] ;y
	push [x] ;x
	call GraphicDrawPixel
	add esp,12
	popa

loop_paint_v:
	inc [y]
	pusha
	push [color] ; color
	push [y] ;y
	push [x] ;x
	call GraphicDrawPixel
	add esp,12
	popa
	mov edx, [dxx]
	add edx, [error] ; error=error+dxx
	mov [error], edx
	imul edx, 00000002h ; edx=error*2
	cmp edx, [dyy] ; if [error]*2>=[dxx]
	jge inc_x
	jmp next_step_v

inc_x:

	cmp esi,eax
	jl decv_x

	inc [x]
	jmp p.037_uSigV

decv_x:
	dec [x]

p.037_uSigV:
	mov edx, [error]
	sub edx, [dyy]
	mov [error], edx ; [error]=[error]-[dxx]

next_step_v:
	loop loop_paint_v ; print next point

exit_line:
	popa
	retn 14h