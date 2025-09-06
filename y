 80;
    server_name _;

    root /home/ubuntu/apps/bolokobul/current/public;

    location / {
        proxy_pass http://unix:/home/ubuntu/apps/bolokobul/shared/tmp/sockets/bolokobul-puma.sock;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 20M;
    keepalive_timeout 10;
}server {
    listen 80;
    server_name _;

    root /home/ubuntu/apps/bolokobul/current/public;

    location / {
        proxy_pass http://unix:/home/ubuntu/apps/bolokobul/shared/tmp/sockets/bolokobul-puma.sock;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 20M;
    keepalive_timeout 10;
}



