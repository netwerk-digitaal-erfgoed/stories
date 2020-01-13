properties([pipelineTriggers([githubPush()])])
podTemplate(label: 'jenkins-slave', containers: [
    containerTemplate(name: 'git', image: 'alpine/git', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl', command: 'cat', ttyEnabled: true)
  ],
  volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
  ]
  ) {
    node('jenkins-slave') {
        def secrets = [
            [path: 'secret/docker', engineVersion: 1, secretValues: [
                [envVar: 'DOCKER_PSW', vaultKey: 'DOCKER_PSW'],
                [envVar: 'DOCKER_USR', vaultKey: 'DOCKER_USR']]]
        ]
        def configuration = [vaultUrl: 'http://vault-helm.default.svc.cluster.local:8200',
                            vaultCredentialId: 'vault', engineVersion: 1]

        git url: 'https://github.com/samleeflang/stories.git', branch: 'master'

        stage('Clone repository') {
            container('git') {
                sh 'git clone -b master  https://github.com/samleeflang/stories'
            }
        }

        stage('Docker Build & Push') {
            container('docker') {
                dir('stories/') {
                    withVault([configuration: configuration, vaultSecrets: secrets]) {
                        sh 'docker login https://harbor.harbor.svc.cluster.local/nde -u $DOCKER_USR -p $DOCKER_PSW'
                        sh 'docker build . -t https://harbor.harbor.svc.cluster.local/nde/nde-stories'
                        sh 'docker push https://harbor.harbor.svc.cluster.local/nde/nde-stories'
                    }
                }
            }
        }

        stage('Automatical deploy to kubernetes') {
            container('kubectl') {
                dir('stories/') {
                    sh 'kubectl apply -f k8s'
                    sh 'kubectl delete pod -l app=nde-stories'
                }
            }
        }
    }
}
