# language: Chinese
功能: 测试创建

背景: 清空数据
  假定 DELETE "bottle"

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
  并且 记住结果的"body.id"到"myid"
  并且 记住`result.body.id`到"myid1"
  并且 记住结果到"myres"
  那么 期望存在保留的"myid"
  并且 期望存在"myres"
  并且 期望不存在"myresxxx"
  并且 期望保留的"myid">=1
  并且 期望保留的"myid"不等于2
  并且 期望保留的"myid"=1
  并且 期望保留的"myid1"=1
  并且 期望保留的"myres"包含:
    ---
      status:200
    ---
  并且 期望保留的"myres"包含key "status"
  并且 期望保留的"myres"不包含key "adstatus"
  并且 期望保留的"myres"包含key:
    ---
    "status"
    ---
  并且 希望获得id为`myid`的资源(bottle)，其结果为
    ----
    id:`myid`
    a:1
    b:2
    ----

  那么 存在id为"1"的资源(bottle)
  当 获得id为"1",过滤条件为"fields:'a'"的资源:bottle
  那么 期望上次的状态为200.
  并且 期望上次的结果是：
    ----
    a: 1
    ----

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
