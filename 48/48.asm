        ;
        ; Lock banking memory register
        ;
        org     0x2000
start:
        ld      bc, 0x7ffd
        ld      a, 0x30                 ; ROM1 + Lock register access
        out     (c), a

        ld      hl, message
nextChar:
        ld      a, (hl)
        or      a
        jr      z, exit
        rst     0x10
        inc     hl
        jr      nextChar

exit:
        xor     a                       ; Clear carry
        ret

message:
        db      "Memory banking disabled.", 0
