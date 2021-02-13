# 常用软件包
## keras 上面的NLP处理工具  
### 包路径  
```
tensorflow.keras.preprocessing.text
```
<https://www.tensorflow.org/api_docs/python/tf/keras/preprocessing/text/Tokenizer>
### 基本流程
1. 使用`tensorflow.keras.preprocessing.text.Tokenizer`
    ```
    from tensorflow.keras.preprocessing.text import Tokenizer
    token = Tokenizer(num_words=MAX_WORD_NUM) # 这一步会把标点过滤掉
    token.fit_on_texts(text_list)
    # 上面这句话以后就可以使用如下方法查看token的情况
    # token.get_config() # 这个里面是一个实例属性的汇总，里面每一个属性都可以直接通过属性名访问
    token.texts_to_sequences(text_list)
    ```
    这样搞完以后会把`text_list`变成一个`sequence_list`，**注意如果设置了`MAX_WORD_NUM`，则可能出现`sequence`不等长的情况，因为这种情况只记录每一个`text`中在`MAX_WORD_NUM`以内的单词的情况。**
2. 使用`tensorflow.keras.preprocessing.text.text_to_word_sequence`  
   这个工具会把一个text变成一个单词list（没有标点）
#### 注意事项
1. keras上面的这些工具都会把标点符号过滤掉。**但是单引号不会滤除**
   

## NLTK 上面的NLP处理工具
### 常用方法
1. 使用`nltk.token.word_tokenize`  
   注意这个函数会把句子切开，切成一个包含所有标点（包括单引号）和单词的list。



  
Encoder-Decoder结构，尤其是里面decoder的两个输出是否相等。attention机制在里面的作用