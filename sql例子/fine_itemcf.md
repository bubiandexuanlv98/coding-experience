drop table tmp.yg_fine_recall_count;
CREATE EXTERNAL TABLE `tmp.yg_fine_recall_count`(
  `cid` string COMMENT '视频id',
  `train_count` string COMMENT 'cid在精排模型中训练次数')
ROW FORMAT SERDE
  'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'field.delim'=',',
  'serialization.format'=',')
STORED AS INPUTFORMAT
  'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 'hdfs:///user/pipline/youguo/tony/spark_data/recall_data/counting_fine_samples/accumulating_counting_samples/hive_readable/';



## 恒哥写的
with play_show_num as
    (select
        dt,
        udid,
        eventid,
        coalesce(videoid, mediaid) as media_id,
        parameters['impressionId'] as impression_id,
        source,
        channelid,
        parameters['playDuration'] as play_duration,
        time
    from matrix_log.dwd_yixia_sdk
    where dt between '20210306' and '20210306'
        and event in ('play','event_clientshow')
        and eventid in ('play','event_clientshow')
        and length(coalesce(videoid, mediaid)) > 0
        and source in ('0','1')
        and pname='com.yixia.youguo'
    ),
recommend_data as 
    (
     select
        dt,
        udid,
        impressionid,
        videoid,
        queue
     from
        matrix_log.dws_mpjs_log_recommend_user_video_detail
     where
      dt between '20210306' and '20210306'
      and pname='com.yixia.youguo'
      and length(nvl(impressionid, '')) > 0
      and length(nvl(videoid, '')) > 0
      and length(nvl(queue, '')) > 0
     group by
        dt,
        udid,
        impressionid,
        videoid,
        queue
  ),
vid_title as (
    select 
        media_id,
        if(length(operator_edit_title) > 0, operator_edit_title, title) as title
    from matrix_dim.dim_lizi_media_info
    where dt='20210307' --取最近时间，也就是昨天
    and is_youguo=1
    group by 
        media_id,
        if(length(operator_edit_title) > 0, operator_edit_title, title)
) 
select
  t1.dt,
  t1.udid,
  eventid,
  t1.time,
  t1.media_id,
  t3.title,
  impression_id,
  source,
  channelid,
  play_duration,
  queue
from 
  play_show_num t1
join
  recommend_data t2
on t1.impression_id=t2.impressionid and t1.media_id=t2.videoid and t1.udid=t2.udid and t1.dt=t2.dt
left join
    vid_title t3
on t1.media_id=t3.media_id
group by 
  t1.dt,
  t1.udid,
  eventid,
  t1.time,
  t3.title,
  t1.media_id,
  impression_id,
  source,
  channelid,
  play_duration,
  queue
order by t1.dt,t1.udid,t1.time
limit 100