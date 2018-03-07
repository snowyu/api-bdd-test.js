@pending
功能: 匹配结果

场景: 先创建一系列的瓶子

  假定 新建资源:bottle 内容为[newItem]

  Examples:
  |-----------------|
  | newItem         |
  |-----------------|
  | id: "match1"    |
  | a: 1234         |
  | b: 'b1'         |
  | c: [1,3,5]      |
  |-----------------|
  | id: "match2"    |
  | a: 34           |
  | b: 'b2'         |
  | c: [7,8]        |
  |-----------------|


@pending  
场景: 匹配资源结果
  当   列出资源:bottle
  那么 期望上次的结果匹配：
  ---
  [
    {
      id: _.isString,
      a: 1234,
      b: _.isString,
      c: _.isArray
    }
    ...
  ]
  ---
