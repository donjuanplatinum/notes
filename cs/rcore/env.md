# 应用程序与基本执行环境

本章我们会先**抛开操作系统** 先用 **裸机** 跑一段RISCV的Rust程序.

因为是**裸机** 目前也没有实现完整的**系统调用** 所以 我们只能使用rust的**core** 且加上`#![no_std]`属性

## build.rs
在这个build.rs中 我们会为这个程序使用 **链接器脚本** 指定程序 各个段的**内存布局**。 因为目前 我们没有 **虚拟内存** 所以只能让程序 利用好每个**物理内存**。


这是build.rs的主函数 将**链接脚本**写到
```rust
fn main() {
    use std::{env, fs, path::PathBuf};

    // 仅在交叉编译到 RISC-V64 时生成链接脚本
    if env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_default() == "riscv64" {
        let ld = PathBuf::from(env::var_os("OUT_DIR").unwrap()).join("linker.ld");
        fs::write(&ld, LINKER_SCRIPT).unwrap();
        // 告诉 rustc 使用此链接脚本
        println!("cargo:rustc-link-arg=-T{}", ld.display());
    }
}

```

这是链接脚本
```rust
const LINKER_SCRIPT: &[u8] = b"
OUTPUT_ARCH(riscv) // 目标架构
ENTRY(_m_start) // 入口点符号为_m_start， 会在汇编程序中找_m_start这个全局符号

M_BASE_ADDRESS = 0x80000000; // M态的基地址 在QEMU中一般是0x80000000 一般SBI或者bootloader放这里
S_BASE_ADDRESS = 0x80200000; // S态的基地址 一般kernel放这里

// 程序分段设置
SECTIONS {
    . = M_BASE_ADDRESS; // . 为当前地址的意思 即 将当前位置赋值为0x8000000
    .text.m_entry : { *(.text.m_entry) } // text
    .text.m_trap  : { *(.text.m_trap)  }
    .bss.m_stack  : { *(.bss.m_stack)  }
    .bss.m_data   : { *(.bss.m_data)   }

    /* ===== S-mode region (this program) ===== */
    . = S_BASE_ADDRESS;
    .text   : {
        *(.text.entry)          /* _start entry, must come first */
        *(.text .text.*)        /* other code */
    }
    .rodata : {
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
    }
    .data   : {
        *(.data .data.*)
        *(.sdata .sdata.*)
    }
    .bss    : {
        *(.bss.uninit)          /* stack space */
        *(.bss .bss.*)
        *(.sbss .sbss.*)
    }
}";

```

