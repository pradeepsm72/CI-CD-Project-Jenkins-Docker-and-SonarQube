# CI/CD Pipeline using Jenkins, Docker, and SonarQube

## Project Description
This project sets up a **CI/CD pipeline** using **Jenkins, Docker, and SonarQube** to automate code building, testing, security analysis, and deployment. The pipeline ensures high code quality and security while deploying containerized applications.

## Technologies Used
- **Jenkins**: For automating the CI/CD pipeline.
- **Docker**: For containerizing the application.
- **SonarQube**: For code quality and security analysis.
- **Git**: For version control.
- **Maven/Gradle**: For building Java applications (optional, based on project requirements).
- **Kubernetes (Optional)**: For deploying the containerized application.

---
## Step 1: Install and Configure Jenkins
### 1.1 Install Jenkins on Ubuntu
```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
```
### 1.2 Access Jenkins
- Open your browser and go to: `http://<your-server-ip>:8080`
- Unlock Jenkins using:
  ```bash
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```
- Install suggested plugins and create an admin user.

---
## Step 2: Install and Configure Docker
### 2.1 Install Docker
```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
```
### 2.2 Verify Docker Installation
```bash
docker --version
```

---
## Step 3: Install and Configure SonarQube
### 3.1 Install SonarQube on Ubuntu
```bash
sudo apt update
sudo apt install unzip
sudo mkdir /opt/sonarqube
cd /opt/sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.1.zip
unzip sonarqube-9.9.1.zip
sudo useradd -r -s /bin/false sonar
sudo chown -R sonar:sonar /opt/sonarqube
```
### 3.2 Start SonarQube
```bash
su - sonar
cd /opt/sonarqube/sonarqube-9.9.1/bin/linux-x86-64/
./sonar.sh start
```
- Access SonarQube at: `http://<your-server-ip>:9000`
- Default login: **admin/admin** (Change password after first login)

---
## Step 4: Configure Jenkins with SonarQube and Docker
### 4.1 Install Jenkins Plugins
- Install the following plugins from `Manage Jenkins > Manage Plugins`:
  - **Docker Plugin**
  - **SonarQube Scanner Plugin**
  - **Pipeline Plugin**

### 4.2 Configure SonarQube in Jenkins
- Go to `Manage Jenkins > Global Tool Configuration`.
- Add a new SonarQube Scanner with a proper name and SonarQube installation directory.
- Configure SonarQube server details under `Manage Jenkins > Configure System`.

---
## Step 5: Create Jenkins Pipeline
### 5.1 Create a New Pipeline Job
- Go to **Jenkins Dashboard > New Item**.
- Choose **Pipeline** and enter the job name.
- In the **Pipeline** section, select **Pipeline script from SCM**.
- Provide the Git repository URL where your **Jenkinsfile** is stored.

### 5.2 Create a Jenkinsfile
Create a `Jenkinsfile` in the project repository with the following steps:
```groovy
pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://<your-sonarqube-server>:9000'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t myapp:latest .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker tag myapp:latest mydockerhubusername/myapp:latest'
                    sh 'docker push mydockerhubusername/myapp:latest'
                }
            }
        }
    }
}
```

---
## Step 6: Run the Pipeline
- Save the pipeline and click **Build Now**.
- Monitor the build logs and ensure each stage completes successfully.
- Check SonarQube for code quality reports.
- Verify the Docker image is pushed to the repository.

---
## Step 7: Deploy the Docker Container
To deploy the Docker container, run:
```bash
docker run -d -p 8080:8080 mydockerhubusername/myapp:latest
```
Or deploy it to Kubernetes:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: mydockerhubusername/myapp:latest
        ports:
        - containerPort: 8080
```
Apply it using:
```bash
kubectl apply -f deployment.yaml
```

---
## Conclusion
You have successfully set up a **CI/CD pipeline using Jenkins, Docker, and SonarQube**. This ensures automated code testing, security scanning, and deployment, improving software quality and reducing manual effort.

