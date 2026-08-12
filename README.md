# AsProgrammer（FlashBridge 分支）

[English](README_EN.md) | [简体中文](README.md)

基于 [nofeletru/UsbAsp-flash](https://github.com/nofeletru/UsbAsp-flash) 的分支，支持 SPI、I2C 协议的存储芯片编程。

支持的编程器：
- CH341
- CH347
- FT232H
- USBasp（需重新烧录固件）
- Arduino
- AVRISP-mkII（需重新烧录固件）
- FlashBridge（本分支新增）

## 本分支修改

- 新增 FlashBridge 编程器：CH347 负责 SPI/I2C 时序，CH32V002 通过 CH347 的 UART 虚拟串口控制 VIO 电压
- 修复 CH347 的 I2C ACK 检测（0x80），刷写中断后 SDA 不再卡死
- 更新 chiplist.xml（新增 vcc 电压信息）、CH34X 驱动与 CH341DLL/CH347DLL

## 使用说明

1. 解压发布包，运行 AsProgrammer.exe
2. 首次使用安装驱动：`drivers/CH34X/CH343SER.EXE`（串口）、`CH341PAR.EXE`（并口/SPI-I2C）
3. 编程器选择 FlashBridge，选择芯片型号后连接读写
4. VIO 电压：范围 1200–3300mV；低于 1.4V 自动使用限时保持模式，到期自动恢复电压