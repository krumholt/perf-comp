; Assembly listing for method Program:<Main>$(System.String[]) (Instrumented Tier0)
; Emitting BLENDED_CODE for X64 with AVX - Unix
; Instrumented Tier0 code
; rbp based frame
; fully interruptible

G_M000_IG01:                ;; offset=0x0000
       push     rbp
       sub      rsp, 128
       lea      rbp, [rsp+0x80]
       xor      eax, eax
       mov      qword ptr [rbp-0x78], rax
       vxorps   xmm8, xmm8, xmm8
       vmovdqu  ymmword ptr [rbp-0x70], ymm8
       vmovdqu  ymmword ptr [rbp-0x50], ymm8
       mov      gword ptr [rbp-0x30], rdi
 
G_M000_IG02:                ;; offset=0x0029
       call     [System.Diagnostics.Stopwatch:StartNew():System.Diagnostics.Stopwatch]
       mov      gword ptr [rbp-0x38], rax
       xor      eax, eax
       mov      qword ptr [rbp-0x40], rax
       mov      dword ptr [rbp-0x4C], 1
       mov      dword ptr [rbp-0x80], 0x3E8
       jmp      SHORT G_M000_IG04
 
G_M000_IG03:                ;; offset=0x0049
       mov      rdi, 0x7FC75091C570
       call     CORINFO_HELP_COUNTPROFILE32
       vxorps   xmm0, xmm0, xmm0
       vcvtsi2sd xmm0, xmm0, dword ptr [rbp-0x4C]
       vaddsd   xmm0, xmm0, qword ptr [rbp-0x40]
       vmovsd   qword ptr [rbp-0x40], xmm0
       mov      eax, dword ptr [rbp-0x4C]
       inc      eax
       mov      dword ptr [rbp-0x4C], eax
 
G_M000_IG04:                ;; offset=0x0073
       mov      eax, dword ptr [rbp-0x80]
       dec      eax
       mov      dword ptr [rbp-0x80], eax
       cmp      dword ptr [rbp-0x80], 0
       jg       SHORT G_M000_IG06
 
G_M000_IG05:                ;; offset=0x0081
       lea      rdi, [rbp-0x80]
       mov      esi, 29
       call     CORINFO_HELP_PATCHPOINT
 
G_M000_IG06:                ;; offset=0x008F
       cmp      dword ptr [rbp-0x4C], 0x3B9ACA00
       jle      SHORT G_M000_IG03
       mov      rdi, 0x7FC75091C574
       call     CORINFO_HELP_COUNTPROFILE32
       mov      rdi, gword ptr [rbp-0x38]
       cmp      dword ptr [rdi], edi
       call     [System.Diagnostics.Stopwatch:get_ElapsedMilliseconds():long:this]
       mov      qword ptr [rbp-0x48], rax
       lea      rdi, [rbp-0x78]
       mov      esi, 21
       mov      edx, 2
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:.ctor(int,int):this]
       lea      rdi, [rbp-0x78]
       mov      rsi, 0x7FC7CAC00720
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendLiteral(System.String):this]
       lea      rdi, [rbp-0x78]
       vmovsd   xmm0, qword ptr [rbp-0x40]
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendFormatted[double](double):this]
       lea      rdi, [rbp-0x78]
       mov      rsi, 0x7FC7CAC00740
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendLiteral(System.String):this]
       lea      rdi, [rbp-0x78]
       mov      rsi, qword ptr [rbp-0x48]
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendFormatted[long](long):this]
       lea      rdi, [rbp-0x78]
       mov      rsi, 0x7FC7CAC00770
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendLiteral(System.String):this]
       lea      rdi, [rbp-0x78]
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:ToStringAndClear():System.String:this]
       mov      rdi, rax
       call     [System.Console:WriteLine(System.String)]
       nop      
 
G_M000_IG07:                ;; offset=0x0138
       add      rsp, 128
       pop      rbp
       ret      
 
; Total bytes of code 321

