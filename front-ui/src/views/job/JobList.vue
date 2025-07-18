<template>
  <a-card :bordered="false">
    <div class="table-operator">
      <a-button @click="$refs.JobSaveOrUpdate.edit('add', '')" icon="plus" type="primary">新建</a-button>
    </div>
    <a-table
      :columns="columns"
      :dataSource="tableData"
      :loading="loading"
      :pagination="pagination"
      :rowKey="record => record.job_id"
      @change="handleTableChange"
    >
    </a-table>
    <job-save-or-update
      @ok="handleOk"
      ref="JobSaveOrUpdate"
    />
  </a-card>
</template>

<script>
import { delObj, exec, pageQuery, stop } from '@/api/job/job'
import { closeConnect } from '@/api/job/sse'
import JobSaveOrUpdate from '../job/JobSaveOrUpdate.vue'
import { fetchEventSource } from '@microsoft/fetch-event-source'
// 0:CREATE|1:SYNCING|2:SYNC_FINISH|3:SYNC_ERROR|4:QUEUING
const StatusType = [
  {
    label: '新建',
    value: 0
  },
  {
    label: '流转中',
    value: 1
  },
  {
    label: '流转完成',
    value: 2
  },
  {
    label: '流转失败',
    value: 3
  },
  {
    label: '流转停止',
    value: 4
  }
]
export default {
  name: 'JobList',
  components: {
    JobSaveOrUpdate
  },
  data () {
    return {
      loading: false,
      columns: [
        {
          title: 'job_id',
          width: '10%',
          dataIndex: 'job_id'
        },
        {
          title: '任务名称',
          width: '10%',
          dataIndex: 'job_name'
        },
        {
          title: '来源表',
          width: '10%',
          dataIndex: 'from_tb_name'
        },
        {
          title: '目标表',
          width: '10%',
          dataIndex: 'to_tb_name',
          sorter: true
        },
        {
          title: '任务状态',
          width: '10%',
          dataIndex: 'status',
          customRender: (text) => {
            return (
              <div>
                {StatusType.map(item => {
                  if (item.value === text) {
                    return <span>{item.label}</span>
                  }
                })}
              </div>
            )
          }
        },
        {
          title: '流转进度(w/r)',
          width: '10%',
          dataIndex: 'progress'
        },
        {
          title: '查看日志',
          width: '10%',
          customRender: (record) => {
            return (
              <div>
                <a href="javascript:;" onClick={() => this.goToJobLog(record.job_id)}>查看</a>
              </div>
            )
          }
        },
        {
          title: '任务上次执行时间',
          width: '10%',
          dataIndex: 'start_time',
          sorter: true
        },
        {
          title: '操作',
          width: '15%',
          customRender: (record) => {
            return (
              <div>
                <a onClick={(e) => this.edit(record)}>修改</a>
                <a-divider type="vertical" />
                <a-popconfirm title="是否删除" onConfirm={() => this.delete(record)} okText="是" cancelText="否">
                  <a-icon slot="icon" type="question-circle-o" style="color: red" />
                  <a href="javascript:;" style="color: red">删除</a>
                </a-popconfirm>
                <a-divider type="vertical" />
                <a href="javascript:;"onClick={(e) => this.execJob(record)}>手动触发</a>
                <a-divider type="vertical" />
                <a href="javascript:;"onClick={(e) => this.stopJob(record)}>停止流转</a>
              </div>
            )
          }
        }
      ],
      tableData: [],
      pagination: {
        pageSize: 10,
        current: 1,
        total: 0,
        showSizeChanger: true
      },
      pages: {
        size: 10,
        current: 1
      },
      queryParam: {
        'type': 0
      },
      source: null
    }
  },
  methods: {
    init () {
      this.loading = true
      pageQuery({
        ...this.queryParam,
        ...this.pages
      }).then(res => {
        this.tableData = res.result.data
        this.pagination.total = +res.result.total
        this.loading = false
      }).finally(() => {
        this.loading = false
      })
    },
    handleTableChange (pagination) {
      this.pagination = pagination
      this.pages.size = pagination.pageSize
      this.pages.current = pagination.current
      this.init()
    },
    edit (record) {
      this.$refs.JobSaveOrUpdate.edit('edit', record.job_id)
    },
    delete (record) {
      this.loading = true
      delObj(record.job_id).then(res => {
        if (res.status === '0') {
          this.$message.info('删除成功')
          this.init()
        } else {
          this.$message.error(res.errstr)
        }
      }).finally(() => {
        this.loading = false
      })
    },
    show (record) {
      this.$refs.JobSaveOrUpdate.edit(record.job_id, 'show')
    },
    execJob (record) {
      this.createEventSource()
      exec(record.job_id).then(res => {
        if (res.status === '0') {
          this.$message.info('触发成功')
          this.init()
        } else {
          this.$message.error(res.errstr)
        }
      }).finally(() => {
        this.loading = false
      })
    },
    stopJob (record) {
      stop(record.job_id).then(res => {
        if (res.status === '0') {
          this.$message.info('停止成功')
          this.init()
        } else {
          this.$message.error(res.errstr)
        }
      }).finally(() => {
        this.loading = false
      })
    },
    handleOk () {
      this.init()
    },
    queryData () {
      this.pages.current = 1
      this.init()
    },
    createEventSource () {
      if (window.EventSource) {
        const token = localStorage.getItem('Access-Token').replace(/"/g, '')
        const url = `api/api/sse/connect/jobList`
        fetchEventSource(url, {
          method: 'GET',
          openWhenHidden: true,
          headers: {
            'ACCESS-TOKEN': token,
            'Accept': 'text/event-stream'
          },
          heartbeatTimeout: 60 * 60 * 1000, // 设置心跳超时时间
          onopen: () => {
            console.log('SSE 连接成功')
          },
          onmessage: (event) => {
            console.log('从服务器接收数据:', event.data)
            const flashData = JSON.parse(event.data)
            console.log(flashData)

            for (const i of this.tableData) {
              if (i.job_id === flashData.job_id) {
                if (flashData.status === 1) {
                  i.status = flashData.status
                  if (flashData.write_records === undefined || flashData.read_records === undefined) {
                    i.progress = '0/0'
                  } else {
                    i.progress = `${flashData.write_records}/${flashData.read_records}`
                  }
                } else {
                  // 防止消息先到前端，后端未入库
                  i.status = flashData.status
                }
              }
            }
          },
          onclose: () => {
            console.log('SSE 连接已关闭')
          },
          onerror: (err) => {
            console.error('SSE 发生错误:', err)
          }
        })
      } else {
        console.log('browser not support SSE')
      }
    },
    goToJobLog (jobId) {
      // 使用 Vue Router 的编程式导航跳转到 jobLog 页面
      this.$router.push({
        name: 'JobLog', // 路由名称
        query: { jobId } // 通过 query 参数传递 jobId
        // 或者使用 params（如果路由配置了动态参数）
        // params: { jobId }
      })
    }
  },
  beforeDestroy () {
    this.eventSource && this.eventSource.close()
    closeConnect('jobList')
  },
  created () {
    this.init()
    this.createEventSource()
  }
}
</script>

<style scoped>

</style>
