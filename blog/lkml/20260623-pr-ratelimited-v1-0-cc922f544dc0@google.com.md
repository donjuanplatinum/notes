# Rate limited printing for Rust
- 日期: Tue, 23 Jun 2026 15:38:03 +0000- 作者: Alice Ryhl


为 Rust 语言在内核中实现限速打印功能.
## [patch 0/5]
### commit-message
```
To avoid DoS on the kernel log, the Rust Binder driver is being switched
to rate limited printing. But before we can do that, we must first
implement rate limited printing for Rust. Thus, do that.

However, it turns out that before we can implement rate limited
printing, we must first implement the ability declare a raw_spinlock_t
in a global variable. Thus, do that too.

The core Rust part of the series applies on top of 7.1-rc6, but the
Binder patches require some other Binder changes. I'll be resending a
more useful and easier to apply series after the merge window.
```
  

### diff
```
Alice Ryhl (5):
      rust: sync: move lockdep types to rust/kernel/sync/lockdep.rs
      rust: sync: add const constructor for raw_spinlock_t
      rust: add pr_*_ratelimit! macros for printing
      rust_binder: consolidate transaction failure prints
      rust_binder: use pr_*_ratelimited! for printing

 drivers/android/binder/allocation.rs  |   4 +-
 drivers/android/binder/context.rs     |   6 +-
 drivers/android/binder/error.rs       |   4 -
 drivers/android/binder/freeze.rs      |  22 ++--
 drivers/android/binder/node.rs        |   8 +-
 drivers/android/binder/page_range.rs  |  12 +-
 drivers/android/binder/process.rs     |  36 +++---
 drivers/android/binder/thread.rs      | 133 ++++++++++++----------
 drivers/android/binder/transaction.rs |  25 +----
 include/linux/spinlock_types_raw.h    |   4 +
 rust/bindings/lib.rs                  |  24 ++++
 rust/helpers/helpers.c                |   1 +
 rust/helpers/ratelimit.c              |  14 +++
 rust/kernel/error.rs                  |   2 +-
 rust/kernel/lib.rs                    |   1 +
 rust/kernel/prelude.rs                |   8 ++
 rust/kernel/ratelimit.rs              | 202 ++++++++++++++++++++++++++++++++++
 rust/kernel/sync.rs                   | 135 +----------------------
 rust/kernel/sync/lock/spinlock.rs     |  29 +++++
 rust/kernel/sync/lockdep.rs           | 161 +++++++++++++++++++++++++++
 20 files changed, 574 insertions(+), 257 deletions(-)
```
## [patch 1/5]
rust: sync: move lockdep types to rust/kernel/sync/lockdep.rs

### commit-message

The lockdep types are currently stored directly in rust/kernel/sync.rs,
but there are starting to be too many of them to keep them in that file.
Thus, move them to a submodule.

For commonly used lockdep logic it's useful to keep re-exports in
kernel::sync, and this also avoids the need to update any users.

将锁类型放到一个新的子模块里 同时重导出到kernel::sync

