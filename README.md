# ML-GPU-docker
## NEED test ! 
----------------------
ML GPU docker

- cuda          10.0           
- cudnn         v7             
- python        3.6            
- anaconda      5.2.0         
- Xgboost       latest(gpu)       
- lightgbm      latest(gpu)   
- tensorflow    latest(pip)    
- pytorch       latest(pip)  


-----------------------
- install docker env
``` 
sudo bash ./docker_install.sh
```
- pull docker from AWS ecr 
```
aws configure
aws ecr get-login --no-include-email > login.sh
sudo bash ./login.sh
sudo rm login.sh
sudo docker pull url:tag
```
- run docker
```
sudo docker run --runtime=nvidia --rm -d -p 8888:8888 --name ml-gpu -e PASSWORD= -v /home/ubuntu/notebook:/notebook image-name
```