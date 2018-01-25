---
title: vue 模块化开发(二)
date: 2017-09-17 09:16:46
categories: "前端之巅"
tags: '前端'
---

## vue组件化开发

better-scroll 是一个移动端滚动的解决方案，它是基于 iscroll 的重写，它和 iscroll 的主要区别在这里。better-scroll 也很强大，不仅可以做普通的滚动列表，还可以做轮播图、picker 等等。

better-scroll 对外暴露了一个 BScroll 的类，我们初始化只需要 new 一个类的实例即可。第一个参数就是我们 wrapper 的 DOM 对象，第二个是一些配置参数，具体参考 [better-scroll](http://link.zhihu.com/?target=https%3A//github.com/ustbhuangyi/better-scroll)的文档。

better-scroll 的初始化时机很重要，因为它在初始化的时候，会计算父元素和子元素的高度和宽度，来决定是否可以纵向和横向滚动。因此，我们在初始化它的时候，必须确保父元素和子元素的内容已经正确渲染了。如果子元素或者父元素 DOM 结构发生改变的时候，必须重新调用 scroll.refresh() 方法重新计算来确保滚动效果的正常。所以同学们反馈的 better-scroll 不能滚动的原因多半是初始化 better-scroll 的时机不对，或者是当 DOM 结构发送变化的时候并没有重新计算 better-scroll。

使用[better-scroll](better-scroll)

使用过小程序的大家都知道scroll-view小程序有个这个下啦组件可以直接调用,下面我们也写一个

### html部分

~~~
<template>
  <div class="wrapper" ref="wrapper">
    <ul class="content">
      <li>...</li>
      <li>...</li>
      ...
    </ul>
  </div>
</template>
~~~

### js部分

~~~
<script>
  import BScroll from 'better-scroll'
  export default {
    mounted() {
      this.$nextTick(() => {
        this.scroll = new Bscroll(this.$refs.wrapper, {})
      })
    }
  }
</script>
~~~

Vue.js 提供了我们一个获取 DOM 对象的接口—— vm.$refs。在这里，我们通过了 this.$refs.wrapper访问到了这个 DOM 对象，并且我们在 mounted 这个钩子函数里，this.$nextTick 的回调函数中初始化 better-scroll 。因为这个时候，wrapper 的 DOM 已经渲染了，我们可以正确计算它以及它内层 content 的高度，以确保滚动正常。

### 异步数据的处理

在我们的实际工作中，列表的数据往往都是异步获取的，因此我们初始化 better-scroll 的时机需要在数据获取后，代码如下：

~~~
<template>
  <div class="wrapper" ref="wrapper">
    <ul class="content">
      <li v-for="item in data">{{item}}</li>
    </ul>
  </div>
</template>
<script>
  import BScroll from 'better-scroll'
  export default {
    data() {
      return {
        data: []
      }
    },
    created() {
      requestData().then((res) => {
        this.data = res.data
        this.$nextTick(() => {
          this.scroll = new Bscroll(this.$refs.wrapper, {})
        })
      })
    }
  }
</script>
~~~

这里的 requestData 是伪代码，作用就是发起一个 http 请求从服务端获取数据，并且这个函数返回的是一个 promise（实际项目中我们可能会用 axios 或者 vue-resource）。我们获取到数据的后，需要通过异步的方式再去初始化 better-scroll，因为 Vue 是数据驱动的， Vue 数据发生变化（this.data = res.data）到页面重新渲染是一个异步的过程，我们的初始化时机是要在 DOM 重新渲染后，所以这里用到了 this.$nextTick，当然替换成 setTimeout(fn, 20) 也是可以的。

为什么这里在 created 这个钩子函数里请求数据而不是放到 mounted 的钩子函数里？因为 requestData 是发送一个网络请求，这是一个异步过程，当拿到响应数据的时候，Vue 的 DOM 早就已经渲染好了，但是数据改变 —> DOM 重新渲染仍然是一个异步过程，所以即使在我们拿到数据后，也要异步初始化 better-scroll。

### 数据的动态更新

我们在实际开发中，除了数据异步获取，还有一些场景可以动态更新列表中的数据，比如常见的下拉加载，上拉刷新等。比如我们用 better-scroll 配合 Vue 实现下拉加载功能，代码如下：

~~~
<template>
  <div class="wrapper" ref="wrapper">
    <ul class="content">
      <li v-for="item in data">{{item}}</li>
    </ul>
    <div class="loading-wrapper"></div>
  </div>
</template>
<script>
  import BScroll from 'better-scroll'
  export default {
    data() {
      return {
        data: []
      }
    },
    created() {
      this.loadData()
    },
    methods: {
      loadData() {
        requestData().then((res) => {
          this.data = res.data.concat(this.data)
          this.$nextTick(() => {
            if (!this.scroll) {
              this.scroll = new Bscroll(this.$refs.wrapper, {})
              this.scroll.on('touchend', (pos) => {
                // 下拉动作
                if (pos.y > 50) {
                  this.loadData()
                }
              })
            } else {
              this.scroll.refresh()
            }
          })
        })
      }
    }
  }
</script>
~~~

这段代码比之前稍微复杂一些, 当我们在滑动列表松开手指时候， better-scroll 会对外派发一个 touchend 事件，我们监听了这个事件，并且判断了 pos.y > 50（我们把这个行为定义成一次下拉的动作）。如果是下拉的话我们会重新请求数据，并且把新的数据和之前的 data 做一次 concat，也就更新了列表的数据，那么数据的改变就会映射到 DOM 的变化。需要注意的一点，这里我们对 this.scroll 做了判断，如果没有初始化过我们会通过 new BScroll 初始化，并且绑定一些事件，否则我们会调用 this.scroll.refresh 方法重新计算，来确保滚动效果的正常。

这里，我们就通过 better-scroll 配合 Vue，实现了列表的下拉刷新功能，上拉加载也是类似的套路，一切看上去都是 ok 的。但是，我们发现这里写了大量命令式的代码（这一点不是 Vue.js 推荐的），如果有很多类似滚动的组件，我们就需要写很多类似的命令式且重复性的代码，而且我们把数据请求和 better-scroll 也做了强耦合，这些对于一个追求编程逼格的人来说，就不 ok 了。

### scroll 组件的抽象和封装

首先，我们要考虑的是 scroll 组件本质上就是一个可以滚动的列表组件，至于列表的 DOM 结构，只需要满足 better-scroll 的 DOM 结构规范即可，具体用什么标签，有哪些辅助节点（比如下拉刷新上拉加载的 loading 层），这些都不是 scroll 组件需要关心的。因此， scroll 组件的 DOM 结构十分简单，如下所示：

~~~
<template>
  <div ref="wrapper">
    <slot></slot>
  </div>
</template>
~~~

这里我们用到了 Vue 的特殊元素—— slot 插槽，它可以满足我们灵活定制列表 DOM 结构的需求。接下来我们来看看 JS 部分：

~~~
<script type="text/ecmascript-6">
  import BScroll from 'better-scroll'

  export default {
    props: {
      /**
       * 1 滚动的时候会派发scroll事件，会截流。
       * 2 滚动的时候实时派发scroll事件，不会截流。
       * 3 除了实时派发scroll事件，在swipe的情况下仍然能实时派发scroll事件
       */
      probeType: {
        type: Number,
        default: 1
      },
      /**
       * 点击列表是否派发click事件
       */
      click: {
        type: Boolean,
        default: true
      },
      /**
       * 是否开启横向滚动
       */
      scrollX: {
        type: Boolean,
        default: false
      },
      /**
       * 是否派发滚动事件
       */
      listenScroll: {
        type: Boolean,
        default: false
      },
      /**
       * 列表的数据
       */
      data: {
        type: Array,
        default: null
      },
      /**
       * 是否派发滚动到底部的事件，用于上拉加载
       */
      pullup: {
        type: Boolean,
        default: false
      },
      /**
       * 是否派发顶部下拉的事件，用于下拉刷新
       */
      pulldown: {
        type: Boolean,
        default: false
      },
      /**
       * 是否派发列表滚动开始的事件
       */
      beforeScroll: {
        type: Boolean,
        default: false
      },
      /**
       * 当数据更新后，刷新scroll的延时。
       */
      refreshDelay: {
        type: Number,
        default: 20
      }
    },
    mounted() {
      // 保证在DOM渲染完毕后初始化better-scroll
      setTimeout(() => {
        this._initScroll()
      }, 20)
    },
    methods: {
      _initScroll() {
        if (!this.$refs.wrapper) {
          return
        }
        // better-scroll的初始化
        this.scroll = new BScroll(this.$refs.wrapper, {
          probeType: this.probeType,
          click: this.click,
          scrollX: this.scrollX
        })

        // 是否派发滚动事件
        if (this.listenScroll) {
          this.scroll.on('scroll', (pos) => {
            this.$emit('scroll', pos)
          })
        }

        // 是否派发滚动到底部事件，用于上拉加载
        if (this.pullup) {
          this.scroll.on('scrollEnd', () => {
            // 滚动到底部
            if (this.scroll.y <= (this.scroll.maxScrollY + 50)) {
              this.$emit('scrollToEnd')
            }
          })
        }

        // 是否派发顶部下拉事件，用于下拉刷新
        if (this.pulldown) {
          this.scroll.on('touchend', (pos) => {
            // 下拉动作
            if (pos.y > 50) {
              this.$emit('pulldown')
            }
          })
        }

        // 是否派发列表滚动开始的事件
        if (this.beforeScroll) {
          this.scroll.on('beforeScrollStart', () => {
            this.$emit('beforeScroll')
          })
        }
      },
      disable() {
        // 代理better-scroll的disable方法
        this.scroll && this.scroll.disable()
      },
      enable() {
        // 代理better-scroll的enable方法
        this.scroll && this.scroll.enable()
      },
      refresh() {
        // 代理better-scroll的refresh方法
        this.scroll && this.scroll.refresh()
      },
      scrollTo() {
        // 代理better-scroll的scrollTo方法
        this.scroll && this.scroll.scrollTo.apply(this.scroll, arguments)
      },
      scrollToElement() {
        // 代理better-scroll的scrollToElement方法
        this.scroll && this.scroll.scrollToElement.apply(this.scroll, arguments)
      }
    },
    watch: {
      // 监听数据的变化，延时refreshDelay时间后调用refresh方法重新计算，保证滚动效果正常
      data() {
        setTimeout(() => {
          this.refresh()
        }, this.refreshDelay)
      }
    }
  }
</script>
~~~

JS 部分实际上就是对 better-scroll 做一层 Vue 的封装，通过 props 的形式，把一些对 better-scroll 定制化的控制权交给父组件；通过 methods 暴露的一些方法对 better-scroll 的方法做一层代理；通过 watch 传入的 data，当 data 发生改变的时候，在适当的时机调用 refresh 方法重新计算 better-scroll 确保滚动效果正常，这里之所以要有一个 refreshDelay 的设置是考虑到如果我们对列表操作用到了 transition-group 做动画效果，那么 DOM 的渲染完毕时间就是在动画完成之后。

有了这一层 scroll 组件的封装，我们来修改刚刚最复杂的代码（假设我们已经全局注册了 scroll 组件）。

~~~
<template>
  <scroll class="wrapper"
          :data="data"
          :pulldown="pulldown"
          @pulldown="loadData">
    <ul class="content">
      <li v-for="item in data">{{item}}</li>
    </ul>
    <div class="loading-wrapper"></div>
  </scroll>
</template>
<script>
  import BScroll from 'better-scroll'
  export default {
    data() {
      return {
        data: [],
        pulldown: true
      }
    },
    created() {
      this.loadData()
    },
    methods: {
      loadData() {
        requestData().then((res) => {
          this.data = res.data.concat(this.data)
        })
      }
    }
  }
</script>
~~~
















