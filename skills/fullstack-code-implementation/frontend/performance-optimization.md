# 性能优化指南

> 本文档示例均使用 TypeScript，适用于 Vue 2/3 和 React 项目。

## 1. 代码优化

### 1.1 代码分割（Code Splitting）

#### 路由懒加载
**Vue 3**：
\`\`\`typescript
// router/index.ts
const routes = [
  {
    path: '/user',
    name: 'User',
    component: () => import('@/pages/User/index.vue')
  }
]
\`\`\`

**React**：
\`\`\`typescript
// router/index.tsx
import { lazy, Suspense } from 'react'

const User = lazy(() => import('@/pages/User'))

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <User />
    </Suspense>
  )
}
\`\`\`

#### 组件懒加载
**Vue 3**：
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

### 1.2 Tree Shaking

#### 使用ES Module
\`\`\`typescript
// 好的做法 - ES Module
import { debounce } from 'lodash-es'

// 不好的做法 - CommonJS
const { debounce } = require('lodash')
\`\`\`

#### 按需引入
\`\`\`typescript
// 好的做法 - 按需引入
import { Button } from 'element-plus'

// 不好的做法 - 全量引入
import ElementPlus from 'element-plus'
\`\`\`

### 1.3 移除未使用的代码

**Vite配置**：
\`\`\`typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'element-plus': ['element-plus'],
          'vue-vendor': ['vue', 'vue-router', 'pinia']
        }
      }
    }
  }
})
\`\`\`

## 2. 资源优化

### 2.1 图片优化

#### 使用WebP格式
\`\`\`html
<picture>
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="描述">
</picture>
\`\`\`

#### 图片懒加载
\`\`\`vue
<template>
  <img v-lazy="imageUrl" :alt="alt">
</template>
\`\`\`

\`\`\`typescript
// 自定义懒加载指令
import type { Directive } from 'vue'

const lazy: Directive<HTMLImageElement, string> = {
  mounted(el, binding) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          el.src = binding.value
          observer.unobserve(el)
        }
      })
    })

    observer.observe(el)
  }
}

export default lazy
\`\`\`

#### 响应式图片
\`\`\`html
<img
  src="image-small.jpg"
  srcset="image-medium.jpg 768w, image-large.jpg 1024w"
  sizes="(max-width: 768px) 100vw, 50vw"
  alt="描述">
\`\`\`

#### 图片压缩
\`\`\`typescript
// 使用vite-plugin-imagemin
import viteImagemin from 'vite-plugin-imagemin'

export default defineConfig({
  plugins: [
    viteImagemin({
      gifsicle: { optimizationLevel: 7 },
      optipng: { optimizationLevel: 7 },
      mozjpeg: { quality: 80 },
      webp: { quality: 80 }
    })
  ]
})
\`\`\`

### 2.2 字体优化

#### 字体子集化
\`\`\`typescript
// 使用vite-plugin-font-min
import fontMin from 'vite-plugin-font-min'

export default defineConfig({
  plugins: [
    fontMin({
      fontPath: 'src/assets/fonts',
      text: '常用汉字列表'
    })
  ]
})
\`\`\`

#### 字体预加载
\`\`\`html
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
\`\`\`

#### 使用系统字体
\`\`\`css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
\`\`\`

### 2.3 资源压缩

#### Gzip压缩
\`\`\`typescript
// vite.config.ts
import viteCompression from 'vite-plugin-compression'

export default defineConfig({
  plugins: [
    viteCompression({
      algorithm: 'gzip',
      ext: '.gz'
    })
  ]
})
\`\`\`

#### Brotli压缩
\`\`\`typescript
import viteCompression from 'vite-plugin-compression'

export default defineConfig({
  plugins: [
    viteCompression({
      algorithm: 'brotliCompress',
      ext: '.br'
    })
  ]
})
\`\`\`

## 3. 渲染优化

### 3.1 虚拟滚动

**Vue 3**：
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

<script setup lang="ts">
import { ref } from 'vue'
import { RecycleScroller } from 'vue-virtual-scroller'

const items = ref(Array.from({ length: 10000 }, (_, i) => ({
  id: i,
  name: \`Item \${i}\`
})))
</script>
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

### 3.2 防抖和节流

#### 防抖（Debounce）
\`\`\`typescript
import { debounce } from 'lodash-es'

const handleSearch = debounce((keyword: string) => {
  // 搜索逻辑
  console.log('搜索:', keyword)
}, 300)
\`\`\`

#### 节流（Throttle）
\`\`\`typescript
import { throttle } from 'lodash-es'

const handleScroll = throttle(() => {
  // 滚动逻辑
  console.log('滚动位置:', window.scrollY)
}, 100)
\`\`\`

### 3.3 计算属性缓存

**Vue 3**：
\`\`\`vue
<script setup lang="ts">
import { computed, ref } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

// 使用computed缓存计算结果
const fullName = computed(() => {
  return \`\${firstName.value} \${lastName.value}\`
})
</script>
\`\`\`

**React useMemo**：
\`\`\`typescript
import { useMemo, useState } from 'react'

function Component() {
  const [firstName, setFirstName] = useState('John')
  const [lastName, setLastName] = useState('Doe')

  const fullName = useMemo(() => {
    return \`\${firstName} \${lastName}\`
  }, [firstName, lastName])

  return <div>{fullName}</div>
}
\`\`\`

### 3.4 避免不必要的渲染

**Vue 3**：
\`\`\`vue
<script setup lang="ts">
import { shallowRef } from 'vue'

// 使用shallowRef避免深层响应式
const data = shallowRef({
  items: []
})

// 直接修改对象属性不会触发更新
data.value.items.push newItem

// 使用triggerRef手动触发更新
import { triggerRef } from 'vue'
triggerRef(data)
</script>
\`\`\`

**React**：
\`\`\`typescript
import { memo, useCallback, useMemo } from 'react'

// 使用memo避免不必要的重新渲染
const MemoComponent = memo(function Component({ data }) {
  return <div>{data}</div>
})

// 使用useCallback缓存函数
const handleClick = useCallback(() => {
  console.log('clicked')
}, [])

// 使用useMemo缓存计算结果
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(a, b)
}, [a, b])
\`\`\`

## 4. 缓存策略

### 4.1 接口数据缓存

\`\`\`typescript
// utils/cache.ts
const cache = new Map<string, { data: any; timestamp: number }>()
const CACHE_DURATION = 5 * 60 * 1000 // 5分钟

export function withCache<T>(
  key: string,
  fetcher: () => Promise<T>,
  duration: number = CACHE_DURATION
): Promise<T> {
  const cached = cache.get(key)

  if (cached && Date.now() - cached.timestamp < duration) {
    return Promise.resolve(cached.data)
  }

  return fetcher().then(data => {
    cache.set(key, { data, timestamp: Date.now() })
    return data
  })
}

export function clearCache(key?: string) {
  if (key) {
    cache.delete(key)
  } else {
    cache.clear()
  }
}
\`\`\`

### 4.2 本地存储缓存

\`\`\`typescript
// utils/storage.ts
export class LocalStorage {
  private static prefix = 'app_'

  static set(key: string, value: any, expire?: number) {
    const data = {
      value,
      expire: expire ? Date.now() + expire : null
    }
    localStorage.setItem(this.prefix + key, JSON.stringify(data))
  }

  static get<T>(key: string): T | null {
    const item = localStorage.getItem(this.prefix + key)
    if (!item) return null

    const data = JSON.parse(item)
    if (data.expire && Date.now() > data.expire) {
      this.remove(key)
      return null
    }

    return data.value
  }

  static remove(key: string) {
    localStorage.removeItem(this.prefix + key)
  }

  static clear() {
    Object.keys(localStorage)
      .filter(key => key.startsWith(this.prefix))
      .forEach(key => localStorage.removeItem(key))
  }
}
\`\`\`

### 4.3 使用SWR或React Query

**SWR**：
\`\`\`typescript
import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(res => res.json())

function UserList() {
  const { data, error, isLoading } = useSWR('/api/users', fetcher, {
    revalidateOnFocus: false,
    revalidateOnReconnect: false,
    dedupingInterval: 5000
  })

  if (error) return <div>加载失败</div>
  if (isLoading) return <div>加载中...</div>

  return <div>{JSON.stringify(data)}</div>
}
\`\`\`

**React Query**：
\`\`\`typescript
import { useQuery } from '@tanstack/react-query'

function UserList() {
  const { data, error, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUserList({ page: 1, pageSize: 10 }),
    staleTime: 5 * 60 * 1000, // 5分钟
    cacheTime: 10 * 60 * 1000 // 10分钟
  })

  if (error) return <div>加载失败</div>
  if (isLoading) return <div>加载中...</div>

  return <div>{JSON.stringify(data)}</div>
}
\`\`\`

## 5. 加载优化

### 5.1 首屏优化

#### 骨架屏
\`\`\`vue
<template>
  <div v-if="loading" class="skeleton">
    <div class="skeleton-header"></div>
    <div class="skeleton-content">
      <div class="skeleton-item"></div>
      <div class="skeleton-item"></div>
      <div class="skeleton-item"></div>
    </div>
  </div>
  <div v-else>
    <!-- 实际内容 -->
  </div>
</template>

<style scoped>
.skeleton {
  padding: 20px;
}
.skeleton-header {
  height: 40px;
  background: #f0f0f0;
  margin-bottom: 20px;
  border-radius: 4px;
}
.skeleton-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.skeleton-item {
  height: 60px;
  background: #f0f0f0;
  border-radius: 4px;
  animation: skeleton-loading 1.5s infinite;
}
@keyframes skeleton-loading {
  0% { opacity: 0.6; }
  50% { opacity: 1; }
  100% { opacity: 0.6; }
}
</style>
\`\`\`

#### 渐进式加载
\`\`\`typescript
// 先加载核心资源，再加载次要资源
import { defineAsyncComponent } from 'vue'

// 核心组件同步加载
import CoreComponent from './CoreComponent.vue'

// 次要组件异步加载
const SecondaryComponent = defineAsyncComponent(() =>
  import('./SecondaryComponent.vue')
)
\`\`\`

### 5.2 资源预加载

#### DNS预解析
\`\`\`html
<link rel="dns-prefetch" href="//api.example.com">
\`\`\`

#### 预连接
\`\`\`html
<link rel="preconnect" href="//api.example.com">
\`\`\`

#### 预加载关键资源
\`\`\`html
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="/images/hero.jpg" as="image">
\`\`\`

### 5.3 预取

\`\`\`typescript
// 预取用户可能访问的页面
import { onMounted } from 'vue'

onMounted(() => {
  // 预取用户列表页
  import('@/pages/User/List.vue')

  // 预取用户详情页
  import('@/pages/User/Detail.vue')
})
\`\`\`

## 6. 构建优化

### 6.1 Vite优化配置

\`\`\`typescript
// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import viteCompression from 'vite-plugin-compression'
import viteImagemin from 'vite-plugin-imagemin'

export default defineConfig({
  plugins: [
    vue(),
    viteCompression({
      algorithm: 'gzip',
      ext: '.gz'
    }),
    viteImagemin({
      gifsicle: { optimizationLevel: 7 },
      optipng: { optimizationLevel: 7 },
      mozjpeg: { quality: 80 }
    })
  ],
  build: {
    target: 'es2015',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          'element-plus': ['element-plus'],
          'vue-vendor': ['vue', 'vue-router', 'pinia'],
          'utils': ['lodash-es', 'dayjs']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  },
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: \`@import "@/assets/styles/variables.scss";\`
      }
    }
  }
})
\`\`\`

### 6.2 Webpack优化配置

\`\`\`javascript
// webpack.config.js
const TerserPlugin = require('terser-webpack-plugin')
const CompressionPlugin = require('compression-webpack-plugin')

module.exports = {
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            drop_console: true,
            drop_debugger: true
          }
        }
      })
    ],
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\\\/]node_modules[\\\\/]/,
          name: 'vendors',
          priority: 10
        },
        common: {
          name: 'common',
          minChunks: 2,
          priority: 5
        }
      }
    }
  },
  plugins: [
    new CompressionPlugin({
      algorithm: 'gzip',
      test: /\\.(js|css|html|svg)$/
    })
  ]
}
\`\`\`

## 7. 运行时优化

### 7.1 减少DOM操作

\`\`\`typescript
// 使用文档片段减少重绘
const fragment = document.createDocumentFragment()

for (let i = 0; i < 1000; i++) {
  const div = document.createElement('div')
  div.textContent = \`Item \${i}\`
  fragment.appendChild(div)
}

document.getElementById('container').appendChild(fragment)
\`\`\`

### 7.2 使用事件委托

\`\`\`typescript
// 好的做法 - 事件委托
document.getElementById('list').addEventListener('click', (e) => {
  const item = e.target.closest('.list-item')
  if (item) {
    console.log('Clicked item:', item.dataset.id)
  }
})

// 不好的做法 - 每个元素绑定事件
items.forEach(item => {
  item.addEventListener('click', () => {
    console.log('Clicked item:', item.dataset.id)
  })
})
\`\`\`

### 7.3 使用requestAnimationFrame

\`\`\`typescript
// 好的做法 - 使用requestAnimationFrame
function animate() {
  // 动画逻辑
  requestAnimationFrame(animate)
}

requestAnimationFrame(animate)

// 不好的做法 - 使用setInterval
setInterval(() => {
  // 动画逻辑
}, 16)
\`\`\`

## 8. 监控与分析

### 8.1 性能监控

\`\`\`typescript
// utils/performance.ts
export function measurePerformance(name: string, fn: () => void) {
  const start = performance.now()
  fn()
  const end = performance.now()
  console.log(\`\${name} took \${end - start}ms\`)
}

// 使用
measurePerformance('render', () => {
  renderComponent()
})
\`\`\`

### 8.2 使用Lighthouse

\`\`\`bash
# 安装Lighthouse
npm install -g lighthouse

# 运行Lighthouse
lighthouse https://example.com --view
\`\`\`

### 8.3 使用Chrome DevTools

#### Performance面板
- 记录页面性能
- 分析帧率
- 查看CPU使用情况

#### Network面板
- 分析资源加载
- 查看请求时间
- 优化资源大小

#### Coverage面板
- 分析未使用的CSS和JS
- 优化代码体积

## 9. 常见性能问题及解决方案

### 9.1 首屏加载慢

**问题**：首屏加载时间过长

**解决方案**：
1. 代码分割，按需加载
2. 使用骨架屏
3. 预加载关键资源
4. 压缩和优化资源
5. 使用CDN加速

### 9.2 页面卡顿

**问题**：页面滚动或交互卡顿

**解决方案**：
1. 使用虚拟滚动
2. 防抖和节流
3. 减少DOM操作
4. 使用requestAnimationFrame
5. 优化重绘和回流

### 9.3 内存泄漏

**问题**：页面长时间运行后变慢

**解决方案**：
1. 及时清理事件监听器
2. 清理定时器
3. 避免闭包引用
4. 使用WeakMap和WeakSet
5. 定期检查内存使用

### 9.4 体积过大

**问题**：打包体积过大

**解决方案**：
1. Tree Shaking
2. 代码分割
3. 按需引入
4. 压缩资源
5. 移除未使用的代码

## 10. 性能优化检查清单

### 代码层面
- [ ] 使用代码分割
- [ ] 移除未使用的代码
- [ ] 按需引入第三方库
- [ ] 使用计算属性缓存
- [ ] 避免不必要的渲染

### 资源层面
- [ ] 图片压缩和优化
- [ ] 使用WebP格式
- [ ] 图片懒加载
- [ ] 字体优化
- [ ] 资源压缩

### 渲染层面
- [ ] 使用虚拟滚动
- [ ] 防抖和节流
- [ ] 减少DOM操作
- [ ] 使用事件委托
- [ ] 优化重绘和回流

### 缓存层面
- [ ] 接口数据缓存
- [ ] 本地存储缓存
- [ ] 使用Service Worker
- [ ] 设置合理的缓存策略

### 加载层面
- [ ] 骨架屏
- [ ] 渐进式加载
- [ ] 资源预加载
- [ ] 预取可能访问的资源
- [ ] CDN加速

### 构建层面
- [ ] 压缩代码
- [ ] Tree Shaking
- [ ] 代码分割
- [ ] 去除console和debugger
- [ ] 优化打包配置