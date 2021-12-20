# Amazon EKS Basic

## Installing latest AWS CLI version 2.


```other
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"  

unzip awscliv2.zip  

sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update  

aws --version

```


## Configuring AWS CLI


```other
aws configure set aws_access_key_id <your_access_key_id>
    
aws configure set aws_secret_access_key <your_secret_access_key>
    
aws configure set default.region <your_default region>>
```


## Installing or upgrading `eksctl`


```other
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp 
		
mv /tmp/eksctl /usr/local/bin
    
eksctl version
```


## Installing `kubectl`


```other
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl

chmod +x ./kubectl

mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

kubectl version --short --client
```


## Using `eksctl` to create a EKS cluster


```other
eksctl create cluster 
--name dev-cluster 
--region us-east-1 
--zones us-east-1a,us-east-1b,us-east-1c 
--nodegroup-name standard-workders 
--node-type t3.micro 
--nodes 3 
--nodes-min 1 
--nodes-max 4 
--managed
```

