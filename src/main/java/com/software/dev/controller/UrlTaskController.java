package com.software.dev.controller;

import com.alibaba.fastjson.JSON;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.software.dev.domain.Result;
import com.software.dev.domain.UrlRequest;
import com.software.dev.job.UrlJob;
import com.software.dev.mapper.UrlRequestMapper;
import lombok.extern.slf4j.Slf4j;
import org.quartz.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Task Controller
 * 新封装URL任务控制器
 * @author zhengkai@blog.csdn.net/moshowgame
 * @date 2019/03/10
 */
@RestController
@Slf4j
@RequestMapping("/urlTask")
public class UrlTaskController {

    @Autowired
    private Scheduler scheduler;
    @Autowired
    private UrlRequestMapper urlRequestMapper;

    @PostMapping("/list")
    public Result list(String requestId,@RequestParam(defaultValue = "1") Integer pageNo,@RequestParam(defaultValue = "5") Integer pageSize){
        log.info("任务列表");
        log.info("pageNo:"+pageNo);
        log.info("pageSize:"+pageSize);
        Object data= urlRequestMapper.listUrl((pageNo-1)*pageSize,pageSize);
        Integer total=urlRequestMapper.selectCount(new QueryWrapper<UrlRequest>());
        return Result.page(data,pageNo,pageSize,total);
    }
    @PostMapping("/trigger")
    public  Result trigger(String requestId) {
        log.info("触发任务:"+requestId);
        try {
            JobKey key = new JobKey(requestId,UrlJob.DEFAULT_GROUP);
            scheduler.triggerJob(key);
        } catch (SchedulerException e) {
            e.printStackTrace();
            return Result.error();
        }
        return Result.ok();
    }
    @PostMapping("/pause")
    public  Result pause(String requestId) {
        log.info("停止任务:"+requestId);
        try {
            JobKey key = new JobKey(requestId,UrlJob.DEFAULT_GROUP);
            scheduler.pauseJob(key);
        } catch (SchedulerException e) {
            e.printStackTrace();
            return Result.error();
        }
        return Result.ok();
    }
    @PostMapping("/resume")
    public  Result resume(String requestId) {
        log.info("恢复任务:"+ requestId);
        try {
            JobKey key = new JobKey(requestId,UrlJob.DEFAULT_GROUP);
            scheduler.resumeJob(key);
        } catch (SchedulerException e) {
            e.printStackTrace();
            return Result.error();
        }
        return Result.ok();
    }
    @PostMapping("/remove")
    public  Result remove(String requestId) {
        log.info("移除任务:"+requestId);
        try {
            TriggerKey triggerKey = TriggerKey.triggerKey(requestId, UrlJob.DEFAULT_GROUP);
            JobKey jobKey=JobKey.jobKey(requestId, UrlJob.DEFAULT_GROUP);
            // 停止触发器
            scheduler.pauseTrigger(triggerKey);
            // 移除触发器
            scheduler.unscheduleJob(triggerKey);
            // 删除任务
            scheduler.deleteJob(jobKey);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error();
        }
        return Result.ok();
    }
    @PostMapping("/test")
    public Result test(@RequestBody Map<String,Object> map){
        log.info("RequestMap:"+ JSON.toJSONString(map));
        return Result.ok("请求成功");
    }
    @PostMapping("/start")
    public Result start(String requestId){
        log.info("新增任务");
        UrlRequest urlRequest=urlRequestMapper.selectOne(new QueryWrapper<UrlRequest>().eq("request_id",requestId));
        if(urlRequest!=null){
            try {
                log.info("确认是否有旧任务，删除重新添加");
                JobKey key = new JobKey(urlRequest.getRequestId(), UrlJob.DEFAULT_GROUP);
                if(scheduler.checkExists(key)){
                    //如果存在旧的，删除重新添加
                    scheduler.deleteJob(key);
                }
                Class cls = Class.forName(UrlJob.class.getName()) ;
                cls.newInstance();
                //构建job信息
                JobDetail job = JobBuilder.newJob(cls).withIdentity(urlRequest.getRequestId(),
                        UrlJob.DEFAULT_GROUP)
                        .withDescription(urlRequest.getRequestName()).build();

                //这里传入id作为处理
                job.getJobDataMap().put("requestId", requestId);
                log.info("开始触发新任务");
                // 触发时间点
                CronScheduleBuilder cronScheduleBuilder = CronScheduleBuilder.cronSchedule(urlRequest.getRequestCron());
                Trigger trigger = TriggerBuilder.newTrigger().withIdentity(urlRequest.getRequestId(),UrlJob.DEFAULT_GROUP)
                        .startNow().withSchedule(cronScheduleBuilder).build();
                //交由Scheduler安排触发
                scheduler.scheduleJob(job, trigger);
            } catch (Exception e) {
                e.printStackTrace();
                return Result.error();
            }
        }
        return Result.ok();
    }
    @PostMapping("/insertN")
    public  Result insertX(@RequestParam Integer n) {
        for (int i = 0; i < n; i++) {
            UrlRequest urlRequest=new UrlRequest();
            urlRequest.setRequestMethod("POST");
            urlRequestMapper.insert(urlRequest);
        }
        return Result.ok();
    }
}