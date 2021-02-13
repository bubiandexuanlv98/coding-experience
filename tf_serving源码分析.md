# tensorflow源码部分
## 油果项目部分的源码  
### 服务接口简析
我们对外提供服务的接口是：
```
::grpc::Status PredictionAFMImpl::PredictExtend(::grpc::ServerContext *context,
                                              const PredictRequestExtend *request,
                                              PredictResponseExtend *response)
```
这个在broker-maityera调用的thrift服务(python)中的写法是：`self.model_stub.PredictExtend()`  
这个接口中会对请求的内容（即`const PredictRequestExtend *request`）做如下操作，接口定义位于`tensorflow_serving\model_servers\prediction_afm_impl.cc`：  
1. 首先新建一个vector，把请求中的Impression ID拷入这个vector。
    ```
    std::set<int64_t> impr;
    for (uint32_t i = 0; i < request->impr_size(); ++i) {
    impr.insert(request->impr(i));
    }
    ```  
    这一部分会在后面起作用，是为了把请求中的cid做去重，把之前已经展现过的视频id（即Impression ID）去除，注意请求中的cid不是单独的一个视频id，是好几个视频id，后面我们会看到我们会用vector去储存它。

2. 接着会解析请求中的ab参数，这个是使用`rapidjson`这个库里面的函数，这里按下不表  
    ```
    try{
        Document abtest_parameters;
        std::string ab_str = request->abtest_parameters_str();
        LOG(INFO) << "abtest_parameter:" << ab_str;
        //std::remove(ab_str.begin(),ab_str.end(),'\\');
        //ab_str = ab_str.substr(1, ab_str.size()-2);
        //LOG(INFO) << "ylzhang12:" << ab_str;
        abtest_parameters.Parse<kParseStopWhenDoneFlag>(ab_str.c_str());
        if (abtest_parameters.HasParseError()) {
            LOG(ERROR) << "abtest_parameters parse error!!";
        } else {
            if(abtest_parameters.HasMember("ptm_weight") && abtest_parameters["ptm_weight"].IsNumber()){
                ptm_weight = abtest_parameters["ptm_weight"].GetDouble();
            }
            if(abtest_parameters.HasMember("model_type") && abtest_parameters["model_type"].IsString()){
                predict_model_type = abtest_parameters["model_type"].GetString();
            }
        }
    } catch (...) {
        LOG(INFO) << "parse abtest_param error!";
    }
    
    LOG(INFO) << "abtest predict model_type:" << predict_model_type << ", ptm_weight:" << ptm_weight;
    ```  

3. 然后我们会新建一个`PredictRequest`的对象，为了把原请求对象（即参数中的`PredictRequestExtend`的对象`requestExt`）中的部分元素做解析，解析到新建的这个对象中去，其实这里所谓的“部分元素做解析”其实就是把传过来的request中的用于预测的参数，转换为适配模型输入的样子。  
    ```
    PredictRequest _request;
    std::vector<int64_t> cids;
    if (!feature_constructor_->construct(request, &_request, cids, impr)) {
        LOG(ERROR) << "construct feature failed!!";
        return ToGRPCStatus(errors::Internal("construct feature failed!"));
    }
    ```  
    这个部分会在下一块：**如何解析request中的主要内容**中（主要内容指的是实际需要走预测模型的参数）详细叙述  

