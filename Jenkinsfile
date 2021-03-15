pipeline {
  agent {
    kubernetes {
      yaml '''
kind: Pod
metadata:
  name: kaniko
spec:
  volumes:
    - name: kaniko-cache
      nfs: 
        server: nas.crazyzone.be 
        path: /volume1/docker-storage/kaniko/cache
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor@sha256:e00dfdd4a44097867c8ef671e5a7f3e31d94bd09406dbdfba8a13a63fc6b8060
    imagePullPolicy: Always
    tty: true
    command:
    - sleep
    - infinity
    volumeMounts:
    - name: kaniko-cache
      mountPath: /cache
  - name: kaniko-warmer
    image: twistedvines/kaniko-executor:latest
    imagePullPolicy: Always
    tty: true
    command:
    - '/busybox/cat'
    volumeMounts:
    - name: kaniko-cache
      mountPath: /cache      
'''
    }

  }
  stages {
    stage('build') {
      steps {
        container(name: 'kaniko-warmer', shell: '/busybox/sh') {
          sh '''#!/busybox/sh 
/kaniko/warmer --cache-dir=/cache --image=httpd:latest
          '''
        }        
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh 
REPO=registry.crazyzone.be
NAME=kickstart
VERSION=`cat VERSION`
if [[ $GIT_LOCAL_BRANCH == "main" || $GIT_LOCAL_BRANCH == "master" ]];
then
  TAG=latest
else
  TAG=$GIT_LOCAL_BRANCH
fi
/kaniko/executor --dockerfile Dockerfile --context `pwd`/ --verbosity debug --destination $REPO/$NAME:$TAG --destination $REPO/$NAME:$VERSION --cache=true --cache-repo $REPO/cache
            '''
        }
      }
    }

  }
}