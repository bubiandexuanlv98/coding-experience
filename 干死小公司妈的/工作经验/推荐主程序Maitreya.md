





## 召回

召回分为两步骤：

1. 调用召回，写入context.recall_result
2. 蛇形打散

### 调用召回

1. 先过AB参数这一关，rulai取回来的ab参数会在这maitreya这一步起效，AB参数带有这个召回的会被相应的添加或者过滤
2. 然后把经过AB过滤后剩余的召回，依次用多线程调用，这里要有timeout（看一下go里面怎么处理这个的）
3. 注意所有的召回都在这里调用，包括走精排的，走强插的，做补全的。每一个召回都有自己的一个类，点进去看会发现前面三个结果分别在各自类中的方法是分别写入`ret`，`context.insert_recalls_dict`,`context.complete_recalls`的

### 蛇形打散（取召回结果）

1. 按照所有召回取一遍为一轮，通过merge_weights确定一轮召回中，每路召回取多少个视频。这个merge_weights可以通过AB参数传一些进来，但是传进来的merge_weights是绑定某一路正在做AB的召回的。剩下的merge_weights主要定义在启动的`conf.py`中
2. 蛇形打散的过程中如果发现不同的召回取出了相同的视频，要去重，但是这个视频的属性中的`strategy`要加上它是由哪几路召回弄出来的



## 打散diverse

这是Maitreya技术含量最高的部分了

+ 打散是在一切排序之后的，所以前面已经精排重排打压过了，到这一步的video_list中视频得分是从高到低的

+ 每个video都会打上相应的标签，但是注意我们公司这里是先把所有打散规则的标签都打上，然后在程序里面通过enable_rules（一部分直接设定，一部分ab传入）然后在后面打散的时候过滤掉不启用的

+ 打散的具体过程中，为了在一个系统中实现三种目标：

  **1. 定位出现（比如作者自己的视频插在它每一刷的第2位）**

  **2. 保量打散，保证4个或者8个里面至少出现1个。**

  **3. 最多出现，保证8个或者4个里面至多出现一个。**

  我们的系统上实现上有两个trick，一个注意点

+ trick1：是每一次插入视频的之前，都要判断这个位置是否可以插入，这个又分三种

  1. 一种是判断这个位置是否需要保量（上面第2点），如果需要则这个位置用来插入保量视频

  ```python
  window_min_insert_index = get_label_insert_index(filter_set)
  if window_min_insert_index is not None:
  	ret.append(context.videos[window_min_insert_index])
  	filter_set.add(ret[-1].content_id)
  ```

  2. 第二种是判断这个位置如果插入当前index对应的视频的话，是否会违反3

     ```python
     if is_insertable(can_video_index): # 其实这个会出现在1前面
       ...
     
     ...
     def is_insertable(index):
       labels = context.video_labels[index]
       crt_index = len(ret)
     
       for la in labels:
         # 只处理明确生效的rule
         if la not in context.enabled_rules:
           continue
           # 窗口最少出几条规则不参与判断是否能插入
           is_window_min = self.label_rule.is_window_min(la)
           if is_window_min:
             continue
             gap = self.label_rule.get_label_gap(la)
             if not gap:
               return True
             # 处理插入的窗口
             count_min, window = gap
             # 这里本来有一段用来保证1的代码被删掉了
             index_max = crt_index
             index_min = max(0, index_max - window + 1)
             # 要算上当前位置插入即是此label，所以等于也不行
             if count(la, index_min, index_max) >= count_min:
               return False
             return True
     ```

  3. 第三个是保证如果在当前位置后的某一个位置要满足1，此处插入的当前index对应的视频不能违反2，3

     ```python
     1. DisplayController.control中
     # 位置强插提取
     pos_insert_map = {}
     # 记录某个位置的插入影响的各种打散区域
     pos_insert_affect_gap = {}
     # 记录某个位置的插入影响前面最远的位置
     pos_max_affect = {}
     # 记录某个窗口处最少条数规则的ID
     window_min_rule_video_ids = {}
     for index, labels in enumerate(context.video_labels):
       pos = None
       las = []
       min_gap_pos = None
       for la in labels:
         is_window_min = self.label_rule.is_window_min(la)
         if la not in context.enabled_rules:
           continue
           # 窗口最少出条数规则不参与强插影响判断处理
           if is_window_min:
             window_min_rule_video_ids.setdefault(la, [])
             window_min_rule_video_ids[la].append((context.videos[index].content_id, index))
             continue
             _pos = self.label_rule.get_label_pos(la)
             # 注意上面那个函数是0就返回None
             if _pos is not None:
               pos = min(pos, _pos) if pos is not None else _pos
               gap = self.label_rule.get_label_gap(la)
               if gap is not None:
                 las.append(la)
                 if min_gap_pos is None:
                   min_gap_pos = max(0, index - gap[1])
                   else:
                     min_gap_pos = min(min_gap_pos, max(0, index - gap[1]))
                     if pos is not None and pos not in pos_insert_map:
                       pos_insert_map[pos] = index
                       if las:
                         pos_insert_affect_gap[pos] = las
                         pos_max_affect[pos] = min_gap_pos
                         pos_insert_items = sorted(pos_insert_map.items(), key=lambda e:e[0])
                         
     2. is_insertable中
     # 相当于下面这一步要提前判断一下，未来要在某个位置插入带特定label的视频，此位置处是否要做一些操作
     for pos, las in pos_insert_affect_gap.iteritems():
       if pos <= crt_index:
         continue
         for _la in las:
           if _la != la:
             continue
             index_max = pos
             index_min = max(0, index_max - window + 1)
             # 加上未来插入的会超出规则限制
             # 要算上当前位置插入即是此label，所以等于也不行
             # 注意这里，理论上count是不能count到index_max的，因为前面pos<=crt_index，我觉得应该是count_min - 1，这个必须要
             if count(la, index_min, index_max) >= count_min:
               return False
     ```

     

