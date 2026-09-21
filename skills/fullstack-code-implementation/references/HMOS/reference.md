# 目录结构与命名（HMOS 鸿蒙）

> **唯一职责**：目录约定与类型命名表。不含示例代码、不含架构/风格规则。
> 编码原则与约束见 [hmos-coding-standard.md](hmos-coding-standard.md)；模式示例见 [design-patterns.md](design-patterns.md)。

## 目录结构

```
src/main/ets/
├── pages/              # 页面（router_map 注册）
├── components/         # UI 组件（@Component）
├── viewmodel/          # ViewModel（@ObservedV2）
├── model/              # 数据模型 / Bean / DTO
├── service/            # 网络请求 / 本地存储等服务
├── manager/            # 业务管理器（单例或生命周期绑定）
├── utils/              # 工具函数
├── config/             # 配置常量（API 路径、全局 Key 等）
└── bean/               # 数据类（简单值对象）
```

- 按功能域划分时可增加子目录：`feature/<name>/pages/`、`feature/<name>/viewmodel/`
- HAR 公共模块的 `src/main/ets/` 按能力分类（network/、storage/、crypto/ 等）

## 命名表

| 元素 | 约定 | 示例 |
|------|------|------|
| Page（页面组件） | `*Page` | `LoginPage` |
| @Component（通用组件） | 名词 PascalCase | `SpeedSettingView`、`TTSPlayerControl` |
| ViewModel | `*ViewModel` | `LoginViewModel` |
| Repository | `*Repository` | `UserRepository` |
| Service | `*Service` / `*Client` | `HttpService`、`DRHttpClient` |
| Manager | `*Manager` | `DRSpeechManager`、`DRRTCManager` |
| Model / Bean | `*Model` / `*Bean` / `*Info` | `OrderInfoModel`、`TTSConfigBean` |
| 工具类 | `*Util` / `*Helper` / `*Tool` | `DRFileUtil`、`CryptoHelper` |
| 配置类 | `*Config` / `*Constant` | `APIPathConfig`、`GlobalDataKey` |
| 接口/抽象 | `I*` 或 `*Interface` | `DRASRCallbackInterface` |
| 枚举 | PascalCase | `RecordMode`、`PlayerState` |

## 文件命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 页面 | `PascalCase.ets` | `LoginPage.ets`、`DRIndex.ets` |
| 组件 | `PascalCase.ets` | `SpeedSettingView.ets` |
| ViewModel | `PascalCase.ets` | `LoginViewModel.ets` |
| 服务/工具 | `PascalCase.ets` | `DRHttpClient.ets`、`CryptoAES.ets` |
| 测试 | `*.test.ets` | `LoginViewModel.test.ets` |

## 资源文件

| 类型 | 位置 | 格式 |
|------|------|------|
| 字符串 | `resources/base/element/string.json` | JSON |
| 颜色 | `resources/base/element/color.json` | JSON |
| 尺寸 | `resources/base/element/float.json` | JSON |
| 图片 | `resources/base/media/` | PNG/SVG |
| Profile | `resources/base/profile/` | JSON5 |

## 路由注册

```json5
// module.json5
{
  "module": {
    "routerMap": "$profile:router_map"
  }
}
```

```json5
// resources/base/profile/router_map.json
{
  "routerMap": [
    { "name": "LoginPage", "pageSourceFile": "src/main/ets/pages/LoginPage.ets" }
  ]
}
```

详细架构规则见 [architecture.md](architecture.md)。
