# 前端业务实现质量检查项

> 本检查项聚焦"前端交互健壮性与业务实现正确性"，与 `frontend-review-checklist.md`（编码规范合规）互补。
> 审查基线来自上游设计文档（PC Web 分端设计文件 `frontend-web.md`（经入口 `frontend-design.md` 定位）、`backend-design.md`）和任务拆分（`task/task-split.md`）。
> 每个检查项标注严重性、审查基线来源、判断标准和**适用粒度**。blocking / important 级别附带正反示例。
> 同时覆盖 Vue 和 React 场景。若项目约定与本检查项冲突，以项目约定优先。
>
> **适用粒度说明**：
> - **模块级**：在按 task-split.md 功能点分组的模块审查中执行。
> - **全局级**：在全局影响分析（步骤 5）中执行。

---

## FQ-STATE：前端状态一致性

> 审查基线：`frontend-web.md` — 组件设计、状态管理方案。

### FQ-STATE-01 [I] [P1]：操作后数据刷新
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 组件设计
- **判断标准**: 增删改操作成功后，相关列表/详情页数据是否同步刷新？编辑保存后返回列表是否看到最新数据？
- **示例**:
  ```typescript
  ✅ async function handleSubmit() {
      await claimService.update(formData);
      message.success('保存成功');
      await fetchList(); // 刷新列表数据
  }

  ❌ async function handleSubmit() {
      await claimService.update(formData);
      message.success('保存成功');
      // 未刷新列表，用户看到的仍是旧数据
  }
  ```

### FQ-STATE-02 [I] [P1]：多视图数据同步
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 状态管理
- **判断标准**: 同一数据在多个组件/页面展示时，一处修改后其他视图是否同步更新？（如侧边栏计数与列表条数）

### FQ-STATE-03 [I] [P1]：乐观更新回滚
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: UI 先行更新（如点赞、收藏）的场景，接口失败时 UI 是否回滚到操作前状态？是否通知用户？
- **示例**:
  ```typescript
  ✅ async function handleLike() {
      const prevState = liked.value;
      liked.value = true; // 乐观更新
      try {
          await claimService.like(id);
      } catch {
          liked.value = prevState; // 回滚
          message.error('操作失败，请重试');
      }
  }

  ❌ async function handleLike() {
      liked.value = true; // 乐观更新
      await claimService.like(id); // 失败时 UI 不回滚
  }
  ```

### FQ-STATE-04 [S] [P2]：缓存数据时效
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 前端缓存的数据（localStorage/sessionStorage/内存缓存）是否有过期机制？是否在关键操作前重新拉取？

### FQ-STATE-05 [I] [P1]：路由切换状态清理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 路由设计
- **判断标准**: 离开页面时，定时器、轮询、WebSocket 订阅是否清理？返回页面时状态是否正确初始化？

---

## FQ-RACE：竞态与并发

> 审查基线：`frontend-web.md` — 交互设计、数据获取策略。

### FQ-RACE-01 [I] [P1]：请求竞态处理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 数据获取
- **判断标准**: 快速切换 Tab/路由/筛选条件时，旧请求的响应是否被丢弃？是否使用 AbortController 或请求标记取消过期请求？
- **示例**:
  ```typescript
  ✅ // 使用 AbortController 取消过期请求
  let controller: AbortController | null = null;
  async function fetchData(params: QueryParams) {
      controller?.abort();
      controller = new AbortController();
      const { data } = await api.get('/claims', {
          params,
          signal: controller.signal,
      });
      list.value = data;
  }

  ❌ async function fetchData(params: QueryParams) {
      const { data } = await api.get('/claims', { params });
      list.value = data; // 快速切换时旧请求响应可能覆盖新数据
  }
  ```

### FQ-RACE-02 [I] [P1]：搜索防抖
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: 搜索框/筛选器连续输入时是否有 debounce？是否取消前一次未完成的搜索请求？
- **示例**:
  ```typescript
  ✅ const debouncedSearch = useDebounceFn((keyword: string) => {
      fetchList({ keyword });
  }, 300);

  ❌ watch(keyword, (val) => {
      fetchList({ keyword: val }); // 每次输入都立即请求
  });
  ```

