---
alwaysApply: false
---
# ArkTS 语言全量规则

本项目基于 HarmonyOS 开发，使用 ArkTS 语言。以下是 ArkTS 的完整语法规则和编码规范，编写代码时必须严格遵守。

---

## 一、ArkTS 语言基础规则

### 1. 类型系统（严格模式）

- **禁止使用 `any` 和 `unknown`**：必须使用具体类型，如 `string`、`number`、`boolean` 或自定义 class/interface。需要动态键值对时使用 `Record<string, T>`。
- **禁止使用 `@ts-ignore` 和 `@ts-nocheck`**：所有变量必须显式声明类型，不得绕过类型检查。
- **严格空值检查**：使用可空类型前必须进行空值判断。
- **严格属性初始化**：class 中所有属性必须初始化或在构造函数中赋值。
- **严格函数类型检查**：函数参数类型必须精确匹配。
- **函数所有分支必须有返回值**。

### 2. 禁止的 TypeScript 语法

- **禁止索引签名 `{ [key: string]: T }`**：使用 `Record<string, T>` 替代。
- **禁止调用签名 `(value: string): void`**：使用 `type I = (value: string) => void` 替代。
- **禁止构造函数签名类型**：使用工厂函数 `() => Instance` 替代。
- **禁止 `typeof` 类型查询**：使用 class/interface/type 显式定义类型。
- **禁止 `this` 作为类型**：使用具体类名替代。
- **禁止映射类型 `{ [K in keyof T]: V }`**：使用 `Record<K, V>` 替代。
- **禁止对象字面量作为类型 `type T = { ... }`**：使用 `interface` 替代。
- **禁止命名空间 `namespace`**：使用 `import/export` 模块化语法。

### 3. 对象与属性访问

- **禁止通过索引访问对象属性 `obj['key']`**（非 Record 类型时）：使用点表示法 `obj.key`。对于动态键访问，使用 `Record<string, T>` 类型。
- **禁止使用 `in` 操作符判断属性**：使用 `Object.keys(obj)` 判断。
- **禁止解构赋值**：使用索引访问或手动赋值替代。
  ```typescript
  // 错误
  let { name, age } = person;
  let [first, second] = arr;
  // 正确
  let name = person.name;
  let age = person.age;
  let first = arr[0];
  ```
- **禁止扩展运算符 `...`**：使用 `Object.assign()` 或手动赋值替代。
- **禁止将 class 作为对象传递**：使用 class 构造实例。
- **禁止在函数上挂载属性 `fn.prop = value`**：使用 class 组织相关函数和属性。

### 4. 控制流与循环

- **禁止 `for...in`**：使用 `Object.entries(obj)` + `for...of` 替代。
- **条件语句和循环必须使用大括号 `{}`**。
- **禁止在循环内声明引用外部不安全变量的函数**。

### 5. 正则表达式

- **禁止正则字面量 `/pattern/flags`**：使用 `new RegExp(pattern, flags)` 构造函数。
  ```typescript
  // 错误
  let regex: RegExp = /\s*/g;
  // 正确
  let regex: RegExp = new RegExp('\\s*', 'g');
  ```

### 6. 异常处理

- **`throw` 值必须为 `Error` 类型或其子类**。
- **`catch` 不允许带类型注解**：使用无类型 `catch`，然后通过类型断言处理。
  ```typescript
  // 正确
  } catch (error) {
    let e: BusinessError = error as BusinessError;
  }
  ```

### 7. 全局对象与函数方法

- **禁止 `globalThis`**：使用单例模式 + `import/export` 替代。
- **禁止 `Function.prototype.apply/bind/call`**：使用箭头函数或直接传参替代。
- **禁止 `Object.fromEntries()`**：使用 `forEach` 手动实现。
- **禁止无类型对象字面量**：所有对象字面量必须有类型标注（class/interface/Record）。

### 8. 泛型与类型推断

- **所有泛型调用必须显式标注泛型参数类型**。
- **数组必须显式声明元素类型**。
- **禁止隐式类型转换（一元操作符 `+x`, `-x`, `~x`）**：使用 `Number.parseInt()`、`new Number()` 等显式转换。

### 9. 模块导入

- **禁止 `import type` 语法**：使用普通 `import` 导入。
- **禁止副作用导入 `import 'module'`**：使用动态 `import('module')` 替代。
- **禁止 `.ts`/`.js` 文件 `import` `.ets` 文件源码**。
- **禁止 `ESObject` 类型**：使用具体类型替代。

### 10. 类与构造函数

- **禁止构造函数参数属性（`constructor(readonly name: string)`）**：显式声明类属性。
  ```typescript
  // 正确
  class Person {
    name: string
    constructor(name: string) {
      this.name = name;
    }
  }
  ```
- **禁止类方法重赋值**：使用函数类型的类字段。
- **禁止在非 class 方法/静态方法外使用 `this`**。

---

## 二、ArkTS 状态管理装饰器规则

### V1 状态管理（@Component）

