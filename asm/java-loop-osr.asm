; C2 OSR compilation of Variants.loop (Variants loop)
   0:	e8 9b 01 5f 16       	call   0x165f01a0
   5:	66 66 66 0f 1f 84 00 	data16 data16 nop WORD PTR [rax+rax*1+0x0]
   c:	00 00 00 00 
  10:	89 84 24 00 c0 fe ff 	mov    DWORD PTR [rsp-0x14000],eax
  17:	55                   	push   rbp
  18:	48 83 ec 20          	sub    rsp,0x20
  1c:	41 81 7f 20 01 00 00 	cmp    DWORD PTR [r15+0x20],0x1
  23:	00 
  24:	0f 85 7a 00 00 00    	jne    0xa4
  2a:	8b 1e                	mov    ebx,DWORD PTR [rsi]
  2c:	44 8b 6e 18          	mov    r13d,DWORD PTR [rsi+0x18]
  30:	c5 fb 10 46 08       	vmovsd xmm0,QWORD PTR [rsi+0x8]
  35:	c4 e1 f9 7e c5       	vmovq  rbp,xmm0
  3a:	48 8b fe             	mov    rdi,rsi
  3d:	49 ba 40 89 87 e6 41 	movabs r10,0x7f41e6878940
  44:	7f 00 00 
  47:	41 ff d2             	call   r10
  4a:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  51:	00 
  52:	41 3b dd             	cmp    ebx,r13d
  55:	7f 32                	jg     0x89
  57:	4d 8b 57 30          	mov    r10,QWORD PTR [r15+0x30]
  5b:	eb 0c                	jmp    0x69
  5d:	66 66 90             	data16 xchg ax,ax
  60:	4d 8b 57 30          	mov    r10,QWORD PTR [r15+0x30]
  64:	c4 e1 f9 7e c5       	vmovq  rbp,xmm0
  69:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  6d:	c5 fb 2a c3          	vcvtsi2sd xmm0,xmm0,ebx
  71:	c4 e1 f9 6e cd       	vmovq  xmm1,rbp
  76:	c5 f3 58 c0          	vaddsd xmm0,xmm1,xmm0
  7a:	ff c3                	inc    ebx
  7c:	41 85 02             	test   DWORD PTR [r10],eax
  7f:	41 3b dd             	cmp    ebx,r13d
  82:	7e dc                	jle    0x60
  84:	c4 e1 f9 7e c5       	vmovq  rbp,xmm0
  89:	be 45 ff ff ff       	mov    esi,0xffffff45
  8e:	89 1c 24             	mov    DWORD PTR [rsp],ebx
  91:	44 89 6c 24 04       	mov    DWORD PTR [rsp+0x4],r13d
  96:	90                   	nop
  97:	e8 44 1a 9e ff       	call   0xffffffffff9e1ae0
  9c:	0f 1f 84 00 94 01 00 	nop    DWORD PTR [rax+rax*1+0x1000194]
  a3:	01 
  a4:	e8 37 43 8f ff       	call   0xffffffffff8f43e0
  a9:	e9 7c ff ff ff       	jmp    0x2a
  ae:	f4                   	hlt
  af:	f4                   	hlt
  b0:	e9 2b 1d 9e ff       	jmp    0xffffffffff9e1de0
  b5:	e8 00 00 00 00       	call   0xba
  ba:	48 83 2c 24 05       	sub    QWORD PTR [rsp],0x5
  bf:	e9 1c ef 90 ff       	jmp    0xffffffffff90efe0
  c4:	f4                   	hlt
  c5:	f4                   	hlt
  c6:	f4                   	hlt
  c7:	f4                   	hlt
