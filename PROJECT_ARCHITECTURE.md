# Tal·译器 (Pure HarmonyOS Watch) 项目架构文档

## 一、项目概述

### 1.1 基本信息
| 属性 | 值 |
|------|-----|
| 项目名称 | DeepL Translator for HarmonyOS Watch |
| 应用包名 | com.translator.deepl |
| 版本号 | 1.0.0 (1000000) |
| 目标设备 | wearable（智能手表/可穿戴设备） |
| 框架 | HarmonyOS ArkUI |
| 开发语言 | ArkTS (TypeScript) |

### 1.2 核心功能
本应用是一款专为纯血鸿蒙智能手表设计的翻译工具，主要功能包括：
- **文本翻译**：支持 13 种目标语言 + 自动检测源语言
- **翻译历史**：本地持久化存储最近 100 条翻译记录
- **API Key 配置**：支持 DeepL Free/Pro 账号切换

---

## 二、系统架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        应用层 (UI Layer)                      │
├─────────────────────────────────────────────────────────────┤
│  SplashPage.ets    │  主闪屏页面（动画 + 路由跳转）           │
│  Index.ets         │  主页面（翻译/历史/设置三合一 Tab 页面）  │
│  History.ets       │  历史记录详情页（手表端独立页面）         │
│  About.ets         │  关于与设置页（手机端独立页面）           │
├─────────────────────────────────────────────────────────────┤
│                     状态管理层 (State Layer)                  │
├─────────────────────────────────────────────────────────────┤
│  GlobalState.ets   │  全局单例：API Key、Pro 模式配置         │
│  @State/@Link      │  页面内组件状态管理                       │
├─────────────────────────────────────────────────────────────┤
│                     服务层 (Service Layer)                    │
├─────────────────────────────────────────────────────────────┤
│  DeepLService.ets  │  DeepL API HTTP 请求封装                │
│  HistoryStore.ets  │  翻译历史 CRUD 持久化                    │
├─────────────────────────────────────────────────────────────┤
│                     数据层 (Data Layer)                       │
├─────────────────────────────────────────────────────────────┤
│  DataModel.ets     │  数据模型定义（接口 + 常量）             │
│  Preferences       │  HarmonyOS 轻量级键值存储               │
├─────────────────────────────────────────────────────────────┤
│                     基础设施层 (Infrastructure)              │
├─────────────────────────────────────────────────────────────┤
│  EntryAbility.ets  │  应用入口 Ability                        │
│  module.json5      │  模块配置（权限、组件声明）               │
│  main_pages.json  │  页面路由配置                            │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 页面路由

| 页面 | 路由路径 | 说明 |
|------|---------|------|
| SplashPage | pages/SplashPage | 闪屏页，启动后首先展示，带淡入动画 |
| Index | pages/Index | 主页面，含三个 Tab：翻译/历史/设置 |
| History | pages/History | 历史记录详情页（手表端独立页面） |
| About | pages/About | 关于与设置页（手机端独立页面） |

---

## 三、核心模块详解

### 3.1 DeepLService（翻译服务）

**文件位置**: `model/DeepLService.ets`

**职责**: 封装所有与 DeepL API 的 HTTP 通信逻辑

**核心属性**:
```typescript
private apiKey: string = ''        // DeepL API 认证密钥
private usePro: boolean = false    // 是否使用 Pro 版本
```

**API 端点**:
| 模式 | URL |
|------|-----|
| Free | `https://api-free.deepl.com/v2/translate` |
| Pro | `https://api.deepl.com/v2/translate` |

**核心方法**:

| 方法 | 签名 | 功能 |
|------|------|------|
| translate | `(text, sourceLang, targetLang) => Promise<string>` | 执行翻译 |
| setApiKey | `(key: string) => void` | 设置 API Key |
| setUsePro | `(usePro: boolean) => void` | 设置是否使用 Pro |
| getApiKey | `() => string` | 获取 API Key |
| parseError | `(responseBody: string) => string` | 解析 API 错误信息 |

**HTTP 请求规范**:
- **Method**: POST
- **Content-Type**: `application/x-www-form-urlencoded`
- **Authorization**: `DeepL-Auth-Key {apiKey}`
- **Body**: `text={url_encoded_text}&target_lang={target}&source_lang={source}`

**错误处理策略**:
1. 预校验：空文本、空 Key 时直接抛错
2. HTTP 状态码非 200 时解析 JSON 错误体
3. 网络异常捕获并重新包装错误信息
4. 敏感信息（API Key）在错误日志中部分掩码显示