### diff
####  `/rust/kernel/sync.rs`
这个改动只是api移动
```diff
--- a/rust/kernel/sync.rs
+++ b/rust/kernel/sync.rs
@@ -5,10 +5,6 @@
 //! This module contains the kernel APIs related to synchronisation that have been ported or
 //! wrapped for usage by Rust code in the kernel.
 
-use crate::prelude::*;
-use crate::types::Opaque;
-use pin_init;
-
 mod arc;
 pub mod aref;
 pub mod atomic;
@@ -16,6 +12,7 @@
 pub mod completion;
 mod condvar;
 pub mod lock;
+pub mod lockdep;
 mod locked_by;
 pub mod poll;
 pub mod rcu;
@@ -28,135 +25,7 @@
 pub use lock::global::{global_lock, GlobalGuard, GlobalLock, GlobalLockBackend, GlobalLockedBy};
 pub use lock::mutex::{new_mutex, Mutex, MutexGuard};
 pub use lock::spinlock::{new_spinlock, SpinLock, SpinLockGuard};
+pub use lockdep::{static_lock_class, LockClassKey};
 pub use locked_by::LockedBy;
 pub use refcount::Refcount;
 pub use set_once::SetOnce;
-
-/// Represents a lockdep class.
-///
-/// Wraps the kernel's `struct lock_class_key`.
-#[repr(transparent)]
-#[pin_data(PinnedDrop)]
-pub struct LockClassKey {
-    #[pin]
-    inner: Opaque<bindings::lock_class_key>,
-}
-
-// SAFETY: Unregistering a lock class key from a different thread than where it was registered is
-// allowed.
-unsafe impl Send for LockClassKey {}
-
-// SAFETY: `bindings::lock_class_key` is designed to be used concurrently from multiple threads and
-// provides its own synchronization.
-unsafe impl Sync for LockClassKey {}
-
-impl LockClassKey {
-    /// Initializes a statically allocated lock class key.
-    ///
-    /// This is usually used indirectly through the [`static_lock_class!`] macro. See its
-    /// documentation for more information.
-    ///
-    /// # Safety
-    ///
-    /// * Before using the returned value, it must be pinned in a static memory location.
-    /// * The destructor must never run on the returned `LockClassKey`.
-    pub const unsafe fn new_static() -> Self {
-        LockClassKey {
-            inner: Opaque::uninit(),
-        }
-    }
-
-    /// Initializes a dynamically allocated lock class key.
-    ///
-    /// In the common case of using a statically allocated lock class key, the
-    /// [`static_lock_class!`] macro should be used instead.
-    ///
-    /// # Examples
-    ///
-    /// ```
-    /// use kernel::alloc::KBox;
-    /// use kernel::types::ForeignOwnable;
-    /// use kernel::sync::{LockClassKey, SpinLock};
-    /// use pin_init::stack_pin_init;
-    ///
-    /// let key = KBox::pin_init(LockClassKey::new_dynamic(), GFP_KERNEL)?;
-    /// let key_ptr = key.into_foreign();
-    ///
-    /// {
-    ///     stack_pin_init!(let num: SpinLock<u32> = SpinLock::new(
-    ///         0,
-    ///         c"my_spinlock",
-    ///         // SAFETY: `key_ptr` is returned by the above `into_foreign()`, whose
-    ///         // `from_foreign()` has not yet been called.
-    ///         unsafe { <Pin<KBox<LockClassKey>> as ForeignOwnable>::borrow(key_ptr) }
-    ///     ));
-    /// }
-    ///
-    /// // SAFETY: We dropped `num`, the only use of the key, so the result of the previous
-    /// // `borrow` has also been dropped. Thus, it's safe to use from_foreign.
-    /// unsafe { drop(<Pin<KBox<LockClassKey>> as ForeignOwnable>::from_foreign(key_ptr)) };
-    /// # Ok::<(), Error>(())
-    /// ```
-    pub fn new_dynamic() -> impl PinInit<Self> {
-        pin_init!(Self {
-            // SAFETY: lockdep_register_key expects an uninitialized block of memory
-            inner <- Opaque::ffi_init(|slot| unsafe { bindings::lockdep_register_key(slot) })
-        })
-    }
-
-    /// Returns a raw pointer to the inner C struct.
-    ///
-    /// It is up to the caller to use the raw pointer correctly.
-    pub fn as_ptr(&self) -> *mut bindings::lock_class_key {
-        self.inner.get()
-    }
-}
-
-#[pinned_drop]
-impl PinnedDrop for LockClassKey {
-    fn drop(self: Pin<&mut Self>) {
-        // SAFETY: `self.as_ptr()` was registered with lockdep and `self` is pinned, so the address
-        // hasn't changed. Thus, it's safe to pass it to unregister.
-        unsafe { bindings::lockdep_unregister_key(self.as_ptr()) }
-    }
-}
-
-/// Defines a new static lock class and returns a pointer to it.
-///
-/// # Examples
-///
-/// ```
-/// use kernel::sync::{static_lock_class, Arc, SpinLock};
-///
-/// fn new_locked_int() -> Result<Arc<SpinLock<u32>>> {
-///     Arc::pin_init(SpinLock::new(
-///         42,
-///         c"new_locked_int",
-///         static_lock_class!(),
-///     ), GFP_KERNEL)
-/// }
-/// ```
-#[macro_export]
-macro_rules! static_lock_class {
-    () => {{
-        static CLASS: $crate::sync::LockClassKey =
-            // SAFETY: The returned `LockClassKey` is stored in static memory and we pin it. Drop
-            // never runs on a static global.
-            unsafe { $crate::sync::LockClassKey::new_static() };
-        $crate::prelude::Pin::static_ref(&CLASS)
-    }};
-}
-pub use static_lock_class;
-
-/// Returns the given string, if one is provided, otherwise generates one based on the source code
-/// location.
-#[doc(hidden)]
-#[macro_export]
-macro_rules! optional_name {
-    () => {
-        $crate::c_str!(::core::concat!(::core::file!(), ":", ::core::line!()))
-    };
-    ($name:literal) => {
-        $crate::c_str!($name)
-    };
-}
```

#### `/rust/kernel/sync/lockdep.rs`
也是api移动
```diff
+// SPDX-License-Identifier: GPL-2.0
+
+//! Utilities related to lockdep.
+//!
+//! C headers: [`include/linux/lockdep.h`](srctree/include/linux/lockdep.h)
+
+use crate::{
+    prelude::*,
+    types::Opaque, //
+};
+
+/// Represents a lockdep class.
+///
+/// Wraps the kernel's `struct lock_class_key`.
+#[repr(transparent)]
+#[pin_data(PinnedDrop)]
+pub struct LockClassKey {
+    #[pin]
+    inner: Opaque<bindings::lock_class_key>,
+}
+
+// SAFETY: Unregistering a lock class key from a different thread than where it was registered is
+// allowed.
+unsafe impl Send for LockClassKey {}
+
+// SAFETY: `bindings::lock_class_key` is designed to be used concurrently from multiple threads and
+// provides its own synchronization.
+unsafe impl Sync for LockClassKey {}
+
+impl LockClassKey {
+    /// Initializes a statically allocated lock class key.
+    ///
+    /// This is usually used indirectly through the [`static_lock_class!`] macro. See its
+    /// documentation for more information.
+    ///
+    /// # Safety
+    ///
+    /// * Before using the returned value, it must be pinned in a static memory location.
+    /// * The destructor must never run on the returned `LockClassKey`.
+    pub const unsafe fn new_static() -> Self {
+        LockClassKey {
+            inner: Opaque::uninit(),
+        }
+    }
+
+    /// Initializes a dynamically allocated lock class key.
+    ///
+    /// In the common case of using a statically allocated lock class key, the
+    /// [`static_lock_class!`] macro should be used instead.
+    ///
+    /// # Examples
+    ///
+    /// ```
+    /// use kernel::alloc::KBox;
+    /// use kernel::types::ForeignOwnable;
+    /// use kernel::sync::{LockClassKey, SpinLock};
+    /// use pin_init::stack_pin_init;
+    ///
+    /// let key = KBox::pin_init(LockClassKey::new_dynamic(), GFP_KERNEL)?;
+    /// let key_ptr = key.into_foreign();
+    ///
+    /// {
+    ///     stack_pin_init!(let num: SpinLock<u32> = SpinLock::new(
+    ///         0,
+    ///         c"my_spinlock",
+    ///         // SAFETY: `key_ptr` is returned by the above `into_foreign()`, whose
+    ///         // `from_foreign()` has not yet been called.
+    ///         unsafe { <Pin<KBox<LockClassKey>> as ForeignOwnable>::borrow(key_ptr) }
+    ///     ));
+    /// }
+    ///
+    /// // SAFETY: We dropped `num`, the only use of the key, so the result of the previous
+    /// // `borrow` has also been dropped. Thus, it's safe to use from_foreign.
+    /// unsafe { drop(<Pin<KBox<LockClassKey>> as ForeignOwnable>::from_foreign(key_ptr)) };
+    /// # Ok::<(), Error>(())
+    /// ```
+    pub fn new_dynamic() -> impl PinInit<Self> {
+        pin_init!(Self {
+            // SAFETY: lockdep_register_key expects an uninitialized block of memory
+            inner <- Opaque::ffi_init(|slot| unsafe { bindings::lockdep_register_key(slot) })
+        })
+    }
+
+    /// Returns a raw pointer to the inner C struct.
+    ///
+    /// It is up to the caller to use the raw pointer correctly.
+    pub fn as_ptr(&self) -> *mut bindings::lock_class_key {
+        self.inner.get()
+    }
+}
+
+#[pinned_drop]
+impl PinnedDrop for LockClassKey {
+    fn drop(self: Pin<&mut Self>) {
+        // SAFETY: `self.as_ptr()` was registered with lockdep and `self` is pinned, so the address
+        // hasn't changed. Thus, it's safe to pass it to unregister.
+        unsafe { bindings::lockdep_unregister_key(self.as_ptr()) }
+    }
+}
+
+/// Defines a new static lock class and returns a pointer to it.
+///
+/// # Examples
+///
+/// ```
+/// use kernel::sync::{static_lock_class, Arc, SpinLock};
+///
+/// fn new_locked_int() -> Result<Arc<SpinLock<u32>>> {
+///     Arc::pin_init(SpinLock::new(
+///         42,
+///         c"new_locked_int",
+///         static_lock_class!(),
+///     ), GFP_KERNEL)
+/// }
+/// ```
+#[macro_export]
+macro_rules! static_lock_class {
+    () => {{
+        static CLASS: $crate::sync::LockClassKey =
+            // SAFETY: The returned `LockClassKey` is stored in static memory and we pin it. Drop
+            // never runs on a static global.
+            unsafe { $crate::sync::LockClassKey::new_static() };
+        $crate::prelude::Pin::static_ref(&CLASS)
+    }};
+}
+pub use static_lock_class;
+
+/// Returns the given string, if one is provided, otherwise generates one based on the source code
+/// location.
+#[doc(hidden)]
+#[macro_export]
+macro_rules! optional_name {
+    () => {
+        $crate::c_str!(::core::concat!(::core::file!(), ":", ::core::line!()))
+    };
+    ($name:literal) => {
+        $crate::c_str!($name)
+    };
+}
```

### reply
#### Carlos Llamas
表示LGTM
#### Boqun Feng
表示review了
#### Gary Guo
也表示review了
## [patch 2/5]
rust: sync: add const constructor for raw_spinlock_t
### commit-message
The abstractions for pr_*_ratelimited! need to construct a global
`struct ratelimit_state`, which contains a `raw_spinlock_t` field. Thus,
add a const constructor for the `raw_spinlock_t` type.

The SPINLOCK_OWNER_INIT constant isn't mirrored via a const helper
because bindgen generates a 'static mut' instead of a constant from the
pointer constant.,

The __ARCH_SPIN_LOCK_UNLOCKED constant cannot be translated by bindgen
because it's a define for a struct without type annotations, so it's
explicitly declared in Rust.

为`pr_*_ratelimited!`宏提供的抽象需要一个全局的`ratelimit_state` 而且需要包含一个`raw_spinlock_t`字段. 因此为`raw_spinlock_t`类型添加一个常量构造函数.

`SPHINLOCK_OWNER_INIT`常量无法通过const辅助函数进行镜像映射 因为bindgen 会将指针生成为`static mut`而不是常量.

`ARCH__SPIN_LOCK_UNLOCKED`常量不能被bindgen翻译 因为它是没有类型注解的结构体定义的宏
### diff
 include/linux/spinlock_types_raw.h |  4 ++++
 rust/bindings/lib.rs               | 24 ++++++++++++++++++++++++
 rust/kernel/sync/lock/spinlock.rs  | 29 +++++++++++++++++++++++++++++
 rust/kernel/sync/lockdep.rs        | 22 ++++++++++++++++++++++
 4 files changed, 79 insertions(+)

#### `/include/linux/spinlock_types_raw.h`
```diff
@@ -11,6 +11,10 @@
 
 #include <linux/lockdep_types.h>


