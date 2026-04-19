# Tal·译

一款专为 HarmonyOS 手表设计的轻量级翻译应用，基于 DeepL API 提供快速、精准的翻译服务。

## 功能特性

- **多语言翻译** - 支持 30+ 种语言互译
- **翻译历史** - 自动保存翻译记录，随时回顾
- **API Key 管理** - 支持 DeepL Free 和 Pro 两种层级
- **手表适配** - 针对圆形屏幕优化的弧形界面
- **表冠滚动** - 支持数字表冠控制列表滚动
- **语言快速选择** - 点击即弹出弧形语言列表

## 技术栈

- **开发语言**: ArkTS
- **UI 框架**: HarmonyOS ArkUI
- **API 服务**: DeepL Translation API
- **数据存储**: @ohos.data.preferences
- **构建工具**: hvigorw

## 项目结构

```
deepltranslator/
├── src/main/ets/
│   ├── pages/
│   │   ├── Index.ets        # 主页面（翻译/历史/设置三Tab）
│   │   └── SplashPage.ets   # 启动页
│   ├── components/
│   │   ├── ApiKeyComponents.ets  # API Key 相关组件
│   │   └── CommonComponents.ets  # 通用组件
│   └── model/
│       ├── ConfigManager.ets     # 配置管理
│       ├── DeepLService.ets      # DeepL API 服务
│       └── HistoryStore.ets      # 历史记录管理
```

## 界面设计

- **翻译页** - 弧形列表展示，支持语言选择、文本输入、翻译按钮和译文显示
- **历史页** - 弧形列表展示翻译历史记录
- **设置页** - 弧形卡片布局，管理 API Key 和应用信息

## 编译构建

```bash
cd deepltranslator
hvigorw assembleApp
```

## 配置说明

1. 前往 [dev.deepl.com](https://dev.deepl.com) 注册并获取 API Key
2. 在设置页面输入 API Key
3. 如使用 Pro 账号，请开启 Pro 模式

## 隐私说明

翻译内容会直接发送至 DeepL 服务器进行处理。

## 版本信息

- 当前版本: v1.0.1
- 作者: @TKStudio
