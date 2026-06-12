# Rust in Linux kernel
Rust语言从7.0版本开始 确立了长期存在地位.

要启用Rust相关支持 请在menuconfig中 勾选 `General setup ->Rust support`

注意 启用rust支持后 编译内核需要使用 `LLVM=1` 因为rust的后端是LLVM.
## quick-start

首先需要安装rust的工具链. 具体按照发行版来即可

下面的命令可以检查构建环境是否完备
```shell
make LLVM=1 rustavailable
```

生成内核的rust-project.json
```shell
make LLVM=1 rust-analyzer
```

格式化
```shell
make LLVM=1 rustfmt
```

### ffi
在linux中引入rust 需要 rust与C的配合. 所以需要C的FFI.

解析C语言代码为AST的是 `libclang` , 而 `bindgen` 利用 `libclang` 解析出的AST **自动**生成 rust的FFI代码.

## 架构
rust支持位于linux的 `rust`目录下


- `bindings/`: 由bindgen自动生成的FFI
- `kernel/`: 核心的抽象
- `drivers/`: 驱动
- `bindgen_parameters`: `bindgen`工具的配置文件
- `build_error.rs`: 提供`build_error!()`宏 在**编译期**报告错误.
- `compiler_builtins.rs`: 将一些
- `exports.c`: C语言的导出桩.暴露符号给其他部分的C代码. 是Rust与C双向通讯的桥梁
- `ffi.rs`: 声明了rust调用C函数时需要的外部函数签名
- `pin-init/`: `pin-init`库 提供宏与trait 允许原地初始化与固定大的对象
- `macros/`: 宏
- `uapi/`: 用户态接口
- `helpers/`: C语言助手 C写的包装函数 把C的内联函数封装为普通的函数符号给Rust用
- `syn/`: 解析rust的AST的
- `quote/`: 将修改后的语法树重新生成为Rust

## 开发流程与注意事项

 1. 在 rust/kernel/ 添加/修改安全抽象

 2. 如需暴露新 C API，在 rust/bindings/bindings_helper.h 添加头文件

 3. 对于 bindgen 无法处理的宏/内联函数，在 rust/helpers/ 添加 C wrapper

 4. 编写驱动实现 kernel::Module trait，使用 module! 宏注册

 5. 通过 make LLVM=1 CLIPPY=1 运行 clippy lint

 6. 通过 make LLVM=1 rustfmtcheck 检查格式

 7. 测试：make LLVM=1 rusttest（用户态）或 KUnit（内核态）

