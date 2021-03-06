; Resolution values
XRES equ 800
YRES equ 600

; Screen positions
POSITION_STACK_X equ 780
POSITION_STACK_Y equ 585

CENTER_POSITION_X equ 400
CENTER_POSITION_Y equ 200

POSITION_MESSAGES_X equ 30
POSITION_MESSAGES_Y equ 530
END_POSITION_MESSAGES_X equ XRES-200
END_POSITION_MESSAGES_Y equ POSITION_MESSAGES_Y+12

POSITION_COMMANDS_Y equ 465

; Keys Constants
K_ENTER equ 28
K_BACKSPACE equ 14
K_SPACE equ $39
K_SUB equ 12
K_ADD equ 13
K_MUL equ 26
K_DIV equ 27
K_A equ 30
K_B equ 48
K_C equ 46
K_D equ 32
K_E equ 18
K_F equ 33

OPERATION_SUB equ 1
OPERATION_ADD equ 2
OPERATION_MUL equ 3
OPERATION_DIV equ 4

; Commands
CMDNUMERO  equ $00001631
CMD$NUMERO equ $00000000
CMDDUP equ $00191620
CMDDROP equ $19181320
CMDSWAP equ $191E111F
CMDADVANCE equ $002F201E
CMDLEFT equ $14211226
CMDRIGTH equ $23221713
CMDPOSITION equ $001F1819
CMDUP equ $00001916
CMDDOWN equ $31111820
CMDCOLOR equ $0026182E
CMDBACKGROUND equ $00222530
CMDHOME equ $12321823
CMDCLEAR equ $0013262E
CMDLOAD equ $201E1826
CMDSAVE equ $122F1E1F
CMDRUN equ $00001613
CMDADD equ $0020201E
CMDSUB equ $0030161F
CMDMUL equ $00261632
CMDDIV equ $002F1720
CMDINITREPEAT equ $00000027
CMDENDREPEAT equ $00000028
CMDBYE equ $00121530

CMDLNUMBER equ $02
CMDHNUMBER equ $0B
CMDHEXANUMBER equ $33

; Colors
RED equ $00ff0000
GREEN equ $0000ff00
BLUE equ $000000ff
WHITE equ $ffffffff

;CommandLineInterface bitmap constants
ALTO_BMP_PIXELS equ 200 ;TODO Renombrar a ALTO_PIXELS_BMP_INTERFAZ
ANCHO_BMP_PIXELS equ 800 ;TODO Renombrar a ANCHO_PIXELS_BMP_INTERFAZ
BPP equ 3 ; bytes per pixel supported for bitmaps

;Characters bitmap constants
PIXELS_POR_CARACTER equ 10
ALTO_PIXELS_BMP_CARACTERES equ 16
ANCHO_PIXELS_BMP_CARACTERES equ 1024

;Command Line cursor
CURSOR_POSITION_Y equ POSITION_COMMANDS_Y+10;
CURSOR_BLINK_TIME equ 250;
