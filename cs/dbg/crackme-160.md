# crackme-160
## 1. acid burn.exe
我们的分析方法很简单而暴力:  找到判断输入错误的逻辑然后jmp掉

我们很容易的发现 错误后 会弹出一个窗口提示输入错误 这个窗口是一个windows api叫MessageBox 定义于user32.dll

那么我们在弹出后 在x64dbg中按下F12停止进程 然后通过函数堆栈的调用关系来找到调用弹出MessageBox的地方

然后我们在调用堆栈找到了MessageBox的这一行


```
地址=0019F668
返回到=0042A1AE
返回自=776B4945
大小=3C
方=用户模块
注释=user32.MessageBoxA+45
```

**注意 MessageBoxA是MessageBox的实现 在这里可以理解为rust中 MessageBoxA实现了MessageBox trait**

我们直接跟踪到 `返回到` 也就是调用它的地方
```asm
0042A16D  | C3                       | ret                                     |
0042A16E  | 8BC0                     | mov eax,eax                             |
0042A170  | 55                       | push ebp                                |
0042A171  | 8BEC                     | mov ebp,esp                             |
0042A173  | 83C4 F4                  | add esp,FFFFFFF4                        |
0042A176  | 53                       | push ebx                                |
0042A177  | 56                       | push esi                                |
0042A178  | 57                       | push edi                                |
0042A179  | 8BF9                     | mov edi,ecx                             |
0042A17B  | 8BF2                     | mov esi,edx                             |
0042A17D  | 8BD8                     | mov ebx,eax                             |
0042A17F  | E8 7CB4FDFF              | call <JMP.&GetActiveWindow>             |
0042A184  | 8945 F8                  | mov dword ptr ss:[ebp-8],eax            |
0042A187  | 33C0                     | xor eax,eax                             |
0042A189  | E8 12A0FFFF              | call acid burn.4241A0                   |
0042A18E  | 8945 F4                  | mov dword ptr ss:[ebp-C],eax            |
0042A191  | 33C0                     | xor eax,eax                             |
0042A193  | 55                       | push ebp                                |
0042A194  | 68 D0A14200              | push acid burn.42A1D0                   |
0042A199  | 64:FF30                  | push dword ptr fs:[eax]                 |
0042A19C  | 64:8920                  | mov dword ptr fs:[eax],esp              |
0042A19F  | 8B45 08                  | mov eax,dword ptr ss:[ebp+8]            |
0042A1A2  | 50                       | push eax                                |
0042A1A3  | 57                       | push edi                                |
0042A1A4  | 56                       | push esi                                |
0042A1A5  | 8B43 24                  | mov eax,dword ptr ds:[ebx+24]           |
0042A1A8  | 50                       | push eax                                |
0042A1A9  | E8 FAB5FDFF              | call <JMP.&MessageBoxA>                 |
```

我们从`0042A1A9`的`call <JMP.&MessageBoxA>`一直观察到`0042A16D`的`ret` , 因为ret是上一个函数的返回指令 和这个地方没关系.

我们发现这一块的汇编并没有和跳转相关的逻辑 所以继续向上走

然后在`0042A1A9`设置断点 在函数的第一个语句`0042A170`也下个断点 然后再跑一次程序

跑到函数头后 我们再次通过调用堆栈定位到调用它的位置

```
地址=0019F6A4
返回到=0042FB37
返回自=0042A170
大小=38
方=用户模块
注释=acid burn.0042A170
```

可以看到是`0042FB37`调用的它 那么我们直接定位



