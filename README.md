# API BDD Test

Use the BDD(Cucumber) to test the RESTful API.


### Installation

1. Install in your project:

    `npm install --save-dev api-bdd-test mocha supertest supertest-as-promised`

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

language supports with:

* File name postfix: a.english.feature
* first line of the file: `# language: English`

the `server`, `root/app`, `resource` could be setting in `.api-bdd-test.json|.cson|.yml` file.
Or as the annotations in a feature file.

the genernal api steps:

* `/(GET|HEAD|DEL(?:ETE)?|POST|PATCH|PUT)\s+$string[:]?\n$object/`
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

eg,

```
Feature: Standard API Test

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
  Then The last status code should be not: 400
  Then The last result should be:
  ----
  id: 10
  a: 13
  ----
```


the genernal Chinese api steps:

* `[新创]建资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?[的其]?(?:内容|结果)[为是]?\\n$object`
* `[编修][辑改]资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?[的其]?(?:内容|结果)[为是]?\\n$object`
* `删[除掉](?:id|ID|编号)[为是:：]?$string的?资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?`
* `检[查测]是否存在资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?\\s*[:：]?$string`
* `/上次[的]?(?:状态[码]?|status)[为是：:]\s*$identifier/`
* `/上次[的]?(?:结果|body)([为是：:]|包[括含][：:]?)\s*\n$object/`
* `[希期]望(?:获[取得]|取[得]?)(?:id|ID|编号)[为是:：]?$string的?资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?[的其]?(?:内容|结果)[为是]?\\n$object`
* `(?:获[取得]|取得?)资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?\\s*[:：]?$string`
* `([不]?会?存在|没有?|有)(?:id|ID|编号)[为是:：]?$string的?资源\\s*[:：]?[(（]?$identifier(?:[)）]?\\s*[,，.。])?`
* `/登[录陆]\s*用户[:：]\s*$string\s*[,，]\s*密码[:：]\s*$string/`
* `/注销用户|退出系统/`
* `/(?:记[住下忆]?|保[存留])结果的(?:属性)?$string到[:：]?$string/`
* `记住结果到"myvar"`
* `期望保存的"mvar"等于xxx`
* `/[期希]望(不?存在)(?:记[住下忆]?|保[存留]的)?\s*$string$/`

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

## History

## TODO

