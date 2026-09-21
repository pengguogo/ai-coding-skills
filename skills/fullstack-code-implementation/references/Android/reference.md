# 包结构与命名

> **唯一职责**：目录约定与类型命名表。不含示例代码、不含架构/风格规则。
> 编码原则与约束见 [android-coding-standard.md](android-coding-standard.md)；模式示例见 [design-patterns-examples.md](design-patterns-examples.md)。

## 包结构

```
com.example.app
├── feature.<name>
│   ├── ui
│   ├── viewmodel
│   └── navigation
├── data
│   ├── repository
│   ├── remote
│   └── local
└── domain          # 可选
```

- 反向 DNS；段小写
- 功能代码在 `feature.<name>`；共享在 `core` 模块

## 命名表

| 元素 | 约定 | 示例 |
|------|------|------|
| Activity | `*Activity` | `MainActivity` |
| Fragment | `*Fragment` | `ProfileFragment` |
| ViewModel | `*ViewModel` | `ProfileViewModel` |
| Repository | `*Repository` | `UserRepository` |
| Use case | 动词短语 | `GetUserProfileUseCase` |
| Compose 界面 | 名词 | `ProfileScreen` |
| 布局 XML | `type_feature.xml` | `fragment_profile.xml` |
| 菜单 | `feature_menu.xml` | `main_menu.xml` |

## 资源文件前缀（速查）

| 类型 | 前缀 |
|------|------|
| 布局 | `activity_` / `fragment_` / `item_` / `dialog_` |
| Drawable | `ic_` / `bg_` / `img_` |
| 字符串 | `feature_context_action` |

详细资源/Manifest 规则见 [android-coding-standard.md](android-coding-standard.md#资源与-manifest)。
