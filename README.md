```markdown
# AutoPurge Pro 🗑️

Magisk/KernelSU 模块 | 智能垃圾清理自动化工具  
🌟 **每日自动清理** | **深度自定义** | **低资源占用**

---

## 📌 核心功能
- **定时垃圾清理**：默认每日凌晨12点自动清理
- **MT管理器专项清理**：深度清理 `/sdcard/` 目录残留
- **日志管理**：自动清理日志文件（可配置大小阈值）
- **双名单机制**：
  - **黑名单**：强制清理指定路径
  - **白名单**：保护重要文件/目录
- **实时监控**：MT管理器前台运行时触发即时清理
- **可视化统计**：累计清理数据展示在Magisk模块描述中

---

## 🚀 快速部署
### 前置条件
- Magisk v24+ 或 KernelSU
- Android 8.0+ (API Level 26+)
- 确保 `/sdcard/` 可读写

### 安装步骤
1. 下载最新 `AutoPurge-Pro.zip`
2. Magisk/KernelSU 中刷入模块
3. 重启设备
4. 自动生成配置目录：
   ```
   /sdcard/Android/Clear/清理垃圾/
   ├── 名单配置/
   │   ├── 黑名单.conf
   │   ├── 白名单.conf
   │   └── MT.conf
   ├── 自定义定时设置/
   │   └── 定时设置.conf
   └── 配置.conf
   ```

---

## ⚙️ 配置指南
### 基础配置 (`配置.conf`)
```conf
// 启用/关闭功能开关
timed_cleaning = true      // 总开关
mt_cleaning = true         // MT管理器清理
log_cleaning = true        // 日志清理
log_purge_size = 2M        // 日志大小阈值（支持K/M单位）
```

### 高级定时设置 (`定时设置.conf`)
```conf
# 时间格式说明：
# - 小时: 0-23 (单数字无需补零)
# - 分钟: 0-59 (允许补零)
# - 星期: 1-7 (1=周一) 或 *

Set_Time1=23       // 时间1-小时
Set_minute1=30     // 时间1-分钟
Set_Time2=6        // 时间2-小时
Set_minute2=0      // 时间2-分钟
Set_weekday1=*     // 星期设定1 (全周)
Set_weekday2=1,3,5 // 星期设定2 (周一/三/五)
```

### 路径规则示例 (`黑名单.conf`)
```conf
# 使用标准glob语法
/data/app/*/cache
/sdcard/Android/data/com.example/app_logs
/sdcard/Download/*.tmp
```

---

## 📊 数据监控
- **实时统计**：查看模块描述的累计清理数据
  ```text
  description=🌟已累计清理: 1587个【文件】 | 243个【文件夹】  
                       🌟上一次清理时间:2023-08-20 00:00:01
  ```
- **日志追踪**：  
  `/sdcard/Android/Clear/清理垃圾/Clear.log`
  ```log
  2023-08-20 00:00:01 "删除文件" "/sdcard/Android/data/com.app/cache.tmp"
  ```

---

## ⚠️ 注意事项
1. 修改配置后需执行：
   ```bash
   # 重新加载定时设置
   sh /sdcard/Android/Clear/清理垃圾/自定义定时设置/Timing_Settings.sh
   ```
2. 白名单优先级高于黑名单
3. 使用 `*` 作为通配符时避免路径越界
4. 紧急停止所有清理任务：
   ```bash
   pkill -f "TimingClear|SmartClear"
   ```

---

## 🔄 更新与反馈
- 建议通过Magisk保留配置升级
- 问题反馈请附：
  - `adb logcat | grep 'AutoPurge'`
  - `/sdcard/Android/Clear/清理垃圾/Clear.log`
  - 相关配置文件片段

**License**: GPL-3.0  
**Telegram Support**: [@AutoPurge_Support](https://t.me/AutoPurge_Support)
```