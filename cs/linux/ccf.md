# CCF
通用时钟框架

API位置: `include/linux/clk.h`

## API

### macro

- `PRE_RATE_CHANGE`：频率即将改变的通知标志
- `POST_RATE_CHANGE`：频率改变完成的通知标志
- `ABORT_RATE_CHANGE`：频率改变被中止的通知标志

### type

- `struct clk`：抽象时钟结构体（不透明类型）
- `struct clk_notifier`：时钟通知器，关联 clk 与通知链
- `struct clk_notifier_data`：通知回调数据，包含新旧频率
- `struct clk_bulk_data`：批量时钟操作数据，包含 id 和 clk 指针

### function

**获取/释放**

- `clk_get`：获取时钟
- `clk_put`：释放时钟
- `devm_clk_get`：设备托管的获取时钟
- `devm_clk_put`：设备托管的释放时钟
- `devm_clk_get_prepared`：获取时钟并 prepare
- `devm_clk_get_enabled`：获取时钟并 prepare + enable
- `devm_clk_get_optional`：获取可选时钟，不存在返回 NULL
- `devm_clk_get_optional_prepared`：获取可选时钟并 prepare
- `devm_clk_get_optional_enabled`：获取可选时钟并 prepare + enable
- `devm_clk_get_optional_enabled_with_rate`：获取可选时钟，设置频率并 enable
- `clk_get_sys`：按设备名获取时钟
- `clk_get_optional`：获取可选时钟，不存在返回 NULL
- `devm_get_clk_from_child`：从子设备树节点获取托管时钟

**批量操作**

- `clk_bulk_get`：批量获取时钟
- `clk_bulk_get_optional`：批量获取可选时钟
- `clk_bulk_get_all`：获取所有时钟
- `clk_bulk_put`：批量释放时钟
- `clk_bulk_put_all`：释放所有时钟
- `devm_clk_bulk_get`：设备托管批量获取
- `devm_clk_bulk_get_optional`：设备托管批量获取可选时钟
- `devm_clk_bulk_get_optional_enable`：设备托管批量获取可选时钟并 enable
- `devm_clk_bulk_get_all`：设备托管获取所有时钟
- `devm_clk_bulk_get_all_enabled`：设备托管获取所有时钟并 enable

**使能控制**

- `clk_prepare`：准备时钟（可睡眠）
- `clk_unprepare`：取消准备时钟
- `clk_enable`：使能时钟（原子上下文可用）
- `clk_disable`：关闭时钟
- `clk_prepare_enable`：prepare + enable
- `clk_disable_unprepare`：disable + unprepare
- `clk_bulk_prepare`：批量准备时钟
- `clk_bulk_unprepare`：批量取消准备
- `clk_bulk_enable`：批量使能
- `clk_bulk_disable`：批量关闭
- `clk_bulk_prepare_enable`：批量 prepare + enable
- `clk_bulk_disable_unprepare`：批量 disable + unprepare
- `clk_is_enabled_when_prepared`：检查 prepare 时是否自动 enable

**频率操作**

- `clk_get_rate`：获取当前频率
- `clk_set_rate`：设置频率
- `clk_round_rate`：查询可设置的最接近频率
- `clk_set_rate_range`：设置频率范围
- `clk_set_min_rate`：设置最小频率
- `clk_set_max_rate`：设置最大频率
- `clk_drop_range`：清除频率范围限制
- `clk_set_rate_exclusive`：设置频率并独占

**父子关系**

- `clk_get_parent`：获取父时钟
- `clk_set_parent`：设置父时钟
- `clk_has_parent`：检查是否为可能的父时钟
- `clk_is_match`：比较两个 clk 是否指向同一硬件时钟

**高级功能**

- `clk_get_accuracy`：获取精度（ppb）
- `clk_set_phase`：设置相位
- `clk_get_phase`：获取相位
- `clk_set_duty_cycle`：设置占空比
- `clk_get_scaled_duty_cycle`：获取缩放后的占空比
- `clk_rate_exclusive_get`：获取频率独占控制权
- `clk_rate_exclusive_put`：释放频率独占控制权
- `devm_clk_rate_exclusive_get`：设备托管获取频率独占控制权
- `clk_save_context`：保存时钟上下文（电源管理）
- `clk_restore_context`：恢复时钟上下文（电源管理）

**通知机制**

- `clk_notifier_register`：注册频率变化通知
- `clk_notifier_unregister`：注销频率变化通知
- `devm_clk_notifier_register`：设备托管注册通知

**OF（设备树）**

- `of_clk_get`：从设备树节点获取时钟
- `of_clk_get_by_name`：按名称从设备树获取时钟
- `of_clk_get_from_provider`：从 phandle 获取时钟
