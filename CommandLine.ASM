;**************************************************************************************
DupCommand:
;DUP
; duplica el tope de la pila de dibujo.

		mov ecx,[cnumberstack]
		cmp ecx,0
		je DupCommand.emptyStack

		sub ecx,1
		mov eax,[number_stack+ecx*4]
		shl eax,1
		mov [number_stack+ecx*4],eax

		call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

 DupCommand.emptyStack:
		push msg_emptystack
		call  GraphicPrintMessage
		add esp,4
		ret


;**************************************************************************************
AddCommand:
;ADD
; suma los dos primeros numeros de la pila

		mov ecx,[cnumberstack]
		cmp ecx,2
		jl AddCommand.emptyStack

		sub ecx,1
		mov ebx,[number_stack+ecx*4] ;Tope de la pila
		sub ecx,1
		mov eax,[number_stack+ecx*4] ;Segundo de la pila

		add eax,ebx
		mov [number_stack+ecx*4],eax

		add ecx,1
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

AddCommand.emptyStack:
		push msg_leasttwo
		call  GraphicPrintMessage
		add esp,4
		ret


;**************************************************************************************
DropCommand:
;DROP
; quita el tope de la pila

		mov ecx,[cnumberstack]
		cmp ecx,0
		je DropCommand.emptyStack

		sub ecx,1
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

DropCommand.emptyStack:
		push msg_emptystack
		call  GraphicPrintMessage
		add esp,4
		ret


;****************************************************************************************
SwapCommand:
;SWAP
; intercambia el tope y el segundo de la pila

		mov ecx,[cnumberstack]
		cmp ecx,2
		jl SwapCommand.emptyStack

		sub ecx,1
		mov eax,[number_stack+ecx*4]
		sub ecx,1
		mov ebx,[number_stack+ecx*4]

		mov [number_stack+ecx*4],eax
		add ecx,1
		mov [number_stack+ecx*4],ebx

		Call  GraphicDrawStack
		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

SwapCommand.emptyStack:
		push msg_leasttwo
		call  GraphicPrintMessage
		add esp,4
		ret

;**************************************************************************************

MultCommand:
;MUL
; multiplica los ultimos dos numeros de la pila
; desapilandolos y apilando el resultados

		mov ecx,[cnumberstack]
		cmp ecx,2
		jl MultCommand.emptyStack

		sub ecx,1
		mov ebx,[number_stack+ecx*4] ;Tope de la pila
		sub ecx,1
		mov eax,[number_stack+ecx*4] ;Segundo de la pila

		imul ebx
		mov [number_stack+ecx*4],eax
		add ecx,1
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		Call  GraphicDrawStack
		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

MultCommand.emptyStack:
		push msg_leasttwo
		call  GraphicPrintMessage
		add esp,4
		ret



;**************************************************************************************

PositionCommand:
;POS
; Ubica lapiz en X,Y tomando los primeros dos valores de la pila.

		mov ecx,[cnumberstack]
		cmp ecx,2
		jl PositionCommand.pilaVacia

		push ecx
		call GraphicDrawPen ;borro el pincel de donde estaba antes de moverlo
		pop ecx

		sub ecx,1
		mov ebx,[number_stack+ecx*4]
		sub ecx,1
		mov eax,[number_stack+ecx*4]

		add ecx,1
		mov [number_stack+ecx*4],0
		add ecx,1
		mov [number_stack+ecx*4],0
		sub ecx,2
		mov [cnumberstack],ecx


		push ebx
		push eax
		call GraphicSysFrameAdjust
		pop eax
		pop ebx

		cmp dword [pen_state],0
		je PositionCommand.noDibuja

		push [pen_color]
		push ebx
		push eax
		push [pen_y]
		push [pen_x]
		call GraphicDrawLine

 PositionCommand.noDibuja:
		mov [pen_x],eax
		mov [pen_y],ebx

		call GraphicDrawPen

		Call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

 PositionCommand.pilaVacia:
		push msg_leasttwo
		call  GraphicPrintMessage
		add esp,4
		ret
;**************************************************************************************

BackgroundCommand:
;BKG
; Cambia el color del fondo de la pantalla.

		mov ecx,[cnumberstack]
		cmp ecx,0
		je PositionCommand.pilaVacia

		sub ecx,1
		mov eax,[number_stack+ecx*4]
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		lea edi,[SYSFRAME]
		mov ecx,800*400
		rep stosd

		call GraphicDrawPen

		call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

BackgroundCommand.pilaVacia:
		push msg_emptystack
		call  GraphicPrintMessage
		add esp,4
		ret

;**************************************************************************************

DivCommand:
;DIV
; divide dos numeros.

		mov ecx,[cnumberstack]
		cmp ecx,2
		jl DivCommand.emptyStack

		;Leer los 2 numeros
		sub ecx,1
		mov ebx,[number_stack+ecx*4] ;Tope de la pila
		sub ecx,1
		mov eax,[number_stack+ecx*4] ;Segundo de la pila

		cmp ebx,0
		je  DivCommand.errorDivision

		idiv ebx

		mov [number_stack+ecx*4],eax
		add ecx,1
		mov [number_stack+ecx*4],0

		mov [cnumberstack],ecx

		call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

DivCommand.emptyStack:
		push msg_leasttwo
		call  GraphicPrintMessage
		add esp,4
		ret

