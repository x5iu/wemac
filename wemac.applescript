-- 微信聊天窗口名称，如果是私聊是对方的昵称或备注，如果是群聊则是群聊名称（暂时只支持一个聊天窗口）
global chatWindowName

-- Bot 名称，用于处理 @ 消息
global botName

-- Python 解释器路径
global pythonBin

-- 工作目录
global workingDir

-- 聊天窗口偏移大小，用于确定回复消息的位置，请根据具体的显示器大小和分辨率进行设置
global windowOffset

set chatWindowName to "CHAT_WINDOW_NAME"
set botName to "YOUR_BOT_NAME"
set pythonBin to "python3"
set workingDir to "./"
set windowOffset to 2400

on leftClick(p)
	set x to the first item of p
	set y to the (last item of p) - 3
	do shell script pythonBin & space & workingDir & "mouseclick.py" & space & (x as text) & space & (y as text) & space & "1"
end leftClick

on rightClick(p)
	set x to the (first item of p) + 61
	set y to the (last item of p) + 13
	do shell script pythonBin & space & workingDir & "mouseclick.py" & space & (x as text) & space & (y as text) & space & "2"
end rightClick

on rightClickMy(p)
	set x to the (first item of p) + 61 + windowOffset
	set y to the (last item of p) + 13
	do shell script pythonBin & space & workingDir & "mouseclick.py" & space & (x as text) & space & (y as text) & space & "2"
end rightClickMy

on isMaxWechatWindow()
	tell application "Finder"
		set windowBounds to bounds of window of desktop
	end tell
	tell application "WeChat"
		set wechatBound to bounds of first window
	end tell
	set windowX to item 3 of windowBounds
	set windowY to item 4 of windowBounds
	set wechatX to item 3 of wechatBound
	set wechatY to item 4 of wechatBound
	return ((wechatX * wechatY) / (windowX * windowY)) ≥ 0.8
end isMaxWechatWindow

on replace(s, old, new)
	set AppleScript's text item delimiters to the old
	set parts to every text item of s
	set AppleScript's text item delimiters to the new
	set replaced to the parts as string
	set AppleScript's text item delimiters to ""
	return replaced
end replace

on removeHeader(s)
	set AppleScript's text item delimiters to ":"
	set parts to text items of s
	if (count of parts) > 1 then
		set newText to (items 2 through (count of parts) of parts) as string
	else
		set newText to s
	end if
	set AppleScript's text item delimiters to ""
	return newText
end removeHeader

on strip(s, p)
	if s starts with p then
		set AppleScript's text item delimiters to p
		set parts to text items of s
		set AppleScript's text item delimiters to ""
		if (count of parts) > 1 then
			return (items 2 through (count of parts) of parts) as string
		else
			return s
		end if
	else
		return s
	end if
end strip

on escaped(s)
	return replace(s, "'", "'\"'\"'")
end escaped

on deleteMessage(messageElement)
	tell application "WeChat" to activate
	delay 1.5
	tell application "System Events"
		set messagePosition to position of messageElement
		my rightClick(messagePosition)
		if exists menu 1 of messageElement then
			repeat with menuItem in menu items of menu 1 of messageElement
				if (name of menuItem) contains "删除" then
					my leftClick(position of menuItem)
					delay 0.5
					key code 36
					return true
				end if
			end repeat
			return false
		else
			return false
		end if
	end tell
end deleteMessage

on deleteMessageMy(messageElement)
	tell application "WeChat" to activate
	delay 1.5
	tell application "System Events"
		my rightClickMy(position of messageElement)
		if exists menu 1 of messageElement then
			repeat with menuItem in menu items of menu 1 of messageElement
				if (name of menuItem) contains "多选" then
					my leftClick(position of menuItem)
					delay 0.5
					set delButton to button 5 of toolbar 1 of splitter group 1 of splitter group 1 of window 1 of process "微信"
					my leftClick(position of delButton)
					delay 0.5
					key code 36
					return true
				end if
			end repeat
		end if
		my rightClickMy(position of messageElement)
		if exists menu 1 of messageElement then
			set menuItem to last menu item of menu 1 of messageElement
			if (name of menuItem) contains "删除" then
				my leftClick(position of menuItem)
				delay 0.5
				key code 36
				return true
			else
				key code 53
				delay 1.5
				return false
			end if
		else
			delay 1.5
			return false
		end if
	end tell
