# 组件设计模式

> 本文档示例均使用 TypeScript，遵循类型安全最佳实践。

## 1. 组件设计原则

### 1.1 单一职责原则
每个组件只负责一个功能，保持组件的简洁和可维护性。

**示例**：
\`\`\`vue
<!-- 好的设计 -->
<UserCard :user="user" />

<!-- 不好的设计 -->
<UserListWithSearchAndFilterAndPagination />
\`\`\`

### 1.2 组合优于继承
通过组合多个小组件来构建复杂功能，而不是创建一个巨大的组件。

**示例**：
\`\`\`vue
<!-- 好的设计 -->
<DataTable>
  <TableHeader />
  <TableBody />
  <TablePagination />
</DataTable>

<!-- 不好的设计 -->
<ComplexDataTableWithAllFeatures />
\`\`\`

### 1.3 组件通信原则
- Props向下传递数据
- Events向上传递事件
- 避免直接修改props
- 使用provide/inject进行跨层级通信

## 2. 组件分类

### 2.1 展示型组件（Presentational Components）
只负责UI展示，不包含业务逻辑。

**特点**：
- 接收props数据
- 触发events事件
- 不直接调用API
- 不包含状态管理

**示例**：
\`\`\`vue
<template>
  <div class="user-card">
    <img :src="user.avatar" :alt="user.name" />
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
  </div>
</template>

<script setup lang="ts">
interface User {
  avatar: string
  name: string
  email: string
}

defineProps<{
  user: User
}>()
</script>
\`\`\`

### 2.2 容器型组件（Container Components）
负责数据获取和业务逻辑，不直接渲染UI。

**特点**：
- 包含业务逻辑
- 调用API获取数据
- 管理状态
- 渲染展示型组件

**示例**：
\`\`\`vue
<template>
  <UserList
    :users="users"
    :loading="loading"
    :error="error"
    @refresh="fetchUsers"
  />
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import UserList from './UserList.vue'

const users = ref([])
const loading = ref(false)
const error = ref(null)

const fetchUsers = async () => {
  loading.value = true
  try {
    users.value = await api.getUsers()
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchUsers()
})
</script>
\`\`\`

### 2.3 布局型组件（Layout Components）
负责页面布局结构，不包含具体业务逻辑。

**示例**：
\`\`\`vue
<template>
  <div class="default-layout">
    <AppHeader />
    <div class="layout-content">
      <AppSidebar />
      <main class="main-content">
        <slot />
      </main>
    </div>
    <AppFooter />
  </div>
</template>
\`\`\`

## 3. 组件通信模式

### 3.1 Props 和 Events
最基础的父子组件通信方式。

**父组件**：
\`\`\`vue
<template>
  <ChildComponent
    :message="parentMessage"
    @update="handleUpdate"
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'
import ChildComponent from './ChildComponent.vue'

const parentMessage = ref('Hello from parent')

const handleUpdate = (newValue: string) => {
  parentMessage.value = newValue
}
</script>
\`\`\`

**子组件**：
\`\`\`vue
<template>
  <div>
    <p>{{ message }}</p>
    <button @click="updateMessage">Update</button>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  message: string
}>()

const emit = defineEmits<{
  update: [value: string]
}>()

const updateMessage = () => {
  emit('update', 'Hello from child')
}
</script>
\`\`\`

### 3.2 Provide 和 Inject
跨层级组件通信，避免props层层传递。

**祖先组件**：
\`\`\`vue
<script setup lang="ts">
import { provide, ref } from 'vue'

const theme = ref('light')

provide('theme', theme)
</script>
\`\`\`

**后代组件**：
\`\`\`vue
<script setup lang="ts">
import { inject } from 'vue'

const theme = inject('theme')
</script>
\`\`\`

### 3.3 状态管理
使用Pinia/Redux等状态管理工具进行全局状态管理。

**Store定义**：
\`\`\`typescript
// stores/user.ts
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: null,
    token: ''
  }),
  actions: {
    setUserInfo(info: UserInfo) {
      this.userInfo = info
    },
    setToken(token: string) {
      this.token = token
    }
  }
})
\`\`\`

**组件中使用**：
\`\`\`vue
<script setup lang="ts">
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

userStore.setUserInfo({ name: 'John' })
</script>
\`\`\`

### 3.4 事件总线
适用于简单的跨组件通信（Vue 3推荐使用Mitt）。

**安装**：
\`\`\`bash
npm install mitt
\`\`\`

**使用**：
\`\`\`typescript
// utils/eventBus.ts
import mitt from 'mitt'
export const eventBus = mitt()

// 组件A
eventBus.emit('user-updated', { name: 'John' })

// 组件B
eventBus.on('user-updated', (data) => {
  console.log(data)
})
\`\`\`

## 4. 组件复用模式

### 4.1 组合式函数（Composables）
Vue 3推荐的状态逻辑复用方式。

**示例**：
\`\`\`typescript
// composables/useTable.ts
import { ref } from 'vue'

export function useTable<T>(api: (params: any) => Promise<T[]>) {
  const data = ref<T[]>([])
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const fetch = async (params: any) => {
    loading.value = true
    try {
      data.value = await api(params)
    } catch (err) {
      error.value = err as Error
    } finally {
      loading.value = false
    }
  }

  return {
    data,
    loading,
    error,
    fetch
  }
}
\`\`\`

**使用**：
\`\`\`vue
<script setup lang="ts">
import { useTable } from '@/composables/useTable'
import { getUsers } from '@/services/api'

const { data, loading, error, fetch } = useTable(getUsers)

fetch({ page: 1, pageSize: 10 })
</script>
\`\`\`

### 4.2 自定义Hooks
React推荐的状态逻辑复用方式。

**示例**：
\`\`\`typescript
// hooks/useTable.ts
import { useState, useEffect } from 'react'

export function useTable<T>(api: (params: any) => Promise<T[]>) {
  const [data, setData] = useState<T[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const fetch = async (params: any) => {
    setLoading(true)
    try {
      const result = await api(params)
      setData(result)
    } catch (err) {
      setError(err as Error)
    } finally {
      setLoading(false)
    }
  }

  return { data, loading, error, fetch }
}
\`\`\`

### 4.3 高阶组件（HOC）
React中用于组件逻辑复用的高级模式。

**示例**：
\`\`\`typescript
function withLoading<P>(Component: React.ComponentType<P>) {
  return (props: P & { loading: boolean }) => {
    if (props.loading) {
      return <Loading />
    }
    return <Component {...props} />
  }
}

// 使用
const UserListWithLoading = withLoading(UserList)
\`\`\`

### 4.4 渲染属性（Render Props）
React中通过props传递函数来复用逻辑。

**示例**：
\`\`\`typescript
interface MouseProps {
  render: (state: { x: number; y: number }) => React.ReactNode
}

function Mouse({ render }: MouseProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 })

  const handleMouseMove = (e: MouseEvent) => {
    setPosition({ x: e.clientX, y: e.clientY })
  }

  return <div onMouseMove={handleMouseMove}>{render(position)}</div>
}

// 使用
<Mouse render={({ x, y }) => <p>Mouse: {x}, {y}</p>} />
\`\`\`

### 4.5 插槽（Slots）
Vue中通过插槽实现内容分发。

**作用域插槽**：
\`\`\`vue
<!-- 父组件 -->
<DataTable :data="users">
  <template #default="{ item }">
    <UserCard :user="item" />
  </template>
</DataTable>

<!-- 子组件 -->
<template>
  <div v-for="item in data" :key="item.id">
    <slot :item="item" />
  </div>
</template>
\`\`\`

## 5. 组件优化模式

### 5.1 懒加载组件
使用动态导入实现组件懒加载。

**Vue**：
\`\`\`vue
<script setup lang="ts">
import { defineAsyncComponent } from 'vue'

const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)
</script>
\`\`\`

**React**：
\`\`\`typescript
import { lazy, Suspense } from 'react'

const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  )
}
\`\`\`

### 5.2 虚拟滚动
长列表性能优化。

**Vue**：
\`\`\`vue
<template>
  <RecycleScroller
    :items="items"
    :item-size="50"
    key-field="id"
  >
    <template #default="{ item }">
      <div class="item">{{ item.name }}</div>
    </template>
  </RecycleScroller>
</template>
\`\`\`

**React**：
\`\`\`typescript
import { FixedSizeList } from 'react-window'

function List({ items }) {
  return (
    <FixedSizeList
      height={400}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{items[index].name}</div>
      )}
    </FixedSizeList>
  )
}
\`\`\`

### 5.3 防抖和节流
优化频繁触发的事件。

**防抖**：
\`\`\`typescript
import { debounce } from 'lodash-es'

const handleSearch = debounce((keyword: string) => {
  // 搜索逻辑
}, 300)
\`\`\`

**节流**：
\`\`\`typescript
import { throttle } from 'lodash-es'

const handleScroll = throttle(() => {
  // 滚动逻辑
}, 100)
\`\`\`

### 5.4 计算属性缓存
Vue中使用computed缓存计算结果。

\`\`\`vue
<script setup lang="ts">
import { computed, ref } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

const fullName = computed(() => {
  return \`\${firstName.value} \${lastName.value}\`
})
</script>
\`\`\`

### 5.5 React.memo和useMemo
React中使用memo和useMemo优化性能。

**React.memo**：
\`\`\`typescript
const MemoComponent = React.memo(function Component({ data }) {
  return <div>{data}</div>
})
\`\`\`

**useMemo**：
\`\`\`typescript
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(a, b)
}, [a, b])
\`\`\`

## 6. 组件设计最佳实践

### 6.1 Props设计
- 使用TypeScript定义props类型
- 提供默认值
- 使用对象传递多个相关props
- 避免props过多（>5个考虑使用对象）

**示例**：
\`\`\`typescript
interface Props {
  user: User
  loading?: boolean
  onUpdate?: (user: User) => void
}

const props = withDefaults(defineProps<Props>(), {
  loading: false
})
\`\`\`

### 6.2 Events设计
- 使用明确的事件名称
- 传递必要的参数
- 使用TypeScript定义事件类型

**示例**：
\`\`\`typescript
const emit = defineEmits<{
  'update:user': [user: User]
  delete: [id: number]
}>()
\`\`\`

### 6.3 Slots设计
- 提供默认插槽
- 提供具名插槽
- 提供作用域插槽
- 文档化插槽用途

**示例**：
\`\`\`vue
<template>
  <div class="card">
    <div class="card-header">
      <slot name="header">
        <h3>默认标题</h3>
      </slot>
    </div>
    <div class="card-body">
      <slot />
    </div>
    <div class="card-footer">
      <slot name="footer" :actions="actions" />
    </div>
  </div>
</template>
\`\`\`

### 6.4 样式隔离
- 使用CSS Modules
- 使用Scoped CSS（Vue）
- 使用CSS-in-JS
- 避免全局样式污染

**Vue Scoped CSS**：
\`\`\`vue
<style scoped>
.card {
  padding: 16px;
}
</style>
\`\`\`

**CSS Modules**：
\`\`\`typescript
import styles from './Card.module.css'

function Card() {
  return <div className={styles.card}>...</div>
}
\`\`\`

### 6.5 组件文档
- 提供组件描述
- 列出所有props
- 列出所有events
- 列出所有slots
- 提供使用示例

## 7. 常见组件模式

### 7.1 受控组件
组件的值由父组件控制。

\`\`\`vue
<template>
  <input
    :value="modelValue"
    @input="$emit('update:modelValue', $event.target.value)"
  />
</template>

<script setup lang="ts">
defineProps<{
  modelValue: string
}>()

defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>
\`\`\`

### 7.2 非受控组件
组件内部管理状态。

\`\`\`vue
<template>
  <input v-model="inputValue" @change="handleChange" />
</template>

<script setup lang="ts">
import { ref } from 'vue'

const inputValue = ref('')

const emit = defineEmits<{
  change: [value: string]
}>()

const handleChange = () => {
  emit('change', inputValue.value)
}
</script>
\`\`\`

### 7.3 表单组件
封装表单验证和提交逻辑。

\`\`\`vue
<template>
  <form @submit.prevent="handleSubmit">
    <slot />
  </form>
</template>

<script setup lang="ts">
import { provide, ref } from 'vue'

const formRef = ref()
const errors = ref<Record<string, string>>({})

const validate = () => {
  // 验证逻辑
}

const handleSubmit = () => {
  if (validate()) {
    emit('submit')
  }
}

provide('form', {
  formRef,
  errors
})

defineEmits<{
  submit: []
}>()

defineExpose({
  validate
})
</script>
\`\`\`

### 7.4 列表组件
封装列表渲染逻辑。

\`\`\`vue
<template>
  <div class="list">
    <div v-for="item in items" :key="item.id" class="list-item">
      <slot :item="item" :index="index" />
    </div>
    <div v-if="loading" class="list-loading">加载中...</div>
    <div v-if="!items.length && !loading" class="list-empty">
      <slot name="empty">暂无数据</slot>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  items: any[]
  loading?: boolean
}>()
</script>
\`\`\`

### 7.5 弹窗组件
封装弹窗显示/隐藏逻辑。

\`\`\`vue
<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="visible" class="modal-overlay" @click="handleClose">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <slot name="header">
              <h3>{{ title }}</h3>
            </slot>
            <button class="modal-close" @click="handleClose">×</button>
          </div>
          <div class="modal-body">
            <slot />
          </div>
          <div class="modal-footer">
            <slot name="footer">
              <button @click="handleClose">取消</button>
              <button type="primary" @click="handleConfirm">确定</button>
            </slot>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { watch } from 'vue'

const props = defineProps<{
  visible: boolean
  title?: string
}>()

const emit = defineEmits<{
  'update:visible': [visible: boolean]
  confirm: []
}>()

const handleClose = () => {
  emit('update:visible', false)
}

const handleConfirm = () => {
  emit('confirm')
}
</script>
\`\`\`

## 8. 组件测试模式

### 8.1 单元测试
测试组件的独立功能。

\`\`\`typescript
import { mount } from '@vue/test-utils'
import Button from './Button.vue'

describe('Button', () => {
  it('renders correctly', () => {
    const wrapper = mount(Button, {
      props: { text: 'Click me' }
    })
    expect(wrapper.text()).toBe('Click me')
  })

  it('emits click event', async () => {
    const wrapper = mount(Button)
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })
})
\`\`\`

### 8.2 快照测试
确保组件UI的一致性。

\`\`\`typescript
it('matches snapshot', () => {
  const wrapper = mount(Button)
  expect(wrapper.html()).toMatchSnapshot()
})
\`\`\`

### 8.3 集成测试
测试组件之间的交互。

\`\`\`typescript
it('integrates with parent component', async () => {
  const wrapper = mount(ParentComponent)
  await wrapper.find('button').trigger('click')
  expect(wrapper.find('.result').text()).toBe('Success')
})
\`\`\`