+ trick2：第二点是使用缓冲区candidates，如果在上面的判断中，is_insertable判断出当前index对应的视频不可插入，那么要把这个视频加入缓冲区（注意加入的是index），等待下一轮的插入。这个candidates可以大大节省时间，因为它可以在这段代码中：

  ```python
  while True:
    is_candidate_added = False
    is_insert_added = False
    for can_video_index in candidates:
      if context.videos[can_video_index].content_id not in filter_set:
        if is_insertable(can_video_index):
          # 每进行一次插入前都要判断是否插入窗口至少几条规则数据
          window_min_insert_index = get_label_insert_index(filter_set)
          if window_min_insert_index is not None:
            ret.append(context.videos[window_min_insert_index])
            filter_set.add(ret[-1].content_id)
            is_insert_added = True
            break
  
            ret.append(context.videos[can_video_index])
            filter_set.add(context.videos[can_video_index].content_id)
            is_candidate_added = True
            break
            # 没有任何添加行为，退出循环
            if not (is_candidate_added or is_insert_added):
              break
  ```

  那个for循环那里，如果没有candidates，那个for循环就得从总的video_list中找，这样的话就导致这个复杂度达到O(n*n)。而实际上如果已经加了很多视频以后，前面大部分视频可能都已经加过了（在filter set里面），如果再从总的video_list里面找是浪费时间

+ 注意点1：在每一轮中（即代码中最外层的for循环），有可能不加入视频只加入candidates，等待下一轮再加入。也有可能是加了好几个保量视频，又加了一些按照分数排下来的视频（前提是这些视频都加入了candidates）

+ 注意点2：每一轮中除了保量视频，其他待插入的视频都是来源于当前index之前的视频（因为candidates）。保量视频在之前单独开辟了一个window_min_rule_video_ids的dict，整体保存了一下每一个保量规则对应的所有视频id

  ```python
  1. DisplayController.control中
  for index, labels in enumerate(context.video_labels):
  ...
  	is_window_min = self.label_rule.is_window_min(la)
    if is_window_min:
      window_min_rule_video_ids.setdefault(la, [])
      window_min_rule_video_ids[la].append((context.videos[index].content_id, index))
  ```

## 强插



