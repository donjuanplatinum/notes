# SMART状态工具
注意 SMART信息不是绝对准确 而且很多二手厂商会修改.
## smartctl
查询nvme的SMART信息:

```
 sudo smartctl -a /dev/nvme0
smartctl 7.5 2025-04-30 r5714 [x86_64-linux-7.2.8-barrensea] (local build)
Copyright (C) 2002-25, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Number:                       CT1000P3PSSD8
Serial Number:                      25044DB8AD3C
Firmware Version:                   P9CR413
PCI Vendor/Subsystem ID:            0x1344
IEEE OUI Identifier:                0x00a075
Controller ID:                      0
NVMe Version:                       1.4
Number of Namespaces:               1
Namespace 1 Size/Capacity:          1,000,204,886,016 [1.00 TB]
Namespace 1 Formatted LBA Size:     512
Namespace 1 IEEE EUI-64:            00a075 014db8ad3c
Local Time is:                      Fri Oct 23 19:51:49 2026 CST
Firmware Updates (0x14):            2 Slots, no Reset required
Optional Admin Commands (0x0017):   Security Format Frmw_DL Self_Test
Optional NVM Commands (0x00d7):     Comp Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp Verify
Log Page Attributes (0x1e):         Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg Pers_Ev_Lg
Maximum Data Transfer Size:         64 Pages
Warning  Comp. Temp. Threshold:     83 Celsius
Critical Comp. Temp. Threshold:     85 Celsius
Namespace 1 Features (0x08):        No_ID_Reuse

Supported Power States
St Op     Max   Active     Idle   RL RT WL WT  Ent_Lat  Ex_Lat
 0 +     5.50W       -        -    0  0  0  0        0       0
 1 +     3.00W       -        -    1  1  1  1        0       0
 2 +     1.50W       -        -    2  2  2  2        0       0
 3 -   0.0300W       -        -    3  3  3  3     5000    2500
 4 -   0.0025W       -        -    4  4  4  4     8000   40000

Supported LBA Sizes (NSID 0x1)
Id Fmt  Data  Metadt  Rel_Perf
 0 +     512       0         1
 1 -    4096       0         0

=== START OF SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02, NSID 0xffffffff)
Critical Warning:                   0x00
Temperature:                        31 Celsius
Available Spare:                    100%
Available Spare Threshold:          5%
Percentage Used:                    10%
Data Units Read:                    49,879,579 [25.5 TB]
Data Units Written:                 98,853,879 [50.6 TB]
Host Read Commands:                 424,512,592
Host Write Commands:                2,341,987,605
Controller Busy Time:               651
Power Cycles:                       2,150
Power On Hours:                     5,015
Unsafe Shutdowns:                   95
Media and Data Integrity Errors:    0
Error Information Log Entries:      0
Warning  Comp. Temperature Time:    0
Critical Comp. Temperature Time:    0
Temperature Sensor 1:               31 Celsius

Error Information (NVMe Log 0x01, 16 of 255 entries)
No Errors Logged

Self-test Log (NVMe Log 0x06, NSID 0xffffffff)
Self-test status: No self-test in progress
No Self-tests Logged

```


其中 `START OF SMART DATA SECTION`信息是目前的状态.

- Critical Warning: 有没有严重警告
- Temperature: 温度
- Temperature Sensor 1: 第一个温度传感器参数
- Available Spare: 设备报告的可用备用容量百分比, SSD会用一些备用的NAND来替换部分坏掉的块
- Available Spare Threshold: Spare容量低于这个值就报警的阈值
- Percentage Used: 消耗的耐久
- Data Units Read: 读了多少
- Data Units Written: 写入量
- Host Read Commands: 主机读命令
- Host Write Commands: 主机写命令
- Controller Busy Time: 忙碌时间 单位分钟
- Power Cycles: 上电次数
- Power On Hours: 通电小时
- Unsafe Shutdowns: 非正常断电次数
