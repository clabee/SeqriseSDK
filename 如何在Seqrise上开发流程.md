
## 开发流程

## 简介
为了给生物医学工作者提供专业易用的基因数据分析服务，深圳云蜂生物技术有限公司（以下简称云蜂生物）开发了Seqrise分析平台，除基本的数据存储和计算功能外，平台上部署了常用的公共数据和专业的NGS分析流程，同时提供云端协作和数据分享等功能。使用Seqrise，用户不需要搭建昂贵的服务器，不需要学习编程，通过简洁易用的web界面，只需上传数据和运行分析流程两步，任何一个生物医学科研工作者就可以在Seqrise上完成一个专业的生物信息分析人员才能完成的数据分析工作。

Seqrise开放了流程开发功能，开发者可以使用Seqrise提供的流程开发SDK，在本地开发流程和测试，测试通过后，把流程上传到Seqrise上，在Seqrise上即可看到带有web操作界面的流程。

## 开发流程
开发Seqrise平台的分析流程，整个过程如下面的流程图所示
```
graph TB
A(本地创建工具docker镜像)-->B(把工具的docker镜像推送到Seqrise docker仓库)
B-->C(在Seqrise开发者页面上填写工具信息)
C-->D(在Seqrise开发者页面上创建流程)
D-->E(添加工具到流程中)
E-->F(导出流程的workflow.json和input.json)
F-->G(下载Seqrise流程开发SDK到本地)
G-->H(调用使用Seqrise SDK开发流程)
H-->I(修改input.json把里面的文件改成实际文件路径)
I-->J(本地测试流程)
J-->K(上传流程到Seqrise开发者页面)
K-->L(登录Seqrise测试流程)
```

### 本地创建工具docker镜像
更多信息请参考[docker](docker.com）网站[创建工具docker镜像](https://docs.docker.com/engine/getstarted/step_four/)

### 把工具的docker镜像推送到Seqrise docker仓库
### 在Seqrise开发者页面上填写工具信息
### 在Seqrise开发者页面上创建流程
### 添加工具到流程中
### 导出流程的workflow.json和input.json
### 下载Seqrise流程开发SDK到本地
### 调用使用Seqrise SDK开发流程


### 修改input.json把里面的文件改成实际文件路径
### 本地测试流程
### 上传流程到Seqrise开发者页面
### 登录Seqrise测试流程
