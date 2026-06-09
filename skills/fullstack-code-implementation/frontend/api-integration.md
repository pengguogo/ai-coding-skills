# API集成最佳实践

> 本文档示例均使用 TypeScript，包含完整的类型定义和接口声明。

## 1. HTTP客户端配置

### 1.1 Axios配置

#### 基础配置
\`\`\`typescript
// services/request.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios'

// 创建axios实例
const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json;charset=UTF-8'
  }
})

// 请求拦截器
service.interceptors.request.use(
  (config: AxiosRequestConfig) => {
    // 添加Token
    const token = localStorage.getItem('token')
    if (token && config.headers) {
      config.headers.Authorization = \`Bearer \${token}\`
    }

    // 添加时间戳防止缓存
    if (config.method === 'get') {
      config.params = {
        ...config.params,
        _t: Date.now()
      }
    }

    return config
  },
  (error: AxiosError) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse) => {
    const { code, data, message } = response.data

    // 根据业务状态码处理
    if (code === 200) {
      return data
    } else if (code === 401) {
      // Token过期，跳转登录
      handleTokenExpired()
      return Promise.reject(new Error(message || '未授权'))
    } else {
      // 其他错误
      showMessage(message || '请求失败', 'error')
      return Promise.reject(new Error(message || '请求失败'))
    }
  },
  (error: AxiosError) => {
    // HTTP错误状态码处理
    if (error.response) {
      const { status } = error.response
      switch (status) {
        case 400:
          showMessage('请求参数错误', 'error')
          break
        case 401:
          showMessage('未授权，请重新登录', 'error')
          handleTokenExpired()
          break
        case 403:
          showMessage('拒绝访问', 'error')
          break
        case 404:
          showMessage('请求资源不存在', 'error')
          break
        case 500:
          showMessage('服务器错误', 'error')
          break
        default:
          showMessage(\`请求失败: \${status}\`, 'error')
      }
    } else if (error.request) {
      // 请求已发出但没有响应
      showMessage('网络错误，请检查网络连接', 'error')
    } else {
      // 请求配置错误
      showMessage('请求配置错误', 'error')
    }

    return Promise.reject(error)
  }
)

// Token过期处理
function handleTokenExpired() {
  localStorage.removeItem('token')
  localStorage.removeItem('userInfo')
  window.location.href = '/login'
}

// 显示消息
function showMessage(message: string, type: 'success' | 'error' | 'warning' | 'info') {
  // 使用UI组件库的消息提示
  // ElMessage({ message, type })
}

export default service
\`\`\`

### 1.2 Fetch封装

\`\`\`typescript
// services/request.ts
interface RequestConfig extends RequestInit {
  params?: Record<string, any>
  timeout?: number
}

class HttpClient {
  private baseURL: string
  private timeout: number = 15000

  constructor(baseURL: string) {
    this.baseURL = baseURL
  }

  private buildURL(url: string, params?: Record<string, any>): string {
    const fullURL = \`\${this.baseURL}\${url}\`
    if (params) {
      const searchParams = new URLSearchParams()
      Object.keys(params).forEach(key => {
        searchParams.append(key, params[key])
      })
      return \`\${fullURL}?\${searchParams.toString()}\`
    }
    return fullURL
  }

  private async request<T>(
    url: string,
    config: RequestConfig = {}
  ): Promise<T> {
    const { params, timeout = this.timeout, ...restConfig } = config
    const fullURL = this.buildURL(url, params)

    // 添加Token
    const headers = new Headers(restConfig.headers)
    const token = localStorage.getItem('token')
    if (token) {
      headers.append('Authorization', \`Bearer \${token}\`)
    }

    // 超时控制
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), timeout)

    try {
      const response = await fetch(fullURL, {
        ...restConfig,
        headers,
        signal: controller.signal
      })

      clearTimeout(timeoutId)

      if (!response.ok) {
        throw new Error(\`HTTP Error: \${response.status}\`)
      }

      const data = await response.json()
      return data
    } catch (error) {
      clearTimeout(timeoutId)
      throw error
    }
  }

  get<T>(url: string, config?: RequestConfig): Promise<T> {
    return this.request<T>(url, { ...config, method: 'GET' })
  }

  post<T>(url: string, data?: any, config?: RequestConfig): Promise<T> {
    return this.request<T>(url, {
      ...config,
      method: 'POST',
      body: JSON.stringify(data)
    })
  }

  put<T>(url: string, data?: any, config?: RequestConfig): Promise<T> {
    return this.request<T>(url, {
      ...config,
      method: 'PUT',
      body: JSON.stringify(data)
    })
  }

  delete<T>(url: string, config?: RequestConfig): Promise<T> {
    return this.request<T>(url, { ...config, method: 'DELETE' })
  }
}

export const httpClient = new HttpClient(import.meta.env.VITE_API_BASE_URL)
\`\`\`

## 2. API模块化设计

### 2.1 目录结构
\`\`\`
services/
├── api.ts              # API配置
├── request.ts          # 请求封装
├── modules/            # API模块
│   ├── user.ts         # 用户API
│   ├── auth.ts         # 认证API
│   ├── common.ts       # 通用API
│   └── index.ts        # 统一导出
└── types/              # API类型定义
    ├── user.ts
    ├── auth.ts
    └── common.ts
\`\`\`

### 2.2 类型定义

#### 用户类型
\`\`\`typescript
// services/types/user.ts
export interface User {
  id: number
  name: string
  email: string
  avatar?: string
  status: 'active' | 'inactive'
  createdAt: string
  updatedAt: string
}

export interface UserListParams {
  page: number
  pageSize: number
  keyword?: string
  status?: string
}

export interface UserListResponse {
  list: User[]
  total: number
  page: number
  pageSize: number
}

export interface CreateUserParams {
  name: string
  email: string
  password: string
  status?: 'active' | 'inactive'
}

export interface UpdateUserParams {
  name?: string
  email?: string
  status?: 'active' | 'inactive'
}
\`\`\`

#### 认证类型
\`\`\`typescript
// services/types/auth.ts
export interface LoginParams {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  userInfo: UserInfo
}

export interface UserInfo {
  id: number
  username: string
  email: string
  roles: string[]
  permissions: string[]
}
\`\`\`

#### 通用类型
\`\`\`typescript
// services/types/common.ts
export interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

export interface PageParams {
  page: number
  pageSize: number
}

export interface PageResponse<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

export interface UploadResponse {
  url: string
  filename: string
  size: number
}
\`\`\`

### 2.3 API模块实现

#### 用户API
\`\`\`typescript
// services/modules/user.ts
import request from '../request'
import type {
  User,
  UserListParams,
  UserListResponse,
  CreateUserParams,
  UpdateUserParams
} from '../types/user'

/**
 * 获取用户列表
 */
export function getUserList(params: UserListParams): Promise<UserListResponse> {
  return request({
    url: '/users',
    method: 'GET',
    params
  })
}

/**
 * 获取用户详情
 */
export function getUserDetail(id: number): Promise<User> {
  return request({
    url: \`/users/\${id}\`,
    method: 'GET'
  })
}

/**
 * 创建用户
 */
export function createUser(data: CreateUserParams): Promise<User> {
  return request({
    url: '/users',
    method: 'POST',
    data
  })
}

/**
 * 更新用户
 */
export function updateUser(id: number, data: UpdateUserParams): Promise<User> {
  return request({
    url: \`/users/\${id}\`,
    method: 'PUT',
    data
  })
}

/**
 * 删除用户
 */
export function deleteUser(id: number): Promise<void> {
  return request({
    url: \`/users/\${id}\`,
    method: 'DELETE'
  })
}

/**
 * 批量删除用户
 */
export function batchDeleteUsers(ids: number[]): Promise<void> {
  return request({
    url: '/users/batch',
    method: 'DELETE',
    data: { ids }
  })
}

/**
 * 导出用户
 */
export function exportUsers(params: UserListParams): Promise<Blob> {
  return request({
    url: '/users/export',
    method: 'GET',
    params,
    responseType: 'blob'
  })
}

/**
 * 导入用户
 */
export function importUsers(file: File): Promise<void> {
  const formData = new FormData()
  formData.append('file', file)

  return request({
    url: '/users/import',
    method: 'POST',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}
\`\`\`

#### 认证API
\`\`\`typescript
// services/modules/auth.ts
import request from '../request'
import type { LoginParams, LoginResponse } from '../types/auth'

/**
 * 登录
 */
export function login(data: LoginParams): Promise<LoginResponse> {
  return request({
    url: '/auth/login',
    method: 'POST',
    data
  })
}

/**
 * 登出
 */
export function logout(): Promise<void> {
  return request({
    url: '/auth/logout',
    method: 'POST'
  })
}

/**
 * 刷新Token
 */
export function refreshToken(): Promise<{ token: string }> {
  return request({
    url: '/auth/refresh',
    method: 'POST'
  })
}

/**
 * 获取当前用户信息
 */
export function getCurrentUser(): Promise<LoginResponse['userInfo']> {
  return request({
    url: '/auth/user',
    method: 'GET'
  })
}
\`\`\`

#### 通用API
\`\`\`typescript
// services/modules/common.ts
import request from '../request'
import type { UploadResponse } from '../types/common'

/**
 * 上传文件
 */
export function uploadFile(file: File): Promise<UploadResponse> {
  const formData = new FormData()
  formData.append('file', file)

  return request({
    url: '/upload',
    method: 'POST',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

/**
 * 获取字典数据
 */
export function getDictData(type: string): Promise<any[]> {
  return request({
    url: \`/dict/\${type}\`,
    method: 'GET'
  })
}

/**
 * 获取地区数据
 */
export function getRegionData(parentId?: number): Promise<any[]> {
  return request({
    url: '/region',
    method: 'GET',
    params: { parentId }
  })
}
\`\`\`

#### 统一导出
\`\`\`typescript
// services/modules/index.ts
export * from './user'
export * from './auth'
export * from './common'
\`\`\`

## 3. API调用最佳实践

### 3.1 在组件中使用

#### Vue 3 Composition API
\`\`\`vue
<template>
  <div>
    <el-button @click="fetchUsers">刷新</el-button>
    <el-table :data="users" v-loading="loading">
      <el-table-column prop="name" label="姓名" />
      <el-table-column prop="email" label="邮箱" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUserList } from '@/services/modules'
import type { User } from '@/services/types/user'

const users = ref<User[]>([])
const loading = ref(false)

const fetchUsers = async () => {
  loading.value = true
  try {
    const result = await getUserList({
      page: 1,
      pageSize: 10
    })
    users.value = result.list
  } catch (error) {
    console.error('获取用户列表失败', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchUsers()
})
</script>
\`\`\`

#### React Hooks
\`\`\`typescript
import { useState, useEffect } from 'react'
import { getUserList } from '@/services/modules'
import type { User } from '@/services/types/user'

function UserList() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(false)

  const fetchUsers = async () => {
    setLoading(true)
    try {
      const result = await getUserList({
        page: 1,
        pageSize: 10
      })
      setUsers(result.list)
    } catch (error) {
      console.error('获取用户列表失败', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchUsers()
  }, [])

  return (
    <div>
      <button onClick={fetchUsers}>刷新</button>
      {loading ? (
        <div>加载中...</div>
      ) : (
        <table>
          {users.map(user => (
            <tr key={user.id}>
              <td>{user.name}</td>
              <td>{user.email}</td>
            </tr>
          ))}
        </table>
      )}
    </div>
  )
}
\`\`\`

### 3.2 使用组合式函数封装

\`\`\`typescript
// composables/useApi.ts
import { ref } from 'vue'

export function useApi<T>(
  apiFunction: (...args: any[]) => Promise<T>
) {
  const data = ref<T | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const execute = async (...args: any[]) => {
    loading.value = true
    error.value = null

    try {
      const result = await apiFunction(...args)
      data.value = result
      return result
    } catch (err) {
      error.value = err as Error
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    data,
    loading,
    error,
    execute
  }
}
\`\`\`

使用：
\`\`\`vue
<script setup lang="ts">
import { useApi } from '@/composables/useApi'
import { getUserList } from '@/services/modules'

const { data, loading, error, execute } = useApi(getUserList)

const fetchUsers = () => {
  execute({ page: 1, pageSize: 10 })
}

fetchUsers()
</script>
\`\`\`

### 3.3 请求取消

\`\`\`typescript
// composables/useApi.ts
import { ref } from 'vue'

export function useApi<T>(
  apiFunction: (...args: any[]) => Promise<T>
) {
  const data = ref<T | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)
  let controller: AbortController | null = null

  const execute = async (...args: any[]) => {
    // 取消之前的请求
    if (controller) {
      controller.abort()
    }

    controller = new AbortController()
    loading.value = true
    error.value = null

    try {
      const result = await apiFunction(...args, controller.signal)
      data.value = result
      return result
    } catch (err) {
      // 如果是取消请求，不设置错误
      if ((err as Error).name !== 'AbortError') {
        error.value = err as Error
      }
      throw err
    } finally {
      loading.value = false
      controller = null
    }
  }

  const cancel = () => {
    if (controller) {
      controller.abort()
      controller = null
    }
    loading.value = false
  }

  return {
    data,
    loading,
    error,
    execute,
    cancel
  }
}
\`\`\`

## 4. 错误处理

### 4.1 统一错误处理

\`\`\`typescript
// utils/errorHandler.ts
export class ApiError extends Error {
  code: number
  data?: any

  constructor(message: string, code: number, data?: any) {
    super(message)
    this.name = 'ApiError'
    this.code = code
    this.data = data
  }
}

export function handleApiError(error: any): ApiError {
  if (error instanceof ApiError) {
    return error
  }

  if (error.response) {
    const { status, data } = error.response
    return new ApiError(
      data.message || \`请求失败: \${status}\`,
      status,
      data
    )
  }

  if (error.request) {
    return new ApiError('网络错误，请检查网络连接', 0)
  }

  return new ApiError(error.message || '未知错误', -1)
}
\`\`\`

### 4.2 在组件中处理错误

\`\`\`vue
<script setup lang="ts">
import { ref } from 'vue'
import { getUserList } from '@/services/modules'
import { handleApiError } from '@/utils/errorHandler'

const users = ref([])
const loading = ref(false)
const error = ref<string | null>(null)

const fetchUsers = async () => {
  loading.value = true
  error.value = null

  try {
    const result = await getUserList({ page: 1, pageSize: 10 })
    users.value = result.list
  } catch (err) {
    const apiError = handleApiError(err)
    error.value = apiError.message

    // 根据错误码处理
    if (apiError.code === 401) {
      // 跳转登录
      window.location.href = '/login'
    }
  } finally {
    loading.value = false
  }
}
</script>
\`\`\`

## 5. 数据缓存策略

### 5.1 简单缓存

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

使用：
\`\`\`typescript
const fetchUsers = async () => {
  const result = await withCache(
    'user-list',
    () => getUserList({ page: 1, pageSize: 10 })
  )
  users.value = result.list
}
\`\`\`

### 5.2 使用SWR或React Query

#### SWR
\`\`\`typescript
import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(res => res.json())

function UserList() {
  const { data, error, isLoading } = useSWR('/api/users', fetcher)

  if (error) return <div>加载失败</div>
  if (isLoading) return <div>加载中...</div>

  return <div>{JSON.stringify(data)}</div>
}
\`\`\`

#### React Query
\`\`\`typescript
import { useQuery } from '@tanstack/react-query'

function UserList() {
  const { data, error, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: () => getUserList({ page: 1, pageSize: 10 })
  })

  if (error) return <div>加载失败</div>
  if (isLoading) return <div>加载中...</div>

  return <div>{JSON.stringify(data)}</div>
}
\`\`\`

## 6. 文件上传下载

### 6.1 文件上传

\`\`\`typescript
// 上传单个文件
export function uploadFile(file: File, onProgress?: (progress: number) => void): Promise<UploadResponse> {
  const formData = new FormData()
  formData.append('file', file)

  return request({
    url: '/upload',
    method: 'POST',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    onUploadProgress: (progressEvent) => {
      if (onProgress && progressEvent.total) {
        const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        onProgress(progress)
      }
    }
  })
}

// 上传多个文件
export function uploadFiles(files: File[], onProgress?: (progress: number) => void): Promise<UploadResponse[]> {
  const formData = new FormData()
  files.forEach(file => {
    formData.append('files', file)
  })

  return request({
    url: '/upload/batch',
    method: 'POST',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    onUploadProgress
  })
}
\`\`\`

### 6.2 文件下载

\`\`\`typescript
// 下载文件
export function downloadFile(url: string, filename: string): Promise<void> {
  return request({
    url,
    method: 'GET',
    responseType: 'blob'
  }).then(blob => {
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = filename
    link.click()
    URL.revokeObjectURL(link.href)
  })
}

// 导出数据
export function exportData(params: any, filename: string): Promise<void> {
  return request({
    url: '/export',
    method: 'GET',
    params,
    responseType: 'blob'
  }).then(blob => {
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = filename
    link.click()
    URL.revokeObjectURL(link.href)
  })
}
\`\`\`

## 7. 请求重试机制

\`\`\`typescript
// utils/retry.ts
export async function retryRequest<T>(
  requestFn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  let lastError: Error

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await requestFn()
    } catch (error) {
      lastError = error as Error

      // 最后一次重试不再延迟
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, delay * (i + 1)))
      }
    }
  }

  throw lastError!
}

// 使用
const result = await retryRequest(
  () => getUserList({ page: 1, pageSize: 10 }),
  3,
  1000
)
\`\`\`

## 8. 并发请求控制

\`\`\`typescript
// utils/concurrency.ts
export async function requestConcurrency<T>(
  requests: Array<() => Promise<T>>,
  maxConcurrency: number = 5
): Promise<T[]> {
  const results: T[] = []
  const executing: Promise<void>[] = []

  for (const request of requests) {
    const promise = request().then(result => {
      executing.splice(executing.indexOf(promise), 1)
      results.push(result)
    })

    executing.push(promise)

    if (executing.length >= maxConcurrency) {
      await Promise.race(executing)
    }
  }

  await Promise.all(executing)
  return results
}

// 使用
const requests = [
  () => getUserDetail(1),
  () => getUserDetail(2),
  () => getUserDetail(3)
]

const results = await requestConcurrency(requests, 2)
\`\`\`

## 9. API Mock

### 9.1 使用MSW

\`\`\`typescript
// mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json({
      code: 200,
      message: 'success',
      data: {
        list: [
          { id: 1, name: 'John', email: 'john@example.com' },
          { id: 2, name: 'Jane', email: 'jane@example.com' }
        ],
        total: 2,
        page: 1,
        pageSize: 10
      }
    })
  })
]
\`\`\`

### 9.2 使用Mock.js

\`\`\`typescript
// mocks/user.ts
import Mock from 'mockjs'

Mock.mock('/api/users', 'get', () => {
  return {
    code: 200,
    message: 'success',
    data: {
      list: Mock.mock({
        'list|10': [
          {
            'id|+1': 1,
            'name': '@cname',
            'email': '@email',
            'status': '@boolean'
          }
        ]
      }).list,
      total: 10,
      page: 1,
      pageSize: 10
    }
  }
})
\`\`\`

## 10. 性能优化

### 10.1 请求去重

\`\`\`typescript
// utils/deduplicate.ts
const pendingRequests = new Map<string, Promise<any>>()

export function deduplicateRequest<T>(
  key: string,
  requestFn: () => Promise<T>
): Promise<T> {
  if (pendingRequests.has(key)) {
    return pendingRequests.get(key)!
  }

  const promise = requestFn().finally(() => {
    pendingRequests.delete(key)
  })

  pendingRequests.set(key, promise)
  return promise
}

// 使用
const fetchUsers = () => {
  return deduplicateRequest('user-list', () =>
    getUserList({ page: 1, pageSize: 10 })
  )
}
\`\`\`

### 10.2 请求节流

\`\`\`typescript
// utils/throttle.ts
export function throttleRequest<T>(
  requestFn: () => Promise<T>,
  delay: number = 300
): () => Promise<T> {
  let lastRequest: Promise<T> | null = null
  let timer: number | null = null

  return () => {
    if (timer) {
      clearTimeout(timer)
    }

    return new Promise((resolve, reject) => {
      timer = window.setTimeout(async () => {
        try {
          const result = await requestFn()
          resolve(result)
        } catch (error) {
          reject(error)
        } finally {
          timer = null
        }
      }, delay)
    })
  }
}

// 使用
const throttledFetchUsers = throttleRequest(
  () => getUserList({ page: 1, pageSize: 10 }),
  300
)
\`\`\`