<template>
  <div class="main">
    <a-form
      id="formLogin"
      class="user-layout-login"
      ref="formLogin"
      :form="form"
      @submit="handleSubmit"
    >
      <a-tabs
        :activeKey="customActiveKey"
        :tabBarStyle="{ textAlign: 'center', borderBottom: 'unset' }"
        @change="handleTabClick"
      >
        <a-tab-pane key="tab1" :tab="$t('user.login.tab-login-credentials')">
          <a-alert v-if="isLoginError" type="error" showIcon style="margin-bottom: 24px;" :message="message" />
          <a-form-item>
            <a-input
              size="large"
              type="text"
              :placeholder="preview ? '请输入用户名' : $t('user.login.username.placeholder')"
              v-decorator="[
                'username',
                {rules: [{ required: true, message: $t('user.userName.required') }, { validator: handleUsernameOrEmail }], validateTrigger: 'change'}
              ]"
            >
              <a-icon slot="prefix" type="user" :style="{ color: 'rgba(0,0,0,.25)' }"/>
            </a-input>
          </a-form-item>

          <a-form-item>
            <a-input-password
              size="large"
              :placeholder="preview ? '请输入密码' : $t('user.login.password.placeholder')"
              v-decorator="[
                'password',
                {rules: [{ required: true, message: $t('user.password.required') }], validateTrigger: 'blur'}
              ]"
            >
              <a-icon slot="prefix" type="lock" :style="{ color: 'rgba(0,0,0,.25)' }"/>
            </a-input-password>
          </a-form-item>
        </a-tab-pane>
      </a-tabs>

      <!--      <a-form-item>-->
      <!--        <a-checkbox v-decorator="['rememberMe', { valuePropName: 'checked' }]">{{ $t('user.login.remember-me') }}</a-checkbox>-->
      <!--        <router-link-->
      <!--          :to="{ name: 'recover', params: { user: 'aaa'} }"-->
      <!--          class="forge-password"-->
      <!--          style="float: right;"-->
      <!--        >{{ $t('user.login.forgot-password') }}</router-link>-->
      <!--      </a-form-item>-->

      <a-form-item style="margin-top:24px">
        <a-button
          size="large"
          type="primary"
          htmlType="submit"
          class="login-button"
          :loading="state.loginBtn"
          :disabled="state.loginBtn"
        >{{ $t('user.login.login') }}</a-button>
      </a-form-item>

      <div class="user-login-other">
        <!--              <span>{{ $t('user.login.sign-in-with') }}</span>-->
        <!--              <a>-->
        <!--                <a-icon class="item-icon" type="alipay-circle"></a-icon>-->
        <!--              </a>-->
        <!--              <a>-->
        <!--                <a-icon class="item-icon" type="taobao-circle"></a-icon>-->
        <!--              </a>-->
        <!--              <a>-->
        <!--                <a-icon class="item-icon" type="weibo-circle"></a-icon>-->
        <!--              </a>-->
        <router-link class="register" :to="{ name: 'register' }">{{ $t('user.login.signup') }}</router-link>
      </div>
    </a-form>

    <two-step-captcha
      v-if="requiredTwoStepCaptcha"
      :visible="stepCaptchaVisible"
      @success="stepCaptchaSuccess"
      @cancel="stepCaptchaCancel"
    ></two-step-captcha>
  </div>
</template>

<script>
import TwoStepCaptcha from '@/components/tools/TwoStepCaptcha'
import { mapActions } from 'vuex'
import { timeFix } from '@/utils/util'
import { get2step, getSmsCaptcha } from '@/api/login'
import { encrypt } from '@/utils/encrypt'

