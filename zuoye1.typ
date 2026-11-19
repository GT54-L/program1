#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2026      046241     高统乐     20241004448", header: "")


#let pvd =math.partial

*作业*

#box-blue[
  *一 上课遇到过的问题*
]

*(1)*.登陆老师的服务器时文件路径错误

*(2)*.引入老师的profile文件的时候，首先是extension下载很慢，后来引入之后总是和老师服务器断开连接（ai说原因可能是外网下载会触发重启，超时后就会反复断开）

*(3)*.引入firday语音助手的时候报错，找不到输出路径（理由是音频没写对或者uxv在非交互shell里可能没有）

*(4)*.登录github以老师的模版创建仓库时，回来在终端里复制下来后想要打开用 code . 时，打开的是一个断开的新窗口

*(5)*.目前老师最后演示的终端和文件交互的内容还没有完全理解，后续需要再学习
\
\
#box-blue[
  *二 地转风公式*
]


1.矢量形式

*$
  arrow(V)_g = 1/(rho f) arrow(k) times nabla_h p quad "(z 坐标系)" #h(1fr)
$* 

*$
   arrow(V)_g = g/f arrow(k) times nabla_p Z quad "(p 坐标系)" #h(1fr)
 $*

2.分量形式

*$
cases(
  u_g &= -1/(rho f) (pvd p)/(pvd y),
  v_g &= 1/(rho f) (pvd p)/(pvd x)
) quad "(z 坐标系)" #h(1fr)
$*
\
*$
cases(
  u_g = -g/f (pvd Z)/(pvd y),
  v_g = g/f (pvd Z)/(pvd x)
) quad "(p 坐标系)" #h(1fr)
$*




