end deleteMessageMy

on reply(msg)
	if (length of msg) > 0 then
		set the clipboard to "" -- clear clipboard
		delay 0.5
		set the clipboard to msg
		if (the clipboard as text) is not equal to msg then
			set the clipboard to msg
		end if
		if (the clipboard as text) ≠ msg then
			set the clipboard to msg
		end if
	end if
	tell application "WeChat" to activate
	delay 1.5
	tell application "System Events"
		tell process "微信"
			tell splitter group 1 of window 1
				my leftClick(position of scroll area 2 of splitter group 1)
				keystroke "v" using command down
				delay 0.7
				set the clipboard to "" -- clear clipboard
				key code 36
				delay 2 -- to ensure message has been sent
			end tell
		end tell
	end tell
end reply

on switchToChat(targetName)
	tell application "System Events"
		tell process "微信"
			tell window 1
				tell table 1 of scroll area 1 of splitter group 1
					repeat with chat in rows
						if exists first row of UI element 1 of chat then
							set chatName to name of first row of UI element 1 of chat
							if chatName starts with targetName then
								my leftClick(position of chat)
								return true
							end if
						end if
					end repeat
				end tell
			end tell
		end tell
	end tell
	return false
end switchToChat

tell application "WeChat" to activate
delay 0.7

-- activate
tell application "System Events"
	set counter to 0
	repeat until (counter > 4) or (window 1 of process "微信" exists)
		set counter to counter + 1
		delay 1
	end repeat
end tell

-- esc
tell application "System Events"
	key code 53
	delay 0.5
end tell

-- login and resize window
tell application "System Events"
	tell process "微信"
		tell window 1
			set loginRequire to false
			repeat with btn in every button
				if name of btn is "切换账号" then
					set loginRequire to true
				end if
			end repeat
			if loginRequire then
				set loginButton to button 2
				my leftClick(position of loginButton)
				delay 3 -- wait login
			end if
		end tell
		if not my isMaxWechatWindow() then
			click menu item "缩放" of menu "窗口" of menu bar 1
		end if
	end tell
end tell

tell application "System Events"
	tell process "微信"
		tell window 1
			if not my switchToChat(chatWindowName) then
				return
			end if
			set username to name of static text of splitter group 1 of splitter group 1
			if exists first item of username then
				set username to first item of username
			end if
			if username starts with chatWindowName then
				tell scroll area 1 of splitter group 1 of splitter group 1
					tell table 1
						set i to 8 -- 用于跳过非聊天信息类的 item，例如消息撤回、群成员邀请等，这些信息无法被删除，只能跳过
						set n to 0
						repeat until i < 0
							key code 53 -- 在每次处理消息前按一下 ESC，用于关闭一些意想不到的菜单和弹窗（通常是误触或者其他进程产生的），能解决很多问题
							set i to i - 1
							set l to count rows
							if (l - n) ≤ 0 then
								delay 2
								return
							end if
							set message to item (l - n) of rows
							set messageElement to UI element 1 of UI element 1 of message
							set messageContent to name of messageElement
							if messageContent does not start with "我" then
								if my deleteMessage(messageElement) then
									if messageContent contains ("@" & botName) then
										set question to my removeHeader(messageContent)
										set question to my replace(question, ("@" & botName), "")
										-------------------
										-- 消息处理逻辑 --
										-------------------
										set replyMessage to "YOUR_REPLY"
										my reply(replyMessage)
									end if
									return
								else
									set n to n + 1
								end if
							else
								if my deleteMessageMy(messageElement) then
									delay 0.5
									return
								else
									set n to n + 1
								end if
							end if
							delay 0.7
						end repeat
					end tell
				end tell
			end if
		end tell
	end tell
end tell