; Assembly listing for method Program:<Main>$(System.String[]) (Tier1-OSR)
; Emitting BLENDED_CODE for X64 with AVX - Unix
; Tier1-OSR code
; OSR variant for entry point 0x1d
; optimized code
; optimized using Dynamic PGO
; rbp based frame
; fully interruptible
; with Dynamic PGO: fgCalledCount is 1.680672
; 28 inlinees with PGO data; 37 single block inlinees; 6 inlinees without PGO data

G_M000_IG01:                ;; offset=0x0000
       mov      rax, qword ptr [rbp]
       push     rax
       sub      rsp, 80
       mov      qword ptr [rsp+0xD8], r15
       mov      qword ptr [rsp+0xD0], r14
       mov      qword ptr [rsp+0xC8], r13
       mov      qword ptr [rsp+0xC0], rbx
       vzeroupper 
       lea      rbp, [rsp+0x50]
       vxorps   xmm8, xmm8, xmm8
       vmovdqa  xmmword ptr [rbp-0x40], xmm8
       xor      eax, eax
       mov      qword ptr [rbp-0x30], rax
       mov      rbx, bword ptr [rbp+0x58]
       vmovsd   xmm0, qword ptr [rbp+0x50]
       mov      eax, dword ptr [rbp+0x44]
 
G_M000_IG02:                ;; offset=0x004D
       cmp      eax, 0x3B9ACA00
       jg       SHORT G_M000_IG08
       align    [0 bytes for IG03]
 
G_M000_IG03:                ;; offset=0x0054
       vxorps   xmm1, xmm1, xmm1
       vcvtsi2sd xmm1, xmm1, eax
       vaddsd   xmm0, xmm0, xmm1
       vmovsd   qword ptr [rbp+0x50], xmm0
       inc      eax
       cmp      eax, 0x3B9ACA00
       jle      SHORT G_M000_IG07
 
G_M000_IG04:                ;; offset=0x006E
       mov      r15, qword ptr [rbx+0x08]
       mov      bword ptr [rbp+0x58], rbx
       cmp      byte  ptr [rbx+0x18], 0
       je       SHORT G_M000_IG09
 
G_M000_IG05:                ;; offset=0x007C
       mov      rax, 0x7FC7CB0E8660
 
G_M000_IG06:                ;; offset=0x0086
       call     rax ; Interop+Sys:GetTimestamp():ulong
       mov      rbx, bword ptr [rbp+0x58]
       sub      rax, qword ptr [rbx+0x10]
       add      r15, rax
       cmp      dword ptr [(reloc 0x7fc7cefab680)], 0
       je       SHORT G_M000_IG09
       jmp      G_M000_IG44
 
G_M000_IG07:                ;; offset=0x00A1
       vmovsd   xmm0, qword ptr [rbp+0x50]
       jmp      SHORT G_M000_IG03
 
G_M000_IG08:                ;; offset=0x00A8
       vmovsd   qword ptr [rbp+0x50], xmm0
       jmp      SHORT G_M000_IG04
 
G_M000_IG09:                ;; offset=0x00AF
       vxorps   xmm1, xmm1, xmm1
       vcvtsi2sd xmm1, xmm1, r15
       vmovsd   qword ptr [rbp-0x48], xmm1
       test     byte  ptr [(reloc 0x7fc75091a358)], 1
       je       G_M000_IG45
 
G_M000_IG10:                ;; offset=0x00CA
       vmulsd   xmm1, xmm1, qword ptr [(reloc 0x7fc74f8cb048)]
       vmovddup xmm2, xmm1
       vmovddup xmm3, xmm1
       vmovddup xmm1, xmm1
       vcmppd   xmm2, xmm3, xmm2, 0
       vandpd   xmm1, xmm2, xmm1
       vcmppd   xmm2, xmm1, xmmword ptr [reloc @RWD00], 13
       vcvttsd2si rax, xmm1
       vmovd    xmm1, rax
       vpbroadcastq xmm1, xmm1
       vpblendvb xmm1, xmm1, xmmword ptr [reloc @RWD16], xmm2
       vmovd    rdx, xmm1
       mov      rdi, 0x346DC5D63886594B
       mov      rax, rdi
       imul     rdx:rax, rdx
       mov      rbx, rdx
       shr      rbx, 63
       sar      rdx, 11
       add      rbx, rdx
       xor      rdi, rdi
       mov      gword ptr [rbp+0x18], rdi
       test     byte  ptr [(reloc 0x7fc75091fb10)], 1
       je       G_M000_IG46
 
