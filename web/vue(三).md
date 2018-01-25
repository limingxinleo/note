---
title: vue vuex应用(三)
date: 2017-09-25 12:43:41
categories: "前端之巅"
tags: '前端'
---

## vue vuex

Vuex 是一个专为 Vue.js 应用程序开发的状态管理模式。它采用集中式存储管理应用的所有组件的状态，并以相应的规则保证状态以一种可预测的方式发生变化。Vuex 也集成到 Vue 的官方调试工具 devtools extension，提供了诸如零配置的 time-travel 调试、状态快照导入导出等高级调试功能。

### 传输参数

~~~
this.$router.push({
	name: 'singerDetail',
	params: {
	  id: singer.id
	}
})
this.$router.replace({
	name: 'singerDetail',
	query: {
	  id: singer.id
	}
})
~~~

但是后面我发现传输复杂的参数放在url总感觉不便，或者说子组件向父组件传参，或者说父组件向子组件传参都是比较麻烦的

### 基本用法

~~~
npm install vuex --save-dev
~~~

~~~
import Vuex from 'vuex';
Vue.use(Vuex);
~~~

### vuex里面有什么？

应用级的状态集中放在store中； 
改变状态的方式是提交mutations，这是个同步的事物； 
异步逻辑应该封装在action中。

~~~
const vuex_store = new Vuex.store({
    state:{
        xxx:oooo; // 定义你的数据源
    }
})
~~~

### State

State负责存储整个应用的状态数据，一般需要在使用的时候在跟节点注入store对象，后期就可以使用this.$store.state直接获取状态

~~~
//store为实例化生成的
import store from './store'

new Vue({
  el: '#app',
  store,
  render: h => h(App)
})
~~~

这个store可以理解为一个容器，包含着应用中的state等。实例化生成store的过程是：

~~~
const mutations = {...};
const actions = {...};
const state = {...};

Vuex.Store({
  state,
  actions,
  mutation
});
~~~

后续在组件中使用的过程中，如果想要获取对应的状态你就可以直接使用this.$store.state获取，当然，也可以利用vuex提供的mapState辅助函数将state映射到计算属性中去，如

~~~
//我是组件
import {mapState} from 'vuex'

export default {
  computed: mapState({
    count: state => state.count
  })
}
~~~

这样直接就可以在组件中直接使用了。

### Mutations

Mutations的中文意思是“变化”，利用它可以更改状态，本质就是用来处理数据的函数，其接收唯一参数值state。store.commit(mutationName)是用来触发一个mutation的方法。需要记住的是，定义的mutation必须是同步函数，否则devtool中的数据将可能出现问题，使状态改变变得难以跟踪。

~~~
const mutations = {
  mutationName(state) {
    //在这里改变state中的数据
  }
}
~~~

在组件中触发：

~~~
//我是一个组件
export default {
  methods: {
    handleClick() {
      this.$store.commit('mutationName')
    }
  }
}
~~~

或者使用辅助函数mapMutations直接将触发函数映射到methods上，这样就能在元素事件绑定上直接使用了。如：

~~~
import {mapMutations} from 'vuex'

//我是一个组件
export default {
  methods: mapMutations([
    'mutationName'
  ])
}
~~~

### Actions

Actions也可以用于改变状态，不过是通过触发mutation实现的，重要的是可以包含异步操作。其辅助函数是mapActions与mapMutations类似，也是绑定在组件的methods上的。如果选择直接触发的话，使用this.$store.dispatch(actionName)方法。

~~~
//定义Actions
const actions = {
  actionName({ commit }) {
    //dosomething
    commit('mutationName')
  }
}
~~~

在组件中使用

~~~
import {mapActions} from 'vuex'

//我是一个组件
export default {
  methods: mapActions([
    'actionName',
  ])
}
~~~

### Getters

有些状态需要做二次处理，就可以使用getters。通过this.$store.getters.valueName对派生出来的状态进行访问。或者直接使用辅助函数mapGetters将其映射到本地计算属性中去。

~~~
const getters = {
  strLength: state => state.aString.length
}
//上面的代码根据aString状态派生出了一个strLength状态
~~~

在组件中使用

~~~
import {mapGetters} from 'vuex'

//我是一个组件
export default {
  computed: mapGetters([
    'strLength'
  ])
}
~~~

### Plugins

插件就是一个钩子函数，在初始化store的时候引入即可。比较常用的是内置的logger插件，用于作为调试使用。

~~~
import createLogger from 'vuex/dist/logger'
const store = Vuex.Store({
  ...
  plugins: [createLogger()]
})
~~~

最后，还有一些高级用法，如严格模式，测试等可能使用频率不会特别高。有需要的时候查官方文档就可以了。总的来说，Vuex还是相对比较简单的，特别是如果之前有学过Flux,Redux之类的话，上手起来更加容易。

## 整合

~~~
目录
    ├── store                 
    │   ├── actions.js 
    │   ├── getters.js
    │   ├── index.js
    │   └── mutation-types.js
    │   └── mutations.js
    │   └── state.js
~~~


### mutation-types.js(放一些常量)

~~~
export const SET_SINGER = 'SET_SINGER'
~~~

### mutations.js

~~~
import * as types from './mutation-types'

const matutaions = {
  [types.SET_SINGER](state, singer) {
    state.singer = singer
  }
}

export default matutaions
~~~

### state.js

~~~
const state = {
  singer: {}
}

export default state
~~~

### getters.js

~~~
export const singer = state => state.singer
~~~

### index.js

~~~
import Vue from 'vue'
import Vuex from 'vuex'
import * as actions from './actions'
import * as getters from './getters'
import state from './state'
import mutations from './mutations'

import createLogger from 'vuex/dist/logger'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
  actions,
  getters,
  state,
  mutations,
  strict: debug,
  plugins: debug ? [createLogger()] : []
})

~~~

### main.js引入 

~~~
import store from './store'

new Vue({
  el: '#app',
  router,
  store,
  template: '<App/>',
  components: {
    App
  }
})
~~~









