# API BDD Test

Use the BDD(Cucumber) to test the RESTful API.


### Installation

1. Install in your project:

    `npm install --save-dev api-bdd-test mocha chai supertest loopback-supertest`

1. mkdir `test` in your project root folder
1. generate the `mocha.opts` file in the test folder:

    ```
    --timeout 10000
    --ui spec
    --growl
    --colors
    node_modules/api-bdd-test/index.js
    ```

  * Or run `mocha --ui spec node_modules/api-bdd-test/index.js` directly.
1. generate the `.api-bdd-test.json|.cson|.yml` in the root folder or test folder:

    ```yaml
    language: English
    server: "http://localhost:3000"
    root: "/api"
    libs: "./libs"
    steps: "./steps"
    features: "./features"
    ```

The feature specifications in the `features` folder for reading and testing.
The `language` is the default bdd language used in the specifications.
The `server` is the api server default url.
The `libs`, `steps` and `features` are the folders to store. the defauls is to
in the `test` folder.

### Usage

* test
   * ./features
     * a.feature
   * ./steps
     * a.steps.js
     * b-step.js
   * ./libs
     * some.lib.js
     * some.dict.js


#### features

* tag with `@only` before the scenario to execute the scenario only.
* tag with `@pending` before the scenario to stop the scenario.
* tag with `@before` before the scenario to turn the scenario to a before feature hook.
* tag with `@after` before the scenario to turn the scenario to a after feature hook.
* tag with `@beforeEach` before the scenario to turn the scenario to a before each scenario hook.
* tag with `@afterEach` before the scenario to turn the scenario to a after each scenario hook.
* tag with `@beforeStep` before the scenario to turn the before each step hook.
* tag with `@afterStep` before the scenario to turn the after each step hook.

```cucumber
@only
Scenario Calc two value
```

language supports with:

* File name postfix: a.english.feature
* first line of the file: `# language: English`

the `server`, `root/app`, `resource` could be setting in `.api-bdd-test.json|.cson|.yml` file.
Or as the annotations in a feature file.

the genernal api steps:

