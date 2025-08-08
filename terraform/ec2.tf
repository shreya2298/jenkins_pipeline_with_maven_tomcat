resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  key_name                    = aws_key_pair.deployer.key_name

 user_data = <<-EOF
              #!/bin/bash

              sudo apt update
              sudo apt install openjdk-17-jdk -y

              # ---------------- Jenkins Installation ----------------
              wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list
              apt update -y
              apt install jenkins -y
              systemctl enable jenkins

              # Override default port to 8082 using systemd drop-in file
              mkdir -p /etc/systemd/system/jenkins.service.d
              
              cat <<EOT > /etc/systemd/system/jenkins.service.d/override.conf
              [Service]
              Environment="JENKINS_PORT=8082"
              EOT

              systemctl daemon-reload
              systemctl restart jenkins

              ---------------- Tomcat Installation ----------------
              cd /opt/
              wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz
              tar -xvf apache-tomcat-9.0.65.tar.gz
              chmod +x /opt/apache-tomcat-9.0.65/bin/*.sh

              ln -s /opt/apache-tomcat-9.0.65/bin/startup.sh /usr/bin/startTomcat
              ln -s /opt/apache-tomcat-9.0.65/bin/shutdown.sh /usr/bin/stopTomcat

              sed -i 's/<Valve className="org.apache.catalina.valves.RemoteAddrValve.*\\/\\>//' /opt/apache-tomcat-9.0.65/webapps/manager/META-INF/context.xml
              sed -i 's/<Valve className="org.apache.catalina.valves.RemoteAddrValve.*\\/\\>//' /opt/apache-tomcat-9.0.65/webapps/host-manager/META-INF/context.xml

              /opt/apache-tomcat-9.0.65/bin/startup.sh
              EOF


  tags = {
    Name = "Jenkins_Tomcat_server"
  }
}

output "ssh_command" {
  value = "ssh ubuntu@${aws_instance.web.public_ip}"
}