| 装饰器 | 用途 | 同步方向 | 初始化 | 允许类型 |
|--------|------|----------|--------|----------|
| `@State` | 组件内状态 | 无同步 | 必须本地初始化 | object, class, string, number, boolean, enum, Date, Map, Set, Array, 联合类型 |
| `@Prop` | 父子单向 | 父→子 | 可本地初始化 | 同 @State，建议嵌套≤5层 |
| `@Link` | 父子双向 | 父↔子 | 禁止本地初始化 | 同 @State |
| `@ObjectLink` | 嵌套对象双向 | 父↔子 | 禁止本地初始化 | class（需配合 @Observed） |
| `@Provide` | 跨层级提供 | 祖先→后代 | 必须本地初始化 | 同 @State |
| `@Consume` | 跨层级消费 | 祖先↔后代 | 禁止本地初始化 | 同 @State |
| `@Watch` | 变量更改通知 | - | 必须本地初始化 | 同 @State |
| `@StorageLink` | AppStorage双向 | 全局↔组件 | 可从AppStorage初始化 | 简单类型+集合类型 |
| `@StorageProp` | AppStorage单向 | 全局→组件 | 可从AppStorage初始化 | 简单类型+集合类型 |
| `@LocalStorageLink` | LocalStorage双向 | 局部↔组件 | 可从LocalStorage初始化 | 同上 |
| `@LocalStorageProp` | LocalStorage单向 | 局部→组件 | 可从LocalStorage初始化 | 同上 |

### V2 状态管理（@ComponentV2）

| 装饰器 | 用途 | 同步方向 | 初始化 | 说明 |
|--------|------|----------|--------|------|
| `@Local` | 组件内部状态 | 无同步 | 必须本地初始化 | 类似 @State 但不可外部初始化 |
| `@Param` | 组件外部输入 | 父→子 | 从外部传入 | 类似 @Prop，不可本地直接修改 |
| `@Event` | 组件输出 | 子→父 | 回调方法 | 配合 @Param 实现双向同步 |
| `@Once` | 初始化同步一次 | 父→子（仅一次） | 配合 @Param | 后续父组件变化不同步 |
| `@Monitor` | 监听变化 | - | - | 监听 @Param/@Local 变化 |
| `@Computed` | 计算属性 | - | - | 自动重新计算 |
| `@ObservedV2` | 类深度观测 | - | 装饰 class | 配合 @Trace |
| `@Trace` | 属性级更新 | - | 装饰 class 属性 | 精确追踪属性变化 |
| `@Type` | 标记序列化类型 | - | 装饰 class 属性 | 配合 PersistenceV2 |

### 装饰器使用限制

- `@State` 不允许装饰 `Function` 类型。
- `@Link` 禁止在 `@Entry` 组件中使用。
- `@Prop` 嵌套传递建议不超过 5 层。
- `@Watch` 使用严格相等（`===`）判断，需避免无限循环。
- `@Track` 装饰的 class 中，非 `@Track` 属性不能在 UI 中使用。
- `@Event` 只能用在 `@ComponentV2` 中。
- `@ObservedV2` + `@Trace` 用于类属性深度观测。
- `@Require` 从 API 11 开始支持，用于强制构造传参。

---

## 三、UI 构建规则

### 1. @Builder 自定义构建函数

- **私有 @Builder**：定义在组件内，可通过 `this` 访问组件状态变量。
- **全局 @Builder**：定义在全局，不涉及组件状态时推荐使用。
- **按引用传递**：仅一个参数且传入对象字面量时可触发 UI 刷新。
- **按值传递**（默认）：状态变量改变不会引起 UI 刷新。
- **两个及以上参数不会触发动态渲染 UI**。
- @Builder 内部不允许修改参数值。

### 2. @Styles 样式复用

- 仅支持通用属性和通用事件。
- 不支持传入参数，不支持逻辑组件（如 if 语句）。
- 组件内 @Styles 优先级高于全局 @Styles。
- 只能在当前文件内使用，不支持 export。

### 3. @Extend 扩展样式

- 支持封装指定组件的私有属性、私有事件和全局方法。
- 支持传入参数（含 function 和状态变量）。
- 仅支持全局定义，不支持组件内部定义。
- 仅限当前文件内使用，不支持导出。

### 4. @Reusable 组件复用（V1）

- 仅用于 `@Component`，不支持 `@ComponentV2`。
- 组件从组件树移除时存入缓存池。
- 状态变量更新有限制，组件结构需一致。
- 配合 `LazyForEach` 实现列表滚动优化。

### 5. 组件结构

- 使用 `@Entry` 标记页面入口组件。
- 使用 `@Component` / `@ComponentV2` 标记自定义组件。
- `build()` 方法内声明 UI 结构。
- 推荐使用 `Navigation` + `NavDestination` 管理页面路由，而非 `UIAbility` 组合所有界面。

---

## 四、并发编程规则

### TaskPool

- 用于执行耗时任务，支持任务调度和优先级设置。
- 任务函数必须使用 `@Sendable` 装饰。

### Worker

- 用于长时间运行的后台任务。
- 通过 `MessageChannel` 通信。

### Sendable 对象

