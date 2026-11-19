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
\
#box-blue[
  *二 地转风公式*
]


1.矢量形式

$
  arrow(V)_g = 1/(rho f) arrow(k) times nabla_h p quad "(z 坐标系)" #h(1fr)
$

$
   arrow(V)_g = g/f arrow(k) times nabla_p Z quad "(p 坐标系)" #h(1fr)
 $

2.分量形式

$
cases(
  u_g &= -1/(rho f) pdv(p,y),
  v_g &= 1/(rho f) pdv(p,x)
) quad "(z 坐标系)" #h(1fr)
$
\
$
cases(
  u_g = -g/f pdv(Z,y),
  v_g = g/f pdv(Z,x)
 ) quad "(p 坐标系)" #h(1fr)
$
\
\
\
\
#box-blue[
  3.推导过程（选取z坐标系推导）
  ]
首先是忽略摩擦项的水平运动方程：
$
  (d arrow(V))/ (d t)= -f arrow(k) times arrow(V) - 1/ rho nabla_z p
$

由于地转风地转平衡，加速度为零，得到：
$
  0 = -f arrow(k) times arrow(V)_g - 1/ rho nabla_z p
$

再移项得到：

$
  f arrow(k) times arrow(V)_g = - 1/ rho nabla_z p
$

两边同时*k*×，得到：

$
    f arrow(k)×( bold(k) times arrow(V)_g) = -1/rho arrow(k) times nabla_z p
$

利用矢量恒等式$f arrow(k)×( arrow(k) times arrow(V)_g) =-f arrow(V)_g $：

$
  arrow(V)_g =1/ (f rho) arrow(k) times nabla_z p
$

分量形式取x轴向东，y轴向北：
$
cases(
  u_g = -1/ (f rho) pdv(p,y),
  v_g = 1/ (f rho) pdv(p,x)
)
$


