```asm
0042FA74  | jmp acid burn.42FB37                    |
0042FA79  | lea edx,dword ptr ss:[ebp-10]           | [ebp-10]:"Enter your serial here !"
0042FA7C  | mov eax,dword ptr ds:[ebx+1DC]          | eax:&"d稝", [ebx+1DC]:&"d稝"
0042FA82  | call acid burn.41AA58                   |
0042FA87  | mov eax,dword ptr ss:[ebp-10]           | [ebp-10]:"Enter your serial here !"
0042FA8A  | movzx eax,byte ptr ds:[eax]             | eax:&"d稝"
0042FA8D  | imul dword ptr ds:[431750]              |
0042FA93  | mov dword ptr ds:[431750],eax           | eax:&"d稝"
0042FA98  | mov eax,dword ptr ds:[431750]           | eax:&"d稝"
0042FA9D  | add dword ptr ds:[431750],eax           | eax:&"d稝"
0042FAA3  | lea eax,dword ptr ss:[ebp-4]            | [ebp-04]:"CW"
0042FAA6  | mov edx,acid burn.42FBAC                | edx:"Sorry , The serial is incorect !", 42FBAC:"CW"
0042FAAB  | call acid burn.403708                   |
0042FAB0  | lea eax,dword ptr ss:[ebp-8]            | [ebp-08]:"CRACKED"
0042FAB3  | mov edx,acid burn.42FBB8                | edx:"Sorry , The serial is incorect !", 42FBB8:"CRACKED"
0042FAB8  | call acid burn.403708                   |
0042FABD  | push dword ptr ss:[ebp-4]               | [ebp-04]:"CW"
0042FAC0  | push acid burn.42FBC8                   |
0042FAC5  | lea edx,dword ptr ss:[ebp-18]           | [ebp-18]:"6560"
0042FAC8  | mov eax,dword ptr ds:[431750]           | eax:&"d稝"
0042FACD  | call acid burn.406718                   |
0042FAD2  | push dword ptr ss:[ebp-18]              | [ebp-18]:"6560"
0042FAD5  | push acid burn.42FBC8                   |
0042FADA  | push dword ptr ss:[ebp-8]               | [ebp-08]:"CRACKED"
0042FADD  | lea eax,dword ptr ss:[ebp-C]            | [ebp-0C]:"CW-6560-CRACKED"
0042FAE0  | mov edx,5                               | edx:"Sorry , The serial is incorect !"
0042FAE5  | call acid burn.4039AC                   |
0042FAEA  | lea edx,dword ptr ss:[ebp-10]           | [ebp-10]:"Enter your serial here !"
0042FAED  | mov eax,dword ptr ds:[ebx+1E0]          | eax:&"d稝", [ebx+1E0]:&"d稝"
0042FAF3  | call acid burn.41AA58                   |
0042FAF8  | mov edx,dword ptr ss:[ebp-10]           | [ebp-10]:"Enter your serial here !"
0042FAFB  | mov eax,dword ptr ss:[ebp-C]            | [ebp-0C]:"CW-6560-CRACKED"
0042FAFE  | call acid burn.4039FC                   |
0042FB03  | jne acid burn.42FB1F                    |
0042FB05  | push 0                                  |
0042FB07  | mov ecx,acid burn.42FBCC                | ecx:"Try Again!", 42FBCC:"Congratz !!"
0042FB0C  | mov edx,acid burn.42FBD8                | edx:"Sorry , The serial is incorect !", 42FBD8:"Good job dude =)"
0042FB11  | mov eax,dword ptr ds:[430A48]           | eax:&"d稝"
0042FB16  | mov eax,dword ptr ds:[eax]              | eax:&"d稝", [eax]:"d稝"
0042FB18  | call acid burn.42A170                   |
0042FB1D  | jmp acid burn.42FB37                    |
0042FB1F  | push 0                                  |
0042FB21  | mov ecx,acid burn.42FB74                | ecx:"Try Again!", 42FB74:"Try Again!"
0042FB26  | mov edx,acid burn.42FB80                | edx:"Sorry , The serial is incorect !", 42FB80:"Sorry , The serial is incorect !"
0042FB2B  | mov eax,dword ptr ds:[430A48]           | eax:&"d稝"
0042FB30  | mov eax,dword ptr ds:[eax]              | eax:&"d稝", [eax]:"d稝"
0042FB32  | call acid burn.42A170                   |
0042FB37  | xor eax,eax                             | eax:&"d稝"
```

可以看到`0042FB32`就是call`42A170`的地方. 我们找到了条件跳转

```asm
0042FB03  | jne acid burn.42FB1F                    | 
```

按照汇编 他的意思是若ZF=1 则不发生跳转 若ZF=0 则跳到`b2FB1F` 其实我们已经可以猜到给jne取反为je就能跳过失败的逻辑 我们试试把jne变成je 果然通过了.

```asm
0042FAFE  | call acid burn.4039FC                   |
0042FB03  | jne acid burn.42FB1F                    |
```

我们在`0042FAFE`处打下断点 并再跑一便程序 然后观察寄存器的值

```
EAX : 02408980     "CW-8938-CRACKED"
EBX : 02404E94     &"d稝"
ECX : 298E508D
EDX : 02406604     "myservi"
EBP : 0019F6A8
ESP : 0019F67C
ESI : 00000A2F     L'ਯ'
EDI : 02408C5C     &"d稝"
EIP : 0042FAFE     acid burn.0042FAFE
EFLAGS : 00000300     L'̀'
ZF : 0
OF : 0
CF : 0
PF : 0
SF : 0
TF : 1     L'ā'
AF : 0     L"IME"
DF : 0
IF : 1

```

可以看到`EDX`就是我们输入的密码 而`EAX`是一个特殊的字符串 我们有理由的可以猜测 在经过name的映射下 正确的密码是EAX的特殊字符串 所以我们试一试在程序中不改变name 把EAX的字符串复制到密码 可以发现正确了

