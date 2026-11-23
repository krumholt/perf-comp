; native-image java/sumint-reduce-native: RangeIntSpliterator.forEachRemaining and the mapToDouble sink
0000000000490d00 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7>:
  490d00:	sub    rsp,0x38
  490d04:	mov    QWORD PTR [rsp+0x18],rsi
  490d09:	cmp    rsp,QWORD PTR [r15+0x8]
  490d0d:	jbe    490db3 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0xb3>
  490d13:	cmp    rsi,r14
  490d16:	je     490db9 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0xb9>
  490d1c:	mov    eax,DWORD PTR [rdi+0x8]
  490d1f:	mov    ecx,DWORD PTR [rdi+0xc]
  490d22:	mov    DWORD PTR [rsp+0x34],ecx
  490d26:	mov    DWORD PTR [rdi+0x8],ecx
  490d29:	mov    DWORD PTR [rdi+0x10],0x0
  490d30:	cmp    ecx,eax
  490d32:	jg     490d4b <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x4b>
  490d34:	mov    ebx,eax
  490d36:	cmp    DWORD PTR [r15+0x10],0x0
  490d3b:	nop    DWORD PTR [rax+rax*1+0x0]
  490d40:	jle    490dab <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0xab>
  490d46:	add    rsp,0x38
  490d4a:	ret
  490d4b:	mov    rdi,0xfffffffffffffff8
  490d52:	and    rdi,QWORD PTR [rsi]
  490d55:	mov    rdx,QWORD PTR [r14+rdi*1+0x100]
  490d5d:	mov    QWORD PTR [rsp+0x28],rdx
  490d62:	mov    ebx,eax
  490d64:	inc    ebx
  490d66:	mov    rdi,rsi
  490d69:	mov    esi,eax
  490d6b:	mov    rax,rdx
  490d6e:	mov    DWORD PTR [rsp+0x24],ebx
  490d72:	call   rax
  490d74:	nop
  490d75:	jmp    490d93 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x93>
  490d77:	nop    WORD PTR [rax+rax*1+0x0]
  490d80:	mov    ebp,ebx
  490d82:	inc    ebp
  490d84:	mov    rdi,rsi
  490d87:	mov    esi,ebx
  490d89:	mov    rax,rdx
  490d8c:	mov    DWORD PTR [rsp+0x24],ebp
  490d90:	call   rax
  490d92:	nop
  490d93:	mov    ebx,DWORD PTR [rsp+0x24]
  490d97:	mov    rdx,QWORD PTR [rsp+0x28]
  490d9c:	mov    ecx,DWORD PTR [rsp+0x34]
  490da0:	mov    rsi,QWORD PTR [rsp+0x18]
  490da5:	cmp    ecx,ebx
  490da7:	jle    490d36 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x36>
  490da9:	jmp    490d80 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x80>
  490dab:	call   17bd00 <SafepointSlowpath_enterSlowPathSafepointCheck_G1njHmDb633sKfTxTdnmIA>
  490db0:	nop
  490db1:	jmp    490d46 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x46>
  490db3:	call   11a8a0 <StackOverflowCheckImpl_throwNewStackOverflowError_CiGyUiZvwzBgNjjkTo2w7K>
  490db8:	nop
  490db9:	mov    rsi,QWORD PTR [r15+0x28]
  490dbd:	lea    rax,[rsi+0x50]
  490dc1:	movabs rcx,0x395300
  490dcb:	cmp    rax,QWORD PTR [r15+0x20]
  490dcf:	ja     490f15 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x215>
  490dd5:	mov    QWORD PTR [r15+0x28],rax
  490dd9:	mov    QWORD PTR [rsi],rcx
  490ddc:	mov    eax,0x8
  490de1:	jmp    490e0c <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x10c>
  490de3:	data16 data16 nop WORD PTR [rax+rax*1+0x0]
  490dee:	data16 data16 xchg ax,ax
  490df2:	data16 nop WORD PTR [rax+rax*1+0x0]
  490dfc:	data16 data16 xchg ax,ax
  490e00:	mov    QWORD PTR [rsi+rax*1],0x0
  490e08:	lea    rax,[rax+0x8]
  490e0c:	cmp    rax,0x50
  490e10:	jb     490e00 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x100>
  490e12:	movabs rax,0x68ed78
  490e1c:	mov    QWORD PTR [rsi+0x28],rax
  490e20:	test   QWORD PTR [rsi],0x2
  490e27:	jne    490e86 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x186>
  490e29:	movabs rax,0x693d48
  490e33:	mov    QWORD PTR [rsi+0x20],rax
  490e37:	test   QWORD PTR [rsi],0x2
  490e3e:	xchg   ax,ax
  490e40:	jne    490eb2 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x1b2>
  490e46:	mov    rax,rsi
  490e49:	sub    rax,r14
  490e4c:	mov    QWORD PTR [rsi+0x18],rax
  490e50:	test   QWORD PTR [rsi],0x2
  490e57:	jne    490ee5 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x1e5>
  490e5d:	mov    QWORD PTR [rsp+0x10],rdi
  490e62:	mov    rdi,rsi
  490e65:	mov    QWORD PTR [rsp+0x8],rsi
  490e6a:	mov    esi,0x0
  490e6f:	call   2034e0 <Throwable_fillInStackTrace_r1XmDo89qjHSNaXbvF0Ch6>
  490e74:	nop
  490e75:	lea    rsi,[rsp+0x40]
  490e7a:	mov    rdi,QWORD PTR [rsp+0x8]
  490e7f:	nop
  490e80:	call   16a2a0 <ExceptionUnwind_unwindExceptionWithoutCalleeSavedRegisters_D2uDbIIG0NJynRdXlWueWI>
  490e85:	nop
  490e86:	mov    rax,rsi
  490e89:	mov    rcx,rax
  490e8c:	and    rcx,0xfffffffffff80000
  490e93:	lea    rdx,[rcx+0x838]
  490e9a:	sub    rax,rdx
  490e9d:	shr    rax,0x9
  490ea1:	cmp    BYTE PTR [rcx+rax*1+0x38],0x0
  490ea6:	je     490e29 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x129>
  490ea8:	mov    BYTE PTR [rcx+rax*1+0x38],0x0
  490ead:	jmp    490e29 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x129>
  490eb2:	mov    rax,rsi
  490eb5:	mov    rcx,rax
  490eb8:	and    rcx,0xfffffffffff80000
  490ebf:	lea    rdx,[rcx+0x838]
  490ec6:	sub    rax,rdx
  490ec9:	shr    rax,0x9
  490ecd:	cmp    BYTE PTR [rcx+rax*1+0x38],0x0
  490ed2:	je     490e46 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x146>
  490ed8:	mov    BYTE PTR [rcx+rax*1+0x38],0x0
  490edd:	data16 xchg ax,ax
  490ee0:	jmp    490e46 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x146>
  490ee5:	mov    rax,rsi
  490ee8:	mov    rcx,rax
  490eeb:	and    rcx,0xfffffffffff80000
  490ef2:	lea    rdx,[rcx+0x838]
  490ef9:	sub    rax,rdx
  490efc:	shr    rax,0x9
  490f00:	cmp    BYTE PTR [rcx+rax*1+0x38],0x0
  490f05:	je     490e5d <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x15d>
  490f0b:	mov    BYTE PTR [rcx+rax*1+0x38],0x0
  490f10:	jmp    490e5d <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x15d>
  490f15:	mov    QWORD PTR [rsp+0x10],rdi
  490f1a:	mov    rdi,rcx
  490f1d:	data16 xchg ax,ax
  490f20:	call   110020 <GenScavengeAllocationSupport_slowNewInstance_GXbD8DDYXSLZ74ueJwxt7B>
  490f25:	nop
  490f26:	mov    rsi,rax
  490f29:	mov    rdi,QWORD PTR [rsp+0x10]
  490f2e:	jmp    490e12 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7+0x112>