---

### 3.2 HistoryStore（历史记录管理）

**文件位置**: `model/HistoryStore.ets`

**职责**: 翻译历史的增删改查及持久化存储

**存储配置**:
```typescript
const HISTORY_KEY = 'translate_history'  // Preferences 键名
const MAX_HISTORY = 100                   // 最大记录数
```

**核心方法**:

| 方法 | 签名 | 功能 |
|------|------|------|
| init | `(context: Context) => Promise<void>` | 初始化 Preferences 实例 |
| getHistory | `() => Promise<TranslateRecord[]>` | 获取所有历史记录 |
| addRecord | `(record: TranslateRecord) => Promise<void>` | 添加单条记录（自动置顶） |
| deleteRecord | `(id: number) => Promise<void>` | 删除指定记录 |
| clearHistory | `() => Promise<void>` | 清空所有记录 |

**数据结构** (TranslateRecord):
```typescript
interface TranslateRecord {
  id: number              // 时间戳作为唯一 ID
  sourceText: string      // 原文
  targetText: string      // 译文
  sourceLang: string      // 源语言代码
  targetLang: string      // 目标语言代码
  timestamp: number       // 毫秒时间戳
}
```

**存储机制**:
- 使用 `@ohos.data.preferences` 轻量级键值存储
- 数据格式：JSON 字符串序列化
- 自动截断：超过 100 条时保留最新 100 条

---

### 3.3 GlobalState（全局状态）

**文件位置**: `model/GlobalState.ets`

**职责**: 应用级配置的单例管理，供所有页面共享

**存储键**:
```typescript
const GLOBAL_PREFS_NAME = 'global_config'  // Preferences 文件名
const API_KEY_KEY = 'deepl_apikey'         // API Key 键名
const USE_PRO_KEY = 'deepl_usepro'         // Pro 模式键名
```

**核心属性**:
```typescript
apiKey: string       // DeepL API Key
usePro: boolean      // 是否使用 Pro 版本
```

**核心方法**:

| 方法 | 签名 | 功能 |
|------|------|------|
| init | `(context: Context) => Promise<void>` | 异步初始化，从存储加载配置 |
| saveConfig | `(key: string, usePro: boolean) => Promise<void>` | 保存配置到存储 |

**导出形式**: 单例模式 `export const globalState = new GlobalState()`

---

### 3.4 DataModel（数据模型）

**文件位置**: `model/DataModel.ets`

**包含内容**:

| 类型 | 定义 |
|------|------|
| `DeepLRequestBody` | DeepL API 请求体结构（预留，当前未使用） |
| `DeepLResponse` | DeepL API 响应体结构 |
| `DeepLTranslation` | 单条翻译结果结构 |
| `TranslateRecord` | 应用内部翻译记录结构 |
| `SUPPORTED_LANGUAGES` | 支持的语言常量映射表 |

**SUPPORTED_LANGUAGES 完整列表**:
| 代码 | 语言 |
|------|------|
| AUTO | 自动检测 |
| ZH | 中文 |
| EN | 英语 |
| JA | 日语 |
| KO | 韩语 |
| FR | 法语 |
| DE | 德语 |
| ES | 西班牙语 |
| PT | 葡萄牙语 |
| IT | 意大利语 |
| RU | 俄语 |
| PL | 波兰语 |
| NL | 荷兰语 |
| TR | 土耳其语 |
| UK | 乌克兰语 |

---

## 四、页面架构

### 4.1 Index（主页面 - 手表端）

**文件位置**: `pages/Index.ets`

**设计模式**: 单页面多 Tab 架构，使用 `ArcSwiper` 实现页面切换

**Tab 结构**:

| Tab 索引 | Tab 名称 | Builder 方法 | 功能 |
|----------|----------|--------------|------|
| 0 | 翻译 | `translateTab()` | 核心翻译功能 |
| 1 | 历史 | `historyTab()` | 翻译历史列表 |
| 2 | 设置 | `settingsTab()` | API Key 配置 |

