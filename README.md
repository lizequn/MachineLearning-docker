# ML-GPU-docker
----------------------
ML GPU docker

- cuda          8.0            
- cudnn         v6             
- python        3.6            
- anaconda      5.0.1          
- Xgboost       0.6(gpu)       
- lightgbm      2.0.10(gpu)   
- tensorflow    1.4.0(pip)    
- pytorch       latest(pip)  
- keras         latest(pip)   

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