import storage from 'store'
import expirePlugin from 'store/plugins/expire'
import { getInfo, login, logout } from '@/api/login'
import { ACCESS_TOKEN, AVATAR, ROLES, USER } from '@/store/mutation-types'
import { welcome } from '@/utils/util'
import { getUserInfo } from '@/api/user'

storage.addPlugin(expirePlugin)
const user = {
  state: {
    token: '',
    name: '',
    welcome: '',
    avatar: '',
    roles: [],
    info: {}
  },

  mutations: {
    SET_TOKEN: (state, token) => {
      state.token = token
    },
    SET_NAME: (state, { name, welcome }) => {
      state.name = name
      state.welcome = welcome
    },
    SET_AVATAR: (state, avatar) => {
      state.avatar = avatar
    },
    SET_ROLES: (state, roles) => {
      state.roles = roles
    },
    SET_INFO: (state, info) => {
      state.info = info
    }
  },

  actions: {
    // 登录
    Login ({ commit }, userInfo) {
      return new Promise((resolve, reject) => {
        login(userInfo).then(response => {
          const result = (response.result || {})
          if (response.status === '0') {
            storage.set(ACCESS_TOKEN, 'Bearer ' + result.token, new Date().getTime() + 7 * 24 * 60 * 60 * 1000)
            getUserInfo().then(response => {
              if (response.status === '0') {
                const { result } = response
                result.avatar ? storage.set(AVATAR, `data:image/jpeg;base64,${result.avatar}`) : storage.set(AVATAR, '/avatar2.jpg')
                storage.set(USER, result.user)
                storage.set(ROLES, result.roles)
                commit('SET_TOKEN', result.token)
              }
            })
          }
          resolve(response)
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 获取用户信息
    GetInfo ({ commit }) {
      return new Promise((resolve, reject) => {
        // 请求后端获取用户信息 /api/user/info
        getInfo().then(response => {
          const { result } = response
          // if (result.role && result.role.permissions.length > 0) {
          // const role = { ...result.role }
          // role.permissions = result.role.permissions.map(permission => {
          //   const per = {
          //     ...permission,
          //     actionList: (permission.actionEntitySet || {}).map(item => item.action)
          //    }
          //   return per
          // })
          // role.permissionList = role.permissions.map(permission => { return permission.permissionId })
          // 覆盖响应体的 role, 供下游使用
          // result.role = role

          if (result.roles.length > 0 && result.permissions.length > 0) {
            commit('SET_ROLES', result.roles)
            commit('SET_INFO', result.user)
            commit('SET_NAME', { name: result.user.nickName, welcome: welcome() })
            commit('SET_AVATAR', result.user.avatar)
            // 下游
            resolve(result)
          } else {
            reject(new Error('getInfo: roles must be a non-null array !'))
          }
        }).catch(error => {
          reject(error)
        })
      })
    },

    // 登出
    Logout ({ commit, state }) {
      return new Promise((resolve) => {
        logout(state.token).then(() => {
          commit('SET_TOKEN', '')
          commit('SET_ROLES', [])
          storage.remove(ACCESS_TOKEN)
          resolve()
        }).catch((err) => {
          console.log('logout fail:', err)
          // resolve()
        }).finally(() => {
        })
      })
    }

  }
}

export default user
