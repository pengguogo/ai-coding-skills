# 前端代码审查检查项

> 本检查项从以下规范文档提炼（均位于 fullstack-code-implementation/references/frontend/）：
> - \`coding_standard.md\`（前端编码规范）
> - \`component-patterns.md\`（组件设计模式）
> - \`api-integration.md\`（API 集成最佳实践）
> - \`performance-optimization.md\`（性能优化指南）
>
> 同时覆盖 Vue 和 React 场景。每个检查项标注严重性、规范来源和判断标准。
> blocking / important 级别检查项附带正反示例。
> 规范来源中的章节号以实际规范文档为准；若项目约定与本检查项冲突，以项目约定优先。
>
> **职责边界**：本文件聚焦**编码规范合规**检查。前端业务实现质量（状态一致性/竞态/接口健壮性/操作防护/权限/数据安全）的深度检查由 \`frontend-quality-checklist.md\`（FQ-*）统一覆盖。

---

## FE-NAME：命名规范

### FE-NAME-01：组件文件名使用 PascalCase
- **严重性**: important
- **规范来源**: coding_standard.md §二·2.1.2 文件与目录命名
- **判断标准**: Vue SFC 和 React 组件文件名使用大驼峰（如 \`ClaimDetail.vue\`、\`ClaimDetail.tsx\`）
- **示例**:
  \`\`\`
  ✅ ClaimDetail.vue / ClaimDetail.tsx
  ❌ claimDetail.vue / claim-detail.tsx
  \`\`\`

### FE-NAME-02：工具函数/hooks 文件名使用 camelCase
- **严重性**: suggestion
- **规范来源**: coding_standard.md §二·2.1.2 文件与目录命名
- **判断标准**: 非组件文件（utils、hooks、services）使用小驼峰命名

### FE-NAME-03：变量和函数使用 camelCase
- **严重性**: important
- **规范来源**: coding_standard.md §二·2.1.3 变量与函数命名
- **判断标准**: 局部变量、函数名使用小驼峰，不使用下划线或匈牙利命名法
- **示例**:
  \`\`\`typescript
  ✅ const claimAmount = ref(0);
  ✅ function handleSubmit() { }
  ❌ const claim_amount = ref(0);
  ❌ function HandleSubmit() { }
  \`\`\`

### FE-NAME-04：常量使用 UPPER_SNAKE_CASE
- **严重性**: suggestion
- **规范来源**: coding_standard.md §二·2.1.3 变量与函数命名
- **判断标准**: 模块级常量使用全大写下划线分隔

### FE-NAME-05：接口/类型名使用 PascalCase 且语义明确
- **严重性**: important
- **规范来源**: coding_standard.md §二·2.1.4 类型与接口命名
- **判断标准**: TypeScript 接口和类型别名使用大驼峰，不加 \`I\` 前缀（除非团队约定）；名称体现业务含义
- **示例**:
  \`\`\`typescript
  ✅ interface ClaimFormData { }
  ✅ type ClaimStatus = 'pending' | 'approved' | 'rejected';
  ❌ interface IData { }  // 语义不明
  \`\`\`

### FE-NAME-06：事件处理函数使用 handle/on 前缀
- **严重性**: suggestion
- **规范来源**: coding_standard.md §二·2.1.3 变量与函数命名
- **判断标准**: 组件内事件处理函数使用 \`handle\` 前缀（如 \`handleSubmit\`），emit 事件使用 \`on\` 前缀

---

## FE-STYLE：代码格式

### FE-STYLE-01：使用项目配置的格式化工具
- **严重性**: important
- **规范来源**: coding_standard.md §2.1
- **判断标准**: 代码格式须符合项目 \`.prettierrc\` / \`.eslintrc\` 配置，不存在格式化冲突
- **示例**:
  \`\`\`typescript
  // 假设项目配置 printWidth: 100, singleQuote: true
  ✅ const message = 'hello world';
  ❌ const message = "hello world";  // 双引号不符合配置
  \`\`\`

### FE-STYLE-02：单文件组件不超过 400 行
- **严重性**: suggestion
- **规范来源**: coding_standard.md §2.2
- **判断标准**: Vue SFC 或 React 组件文件不超过 400 行，超过须拆分子组件

### FE-STYLE-03：模板/JSX 嵌套不超过 4 层
- **严重性**: suggestion
- **规范来源**: coding_standard.md §2.3
- **判断标准**: 模板或 JSX 中 DOM 嵌套层级不超过 4 层，超过须提取子组件

### FE-STYLE-04：CSS 类名使用 BEM 或项目约定规范
- **严重性**: nit
- **规范来源**: coding_standard.md §2.4
- **判断标准**: 自定义 CSS 类名遵循 BEM 命名或项目约定的 CSS Modules / scoped 方案

---

## FE-DOC：注释规范

### FE-DOC-01：组件须有功能说明注释
- **严重性**: important
- **规范来源**: coding_standard.md §2.3.1
- **判断标准**: 每个组件文件顶部须有注释说明组件职责和使用场景
- **示例**:
  \`\`\`vue
  ✅
  <!--
    ClaimDetail - 理赔详情页
    展示理赔单详细信息，支持审批操作
  -->
  <template>...</template>

  ❌
  <template>...</template>  <!-- 缺少组件说明 -->
  \`\`\`

### FE-DOC-02：复杂逻辑须有注释
- **严重性**: suggestion
- **规范来源**: coding_standard.md §2.3.2
- **判断标准**: 复杂的计算逻辑、状态流转、条件判断须有解释性注释

### FE-DOC-03：公共函数/hooks 须有 JSDoc
- **严重性**: important
- **规范来源**: coding_standard.md §2.3.3
- **判断标准**: 导出的工具函数和自定义 hooks 须有 JSDoc 注释，包含参数和返回值说明
- **示例**:
  \`\`\`typescript
  ✅
  /**
   * 格式化理赔金额
   * @param amount - 金额（分）
   * @returns 格式化后的金额字符串（元）
   */
  export function formatClaimAmount(amount: number): string { }

  ❌
  export function formatClaimAmount(amount: number): string { } // 缺少 JSDoc
  \`\`\`

### FE-DOC-04：TODO/FIXME 须关联任务编号
- **严重性**: nit
- **规范来源**: coding_standard.md §2.3.4
- **判断标准**: 代码中的 \`TODO\` 和 \`FIXME\` 须关联任务编号或说明计划处理时间

---

## FE-AI：AI-Generate 标记

> AI-Generate 标记的完整检查由 \`cross-cutting-review.md\` CC-AI-* 统一覆盖（含前后端）。
> 前端特有补充：Vue SFC 和样式文件的标记位置。

### FE-AI-01：Vue SFC 中的 AI 标记位置
- **严重性**: important
- **规范来源**: coding_standard.md §二·2.3.5
- **判断标准**: Vue SFC 在 \`<script>\` 或 \`<script setup>\` 内第一行标注 \`// AI-Generate\`；样式文件使用 \`/* AI-Generate */\`

---

## FE-ARCH：架构设计

### FE-ARCH-01：目录结构符合项目约定
- **严重性**: important
- **规范来源**: coding_standard.md §3.1
- **判断标准**: 新增文件放置在正确的目录层级（pages/components/hooks/services/utils/types）
- **示例**:
  \`\`\`
  ✅ src/pages/claim/ClaimDetail.vue
  ✅ src/hooks/useClaimStatus.ts
  ❌ src/ClaimDetail.vue  // 未按目录结构放置
  \`\`\`

### FE-ARCH-02：页面与组件职责分离
- **严重性**: important
- **规范来源**: coding_standard.md §3.2
- **判断标准**: 页面组件负责数据获取和状态管理，UI 组件负责展示和交互，不混合职责
- **示例**:
  \`\`\`vue
  ✅ <!-- 页面组件：负责数据 -->
  <template>
    <ClaimForm :data="formData" @submit="handleSubmit" />
  </template>

  ❌ <!-- 页面组件中直接写大量 UI 细节和 API 调用混在一起 -->
  \`\`\`

### FE-ARCH-03：路由配置与设计文档一致
- **严重性**: important
- **规范来源**: frontend-design.md
- **判断标准**: 路由路径、参数、守卫配置须与 \`frontend-design.md\` 中的路由设计一致

### FE-ARCH-04：状态管理方案合理
- **严重性**: suggestion
- **规范来源**: coding_standard.md §3.4
- **判断标准**: 局部状态用组件内管理，跨组件共享状态用 Pinia/Redux/Zustand 等状态管理库，不滥用全局状态

---

## FE-COMP：组件设计

### FE-COMP-01：Props 定义完整且有类型
- **严重性**: important
- **规范来源**: coding_standard.md §4.1
- **判断标准**: Vue 使用 \`defineProps<T>()\` 或 \`PropType\`；React 使用 TypeScript interface 定义 props 类型
- **示例**:
  \`\`\`typescript
  // Vue 3
  ✅ const props = defineProps<{ claimId: number; readonly?: boolean }>();
  ❌ const props = defineProps(['claimId', 'readonly']); // 缺少类型

  // React
  ✅ interface ClaimDetailProps { claimId: number; readonly?: boolean; }
  ❌ function ClaimDetail(props: any) { } // any 类型
  \`\`\`

### FE-COMP-02：Emit 事件有类型定义
- **严重性**: suggestion
- **规范来源**: coding_standard.md §4.2
- **判断标准**: Vue 使用 \`defineEmits<T>()\` 定义事件类型；React 通过 props 回调函数类型约束

### FE-COMP-03：组件职责单一
- **严重性**: important
- **规范来源**: coding_standard.md §4.3
- **判断标准**: 单个组件只负责一个功能区域，不同时处理多个不相关的业务逻辑
- **示例**:
  \`\`\`
  ✅ ClaimForm.vue — 仅负责理赔表单
  ✅ ClaimTimeline.vue — 仅负责理赔时间线
  ❌ ClaimFormAndTimeline.vue — 同时处理表单和时间线（应拆分）
  \`\`\`

### FE-COMP-04：避免过深的 props 透传
- **严重性**: suggestion
- **规范来源**: coding_standard.md §4.4
- **判断标准**: props 透传不超过 2 层，超过须使用 provide/inject（Vue）或 Context（React）

### FE-COMP-05：列表渲染使用唯一 key
- **严重性**: important
- **规范来源**: coding_standard.md §4.5
- **判断标准**: \`v-for\`（Vue）或 \`map\`（React）渲染列表时须绑定唯一且稳定的 key，不使用 index
- **示例**:
  \`\`\`vue
  ✅ <div v-for="item in claims" :key="item.id">
  ❌ <div v-for="(item, index) in claims" :key="index">
  \`\`\`

### FE-COMP-06：表单校验规则完整
- **严重性**: important
- **规范来源**: coding_standard.md §4.6
- **判断标准**: 表单组件须定义校验规则，必填字段有 required 校验，格式字段有 pattern 校验

---

## FE-TS：TypeScript 规范

### FE-TS-01：禁止使用 any 类型
- **严重性**: important
- **规范来源**: coding_standard.md §5.1
- **判断标准**: 不使用 \`any\` 类型，确需宽泛类型时使用 \`unknown\` 并做类型收窄
- **示例**:
  \`\`\`typescript
  ✅ function parse(input: unknown): ClaimData {
      if (isClaimData(input)) return input;
      throw new Error('Invalid data');
  }
  ❌ function parse(input: any): ClaimData { return input; }
  \`\`\`

### FE-TS-02：接口响应有类型定义
- **严重性**: important
- **规范来源**: coding_standard.md §5.2
- **判断标准**: API 请求和响应须有对应的 TypeScript 类型定义，不使用裸对象
- **示例**:
  \`\`\`typescript
  ✅ const { data } = await api.get<Result<ClaimVO>>('/claims/1');
  ❌ const { data } = await api.get('/claims/1'); // 响应无类型
  \`\`\`

### FE-TS-03：枚举/联合类型用于有限状态
- **严重性**: suggestion
- **规范来源**: coding_standard.md §5.3
- **判断标准**: 有限状态集合使用 \`enum\` 或字面量联合类型，不使用 \`string\` 或 \`number\`

### FE-TS-04：类型定义集中管理
- **严重性**: suggestion
- **规范来源**: coding_standard.md §5.4
- **判断标准**: 共享类型定义放在 \`types/\` 目录，不在组件内部重复定义

### FE-TS-05：严格模式开启
- **严重性**: important
- **规范来源**: coding_standard.md §5.5
- **判断标准**: \`tsconfig.json\` 中 \`strict: true\`，不使用 \`@ts-ignore\` 或 \`@ts-nocheck\` 绕过检查
- **示例**:
  \`\`\`typescript
  ✅ // tsconfig.json: "strict": true
  ❌ // @ts-ignore  // 不应绕过类型检查
  ❌ // @ts-nocheck // 整个文件跳过检查
  \`\`\`

---

## FE-API：API 集成

### FE-API-01：API 调用封装在 service 层
- **严重性**: important
- **规范来源**: coding_standard.md §6.1
- **判断标准**: API 请求不直接写在组件中，须封装在 \`services/\` 或 \`api/\` 目录的模块中
- **示例**:
  \`\`\`typescript
  ✅ // services/claimService.ts
  export const claimService = {
      getDetail: (id: number) => request.get<ClaimVO>(\`/claims/\${id}\`),
  };
  // 组件中
  const data = await claimService.getDetail(id);

  ❌ // 组件中直接调用
  const data = await axios.get(\`/claims/\${id}\`);
  \`\`\`

### FE-API-02：请求/响应拦截器统一处理
- **严重性**: suggestion
- **规范来源**: coding_standard.md §6.2
- **判断标准**: Token 注入、错误码处理、loading 状态等通过拦截器统一处理，不在每个请求中重复

### FE-API-03：错误处理覆盖完整
- **严重性**: important
- **规范来源**: coding_standard.md §6.3
- **判断标准**: API 调用须有 try-catch 或 \`.catch()\` 处理，用户可见的错误须有友好提示
- **示例**:
  \`\`\`typescript
  ✅ try {
      await claimService.submit(formData);
      message.success('提交成功');
  } catch (error) {
      message.error('提交失败，请稍后重试');
  }

  ❌ await claimService.submit(formData); // 未处理异常
  \`\`\`

### FE-API-04：API 路径与设计文档一致
- **严重性**: blocking
- **规范来源**: frontend-design.md + backend-design.md
- **判断标准**: 前端调用的 API 路径须与后端设计文档中的接口定义一致

### FE-API-05：避免重复请求
- **严重性**: suggestion
- **规范来源**: coding_standard.md §6.5
- **判断标准**: 表单提交等操作须有防重复提交机制（loading 状态、debounce、请求取消）。**深度检查见 FQ-RACE-03（frontend-quality-checklist.md）**

---

## FE-ERR：错误处理

### FE-ERR-01：全局错误边界
- **严重性**: important
- **规范来源**: coding_standard.md §7.1
- **判断标准**: 应用须有全局错误边界（Vue: \`errorHandler\`；React: \`ErrorBoundary\`），防止白屏
- **示例**:
  \`\`\`typescript
  // Vue
  ✅ app.config.errorHandler = (err, vm, info) => {
      logger.error(err);
      showErrorPage();
  };

  // React
  ✅ <ErrorBoundary fallback={<ErrorPage />}>
      <App />
  </ErrorBoundary>
  \`\`\`

### FE-ERR-02：异步操作有 loading 和 error 状态
- **严重性**: suggestion
- **规范来源**: coding_standard.md §7.2
- **判断标准**: 数据请求须有 loading、error、empty 三种状态的 UI 反馈

### FE-ERR-03：表单提交失败保留用户输入
- **严重性**: important
- **规范来源**: coding_standard.md §7.3
- **判断标准**: 表单提交失败后不清空用户已填写的数据，允许用户修改后重试。**深度检查见 FQ-UX-04（frontend-quality-checklist.md）**

---

## FE-PERF：性能优化

### FE-PERF-01：大列表使用虚拟滚动
- **严重性**: suggestion
- **规范来源**: performance-optimization §1.1
- **判断标准**: 列表数据超过 100 条时，须使用虚拟滚动（virtual scroll）方案

### FE-PERF-02：路由懒加载
- **严重性**: important
- **规范来源**: performance-optimization §1.2
- **判断标准**: 页面级路由组件须使用动态 import 实现懒加载
- **示例**:
  \`\`\`typescript
  ✅ const ClaimDetail = () => import('@/pages/claim/ClaimDetail.vue');
  ❌ import ClaimDetail from '@/pages/claim/ClaimDetail.vue'; // 同步导入
  \`\`\`

### FE-PERF-03：避免不必要的重渲染
- **严重性**: suggestion
- **规范来源**: performance-optimization §1.3
- **判断标准**: Vue 使用 \`computed\`/\`shallowRef\` 避免深层响应；React 使用 \`useMemo\`/\`useCallback\`/\`React.memo\` 优化

### FE-PERF-04：图片资源优化
- **严重性**: nit
- **规范来源**: performance-optimization §1.4
- **判断标准**: 图片使用合适格式（WebP 优先）、设置尺寸属性、大图使用懒加载

### FE-PERF-05：避免内存泄漏
- **严重性**: important
- **规范来源**: performance-optimization §1.5
- **判断标准**: 组件卸载时清理定时器、事件监听、WebSocket 连接等副作用
- **示例**:
  \`\`\`typescript
  // Vue
  ✅ onUnmounted(() => {
      clearInterval(timer);
      window.removeEventListener('resize', handleResize);
  });

  // React
  ✅ useEffect(() => {
      const timer = setInterval(poll, 5000);
      return () => clearInterval(timer);
  }, []);

  ❌ // 未清理定时器，组件卸载后仍在执行
  onMounted(() => { setInterval(poll, 5000); });
  \`\`\`

---

## FE-TOOL：工具配置遵循

### FE-TOOL-01：ESLint 无报错
- **严重性**: important
- **规范来源**: coding_standard.md §8.1
- **判断标准**: 代码通过项目 ESLint 检查，无 error 级别报告；warning 须有合理说明

### FE-TOOL-02：TypeScript 编译无报错
- **严重性**: blocking
- **规范来源**: coding_standard.md §8.2
- **判断标准**: \`tsc --noEmit\` 无编译错误

### FE-TOOL-03：Stylelint 无报错
- **严重性**: nit
- **规范来源**: coding_standard.md §8.3
- **判断标准**: 样式文件通过 Stylelint 检查

### FE-TOOL-04：提交前 lint-staged 通过
- **严重性**: suggestion
- **规范来源**: coding_standard.md §8.4
- **判断标准**: 项目配置了 \`lint-staged\` + \`husky\`，提交前自动执行格式化和 lint 检查