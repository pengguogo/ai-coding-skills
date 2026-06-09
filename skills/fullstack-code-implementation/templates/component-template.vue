<!--
  Vue 组件模板（TypeScript）
  占位符说明：{{component-name}} 组件名(kebab-case) | {{prop1}}/{{prop2}} props名 | {{type}} 类型 | {{default-value}} 默认值 | {{event1}}/{{event2}} 事件名 | {{initial-value}} 初始值
-->
<template>
  <div class="{{component-name}}">
    <!-- 组件内容 -->
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

// Props定义
interface Props {
  {{prop1}}?: {{type}}
  {{prop2}}?: {{type}}
}

const props = withDefaults(defineProps<Props>(), {
  {{prop1}}: {{default-value}},
  {{prop2}}: {{default-value}}
})

// Emits定义
interface Emits {
  (event: '{{event1}}', value: {{type}}): void
  (event: '{{event2}}', value: {{type}}): void
}

const emit = defineEmits<Emits>()

// 响应式状态
const state = ref<{{type}}>({{initial-value}})

// 计算属性
const computedValue = computed(() => {
  // 示例：根据props和state计算值
  return state.value
})

// 方法
const handleEvent = () => {
  emit('{{event1}}', state.value)
}

// 生命周期
onMounted(() => {
  // 组件挂载后的逻辑
})

onUnmounted(() => {
  // 组件卸载前的清理逻辑
})

// 暴露给父组件的方法
defineExpose({
  state,
  handleEvent
})
</script>

<style scoped lang="scss">
.{{component-name}} {
  // 组件样式
}
</style>