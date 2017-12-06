// Stand-alone test (cleanup before and after; does not retain container or persistent volumes)
pipeline {
    agent any
    stages {
        stage('Cleanup container, volumes') {
            steps {
                sh '''
                    rm conf.sh 2> /dev/null || true
                    ln -sf conf.sh.default conf.sh
                    ./dscripts/manage.sh rm 2>/dev/null || true
                    ./dscripts/manage.sh rmvol 2>/dev/null || true
                '''
            }
        }
        stage('Build-Run-Test') {
            steps {
                build job: '/shib/d-shibsp.bst'
            }
        }
    }
    post {
        always {
            echo 'Remove container, volumes'
            sh '''
                ./dscripts/manage.sh rm 2>/dev/null || true
                ./dscripts/manage.sh rmvol 2>/dev/null || true
            '''
        }
    }
}