**状态定义**:
```typescript
@State currentIndex: number = 0      // 当前 Tab 索引
@State sourceText: string = ''        // 原文输入
@State targetText: string = ''        // 译文输出
@State sourceLang: string = 'AUTO'   // 源语言
@State targetLang: string = 'ZH'      // 目标语言
@State isLoading: boolean = false     // 加载状态
@State errorMsg: string = ''          // 错误信息
@State historyList: TranslateRecord[] = []  // 历史列表
@State settingsKey: string = ''        // 设置页显示的 Key
@State settingsPro: boolean = false   // 设置页 Pro 开关状态
@State settingsEdit: boolean = false  // 设置页编辑态
@State settingsInput: string = ''      // 设置页输入框值
@State settingsInputPro: boolean = false  // 设置页输入框 Pro 态
@State settingsError: string = ''     // 设置页错误信息
```

**组件协调**:
```typescript
private deeplService: DeepLService      // DeepL 服务实例
private historyStore: HistoryStore      // 历史存储实例
private arcListScroller: Scroller       // ArcList 滚动控制器
private arcSwiperController: ArcSwiperController  // Tab 切换控制器
```

**核心交互流程**:

1. **翻译流程** (`doTranslate`):
   ```
   输入文本 → 校验 → 显示 Loading → 调用 DeepLService.translate()
          → 成功后存储历史 → 更新 targetText → 隐藏 Loading
          → 失败时显示 errorMsg
   ```

2. **语言切换**: 点击 ⇄ 图标交换源语言和目标语言

3. **历史点击回填**: 点击历史记录项，自动回填到翻译区并切换到 Tab 0

4. **API Key 配置**: 设置 Tab 中可展开/收起配置面板，保存后同步到 DeepLService 和 GlobalState

---

### 4.2 SplashPage（闪屏页）

**文件位置**: `pages/SplashPage.ets`

**职责**: 应用启动展示，带动画效果后自动跳转

**动画配置**:
```typescript
const ANIMATION_DELAY = 300     // 动画开始前延迟 (ms)
const ANIMATION_DURATION = 500  // 动画时长 (ms)
const ANIMATION_CURVE = Curve.EaseIn  // 动画曲线
```

**动画效果**: 整体页面 opacity 从 0 渐变到 1（淡入）

**跳转逻辑**: `setTimeout` 在 `ANIMATION_DELAY + ANIMATION_DURATION + 200` 后执行 `router.replaceUrl`

---

### 4.3 History（历史页面 - 手表端独立页面）

**文件位置**: `pages/History.ets`

**职责**: 作为手表端独立页面展示历史记录列表

**与 Index.ets 的历史 Tab 关系**:
- Index.ets 的历史 Tab 直接使用 `historyTab()` Builder 内联实现
- History.ets 是独立的全页面实现，供其他入口（如手机端）访问

**状态定义**:
```typescript
@State records: TranslateRecord[] = []  // 历史记录列表
@State isLoading: boolean = true        // 加载状态
```

**点击行为**: 点击记录项跳转到 Index 页面（但不传递数据，因为 Index 已有数据）

---

### 4.4 About（关于页面 - 手机端）

**文件位置**: `pages/About.ets`

**职责**: 作为手机端独立页面，提供完整的设置功能

**与 Index.ets 的设置 Tab 关系**:
- Index.ets 的设置 Tab 是手表端的简化实现
- About.ets 是手机端的完整实现，UI 风格为 iOS 风格

**状态定义**:
```typescript
@State apiKey: string = ''          // 当前 API Key
@State usePro: boolean = false       // 当前 Pro 状态
@State showKeyInput: boolean = false // 输入面板展开态
@State inputKey: string = ''         // 输入框 Key
@State inputPro: boolean = false    // 输入框 Pro 态
@State inputError: string = ''       // 输入错误信息
```

---

## 五、技术实现细节

### 5.1 网络请求实现

**使用的 HarmonyOS API**: `@ohos.net.http`

**请求流程**:
```typescript
1. http.createHttp() 创建 HTTP 请求实例
2. 配置 method, header, extraData
3. await httpRequest.request() 发起请求
4. 检查 responseCode
5. JSON.parse 解析响应体
6. httpRequest.destroy() 释放资源
```

**错误信息包装**: 所有错误都会附加上请求的 URL、Authorization 头（掩码后）、Content-Type 和请求体，方便调试

---

### 5.2 数据持久化实现

**使用的 HarmonyOS API**: `@ohos.data.preferences`

**Preferences 初始化**:
```typescript
this.pref = await preferences.getPreferences(context, { name: 'prefs_name' });
```

**数据操作**:
- 读取: `await this.pref.get(key, defaultValue)`
- 写入: `await this.pref.put(key, value)`
- 提交: `await this.pref.flush()`

