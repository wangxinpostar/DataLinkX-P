<template>
  <a-config-provider :locale="locale">
    <loading v-if="isLoading" />
    <div id="app">
      <router-view v-if="ifRouterAlive" />
      <!--      <div class="chat-container">-->
      <!--        <beautiful-chat-->
      <!--          :participants="participants"-->
      <!--          :titleImageUrl="titleImageUrl"-->
      <!--          :onMessageWasSent="onMessageWasSent"-->
      <!--          :messageList="messageList"-->
      <!--          :newMessagesCount="newMessagesCount"-->
      <!--          :isOpen="isChatOpen"-->
      <!--          :close="closeChat"-->
      <!--          :open="openChat"-->
      <!--          :showEmoji="true"-->
      <!--          :showFile="true"-->
      <!--          :showEdition="true"-->
      <!--          :showDeletion="true"-->
      <!--          :showTypingIndicator="showTypingIndicator"-->
      <!--          :showLauncher="true"-->
      <!--          :showCloseButton="true"-->
      <!--          :colors="colors"-->
      <!--          :alwaysScrollToBottocom="alwaysScrollToBottom"-->
      <!--          :disableUserListToggle="false"-->
      <!--          :messageStyling="messageStyling"-->
      <!--          @onType="handleOnType"-->
      <!--          @edit="editMessage" />-->
      <!--      </div>-->
    </div>
  </a-config-provider>
</template>

<script>
import { domTitle, setDocumentTitle } from '@/utils/domUtil'
import { i18nRender } from '@/locales'
import EVA from '@/assets/eva.png'
import TitleImg from '@/assets/titleImg.png'
import Loading from '@/components/common/loading.vue'

export default {
  components: { Loading },
  created () {
    setTimeout(() => {
      this.isLoading = false
    }, 500)
  },
  provide () {
    return {
      reload: this.reload
    }
  },
  data () {
    return {
      isLoading: true,
      ifRouterAlive: true,
      msg: '聊天浮球',
      participants: [
        {
          id: 'user1',
          name: 'Matteo',
          imageUrl: EVA
        }
      ], // the list of all the participant of the conversation. `name` is the user name, `id` is used to establish the author of a message, `imageUrl` is supposed to be the user avatar.
      titleImageUrl: TitleImg,
      messageList: [
        // { type: 'text', author: `me`, data: { text: `Say yes!` } },
        { type: 'text', author: `user1`, data: { text: `你好，我是DatalinkX智能问答助手` } }
      ], // the list of the messages to show, can be paginated and adjusted dynamically
      newMessagesCount: 0,
      isChatOpen: false, // to determine whether the chat window should be open or closed
      showTypingIndicator: '', // when set to a value matching the participant.id it shows the typing indicator for the specific user
      colors: {
        header: {
          bg: '#4e8cff',
          text: '#ffffff'
        },
        launcher: {
          bg: '#4e8cff'
        },
        messageList: {
          bg: '#ffffff'
        },
        sentMessage: {
          bg: '#4e8cff',
          text: '#ffffff'
        },
        receivedMessage: {
          bg: '#eaeaea',
          text: '#222222'
        },
        userInput: {
          bg: '#f4f7f9',
          text: '#565867'
        }
      }, // specifies the color scheme for the component
      alwaysScrollToBottom: false, // when set to true always scrolls the chat to the bottom when new events are in (new message, user starts typing...)
      messageStyling: true // enables *bold* /emph/ _underline_ and such (more info at github.com/mattezza/msgdown)
    }
  },
  methods: {
    reload () {
      this.ifRouterAlive = false
      this.$nextTick(() => {
        this.ifRouterAlive = true
      })
    },
    onMessageWasSent (message) {
      // called when the user sends a message
      this.messageList = [...this.messageList, message]
      const lastChild = document.querySelector('.sc-message-list').lastElementChild
      lastChild.style.display = 'block'

      const eventSource = new EventSource('api/api/copilot/stream/chat?question=' + message.data.text)
      eventSource.onopen = function (event) {
        console.log(event.data)
      }
      const answerId = this.getTimestamp()
      var self = this
      eventSource.onmessage = function (event) {
        console.log(event.data)
        var modelMessage = JSON.parse(event.data)

        console.log(answerId)
        let flag = 0
        for (const message of self.messageList) {
          if (message.id === answerId) {
            flag = 1
            console.log(message.data.text)
            message.data.text = message.data.text.concat(modelMessage.message.content)
          }
        }
        if (flag === 0) {
          const answer = {
            type: 'text',
            author: `user1`,
            id: answerId,
            data: {
              text: modelMessage.message.content
            }
          }
          self.messageList.push(answer)
        }
      }
      eventSource.onerror = function (error) {
        console.error('Error:', error)
        lastChild.style.display = 'none'
        eventSource.close()
      }
      // eventSource.close()
    },
    openChat () {
      // called when the user clicks on the fab button to open the chat
      this.isChatOpen = true
      this.newMessagesCount = 0
    },
    closeChat () {
      // called when the user clicks on the botton to close the chat
      this.isChatOpen = false
    },
    handleScrollToTop () {
      // called when the user scrolls message list to top
      // leverage pagination for loading another page of messages
    },
    handleOnType () {
      console.log('Emit typing event')
    },
    editMessage (message) {
      const m = this.messageList.find(m => m.id === message.id)
      m.isEdited = true
      m.data.text = message.data.text
    },
    getTimestamp () {
      return new Date().getTime() + Math.random()
    }
  },
  computed: {
    locale () {
      // 只是为了切换语言时，更新标题
      const { title } = this.$route.meta
      title && (setDocumentTitle(`${i18nRender(title)} - ${domTitle}`))

      return this.$i18n.getLocaleMessage(this.$store.getters.lang).antLocale
    }
  }
}
</script>

<style scoped>
h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}

.chat-container {
  position: relative;
  z-index: 9999;
}

* {
  box-sizing: border-box;
}

*::before, *::after {
  box-sizing: border-box;
}
</style>
