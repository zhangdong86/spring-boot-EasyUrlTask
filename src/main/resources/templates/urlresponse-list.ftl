<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SpringBoot EasyUrlTask</title>
    <#import "common/common-import.ftl" as common>
    <@common.commonStyle />

</head>
<body>

<el-container>

    <el-container>
        <el-header>
            <#--<el-breadcrumb separator-class="el-icon-arrow-right">
                <el-breadcrumb-item>EasyTask</el-breadcrumb-item>
                <el-breadcrumb-item>任务管理</el-breadcrumb-item>
                <el-breadcrumb-item>任务列表</el-breadcrumb-item>
            </el-breadcrumb>-->
        </el-header>
        <el-main>
            <#--内容展示-->
            <div id="app">
                <!-- 分页 -->
                <el-table
                        ref="multipleTable"
                        :data="tableData"
                        tooltip-effect="dark"
                        width=" 99.9%"
                        @selection-change="handleSelectionChange">
                   <#-- <el-table-column
                            type="selection"
                            width="50">
                    </el-table-column>-->
                    <el-table-column
                            prop="responseId"
                            label="" type="expand"
                            width="100">
                        <template slot-scope="props">
                            <span>{{ props.row.responseText }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column
                            prop="requestId"
                            label="任务ID"
                            width="100">
                    </el-table-column>
                    <el-table-column
                            prop="responseTime"
                            label="时间" :formatter="formatterDate"
                            width="200">
                    </el-table-column>
                    <el-table-column
                            prop="responseText"
                            label="报文"
                            :show-overflow-tooltip="true"
                            >
                        <template slot="header" slot-scope="scope">
                            <el-input
                                    v-model="search"
                                    size="mini"  @change="search_change()"
                                    placeholder="输入关键字搜索"/>
                            <i
                                    class="el-icon-search el-input__icon"
                                    slot="suffix">
                            </i>
                        </template>
                    </el-table-column>
                </el-table>
                <div style="text-align: center;margin-top: 30px;">
                    <el-pagination
                            background
                            layout="prev, pager, next"
                            :total="total" :page-size="pageSize"
                            @current-change="current_change">
                    </el-pagination>
                </div>
            </div>
        </el-main>
    </el-container>
</el-container>


</body>
<@common.commonScript />
<style>
    .el-header {
        background-color: #B3C0D1;
        color: #333;
        line-height: 60px;
    }

    .el-aside {
        color: #333;
    }
</style>

<script>
    var Main = {
        data() {
            return {
                dialogFormVisible: false,
                formLabelWidth: '120px',
                tableData: [{
                    "responseId": "1 ",
                    "requestId": "1",
                    "requestName": "localhost",
                    "responseTime": "2019-04-08",
                    "requestText": "啦啦啦啦啦啦"
                }],
                search:"",
                multipleSelection: [],
                total: 1,
                pageSize:10,
                pageNo:1
            }
        },
        created: function(){
            // 组件创建完后获取数据，
            // 此时 data 已经被 observed 了
            this.fetchData();
        },
        methods: {
            fetchData: function () {
                this.$http({
                    method: 'POST',
                    url: '${request.contextPath}/urlTask/log/list',
                    params:{pageNo:this.pageNo,pageSize:this.pageSize,search:this.search,requestId:"${requestId!!}" }
                }).then(res => {
                    console.log(res);
                    this.tableData = res.data.msg;
                    this.total= res.data.total;
                    this.pageNo=res.data.pageNo;
                    this.pageSize=res.data.pageSize;
                }).catch(function (error) {
                        console.log(error);
                    });
            },
            // 时间戳 => 标准格式
            formatDate: function(time, fmt){
                var date = time ? new Date(time) : new Date(),
                    fmt = fmt || 'yyyy-MM-dd hh:mm:ss';
                if (/(y+)/.test(fmt)) {
                    fmt = fmt.replace(RegExp.$1, (date.getFullYear() + '').substr(4 - RegExp.$1.length));
                }
                let o = {
                    'M+': date.getMonth() + 1,
                    'd+': date.getDate(),
                    'h+': date.getHours(),
                    'm+': date.getMinutes(),
                    's+': date.getSeconds()
                };
                for (let k in o) {
                    if (new RegExp(`(`+k+`)`).test(fmt)) {
                        let str = o[k] + '';
                        fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? str : ('00' + str).substr(str.length));
                    }
                }
                return fmt;
            },
            formatterDate(data) {
                /*var date = new Date(parseInt(data.responseTime) );
                Y = date.getFullYear() + '-';
                M = (date.getMonth()+1 < 10 ? '0'+(date.getMonth()+1) : date.getMonth()+1) + '-';
                D = (date.getDate()<10?'0'+date.getDate():date.getDate()) + ' ';
                h = (date.getHours() <10?'0'+date.getHours() :date.getHours() )+ ':';
                m = (date.getMinutes() <10?'0'+date.getMinutes() :date.getMinutes() ) + ':';
                s = (date.getSeconds() <10?'0'+date.getSeconds() :date.getSeconds() );
                return(Y+M+D+h+m+s);*/
                return this.formatDate(data.responseTime,'yyyy-MM-dd hh:mm:ss');
            },
            current_change:function(pageNo){
                this.pageNo = pageNo;
                this.tableData=[];
                this.fetchData();
            },
            handleSelectionChange:function(){
            },
            search_change:function(){
                this.tableData=[];
                this.fetchData();
            }
        }
    }
    var Ctor = Vue.extend(Main)
    new Ctor().$mount('#app')
</script>
</html>