# Docker Swarm集群搭建教程

现阶段，Docker容器技术已经相当成熟，就算是中小型公司也可以基于 Gitlab、Aliyun镜像服务、Docker Swarm 轻松搭建自己的 Docker集群服务。

## 搭建自己的Gitlab

### 安装Gitlab

```
sudo docker run -d --hostname gitlab.xxx.cn \
--publish 443:443 --publish 80:80 --publish 422:22 \
--name gitlab --restart always --volume /srv/gitlab/config:/etc/gitlab \
--volume /srv/gitlab/logs:/var/log/gitlab \
--volume /srv/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest
```

### 安装gitlab-runner

[官方地址](https://docs.gitlab.com/runner/install/linux-repository.html)

> 后续完善DEMO

### 注册 gitlab-runner

```
$ gitlab-runner register

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://gitlab.xxx.cc/
Please enter the gitlab-ci token for this runner:
xxxxx
Please enter the gitlab-ci description for this runner:
xxx
Please enter the gitlab-ci tags for this runner (comma separated):
test-vpc
Please enter the executor: docker-ssh, shell, docker+machine, docker-ssh+machine, docker, parallels, ssh, virtualbox, kubernetes:
shell
```

