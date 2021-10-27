# Golang Dockerfile 样例

## 常用

```dockerfile
FROM golang:1.17 as builder

LABEL maintainer="limx <l@hyperf.io>"

WORKDIR /go/builder

ADD go.mod .
ADD go.sum .
RUN go mod download

ADD . .

RUN go mod download

# 当CGO_ENABLED=1， 进行编译时， 会将文件中引用libc的库（比如常用的net包），以动态链接的方式生成目标文件。
# 当CGO_ENABLED=0， 进行编译时， 则会把在目标文件中未定义的符号（外部函数）一起链接到可执行文件中。
# -ldflags 其中-w为去掉调试信息（无法使用gdb调试），-s为去掉符号表
RUN GOOS=linux CGO_ENABLED=0 go build -ldflags="-s -w" -o main main.go

FROM scratch

COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/builder /

EXPOSE 9501

ENTRYPOINT ["/main"]
```
