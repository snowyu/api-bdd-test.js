功能: THis is a test

Scenario: story 1

  Given this is a general lib
  假定 这是中文通用库测试
  假定 删除指定条件的资源
  # 假定 这是中文特定功能步骤加载

@pending
@resource=bottle
场景: 默认资源

  假定 新建资源 内容为
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
