# language: Chinese
功能: 测试创建


#@暂停
场景: 创建瓶子

  假定 新建资源:bottle 内容为
    ----
    id: 1
    a: 1
    b: 2
    ----

  那么 期望上次的状态为200.
  并且 期望上次的结果包括：
    ----
    a: 1
    ----

  并且 希望获得id为"1"的资源(bottle)，其结果为
    ----
    id:1
    a:1
    b:2
    ----

  那么 存在id为"1"的资源(bottle)
  当 删除id为"1"的资源(bottle)
  那么 不会存在id为"1"的资源(bottle)
  当 登录用户:'test1',密码:'123123'
  那么 期望上次的状态为200.
  那么 当注销用户
  那么 期望上次的状态为204.

场景: load test feature step

  假定 this is a special step
  假定 这是中文通用库测试
  假定 this is a general lib
  假定 这是中文特定功能步骤加载