G_M000_IG11:                ;; offset=0x013F
       mov      rdi, 0x7F8738000180
       mov      rdi, gword ptr [rdi]
       mov      esi, 256
       cmp      dword ptr [rdi], edi
       call     [System.Buffers.SharedArrayPool`1[ushort]:Rent(int):ushort[]:this]
       mov      gword ptr [rbp+0x20], rax
       test     rax, rax
       je       G_M000_IG47
       lea      r14, bword ptr [rax+0x10]
       mov      r13d, dword ptr [rax+0x08]
 
G_M000_IG12:                ;; offset=0x016E
       mov      bword ptr [rbp+0x30], r14
       mov      dword ptr [rbp+0x38], r13d
       xor      edi, edi
       mov      dword ptr [rbp+0x28], edi
       mov      byte  ptr [rbp+0x2C], 0
       mov      edi, dword ptr [rbp+0x28]
       cmp      edi, dword ptr [rbp+0x38]
       ja       G_M000_IG61
       mov      rsi, bword ptr [rbp+0x30]
       mov      eax, edi
       lea      rsi, bword ptr [rsi+2*rax]
       mov      eax, dword ptr [rbp+0x38]
       sub      eax, edi
       cmp      eax, 5
       jb       G_M000_IG34
 
G_M000_IG13:                ;; offset=0x01A3
       mov      rdi, 0x7FC7CAC0072C
       mov      rax, qword ptr [rdi]
       mov      rcx, qword ptr [rdi+0x02]
       mov      qword ptr [rsi], rax
       mov      qword ptr [rsi+0x02], rcx
       mov      edi, dword ptr [rbp+0x28]
       add      edi, 5
       mov      dword ptr [rbp+0x28], edi
 
G_M000_IG14:                ;; offset=0x01C4
       vmovsd   xmm0, qword ptr [rbp+0x50]
       vmovsd   qword ptr [rbp-0x28], xmm0
       cmp      byte  ptr [rbp+0x2C], 0
       jne      G_M000_IG49
 
G_M000_IG15:                ;; offset=0x01D8
       mov      eax, dword ptr [rbp+0x28]
       cmp      eax, dword ptr [rbp+0x38]
       ja       G_M000_IG61
       mov      rcx, bword ptr [rbp+0x30]
       mov      edx, eax
       lea      r15, bword ptr [rcx+2*rdx]
       mov      r14d, dword ptr [rbp+0x38]
       sub      r14d, eax
       xor      r13, r13
       mov      rdi, gword ptr [rbp+0x18]
       test     rdi, rdi
       jne      G_M000_IG35
 
G_M000_IG16:                ;; offset=0x0205
       call     [System.Globalization.NumberFormatInfo:get_CurrentInfo():System.Globalization.NumberFormatInfo]
 
G_M000_IG17:                ;; offset=0x020B
       mov      rcx, r15
       mov      r8d, r14d
       mov      rdi, r13
       xor      esi, esi
       lea      r9, [rbp-0x30]
       vmovsd   xmm0, qword ptr [rbp-0x28]
       mov      rdx, rax
       call     [System.Number:TryFormatFloat[double,ushort](double,System.ReadOnlySpan`1[ushort],System.Globalization.NumberFormatInfo,System.Span`1[ushort],byref):ubyte]
       test     eax, eax
       je       G_M000_IG48
       mov      edi, dword ptr [rbp+0x28]
       add      edi, dword ptr [rbp-0x30]
       mov      dword ptr [rbp+0x28], edi
 
G_M000_IG18:                ;; offset=0x0239
       mov      edi, dword ptr [rbp+0x28]
       cmp      edi, dword ptr [rbp+0x38]
       ja       G_M000_IG61
       mov      rsi, bword ptr [rbp+0x30]
       mov      eax, edi
       lea      rsi, bword ptr [rsi+2*rax]
       mov      eax, dword ptr [rbp+0x38]
       sub      eax, edi
       cmp      eax, 13
       jb       G_M000_IG36
 
G_M000_IG19:                ;; offset=0x025D
       mov      rdi, 0x7FC7CAC0074C
       vmovdqu  xmm0, xmmword ptr [rdi]
       vmovdqu  xmm1, xmmword ptr [rdi+0x0A]
       vmovdqu  xmmword ptr [rsi], xmm0
       vmovdqu  xmmword ptr [rsi+0x0A], xmm1
       mov      edi, dword ptr [rbp+0x28]
       add      edi, 13
       mov      dword ptr [rbp+0x28], edi
 
G_M000_IG20:                ;; offset=0x0282
       mov      r15, rbx
       cmp      byte  ptr [rbp+0x2C], 0
       jne      G_M000_IG60
 
G_M000_IG21:                ;; offset=0x028F
       mov      edi, dword ptr [rbp+0x28]
       cmp      edi, dword ptr [rbp+0x38]
       ja       G_M000_IG61
 
G_M000_IG22:                ;; offset=0x029B
       mov      rsi, bword ptr [rbp+0x30]
       mov      eax, edi
       lea      rsi, bword ptr [rsi+2*rax]
       mov      eax, dword ptr [rbp+0x38]
       sub      eax, edi
       mov      r14, rsi
       mov      r13d, eax
       mov      rdi, gword ptr [rbp+0x18]
       test     r15, r15
       jl       G_M000_IG54
       mov      rdi, r15
       or       rdi, 1
       lzcnt    rdi, rdi
       xor      edi, 63
       movsxd   rdi, edi
       mov      rcx, 0x7FC74F99FEE0
       movzx    rdi, byte  ptr [rdi+rcx]
       mov      ecx, edi
       mov      rdx, 0x7FC74F9A69F8
       cmp      r15, qword ptr [rdx+8*rcx]
       setb     cl
       movzx    rcx, cl
       sub      edi, ecx
       cmp      edi, eax
       jg       G_M000_IG52
       mov      dword ptr [rbp-0x38], edi
       mov      bword ptr [rbp-0x40], rsi
       movsxd   rdi, edi
       lea      r14, [rsi+2*rdi]
       mov      rbx, r15
       cmp      rbx, 10
       jae      G_M000_IG38
 
G_M000_IG23:                ;; offset=0x0319
       add      r14, -2
       add      ebx, 48
       mov      word  ptr [r14], bx
 
G_M000_IG24:                ;; offset=0x0324
       xor      edi, edi
       mov      bword ptr [rbp-0x40], rdi
       mov      ebx, 1
 
G_M000_IG25:                ;; offset=0x032F
       xor      rdi, rdi
       mov      bword ptr [rbp-0x40], rdi
 
G_M000_IG26:                ;; offset=0x0335
       test     ebx, ebx
       je       G_M000_IG59
 
G_M000_IG27:                ;; offset=0x033D
       mov      edi, dword ptr [rbp+0x28]
       add      edi, dword ptr [rbp-0x38]
       mov      dword ptr [rbp+0x28], edi
 
G_M000_IG28:                ;; offset=0x0346
       mov      edi, dword ptr [rbp+0x28]
       cmp      edi, dword ptr [rbp+0x38]
       ja       G_M000_IG61
       mov      rsi, bword ptr [rbp+0x30]
       mov      eax, edi
       lea      rsi, bword ptr [rsi+2*rax]
       mov      eax, dword ptr [rbp+0x38]
       sub      eax, edi
       cmp      eax, 3
       jb       G_M000_IG43
 
G_M000_IG29:                ;; offset=0x036A
       mov      rdi, 0x7FC7CAC0077C
       mov      eax, dword ptr [rdi]
       mov      ecx, dword ptr [rdi+0x02]
       mov      dword ptr [rsi], eax
       mov      dword ptr [rsi+0x02], ecx
       mov      edi, dword ptr [rbp+0x28]
       add      edi, 3
       mov      dword ptr [rbp+0x28], edi
 
G_M000_IG30:                ;; offset=0x0387
       mov      esi, dword ptr [rbp+0x28]
       cmp      esi, dword ptr [rbp+0x38]
       ja       G_M000_IG61
       mov      rdi, bword ptr [rbp+0x30]
       call     System.String:.ctor(System.ReadOnlySpan`1[ushort]):this
       mov      r15, rax
       mov      rsi, gword ptr [rbp+0x20]
       vxorps   ymm0, ymm0, ymm0
       vmovdqu  ymmword ptr [rbp+0x18], ymm0
       vmovdqu  xmmword ptr [rbp+0x30], xmm0
       test     rsi, rsi
       je       SHORT G_M000_IG32
 
