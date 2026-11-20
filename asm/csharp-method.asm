; Assembly listing for method Program:<<Main>$>g__Sum|0_0(int):double (Instrumented Tier0)
; Emitting BLENDED_CODE for X64 with AVX - Unix
; Instrumented Tier0 code
; rbp based frame
; fully interruptible

G_M000_IG01:                ;; offset=0x0000
       push     rbp
       sub      rsp, 80
       lea      rbp, [rsp+0x50]
       xor      eax, eax
       mov      qword ptr [rbp-0x38], rax
       mov      dword ptr [rbp-0x3C], eax
       mov      dword ptr [rbp-0x2C], edi
 
G_M000_IG02:                ;; offset=0x0016
       xor      eax, eax
       mov      qword ptr [rbp-0x38], rax
       mov      dword ptr [rbp-0x3C], 1
       mov      dword ptr [rbp-0x48], 0x3E8
       jmp      SHORT G_M000_IG04
 
G_M000_IG03:                ;; offset=0x002C
       mov      rdi, 0x7FAC3B35E890
       call     CORINFO_HELP_COUNTPROFILE32
       vxorps   xmm0, xmm0, xmm0
       vcvtsi2sd xmm0, xmm0, dword ptr [rbp-0x3C]
       vaddsd   xmm0, xmm0, qword ptr [rbp-0x38]
       vmovsd   qword ptr [rbp-0x38], xmm0
       mov      eax, dword ptr [rbp-0x3C]
       inc      eax
       mov      dword ptr [rbp-0x3C], eax
 
G_M000_IG04:                ;; offset=0x0056
       mov      eax, dword ptr [rbp-0x48]
       dec      eax
       mov      dword ptr [rbp-0x48], eax
       cmp      dword ptr [rbp-0x48], 0
       jg       SHORT G_M000_IG06
 
G_M000_IG05:                ;; offset=0x0064
       lea      rdi, [rbp-0x48]
       mov      esi, 23
       call     CORINFO_HELP_PATCHPOINT
 
G_M000_IG06:                ;; offset=0x0072
       mov      eax, dword ptr [rbp-0x3C]
       cmp      eax, dword ptr [rbp-0x2C]
       jle      SHORT G_M000_IG03
       mov      rdi, 0x7FAC3B35E894
       call     CORINFO_HELP_COUNTPROFILE32
       vmovsd   xmm0, qword ptr [rbp-0x38]
 
G_M000_IG07:                ;; offset=0x008E
       add      rsp, 80
       pop      rbp
       ret      
 
; Total bytes of code 148

; Assembly listing for method Program:<<Main>$>g__Sum|0_0(int):double (Tier1-OSR)
; Emitting BLENDED_CODE for X64 with AVX - Unix
; Tier1-OSR code
; OSR variant for entry point 0x17
; optimized code
; optimized using Dynamic PGO
; rbp based frame
; fully interruptible
; with Dynamic PGO: fgCalledCount is 1.680672

G_M000_IG01:                ;; offset=0x0000
       mov      rax, qword ptr [rbp]
       push     rax
       mov      rbp, rsp
       mov      edi, dword ptr [rbp+0x34]
       vmovsd   xmm0, qword ptr [rbp+0x28]
       mov      eax, dword ptr [rbp+0x24]
 
G_M000_IG02:                ;; offset=0x0013
       cmp      eax, edi
       jg       SHORT G_M000_IG04
       align    [9 bytes for IG03]
 
G_M000_IG03:                ;; offset=0x0020
       vxorps   xmm1, xmm1, xmm1
       vcvtsi2sd xmm1, xmm1, eax
       vaddsd   xmm0, xmm0, xmm1
       inc      eax
       cmp      eax, edi
       jle      SHORT G_M000_IG03
 
G_M000_IG04:                ;; offset=0x0032
       add      rsp, 96
       pop      rbp
       ret      
 
; Total bytes of code 56