### FQ-RACE-03 [B] [P0]：防重复提交
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 表单设计
- **判断标准**: 表单提交/按钮点击后是否禁用按钮或加 loading 锁？连续快速点击是否只触发一次请求？
- **示例**:
  ```typescript
  ✅ const submitting = ref(false);
  async function handleSubmit() {
      if (submitting.value) return;
      submitting.value = true;
      try {
          await claimService.submit(formData);
          message.success('提交成功');
      } finally {
          submitting.value = false;
      }
  }
  // 模板中: <Button :loading="submitting" @click="handleSubmit">提交</Button>

  ❌ async function handleSubmit() {
      await claimService.submit(formData); // 无 loading 锁，快速双击会重复提交
  }
  ```

### FQ-RACE-04 [S] [P2]：并发编辑冲突
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: 多人同时编辑同一数据时是否有冲突检测？（如基于版本号的乐观锁提示"数据已被他人修改"）

---

## FQ-API：接口交互健壮性

> 审查基线：`frontend-web.md` — 接口对齐表、错误处理章节；`backend-design.md` — 错误码。

### FQ-API-01 [I] [P1]：HTTP 状态码全覆盖
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 错误处理
- **判断标准**: 是否处理了 401（token 过期→刷新/重登录）、403（无权限→提示）、404（资源不存在→友好页面）、500（服务异常→重试提示）、网络断开（离线提示）？
- **示例**:
  ```typescript
  ✅ // 响应拦截器
  axios.interceptors.response.use(null, (error) => {
      if (error.response?.status === 401) {
          return refreshTokenAndRetry(error.config);
      }
      if (error.response?.status === 403) {
          message.error('您没有权限执行此操作');
          return Promise.reject(error);
      }
      if (!error.response) {
          message.error('网络连接异常，请检查网络');
      }
      return Promise.reject(error);
  });

  ❌ axios.interceptors.response.use(null, (error) => {
      message.error('请求失败'); // 所有错误一刀切提示
      return Promise.reject(error);
  });
  ```

### FQ-API-02 [I] [P1]：Token 过期自动刷新
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 认证方案
- **判断标准**: token 过期时是否自动刷新并重发原请求？刷新失败是否跳转登录页？并发请求时是否只刷新一次 token？

### FQ-API-03 [B] [P0]：接口数据防御性处理
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 接口对齐表
- **判断标准**: 后端返回 null/undefined/空数组/字段缺失时前端是否崩溃？是否有默认值兜底和可选链（?.）保护？
- **示例**:
  ```typescript
  ✅ const claimNo = data?.claimInfo?.claimNo ?? '—';
  const items = data?.list ?? [];

  ❌ const claimNo = data.claimInfo.claimNo; // data 或 claimInfo 为 null 时崩溃
  ```

### FQ-API-04 [I] [P1]：加载状态四态完整
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: 数据请求是否覆盖 loading（加载中）、success（成功展示）、error（失败+重试）、empty（空数据提示）四种 UI 状态？

### FQ-API-05 [I] [P1]：前端校验与后端对齐
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 接口对齐表 + backend-design.md §3.2 对外接口
- **判断标准**: 前端表单校验规则是否覆盖后端所有必填/格式/范围校验？后端拒绝时的错误信息是否能友好展示给用户？

### FQ-API-06 [I] [P1]：请求超时处理
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用
- **判断标准**: 接口请求是否设置了超时时间？超时后是否有用户可感知的提示和重试入口？

---

## FQ-UX：操作反馈与防护

> 审查基线：`frontend-web.md` — 交互设计、表单设计。

### FQ-UX-01 [I] [P1]：操作反馈即时性
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: 每个用户操作（点击/提交/删除/切换）是否都有即时视觉反馈（loading/toast/状态变化）？不存在"点了没反应"的情况？

### FQ-UX-02 [B] [P0]：危险操作二次确认
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: 删除、批量操作、不可逆操作是否有二次确认弹窗？确认文案是否明确告知后果？
- **示例**:
  ```typescript
  ✅ async function handleDelete(id: number) {
      await Modal.confirm({
          title: '确认删除',
          content: '删除后数据不可恢复，是否继续？',
      });
      await claimService.delete(id);
  }

  ❌ async function handleDelete(id: number) {
      await claimService.delete(id); // 无确认，误点直接删除
  }
  ```