G_M000_IG31:                ;; offset=0x03B6
       mov      rdi, 0x7F8738000180
       mov      rdi, gword ptr [rdi]
       xor      edx, edx
       cmp      dword ptr [rdi], edi
       call     [System.Buffers.SharedArrayPool`1[ushort]:Return(ushort[],ubyte):this]
 
G_M000_IG32:                ;; offset=0x03CD
       mov      rdi, r15
       call     [System.Console:WriteLine(System.String)]
       nop      
 
G_M000_IG33:                ;; offset=0x03D7
       add      rsp, 192
       pop      rbx
       pop      r13
       pop      r14
       pop      r15
       pop      rbp
       ret      
 
G_M000_IG34:                ;; offset=0x03E7
       lea      rdi, [rbp+0x18]
       mov      rsi, 0x7FC7CAC00720
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:GrowThenCopyString(System.String):this]
       jmp      G_M000_IG14
 
G_M000_IG35:                ;; offset=0x0400
       call     [System.Globalization.NumberFormatInfo:<GetInstance>g__GetProviderNonNull|58_0(System.IFormatProvider):System.Globalization.NumberFormatInfo]
       jmp      G_M000_IG17
 
G_M000_IG36:                ;; offset=0x040B
       lea      rdi, [rbp+0x18]
       mov      rsi, 0x7FC7CAC00740
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:GrowThenCopyString(System.String):this]
       jmp      G_M000_IG20
 
G_M000_IG37:                ;; offset=0x0424
       mov      rdi, 0x7F87380001A8
       mov      rdi, gword ptr [rdi]
       cmp      byte  ptr [rdi], dil
       shl      r13d, 2
       mov      esi, r13d
       mov      edi, dword ptr [rdi+rsi+0x10]
       mov      dword ptr [r14], edi
 
G_M000_IG38:                ;; offset=0x0442
       cmp      rbx, 100
       jae      SHORT G_M000_IG42
 
G_M000_IG39:                ;; offset=0x0448
       cmp      rbx, 10
       jb       G_M000_IG23
 
G_M000_IG40:                ;; offset=0x0452
       add      r14, -4
       test     byte  ptr [(reloc 0x7fc7509b6fc8)], 1
       je       G_M000_IG50
 
G_M000_IG41:                ;; offset=0x0463
       mov      rax, 0x7F87380001A8
       mov      rax, gword ptr [rax]
       cmp      byte  ptr [rax], al
       lea      edx, [4*rbx]
       mov      eax, dword ptr [rax+rdx+0x10]
       mov      dword ptr [r14], eax
       jmp      G_M000_IG24
 
G_M000_IG42:                ;; offset=0x0485
       add      r14, -4
       mov      rdx, 0x28F5C28F5C28F5C3
       mov      rax, rbx
       shr      rax, 2
       mul      rdx:rax, rdx
       shr      rdx, 2
       imul     rdi, rdx, 100
       mov      r13, rbx
       sub      r13, rdi
       mov      rbx, rdx
       test     byte  ptr [(reloc 0x7fc7509b6fc8)], 1
       jne      G_M000_IG37
       jmp      G_M000_IG51
 
G_M000_IG43:                ;; offset=0x04C0
       lea      rdi, [rbp+0x18]
       mov      rsi, 0x7FC7CAC00770
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:GrowThenCopyString(System.String):this]
       jmp      G_M000_IG30
 
G_M000_IG44:                ;; offset=0x04D9
       call     CORINFO_HELP_POLL_GC
       jmp      G_M000_IG09
 
G_M000_IG45:                ;; offset=0x04E3
       mov      rdi, 0x7FC75091A2C8
       call     CORINFO_HELP_GET_NONGCSTATIC_BASE
       vmovsd   xmm1, qword ptr [rbp-0x48]
       jmp      G_M000_IG10
 
G_M000_IG46:                ;; offset=0x04FC
       mov      rdi, 0x7FC75091FA38
       call     CORINFO_HELP_GET_GCSTATIC_BASE
       jmp      G_M000_IG11
 
G_M000_IG47:                ;; offset=0x0510
       xor      r14, r14
       xor      r13d, r13d
       jmp      G_M000_IG12
 
G_M000_IG48:                ;; offset=0x051B
       lea      rdi, [rbp+0x18]
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:Grow():this]
       jmp      G_M000_IG15
 
G_M000_IG49:                ;; offset=0x052A
       lea      rdi, [rbp+0x18]
       vmovsd   xmm0, qword ptr [rbp+0x50]
       xor      rsi, rsi
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendCustomFormatter[double](double,System.String):this]
       jmp      G_M000_IG18
 
G_M000_IG50:                ;; offset=0x0540
       mov      rdi, 0x7FC7509B6CA0
       call     CORINFO_HELP_GET_GCSTATIC_BASE
       jmp      G_M000_IG41
 
G_M000_IG51:                ;; offset=0x0554
       mov      rdi, 0x7FC7509B6CA0
       call     CORINFO_HELP_GET_GCSTATIC_BASE
       jmp      G_M000_IG37
 
G_M000_IG52:                ;; offset=0x0568
       xor      eax, eax
       mov      dword ptr [rbp-0x38], eax
 
G_M000_IG53:                ;; offset=0x056D
       xor      ebx, ebx
       jmp      G_M000_IG25
 
G_M000_IG54:                ;; offset=0x0574
       test     rdi, rdi
       jne      SHORT G_M000_IG55
       call     [System.Globalization.NumberFormatInfo:get_CurrentInfo():System.Globalization.NumberFormatInfo]
       jmp      SHORT G_M000_IG56
 
G_M000_IG55:                ;; offset=0x0581
       call     [System.Globalization.NumberFormatInfo:<GetInstance>g__GetProviderNonNull|58_0(System.IFormatProvider):System.Globalization.NumberFormatInfo]
 
G_M000_IG56:                ;; offset=0x0587
       mov      r8, gword ptr [rax+0x28]
       test     r8, r8
       jne      SHORT G_M000_IG57
       xor      rdx, rdx
       xor      ecx, ecx
       jmp      SHORT G_M000_IG58
 
G_M000_IG57:                ;; offset=0x0596
       lea      rdx, bword ptr [r8+0x0C]
       mov      ecx, dword ptr [r8+0x08]
 
G_M000_IG58:                ;; offset=0x059E
       lea      r8, [rbp-0x38]
       mov      qword ptr [rsp], r8
       mov      r8, r14
       mov      r9d, r13d
       mov      rdi, r15
       mov      esi, -1
       call     [System.Number:TryNegativeInt64ToDecStr[ushort](long,int,System.ReadOnlySpan`1[ushort],System.Span`1[ushort],byref):ubyte]
       mov      ebx, eax
       jmp      G_M000_IG26
 
G_M000_IG59:                ;; offset=0x05C1
       lea      rdi, [rbp+0x18]
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:Grow():this]
       jmp      G_M000_IG21
 
G_M000_IG60:                ;; offset=0x05D0
       lea      rdi, [rbp+0x18]
       mov      rsi, rbx
       xor      rdx, rdx
       call     [System.Runtime.CompilerServices.DefaultInterpolatedStringHandler:AppendCustomFormatter[long](long,System.String):this]
       jmp      G_M000_IG28
 
G_M000_IG61:                ;; offset=0x05E4
       call     [System.ThrowHelper:ThrowArgumentOutOfRangeException()]
       int3     
 
RWD00  	dq	43E0000000000000h, 43E0000000000000h
RWD16  	dq	7FFFFFFFFFFFFFFFh, 7FFFFFFFFFFFFFFFh

; Total bytes of code 1515

