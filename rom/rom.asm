;******************************************************************************
;*
;* Copyright(c) 2021 Bob Fossil. All rights reserved.
;*
;* This program is free software; you can redistribute it and/or modify it
;* under the terms of version 2 of the GNU General Public License as
;* published by the Free Software Foundation.
;*
;* This program is distributed in the hope that it will be useful, but WITHOUT
;* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
;* more details.
;*
;* You should have received a copy of the GNU General Public License along with
;* this program; if not, write to the Free Software Foundation, Inc.,
;* 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
;*
;*
;******************************************************************************/

        include "plugin.asm"
        include "esxdos.asm"

        DEFC    ROM_SIZE=$4000
        DEFC    ROM_BUFFER=$c000

        org     PLUGIN_ORG
        section code

        jr      _plugin_start

_plugin_info:

        defb    "BP"                    ; id
        defb    0                       ; spare
        defb    0                       ; spare
        defb    0                       ; flags
        defb    0                       ; flags2
        defb    ".ROM plugin - velesoft/bob_fossil", $0

_plugin_start:

	; hl is the filename

        xor     a
        ld      (_plugin_file_handle), a

        ld      a, ESXDOS_CURRENT_DRIVE ; *
        ld      b, ESXDOS_MODE_READ
        rst     ESXDOS_SYS_CALL         ; open file for reading
        defb    ESXDOS_SYS_F_OPEN

        jr      nc, _plugin_stat

        ld      bc, _err_file
        ld      a, PLUGIN_ERROR
        ret

_plugin_stat:

        ld      (_plugin_file_handle), a
        ld      hl, _plugin_file_stat
        rst     ESXDOS_SYS_CALL         ; get file information
        defb    ESXDOS_SYS_F_FSTAT

        jr      nc, _plugin_read

        ld      bc, _err_io
        ld      a, PLUGIN_ERROR
        ld      (_plugin_error_ret+1), a
        jp      _plugin_error

_plugin_read:

        ld      a, (_plugin_file_handle)
        ld      bc, (_plugin_file_stat_size)
                                        ; put 16 bit file size into hl
        ld      hl, ROM_BUFFER
        rst     ESXDOS_SYS_CALL         ; read ROM to buffer
        defb    ESXDOS_SYS_F_READ

        jr      nc, _plugin_main

        ld      bc, _err_io
        ld      a, PLUGIN_ERROR
        ld      (_plugin_error_ret+1), a
        jp      _plugin_error

_plugin_main:

        ld      a, $83                  ; Map DivMMC RAM bank 3 to $2000
        out     (MMC_MEMORY_PORT), a

        ld      hl, ROM_BUFFER          ; copy 8k ROM from $c000 to $2000
        ld      de, $2000
        ld      bc, ROM_SIZE/2
        ldir

        ld      a, $40                  ; Map DivMMC RAM bank 0 to $2000 and set MAPRAM
        out     (MMC_MEMORY_PORT), a

        ld      de, $2000               ; copy 8k ROM from $e000 to $2000
        ld      bc, ROM_SIZE/2
        ldir

        rst     0

_plugin_ok_ret:

        ld      a, 0
        ret

_plugin_error:

        push    bc

        ld      a, (_plugin_file_handle)
        rst     ESXDOS_SYS_CALL
        defb    ESXDOS_SYS_F_CLOSE

        pop     bc

_plugin_error_ret:

        ld      a, 0

        ret


_plugin_file_handle:

        defb    0

_plugin_file_stat:

;struct esxdos_stat
;{
;   uint8_t  drive;
;   uint8_t  device;
;   uint8_t  attr;
;   uint32_t date;
;   uint32_t size;
;};

        defb    0                       ; uint8_t  drive;
        defb    0                       ; uint8_t  device;
        defb    0                       ; uint8_t  attr;

_plugin_file_stat_time:

        defw    0                       ; uint32_t date;

_plugin_file_stat_date:

        defw    0                       ; time word (not supported)

_plugin_file_stat_size:

        defw    0                       ; uint32_t size;

_plugin_file_stat_size2:

        defw    0                       ; uint32_t size;

        section rodata
_err_io:

        defb    "IO error!", $0

_err_file:

        defb    "Couldn't open file!", $0