+/*
+ * Keep in sync with rust/kernel/sync/lock/spinlock.rs
+ */
+
 context_lock_struct(raw_spinlock) {
 	arch_spinlock_t raw_lock;
 #ifdef CONFIG_DEBUG_SPINLOCK
diff --git a/rust/bindings/lib.rs b/rust/bindings/lib.rs
index 854e7c471434..adde41e41edc 100644
```
#### `rust/bindings/lib.rs`
```diff
--- a/rust/bindings/lib.rs
+++ b/rust/bindings/lib.rs
@@ -77,3 +77,27 @@ mod bindings_helper {
         None
     }
 };
+
+// Explicitly list architectures where this logic is checked correct.
+#[cfg(any(
+    CONFIG_ARM,
+    CONFIG_ARM64,
+    CONFIG_LOONGARCH,
+    CONFIG_PPC,
+    CONFIG_RISCV,
+    CONFIG_S390,
+    CONFIG_X86,
+))]
加入__ARCH_SPIN_LOCK_UNLOCKED常量
+pub const __ARCH_SPIN_LOCK_UNLOCKED: arch_spinlock_t = {
+    // SAFETY: The `arch_spinlock_t` type can be zeroed.
+    #[allow(unused_mut)]
+    let mut lock: arch_spinlock_t = unsafe { core::mem::zeroed() };
+
+    #[cfg(not(CONFIG_SMP))]
+    #[cfg(CONFIG_DEBUG_SPINLOCK)]
+    {
+        lock.slock = 1;
+    }
+
+    lock
+};
diff --git a/rust/kernel/sync/lock/spinlock.rs b/rust/kernel/sync/lock/spinlock.rs
index ef76fa07ca3a..8babfb79098f 100644
```
- `/rust/kernel/sync/lock/spinlock.rs`
```diff
 //!
 //! This module allows Rust code to use the kernel's `spinlock_t`.
 
