# langimage
LLM apps development air-gapped image.


```bash
docker build . -t langimage:cuda126-base -f ./cuda126.dockerfile

# cpu
docker run --name langimage -v $(pwd):/workspace/app --privileged -p 8888:8888 langimage:cuda126-base
# gpu
docker run --name langimage -v $(pwd):/workspace/app --shm-size=1g --gpus all --privileged -p 8888:8888 langimage:cuda126-base

# code-server 密码在容器里的 /root/.config/code-server/config.yaml
docker exec -it langimage cat /root/.config/code-server/config.yaml
```

国内镜像加速
1. 清华 conda：https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/
2. 清华 code-server：https://mirrors.tuna.tsinghua.edu.cn/help/pypi/