export default {
  components: {
    TwoStepCaptcha
  },
  data () {
    return {
      customActiveKey: 'tab1',
      loginBtn: false,
      // login type: 0 email, 1 username, 2 telephone
      loginType: 1,
      isLoginError: false,
      message: '',
      requiredTwoStepCaptcha: false,
      stepCaptchaVisible: false,
      form: this.$form.createForm(this),
      state: {
        time: 60,
        loginBtn: false,
        // login type: 0 email, 1 username, 2 telephone
        loginType: 1,
        smsSendBtn: false
      },
      preview: process.env.NODE_ENV === 'production'
    }
  },
  created () {
    get2step({ })
      .then(res => {
        this.requiredTwoStepCaptcha = res.result.stepCode
      })
      .catch(() => {
        this.requiredTwoStepCaptcha = false
      })
    // this.requiredTwoStepCaptcha = true
  },
  methods: {
    ...mapActions(['Login', 'Logout']),
    // handler
    handleUsernameOrEmail (rule, value, callback) {
      const { state } = this
      const regex = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/
      if (regex.test(value)) {
        state.loginType = 0
      } else {
        state.loginType = 1
      }
      callback()
    },
    handleTabClick (key) {
      this.customActiveKey = key
      // this.form.resetFields()
    },
    handleSubmit (e) {
      e.preventDefault()
      const {
        form: { validateFields },
        state,
        customActiveKey,
        Login
      } = this

      state.loginBtn = true

      const validateFieldsKey = customActiveKey === 'tab1' ? ['username', 'password'] : ['mobile', 'captcha']

      validateFields(validateFieldsKey, { force: true }, (err, values) => {
        if (!err) {
          const loginParams = { ...values }
          delete loginParams.username
          loginParams[!state.loginType ? 'email' : 'username'] = values.username
          encrypt(values.password).then(res => {
            loginParams.password = res
            Login(loginParams)
              .then((res) => {
                if (res.status !== '0') {
                  this.requestFailed(res)
                } else {
                  this.loginSuccess(res)
                }
              })
              .catch(err => this.requestFailed(err))
              .finally(() => {
                state.loginBtn = false
              })
          })
        } else {
          setTimeout(() => {
            state.loginBtn = false
          }, 600)
        }
      })
    },
    getCaptcha (e) {
      e.preventDefault()
      const { form: { validateFields }, state } = this

      validateFields(['mobile'], { force: true }, (err, values) => {
        if (!err) {
          state.smsSendBtn = true

          const interval = window.setInterval(() => {
            if (state.time-- <= 0) {
              state.time = 60
              state.smsSendBtn = false
              window.clearInterval(interval)
            }
          }, 1000)

          const hide = this.$message.loading('验证码发送中..', 0)
          getSmsCaptcha({ mobile: values.mobile }).then(res => {
            setTimeout(hide, 2500)
            this.$notification['success']({
              message: '提示',
              description: '验证码获取成功，您的验证码为：' + res.result.captcha,
              duration: 8
            })
          }).catch(err => {
            setTimeout(hide, 1)
            clearInterval(interval)
            state.time = 60
            state.smsSendBtn = false
            this.requestFailed(err)
          })
        }
      })
    },
    stepCaptchaSuccess () {
      this.loginSuccess()
    },
    stepCaptchaCancel () {
      this.Logout().then(() => {
        this.loginBtn = false
        this.stepCaptchaVisible = false
      })
    },
    loginSuccess (res) {
      // check res.homePage define, set $router.push name res.homePage
      // Why not enter onComplete
      /*
      this.$router.push({ name: 'analysis' }, () => {
        console.log('onComplete')
        this.$notification.success({
          message: '欢迎',
          description: `${timeFix()}，欢迎回来`
        })
      })
      */
      this.$router.push({ path: '/' })
      // 延迟 1 秒显示欢迎信息
      setTimeout(() => {
        this.$notification.success({
          message: '欢迎',
          description: `${timeFix()}，欢迎回来`
        })
      }, 1000)
      this.isLoginError = false
    },
    requestFailed (err) {
      this.isLoginError = true
      this.message = this.$t(((err || {}).errstr || {}) || '请求出现错误，请稍后再试')
    }
  }
}
</script>

<style lang="less" scoped>
.user-layout-login {
  background: rgba(255, 255, 255, 0.2); /* 轻微透明 */
  backdrop-filter: blur(10px); /* 玻璃模糊效果 */
  border-radius: 12px; /* 圆角 */
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2); /* 轻微阴影，增加立体感 */
  display: flex;
  padding: 24px;
  flex-direction: column;
  label {
    font-size: 14px;
  }

  .getCaptcha {
    display: block;
    width: 100%;
    height: 40px;
  }

  .forge-password {
    font-size: 14px;
  }
  button:hover {
    background: linear-gradient(to right, #0094ff, #0070e0);
    transform: scale(1.05); /* 轻微放大，提升点击感 */
    box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3); /* 发光效果 */
  }
  button.login-button {
    background: linear-gradient(to right, #007bff, #0056b3);
    border: none;
    font-size: 16px;
    line-height: 16px;
    height: 40px;
    width: 100%;
    color: white;
    padding: 12px 20px;
    border-radius: 8px;
    transition: all 0.3s ease-in-out;
  }

  .user-login-other {
    text-align: left;
    line-height: 22px;

    .item-icon {
      font-size: 24px;
      color: rgba(0, 0, 0, 0.2);
      margin-left: 16px;
      vertical-align: middle;
      cursor: pointer;
      transition: color 0.3s;

      &:hover {
        color: #1890ff;
      }
    }

    .register {
      float: right;
    }
  }
}
::v-deep input {
  border-radius: 8px;
}
</style>