### FQ-UX-03 [I] [P1]：表单数据丢失防护
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 表单设计
- **判断标准**: 表单填写过程中刷新页面/关闭浏览器/误点返回是否有"未保存提示"（beforeunload/路由守卫）？长表单是否有草稿自动保存？
- **示例**:
  ```typescript
  // Vue Router 路由守卫
  ✅ onBeforeRouteLeave((to, from, next) => {
      if (formDirty.value) {
          Modal.confirm({
              title: '离开页面？',
              content: '您有未保存的修改，确定离开吗？',
              onOk: () => next(),
              onCancel: () => next(false),
          });
      } else {
          next();
      }
  });

  ❌ // 无任何防护，用户误点返回直接丢失表单数据
  ```

### FQ-UX-04 [I] [P1]：提交失败保留输入
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 表单设计
- **判断标准**: 表单提交失败后是否保留用户已填写的数据？不清空表单让用户重新填写？

### FQ-UX-05 [S] [P2]：批量操作进度反馈
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 交互设计
- **判断标准**: 批量导入/导出/删除等耗时操作是否有进度条或进度提示？是否支持取消？

---

## FQ-AUTH：权限控制落地

> 审查基线：`frontend-web.md` — 权限设计章节。

### FQ-AUTH-01 [I] [P1]：按钮级权限与设计一致
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 权限设计
- **判断标准**: 设计文档中定义的按钮级权限（如"仅管理员可审批"）是否在前端落地？无权限时按钮是隐藏还是禁用，是否与设计一致？

### FQ-AUTH-02 [B] [P0]：路由级权限拦截
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 路由设计
- **判断标准**: 无权限用户直接访问受限路由（通过 URL 输入）是否被拦截并跳转到 403 页面或登录页？

### FQ-AUTH-03 [S] [P2]：权限数据动态获取
- **严重性**: suggestion
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 权限设计
- **判断标准**: 权限数据是否从后端动态获取而非前端硬编码？角色/权限变更后是否无需重新部署前端？

---

## FQ-DATA：数据安全与防御

> 审查基线：`frontend-web.md` — 安全设计；`backend-design.md` — 安全评估。

### FQ-DATA-01 [I] [P1]：敏感数据脱敏展示
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 安全设计
- **判断标准**: 页面上展示的手机号/身份证/银行卡是否脱敏（如 138****5678）？完整信息是否需要二次验证才能查看？

### FQ-DATA-02 [B] [P0]：敏感数据不存本地
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: localStorage/sessionStorage/cookie 中是否存储了密码、token 以外的敏感信息（身份证号、银行卡号）？

### FQ-DATA-03 [I] [P1]：控制台无敏感泄露
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: 浏览器控制台（console.log）和网络面板中是否泄露敏感数据？生产环境是否移除了调试日志？

### FQ-DATA-04 [B] [P0]：XSS 防护
- **严重性**: blocking
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: 用户输入的内容在页面渲染时是否经过转义？是否使用了 v-html/dangerouslySetInnerHTML 渲染未经清洗的用户输入？
- **示例**:
  ```vue
  ✅ <span>{{ userInput }}</span>  <!-- 框架自动转义 -->

  ❌ <div v-html="userInput"></div>  <!-- 未经清洗的用户输入，XSS 风险 -->
  ```


---

## FQ-STORE：Store 状态管理

> 审查基线：`frontend-web.md` — 认证/权限设计。

### FQ-STORE-01 [I] [P1]：Store 状态重置
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: frontend-web.md — 认证/权限设计
- **判断标准**: 用户登出或切换身份时，全局 Store 中的业务数据须被重置，避免用户 A 的数据残留到用户 B 的会话中。
- **示例**:
  ```typescript
  ❌ function logout() {
      removeToken();
      router.push('/login');
      // Store 中仍保留上一个用户的业务数据！
  }

  ✅ function logout() {
      removeToken();
      claimStore.$reset();
      userStore.$reset();
      router.push('/login');
  }
  ```

---

## FQ-SEC：前端安全

> 审查基线：通用安全规范。

### FQ-SEC-01 [I] [P0]：Open Redirect 防护
- **严重性**: important
- **适用粒度**: 模块级
- **审查基线**: 通用安全规范
- **判断标准**: 页面跳转（`window.location.href`、`router.push`）的目标 URL 如果来自用户输入或 URL 参数，须校验是否为可信域名。
- **示例**:
  ```typescript
  ❌ const redirectUrl = route.query.redirect as string;
  window.location.href = redirectUrl; // 可能被构造为恶意网站

  ✅ if (isInternalUrl(redirectUrl)) {
      router.push(redirectUrl);
  } else {
      router.push('/');
  }
  ```
