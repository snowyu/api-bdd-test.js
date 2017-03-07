功能: 测试编辑

@功能前提
场景: 清空数据
  假定 DELETE "bottle"

场景: 创建瓶子

  假定 新建资源"bottle"成功,内容为
    ----
    id: 'create_22'
    a: 1
    b: 2
    ----

  假定 新建资源:bottle 内容为
    ----
    id: 'create1'
    a: 1
    b: 2
    ----

  那么 期望上次的状态为200.
  并且 期望上次的结果包括：
    ----
    a: 1
    ----

  并且 希望获得id为"create1"的资源(bottle)，其结果为
    ----
    id:'create1'
    a:1
    b:2
    ----

场景: 修改瓶子
  假定 存在新建资源:bottle 内容为
    ----
    id: 'modify1'
    a: 222
    b: 11
    ----

  当 修改id为"modify1"的资源:bottle 内容为:
    ----
    a: 'A1'
    b: 'b1'
    ----

  那么 希望获得id为"modify1"的资源(bottle)，其结果为
    ----
    id: 'modify1'
    a: 'A1'
    b: 'b1'
    ----

