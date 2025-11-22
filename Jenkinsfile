pipeline {
    agent {
        node {
            label 'maven'
        }
    }
environment {
    PATH = "/opt/apache-maven-3.9.11/bin:$PATH"
    
}
   stages {
        stage("build"){
            steps {
                 echo "----------- build started ----------"
                sh 'mvn package'
                 echo "----------- build complted ----------"
            }
        }
}
}

