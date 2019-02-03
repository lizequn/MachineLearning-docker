# ML-GPU-docker
## NEED test ! 
----------------------
ML GPU docker

- cuda          10.0           
- cudnn         v7             
- python        3.7            
- anaconda      2018.12          
- Xgboost       0.6(gpu)       
- lightgbm      2.0.10(gpu)   
- tensorflow    1.4.0(pip)    
- pytorch       latest(pip)  
- keras         included in Tensorflow

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