* `/(GET|HEAD|DEL(?:ETE)?)\s+$string/`
* `/(GET|HEAD|DEL(?:ETE)?|POST|PATCH|PUT)\s+$string[:]\n$object/`
  * the object is [cson format](https://github.com/bevry/cson)
  * data: send to
  * heads:
  * type: accepting the canonicalized MIME type name complete with type/subtype, or simply the extension name such as "xml", "json", "png", etc, defaults to 'json'
  * queries:
  * fields:
  * accepts:
  * attachments:
  * explain to see http://visionmedia.github.io/superagent/
* `/(?:last|prev(?:ious)?)\\s+results?\s+(?:should\s+)?(be|is|are|includes?)\n$object/`
* `/(?:last|prev(?:ious)?)\s+status\s*(?:code)?\\s*(?:should\\s+)?((?:be|is)(?:n't|\s+not)?)\s*[:]?\s*$integer/`
* keep the `result.body.id` to 'myvar'

eg,

```cucumber
Feature: Standard API Test

@before
Scenario: empty data before feature running
  Given DELETE "bottle"

Scenario: POST and Get result

  # POST 'http://127.0.0.1:3000/api/bottle'
  # with data
  #
  Given POST "bottle":
  ----
  type: 'json'
  data:
    id: 10
    a: 13
  ----
  Then The last status code should be: 200
  And The last status code should be not: 400
  And The last result should be:
  ----
  id: 10
  a: 13
  ----
  And keep the result of "body.id" to "myid"
  And keep the `result.body.id` to "myid1"
  And keep the result to "myres"
  And expect the stored `myid` equal 10
  And expect the stored `myid1` equal 10
  And expect the stored `myid` is not equal 0
  And expect the kept `myid` least 1
```

the genernal Chinese api steps:

* `新建资源:"resource",其内容为\n$object`
* `编辑(ID|编号)是:"the-id"的资源:"resource",其内容为\n$object`
* `删除(ID|编号)是:"the-id"的资源:"resource"`
* `检[查测]是否存在资源\\s*[:：]?[(（ ]$identifier(?:[)） ]\\s*[,，.。])?\\s*[:：]?$string`
* `/上次[的]?(?:状态[码]?|status)[为是：:]\s*$identifier/`
* `/上次[的]?(?:结果|body)([为是：:]|包[括含][：:]?)\s*\n$object/`
* `(?:获[取得]|取[得]?)(?:id|ID|编号)[为是:：]?$string的?资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?[的其]?(?:内容|结果)[为是]?\\n$object`
* `(?:获[取得]|取得?)资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?\\s*[:：]?$string`
* `([不]?会?存在|没有?|有)(?:id|ID|编号)[为是:：]?$string的?资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?`
* `/登[录陆]\s*用户[:：]\s*$string\s*[,，]\s*密码[:：]\s*$string/`
* `/注销用户|退出系统/`
* `/(?:记[住下忆]?|保[存留])结果的(?:属性)?$string到[:：]?$string/`
* `记住结果到"myvar"`
* `保存的"mvar"等于xxx`
* `/(不?存在)(?:记[住下忆]?|保[存留]的)?\s*$string$/`
* `列[出举]资源\\s*[:：]?[(（ ]$identifier(?:[)） ]\\s*[,，.。])?`
* `[搜查][索询找]资源\\s*'+resNameRegEx+'按?(?:指定|如下)?(?:条件|设置)[:：]?$object`
* ```记住`result.body[0].id`到"myvar"```
* `获得id为"id",过滤条件为"xxx"的资源: bottle`

#### steps and libs


The all scripts in the `libs` folder will be loaded.
The `a.steps.js` script in the `steps` folder will be loaded for `a.feature`.
The `steps` script file extend name should be end with `[.-]step[s]?\\.(js|coffee)`

The `libs` script(extend name should be end with`[.-](lib[s]?|dict[s]?)\.(js|coffee)`) should be like this:

```js
var Dictionary = Yadda.Dictionary;
var converters = Yadda.converters;

module.exports = function(dictionary){
  dictionary
  .define('integer', /(\d+)/, converters.integer);

  this
  .define('Expect $integer to be an integer', function(i, next) {
    assert.equal(typeof i, 'number');
    assert(i % 1 === 0);
    next();
  });
}
```

The `steps` script(file name should be `#{featureName}(.#{lang})?.step[s]?.(js|coffee)`) should be like this:

```js
//the `this` is the Yadda.Library() (bind to current language)
//the dict is the Yadda.Dictionary()
module.exports = function(dict){
  this.given("$integer green bottles are standing on the wall", function(number_of_bottles) {
    wall = new Wall(number_of_bottles);
    wall.printStatus();
   })
  .when("$integer green bottle accidentally falls", function(number_of_falling_bottles) {
      wall.fall(number_of_falling_bottles);
      console.log("%s bottle falls", number_of_falling_bottles);
  })
  .then("there are $integer green bottles standing on the wall", function(number_of_bottles) {
      assert.equal(number_of_bottles, wall.bottles);
      wall.printStatus();
  });
}
```

## limits

* no back ref in regexp.
* no optional group on `$xxx` defininition. eg, `$string?` should be wrong.
* report the `<-- Undefined Step` error:
  1. Duplication Regexp Step
  2. Optional Group in the regexp step.


## History

### V0.5.1

* [Broken] the `resNameRegEx`(Chinese) force use limiter to get the identifier.

### V 0.4.0

+ Add Special Scenarios
  * add the before/after annotations for feature hook
  * add the beforeEach/afterEach annotations for Scenario hook
  + add the beforeStep/afterStep annotations for step hook

### V 0.3.0

+ referernce the variaible which stored by steps. use the "``" delimiter instead.
  * it's an one line coffee-script code in this delimiter.
    * `\`"#{myid}"\``

## TODO