- 使用 `@Sendable` 装饰的 class/function 可在并发实例间安全共享。
- Sendable 对象分配在共享堆（SharedHeap）中。
- 支持：基本数据类型、const enum、ArkTS 容器类型（需引入 `@arkts.collections`）、继承 `ISendable` 的 interface。
- 不支持：非 Sendable 类型的引用传递。

---

## 五、MVVM 架构规则

### 分层原则

1. **不可跨层访问**：View 不能直接访问 Model，Model 不能访问 View。
2. **下层不可访问上层数据**：ViewModel 不能访问 View 层数据。
3. **非父子组件间不可直接访问**：通过状态管理装饰器传递数据。

### 推荐文件结构

```
pages/          # 页面入口
views/          # 视图组件
viewmodel/      # ViewModel 层
model/          # Model 层（数据结构定义）
shares/         # 共享工具
```

- **Model 层**：定义数据结构（class）、数据加载逻辑。
- **ViewModel 层**：管理页面状态，为 View 提供数据和方法。
- **View 层**：纯 UI 展示，通过装饰器绑定 ViewModel 数据。

---

## 六、Code Linter 代码风格规则

### 格式规范

| 规则 | 说明 |
|------|------|
| `@hw-stylistic/max-len` | 代码行最大长度 **120 字符** |
| `@hw-stylistic/no-tabs` | 禁止 Tab 缩进，使用空格 |
| `@hw-stylistic/indent` | switch 中 case/default 缩进一层 |
| `@hw-stylistic/curly` | 条件/循环语句必须使用大括号 |
| `@hw-stylistic/semi-spacing` | 分号前不加空格 |

### 类型与声明规范

| 规则 | 说明 |
|------|------|
| `@typescript-eslint/array-type` | 数组类型统一使用 `T[]` 而非 `Array<T>` |
| `@typescript-eslint/ban-types` | 禁止使用 `String`/`Boolean`/`Number`/`Symbol`/`BigInt`/`Function`/`Object` 包装类型，使用小写基本类型 |
| `@typescript-eslint/typedef` | 特定位置需要类型注解 |
| `@typescript-eslint/semi` | 语句末尾必须加分号 |
| `@typescript-eslint/comma-dangle` | 不允许尾随逗号 |
| `@typescript-eslint/quotes` | 推荐使用双引号 |
| `@typescript-eslint/brace-style` | 大括号不换行（K&R 风格） |

### 最佳实践

| 规则 | 说明 |
|------|------|
| `eqeqeq` | 必须使用 `===` 和 `!==`，禁止 `==` 和 `!=` |
| `prefer-const` | 声明后未修改的变量使用 `const` |
| `@typescript-eslint/dot-notation` | 使用点表示法访问属性 |
| `@typescript-eslint/no-shadow` | 禁止声明与外部作用域同名的变量 |
| `@typescript-eslint/no-redeclare` | 禁止变量重复声明 |
| `@typescript-eslint/no-loop-func` | 禁止循环内声明不安全引用的函数 |
| `@typescript-eslint/no-namespace` | 禁止使用命名空间 |
| `@typescript-eslint/return-await` | async 函数中 try/catch 内必须 `return await` |

### 安全规则

| 规则 | 说明 |
|------|------|
| `@security/no-cycle` | 禁止循环依赖 |
| `@security/no-unsafe-dh` | 禁止不安全的 DH 密钥协商（模数 < 2048bit） |

### 多端适配规则

| 规则 | 说明 |
|------|------|
| `@cross-device-app-dev/color-value` | 颜色值使用 `$r('app.color.xxx')` 或 `$r('sys.color.xxx')`，禁止硬编码 |
| `@cross-device-app-dev/font-size` | 字体大小至少 **8fp** |
| `@cross-device-app-dev/size-unit` | width/height/size 使用 **vp** 单位，禁止 px |

---

## 七、命名规范

### 代码文件命名

- 使用小写字母 + 连字符或下划线风格。

### 标识符命名

- **类名/组件名**：大驼峰（PascalCase），如 `TodoListModel`、`Index`。
- **变量/函数/属性**：小驼峰（camelCase），如 `getTitle`、`isVisible`。
- **常量**：全大写 + 下划线（UPPER_CASE），如 `MAX_COUNT`。
- **装饰器**：以 `@` 开头，如 `@State`、`@Prop`、`@Builder`。

---

## 八、常用 Kit 导入方式

```typescript
import { Router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { http } from '@kit.NetworkKit';
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
```

---

## 九、参考文档

项目内 `harmony_documents/` 目录包含完整的 HarmonyOS 开发文档，主要参考：
- `arkts-more-cases.md`：ArkTS 语法适配完整案例
- `arkts-state.md` / `arkts-prop.md` / `arkts-link.md`：状态管理装饰器详解
- `arkts-mvvm.md` / `arkts-mvvm-v2.md`：MVVM 架构实战
- `arkts-builder.md`：@Builder 使用指南
- `arkts-sendable.md`：并发编程 Sendable 规范
- `ide-code-linter.md`：Code Linter 配置说明
