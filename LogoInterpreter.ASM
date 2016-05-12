format PE GUI 4.0
entry start

include 'WIN32A.inc'
include 'Constants.asm'
include 'SysUtils.asm'
include 'CommandLine.asm'
include 'GraphicUtils.asm'
include 'Utils.asm'

section '.code' code readable executable

start:
	 call INITIALIZE
	 call SYSCLS

	 call LoadKeycodeToASCIIMapper
	 call LoadCosVector

	 call GraphicDrawInterpreter
	 call LoadCharactersFile
	 call GraphicDrawPen
	 call CenterCommand

main:

	 call GraphicDrawCommandsCursor


	 call SYSREDRAW
	 mov [SYSKEY],0
	 call SYSUPDATE

	 cmp [SYSKEY],1
	 je SYSEND
	 cmp [SYSKEY],0
	 je main

	 call KeyboardEventHandler
	 jmp main

	 jmp SYSEND

;====================================================================================================================

section '.idata' import data readable

library kernel,'KERNEL32.DLL', user,'USER32.DLL', gdi,'GDI32.DLL'

import kernel,\
	 GetModuleHandle,'GetModuleHandleA',\
	 CreateFile,'CreateFileA',\
	 ReadFile,'ReadFile',\
	 WriteFile,'WriteFile',\
	 CloseHandle,'CloseHandle',\
	 GetTickCount,'GetTickCount',\
	 ExitProcess,'ExitProcess',\
	 GetLocalTime,'GetLocalTime',\
	 SetCurrentDirectory,'SetCurrentDirectoryA',\
	 FindFirstFile,'FindFirstFileA',\
	 FindNextFile,'FindNextFileA',\
	 FindClose,'FindClose'

import user,\
	 RegisterClass,'RegisterClassA',\
	 CreateWindowEx,'CreateWindowExA',\
	 DestroyWindow,'DestroyWindow',\
	 DefWindowProc,'DefWindowProcA',\
	 GetMessage,'GetMessageA',\
	 PeekMessage,'PeekMessageA',\
	 TranslateMessage,'TranslateMessage',\
	 DispatchMessage,'DispatchMessageA',\
	 LoadCursor,'LoadCursorA',\
	 SetCursor,'SetCursor',\
	 MessageBox,'MessageBoxA',\
	 PostQuitMessage,'PostQuitMessage',\
	 WaitMessage,'WaitMessage'	 ,\
	 ShowWindow,'ShowWindow',\
	 UpdateWindow,'UpdateWindow',\
	 ChangeDisplaySettings,'ChangeDisplaySettingsA',\
	 GetDC,'GetDC',\
	 ReleaseDC,'ReleaseDC',\
	 AdjustWindowRect,'AdjustWindowRect',\
	 ShowCursor,'ShowCursor',\
	 ScreenToClient,'ScreenToClient'

import gdi,\
	SetDIBitsToDevice,'SetDIBitsToDevice'




section '.data' data readable writeable

	hinstance	dd 0
	hwnd		dd 0
	wc		WNDCLASS ;EX?
	msg		MSG
	hDC		dd 0
	bDC		dd 0
	hbitmap 	dd 0
	dwExStyle	dd 0
	dwStyle 	dd 0
	rec		RECT
	bmi		BITMAPINFOHEADER
	SysTime 	SYSTEMTIME
	hdir		dd 0
	afile		dd 0
	cntr		dd 0
	_title		db 'Logo Interpreter',0
	_class		db 'Logo Interpreter',0

	;bitmaps a cargar
	img_background	  db 'CommandLineInterface.bmp',0
	img_caracteres	  db 'Characters.bmp',0
	historyfile	  db 'History.txt',0

	;nro de caracteres en las lineas de texto * cantidad de pixel por caracter
	nComandos dd POSITION_MESSAGES_X
	nPila	  dd POSITION_STACK_X

	;TIMERS
	tcursor        dd 0

	;contadores
	cinput	       dd 0
	cnumberstack   dd 0 ; Cantidad de numero en la pila de dibujo
	chistorybuffer dd 0

	arithmetic_operation dd 0;
	arithmetic_expression	     rd 128

	negcolor dd 0

	;mensajes
	msg_cmdok db		'ok',0
	msg_full_stack db	'full stack',0
	msg_notrecognizedcmd db 'command not recognized',0
	msg_decnumbercmd db	'decimal number inserted',0
	msg_hexnumbercmd db	'hexadecimal number inserted',0
	msg_emptystack db	'empty stack',0
	msg_leasttwo db 	'at least 2 numbers must be inserted in stack',0
	msg_divisionerror db	'error division by zero',0
	msg_repeatok db 	'repeat command executed',0
	msg_numerocmd db	'number ',0
	msg_dupcmd db		'du ',0
	msg_dropcmd db		'dr ',0
	msg_swapcmd db		'sw ',0
	msg_advancecmd db	'ad ',0
	msg_leftcmd db		'le ',0
	msg_rightcmd db 	'ri ',0
	msg_positioncmd db	'po ',0
	msg_upcmd db		'up ',0
	msg_downcmd db		'do ',0
	msg_colorcmd db 	'co ',0
	msg_bkgcmd db		'ba ',0
	msg_homecmd db		'ho ',0
	msg_clearcmd db 	'clear command executed',0
	msg_loadcmd db		'lo ',0
	msg_savecmd db		'sa ',0
	msg_runcmd db		'ru ',0
	msg_space db		'   ',0
	msg_neg db		'-  ',0
	msg_pesos db		'$',0

	;variables del lapiz
	pen_x dd CENTER_POSITION_X
	pen_y dd CENTER_POSITION_Y

	pen_xl1 dd 0
	pen_yl1 dd 0

	pen_xl2 dd 0
	pen_yl2 dd 0

	pen_color dd 0
	pen_angle dd 0
	pen_state dd 0

	error dd 0
	dxx   dd 0
	dyy   dd 0
	x     dd 0
	y     dd 0
	color dd 0

align 4
	SYSXYM	dd 0
	SYSBM	dd 0
	SYSKEY	dd 0
	SYSPAPER dd $0
	Dpila	rd 1024 ; Pila Auxiliar

align 16 ; CUADRO DE VIDEO (FrameBuffer)

	history_buffer rd 256
	;storage de inputs
	input_storage	     rd 128

	;pila de numero s de dibujo (en formato decimal)
	number_stack	rd 128

	;ascii vector
	ascii_vector	rd 128
	cos_table	rd 512

	SYSFRAME	rd XRES*YRES

	;bitmaps en memoria
	bmp_mem_ImgBackground	     rd 1024
	bmp_mem_caracteres	     rd 1024*1024