**应用场景**:
| 存储实例 | 文件名 | 存储内容 |
|---------|--------|----------|
| GlobalState | `global_config` | API Key、Pro 模式 |
| HistoryStore | `translator_prefs` | 翻译历史 JSON |

---

### 5.3 UI 组件使用

**核心组件**:

| 组件 | 来源 | 用途 |
|------|------|------|
| ArcSwiper | @ohos.arkui.ArcSwiper | 手表端 Tab 页面切换 |
| ArcList | @ohos.arkui.ArcList | 手表端历史列表 |
| ArcListItem | @ohos.arkui.ArcListItem | 历史列表项 |
| ArcDotIndicator | @ohos.arkui.ArcSwiper | Tab 指示器（圆点） |
| List | @kit.ArkUI | 手机端历史列表 |
| Select | @kit.ArkUI | 语言选择下拉框 |
| TextArea | @kit.ArkUI | 文本输入框 |
| Toggle | @kit.ArkUI | Switch 开关 |

**手表端特有组件原因**: ArcSwiper/ArcList 是专为圆形智能手表优化的组件，支持圆形屏的弧形滚动和展示

---

### 5.4 路由管理

**使用的 HarmonyOS API**: `@kit.ArkUI` 的 `router`

**支持的方法**:
- `router.replaceUrl({ url: 'pages/Target' })`: 替换当前页（无返回）
- `router.pushUrl({ url: 'pages/Target' })`: 推入新页（可返回）
- `router.back()`: 返回上一页

**路由配置** (`main_pages.json`):
```json
{
  "src": [
    "pages/SplashPage",
    "pages/Index"
  ]
}
```

**注意**: History.ets 和 About.ets 未在 main_pages.json 中注册，但通过 router.pushUrl 被直接引用（这可能是配置遗漏或设计意图）

---

### 5.5 应用入口 (EntryAbility)

**文件位置**: `entryability/EntryAbility.ets`

**职责**:
1. 应用生命周期管理
2. 窗口舞台配置
3. 颜色模式设置

**生命周期钩子**:
| 钩子 | 时机 | 用途 |
|------|------|------|
| onCreate | 应用首次创建 | 设置颜色模式 |
| onDestroy | 应用销毁 | 资源清理 |
| onWindowStageCreate | 窗口舞台创建 | 加载首页内容 |
| onWindowStageDestroy | 窗口舞台销毁 | 释放窗口资源 |
| onForeground | 应用进入前台 | - |
| onBackground | 应用进入后台 | - |

---

## 六、配置与权限

### 6.1 模块配置 (module.json5)

```json
{
  "module": {
    "name": "translator",           // 模块名
    "type": "entry",                // 入口模块
    "deviceTypes": ["wearable"],    // 支持设备类型：手表
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",  // 网络权限
        "reason": "$string:permission_reason"
      }
    ]
  }
}
```

### 6.2 应用配置 (AppScope/app.json5)

```json
{
  "app": {
    "bundleName": "com.translator.deepl",  // 应用包名
    "vendor": "translator",
    "versionCode": 1000000,
    "versionName": "1.0.0"
  }
}
```

---

## 七、现有架构问题与重构建议

### 7.1 已发现的问题

#### 问题 1: 代码重复
- **Index.ets** 和 **About.ets** 有大量相似的设置 UI 代码
- **Index.ets** 的 `historyTab()` 和独立的 **History.ets** 功能高度相似
- **GlobalState** 和 **DeepLService** 都有 API Key 存储，存在数据冗余

#### 问题 2: 初始化时机问题
- **HistoryStore** 在 Index.ets 中有两种初始化路径：
  1. `aboutToAppear()` 调用 `initAll()` 再调用 `historyStore.init()`
  2. `loadHistory()` 中也有条件初始化逻辑
  - 可能导致重复初始化或初始化竞争

#### 问题 3: 状态管理分散
- API Key 状态同时存在于 `GlobalState` 和 `DeepLService` 中
- 需要手动同步：`deeplService.setApiKey(globalState.apiKey)`
- 设置 Tab 修改后需手动同步到 DeepLService

#### 问题 4: 路由配置不完整
- `main_pages.json` 只注册了 SplashPage 和 Index
- History.ets 和 About.ets 虽被 router.pushUrl 引用但未注册

#### 问题 5: 错误处理不一致
- 某些地方用 `console.error`，某些地方用异常抛出
- 错误信息格式不统一

