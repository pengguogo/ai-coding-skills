/**
 * Store模板
 * 用于创建新的状态管理模块（TypeScript + Pinia）
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/** {{Entity}} 基础类型 */
export interface {{Entity}}Item {
  id: number
  [key: string]: unknown
}

export const use{{Entity}}Store = defineStore('{{entity}}', () => {
  // 状态
  const list = ref<{{Entity}}Item[]>([])
  const current = ref<{{Entity}}Item | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // 计算属性
  const total = computed(() => list.value.length)
  const isEmpty = computed(() => list.value.length === 0)

  // Actions
  /**
   * 设置列表数据
   */
  function setList(data: {{Entity}}Item[]): void {
    list.value = data
  }

  /**
   * 设置当前{{entity}}
   */
  function setCurrent(data: {{Entity}}Item | null): void {
    current.value = data
  }

  /**
   * 添加{{entity}}
   */
  function add{{Entity}}(data: {{Entity}}Item): void {
    list.value.push(data)
  }

  /**
   * 更新{{entity}}
   */
  function update{{Entity}}(id: number, data: Partial<{{Entity}}Item>): void {
    const index = list.value.findIndex((item) => item.id === id)
    if (index !== -1) {
      list.value[index] = { ...list.value[index], ...data }
    }
  }

  /**
   * 删除{{entity}}
   */
  function delete{{Entity}}(id: number): void {
    const index = list.value.findIndex((item) => item.id === id)
    if (index !== -1) {
      list.value.splice(index, 1)
    }
  }

  /**
   * 批量删除{{entity}}
   */
  function batchDelete{{Entity}}(ids: number[]): void {
    list.value = list.value.filter((item) => !ids.includes(item.id))
  }

  /**
   * 设置加载状态
   */
  function setLoading(value: boolean): void {
    loading.value = value
  }

  /**
   * 设置错误信息
   */
  function setError(err: string | null): void {
    error.value = err
  }

  /**
   * 重置状态
   */
  function reset(): void {
    list.value = []
    current.value = null
    loading.value = false
    error.value = null
  }

  return {
    // 状态
    list,
    current,
    loading,
    error,
    // 计算属性
    total,
    isEmpty,
    // Actions
    setList,
    setCurrent,
    add{{Entity}},
    update{{Entity}},
    delete{{Entity}},
    batchDelete{{Entity}},
    setLoading,
    setError,
    reset
  }
})