+use kernel::prelude::*;
+
 /// Creates a [`SpinLock`] initialiser with the given name and a newly-created lock class.
 ///
 /// It uses the name if one is given, otherwise it generates one based on the file name and line
@@ -144,3 +146,30 @@ unsafe fn assert_is_held(ptr: *mut Self::State) {
         unsafe { bindings::spin_assert_is_held(ptr) }
     }
 }
 
+
+/// Helper for creating a raw unlocked `bindings::raw_spinlock_t`.
+///
+/// For use in statics containing raw spinlocks.
+pub const fn raw_spin_lock_unlocked(name: &'static CStr) -> bindings::raw_spinlock_t {
+    // Silence unused variable warnings.
+    #[cfg(not(CONFIG_DEBUG_LOCK_ALLOC))]
+    let _ = name;
+
+    bindings::raw_spinlock_t {
+        raw_lock: bindings::__ARCH_SPIN_LOCK_UNLOCKED,
+
+        #[cfg(CONFIG_DEBUG_SPINLOCK)]
+        magic: bindings::SPINLOCK_MAGIC,
+        #[cfg(CONFIG_DEBUG_SPINLOCK)]
+        owner_cpu: u32::MAX,
+        #[cfg(CONFIG_DEBUG_SPINLOCK)]
+        owner: usize::MAX as *mut c_void,
+
+        #[cfg(CONFIG_DEBUG_LOCK_ALLOC)]
+        dep_map: kernel::sync::lockdep::raw_lockdep_map(
+            name,
+            kernel::sync::lockdep::LD_WAIT_SPIN,
+            kernel::sync::lockdep::LD_WAIT_INV,
+        ),
+    }
+}
```