#### 问题 6: 手机端/手表端代码耦合
- Index.ets 需要同时适配手表 UI 和基本功能
- About.ets 和 History.ets 是独立的手机端页面
- 代码没有明确分离手表端和手机端逻辑

### 7.2 重构建议

#### 建议 1: 建立统一状态管理
```
方案 A: 使用 AppStorage / LocalStorage
方案 B: 建立事件中心 (EventBus)
方案 C: 依赖注入容器
推荐: 方案 A，符合 HarmonyOS 官方推荐
```

#### 建议 2: 抽取公共组件
- 抽取 `LanguageSelector` 组件
- 抽取 `ApiKeyInput` 组件
- 抽取 `HistoryListItem` 组件

#### 建议 3: 建立 Service 层统一管理
- 建立 `TranslationService` 统一管理 DeepLService 和 GlobalState
- 内部自动同步 API Key 状态

#### 建议 4: 完善路由配置
- 将所有页面都注册到 main_pages.json
- 或使用动态路由

#### 建议 5: 建立统一的错误处理
- 创建 `AppError` 类
- 建立全局错误处理器

#### 建议 6: 设备类型适配
- 建立 deviceUtils 工具类判断设备类型
- Index.ets 根据设备类型选择不同布局策略

---

## 八、数据流图

### 8.1 翻译操作数据流

```
用户输入文本
      │
      ▼
Index.doTranslate()
      │
      ▼
校验 (空文本检查) ──[失败]──▶ 显示错误信息
      │
      ▼ (成功)
DeepLService.translate()
      │
      ▼
HTTP POST 到 DeepL API
      │
      ├──[失败]──▶ 捕获异常 ──▶ 解析错误 ──▶ 显示错误信息
      │
      ▼ (成功)
返回译文文本
      │
      ▼
HistoryStore.addRecord() ──▶ 持久化到 Preferences
      │
      ▼
更新 UI 状态 (targetText, historyList)
```

### 8.2 应用启动数据流

```
EntryAbility.onWindowStageCreate()
      │
      ▼
加载 pages/SplashPage
      │
      ▼
SplashPage.aboutToAppear()
      │
      ▼
启动淡入动画 (300ms delay, 500ms duration)
      │
      ▼
动画结束后 router.replaceUrl('pages/Index')
      │
      ▼
Index.aboutToAppear()
      │
      ▼
initAll() ──▶ GlobalState.init() ──▶ 加载 API Key 和 Pro 配置
      │
      ▼
DeepLService.setApiKey() ──▶ 同步配置到服务
      │
      ▼
HistoryStore.init() ──▶ 初始化历史存储
```

---

## 九、依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│                         Index.ets                            │
│  (依赖 DeepLService, HistoryStore, GlobalState, DataModel)  │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌─────────────────┐   ┌─────────────────┐
│ DeepLService  │   │  HistoryStore   │   │   GlobalState   │
│   .ets        │   │     .ets        │   │     .ets        │
└───────────────┘   └─────────────────┘   └─────────────────┘
        │                     │                     │
        ▼                     ▼                     │
┌───────────────┐   ┌─────────────────┐            │
│   DataModel   │   │  Preferences    │            │
│     .ets      │   │   (系统 API)    │            │
└───────────────┘   └─────────────────┘            │
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  @ohos.net.http  │
                    │   (系统 API)     │
                    └─────────────────┘
```

---

## 十、文件清单

| 文件路径 | 类型 | 说明 |
|---------|------|------|
| `entryability/EntryAbility.ets` | UIAbility | 应用入口 |
| `pages/Index.ets` | Page | 主页面（手表端） |
| `pages/SplashPage.ets` | Page | 闪屏页 |
| `pages/History.ets` | Page | 历史页（手机端） |
| `pages/About.ets` | Page | 关于页（手机端） |
| `model/DeepLService.ets` | Service | DeepL API 服务 |
| `model/HistoryStore.ets` | Service | 历史存储服务 |
| `model/GlobalState.ets` | State | 全局状态单例 |
| `model/DataModel.ets` | Model | 数据模型定义 |
| `module.json5` | Config | 模块配置 |
| `main_pages.json` | Config | 页面路由配置 |
| `color.json` | Resource | 颜色资源 |
| `string.json` | Resource | 字符串资源 |

---

*文档版本: 1.0.0*
*生成时间: 2026-04-18*
*用途: 为项目重构提供全面参考*
