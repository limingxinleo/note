# 删除本地tag，并推送到远程

git tag -d $1 && git push origin --delete $1