### 如何解析request中的主要内容
虽然上一块中的1，2，3点中都在解析request中的内容，但真正复杂的解析是第3点，因为这里面会对cid，uid等实际用于预测的输入做处理，这也是我们油果整个服务框架中需要做密集修改从而适配不同模型的输入的地方，为了方便说明，这里先放出入口的模样（即上一块第3点）  
```
PredictRequest _request;
std::vector<int64_t> cids;
if (!feature_constructor_->construct(request, &_request, cids, impr)) {
    LOG(ERROR) << "construct feature failed!!";
    return ToGRPCStatus(errors::Internal("construct feature failed!"));
}
```   
注意这里有一个很关键的点：cids是一个vector，这说明一个请求里面包含不只一个cid
1. `!feature_constructor_->construct(request, &_request, cids, impr)`
    ```
    bool AFMFeatureConstructor::construct(const PredictRequestExtend* requestExt, 
            PredictRequest *request, 
            std::vector<int64_t>& cids,
            const std::set<int64_t> &impr) {
        if (util == NULL) return false;
        std::string fudid = requestExt->fudid();
        uint32_t cid_num = requestExt->cids_size();
        for (uint32_t i = 0; i < cid_num; ++i) {
            if (impr.find(requestExt->cids(i)) != impr.end()) continue;
            //if (content_feature_idx.find(requestExt->cids(i)) == content_feature_idx.end()) continue;
            cids.push_back(requestExt->cids(i));
        }
        User user;
        std::vector<Content> predicts;
        int64_t t2 = CurrentTimeInMs();
        util->get_user(fudid, user);
        int64_t t3 = CurrentTimeInMs();
        return _construct(request, requestExt->ct(), requestExt->chnid(), user, predicts, cids);
    }
    ```   
    这个函数便是入口处那个`feature_constructor_->construct(request, &_request, cids, impr)`对应的函数  
    + 这里首先把request中的fudid拷贝了出来，这个fudid可参考`recommend-tf21cpp-project\app\tony_bench\serving_transmodule`中的`trans_sv.py`中fudid的定义，它实际上是`recommend-tf21cpp-project\app\tony_bench\serving_transmodule`中的`client.py`中的uid，是一串string。  
    + 然后用impression ID容器里面的值对cid的容器做了一个过滤，把过去展现过的视频删除。  
  
2. `util->get_user(fudid, user)`  
    这是最恶心的一步，调用用户画像服务，它事实上是基于thrift调用高超那边管理的用户画像，我们先看一下这个函数的上下文：
    ```
    User user;
    std::vector<Content> predicts;
    int64_t t2 = CurrentTimeInMs();
    util->get_user(fudid, user);
    int64_t t3 = CurrentTimeInMs();
    ```  
    1. 首先这里看一下User这个类里面有什么，这个见源码类图，这个事实上是在`profile_mp.thrift`中定义的结构体，它是每一个uid对应的用户画像集合。  
    2. 然后看一下`util->get_user(fudid, user)`。
    这个函数是调用的位于`tensorflow_serving\model_servers\extend\feature_util.cpp`中的，函数定义如下：  
    ```
    bool FeatureUtil::get_user(const std::string& uid,  User& user) {
        auto client = content_profile->new_client<ProfileClient>();
        if (client == NULL) {
            LOG(ERROR) << "no endpoints for user profile!!";
            return false;
        }
        Poco::SharedPtr<User> ptrElem = p_user_cache->get(uid);
        if (ptrElem.get() != NULL) {
            user = *ptrElem;
            return true;
        }
        UserProfileGetReq req;
        req.uid_list.push_back(uid);
        UserProfileGetRsp rsp;
        std::map<std::string, std::string> c = {{"name","dien_predict"}};
        THRIFT_CLIENT_DELEGATIION(client, get_user_profiles_ex, rsp, req, c);
        if (client->get_error_code() != THRIFT_RPC_SUCCESS) {
            LOG(ERROR) << "getting user profile failed:";
            return false;
        }
        if (rsp.user_list.size() == 0) return false;
        user = rsp.user_list[0];
        p_user_cache->add(uid, user);
        return true;
        }
    ```      
    + 这个会首先调用`FeatureUtil`中的私有变量——`ThriftClientPool *content_profile;`去创建一个新的thrift客户端，注意这里的`ThriftClientPool`是一个我们自己定义的类，不是自动生成的？，位于`tensorflow_serving\model_servers\extend\thrift_client.cpp`中，可以简单看一下它的定义（在源码类图里面），只要注意一下那个`ProfileClient`是由位于`app\relate\idl\profile_mp.thrift`的接口文件生成的位于`tensorflow_serving\model_servers\extend\idl\Profile.h`中的类。但是`new_client`那个函数是我们自己定义的。  
    + 然后那个`Poco::SharedPtr<User> ptrElem = p_user_cache->get(uid)`是调用了一个很牛逼的库：`Poco`。在`FeatureUtil`中有用到这个库中的`Poco::ExpireLRUCache<std::string, User>`这个事实上是一个高速缓存的保存方式，它默认保留这个键值对10分钟，占用的高速缓存空间为1024。因此这里这句话事实上就是为了防止多次请求相同的uid对应的index
    + 然后是`UserProfileGetReq`和`UserProfileGetRsp`这两个类，这两个类在类图中都有介绍，注意Req里面传的值事实上是一个uid的vector，返回的Rsp是一个对应的User类型的vector，因为一个uid可能对应有多个值，这些值都是User这个类中的。但这里注意我们一次只传一个uid  
    + 然后是thrift rpc的过程，注意这里我们用了一个很有趣的写法：`THRIFT_CLIENT_DELEGATIION(client, get_user_profiles_ex, rsp, req, c)`，这个`THRIFT_CLIENT_DELEGATIION`事实上是一个宏定义，它在`tensorflow_serving\model_servers\extend\thrift_client.h`中定义，是一种调试手段，让所有thrift rpc报错都加上特殊的前缀，这样省去在Thrift Client内部多次修改（注意这里有一个恶心的地方，就是虽然我们要写入rsp，但在宏定义里面我们似乎并没有传地址）。有必要说鸡明一下`thrift_client.h`和`thrift_client.cpp`是一个我们写的服务端，它用模板的方式封装了自动生成的客户端（用模板方便我们封装自动生成的不同的客户端），然后添加了一些必要的信息，和之前接触的那些用于测试的python的thrift客户端不一样，这个比较复杂。
    + 最后是把请求结果rsp的内容写到高速缓存中去（注意`Poco`那个库） 
    + 返回bool值到第1点的函数中去   

