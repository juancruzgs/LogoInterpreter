INITIALIZE:
	invoke	GetModuleHandle,0
	mov	[hinstance],eax
	;invoke LoadIcon,0,IDI_APPLICATION
	;mov	[wc.hIcon],eax
	mov	[wc.style],0
	mov	[wc.lpfnWndProc],WindowProc
	mov	[wc.cbClsExtra],0
	mov	[wc.cbWndExtra],0
	mov	eax,[hinstance]
	mov	[wc.hInstance],eax
	mov	[wc.hbrBackground],0
	mov	dword [wc.lpszMenuName],0
	mov	dword [wc.lpszClassName],_class
	invoke	RegisterClass,wc
	mov [dwExStyle],WS_EX_APPWINDOW
	mov [dwStyle],WS_VISIBLE+WS_CAPTION+WS_SYSMENU
	invoke ShowCursor,0
	xor eax,eax
	mov [rec.left],eax
	mov [rec.top],eax
	mov [rec.right],XRES
	mov [rec.bottom],YRES
	invoke AdjustWindowRect,rec,[dwStyle],0
	mov eax,[rec.left]
	sub [rec.right],eax
	mov eax,[rec.top]
	sub [rec.bottom],eax
	xor eax,eax
	mov [rec.left],eax
	mov [rec.top],eax
	invoke	CreateWindowEx,[dwExStyle],_class,_title,[dwStyle],0,0,[rec.right],[rec.bottom],0,0,[hinstance],0
	mov	[hwnd],eax
	invoke GetDC,[hwnd]
	mov [hDC],eax
	mov [bmi.biSize],sizeof.BITMAPINFOHEADER
	mov [bmi.biWidth],XRES
	mov [bmi.biHeight],-YRES
	mov [bmi.biPlanes],1
	mov [bmi.biBitCount],32
	mov [bmi.biCompression],BI_RGB
	invoke ShowWindow,[hwnd],SW_NORMAL
	invoke UpdateWindow,[hwnd]
	
	ret
	


; ===============================================
align 16
SYSUPDATE: ; ( -- )
	push eax ebx edx ecx
	invoke	PeekMessage,msg,0,0,0,PM_NOREMOVE
	or	eax,eax
	jz	.noEvent
	invoke	GetMessage,msg,0,0,0
	or	eax,eax
	jz	.endApp
	invoke	TranslateMessage,msg
	invoke	DispatchMessage,msg
.noEvent:
	pop ecx edx ebx eax
	ret
.endApp:
	pop ecx edx ebx eax
;===============================================
align 16
SYSEND: ; ( -- )
	invoke ReleaseDC,[hwnd],[hDC]
	invoke DestroyWindow,[hwnd]
	invoke ExitProcess,0
	ret

;===============================================
align 16
SYSREDRAW: ; ( -- )
	pusha
	invoke SetDIBitsToDevice,[hDC],0,0,XRES,YRES,0,0,0,YRES,SYSFRAME,bmi,0
	popa
	ret

;===============================================
align 16
SYSCLS: 	; ( -- )
	pusha
	mov eax,[SYSPAPER]
	lea edi,[SYSFRAME]
	mov ecx,XRES*YRES
	rep stosd
	popa
	ret

;===============================================
SYSMSEC: ;  ( -- msec )
	lea esi,[esi-4]
	mov [esi], eax
	invoke GetTickCount
	ret

;===============================================
SYSTIME: ;  ( -- s m h )
	lea esi,[esi-12]
	mov [esi+8],eax
	invoke GetLocalTime,SysTime
	movzx eax,word [SysTime.wHour]
	mov [esi+4],eax
	movzx eax,word [SysTime.wMinute]
	mov [esi],eax
	movzx eax,word [SysTime.wSecond]
	ret

;===============================================
SYSDATE: ;  ( -- y m d )
	lea esi,[esi-12]
	mov [esi+8],eax
	invoke GetLocalTime,SysTime
	movzx eax,word [SysTime.wYear]
	mov [esi+4],eax
	movzx eax,word [SysTime.wMonth]
	mov [esi],eax
	movzx eax,word [SysTime.wDay]
	ret


;===============================================
SYSLOAD: ;  edi='from eax="filename"
	invoke CreateFile,eax,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,0
	mov [hdir],eax
	or eax,eax
	jz .end
	invoke ReadFile,[hdir],edi,$3fffff,cntr,0 ; hasta 16MB
	invoke CloseHandle,[hdir]
.end:
	ret

;===============================================
SYSSAVE: ; edx='from ecx=cnt eax="filename" -- 
	push edx ecx
	invoke CreateFile,eax,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_FLAG_SEQUENTIAL_SCAN,0
	mov [hdir],eax
	pop ecx edx
	or eax,eax
	jz .saveend
	invoke WriteFile,[hdir],edx,ecx,cntr,0
	cmp [cntr],ecx
	je .saveend
	or eax,eax
	jz .saveend
	invoke CloseHandle,[hdir]
.saveend:
	ret

;--------------------------------------
proc WindowProc hwnd,wmsg,wparam,lparam
	mov	eax,[wmsg]
	cmp	eax,WM_MOUSEMOVE
	je	wmmousemove
	cmp	eax,WM_LBUTTONUP
	je	wmmouseev
	cmp	eax,WM_MBUTTONUP
	je	wmmouseev
	cmp	eax,WM_RBUTTONUP
	je	wmmouseev
	cmp	eax,WM_LBUTTONDOWN
	je	wmmouseev
	cmp	eax,WM_MBUTTONDOWN
	je	wmmouseev
	cmp	eax,WM_RBUTTONDOWN
	je	wmmouseev
	cmp	eax,WM_KEYUP
	je	wmkeyup
	cmp	eax,WM_KEYDOWN
	je	wmkeydown
	cmp	eax,WM_CLOSE
	je	close
	cmp	eax,WM_DESTROY
	je	close
  defwindowproc:
	invoke	DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
	ret
  wmmousemove:
	mov eax,[lparam]
	mov [SYSXYM],eax
	xor eax,eax
	ret
  wmmouseev:
	mov eax,[wparam]
	mov [SYSBM],eax
	xor eax,eax
	ret
  wmkeyup:
	mov eax,[lparam]
	shr eax,16
	and eax,$7f
	or eax,$80
	mov [SYSKEY],eax
	xor eax,eax
	ret
  wmkeydown:			; cmp [wparam],VK_ESCAPE ; je wmdestroy
	mov eax,[lparam]
	shr eax,16
	and eax,$7f
	mov [SYSKEY],eax
	xor eax,eax
	ret
  close:
	mov eax,1
	ret
endp