DivCommand.errorDivision:
		add ecx,2

		push msg_divisionerror
		call GraphicPrintMessage
		add esp,4
		ret

;**************************************************************************************

CenterCommand:
; Posiciona en centro de pantalla y apunta el lapiz hacia el norte.

		call GraphicDrawPen

		mov [pen_x],CENTER_POSITION_X
		mov [pen_y],CENTER_POSITION_Y
		mov [pen_angle],90
		call GraphicDrawPen

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

;**************************************************************************************

UpCommand:
;UP
; Levanta el lapiz
		mov [pen_state],0
		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

;**************************************************************************************

RightCommand:
;RIGH
; Rota lapiz a la izquierda la cantidad de grados que indica el valor de la pila.


       mov ecx,[cnumberstack]
       cmp ecx,0
       je RightCommand.pilaVacia

       push ecx
       call GraphicDrawPen
       pop ecx

       mov ebx,[pen_angle]

       sub ecx,1
       sub ebx,[number_stack+ecx*4]

       mov [number_stack+ecx*4],0
       mov [cnumberstack],ecx

       push ebx
       call NormalizeAngle
       pop ebx

       mov [pen_angle],ebx

       call  GraphicDrawStack

       push msg_cmdok
       call  GraphicPrintMessage
       add esp,4

       call GraphicDrawPen

       ret

 RightCommand.pilaVacia:

       push msg_emptystack
       call  GraphicPrintMessage
       add esp,4
       ret

;**************************************************************************************

DownCommand:
;DOWN
; Baja el lapiz

		mov [pen_state],1
		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4

		ret


;**************************************************************************************

ColorCommand:
;COL
; Levanta el lapiz y cambia el color en el que este dibuja.

		mov ecx,[cnumberstack]
		cmp ecx,0
		je ColorCommand.pilaVacia

		sub ecx,1
		mov eax,[number_stack+ecx*4]
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		mov [pen_color],eax

		Call  GraphicDrawStack
		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4
		ret

 ColorCommand.pilaVacia:
		push msg_emptystack
		call  GraphicPrintMessage
		add esp,4
		ret

		call  GraphicPrintMessage
		add esp,4
		ret

;**************************************************************************************

AdvanceCommand:
;ADV
; Mueve el lapiz en la direccion que apunta


		mov ecx,[cnumberstack]
		cmp ecx,0
		je AdvanceCommand.pilaVacia

		push ecx
		call GraphicDrawPen ;Antes de mover el picel, borro donde estaba.
		pop ecx

		sub ecx,1
		mov eax,[number_stack+ecx*4]
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		push eax

		push eax
		call XDistance
		pop eax
		;TODO Check eax > 0

		pop ebx
		push eax

		push ebx
		call YDistance
		pop ebx
		;TODO Check ebx > 0

		pop eax

		cmp dword [pen_state],0
		je AdvanceCommand.noDibuja


		push [pen_color]
		push ebx
		push eax
		push [pen_y]
		push [pen_x]
		call GraphicDrawLine

  AdvanceCommand.noDibuja: mov [pen_x],eax
		mov [pen_y],ebx

		call GraphicDrawPen

		Call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4

		ret

 AdvanceCommand.pilaVacia:
		push msg_emptystack
		call  GraphicPrintMessage
		add esp,4

		ret



;**************************************************************************************


HistoryBufferCommand:

	mov eax,[esp+4]
	mov ecx,[chistorybuffer]

	cmp ecx,100
	jge HistoryBufferCommand.exit

	mov [history_buffer+ecx],eax
	add ecx,1
	mov [chistorybuffer],ecx
	ret

HistoryBufferCommand.exit:
	ret

;**************************************************************************************

LeftCommand:
;LEFT
; Rota lapiz a la izquierda la cantidad de grados que indica el valor de la pila.

       mov ecx,[cnumberstack]
       cmp ecx,0
       je LeftCommand.pilaVacia

       push ecx
       call GraphicDrawPen
       pop ecx


       mov ebx,[pen_angle]

       sub ecx,1
       add ebx,[number_stack+ecx*4]

       mov [number_stack+ecx*4],0
       mov [cnumberstack],ecx

       push ebx
       call NormalizeAngle
       pop ebx

       mov [pen_angle],ebx


       call  GraphicDrawStack

       push msg_cmdok
       call  GraphicPrintMessage
       add esp,4

       call GraphicDrawPen

       ret

 LeftCommand.pilaVacia:

       push msg_emptystack
       call  GraphicPrintMessage
       add esp,4
       ret

 ;**************************************************************************************

SubCommand:
;SUB
; resta los dos primeros numeros de la pila
; desapilandolos y apila el resultado

		mov ecx,[cnumberstack]
		cmp ecx,2
		jl SubCommand.emptyStack

		sub ecx,1
		mov ebx,[number_stack+ecx*4] ;Tope de la pila
		sub ecx,1
		mov eax,[number_stack+ecx*4] ;Segundo de la pila

		sub eax,ebx
		mov [number_stack+ecx*4],eax

		add ecx,1
		mov [number_stack+ecx*4],0
		mov [cnumberstack],ecx

		call  GraphicDrawStack

		push msg_cmdok
		call  GraphicPrintMessage
		add esp,4

		ret

 SubCommand.emptyStack:
		push msg_leasttwo
		call  GraphicPrintMessage
		add esp,4
		ret



;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
