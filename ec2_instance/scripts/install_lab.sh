#!/bin/bash

apt-get update -y
apt-get install -y curl vim nginx git php-fpm

systemctl enable nginx && systemctl start nginx

cat > /var/www/html/index.php << 'EOF'
<?php 
$input = filter_var($_POST['input'], FILTER_VALIDATE_URL);
$command = "curl $input";
$output = system($command);
?>
<!DOCTYPE html>
<html>
<body>

<form action="index.php" method="post">
Enter URL to curl :
   <input type="text" name="input" id="input">
   <input type="submit" value="Launch" name="submit">
</form>
</body>
</html>
EOF

cat > /etc/nginx/sites-available/default << 'EOF'
server {
  # Example PHP Nginx FPM config file
  listen 80 default_server;
  listen [::]:80 default_server;
  root /var/www/html;
  keepalive_timeout 0;

  index index.php;

  server_name _;

  location / {
    try_files $uri $uri/ /index.php;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    # Nginx php-fpm sock config:
    fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    # Nginx php-cgi config :
    # Nginx PHP fastcgi_pass 127.0.0.1:9000;
  }
}
EOF

echo "<?php phpinfo(); ?>" >> /var/www/html/info.php

chmod -R 755 /var/www/html

systemctl restart nginx