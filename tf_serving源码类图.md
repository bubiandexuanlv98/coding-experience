`tensorflow_serving\model_servers\extend\feature_util.h`  




由profile_mp.thrift生成的，是把这个IDL文件中定义的一些类型实例化了
`tensorflow_serving/model_servers/extend/idl/profile_mp_types.h`
**注意：这个文件只关注每个类的成员变量，因为其余方法都是脚手架。**  
class UserProfileGetReq  
```
std::vector<std::string>  uid_list;
```  
这个是请求的内容，uid_list内部是uid（就是之前那些数字字幕组合）的集合
  
class UserProfileGetRsp
```
std::vector<User>  user_list;
std::string status;
```  
这是response的内容，user_list是每个uid对应的index

class User 
```
std::string uid;
int32_t u_age;
int32_t u_gender;
int32_t u_area;
std::vector<KV>  u_keyword;
std::vector<KV>  u_follow;
std::vector<KV>  u_video_topic;
std::vector<KV>  u_cluster;
std::vector<KV>  u_category;
std::vector<KV>  u_search_keyword;
int32_t u_reg;
std::vector<KV>  u_installed_apps;
std::vector<KV>  u_dislike_authors;
std::vector<KV>  u_dislike_keywords;
std::vector<KV>  u_apps_category;
int32_t u_model_price;
std::vector<KV>  u_dislike_category;
int32_t u_redpacket;
std::vector<KV>  u_l_keyword;
std::vector<KV>  u_l_video_topic;
std::vector<KV>  u_l_category;
std::map<int32_t, int32_t>  u_redpacket_map;
std::string u_device_platform;
std::string u_device_brand;
std::vector<KV>  u_active_time;
int32_t u_area_id;
int32_t u_app_id;
std::vector<KV>  u_first_catg;
std::vector<KV>  u_dislike_video_topic;
std::vector<KV>  u_tag;
std::vector<KV>  u_l_tag;
std::vector<KV>  u_topic_tag;
std::vector<KV>  u_long_topic_tag;
```  
这个类里面的这些值就是一个请求uid返回的值，注意那个`string uid`不再是请求里面那个串了，而是一串数字


`tensorflow_serving\model_servers\extend\thrift_client.h`  
**注意：这个文件是由是我们自己定义的，不是自动生成的**
ThriftClientPool  
```
class ThriftClientPool {
public:
    ThriftClientPool(const std::string& endpoints,
        uint32_t connTimeOut=300,
        uint32_t recvTimeOut=300,
        uint32_t sendTimeOut=300,
        bool frame = true);
    template<class client_type>
    apache::thrift::stdcxx::shared_ptr<ThriftClient<client_type> > new_client();
private:
    std::vector<EndPoint> endpoints;
    uint32_t connTimeOut;
    uint32_t recvTimeOut;
    uint32_t sendTimeOut;
    bool bframe;
};
```  

ThriftClient
```
template<class client_type>
class ThriftClient {
public:
    ThriftClient(const EndPoint& endPoint, 
        uint32_t connTimeOut=500,
        uint32_t recvTimeOut=500,
        uint32_t sendTimeOut=500,
        bool frame = true
        );
    ~ThriftClient();
    client_type* instance() {  
        return m_client;
    }
    void update_error_code(int code) {
        error_code = code;
    }
    int get_error_code() {
        return error_code;
    }
    EndPoint* get_endPoint() {
        return &m_endPoint;
    }
    bool is_open() {
        return m_transport->isOpen();
    }
private:
    apache::thrift::stdcxx::shared_ptr<TTransport> m_transport;
    client_type * m_client;
    int error_code;
    EndPoint m_endPoint;
};
```  
注意一下那个模板，使用的时候事实上是传一个由thrift编译好的idl文件中的client类进去，所以虽然这是自定义的。但是使用的时候还是会和自动生成一块用。因此这几个类都相当于是把自动生成的client类封装了一下，加了几个对延迟，终端等信息的判断。这个事实上就是真正意义上的客户端，比之前用来测试thrift服务的瞎几把写的client简单  

`tensorflow_serving\model_servers\extend\afm_feature_constructor.h`  
```
class AFMFeatureConstructor {
public:
    AFMFeatureConstructor(const std::string& c_endpoints,
        const std::string& u_endpoints,
        const std::string& p_endpoints);
    ~AFMFeatureConstructor();
public:
    void prepare(const std::string& uid);
    bool construct(const PredictRequestExtend* requestExt, PredictRequest *request, std::vector<int64_t>& predict_cids, const std::set<int64_t> &impr);
    bool mp_construct(const PredictRequestExtend* requestExt, PredictRequest *request, std::vector<int64_t>& predict_cids, const std::set<int64_t> &impr);
private:
    bool cal_contentid_feature(int64_t cid, int64_t &fm);
    bool _construct(PredictRequest *request, 
        int32_t ct,
        int32_t chnid,
        const User& user,
        const std::vector<Content>& predicts,
        std::vector<int64_t>& predict_cids);
private:
    FeatureUtil *util;
    zion::FeatureExtractor* extractor_;
    zion::JsonFeatureExtractor author_jfe;
    zion::JsonFeatureExtractor video_jfe;
    zion::JsonFeatureExtractor user_jfe;
    zion::JsonFeatureExtractor context_jfe;
};
```





`model_servers/model_service_impl.h`
ModelServiceImpl

`model_servers/prediction_afm_impl.h`

这个类里面最重要的函数是`Predict`
```
::grpc::Status Predict(::grpc::ServerContext* context,
                         const PredictRequest* request,
                         PredictResponse* response) override;
```
这个函数实现中