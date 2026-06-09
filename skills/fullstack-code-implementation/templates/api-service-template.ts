/**
 * API服务模板
 * 用于创建新的API服务模块（TypeScript）
 */

import request from '../request'

/** {{Entity}} 列表查询参数 */
export interface Get{{Entity}}ListParams {
  keyword?: string
  page?: number
  pageSize?: number
}

/** {{Entity}} 列表项/详情基础类型 */
export interface {{Entity}}Item {
  id: number
  [key: string]: unknown
}

/** {{Entity}} 分页响应 */
export interface {{Entity}}ListResponse<T = {{Entity}}Item> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

/**
 * 获取{{entity}}列表
 * @param params 查询参数
 * @returns 分页数据
 */
export function get{{Entity}}List(
  params?: Get{{Entity}}ListParams
): Promise<{{Entity}}ListResponse> {
  return request({
    url: '/{{entity}}/list',
    method: 'get',
    params
  })
}

/**
 * 获取{{entity}}详情
 * @param id {{entity}} ID
 * @returns 详情数据
 */
export function get{{Entity}}Detail(id: number): Promise<{{Entity}}Item> {
  return request({
    url: \`/{{entity}}/\${id}\`,
    method: 'get'
  })
}

/**
 * 创建{{entity}}
 * @param data {{entity}}数据
 * @returns 创建结果
 */
export function create{{Entity}}(data: Partial<{{Entity}}Item>): Promise<{{Entity}}Item> {
  return request({
    url: '/{{entity}}',
    method: 'post',
    data
  })
}

/**
 * 更新{{entity}}
 * @param id {{entity}} ID
 * @param data 更新数据
 * @returns 更新结果
 */
export function update{{Entity}}(
  id: number,
  data: Partial<{{Entity}}Item>
): Promise<{{Entity}}Item> {
  return request({
    url: \`/{{entity}}/\${id}\`,
    method: 'put',
    data
  })
}

/**
 * 删除{{entity}}
 * @param id {{entity}} ID
 * @returns 删除结果
 */
export function delete{{Entity}}(id: number): Promise<void> {
  return request({
    url: \`/{{entity}}/\${id}\`,
    method: 'delete'
  })
}

/**
 * 批量删除{{entity}}
 * @param ids {{entity}} ID数组
 * @returns 删除结果
 */
export function batchDelete{{Entity}}(ids: number[]): Promise<void> {
  return request({
    url: '/{{entity}}/batch',
    method: 'delete',
    data: { ids }
  })
}

export default {
  get{{Entity}}List,
  get{{Entity}}Detail,
  create{{Entity}},
  update{{Entity}},
  delete{{Entity}},
  batchDelete{{Entity}}
}