# MachineLearning-docker
----------------------
[Doc](https://lizequn.github.io/2019/02/03/GPU-supported-Machine-Learning-docker/)

----------------------
### GPU docker

- cuda          10.0           
- cudnn         v7             
- python        3.6            
- anaconda      5.2.0 
- Jupyter Notebook @:8888        
- Xgboost       latest(gpu)       
- lightgbm      latest(gpu)   
- tensorflow    1.13.0rc0(pip) 
- tensorboard   latest (pip) @:6006   
- pytorch       latest(pip) 
- torchvision   latest (pip) 
- keras         latest (pip)

-----------------------
### CPU docker
-python        3.6
-anaconda      5.2.0
-Jupyter Notebook @:8888  
-AwS api       boto3(pip)
-Xgboost       latest(pip)
-lightgbm      latest

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
- run gpu docker
```
sudo docker run --runtime=nvidia --rm -d -p 8888:8888 -p 6006:6006 --name ml-gpu -e PASSWORD= -v /home/ubuntu/notebook:/notebook <image-name>
```
- run cpu docker
```
sudo docker run --rm -d -p 8888:8888 --name ml-cpu -e PASSWORD= -v /home/ubuntu/notebook:/notebook <image-name>
```
