# Mac 版微信 RPA 群聊机器人

这是一个利用 AppleScript 和 Mac 版微信客户端制作的简易版微信机器人。这个机器人起源于我想做一个 ChatBot，帮我记录消费、饮食、运动等数据，以及帮我总结微信公众号文章内容。目前利用个人微信实现 ChatBot 的方案，主流的是 wechaty，但是 wechaty 使用的 puppet 中，免费的网页版或 UOS 版本不够稳定（不稳定的意思是经常莫名奇妙被踢下线），稳定且功能丰富的 ipadloacl 等方案又需要花费额外的金币购买 token。于是我经过一些小小的尝试，实现了这个速度慢、功能少但足够稳定的微信机器人（*选择 Mac 版微信客户端是因为我手上只有 Mac 设备*）。

## 如何跑起来

这个机器人主要利用 AppleScript 完成，辅以一些 Python 代码，使用 Python 是因为 AppleScript 自带的鼠标点击操作无法作用于微信客户端，因此使用了额外的 Python 库来实现点击操作。因此，你需要先有一个 Python3 的解释器，以及安装 [PyUserInput](https://github.com/PyUserInput/PyUserInput)：

```
pip3 install PyUserInput
```

当然，如果你有其他模拟鼠标点击的方案，也可以用自己的（在写这篇 README 时才发现 PyUserInput 已经 Deprecated 了）。

接下来，你需要修改 `wemac.applescript` 中的一些配置，如下所示：

- **chatWindowName**: 指定当前处理哪一个窗口的聊天，如果是私聊则是对方的昵称或备注，如果是群聊则是群聊名称;
- **botName**: 机器人本身账号的名称，其作用是判断是否有人 at 自己，然后进行回复;
- **pythonBin**: Python3 解释器的路径;
- **workingDir**: 工作目录，也是放置 `mouseclick.py` 文件的目录;
- **windowOffset**: 基本上，这个值是显示器宽度 - 400 - 20，它的作用是用于定位由机器人发送的消息的位置（如果你发现执行 AppleScript 的过程中，脚本无法顺利删除机器人自己发送的消息，请尝试调整这个值）;

设置完上述变量后，就可以尝试运行一次脚本了，**运行之前，请确保已登录 Mac 版微信**。执行脚本，你会发现 AppleScript 会自动找到目标的聊天，点击聊天窗口，~~并开始删除最近的一条聊天记录~~ **2025-12-23 更新，现在会滚动屏幕到第一条消息处，从第一条消息处开始删除消息**，没错，这个 AppleScript 会删除聊天记录，这是因为没有地方记录每条消息是否已被回复，只能通过删除消息的方式来避免重复回复消息；删除完消息后，如果这条消息 at 了机器人，则会进行回复；然后，AppleScript 的执行就结束了，注意，**一次 AppleScript 执行只会处理一条消息**。

那么如何让机器人一直运作下去呢，可行的方案是写个 `run.sh`，在里面写死循环不断执行 `wemac.applescript`（事实上我自己也是这么做的）。

### 如何自定义回复内容

如果想自定义回复内容，比如接入大语言模型，在 `wemac.applescript` 的 320 行，“消息处理逻辑”注释处，你可以添加自己的回复逻辑，由于 AppleScript 本身能力有限，你可以利用 shell 外接其他语言，例如 Python，你可以用以下方式调用 [Kimi CLI](https://github.com/MoonshotAI/kimi-cli) 来获得 Kimi 的回复：

```
set replyMessage to do shell script "kimi --print -c '" & (my escaped(question)) & "' --output-format stream-json | tail -n1 | jq -r '.content[-1].text'"
```

被执行的 shell 的标准输出（stdout）将会赋值给 `replyMessage`，然后作为回复由机器人发出去。

在拼接 shell 命令时，可以使用 `escaped` 函数转义参数，以避免注入攻击。

至此，一个简单的聊天机器人就跑起来了，期间可能遇到一些无法定位元素的错误，但是一般而言忽略他们重新运行一遍 AppleScript 就可以了。

## 局限

- 无法获取用户唯一 ID，openid 和 unionid 都不可以，只有昵称或备注；
- 无法获取消息的唯一 ID，只能处理一条删一条；
- 处理速度慢，如果群聊的速度大于 AppleScript 的运行速度，那就会出现消息永远无法被处理的情况；
- 必须用一台 Mac 来 Host，当然也可以通过开虚拟机的方式让一台 Mac 运行多个机器人；
- 一个 AppleScript 脚本只能处理一个聊天窗口，当然也可以在 `run.sh` 中同时添加多个 AppleScript 以处理不同的聊天，但这样会拖慢运行速度；

但好处就是足够稳定，只要登录上基本能一直运行下去，而且用 AppleScript 模拟点击理论上也不会被微信检测到异常行为导致封号。

## 其他

使用的 Mac 微信客户端版本是 `Version. 3.8.6 (28078)`。

## TODO

- [ ] 支持处理图片、语音、链接等消息；
- [ ] 支持发送图片、文件；
- [ ] 支持发送朋友圈；
- [ ] **支持企业微信**；
