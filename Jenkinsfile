pipeline{
    agent none
    // specify your agent details or else specify none
    parameters{
        base64File "INPUTYAML"
    }
    stages {
        stage('main') {
            steps {
                sh 'ls'
            }
        }
        stage('job1') {
            steps {
                script {
                    job1res = build job: "job1", parameters: [base64File(name: 'INPUTYAML')]
                    env.job1buildno = job1res.number
                }
            }
        }
        stage('job2') {
            steps {
                script {
                    job2res = build job: "job2", parameters: [base64File(name: 'INPUTYAML')]
                    env.job2buildno = job2res.number
                }
            }
        }
        stage('job3') {
            steps {
                script {
                    job3res = build job: "job3", parameters: [base64File(name: 'INPUTYAML')]
                    env.job3buildno = job3res.number
                }
            }
        }
    }
    post {
        always {
            notify_email()
        }
    }
}
def notify_email() {
    step([$class: 'CopyArtifact', filter: 'testfile.txt', projectName: 'job1', selector: specific('${job1buildno}')])
    script {
        sh """
        chmod +x sendgrid.sh
        SUBJECT="Test reporting"
        SENDGRID_API_KEY=\${add your key}
        FROM_NAME="Testing"
        FROM_EMAIL="user1@gmail.com"
        EMAIL_TO="user2@gmail.com"
        CC_EMAIL="user3@gmail.com"
        Result=\$(grep result testfile.txt | cut -d ':' -f '2' | sed 's/^ *//g')
        Time=\$(grep timetaken testfile.txt | cut -d ':' -f '2' | sed 's/^ *//g')
        Url=\$(grep joburl testfile.txt | cut -d ':' -f '2' | sed 's/^ *//g')
        MESSAGE="<html><head> <style> </style> </head> 
        <body> 
        <table style='border:1px solid #000000;width:900px;margin:0;'> 
        <tr> <th style='border: 1px solid #000000;width:900px;margin:0;text-align:center'> Status </th> 
        <th style='border: 1px solid #000000;width:900px;margin:0;text-align:center'> Time </th> 
        <th style='border: 1px solid #000000;width:900px;margin:0;text-align:center'> Job URL </th> </tr>
        <tr> <td style='border: 1px solid #000000;width:900px;margin:0;text-align:center'> \${Result} </td> 
        <td style='border: 1px solid #000000;width:900px;margin:0;text-align:center'> ${Time} </td> 
        <td style='border: 1px solid #000000;width:900px;margin:0;text-align:center'> \${Url} </td> </tr>
        </table> </body> </html>"
        
        ./sendgrid.sh -k "\${SENDGRID_API_KEY}" -n "\${FROM_NAME}" -e "\${FROM_EMAIL}" -s "\${SUBJECT}" -t "\${EMAIL_TO}" -c "\${CC_EMAIL}" -o "\${MESSAGE}"
        """
    }
}