0000000000490c80 <Streams$RangeIntSpliterator_forEachRemaining_qfvQQMUeEABL32Qz0K3GL1>:
  490c80:	sub    rsp,0x8
  490c84:	cmp    rsp,QWORD PTR [r15+0x8]
  490c88:	jbe    490cc8 <Streams$RangeIntSpliterator_forEachRemaining_qfvQQMUeEABL32Qz0K3GL1+0x48>
  490c8a:	cmp    rsi,r14
  490c8d:	je     490cab <Streams$RangeIntSpliterator_forEachRemaining_qfvQQMUeEABL32Qz0K3GL1+0x2b>
  490c8f:	mov    rax,0xfffffffffffffff8
  490c96:	and    rax,QWORD PTR [rsi]
  490c99:	mov    ecx,0xffff
  490c9e:	and    ecx,DWORD PTR [r14+rax*1+0x18]
  490ca3:	lea    eax,[rcx-0x7]
  490ca6:	cmp    eax,0x3
  490ca9:	jae    490cce <Streams$RangeIntSpliterator_forEachRemaining_qfvQQMUeEABL32Qz0K3GL1+0x4e>
  490cab:	call   490d00 <Streams$RangeIntSpliterator_forEachRemaining_HQFTkU5fBy047StryLciG7>
  490cb0:	nop
  490cb1:	cmp    DWORD PTR [r15+0x10],0x0
  490cb6:	jle    490cbd <Streams$RangeIntSpliterator_forEachRemaining_qfvQQMUeEABL32Qz0K3GL1+0x3d>
  490cb8:	add    rsp,0x8
  490cbc:	ret
  490cbd:	data16 xchg ax,ax
  490cc0:	call   17bd00 <SafepointSlowpath_enterSlowPathSafepointCheck_G1njHmDb633sKfTxTdnmIA>
  490cc5:	nop
  490cc6:	jmp    490cb8 <Streams$RangeIntSpliterator_forEachRemaining_qfvQQMUeEABL32Qz0K3GL1+0x38>
  490cc8:	call   11a8a0 <StackOverflowCheckImpl_throwNewStackOverflowError_CiGyUiZvwzBgNjjkTo2w7K>
  490ccd:	nop
  490cce:	movabs rax,0x19ca90
  490cd8:	lea    rax,[r14+rax*1]
  490cdc:	mov    rdi,rsi
  490cdf:	mov    rsi,rax
  490ce2:	call   171fe0 <ImplicitExceptions_throwNewClassCastExceptionWithArgs_a3UIMFZPA75NBVhFdWIuK8>
  490ce7:	nop

