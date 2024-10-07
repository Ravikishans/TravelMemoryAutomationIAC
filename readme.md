sudo scp -i /home/ravikishans/raviAWS.pem /home/ravikishans/raviAWS.pem ubuntu@${aws_instance.frontend_server.public_ip}:/home/ubuntu
