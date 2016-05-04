# React-Native 分包实践

---

对于很多在使用react-native开发应用的小伙伴们肯定都会遇到一个问题，功能越来越复杂，生成的jsbundle文件越来越大，无论是打包在app内发布还是走http请求更新bunlde文件都是噩梦，这个时候我们应该如何来更新呢？来看看我们的方案。




```seq
Bundler-->Reslover:getDependencies
Reslover-->DependencyResolver:
DependencyResolver-->Reslover:
Reslover-->Bundler:return system + Polyfill + dependencies
Bundler-->JSTransformer:loadFileAndTransform
JSTransformer-->Bundler:返回babel转换后的代码
note over Bundler:finalize
```

finalize会根据参数runMainModule在生成的代码插入执行代码，然后我们就能获得生成的bundle文件了

--
通过上面的过程了解后，我们可以在原有的基础上进行扩展，在获取到denpendencies后(onResolutionResponse)通过请求参数，选择过滤基础模块或者仅基础模块，这时就能生成我们需要的文件。

```javascript
//react-native/packager/react-packager/src/Bundler/index.js onResolutionResponse
if (withoutSource) {
    response.dependencies = response.dependencies.filter(module = >
    !~module.path.indexOf('react-native')
)
    ;
} else if (sourceOnly) {
    response.dependencies = response.dependencies.filter(module = >
    ~module.path.indexOf('react-native')
)
```

同时修改RCTbridge暴露enqueueApplicationScript接口来将加载后的source运行到javascript core

