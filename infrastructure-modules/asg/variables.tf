#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "terraform-environment"
}


# Launch Template and ASG Variables
variable "instance_type" {
  description = "launch template EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "target_group_arn_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "asg_security_group_id" {
  type = string
}
#This user data variable indicates that the script configures Apache on a server.
variable "ec2_user_data" {
  description = "variable indicates that the script configures Apache on a server"
  type        = string
  default     = <<EOF
#!/bin/bash

# Update package index
sudo apt-get update -y
sudo apt-get install -y apache2 unzip

# Fetching the token for IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`

# Install Python3 virtual environment package
sudo apt install -y software-properties-common
yes '' | sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

sudo apt install -y python3.9  python3.9-venv

sudo apt install -y
# Clone repository
cd /home/ubuntu/
git clone https://github.com/lhdlam/Django-ECommerce-2024.git

# Navigate to the repository directory
cd /home/ubuntu/Django-ECommerce-2024

# Create virtual environment
python3.9 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt 

# Install Gunicorn
pip install gunicorn

# Create directory for Gunicorn logs
sudo mkdir /var/log/gunicorn

# Create and edit gunicorn socket file
sudo tee /etc/systemd/system/gunicorn.socket > /dev/null <<EOT
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target
EOT

# Create and edit gunicorn service file
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOT
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/Django-ECommerce-2024
ExecStart=/home/ubuntu/Django-ECommerce-2024/venv/bin/gunicorn \
        --access-logfile - \
        --workers 3 \
        --bind unix:/run/gunicorn.sock \
        demo.wsgi:application

[Install]
WantedBy=multi-user.target
EOT

# Start gunicorn socket
sudo systemctl start gunicorn.socket

# Enable gunicorn socket to start on boot
sudo systemctl enable gunicorn.socket

# Reload daemon to apply changes
sudo systemctl daemon-reload

# Restart gunicorn service
sudo systemctl restart gunicorn

# Install Nginx
sudo apt-get install -y nginx

# Run Django collectstatic command
python manage.py collectstatic

# Add www-data user to django group
sudo gpasswd -a www-data ubuntu

# Get public IPv4 address using IMDSv2
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

# Create and edit Nginx server block file
sudo tee /etc/nginx/sites-available/django_website > /dev/null <<EOT
server {
    listen 80;
    server_name $PUBLIC_IP;

    location = /favicon.ico { access_log off; log_not_found off; }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }

    location  /static/ {
        root /home/ubuntu/Django-ECommerce-2024;
        access_log off;
    }

    location  /media/ {
        root /home/ubuntu/Django-ECommerce-2024;
       access_log off;
    }
}
EOT

# Enable Nginx server block
sudo ln -s /etc/nginx/sites-available/django_website /etc/nginx/sites-enabled

sudo service apache2 stop

sudo rm /etc/nginx/sites-enabled/default

# Restart Nginx
sudo systemctl restart nginx

# Allow Nginx through firewall
sudo ufw allow 'Nginx Full'

# Reload Nginx
sudo nginx -s reload
EOF
}