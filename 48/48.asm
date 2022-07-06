        ;
        ; Lock banking memory register
        ;
        org     0x2000
start:
        push    af
        push    bc
        ld      bc, 0x7ffd
        ld      a, 0x30                 ; ROM1 + Lock banks
        out     (c), a
        pop     bc
        pop     af
        ret