3. `return _construct(request, requestExt->ct(), requestExt->chnid(), user, predicts, cids);`  
   现在回到第1点的函数中，放一下上下文：  
   ```
    User user;
    std::vector<Content> predicts;
    int64_t t2 = CurrentTimeInMs();
    util->get_user(fudid, user);
    int64_t t3 = CurrentTimeInMs();
    return _construct(request, requestExt->ct(), requestExt->chnid(), user, predicts, cids);
   ```  
   现在`get_user`函数结束了，正式进入对原请求requestExt的解析，即`_construct`这个函数： 
   ```
    bool AFMFeatureConstructor::_construct(PredictRequest *request, 
                                  int32_t ct_,
                                  int32_t chnid_,
                                  const User& user,
                                  const std::vector<Content>& predicts,
                                  std::vector<int64_t> &cids)
   ```
   
   1. 首先是一些初始化  
    ```
        if (cids.size() < 1) return false;
        uint32_t cids_size = cids.size();
        std::vector<int64_t> Xindex;
        zion::Instance instance_(*extractor_);
        std::unordered_map<string, boost::any> user_features, context_features;
        auto inputs = request->mutable_inputs();
        std::vector<uint64_t> h_feature;
    ```  
    + Xindex这个东西
    + 注意`zion::Instance`这个东西，在`app\feature_extract\zion\include\instance.h`里面，而实现在`app\feature_extract\zion\src\instance.cpp`里面，这是一个类，它的构造函数接收的参数是`zion::FeatureExtractor`，而上面这段代码里面就是用`class AFMFeatureConstructor`这个类里面的私有变量`extractor_`初始化的一个`_instance`对象。这里有个问题，就是到底哪里初始化了`extractor_`这个私有变量。这个问题其实很操蛋，因为它是在`tensorflow_serving\model_servers\prediction_afm_impl.h`中的`class PredictionAFMImpl`的构造函数中初始化的，而`PredictionAFMImpl`这个类的初始化在`server.cc`中的395行
        ```
        prediction_afm_ = absl::make_unique<PredictionAFMImpl>(predict_server_options);
        ```
        这个`prediction_afm_`是server类的私有变量，它是一个`PredictionAFMImpl`类的指针  
        因此它的链条事实上是：初始化`class PredictionAFMImpl`的同时也初始化了一个`class AFMFeatureConstructor`。  
    + 看那个`user_features`，`context_features`，这两个无序map容器事实上是为了存储`key=feat_name`，`value=转化为对应类型的画像值`这个在后面会有更详细的讲解。  
    + inputs这个东西其实非常非常重要，这个事实上就是我们之前写模型时导出的[signatureDef中的value值中的inputs](https://www.tensorflow.org/tfx/serving/signature_defs)，它定义在`tensorflow_serving\apis\predict.proto`中，这个算是tensorflow内部定义的一种格式，是给input tensor专门定义的

   2. 然后是一段非常操蛋的程序，这一块对于现在我们的模型而言有很多不必要的步骤，换句话说这里有极大的冗余，非常非常非常操蛋。  
    ```
    try {
        std::string user_info = std::move(construct_user(user));
        std::string context_info = std::move(construct_context(chnid_));
        //LOG(INFO) << user_info;
        //LOG(INFO) << context_info;
        user_jfe.parse_features_new(user_info, user_features, "user_feature");
        context_jfe.parse_features_new(context_info, context_features, "context_feature");
        for(auto& f : user_features) instance_.add_feature_value(f.first, f.second);
        for(auto& f : context_features) instance_.add_feature_value(f.first, f.second);
        extractor_->extract(&instance_);
        instance_.get_hash_features(h_feature);
    } catch (...) {
        LOG(ERROR) << "construct user or context failed";
        return false;
    }
    ```  
    + 首先是那个`construct_user(user)`这个函数的实现在`tensorflow_serving\model_servers\extend\math_func.cpp`里面，这个函数事实上就是把用户画像传回来的那些值拼接成json字符串。然后那个`construct_context(chnid_)`同理。
    + 然后是那个`user_jfe.parse_features_new(user_info, user_features, "user_feature")`这个函数是把json字符串解析回来，这个操作就很骚，妈的直接解析不好吗，为啥非要转个json。但是注意它在这个解析中去掉了很多没用的画像值。然后这个json解析本身还很操蛋，我们可以看一下`user_jfe`这个私有变量，这个对象的类实现位于`app\feature_extract\zion\include\json_feature_extractor.h`中。这里注意一下这个私有变量在哪初始化的，和第一点中那个操蛋的问题一样，他的链条是：初始化`class PredictionAFMImpl`的同时也初始化了一个`class AFMFeatureConstructor`，而在`class AFMFeatureConstructor`的初始化中，初始化了`class JsonFeatureExtractor`，可以看一下位于`tensorflow_serving\model_servers\extend\afm_feature_constructor.cpp`中的`AFMFeatureConstructor`这个类的构造函数中的代码：
        ```
        author_jfe.set(MIAOPAI_AUTHOR_FORMATS);
        video_jfe.set(MIAOPAI_CONTENT_FORMATS);
        user_jfe.set(MIAOPAI_USE_FORMATS);
        context_jfe.set(MIAOPAI_CONTEXT_FORMATS);
        ```  
        看那个`MIAOPAI_USE_FORMATS`，这个事实上是定义在`app\feature_extract\zion\include\feature_format.h`中的，而它的实现在`app\feature_extract\zion\extension\feature_format.cpp`中，这个傻逼文件规定了解析的json串中的各个value部分应该怎样被处理（以哪一种类型被存储）  
        这里它的这个初始化其实挺讲究，它把`MIAOPAI_USE_FORMATS`中的每一行元素，初始化成了定义在`app\feature_extract\zion\include\json_feature_extractor.h`中的`feature_format_t`这个结构体中的元素：  
            ```
            struct feature_format_t{
            std::string key;
            std::string fea_name;
            int32_t type;
            };
            ```
        因此后面我们会看到在它的解析过程中会用这个结构体里面的变量名去索引，比如用`fea_name`。
        解析完的内容存放在前面定义的user_features中，这也是为什么这个map的value类型是`boost::any`，这个语法只在c++17中被支持，它是一种可以存放任何类型的，但只能容纳一个元素的容器。  
        这个解析结束以后，`user_info`里面的值被解析到`user_features`中去了，存储格式为`fea_name:画像值（转换为对应的c++类型的）`  
        + 下面这部分代码就是一个非常非常非常冗余，虽然以前很奈斯，但是现在无比傻逼的一个步骤——转hash值，然后再他妈转回来，这个属于历史遗留问题。  
        ```
        for(auto& f : user_features) instance_.add_feature_value(f.first, f.second);
        for(auto& f : context_features) instance_.add_feature_value(f.first, f.second);
        extractor_->extract(&instance_);
        instance_.get_hash_features(h_feature);
        ```  
        这一块的内容其实非常非常有讲头，里面用到了无数的骚操作，以后有空要看一下。反正最后就是解析出了h_feature这个vector，这个vector中存放的是一系列哈希值，是所有可能会用到的用户画像对应的hash值。   

   3. 接着就到了针对上一步转换后的hash值做index的步骤了，这里做的index就是最终送到模型input的值，用他们去索引那个特别大embeddings。
    ```  
    std::map<uint32_t, std::vector<int64_t> > fm_index;
    for (uint32_t i=0;i<h_feature.size();i++) {
        uint64_t f = h_feature[i];
        uint32_t slot_id = 0;
        uint64_t index = 0;
        auto it = idmapping.find(f);
        if (it != idmapping.end()) {
            slot_id = it->second.slot;
            index = it->second.feature;
        } else {
            slot_id = get_slot_id(f);
        }
        if (afm_need_slot_list.find(slot_id) == afm_need_slot_list.end()) continue;
        auto &fmr = fm_index[slot_id]; 
        fmr.push_back(index);
    }
    //LOG(INFO) << a;
    for (auto slot_id : afm_single_slot_list) {
        auto itr = fm_index.find(slot_id);
        if (itr == fm_index.end()) {
            fm_index[slot_id] = {0};
        }
    }
    for (auto slot_id : afm_more5_slot_list) {
        auto itr = fm_index.find(slot_id);
        if (itr == fm_index.end()) {
            fm_index[slot_id] = {0,0,0,0,0};
        } else if (itr->second.size() != 5) {
                itr->second.resize(5);
        }
    }
    for (auto slot_id : afm_more3_slot_list) {
        auto itr = fm_index.find(slot_id);
        if (itr == fm_index.end()) {
            fm_index[slot_id] = {0,0,0};
        } else if (itr->second.size() != 3) {
                itr->second.resize(3);
        }
    }    
    ```
    + fm_index 这个map的存的东西就是`slot_id：index值的vector`，注意这个fm_index中的内容是一条数据的slot值和index值，即和一个用户&一个channel&多个cid有关的所有`slot_id:index`。
    + idmapping这是从一个类似于`app\tony_bench\serving_server\index.txt`的文件中读取进来的索引unordered_map，`tensorflow_serving\model_servers\extend\idmapping.cpp`中有讲这个是怎么load进来的，注意，项目里面的那个`index.txt`不全，得去线上的机器看。
    + 第一个for循环就是把每个slot_id对应的index值一一加入到fm_index中的各个vector中去
    + 后面几个循环是把只应该有三个值和只应该有五个值的slot_id挑出来做一些处理，注意这里不是说这个slot_id只能对应三个值或者五个值，而是只对一条数据而言。  
  4. 快结束了，要撑住啊小伙子，下面这段程序就是拼input tensor的过程了。   
   ```
   std::unordered_map<int64_t, std::vector<int64_t>>::iterator iter;
    std::vector<int64_t> cid_fill = {0,0,0,0,0,0,0,0,0,0,0};
    for (uint32_t i = 0; i < cids_size; ++i) {
        int64_t tmp_cid = cids[i];
        //iter = content_feature_idx.find(tmp_cid);
        //if (iter==content_feature_idx.end()){ 
        //    continue;
        //}
        int64_t cid_feature;
        if (!cal_contentid_feature(tmp_cid, cid_feature)){
            continue;
        }
        Xindex.push_back(fm_index[1][0]);
        Xindex.insert(Xindex.end(), fm_index[111].begin(), fm_index[111].end());
        Xindex.insert(Xindex.end(), fm_index[112].begin(), fm_index[112].end());
        Xindex.push_back(cid_feature);
        Xindex.insert(Xindex.end(), cid_fill.begin(), cid_fill.end());
        Xindex.push_back(fm_index[3][0]);
    }
    std::cout << "cid_size:" << cids_size << std::endl;
   ```  
   这里是一个一个cid处理的，中间那个函数`cal_contentid_feature(tmp_cid, cid_feature)`其实和前面对uid的处理过程一模一样。最后事实上一个`Xindex`是一个`input_tensor`的内容，它包含的是一个batch。这里的每一次循环，都会往这个batch里面添加一条。这里注意一下，我们可以看一看我们之前在写模型时是怎么处理`input_tensor`的：
   ```
    self.ind_phh = tf.placeholder(tf.int64, [None, None])
    self.ind_ph = tf.concat(
    [tf.expand_dims(self.ind_phh[:, 0], axis=-1), tf.expand_dims(self.ind_phh[:, 11], axis=-1),
        tf.expand_dims(self.ind_phh[:, 23], axis=-1)], 1)
   ```  
   有没有发现一些很有趣的现象，我们事实上最后用的是`input_tensor`中的一部分，也就是`uid`,`cid`,`channel_id`，其实这就和我们正在干的事情对上了，如果你耐心的数一下就会发现，我们做的`Xindex`就是uid在batch中每一条的第0位，cid在batch中每一条的第11位，channel_id就是batch中每一条的第23位。  
   5. 然后就到了正式构建input tensor的过程了  
   ```
    std::vector<float> label_train_list(3 * cids.size());
    bool train_phase = false;
    (*inputs)["ind_batch_input"] = construct_tensor_proto(&(Xindex[0]), Xindex.size() * sizeof(int64_t), DT_INT64, {Xindex.size()/24, 24});
    (*inputs)["label_input"] = construct_tensor_proto(&(label_train_list[0]),label_train_list.size() * sizeof(float), DT_FLOAT, {label_train_list.size()/3, 3});
    //LOG(INFO) << "label_input:" << ToString(label_train_list);
    (*inputs)["train_phase_input"] = construct_tensor_proto(&(train_phase), sizeof(train_phase), DT_BOOL, {});
    //LOG(INFO) << "train_phase_input:" << ToString(train_phase);
   ```  
   为了看明白这个问题，需要去看几个地方：一个是`predict.proto`这个文件中的inputs，这是一个map，包含了一个位于`tensor.proto`中的`TensorProto`的message。可以跳到`tensor.proto`中看一下，然后结合下面这个`construct_tensor_proto`函数，我这里po出这个函数的代码（位于`tensorflow_serving\model_servers\extend\math_func.cpp`），有很多有意思的地方我可以说一下：
   ```
   TensorProto construct_tensor_proto(const void* bytes, size_t size, DataType type,
    const std::vector<int32_t> &shape) {
    TensorProto tensor_proto;
    tensor_proto.set_dtype(type);
    tensor_proto.set_tensor_content(bytes, size);
    auto tensor_shape = tensor_proto.mutable_tensor_shape();
    for (const auto &it : shape) {
        auto dim = tensor_shape->add_dim();dim->set_size(it);
    }
    return std::move(tensor_proto);
    }
   ```  
   首先是对于message中的信息，如果想给这个message里面的各个field赋值的话，有时候用`set_field名字`，有时候用`mutable_field名字`，这个其实很骚的，可以上网搜一下，我这里给出[`protocol buffers`的官方文档](https://developers.google.com/protocol-buffers/docs/cpptutorial)，可以简单上去看看，除此之外，对于grpc的IDL文件中用repeated标注的field，如果要添加多个元素的话用`add_名字`，这个在官方文档上也讲过。然后有个很有意思的地方就是那个`set_tensor_content`方法，这个可以看一下`tensor.proto`这个文件对`tensor_content`这个东西的介绍，它事实上是为了减少序列化开销（serialization overhead）的，可以初始化它，也可以不初始化它。注意一下它在`tensor.proto`中是`Bytes`类型的，在protobuf里面认为`Bytes`和`String`类型相似，因此编译proto文件后对这两种类型给出的set方法也很类似，[这两种类型区别见](https://blog.csdn.net/csCrazybing/article/details/78061475]。这里这个`set_tensor_content`方法可以参考c++ primer plus对string构造函数那一节的讲解。




`tensorflow_serving\model_servers\extend\math_func.cpp`  
这`std::string construct_user(const User& user)`里面有一个c_str()的转换，为啥？   

`tensorflow_serving\model_servers\extend\afm_feature_constructor.cpp`220行做的转换为啥  

`tensorflow_serving\model_servers\extend\afm_feature_constructor.cpp`224行到245行有问题


## 如何创建一个定时更新的（每日更新的）一个伴随模型的资源（哈希表，字典）  

### 首先是创建一个可以定时查看路径的模块：  
<https://www.tensorflow.org/tfx/guide/serving>
### 其次是创建一个用于载入的模块  
<https://www.tensorflow.org/tfx/serving/custom_servable>  
然后把用于定时查看路径的模块挂到用于载入的模块上：即首先传利一个

  
### 知识补充
   profile_mp.thrift生成了`Profile.cpp`，`Profile.h`，`profile_mp_types.h`，`profile_mp_types.h`，为什么会生成`Profile.cpp`这种名字：因为它里面的服务的名称是`Profile`
   
   
   但是这里面操蛋的地方在于它是一个模板

## 用core怎么去预测：

`server.cc`文件中的入口：  
446~450行
```
if (server_options.model_message == "afm_predict"){
builder.RegisterService(prediction_afm_.get());
} else {
builder.RegisterService(prediction_service_.get());
}
```

看一下`prediction_afm_`这个成员变量（定义在`server.h`），它是一个指针：
```
std::unique_ptr<PredictionAFMImpl> prediction_afm_;
```
`PredictionAFMImpl`这个类见类图，它在`model_servers/prediction_afm_impl.h`这个文件中，这个类里面最重要的函数是`Predict`，它是`prediction_afm_`这个指针执行预测的关键，它的接口定义如下：
```
::grpc::Status PredictionAFMImpl::Predict(::grpc::ServerContext *context,
                                              const PredictRequest *request,
                                              PredictResponse *response) 
```
参数说明：这几个参数都是在预测的时候传进来的，其中前两个应该是请求的内容，最后一个应该到时候会传一个地址进来，上面这个函数会把结果写的这个地址里面  

这个函数实现中最核心的是这句
```
const ::grpc::Status status = ToGRPCStatus(predictor_->Predict(run_options, core_, *request, response));
```
参数说明：最后的`*request`，`response`，这两个是用的时候传的，而`core_`是`PredictionAFMImpl`的成员变量，`run_options`这个是在`Predict`这个函数中定义的。  
看一下`predictor_`这个成员变量，它会调用`Predict`函数做预测，定义在`model_servers/prediction_afm_impl.h`中，它是一个指针：  
```
std::unique_ptr<TensorflowPredictor> predictor_;
```  
`TensorflowPredictor`这个类见类图，它在`servables/predict_impl.h`这个文件中，这个类里面最重要的函数是`Predict`，因为`predictor_`，它会调用`Predict`函数做预测，然后会发现它是个壳子，真正重要的函数是`PredictWithModelSpec`，这两个函数的接口定义如下：
```
Status TensorflowPredictor::PredictWithModelSpec(const RunOptions& run_options,
                                                 ServerCore* core,
                                                 const ModelSpec& model_spec,
                                                 const PredictRequest& request,
                                                 PredictResponse* response)

Status TensorflowPredictor::PredictWithModelSpec(const RunOptions& run_options,
                                                 ServerCore* core,
                                                 const ModelSpec& model_spec,
                                                 const PredictRequest& request,
                                                 PredictResponse* response) 
```  
参数说明：这里的所有参数都是从`PredictionAFMImpl`这个类里面传过来的，其中`model_spec`实际上是`request`里面的内容，这个你去仔细看函数会发现，只是拆开了传而已。`TensorflowPredictor`这个类并不自带成员变量。  
`Status TensorflowPredictor::PredictWithModelSpec`在这个函数里面，我们就能看到最牛逼的部分了——`SavedModelBundle`，这个是Tensorflow Serving的核心类，在tf serving 的官方文档<https://www.tensorflow.org/tfx/serving/serving_advanced?hl=en>这个里面有讲这个类会干些什么。这里我们先看一下这个函数体（`PredictWithModelSpec`函数）内部（提醒一下我们现在在`servables/predict_impl.cc`这个文件中），假设`use_saved_model_`这个flag是`True`的，看一下这个函数的内容：
```
ServableHandle<SavedModelBundle> bundle;
TF_RETURN_IF_ERROR(core->GetServableHandle(model_spec, &bundle));
return internal::RunPredict(
run_options, bundle->meta_graph_def, bundle.id().version,
core->predict_response_tensor_serialization_option(),
bundle->session.get(), request, response);
```   
我们其实可以发现这里开始调用`server_core`去预测了，先用`model_spec`初始化一下`bundle`，然后
