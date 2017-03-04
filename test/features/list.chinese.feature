功能: 查询

@功能前提
@功能收尾
# @pending
场景: 清空数据
  假定 DELETE "bottle"
  并且 increment _incr_

@功能收尾
场景: 检视自增变量
  假定 期望保留的"s"=8
  假定 期望保留的"sc"=5
  假定 期望保留的"_incr_"=2


@场景前提
场景: 增加变量数据Sc
  假定 increment sc

@beforeStep
场景: 增加变量数据beforeStep
  假定 increment s

场景: 先创建一系列的瓶子

  假定 新建资源:bottle 内容为[newItem]

  Examples:
  |-----------------|
  | newItem         |
  |-----------------|
  | id: "A1"        |
  | a: 'a1'         |
  | b: 'b1'         |
  |-----------------|
  | id: "A2"        |
  | a: 2            |
  | b: 'b2'         |
  |-----------------|
  | id: "id3"       |
  | a: 3            |
  | b: 'b3'         |
  |-----------------|

场景: 列出资源
  当   列出资源:bottle
  那么 期望上次的结果是：
    ----
    [
      id: 'A1'
      a: 'a1'
      b: 'b1'
    ,
      id: "A2"
      a: 2
      b: 'b2'
    ,
      id: "id3"
      a: 3
      b: 'b3'
    ]
    ----

场景: 搜索资源

  当   搜索资源:bottle，按如下设置:
  ---
  filter: where: a:3
  ---
  那么 期望上次的结果是：
    ----
    [
      id: "id3"
      a: 3
      b: 'b3'
    ]
    ----
